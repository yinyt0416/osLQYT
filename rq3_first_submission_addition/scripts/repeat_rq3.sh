#!/usr/bin/env bash
set -u

# Run one already-built benchmark repeatedly inside the PERIOD container.
# Usage: ./repeat_rq3.sh PROGRAM [REPEATS] [TIMEOUT_S]

PROGRAM="${1:-}"
REPEATS="${2:-5}"
TIMEOUT_S="${3:-600}"

if [ -z "$PROGRAM" ]; then
  echo "Usage: $0 PROGRAM [REPEATS] [TIMEOUT_S]"
  exit 2
fi

if [ ! -x "./$PROGRAM" ]; then
  echo "Executable not found: ./$PROGRAM"
  exit 2
fi

rm -f native_times.txt period_times.txt
rm -f native_run_*.log period_run_*.log
rm -rf out_*

echo "Native runs: $REPEATS"
for i in $(seq 1 "$REPEATS"); do
  start=$(date +%s%N)
  "./$PROGRAM" >"native_run_${i}.log" 2>&1
  rc=$?
  end=$(date +%s%N)
  elapsed=$(python3 -c "print(($end-$start)/1000000000)")
  printf '%s,%s,%s\n' "$i" "$elapsed" "$rc" | tee -a native_times.txt
done

echo "PERIOD runs: $REPEATS"
for i in $(seq 1 "$REPEATS"); do
  rm -rf out_*
  start=$(date +%s%N)
  /workdir/PERIOD/tool/DBDS/run_PDS.py -y -d 3 -t "$TIMEOUT_S" "./$PROGRAM" \
    >"period_run_${i}.log" 2>&1
  rc=$?
  end=$(date +%s%N)
  elapsed=$(python3 -c "print(($end-$start)/1000000000)")
  printf '%s,%s,%s\n' "$i" "$elapsed" "$rc" | tee -a period_times.txt
  grep -E 'End Testing|Total Error|Total Timeouts|Total Time' "period_run_${i}.log" || true
done

echo "Results: native_times.txt period_times.txt and run logs"
