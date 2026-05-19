# sp v0.8.11 Migration Plan

This document records what must be preserved from the previous sp project while rebasing onto upstream `github/spec-kit` `v0.8.11`.

## Baseline

- Upstream baseline: `/Users/hula/Projects/spec-kit-v0.8.11-upstream`
- New sp working tree: `/Users/hula/Projects/speckit-layered-v0.8.11-sp`
- Upstream tag: `v0.8.11`
- Upstream commit: `5301b34132fd0dfa96767631c3a79fd28ce30d00`
- Previous sp archive: `archieve3-pre-v0.8.11-rebase/current-working-tree/`

## Migration Principle

Keep the upstream mechanism as the bottle:

- Preserve upstream CLI shape, integration registry, shared infrastructure install flow, scripts, extension system, presets, workflows, and packaging style as much as possible.
- Avoid rebuilding the installer as a separate static distribution layer.
- Prefer small upstream-compatible hooks over custom parallel mechanisms.

Move sp improvements as the contents:

- Command business instructions can differ from upstream.
- `sp.analyze` may write `analysis.md` and refresh memory; this is an intended workflow enhancement, not a mechanism conflict.
- Layered clarification, flow, UI, gate, bundle, delivery, and memory routing are sp content and should be preserved.

## Previous sp Features To Preserve

This section is the migration checklist. Each preserved feature must have a
clear target location and a concrete way to verify it after installation.

### Command Layer

Previous sp command templates live at:

`archieve3-pre-v0.8.11-rebase/current-working-tree/templates/commands/`

Commands to preserve:

- `specify.md` -> `sp.specify`
- `clarify.md` -> `sp.clarify`
- `flow.md` -> `sp.flow`
- `ui.md` -> `sp.ui`
- `gate.md` -> `sp.gate`
- `bundle.md` -> `sp.bundle`
- `plan.md` -> `sp.plan`
- `tasks.md` -> `sp.tasks`
- `analyze.md` -> `sp.analyze`
- `constitution.md` -> `sp.constitution`
- `checklist.md` -> `sp.checklist`
- `implement.md` -> `sp.implement`
- `taskstoissues.md` -> `sp.taskstoissues`

Upstream only has nine command templates. sp adds:

- `flow.md`
- `ui.md`
- `gate.md`
- `bundle.md`

Migration target:

- Source templates stay in `templates/commands/`, matching upstream command
  template placement.
- Built-in runtime names are generated as `sp.*` or `sp-*`.
- Extension and preset ecosystem commands keep upstream `speckit.*` or
  `speckit-*` names unless they intentionally target a built-in command.

Acceptance checks:

- Markdown/TOML/YAML/Copilot command integrations create `sp.plan.*`,
  `sp.specify.*`, and the other built-in `sp.*` command files.
- Skills integrations create `sp-plan/SKILL.md`, `sp-specify/SKILL.md`, and the
  other built-in `sp-*` skill directories.
- Command bodies resolve `__SPECKIT_COMMAND_PLAN__` to `/sp.plan` for dotted
  agents and `/sp-plan` for skills agents.
- Extension commands such as `speckit.git.commit` continue to resolve to
  `/speckit.git.commit` or `/speckit-git-commit`.

### Project Memory

Previous project memory templates live at:

`archieve3-pre-v0.8.11-rebase/current-working-tree/templates/project/.specify/memory/`

Files to preserve:

- `project-index.md`
- `active-context.md`
- `constitution.md`
- `feature-map.md`
- `domain-map.md`
- `hotspots.md`

Purpose:

- Route the agent to the active feature and smallest useful read set.
- Avoid broad repeated source reads.
- Preserve stable project facts across commands.
- Let feature-level memory override stale project-level routing.

Migration target:

- Project memory seeds are installed into generated projects at
  `.specify/memory/`.
- They are copied by the shared infrastructure installer and tracked in the
  shared manifest, not by a separate static starter-pack installer.

Acceptance checks:

- `specify init` creates `.specify/memory/project-index.md`.
- `specify init` creates `.specify/memory/active-context.md`.
- The generated project has enough routing files for `sp.analyze` to reconcile
  project-level memory against feature-level memory.

### Feature Template Tree

Previous feature templates live at:

`archieve3-pre-v0.8.11-rebase/current-working-tree/templates/project/.specify/templates/feature/`

Feature root files to preserve:

- `analysis.md`
- `bundle.md`
- `clarifications.md`
- `clarify-log.md`
- `gate.md`
- `tasks.md`

