#!/usr/bin/env bash
set -eu

SCT_ROOT="${SCT_ROOT:-/home/vagrant/sctbench}"
TEST_LIST="${TEST_LIST:-$SCT_ROOT/benchmarks/rq3_matched.txt}"
RUN_ROOT="${RUN_ROOT:-$SCT_ROOT/rq3-formal}"
SCHEDULE_LIMIT="${SCHEDULE_LIMIT:-10000}"
TIME_LIMIT="${TIME_LIMIT:-300}"

export ROOT="$SCT_ROOT"
export PIN_HOME="$SCT_ROOT/pin"
export MAPLE_HOME="$SCT_ROOT/maple"
export PATH="$MAPLE_HOME/script:$SCT_ROOT/scripts:$PATH"
. "$SCT_ROOT/scripts/settings.sh"

mkdir -p "$RUN_ROOT/logs"
cp "$TEST_LIST" "$RUN_ROOT/subjects.txt"
if [ ! -f "$RUN_ROOT/run.meta" ]; then
  printf '%s\n' "started_utc=$(date -u +%Y-%m-%dT%H:%M:%SZ)" > "$RUN_ROOT/run.meta"
  printf '%s\n' "schedule_limit=$SCHEDULE_LIMIT" >> "$RUN_ROOT/run.meta"
  printf '%s\n' "time_limit_seconds=$TIME_LIMIT" >> "$RUN_ROOT/run.meta"
  printf '%s\n' "sctbench_commit=$(cd "$SCT_ROOT" && git rev-parse HEAD)" >> "$RUN_ROOT/run.meta"
else
  printf '%s\n' "resumed_utc=$(date -u +%Y-%m-%dT%H:%M:%SZ)" >> "$RUN_ROOT/run.meta"
fi

run_phase() {
  phase="$1"
  max_bound="$2"
  printf '%s\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ) START $phase" | tee -a "$RUN_ROOT/progress.log"
  index=0
  while read -r suite subject max_threads max_steps; do
    case "$suite" in ''|'#'*) continue ;; esac
    if grep -q "^${phase},${subject}," "$RUN_ROOT/phase_status.csv"; then
      printf '%s\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ) SKIP $phase $subject ALREADY_RECORDED" >> "$RUN_ROOT/progress.log"
      index=$((index + 1))
      continue
    fi
    log="$RUN_ROOT/logs/${phase}--${subject}.log"
    started=$(date +%s)
    printf '%s\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ) START $phase $subject" | tee -a "$RUN_ROOT/progress.log"
    if python "$SCT_ROOT/scripts/run_many.py" \
      --mode "$phase" --max "$max_bound" --limit "$SCHEDULE_LIMIT" \
      --timelimit "$TIME_LIMIT" --numjobs 1 --benchmarkindex "$index" \
      "$TEST_LIST" > "$log" 2>&1; then
      status=OK
    else
      status=TIMEOUT_OR_ERROR
    fi
    elapsed=$(($(date +%s) - started))
    printf '%s,%s,%s,%s\n' "$phase" "$subject" "$status" "$elapsed" >> "$RUN_ROOT/phase_status.csv"
    printf '%s\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ) DONE $phase $subject $status ${elapsed}s" | tee -a "$RUN_ROOT/progress.log"
    index=$((index + 1))
  done < "$TEST_LIST"
  printf '%s\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ) DONE $phase" | tee -a "$RUN_ROOT/progress.log"
}

# SCTBench's published workflow constructs race databases before search.
if [ ! -f "$RUN_ROOT/phase_status.csv" ]; then
  printf '%s\n' 'tool,subject,status,wall_seconds' > "$RUN_ROOT/phase_status.csv"
fi
run_phase race 10
run_phase pb 4
run_phase db 4
run_phase pct 3

printf '%s\n' "finished_utc=$(date -u +%Y-%m-%dT%H:%M:%SZ)" >> "$RUN_ROOT/run.meta"
touch "$RUN_ROOT/COMPLETE"
