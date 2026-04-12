# Repository Guidelines

## Project Structure & Module Organization
This repository is a documentation-first starter pack for the `sp.*` workflow.

- `docs/`: source specifications, architecture notes, installation strategy, and validation docs.
- `installer-assets/claude-commands/`: pre-rendered slash-command templates for Claude-style hosts.
- `installer-assets/codex-prompts/`: pre-rendered prompt templates for Codex Desktop hosts.
- `installer-assets/project/`: files copied into target projects, including `.specify/memory/` and overview docs.
- `scripts/install.sh` and `scripts/install.ps1`: the main installer entry points.
- `layer-1-business-clarification/` and `layer-2-delivery/`: staged workflow content shipped by the installer.

## Build, Test, and Development Commands
There is no app build pipeline in the root package. Use these commands during maintenance:

- `sh -n scripts/install.sh`: syntax-check the POSIX installer.
- `sh scripts/install.sh --help`: verify CLI help text and flags.
- `CODEX_HOME=/tmp/codex-home sh scripts/install.sh --yes --ai codex /tmp/sp-project`: smoke-test Codex installation.
- `git diff --stat`: review change scope before commit.

If PowerShell is available, validate Windows behavior with:

- `powershell -ExecutionPolicy Bypass -File .\scripts\install.ps1 -Ai codex .\tmp-project`

## Coding Style & Naming Conventions
- Use ASCII unless a file already contains Chinese copy that should remain bilingual.
- Keep shell scripts POSIX-compatible; avoid Bash-only features in `scripts/install.sh`.
- Keep PowerShell changes aligned with shell behavior and output.
- Use existing naming patterns: `sp.<step>.md` for prompts and Markdown docs.
- Prefer short, direct documentation edits over marketing-style copy.

## Testing Guidelines
- Treat installer smoke tests as the primary verification gate.
- For Codex changes, verify both `CODEX_HOME/prompts` and `CODEX_HOME/commands`.
- Confirm legacy `speckit.*` files are removed when relevant.
- Check `.sp/install-manifest.json` for the expected installed paths and command lists.

## Commit & Pull Request Guidelines
- Follow the existing history: concise imperative subjects such as `fix codex desktop prompt install targets` or `docs(install): clarify codex remote install`.
- Keep commits scoped to one concern: installer logic, docs, or asset templates.
- PRs should describe user-visible behavior changes, list verification commands run, and mention any platform gaps not tested.

## Contributor Notes
- Do not change trigger semantics casually: `/prompts:sp.*` and `/sp.*` serve different hosts.
- When updating installation behavior, keep `install.sh`, `install.ps1`, and affected docs in sync.
- Codex `sp-*` skills are legacy cleanup targets, not an active packaging path.
