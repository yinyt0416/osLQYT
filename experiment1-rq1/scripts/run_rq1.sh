#!/bin/bash
set -u
source "$(cd "$(dirname "$0")" && pwd)/env.sh"
STAGE="${1:-all}"
mkdir -p "$OUT_DIR/rq1/logs"
LOG="$OUT_DIR/rq1/queue_$(date +%Y%m%d_%H%M%S).log"
exec > >(tee -a "$LOG") 2>&1
echo "==== RQ1 Period vs Serial $(date -Is) STAGE=$STAGE IMAGE=$PERIOD_IMAGE BUDGET=$BUDGET ===="
echo "NOTE: Serial MUST use pack-local scripts/run_Serial.py (ABI-fixed)."
echo "      Stock run_OldPDS.py SEGVs on period:latest (c_uint vs c_uint16). Do NOT use it."
if ! "$DOCKER_BIN" image inspect "$PERIOD_IMAGE" >/dev/null 2>&1; then
  echo "ERROR: missing $PERIOD_IMAGE"
  echo "  docker pull wcventure/period:stable && docker tag wcventure/period:stable period:latest"
  exit 1
fi
SUBJ="$PACK_ROOT/subjects/rq1_subjects.tsv"
SERIAL_PY="$PACK_ROOT/scripts/run_Serial.py"
INSIDE="$PACK_ROOT/scripts/run_rq1_inside.sh"
[ -f "$SERIAL_PY" ] || { echo "ERROR: missing $SERIAL_PY"; exit 1; }
[ -f "$INSIDE" ] || { echo "ERROR: missing $INSIDE"; exit 1; }
"$DOCKER_BIN" run --privileged --rm \
  -e BUDGET="$BUDGET" \
  -e TIMEOUT_S="$TIMEOUT_S" \
  -e SUBJECTS_FILE=/tmp/rq1_subjects.tsv \
  -e SERIAL_PY=/tmp/run_Serial.py \
  -v "$OUT_DIR/rq1:/out" \
  -v "$SUBJ:/tmp/rq1_subjects.tsv:ro" \
  -v "$INSIDE:/tmp/run_rq1_inside.sh:ro" \
  -v "$SERIAL_PY:/tmp/run_Serial.py:ro" \
  "$PERIOD_IMAGE" /bin/bash /tmp/run_rq1_inside.sh
echo "==== see $OUT_DIR/rq1/rq1_summary.tsv ===="
