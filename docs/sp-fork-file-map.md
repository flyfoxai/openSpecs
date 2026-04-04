# `sp` fork 文件落位图

> 目标：把当前设计阶段的文档成果，映射成未来 fork 原版 `Spec Kit` 时的落位方案。

## 1. 设计原则

当前仓库不是原版 `Spec Kit` fork 仓库，因此这里不直接伪造原版目录。

这份文档只回答一件事：

- 等真正 fork 原版后，哪些内容应该落到哪里

总原则：

- 尽量保留原版 CLI、脚本和 active feature 机制
- 主要修改命令模板、文档模板和 constitution
- 新增内容优先作为模板层增量，不重写整个项目结构

## 2. 建议保留的原版区域

未来 fork 后，以下区域应尽量原样保留或只做小改：

- `specify init`
- `specify check`
- active feature 识别逻辑
- `SPECIFY_FEATURE` 环境变量支持
- 跨平台脚本选择机制

对应目录类型：

- `.specify/scripts/`
- `.specify/templates/`
- `.specify/memory/`

## 3. 建议新增或重写的区域

## 3.1 项目级记忆入口

目标落位：

- `.specify/memory/constitution.md`
- `.specify/memory/project-index.md`
- `.specify/memory/feature-map.md`
- `.specify/memory/domain-map.md`
- `.specify/memory/active-context.md`
- `.specify/memory/hotspots.md`

来源：

- [docs/sp-project-memory-architecture.md](sp-project-memory-architecture.md)
- [docs/sp-command-spec.md](sp-command-spec.md)

写入重点：

- 项目级第一跳路由
- feature 阶段 / 入口 / workset 摘要
- 当前最小阅读集
- 跨 feature 热点与 readiness 结论

## 3.2 constitution

目标落位：

- `.specify/memory/constitution.md`

来源：

- [docs/sp-command-template-drafts.md](sp-command-template-drafts.md)
- [docs/layered-business-framework.md](layered-business-framework.md)

写入重点：

- 两层推进
- 文档阶段边界
- `Mermaid` / `Markdown` / `JSON Forms`
- gate 通过前不进入第二层
- 文档工作流在 `sp.analyze` 结束

## 3.3 feature 文档模板

目标落位：

- `.specify/templates/spec.md`
- `.specify/templates/plan.md`
- `.specify/templates/tasks.md`
- 以及新增的 feature 子模板或生成片段

来源：

- [docs/sp-feature-template-pack.md](sp-feature-template-pack.md)

建议扩展的目标模板：

- `clarifications.md`
- `gate.md`
- `bundle.md`
- `analysis.md`
  - 固定 verdict 表
  - 固定 gap category 表
- `flows/*.mmd`
- `ui/screen-map.md`
- `ui/screen-xx.md`
- `ui/jsonforms/*`
- `delivery/01-prd.md`
- `delivery/02-screen-to-delivery-map.md`
- `delivery/03-use-case-matrix.md`
- `delivery/04-domain-model.md`
- `delivery/05-data-entity-catalog.md`
- `delivery/06-table-index.md`
- `delivery/tables/table-*.md`
- `delivery/07-api-contracts.md`
- `delivery/08-permissions-matrix.md`
- `delivery/09-events-and-side-effects.md`
- `delivery/10-non-functional-requirements.md`
- `delivery/11-module-boundaries.md`
- `delivery/12-test-and-acceptance.md`

## 3.4 命令模板

命令模板是这次 fork 的主改动区。

来源：

- [docs/sp-command-template-drafts.md](sp-command-template-drafts.md)
- [docs/sp-command-spec.md](sp-command-spec.md)

目标：

- 将命令名从 `speckit.*` 改成 `sp.*`
- 新增 `flow / ui / gate / bundle`
- 重写 `specify / clarify / plan / tasks / analyze`
- 当前 fork 只分发文档命令

## 4. agent 命令落位建议

## 4.1 统一原则

- slash command agent 与 Codex skills 使用同一份正文逻辑
- 差异只应体现在触发方式和落位目录
- 不同 agent 不应拥有不同的业务规则版本

## 4.2 slash command agent

适用：

- Qoder CLI
- Kiro CLI
- Amp
- Auggie CLI
- Claude Code
- CodeBuddy CLI
- Cursor
- GitHub Copilot
- Gemini CLI
- IBM Bob
- Jules
- Kilo Code
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
- Trae
- opencode

建议落位方式：

- 保持原版按 agent 写入命令目录的策略
- 每个 agent 下写入：
  - `/sp.constitution`
  - `/sp.specify`
  - `/sp.clarify`
  - `/sp.flow`
  - `/sp.ui`
  - `/sp.gate`
  - `/sp.bundle`
  - `/sp.plan`
  - `/sp.tasks`
  - `/sp.analyze`

兼容别名建议：

