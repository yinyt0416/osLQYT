# Chess InterlockedWorkStealQueueWithState — 状态证据（2026-11-07）

时区：Asia/Shanghai (CST, UTC+8)  
记录时刻：约 2026-11-07 18:28

> HISTORY: Absolute `/workspace/...` paths below refer to the **author machine** tree; this pack ships only the POINTER + this note. Do **not** commit the ~142 MiB full log.

## 日志文件

- 作者机路径（未打进 zip）：`<author PERIOD results>/logs/Chess_InterlockedWorkStealQueueWithState.log`
- 大小：148 134 240 字节（约 **142 MiB**）
- mtime：`2026-11-07 18:17:14 Asia/Shanghai`（之后无再增长）
- 本包：见同目录 `Chess_InterlockedWorkStealQueueWithState.log.POINTER.txt`

## 进度

- 最后一条可见测试：**test 331200**
- 前序连续：`test 331198` → `331199` → `331200`
- 日志在 `test 331200` 处截断，**无**出现 run 完成 / finish / total-summary 类收尾行
- 容器侧：此前已确认跑程停止；本笔记只做文件证据，**未**重启容器

## Bug / Error 摘要

- 构建阶段有 clang 弃用/`int→void*` 警告，未阻断运行
- 运行配置：`bugDepth: 3`；按 depth 1/2/3 迭代
- `[Error Found]` 累计 **294** 条（末几条示例：NO.290–292 Exception、NO.293 assertion failed、NO.294 Exception）
- 错误产物路径形如：`out_InterlockedWorkStealQueueWithState_1/Errors/...`
- 结论：跑过一半、已挖出大量 Exception/assertion；**非**干净 NO_BUG 完结，也**非**完整跑穿后的正式收口

## summary 核对

- `summary_full_final.tsv` 含 Chess_WSQ / Chess_ILWSQ（DONE）与 Chess_StateWSQ / Chess_ILWSQState（TIMEOUT 部分结果）
- **WithState 长跑**进度以本 POINTER + 本笔记为准；完整 log 不随包分发

## 续跑建议（仅建议，本包未启动）

- 在 RQ1/RQ3 扩科空档再续跑；从现有 log 可见进度约 **test 331200**
- 今晚交付以断点进度 + Error Found 294 作为「进行中/截断」证据即可
