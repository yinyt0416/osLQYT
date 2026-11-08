#!/bin/bash
# Inside PERIOD image: Period (run_PDS/SBPMESched) vs Serial (mounted run_Serial.py / SBPSched)
set -u
ROOT_DIR=${ROOT_DIR:-/workdir/PERIOD}
BUDGET=${BUDGET:-10000}
TIMEOUT_S=${TIMEOUT_S:-480}
SUBJECTS=${SUBJECTS_FILE:-/tmp/rq1_subjects.tsv}
SERIAL_PY=${SERIAL_PY:-/tmp/run_Serial.py}
mkdir -p /out/logs
# Install Serial wrapper beside DBDS (ABI-compatible)
if [ -f "$SERIAL_PY" ]; then
  cp "$SERIAL_PY" "$ROOT_DIR/tool/DBDS/run_Serial.py"
  chmod +x "$ROOT_DIR/tool/DBDS/run_Serial.py"
fi
summary=/out/rq1_summary.tsv
echo -e "subject\tmode\trunner\tdepth\tbudget\terrors\tschedules\tfirst_bug_sched\tduration_s\tstatus\tnotes" > "$summary"

count_tests() {
  # ANSI-safe: match "test NNNN:" anywhere
  grep -cE 'test [0-9]+:' "$1" 2>/dev/null | head -1 || echo 0
}

run_one() {
  local subject="$1" rel="$2" bin="$3" depth="$4" mode="$5" runner="$6"
  local dir="$ROOT_DIR/$rel"
  local log=/out/logs/${subject}_${mode}.log
  echo "===== RQ1 $subject mode=$mode runner=$runner =====" | tee "$log"
  if [ ! -d "$dir" ]; then
    echo -e "${subject}\t${mode}\t${runner}\t${depth}\t${BUDGET}\tNA\tNA\tNA\tNA\tBLOCKED\tmissing $rel" | tee -a "$summary"
    return
  fi
  (
    set -e
    cd "$dir"
    [ -x ./cleanDIR.sh ] && ./cleanDIR.sh || true
    ./build.sh
    [ -x "./$bin" ] || { ls -la; exit 3; }
  ) >>"$log" 2>&1 || {
    echo -e "${subject}\t${mode}\t${runner}\t${depth}\t${BUDGET}\tNA\tNA\tNA\tNA\tFAIL_BUILD\tsee log" | tee -a "$summary"
    return
  }
  cd "$dir"
  rm -rf out_* 2>/dev/null || true
  ipcrm -M 1111 2>/dev/null || true
  local t0 t1 rc=0 dur
  t0=$(date +%s.%N)
  timeout -k 15 "$TIMEOUT_S" python3 -u "$ROOT_DIR/tool/DBDS/$runner" -y -d "$depth" -f "$BUDGET" "./$bin" >>"$log" 2>&1 || rc=$?
  t1=$(date +%s.%N)
  dur=$(awk -v b="$t0" -v c="$t1" 'BEGIN{printf "%.3f", c-b}')
  local errors schedules first status note
  errors=$(grep -oE 'Total Error Interleavings: [0-9]+' "$log" 2>/dev/null | tail -1 | grep -oE '[0-9]+$' || true)
  errors=${errors:-0}
  schedules=$(count_tests "$log")
  schedules=$(echo "$schedules" | tr -d '\n' | head -c 20)
  first=$(awk '/\[Error Found\]/{print NR; exit}' "$log")
  if [ -n "${first:-}" ]; then
    first=$(awk -v cut="$first" 'NR<cut && /test [0-9]+:/{c++} END{print c+0}' "$log")
  else
    first=NA
  fi
  status=OK
  note="rc=$rc"
  if grep -q 'End Testing!' "$log" 2>/dev/null; then
    if [ "${errors:-0}" -gt 0 ] 2>/dev/null; then status=BUGS_OK; fi
  else
    status=INCOMPLETE
  fi
  [ "$rc" -eq 124 ] && { status=TIMEOUT; note="$note; TIMEOUT_${TIMEOUT_S}s"; }
  [ "$rc" -eq 139 ] && { status=FAIL_SEGV; note="$note; SEGV stock_OldPDS_ABI_mismatch_or_crash"; }
  # Budget hit only if rounds exceeded (not mere presence of runs_limit print)
  if grep -qE 'reach_runs_limit|schedules>=budget' "$log" 2>/dev/null; then
    note="$note; BUDGET_HIT"
  elif [ "${schedules:-0}" -ge "$BUDGET" ] 2>/dev/null; then
    note="$note; schedules>=budget"
  fi
  if grep -q '\[Serial\]' "$log" 2>/dev/null; then
    note="$note; $(grep '\[Serial\]' "$log" | head -1 | tr '\t' ' ')"
  fi
  echo -e "${subject}\t${mode}\t${runner}\t${depth}\t${BUDGET}\t${errors}\t${schedules}\t${first}\t${dur}\t${status}\t${note}" | tee -a "$summary"
}

tail -n +2 "$SUBJECTS" | while IFS=$'\t' read -r subject rel bin depth notes; do
  [ -z "${subject:-}" ] && continue
  run_one "$subject" "$rel" "$bin" "$depth" Period run_PDS.py
  run_one "$subject" "$rel" "$bin" "$depth" Serial run_Serial.py
done

echo "==== RQ1 DONE $(date -Is) ====" | tee -a "$summary"
cat "$summary"
