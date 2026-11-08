#!/bin/bash
# aget/pbzip2 need non-default binary paths + args (see prior CB_aget_fixed / CB_pbzip2_fixed).
set -u
ROOT_DIR=${ROOT_DIR:-/workdir/PERIOD}
mkdir -p /out/logs /out/results
summary=/out/results/summary_cb_fixed.tsv
echo -e "subject\tstatus\terrors\ttests\tduration_s\tlog" > "$summary"
run() {
  name=$1; dir=$2; shift 2
  log=/out/logs/${name}.log
  t0=$(date +%s); rc=0
  echo "===== $name =====" | tee "$log"
  ( set -e; cd "$dir"; ./cleanDIR.sh; ./build.sh; timeout -k 10 300 $ROOT_DIR/tool/DBDS/run_PDS.py -y "$@" ) >>"$log" 2>&1 || rc=$?
  t1=$(date +%s); dur=$((t1-t0))
  errors=$(grep -oE 'Total Error Interleavings: [0-9]+' "$log" | tail -1 | grep -oE '[0-9]+$' || echo NA)
  tests=$(grep -cE 'test [0-9]+:' "$log" || echo 0)
  status=OK
  [ $rc -eq 124 ] && status=TIMEOUT
  [ $rc -ne 0 ] && [ $rc -ne 124 ] && status=FAIL_$rc
  grep -q 'End Testing!' "$log" || status=INCOMPLETE_$status
  [ "$errors" != NA ] && [ "$errors" != 0 ] && status=BUGS_$status
  echo -e "$name\t$status\t$errors\t$tests\t${dur}\t$log" | tee -a "$summary"
}
run CB_aget_fixed "$ROOT_DIR/evaluation/CB/aget-bug2" -d 2 ./aget-devel/aget -l dl.txt http://www.gnu.org/licenses/gpl.txt
run CB_pbzip2_fixed "$ROOT_DIR/evaluation/CB/pbzip2-0.9.4" -t 15 -d 2 ./pbzip2-0.9.4-src/pbzip2 -k -f -p3 test.tar
cat "$summary"
