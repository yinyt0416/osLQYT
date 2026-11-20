#!/usr/bin/env bash
set -euo pipefail

# Run inside the PERIOD container after copying this directory to /tmp/rq3-repeat10.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPEATS="${REPEATS:-10}"
BUDGET="${BUDGET:-10000}"
WALL_TIMEOUT="${WALL_TIMEOUT:-300}"
TARGET_TIMEOUT="${TARGET_TIMEOUT:-5}"
NATIVE_BATCH="${NATIVE_BATCH:-20}"
ROOT="${EVIDENCE_ROOT:-/evidence/rq3-cve-repeat10-$(date +%Y%m%d-%H%M%S)}"

mkdir -p "$ROOT"
printf '%s\n' "$ROOT" > /evidence/rq3-cve-repeat10-latest.txt
printf 'evidence_root=%s\n' "$ROOT"
uname -a > "$ROOT/environment.txt"
cat /etc/os-release >> "$ROOT/environment.txt"

# rq3_worker.py installs this helper into PERIOD's DBDS directory.
cp "$SCRIPT_DIR/rq3_timing.py" /tmp/rq3_timing.py

python3 "$SCRIPT_DIR/rq3_worker.py" \
  --backend period --action instrument --root "$ROOT" \
  --run-id cve-repeat10 --subject CVE-2017-6346 \
  | tee "$ROOT/instrument.log"

python3 "$SCRIPT_DIR/rq3_worker.py" \
  --backend period --action prepare --root "$ROOT" \
  --run-id cve-repeat10 --subject CVE-2017-6346 \
  | tee "$ROOT/prepare.log"

for i in $(seq 1 "$REPEATS"); do
  echo "===== Round $i / $REPEATS ====="
  python3 "$SCRIPT_DIR/rq3_worker.py" \
    --backend period --action run --root "$ROOT" \
    --run-id cve-repeat10 --subject CVE-2017-6346 \
    --tool native --repeat "$i" --native-batch "$NATIVE_BATCH" \
    --target-timeout "$TARGET_TIMEOUT" \
    | tee "$ROOT/native-$i.log"

  python3 "$SCRIPT_DIR/rq3_worker.py" \
    --backend period --action run --root "$ROOT" \
    --run-id cve-repeat10 --subject CVE-2017-6346 \
    --tool Period --repeat "$i" --budget "$BUDGET" \
    --wall-timeout "$WALL_TIMEOUT" --target-timeout "$TARGET_TIMEOUT" \
    | tee "$ROOT/period-$i.log"
done

if [ "$REPEATS" -eq 10 ]; then
  python3 "$SCRIPT_DIR/rq3_summarize.py" "$ROOT" | tee "$ROOT/summary.log"
else
  echo "Skipping fixed 10-round summary because REPEATS=$REPEATS"
fi

echo "DONE: $ROOT"
