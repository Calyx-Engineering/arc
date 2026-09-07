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
| `ROWS` | A provenance column, **or** the terms carried in **every** row. The only pass |
| `NONE` | Nothing says where the numbers came from. A fail |
| `TABLE` | One source stated once in the lead-in, for a uniform-source table. **Not scored** |
| `NOTABLE` | No table in the region. Not scored |

**`ROWS` accepts both shapes, and the inline shape needs every row.** A ledger that names its
sources inline is sourced; demanding the column shape would fail it for formatting rather than
for the defect. But a half-sourced table is the defect — adjacent rows with nothing saying which
is which is exactly what #164 names — so the inline path requires all of them.

**`TABLE` is counted in neither column.** *"From the product label:"* above ten rows that all
come from the product label is real provenance — weaker than a column, and not what #164 names.
Scored as a pass it would license dropping the column; scored as a fail it would report a
correctly sourced table as unsourced. Same reasoning as `BOLDONLY` in `tools/topic-numbering.py`:
the ambiguous middle is reported, never guessed.

## Conflict verdicts

Scored on every case. **There is no field a case author can set to change this**, and there was:
an earlier `conflict.favours` both gated whether the column ran and decided whether a resolved
conflict counted, so omitting it made a silent conflict ungraded. A case declares a document and
a region; the scorer derives the rest.

| Verdict | Condition |
|---|---|
| `RESOLVED` | Two or more provenance strengths in play, the disagreement said out loud, and the source **asserted** at least as strong as the one set aside. The pass |
| `WEAKWINS` | The same, but the **weaker** source is the one asserted. Reported, scored in neither column |
| `SILENT` | Two or more in play and nothing says they disagree. **The fail #164 names** |
| `ONESIDED` | Fewer than two. Nothing to resolve. Not scored |
| `UNREADABLE` | A contrast marker with a source on only one side of it. No direction to read, so none is claimed. Not scored |

**`UNREADABLE` exists because "no direction derivable" used to return `RESOLVED`** — the pass
verdict — putting an unread sentence in the numerator. That is the inverse of how `UNCLEAR`,
`TABLE` and `BOLDONLY` are handled everywhere else in this repo: the ambiguous middle is
reported, never credited.

**The direction is derived, never assumed.** The first contrast marker splits the region:
provenance named before it is being set aside, provenance named after it is being asserted. An
earlier version returned the strongest term *present* and printed it as *"resolves in favour
of"* — which is the vocabulary's own ordering restated, not a reading of the document. It graded
this as a pass, in favour of `measured`:

> The measured gain is 41.7x on the bench. However the estimated gain from the instrument is
> 24.7x, and we are taking the estimate as correct.

That is the 2026-08-28 incident #164 was written about. **An instrument has to be able to fail
the thing it was built for.** It now scores `WEAKWINS`, asserting `inferred`.

**`WEAKWINS` is reported, not failed.** #164's rule is *not overridden without saying so
explicitly*, so a weak source that wins out loud has obeyed the rule. Whether the reason was good
is a judgement, and this grader does not make judgements — it points.

**Table rows are excluded from the conflict scan, and so are fenced blocks.** A correctly sourced
ledger names a different source on every row; that is the shape #164 asks for, and reading it as
prose reported the exemplar of the rule as a silent conflict. **A line counts as a table row only
if it starts with a pipe** — dropping every line that merely contains one deleted `|Vgs| < 20 V`,
`|Z|` and `|S21|`, and with them whole conflicts, silently, into `ONESIDED`.

**`SILENT` is the whole defect.** A weak claim standing beside a strong one, with nothing
recording which won, is how a photograph outranked a schematic for weeks. The rule is not *cite
the stronger source* — it is **say so when the weaker one wins**, and the countable half of that
is whether anything in the section states the disagreement at all.

## What this grader cannot see

**Whether two sources are about the same thing.** The conflict column detects co-occurrence plus
a stated disagreement. A region that mentions two sources incidentally, with an ordinary *but*
between them, is reported as a conflict — and `RESOLVED` **is** the scored bucket, so that lands
in the numerator rather than out of it. Two things hold it down and neither removes it: the
region is the case's chosen excerpt rather than a whole file, and a contrast marker that fires on
agreement has been taken out of the list (`wins`, `against the`). Over a whole file, via `--file`,
this column does not gate at all.

**A sourced table with a totals or spacer row.** `ROWS` by the inline path requires every row to
name a source, so `| **Total** | **$180** |` under two sourced rows scores `NONE`. The strict rule
is deliberate — half-sourced is the defect — and this is its cost.

**Whether the source named is the true one.** It reads what the document claims about its own
provenance; it cannot check a row that says `measured` against a bench that never ran. The
strength ordering makes a weak source visible, not honest.
