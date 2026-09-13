# Issue #314 — the confidence split's table graded as an unsourced claim table

`skills/engineering-report` makes the confidence split mandatory, and its third group — *Not
established* — is written as a table of open questions, each with what would settle it.
`tools/report-grade.py`'s `grade_tables` read every table in the file and returned the worst, so
that table scored `NONE` and dragged a document there while the claim table beside it was
perfect. Measured on [#260](https://github.com/Calyx-Engineering/arc/issues/260)'s probe: three
of nine after-runs read `NONE` with a fully sourced `Provenance` claim table and an
open-questions table carrying none.

## The decision

The grader moves, not the skill. #260's own dev-log had already ruled out the column: adding a
`Provenance`-shaped column to *Not established* would source *why an item is unsettled*, which
is not what the group is for — it reshapes a structure the skill mandates for an unrelated
reason, in order to move a score, which is the exact thing #260's constraint forbids.

## The fix

`tools/report-grade.py`'s `tables()` now tracks the nearest markdown heading above each table
(any level, carried forward past blank lines and prose until the next heading). `grade_tables`
excludes any table whose heading matches `not established` from claim-table scoring — a new
`OPEN` verdict, not scored, on the same footing as `TABLE` and `NOTABLE`.

Matched on the **heading text**, never the table's own column names. Real reports write this
group under several headers — `Item`, `Unknown`, `Open point`, `Open item` — and #314 exists
because three of those variants still tripped the old column-based reading. The heading is the
one thing `skills/engineering-report` fixes the name of, so that is what is matched.

## Evidence

A real excerpt —
`docs/report/issue-01-warning-light-dimming/analysis-night-detect.md` lines 120-159 in the
`roadz-sound-system` corpus, the document's own `## Confidence` section — scored `NONE` before
the fix (its only table is *Not established*, six rows, none naming a source) and `NOTABLE`
after, since the region now has no claim table in it at all. Filed as
[`evals/report-shape/night-detect-not-established`](../../evals/report-shape/night-detect-not-established).

Two selftest fixtures in `tools/report-grade.sh` pin the mechanism directly:

| Fixture | Shape | Verdict |
|---|---|---|
| `provopennone` | The open-questions table alone | `NOTABLE` |
| `provopenbeside` | A sourced `Provenance` table beside an open-questions table — #314's exact reported shape | `ROWS`, not `NONE` |

`bash tools/report-grade.sh selftest` — 71 → 73 cases (two added), all green.

## Re-measurement — box 3

`tools/report-shape-probe.sh --label after314 --runs 3`, same installed plugin (the skill is
unchanged — this issue fixes the grader, not the skill). `n=3`:

| | rate |
|---|---|
| opening | 3/3 · 1.000 |
| table source | 3/3 · 1.000 |
| conflict | 3/3 · 1.000 |

Cost $2.135. All three runs wrote *Not established* as bullets rather than a table this time —
model variance, not a re-run of #260's exact defect — so this side does not itself exercise the
new `OPEN` path; the two selftest fixtures above pin that mechanism deterministically instead.
`n=3` is a smoke test, not a claim against the threshold — #260's own finding about sample size,
restated rather than re-earned here.

## Review pass 2 found a real edge case in the new code

The heading tracker in `tables()` ran its ATX-heading regex on every line before checking
whether that line was actually a table header row. A header row whose first cell is itself a
bare `#` — `| # | What would settle it |`, an ordinary row-number column — matched the heading
pattern too, silently overwriting the tracked `Not established` heading with the row's own
text and reintroducing #314's exact defect on that table (and on every later table in the
section, since a heading is carried forward until the next one). Reproduced directly, then
fixed: table-header detection now runs first, and the heading regex only runs on a line that is
not one. The same pass also caught the inline heading regex tolerating no leading whitespace
where the file's own `HEADING` constant (used by `grade_opening`) tolerates up to three spaces
per CommonMark — `tables()` now reuses that constant instead of a second, looser one. Both
fixes verified against a reproduction and the full selftest suite, still 73 green.

## Gates

`bash tools/report-grade.sh` (frozen suite, `--strict`) — no drift, corpus verified, exit 0.
`bash tools/report-grade.sh selftest` — 71 → 73 cases, 0 failed.
`bash tests/verify-all.sh` — run as part of this batch; see #315's dev-log for the combined gate
output, since both issues land in one PR.
