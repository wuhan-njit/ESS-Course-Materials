# 储能课程交互教学实时脚本

本目录为新增的课堂教学文件。原有 `demos/`、`templates/` 和作业示例继续保留。

## 使用顺序

在 MATLAB 中将当前文件夹切换到本目录，再打开相应 MLX，首次点击“全部运行”。本目录可随教学资源库一起复制。

| 文件 | 主要内容 | 交互操作 |
| --- | --- | --- |
| `Interactive01_TimeSeriesPF.mlx` | 24 小时时序交流潮流、节点电压、全天电能损耗 | 修改负荷倍率；选择时段和节点 |
| `Interactive02_StorageArbitrage.mlx` | 单节点储能套利、SoC 动态、LP/MILP 比较 | 调整功率、能量容量和效率；选择时段 |
| `Interactive03_NetworkDispatch.mlx` | 支路潮流、充放电互斥、MISOCP 与三种调度目标 | 选择目标；查看支路松弛间隙和关联矩阵 |
| `Interactive04_StoragePlanning.mlx` | 大M法、选址定容、交流潮流验证 | 改变配置选择变量和 SoC；调整投资费用、电压下限；选择节点 |

## 课堂操作

- 文字说明和数学公式位于富文本块，模型实现位于代码块，输出与所在节相邻。
- 修改计算参数后，重新运行该参数及后续模型。若同时修改多个条件，使用“全部运行”。
- 时段、节点、支路及大M法示例滑块设置为只运行当前节，用于即时更新图表。
- 讲解物理含义时可在 Live Editor 中选择“隐藏代码”；讲解实现时切换到代码与输出并排显示。
- 目标比较必须使用相同算例和设备参数。调度历史表仅供课堂比较，每次完整试验前可在 MATLAB 中执行 `clear Dispatch_History`。
- 第三份文件对 A/B/C 均施加充放电互斥约束，完整模型为 MISOCP。目标 C 保留为二阶锥松弛不精确的教学特例：继续显示计算结果、松弛间隙和交流电压对比，分别记录储能约束与交流运行检查结果。

## 求解器

LP/MILP/SOCP 默认使用 MATLAB 原生 `linprog/intlinprog/coneprog`。任务三为 MISOCP，使用 MOSEK 或 Gurobi；MOSEK 可来自独立安装或 CVX 随附目录（若使用 CVX 随附的 MOSEK，请仅通过 `addpath(genpath('.../cvx/mosek'))` 添加 `cvx/mosek` 子目录，切勿运行 `cvx_setup` 或添加 `cvx` 根目录），YALMIP 负责建模。`ess_live_solve.m` 记录实际求解器，使用内置函数时核对 MathWorks 路径。

若旧版 YALMIP 调用 `linprog` 时出现“不接受 X0”或“does not accept X0”，`ess_live_solve.m` 会使用 `ess_live_linprog.m` 导出同一个线性规划，以不含 X0 的语法调用原生 `linprog`，并将解写回 YALMIP 变量。更新文件时应同时复制这两个函数。也可按 [YALMIP 官方问题记录](https://github.com/yalmip/YALMIP/issues/1381) 更新 YALMIP，并用 `which calllinprog -all` 检查当前加载的接口位置。

若任务三出现 `Gurobi error 10008: Unable to set parameter TuneTimeLimit to value -1`，请更新本目录的 `ess_live_solve.m`，执行 `clear ess_live_solve` 后重新运行。该函数显式设置 `ops.gurobi.TuneTimeLimit=0`，兼容旧版 YALMIP 与新版 Gurobi。也可更新 YALMIP，参见 [YALMIP 官方讨论](https://github.com/yalmip/YALMIP/discussions/1506)。

MISOCP 调用启用 YALMIP 的 `debug` 并逐个捕获异常，MOSEK 失败后仍会尝试 Gurobi；若全部失败，报错包含原始异常或求解器返回信息。MOSEK 的 `Unknown error` 需要结合这些信息定位。可先运行 `which mosekopt -all`、`which callmosek -all`、`which sdpsettings -all` 检查加载位置，再运行 `mosekdiag` 检查 MOSEK 安装与许可证，并保留完整输出。

2026-10-27 复核：默认学号 242400000 的目标 C 在 MOSEK 11.2 上达到 120 秒上限时尚未找到整数可行解（返回码 100001，整数问题及解状态均为 UNKNOWN），YALMIP 将其汇总为 `Unknown error`。同一模型使用 Gurobi 13.0.2 约 3.4 秒求解成功，购电费用为 28414.17 元。课程此前保存的目标 C 结果也使用 Gurobi。目标 C 当前可通过上述 Gurobi 参数兼容性修复及自动切换运行；该次 MOSEK 终止不能解释为模型不可行。目标 C 的二阶锥松弛精确性与交流电压检查仍按原有教学特例处理。

随后仅将 MOSEK 时间上限提高至 600 秒，其余求解容差保持不变，同一目标 C 在约 153.6 秒返回 `INTEGER_OPTIMAL`，相对最优性间隙约为 `8.11e-9`，购电费用为 28414.17 元，储能与线性约束检查通过。当前 `ess_live_solve.m` 已采用 MOSEK 600 秒上限；Gurobi 仍为 120 秒。教师更新时替换该函数，执行 `clear ess_live_solve` 后重新运行交互文件即可。

`templates/Template_Week1_Dispatch.mlx` 已同步上述求解参数、Gurobi `TuneTimeLimit=0` 兼容修复、原始错误输出及异常后切换求解器的处理。模板保留内嵌求解代码，可独立运行；MOSEK 上限为 600 秒，Gurobi 为 120 秒，gap、可行性及整数容差与 Interactive03 一致。

## 场景参数

网络算例基准容量为 100 MVA、基准电压为 12.66 kV。

- 任务一：每个指定节点光伏装机 0.8 MW，无储能。
- 任务二：默认储能 2 MW/2 MWh，SoC 范围 0.10～1.00。
- 任务三：每个指定节点光伏装机 1.2 MW，储能 1.5 MW/3 MWh，SoC 范围 0.20～0.80，模型 A 的网损权重为 0.01。
- 任务四：不设置光伏注入，五种成对功率/能量配置方案，SoC 范围 0.20～0.80，默认线性模型电压下限 0.96 p.u.。

## 保存位置

图形配色、线型和标记按项目根目录的 [04_课件与MLX绘图规范.md](../../04_课件与MLX绘图规范.md) 执行，统一由 `figure_style_registry.json` 和 `ess_live_style.m` 管理。电价、功率和荷电状态采用上下排列的独立坐标轴。任务三分别显示充电与放电功率；电压限值线默认不显示，折线线宽为 2 pt。

教学结果位于本目录的 `results/`，按任务、学号和目标函数区分。默认导出白底 PNG（600 dpi）、矢量 PDF 和 FIG。修改滑块查看曲线时不会自动导出；运行保存结果节时导出当前图形。

任务四将 `result_summary.mat` 写入 `results/Lesson04_学号/`。六个字段沿用课程约定，`Opt_Sites` 为候选节点集合中的序号，配置表另外显示实际节点编号。

## 文件维护

- `sources/`：与 MLX 对应的可编辑实时脚本文本源码，包含富文本与控件信息。
- `ess_live_*.m`：路径设置、图形、导出和 LP/MILP 比较函数。
- `_build/`：生成脚本、临时预览与运行检查记录。

本目录使用 MATLAB R2026a 生成。运行需要 MATPOWER、YALMIP 和相应求解器。原生控件、富文本和实时脚本在 MATLAB Live Editor 内使用。
