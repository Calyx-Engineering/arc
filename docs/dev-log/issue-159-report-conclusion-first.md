# Issue #159 — reports are written as narrative, not as conclusion

**Issue:** [#159](https://github.com/Calyx-Engineering/arc/issues/159)  ·  **PR:** [#224](https://github.com/Calyx-Engineering/arc/pull/224)

## Problem

Cluster C3 of the 2026-09 retrospective: reports, READMEs and one spec written as an account of
the exploration rather than as the current state of knowledge. Five post-install corrections.

`skills/engineering-report` has said *Findings first* since it was written. Nothing has ever
checked a document against it, and
[#155](https://github.com/Calyx-Engineering/arc/issues/155) recorded Fire-5 as **unmeasured** for
exactly that reason — the skill fired once in fifteen sessions, and no session has it firing
while a report stayed narrative. Until an instrument existed, *"fire it more"* was untested as
the remedy.

## What changed

| File | |
| --- | --- |
| `tools/report-grade.py`, `.sh` | Grades a report's **opening** — first line through the end of the first `##` section — as `CONCLUSION`, `NARRATIVE`, `DEFERRED`, `PREAMBLE`, or unscored. `--file` grades one document and exits on its verdict |
| `evals/report-shape/` | Three cases, each an excerpt copied verbatim from a real report in the ROADZ corpus, with the document and line range it came from. #164 added three more to the same suite |
| `evals/README.md` | A fourth suite, and why it is keyed by document rather than by session and turn |
| `skills/engineering-report/SKILL.md` | A new **The opening — conclusion first** section; the `description:` trigger clause rebuilt against #155 §1; a *No framing preamble* row in *Point of view*; a grader line in *Before finishing* |
| `tools/verify-all.sh` | The new selftest is a gate. 19 after merging the arc branch, all clean |

## The result

```text
opens with the conclusion        1/3  0.33
threshold                        0.67
verdict                          FAIL
```

| Case | Verdict | |
| --- | --- | --- |
| `cellular-recommendation-first` | `CONCLUSION` | Status header carries the decision, first section is *Recommendation*, nothing between them |
| `light-dimming-findings-first` | `PREAMBLE` | Everything right except one line — *"Findings and conclusions. The derivations are in the companion notes listed in §6."* |
| `poe-pse-question-first` | `NARRATIVE` | All three flags. *"Conclusion in Section 9"* on the status line, *"Investigation only"* below it, and `## Question` as the first section |

**The baseline fails, and that is the deliverable.** The three documents were written before any
of this existed. A passing number was reachable only by picking well-shaped documents or by
lowering the threshold; both produce a figure that means nothing. Fire-5 was *unmeasured* and is
now measured.

## Decisions and trade-offs

| Decision | Why |
| :--- | :--- |
| **A fourth instrument, not a fourth mode of an existing one** | The three that exist score a *reply* out of a transcript. A report is a file, edited over days, and the turn it was written on says nothing about the shape it ended in |
| **The case carries the excerpt, and the corpus is checked against it** | The other three suites cannot score at all without their transcripts. This one scores from `excerpt.md` anywhere, and when the corpus *is* present the excerpt is diffed against its source lines and a mismatch fails the run. Portability without dropping the verbatim claim |
| **The opening only. Nothing below the first `##` is read** | A conclusion in section 9 does not repair an opening. The reader who stops after the first screen never reaches it, and that reader is who the rule exists for |
| **`UNCLEAR` is reported, never guessed** | A first heading in neither class — *"Load switch rise time"* — could be a findings section named after its subject or a background section named the same way. Crediting it would score an unread opening as a pass. Same reasoning as `BOLDONLY` in `topic-numbering.py` |
| **The verdict is the worst flag, and every flag prints** | `NARRATIVE > DEFERRED > PREAMBLE`. Opening on the wrong section is a bigger failure than a spare sentence above the right one, and reporting only the worst would hide the other two on a document carrying all three |
| **A region that does not start at line 1 is `NOTOPENING`** | An excerpt cut from the middle of a document is evidence about a table or a section. Grading it for conclusion-first would score the absence of a status header — the part it simply does not contain — as a defect |

## Unplanned but needed

| | |
| --- | --- |
| **`--file`** | The skill now states a rule and names a grader. A check nobody can run against their own document is a check nobody runs, so `--file <path>` grades one document and its exit code *is* the verdict — the opposite of the suite's contract, which reports drift. Three selftests cover both directions and the missing-file case |
| **`NOTOPENING`** | Added when #164's cases entered the same suite. Without it, three excerpts cut from the middle of documents were being graded for an opening they do not contain, and two of them landed in the denominator |

## What testing the tests found

**The fixture line ranges were wrong and the drift check caught it.** Nine fixtures declared
`lines: 1-6` against files of seven to nine lines, so every clean run reported drift and left the
scorer exiting 1. The selftest asserted *"a clean run exits 0"* and went red — the drift check
doing its job on its own fixtures before it ever saw a real document.

**Three checks exist because a strict version would be unusable.** A `**Scope:**` line is the
status header §1 requires. A `> [!WARNING]` callout is a finding about how far results reach —
the PoE report's damaged-DUT caveat is the reason the skill has a safety section at all. A first
section named after its subject is not a background section. Each has a fixture, and the real
`cellular-recommendation-first` case would fail without the first of them.

## What pass 1 found

Four defects in this issue's half, all in `tools/report-grade.py`, all fixed here.

| | |
| --- | --- |
| **`UNCLEAR` short-circuited the fails** | The heading class was read before the deferred and preamble checks, so an unclassifiable first heading hid both. Take the skill's own advice — *"a first section named after its subject is fine"* — and a document with a pointer on its status line **and** a framing preamble scored `UNCLEAR` and exited 0. `DEFERRED` and `PREAMBLE` are now decided first: an unreadable heading says nothing about the two things that are visible whatever the heading is called |
| **The roman-numeral strip ate a leading I, V or X** | `^[0-9IVXivx]+\s*[.)-]*` matched with no separator required, so *Investigation* became *nvestigation*. **Investigation, Introduction, Intro and Verdict were all unreachable** — and *Investigation* is named in the skill's own list of failing shapes. A lookahead now requires a separator after the numeral |
| **A section headed `Status` scored `CONCLUSION`** | `status` and `state` were in the findings class. Removed |
| **The skill named four failing shapes and the tool could see three** | Development narrative — *"we first tried X, then found Y"* — had no pattern anywhere. `NARRATIVE_PAT` adds it as a `development-narrative` flag at the `PREAMBLE` tier |

**`--file` graded only the opening**, which mattered once #164 put two more columns on the same
tool: the skill pointed an author at a command that then said nothing about their tables. It now
grades all three and exits 1 on any of them.

## What pass 2 found — in pass 1's own fixes

**Pass 1's fixes were unreviewed code, and two of them made the tool worse than it had been.**

| | |
| --- | --- |
| **`--file` failed 116 of 120 markdown files** | Pass 1 widened it to grade tables and conflict over a whole file. Both are region-scoped by construction, and neither can tell a claim table from any other table. `README.md`, `CLAUDE.md` and the product definition all exited 1 — while `skills/engineering-report` named that exact command as its pre-commit check. **Only the opening gates now**; the other two print `LOOK` and exit 0 |
| **The development-narrative patterns were blind where it mattered and wrong where they fired** | `opening()` collects prose only until the first `##`, so the first section's body — where *"We first tried a linear regulator, then found the switcher was needed"* actually lives — was never scanned. In the few lines it could see it failed ordinary prose: *"At first glance the two adapters are identical"*, *"It turns out the PSE budgets by declared class"*. **Removed.** The skill names four failing shapes; the tool checks three and now says so |
| **`DEFERRED` fired on a cross-reference** | *"The findings in Section 3 are unchanged by this revision"* is a pointer to related work. `finding`, `findings`, `result` and `results` are out of that pattern; the four that name the answer itself remain |
| **Six of nine fixes had no fixture** | Reverting each left the selftest green. That is how a fix that made things worse got through. Ten fixtures added — the reorder, the numeral lookahead, `Status`, the cross-reference, half-sourced tables, `extrapolated`, a pipe inside prose, a fenced sample, a sentence about agreement, and an unreadable direction |

**The lesson is the one this arc keeps relearning.** A green gate constrains only what has a
fixture behind it. `verify-all.sh` was clean and 45 selftests passed while `--file` was unusable
on almost every document in the repository, because nothing tested `--file` against a real one.

## What the fixes themselves needed

**Commit attribution on the two pass-1 commits is wrong, and is recorded rather than rewritten.**
`6193a3c` carries seven changes and its message describes four; `7583fb3` describes
`grade_conflict`'s rewrite, `WEAKWINS`, the row exclusion and both matcher fixes, and touches no
file under `tools/` at all. Every fix named in either message is genuinely in the tree — pass 3
confirmed each one against current code — but the split between the two commits is not what the
messages say. Rewriting pushed history to tidy it would cost more than it buys; the record says
so instead.

## Hooks that fired

`mode-guard` read `HANDOFF.md` before the commit and allowed it — the worktree's row says
**Autonomous** until #159 and #164 merge.

## Retrospective

**The instrument answers a question the other three cannot, and it says so out loud.** Its own
output ends with *"A rate here is a property of the DOCUMENTS, not of a skill"* — because #155
settled that firing and adherence move independently, and a number that gets read as a skill
score would undo that finding.

**What it still cannot do.** There is no probe mode. `tools/response-length.sh --probe` and
`tools/skill-probe.sh` can re-run a turn against the installed plugin; a document cannot be
re-written on demand. So this suite measures history and will keep measuring history until a report is written
*with* the skill loaded and scored with `--file`. That is the soak, and it is the next report.
