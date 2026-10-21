# 《储能优化规划与运行课程设计》 — 教学资源库 (`ESS-Course-Materials`)

本仓库为南京工程学院《储能优化规划与运行课程设计》的**只读教学资源库**（仓库 A），存放课程教学课件、修复并校准后的标准配电网算例、24 小时源荷与江苏省分时电价数据、课堂随堂演示实时脚本（`.mlx`）以及供学生复制使用的作业空白模板。

* **教学资源库（本仓库，只读免 Fork）**：`https://github.com/wuhan-njit/ESS-Course-Materials`
* **学生作业提交库（需 Fork 并提交 Pull Request）**：`https://github.com/wuhan-njit/ESS-Course-Submissions`

> **当前课堂与作业入口**：课堂使用 `interactive/` 下新建的四份交互教学 MLX，学生课后作业使用 `templates/` 下的两份模板。任务三统一为含充放电互斥的 MISOCP，调用 MOSEK 或 Gurobi，并保留目标 C 的松弛不精确教学特例；任务二和任务四默认调用 MATLAB 原生求解器（`intlinprog`/`linprog`）。详见 `interactive/README.md`。

**课程介绍课件**：[12 页 PDF](slides/Lesson01_CourseIntroduction/01_课程介绍.pdf) / [HTML 演示](slides/Lesson01_CourseIntroduction/index.html)。

**完整课件入口**：[五份课件](slides/index.html) / [全部课件 PDF（70 页）](slides/01-05_全部课件.pdf)。后续四份依次为潮流计算8页、单节点套利12页、网络调度18页、选址定容20页。教师讲稿在项目根目录“教师讲稿”中独立保存。

---

## 一、 仓库目录结构

```text
ESS-Course-Materials/                 <-- 仓库 A：只读教学资源库
├── README.md                         # 课程大纲、软件安装指南(Matpower 8.1/Yalmip/Gurobi)、学号映射规则表
├── interactive/                      # 当前课堂的四份交互教学 MLX、源码与公共函数
├── slides/                           # 存放 01~05 教学课件 PDF
├── cases/                            # 标准配电网算例与典型日数据
│   ├── case_nongcun.m                # 尾号 0-3：49节点农村电网（已修复关口边界）
│   ├── case_chengshi_A.m             # 尾号 4-6：23节点城市电网（已校准馈线阻抗与关口边界）
│   ├── case_kaifaqu_A.m              # 尾号 7-9：18节点工业园区（已修复节点11无功笔误与关口边界）
│   └── profiles_24h.mat              # 24h负荷、光伏标幺值曲线及江苏省分时电价向量
├── demos/                            # 课堂随堂演示实时脚本
│   ├── Demo01_Matpower_PF.mlx        # MATPOWER 结构体与 24h 时序基准潮流演示
│   └── Demo02_Yalmip_Basic.mlx       # YALMIP 语法与单节点储能套利演示 (对应 Yalmip_test.mlx)
└── templates/                        # 供学生复制使用的作业空白模板
    ├── Template_Week1_Dispatch.mlx   # 第一周模板：固定容量下的储能 SOCP 优化调度
    └── Template_Week2_Planning.mlx   # 第二周模板：含 Big-M 线性化与 LinDistFlow 的选址定容 + AC 校验
```

---

## 二、 软件环境与快速开始

1. **下载本教学资源库**：
   无需 Fork 本仓库。直接点击页面右上角 `Code -> Download ZIP` 解压到本地**无中文字符**的路径下，或使用 Git 克隆：
   ```bash
   git clone https://github.com/wuhan-njit/ESS-Course-Materials.git
   ```
   当教师在课程中途更新课件或模板时，只需执行 `git pull` 即可同步。
