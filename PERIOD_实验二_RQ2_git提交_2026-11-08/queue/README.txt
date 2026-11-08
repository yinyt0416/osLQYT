实验二 / RQ2 队列入口：
  bash run_queue.sh period     # PERIOD 自身：smoke → CVE → SCTBench
  bash run_queue.sh baselines  # 六基线 clone + stubs（实测需旧内核 VM）
  bash run_queue.sh all        # 两者都跑
先验证据：prior_results/（只读）
新跑输出：results/{smoke,cve,sctbench}/ 与 results/baselines/