Feature memory files to preserve:

- `memory/index.md`
- `memory/stable-context.md`
- `memory/open-items.md`
- `memory/trace-index.md`
- `memory/worksets/index.md`
- `memory/worksets/ws-primary-journey.md`
- `memory/worksets/ws-decision-and-approval.md`
- `memory/worksets/ws-query-and-followup.md`
- `memory/worksets/ws-side-effects.md`

Flow files to preserve:

- `flows/index.md`
- `flows/main-flow.mmd`
- `flows/sequence.mmd`
- `flows/state.mmd`

UI files to preserve:

- `ui/index.md`
- `ui/screen-map.md`
- `ui/screen-primary.md`
- `ui/screen-list.md`
- `ui/screen-detail.md`
- `ui/screen-review.md`
- `ui/jsonforms/schema.json`
- `ui/jsonforms/uischema.json`
- `ui/jsonforms/data.example.json`

Delivery files to preserve:

- `delivery/01-prd.md`
- `delivery/02-screen-to-delivery-map.md`
- `delivery/03-use-case-matrix.md`
- `delivery/04-domain-model.md`
- `delivery/05-data-entity-catalog.md`
- `delivery/06-table-index.md`
- `delivery/07-api-contracts.md`
- `delivery/08-permissions-matrix.md`
- `delivery/09-events-and-side-effects.md`
- `delivery/10-non-functional-requirements.md`
- `delivery/11-module-boundaries.md`
- `delivery/12-test-and-acceptance.md`
- `delivery/tables/table-primary-record.md`
- `delivery/tables/table-decision-record.md`
- `delivery/tables/table-side-effect-ledger.md`

Migration target:

- Generic feature seed files are installed under
  `.specify/templates/feature/` in generated projects.
- `spec-template.md` and `plan-template.md` remain at the upstream top-level
  `templates/` source because upstream installs them directly into
  `.specify/templates/`.
- Do not keep duplicate `spec-template.md` or `plan-template.md` copies inside
  `templates/project/.specify/templates/`; duplicates are skipped by default
  install behavior and can silently install the weaker version.

Acceptance checks:

- `specify init` creates `.specify/templates/feature/memory/index.md`.
- `specify init` creates `.specify/templates/feature/flows/index.md`.
- `specify init` creates `.specify/templates/feature/ui/index.md`.
- `specify init` creates `.specify/templates/feature/delivery/01-prd.md`.
- `.specify/templates/spec-template.md` and
  `.specify/templates/plan-template.md` contain the sp enhanced scaffold, not
  the unmodified upstream placeholders.

### Context-Minimization Mechanism

Previous sp introduced a document routing model to reduce repeated model reads:

- project-level routing in `.specify/memory/*`
- feature-level routing in `specs/<feature>/memory/*`
- workset-level routing in `memory/worksets/*`
- trace files that connect owners, states, screens, APIs, tables, permissions,
  side effects, tasks, and acceptance paths

Migration target:

- Preserve this as content and scaffold structure, not as a parallel runtime
  engine.
- Commands must instruct agents to read routing entries first and expand only
  into the current target area.
- The install mechanism only guarantees the files exist; the command templates
  enforce how agents use them.

Acceptance checks:

- New projects contain both project memory seeds and feature memory templates.
- `sp.analyze` can produce a FAIL when scaffold placeholders remain, instead of
  pretending the document system is automation-ready.
- Memory refresh is permitted only as documentation work and must not write
  production code.

### Layered Design Outputs

Previous sp added design layers that upstream does not model explicitly:

- clarification logs and open items
- flow diagrams and state/sequence views
- UI screen maps and JSONForms examples
- delivery package documents for PRD, data, APIs, permissions, side effects,
  module boundaries, tests, and acceptance
- gate and bundle review outputs

Migration target:

- Preserve these as feature template content under
  `.specify/templates/feature/`.
- Preserve command entrypoints for `sp.flow`, `sp.ui`, `sp.gate`, and
  `sp.bundle`.
- Keep the upstream CLI/integration install path unchanged except for the small
  scaffold copy hook needed to seed these files.

Acceptance checks:

- A freshly initialized project includes the feature template tree even before
  a concrete feature is created.
- The command list includes all sp built-ins.
- No agent-specific static installer directory is required for these layers.

### Concrete Reference Example

The richest previous example is:

`archieve3-pre-v0.8.11-rebase/current-working-tree/archieve2/Archieved/project-root/specs/attendance-leave/`

