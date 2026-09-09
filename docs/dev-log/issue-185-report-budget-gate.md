# Issue #185 — the boundary report's word budget is not checked

> Dev-log, not a spec.

**Issue:** [#185](https://github.com/Calyx-Engineering/arc/issues/185)  ·  **PR:** [#256](https://github.com/Calyx-Engineering/arc/pull/256)

## Problem

The boundary report has a 200-word budget and nothing counted it. Loop's first report was 302
words; the user caught it. The same boundary closed [#144](https://github.com/Calyx-Engineering/arc/issues/144)
the moment its children closed, which buried the report in a closed issue.

## Intent and north star

| | |
|---|---|
| **What this issue is really for** | The budget was written down in three documents and read by none of them. That is this arc's subject reproduced inside the arc's own instructions |
| **North star** | A run learns from an exit code, before the report is posted, that it is over budget — and learns the number, not that something is wrong |
| **What makes it durable** | The counter has to agree with the rule as written rather than invent one. `run-instructions.md` §6.2 already excludes the diagram; a checker that reinterpreted that would fail correct reports and teach writers to ignore it |
| **Out of scope** | Grading a report's SHAPE — sections, order, lists where lists belong. `tools/report-grade.sh` has that, on its own corpus. Checking a report's self-declared word count against the counted one: that number is a hand count, and failing a report over a tokenisation difference is a finding about tokenisation |

## Decisions & trade-offs

| | |
|---|---|
| **The counting rule was derived from the reports, not invented** | The three written reports declare 199, 200 and 200. A rule was measured against them until it returned the same numbers to within a few words — 195, 186, 194 — which is what makes it the rule they were written to rather than a second, competing budget |
| **Structure first, words second** | `keep_lines` decides which lines hold prose while `#` and `*` still mean something; `to_words` then flattens, which destroys exactly those characters. One pass could not do both |
| **The diagram is found by heading depth, not by its number** | `### 6.7 Upkeep — boundary report` is a report whose own number ends in 7. Matching the digit alone latched the exclusion on the region's first line and scored that whole workstream at zero — a report that could never fail. Arc 04 reaches 6.6; the next arc reaches this |
| **The exclusion is released at the next heading of the same depth** | Section 7 is last in a well-formed report, so the release never fires there. Where the `*End of ...*` line is missing, the region runs to the next report or to EOF, and a latch with no release would hand everything after the diagram to the writer free |
| **A malformed frame is reported, never quietly accepted** | An unclosed fence swallows the rest of a report and scores it near zero. It is named rather than counted. So is a heading dashed with a hyphen instead of an em dash — it used to match nothing at all, and a report nothing recognises is a report nothing checks |
| **Ordered-list markers are not words; a leading year is** | `1.` carries a digit, so §6.2's numbered section 1 would have paid a per-item tax its bulleted sections do not. The strip is capped at two digits, because `2026. the year` opens with content |
| **The gate is wired to the docs, not only to the arc-log** | It also asserts `run-instructions.md` still says a workstream parent closes when the user says so. Both of #185's failures happened at one boundary; the second one is a sentence, and a sentence with no check is how the first one got out |

## Rejected approaches

| | |
|---|---|
| Truncating or rewriting an over-budget report | #185's constraint. A gate that silently cuts a report is worse than one that names it |
| Failing a report whose declared count differs from the counted one | Fire declares 200 and measures 186. That gap is hand counting, not length |
| A python counter with a shell wrapper, as `report-grade.py`/`.sh` do | Nothing here needs it. `verify-*.sh` is the shape of a verifier in this repo |

## Retrospective

**The three review passes each found defects the earlier one could not have.** Pass 1 read the
requirements and found the section-7 rule latching on a report numbered 6.7. Pass 2 read what
pass 1's repairs introduced and found the release rule's own holes — a section titled *What it
changed and why* being read as the diagram, and an unclosed fence pinning the exclusion open.
Pass 3 audited the ticks and found that **the entire section-7 heading rule could be deleted with
every case still green**, because every fixture diagram sat inside a fence and fences are excluded
independently. That last one is the pass most easily skipped and it caught an untested rule of
fourteen lines.

The counting rule is stated in the script's header, in `run-instructions.md` §6.2 and in
`execution-process.md`, which now all point at the checker rather than restating a number nothing
reads. `docs/dev-log/pr-186-report-budget.md` records Loop's report at 184 words; it has grown
since, and the tree measures 195.
