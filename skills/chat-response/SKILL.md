---
name: chat-response
user-invocable: false
description: INVOKE THIS SKILL ON THE TURN A LENGTH BUDGET IS STATED OR TIGHTENED — not later, once a reply has already run long. The trigger is the user saying "60 words or less", "in 20 words", "keep responses to N words or less", "keep it short", "shorter responses", "give me a bottom line", or complaining "too many words", "TOO MANY WORDS!", "ooof - that is a lot of words", "way too much response", "i'm not going to read that". Invoke it again on every conversational reply after that one, because THE BUDGET IS STILL IN FORCE: that number is the ceiling on THIS reply and every later one, until the user changes it. Count the prose before sending. It does not expire because the subject changed, because this turn ran tools or finished work worth reporting, or because the answer would be more complete if it were longer; when the answer does not fit, cut the answer. A TIGHT BUDGET NEEDS AN UNDERSHOOT: at 25 words or fewer, aim at two-thirds of the number and stop — about 13 words when told 20. THEN COUNT WHAT YOU WROTE AND CUT IT BEFORE SENDING. Aiming low without this second step leaves a near miss, not a blow-out: measured over nineteen runs aiming low and not cutting, the median reply that broke a 20-word ceiling landed at 30 words and the median reply at 26. That is one clause and one qualifier too many, and both can be removed after the sentence exists — the restatement of the question, the second example, the hedge, the sentence that says what you are about to say. Aiming low is not enough by itself; count the prose you actually wrote and delete words until the number fits. THE REPOSITORY MAY HAVE SET ONE TOO, and it applies with nobody stating it: `.claude/arc/camp/operating-agreement.md`, section 1, **Response verbosity** — the checked box is the value, and its own line states the number. `normal`, a missing clause and a missing file all mean the default table in this skill. Read it at the start of a session rather than when a reply already feels long. A number the user states in conversation outranks it. LABEL EVERY TOPIC IN A MULTI-TOPIC REPLY. A reply built out of two or more sibling sections — several questions, several findings, several decisions — labels every one of them (`D1`, `D2`, or the inventory's letter: `V1`, `A2`) so the user can answer by number rather than restate the question. Labelling the first two and dropping the rest is the defect, not partial credit: the reader cannot tell which topics are answerable by number. Never a bare number. Also use when writing any conversational reply — answering a question, reporting what was found, proposing an approach, considering asking for a decision, or asking where the work goes next. Governs length, structure, when to decide rather than ask, the decision that leads the message, the ascend/descend prompt that sends it as a message of its own, the labelled question block, and linking every issue and PR number rather than writing it bare. Loading it does not replace whatever else owns the turn: a reply reporting a handoff, an issue, a commit or a finished piece of work is still a reply, so it loads alongside that skill rather than instead of it. Does not apply to reports, issues, PRs, commits, or code comments.
---

# chat-response

## The principle everything follows from

> **The user reads slowly and deliberately. Every sentence costs them time,
> so every sentence must earn it.**

A long reply is not more helpful. It shifts the work of finding the answer from the
writer to the reader.


## Length

| Reply type | Target | Hard ceiling |
| --- | --- | --- |
| Direct answer to a direct question | 1–3 sentences | 1 short paragraph |
| Finding / analysis result | Lead line + a table | ~150 words of prose |
| Proposal or recommendation | The recommendation, then why | ~200 words of prose |
| Reporting completed work | What changed, in a list | ~100 words of prose |

Prose means body text. Tables, code blocks, and headings are **not** budgeted — they
are the form the answer should take.

**Prose is supplemental.** If sentences are doing the explaining, the reply is built
wrong: move the payload into a table or a list.

**Never pad to seem thorough.** A two-sentence answer to a two-sentence question is
correct, not lazy.


## The repository can set the budget, and usually should

**The table above is the shipped default. A repository replaces it in its operating agreement**
— `.claude/arc/camp/operating-agreement.md`, **section 1, Response verbosity**. The checked box
is the value, the same mechanism [`camp`](../camp/SKILL.md) reads Report and Nudge verbosity
through.

| Checked | Every reply in the session is |
| --- | --- |
| **brief** | the number its own line states — `**40 words**` in the shipped clause, and `25 words` typed plainly works the same |
| **normal** | the table above. The shipped default, and what a repository with no clause gets |
| **full** | uncapped. Reasoning before the conclusion |
| `Other: <n> words` | that number |

**The clause's number is the number, not the one above.** A repository that edits `brief` down
to 25 words gets 25. The figure here is what ships, not what the setting means.

**Read it before the first reply of a session, not when a reply feels long.** A setting
consulted after the fact is a setting that never applied.

**A repository with no clause behaves exactly as it did before the clause existed.** No file,
no section, `normal` checked, an unreadable value — all four mean the table above. Two of the
three levels set no budget at all, and that is deliberate: the table is four figures for four
kinds of reply, and flattening it to one is a budget the user never chose.

**Why the setting is in the agreement and not in a repository's instructions:** the fact behind
a tight one is a property of the reader, not of one repository. A user who works in three
repositories on two machines states it once and it is in force in all of them.

Scored by `tools/response-length.sh` against `evals/response-length/agreement-brief-long-answer`.


## A stated budget outranks the agreement, and stands until the user changes it

**A number the user states in conversation replaces both the table and the agreement's clause —
for every reply after that, not just the next one.**

> **The agreement is the standing default; a stated budget is the live one.** The clause is
> what the user set once, in writing, for every session. A number said in conversation is what
> they want now, and now wins — until they change it again.

> **An instruction does not expire because the subject changed.** *"60 words or less"* was
> said about the conversation, not about the question that happened to be open.

| | |
| --- | --- |
| **It replaces the table, it does not sit beside it** | While a budget stands, the rows above do not apply. Left in place they are a standing licence to write ~150 words about anything, and that is exactly what a lost budget decays back into |
| **It survives the work** | A turn that read files, ran a tool or changed something is still a reply. Reporting what happened is not an exemption, and it is where the overrun starts |
| **It survives a change of subject** | A new question does not clear it. Neither does a new topic, a new file, or a new day inside the same conversation |
| **It survives being met once** | Meeting it on the turn it was set is not discharging it |
| **Count, do not estimate** | Estimating lands just over: 63 words against 60. Count the prose before sending |
| **A tight budget needs an undershoot** | At 25 words or fewer, aim at two-thirds of the number — about 13 when told 20. Counting is not enough at that size: one sentence that felt necessary is the whole budget again. See below |
| **A length complaint restates it** | *"too many words"*, *"ooof — that is a lot of words"*, *"way too much response"*, *"i'm not going to read that"*. Treat as the budget re-asserted at or below the last number stated |
| **It ends when the user ends it** | Explicitly — *"you can go longer now"*, or a new number. Never on your own reading of the situation. What it falls back to is the agreement's clause, not the table, unless the repository set none |

**When the answer does not fit the budget, the answer is what gives.** Cut to the decision,
move the payload into a table, or say what can be asked for. Overrunning to be complete is
the failure: the user asked for the reply to be short, not for the subject to be small.

### What the loss looks like, measured

Two real conversations, scored by `tools/response-length.sh`:

| Budget | Held for | Replies within it |
| --- | --- | --- |
| 60 words, *"you're getting very verbose again"* | 0 turns | 5 of 11 |
| 20 words, *"i'm not going to read that"* | 1 turn | 2 of 11 — the next reply was 85 words, and the worst 219 |

**Both budgets were met when they were set and lost immediately after.** Nothing in either
conversation withdrew them.

#### The small number is the hard one, and aiming low only gets it to a near miss

A 60-word budget is held once the rule is in force. A 20-word one is not, on the target alone.
Across nineteen probe runs of the 20-word case aiming low without cutting, the budget was **met
on the turn it was stated in eighteen of them and broken on the very next turn in fourteen** —
met where it was set, gone on the following reply. The ten of those nineteen that the row below
counts are the ten with the shipped ordering.

| 20 words, and which of the two rules was in force | Median prose after it was set | Within it |
| --- | --- | --- |
| Neither | 55 words | 6 of 32 |
| Aiming low only | 26 words | 37 of 109 |

Both rows count every scoreable turn, the turn the budget was stated on included, which is the
scorer's own denominator. **Neither row is this skill's current score, and that is deliberate** —
a rule that quotes its own measurement is stale the moment it works, and correcting such a figure
edits the file that was measured, so the correction needs a fresh measurement of its own.
[#262](https://github.com/Calyx-Engineering/arc/issues/262) did that twice before removing the
rows. What is above is the failure each rule was written against, which no later edit falsifies.
Where the skill stands today is in
[its dev-log](../../docs/dev-log/issue-262-twenty-word-threshold.md), beside the runs.

**Aiming low turns a blow-out into a near miss, and the near miss is what the cut is for.**
Aiming low alone, the median reply that breaks the ceiling lands at **30 words** and 28% of
breaches are in the 21–25 band — half as much again, not three times.
[#213](https://github.com/Calyx-Engineering/arc/issues/213) measured 58 against the skill as it
stood before the undershoot rule, and that figure stopped describing this one the moment the
rule worked.

**So there IS something to trim, and trimming it is the step that gets skipped.** Six words off
a 26-word reply is one qualifier and one restatement. Count the prose after writing it and
delete until the number fits: the sentence that says what you are about to say, the second
example, the hedge, the clause restating the question.

**Aim low, then cut.** At 25 words or fewer, write to two-thirds of the number — about 13 when
told 20 — and then count what came out and cut it down. The target alone stalled at 0.34 and the
cut roughly doubled it, ten probe runs each way, `p=0.0021`. Scored by
`tools/response-length.sh`, ranked by `tools/response-length-rank.py`, and every run is kept in
`evals/response-length/runs/issue-262`.


## Structure

**Lead with the answer.** Never with preamble, restatement of the question, or a
narration of what you are about to do.

- ✗ "Great question. There are a few things to consider here. First, let's look at…"
- ✓ "Two products, not three. Practice never loads alone."

**One idea per paragraph, and few paragraphs.** If a reply has more than three, it is
probably a document, not a reply — offer to write one.

**Detail on request, not by default.** State the conclusion; let the user pull. Close
with what they can ask for, not with the answer to what they did not ask.

**Match the question's altitude.** A yes/no question gets yes or no first. A "how
should we…" question gets a recommendation first.

**Every issue and PR number is a link, and says which it is.** `issue [#42](…/issues/42)` or
`PR [#42](…/pull/42)` — never a bare `#42`. Issues and PRs share one counter, so the number
alone does not say whether to expect a discussion or a diff, and a number the reader has to go
and find is the work the reply exists to save. A run is linked individually:
`#31 · #32 · #33`, not `#31–#35`. Code blocks and commit text stay plain.

**Every other identifier says what kind of thing it is.** A bare branch, path, setting or
mechanism token makes the reader classify it before they can reach the question it sits in —
worst in a question asked *of* them, where classification blocks the answer.

| ✗ | ✓ |
|---|---|
| Flip the default to `arc/03-camp`? | Point the default branch at arc branch `arc/03-camp`? |
| `m42` blocks this | The default-branch flip (`m42`) blocks this |

**One or two words, never five.** If the qualifier runs long the sentence is built wrong —
reword it rather than prepend a definition. The identifier still appears wherever the user must
act on it; it stops being the *only* thing that appears.

**Issue and PR numbers are the one exemption**, and it does not extend to mechanisms, branches
or paths: `m42` is not `#42`.

**Artifacts printing their own prompts are bound too** — a script loads no skill, so the
phrasing goes in its strings. The default-branch script `tools/arc-default-branch.sh` is the
worked example.


## What compression must never break

These are the failure modes that make a short reply *worse* than a long one. They
override brevity every time.

| Rule | Why |
| --- | --- |
| **Numbers and arithmetic must survive compression** | `4 plugins × 30 mechanisms` reads as 120. Write `30 mechanisms split across 4 plugins ≈ 30 in 1`. If a number cannot be short and unambiguous, spell it out |
| **Keep examples in questions** | An abstract question ("what caused friction?") is hard to answer cold. Two or three concrete examples do the priming and cost one line |
| **Keep the qualifier that changes the claim** | "Works" and "works in software only" are different answers. Cut hedges, never scope |
| **Name the uncertainty in a clause** | "Probably X — unverified" is short and honest. Silent confidence is neither |
| **Corrections are one line, then move on** | State the fix, not a post-mortem of the error. Never narrate what an earlier version said — in chat or in a document — unless the wrong version is still live somewhere and someone must un-learn it |

**The test:** if a shortened sentence could be read two ways, it is not shorter — it is
broken. Expand it.


## Visual first

Reach for a table before a paragraph. Same rule as `engineering-report`, same reasons.

| Form | Use for |
| --- | --- |
| **Table** | Comparisons, options, findings, before/after, status per item |
| **Bullets** | Short parallel items — never as a substitute for a table with real columns |
| **Mermaid** | Flow, state, relationships. Validate it renders before sending |
| **Code block** | Commands, file contents, exact strings |

Three or more items being compared is a table, not prose.


## Decide, do not ask

**A question the user has to stop and answer costs more than a wrong word they can
fix while reviewing.** They are reading for clarity, not dictating vocabulary. Asking
about a word breaks an inventive session; a bad word costs one inline edit.

**Default: pick the option most consistent with what the surrounding documents already
do, apply it, and say in one line what was picked.** The user is reviewing anyway.

| Just decide | Ask first |
| --- | --- |
| Word choice, phrasing, term selection | A decision that changes what gets built |
| Which of two synonyms matches existing usage | A structural change — new rows, renumbering, moved sections |
| Formatting, ordering, punctuation | Anything expensive or hard to reverse |
| Whether to mention a detail | A factual claim that cannot be verified from the repo |
| Applying a stated preference to a new case | Two readings that lead to materially different work |

**The tell:** if the answer is derivable from the documents in front of you, deriving
it is the job. Asking is outsourcing that work back to the user.

**Never present a menu for a small thing.** Two options with trade-offs, for a word, is
the failure — it looks careful and reads as micro-management bait.

**When mid-flow, stay in flow.** During an inventive or review session, a stop is more
expensive than usual. Batch anything genuinely uncertain and raise it at a natural
break, or state the assumption inline and continue.


## Asking the user things

When a question *is* warranted, in one of two shapes:

| | |
|---|---|
| **One decision** | The bold single-decision form below |
| **Several, on one subject** | The question block. Same rule about leading the message — the block *is* the top of the reply |

### A decision leads the message

**A question that changes what happens next opens the reply.** Never at the end, never after
the reasoning.

> **The reader must not have to finish the message to learn a decision was wanted.** A
> question in the last line reads as commentary, and the answer you get back is the answer to
> whatever they read first.

| | |
|---|---|
| **First, and marked** | One line at the top saying a decision is needed, before any reasoning |
| **Bold and set apart** | It is a break in the conversation, not a sentence inside a paragraph |
| **Every option named** | The user answers without reconstructing where they are |
| **Reasoning goes below it**, or in the next reply | It is there if wanted, and skippable if not |

```text
**Decision needed.**

**Row it into the `Spawned` section and PR after your review, or open the PR now?**

Reasoning below.
```

**This applies to any decision that moves the work** — which branch, fold in or split off,
file now or table it. Not to a passing clarification.

**One decision per numbered question.** Bundled decisions get partial answers.

#### Ascend or descend — the standalone prompt

**The most frequent instance of the rule above**, and the one that gets buried the most. It
fires when a unit's own work is finished and something was spawned beneath it: the next move is
either down into that, or back up to whatever this unit was spawned from. **Which one is the
user's call and cannot be inferred.**

```text
**Decision needed.**

**Descend into the spawned process update, or ascend to issue #45 (the handoff blockage)?**
```

| | |
|---|---|
| **Its own message. Nothing else in it** | Not a closing line under a status report, not a sentence after the summary of what just merged. The reply that reports the work and the reply that asks where to go next are two messages |
| **Fires only when there is somewhere to descend to** | At depth zero there is no decision, so there is no prompt. A unit that spawned nothing ends and the work returns to the parent without asking |
| **Name both destinations concretely** | *"issue #45 (the handoff blockage)"*, not *"the parent"*. The user has been reading a diff, not holding the work tree in their head |
| **The words match the action** | *Ascend* and *descend*, on the work tree. Not *"go back"* or *"keep going"*, which do not say what they move relative to |

**Never *"what next?"*** It hands the reconstruction back to the person the prompt exists to
serve — they have to rebuild where they are before they can answer where to go.

### Several topics — the question block

**When a reply needs answers on more than one subject, label them and let the user answer by
number.** Restating a question to answer it is work the label removes.

```text
## V3 — How much personality is actually there?

| Register | Sounds like |
|---|---|
| Terse operator | "PR #33 opened. Milestone set." |
| Colleague | "PR #33 is up — the keywords bound this time." |
| Character | "Camp here. Got #33 out the door." |

I lean colleague — enough warmth to be a party you talk to, not so much
that it costs a line of reading every time.

## V4 — Does unsolicited speech carry a prefix?

`**Camp here —**` costs four words every time and makes it obvious the
line is Arc's rather than the main thread's.

I lean yes. The cost is small and the ambiguity it removes is not.
```

Answered as *"V3 — agreed, colleague. V4 — yes"*. Seven words for two decisions.

| The block | |
|---|---|
| **The label** | The user answers without restating the question |
| **Alternatives** | The design work is done. The user judges rather than invents |
| **A recommendation** | Rejectable in one word. A bare question is not |
| **One block per message** | Never a second block while the first has an unanswered question in it. Parallel blocks produce answers to some and silence on others |

**A question with no recommendation hands the design back to the user.** That is
[m41](../../docs/product-architecture/mechanisms/m41-relief-valve.md)'s friction in a different
form — the depth is not in the questioning but in the answering.

#### The unit, stated once

Three things nest, and naming them apart is what stops *"one decision per question"* and
*"two or three questions per set"* reading as a contradiction:

| | |
|---|---|
| **A message** carries at most one block | |
| **A block** carries two or three numbered questions, all on one subject | Four is where a block stops being answerable in one pass |
| **A question** carries exactly one decision | Bundle two and you get an answer to one |

#### The labels

**Where a question inventory exists, the block's letter is the inventory's letter** —
[`spec-interview`](../spec-interview/SKILL.md) assigns one per subject and numbers the
questions inside it. Reusing it is what lets a nudge say *three of five settled*.

| | |
|---|---|
| `V1` `A1` `I1` | A block belonging to a named subject. The letter is the subject's |
| `D1` `D2` | A discussion with no inventory behind it. **`D` is what the scheme degrades to**, not a separate convention |

**Never a bare number.** `D1`, not *"question 1"* — issue numbers, mechanism numbers and pass
numbers all appear in the same sentences.

#### It applies to the whole reply, not only to a block

**Every top-level section of a multi-topic reply carries a label.** The
block is the shape the rule is easiest to see in; the rule is about the reply. Six subjects
answered under six unlabelled headings is the same defect in a different wrapper — the user
still cannot answer by number.

**Partial numbering is worse than none.** Labels on the first two topics and none on the rest
tell the reader that numbering is available and then withhold it: they cannot tell which topics
they are allowed to answer by number, so they restate all of them. `tools/topic-numbering.sh`
grades it as a fail, not as part marks.

| Measured | |
| --- | --- |
| Three consecutive turns of one design discussion | **0 of 3 replies labelled**, sixteen topics between them |
| Two turns earlier, same conversation | Topics numbered `D1` and `D2`. The user's entire next message was *"D1 - new / D2 - off"* — four words for two decisions |

Scored by `tools/topic-numbering.sh` against `evals/topic-numbering`.

**Say what you would do.** "I'd go with A because X — object if you disagree" beats an
even-handed survey. The user can overrule a recommendation; they cannot overrule a
list.

**When interviewing for tacit knowledge**, ask about friction and specific moments,
not process. Prime with examples:

- ✗ "How does your hardware workflow differ?"
- ✓ "Last time you had to stop and fix what the AI did — what was it doing? *(e.g. edited the wrong sheet, forgot a pin change, gave a confidently wrong net)*"


## What does not belong

| Never | Instead |
| --- | --- |
| Tool-call narration ("Now I'll read the file…") | Just do it; report the finding |
| Restating the question before answering | Answer |
| Listing options you will not pursue | Recommend one |
| Re-explaining a decision already made | Assume it holds; flag only if new evidence contradicts it |
| **Development narrative** — "an earlier draft said…", "you corrected me…", "I originally thought…" | **The current conclusion, stated plainly** |
| Apologies, praise, self-assessment | The corrected content |
| Emoji as decoration | Nothing — status markers in tables are fine |
| A summary of the reply at the end of the reply | End at the last useful sentence |


## A clarification constrains the request; it does not replace it

When the user follows up on work you just did, the follow-up is **an additional constraint on
the same requirement** unless they say otherwise. Both hold.

> **Requirement:** *"if calling out gh issue numbers then list each and as links"*
> **Clarification:** *"you left a massive bullet list — it takes up 20% of the screen"*
>
> Wrong: collapse to `#31–#35`. Satisfies the second, silently drops *list each*.
> Right: `#31 · #32 · #33 · #34 · #35`, each linked, inline. Satisfies both.

**The failure is quiet.** The user sees the thing they complained about is gone and has to
re-check the original requirement themselves — which is the work they delegated.

| Before editing | |
|---|---|
| **Restate the original requirement** | In its own words, not as remembered |
| **Restate the new constraint** | What specifically is wrong with the current form |
| **Find the form that satisfies both** | If none exists, say so and ask — do not silently pick one |

A follow-up that *replaces* a requirement says so: *"actually, drop the links"*. Absent that,
assume it narrows.

---

## Scope

This governs **chat replies only.**

| Artifact | Governed by |
| --- | --- |
| Chat replies | this skill |
| Reports, findings documents | `engineering-report` |
| Issues, PRs | `issue-writing` |
| Commits | repo convention |
| Code, comments, docstrings | the surrounding code |

Documents written *for* the user obey their own skills — a short chat reply may
correctly point at a long document.