Use it as a quality reference when improving scaffold templates, but do not copy business-specific attendance leave content into generic templates.

## Required v0.8.11 Adaptation

### Command Naming

Runtime command names must switch from upstream `speckit.*` / `speckit-*` to sp `sp.*` / `sp-*` for built-in commands.

Extension and ecosystem identifiers may still use upstream `speckit` metadata where that is part of the upstream product mechanism.

### Shared Infrastructure Install

Upstream `v0.8.11` installs shared infrastructure from top-level `templates/` and `scripts/` into generated projects.

Important upstream fact:

- `templates/project/` is not an upstream install root.
- `shared_infra.py` copies top-level template files from `templates/` to `.specify/templates`.
- It currently skips template directories.

Therefore sp must not assume the old `templates/project/` directory is automatically installed.

Compatible migration options:

- Add a small upstream-style project scaffold install path that copies a bundled `templates/project/` tree into the generated project.
- Or teach shared infrastructure to copy selected template subdirectories while preserving upstream safety checks and manifest tracking.

Chosen direction:

- Add a small project scaffold installer in the shared infrastructure path.
- Keep it manifest-tracked.
- Keep the source under `templates/project/` because it clearly separates generated-project seed files from upstream command/page templates.

### Packaging

If new bundled assets are added under `templates/project/`, update `pyproject.toml` force-include so wheel installs behave like source installs.

### Regression Checks

At minimum, after migration:

- `uv run specify --help`
- `uv run specify init <tmp> --offline --integration codex --ignore-agent-tools --no-git`
- `uv run specify init <tmp> --offline --integration claude --ignore-agent-tools --no-git`
- Verify generated Codex skills are named `sp-*`.
- Verify generated Claude skills are named `sp-*`.
- Verify `.specify/memory/*` exists.
- Verify `.specify/templates/feature/*` exists.
- Verify command content can route through project memory and feature memory.

## Migration Order

1. Copy previous sp command templates into `templates/commands/`.
2. Update built-in command naming helpers from `speckit` to `sp` for generated command files and slash invocations.
3. Add `flow`, `ui`, `gate`, and `bundle` to command expectations and tests.
4. Copy previous project memory and feature template tree into `templates/project/`.
5. Add an upstream-compatible, manifest-tracked project scaffold installation step.
6. Update package asset includes.
7. Add focused tests for command naming and scaffold installation.
8. Run real `specify init` smoke checks for Codex and Claude.

## Non-Goals For This Pass

- Do not rewrite upstream extension, preset, or workflow engines unless tests prove they are broken by the sp command prefix.
- Do not copy business-specific attendance leave content into generic templates.
- Do not remove archive folders.
- Do not claim full product polish until real host command smoke checks are run.

## Legacy sp Feature Inventory

This section records the old project's actual modifications before further
implementation. It is the preservation checklist for the v0.8.11 rebase.

