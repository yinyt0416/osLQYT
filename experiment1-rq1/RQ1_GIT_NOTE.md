# 实验一 RQ1 Git 提交说明

- 提交人：殷雨婷
- 学号：1240017048
- 对应论文问题：RQ1，比较 PERIOD 的 Period 与 Serial 调度方式
- 本次性质：阶段性 Git 提交，不是项目主 README 或最终实验报告

## 本次提交内容

- `scripts/`：RQ1 运行脚本及 Serial 调度器
- `subjects/rq1_subjects.tsv`：8 个已运行实验对象及参数
- `evidence/rq1_summary_reported.tsv`：本次已有结果汇总
- `evidence/logs/`：16 份 Period / Serial 原始运行日志

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

已运行 8 个实验对象，每个对象包含 Period 和 Serial 两种模式。现有结果属于初步复现证据，原始数字以 `evidence/logs/` 为准。

核查发现，带 `for prefix` 的调度行会被旧汇总脚本漏计；`CS_bluetooth_driver` 两种模式的原表为 47，日志实际均为 205。Serial 的长周期搜索范围也需要继续校准，因此本次结果不作为最终论文结论。

## 代码来源

- 原项目：<https://github.com/wcventure/PERIOD>
- 起始 commit：`cb8deb9a176e5bb292d70d46557dd61dc0e98069`
- 原项目许可证：MIT
- `scripts/run_Serial.py` 基于 PERIOD 的 `run_PDS.py` 调整，用于 RQ1 的 Serial 对照。
