# Issue #260 — report-shape probe

`tools/report-shape-probe.sh` has the plugin as installed write a report from a fixed brief and
grades it with `tools/report-grade.sh --file`. It is the report-shape analogue of
`tools/skill-probe.sh`, and it exists because `evals/report-shape` cannot see a skill edit:
those six cases are frozen excerpts of documents the skill was never an input to.

The instrument works. The measurement it produced does not clear the bar #260 set, and the
reason is a conflict between the skill and the grader rather than a shape defect in the reports.

## The figures

Threshold 0.67, `claude -p` against the plugin installed from this tree, 2026-09-09.

| | opening | table source | conflict | n |
|---|---|---|---|---|
| Frozen suite — the baseline | 1/3 · 0.333 | 1/4 · 0.250 | 2/2 · 1.000 | six excerpts |
| Probe, before the skill edit | 2/2 · 1.000 | **1/3 · 0.333** | 3/3 · 1.000 | 3 |
| Probe, after | 1/1 · 1.000 | 3/3 · 1.000 | 2/3 · 0.667 | 3 |
| Probe, after — same plugin, re-measured | 4/4 · 1.000 | **3/6 · 0.500** | 4/6 · 0.667 | 6 |
| Probe, after — all nine runs | 5/5 · 1.000 | 6/9 · 0.667 | 6/9 · 0.667 | 9 |

`engineering-report` fired on all 12 billed runs, so every figure is a measurement of the skill
in context and not of a session that never loaded it. Cost: **$8.24 measured** — $2.043 for the
before side, $2.020 and $4.173 for the two after sides, each figure the sum of the `result`
lines. Two further runs were lost before the budget was raised; both were cut and neither
reported a cost, so what they spent is bounded by the 0.60 cap and not known.

The frozen suite is unchanged and cannot move. It is a property of six documents on disk, which
is exactly why it could not answer #260's question and why both figures are recorded together.

## What the before side found, and what the skill edit did about it

The before side's claim tables were sourced in all three runs. What scored `NONE` was a
**second** table — a two-row margin comparison derived from the rows above it, with no source
column. `grade_tables` returns the worst table in the document, so a perfect claim table beside
an unsourced derived one reads `NONE`.

Three edits to `skills/engineering-report`, all in place:

| | |
|---|---|
| A rule row naming the derived table | The margin table, the comparison, the summary. A derived number is still a claim |
| *How it is scored* | Now says the worst table in the document is the verdict |
| *Before finishing* | "Count the tables, not the table" |

The table column moved from 1/3 to 6/9 across all nine after runs. Real movement, still short of
the bar.

## The finding: the skill mandates a table the grader fails

Every remaining `NONE` on the after side has the same shape. `skills/engineering-report` makes
the confidence split mandatory and *Not established* is written as a table —
`| Open point | What would settle it |` — with no provenance column, because the rows are open
questions rather than sourced claims. `grade_tables` cannot tell a claim table from any other
table, and its own docstring says so.

| Run | Claim table | What scored `NONE` |
|---|---|---|
| after-run1, n=6 | 9 rows, all sourced | `Open point / What would settle it`, 6 rows |
| after-run5, n=6 | 8 rows, all sourced | `Configuration / Rail minimum / Margin`, 2 rows |
| after-run6, n=6 | 8 rows, all sourced | `Open item / What would settle it`, 7 rows |

`after-run1` verbatim, so the claim is checkable without the billed session. The grader:

```
  opening        CONCLUSION
                 first section: Findings  [findings]
  table source   NONE        4 of 6 row(s) name a source
  conflict       RESOLVED    in play: measured, datasheet, vendor, conversation
                 asserted over the rest: measured
```

Its two tables, first rows only. The nine-row claim table carries the column the skill asks for;
the six-row *Not established* table is the one that scored:

```markdown
| Claim | Value | Provenance |
|---|---|---|

| Open point | What would settle it |
|---|---|
```

