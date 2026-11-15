# PERIOD 实验三 · RQ3 开销 Period vs native · git 提交版（2026-11-08）

独立 mini-repo。对应论文 **RQ3**：native wall-time vs Period（精选科目）。

**不含** RQ1 Serial（见实验一）、**不含** RQ2 自身检出/基线（见实验二）。  
（旧命名「包3」曾把 RQ1+RQ3 混在一起；现已按论文 RQ 拆开。）

相对 IPB/IDB/PCT 的开销对比仍为 **NOT_RUN**（依赖实验二旧内核基线实测；本机 kernel 6.12 不可跑 Pin）。

## 本版增量（相对 2026-11-02）

- PRIOR 扩科至 **11 Period 科**（curated 7 + expand 4）；合并表 `prior_results/rq3/rq3_overhead_merged_20261107.csv`
- `subjects/rq3_subjects.tsv` 已含扩科科目
- IPB/IDB/PCT 行在合并 CSV 中明确 **NOT_RUN**

## Docker 前置

```bash
docker pull wcventure/period:stable
docker tag wcventure/period:stable period:latest
```

## 一键

```bash
cd PERIOD_实验三_RQ3_git提交_2026-11-08
bash run_queue.sh rq3
# 或
bash run_queue.sh all
```

## 目录

| 路径 | 含义 |
|------|------|
| `scripts/run_rq3*.sh` | RQ3 容器内外跑法 |
| `subjects/rq3_subjects.tsv` | RQ3 科目表（11 科） |
| `prior_results/rq3/` | 只读 PRIOR（含 merged + expand） |
| `results/rq3/` | 你的新跑 |

## 跑完 git add

见 `SUBMIT.md`：`results/rq3/rq3_overhead.csv`。
