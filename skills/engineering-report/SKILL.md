---
name: engineering-report
user-invocable: false
description: Use when the user asks for a report, a README, a write-up or a findings document to be written or changed, in any wording — "write the report", "write this up", "write up the findings", "update the readme", "add it to the report", "document this", "put it in the notes". Also fires when the request describes this work without naming it: recording what was investigated, measured, decided or ruled out, for a reader who was not there. Fires when the ask is wrapped inside other instructions rather than being the whole message — a report asked for alongside a commit, an issue and three further requests is still this skill's turn. Fires again when the user objects to a document already written: "too much in there", "way too long", "lacking all context", "what does this even mean", "this reads like what you did, not what is true", "i cant tell what the answer is". Covers what goes at the top and what a framing preamble costs, where each claim came from, the confidence split, length, and what never belongs in a report.
camp-reports: [report-written, report-revised]
checks: [destination, structure, actions-routed-to-tracker]
skips:
  - actions-routed-to-tracker (the report names no action)
---

# Engineering reports

> **A report states the current state of knowledge to someone who was not there.**

Not a record of how the knowledge was reached. Not a to-do list. A reader arriving cold
learns what is true, how well it is known, and what it means for the design — without
reconstructing the investigation.

**A report is K3 and it is rare.** Its unit is a product *capability*, not an issue. Several
issues may feed one report; most feed none. Three hundred reports means none get read — when
in doubt, it is analysis, which is K2. See
[knowledge-tiers](../../reference/knowledge-tiers.md).

---

## The opening — conclusion first

> **The first section states what is true. Everything a reader needs to act is above the fold,
> or the report failed.**

