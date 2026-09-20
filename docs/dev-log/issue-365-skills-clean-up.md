# Issue #365 — scope: whether the skills need a clean-up at all

> Dev-log, not a spec. Started at plan time, finalised as a retrospective at PR time.

**Issue:** [#365](https://github.com/Calyx-Engineering/arc/issues/365)  ·  **PR:** [#367](https://github.com/Calyx-Engineering/arc/pull/367) — the first pass; the issue stays open

## Problem

[#275](https://github.com/Calyx-Engineering/arc/issues/275) chose a review method and
[#277](https://github.com/Calyx-Engineering/arc/issues/277)–[#281](https://github.com/Calyx-Engineering/arc/issues/281)
assume a clean-up is warranted. Nobody had run the tools over all thirteen skills and looked at
what they return.

## Intent and north star

| | |
|---|---|
| **What this issue is really for** | An answer to *is there anything to cut*, from tools, before five review issues spend a session each finding out |
| **North star** | Every reduction made is one where the rule demonstrably still exists somewhere a session will read it |
| **Out of scope** | Re-opening [`skill-method-decision.md`](../arc-work/04-dogfood/skill-method-decision.md) §4.1's deviations — settled by #275. Frontmatter that does not parse — [#338](https://github.com/Calyx-Engineering/arc/issues/338) owns it |

**Arc-intent: escalate, and the user said proceed.** Filed to Self-improvement as outside arc
04's stated intent; David moved it into arc 04 in chat, 2026-09-20 — *"we have the time now"*.

## First pass — the mechanical tools, 2026-09-20

Every number below is `measured` on this tree at `arc/04-dogfood` + #364's working changes.

| Tool | Result |
|---|---|
| `skill-creator`'s `quick_validate.py`, all 13 | **13 of 13 exit non-zero.** Eight on non-spec frontmatter keys — a kept deviation, §4.1. **Five still do not parse as YAML** — `camp`, `chat-response`, `engineering-report`, `handoff`, `record-route` — #338, unchanged since 2026-09-13 |
| `claude plugin validate skills --strict` | Passes all 13, including the five above. Still a precondition and not a review |
| `tools/verify-skill-length.sh` | **Two over 500 lines** — `issue-write` 867, `work-watch` 609 (file lines) |
| `claude plugin eval` | **Still refuses to run.** `--help` prints on Claude Code 2.1.263, which it did not on 2026-09-13, but one case on Haiku with a $1 ceiling and `--no-publish` returned *`plugin eval` is currently in early access*. `evals/` holds 50 `case.yaml` files in Arc's own schema, so whether the tool would read them is untested. **`--no-publish` matters when it opens:** the default publishes the report to claude.ai, and these cases quote ROADZ documents |
| Repeated text **within** a skill — 7-word shingles seen twice, fenced code excluded | **Under 2% in every skill**, and most of that is a repeated issue link. There is no verbatim repetition worth cutting inside any one skill |
| Repeated text **between** skills — same measure | **Two pairs carry a duplicated block; every other pair shares under 30 shingles** |

| Pair | Shared | What it is |
|---|---|---|
| `engineering-report` ↔ `record-route` | 199 shingles, ~45 lines each | The twelve-term provenance ladder, the [#164](https://github.com/Calyx-Engineering/arc/issues/164) photograph incident, *the order is the point*, the 2026-08-28 scope reading, and two of the three rules — stated in full in both |
| `relief-valve` ↔ `work-watch` | 156 shingles, ~40 lines | `work-watch` check 3 restated `relief-valve`'s opening quote, its threshold table, its *untracked work* section and its *cannot do* |

**The finding:** length here is not repetition. Twelve skills say each thing once. What remains
is whether each thing belongs in a skill at all — bucket E and bucket C in the method's terms —
and that is a reading, which is what #277–#281 are.

## Decisions & trade-offs

- **`work-watch` check 3 cut from 67 lines to 35.** `relief-valve` already holds every removed
  line, and check 3 already said `relief-valve` *is what this check runs*. Kept: the *watch
  for* table and the example nudge, which `relief-valve` does not have, and one sentence each of
  the shape and the closing, because check 7 cites both — *same shape as check 3*, *same
  closing as check 3*.
  `work-watch` is 577 file lines — still over.
- **The provenance ladder has one owner, `record-route` — David, 2026-09-20:** *"record-route
  would track the provenance and report would document it to the user. why not?"* The
  objection had been that a session writing a report loads `engineering-report` and not
  necessarily `record-route`. Answered by keeping the twelve words, in order, on one line of
  `engineering-report`, with the three report-side rules and the grader untouched. 41 lines →
  14; `engineering-report` is 404 file lines. One note existed only in the removed copy —
  `vendor`: *the seller's claim about the seller's part* — and moved into `record-route`'s row.

## What is left, and it is the larger half

| | |
|---|---|
| **`issue-write`, 867 file lines** | 367 over. Nothing in it repeats, so getting under 500 is a bucket-E move — the measured incidents (2026-08-17 base-branch isolation, #323, #192/#215, the three 2026-08-20 write-back failures) into m12 and m13, one citing clause left behind each. Not started |
| **`work-watch`, 577** | 77 over after check 3. Not read for bucket E yet |
| **The other eleven** | Under the limit. Read for improvement, not length — not started |
| **Five skills whose frontmatter does not parse** | [#338](https://github.com/Calyx-Engineering/arc/issues/338), unchanged |

## Retrospective

TBD at PR time.
