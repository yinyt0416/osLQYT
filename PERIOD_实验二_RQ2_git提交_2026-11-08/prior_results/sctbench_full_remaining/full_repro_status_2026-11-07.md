> HISTORY: Absolute `/workspace/...` paths below (if any) were recorded on the **author machine** during packaging; on your machine use `$PACK_ROOT` / relative paths only. Scripts in this pack never hardcode those paths.

# PERIOD full reproduction status

**Updated:** 2026-11-07 18:34 Asia/Shanghai (UTC+8)  
**Delivery target:** 2026-11-08 evening Asia/Shanghai — **everything except RQ2 six baselines**  
**Host kernel:** 6.12.113+ · MemAvailable ≈ **13.4 Gi** (after Chess/Interlocked stopped)

## Delivery scope (user-confirmed 2026-11-07)

| Item | Status |
|------|--------|
| RQ1 Serial vs Period (smoke + expand) | **DONE** — 8 subjects × 2 modes |
| RQ3 Period vs native overhead (curated + expand) | **DONE** — 11 Period rows |
| SCTBench remaining 13/13 | **DONE** (2026-11-03) — large cases mostly TIMEOUT partial |
| Chess `InterlockedWorkStealQueueWithState` (`funny_faraday`) | **STOPPED** — log ends at **test 331200** (`<author PERIOD results>/logs/Chess_InterlockedWorkStealQueueWithState.log`, ~332k lines / ~148 MiB) |
| RQ2 six Pin baselines (IPB/IDB/DFS/PCT/Random/Maple) | **NOT_RUN** — out of scope for 11-08 deliverable unless external SSH arrives |

## RQ1 Period vs Serial

- Smoke (2026-11-02): `CS_account` / `CS_lazy01` / `CS_reorder_3` — all BUGS_OK; `CS_reorder_3` Period schedules=**27**
- Expand (2026-11-07): `CS_twostage` / `CS_reorder_4` / `CS_bluetooth_driver` / `CS_wronglock_3` / `CS_token_ring`
- Merged table: `full_baselines/results/rq1/rq1_summary_merged_20261107.tsv` (also `rq1/rq1_summary.tsv`)
- Expand raw: `full_baselines/results/rq1_expand/`
- Serial runner: `full_baselines/scripts/run_Serial.py` (stock `run_OldPDS.py` SEGV on period:latest)

## RQ3 Period overhead

- Curated 7 OK (2026-11-02) + expand 4 OK (2026-11-07)
- Merged: `full_baselines/results/rq3/rq3_overhead_merged_20261107.csv` (also `rq3/rq3_overhead.csv`)
- Expand raw: `full_baselines/results/rq3_expand/`
- IPB/IDB/PCT overhead rows remain **NOT_RUN** (need Pin baselines)

## SCTBench (PERIOD self-detection)

- Remaining queue drained 13/13 on 2026-11-03 01:38 Asia/Shanghai (`sctbench_full_remaining` Exit=0)
- Final: `results/sctbench_full/summary_full_final.tsv`
- Large CS (`reorder_50/100`, `twostage_50/100`) and some Chess: `BUGS_INCOMPLETE_TIMEOUT_3600s` with partial counts

## RQ2 six baselines — NOT_RUN (honest rationale)

**Not claimed complete. Not started on this host.**

1. **Intel Pin / SCTBench** need old Linux (Ubuntu **14.04** preferred / **16.04**); host is **6.12.113+**.
2. **Nested KVM** on this box: guest does not boot (`kvm_arch_vcpu_create` BUG / process spins). Observed earlier on 6.12.94+.
3. **TCG** can smoke-boot Trusty but is **too slow for Pin** six-baseline workloads.
4. **Update Bot's Computer**: user UI shows **「已是最新版本」** — Update button unavailable. Do **not** suggest Reset. (Forum note: group-chat settings view can also gray the control; 1:1 chat does not help if already-latest.)
5. **External SSH**: user has **none for now**. Option A scripts ready at  
   `PERIOD_full_repro/qemu_baseline/option_A_cloud/` (`01_provision_remote.sh` / `02_rsync_sctbench.sh` / `03_remote_build_and_run.sh`).
6. YYT does **not** start QEMU from this workstream.

## Bro coordination

- Do not kill PERIOD docker containers bro owns; Interlocked/`funny_faraday` already gone.
- PERIOD_repro dockerd: `scripts/pdocker` → `unix://<author-machine docker.sock — use system docker.sock>` (restarted 2026-11-07; `period:latest` re-pulled).
- No zip rebuild of 实验一/二/三 this turn (results folded into report draft + merged TSVs only).

## Heavy subjects intentionally skipped this turn

See `full_baselines/subjects/SKIPPED_heavy_20261107.md` (reorder_10+, twostage_20+, full wronglock/stack/queue, Chess/Splash2 long runs).
