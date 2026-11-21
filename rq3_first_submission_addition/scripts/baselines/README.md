# IPB / IDB / PCT 基线

这些基线由 SCTBench 提供，不在 PERIOD 容器中运行。官方 SCTBench 使用 Pin，并要求 Linux 内核不高于 3.x。先运行 `run_sctbench_preflight.sh`，只有 `run_many`、Maple runner、Pin、匹配后的测试对象和旧内核检查都通过，才能开始正式测量。

统一参数：

- schedule budget：10,000；
- IPB：SCTBench mode `pb`，bounds 0–4；
- IDB：SCTBench mode `db`，bounds 0–4；
- PCT：SCTBench mode `pct`，depth 3；
- 每个工具单独保存逐次调用、错误、超时与原始日志；
- 不把 Pin/ASAN 工具错误计为程序错误。

正式实验使用 `run_sctbench_rq3.sh`。`rq3_sctbench_matched.txt` 固定记录与 PERIOD 对应的 10 个 SCTBench 对象；`doubleFree` 仅是 PERIOD 冒烟对象，SCTBench 中没有同名、同实现的可比对象，因此不伪造其基线数据。

脚本先按 SCTBench 官方流程生成 race database，再依次运行 IPB (`pb`)、IDB (`db`) 和 PCT (`pct`)。默认每种方法、每个对象的 schedule budget 为 10,000，单次搜索上限为 300 秒，原始日志和运行元数据保存在 `$SCT_ROOT/rq3-formal`。
