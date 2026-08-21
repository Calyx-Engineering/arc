# PR #130 — the arc close

> Decision log, not a spec. **No issue behind it** — the close is §14's checklist, not a unit of
> work someone scoped.

**Issue:** none  ·  **PR:** [#130](https://github.com/Calyx-Engineering/arc/pull/130)

## Problem

Arc 03 ran 25 numbered steps and eleven direct PRs, and shipped `v0.1.0`. The close is what turns
that into a record: §14's checklist, the soak table finished, the friction log swept, and the
default branch handed back.

## Intent and north star

### Pass 1 — from §14's checklist alone

| | |
|---|---|
| **What this is really for** | Not ticking boxes. **The arc-log is what a session six months from now reads instead of the transcripts**, and an unfinished close is a document that describes a plan rather than what happened |
| **North star (pass 1)** | Someone who was not here can read the arc-log and know what shipped, what it cost, and what is still not true |

### Pass 2 — after running the checklist

**Two items were wrong rather than undone.**

| | |
|---|---|
| **"Arc PR into `main` carries a `Closes` line for every issue" is obsolete** | It predates [m42](../product-architecture/mechanisms/m42-default-branch-flip.md)'s flip. With the default branch pointed at `arc/03-camp`, **every PR bound its own issue as it merged** — the milestone is 65 closed, 0 open, and the arc PR needs no closing keyword at all. The open thread about `verify-tracker-body.sh body` allowing exactly one keyword **was never the blocker it looked like**: nothing needs more than one |
| **Thirteen soak rows for waves 1–4 would be thirteen findings, not one fact** | Every one is unsoaked for the same reason — nothing here invokes a skill. One consolidated row says it once and names the two real exceptions |

**North star.** The arc-log reads as a record of what happened, its unfinished claims are stated as
unfinished, and the two obsolete checklist items are corrected rather than ticked as though they
had been satisfied.

## What the close found

| | |
|---|---|
| **The friction log's four entries are all resolved** | Two inside the arc, two by [m40](../product-architecture/mechanisms/m40-autonomy-switch.md). **Entry 4's *unfiled* is dropped rather than filed** — what it wanted was a durable switch, and that exists |
| **Wave 6 added the fact that closes entry 1** | One standing grant covered every merge of a whole issue. Every earlier success had needed an ask **per merge**, which is what *approval in one context doesn't extend to the next* predicted |
| **The four non-blocking review findings moved to *Self-improvement*** | They ship with `v0.1.0` and land later — the same treatment [#105](https://github.com/Calyx-Engineering/arc/issues/105) and [#106](https://github.com/Calyx-Engineering/arc/issues/106) got, and the reason the milestone can close |
| **`release-process.md` §4's order was wrong and is corrected** | It said *cut the tag, merge the arc, restore the default*. Tagging after the merge is right: the marketplace route resolves the **default branch**, so the tag and the default should be the same commit |

## Retrospective

*Written at PR time.*
