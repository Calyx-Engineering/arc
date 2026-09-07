# Grader — does a claim carry where it came from?

Scored by `tools/report-grade.sh`, arithmetic, no model in the loop. The rules live once, here;
the other provenance cases link to this file.

**A claim's source is not recorded, so a weak source silently overrides a strong one.**
[#164](https://github.com/Calyx-Engineering/arc/issues/164). A demand list carried three
kill-path signals read off a photograph of a board the project does not hold, treated as
specified for weeks, and nothing in the document said those rows were weaker than the ones
beside them.

## The vocabulary, strongest first

| | Is | And |
|---|---|---|
| `measured` | A bench result | The rig and its limits belong with it |
| `datasheet` | The part's own document | Cite the page |
| `vendor` | A label, a listing, a product page, silkscreen | The seller's claim about the seller's part |
| `schematic` | This board's own sheets | |
| `photograph` | A picture of a circuit not in hand | **Treat as a hypothesis** |
| `conversation` | Said, not written | Not a decision until it is |
| `inferred` | Extrapolated, assumed, calculated from something else | The weakest, and the easiest to mistake for a measurement |

**The order is the point.** Without it, "record the source" is a label with no consequence.

**The grader matches aliases, not only these seven words.** A report written before the
vocabulary existed still records provenance in its own words — *"from the product label"*,
*"the scope reported"*, *"most likely explanation"*. An instrument matching only the vocabulary
would score every one of those as unsourced, and the baseline would measure adoption of a word
list rather than the defect.

## Table verdicts

| Verdict | Condition |
|---|---|
| `ROWS` | A provenance column, **or** the terms carried in the rows themselves. The only pass |
| `NONE` | Nothing says where the numbers came from. A fail |
| `TABLE` | One source stated once in the lead-in, for a uniform-source table. **Not scored** |
| `NOTABLE` | No table in the region. Not scored |

**`ROWS` accepts both shapes.** A ledger that names its sources inline is sourced; demanding the
column shape would fail it for formatting rather than for the defect.

**`TABLE` is counted in neither column.** *"From the product label:"* above ten rows that all
come from the product label is real provenance — weaker than a column, and not what #164 names.
Scored as a pass it would license dropping the column; scored as a fail it would report a
correctly sourced table as unsourced. Same reasoning as `BOLDONLY` in `tools/topic-numbering.py`:
the ambiguous middle is reported, never guessed.

## Conflict verdicts

Scored only where `case.yaml` declares `conflict.favours`.

| Verdict | Condition |
|---|---|
| `RESOLVED` | Two or more provenance strengths in play, and the disagreement said out loud. The pass. The source it resolves toward is the strongest present, and it is named in the output |
| `SILENT` | Two or more in play and nothing says they disagree. **The fail #164 names** |
| `ONESIDED` | Fewer than two. Nothing to resolve. Not scored |
| `MISMATCH` | Resolved, but toward a source the case did not expect. Reported, never scored |

**`SILENT` is the whole defect.** A weak claim standing beside a strong one, with nothing
recording which won, is how a photograph outranked a schematic for weeks. The rule is not *cite
the stronger source* — it is **say so when the weaker one wins**, and the countable half of that
is whether anything in the section states the disagreement at all.

**`MISMATCH` is reported because the scorer cannot tell which side is wrong.** Either the case
named the wrong source, or the document resolves toward a stronger one than expected and that is
a finding. Guessing would score one of the two as a pass.

## What this grader cannot see

**Whether the source named is the true one.** It reads what the document claims about its own
provenance; it cannot check a row that says `measured` against a bench that never ran. The
strength ordering makes a weak source visible, not honest.
