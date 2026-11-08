> HISTORY: Absolute `/workspace/...` paths below (if any) were recorded on the **author machine** during packaging; on your machine use `$PACK_ROOT` / relative paths only. Scripts in this pack never hardcode those paths.

# sctbench 本机非破坏构建尝试（2026-11-02 CST）

尝试：安装 build-essential/cmake/m4/protobuf → apt InRelease SSL EOF，无候选包。  
探测：有 `gcc`/`cc`，无 `g++`/`make`；便携 cmake 在 `<local cmake> 但未接入。  
PIN：`$PACK_ROOT/third_party/sctbench/pin/pin` → `cannot execute: required file not found`（与 kernel 6.12 / 动态链接器不匹配）。  
结论：不在本 box 强行编译；文档化命令留给旧环境。未改系统关键配置，未动 PERIOD docker。
