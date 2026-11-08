# PERIOD full reproduction status (SCTBench remaining)

**Updated:** 2026-11-02 20:20 Asia/Shanghai (UTC+8)  
**Container:** `sctbench_full_remaining` Up (not killing)

## Progress
- Targeted leftovers: **13** · rows landed: **9**
- Running: `CS_reorder_50` (~50018 tests so far, wall 3600s)
- Queued: CS_twostage_50, CS_reorder_100, CS_twostage_100

### Remaining-subject rows
| Subject | Status | errors | tests | dur_s | depth |
|---------|--------|--------|-------|-------|-------|
| Inspect_qsort_mt | BUGS_OK | 139 | 8648 | 122 | 3 |
| Inspect_ctrace-test | BUGS_OK | 4 | 13 | 3 | 3 |
| Splash2_fft | BUGS_OK | 94 | 194 | 8 | 2 |
| Splash2_lu | BUGS_OK | 55 | 114 | 5 | 2 |
| Splash2_barnes | BUGS_OK | 342 | 704 | 95 | 2 |
| Chess_StateWSQ | BUGS_INCOMPLETE_TIMEOUT_3600s | partial_62 | 28210 | 5290 | 3 |
| Chess_ILWSQState | BUGS_INCOMPLETE_TIMEOUT_3600s | partial_87 | 29998 | 5518 | 3 |
| Inspect_boundedBuffer | INCOMPLETE_TIMEOUT_3600s | NA | 0 | 4999 | 3 |
| CS_twostage_20 | BUGS_OK | 3075 | 62431 | 2652 | 3 |
| CS_reorder_50 | IN_PROGRESS ~50018 tests | | | | |
| CS_twostage_50 | pending | | | | |
| CS_reorder_100 | pending | | | | |
| CS_twostage_100 | pending | | | | |

## Pack1 fold
Latest DONE/TIMEOUT rows synced into `prior_results/sctbench_full_remaining/` and rezipped for 21:00.
