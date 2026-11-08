# DONE vs TODO（实验二 / RQ2 PERIOD 自身检出）

时间戳：2026-11-08 Asia/Shanghai  
权威 SCTBench 汇总：`prior_results/summary_full_final.tsv`（含 TIMEOUT 部分结果；路径列多为容器内 `/out/logs/...`）  
Chess WithState 长跑：`prior_results/chess_interlocked/`（POINTER + 状态笔记；**不**含 ~142 MiB 完整 log）  
**六基线**：见 `DONE_vs_TODO_baselines.md` —— 仍全部 **NOT_RUN**（需 Ubuntu 14.04/16.04 + Pin；本机 6.12 不可跑）。

报告草稿（缺六基线）：`manifests/PERIOD_实验验证与结果分析_缺六基线_2026-11-07.md`

---
## 历史明细（2026-11-02 起，保留对照）

来源：`subjects/subjects.tsv` + `reference_baselines/`（更新：2026-11-02 晚间 remaining 增量，Asia/Shanghai）。

## DONE（干净完成）— 29
subject	prior_status	queue_status	errors	tests	duration_s
CS_account	BUGS_OK	DONE	29	65	3
CS_deadlock01	OK	DONE	0	14	31
CS_lazy01	BUGS_OK	DONE	13	39	1
CS_carter01	OK	DONE	0	42	52
CS_reorder_3	BUGS_OK	DONE	6	27	1
CS_reorder_4	BUGS_OK	DONE	12	100	2
CS_reorder_5	BUGS_OK	DONE	20	225	8
CS_wronglock_3	BUGS_OK	DONE	43	172	5
CS_wronglock	BUGS_OK	DONE	232	1464	55
CS_stack	BUGS_OK	DONE	67	918	39
CS_queue	BUGS_OK	DONE	50	625	27
CS_circular_buffer	BUGS_OK	DONE	57	366	17
CS_token_ring	BUGS_OK	DONE	55	232	5
CS_twostage	BUGS_OK	DONE	2	33	1
CS_bluetooth_driver	BUGS_OK	DONE	7	47	5
CS_reorder_10	BUGS_OK	DONE	90	2350	29
CS_reorder_20	BUGS_OK	DONE	2900	14550	324
CB_stringbuffer	BUGS_OK	DONE	4	163	4
CB_aget_fixed	BUGS_OK	DONE	26	153	7
CB_pbzip2_fixed	BUGS_OK	DONE	5	106	172
Chess_WSQ	BUGS_OK	DONE	14	81	3
Chess_ILWSQ	BUGS_OK	DONE	16	81	14
Inspect_bbuf	OK	DONE	0	482	17
Inspect_ctrace-test	BUGS_OK	DONE	4	13	3
Inspect_qsort_mt	BUGS_OK	DONE	139	8648	122
Splash2_fft	BUGS_OK	DONE	94	194	8
Splash2_lu	BUGS_OK	DONE	55	114	5
Splash2_barnes	BUGS_OK	DONE	342	704	95
SafeStack	OK	DONE	0	135	6

## IN_PROGRESS（源机勿杀）— 1
subject	prior_status	queue_status	notes
Chess_StateWSQ	INCOMPLETE_TIMEOUT_480s	IN_PROGRESS	prior 480s timeout; 2026-11-02 remaining re-run IN_PROGRESS wall=3600s ./StateWorkStealQueue 2 4 2 — do not kill

## TIMEOUT（可提高 TIMEOUT_S 续跑）— 2
subject	prior_status	queue_status
Chess_ILWSQState	INCOMPLETE_TIMEOUT_480s	TIMEOUT
Inspect_boundedBuffer	INCOMPLETE_TIMEOUT_480s	TIMEOUT

## TODO / 失败待排障 — 2
subject	prior_status	queue_status	notes
CB_aget-bug2	INCOMPLETE_FAIL_RC3	TODO	phase2 looked for ./aget; binary in aget-devel/; see CB_aget_fixed
CB_pbzip2-0.9.4	INCOMPLETE_FAIL_RC3	TODO	phase2 looked for ./pbzip2; binary in pbzip2-0.9.4-src/; see CB_pbzip2_fixed

## SKIP（大用例，需 RUN_HUGE=1）— 5
subject	prior_status	queue_status
CS_twostage_20	SKIPPED_after_partial	SKIP
CS_reorder_50	SKIPPED_timebudget	SKIP
CS_twostage_50	SKIPPED_timebudget	SKIP
CS_reorder_100	SKIPPED_timebudget	SKIP
CS_twostage_100	SKIPPED_timebudget	SKIP

## CVE（reference）
全部 10/10 BUGS_OK，见 `reference_baselines/summary_cve.tsv`。

## 晚间 remaining 增量（官方 README 参数）
- 新 DONE：Inspect_qsort_mt / Inspect_ctrace-test / Splash2_fft / Splash2_lu / Splash2_barnes
- 详见 `reference_baselines/sctbench_full_remaining/summary_full.tsv`
- Chess_StateWSQ：IN_PROGRESS（3600s）；Chess_ILWSQState 仍 TIMEOUT 待空窗

## 续跑建议
- `bash run_queue.sh resume` 或 `TIMEOUT_S=3600 bash run_queue.sh sctbench`
- 勿与源机 sctbench_full_remaining / Chess 同 dockerd 抢跑

---
## Remaining-stream update (2026-11-02 20:20 Asia/Shanghai)

New/updated from `sctbench_full` (3600s walls, README args):

| Subject | Status | errors | tests | dur_s |
|---|---|---|---|---|
| Inspect_qsort_mt | BUGS_OK | 139 | 8648 | 122 |
| Inspect_ctrace-test | BUGS_OK | 4 | 13 | 3 |
| Splash2_fft | BUGS_OK | 94 | 194 | 8 |
| Splash2_lu | BUGS_OK | 55 | 114 | 5 |
| Splash2_barnes | BUGS_OK | 342 | 704 | 95 |
| Chess_StateWSQ | BUGS_INCOMPLETE_TIMEOUT_3600s | partial_62 | 28210 | 5290 |
| Chess_ILWSQState | BUGS_INCOMPLETE_TIMEOUT_3600s | partial_87 | 29998 | 5518 |
| Inspect_boundedBuffer | INCOMPLETE_TIMEOUT_3600s | NA | 0 | 4999 |
| CS_twostage_20 | BUGS_OK | 3075 | 62431 | 2652 |

Still running on source machine: **CS_reorder_50** (do not kill). Queued: CS_twostage_50, CS_reorder_100, CS_twostage_100.

---
## 2026-11-07/08 刷新

- `summary_full_final.tsv` 已放入 `prior_results/`（覆盖/补充 remaining 流；含 Chess_StateWSQ / Chess_ILWSQState / Inspect_boundedBuffer / CS_reorder_50 等 TIMEOUT 部分结果）
- Chess `InterlockedWorkStealQueueWithState`：断点 **test 331200**，Error Found **294**；完整 log 仅 POINTER
- 六基线：**仍 NOT_RUN**，勿当作已跑