| Area | Old sp capability | Old source | v0.8.11-sp target | Verification |
| --- | --- | --- | --- | --- |
| Built-in command set | Adds the layered commands `flow`, `ui`, `gate`, and `bundle` on top of upstream commands. | `archieve3-pre-v0.8.11-rebase/current-working-tree/templates/commands/` | `templates/commands/` | Installed agents expose `sp.flow`, `sp.ui`, `sp.gate`, `sp.bundle` or skill names `sp-flow`, `sp-ui`, `sp-gate`, `sp-bundle`. |
| Built-in command naming | Built-in runtime commands use `sp.*` or `sp-*` rather than upstream `speckit.*` or `speckit-*`. | Old installed command output and old command docs. | `src/specify_cli/command_names.py`, integration setup paths, command reference replacement. | Generated command files and slash invocations use `sp.*` for markdown-style agents and `sp-*` for skills agents. |
| Extension ecosystem naming | Extensions, presets, and community packages remain under upstream `speckit.*` and `speckit-*` naming. | Upstream extension and preset mechanisms. | Preserve upstream extension and preset files unless a failing test proves a required compatibility hook. | Extension/preset tests continue to resolve `speckit.git.*` and preset override names. |
| Project memory routing | Project-level routing files reduce repeated model reads and route agents to the active feature. | `templates/project/.specify/memory/` | `templates/project/.specify/memory/` installed into generated projects. | `specify init` creates `.specify/memory/project-index.md`, `active-context.md`, `feature-map.md`, `domain-map.md`, `hotspots.md`, and `constitution.md`. |
| Feature memory routing | Feature-level memory index, stable context, open items, trace index, and worksets constrain the read set. | `templates/project/.specify/templates/feature/memory/` | `templates/project/.specify/templates/feature/memory/` installed as feature templates. | `specify init` creates `.specify/templates/feature/memory/index.md` and workset templates. |
| Workset splitting | Primary journey, decision/review, query/follow-up, and side-effect worksets split large features into bounded model work areas. | `templates/project/.specify/templates/feature/memory/worksets/` and attendance-leave reference. | Generic workset templates under `templates/project/.specify/templates/feature/memory/worksets/`. | New project contains the four generic `ws-*.md` files and command prompts read them before broad expansion. |
| Flow layer | Business flow docs and Mermaid assets make stage, branch, sequence, and state paths explicit. | `templates/project/.specify/templates/feature/flows/` | `templates/project/.specify/templates/feature/flows/` plus `templates/commands/flow.md`. | New project contains flow templates; `/sp.flow` can create or refresh `specs/<feature>/flows/*`. |
| UI layer | UI screen maps, screen detail docs, and JSON Forms assets make screen responsibilities and fields explicit. | `templates/project/.specify/templates/feature/ui/` | `templates/project/.specify/templates/feature/ui/` plus `templates/commands/ui.md`. | New project contains UI templates; `/sp.ui` can create or refresh `specs/<feature>/ui/*`. |
| Gate and bundle outputs | Gate records readiness decisions; bundle compresses first-layer stable conclusions before delivery design. | `templates/project/.specify/templates/feature/gate.md`, `bundle.md`, and related commands. | `templates/project/.specify/templates/feature/gate.md`, `bundle.md`, `templates/commands/gate.md`, `templates/commands/bundle.md`. | New project contains gate/bundle templates; command prompts refresh memory after verdict or bundle changes. |
| Delivery design package | Layer 2 delivery docs cover PRD, screens-to-delivery, use cases, domain, data entities, tables, APIs, permissions, side effects, NFRs, modules, tests, and acceptance. | `templates/project/.specify/templates/feature/delivery/` and attendance-leave reference. | Generic delivery templates under `templates/project/.specify/templates/feature/delivery/`. | New project contains all delivery docs and table templates. |
| Enhanced spec and plan templates | Spec and plan templates include layered routing, memory, trace, and delivery placeholders rather than plain upstream scaffold only. | Old `templates/spec-template.md`, `templates/plan-template.md`, plus stronger copies once under `templates/project/.specify/templates/`. | Top-level `templates/spec-template.md` and `templates/plan-template.md`; do not duplicate under `templates/project/.specify/templates/`. | Installed `.specify/templates/spec-template.md` and `plan-template.md` include sp sections and resolved command references. |
| Analyze enhancement | `sp.analyze` may create or update `analysis.md` and refresh memory as documentation work. | Old `templates/commands/analyze.md`. | `templates/commands/analyze.md`. | Installed `sp.analyze` keeps upstream command shell/frontmatter but includes the sp readiness audit and memory refresh rules. |
| Documentation package | User-facing SP overview, command spec, context-memory architecture, and agent compatibility docs should travel with generated projects where useful. | Old `materials/` and generated project docs. | `templates/project/docs/` for generated projects; repository-level docs remain under upstream-style `docs/`. | `specify init` creates generated-project SP docs without replacing upstream product docs. |
| Installation mechanism | Old static starter-pack installer is replaced by upstream `specify init` and integration mechanisms. | Old installer assets and scripts in archives. | Upstream `shared_infra.py` plus a small manifest-tracked project scaffold copy step. | Real `specify init` smoke checks for Codex, Claude, and Copilot install commands, scripts, memory, feature templates, and docs. |
| Packaging | Added project scaffold assets must work from both source checkout and built wheel. | Old source-only starter assets. | `pyproject.toml` force-includes `templates/project`. | Wheel/source install tests can find `core_pack/templates/project`. |

## Current Migration Status

