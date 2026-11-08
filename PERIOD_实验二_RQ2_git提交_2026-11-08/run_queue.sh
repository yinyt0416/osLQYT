#!/bin/bash
# 实验二 / RQ2: PERIOD 自身检出 (smoke/CVE/SCTBench) + 六基线对比脚手架
# 六基线实测需旧内核 VM；见 notes/ 与 MACHINE_SETUP.md
set -u
PACK_ROOT="$(cd "$(dirname "$0")" && pwd)"
# shellcheck disable=SC1091
source "$PACK_ROOT/scripts/env.sh"

STAGE="${1:-help}"
mkdir -p "$RESULTS_ROOT"/{smoke,cve,sctbench}/logs "$BASELINE_OUT_DIR"
LOG_MASTER="$RESULTS_ROOT/queue_$(date +%Y%m%d_%H%M%S).log"
# Only tee for long PERIOD stages; short baseline stages also ok
exec > >(tee -a "$LOG_MASTER") 2>&1

echo "==== PERIOD 实验二 RQ2 queue $(date -Is) STAGE=$STAGE IMAGE=$PERIOD_IMAGE ===="
echo "PACK_ROOT=$PACK_ROOT RESULTS_ROOT=$RESULTS_ROOT BASELINE_OUT_DIR=$BASELINE_OUT_DIR"
echo "DOCKER_HOST=${DOCKER_HOST:-<system default>} KERNEL=$(uname -r 2>/dev/null || echo unknown)"

need_image() {
  if ! "$DOCKER_BIN" image inspect "$PERIOD_IMAGE" >/dev/null 2>&1; then
    echo "ERROR: image $PERIOD_IMAGE not found. Run:"
    echo "  docker pull wcventure/period:stable"
    echo "  docker tag wcventure/period:stable period:latest"
    exit 1
  fi
}

stage_smoke() {
  export OUT_DIR="$RESULTS_ROOT"
  echo "---- Stage A: smoke doubleFree ----"
  mkdir -p "$OUT_DIR/smoke/logs"
  "$DOCKER_BIN" run --privileged --rm -v "$OUT_DIR/smoke:/out" "$PERIOD_IMAGE" /bin/bash -lc '
    set -e
    ROOT_DIR=${ROOT_DIR:-/workdir/PERIOD}
    mkdir -p /out/logs
    cd $ROOT_DIR/test/doubleFree && ./cleanDIR.sh && ./build.sh
    $ROOT_DIR/tool/DBDS/run_PDS.py -y -d 3 ./df | tee /out/logs/smoke_doubleFree.log
    grep -E "Total Error Interleavings" /out/logs/smoke_doubleFree.log | tee /out/smoke_summary.txt
  '
}

stage_cve() {
  export OUT_DIR="$RESULTS_ROOT"
  echo "---- Stage B: ConVul 10 CVE ----"
  "$DOCKER_BIN" run --privileged --rm \
    -v "$OUT_DIR/cve:/out" \
    -v "$PACK_ROOT/scripts/run_cve_inside.sh:/tmp/run_cve_inside.sh:ro" \
    "$PERIOD_IMAGE" /bin/bash /tmp/run_cve_inside.sh
}

stage_sctbench() {
  export OUT_DIR="$RESULTS_ROOT"
  echo "---- Stage C: SCTBench (depth≤3, timeout ${TIMEOUT_S}s) ----"
  "$DOCKER_BIN" run --privileged --rm \
    -e RUN_HUGE="${RUN_HUGE:-0}" \
    -e RUN_TWOSTAGE20="${RUN_TWOSTAGE20:-0}" \
    -e TIMEOUT_S="${TIMEOUT_S}" \
    -v "$OUT_DIR/sctbench:/out" \
    -v "$PACK_ROOT/scripts/run_sctbench_inside.sh:/tmp/run_sctbench_inside.sh:ro" \
    "$PERIOD_IMAGE" /bin/bash /tmp/run_sctbench_inside.sh
}

stage_cb_fixed() {
  export OUT_DIR="$RESULTS_ROOT"
  echo "---- Stage D: CB aget/pbzip2 fixed paths ----"
  "$DOCKER_BIN" run --privileged --rm \
    -v "$OUT_DIR/sctbench:/out" \
    -v "$PACK_ROOT/scripts/run_cb_fixed_inside.sh:/tmp/run_cb_fixed_inside.sh:ro" \
    "$PERIOD_IMAGE" /bin/bash /tmp/run_cb_fixed_inside.sh
}

