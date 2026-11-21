# 交作业清单 · 实验三 RQ3（Period vs native 开销）

日期戳：2026-11-08 Asia/Shanghai

## 必须提交（已打包）

- [x] README / SUBMIT / .gitignore / MACHINE_SETUP / CHECKLIST
- [x] `run_queue.sh` + `scripts/`（`run_rq3.sh`、`run_rq3_inside.sh`）
- [x] `subjects/rq3_subjects.tsv` `manifests/`
- [x] `prior_results/rq3/`（含 `rq3_overhead_merged_20261107.csv` + expand 日志）

## 跑实验后必须补交

| 文件 | 说明 |
|------|------|
| `results/rq3/rq3_overhead.csv` | Period vs native |
| `results/rq3/repeat10/` | CVE-2017-6346 十轮配对正式结果 |
| `results/rq3/archive/five_round_legacy/` | 早期五轮历史记录，不作为主结论 |
| `scripts/repeat10/` | 十轮配对实验的实际运行、计时与汇总脚本 |
| `results/rq3/sctbench/` | SCTBench race/IPB/IDB/PCT 的完整状态、日志、原始输出与环境信息 |
| `scripts/baselines/` | SCTBench 预检、对象清单和可断点续跑驱动 |
| `reports/rq3-sctbench-final.md` | SCTBench 最终结果与解释边界 |
| （可选）`results/rq3/logs/*.log` 精选 | 体积可控时 |

## 禁止提交

- `__pycache__/`、docker 镜像、整目录无筛选 log
- `run_Serial.py` / RQ1 内容（属实验一）
- 把超时行改写成成功或发现 bug；必须保留 `TIMEOUT_OR_ERROR` 原始分类
- `.vagrant/`、VirtualBox 镜像、SSH 私钥或完整虚拟机目录
- 与解压结果重复的 ZIP/TAR 包

```bash
git add README.md SUBMIT.md .gitignore MACHINE_SETUP.md CHECKLIST.md
git add run_queue.sh scripts/ subjects/ manifests/ queue/ prior_results/
git add results/.gitkeep results/rq3/.gitkeep
# after runs:
git add results/rq3/rq3_overhead.csv
git add results/rq3/repeat10/
git add results/rq3/archive/five_round_legacy/
git add scripts/repeat10/
git add results/rq3/sctbench/
git add scripts/baselines/
git add reports/rq3-sctbench-final.md
```
