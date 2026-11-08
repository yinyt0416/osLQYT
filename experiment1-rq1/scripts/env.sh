#!/bin/bash
# Portable env for 实验一 / RQ1: Period vs Serial.
set -u
PACK_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
export PACK_ROOT
export PERIOD_IMAGE="${PERIOD_IMAGE:-period:latest}"
export DOCKER_BIN="${DOCKER_BIN:-docker}"
export OUT_DIR="${OUT_DIR:-$PACK_ROOT/results}"
export BUDGET="${BUDGET:-10000}"
export TIMEOUT_S="${TIMEOUT_S:-480}"
if [ -z "${DOCKER_HOST:-}" ] && [ -n "${DOCKER_SOCK:-}" ]; then
  export DOCKER_HOST="unix://${DOCKER_SOCK}"
fi
mkdir -p "$OUT_DIR"
