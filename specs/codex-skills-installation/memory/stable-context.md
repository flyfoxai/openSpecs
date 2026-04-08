# Stable Context

## Freshness And Sync

| Key | Value |
| --- | --- |
| Feature | `codex-skills-installation` |
| Status | baseline requirement recorded; current repo implementation evidence exists; feature doc chain incomplete |
| Refresh Date | `2026-04-06` |
| Refresh Basis | `spec.md`, `analysis.md`, `README.md`, `scripts/install.ps1`, `scripts/install.sh` |
| Source Of Truth | `spec.md`, `analysis.md`, installer scripts, compatibility docs |
| Required Sync Files | `memory/index.md`, `memory/open-items.md`, `.specify/memory/active-context.md`, `.specify/memory/feature-map.md` |
| Stale Trigger | Codex trigger form changes, install mode changes, manifest field changes, Windows fallback logic changes |

## Role Lookup

| Role ID | Core Actions | Main Artifact | Notes |
| --- | --- | --- | --- |
| `ROLE-USER` | run installer, inspect output, trigger skills | `scripts/install.ps1`, `README.md` | must not be forced to infer Codex readiness from starter-pack output |
| `ROLE-INSTALLER` | copy assets, validate mode, resolve paths, write skills, fail loudly on invalid install | `scripts/install.ps1`, `scripts/install.sh` | owns the success criteria |
| `ROLE-CODEX` | load `sp-*` from the Codex skills directory | resolved Codex skills directory | trigger form is `$sp-*` only |
| `ROLE-MAINTAINER` | keep scripts, docs, and validation matrix aligned | `docs/*`, `README*` | owns drift prevention |

## Install Mode Lookup

| Mode ID | Mode | Required Flags | Expected Outcome | Wrong Assumption To Avoid |
| --- | --- | --- | --- | --- |
| `MODE-SP-ONLY` | starter pack only | none | project docs, layers, `.specify/memory`, `specs`, manifest | do not treat this as Codex integration |
| `MODE-CODEX` | starter pack plus Codex skills | `-Ai codex` or `--ai codex` (`-AiSkills` / `--ai-skills` only as compatibility alias) | project assets plus `sp-*` skills written into Codex skills directory | do not test `/sp.*` in Codex |

## Trigger Lookup

| Target | Trigger Form | Stable Rule |
| --- | --- | --- |
| Codex skills | `$sp-*` | Codex uses skills only |
| slash-command agents | `/sp.*` | not a Codex trigger form |

## Path Resolution Lookup

| Rule ID | Condition | Expected Resolution |
| --- | --- | --- |
| `PATH-CODEX-001` | `CODEX_HOME` is set | use `CODEX_HOME` as Codex home |
| `PATH-CODEX-002` | `CODEX_HOME` is empty on Windows | fall back to `%USERPROFILE%\.codex` |
| `PATH-CODEX-003` | Codex home resolved | skills directory is `<codex_home>\skills` or `<codex_home>/skills` |
| `PATH-CODEX-004` | skills directory missing | create it before copying `sp-*` |
| `PATH-CODEX-005` | skills directory unresolved or unwritable | fail installation loudly |

## Stable Decisions

| Decision ID | Question | Stable Answer | Primary Evidence |
| --- | --- | --- | --- |
| `DEC-CODEX-001` | should Codex be tested with `/sp.*` | no; Codex uses `$sp-*` | compatibility docs and README |
| `DEC-CODEX-002` | is manifest-only output enough to claim Codex success | no; `sp-*` must actually be written | `spec.md`, current installer logic |
| `DEC-CODEX-003` | should Windows support default Codex home fallback | yes | compatibility docs and current installer logic |

## Acceptance Anchors

| Anchor ID | What Must Be True |
| --- | --- |
| `ACC-CODEX-001` | starter-pack-only output clearly says Codex skills were not installed |
| `ACC-CODEX-002` | Codex mode output shows detected `CODEX_HOME`, resolved Codex home, and resolved skills directory |
| `ACC-CODEX-003` | Codex mode writes one or more `sp-*` skills and lists them |
| `ACC-CODEX-004` | Codex mode prints `$sp-specify` and `$sp-analyze` examples |
| `ACC-CODEX-005` | unresolved or unwritable skills directory causes failure, not silent success |
