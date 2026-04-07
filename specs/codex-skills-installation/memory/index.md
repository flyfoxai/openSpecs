# Feature Memory Index

## Question Routing Matrix

| If You Need To... | Read First | Then Expand Only If Needed | Primary Workset |
| --- | --- | --- | --- |
| 确认这个 feature 的业务目标、边界和成功标准 | `memory/stable-context.md` | `spec.md` | none |
| 查当前分析结论、缺口和回退步骤 | `analysis.md` | `memory/open-items.md` | none |
| 看当前实现已覆盖哪些 Codex 安装要求 | `spec.md` | `scripts/install.ps1`, `scripts/install.sh`, `README.md` | none |
| 看尚未固定的策略和回归风险 | `memory/open-items.md` | `analysis.md` | none |

## Freshness And Sync

| Key | Value |
| --- | --- |
| Feature | `codex-skills-installation` |
| Stage | baseline requirement and analysis recorded |
| Latest Gate | `Not Run` |
| Latest Analysis | `FAIL` |
| Refresh Date | `2026-04-06` |
| Refresh Basis | `spec.md`, `analysis.md`, user Windows retest summary |
| Source Of Truth | `spec.md`, `analysis.md`, current installer scripts and docs |
| Required Sync Files | `memory/stable-context.md`, `memory/open-items.md`, `.specify/memory/feature-map.md`, `.specify/memory/active-context.md` |
| Stale Trigger | installer entry policy changes, Codex trigger wording changes, Windows fallback behavior changes |

## Recommended Read Order

1. `memory/index.md`
2. `memory/stable-context.md`
3. `spec.md`
4. `analysis.md`
5. `memory/open-items.md`

## Hotspots

| Hotspot | Why It Matters | Where To Start |
| --- | --- | --- |
| Windows default Codex path fallback | directly determines whether skills are written at all | `memory/stable-context.md` |
| success criteria drift | causes false-success installs | `spec.md`, `analysis.md` |
| trigger wording drift | causes users to test the wrong command form | `spec.md`, `README.md` |

## Open Items Entry

| Priority | Current Focus | Start Here |
| --- | --- | --- |
| `High` | installer entry strategy and readiness gaps | `memory/open-items.md` |
