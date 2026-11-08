# 如何运行 SCTBench 六基线（IPB / IDB / DFS / PCT / Random + Maple）

来源仓库（clone 后）：`$PACK_ROOT/third_party/sctbench`（https://github.com/mc-imperial/sctbench）  
独立 Maple：`$PACK_ROOT/third_party/maple`（https://github.com/jieyu/maple；sctbench 内也嵌了 `sctbench/maple`）

先执行：`bash run_queue.sh clone`

## 论文名 ↔ sctbench `--mode`

| 论文（RQ2） | sctbench mode | 说明 |
|------------|---------------|------|
| IPB | `pb` | Preemption Bounding（CHESS 风格） |
| IDB | `db` | Delay Bounding |
| DFS | `dfs` | Depth-first systematic |
| PCT | `pct` | Probabilistic Concurrency Testing |
| Random | `random` | 随机调度 |
| Maple | （独立工具） | 基于 Intel PIN；不走 `run_many.py --mode` |

## 构建（上游 README）

```bash
cd "$PACK_ROOT/third_party/sctbench"
# 依赖见 vagrant_provision.sh: libprotobuf-dev protobuf-compiler python-protobuf build-essential ipython m4 cmake
# 另需可用的 Intel PIN（仓库已带 pin/）；上游称 kernel <= 3.x
cp -n env.template env.sh
source env.sh            # ROOT / MAPLE_HOME / PIN_HOME / PATH
build_maple              # = cd maple && make compiletype=release
build_benchmarks         # chess / CS / inspect / splash2 / safestack / ...
```

## 跑法

```bash
source "$PACK_ROOT/third_party/sctbench/env.sh"
run_many.py --mode race --max 10 benchmarks/buggy.txt
run_many.py --mode pb     --limit 10000 --timelimit 300 benchmarks/buggy.txt   # IPB
run_many.py --mode db     --limit 10000 --timelimit 300 benchmarks/buggy.txt   # IDB
run_many.py --mode dfs    --limit 10000 --timelimit 300 benchmarks/buggy.txt
run_many.py --mode pct    --limit 10000 --timelimit 300 benchmarks/buggy.txt
run_many.py --mode random --limit 10000 --timelimit 300 benchmarks/buggy.txt
```

日志落在 `benchmarks/__results/<timestamp>/...`。制表用 `scripts/tabulate2.py`。

## Maple

```bash
export PIN_HOME="$PACK_ROOT/third_party/sctbench/pin"
export PROTOBUF_HOME=/usr
cd "$PACK_ROOT/third_party/maple"   # 或 sctbench/maple
make compiletype=release
```

## 阻塞说明（事实）

- 现代 kernel（≥6.x）上 Intel PIN 2.12 通常不可用；需 Ubuntu 14.04/16.04 类旧内核 VM。
- **不要**用共享宿主内核的 `docker run ubuntu:14.04` 指望跑通 PIN。
- 详见 `BASELINE_OLD_KERNEL_OPTIONS.md`。

> HISTORY: 早期草稿曾写作者机绝对路径；本文件已改为 `$PACK_ROOT/...`。
