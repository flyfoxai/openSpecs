# OpenSpecs (Speckit Layered)

`sp` (OpenSpecs) 是一个基于 `Spec Kit` 改造出来的**分层文档工作流框架（Document-Stage Framework）**。

上游原始仓库：[github/spec-kit](https://github.com/github/spec-kit)

它的目标不是让大模型从“一句话需求”直接跳到“生成代码”，而是强制 AI 在写代码前，先把需求、业务流、界面、交付设计按固定步骤沉淀成可查询、可回链的“文档骨架”。
这能有效防止大模型在复杂项目中产生“架构崩塌”和“幻觉循环”。

> **注意：** 当前阶段框架主要覆盖“文档化阶段”，工作流到 `sp.analyze` 结束，暂不包含后续的自动化实现（`sp.implement`）。

---

## 🎯 核心机制：解决什么问题？

大模型辅助编程通常面临三大痛点：
1. **歧义陷阱**：需求和实现之间有大量路线、边界、数据决策未澄清，导致模型乱猜。
2. **记忆碎片**：大模型上下文有限，且没有长期记忆，容易重复推理、前后逻辑打架。
3. **上下文爆炸**：项目变大后（几十张表、几十个接口），全量读取代码会导致 Token 爆炸和注意力失焦。

**OpenSpecs 的解法：**

### 1. 两层推进流 (Two-Layer Document Workflow)
*   **Layer 1：业务与分析层**
    *   明确“做什么”、“为什么做”、“业务主线与边界”。
    *   包含：`sp.specify` -> `sp.clarify` -> `sp.flow` -> `sp.ui` -> `sp.gate` -> `sp.bundle`
*   **Layer 2：交付与设计层**
    *   明确“怎么落地”、“用例与数据表的对应”、“如何拆解任务”。
    *   包含：`sp.plan` -> `sp.tasks` -> `sp.analyze`

### 2. 统一澄清与传播闭环
*   **`sp.clarify`**：它是全流程唯一的澄清入口。模型必须通过单选题/多选题来提问，减少模糊回答。
*   **闭环强制同步**：一旦澄清结论发生改变，必须按照 `Required Sync Files` 同步更新所有关联的文档和记忆层，否则打上 Stale 标记。

### 3. Query-First 的记忆路由 (Context Memory)
打破“全量读取”习惯，建立严格的上下文索引：
*   **项目级路由**：`.specify/memory/*`
*   **Feature级路由**：`specs/<feature>/memory/*`
*   模型介入后，必须**先读索引 -> 找到当前 Feature -> 提取当前 Workset 的“最小读集”**，大幅度降低无用 Token 消耗。

### 4. 局部工作面 (Workset)
到了 `sp.plan` 阶段，将庞大的系统强行拆成多个局部的 `ws-*.md` (Workset)。模型每次干活只背负当前闭环区域的上下文（如：一个审批链路、一组高关联数据表）。

### 5. 步骤语义与平台触发解耦 (Agent Agnostic)
无论你用哪个 AI 平台，底层工程规范始终是 `sp.*`：
*   **Claude Code 等 (Slash Command)** 触发形式：`/sp.specify`
*   **Codex CLI (Skills)** 触发形式：`$sp-specify`

---

## 🚀 安装到你的项目

我们提供了自动化的安装脚本（Starter Pack）。你可以将这套机制快速安装到现有的业务代码库中。

### macOS / Linux 本地安装
```bash
# 默认安装
sh scripts/install.sh ./your-project

# 为 Codex 安装 (自动生成 sp-* skills)
sh scripts/install.sh --ai codex ./your-project

# 为 Claude 安装 (自动生成 /sp.* commands)
sh scripts/install.sh --ai claude ./your-project
```

### Windows 本地安装 (PowerShell)
```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\install.ps1 .\your-project

# 为 Codex 安装
powershell -ExecutionPolicy Bypass -File .\scripts\install.ps1 -Ai codex .\your-project
```

### 远程一键安装 (无需 clone 仓库)
**Mac/Linux:**
```bash
curl -fsSL https://raw.githubusercontent.com/flyfoxai/openSpecs/main/scripts/install.sh | sh -s -- --archive-url https://github.com/flyfoxai/openSpecs/archive/refs/heads/main.tar.gz ./your-project
```
**Windows:**
```powershell
$env:SP_INSTALL_ARCHIVE_URL="https://github.com/flyfoxai/openSpecs/archive/refs/heads/main.zip"; $env:SP_INSTALL_TARGET_DIR="C:\path\to\your-project"; irm https://raw.githubusercontent.com/flyfoxai/openSpecs/main/scripts/install.ps1 | iex
```

> *注：Codex 模式下（`--ai codex`），安装器默认会检测 `CODEX_HOME` 或使用默认 `.codex/skills` 目录，将技能直接落盘。*

---

## 📦 适用场景

*   **极度适合**：需求复杂、流程多、界面多、数据表多，且希望后期接入“AI 自动化流水线”的大中型业务项目。
*   **不太适合**：仅有一两个页面、规则简单的单体玩具 Demo。

## 📖 详细文档指引

想要了解这套机制背后的更多细节？请参阅以下进阶文档：

*   **中文详细指南**：[READMEDETAILS.md](READMEDETAILS.md)
*   **English Short Version**：[README.en.md](README.en.md)
*   **English Detailed Version**：[READMEDETAILS.en.md](READMEDETAILS.en.md)
*   **安装策略与设计依据**：[docs/sp-agent-install-strategy.md](docs/sp-agent-install-strategy.md)
