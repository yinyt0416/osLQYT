# PERIOD 实验三：RQ3 复现结果

本目录记录 RQ3 中 Period 与 native 的运行开销对比，以及 CVE 手动复现和重复测量结果。

## 当前已完成

- 11 个 benchmark 的 Period/native 开销测量；
- 9 个 CVE 的手动复现成功；
- CVE-2016-1973 的 dry-run SEGV 失败记录；
- CVE-2017-6346 的 10 轮配对正式实验（7 轮有效，保留全部异常轮）；
- 早期五轮实验已移入历史归档，不作为主结论；
- SCTBench 的 race、IPB、IDB、PCT 基线正式实验（40/40 组合均有终态记录）；
- 运行脚本、结果 CSV 和 RQ3 报告。

主要结果文件：

```text
results/rq3/rq3_overhead.csv
results/rq3/rq3_cve_manual.csv
results/rq3/repeat10/rq3_repeat10_rounds.csv
results/rq3/repeat10/rq3_repeat10_summary.json
results/rq3/sctbench/phase_status.csv
reports/rq3-sctbench-final.md
scripts/repeat_rq3.sh
scripts/repeat10/run_rq3_repeat10.sh
scripts/baselines/run_sctbench_rq3.sh
```

## CVE-2017-6346 十轮配对正式实验

正式实验以目标进程单次调用延迟为口径：10 轮中 7 轮完全有效，slowdown 均值为 `53.66x`、中位数为 `58.22x`，范围为 `14.12x–68.30x`。第 7、8、10 轮因超时或无完成调用而排除，但仍完整保留在逐轮 CSV 中。详见 `results/rq3/repeat10/README.md`。

早期五轮整轮计时数据仅作为历史记录，位于 `results/rq3/archive/five_round_legacy/`，不作为主结论，也不与十轮结果合并。

十轮正式结果的实际测量与汇总脚本位于 `scripts/repeat10/`。11 个 benchmark 的横向基线仍使用 `scripts/run_rq3.sh` 和 `scripts/run_rq3_inside.sh`，两类实验的对象与统计目的不同。

## SCTBench 基线结果

旧内核虚拟机上的 SCTBench 基线已完成。统一参数为 schedule budget 10,000、单次调用上限 300 秒；IPB/IDB 使用 bounds 0–4，PCT 使用 depth 3。

| phase | OK | TIMEOUT_OR_ERROR | total |
|---|---:|---:|---:|
| race | 10 | 0 | 10 |
| IPB (`pb`) | 5 | 5 | 10 |
| IDB (`db`) | 7 | 3 | 10 |
| PCT (`pct`) | 0 | 10 | 10 |

18 个 `TIMEOUT_OR_ERROR` 经日志核对均为超时。完整状态、逐对象日志、185 个原始输出和环境信息位于 `results/rq3/sctbench/`。这些结果证明基线流程已实际运行，并定性支持基线开销较高；由于本批次记录的是搜索任务总墙钟时间而非相对 Native 的单次执行 slowdown，不能据此宣称精确复现论文 Figure 7 的 `10–500x` 数值。

## 正式十轮实验运行方式

先将十轮脚本复制进已有 PERIOD 容器，再执行：

```bash
docker cp scripts/repeat10/. period-rq3-local:/tmp/rq3-repeat10/
docker exec -it period-rq3-local bash /tmp/rq3-repeat10/run_rq3_repeat10.sh
```

`scripts/repeat_rq3.sh` 是早期五轮历史流程，仅为追溯保留，不用于生成当前主结论。
