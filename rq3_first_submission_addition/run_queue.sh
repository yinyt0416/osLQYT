#!/bin/bash
# 实验三 / RQ3: native wall-time vs Period overhead (curated)
set -u
PACK_ROOT="$(cd "$(dirname "$0")" && pwd)"
# shellcheck disable=SC1091
source "$PACK_ROOT/scripts/env.sh"
STAGE="${1:-all}"
echo "PACK_ROOT=$PACK_ROOT DOCKER_HOST=${DOCKER_HOST:-<system default>} IMAGE=$PERIOD_IMAGE"
case "$STAGE" in
  rq3|rq3_curated|all|curated)
    bash "$PACK_ROOT/scripts/run_rq3.sh" curated
    ;;
  help|*)
    echo "usage: $0 {rq3|all|curated}"
    echo "  rq3|all  — native vs Period overhead → results/rq3/rq3_overhead.csv"
    echo "Reference evidence (prior run): prior_results/rq3/"
    echo "本包仅含 实验三=RQ3；Serial/RQ1 见 PERIOD_实验一_RQ1_*。"
    exit 0
    ;;
esac
