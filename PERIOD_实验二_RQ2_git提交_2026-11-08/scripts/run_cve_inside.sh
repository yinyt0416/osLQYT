#!/bin/bash
# Run inside PERIOD docker image. Depths mirror paper/README examples (≤5).
set -u
ROOT_DIR=${ROOT_DIR:-/workdir/PERIOD}
export ROOT_DIR
mkdir -p /out/logs /out/results
summary=/out/results/summary_cve.tsv
echo -e "subject\tstatus\terrors\ttimeouts\ttests\tduration_s\tdepth\tlog" > "$summary"

run_one() {
  local name="$1" dir="$2" bin="$3" depth="$4"
  local log=/out/logs/${name}.log
  local t0=$(date +%s) rc=0
  echo "===== BUILD+RUN $name (depth=$depth) =====" | tee "$log"
  (
    set -e
    cd "$dir"
    [ -x ./cleanDIR.sh ] && ./cleanDIR.sh
    [ -x ./build.sh ] || { echo no_build; exit 2; }
    ./build.sh
    [ -x "./$bin" ] || { ls -la; exit 3; }
    timeout 1800 $ROOT_DIR/tool/DBDS/run_PDS.py -y -d "$depth" "./$bin"
  ) >>"$log" 2>&1 || rc=$?
  local t1=$(date +%s) dur=$((t1-t0))
  local errors=$(grep -oE 'Total Error Interleavings: [0-9]+' "$log" | tail -1 | grep -oE '[0-9]+$' || echo NA)
  local timeouts=$(grep -oE 'Total Timeouts Interleavings: [0-9]+' "$log" | tail -1 | grep -oE '[0-9]+$' || echo NA)
  local tests=$(grep -cE 'test [0-9]+:' "$log" || echo 0)
  local status=OK
  if [ "$rc" -eq 124 ]; then status=TIMEOUT; elif [ "$rc" -ne 0 ]; then status="FAIL_RC${rc}"; fi
  if ! grep -q 'End Testing!' "$log"; then status="INCOMPLETE_${status}"; fi
  if [ "$errors" != "NA" ] && [ "$errors" != "0" ]; then status="BUGS_${status}"; fi
  echo -e "${name}\t${status}\t${errors}\t${timeouts}\t${tests}\t${dur}\t${depth}\t${log}" | tee -a "$summary"
}

run_one CVE-2016-7911 "$ROOT_DIR/evaluation/ConVul-CVE-Benchmarks/CVE-2016-7911" 2016-7911 3
run_one CVE-2009-3547 "$ROOT_DIR/evaluation/ConVul-CVE-Benchmarks/CVE-2009-3547" 2009-3547 1
run_one CVE-2011-2183 "$ROOT_DIR/evaluation/ConVul-CVE-Benchmarks/CVE-2011-2183" 2011-2183 2
run_one CVE-2013-1792 "$ROOT_DIR/evaluation/ConVul-CVE-Benchmarks/CVE-2013-1792" 2013-1792 2
run_one CVE-2015-7550 "$ROOT_DIR/evaluation/ConVul-CVE-Benchmarks/CVE-2015-7550" 2015-7550 3
run_one CVE-2016-1972 "$ROOT_DIR/evaluation/ConVul-CVE-Benchmarks/CVE-2016-1972" 2016-1972 3
run_one CVE-2016-1973 "$ROOT_DIR/evaluation/ConVul-CVE-Benchmarks/CVE-2016-1973" 2016-1973 3
run_one CVE-2016-9806 "$ROOT_DIR/evaluation/ConVul-CVE-Benchmarks/CVE-2016-9806" 2016-9806 3
run_one CVE-2017-6346 "$ROOT_DIR/evaluation/ConVul-CVE-Benchmarks/CVE-2017-6346" 2017-6346 3
run_one CVE-2017-15265 "$ROOT_DIR/evaluation/ConVul-CVE-Benchmarks/CVE-2017-15265" 2017-15265 3

echo "==== CVE DONE $(date -Is) ====" | tee -a "$summary"
cat "$summary"
