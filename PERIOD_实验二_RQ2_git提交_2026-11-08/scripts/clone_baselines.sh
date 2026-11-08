#!/bin/bash
# Clone SCTBench (IPB/IDB/DFS/PCT/Random) and note Maple separately.
# Requires network. Does NOT fabricate results.
set -u
# shellcheck disable=SC1091
source "$(cd "$(dirname "$0")" && pwd)/env.sh"
set -e
mkdir -p "$PACK_ROOT/third_party"
if [ ! -d "$SCTBENCH_DIR/.git" ]; then
  echo "Cloning mc-imperial/sctbench ..."
  git clone --depth 1 https://github.com/mc-imperial/sctbench.git "$SCTBENCH_DIR"
else
  echo "sctbench already present: $SCTBENCH_DIR"
fi
if [ ! -d "$MAPLE_DIR/.git" ]; then
  echo "Cloning jieyu/maple (optional; build notes differ) ..."
  git clone --depth 1 https://github.com/jieyu/maple.git "$MAPLE_DIR" || {
    echo "WARN: Maple clone failed; continue without Maple"
  }
else
  echo "maple already present: $MAPLE_DIR"
fi
echo "Next: follow $SCTBENCH_DIR README to build checkers (chess/pct/etc)."
echo "Maple: see $MAPLE_DIR README; often needs Pin/LLVM — treat as separate stage."
