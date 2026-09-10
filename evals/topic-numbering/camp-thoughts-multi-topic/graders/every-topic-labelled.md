# Grader — every topic in a multi-topic reply is labelled

Scored by `tools/topic-numbering.sh`, arithmetic, no model in the loop.

A reply organised into `min_topics` or more sibling sections is a multi-topic reply — two, in
every case here. Sections are found two ways. Headings are always sections; bold lead-ins have
to evidence that they are.

| Reply is built from | Then |
|---|---|
| **Headings** — the shallowest heading level. A lone `# Title` above them is a title and is dropped; deeper headings are a topic's internals | Graded, below |
| **Bold lead-ins**, when there are no headings at all — `**D1 — …**` opening a line, prose may follow | Graded the same way **once the sections are evidenced**: every lead-in labelled, or two or more unlabelled ones numbered. Otherwise not scored |

| Verdict | Condition |
|---|---|
| `NUMBERED` | `min_topics` or more topics, **every one** labelled. The only pass |
| `PARTIAL` | `min_topics` or more topics, **some** labelled. A fail, not part marks — see below |
| `UNNUMBERED` | `min_topics` or more topics, **none** labelled. A fail |
| `SINGLE` | Fewer topics than the case's `min_topics`. Nothing to number at that width; not scored |
| `NOTOPICS` | No sections — including bold lead-ins with **no** labels and no numbering. Not scored |
| `BOLDONLY` | Bold lead-ins, **some** labelled, and fewer than two unlabelled ones numbered. Not scored |
| `CUT` | The runner truncated the reply. Not scored |

**Numbered bold lead-ins are graded, not withheld** —
[#259](https://github.com/Calyx-Engineering/arc/issues/259). The reason the bold form withholds
a verdict is that an unlabelled lead-in is equally a dropped topic and ordinary emphasis. A
lead-in that opens `**2 — What this repo is trying to do.**` is neither: prose does not begin a
paragraph with a number and a dash. So when **two or more unlabelled** lead-ins are numbered,
the ambiguity is absent and the verdict is not withheld — none labelled scores `UNNUMBERED`,
some labelled scores `PARTIAL`. One numbered lead-in among plain ones is a figure in a sentence
and the reply stays `NOTOPICS`.

**The bar is two, and it is not `min_topics`.** `min_topics` is how many topics a case requires
before it is a multi-topic reply at all. Two numbered lead-ins is what makes an enumeration an
enumeration, and a case that set `min_topics: 3` must not silently raise the evidence bar.

**Partial numbering is a fail, not a partial pass.** The label exists so the user can answer
by number without restating the question. A reply that labels its first two topics and drops
the rest has not half-delivered that — the user reading it cannot tell which topics they are
allowed to answer by number, so they restate all of them. Scoring it as half a pass would let
the defect this case exists to catch appear as progress.

**In the bold form that judgement cannot be made where the lead-ins are plain, so it is not
made.** A plain unlabelled bold lead-in is equally a dropped topic and an ordinary emphasis
opening — `**Fails closed.** Any check errors and it does not flip.` — and the skill's own
single-decision template is two unlabelled bold lines. So a bold reply with no labels and no
numbering is `NOTOPICS`, one with all of them labelled is `NUMBERED`, and the ambiguous middle
is `BOLDONLY` and scores in neither column. **Crediting that middle would score the defect as a
pass**, which is the one answer this instrument must never give.

**The one exception is stated with the verdict table above, and only there** — two or more
unlabelled lead-ins numbered, which is the case where the ambiguity this paragraph turns on is
absent. `PARTIAL` is reachable in the bold form on that evidence and on no other.

**A bare number is not a label.** `## 1. Branch from the sub-branch` scores unlabelled and is
reported as a bare number. `skills/chat-response` and `CLAUDE.md` both forbid it: issue
numbers, mechanism numbers and pass numbers appear in the same sentences, so `1` names nothing.
A label is one or two capitals and a number — `D1`, `V2`, `A12` — followed by a separator:
an em or en dash, a colon, a hyphen, a full stop or a closing paren.
