#!/bin/bash
# SCTBench PERIOD self batch. Depth≤3, timeout 480s.
# Huge subjects (reorder_50/100, twostage_50/100) skipped unless RUN_HUGE=1.
# CS_twostage_20 skipped unless RUN_TWOSTAGE20=1.
set -u
ROOT_DIR=${ROOT_DIR:-/workdir/PERIOD}
export ROOT_DIR
TIMEOUT_S=${TIMEOUT_S:-480}
RUN_HUGE=${RUN_HUGE:-0}
RUN_TWOSTAGE20=${RUN_TWOSTAGE20:-0}
mkdir -p /out/logs /out/results
summary=/out/results/summary_sctbench.tsv
echo -e "subject\tstatus\terrors\ttimeouts\ttests\tduration_s\tdepth\tlog\tnotes" > "$summary"

run_one() {
  local name="$1" dir="$2" bin="$3" depth="$4"; shift 4 || true
  local extra_args=("$@")
  local log=/out/logs/${name}.log
  local t0=$(date +%s) rc=0
  echo "===== BUILD+RUN $name (depth=$depth bin=$bin) =====" | tee "$log"
  (
    set -e
    cd "$dir"
    [ -x ./cleanDIR.sh ] && ./cleanDIR.sh
    [ -x ./build.sh ] || { echo "no build.sh"; exit 2; }
    ./build.sh
    if [ ! -x "./$bin" ]; then echo "missing binary ./$bin"; ls -la; exit 3; fi
    timeout -k 10 "$TIMEOUT_S" $ROOT_DIR/tool/DBDS/run_PDS.py -y -d "$depth" "./$bin" "${extra_args[@]}"
  ) >>"$log" 2>&1 || rc=$?
  local t1=$(date +%s) dur=$((t1-t0))
  local errors=$(grep -oE 'Total Error Interleavings: [0-9]+' "$log" | tail -1 | grep -oE '[0-9]+$' || echo NA)
  local timeouts=$(grep -oE 'Total Timeouts Interleavings: [0-9]+' "$log" | tail -1 | grep -oE '[0-9]+$' || echo NA)
  local tests=$(grep -cE 'test [0-9]+:' "$log" || echo 0)
  local status=OK
  if [ "$rc" -eq 124 ]; then status="TIMEOUT_${TIMEOUT_S}s"; fi
  if [ "$rc" -ne 0 ] && [ "$rc" -ne 124 ]; then status="FAIL_RC${rc}"; fi
  if ! grep -q 'End Testing!' "$log"; then status="INCOMPLETE_${status}"; fi
  if [ "$errors" != "NA" ] && [ "$errors" != "0" ]; then status="BUGS_${status}"; fi
  echo -e "${name}\t${status}\t${errors}\t${timeouts}\t${tests}\t${dur}\t${depth}\t${log}\t" | tee -a "$summary"
}

mark_skip() {
  local name="$1" reason="$2"
  echo -e "${name}\tSKIPPED_${reason}\tNA\tNA\tNA\tNA\t3\t-\tset RUN_HUGE=1 or RUN_TWOSTAGE20=1 to enable" | tee -a "$summary"
}

# CS small/medium
run_one CS_account        "$ROOT_DIR/evaluation/CS/account"        account_bad 3
run_one CS_deadlock01     "$ROOT_DIR/evaluation/CS/deadlock01"     deadlock01_bad 3
run_one CS_lazy01         "$ROOT_DIR/evaluation/CS/lazy01"         lazy01_bad 3
run_one CS_carter01       "$ROOT_DIR/evaluation/CS/carter01"       carter01_bad 3
run_one CS_reorder_3      "$ROOT_DIR/evaluation/CS/reorder_3"      reorder_3_bad 3
run_one CS_reorder_4      "$ROOT_DIR/evaluation/CS/reorder_4"      reorder_4_bad 3
run_one CS_reorder_5      "$ROOT_DIR/evaluation/CS/reorder_5"      reorder_5_bad 3
run_one CS_wronglock_3    "$ROOT_DIR/evaluation/CS/wronglock_3"    wronglock_3_bad 3
run_one CS_wronglock      "$ROOT_DIR/evaluation/CS/wronglock"      wronglock_bad 3
run_one CS_stack          "$ROOT_DIR/evaluation/CS/stack"          stack_bad 3
run_one CS_queue          "$ROOT_DIR/evaluation/CS/queue"          queue_bad 3
run_one CS_circular_buffer "$ROOT_DIR/evaluation/CS/circular_buffer" circular_buffer_bad 3
run_one CS_token_ring     "$ROOT_DIR/evaluation/CS/token_ring"     token_ring_bad 3
run_one CS_twostage       "$ROOT_DIR/evaluation/CS/twostage"       twostage_bad 3
run_one CS_bluetooth_driver "$ROOT_DIR/evaluation/CS/bluetooth_driver" bluetooth_driver_bad 3
run_one CS_reorder_10     "$ROOT_DIR/evaluation/CS/reorder_10"     reorder_10_bad 3
run_one CS_reorder_20     "$ROOT_DIR/evaluation/CS/reorder_20"     reorder_20_bad 3

