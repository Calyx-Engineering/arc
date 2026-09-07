# Issue #164 — a claim records where it came from

**Issue:** [#164](https://github.com/Calyx-Engineering/arc/issues/164)  ·  **PR:** [#219](https://github.com/Calyx-Engineering/arc/pull/219)

## Problem

A claim's source is not recorded, so a weak source silently overrides a strong one. Two
instances, both from the dogfood window:

| | |
| --- | --- |
| **A photograph outranked a schematic for weeks** | Three kill-path signals on the rev B demand list were read off a photograph of a board the project does not hold, and were treated as specified because nothing on those rows said they were weaker than the rows beside them |
| **An inference outranked a bench measurement** | 2026-08-28. A measurement the user had verified by hand was discounted in favour of a number read off an instrument that was interpreting a 433 kHz class-D carrier as signal |

**The rule that was missing is not *cite your sources*.** It is *say so when the weaker one
wins*. Both failures are silent overrides, and silence is what makes them expensive.

## What changed

| File | |
| --- | --- |
| `tools/report-grade.py`, `.sh` | Two more columns on the instrument #159 built. `ROWS` / `NONE` / `TABLE` per claim table; `RESOLVED` / `SILENT` / `ONESIDED` / `MISMATCH` where two sources disagree. 43 selftests, up from 27 |
| `evals/report-shape/` | Three more cases: `pin-allocation-ledger` (the exemplar), `poe-device-under-test` (uniform-source, reported not scored), `poe-class-conflict` (the conflict). The three #159 cases gained a table verdict as well |
| `skills/engineering-report/SKILL.md` | **Where each claim came from** — the vocabulary, the three rules, and why it is not the confidence split |
| `skills/record-route/SKILL.md` | **Every record carries where its claims came from** — the same vocabulary at every tier, and a `description:` clause so the skill fires on *"where did that number come from"* |

## The result

```
tables: sourced by row 1, unsourced 3, one source in the lead-in 1 (not scored), no table 1
conflicts: resolved out loud 1, silent 0, one source only 0 (not scored), resolved elsewhere 0

table rows carry a source        1/4  0.25
conflicts resolved out loud      1/1  1.00
```

**Both halves of *Done when* are met.** Three tables without provenance are reported by name, and
`poe-class-conflict` grades `RESOLVED` in favour of `measured` — a measured class 4 signature
against the vendor's own label, model suffix and silkscreen, with the inference named as an
inference rather than as settled.

**1/4 is the baseline, and it is the interesting number.** The one pass is the user's own repair
of this exact defect: `rp2040-pin-allocation.md` grew a `Provenance` column after the photograph
incident. The three fails are an option comparison with six prices and no basis, a consequences
table derived from a standard it does not cite, and — the sharpest one — a findings table whose
per-row links point at **where the claim was worked out** rather than where it came from. Two of
those links are `test-` notes and two are `analysis-`: measured against inferred, on adjacent
rows, with nothing saying which is which. That is on the document #159 uses as its
clean-except-one-line case.

## Decisions and trade-offs

| Decision | Why |
| :--- | :--- |
| **Two more columns on #159's instrument, not a second tool** | Both defects live in the same artifact. A document that fixed its opening while leaving its tables unsourced would otherwise read as repaired |
| **Every column with a denominator must clear the threshold** | A verdict on the average of three questions lets a repaired opening report an unsourced table as progress — the two halves reporting each other's work as their own. The selftest proves it at 0.55, where the opening column clears and the table column does not |
| **The grader matches aliases, not only the seven words** | *"From the product label"*, *"the scope reported"*, *"most likely explanation"* are provenance. An instrument matching only the vocabulary would score every pre-existing report as unsourced, and the baseline would measure adoption of a word list rather than the defect |
| **`TABLE` is scored in neither column** | One source stated once above a uniform-source table is real provenance — weaker than a column, and not what #164 names. As a pass it licenses dropping the column; as a fail it reports a correctly sourced table as unsourced. Same reasoning as `BOLDONLY` in `topic-numbering.py` |
| **`MISMATCH` is reported, never scored** | Resolving toward a stronger source than the case expected is either a mis-authored case or a real finding, and the scorer cannot tell which |
| **The skills carry the issue's vocabulary, not the field's** | See *Unexpected* |

## Unexpected

**The vocabulary in the field does not match the one the issue specifies.**
`rp2040-pin-allocation.md` — written by the user, in response to this exact defect — uses
`schematic · datasheet · firmware · drawing · report · thread · photo · conversation`. Three of
those terms have no home in `measured > datasheet > vendor > schematic > photograph >
conversation > inferred`, and three of the issue's are absent from his.

The skills ship the issue's list, plus the rule for extending it: a project may add a term it
genuinely has, but it **places the new term in the order**, or it has added a word and not a
rule. Reconciling the two vocabularies is a decision and is spawned, not made here.

## What testing the tests found

**The lead-in scan stopped at the blank line.** `poe-device-under-test` scored `NONE` when it
should have scored `TABLE`: the source line *"From the product label:"* sits one blank line above
its table, and the scan walked back only while lines were non-blank. Every table in the corpus is
written that way, so the `TABLE` verdict would have been unreachable on real documents while
passing its own fixture — which had no blank line. Caught by running the real cases, not the
selftest.

## Hooks that fired

`mode-guard` read `HANDOFF.md` before the commit and allowed it. The worktree's row says
**Autonomous** until #159 and #164 merge.

## Retrospective

**The instrument can see whether a source is named. It cannot see whether the source is true.**
A row saying `measured` against a bench that never ran scores clean. The strength ordering makes
a weak source *visible*, which is all it was ever going to do — the photograph incident did not
happen because anyone lied about the photograph, it happened because nobody wrote it down.

**The instance that cost the most has no artifact to score.** The 2026-08-28 dead-instrument
override happened in conversation and never reached a document, so it is a selftest fixture
rather than a case. A document instrument cannot reach a defect that never became a document,
and #164's Required box asked for exactly that shape. It is recorded in `poe-class-conflict`'s
case file as a limit rather than papered over with an invented case.
