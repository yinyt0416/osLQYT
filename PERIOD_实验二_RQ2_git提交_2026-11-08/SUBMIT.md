# 交作业清单 · 实验二 RQ2（自身检出 + 基线对比）

日期戳：2026-11-08 Asia/Shanghai

把本目录当作一个独立 git 仓库（或子目录）提交。

## 必须提交（已打包）

- [x] `README.md` / `SUBMIT.md` / `.gitignore` / `MACHINE_SETUP.md` / `CHECKLIST.md`
- [x] `run_queue.sh` + `scripts/`
- [x] `subjects/` + `manifests/` + `notes/` + `queue/`
- [x] `prior_results/`（只读 PRIOR；含 `summary_full_final.tsv`、Chess POINTER；**无**大 Chess log）

## 跑实验后必须补交

| 文件 | 说明 |
|------|------|
| `results/cve/results/summary_cve.tsv` | ConVul 10 CVE 汇总 |
| `results/sctbench/results/summary_sctbench.tsv` | SCTBench 汇总 |
| `results/sctbench/results/summary_cb_fixed.tsv` | CB fixed（若跑了） |
| `results/smoke/` 下 smoke 摘要 | 若跑了 smoke |
| `results/baselines/*_results.tsv` | stub 或实测每工具表 |
| `results/baselines/compare_summary.tsv` | merge 后总表 |
| （若在旧内核 VM 跑通）各工具真实 bugs/schedules | 替换 NOT_RUN |

可选：少量代表性 `*.log`；**不要**整目录无筛选日志；**不要**提交 ~142 MiB Chess WithState 完整 log。

## 六基线声明（今晚交付）

IPB / IDB / DFS / PCT / Random / Maple 在本机 **6.12** 上均为 **NOT_RUN**。  
需要 **Ubuntu 14.04/16.04 + Pin** 的真 guest 内核才能实测。stub 表可提交，**勿假装已跑**。

## 禁止提交

- Docker 镜像 / `docker-data` / socket
- `__pycache__`、编译产物、PIN 工具树
- `third_party/sctbench/`、`third_party/maple/` 整树
- VM 镜像、`*.qcow2`
- Chess `InterlockedWorkStealQueueWithState` 完整 `.log`（用 POINTER）
- 含本机绝对路径的临时笔记

```bash
git add README.md SUBMIT.md .gitignore MACHINE_SETUP.md CHECKLIST.md
git add run_queue.sh scripts/ subjects/ manifests/ notes/ queue/ prior_results/
git add results/.gitkeep results/*/.gitkeep third_party/.gitkeep
# 跑完后：
git add results/cve/results/*.tsv results/sctbench/results/*.tsv
git add results/baselines/*.tsv
git status
```
