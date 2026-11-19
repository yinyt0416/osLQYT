# CHECKLIST · 实验三 RQ3 续跑

- [ ] Docker + `period:latest` 就绪（见 MACHINE_SETUP.md）
- [ ] `bash -n run_queue.sh scripts/*.sh`
- [ ] `bash run_queue.sh rq3` → `results/rq3/rq3_overhead.csv`
- [ ] 对照 `prior_results/rq3/rq3_overhead.csv`
- [ ] IPB/IDB/PCT 仍为 NOT_RUN 属预期（需实验二旧内核）
- [ ] 本包无 `run_Serial` / `rq1` 路径（Serial 见实验一）
- [ ] 未与源机长任务抢同一 dockerd
