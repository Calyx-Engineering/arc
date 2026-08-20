---
name: chat-response
description: Use when writing any conversational reply to the user — answering a question, reporting what was found, proposing an approach, or considering asking for a decision. Governs length, structure, when to decide rather than ask, linking every issue and PR number rather than writing it bare, and the rules that keep a short answer from becoming an unreliable one. Does not apply to reports, issues, PRs, commits, or code comments.
---

> **Copy — do not edit.** The source is [`skills/chat-response/SKILL.md`](../../../skills/chat-response/SKILL.md),
> which is what the plugin ships. This copy exists only so the skill is live in this repo
> before Arc is installed here. **Edit the source, then re-run `tools/sync-local-skills.sh`.**


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

When a question *is* warranted:

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

**One decision per question.** Bundled questions get partial answers.

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
