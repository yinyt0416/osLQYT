# PERIOD 实验二 · RQ2 自身检出 + 基线对比 · git 提交版（2026-11-08）

独立 mini-repo。对应论文 **RQ2**：

1. **PERIOD 自身检出**：冒烟 + ConVul Table 1 + SCTBench Table 2  
2. **六基线对比脚手架**：IPB / IDB / DFS / PCT / Random / Maple

（旧命名把「自身检出」叫包1、「基线对比」叫包2；现按论文 RQ 合并为本包。）

## 本版增量（相对 2026-11-02）

- PRIOR 刷新：`summary_full_final.tsv`（含 TIMEOUT 部分结果）
- Chess WithState：仅 POINTER + 状态笔记（**不**打进 ~142 MiB 完整 log）
- **六基线仍全部 NOT_RUN**（需 Ubuntu 14.04/16.04 + Pin；本机 kernel 6.12 不可跑）
- 今晚交付范围：**除六基线外**

## 重要：六基线需要旧内核 VM

Intel PIN 2.12（SCTBench / Maple）官方要求 **kernel ≤ 3.x**。  
在现代 Linux（kernel ≥ 6）上：

- `bash run_queue.sh baselines` 只会 **clone + 生成 NOT_RUN stub 表**（这是正确行为）
- **实测**六基线必须在 **Ubuntu 14.04 / 16.04 VM**（云主机或 QEMU），见 `notes/BASELINE_OLD_KERNEL_OPTIONS.md` 与 `notes/HOW_TO_RUN_BASELINES.md`
- **不要**用共享宿主 6.x 内核的 `docker run ubuntu:14.04` 冒充旧内核
- **不要**把 NOT_RUN stub 改成已跑数字

## Docker 前置（PERIOD 自身检出）

```bash
docker pull wcventure/period:stable
docker tag wcventure/period:stable period:latest
```

## 一键开跑

```bash
cd PERIOD_实验二_RQ2_git提交_2026-11-08

# PERIOD 自身
bash run_queue.sh period          # smoke → CVE → SCTBench → CB fixed
bash run_queue.sh smoke
bash run_queue.sh cve
bash run_queue.sh sctbench
bash run_queue.sh resume

# 六基线脚手架（现代机 = clone + NOT_RUN stubs）
bash run_queue.sh baselines
bash run_queue.sh status          # 打印 kernel 与阻塞说明

# 全部
bash run_queue.sh all
```

大用例：

```bash
RUN_HUGE=1 RUN_TWOSTAGE20=1 TIMEOUT_S=3600 bash run_queue.sh sctbench
```

脚本全部相对 `PACK_ROOT`，无绝对路径。

## 目录约定

| 路径 | 含义 |
|------|------|
| `scripts/` | PERIOD 容器内外跑法 + clone/stub/merge |
| `prior_results/` | **只读** PRIOR 证据；勿覆盖 |
| `prior_results/summary_full_final.tsv` | SCTBench 权威汇总（含 TIMEOUT 部分） |
| `prior_results/chess_interlocked/` | Chess WithState POINTER + 状态 |
| `results/{smoke,cve,sctbench}/` | PERIOD 新跑输出 |
| `results/baselines/` | 基线 stub / 实测输出 |
| `notes/` | 旧内核方案、HOW_TO、Maple 构建 |
| `manifests/` | DONE / TODO（自身 + 基线）+ 缺六基线报告草稿 |
| `subjects/` | 科目表（含 `rq2_subjects.tsv`） |
| `third_party/` | clone 目标（gitignore，勿整树提交） |

## 跑完后建议 `git add`

见 `SUBMIT.md`。

## 不含

- RQ1 Serial vs Period → 见 `PERIOD_实验一_RQ1_*`
- RQ3 开销 → 见 `PERIOD_实验三_RQ3_*`
