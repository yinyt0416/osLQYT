# 实验一 RQ1 Git 提交说明

- 提交人：殷雨婷
- 学号：1240017048
- 对应论文问题：RQ1，比较 PERIOD 的 Period 与 Serial 调度方式
- 本次性质：阶段性 Git 提交，不是项目主 README 或最终实验报告

## 本次提交内容

- `scripts/`：RQ1 运行脚本及 Serial 调度器
- `subjects/rq1_subjects.tsv`：8 个已运行实验对象及参数
- `evidence/rq1_summary_reported.tsv`：修复后单次重跑的结果汇总
- `evidence/rq1_summary_checked.tsv`：汇总值与日志计数的核对表
- `evidence/logs/`：16 份修复后单次重跑的 Period / Serial 原始运行日志

## 运行方法

准备 PERIOD 官方 Docker 镜像：

```bash
docker pull wcventure/period:stable
docker tag wcventure/period:stable period:latest
```

在本目录运行：

```bash
bash run_queue.sh rq1
```

默认设置为 depth=3、预算 10000、单项超时 480 秒，结果写入 `results/rq1/`。

## 当前说明

已修正两处运行脚本问题：

1. Serial 现在按 `iterPeriod - N + 1` 计算相对 bug depth，不再把 N=4、depth=3 的第 5、6 周期错误跳过。纯生成器回归中，`reorder_3` 固定切片为 30 个候选，`reorder_4` 为 384 个候选。
2. 汇总脚本现在同时统计 `test NNNN:` 和 `test NNNN for prefix ...:`，`CS_bluetooth_driver` 两种模式的日志和汇总均为 205。

2026-11-15 已在 Docker Desktop 4.99.0、Linux/WSL2 容器环境中完成一次修复后重跑，16 项均正常结束。关键回归结果为：`CS_reorder_3` Serial=30、`CS_reorder_4` Serial=384、`CS_bluetooth_driver` Period/Serial=205。两份汇总均已按新日志更新并核对一致。

本轮只完成一次运行，尚未满足课程“至少 3 次独立运行、均值 ± 标准差”的最终统计要求，因此仍作为阶段性证据，不作为最终论文结论。

## 代码来源

- 原项目：<https://github.com/wcventure/PERIOD>
- 起始 commit：`cb8deb9a176e5bb292d70d46557dd61dc0e98069`
- 原项目许可证：MIT
- `scripts/run_Serial.py` 基于 PERIOD 的 `run_PDS.py` 调整，用于 RQ1 的 Serial 对照。
