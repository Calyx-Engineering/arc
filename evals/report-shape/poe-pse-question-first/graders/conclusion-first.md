# Grader — does the report open with the conclusion?

Scored by `tools/report-grade.sh`, arithmetic, no model in the loop. The same grader applies to
every case in this suite that carries a region starting at line 1; it lives once, here, and the
other cases link to it.

**A report states the current state of knowledge to someone who was not there.** A reader who
stops after the first screen has the conclusion, or the report failed. That is
`skills/engineering-report` §2, and this grader is the first thing that checks it.

## What is read

The **opening** — the document's first line through the end of its first `##` section. Nothing
below that is read, because nothing below it can repair an opening.

Inside the opening, three parts are told apart:

| Part | Is | Because |
|---|---|---|
| **YAML front matter** and **bold-label lines** — `**Status:** …`, `**Author:** …`, `**Scope:** …` | The status header. Exempt from the preamble check | §1 of the skill requires a status header. A check that failed one would be unusable |
| **Blockquote callouts** — `> [!WARNING]` and the like | Content. Exempt | A safety caveat is a finding, not framing |
| **Everything else before the first `##`** | Prose, and it is where a framing preamble hides | |

## The verdicts

| Verdict | Condition |
|---|---|
| `CONCLUSION` | The first `##` section is a findings section, no framing preamble, no deferred conclusion. The only pass |
| `NARRATIVE` | The first `##` section is background-class. A fail |
| `DEFERRED` | The opening points elsewhere for the conclusion — *"Conclusion in Section 9"*. A fail |
| `PREAMBLE` | Prose in the opening explains what the document is. A fail |
| `UNCLEAR` | The first section's heading is in neither class. Not scored, and reported by name |
| `NOSECTION` | No `##` heading in the region. Not scored |
| `NOTOPENING` | The case's region does not start at line 1, so it is not an opening. Not scored |

**The background class, in full:** *question, questions, background, context, problem, purpose,
introduction, intro, overview, method, methods, methodology, approach, history, scope,
investigation, motivation, premise.* The findings class: *finding, findings, conclusion,
conclusions, recommendation, recommendations, answer, answers, result, results, verdict, summary,
decision, decisions, outcome.* Only the heading's first three words are read — *"Summary of
findings"* is a findings section and so is *"Findings — background to the sweep"*.

**Every flag is printed; the verdict is the worst one.** `NARRATIVE` outranks `DEFERRED`
outranks `PREAMBLE`. A document that opens on the wrong section has a bigger problem than one
that opens with a spare sentence above the right section, and reporting only the worst would
hide the other two.

**`DEFERRED` and `PREAMBLE` are decided before `UNCLEAR` is allowed to withhold a verdict.** An
unclassifiable heading means the grader cannot say whether the first section is a findings
section. It says nothing about a pointer on the status line or a sentence explaining what the
document is, both of which are visible whatever the heading is called. Returning `UNCLEAR` first
made both invisible on the shape the skill explicitly blesses — *a first section named after its
subject* — so a document following the skill's own advice could carry two failing shapes and
still exit 0.

**Three of the skill's four failing shapes are graded here. Development narrative is not.** A
pattern for it was written and removed: `opening()` collects prose only until the first `##`, so
the first section's *body* — where *"We first tried a linear regulator, then found the switcher
was needed"* actually lives — is never in the text it would scan. In the few lines it could see,
it failed ordinary report prose instead: *"At first glance the two adapters are identical"*,
*"It turns out the PSE budgets by declared class"*. Blind where it mattered and wrong where it
fired. The skill still names four shapes; this grader covers three, and says which one it does
not.

**A framing preamble is a fail on its own.** [#159](https://github.com/Calyx-Engineering/arc/issues/159)
requires it explicitly, and `light-dimming-findings-first` is the case that isolates it: a
correct findings section, a correct status header, and one line between them saying what the
document is. The reader already knows what the document is — they opened it.

**`UNCLEAR` is reported, never guessed.** A heading in neither class could be a findings section
named after its subject or a background section named the same way, and nothing structural
separates them. Crediting it would score an unread opening as a pass; failing it would punish a
report for naming its first section well. Same reasoning as `BOLDONLY` in
`tools/topic-numbering.py`.

## What this grader cannot see

**It reads a document, not a session.** Whether `engineering-report` fired while the document
was being written is `tools/skill-cases.sh`'s question, and
[#155](https://github.com/Calyx-Engineering/arc/issues/155) settled that the two answers are
independent. A rate here is a property of what got written, and it can move without any skill
firing more often.
