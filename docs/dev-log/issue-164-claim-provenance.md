# Issue #164 — a claim records where it came from

**Issue:** [#164](https://github.com/Calyx-Engineering/arc/issues/164)  ·  **PR:** [#224](https://github.com/Calyx-Engineering/arc/pull/224)

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
| `tools/report-grade.py`, `.sh` | Two more columns on the instrument #159 built. `ROWS` / `NONE` / `TABLE` per claim table; `RESOLVED` / `WEAKWINS` / `SILENT` / `ONESIDED` where two sources disagree |
| `evals/report-shape/` | Three more cases: `pin-allocation-ledger` (the exemplar), `poe-device-under-test` (uniform-source, reported not scored), `poe-class-conflict` (the conflict). The three #159 cases gained a table verdict as well |
| `skills/engineering-report/SKILL.md` | **Where each claim came from** — the vocabulary, the three rules, and why it is not the confidence split |
| `skills/record-route/SKILL.md` | **Every record carries where its claims came from** — the same vocabulary at every tier, and a `description:` clause so the skill fires on *"where did that number come from"* |

## The result

```text
tables: sourced by row 1, unsourced 3, one source in the lead-in 1 (not scored), no table 1
conflicts: resolved out loud 2, silent 0, one source only 3 (not scored), weaker source asserted 1 (reported)

table rows carry a source        1/4  0.25
conflicts resolved out loud      2/2  1.00
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
those links are `test-` notes and four are `analysis-`: measured against inferred, on adjacent
rows, with nothing saying which is which. That is on the document #159 uses as its
clean-except-one-line case.

## Decisions and trade-offs

| Decision | Why |
| :--- | :--- |
| **The exemplar's region starts at section 5, not section 6** | Cut at the anomaly alone, the only `measured` token is a negated clause — *"not by measured draw"* — so the verdict rested on an incidental word. Section 5 is where the measurement is. It is still thinner than it looks, and the case file says so: `measured` falls on both sides of the split |
| **Two more columns on #159's instrument, not a second tool** | Both defects live in the same artifact. A document that fixed its opening while leaving its tables unsourced would otherwise read as repaired |
| **Every column with a denominator must clear the threshold** | A verdict on the average of three questions lets a repaired opening report an unsourced table as progress — the two halves reporting each other's work as their own. The selftest proves it at 0.55, where the opening column clears and the table column does not |
| **The grader matches aliases, not only the seven words** | *"From the product label"*, *"the scope reported"*, *"most likely explanation"* are provenance. An instrument matching only the vocabulary would score every pre-existing report as unsourced, and the baseline would measure adoption of a word list rather than the defect |
| **`TABLE` is scored in neither column** | One source stated once above a uniform-source table is real provenance — weaker than a column, and not what #164 names. As a pass it licenses dropping the column; as a fail it reports a correctly sourced table as unsourced. Same reasoning as `BOLDONLY` in `topic-numbering.py` |
| **The direction is derived from the text, never from the ordering** | See *What pass 1 found* — this was wrong, and wrong in the one way that mattered |
| **The skills carry the issue's vocabulary, not the field's** | See *Unexpected* |

## Unexpected

**The vocabulary in the field does not match the one the issue specifies.**
`rp2040-pin-allocation.md` — written by the user, in response to this exact defect — uses
`schematic · datasheet · firmware · drawing · report · thread · photo · conversation`. Four of
those terms have no home in `measured > datasheet > vendor > schematic > photograph >
conversation > inferred` — `firmware`, `drawing`, `report`, `thread` — and three of the issue's
are absent from his: `measured`, `vendor`, `inferred`.

The skills ship the issue's list, plus the rule for extending it: a project may add a term it
genuinely has, but it **places the new term in the order**, or it has added a word and not a
rule. Reconciling the two vocabularies is a decision and is spawned, not made here.

## What pass 1 found

**The conflict column asserted a direction it never derived, and passed the incident it was
built for.** `grade_conflict` returned the strongest provenance term *present* and printed it as
*"resolves in favour of"*. That is the vocabulary's own ordering restated, not a reading of the
document. Probed:

```text
"The measured gain is 41.7x on the bench. However the estimated gain from the
 instrument is 24.7x, and we are taking the estimate as correct."

  before:  RESOLVED  resolves in favour of: measured     <- a pass
  after:   WEAKWINS  asserted over the rest: inferred
```

That sentence **is** the 2026-08-28 incident this issue was written about. An instrument has to
be able to fail the thing it was built for. The direction now comes from which side of the first
contrast marker each source sits on, and that fixture is in the selftest as a regression guard.

**`conflict.favours` in `case.yaml` was a recorded expected outcome**, which this PR's own
`evals/README.md` forbids in the same commit that wrote the rule. It was not inert: it gated
whether the conflict column ran at all, so omitting it made a silent conflict ungraded, and it
decided whether a resolved conflict counted. Removed. A case declares a document and a region;
the scorer derives everything else.

**Two matcher defects.** `extrapolat` could never match: the alternation is wrapped in
`(?:...)`, and those `` anchors are the whole cause — no word boundary follows
`extrapolat` in *extrapolated*. It was the headline
word of `inferred`'s own definition in both skills. And `ROWS` needed only **half** a table's
rows sourced; nothing in either skill says half, and a half-sourced table is the defect.

**The conflict scan read table rows as prose**, so a correctly sourced ledger — a different
source on every row, which is exactly what this issue asks for — was reported as a silent
conflict. Rows are now excluded.

## What pass 2 found — in pass 1's own fixes

| | |
| --- | --- |
| **`RESOLVED` was the default when no direction could be read** | `if not asserted or not aside: return "RESOLVED"` put *"no direction derivable"* in the numerator — the inverse of how `UNCLEAR`, `TABLE` and `BOLDONLY` are handled everywhere else here. Now `UNREADABLE`, scored in neither column |
| **`CONTRAST` fired on agreement** | `wins` and `against the` matched *"the datasheet part wins on cost"* and *"plotted the measured curve against the datasheet curve; they agree"*. Both produced a false `RESOLVED` **in the scored bucket**. Removed |
| **The table-row strip deleted any line containing a pipe** | `\|Vgs\| < 20 V`, `\|Z\|`, `\|S21\|` are ordinary in this corpus, and dropping those lines took whole conflicts with them into `ONESIDED`. A line is a table row only if it **starts** with a pipe |
| **`grade_conflict` was the only reader in the file with no fence tracking** | A fenced sample naming two sources scored `SILENT` — a scored fail |
| **The unsourced-table message was misleading** | *"10 row(s), no source"* for a table where nine rows name one. It now says *"9 of 10 row(s) name a source"*, and that string is what `--file` shows the author |

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

## Spawned

| Finding | Where it routes |
| --- | --- |
| **The vocabulary has no term for an instrument reading that is not a measurement.** `measured` collapses *a number the bench produced* and *a number a fooled instrument produced* — and that distinction is the whole of the 2026-08-28 incident. `pr-68-gain-sweep-tool.md` records it (*"the scope reported 2.473 Vpp where the tone was 1.456 Vpp"*); the candidate region grades `ONESIDED` because both readings are `measured` to the matcher. The whole file grades `SILENT`, on an unrelated pairing further down | Needs an issue. It is why that document could not become the box-5 case |
| **The two vocabularies do not reconcile** — see *Unexpected* | Needs an issue |
| **Four scorers duplicate fence-tracking and case-reading** — also raised on #159 | Needs an issue |

## Retrospective

**The instrument can see whether a source is named. It cannot see whether the source is true.**
A row saying `measured` against a bench that never ran scores clean. The strength ordering makes
a weak source *visible*, which is all it was ever going to do — the photograph incident did not
happen because anyone lied about the photograph, it happened because nobody wrote it down.

**The Required box asking for a user-stated measurement against an inference is not met, and
the box is left unticked.** `poe-class-conflict` is a real conflict — measured against a vendor
label, with an inference named alongside and declined — but the measurement is the report's own,
not the user's. The 2026-08-28 instance is the right shape. It was argued out in conversation;
the one place it is written down is `pr-68-gain-sweep-tool.md`, which was cut as a candidate
case and dropped because the vocabulary cannot tell the fooled instrument's number from the
bench's — both read as `measured`, so the region grades `ONESIDED`. It is a selftest fixture
instead. Recorded in *Spawned*, and the box says so rather than a case being invented to close
it.