| Item | Status | Notes |
| --- | --- | --- |
| New upstream-shaped directory | Done | The new work tree is `/Users/hula/Projects/speckit-layered-v0.8.11-sp`; the upstream baseline is `/Users/hula/Projects/spec-kit-v0.8.11-upstream`. |
| Previous work tree archive | Done | The previous tree is preserved under `archieve3-pre-v0.8.11-rebase/current-working-tree/`. |
| Command templates | Done, install-smoke verified | Current `templates/commands/` contains all old sp command stems including `flow`, `ui`, `gate`, and `bundle`. Codex and Claude smoke installs generated `sp-*` skills; Copilot smoke install generated `sp.*.agent.md` files. |
| Project memory templates | Done, install-smoke verified | Current `templates/project/.specify/memory/` contains the six project routing files. Codex smoke install created `.specify/memory/project-index.md` and `.specify/memory/active-context.md`. |
| Feature template tree | Done, install-smoke verified | Current `templates/project/.specify/templates/feature/` contains memory, flows, UI, delivery, gate, bundle, analysis, clarification, and task scaffolds. Codex smoke install created representative memory, flow, UI, and delivery files. |
| Duplicate old spec/plan template location | Intentionally removed | v0.8.11 installs spec and plan templates from top-level `templates/`, so duplicate copies under `templates/project/.specify/templates/` are not retained. |
| Command naming helper | Done, install-smoke verified | `src/specify_cli/command_names.py` centralizes `sp.*` / `sp-*` for built-ins while preserving `speckit.*` / `speckit-*` for extension-style commands. Smoke installs generated only `sp-*` or `sp.*` built-in command names. |
| Shared install hook | Done, install-smoke verified | `src/specify_cli/shared_infra.py` copies `templates/project/` into generated projects and tracks files in the shared manifest. |
| Package asset include | Done, pending wheel regression | `pyproject.toml` force-includes `templates/project`. Source-tree smoke installs verified the scaffold path; a built-wheel smoke remains useful before release. |
| Historical docs cleanup | Partial | Runtime-impacting docs are being moved toward current v0.8.11-SP wording; archival docs are kept for traceability. |

## Old Feature Preservation Audit

Fresh file-level comparison against the archived previous sp tree shows:

- `templates/commands/`: no old command file is missing in the v0.8.11-sp tree.
- `templates/project/`: no old generated-project scaffold file is missing except the intentionally removed duplicate `.specify/templates/spec-template.md` and `.specify/templates/plan-template.md` copies.
- The duplicate spec and plan templates are preserved through the upstream v0.8.11 source location: top-level `templates/spec-template.md` and `templates/plan-template.md`.
- `templates/commands/checklist.md` differs only by changing a hardcoded `/sp.checklist` reference to `__SPECKIT_COMMAND_CHECKLIST__`, so upstream integration processing can render the correct host-specific invocation.
- `templates/commands/implement.md` differs by adding project memory reads and changing a hardcoded `/sp.tasks` reference to `__SPECKIT_COMMAND_TASKS__`, preserving the old context-minimization goal while staying inside upstream command-reference processing.

Smoke install evidence from this tree:

- `uv run specify init /tmp/sp-v0811-codex --offline --integration codex --ignore-agent-tools --no-git` completed successfully.
- `uv run specify init /tmp/sp-v0811-claude --offline --integration claude --ignore-agent-tools --no-git` completed successfully.
- `uv run specify init /tmp/sp-v0811-copilot --offline --integration copilot --ignore-agent-tools --no-git` completed successfully.
- Generated Codex file exists: `/tmp/sp-v0811-codex/.agents/skills/sp-analyze/SKILL.md`.
- Generated Claude file exists: `/tmp/sp-v0811-claude/.claude/skills/sp-analyze/SKILL.md`.
- Generated Copilot file exists: `/tmp/sp-v0811-copilot/.github/agents/sp.analyze.agent.md`.
- Generated project memory exists: `/tmp/sp-v0811-codex/.specify/memory/project-index.md` and `/tmp/sp-v0811-codex/.specify/memory/active-context.md`.
- Generated feature templates exist for memory, flows, UI, and delivery under `/tmp/sp-v0811-codex/.specify/templates/feature/`.

## Immediate Remaining Work

1. Run a fresh broad integration regression after each further mechanism edit.
2. Run a built-wheel smoke check before release, because `templates/project/` is a new packaged asset path.
3. Manually verify real host UI execution for at least Codex and Claude: start the host in an initialized temp project and invoke `sp.analyze` / `sp-plan` in the host, not only through file-existence checks.
4. Keep non-archive runtime `speckit.*` references only where they belong to upstream extension, preset, workflow, or manifest naming; built-in runtime commands should continue to resolve through `src/specify_cli/command_names.py`.
5. Continue improving scaffold quality in feature templates; the mechanism can install and route them, but business completeness still depends on template content quality.
