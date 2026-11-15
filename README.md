# PERIOD 论文复现项目

> **仓库现有贡献说明：** 覃蕾霓（1240025809）负责论文三项主张与复现范围整理，并提交 RQ3 阶段性结果（`claims_1240025809_qinleini`）；殷雨婷（1240017048）负责实验一 RQ1 的代码、脚本、统计修正与重跑结果（`rq1-yinyuting-1240017048`）；谭鸿清（1240026714）负责实验二 RQ2 的复现脚本、结果整理及六基线实测（`rq2`）；Liyuchen（1240016951）负责报告 Introduction 和 RQ3 实验框架及运行说明（`Liyuchen-1240016951`）。

> **当前状态：阶段性 README（2026-11-15）**
> 仓库已形成 RQ1、RQ2、RQ3 的分支材料，但课程要求的三次独立运行、均值 ± 标准差、完整环境快照和最终英文报告仍未全部完成。以下内容只表示当前可核查进度，不代表最终论文结论。

## 1. 项目简介

本项目复现论文 **Controlled Concurrency Testing via Periodical Scheduling**（ICSE 2022）及其开源工具 **PERIOD**，重点检查周期性调度在并发程序测试中的探索能力、缺陷检测效果和运行开销。

- 原论文代码仓库：[wcventure/PERIOD](https://github.com/wcventure/PERIOD)
- 上游起始提交：`cb8deb9a176e5bb292d70d46557dd61dc0e98069`
- 课程复现仓库：[yinyt0416/osLQYT](https://github.com/yinyt0416/osLQYT)
- 主要运行方式：Linux x86_64 / WSL2 + Docker；旧内核基线使用 Ubuntu 14.04（kernel 3.13）

## 2. 复现问题

- **RQ1：探索能力。** 比较 Period 与 Serial 调度探索的执行前缀及错误交错。
- **RQ2：缺陷检测。** 检查 PERIOD 对已知并发缺陷的检测能力，并与 IPB、IDB、DFS、PCT、Random、Maple 六种基线比较。
- **RQ3：运行开销。** 比较 Period 与 native 的 wall-clock 时间，并在统一工作量下计算 slowdown。

## 3. 当前仓库结构

| 分支 | 负责人及主要内容 | 当前状态 |
| --- | --- | --- |
| `main` | 仓库统一入口 README | 仅保存项目总览，不放实验原始材料 |
| [`claims_1240025809_qinleini`](https://github.com/yinyt0416/osLQYT/tree/claims_1240025809_qinleini) | 覃蕾霓：论文主张 PDF、RQ3 的 11 个科目结果 | 已有阶段性 CSV；仍需统一协议和重复实验 |
| [`rq1-yinyuting-1240017048`](https://github.com/yinyt0416/osLQYT/tree/rq1-yinyuting-1240017048) | 殷雨婷：`experiment1-rq1/` 脚本、16 份日志和两份汇总 | Serial 与 prefix 统计已修正并完成一次重跑 |
| [`rq2`](https://github.com/yinyt0416/osLQYT/tree/rq2) | 谭鸿清：RQ2 脚本、PERIOD 历史结果、六基线结果 | 已完成 18 个程序的六基线阶段性实测 |
| [`Liyuchen-1240016951`](https://github.com/yinyt0416/osLQYT/tree/Liyuchen-1240016951) | Liyuchen：Introduction PDF、RQ3 框架和运行说明 | 框架仍缺其引用的 `scripts/`、`subjects/` 等目录，暂不能独立运行 |

仓库中的 `OK`、`BUGS_OK`、`BUGS_TIMEOUT`、`TIMEOUT`、`INCOMPLETE` 和 `NOT_RUN` 含义不同；超时或未运行项目不得表述为成功复现。

## 4. 当前复现进度

### RQ1：探索能力

- 已对 8 个测试对象完成一次修复后的 Period/Serial 对照，共 16 份原始日志。
- 已修正 Serial 相对 bug depth，N=4、depth=3 时不再错误跳过第 5、6 周期。
- 已修正 `test NNNN for prefix ...:` 漏计问题，日志与汇总现已一致。
- 关键回归结果：`reorder_3` Serial=30、`reorder_4` Serial=384、`bluetooth_driver` Period/Serial=205。
- 当前仅运行一次，尚不能形成均值 ± 标准差或最终优劣结论。

### RQ2：缺陷检测

- 已保留 PERIOD smoke、CVE、SCTBench 的脚本、历史汇总和部分原始日志。
- 本周已在 Ubuntu 14.04（kernel 3.13）上对 18 个程序运行 IPB、IDB、DFS、PCT、Random 和 Maple，参数为调度上限 10000、墙钟上限 300 秒。
- `results/baselines/` 保存六种工具的独立 TSV 和 `compare_summary.tsv`；部分组合为 `BUGS_TIMEOUT`、`TIMEOUT` 或 `FAIL`。
- 尚未进入本轮队列的程序没有结果；PERIOD 与六基线的指标定义和超时口径仍需在最终对照表中统一。
- CVE 历史汇总与现有原始日志仍需补齐完整证据链。

### RQ3：运行开销

- `Liyuchen-1240016951` 分支提供 RQ3 框架、`run_queue.sh` 和提交说明，但脚本引用的 `scripts/`、`subjects/`、`prior_results/` 尚未随分支提交。
- `claims_1240025809_qinleini` 分支提供 11 个 Period-versus-native 科目的阶段性 CSV。
- 当前 slowdown 为 `tool_s / native_s`；部分结果来自不同批次，且每个配置尚未完成至少三次独立运行。
- 在统一计时协议、保留每次原始样本并报告均值 ± 标准差之前，不发布最终性能结论。

## 5. 周进展

### 上周（截至 2026-11-08）

- 建立 `main` 项目入口和贡献说明。
- RQ1 上传 8 个对象的初步 Period/Serial 脚本、日志和汇总。
- RQ2 上传 PERIOD 自身检出材料及六基线运行框架，六基线当时尚未实测。
- 完成论文三项主张与复现范围的初步整理；RQ3 尚未形成远程分支材料。

### 本周（2026-11-09 至 2026-11-15）

- RQ1 修正 Serial 搜索范围和 prefix 计数，完成一次统一参数重跑并更新 16 份日志。
- RQ2 新增 18 个程序 × 6 种基线的阶段性实测结果。
- 新增第四位成员分支，提交报告 Introduction 与 RQ3 初步框架；框架依赖文件仍需补齐。
- RQ3 上传 11 个科目的阶段性结果；仍需统一协议和完成三次独立运行。
- `main` 清理临时 RQ3 压缩包，继续只保留统一入口 README。

## 6. 快速开始

### 获取仓库和镜像

```bash
git clone https://github.com/yinyt0416/osLQYT.git
cd osLQYT
docker pull wcventure/period:stable
docker tag wcventure/period:stable period:latest
```

### RQ1

```bash
git switch rq1-yinyuting-1240017048
cd experiment1-rq1
bash run_queue.sh rq1
```

默认参数为 depth=3、预算 10000、单项超时 480 秒，输出写入 `results/rq1/`。

### RQ2

```bash
git switch rq2
cd PERIOD_实验二_RQ2_git提交_2026-11-08
bash run_queue.sh smoke
```

PERIOD 自身实验可通过 `period`、`cve`、`sctbench` 等阶段运行。六基线依赖旧内核环境，不应在现代内核容器中伪装运行。

### RQ3

```bash
git switch Liyuchen-1240016951
cd "PERIOD_RQ3_commit1_framework(1)"
```

该分支目前用于查看框架和说明，尚不能直接执行 `run_queue.sh`。RQ3 阶段性结果位于 `claims_1240025809_qinleini` 分支的 `PERIOD_RQ3_commit2_results/results/rq3/`。

## 7. 结果记录与提交规范

- 保存运行命令、run ID、开始与结束时间、硬件、系统与内核、编译器、镜像 digest、参数、退出码和原始日志。
- 原始证据与汇总分开保存；重复实验使用 `run_01/run_02/run_03` 等独立目录，不互相覆盖。
- 报告中的每一个数字必须能够追溯到对应脚本、配置和原始日志。
- 每个正式配置至少独立运行 3 次，报告均值 ± 标准差。
- 每位成员使用自己的 GitHub 账号提交实质内容；每条 commit message 必须包含实际提交人的学号和全名。
- 最终版本通过检查后打标签 `v1.0`。

## 8. 下一步工作

1. 对 RQ1、RQ2、RQ3 的正式子集各完成至少三次独立运行，并保留逐次日志。
2. 为 RQ2 统一 PERIOD 与六基线的 bug、schedule、first bug 和 timeout 指标定义。
3. 补齐 RQ3 框架引用的脚本、科目表和环境文件，统一等工作量计时协议并重新计算 Paper vs. Ours slowdown。
4. 补齐 CVE、SCTBench 和基线原始证据、环境快照及偏差表。
5. 完成单因素 Extension、英文最终报告、图表、贡献声明与 AI 使用声明。
6. 最终核查 README 可复现性、提交历史和成员贡献后打 `v1.0`。

## 9. 来源与说明

本项目基于 [wcventure/PERIOD](https://github.com/wcventure/PERIOD) 开展课程复现，上游代码采用 **MIT License**。上游代码的版权和许可证文本以原仓库为准；本仓库新增脚本、实验配置和结果说明应记录作者、日期及相对上游的修改。
