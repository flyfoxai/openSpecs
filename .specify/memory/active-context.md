# Active Context

## Current Goal And Minimum Read Set

| Key | Value |
| --- | --- |
| Current Goal | keep the document-stage framework query-first and ready for localized extension |
| Active Feature | `attendance-leave` |
| Primary Workset | `WS-LEAVE-SIDE-EFFECTS` |
| Highest Risk | approval side effects, notification policy, compensation semantics |
| No-Go Boundary | do not enter implementation and do not reopen full-feature scanning by default |
| Refresh Date | `2026-04-02` |
| Refresh Basis | `.specify/memory/project-index.md`, `specs/attendance-leave/memory/index.md`, `specs/attendance-leave/memory/open-items.md` |
| Source Of Truth | `.specify/memory/project-index.md`, `specs/attendance-leave/memory/index.md`, `specs/attendance-leave/memory/worksets/*` |
| Required Sync Files | `.specify/memory/feature-map.md`, `specs/attendance-leave/memory/index.md`, `specs/attendance-leave/memory/worksets/index.md` |
| Stale Trigger | active workset changes, highest-risk topic changes, minimum read set exceeds budget |

## Minimum Read Set

| Order | File | Why It Is Required |
| --- | --- | --- |
| 1 | `.specify/memory/project-index.md` | confirms project-level route |
| 2 | `.specify/memory/active-context.md` | confirms current smallest useful read set |
| 3 | `specs/attendance-leave/memory/index.md` | selects the active feature route |
| 4 | `specs/attendance-leave/memory/open-items.md` | exposes current risk and rollback |
| 5 | `specs/attendance-leave/memory/worksets/ws-leave-side-effects.md` | contains the current highest-risk bounded area |

## Workset Routing

| If You Need To... | Choose | Why |
| --- | --- | --- |
| refine employee submit or time-range validation | `WS-LEAVE-EMPLOYEE-SUBMIT` | contains apply-page fields, validation, and create API touchpoints |
| refine approve or reject decisions | `WS-LEAVE-MANAGER-APPROVAL` | contains approval scope, action rules, and rejection handling |
| refine list, detail, or withdraw | `WS-LEAVE-QUERY-WITHDRAW` | contains visibility, query filters, detail view, and withdraw boundaries |
| refine post-approval side effects | `WS-LEAVE-SIDE-EFFECTS` | contains the highest current risk around balance, notification, and compensation |

## Forced Clarify Flush Checkpoints

| When | Why |
| --- | --- |
| before `sp.gate` | route-level questions must not stay hidden in batch queues |
| before `sp.bundle` | stable bundle must not carry unresolved route conflicts |
| before `sp.plan` | delivery design must inherit a stable business frame |

## Current Highest-Risk Area

| Priority | Topic | Entry |
| --- | --- | --- |
| `High` | approval side effects and compensation semantics | `specs/attendance-leave/memory/worksets/ws-leave-side-effects.md` |
| `High` | timezone and field precision | `specs/attendance-leave/memory/worksets/ws-leave-employee-submit.md` |
