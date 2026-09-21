# Grader — a numbered reply is not a labelled reply

Scored by `tools/topic-numbering.sh`, arithmetic, no model in the loop. The verdicts, what
counts as a topic and what counts as a label are
[`camp-thoughts-multi-topic`'s grader](../../camp-thoughts-multi-topic/graders/every-topic-labelled.md).
This file records only what this case is for.

**The reply under test is numbered and still fails.** `## 2. What repo trying to do` opens with
a number, a separator and a title, and `2` is the user's step number carried across. It is not a
label: it names a step in the question, not a topic in the answer, and it collides with every
other number in the same sentences — `#2` the issue, `m02` the mechanism, pass 2 of four. The
user asked for numbering in the turn itself and got the one form of it they cannot answer by.
`UNNUMBERED`, with the bare-number count printed beside it.

**A label is one or two capitals and a number** — `D1`, `Q3`, `V2` — so the reply's own text
says which ladder it is on. `skills/chat-response` and `CLAUDE.md` both forbid the bare form.

| Turn | What the reply did | Verdict |
|---|---|---|
| **t1** | Four sections, all four opening with the user's step number | `UNNUMBERED`, 4 bare |
| **t2** | Same four sections, re-answered after a full read. Same numbering | `UNNUMBERED`, 4 bare |
| **t3** | Numbering dropped entirely — three descriptive headings | `UNNUMBERED`, 0 bare |

**This case exists to have headroom, and headroom is the thing being graded.** The suite's other
case scores 1.00 under `--probe` whether or not the fix is installed, so it cannot show the rule
working. Two questions, and only the second is this case's:

| | |
|---|---|
| Does the reply label its topics? | The rate above, threshold 0.67 |
| **Does the rate move when the rule is removed?** | `--compare`, which scores two stored probe runs side by side and says whether they separate |

A case that scores the same on both sides is a regression floor, not evidence. `--compare`
prints that verdict rather than leaving it to a reader holding two runs in their head.
