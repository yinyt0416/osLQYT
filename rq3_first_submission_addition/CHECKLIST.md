# CHECKLIST · 实验三 RQ3 续跑

- [ ] Docker + `period:latest` 就绪（见 MACHINE_SETUP.md）
- [ ] `bash -n run_queue.sh scripts/*.sh`
- [ ] `bash run_queue.sh rq3` → `results/rq3/rq3_overhead.csv`
- [ ] 对照 `prior_results/rq3/rq3_overhead.csv`
- [x] 在旧内核虚拟机完成 race、IPB、IDB、PCT（40/40 组合有终态记录）
- [x] 提交 `results/rq3/sctbench/` 原始输出、日志、状态表和环境信息
- [x] 提交 `scripts/baselines/` 正式运行与预检脚本
- [ ] 本包无 `run_Serial` / `rq1` 路径（Serial 见实验一）
- [ ] 未与源机长任务抢同一 dockerd
