# Open Items

| Item ID | Type | Severity | Domain | Workset | Description | Impact Area | Affected Docs | Suggested Rollback | Last Refresh | Status |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| `OPEN-CODEX-001` | `Question` | `Medium` | installer entry strategy | none | 是否需要独立的 `install-codex-skills.ps1`，还是维持单脚本加模式开关。 | installer UX, docs | `spec.md`, future `clarifications.md` | `sp.clarify` | `2026-04-06` | `Open` |
| `OPEN-CODEX-002` | `Question` | `Medium` | tool prerequisite | none | 是否必须检查 `codex` 命令存在于 `PATH`，还是允许先复制 skills 再由用户后续 reload。 | install precheck, failure policy | `spec.md`, future `clarifications.md` | `sp.clarify` | `2026-04-06` | `Open` |
| `RISK-CODEX-001` | `Risk` | `High` | readiness | none | 当前 feature 还没有 `gate.md`、`bundle.md`、`plan.md`、`tasks.md`，容易被误判为“问题已完全沉淀并可继续自动化”。 | later automation handoff | `analysis.md` | `sp.gate` | `2026-04-06` | `Open` |
| `RISK-CODEX-002` | `Risk` | `High` | docs drift | none | 如果 README、兼容文档和安装脚本的 trigger 文案再次漂移，用户仍可能回到错误的 `/sp.*` 测试方式。 | user testing path | `analysis.md`, `README.md`, `docs/*` | `sp.gate` | `2026-04-06` | `Open` |
| `RISK-CODEX-003` | `Risk` | `Medium` | Windows regression coverage | none | Windows 默认目录回退已有实现，但缺少 feature 级回归清单时，后续回归难以及时发现。 | regression verification | `analysis.md` | `sp.plan` | `2026-04-06` | `Open` |
| `BLOCK-CODEX-000` | `Blocker` | `None` | none | none | 当前没有阻止继续补文档的硬 blocker，但 readiness 仍不足。 | none | `analysis.md` | none | `2026-04-06` | `Closed` |

## Filter Views

| If You Are Working On... | Read These IDs First | Main Workset | Main Rollback |
| --- | --- | --- | --- |
| installer 入口策略 | `OPEN-CODEX-001`, `OPEN-CODEX-002` | none | `sp.clarify` |
| readiness 收口 | `RISK-CODEX-001` | none | `sp.gate` |
| trigger 与文案一致性 | `RISK-CODEX-002` | none | `sp.gate` |
| Windows 回归覆盖 | `RISK-CODEX-003` | none | `sp.plan` |

## Freshness And Sync

| Key | Value |
| --- | --- |
| Open Questions | `2` |
| Risks | `3` |
| Blockers | `0 active` |
| Highest Priority Domain | readiness and docs drift |
| Refresh Date | `2026-04-06` |
| Refresh Basis | `spec.md`, `analysis.md`, current installer evidence |
| Source Of Truth | `spec.md`, `analysis.md` |
| Required Sync Files | `memory/index.md`, `memory/stable-context.md`, `.specify/memory/active-context.md`, `.specify/memory/feature-map.md` |
| Stale Trigger | installer mode policy changes, Windows fallback policy changes, new Codex acceptance coverage lands |
