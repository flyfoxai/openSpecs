# `sp` 安装与 Agent 兼容规范

> 目标：尽量参考原版 `Spec Kit` 的安装思路，但在这个 fork 中把用户可见步骤名统一为 `sp.*`，并为不同 agent 提供清晰的接入方式。

## 1. 设计原则

`sp` 应尽量继承原版 `Spec Kit` 的以下机制：

- 使用 `specify` CLI 完成项目初始化
- 使用 `specify check` 做环境检查
- 使用 `--ai` 选择 agent 模板
- 使用 `--script sh|ps` 选择脚本类型
- 在项目内安装命令文件、模板、脚本和 memory 文件
- 通过当前 Git branch 自动识别 active feature

这样做的原因：

- 降低 fork 与上游的偏离
- 保持跨平台安装体验一致
- 保持对不同 agent 的接入方式一致
- 尽量保持与上游 agent 支持矩阵一致

## 2. 支持平台

当前规范应覆盖：

- macOS
- Linux
- Windows

脚本策略沿用原版：

- Windows 默认 `ps`
- 其他系统默认 `sh`
- 允许通过 `--script sh` 或 `--script ps` 显式指定

## 3. 安装方式

### 3.1 当前文档阶段 starter pack 安装

当前仓库已经提供跨平台安装脚本，用于把文档阶段的 `sp` starter pack 安装到指定项目目录中。

本地仓库执行：

