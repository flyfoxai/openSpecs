# `sp` Agent 安装策略

> 这份文档定义的是 `sp` 的目标安装策略，不等于当前仓库已经全部实现的状态。
> 当前仓库的真实落地情况，必须同时以安装脚本实现和安装输出为准。

## 1. 目标

`sp` 要解决的是两件事：

1. 把项目内的文档工作流 starter pack 装进去
2. 按用户选择的 agent，把对应的命令入口一起装进去

这两层不能混为一谈。

- starter pack 是项目内资产
- agent integration 是项目外或 agent 专用目录资产

因此安装策略必须显式区分：

- 只装 starter pack
- starter pack + 某个 agent 的集成

## 2. 统一命令语义

`sp` 的规范步骤名应统一保持为点号形式：

- `sp.constitution`
- `sp.specify`
- `sp.clarify`
- `sp.flow`
- `sp.ui`
- `sp.gate`
- `sp.bundle`
- `sp.plan`
- `sp.tasks`
- `sp.analyze`

这是框架层面的“步骤语义”。

不同 agent 只是在触发形式上适配，不应把步骤名本身改乱。

## 3. 不同 agent 的触发形式

### 3.1 Claude 类 slash-command agent

Claude 这类 agent 应使用 slash command：

- `/sp.constitution`
- `/sp.specify`
- `/sp.analyze`

这里的 `/sp.*` 是触发形式，不是步骤定义本体。

### 3.2 Codex Desktop prompt agent

Codex Desktop 应使用 prompts 触发：

- `/prompts:sp.constitution`
- `/prompts:sp.specify`
- `/prompts:sp.analyze`

这里的 `/prompts:sp.*` 是 Codex Desktop 的调用形式，本质上仍对应同一组 `sp.*` 步骤。

## 4. 安装策略

### 4.1 不带 `--ai`

如果用户不指定 `--ai`，安装器只做一件事：

- 安装项目内 starter pack

此时不应默认写入任何 agent 的命令目录或 skill 目录。

这样做的原因：

- 避免静默改写用户目录
- 避免用户根本没选 agent 却被写入无关集成
- 让 starter pack 安装保持最保守、最稳定

### 4.2 指定 `--ai codex`

当用户显式指定：

```bash
... --ai codex
```

安装器应默认执行：

- 安装 starter pack
- 安装 Codex Desktop 可见的 `/prompts:sp.*` prompts 到 `CODEX_HOME/prompts`
- 同步镜像 `/prompts:sp.*` 到 `CODEX_HOME/commands` 兼容目录
- 清理遗留的 `CODEX_HOME/skills/sp-*`

不应再要求用户额外记忆“只有再加一个 `--ai-skills` 才会真的装”这种隐藏规则。

如果确实需要保留兼容参数，也应这样处理：

- `--ai-skills` 作为兼容别名保留
- 但它只应作为无副作用的兼容空操作，不再触发任何 skill 安装

Codex 模式的成功条件必须同时满足：

- starter pack 已写入目标项目
- Codex prompts 目录里实际出现 `sp.*` 命令文件
- Codex commands 兼容目录里实际出现镜像的 `sp.*` 命令文件
- 若 `CODEX_HOME/skills` 下存在旧 `sp-*`，安装后应被清理
- 安装输出打印出已安装的 `/prompts:sp.*` 列表
- 安装输出给出正确触发示例，如 `/prompts:sp.specify`
- `prompts` 与 `commands` 里的旧 `/prompts:speckit.*` 若存在，应被清理

否则应直接失败，不允许假成功。

### 4.3 指定 `--ai claude`

当用户显式指定：

```bash
... --ai claude
```

安装器应默认执行：

- 安装 starter pack
- 安装 Claude 的 `/sp.*` slash commands

Claude 模式下，命令应写入项目目录下的 Claude commands 目录，例如：

- `.claude/commands/`

Claude 模式的成功条件必须同时满足：

