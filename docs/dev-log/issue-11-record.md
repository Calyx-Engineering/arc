# Issue #11 — the record

> Decision log, not a spec.

**Issue:** [#11](https://github.com/Calyx-Engineering/arc/issues/11)  ·  **PR:** [#21](https://github.com/Calyx-Engineering/arc/pull/21)

## Problem

The dev-log and arc-log get written, not remembered. Without this there is no K1, and
everything downstream in pass 1 writes to it.

## Decisions & trade-offs

**The arc-log's waves and tracks are replaced, not tuned.** The spec named this as the open
question and the answer is that they go. A guided hardware arc has no waves and no parallel
tracks, and build order is discovered rather than planned. Two sections replace them: a
**tree** showing how scope actually grew, and a flat **status** table. Where a sequence
genuinely is known up front — as it is for this arc — that is a load-bearing decision, not a
wave.

**The dev-log gains Spawned; nothing else changes.** TimeScope's four sections survive
intact. The Spawned section is written as things are created rather than at PR time, because
a document nothing points at is a document nobody finds.

**`reference/knowledge-tiers.md` ships as a plugin artifact, not only as a spec.** Other
artifacts need something to link to that travels with the plugin. The spec in
`docs/product-architecture/mechanisms/` stays the design record; this is the shipped copy,
and it is a compression rather than a duplicate — it holds the routing rules a session needs
mid-work, not the reasoning behind them.

**Templates live in `templates/`, not inside the skill.** Both the record skill and (later)
`agents/camp` need them, and a template inside one skill's folder implies ownership that
does not exist.

## Rejected approaches

**Folding the routing table into the templates.** The template is copied into a file that
then lives forever; routing advice would be dead text in every dev-log ever written. Routing
belongs where the decision is made, which is the skill.

**One combined record template.** The arc-log and dev-log have different lifetimes and
different readers. Merging them recreates the single-deep-document failure the tier ladder
exists to prevent.

## Spawned

- **Arc log:** [arc-02-foundation](../arc-log/arc-02-foundation.md) — this arc's own K1, created by exercising the template
- **Arc work:** [closing keywords and the base branch](../arc-work/02-foundation/closing-keywords-and-base-branch.md)

## Retrospective

Shipped `skills/record-route`, `reference/knowledge-tiers.md`, and both templates. Both
templates were exercised on this arc's own work rather than on a fixture: the arc-log is
this arc's real K1, and the two dev-logs are this issue's and #10's.

**Exercising them surfaced the section that was missing.** The arc-log needed a *Related
analysis* section — the closing-keyword finding is arc-scoped K2, and without a pointer from
K1 a fresh session would never find it. That is the loading rule working as designed: K1
names what else matters, and a K1 file with no way to name it is broken.
