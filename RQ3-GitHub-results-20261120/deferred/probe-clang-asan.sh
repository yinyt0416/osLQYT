#!/bin/bash
set -eu
root=/home/sct/rq3-compat-clang35
mkdir -p "$root"
src=/home/sct/rq3-staging/rq3-preparation/rq3-period-matched
pin=/home/sct/sctbench/pin/pin.sh
tools=/home/sct/sctbench/maple/build-release
export ASAN_OPTIONS=abort_on_error=1:detect_leaks=0
ulimit -c 0
for subject in doubleFree CB_stringbuffer; do
  mkdir -p "$root/$subject/run" "$root/$subject/run_race"
  cd "$root/$subject/run"
  cp "$src/$subject/run/"*.c* . 2>/dev/null || true
  if [ "$subject" = doubleFree ]; then
    clang-3.5 -O0 -g -fsanitize=address -fno-omit-frame-pointer df.c -o program -pthread -ldl > build.log 2>&1
  else
    cp "$src/$subject/run/"*.hpp .
    clang++-3.5 -O0 -g -fsanitize=address -fno-omit-frame-pointer main.cpp stringbuffer.cpp -o program -pthread -ldl > build.log 2>&1
  fi
  set +e
  timeout 15 "$pin" -injection child -t "$tools/race_pct_profiler.so" -enable_djit 1 -ignore_lib 0 -race_out ../run_race/race.db -sinfo_out ../run_race/sinfo.db -- ./program > race.log 2>&1
  echo "$subject race exit=$?"
  timeout 15 "$pin" -injection child -t "$tools/systematic_controller.so" -enable_chess_scheduler 1 -race_in ../run_race/race.db -sinfo_in ../run_race/sinfo.db -search_in search.db -search_out search.db -program_in program.db -program_out program.db -pb 1 -delay_bound 0 -pb_limit 0 -unit_size 1 -sched_race 1 -sched_app 1 -- ./program > controller.log 2>&1
  echo "$subject controller exit=$?"
  grep -E 'Sanitizer|ERROR|finished|search done|Program EXIT|signal 11|failed' race.log controller.log | tail -16
  set -e
done
