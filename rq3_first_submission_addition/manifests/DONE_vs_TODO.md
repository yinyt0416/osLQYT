# DONE vs TODO（实验三 / RQ3）

更新时间：2026-11-21（Asia/Shanghai）

## DONE

- 完成 11 个 Period/native overhead benchmark；
- 结果保存于 `results/rq3/rq3_overhead.csv`；
- 完成 9 个 CVE 的手动复现；
- 记录 CVE-2016-1973 dry-run SEGV；
- 完成 CVE-2017-6346 十轮配对正式实验，并记录 3 个无效轮次；
- 将存在环境警告的早期五轮结果移入历史归档；
- 记录 native/Period 均值、标准差、slowdown、错误数和超时数；
- 提供 `scripts/repeat10/` 十轮正式实验的运行、计时与汇总脚本；
- 保留 `scripts/repeat_rq3.sh` 作为早期五轮历史流程；
- 在兼容旧内核虚拟机完成 SCTBench race、IPB、IDB、PCT，40/40 组合均有终态记录；
- 保存 185 个原始输出、逐对象日志、状态表、环境和可断点续跑脚本；
- 完成 RQ3 报告。

## 正式重复测量结果

subject：`CVE-2017-6346`

| metric | value |
|---|---:|
| 有效配对 | 7 / 10 |
| Native 单次延迟均值 | 7.858 ms |
| Period 单次延迟均值 | 299.236 ms |
| slowdown 均值 | 53.66x |
| slowdown 中位数 | 58.22x |
| slowdown 范围 | 14.12x–68.30x |

原始逐轮数据位于 `results/rq3/repeat10/`。早期五轮整轮计时结果位于 `results/rq3/archive/five_round_legacy/`，仅供历史追溯，不作为主结论。

## SCTBench 基线结果

| tool | OK | TIMEOUT_OR_ERROR | total |
|---|---:|---:|---:|
| race | 10 | 0 | 10 |
| IPB | 5 | 5 | 10 |
| IDB | 7 | 3 | 10 |
| PCT | 0 | 10 | 10 |

18 个非 OK 终态经日志核对均为超时。结果位于 `results/rq3/sctbench/`，运行脚本位于 `scripts/baselines/`。

## 环境限制

native 日志出现 `sched_setattr: Invalid argument`，并伴随部分退出码 255。这是 Windows Docker Desktop/WSL2 内核与旧版调度接口不兼容导致的环境警告。Period 运行完成且无超时；绝对时间可能受宿主机调度影响。

SCTBench 基线不在 WSL2 中执行，而是在 Linux `3.2.0-23-generic` 虚拟机中完成。该批次的搜索任务总墙钟时间不能直接当作论文 Figure 7 的 Native 归一化 slowdown。

