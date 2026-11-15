# DONE vs TODO（实验二 · 六基线对比）

时间戳：2026-11-15 Asia/Shanghai

## DONE

| 项 | 状态 |
|----|------|
| Period 侧 CVE/SCTBench 参考数字（PRIOR_REF） | `prior_results/` |
| 科目表、复现脚本、旧内核说明 | `subjects/`、`scripts/`、`notes/` |
| 六基线实测（18 个程序） | `results/baselines/` |

这 18 个程序已在 Ubuntu 14.04 客户机上跑完 IPB、IDB、DFS、PCT、Random、Maple。客户机内核 `3.13.0-170-generic`，Intel Pin 2.12。协议：调度上限 10000，深度不超过 3，每次调用墙钟 300 秒，竞态检测最多 10 次。状态为 `TIMEOUT` 或 `BUGS_TIMEOUT` 的行是碰到 300 秒上限的部分结果，不是跑满 10000 条调度。

已写入结果的程序：`CS_account`、`CS_lazy01`、`CS_deadlock01`、`CS_reorder_3`、`CS_token_ring`、`CS_twostage`、`CS_bluetooth_driver`、`CS_carter01`、`CS_stack`、`CS_circular_buffer`、`CS_reorder_4`、`CS_reorder_5`、`CS_queue`、`CS_wronglock_3`、`CB_stringbuffer`、`CS_wronglock`、`CS_reorder_10`、`CB_aget-bug2`。

`prior_results/` 里的 Period 数字仍是 PRIOR_REF，没有改成基线数字。

## 尚未写入

其余程序还在同一队列里，这次没有放进结果表。RADBench 未构建。`CB_aget-bug2` 的 Random 没有完成一次调度（`FAIL`），Maple 在 300 秒时没有跑起来。
