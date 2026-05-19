# `sp` Command Specification

## 1. Purpose

This document explains what the `sp` command family is responsible for in the current project template.

Its role is not to replace the command templates themselves. It acts as the stable human-readable contract for:

- command naming
- workflow boundaries
- document outputs
- memory update responsibilities
- the allowed differences from upstream `Spec Kit`

## 2. Current Scope

The current `sp` workflow is a documentation-first workflow.

It deliberately stops at document analysis and preparation for later automation. It does not treat the current phase as a production-code workflow.

The active command set is:

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

Related upstream-shaped commands such as `implement`, `checklist`, or issue-export helpers may still exist in the broader template tree, but the core `sp` documentation contract above is the main path.

## 3. Command Naming

The visible step names stay in the `sp` namespace.

Two trigger forms are intentionally supported:

- command-style hosts: `sp.<command>`
- skill-style hosts: `sp-<command>`

Typical examples:

- Codex skills: `$sp-specify`
- Claude skills: `/sp-specify`
- slash-command hosts: `/sp.specify`

The command identity is the step itself, not the host-specific punctuation.

## 4. What Must Stay Aligned With Upstream

The current fork tries to stay close to upstream `Spec Kit` in mechanism shape:

- command templates live under `templates/commands/`
- templates use frontmatter metadata such as `description`, `scripts`, and `handoffs`
- `scripts` is installer/rendering metadata used to select the platform script and render `{SCRIPT}`; it is not a promise that every host will hard-execute frontmatter
- historical `agent_scripts` metadata is not part of the current runtime contract unless a real host context script is installed
- templates keep the `## User Input` block and `$ARGUMENTS`
- initialization is expected to happen through `specify init`
- platform shell selection still follows upstream `sh` and `ps` conventions
- project assets still center around `.specify/`, `templates/`, `scripts/`, and `specs/`

This is the "same bottle" part.

## 5. What Is Intentionally Different From Upstream

The fork changes the workflow content, not only the wording.

Allowed content-level differences include:

- added layered steps such as `flow`, `ui`, `gate`, and `bundle`
- a stronger documentation-first boundary
- feature memory and workset routing requirements
- richer analysis expectations
- `sp.analyze` being allowed to write `analysis.md` and refresh related memory when findings require it

This means behavior can differ while the outer mechanism still tracks upstream closely.

## 6. Standard Command Shell

The current command templates follow a stable outer structure:

1. frontmatter metadata
2. `## User Input`
3. optional pre-execution hook instructions
4. command title such as `# sp.specify`
5. `## Outline`
6. explicit goal, rules, execution flow, outputs, and completion checks

In practical terms, each command should make the model do four things clearly:

- read the right routing files first
- stay inside the current phase boundary
- update only the documents owned by the step
- expose missing inputs instead of inventing facts

## 7. Output Contract

### 7.1 Project-Level Outputs

Project-level routing and memory live under `.specify/`.

The current baseline expects:

- `.specify/memory/constitution.md`
- `.specify/memory/project-index.md`
- `.specify/memory/feature-map.md`
- `.specify/memory/domain-map.md`
- `.specify/memory/active-context.md`
- `.specify/memory/hotspots.md`

### 7.2 Feature-Level Outputs

Feature work lives under `specs/<feature>/`.

The full `sp` document system may include:

- `spec.md`
- `clarifications.md`
- `clarify-log.md`
- `gate.md`
- `bundle.md`
- `plan.md`
- `tasks.md`
- `analysis.md`
- `flows/*`
- `ui/*`
- `delivery/*`
- `memory/*`

Not every file is seeded up front by the template root. Some are created or expanded by later commands.

## 8. Command Responsibilities

### `sp.constitution`

- establish the project-level rules
- create the first routing layer
- define what must not be skipped later

### `sp.specify`

- create or refresh the baseline feature requirement document
- register the feature in project routing
- initialize the feature memory entry point

### `sp.clarify`

- resolve high-impact business ambiguities
- record answers and propagation obligations
- turn unresolved ambiguity into explicit tracked items

### `sp.flow`

- express the business and state transitions clearly
- connect major steps and decision points back to stable IDs

### `sp.ui`

- define screen structure, user actions, and interface-level responsibilities
- connect screens back to clarified business intent

### `sp.gate`

- judge whether the first layer is strong enough to continue
- surface blockers, risks, and stale information

### `sp.bundle`

- compress the stable first-layer conclusions for the delivery layer
- prepare the second layer to inherit the right facts instead of re-deriving them

### `sp.plan`

- organize delivery design outputs
- split the feature into worksets
- make later reading smaller and more local

### `sp.tasks`

- bind worksets and deliverables into an actionable documentation task set
- keep task boundaries aligned with the workset split

### `sp.analyze`

- test whether the whole document system is automation-ready
- verify consistency across the routed source set
- fail explicitly when memory is stale, coverage is weak, or smoke checks are missing

## 9. Read-Order Contract

The current commands are not allowed to jump directly into a full scan when routing files already exist.

Default read order:

1. `.specify/memory/project-index.md`
2. `.specify/memory/active-context.md`
3. `specs/<feature>/memory/index.md`
4. only then the smallest useful source documents for the active area

If the project-level route is stale, the command should mark it stale and continue from the freshest feature-level evidence.

## 10. Boundary Rules

All current `sp` commands should preserve these rules unless a later product decision changes them explicitly:

- stay within documentation work
- do not invent missing facts
- do not silently ignore stale routing
- do not treat memory as a replacement for source-of-truth documents
- do not redo full-project reading when a smaller routed read set is enough

## 11. PASS / FAIL Expectations

`sp.analyze` and related review-style steps must remain evidence-based.

A `PASS` is only justified when:

- routing is coherent
- the active feature is identifiable
- core documents are present and cross-consistent
- traceability is good enough for later automation
- stale memory, missing smoke checks, and major coverage gaps are not left open

If those conditions are not met, the correct result is `FAIL` with the exact blocking step to revisit.

## 12. Why This Reference Exists

This file exists so overview documents can point to a stable explanation of the `sp` command contract without forcing readers to open every command template one by one.

When command templates evolve, this reference should be updated to match the current mechanism and output contract.
