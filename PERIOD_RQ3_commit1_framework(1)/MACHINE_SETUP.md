# MACHINE_SETUP · 实验三 RQ3 开销（外机 Linux）

## 要求

Linux x86_64、Docker privileged、`period:latest`。

```bash
docker pull wcventure/period:stable
docker tag wcventure/period:stable period:latest
```

Windows → WSL2。

## DOCKER_HOST

默认系统 socket。覆盖：

```bash
export DOCKER_HOST=unix:///var/run/docker.sock
# 或
export DOCKER_SOCK=/var/run/docker.sock
```

## 自检

```bash
cd PERIOD_实验三_RQ3_git提交_2026-11-08
bash -n run_queue.sh scripts/*.sh
bash run_queue.sh rq3    # 写入 results/rq3/rq3_overhead.csv
```

可选环境变量：`NATIVE_REPEATS`（默认 5）、`TIMEOUT_S`、`BUDGET`、`PERIOD_IMAGE`。
