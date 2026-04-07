# `speckit-layered`

`sp` is a layered documentation workflow adapted from `Spec Kit`.
The framework step names stay in `sp.*`; each agent only changes how those steps are triggered.

Upstream original repository: `https://github.com/github/spec-kit`

Its goal is not to jump straight from a raw request to code. It first turns a project into a queryable, traceable, incremental documentation skeleton so a model can work on one local area at a time under limited context.

The current phase covers documentation only. The workflow ends at `sp.analyze` and does not include implementation.

## What It Solves

- Real projects contain many unresolved decisions between initial requirements and final implementation.
- Models have limited context and no durable memory, which causes repeated reasoning and drift.
- As scope grows, models start missing important information or reading the wrong area.

`sp` addresses this with layered documents, a unified clarify step, a memory layer, and workset-based decomposition.

## Core Ideas

- Two layers: business clarification first, delivery design second.
- Unified clarify: `sp.clarify` handles high-impact spec, flow, and UI decisions.
- Query-first memory: check project-level and feature-level memory before expanding source docs.
- Worksets: split large features into local work areas.
- Clarification propagation: once a decision changes, all affected docs and memory must be synced.

## Basic Flow

1. `sp.constitution`
2. `sp.specify`
3. `sp.clarify`
4. `sp.flow`
5. `sp.ui`
6. `sp.gate`
7. `sp.bundle`
8. `sp.plan`
9. `sp.tasks`
10. `sp.analyze`

## Install Into a Project Directory

This repository already includes installer scripts for the documentation-stage starter pack.

Local repository install:

```bash
sh scripts/install.sh
sh scripts/install.sh ./your-project
sh scripts/install.sh --ai codex ./your-project
sh scripts/install.sh --ai claude ./your-project
```

Remote one-command install:

```bash
curl -fsSL https://raw.githubusercontent.com/flyfoxai/openSpecs/main/scripts/install.sh | sh -s -- --archive-url https://github.com/flyfoxai/openSpecs/archive/refs/heads/main.tar.gz ./your-project
```

Windows local install:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\install.ps1
powershell -ExecutionPolicy Bypass -File .\scripts\install.ps1 .\your-project
powershell -ExecutionPolicy Bypass -File .\scripts\install.ps1 -Ai codex .\your-project
powershell -ExecutionPolicy Bypass -File .\scripts\install.ps1 -Ai claude .\your-project
```

Windows remote one-command install:

```powershell
$env:SP_INSTALL_ARCHIVE_URL="https://github.com/flyfoxai/openSpecs/archive/refs/heads/main.zip"; $env:SP_INSTALL_TARGET_DIR="C:\path\to\your-project"; irm https://raw.githubusercontent.com/flyfoxai/openSpecs/main/scripts/install.ps1 | iex
```

If no directory is provided, installation defaults to the current directory. Confirmation is required by default unless `--yes`, `-Yes`, or an explicit environment override is used.

Codex integration notes:

- `sp.specify` and `sp.analyze` are framework step names
- Codex uses `$sp-*` triggers
- slash-command agents use `/sp.*`
- The installer installs Codex skills by default when `--ai codex` or `-Ai codex` is used
- The installer installs Claude slash commands by default when `--ai claude` or `-Ai claude` is used
- In Codex mode, installation is successful only when both project templates and actual `sp-*` skills are written

## Best Fit

Best for medium or growing business systems with many screens, flows, and data objects, especially when the team wants a stable document backbone for later automation.

Less useful for very small tools with only a few pages and simple rules.

## Read More

- Chinese short version: [README.md](README.md)
- Chinese detailed version: [READMEDETAILS.md](READMEDETAILS.md)
- English detailed version: [READMEDETAILS.en.md](READMEDETAILS.en.md)
- Installation strategy target doc: [docs/sp-agent-install-strategy.md](docs/sp-agent-install-strategy.md)
