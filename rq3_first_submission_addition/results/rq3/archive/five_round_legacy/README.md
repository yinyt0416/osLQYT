# 五轮实验历史归档

本目录保存 `CVE-2017-6346` 的早期五轮重复实验，仅用于追溯实验过程，不作为 RQ3 主结论。

该实验按整轮运行时间统计，得到 slowdown `56.679690x`。运行期间 Native 出现退出码 255、`sched_setattr: Invalid argument` 和潜在线程泄漏提示，且计时口径与当前十轮配对实验不同。因此该结果不能与十轮数据合并，也不应在报告或答辩中作为正式结果引用。

RQ3 的正式重复实验结果位于：

```text
../../repeat10/rq3_repeat10_rounds.csv
../../repeat10/rq3_repeat10_summary.json
```