stage_resume() {
  export OUT_DIR="$RESULTS_ROOT"
  echo "---- Resume hint: remaining / TODO subjects ----"
  echo "See manifests/DONE_vs_TODO.md and manifests/TODO_sctbench_remaining.tsv"
  echo "Raise TIMEOUT_S for Chess_*/Splash2_barnes/Inspect_boundedBuffer, e.g.:"
  echo "  TIMEOUT_S=3600 bash run_queue.sh sctbench"
  echo "Huge CS (optional): RUN_HUGE=1 RUN_TWOSTAGE20=1 bash run_queue.sh sctbench"
  if [ ! -f "$OUT_DIR/cve/results/summary_cve.tsv" ]; then
    stage_cve
  else
    echo "CVE summary already present under results/cve — skip; delete to force re-run."
  fi
  stage_sctbench
  stage_cb_fixed
}

print_blockers() {
  echo "---- BLOCKERS (六基线实测) ----"
  echo "Host kernel: $(uname -r 2>/dev/null || echo unknown)"
  echo "SCTBench/Maple Intel PIN 2.12 官方要求 kernel <= 3.x。"
  echo "若 kernel >= 6.x：六基线工具标 NOT_RUN；请用 Ubuntu 14.04/16.04 VM（见 notes/BASELINE_OLD_KERNEL_OPTIONS.md）。"
  echo "HOW_TO: notes/HOW_TO_RUN_BASELINES.md"
  echo "Period PRIOR_REF：prior_results/ 与 results/baselines/compare_summary.tsv（跑 stubs 后生成）"
}

clone_stage() {
  bash "$PACK_ROOT/scripts/clone_baselines.sh" || echo "WARN: clone incomplete (network?)"
}

stubs_stage() {
  # baseline scripts source env.sh and use OUT_DIR — force baselines dir
  export OUT_DIR="$BASELINE_OUT_DIR"
  for t in Period IPB IDB DFS PCT Random Maple; do
    bash "$PACK_ROOT/scripts/run_baseline_stub.sh" "$t"
  done
  bash "$PACK_ROOT/scripts/merge_compare.sh"
}

case "$STAGE" in
  # PERIOD self
  all_period|period)
    need_image
    stage_smoke; stage_cve; stage_sctbench; stage_cb_fixed
    ;;
  smoke) need_image; stage_smoke ;;
  cve) need_image; stage_cve ;;
  sctbench) need_image; stage_sctbench ;;
  cb_fixed) need_image; stage_cb_fixed ;;
  resume) need_image; stage_resume ;;
  # baselines
  baselines|all_baselines)
    print_blockers; clone_stage; stubs_stage
    ;;
  clone) clone_stage ;;
  stubs) stubs_stage ;;
  status|blockers) print_blockers; ls -la "$BASELINE_OUT_DIR" "$PACK_ROOT/notes" 2>/dev/null || true ;;
  # everything
  all)
    need_image
    stage_smoke; stage_cve; stage_sctbench; stage_cb_fixed
    print_blockers; clone_stage; stubs_stage
    ;;
  help|*)
    echo "usage: $0 {all|period|smoke|cve|sctbench|cb_fixed|resume|baselines|clone|stubs|status}"
    echo "  PERIOD 自身检出:"
    echo "    all_period|period  — smoke → CVE → SCTBench → CB fixed"
    echo "    smoke|cve|sctbench|cb_fixed|resume"
    echo "  六基线脚手架 (IPB/IDB/DFS/PCT/Random/Maple):"
    echo "    baselines|all_baselines — clone + stubs + merge"
    echo "    clone|stubs|status"
    echo "  all — PERIOD 全队列 + 基线脚手架"
    echo "NOTE: 六基线实测需旧内核 VM；现代 Linux 上 stub 为 NOT_RUN 属预期。"
    echo "Prior reference (NOT overwritten): $PACK_ROOT/prior_results/"
    exit 0
    ;;
esac

echo "==== queue done $(date -Is) ===="
echo "PERIOD results: $RESULTS_ROOT"
echo "Baseline results: $BASELINE_OUT_DIR"
echo "Prior reference (NOT overwritten): $PACK_ROOT/prior_results/"
ls -la "$RESULTS_ROOT"/smoke "$RESULTS_ROOT"/cve "$RESULTS_ROOT"/sctbench "$BASELINE_OUT_DIR" 2>/dev/null || true
