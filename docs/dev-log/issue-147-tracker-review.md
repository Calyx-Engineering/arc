# Issue #147 — workstream: Tracker — write the record correctly

> Dev-log, not a spec.

**Issue:** [#147](https://github.com/Calyx-Engineering/arc/issues/147)  ·  **PR:** the review PR on `arc/04-dogfood-issue-147-tracker-review`

## Problem

Tracker closed twice — twelve children on 2026-09-09, six more on 2026-09-13 — and wrote §6.6 and §6.8. The user's review of Handoff's report set one report per workstream, a goal line, a before/after table naming its instrument, end state only, every Spawned row an issue. §6.6's Spawned table read *Dogfood, unattached* on five rows that have since closed; §6.8 was a second section.

## Intent and north star

| | |
|---|---|
| **What this is for** | The user closes Tracker in one read of §6.6 |
| **North star** | One §6.6 in the reviewed shape; §6.8 gone; nothing else in the diff |
| **Out of scope** | The children's work. #346, rolled to arc 05 and detached, is a Spawned row here and nothing more |

## Decisions & trade-offs

| | |
|---|---|
| Before/after rows read from `v0.1.0` and the live tracker | `checks:` 11 to 18 by `git show v0.1.0:hooks/tracker-verify`; case files 20 to 129 by `git ls-tree`; unlinked issues 47 of 102 to 9 of 106 by `tools/arc-link-sweep.sh Dogfood` run on 2026-09-13 |
| #305 routed *Dogfood, no workstream* | It has no parent and closed under Fire's fix; the row says where it is, not where it should have been |
| Four of §6.6's *Not done* items kept, two dropped | #84's label delete and `issue-write`'s two deferral sentences are done — #242 closed, the skill rewritten. The rest say where they went |
| The budget commit cherry-picked from the Handoff branch | The reviewed shape does not fit 200 words; the gate has to be green on this PR alone |

## Retrospective

The second closing's report had the numbers the first lacked — 136 cases, the live test for #287 — and the first had the routing the second lacked. One section holds both without repeating either.
