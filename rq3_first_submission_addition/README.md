# PERIOD 实验三 · RQ3 开销 Period vs native · git 提交版（2026-11-08）

独立 mini-repo。对应论文 **RQ3**：native wall-time vs Period（精选科目）。

**不含** RQ1 Serial（见实验一）、**不含** RQ2 自身检出/基线（见实验二）。  

相对 IPB/IDB/PCT 的开销对比仍为 **NOT_RUN**（依赖实验二旧内核基线实测；本机 kernel 6.12 不可跑 Pin）。


## Docker 前置

```bash
docker pull wcventure/period:stable
docker tag wcventure/period:stable period:latest
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

## 本次第一次提交补充

本提交补充了 11 个 RQ3 subject 的运行脚本和统一 Period/native 开销结果：

- scripts/run_rq3.sh：宿主机入口脚本
- scripts/run_rq3_inside.sh：容器内运行脚本
- subjects/rq3_subjects.tsv：11 个 subject 清单
- 
esults/rq3/rq3_overhead.csv：native 时间、Period 时间、slowdown、schedules 和 errors

IPB、IDB、PCT、CVE 手动补充和五次重复测量不属于本次第一次提交。
