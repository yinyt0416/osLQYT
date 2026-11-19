# PERIOD 实验三：RQ3 复现结果

本目录记录 RQ3 中 Period 与 native 的运行开销对比，以及 CVE 手动复现和重复测量结果。

## 当前已完成

- 11 个 benchmark 的 Period/native 开销测量；
- 9 个 CVE 的手动复现成功；
- CVE-2016-1973 的 dry-run SEGV 失败记录；
- CVE-2017-6346 的 5 次重复测量；
- 运行脚本、结果 CSV 和 RQ3 报告。

主要结果文件：

```text
results/rq3/rq3_overhead.csv
results/rq3/rq3_cve_manual.csv
results/rq3/rq3_repeated_summary.csv
reports/rq3-final.md
scripts/repeat_rq3.sh
```

## CVE-2017-6346 五次重复测量

```text
native mean  = 1.013733 s
native stdev = 0.008283 s
Period mean  = 57.458043 s
Period stdev = 9.638607 s
slowdown     = 56.679690x
timeouts     = 0
```

Period 错误交错数为 `80, 79, 81, 79, 75`。native 日志中的 `sched_setattr: Invalid argument` 是 Windows Docker Desktop/WSL2 环境限制，已在报告中注明。

## 尚未完成

IPB、IDB、PCT 尚未进行实际测量，当前标记为 `NOT_RUN`。由成员liyucheng进行此部分操作。

## 运行方式

在 PERIOD 容器内执行：

```bash
chmod +x scripts/repeat_rq3.sh
scripts/repeat_rq3.sh 2017-6346 5 600
```


