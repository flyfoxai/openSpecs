---
name: sp-analyze
description: Run the document-stage `sp.analyze` step. Trigger with `$sp-analyze`.
---

# sp-analyze

Use this skill when the user wants to verify whether the full document system is strong enough for later automation.

Global rules:
- Stay within documentation work only.
- Reuse existing project context and active feature state.
- Do not write production code.
- If `.specify/memory/project-index.md` exists, read it first and use it as the project routing entry.
- If `.specify/memory/active-context.md` exists, use it to pick the current smallest useful read set.
- If `specs/<feature>/memory/index.md` exists, read it first and use it as the feature routing entry.
- Expand to source documents only for the current target area.
- If required inputs are missing or unstable, stop and report the gap explicitly.

## Purpose

- Verify whether the document system is actually strong enough for later automation, rather than only looking complete on paper.

## Read First

- Read project-level `.specify/memory/*` routing files first.
- Read feature-level `memory/*` routing files next.
- Read first-layer and second-layer core outputs for the active feature.

## Do

- Check consistency across `spec.md`, `clarifications.md`, `flows/*`, `ui/*`, `gate.md`, `bundle.md`, `plan.md`, `delivery/*`, and `tasks.md`.
- Verify coverage of IDs, owners, states, screens, APIs, tables, permissions, and acceptance paths.
- Report conflicts, stale memory, missing links, or weak spots explicitly.
- Record the result in `analysis.md`.
- Refresh memory when analysis stabilizes or invalidates important facts.

## Do Not

- Do not write production code.
- Do not invent missing facts.
- Do not mark PASS when major gaps, stale memory, or missing smoke checks remain.

## Output

- Create or update `specs/<feature>/analysis.md`
- Refresh related `memory/*` entries when findings change routing or stable context

## Check Before Finish

- Confirm findings are evidence-based and traceable to current documents.
- Confirm PASS or FAIL is justified explicitly.
- Confirm the next blocking actions are clear.

## Next

- If PASS, the document set is ready for later implementation work outside this workflow.
- If FAIL, point to the exact `sp.*` step that must be revisited.
