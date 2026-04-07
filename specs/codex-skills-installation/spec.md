# Windows Codex Skills Installation

## Background

`2026-04-06` 的 Windows 复测表明，提交 `172cfbc` 的 `install.ps1` 只落地了 document-stage starter pack，并没有把任何 `sp-*` skills 写入 Codex skills 目录。

这会制造一个危险假象：用户看到安装成功与 `install-manifest.json` 后，容易误以为 Codex 已可直接使用，但实际既没有完成 Codex skills 集成，也容易被误导去测试 `/sp.*` 或 `/prompt:sp.analyze` 这类不属于 Codex 的触发形式。

当前仓库文档已经明确区分：

- slash-command agents 使用 `/sp.*`
- Codex skills 使用 `$sp-*`

因此，这个 feature 的核心目标不是“让 Codex 也支持 slash command”，而是让 Windows 安装器在 Codex 模式下真正完成 skills 安装，并把成功条件、失败条件和触发方式讲清楚。

## Goals

- 明确区分 starter-pack 安装和 Codex integration 安装
- 当用户选择 Codex 模式时，真正把 `sp-*` 写入 Codex skills 目录
- 确保 Codex 的对外触发方式始终是 `$sp-*`
- 让 Windows 在 `CODEX_HOME` 为空时仍能正确回退到默认目录
- 让 Codex 模式下的“安装成功”必须同时代表项目资产和 skills 均已写入

## In Scope

- `scripts/install.ps1` 的 Codex 模式入口与行为
- `-Ai codex -AiSkills` 的模式约束与错误提示
- Windows 下 `CODEX_HOME` 与默认 `.codex` 目录解析
- Codex skills 目录创建、写入校验与失败判定
- 安装输出、manifest 字段、trigger 示例与 next steps 文案
- starter-pack-only 模式与 Codex mode 的文案区分

## Out Of Scope

- 为 Codex 增加 `/sp.*` 兼容形式
- 修改 `sp-*` skills 的正文工作流语义
- 改变其他 slash-command agent 的命令注册方式
- 与安装器无关的生产实现

## Roles

- `ROLE-USER`：执行一键安装并依据输出判断是否能在 Codex 中直接使用 `sp`
- `ROLE-INSTALLER`：复制 starter pack，按模式决定是否安装 Codex skills，并输出可验证结果
- `ROLE-CODEX`：从 Codex skills 目录加载 `sp-*`，并通过 `$sp-*` 触发
- `ROLE-MAINTAINER`：保持脚本、README、兼容文档和验证矩阵的一致性

## Success Criteria

- starter-pack-only 模式必须明确说明未安装 Codex skills
- Codex 模式必须要求 `-Ai codex -AiSkills`
- 当 `CODEX_HOME` 为空时，Windows 必须回退到 `%USERPROFILE%\.codex`
- 最终 skills 目录必须解析为 `<codex_home>\skills`
- 若 skills 目录不存在，安装器必须自动创建
- 若目录无法解析或不可写，安装器必须直接失败，不允许静默成功
- Codex 模式下，只有在项目资产已落地且至少一个 `sp-*` 已成功写入时，安装才算成功
- 安装器必须输出检测到的 `CODEX_HOME`、最终 Codex home、最终 skills 目录、已安装的 `sp-*` 列表
- 安装器必须输出 Codex 触发示例，例如 `$sp-specify`、`$sp-analyze`
- manifest 必须在 Codex 模式下记录 Codex 相关安装信息

## Non-Goals

- 把 `install-manifest.json` 单独视为 Codex 集成完成的证明
- 继续使用模糊文案，让用户自行猜测触发方式
- 允许 Codex 模式在没有写出任何 `sp-*` 时仍显示成功

## Evidence Snapshot

- 用户提供的 `2026-04-06` Windows 复测显示，`172cfbc` 下的 `install.ps1` 只安装 starter pack，未安装任何 Codex skills
- 当前仓库文档已经把 Codex 触发方式定义为 `$sp-*`
- 当前仓库安装脚本已经包含 Codex 模式、路径解析、skills 安装、失败判定与 post-install 输出

## Open Clarification Items

- 是否还需要额外提供独立的 `install-codex-skills.ps1`，还是保留单脚本模式即可
- 安装器是否必须要求 `codex` 命令存在于 `PATH` 中，还是允许先复制 skills、后由用户自行 reload
- 非 Codex 模式下的 next steps 是否要进一步明确到具体 agent，而不是泛化为 `sp.specify`
