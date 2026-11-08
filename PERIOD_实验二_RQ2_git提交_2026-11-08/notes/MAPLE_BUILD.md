> HISTORY: Absolute `/workspace/...` paths below (if any) were recorded on the **author machine** during packaging; on your machine use `$PACK_ROOT` / relative paths only. Scripts in this pack never hardcode those paths.

# Maple 构建要点（独立 clone）

路径：`$PACK_ROOT/third_party/maple`（浅克隆 https://github.com/jieyu/maple）  
sctbench 内嵌副本：`$PACK_ROOT/third_party/sctbench/maple`（与官方同源风格，供 `build_maple` 使用）

## 依赖

- GNU make ≥ 3.81、Python（上游写 2.4+；实际脚本偏 py2）
- Intel PIN（`PIN_HOME`；sctbench 已带 `sctbench/pin`）
- Google protobuf（`PROTOBUF_HOME`，推荐 2.4.1）
- Linux x86_64；上游测试过 Ubuntu 10.10–12.04 / RHEL 5.4
- `/etc/security/limits.conf` 中 rtprio/nice（见 maple README）

## 命令

```bash
export PIN_HOME=$PACK_ROOT/third_party/sctbench/pin
export PROTOBUF_HOME=/usr
cd $PACK_ROOT/third_party/maple
make compiletype=release
```

## 本 box 结论（2026-11-02）

未完成构建：缺 make/g++/cmake/protobuf（apt SSL 失败）、无 python2、PIN 二进制在 kernel 6.12 上不可执行。建议旧内核 VM。不要在 PERIOD_repro dockerd 上硬刚 Maple。
