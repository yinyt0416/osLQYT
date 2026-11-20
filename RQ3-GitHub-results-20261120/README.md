# RQ3 实验结果（2026-11-20）

本目录用于提交到 yinyt0416/osLQYT，由 Liyuchen-1240016951 上传。它记录一次本机限时实验，不宣称严格复现论文 Figure 7。

## 本次交付范围

主要结果为 9 个程序，每个程序 PERIOD、IPB、IDB 各安排 10 轮，两个后端各测 10 轮 native。共 450 个配置轮次：400 个正常结束、50 个达到 300 秒上限。
doubleFree、CB_stringbuffer 暂缓，由队友排查。它们已有的两后端 native 和 PERIOD 结果保留在总表和 deferred 表中，IPB/IDB 合计 40 个未执行位置不可视作失败检测次数为零。

## 主要程序状态

|程序|PERIOD 成功/10|IPB 成功/10|IDB 成功/10|
|---|---:|---:|---:|
|CS_account|10|10|10|
|CS_lazy01|10|10|10|
|CS_twostage|10|10|10|
|CS_reorder_3|10|0|10|
|CS_circular_buffer|10|10|10|
|CS_reorder_4|10|0|10|
|CS_token_ring|10|0|10|
|CS_bluetooth_driver|10|10|10|
|CS_wronglock_3|10|0|0|

## 文件

- `data/rq3_primary_9.csv`：其余9程序450条正式记录。
- `data/rq3_overhead.csv`：全部11程序550条位置，包含暂缓和超时状态。
- `data/rq3_summary.csv`：仅 OK 轮次的均值、样本标准差与有效样本数。
- `data/rq3_timeouts.csv`：50条超时记录，保留截断前的调用数与错误数。
- `figures/`：3张图，每张提供 PNG 和 PDF。先看 completion 图再解释 overhead 图。
- `raw/`：按后端、程序分开的原始日志压缩包，含逐次调用JSONL和结果JSON。
- `sources/`：本次同源程序与许可证，文件哈希在 `data/source_hashes.csv`。
- `scripts/`：测量脚本存档，需要原环境路径和依赖，不能直接在任意电脑运行。
- `deferred/`：暂缓程序数据与Pin/ASan排查材料，供队友接续。
- `data/audit.json`：550条唯一位置、逐条计数和耗时均值、两后端源码哈希核查。

## 测量口径

`tool_s` 是一轮搜索中已完成目标进程调用的平均延迟，包含进程启动、Pin/launcher 等成本。`native_s` 是相同后端、相同程序、相同重复轮次下20次native调用的平均延迟。`slowdown = tool_s / native_s`，对10个有效轮次再计算均值和样本标准差。不能用整轮搜索时间除以一次native时间。
`search_wall_s` 是整轮搜索墙钟时间。`schedules` 实际表示已完成目标调用次数，包含重试和各bound重复，不是唯一调度数。`errors` 是这些调用中被检测为目标程序错误的次数，不是不同缺陷数，也不能直接称为唯一错误交错数。
native 行的 schedules 留空。超时行保留部分调用的 tool_s、schedules、errors，但 slowdown 留空，并从完整搜索均值和主图中排除。没有有效数据留空，不填0。
PERIOD 搜索depth=3，预算10000，目标调用timeout=5秒。IPB/IDB bounds=0..3，各bound预算10000。整个配置轮次外部上限300秒；IPB/IDB的5秒字段未作为独立目标超时传给Maple。

## 环境与解释限制

PERIOD：Docker Ubuntu18.04，Clang/LLVM10，原仓库commit cb8deb9a176e5bb292d70d46557dd61dc0e98069。IPB/IDB：WSL中KVM/QEMU Ubuntu14.04.6，kernel3.13.0-170-generic，GCC4.8，Pin2.12 kit58423、Maple、Python2.7。虚拟机2vCPU、约3GB内存。两个后端使用同一批目标源码。正式测量串行进行。
两个后端内核、编译器与虚拟化方式不同，采用各自native归一化仍不能完全消除环境差异。这些数据支持本机环境下的描述性比较，不支持将差距全归因于算法。计时包含启动与插桩成本。部分轮次超时，完成样本均值可能存在选择偏差，需与有效n一起报告。
基线 runner 的退出码1本身不判为工具故障，按原日志判别；早期误分类已重新核对。原始tar内保留修订记录。raw日志收集采用时间窗口，可能附带邻近轮次日志；正式逐次统计以对应executions.jsonl、host_result.json为准，不能将压缩包中全部文本次数相加。
data/protocol.json 是运行时配置存档。deferred 的 preparation 可能生成race.db并显示READY，但短测试仍出现工具错误，不能据此认为兼容修复。

## 结果可以怎样写进报告

“在本机设定的300秒单轮上限内，对9个可运行程序分别进行10轮PERIOD/IPB/IDB测试；两后端分别测native作为归一化基准。报告完整轮次的平均调用开销，同时给出超时次数。doubleFree与CB_stringbuffer的两种基线因Pin/ASan冲突暂缺，后续补测。”

## 上传 GitHub

解压外层ZIP，打开仓库自己的分支，进入计划存放结果的目录（建议 `rq3/results/Liyuchen-1240016951/2026-11-20/`），选择 Add file → Upload files，拖入本目录内容后提交。保留raw内部的.tar.gz，不必解压。不要覆盖队友分支或旧结果。本次没有自动推送。
建议提交说明：`Add RQ3 results for 9 subjects with timeout records and figures`。如果网页不支持一次上传整个文件夹，可以分批上传 data、figures、raw、sources、scripts、deferred 和根目录文件。

## 重新画图

在解压后的目录安装 `scripts/requirements-plot.txt` 中的Python依赖，再执行 `python scripts/plot_results.py`。脚本从汇总CSV重画三张图，不需要重跑实验。
