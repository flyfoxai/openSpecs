# `sp`

`sp` 是一个基于 `Spec Kit` 改造出来的分层文档工作流。

上游原始仓库：`https://github.com/github/spec-kit`

它的重点不是直接写代码，而是先把需求、业务框架、流程、界面、交付设计和一致性分析按固定步骤沉淀成可查询、可回链、可局部推进的文档骨架，帮助大模型在有限上下文里稳定工作。

当前阶段只覆盖文档工作，流程到 `sp.analyze` 结束，不包含 `sp.implement`。

## 它解决什么问题

- 需求和最终实现之间有大量路线、流程、界面决策需要澄清。
- 大模型上下文有限，容易重复推理、前后不一致。
- 项目一旦变大，模型容易读不全、记不住、找不到入口。

`sp` 通过两层文档、统一澄清、记忆层和 workset 拆分，尽量把这些问题前置处理。

## 最核心的东西

- 两层推进：先业务澄清，再交付设计。
- 统一澄清：`sp.clarify` 统一处理 spec、flow、ui 的高影响问题。
- Query-First Memory：先查项目级和 feature 级 memory，再决定读哪些正文。
- Workset：把大 feature 拆成局部工作面，减少上下文压力。
- 澄清传播闭环：结论变更后必须同步相关文档和 memory。

## 基本流程

1. `sp.constitution`：先定规则、边界和记忆层原则。
2. `sp.specify`：把原始需求收敛成 feature 规格。
3. `sp.clarify`：把关键路线问题问清楚。
4. `sp.flow`：固定业务流程。
5. `sp.ui`：固定界面结构和关键交互。
6. `sp.gate`：判断第一层是否过关。
7. `sp.bundle`：给第二层准备稳定交接包。
8. `sp.plan`：生成交付设计和 workset。
9. `sp.tasks`：做任务拆解和绑定。
10. `sp.analyze`：做一致性分析和冒烟判断。

## 安装到项目目录

当前仓库已经提供文档阶段 starter pack 安装脚本。

本地仓库安装：

```bash
sh scripts/install.sh
sh scripts/install.sh ./your-project
sh scripts/install.sh --ai codex --ai-skills ./your-project
```

远程一条命令安装：

```bash
curl -fsSL https://raw.githubusercontent.com/flyfoxai/openSpecs/main/scripts/install.sh | sh -s -- --archive-url https://github.com/flyfoxai/openSpecs/archive/refs/heads/main.tar.gz ./your-project
```

Windows 本地安装：

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\install.ps1
powershell -ExecutionPolicy Bypass -File .\scripts\install.ps1 .\your-project
powershell -ExecutionPolicy Bypass -File .\scripts\install.ps1 -Ai codex -AiSkills .\your-project
```

Windows 远程一条命令安装：

```powershell
$env:SP_INSTALL_ARCHIVE_URL="https://github.com/flyfoxai/openSpecs/archive/refs/heads/main.zip"; $env:SP_INSTALL_TARGET_DIR="C:\path\to\your-project"; irm https://raw.githubusercontent.com/flyfoxai/openSpecs/main/scripts/install.ps1 | iex
```

如果不指定目录，默认安装到当前目录。默认会先提示确认，只有 `--yes`、`-Yes` 或环境变量显式开启后才会跳过。

Codex 集成说明：

- Codex 只使用 skills，触发方式是 `$sp-*`
- `/sp.*` 只属于 slash-command agents
- 只有在使用 `--ai codex --ai-skills` 或 `-Ai codex -AiSkills` 时，安装器才会把 `sp-*` skills 写入 Codex skills 目录
- Codex 模式下，“安装成功”必须同时包含项目内模板和实际写入的 `sp-*` skills

## 适合什么项目

适合需求复杂、流程多、界面多、数据对象多，且希望后续接入自动开发的大中型业务项目。

不太适合只有一两个页面、规则很少、也不关心长期文档一致性的小工具。

## 查看详细说明

- 中文详细版：[READMEDETAILS.md](READMEDETAILS.md)
- English short version: [README.en.md](README.en.md)
- English detailed version: [READMEDETAILS.en.md](READMEDETAILS.en.md)
