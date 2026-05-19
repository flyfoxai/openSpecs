# `sp` Context Memory Architecture

## 1. Purpose

The `sp` workflow adds a memory layer so the model does not need to re-read or re-derive the whole feature on every step.

This memory layer is meant to reduce token waste, reduce drift, and make bounded local work possible.

## 2. Core Principle

Memory is a routing and compression layer.

It is not the final source of truth.

Source-of-truth documents still include the active feature documents such as:

- `spec.md`
- `clarifications.md`
- `flows/*`
- `ui/*`
- `gate.md`
- `bundle.md`
- `plan.md`
- `delivery/*`
- `tasks.md`
- `analysis.md`

Memory exists to answer one question quickly:

"What is the smallest correct set of files I should read next?"

## 3. Two Memory Layers

### 3.1 Project-Level Memory

Project-level memory lives under `.specify/memory/`.

Its job is to answer:

- which feature is active
- which domain or hotspot matters
- what the current smallest read set should be
- where the first routing jump should go

The current baseline uses:

- `constitution.md`
- `project-index.md`
- `feature-map.md`
- `domain-map.md`
- `active-context.md`
- `hotspots.md`

### 3.2 Feature-Level Memory

Feature-level memory lives under `specs/<feature>/memory/`.

Its job is to answer:

- which local area is relevant
- which workset should own the next action
- which facts are already stable
- which open items or stale areas still block reuse

The current intended structure includes:

- `index.md`
- `stable-context.md`
- `open-items.md`
- `trace-index.md`
- `worksets/index.md`
- `worksets/ws-*.md`

## 4. Query-First Routing

The memory system is designed around query-first routing.

That means a command should try to route first and expand second.

Default sequence:

1. read `.specify/memory/project-index.md`
2. read `.specify/memory/active-context.md`
3. choose the active feature
4. read `specs/<feature>/memory/index.md`
5. read only the needed local memory files
6. expand into source documents only for the active target area

This avoids whole-project re-scans when the task only touches one feature or one workset.

## 5. Stable Context vs Open Items

The memory layer separates stable facts from unstable questions on purpose.

### `stable-context.md`

Should contain facts that later steps should normally reuse instead of re-deriving:

- stable scope boundaries
- key actors and owners
- confirmed stage ordering
- durable object relationships
- settled high-level business rules

### `open-items.md`

Should contain what is still unresolved or risky:

- open clarifications
- blocked areas
- stale propagation
- conflict flags
- recommended fallback or revisit step

If a fact is still disputed, it belongs in `open-items.md`, not in the stable layer.

## 6. Trace Index and Worksets

### `trace-index.md`

This file exists so the model can jump across documents through stable IDs instead of re-inventing the chain each time.

Typical chains include:

- `FLOW-*`
- `SCREEN-*`
- `UC-*`
- `API-*`
- `TABLE-*`
- `ACC-*`

The file should support both forward tracing and reverse lookup.

### `worksets/*`

Worksets are the local working surfaces for a larger feature.

They matter when:

- the feature is too broad for one prompt window
- different sub-areas need different local read sets
- the model must stay inside one bounded slice

Each workset should make four things obvious:

- what is in scope
- what is out of scope
- what the minimum read set is
- what counts as done for that slice

## 7. Freshness and Stale Detection

The memory system only saves tokens if it stays fresh enough to trust for routing.

Memory should be treated as stale when:

- source documents changed but memory was not synced
- project-level routing points to the wrong feature
- trace links no longer match the current feature docs
- a clarification changed but the downstream sync never finished

When stale memory is found, the command should:

1. mark the stale area explicitly
2. expand only the smallest relevant source set
3. refresh the affected memory files before finishing

## 8. Clarification Propagation

`sp.clarify` is not just a Q and A record.

It is also the trigger for downstream sync.

Once a clarification becomes stable, the correct order is:

1. update the source-of-truth document first
2. update the required synced documents
3. refresh the impacted memory files
4. close the clarification only after propagation is done

If propagation is incomplete, the affected memory must be treated as stale.

## 9. No-Reinfer Rule

The memory architecture exists to stop repeated inference on already-settled topics.

If a stable conclusion is already fresh and queryable in memory, later steps should normally reuse it rather than rebuild it from scratch.

Re-inference is justified only when:

- the memory entry is missing
- the memory entry is stale
- the target cannot be mapped cleanly
- the source-of-truth document changed

If a command does re-derive something, it should write the refreshed conclusion back into memory before finishing.

## 10. Template Seed vs Runtime Expansion

The template project seeds the memory system, but it does not fully populate every feature-level file up front.

In practice:

- project-level memory files are present in the template root
- feature-level memory is initialized and expanded by the `sp` commands
- later commands enrich `trace-index.md`, `worksets/*`, and related routing material as the feature matures

This is expected. A partially seeded tree is not a bug by itself.

The real quality bar is whether the commands keep the memory layer synchronized as work progresses.

## 11. Minimum Read-Set Goal

The whole architecture is aimed at shrinking default context.

A healthy run should usually be able to answer:

- which feature is active
- which workset is relevant
- which 3 to 7 files should be read first

If the system keeps forcing full rescans, then the memory layer exists on paper but is not doing its job.

## 12. Why This Reference Exists

This file gives the project template a stable explanation of the memory model that the overview docs can point to.

When routing rules, freshness checks, or workset expectations change, this reference should be updated along with the command templates and seeded memory files.
