> HISTORY: Absolute `/workspace/...` paths below (if any) were recorded on the **author machine** during packaging; on your machine use `$PACK_ROOT` / relative paths only. Scripts in this pack never hardcode those paths.

# SCTBench / Maple 旧内核运行方案（本 box 探测 2026-11-02 Asia/Shanghai）

目标：跑通 SCTBench 六基线（IPB/`pb`、IDB/`db`、DFS、PCT、Random）与 Maple。它们依赖仓库自带的 **Intel PIN 2.12**（`sctbench/pin`）以及旧工具链（python2、g++/make、protobuf 等）。

**约束（本次遵守）**：未启动/改动 PERIOD docker；未 kill Chess / PERIOD 相关进程；未下载多 GB 镜像（仅文档化配方）。

---

## 0. 本机实测事实

| 项 | 结果 |
|----|------|
| 内核 | `uname -r` → **`6.12.94+`**（Debian 13 trixie） |
| 已是虚拟机 | `/proc/cpuinfo` 含 `hypervisor`；同时有 **`/dev/kvm` + VMX**（可嵌套虚拟化） |
| 内存/盘 | ~15 Gi RAM（探测时可用约 5 Gi，PERIOD/Chess 已占大量内存）；author disk free space (HISTORY)|
| `sctbench/pin/pin` | 32-bit launcher，interpreter=`/lib/ld-linux.so.2` **不存在** → `cannot execute: required file not found` |
| `pin/pin.sh -version` | 到达 pinbin 后报 **`E:6.12 is not a supported linux release`** |
| `-injection child/parent` | `-version` 可通过版本门；**真正注入** `/bin/true` / `/bin/echo` 崩溃：`unexpected AUX VEC type 51`（`auxvector.cpp:CopyAux`） |
| 工具链 | 无 `python2` / `g++` / `make`；仅有 Python 3.13 |
| 虚拟化包（探测前） | **未安装**：`qemu-system-x86_64`、`virt-manager`、`firecracker`、`lima`、`multipass` 均不在 PATH |
| apt 现状 | 默认 `https://deb.debian.org` 经代理 `198.18.0.1` **SSL EOF**；已临时改成 **`https://ftp.debian.org/debian` + `https://security.debian.org/debian-security`** 后 `apt-get update` 成功。备份：`/etc/apt/sources.list.d/debian.sources.bak.period2` |
| Docker | 系统 `/var/run/docker.sock` 不可用；PERIOD 自带 dockerd 在跑（`unix://<author-machine docker.sock — use system docker.sock>`，容器 `period:latest`）。**勿占用该 daemon 跑 SCTBench PIN** |
| 上游要求 | `sctbench/Dockerfile` / README：**kernel ≤ 3.x（因 PIN）**；Vagrant box=`hashicorp/precise64`（Ubuntu 12.04）；Docker base=`ubuntu:14.04`（用户态旧，但共享宿主内核 → 对本机无效） |

结论：**本宿主内核 6.12 上 PIN 2.12 不可用**（版本门 + AUX VEC）；缺旧工具链；**共享内核的容器/DinD 不能解决问题**。

---

## 1. 方案排序（推荐度 ↓）

### 方案 A（首选）：外部云 VM / 独立物理机 — Ubuntu 14.04（kernel ~3.13）或 16.04（4.4 + `-injection child`）

| | |
|--|--|
| **为何首选** | 真正独立旧内核；不抢本 box 上 PERIOD/Chess 的内存与 CPU；避免嵌套 virt 坑 |
| **估时** | 开通 + 装依赖 + 同步仓库：**1–3 小时**（首次）；其后跑基线视 scale 数小时～数天 |
| **磁盘** | 云盘 20–40 Gi 足够；不必在本 box 下大镜像 |
| **风险** | 14.04/16.04 已 EOL，需关公网或限制入站；16.04 上 PIN 2.12 通常需 `-injection child`（SCTBench 脚本可能要补丁） |

**云端骨架（AWS 示例；GCP/Azure 同理选旧 Ubuntu 镜像）：**

