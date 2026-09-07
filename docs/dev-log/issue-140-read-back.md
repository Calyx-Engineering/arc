# Issue #140 — feat: read the work back against the issue before a PR

**Issue:** [#140](https://github.com/Calyx-Engineering/arc/issues/140)  ·  **PR:** [#219](https://github.com/Calyx-Engineering/arc/pull/219)

## Problem

The close sequence had nine steps and none of them read the work back. A section gets rewritten
correctly while other sections of the same file keep describing the old behaviour — every edit
succeeds, every gate passes, and the record is wrong. Observed in ROADZ (PR #67, four stale README
sections, 78 offline checks green) and here ([#17](https://github.com/Calyx-Engineering/arc/issues/17),
shipped missing two of five requirements).

## Intent and north star

| | |
|---|---|
| **What this issue is really for** | A step that tests the prose against the issue, performed by someone who did not write it |
| **North star** | A unit cannot reach its PR without every changed file having been read whole against the issue body, and every checklist box dispositioned |
| **What makes it durable** | It is a step in the document that owns the order, not advice. The step count is gated, so the next edit to the sequence cannot leave half the repo describing the old one |
| **Out of scope** | Any attempt to gate prose correctness mechanically. The constraint forbids it, and it is not checkable |

## Decisions & trade-offs

| | |
|---|---|
| **Ten steps, not `4c`** | A lettered sub-step would have kept the count at nine and cost nothing. Rejected: `4b` is a sub-step of *changes committed*, and hanging the read-back off it mislabels its owner and reads as optional. The issue's constraint anticipates the count moving — *adding a step is a deliberate edit to the document that owns the order* — so old 5–9 became 6–10 and every live citation moved with them |
| **The Note is settled: a sub-agent performs it** | The six open questions answered in `close-sequence.md` §*Who performs it* — it gets the issue body verbatim plus the files to read (changed files on pass 1, what the dispositions changed on pass 2), never a brief and never the whole repo; it returns findings, never edits and never a verdict; it runs twice per unit, never on a size threshold; it blocks nothing; and its cost is two dispatches whose context dies with them against two whole-file readings carried in the session for the rest of the unit |
| **Findings report, they do not block** | Same posture as every verifier in this repo. The session disposes each finding in the PR body, and a pass that returned nothing is recorded as having returned nothing |
| **`skills/issue-write` grew the carrier** | The constraint says the step is *confirmed in the PR body*, and the file that owns PR bodies had no section for it — asserted in one file and unimplemented in the file that owns it. Added as a `###` under *Body content*, with a `read-back-dispositions` token in `checks:` and a `skips:` condition for issue writes |
| **A gate for the count, never for the content** | `tools/verify-close-sequence.sh` checks only that the Closing table's row count matches every count claim in every live artifact. It cannot see whether a step's text is right — which is the whole reason step 5 exists |
| **History is not edited** | `docs/dev-log/`, `docs/arc-log/` and `pre-release-review.md` §7's run record still say nine steps and 8 gates. They record what was true when written; the gate excludes both log trees by path |

## Rejected approaches

| | |
|---|---|
| **A `verify-all.sh` gate on the read-back itself** | Forbidden by the issue's first constraint, and correct: prose truth is not mechanically checkable. 78 offline checks passed on the ROADZ change that motivated this |
| **A dedicated `agents/read-back.md`** | Not built. The step names a read-only sub-agent and the dispatch shape, which is enough to perform it; an agent artifact is a separate unit. Recorded in *Spawned* |
| **A size threshold before the agent runs** | The size would be judged by the session the step distrusts |

## What the passes found

The step was performed on its own unit — three dispatches, findings dispositioned below.

| Pass | Found |
|---|---|
| **1 — what the change broke** | 12 findings. Load-bearing: step 5's *Confirmed by* cell named a surface that does not exist yet at step 5; *two passes* and *one dispatch per PR* did not compose, so pass 2 had no performer; the PR-body carrier did not exist in `issue-write`; "Every step is already owned by an artifact" was made false by the new step; `skills/decompose` still said *the nine closing steps* with no reference to the file, so the gate could not see it; `CLAUDE.md` and `pre-release-review.md` still claimed gate counts this change moved |
| **2 — what pass 1 introduced** | 16 findings. The *It costs* row asserted the two passes were the same; the *It gets* row was true only of pass 1; the rewritten *Silence* sentence inverted its own referent; the new `issue-write` section landed under `## Titles` rather than `## Body content`; the gate had a dead filter, a stale example, and printed *agrees on ten* for files that state no count at all |
| **3 — the checklist against the tree** | All nine ticks stand, each quoted from the deliverable. Two contradictions left by pass 2's own fixes: *confirms each landed before naming the next* is false of a step confirmed at step 6, in both `close-sequence.md` and `skills/camp`; and *every step names who performs it* is false of step 1, whose cell names Camp, of whom the previous sentence says it performs none of them |

**Every finding above was found by a sub-agent reading files this session wrote.** None was
visible to the session from reading them again.

## Spawned

- **Issues:** none filed. Two items recorded in the issue's `Spawned` table — an `agents/read-back`
  artifact, and the dispatch-count divergence between `close-sequence.md` step 5 (two dispatches)
  and `docs/arc-work/04-dogfood/run-instructions.md` §2 (three), which belongs to the arc's own
  loop document rather than to this unit

## Retrospective

The sequence is ten steps. Step 5 reads every changed file whole against the issue body, in two
dispatches to a read-only sub-agent, and its findings are dispositioned in the PR body — the
carrier for which now exists in `skills/issue-write`. `tools/verify-close-sequence.sh` is the
tenth gate in `verify-all.sh` and holds the count invariant across every live artifact; it was
made to fail on four shapes before it was trusted — a stale citation, a line carrying both the
old and new count, a path with a space in it, and a heading that dropped its count.

**The unit is its own first soak.** The step found real defects in the work that created it,
including one — the missing PR-body carrier — that made the issue's own constraint unsatisfiable
as first implemented.
