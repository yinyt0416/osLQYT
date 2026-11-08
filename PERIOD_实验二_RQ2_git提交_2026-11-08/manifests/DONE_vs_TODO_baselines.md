# DONE vs TODO（实验二 · 六基线对比）

时间戳：2026-11-08 Asia/Shanghai

## DONE（本包可交付的）

| 项 | 状态 |
|----|------|
| Period 侧 CVE/SCTBench 参考数字（PRIOR_REF） | ✅ `prior_results/`（含 `summary_full_final.tsv`） |
| 科目表 | ✅ `subjects/` |
| clone + stub 队列 | ✅ `bash run_queue.sh baselines` |
| 旧内核/VM 文档 | ✅ `notes/` |

## TODO / NOT_RUN（六基线 —— 今晚交付明确缺项）

| 工具 | 状态 | 原因 |
|------|------|------|
| IPB (`pb`) | **NOT_RUN** | 需 SCTBench + Intel Pin；**Ubuntu 14.04/16.04** guest（kernel≤3.x）；本机 **6.12** 不可跑 |
| IDB (`db`) | **NOT_RUN** | 同上 |
| DFS | **NOT_RUN** | 同上 |
| PCT | **NOT_RUN** | 同上 |
| Random | **NOT_RUN** | 同上 |
| Maple | **NOT_RUN** | 需 Pin + 旧工具链；见 `notes/MAPLE_BUILD.md` |

**不要**把 stub/`NOT_RUN` 行改成已跑数字。`bash run_queue.sh baselines` 在现代机上只应 clone + 生成 NOT_RUN stub。

## 阻塞摘要

- 作者观测主机内核 **6.12.x**：PIN 2.12 报 unsupported / AUX VEC 失败。  
- **共享宿主内核的 Docker `ubuntu:14.04` 无效**；需要真正的旧 guest 内核（云 VM 或嵌套 QEMU）。  
- 推荐：Ubuntu **14.04**（~3.13）或 **16.04**（4.4 + `-injection child`）。