This is the rule the whole skill turns on, and it is the one most often broken.
[#159](https://github.com/Calyx-Engineering/arc/issues/159): five post-install corrections,
cluster C3 of the 2026-09 retrospective, every one of them a document that led with how the
answer was reached instead of the answer.

**Write the last section first.** A report drafted in the order the work happened comes out in
that order, and reordering it afterwards is an edit nobody makes. The finding exists before the
document does — put it at the top and let the method follow.

### The four shapes that fail

| Shape | What it looks like | Why it fails |
|---|---|---|
| **Background first** | The first section is *Question*, *Context*, *Problem*, *Scope*, *Method*, *Approach* or *Investigation* | The reader who stops after the first screen has the premise and none of the answer |
| **Deferred conclusion** | *"Status: complete. Conclusion in Section 9."* | A pointer where the answer should be. If it fits on the status line, so did the finding |
| **Framing preamble** | *"This document describes…"*, *"Findings and conclusions."*, *"Investigation only."* | **A fail on its own, with nothing else wrong.** The reader opened the document; they know what it is. It costs a line at the exact point attention is highest |
| **Development narrative** | *"We first tried X, then found Y"* | State Y. See [Point of view](#point-of-view). **This is the one shape the grader does not check** — it reads the opening, and a narrative in the first section's body is below what it sees. Yours are the only eyes on it |

**A framing preamble is not a small thing.** It is the shape that survives review, because it
reads as courtesy rather than as a defect, and it sits in the one place where the finding should
be. If a sentence would still be true of a different report on a different subject, delete it.

### What is not a preamble

| | |
|---|---|
| **The status header** | Subject, related issue, author, date, status, scope — `**Status:** …` lines. Required, and §1 says so |
| **A safety or validity callout** | `> [!WARNING] Every measurement here was taken on a damaged unit.` That is a finding about how far the results reach, and it belongs high |
| **A first section named after its subject** | *"Load switch rise time"* over a finding is fine. The heading does not have to say *Findings* — the section has to be one |

### The trigger

**Load this skill before the first line of a report is written, not at review.** An opening is
decided by the order the document is drafted in, and by then the order exists. The situations
that are this skill's turn even when nothing is called a report:

- A findings document, a README, a companion note, a data note, a spec write-up
- The user objecting to a document already written — *"too much in there"*, *"lacking all
  context"*, *"what does this mean"*
- Restructuring, re-ordering or shortening a document that already exists

### How it is scored

[`tools/report-grade.sh`](../../tools/report-grade.sh) reads a report's opening — its first line
through the end of its first `##` section. It is arithmetic, no model in the loop, and it grades
**the document, not the session**: whether this skill fired while the report was written is a
separate question with a separate instrument, which
[#155](https://github.com/Calyx-Engineering/arc/issues/155) settled move independently.

| Verdict | |
|---|---|
| `CONCLUSION` | The pass |
| `NARRATIVE` · `DEFERRED` · `PREAMBLE` | The fails. Every flag prints, so a document that hits two shapes shows both |
| `UNCLEAR` | The first heading is in neither class. **Not scored, and it exits 0** — read it yourself |
| `NOSECTION` | No `##` heading. Not scored |
| `NOTOPENING` | A suite case whose region does not start at line 1. Never seen from `--file` |

**Three of the four failing shapes are checked.** Development narrative is not — see the table
above.

`bash tools/report-grade.sh --file <path>` grades one document on all three questions and prints
each. **Only the opening decides the exit code.**

| | |
|---|---|
| `FIX`, exit 1 | The opening. There is one opening per document and it either states the finding or it does not |
| `LOOK`, exit 0 | Everything else. The table and conflict checks are **region-scoped by construction** — the suite runs them over a chosen excerpt, and over a whole file they cannot tell a claim table from any other table. They are worth reading and they do not gate |

**Exit 0 is not a verdict that the document is fine.** Read every `LOOK` line. The three that
appear: an unsourced claim table; two sources named with nothing saying they disagree; and
`WEAKWINS` — a weaker source asserted over a stronger one **and said so**, which obeys the rule
and is exactly the shape of the incident
[#164](https://github.com/Calyx-Engineering/arc/issues/164) was written about.

Cases in [`evals/report-shape/`](../../evals/report-shape/).

---

## Where each claim came from

> **A claim's source travels with the claim, on the same row.** A source recorded once in a
> lead-in, or not at all, is a source that stops travelling the first time the row is quoted
> somewhere else.

[#164](https://github.com/Calyx-Engineering/arc/issues/164). A demand list carried three
kill-path signals read off **a photograph of a board the project does not hold**, treated as
specified for weeks, because nothing on those rows said they were weaker than the rows beside
them. Separately, a bench measurement the user had verified was discounted in favour of an
inference from a dead instrument.

### The vocabulary, strongest first

| | Is | And |
|---|---|---|
| `measured` | A bench result | Name the rig and its limits |
| `instrument` | A number an instrument displayed | **Not a measurement.** Nothing yet says it was measuring what the claim names |
| `schematic` | This board's own sheets | |
| `datasheet` | The part's own document | Cite the page |
| `vendor` | A label, a listing, a product page, silkscreen | The seller's claim about the seller's part |
| `firmware` | Shipped source | What the code *does*, not what the hardware requires |
| `drawing` | A reviewed diagram | As strong as the review behind it |
| `report` | A merged study in `docs/report/` | Never stronger than the row it cites |
| `thread` | An issue thread | A decision was reached; no artifact records it yet |
| `photograph` | A picture of a circuit not in hand | **Treat as a hypothesis, never as a specification** |
| `conversation` | Said, not written down | Not a decision until it is |
| `inferred` | Extrapolated, assumed, calculated from something else | The weakest, and the easiest to mistake for a measurement |

**The order is the point.** Without it, *record the source* is a label with no consequence. A
project may add a term where it genuinely has one, but it places the new term **in the order**,
or it has added a word and not a rule.

**`instrument` is the one most often written as `measured`.** On 2026-08-28 a scope reported
2.473 Vpp where the tone was 1.456 Vpp — a peak-to-peak reading cannot separate a tone from a
tone plus a 433 kHz class-D carrier — and an estimate drawn from that reading was taken over a
bench measurement the user had verified. Under one word for both, a report of that afternoon
names one source and shows no disagreement at all. A reading becomes `measured` when the rig and
its limits are **written down beside it**, not when it has been thought about.

**These twelve are two vocabularies reconciled** —
[#266](https://github.com/Calyx-Engineering/arc/issues/266). `firmware`, `drawing`, `report` and
`thread` are adopted from the ledger the user had been keeping by hand, `photo` maps to
`photograph`, and `schematic` rises above `datasheet` and `vendor` both — a claim about *this
board* is settled by this board's own sheets. [record-route](../record-route/SKILL.md#these-twelve-are-the-fields-and-the-specs-reconciled)
holds the mapping.

### The three rules

| | |
|---|---|
| **Every claim table carries a `Provenance` column** | Or each row names its source inline. A table of numbers with no basis is a table a reader has to take on trust, and *the trust is what fails* |
| **So does the second table** | The margin table, the comparison, the summary of the rows above. A derived number is still a claim, and a reader who quotes that row cannot see the rows it came from. Give it the column, or say in the row which measurement it is derived from. **This is the rule that gets dropped**, and it is dropped while the main table is perfect: measured over [#260](https://github.com/Calyx-Engineering/arc/issues/260)'s probe runs, the claim table carried provenance every time and a second table in the same report carried it once in three |
| **A strong claim is never overridden by a weak one silently** | If an inference wins over a measurement, the document says so, in the same sentence as the claim it is overriding, with why. The rule is not *cite the stronger source* — it is **say so when the weaker one wins** |
| **A weak row is interrogated before anything is built on it** | `photograph`, `conversation` and `inferred` are hypotheses. They belong in *Not established* with what would settle them |

### It is not the confidence split

The [confidence split](#4-confidence-split--mandatory) groups the report's claims into
**Verified / Measured / Not established**. Provenance is per row, and it survives being quoted
out of the document. A report needs both: the split tells a reader how much of the whole is
solid, the column tells them whether *this* number is.

**The same rule applies outside a report.** A wiki fact, an arc-work ledger and a scratch
measurement all carry their source —
[record-route](../record-route/SKILL.md#every-record-carries-where-its-claims-came-from) holds
that side.

### How it is scored

[`tools/report-grade.sh`](../../tools/report-grade.sh) returns `ROWS`, `NONE` or `TABLE` per
claim table, and `RESOLVED` or `SILENT` where two sources disagree. **The worst table in the
document is the verdict** — a perfect claim table beside an unsourced margin table reads `NONE`,
which is the rule above being enforced and not a scoring artefact. It matches how provenance
is actually written — *"from the product label"*, *"the scope reported"*, *"most likely
explanation"* — not only the vocabulary words themselves, so a report is scored on the defect
and not on adoption of a vocabulary. Cases in [`evals/report-shape/`](../../evals/report-shape/).

---

## Point of view

| Rule | |
|---|---|
| **"Previous" means the last released revision** | Not the last thing tried. Rev A is previous; a rejected proposal from last week is not |
| **Rejected alternatives are alternatives, not history** | Present them as options with verdicts, not as a sequence of attempts |
| **No development narrative** | Never "we first tried X, then found Y". State Y |
| **No first-person journey** | "the hoped-for benefit", "this corrects an earlier version" — all wrong in a report |
| **No framing preamble** | The document does not describe itself. [The opening](#the-opening--conclusion-first) |

**Corrections are restated as properties of the thing, not as a changelog.** A superseded
claim becomes a fact about the component or the method:

- ✗ "This corrects an earlier version of this report, which said 0.21 nF would work."
- ✓ "The datasheet slew relation does not extrapolate below its characterised range; this
  part family must be measured, not calculated."

---

## Layering — what goes where

| Layer | Holds | Length |
|---|---|---|
| **The issue** (tracker) | Actions, plans, checklists, assignments, open questions | — |
| **Report `README.md`** | Conclusions. What is true, what it costs, what changes | **1–2 pages** |
| **Companion notes** | Method, data, measurements, explorations, superseded concepts | ≤ 3 pages each |
| **The wiki** | Durable facts that outlive the report — part behaviours, standards thresholds, gotchas | — |

**Never put actions or plans in a report.** No checklists, no next steps, no owners. Mixing
work items with conclusions means neither is trustworthy — the tracker owns actions.

**Promote durable findings to the wiki.** A fact that will matter on an unrelated task next
year does not belong only inside one report. Graduating means the report links to the wiki,
never that the fact is copied — a fact in two places drifts, and the stale copy wins.

**Do not add an AI appendix or machine-readable section.** The duplicate drifts and a future
session trusts the stale copy. Good tables and a good confidence section are already the
machine-useful part.

---

## Length

| Document | Target | Working proxy |
|---|---|---|
| Report `README.md` | **1–2 printed pages** | ≤ ~500 words of prose |
| Any other document | **≤ 3 printed pages** | ≤ ~1200 words of prose |

Prose means body text. Tables, figures, captions and headings are **not** budgeted — they
are the form length should take.

**Prose is supplemental.** If sentences are doing the explaining, the document is built
wrong: move the payload into a table or figure, or move the detail into a companion note.

**Safety, health and compliance content is never trimmed to fit.** If it pushes a document
over budget, that is the correct outcome.

---

## Visual first

Reach for a visual before a paragraph.

| Form | Use for |
|---|---|
| **Table** | Comparisons, limits, options, requirements, before/after |
| **Bullets** | Short parallel items — never as a substitute for a table with real columns |
| **Mermaid** | Flow, state, decision, sequence. Text-diffable and renders natively |
| **Vector diagram** | Block and system diagrams; match whatever the project already uses |
| **Authored figure + generator** | Plots and dimensioned drawings. **Commit the generator** beside the output so the figure can be regenerated |
| **Photo / instrument capture** | Evidence. Captioned with what the reader is looking at and under what conditions |

Every figure needs a caption stating **what it shows**, not what it is. "500 µs/div. Yellow —
switch output. Cyan — light" beats "Scope capture 3".

---

## Required elements

Structure beyond these is topic-dependent. Do not force a template.

### 1. Status header

Subject, related issue, author, date, status. Say plainly if the document is superseded, and
link to what replaced it.

### 2. Findings first

The top answers **what is true, and what does it cost?** A reader who stops after the first
screen has the conclusion. Never open with background or method, and never with a sentence
explaining what the document is — the four failing shapes, what is exempt, and how it is
scored are in [The opening](#the-opening--conclusion-first).

### 3. Safety, health, compliance and test — your analysis, not a question

**This is work you do, not a question you ask.** Reason through the implications and write
the conclusion with its basis. Asking "any safety concerns?" invites a reflexive no, and
that no then reads as a cleared check forever.

| Angle | Ask of the change |
|---|---|
| **Human exposure** | What does a person see, hear, touch or breathe? At what intensity, how close, how long? |
| **Thermal** | What dissipates, where, worst case? What is the failure temperature? |
| **Electrical** | Fault currents, stored energy, isolation, behaviour on a short or an open |
| **Certification** | Does this touch a rated device, a certified mode, or a compliance claim? Does the rating still hold? |
| **Emissions** | Conducted, radiated, acoustic — what got faster, bigger, or longer |
| **Failure modes** | The state after a fault, a brownout, a disconnected sensor, a stuck control line |
| **Test coverage** | What existing test no longer proves what it used to, because this changed |

- **A nil finding must be reasoned, not asserted.** "No exposure concern — the emitter is
  enclosed and the duty is fixed in firmware" is a finding. "None identified" is not
- **Record uncertainty as uncertainty** — in *not established*, with what would settle it
- **Surface real findings prominently**, asked for or not. Own section, early, never trimmed
- **The check is standing, not one-time.** Re-run whenever new measurements arrive

Escalate when a finding would change what gets built or shipped — as a **conclusion with its
basis**, not an open question for someone else to dispose of.

### 4. Confidence split — mandatory

| Group | Contains |
|---|---|
| **Verified** | Quoted from datasheets, standards, or primary documents — with the source |
| **Measured** | Bench results, with the rig and its limits stated |
| **Not established** | Everything assumed, extrapolated, or untested, each with what would settle it. **The most valuable group and the most often dropped** |

A report without the split looks more certain than it is.

**The split is per report; the provenance column is per row.** They do different jobs and the
column does not replace the split — see [Where each claim came from](#where-each-claim-came-from).

### 5. Sources

Primary documents, datasheets, standards, part numbers, and links to the companion notes.

---

## Companion data notes

Notes recording a measurement or test session follow one extra rule:

> **Structure chronological, prose declarative.**

Organise by session or configuration — reproducibility depends on knowing what was set when.
But state findings rather than narrate discovery:

- ✗ "We removed C25 and found it still wasn't fast enough."
- ✓ "With C25 removed, rise time is 336–546 µs."

State **what the session characterises and what it does not**, at the top. A measurement
taken with substitute hardware characterises the substitute, and that has to be impossible
to miss.

---

## Files and naming

| | |
|---|---|
| One directory per capability | `README.md` plus companions |
| `README.md` | Always the conclusions document |
| Companion filenames | `<class>-<subject>.md`, kebab-case — `test-load-switch-rev-a.md`, not `notes2.md` |
| Figures in subfolders per setup or source | Keeps the top level readable and stops captures from different rigs mixing |
| Source PDFs and datasheets in a subfolder | Not loose in the report directory |
| Superseded documents | Keep them. Add a status banner with the date and a link to what replaced it. **Never delete** |

Companion notes link **up** to the conclusions document; the README links **down** to each
companion.

### Class prefix

| Class | Holds |
|---|---|
| `safety-` | Human exposure, thermal, electrical, compliance analysis |
| `analysis-` | Paper analysis — budgets, trade studies, selections. No hardware |
| `test-` | Bench sessions. Measured data, rig described |
| `reference-` | Background research on how something external works |
| `archive-` | An approach explored and set aside, kept in case it is revived |

`archive-` rather than `concept-`: the filename states what the document permanently is, the
status banner inside states where it currently stands. A name that reads as live goes stale.

Add a class only when a document genuinely fits none of these. A one-off class defeats the
grouping.

### No number prefixes

Numbering puts reading order in the filename, where every insert mid-study forces renames
that churn history and break links already pasted into issues and reviews.

| Job | Where it lives |
|---|---|
| Grouping by kind | The class prefix — alphabetical sort does it for free |
| Reading order | The README link list — one place, reorderable at no cost |

`README.md` keeps that exact spelling: it auto-renders beneath the folder's file list. Never
rename it to `_README.md` or `00-README.md` to improve its sort position.

Numbering is right only when the set ships as an ordered bundle outside a repo viewer — a
printed pack or a stitched PDF.

---

## Before finishing

- **Markdown lints clean.** Run the repo's linter over the whole report directory, not just
  the file you touched — heading and table rules catch neighbouring files too
- Count prose words against the budget. Over? Move payload into tables or a companion note
- Every figure captioned with what it shows
- Safety, health, compliance and test worked through and written up, with reasoning if nil
- Confidence split present, with a populated *not established*
- No actions, checklists or next steps anywhere in the report
- No development narrative, no "previously we thought"
- **The opening grades clean** — `bash tools/report-grade.sh --file <report>/README.md`, exit 0.
  **That is the opening only**: read every `LOOK` line as well, and read the first section's body
  yourself for development narrative, which no check covers
- **Every table of claims carries a source**, per row — **count the tables, not the table.** The
  derived one, the margin table and the summary are claims too, and they are where the rule gets
  dropped. Where two sources disagree, the document says which won —
  [Where each claim came from](#where-each-claim-came-from)
- All internal links resolve
- Filenames carry a class prefix and no numbers; README lists companions in reading order

### Linting

Run it after every editing pass, not once at the end. A lint error found ten edits later
costs more to place than to fix.

Use whatever config the repo already carries rather than introducing one. If a rule fights
the report — a deliberate table shape, an intentional heading level — **fix the document,
not the config.**

Two rules account for most failures: `MD022` blanks-around-headings, usually from scripted
edits that insert a heading without the blank lines; and `MD060` table-column-style, from
pipe spacing that differs from the rest of the file. Both are mechanical. Normalising
headings across a file is a safe scripted fix; re-check the whole directory afterwards.

### Verifying figures

Hand-authored SVG needs its text checked, because overflowing and colliding labels render
without error. Parse the `<text>` elements, estimate each box from its font size and anchor,
and flag anything overlapping a neighbour or leaving the `viewBox`. Do this after every
figure edit — a label that fitted before a value changed may not fit after.
