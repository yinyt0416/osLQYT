# DONE vs TODO（实验二 · 六基线对比）

时间戳：2026-11-16 Asia/Shanghai

## DONE

| 项 | 状态 |
|----|------|
| Period 侧 CVE/SCTBench 参考数字（PRIOR_REF） | `prior_results/` |
| 科目表、复现脚本、旧内核说明 | `subjects/`、`scripts/`、`notes/` |
| 六基线实测（31 个程序） | `results/baselines/` |
| 结果表 | `results/baselines/结果表.md` |

这 31 个已构建程序已在 Ubuntu 14.04 客户机上跑完 IPB、IDB、DFS、PCT、Random、Maple。客户机内核 `3.13.0-170-generic`，Intel Pin 2.12。协议：调度上限 10000，深度不超过 3，每次调用墙钟 300 秒，竞态检测最多 10 次。状态为 `TIMEOUT` 或 `BUGS_TIMEOUT` 的行是碰到 300 秒上限的部分结果，不是跑满 10000 条调度。

`prior_results/` 里的 Period 数字仍是 PRIOR_REF，没有改成基线数字。

## 未纳入

RADBench 的 5 个程序没有构建。`CB_aget-bug2` 和 `CB_pbzip2-0.9.4` 的 Random 没有完成一次调度（`FAIL`）。