```bash
# 1) 开一台 x86_64 Ubuntu 14.04 或 16.04（≥4 vCPU / ≥8 GiB RAM / ≥30 GiB disk）
# 2) SSH 进入后：
sudo apt-get update
sudo apt-get install -y libprotobuf-dev protobuf-compiler python-protobuf \
  build-essential ipython m4 cmake python2.7   # 14.04 上 python-protobuf 即 py2

# 3) 同步本仓库（rsync/scp/git）：
#    $PACK_ROOT/third_party/sctbench  →  VM 上 ~/sctbench
cd ~/sctbench
cp -n env.template env.sh && source env.sh
build_maple
build_benchmarks
run_many.py --mode race --max 10 benchmarks/buggy.txt
run_many.py --mode pb --limit 10000 --timelimit 300 benchmarks/buggy.txt   # IPB
# ... db / dfs / pct / random 同 HOW_TO_RUN_BASELINES.md
```

若只能拿到 **16.04（4.4）**：先 smoke：

```bash
$PIN_HOME/pin.sh -injection child -- /bin/echo ok
# 若成功，再考虑给 maple/sctbench 启动 PIN 的地方统一加 -injection child
```

官方旧 Vagrant 目标是 **Precise 12.04**；Google Sites 上的 VirtualBox artifact 链接多半已失效，优先用 git 仓库 + 旧云镜像。

---

### 方案 B（本 box 可行次选）：嵌套 QEMU/KVM + Ubuntu 14.04 cloudimg（~253 MiB）

| | |
|--|--|
| **条件** | `/dev/kvm` 已存在；磁盘充足；**需先装 qemu**（见下）；内存紧张时 guest 建议 **2–4 Gi**（勿照搬 Vagrant 的 7 Gi） |
| **估时** | 装 qemu ~10–20 min；下镜像 ~5 min；cloud-init + 构建 **1–2 小时** |
| **镜像尺寸** | Trusty qcow2 **~253 MiB**（`Content-Length: 264897024`）；Xenial **~301 MiB**；均 **≪ 5 GiB**，可接受 |
| **风险** | 嵌套 KVM 性能/稳定性；与 PERIOD 抢内存；cloud-init 用户配置需一次写对 |

**本机已确认可 apt 安装（需沿用可用镜像源）：**

```bash
# 若 deb.debian.org 再次 SSL 失败，保持：
#   URIs: https://ftp.debian.org/debian
#   security: https://security.debian.org/debian-security
sudo apt-get update
sudo apt-get install -y --no-install-recommends \
  qemu-system-x86 qemu-utils cloud-image-utils genisoimage

# 下载 Ubuntu 14.04 cloudimg（~253MB，未在本次自动下载）
mkdir -p $PACK_ROOT/vms && cd $PACK_ROOT/vms
wget -c https://cloud-images.ubuntu.com/releases/trusty/release/ubuntu-14.04-server-cloudimg-amd64-disk1.img
qemu-img create -f qcow2 -b ubuntu-14.04-server-cloudimg-amd64-disk1.img -F qcow2 sctbench-trusty.qcow2 40G

# cloud-init：用户 ubuntu / 注入 SSH key（按需改）
cat > user-data <<'UD'
#cloud-config
users:
  - name: sct
    sudo: ALL=(ALL) NOPASSWD:ALL
    shell: /bin/bash
    ssh_authorized_keys:
      - ssh-ed25519 AAAA...REPLACE_ME...
package_update: true
packages: [build-essential, cmake, m4, libprotobuf-dev, protobuf-compiler, python-protobuf, ipython]
UD
echo 'instance-id: sctbench-1' > meta-data
echo 'local-hostname: sctbench-trusty' >> meta-data
cloud-localds seed.iso user-data meta-data

# 启动（后台；勿与 PERIOD 高峰抢满内存）
qemu-system-x86_64 -enable-kvm -m 3072 -smp 2 \
  -drive file=sctbench-trusty.qcow2,if=virtio \
  -cdrom seed.iso -netdev user,id=n0,hostfwd=tcp::2222-:22 \
  -device virtio-net-pci,netdev=n0 -nographic -serial mon:stdio
# 另开终端: ssh -p 2222 sct@127.0.0.1
# 然后 rsync sctbench 进 guest，按方案 A 构建
```

