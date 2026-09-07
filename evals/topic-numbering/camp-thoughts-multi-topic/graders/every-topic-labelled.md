# Grader — every topic in a multi-topic reply is labelled

Scored by `tools/topic-numbering.sh`, arithmetic, no model in the loop.

A reply organised into two or more sibling sections is a multi-topic reply. Sections are found
two ways, and only the first is fully gradeable.

| Reply is built from | Then |
|---|---|
| **Headings** — the shallowest heading level. A lone `# Title` above them is a title and is dropped; deeper headings are a topic's internals | Fully graded, below |
| **Bold lead-ins**, when there are no headings at all — `**D1 — …**` opening a line, prose may follow | Three outcomes only, and `PARTIAL` is not one of them |

| Verdict | Condition |
|---|---|
| `NUMBERED` | Two or more topics, **every one** labelled. The only pass |
| `PARTIAL` | Headings, two or more topics, **some** labelled. A fail, not part marks — see below |
| `UNNUMBERED` | Headings, two or more topics, **none** labelled. A fail |
| `SINGLE` | One topic. Nothing to number; not scored |
| `NOTOPICS` | No sections — including bold lead-ins with **no** labels at all. Not scored |
| `BOLDONLY` | Bold lead-ins, **some** labelled. Not scored |
| `CUT` | The runner truncated the reply. Not scored |

**Partial numbering is a fail, not a partial pass.** The label exists so the user can answer
by number without restating the question. A reply that labels its first two topics and drops
the rest has not half-delivered that — the user reading it cannot tell which topics they are
allowed to answer by number, so they restate all of them. Scoring it as half a pass would let
the defect this case exists to catch appear as progress.

**In the bold form that judgement cannot be made, so it is not made.** An unlabelled bold
lead-in is equally a dropped topic and an ordinary emphasis opening — `**Fails closed.** Any
check errors and it does not flip.` — and the skill's own single-decision template is two
unlabelled bold lines. So a bold reply with no labels is `NOTOPICS`, one with all of them
labelled is `NUMBERED`, and the ambiguous middle is `BOLDONLY` and scores in neither column.
**Crediting that middle would score the defect as a pass**, which is the one answer this
instrument must never give.

**A bare number is not a label.** `## 1. Branch from the sub-branch` scores unlabelled and is
reported as a bare number. `skills/chat-response` and `CLAUDE.md` both forbid it: issue
numbers, mechanism numbers and pass numbers appear in the same sentences, so `1` names nothing.
A label is one or two capitals and a number — `D1`, `V2`, `A12` — followed by a separator:
an em or en dash, a colon, a hyphen, a full stop or a closing paren.
