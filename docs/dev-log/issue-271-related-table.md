# Issue #271 — Fire's nine bodies reshaped to the `Related` table

**Issue:** [#271](https://github.com/Calyx-Engineering/arc/issues/271)  ·  **PR:** [#302](https://github.com/Calyx-Engineering/arc/pull/302)

## Problem

Eight of Fire's nine children carried a `Spawned` section, each holding a table. Seven of
those held **findings** — observations, limits, things noticed in passing — rather than units of
work; the eighth, #166's, held two filed issues, and #165 had no such section at all.
`skills/issue-write`
admits no `Spawned` section at all: a body has one `Related` table, three columns, and spawned
work is a row in it.

[#270](https://github.com/Calyx-Engineering/arc/issues/270) fixed the cause — `run-instructions.md`
told a run to record a discovery "in the issue's Spawned table" — and landed the
`hooks/tracker-verify` check that reports the heading. This issue reshapes the nine bodies that
were written before that.

## Intent and north star

| | |
|---|---|
| **What this issue is really for** | The tracker and the dev-log disagree about where a finding lives. Nine bodies are the evidence, and the fix is mechanical once the routing rule exists |
| **North star** | Nine bodies whose last section is one three-column `Related` table with the spawn rows on top, and twenty-nine finding rows recoverable from the dev-logs |
| **What makes it durable** | `hooks/tracker-verify`'s `scan_spawned_heading`, landed on #270, reports the next body written in the old shape |
| **Out of scope** | Every issue outside the nine. #269 needs the same reshape and #238/#239 need the return edge from #166 — both recorded below, neither done here. §5: a discovery is not permission to widen the unit |

## What changed

**Nine bodies.** Each `Spawned` heading and its table removed; each `Related` section rewritten
from the two-column `| Issue | Relationship |` shape to `templates/issue.md`'s
`| | Link | What it is |`, with `Spawned by` as the first row. #213 had no `Related` heading at
all — its edges were a `·`-separated prose line, which is a list wearing a list's clothes without
being one.

**Twenty-nine finding rows** moved verbatim into seven dev-logs under a new `## Findings` heading:
156 (4), 159 (4), 160 (3), 164 (5), 208 (4), 210 (3), 213 (6). Order preserved and byte-identical but for one character,
including #210's headerless `| | |` table shape. The exception is #160's marketplace path: the
body reads ``R:^Grc`` where it means ``R:\arc``, a backslash mangled before this run touched it.
Corrected in the dev-log, with the deviation named there.

**Three bare `Blocked by #NN` lines** — #156, #160, #165 — moved under the new table rather than
dropped. The driver greps for that line; the table cell does not match it.

## Decisions and trade-offs

| | |
|---|---|
| **#166's two rows are not findings** | [#238](https://github.com/Calyx-Engineering/arc/issues/238) and [#239](https://github.com/Calyx-Engineering/arc/issues/239) are filed issues, so they are units of work and become `Spawned` rows. That body is the one where the section's content stayed in the tracker |
| **Findings moved verbatim, routing column and all** | Some routing cells now point at their own container — *"Recorded in the dev-log"* read from inside the dev-log. Re-pointing twenty-nine cells is a rewrite of somebody else's record; the box says none dropped, not none touched |
| **#165 gained a `Spawned` row nobody asked for** | It was the one body with no findings to move. `#246`'s own body already carried `Spawned by #165`, so the edge existed from one end only — `skills/issue-write`, *the edge is written from both ends*. Found by pass 1 |
| **#164's dev-log already held three of its own findings** | Richer text than the body carried, under the dev-log template's `## Spawned`. Merged into one `## Findings` section, the verbatim five first and the three richer ones after, with a line saying which overlap. Two lists of the same findings in one file is worse than one list that names its own duplication |

## Rejected approaches

| | |
|---|---|
| **A new repo gate for the three-column shape** | `hooks/tracker-verify` already reports the heading and `tools/verify-tracker-body.sh body` already reports placement. A third instrument for a nine-row one-off is a tool nobody runs again |
| **Re-pointing every routing cell to its new home** | See above. It converts a verbatim move into an edit of twenty-nine judgements made by other runs |

## Evidence

| | |
|---|---|
| `tools/verify-tracker-body.sh body` | All nine reshaped bodies exit 0 — `Related` is the last section in each |
| `tools/verify-tracker-body.sh selftest` | 26 passed, 0 failed, exit 0 |
| `bash tools/verify-all.sh` | **42 gates PASS, 0 FAIL — the run did not reach its exit line.** Five worktree runs share this machine and the runner stalled inside a hook gate; killed rather than left holding `$HOME/.claude/HOOKS_OFF`, which was confirmed absent afterwards. Not a green claim |
| Gates not reached | Eleven, `verify-hook` among them — 42 run plus 11 unreached is the 53 `verify-all.sh --list` names. Ten read nothing this diff touches. **`activation log` does** — `tools/verify-activation-log.sh` reads `.claude/arc/log.md`, which the second commit grows by 4050 lines |
| Read-back of all nine live bodies | Identical to what was written, re-confirmed against the tracker after the last write. `Spawned` headings 0/9, three-column delimiter present 9/9, first row `**Spawned by**` 9/9, last section `Related` 9/9 |
| Finding-row counts, source against dev-log | 4·4·3·5·4·3·6 — twenty-nine, no difference |

## What the review passes found

**Pass 1** returned twelve findings. The ones inside this unit were fixed:

| | |
|---|---|
| **A framing preamble on all seven `## Findings` sections** | Each opened with a paragraph explaining what the section was — the shape #159 grades as a standalone `PREAMBLE` fail. Cut to the provenance sentence |
| **Three stale pointers at a table that no longer exists** | The 208, 210 and 183 dev-logs each cited *"#NNN's `Spawned` table"*. 208's was not merely stale but false — it named a table its own issue no longer had |
| **#164's duplicate findings list** | Above |
| **#165's missing `Spawned` row** | Above |
| **Two dropped lead-ins carried real content** | #213's *"a row saying needs an issue is a routing decision, not an action left undone by this run"*, and #208's provenance for its four. Both carried into the dev-log |

Pass 1 also reported the worktree as detached with no branch. It read
`.claude/arc/sessions.md`, which was written at session start and is stale by the time the branch
exists. `git branch --show-current` disagreed with it. **A sub-agent reading a status file is
reading a snapshot, and the pass has to say which of the two it read.**

**Pass 2**, in pass 1's own fixes — four of the five were defects pass 1 created:

| | |
|---|---|
| **A carried lead-in overclaimed** | #208's new sentence said all four findings came out of the review passes. Two are consequences of the issue's own decisions, and the file says so about itself two sections earlier |
| **#208 ended up with `## Spawned` and `## Findings`** | The first held *"none filed"* plus a shorthand restatement of the four the second carries in full. `templates/dev-log.md`: omit the section entirely when nothing was spawned. Removed |
| **#164's joining sentence pointed the wrong way** | *"These three"* sat above the table it named. Rewritten to say which table and where the rows came from |
| **This dev-log contradicted itself twice** | *"Eight of those sections held findings"* against its own seven-dev-log count, and a PR number written before the PR existed |
| **A moved row carried a corrupted path** | Pass 2 read it as introduced here. It is not — the same bytes are in the live body, so the move was faithful and the corruption predates it. Corrected anyway, because a verbatim copy of a broken path is still a broken path |

**The one pass 2 got wrong is the one worth keeping.** It reasoned that because ``R:^Grc`` is
absent from `HEAD`, this unit introduced it — but the row lived in the tracker, not the tree, so
`HEAD` was never going to hold it. **A pass comparing against `git` alone cannot review a change
whose source is the tracker**, and it has to say which side it could not see.

**Pass 3** audited the three boxes against the tree and unticked one:

| | |
|---|---|
| **#165's `Spawned` row was not in the tracker** | The write had been refused by the rate limit and the run had recorded it as fixed. Pass 3 read the live body and found the row absent. Landed afterwards through the REST endpoint and read back individually |
| **`gh issue view` is rate-limited where `gh api` is not** | Pass 3 found the REST path answering while every GraphQL call failed. That is what unblocked the #165 write |
| **The corpus count was invented** | *29 with `## Spawned`, 10 with `## Findings`* matched no measurement. Measured: 28 and 10 on this branch, 30 and 2 on `arc/04-dogfood` |
| **Two counting claims disagreed with each other** | Whether eight or nine bodies carried the section, and whether all of them held a table |

**Box 3 is the one pass 3 was right to press on.** The nine bodies were written in a loop and
read back in a second loop straight after — a read-back per batch, not per edit. The distinction
was not academic: #165's later single edit *was* read back individually, twice, and both times
the read-back returned the row absent. **That is the box working, and it is the only reason the
failed write was not shipped as done.**

## Findings

| Finding | Where it routes |
|---|---|
| **[#269](https://github.com/Calyx-Engineering/arc/issues/269) needs the same reshape** — it carries a `Spawned` heading and the kind words `Filed` and `Noted`, neither of which is one of the four | Needs an issue. Outside the nine |
| **#269's body now carries a false claim.** It says *"#213 has no `Spawned by` row"*; #213 gained one here | Same issue. The claim was true when written |
| **#166's spawn edge is one-directional.** [#238](https://github.com/Calyx-Engineering/arc/issues/238) and [#239](https://github.com/Calyx-Engineering/arc/issues/239) still carry the two-column table and no `Spawned by` row | Needs an issue. Outside the nine |
| **The `Routed` column was lost from #166's two rows.** Both said *"This arc — Fire"*; a three-column table has no cell for it. Recoverable from each issue's own milestone and parent | Recorded. Not a defect in the shape |
| **`## Findings` is a heading no artifact defines.** `templates/dev-log.md` defines `## Spawned`; `skills/record-route` says a created thing goes in *the dev-log's Spawned section*. The corpus is now split — of 102 dev-logs, 28 carry `## Spawned` and 10 carry `## Findings` on this branch, against 30 and 2 on `arc/04-dogfood`. #270 routed findings to the dev-log without saying which section receives them | Needs an issue. It is #270's other half |
| **#213's moved row disagrees with its own dev-log.** The row says fired runs scored 0.30–0.91 and non-fired 0.09–0.20; the tables in the same file say 0.36–0.91 and 0.09–0.27. Verbatim from the body, so the disagreement was already there — the move put both numbers in one file, where it is visible | Recorded. Not corrected: unlike the path, neither figure is decidably the typo |
| **A secondary GitHub rate limit is not the documented one, and it blocked this run's last step.** `gh issue edit` and `gh pr ready` return *"API rate limit already exceeded"* while `gh api rate_limit` reports every bucket at full. It outlived the documented reset — retried once past `reset` and refused again. **The REST endpoints kept working throughout**, which is what landed #165 and every body edit after it, but `markPullRequestReadyForReview` has no REST equivalent, so #302 could not be taken out of draft. Five worktrees share one token | Needs an issue. Every run in this arc writes to the tracker, and the arc runs five at a time |

## Retrospective

The mechanical half — strip a heading, rewrite a table — was done in one pass and read back
clean. Everything worth recording came from the review passes, and most of it was one class of
defect: a *reference* left pointing at something the move deleted. Three dev-logs cited a table
that no longer existed, #164's own body said *see Spawned*, one dev-log ended up holding the same
findings twice, and an issue outside the nine now makes a claim that this change falsified.

**The passes did not find the same thing twice.** Pass 1 found the dangling references, pass 2
found what pass 1's own fixes broke, and pass 3 found the one that would have shipped: a
`Spawned` row recorded as fixed while the write behind it had been refused. Three questions, three
different answers.

**Moving a section is not finished when the section has moved.** What makes it a defect rather
than untidiness is that each of those pointers reads as a live cross-reference — a reader follows
it and finds nothing, and cannot tell whether the record was lost or never written.
