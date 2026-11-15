# GitHub 上传顺序

两位成员各提交两次，顺序为 A-1、A-2、B-1、B-2。

## A-1：框架和协议

如果从搭档压缩包复制了 `run_queue.sh`、`scripts/`、`subjects/`、`manifests/`、`prior_results/`，提交：

```bash
git add README.md SUBMIT.md CHECKLIST.md MACHINE_SETUP.md .gitignore
git add run_queue.sh scripts/ subjects/ manifests/ queue/ prior_results/
git commit -m "Add RQ3 experiment framework and protocol"
```

## A-2：统一 RQ3 结果

```bash
git add results/rq3/rq3_overhead.csv
git commit -m "Add unified RQ3 Period versus native results"
```

## B-1：CVE 补充结果

```bash
git add results/rq3/rq3_cve_manual.csv
git commit -m "Add ConVul CVE RQ3 supplement"
```

## B-2：报告和限制

```bash
git add reports/rq3-final.md UPLOAD_GUIDE.md COLLABORATIVE_SUBMISSION_PLAN.md
git commit -m "Document RQ3 findings and reproduction limits"
```

每次提交前执行 `git status`，提交后由另一位成员执行 `git pull --rebase`。不要提交 Docker 镜像、tar.gz、`out_*`、完整临时日志或 `__pycache__`。
