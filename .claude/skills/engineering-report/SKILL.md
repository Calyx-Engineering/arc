---
name: engineering-report
description: Use when writing, revising, or restructuring an engineering report — a findings document under report/ or equivalent that records what was investigated, measured, or decided. Invoke before drafting or editing any report document, including companion notes and data notes.
camp-reports: [report-written, report-revised]
checks: [destination, structure, actions-routed-to-tracker]
skips:
  - actions-routed-to-tracker (the report names no action)
---

> **Copy — do not edit.** The source is [`skills/engineering-report/SKILL.md`](../../../skills/engineering-report/SKILL.md),
> which is what the plugin ships. This copy exists only so the skill is live in this repo
> before Arc is installed here. **Edit the source, then re-run `tools/sync-local-skills.sh`.**


# Engineering reports

> **A report states the current state of knowledge to someone who was not there.**

Not a record of how the knowledge was reached. Not a to-do list. A reader arriving cold
learns what is true, how well it is known, and what it means for the design — without
reconstructing the investigation.

**A report is K3 and it is rare.** Its unit is a product *capability*, not an issue. Several
issues may feed one report; most feed none. Three hundred reports means none get read — when
in doubt, it is analysis, which is K2. See
[knowledge-tiers](../../../reference/knowledge-tiers.md).

---

## Point of view

| Rule | |
|---|---|
| **"Previous" means the last released revision** | Not the last thing tried. Rev A is previous; a rejected proposal from last week is not |
| **Rejected alternatives are alternatives, not history** | Present them as options with verdicts, not as a sequence of attempts |
| **No development narrative** | Never "we first tried X, then found Y". State Y |
| **No first-person journey** | "the hoped-for benefit", "this corrects an earlier version" — all wrong in a report |

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
screen has the conclusion. Never open with background or method.

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