- starter pack 已写入目标项目
- `.claude/commands/` 中实际出现 `sp.*` 命令文件
- 安装输出打印出已安装的命令名
- 安装输出给出正确触发示例，如 `/sp-specify` 以外的错误写法不得出现
- 正确示例应为 `/sp.specify`

## 5. 第一阶段直接支持的 agent

安装层面第一阶段先直接支持两个 agent：

- `codex`
- `claude`

原因很简单：

- 这两类代表了两种最典型的接入模型
- Claude 代表 slash-command 模型
- Codex 代表 host-level prompt 模型

只要这两类打通，其他 agent 的适配就不再是“从零开始”，而只是目录和触发形式映射问题。

## 6. 其他 CLI / agent 的通用接入方法

即使某个 CLI 暂时没有专门安装脚本，也应该能通过这份文档自行完成接入。

关键不是厂商名，而是它属于哪一类：

### 6.1 如果它支持 slash command

那就按 Claude 类方式接入：

- 命令语义仍然是 `sp.*`
- 触发形式使用 `/sp.*`
- 把命令文件写进该 agent 的 commands/prompts 目录

要点：

- 文件名与命令名保持一致
- 命令正文要写清楚读取顺序、输出目标、禁止越界范围
- 安装后要验证这些命令在 agent 中真的可见

### 6.2 如果它支持 host-level prompts

那就按 Codex 类方式接入：

- 步骤语义仍然是 `sp.*`
- 触发形式使用宿主要求的 prompt 语法
- 把 prompt 文件写进该 agent 的 prompts/commands 目录

### 6.3 如果它两种都支持

优先级建议如下：

- 简单、显式、单文件入口场景，优先 slash command
- 宿主原生支持 prompts 时，优先 prompt 文件而不是额外 skill 包装

如果两种都支持，文档必须写清楚：

- 哪一种是默认推荐入口
- 另一种是兼容入口还是正式入口

## 7. 安装输出要求

无论是哪种 agent，安装器最后都应打印：

- 安装到的项目目录
- 当前选择的 agent
- 实际写入的 agent 集成目录
- 实际写入的命令名称
- 正确触发示例

例如：

- Claude：`/sp.specify`
- Codex Desktop：`/prompts:sp.specify`

安装输出里不应混入错误触发方式。

## 8. 失败处理要求

如果用户选择了某个 agent，但安装器没有真正完成对应集成，应立即失败。

例如：

- 选了 `--ai codex`，但 prompts 主目录或 commands 兼容目录不可写
- 选了 `--ai codex`，但没有任何 `sp.*` prompt 文件被写入
- 选了 `--ai codex`，但 prompts 主目录或 commands 兼容目录未产生任何 `sp.*`
- 选了 `--ai claude`，但 `.claude/commands/` 没有生成命令文件

都不应只留下 starter pack 就当成功。

## 9. 当前仓库的实现状态

截至当前仓库状态，这份文档描述的是目标策略，不是全部已实现能力。

当前实现是否达标，必须按下面顺序判断：

1. 看安装脚本真实支持的 `--ai` 分支
2. 看安装脚本是否真的写入了对应目录
3. 看安装输出是否列出了实际写入结果
4. 安装后到目标目录复查文件是否存在

如果脚本没有这些行为，就只能算“策略已定义”，不能算“能力已落地”。

## 10. 推荐的下一步落地顺序

建议按下面顺序实现，而不是一次铺开所有 agent：

1. 先把 `codex` 打通
   要求 `--ai codex` 默认完成 `/prompts:sp.*` 安装、`commands` 镜像和遗留 skills 清理
2. 再把 `claude` 打通
   要求 `--ai claude` 默认完成 `/sp.*` 命令安装与校验
3. 再补通用适配文档
   说明其他支持 skills 或 slash command 的 CLI 如何手动接入
4. 最后再扩展更多 agent
   例如 Gemini、Cline、Cursor、Copilot

这样推进最稳，也最不容易再出现“看起来装成功，其实没有真正接入 agent”的假象。
