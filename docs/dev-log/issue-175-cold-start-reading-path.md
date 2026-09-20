# Issue #175 — fix: the cold-start reading path is 490 lines, one stale

> Dev-log, not a spec. Started at plan time, finalised as a retrospective at PR time.

**Issue:** [#175](https://github.com/Calyx-Engineering/arc/issues/175)  ·  **PR:** none yet

## Problem

`ROADMAP.md` was last touched 2026-08-21 and does not know arc 04 exists. Three documents still
named it the authority on what gets built next.

## Intent and north star

David, 2026-09-20: *"#175 lets do that one real quick - retire the roadmap."*

| | |
|---|---|
| **What this issue is really for** | One answer to *what moves next*, held in one place |
| **North star** | No document a cold start is pointed at contradicts the arc-log |

## Decisions & trade-offs

| | Decision | Why |
|---|---|---|
| **Maintained, folded in, or retired** | **Retired** — his word | The arc-log already holds the current arc's intent, decisions and status. A second document holding the same thing is the drift arc 04 is about — the issue's own first constraint |
| **Deleted or kept** | **Kept, frozen**, at `docs/release/roadmap-2026-08.md`, under a status line saying it is retired and unmaintained | The issue's second constraint: *do not delete the roadmap silently — it carries deferred work and spec gaps that exist nowhere else.* Those are its *Deferred, needing an interview* and *Spec gaps* sections |
| **What replaces it as the authority on sequence** | The current arc's arc-log and the tracker's milestones | Both already exist and are already current. Nothing new to maintain |
| **Its relative links** | Repointed for the new location | A frozen record with dead links is a record nobody can follow |

## What changed

| File | Change |
|---|---|
| `ROADMAP.md` → `docs/release/roadmap-2026-08.md` | `git mv`, a retired status line, links repointed |
| `CLAUDE.md` *Start here* | *There is no roadmap*, where it said #175 would decide |
| `README.md` · `docs/product-architecture/README.md` (two places) | *What lands next* points at the arc-log and the milestones |
| `tools/plugin-reload.sh` | Its list of top-level files a reload may ignore drops `ROADMAP.md` and gains `LICENSE`, which #320 added and the list did not know. `measured` — selftest 46 pass |

One mention is left on purpose: `tools/hook-cases/branch-guard/pass/arc-branch-markdown.json` uses
the filename as an arbitrary markdown path. It tests the hook, not the roadmap.

## The cold-start half — the other two boxes

**The reading path already existed and was not the one `CLAUDE.md` named.** `skills/handoff` says
*read `HANDOFF.md` first, before anything else*, then this file, the arc-log, the dev-log, and only
what those name. *Start here* said *read the product definition first, every cold start* — 317 lines,
whole, and in contradiction with the skill. David, 2026-09-20: *"what must cold start read - handled
by updated `/handoff` right?"* It was, everywhere but here.

| Box | Done by |
|---|---|
| *Establish what a cold start must read, and cut* Start here *to that* | *Start here* now names `skills/handoff`'s path and nothing else; the product definition is opened when the work asks what Arc is made of, never read whole |
| *The product definition says which of its sections a cold start needs* | Four rows at its top: the question, and the one section or row that answers it |

The third box — *if maintained, it carries the current arc* — is moot: it was retired.

**Why one issue held both halves:** it was filed as *the reading path is 490 lines, one stale* — the
roadmap was the stale one. Two subjects sharing a symptom, not a deliverable.

## Retrospective

TBD at PR time.
