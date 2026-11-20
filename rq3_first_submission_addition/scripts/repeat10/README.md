# 十轮配对实验脚本

本目录是 `results/rq3/repeat10/` 正式结果对应的实际测量流程，与用于 11 个 benchmark 横向开销测量的 `run_rq3.sh` / `run_rq3_inside.sh` 分开。

文件说明：

- `rq3_worker.py`：准备测试对象并运行 Native/PERIOD 单轮测量；
- `rq3_timing.py`：记录 PERIOD 启动的目标进程调用耗时与状态；
- `rq3_summarize.py`：汇总 10 轮配对结果，保留无效轮；
- `run_rq3_repeat10.sh`：固定实验参数和十轮执行顺序。

在宿主机将本目录复制进已有 PERIOD 容器，然后在容器内运行：

```bash
docker cp scripts/repeat10/. period-rq3-local:/tmp/rq3-repeat10/
docker exec -it period-rq3-local bash /tmp/rq3-repeat10/run_rq3_repeat10.sh
```

默认参数与已提交结果一致：10 轮、Native 每轮调用 20 次、PERIOD budget 10000、整轮上限 300 秒、目标调用上限 5 秒。证据保存在容器的 `/evidence/rq3-cve-repeat10-<timestamp>/`。

脚本会运行 `instrument`、`prepare`，再逐轮执行 Native 和 PERIOD。只有同一轮两侧状态均为 `OK` 时，汇总脚本才计算 slowdown；异常轮仍写入逐轮 CSV。
