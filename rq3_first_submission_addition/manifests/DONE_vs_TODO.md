# DONE vs TODO（实验三 / RQ3 overhead）

时间戳：2026-11-08 Asia/Shanghai（PRIOR：curated 2026-11-02 + expand 2026-11-07）

## RQ3 overhead — DONE（Period vs native，合并 11 科）

来源：`prior_results/rq3/rq3_overhead_merged_20261107.csv`

| subject | batch | slowdown (Period/native) | schedules | status |
|---------|-------|--------------------------|-----------|--------|
| doubleFree | curated | 0.36 | 6 | OK |
| CS_lazy01 | curated | 19.49 | 39 | OK |
| CS_twostage | curated | 26.02 | 33 | OK |
| CB_stringbuffer | curated | 34.72 | 163 | OK |
| CS_reorder_3 | curated | 45.31 | 27 | OK |
| CS_account | curated | 55.88 | 65 | OK |
| CS_circular_buffer | curated | 446.93 | 366 | OK |
| CS_reorder_4 | expand | 2.28 | 100 | OK |
| CS_token_ring | expand | 7.39 | 232 | OK |
| CS_bluetooth_driver | expand | 5.17 | 47 | OK |
| CS_wronglock_3 | expand | 4.66 | 172 | OK |

### RQ3 NOT_RUN（相对 IPB/IDB/PCT）

| tool | status | reason |
|------|--------|--------|
| IPB / IDB / PCT | NOT_RUN | 需 SCTBench 基线实测；需 Ubuntu 14.04/16.04 + Pin（kernel≤3.x）；本机 6.12 不可跑 |

## 范围说明

- 本包**不含** RQ1 Serial（`run_Serial.py`）；见 `PERIOD_实验一_RQ1_git提交_*`。
- 今晚交付：**除六基线外**；六基线仍 NOT_RUN，勿假装已跑。
