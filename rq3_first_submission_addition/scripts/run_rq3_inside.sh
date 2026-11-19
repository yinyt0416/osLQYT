#!/bin/bash
# Inside PERIOD image: native wall-time vs Period; CSV with schedules/sec.
set -u
ROOT_DIR=${ROOT_DIR:-/workdir/PERIOD}
NATIVE_REPEATS=${NATIVE_REPEATS:-5}
TIMEOUT_S=${TIMEOUT_S:-300}
BUDGET=${BUDGET:-10000}
SUBJECTS=${SUBJECTS_FILE:-/tmp/rq3_subjects.tsv}
mkdir -p /out/logs
summary=/out/rq3_overhead.csv
echo "subject,tool,native_s,tool_s,slowdown,schedules,sched_per_s,errors,status,notes" > "$summary"

avg_time() {
  local n=$1; shift
  local sum=0
  local i
  for i in $(seq 1 "$n"); do
    local t0 t1
    t0=$(date +%s.%N)
    "$@" >/dev/null 2>&1 || true
    t1=$(date +%s.%N)
    sum=$(awk -v a="$sum" -v b="$t0" -v c="$t1" 'BEGIN{printf "%.6f", a+(c-b)}')
  done
  awk -v s="$sum" -v n="$n" 'BEGIN{printf "%.6f", s/n}'
}

count_tests() {
  local c
  c=$(grep -cE 'test [0-9]+:' "$1" 2>/dev/null || true)
  echo "${c:-0}"
}

tail -n +2 "$SUBJECTS" | while IFS=$'\t' read -r subject rel bin depth priority notes; do
  [ -z "${subject:-}" ] && continue
  dir="$ROOT_DIR/$rel"
  log=/out/logs/${subject}.log
  echo "===== RQ3 overhead $subject =====" | tee "$log"
  if [ ! -d "$dir" ]; then
    echo "${subject},Period,NA,NA,NA,NA,NA,NA,BLOCKED,missing dir $rel" | tee -a "$summary"
    continue
  fi
  (
    set -e
    cd "$dir"
    [ -x ./cleanDIR.sh ] && ./cleanDIR.sh || true
    ./build.sh
    [ -x "./$bin" ] || { ls -la; exit 3; }
  ) >>"$log" 2>&1 || {
    echo "${subject},Period,NA,NA,NA,NA,NA,NA,FAIL_BUILD,see log" | tee -a "$summary"
    continue
  }
  cd "$dir"
  rm -rf out_* 2>/dev/null || true
  ipcrm -M 1111 2>/dev/null || true

  native_s=$(avg_time "$NATIVE_REPEATS" timeout 30 "./$bin")
  echo "native_avg=${native_s}s repeats=$NATIVE_REPEATS" >>"$log"

  t0=$(date +%s.%N)
  rc=0
  # No -o: keep Error Interleavings counts; wall time still measured around full run
  timeout -k 10 "$TIMEOUT_S" python3 -u $ROOT_DIR/tool/DBDS/run_PDS.py -y -d "$depth" -f "$BUDGET" "./$bin" >>"$log" 2>&1 || rc=$?
  t1=$(date +%s.%N)
  tool_s=$(awk -v b="$t0" -v c="$t1" 'BEGIN{printf "%.6f", c-b}')
  errors=$(grep -oE 'Total Error Interleavings: [0-9]+' "$log" | tail -1 | grep -oE '[0-9]+$' || true)
  errors=${errors:-0}
  schedules=$(count_tests "$log")
  slowdown=NA
  sps=NA
  if awk -v n="$native_s" 'BEGIN{exit !(n+0>0)}'; then
    slowdown=$(awk -v t="$tool_s" -v n="$native_s" 'BEGIN{printf "%.2f", t/n}')
  fi
  if awk -v t="$tool_s" 'BEGIN{exit !(t+0>0)}'; then
    sps=$(awk -v s="$schedules" -v t="$tool_s" 'BEGIN{printf "%.4f", s/t}')
  fi
  status=OK
  note="rc=$rc priority=$priority; native=instrumented_bin_no_scheduler"
  [ "$rc" -eq 124 ] && { status=TIMEOUT; note="$note;TIMEOUT"; }
  grep -q 'End Testing!' "$log" 2>/dev/null || status=INCOMPLETE
  echo "${subject},Period,${native_s},${tool_s},${slowdown},${schedules},${sps},${errors},${status},${note}" | tee -a "$summary"
done

for tool in IPB IDB PCT; do
  echo "ALL_CURATED,${tool},NA,NA,NA,NA,NA,NA,NOT_RUN,need sctbench ${tool}; kernel=$(uname -r) Pin needs <=3.x" >> "$summary"
done
echo "native_ref,native,NA,NA,1.0,NA,NA,NA,REF,baseline=1x by definition" >> "$summary"

echo "==== RQ3 DONE $(date -Is) ====" | tee -a "$summary"
cat "$summary"