2. **软件环境要求**：
   * **MATLAB**：推荐 R2024a – R2026a，需包含内置的 **Optimization Toolbox**（LP/MILP/SOCP 默认使用内置求解器 `linprog/intlinprog/coneprog`；任务三 MISOCP 使用 MOSEK 或 Gurobi。若使用 CVX 随附的 MOSEK，**请勿运行 `cvx_setup` 或添加 `cvx` 根目录**，仅需将 `cvx/mosek` 子文件夹通过 `addpath(genpath('.../cvx/mosek'))` 加入路径并用 `which mosekopt` 验证）。
   * **MATPOWER 8.1**：解压至无中文字符目录，在 MATLAB 命令行运行 `install_matpower` 并保存路径。
   * **YALMIP**：解压至无中文字符目录，通过 MATLAB `设置路径 (Set Path) -> 添加并包含子文件夹 (Add with Subfolders)` 添加并保存。
3. **打开新交互教学文件**：在 MATLAB 中将当前文件夹切换到 `interactive/`，打开对应 MLX 并点击“全部运行”。文件通过 `ess_live_setup.m` 添加课程算例路径；任务三另检查 MISOCP 求解器。

---

## 三、 个人学号参数映射规则（一人一题）

设学生学号最后两位数字为 $\text{XY}$，其中十位数字为 $X \in \{0, 1, \dots, 9\}$，个位数字为 $Y \in \{0, 1, \dots, 9\}$（例如学号 `242400038`，则 $X = 3, Y = 8, \text{XY} = 38$）：

| 分配维度 | 学号特征 | 分配结果与对应参数 | 说明 |
| :--- | :--- | :--- | :--- |
| **1. 个人负荷缩放系数** | 学号后两位 $\text{XY}$ | $\alpha = 1 + 0.002 \times (10X + Y)$ | 全网有功与无功基准负荷均乘以 $\alpha$，实现一人一题。 |
| **2. 配电网算例分配** | 个位数字 $Y \in \{0, 1, 2, 3\}$ | **农村配电网** `case_nongcun.m`（49 节点，12.66 kV / 100 MVA） | 供电半径长，电压跌落显著。 |
| | 个位数字 $Y \in \{4, 5, 6\}$ | **城市配电网** `case_chengshi_A.m`（23 节点，12.66 kV / 100 MVA） | 商居混合负荷，重负荷支路压降明显。 |
| | 个位数字 $Y \in \{7, 8, 9\}$ | **工业园区配网** `case_kaifaqu_A.m`（18 节点，12.66 kV / 100 MVA） | 工业大负荷集中，已修正节点 11 无功参数。 |
| **3. 第一周调度目标与第二周候选节点** | 十位数字 $X \in \{0, 1, 2\}$ | **模型 A**：最大化新能源消纳；接入/候选节点 $\Omega_{\text{cand}} = \{4, 9, 14\}$ | 含网损惩罚项（权重 $\rho = 10^{-2}$）保证二阶锥松弛紧致。 |
| | 十位数字 $X \in \{3, 4, 5\}$ | **模型 B**：最小化全网有功网损；接入/候选节点 $\Omega_{\text{cand}} = \{5, 11, 16\}$ | 直接最小化支路有功损耗之和。 |
| | 十位数字 $X \in \{6, 7, 8, 9\}$ | **模型 C**：最小化关口购电成本；接入/候选节点 $\Omega_{\text{cand}} = \{6, 13, 17\}$ | 结合江苏省工商业分时电价降本。 |

### 各阶段任务的场景参数设置对比表

