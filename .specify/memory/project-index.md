# Project Memory Index

## Question Routing Matrix

| If The Question Is About... | Keywords | Recommended Feature | Read First | Next Hop |
| --- | --- | --- | --- | --- |
| project rules, phase boundaries, what is forbidden now | constitution, boundary, phase, scope, implement | project-level | `constitution.md` | `docs/sp-command-spec.md` |
| which feature to enter, what to read first, current smallest work area | active feature, read order, workset, smallest context | `attendance-leave` | `active-context.md` | `specs/attendance-leave/memory/index.md` |
| overall feature stage, gate verdict, readiness, workset count | stage, verdict, readiness, gate, analyze | `attendance-leave` | `feature-map.md` | `specs/attendance-leave/gate.md` or `specs/attendance-leave/analysis.md` |
| shared object, business domain, cross-feature consistency | domain, object, shared rule, ownership | `attendance-leave` | `domain-map.md` | `specs/attendance-leave/memory/stable-context.md` |
| repeated high-risk topics, rollback entry, where drift may happen | hotspot, risk, rollback, drift | `attendance-leave` | `hotspots.md` | `specs/attendance-leave/memory/open-items.md` |
| whether the sample pack proves query-first routing | sample pack, memory pack, routing example | `attendance-leave` | `specs/attendance-leave/memory/index.md` | `specs/attendance-leave/bundle.md` |

## Current Snapshot

| Key | Value |
| --- | --- |
| Project | `speckit-layered` |
| Stage | document-stage framework design |
| Active Feature | `attendance-leave` |
| Primary Workset | `WS-LEAVE-SIDE-EFFECTS` |
| Latest Gate | `PASS WITH OPEN QUESTIONS` |
| Latest Analysis | `PASS WITH RISKS` |
| Refresh Date | `2026-04-02` |

## Current Minimum Read Set

| Order | File | Why It Is In The Minimum Set |
| --- | --- | --- |
| 1 | `project-index.md` | first-hop routing |
| 2 | `active-context.md` | current feature and workset selection |
| 3 | `specs/attendance-leave/memory/index.md` | feature-level routing |
| 4 | `specs/attendance-leave/memory/open-items.md` | current risks and rollback entry |
| 5 | `specs/attendance-leave/memory/worksets/ws-leave-side-effects.md` | highest-risk bounded work area |

## Current Focus

| Topic | Recommended Entry | Why Now |
| --- | --- | --- |
| query-first memory pattern | `docs/sp-project-memory-architecture.md` | defines the project-level routing standard |
| sample feature verification | `specs/attendance-leave/memory/index.md` | proves the pattern on a real feature |
| current highest-risk work area | `specs/attendance-leave/memory/worksets/ws-leave-side-effects.md` | most likely drift point for later automation |

## Latest Summary

- Project-level and feature-level memory layers are both defined and linked.
- Current repository contains one end-to-end document-stage sample feature.
- Query-first routing, workset routing, and targeted clarify records are now part of the documented standard.