- `/sp.checklist` 可作为 `/sp.gate` 的兼容别名

## 4.3 skills 型 agent

适用：

- Codex CLI
- Antigravity (`agy`)

建议落位方式：

- 继续沿用原版 skills 安装机制
- 使用独立的 skills 模板目录
- Codex 命令触发形式固定为：
  - `$sp-constitution`
  - `$sp-specify`
  - `$sp-clarify`
  - `$sp-flow`
  - `$sp-ui`
  - `$sp-gate`
  - `$sp-bundle`
  - `$sp-plan`
  - `$sp-tasks`
  - `$sp-analyze`

额外要求：

- 初始化时支持 `--ai codex --ai-skills`
- 兼容 `CODEX_HOME`
- 升级后提醒重载 workspace

## 4.4 generic bring-your-own agent

适用：

- 原版未内置，但支持自定义命令目录的 agent

建议落位方式：

- 保留 `--ai generic --ai-commands-dir <path>`
- 将 `sp` 命令模板写入用户指定目录
- generic 模式下仍复用同一套命令正文

## 5. feature 输出落位建议

建议仍保留原版 `specs/<feature>/` 作为 active feature 输出根目录：

```text
specs/<feature>/
├── spec.md
├── clarifications.md
├── gate.md
├── bundle.md
├── plan.md
├── tasks.md
├── analysis.md
├── flows/
├── ui/
└── delivery/
```

输出生成责任建议如下：

| 命令 | 主要写入文件 |
| --- | --- |
| `sp.constitution` | `.specify/memory/constitution.md`, `.specify/memory/project-index.md`, `.specify/memory/feature-map.md`, `.specify/memory/domain-map.md`, `.specify/memory/active-context.md`, `.specify/memory/hotspots.md` |
| `sp.specify` | `spec.md`，并刷新 `.specify/memory/feature-map.md`、`.specify/memory/active-context.md` |
| `sp.clarify` | `spec.md`, `clarifications.md` |
| `sp.flow` | `flows/*` |
| `sp.ui` | `ui/*` |
| `sp.gate` | `gate.md`，并刷新 `.specify/memory/project-index.md`、`.specify/memory/feature-map.md` |
| `sp.bundle` | `bundle.md`，并刷新 `.specify/memory/active-context.md` |
| `sp.plan` | `plan.md`, `delivery/*`，并刷新 `.specify/memory/feature-map.md` |
| `sp.tasks` | `tasks.md` |
| `sp.analyze` | `analysis.md`，并刷新 `.specify/memory/project-index.md`、`.specify/memory/feature-map.md`、`.specify/memory/hotspots.md`，且必须包含固定 verdict 与 gap category 结构 |

## 6. 脚本层建议

脚本层以复用原版为主，只做增量扩展。

建议保留：

- feature 定位脚本
- active feature 检测
- `sh` / `ps` 双脚本体系

建议扩展：

- 对 `clarifications.md`、`gate.md`、`bundle.md`、`analysis.md` 的路径支持
- 对 `flows/` 与 `ui/` 的路径创建支持
- 对 `delivery/` 与 `delivery/tables/` 的路径创建支持
- 对 `sp.gate` 和 `sp.bundle` 的文档产物支持
- 对 `sp.plan` 生成多文件第二层输出的支持

## 7. 平台映射建议

macOS / Linux：

- 默认使用 `sh`
- 初始化建议：
  - `specify init . --ai claude --script sh`
  - `specify init . --ai codex --ai-skills --script sh`

Windows：

- 默认使用 `ps`
- 初始化建议：
  - `specify init . --ai claude --script ps`
  - `specify init . --ai codex --ai-skills --script ps`

## 8. 当前设计成果与未来落位的对应关系

| 当前设计文档 | 未来 fork 主要落位 |
| --- | --- |
| [docs/layered-business-framework.md](layered-business-framework.md) | constitution 与工作流说明来源 |
| [docs/sp-command-spec.md](sp-command-spec.md) | 命令规范来源 |
| [docs/sp-installation-and-agent-compatibility.md](sp-installation-and-agent-compatibility.md) | init/check/agent 模板策略来源 |
| [docs/spec-kit-fork-adaptation.md](spec-kit-fork-adaptation.md) | fork 改造边界来源 |
| [docs/sp-command-template-drafts.md](sp-command-template-drafts.md) | 命令正文模板来源 |
| [docs/sp-feature-template-pack.md](sp-feature-template-pack.md) | feature 文档模板来源 |
| [docs/sp-project-memory-architecture.md](sp-project-memory-architecture.md) | 项目级记忆入口模板来源 |

## 9. 下一步建议

当你开始真实 fork 原版仓库时，建议顺序如下：

1. 先替换 constitution
2. 再替换命令模板
3. 再补 feature 文档模板
4. 最后验证 Claude 与 Codex 两条链路
