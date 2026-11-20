# DONE vs TODO（实验三 / RQ3）

更新时间：2026-11-20（Asia/Shanghai）

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

## TODO / NOT_RUN

| tool | status | reason |
|---|---|---|
| IPB | NOT_RUN | 需要 SCTBench 基线和兼容的 Ubuntu/Pin 环境 |
| IDB | NOT_RUN | 需要 SCTBench 基线和兼容的 Ubuntu/Pin 环境 |
| PCT | NOT_RUN | 需要 SCTBench 基线和兼容的 Ubuntu/Pin 环境 |

## 环境限制

native 日志出现 `sched_setattr: Invalid argument`，并伴随部分退出码 255。这是 Windows Docker Desktop/WSL2 内核与旧版调度接口不兼容导致的环境警告。Period 运行完成且无超时；绝对时间可能受宿主机调度影响。

