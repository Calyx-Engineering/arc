# Issue #167 — the arc-work path assumes a flat slug

> Decision log, not a spec. Started at plan time, finalised as a retrospective at PR time.
> Keep it short — capture the *why*, not a blow-by-blow. Skip any section that doesn't apply.

**Issue:** [#167](https://github.com/Calyx-Engineering/arc/issues/167)  ·  **PR:** &lt;link&gt;

## Problem

`templates/dev-log.md` and `templates/arc-log.md` both carry
`../arc-work/&lt;arc-slug&gt;/&lt;topic&gt;.md`. `tools/verify-template-links.sh` skipped any link
holding a placeholder — one line, `*'<'*|*'&lt;'*) continue` — so the `../` count was never
checked against where the template actually lands. Every other template link in the repository
was resolved; these were not, and a wrong one would have reported nothing.

## Intent and north star

| | |
|---|---|
| **What this issue is really for** | The half of a placeholder path that is *not* a placeholder is still a path, and it should be checked like one |
| **North star** | `verify-all.sh` exits 1 when an arc-work path does not resolve from where its template lands |
| **What makes it durable** | The slug is expanded against the tree rather than assumed to be one flat segment, so a nested slug resolves and a wrong `../` count does not |
| **Out of scope** | Whether `docs/scratch/` and `docs/report/` should exist in this repository |

## Decisions & trade-offs

| | |
|---|---|
| **The fixed half is checked, the placeholder half is expanded** | `../arc-work/` is a real path and `&lt;arc-slug&gt;` is not. The first is resolved from the template's destination; the second is satisfied by finding at least one real arc slug under that root. Both halves have to hold, and the second is what makes it a derivation rather than a prefix check |
| **A root with no arc slug is a failure** | Without it the check would pass on an empty `docs/arc-work/` and would only ever have proved that `..` was counted correctly. Case 4 is that case |
| **Only the arc-work path is derived** | The issue names arc-work, and arc-work is the one K2 directory this repository populates — three real slugs to expand against. `../scratch/` and `../report/` have the same shape and no instances, so there is nothing to derive them from. Scoped deliberately and recorded in *Spawned*, not swept |
| **It lives in `verify-template-links.sh`** | That script already owns "a template link resolves from where it lands", already has the destination MAP the derivation needs, and already takes `TEMPLATE_ROOT` — which is what let the selftest run the real script against fixture trees without inventing anything |

## Rejected approaches

| | |
|---|---|
| **Resolving the fixed prefix of every placeholder link** | The general form. It fails on `../scratch/` and `../report/`, which point at tiers this repository has never created — and the script's own header says it "cannot know whether a consuming repo has a `docs/arc-log/` yet". Applying it would have turned a template that is arguably correct into a red gate, and widened the unit past what #167 asks |
| **Deriving the slug from the branch name** | The arc slug is in the tree, not in the branch. Reading it from `arc/04-dogfood` would reintroduce the flat assumption one level up — a branch `arc/04/dogfood` would give the wrong answer, which is the defect this issue names |

## Evidence

| | |
|---|---|
| `bash tools/verify-template-links.sh selftest` | 6 passed, 0 failed |
| `bash tools/verify-template-links.sh` | exit 0 against the live tree |
| `bash tools/verify-all.sh` | 24 gates, all clean, exit 0 |
| **The Done-when, measured** | With `templates/dev-log.md` pointing at `../../arc-work/…`: `24 gates, 1 failed — template links`, exit **1**. Reverted after the measurement, `git diff` clean |

The live tree passing is not evidence the check can fail, which is the whole reason the selftest
builds trees that do. Cases 2, 3 and 4 are the three ways an arc-work path fails to resolve; case
5 is a nested slug, the shape the issue names; case 6 pins that the derivation is scoped.

## Spawned

- **Issues:** none filed.
- **Recorded, not fixed:** `../scratch/issue-&lt;N&gt;-&lt;slug&gt;/&lt;topic&gt;.md` and
  `../report/&lt;capability-slug&gt;/README.md` in `templates/dev-log.md` are the same shape with
  no instances in this repository to derive against. Noted on
  [#167](https://github.com/Calyx-Engineering/arc/issues/167).