```bash
sh scripts/install.sh
sh scripts/install.sh ./your-project
```

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\install.ps1
powershell -ExecutionPolicy Bypass -File .\scripts\install.ps1 .\your-project
```

远程一条命令执行：

```bash
curl -fsSL https://raw.githubusercontent.com/flyfoxai/openSpecs/main/scripts/install.sh | sh -s -- --archive-url https://github.com/flyfoxai/openSpecs/archive/refs/heads/main.tar.gz ./your-project
```

```powershell
$env:SP_INSTALL_ARCHIVE_URL="https://github.com/flyfoxai/openSpecs/archive/refs/heads/main.zip"; $env:SP_INSTALL_TARGET_DIR="C:\path\to\your-project"; irm https://raw.githubusercontent.com/flyfoxai/openSpecs/main/scripts/install.ps1 | iex
```

安装约束：

- 未指定目录时默认安装到当前目录
- 安装前必须确认；只有显式传入 `--yes`、`-Yes` 或设置 `SP_INSTALL_AUTO_YES=1` 时才跳过
- macOS / Linux 远程安装包建议使用 `tar.gz`
- Windows 远程安装包建议使用 `zip`
- 安装脚本只写入受管路径，不删除无关文件

### 3.2 持久安装

建议保留原版 `specify` CLI 的持久安装方式：

```bash
uv tool install specify-cli --from git+https://github.com/github/spec-kit.git
```

安装后使用：

```bash
specify init <PROJECT_NAME>
specify check
```

### 3.3 一次性运行

也应保留原版 `uvx` 方式：

```bash
uvx --from git+https://github.com/github/spec-kit.git specify init <PROJECT_NAME>
```

### 3.4 在当前目录初始化

```bash
specify init . --ai claude
specify init --here --ai claude
```

如果目录非空，需要兼容原版 `--force`：

```bash
specify init . --force --ai claude
specify init --here --force --ai claude
```

## 4. `sp` 的推荐安装包装

为了降低与 upstream 的偏移，可以保留 `specify` CLI 这一层初始化思路；但在这个 fork 中，对用户暴露的步骤名应统一为 `sp.*`。

推荐模式：

1. 用户仍执行 `specify init`
2. 通过 `--ai` 选择目标 agent
3. 初始化出的命令文件内容按 agent 类型分别写入：
   - slash command agent 使用 `/sp.*`
   - Codex skills 模式使用 `$sp-*`

这样做的好处：

- 安装链路与原版一致
- 升级链路与原版一致
- 真正自定义的部分集中在模板层，而不是 CLI 层
- 不会为了统一外观而破坏 Codex 原有 skills 工作方式

## 5. Agent 兼容要求

参考原版官方支持列表，`sp` 不应只兼容少数常见 agent，而应尽量对齐上游支持矩阵。

重要约束：

- 文中出现的 agent 名称和部分 `--ai` 示例值，当前用于设计说明
- 真实 fork 时，准确的 `--ai` 标识、命令目录和安装方式必须以上游快照里的 `AGENT_CONFIG` 为准
- 本地规范不应自己发明一套与 upstream 冲突的 agent id

按 2026-03-31 的上游 README 快照，至少应覆盖：

- Qoder CLI
- Kiro CLI
- Amp
- Auggie CLI
- Claude Code
- CodeBuddy CLI
- Codex CLI
- Cursor
- Gemini CLI
- GitHub Copilot
- IBM Bob
- Jules
- Kilo Code
- opencode
- Pi Coding Agent
- Qwen Code
- Roo Code
- SHAI (OVHcloud)
- Tabnine CLI
- Mistral Vibe
- Kimi Code
- iFlow CLI
- Windsurf
- Junie
- Antigravity (`agy`)
- Trae
- Generic bring-your-own agent

设计要求：

- 大多数支持 slash command 的 agent 使用 `/sp.*`
- Codex skills 模式使用 `$sp-*`
- 不应把 Codex 视为唯一的 skills 型 agent
- 命令参数写法尽量简单，避免依赖少数 agent 才支持的复杂自定义参数
- 命令模板内容应尽量将“输入说明”和“执行步骤”写在命令文本内部，而不是假设 agent 自己知道上下文
- 对于未内置但可自定义命令目录的 agent，应保留 generic 接入能力

## 6. Agent 适配层建议

fork 时建议延续原版“按 agent 写入不同命令目录”的方式。

至少要考虑：

- Claude 的命令目录
- Codex 的命令目录
- Cursor 的命令目录
- Gemini 的命令目录
- Copilot 的 prompt/command 目录
- Kiro CLI 的命令目录
- Windsurf / Roo Code / Kilo Code 等 IDE-based agent 的命令目录
- generic agent 的自定义命令目录

适配原则：

- 命令语义一致
- 目录位置按 agent 习惯分别落地
- 同一个命令在不同 agent 上，正文尽量一致
- 不强求所有 agent 共享同一种触发语法
- agent 覆盖面应尽量跟随上游 `AGENT_CONFIG`

## 7. Skills 型 Agent 兼容要求

上游当前已明确并非所有 agent 都使用 slash command。

按官方说明，当前至少包括：

- Codex CLI：在 upstream 里可见 `--ai-skills` 这一类 skills 开关
- Antigravity (`agy`)：需要 `--ai-skills`

其中 Codex 还有额外要求：

- 检测 `codex` 工具是否存在
- 优先读取 `CODEX_HOME`
- 若 `CODEX_HOME` 为空，则回退到系统默认目录
- Windows: `%USERPROFILE%\.codex`
- macOS / Linux: `~/.codex`
- 最终 skills 安装目录为 `<codex_home>/skills`
- 若目录不存在，应主动创建
- 若目录仍无法解析或不可写，应直接报错
- 当前 fork 的安装脚本应支持 `--ai codex` 直接进入 Codex 集成模式
- `--ai-skills` 在当前 fork 中只保留为兼容别名，不应再成为隐藏前提
- 将命令以 Codex skills 形式安装，并采用 `$sp-*` 调用方式
- 升级后提醒用户重载 workspace 或重新打开 agent

skills 型 agent 的实现约束：

- 不应把 skills 型 agent 强行改成 slash command 模式
- 命令安装方式应遵循上游对该 agent 的原有模式
- 若 fork 延续原版多 agent 模板目录，应把 skills 模板与 slash command 模板分开维护

Codex 的额外实现约束：

- 命令文件命名应与 `$sp-*` 调用方式一致
- 选择 Codex 模式后，“安装成功”必须同时满足：
- 项目内模板已生成
- `sp-*` skills 已实际写入 Codex skills 目录
- 安装器输出实际写入的 skill 列表和触发示例

## 7.1 Generic Agent 兼容要求

原版当前支持：

- `--ai generic --ai-commands-dir <path>`

因此 `sp` 也应保留：

- generic bring-your-own agent 入口
- 外部自定义命令目录的写入能力
- 不依赖特定厂商 CLI 的模板分发能力

## 8. Claude 兼容要求

Claude 兼容应沿用原版 slash command 工作方式：

- 将 `/sp.*` 命令安装到 Claude 的命令目录
- 命令正文保持结构化步骤提示
- 升级命令模板后，需要提示用户重启或刷新 Claude 工作区

同类 slash command agent 兼容要求可参照 Claude：

- Qoder CLI
- Kiro CLI
- Amp
- Auggie CLI
- Cursor
- GitHub Copilot
- Gemini CLI
- IBM Bob
- Jules
- Kilo Code
- Pi Coding Agent
- Qwen Code
- opencode
- Roo Code
- SHAI (OVHcloud)
- Tabnine CLI
- Mistral Vibe
- Kimi Code
- iFlow CLI
- Windsurf
- Junie
- Trae

## 9. 工作提示规范

原版 `Spec Kit` 的核心优势之一，不只是命令名，而是每一步都有明确工作提示。

因此 `sp` 的每个命令模板都应固定包含以下块：

- `Purpose`
- `Read First`
- `Do`
- `Do Not`
- `Output`
- `Check Before Finish`
- `Next`

每个块的职责应固定：

- `Purpose`：明确本步解决什么问题
- `Read First`：列出必须先读的文件、上下文和前序产物
- `Do`：写清楚本步必须执行的分析或整理动作
- `Do Not`：约束越界行为，避免 agent 直接进入实现
- `Output`：明确要生成或更新哪些文件
- `Check Before Finish`：要求自检完整性、一致性和阻塞项
- `Next`：给出建议的下一条命令

## 10. 各命令的提示强度

### 10.1 第一层命令

`sp.specify`、`sp.clarify`、`sp.flow`、`sp.ui`、`sp.gate`、`sp.bundle` 的提示语应更强约束：

- 防止进入技术方案
- 防止直接写代码
- 防止跳过边界条件和异常
- 防止把未确认规则包装成已确认结论

### 10.2 第二层命令

`sp.plan`、`sp.tasks`、`sp.analyze` 的提示语应强调：

- 仍然属于文档工作
- 不直接进入代码实现
- 重点是交付结构、拆解和一致性检查
- 必须回链第一层产物，而不是凭空重写业务

## 11. 建议的初始化参数

### 11.1 macOS / Linux

下面命令主要用于说明调用形态。

除 `codex`、`generic` 这类当前已明确依赖的参数外，其余 agent 的准确 `--ai` 值在真实 fork 时必须以上游 `AGENT_CONFIG` 为准。

推荐：

```bash
specify init . --ai codex --script sh
specify init . --ai claude --script sh
specify init . --ai gemini --script sh
specify init . --ai kiro-cli --script sh
specify init . --ai windsurf --script sh
specify init . --ai generic --ai-commands-dir .myagent/commands --script sh
```

如果在非空目录初始化：

```bash
specify init . --force --ai codex --script sh
specify init . --force --ai claude --script sh
```

### 11.2 Windows

同样地，下面示例主要用于说明调用形态，不作为脱离 upstream 的最终参数表。

推荐：

```powershell
specify init . --ai codex --script ps
specify init . --ai claude --script ps
specify init . --ai copilot --script ps
specify init . --ai kiro-cli --script ps
specify init . --ai windsurf --script ps
specify init . --ai generic --ai-commands-dir .myagent/commands --script ps
```

如果在非空目录初始化：

```powershell
specify init . --force --ai codex --script ps
specify init . --force --ai claude --script ps
```

## 11.3 安装后检查

初始化完成后，应保留原版的检查动作：

```bash
specify check
```

检查目标包括：

- CLI 是否可用
- agent 模板是否已正确写入
- 脚本类型是否符合当前平台
- Codex 场景下 `CODEX_HOME` 是否可用
- slash command 场景下命令目录是否已刷新

## 12. 升级策略

应沿用原版升级方式：

升级 CLI：

```bash
uv tool install specify-cli --force --from git+https://github.com/github/spec-kit.git
```

升级项目模板：

```bash
specify init --here --force --ai <your-agent>
```

Codex 升级示例：

```bash
specify init --here --force --ai codex
```

升级约束：

- `specs/` 目录中的 feature 文档不应被模板升级覆盖
- 升级影响范围应限制在命令文件、脚本、模板和 memory
- 升级后要提示用户刷新对应 agent
