# CHECKLIST · 实验二 RQ2 续跑

## PERIOD 自身检出

- [ ] 已解压；`MACHINE_SETUP.md` 完成：Docker + privileged 可用
- [ ] `docker pull wcventure/period:stable && docker tag wcventure/period:stable period:latest`
- [ ] `bash -n run_queue.sh scripts/*.sh` 无语法错误
- [ ] `bash run_queue.sh smoke` → `Total Error Interleavings: 4`
- [ ] `bash run_queue.sh cve` → `results/cve/.../summary_cve.tsv` 10 行 BUGS_OK
- [ ] `bash run_queue.sh sctbench`（默认可跳过大用例）
- [ ] 对照 `manifests/DONE_vs_TODO.md`：TIMEOUT 科用更大 `TIMEOUT_S` 复跑
- [ ] 结果只写 `results/`；保留 `prior_results/` 作对照

## 六基线对比

- [ ] 阅读 `notes/README_NOTES.md` 与 `notes/BASELINE_OLD_KERNEL_OPTIONS.md`
- [ ] `bash run_queue.sh baselines` → 生成 `results/baselines/*_results.tsv` 与 `compare_summary.tsv`
- [ ] 确认六基线行为 **NOT_RUN**（在未建旧 VM 前这是正确状态）
- [ ] 准备 Ubuntu 14.04/16.04 VM；**不要**用共享 6.x 内核的 Docker 冒充
- [ ] VM 内按 `notes/HOW_TO_RUN_BASELINES.md` build + `run_many.py`
- [ ] 将 VM 结果回填 `results/baselines/`，更新 status 列
- [ ] 未把多 GB PIN/镜像打进 zip（按设计）