The skill instructs authors to write the table that fails the check the skill points them at.
Filed as [#314](https://github.com/Calyx-Engineering/arc/issues/314). It was not fixed here:
#260's constraint fixes the grader, and adding a provenance column to a structure the skill
mandates for unrelated reasons, in order to move a score, is the reshaping that constraint
forbids.

## The second finding: n=3 is not a measurement

The same installed plugin, the same brief and the same grader gave the table column **1.000 at
n=3 and 0.500 at n=6**. Nothing between the two sides changed. Three runs cannot tell those
apart, so a three-run side is a smoke test and not evidence for a claim against a threshold —
recorded in the tool's own header, where the next operator reads it before choosing `--runs`.

`--runs` defaults to 1, which is right for checking the instrument is alive and wrong for every
other purpose.

## The third finding: 0.67 rejects two out of three

`2/3`, `4/6` and `6/9` all printed `FAIL`. `0.67` is the repo's shorthand for two out of three
and `2/3` is `0.6666…`, so `>= 0.67` rejects the ratio the constant was named for. The same
comparison is in `tools/report-grade.py:715` and `tools/skill-probe.sh`, so this is a repo-wide
convention rather than a defect in the new tool, and it was not changed here — #260's constraint
forbids moving the threshold, and quietly adding a tolerance to pass a suite is the same act.
Filed as [#315](https://github.com/Calyx-Engineering/arc/issues/315).

## Design decisions

| | |
|---|---|
| **The session writes a file; the reply is not graded** | A `-p` reply carries a conversational wrapper — *"Here is the report:"* — which scores as `PREAMBLE`, one of the three shapes being measured. Telling the model not to write a preamble contaminates the preamble flag. A file written by `Write` has no wrapper |
| **The brief is chronological and names no section** | A brief already in report order scores `CONCLUSION` whether the skill loaded or not. The brief supplies raw material; the skill supplies shape. Any shape instruction in the brief is the probe grading its own prompt |
| **The grader is called, never re-implemented** | `report-grade.sh --file`, with the three printed verdicts read off it. A second copy of the scoring rules would have broken #260's constraint on the first drift |
| **All three columns score, not only the opening** | `--file`'s exit code is the opening alone, which is right for an author's pre-commit check — over a whole file the other two are noisy, and a check that fails on every document gets turned off. A probe is not that check, and the brief was built to put material in all three columns |
| **A column with no denominator prints `not scored`** | Never `0/0`, never gating. The grader's own rule for `TABLE`, `ONESIDED` and `UNCLEAR`, and `skill-probe.sh`'s for a case that measured no runs |
| **Exit 0 or 2, never 1** | The threshold colours the printed verdict; it is not the exit code. Shape is a model decision and a rate is a reading, not a gate — `skill-probe.sh`'s convention |

## Two defects the probe found in itself, both billed to find

| | |
|---|---|
| `RSP_BUDGET` was 0.60 | Borrowed from `tools/response-length-probe.py`, where it is a **per-turn** budget. Here one run is a session that loads a 400-line skill and writes a page of markdown; 0.60 killed both attempts of the first before side with `error_max_budget_usd`. Now 3.00, and measured runs cost $0.64–$0.81 |
| A cut run's report was kept under the side's name | `error_max_budget_usd` arrived **after** the session had written a complete report. Nothing here can tell a finished document from one the budget stopped mid-sentence, so the run is correctly not a measurement — but the file it left made the loop's overwrite guard refuse the re-run, and the side could not be measured again without deleting files by hand. A cut run's report now lands at `<name>.cut` |

Both are `keep()` and `unusable()`, which bill nothing, so both are now pinned by
`python tools/report-shape-probe.py selftest` — 10 cases, beside the loop's 32.

## Gates

`bash tests/verify-all.sh` — 60 gates, all clean, exit 0. Two of them are this issue's:

| | |
|---|---|
| `report shape probe cases` | `python tools/report-shape-probe.py selftest` — 10 cases |
| `report shape probe loop cases` | `bash tools/report-shape-probe.sh selftest` — 32 cases |

One review pass observed `a runner that never spoke claims no retry` fail once, inside a full
suite it was running concurrently with a standalone copy of the same selftest. Not reproduced:
five consecutive standalone runs and a full `tests/verify-all.sh` both came back clean, and the
case's path is deterministic — a runner that exits non-zero never enters the branch that sets
`RETRIED`. Recorded rather than dismissed, because a selftest that fails once under load and
never again is the shape that gets explained away twice before it is diagnosed.

The loop's selftest grades its canned reports with the **real** `tools/report-grade.sh`, so a
drift between the verdict strings the probe classifies and the ones the grader prints fails the
gate rather than silently mis-scoring a billed side.

Neither gate bills. The live run is excluded for the same reason every other probe's is, and
`tests/verify-all.sh --list` says so under *the SHAPE of a report against a CHANGED skill*.

## What is not covered

- No gate here opens a session, so nothing checks that the brief still elicits material in all
  three columns. A model that stopped writing tables would show as `not scored`, not as a failure
- `WEAKWINS` and `UNREADABLE` are reported by the grader and scored in neither column, so a run
  that asserts a weak source out loud passes through the conflict column without a denominator
- The probe sessions inherit this machine's `SessionStart` hooks and their injected instructions.
  Both sides carry them equally, so the comparison holds; an absolute figure from another machine
  will not match
