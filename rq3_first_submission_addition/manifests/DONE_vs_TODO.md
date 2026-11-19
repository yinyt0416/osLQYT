# DONE vs TODO（实验三 / RQ3）

更新时间：2026-11-20（Asia/Shanghai）

## DONE

- 完成 11 个 Period/native overhead benchmark；
- 结果保存于 `results/rq3/rq3_overhead.csv`；
- 完成 9 个 CVE 的手动复现；
- 记录 CVE-2016-1973 dry-run SEGV；
- 完成 CVE-2017-6346 五次重复测量；
- 记录 native/Period 均值、标准差、slowdown、错误数和超时数；
- 提供 `scripts/repeat_rq3.sh` 自动重复运行脚本；
- 完成 RQ3 报告。

## 重复测量结果

subject：`CVE-2017-6346`

| metric | value |
|---|---:|
| native mean | 1.013733 s |
| native stdev | 0.008283 s |
| Period mean | 57.458043 s |
| Period stdev | 9.638607 s |
| slowdown | 56.679690x |
| Period timeouts | 0 |
| Period errors | 80, 79, 81, 79, 75 |

## TODO / NOT_RUN

| tool | status | reason |
|---|---|---|
| IPB | NOT_RUN | 需要 SCTBench 基线和兼容的 Ubuntu/Pin 环境 |
| IDB | NOT_RUN | 需要 SCTBench 基线和兼容的 Ubuntu/Pin 环境 |
| PCT | NOT_RUN | 需要 SCTBench 基线和兼容的 Ubuntu/Pin 环境 |

## 环境限制

native 日志出现 `sched_setattr: Invalid argument`，并伴随部分退出码 255。这是 Windows Docker Desktop/WSL2 内核与旧版调度接口不兼容导致的环境警告。Period 运行完成且无超时；绝对时间可能受宿主机调度影响。

