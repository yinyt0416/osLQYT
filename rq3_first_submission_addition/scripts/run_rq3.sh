#!/bin/bash
set -u
source "$(cd "$(dirname "$0")" && pwd)/env.sh"
STAGE="${1:-curated}"
mkdir -p "$OUT_DIR/rq3/logs"
LOG="$OUT_DIR/rq3/queue_$(date +%Y%m%d_%H%M%S).log"
exec > >(tee -a "$LOG") 2>&1
echo "==== RQ3 overhead $(date -Is) STAGE=$STAGE ===="
if ! "$DOCKER_BIN" image inspect "$PERIOD_IMAGE" >/dev/null 2>&1; then
  echo "ERROR: need $PERIOD_IMAGE (docker pull wcventure/period:stable && docker tag ... period:latest)"
  exit 1
fi
SUBJ="$PACK_ROOT/subjects/rq3_subjects.tsv"
INSIDE="$PACK_ROOT/scripts/run_rq3_inside.sh"
"$DOCKER_BIN" run --privileged --rm \
  -e NATIVE_REPEATS="${NATIVE_REPEATS}" \
  -e TIMEOUT_S="${TIMEOUT_S:-300}" \
  -e BUDGET="${BUDGET}" \
  -e SUBJECTS_FILE=/tmp/rq3_subjects.tsv \
  -v "$OUT_DIR/rq3:/out" \
  -v "$SUBJ:/tmp/rq3_subjects.tsv:ro" \
  -v "$INSIDE:/tmp/run_rq3_inside.sh:ro" \
  "$PERIOD_IMAGE" /bin/bash /tmp/run_rq3_inside.sh
echo "==== see $OUT_DIR/rq3/rq3_overhead.csv ===="
