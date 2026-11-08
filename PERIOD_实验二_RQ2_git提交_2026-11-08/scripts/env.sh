#!/bin/bash
# Portable env for 实验二 / RQ2: PERIOD self-detection + baseline compare scaffolding.
set -u
PACK_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
export PACK_ROOT
export PERIOD_IMAGE="${PERIOD_IMAGE:-period:latest}"
export PERIOD_ROOT="${PERIOD_ROOT:-$PACK_ROOT}"
export DOCKER_BIN="${DOCKER_BIN:-docker}"
export TIMEOUT_S="${TIMEOUT_S:-480}"
# PERIOD self results root (smoke/cve/sctbench)
export RESULTS_ROOT="${RESULTS_ROOT:-$PACK_ROOT/results}"
# Baseline stub/compare output (IPB/IDB/DFS/PCT/Random/Maple)
export BASELINE_OUT_DIR="${BASELINE_OUT_DIR:-$PACK_ROOT/results/baselines}"
# Default OUT_DIR = PERIOD results; baseline stages override to BASELINE_OUT_DIR
export OUT_DIR="${OUT_DIR:-$RESULTS_ROOT}"
export SCTBENCH_DIR="${SCTBENCH_DIR:-$PACK_ROOT/third_party/sctbench}"
export MAPLE_DIR="${MAPLE_DIR:-$PACK_ROOT/third_party/maple}"
export SUBJECTS_TSV="${SUBJECTS_TSV:-$PACK_ROOT/subjects/subjects.tsv}"
if [ -z "${DOCKER_HOST:-}" ] && [ -n "${DOCKER_SOCK:-}" ]; then
  export DOCKER_HOST="unix://${DOCKER_SOCK}"
fi
mkdir -p "$OUT_DIR" "$BASELINE_OUT_DIR" "$PACK_ROOT/third_party"
