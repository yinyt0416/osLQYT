# PERIOD 论文复现项目

> **当前状态：阶段性 README（2026-11-08）**  
> 本仓库仍在持续更新，目前内容用于记录和共享阶段性复现工作，不代表最终实验结论或课程最终报告。

## 1. 项目简介

本项目复现论文 **Controlled Concurrency Testing via Periodical Scheduling**（ICSE 2022）及其开源工具 **PERIOD**，重点检查周期性调度在并发程序测试中的探索能力、缺陷检测效果和运行开销。

- 原论文代码仓库：[wcventure/PERIOD](https://github.com/wcventure/PERIOD)
- 本项目采用的上游起始提交：`cb8deb9a176e5bb292d70d46557dd61dc0e98069`
- 课程复现仓库：[yinyt0416/osLQYT](https://github.com/yinyt0416/osLQYT)
- 计划采用的主要运行方式：Linux x86_64 服务器 + Docker

## 2. 复现问题

项目按照论文的三个研究问题组织：

- **RQ1：探索能力。** 比较 PERIOD 的并行周期调度与 Serial 调度所探索的不同执行前缀。
- **RQ2：缺陷检测。** 检查 PERIOD 对已知并发缺陷的检测能力，并为论文中的其他基线工具准备对比入口。
- **RQ3：运行开销。** 在可比工作量下测量 PERIOD 相对原生运行及其他方法的时间开销。

## 3. 当前仓库结构

| 分支 | 主要内容 | 当前状态 |
| --- | --- | --- |
| `main` | 项目计划文档与仓库统一入口 README | 当前为阶段性版本，后续持续更新 |
| [`claims_1240025809_qinleini`](https://github.com/yinyt0416/osLQYT/tree/claims_1240025809_qinleini) | 论文主张整理分支 | 分支已创建，独立内容尚未合并 |
| [`rq1-yinyuting-1240017048`](https://github.com/yinyt0416/osLQYT/tree/rq1-yinyuting-1240017048) | `experiment1-rq1/`：RQ1 代码、脚本、日志和简要说明 | 已上传初步结果，仍需校准统计口径 |
| [`rq2`](https://github.com/yinyt0416/osLQYT/tree/rq2) | RQ2 运行脚本、结果整理和基线框架 | 已有阶段性材料，部分长任务超时，外部基线尚未运行 |
| （待创建）RQ3 分支 | RQ3 等工作量性能测试 | 尚未上传，测量方法仍在修正 |

仓库中保存的日志和汇总文件用于保留可核查证据。标记为 `NOT_RUN`、`INCOMPLETE` 或 `TIMEOUT` 的项目不应被解释为已经成功复现。

## 4. 当前复现进度

### RQ1：探索能力

- 已整理 8 个测试对象的 Period/Serial 两组运行材料，共 16 份原始日志。
- 已提供队列脚本、结果收集脚本和 `rq1_summary.tsv` 汇总入口。
- 当前结果属于初步结果：旧统计脚本可能少计日志中的 `test ... for prefix` 记录，例如 `bluetooth_driver` 的汇总数与原始日志计数不一致。
- Serial 组的长周期探索仍需在服务器上继续运行和校准，因此暂不作最终优劣结论。

### RQ2：缺陷检测

- 已保留 smoke test 历史日志，并整理了 PERIOD 自身检测流程及 SCTBench/CVE 结果框架。
- 最近一次 SCTBench 汇总包含 37 条记录，其中部分任务已完成，另有 7 条为超时或不完整状态，后续需要续跑。
- IPB、IDB、DFS、PCT、Random 和 Maple 等外部基线目前仍为 `NOT_RUN`；仓库中的相关脚本只是接口框架，不等同于基线结果。
- 历史 CVE 汇总与当前保留的原始日志数量尚未完全对应，最终报告前需要补齐证据链。

### RQ3：运行开销

- 本地已有早期计时材料，但现有指标使用“完整搜索时间 / 单次原生运行时间”，与论文图表要求的等工作量比较不一致。
- 后续将统一工作量，每个配置至少独立运行 3 次，并报告均值和标准差。
- 在重新测量完成前，仓库不发布 RQ3 的最终性能结论。

## 5. 运行环境

建议在 Linux x86_64 多核服务器上运行：

- Docker
- 可使用特权容器的账号
- 足够的磁盘空间保存镜像、构建产物和日志
- PERIOD 镜像：`wcventure/period:stable`

PERIOD 使用 Linux `SCHED_DEADLINE` 调度能力，因此容器通常需要 `--privileged`。Windows/macOS 本机可用于整理代码和结果，但不建议作为核心实验环境。

## 6. 快速开始

### 获取仓库和镜像

```bash
git clone https://github.com/yinyt0416/osLQYT.git
cd osLQYT

docker pull wcventure/period:stable
docker tag wcventure/period:stable period:latest
```

首次拉取镜像和构建测试对象耗时较长；实际运行时间与服务器配置、测试对象和超时设置有关。

### 查看并运行 RQ1

以下命令从仓库根目录执行：

```bash
git switch rq1-yinyuting-1240017048
cd experiment1-rq1
bash run_queue.sh rq1
```

RQ1 默认按队列执行测试对象，并将日志和汇总写入实验目录。部分任务的单项超时上限为 480 秒，完整运行前请先阅读该分支中的 `RQ1_GIT_NOTE.md` 和脚本参数。

### 查看 RQ2

```bash
git switch rq2
cd PERIOD_实验二_RQ2_git提交_2026-11-08
bash run_queue.sh smoke
```

RQ2 包含短流程验证、长时间实验和结果整理材料。上面的命令只执行 smoke test；历史正常输出包含 `Total Error Interleavings: 4`。确认短流程成功后，再依据该分支说明启动 CVE/SCTBench 长任务。长任务可达到 3600 秒超时上限，运行前应检查输出目录、参数和服务器剩余空间。外部基线目前尚未具备一键复现条件。

## 7. 结果记录约定

- 保存运行命令、开始/结束时间、服务器配置、退出码和原始日志。
- 原始证据与人工整理的汇总分开保存，不直接修改原始日志。
- 明确区分 `OK`、`BUGS_OK`、`TIMEOUT`、`INCOMPLETE` 和 `NOT_RUN`。
- 任何论文级结论都必须能追溯到对应脚本、配置和原始输出。
- 性能实验使用相同工作量，并至少重复 3 次后报告均值和标准差。

## 8. 分支与提交规范

各成员应在独立分支完成实验，检查后再通过 Pull Request 合并到 `main`。根据课程要求，每条提交信息必须包含**实际提交人的学号和姓名**，格式例如：

```text
<学号> <姓名>：更新实验脚本与结果说明
```

请勿提交镜像、构建缓存、体积过大的临时文件、账号凭据或无法说明来源的数据。阶段性结果应在说明文件中明确限制，避免被误认为最终结论。

## 9. 下一步工作

1. 修正 RQ1 前缀计数脚本，并在服务器上完成 Period/Serial 的统一参数重跑。
2. 续跑 RQ2 中超时或不完整的测试对象，补齐 CVE 原始证据。
3. 安装并实际运行可复现的 RQ2 外部基线；无法运行的项目记录具体原因。
4. 按等工作量和多次重复原则重新测量 RQ3。
5. 汇总服务器软硬件环境、复现偏差和完整运行命令。
6. 所有证据检查通过后，再更新最终 README 和英文 PDF 报告。

## 10. 来源与说明

本项目基于 [wcventure/PERIOD](https://github.com/wcventure/PERIOD) 开展课程复现，上游代码采用 **MIT License**。上游代码的版权与许可证文本以原仓库为准；本仓库新增脚本、实验配置和结果说明应同时记录作者、日期及相对上游的修改。

本 README 只承担仓库导航和阶段性进度说明，不替代课程要求的最终英文复现报告。