**未装包**：`firecracker` / `lima` / `multipass` 在 Debian 13 apt **无候选**；`virt-manager` 有包但偏 GUI，headless 用纯 qemu 即可。`qemu-kvm` 元包无候选（装 `qemu-system-x86` 即可）。

---

### 方案 C：本机硬刚 PIN（`-injection` / 装 i386 ld）— **不可行（已证伪）**

| 尝试 | 结果 |
|------|------|
| 装 `/lib/ld-linux.so.2` | 仅解决 32-bit `pin` 启动器；真正逻辑在 `intel64/bin/pinbin` |
| `-injection child` | 绕过 `E:6.12 is not a supported linux release`，但注入时 **AUX VEC type 51** 断言失败 |
| 缺 python2 / g++ / make / apt 旧包 | 即使 PIN 能跑也无法按上游构建 Maple |

**不要**再在 6.12 宿主上投入调试 PIN。

---

### 方案 D：Docker / Docker-in-Docker / `ubuntu:14.04` 容器 — **无效**

PIN 依赖**宿主内核** ABI（ptrace、auxv、系统调用）。`sctbench/Dockerfile` 虽写 `FROM ubuntu:14.04`，注释已写明需要 kernel ≤ 3.x；在 6.12 上跑该容器仍会触发同样 PIN 失败。DinD 也共享同一内核。  
另：请勿挪用 `PERIOD_repro` 的 dockerd（正在跑 Chess / RQ 任务）。

---

### 方案 E：qemu-user / binfmt 用户态模拟 — **无效**

`qemu-user-static` 只翻译指令，**不提供旧内核**；PIN 作为动态插桩/注入工具无法在 user-mode qemu 里可靠工作。需要的是 **方案 B 的系统级 qemu-system + 旧 guest 内核**。

---

### 方案 F：官方 VirtualBox artifact / Vagrant precise64

| | |
|--|--|
| Vagrantfile | `hashicorp/precise64` + `vagrant_provision.sh`（与云端依赖一致） |
| VirtualBox 旧 artifact | sites.google.com/sctbenchmarks 称可下载；链接多数失效，**不作为依赖** |
| 估时 | 若本机有 VirtualBox/Vagrant：**2–4 小时**；本 box **无** vagrant/virt-manager 现成环境 |

---

## 2. 给 parent 的推荐下一步（单一路径）

**优先走方案 A（外部 Ubuntu 14.04/16.04 VM）**，与正在跑的 PERIOD/Chess 隔离。若必须留在本 box：先执行方案 B 的 **apt 安装 qemu**（约几十到一百多 MB 包，非多 GB），**确认 PERIOD 内存空闲 ≥4 Gi 后再**下载 Trusty cloudimg（~253 MiB）并起嵌套 VM；不要下载桌面 ISO / 完整 VirtualBox 大包。

最小可执行命令（仅装 hypervisor，不下 OS 镜像）：

```bash
sudo apt-get update
sudo apt-get install -y --no-install-recommends \
  qemu-system-x86 qemu-utils cloud-image-utils genisoimage
which qemu-system-x86_64
ls -l /dev/kvm
```

装好后由 parent 再决定是否拉 Trusty 镜像并启动（配方见方案 B）。同步跑基线时继续用 `$PACK_ROOT/notes/HOW_TO_RUN_BASELINES.md`。

---

## 3. 相关路径

- 本笔记：`$PACK_ROOT/notes/BASELINE_OLD_KERNEL_OPTIONS.md`
- PIN 树：`$PACK_ROOT/third_party/sctbench/pin`（Pin 2.12 kit 58423）
- 上游说明：`sctbench/README.md`、`Dockerfile`、`Vagrantfile`
- 基线跑法：`notes/HOW_TO_RUN_BASELINES.md`
- 构建失败记录：`notes/SCTBENCH_BUILD_ATTEMPT.md`、`notes/MAPLE_BUILD.md`

