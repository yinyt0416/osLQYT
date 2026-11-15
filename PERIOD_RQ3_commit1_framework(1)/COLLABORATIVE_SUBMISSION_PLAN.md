# PERIOD RQ3 两人四次提交计划

本方案把 RQ3 复现材料拆成两位成员、每人两次提交。提交前先在实际 Git 仓库根目录执行 `git status`，确认没有未预期的改动。

## 成员 A：实验框架与统一结果

### A-1：脚本、协议和科目清单

负责内容：实验脚本、环境说明、科目清单、已有参考结果和 manifest。

```bash
git add README.md SUBMIT.md CHECKLIST.md MACHINE_SETUP.md .gitignore
git add run_queue.sh scripts/ subjects/ manifests/ queue/ prior_results/
git commit -m "Add RQ3 experiment framework and protocol"
```

验收条件：

- `bash -n run_queue.sh scripts/*.sh` 通过；
- `subjects/rq3_subjects.tsv` 和 `subjects/rq3_expand_20261107.tsv` 存在；
- `manifests/` 明确记录 IPB/IDB/PCT 为 `NOT_RUN`，没有伪造结果。

### A-2：统一 RQ3 队列结果

负责内容：搭档脚本生成的 11 个 Period-versus-native 科目结果。

```bash
git add results/rq3/rq3_overhead.csv
git add results/rq3/rq3_overhead_2026-11-14.csv
git add results/rq3/README.md
git commit -m "Add unified RQ3 Period versus native results"
```

验收条件：

```bash
grep ',Period,' results/rq3/rq3_overhead.csv | wc -l
```

结果应为 11。不要提交 Docker 镜像、备份压缩包或完整 `out_*` 目录。

## 成员 B：补充实验与分析

### B-1：CVE 补充结果

负责内容：手动完成的 CVE RQ3 结果，包括有效结果和失败复现记录。

```bash
git add results/rq3/rq3_cve_manual.csv
git commit -m "Add ConVul CVE RQ3 supplement"
```

验收条件：

- 9 个 CVE 有有效 Period 时间；
- `CVE-2016-1973` 保持 `FAIL_DRY_RUN_SEGV`；
- 失败记录不参与 slowdown 平均值；
- 所有手动数据注明为单次测量。

### B-2：报告、限制和最终说明

负责内容：RQ3 最终报告、误差说明、基线未运行原因和复现边界。

```bash
git add reports/rq3-final.md
git add UPLOAD_GUIDE.md COLLABORATIVE_SUBMISSION_PLAN.md
git commit -m "Document RQ3 findings and reproduction limits"
```

验收条件：

- 明确区分统一 SCTBench/CB 结果与 CVE 补充结果；
- 明确 IPB/IDB/PCT 为 `NOT_RUN`；
- 说明 WSL2 6.x 内核与旧版 Pin 不兼容；
- 不宣称当前结果与论文硬件环境的绝对时间完全一致。

## 合并顺序

建议顺序为：A-1 → A-2 → B-1 → B-2。每次提交后由另一位成员执行：

```bash
git pull --rebase
git log --oneline -4
git status
```

如果两个人使用同一个 GitHub 仓库，不要同时修改同一份 CSV 或报告；B-1 只新增 `rq3_cve_manual.csv`，B-2 只新增和完善报告文档。
