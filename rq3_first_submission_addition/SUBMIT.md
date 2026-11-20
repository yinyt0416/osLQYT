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
| （可选）`results/rq3/logs/*.log` 精选 | 体积可控时 |

## 禁止提交

- `__pycache__/`、docker 镜像、整目录无筛选 log
- `run_Serial.py` / RQ1 内容（属实验一）
- 假装已跑的六基线结果（IPB/IDB/PCT 仍 NOT_RUN）

```bash
git add README.md SUBMIT.md .gitignore MACHINE_SETUP.md CHECKLIST.md
git add run_queue.sh scripts/ subjects/ manifests/ queue/ prior_results/
git add results/.gitkeep results/rq3/.gitkeep
# after runs:
git add results/rq3/rq3_overhead.csv
git add results/rq3/repeat10/
git add results/rq3/archive/five_round_legacy/
```
