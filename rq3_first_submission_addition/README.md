# PERIOD 实验三：RQ3 复现结果

本目录记录 RQ3 中 Period 与 native 的运行开销对比，以及 CVE 手动复现和重复测量结果。

## 当前已完成

- 11 个 benchmark 的 Period/native 开销测量；
- 9 个 CVE 的手动复现成功；
- CVE-2016-1973 的 dry-run SEGV 失败记录；
- CVE-2017-6346 的 10 轮配对正式实验（7 轮有效，保留全部异常轮）；
- 早期五轮实验已移入历史归档，不作为主结论；
- 运行脚本、结果 CSV 和 RQ3 报告。

主要结果文件：

```text
results/rq3/rq3_overhead.csv
results/rq3/rq3_cve_manual.csv
results/rq3/repeat10/rq3_repeat10_rounds.csv
results/rq3/repeat10/rq3_repeat10_summary.json
reports/rq3-final.md
scripts/repeat_rq3.sh
```

## CVE-2017-6346 十轮配对正式实验

正式实验以目标进程单次调用延迟为口径：10 轮中 7 轮完全有效，slowdown 均值为 `53.66x`、中位数为 `58.22x`，范围为 `14.12x–68.30x`。第 7、8、10 轮因超时或无完成调用而排除，但仍完整保留在逐轮 CSV 中。详见 `results/rq3/repeat10/README.md`。

早期五轮整轮计时数据仅作为历史记录，位于 `results/rq3/archive/five_round_legacy/`，不作为主结论，也不与十轮结果合并。

## 尚未完成

IPB、IDB、PCT 尚未进行实际测量，当前标记为 `NOT_RUN`。由成员 liyucheng 进行此部分操作。

## 运行方式

在 PERIOD 容器内执行：

```bash
chmod +x scripts/repeat_rq3.sh
scripts/repeat_rq3.sh 2017-6346 5 600
```