| 阶段任务 | 对应脚本 / 模板 | 基准容量 $S_{\text{base}}$ | 分布式光伏配置（节点集 $\Omega_{\text{cand}}$） | 储能配置与 $\text{SoC}$ 运行区间 |
| :--- | :--- | :---: | :--- | :--- |
| **任务一**：24h 基态潮流诊断 | `Demo01_Matpower_PF.mlx` | $100\text{ MVA}$ | 3 个节点各接入 **$0.8\text{ MW}$** 固定出力光伏 | 无储能（基态对照） |
| **任务二**：单节点分时电价套利 | `Demo02_Yalmip_Basic.mlx` | —（有名值） | 无（独立储能电站） | 单节点固定 **$2.0\text{ MW} / 2.0\text{ MWh}$**，$\text{SoC} \in [0.10, 1.00]$ |
| **任务三**：含互斥约束的配电网日前 MISOCP 调度 | `interactive/Interactive03_NetworkDispatch.mlx` | $100\text{ MVA}$ | 3 个节点光伏提升至 **$1.2\text{ MW}$/节点**（可弃光） | 3 个节点各固定 **$1.5\text{ MW} / 3.0\text{ MWh}$**，$\text{SoC} \in [0.20, 0.80]$ |
| **任务四**：配电网选址定容与 AC 校验 | `Template_Week2_Planning.mlx` | $100\text{ MVA}$ | **不设置光伏注入（$0\text{ MW}$，纯负荷馈线）** | 3 个候选节点从 $1\sim 5\text{ MW/MWh}$ 离散档位选址定容，$\text{SoC} \in [0.20, 0.80]$ |

---

## 四、 江苏省工商业分时电价表（内置于 `profiles_24h.mat`）

| 时段类型 | 覆盖小时（第 $t$ 小时对应 $(t-1):00 \sim t:00$） | 电价（元/kWh） | 电价（元/MWh） |
| :--- | :--- | :--- | :--- |
| **低谷时段 (Valley)** | $t \in \{1, 2, 3, 4, 5, 6, 7, 8\}$（00:00–08:00） | `0.3180` | `318.0` |
| **平时段 (Flat)** | $t \in \{9, 10, 11, 12, 13, 14, 18, 23, 24\}$（08:00–14:00, 17:00–18:00, 22:00–24:00） | `0.6715` | `671.5` |
| **高峰时段 (Peak)** | $t \in \{15, 16, 17, 19, 20, 21, 22\}$（14:00–17:00, 18:00–22:00） | `1.1248` | `1124.8` |

---

## 五、 两周课程设计进度概览

* **第一周（配电网时序潮流诊断与日前 SOCP 优化调度）**：
  * **周一**：学习 MATPOWER 结构体与标幺值归算，基于 `Demo01_Matpower_PF.mlx` 完成 24 小时基态时序潮流与薄弱节点诊断。
  * **周二**：学习 YALMIP 基础语法，基于 `Demo02_Yalmip_Basic.mlx` 完成单节点 $2\text{ MW}/2\text{ MWh}$ 储能分时电价日前套利。
  * **周三 ~ 周五**：学习 DistFlow 二阶锥松弛（SOCP）理论，基于 `interactive/Interactive03_NetworkDispatch.mlx` 完成含互斥约束的配电网日前调度，并分析目标 C 的松弛不精确特例，并在周五 17:00 前向作业库 `ESS-Course-Submissions` 提交第一阶段 Pull Request。
* **第二周（储能选址定容 MILP 优化与交流潮流闭环验证）**：
  * **周一 ~ 周二**：学习等年值成本模型、双线性项 $\text{SoC}_{i,t} \cdot E_i^{\text{rated}}$ 的离散档位选择（$w_{i,k}$）与四条紧致 Big-M 线性化不等式（$\delta_{i,k,t}$），基于 `Template_Week2_Planning.mlx` 完成 LinDistFlow 选址定容求解。
  * **周三**：将 MILP 最优充放电功率代回 MATPOWER `runpf` 进行 24 小时精确交流潮流事后验证，对比 $\sqrt{U_{i,t}^{\text{Lin}}}$ 与 $V_{i,t}^{\text{AC}}$ 的电压偏差、核算真实年化降损收益 $B_{\text{loss}}$，并导出 `result_summary.mat`。
  * **周四 ~ 周五**：完成课程设计报告（`.pdf`），集齐个人文件夹下的最终交付物更新 Pull Request 并参加现场答辩。
