#!/bin/bash
# 实验一 / RQ1: Period (run_PDS.py) vs Serial (scripts/run_Serial.py)
set -u
PACK_ROOT="$(cd "$(dirname "$0")" && pwd)"
# shellcheck disable=SC1091
source "$PACK_ROOT/scripts/env.sh"
STAGE="${1:-all}"
echo "PACK_ROOT=$PACK_ROOT DOCKER_HOST=${DOCKER_HOST:-<system default>} IMAGE=$PERIOD_IMAGE"
case "$STAGE" in
  rq1|all|rq1_all)
    bash "$PACK_ROOT/scripts/run_rq1.sh" all
    ;;
  help|*)
    echo "usage: $0 {rq1|all}"
    echo "  rq1|all  — Period (run_PDS.py) vs Serial (scripts/run_Serial.py)"
    echo "            → results/rq1/rq1_summary.tsv"
    echo "Reference evidence (prior run): prior_results/rq1/"
    echo "本包仅含 实验一=RQ1；开销 RQ3 见 PERIOD_实验三_RQ3_*。"
    exit 0
    ;;
esac
