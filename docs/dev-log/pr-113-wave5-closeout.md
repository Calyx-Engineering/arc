# PR #113 — Wave 5 close-out, and the branch-naming record

> Decision log, not a spec. Opened by `tools/new-direct-pr.sh` — **its first use in real
> work**, which makes this PR its own soak.

**Issue:** none  ·  **PR:** [#113](https://github.com/Calyx-Engineering/arc/pull/113)

## Problem

Wave 5 closed at [PR #104](https://github.com/Calyx-Engineering/arc/pull/104). Four no-issue
PRs and two out-of-arc issues have merged or been filed since, and the arc-log records none of
them. **The record stops where the wave stopped, and the work did not.**

## Intent and north star

**Pass 1 — what this is for.**

| | |
|---|---|
| **What this is really for** | Not "tidy the arc-log". A cold session reads §1, §10 and §12 to learn where the arc stands. Four merged PRs invisible in all three means the next window starts from a record that is confidently incomplete |
| **North star** | A session arriving at wave 6 can account for every merge in this arc from the arc-log alone, without reading git |
| **What makes it durable** | The findings, not the rows. The rows say *what merged*; §12.2 says *what the stretch proved*, and that is what survives into [#105](https://github.com/Calyx-Engineering/arc/issues/105) |
| **Out of scope** | Wave 6 itself. Closing the arc — [§14](../arc-log/arc-03-camp.md) is a checklist for later |

**Pass 2 — what changed.** Nothing moved the north star. One thing was found while writing:
**§12.3 still said *"Nothing here has run."*** That stopped being true when
`tools/new-direct-pr.sh` ran twice for real. Corrected in place — `tools/` is the one part of
this repository that actually executes, which is why the only genuinely soaked change in the
arc is a script.

## What this records

| | |
|---|---|
| §1 | A row for the post-wave stretch, so the one-minute read accounts for it |
| §4.2 | [PR #107](https://github.com/Calyx-Engineering/arc/pull/107), [PR #108](https://github.com/Calyx-Engineering/arc/pull/108), [PR #110](https://github.com/Calyx-Engineering/arc/pull/110) in the spawned tree, each with what caused it |
| §10 | The same three in the execution order, taking no step number — the order is frozen |
| **§12.2** | The stretch itself: the repeated correction that triggered it, why the rule was unreachable *and* unfollowable, and the three probes |
| §13 | Four soak lines, including the two that are real executions rather than by-hand |
| §14 | Two additions to the arc-close checklist — sweep the friction log, confirm [#105](https://github.com/Calyx-Engineering/arc/issues/105) and [#106](https://github.com/Calyx-Engineering/arc/issues/106) |

## Decisions & trade-offs

| | |
|---|---|
| **§12.2 leads with the friction, not the fix** | The rule was reachable-in-principle and unfollowable-in-fact, and both had to be said. A section that only listed what changed would lose why three sessions failed the same way |
| **The probes get their own table** | [PR #109](https://github.com/Calyx-Engineering/arc/pull/109) and [PR #111](https://github.com/Calyx-Engineering/arc/pull/111) each disproved something already written down as true. **That is the finding**, and it is the same one friction-log entry 1 records |
| **The no-issue PRs take no step number** | §10's order is frozen by a load-bearing decision. They are recorded with `—` in the step column, as [#73](https://github.com/Calyx-Engineering/arc/issues/73) and [#76](https://github.com/Calyx-Engineering/arc/issues/76) already are |
| **This PR was opened by the script it documents** | Not ceremony. The script had run once as a self-test on a throwaway; using it for real work is the difference between a passing test and a soak |

## Retrospective

**The stretch after wave 5 was worth more than most of wave 5.** It started from a repeated
correction — *"its still failing on you, so we have to change the rule"* — and ended with a
rule that is reachable, followable, drawn, and executable in one command.

Three things it proved, none of which came from reasoning:

| | |
|---|---|
| Renaming an open PR's branch **closes the PR** | It was about to ship as the preferred correction |
| A PR's `head` **cannot be changed** | The PATCH returns 200 and ignores the field — silent success, wrong result |
| The window claim was **aspirational** | *Seconds, not hours* was false by hand. Drawing it exposed that; the script made it true |

**Two of the three probes disproved documentation.** Both claims were plausible, both came from
reading rather than running, and both would have shipped. The cost of finding out was three
burned PR numbers.