if [ "$RUN_TWOSTAGE20" = "1" ]; then
  run_one CS_twostage_20 "$ROOT_DIR/evaluation/CS/twostage_20" twostage_20_bad 3
else
  mark_skip CS_twostage_20 after_partial_default
fi

if [ "$RUN_HUGE" = "1" ]; then
  run_one CS_reorder_50   "$ROOT_DIR/evaluation/CS/reorder_50"   reorder_50_bad 3
  run_one CS_twostage_50  "$ROOT_DIR/evaluation/CS/twostage_50"  twostage_50_bad 3
  run_one CS_reorder_100  "$ROOT_DIR/evaluation/CS/reorder_100"  reorder_100_bad 3
  run_one CS_twostage_100 "$ROOT_DIR/evaluation/CS/twostage_100" twostage_100_bad 3
else
  mark_skip CS_reorder_50 timebudget
  mark_skip CS_twostage_50 timebudget
  mark_skip CS_reorder_100 timebudget
  mark_skip CS_twostage_100 timebudget
fi

# CB (default binary names; fixed variants separately)
run_one CB_aget-bug2      "$ROOT_DIR/evaluation/CB/aget-bug2"      aget 2
run_one CB_pbzip2-0.9.4   "$ROOT_DIR/evaluation/CB/pbzip2-0.9.4"   pbzip2 3
run_one CB_stringbuffer   "$ROOT_DIR/evaluation/CB/stringbuffer-jdk1.4" main 3

# Chess / Inspect / Splash2 / SafeStack
run_one Chess_WSQ         "$ROOT_DIR/evaluation/Chess/WorkStealQueue" WorkStealQueue 3
run_one Chess_StateWSQ    "$ROOT_DIR/evaluation/Chess/StateWorkStealQueue" StateWorkStealQueue 3
run_one Chess_ILWSQ       "$ROOT_DIR/evaluation/Chess/InterlockedWorkStealQueue" InterlockedWorkStealQueue 3
run_one Chess_ILWSQState  "$ROOT_DIR/evaluation/Chess/InterlockedWorkStealQueueWithState" InterlockedWorkStealQueueWithState 3
run_one Inspect_bbuf           "$ROOT_DIR/evaluation/Inspect_benchmarks/bbuf" bbuf 3
run_one Inspect_boundedBuffer  "$ROOT_DIR/evaluation/Inspect_benchmarks/boundedBuffer" boundedBuffer 3
run_one Inspect_ctrace-test    "$ROOT_DIR/evaluation/Inspect_benchmarks/ctrace-test" ctrace-test 3
run_one Inspect_qsort_mt       "$ROOT_DIR/evaluation/Inspect_benchmarks/qsort_mt" qsort_mt 3
run_one Splash2_fft    "$ROOT_DIR/evaluation/Splash2/fft" FFT 3
run_one Splash2_lu     "$ROOT_DIR/evaluation/Splash2/lu" LU 3
run_one Splash2_barnes "$ROOT_DIR/evaluation/Splash2/barnes" BARNES 3
run_one SafeStack "$ROOT_DIR/evaluation/SafeStack" SafeStack 3

echo "==== SCTBench DONE $(date -Is) ====" | tee -a "$summary"
cat "$summary"
