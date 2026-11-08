# MACHINE_SETUP · 实验二 RQ2（外机 Linux）

## 两层机器

1. **任意现代 Linux（或 WSL2）**：PERIOD 自身检出（Docker `period:latest`）+ clone/stub 基线表。  
2. **旧内核 VM（Ubuntu 14.04/16.04）**：**唯一**能实际跑 IPB/IDB/DFS/PCT/Random/Maple（Intel PIN 2.12）的环境。

## PERIOD 自身检出（现代 Linux）

| 项 | 要求 |
|----|------|
| OS | Linux x86_64（推荐 Ubuntu 20.04/22.04） |
| Docker | ≥ 18.09，可 `docker run --privileged` |
| 磁盘 | ≥ 10 GiB 空闲 |
| CPU/内存 | ≥ 4 核 / ≥ 8 GiB 建议 |

```bash
sudo apt-get install -y docker.io git
sudo usermod -aG docker "$USER"   # 重新登录后
docker pull wcventure/period:stable
docker tag wcventure/period:stable period:latest

cd PERIOD_实验二_RQ2_git提交_2026-11-08
bash -n run_queue.sh scripts/*.sh
bash run_queue.sh smoke
```

覆盖 socket：`export DOCKER_HOST=unix:///path/to/docker.sock`

## 六基线脚手架（现代 Linux）

```bash
bash run_queue.sh baselines   # clone + NOT_RUN stubs + merge
bash run_queue.sh status
```

`third_party/sctbench` 与 `maple` 由 clone 拉入，已被 `.gitignore` 排除。

## 旧内核 VM（实测六基线）

详见 `notes/BASELINE_OLD_KERNEL_OPTIONS.md` 与 `notes/HOW_TO_RUN_BASELINES.md`。

摘要：

```bash
# 在 Ubuntu 14.04 VM 内：
sudo apt-get install -y libprotobuf-dev protobuf-compiler python-protobuf \
  build-essential m4 cmake python2.7
# 将 third_party/sctbench 同步进 VM 后：
cd ~/sctbench
cp -n env.template env.sh && source env.sh
build_maple
build_benchmarks
run_many.py --mode race --max 10 benchmarks/buggy.txt
run_many.py --mode pb --limit 10000 --timelimit 300 benchmarks/buggy.txt   # IPB
# 同理: db dfs pct random
```

**不要**指望在 kernel ≥ 6 的宿主上用 `docker run ubuntu:14.04` 跑 PIN——容器共享宿主内核。

## Windows

WSL2 可做 PERIOD 自身 + clone/stub。六基线实测请另开 Linux 云主机/VM。
