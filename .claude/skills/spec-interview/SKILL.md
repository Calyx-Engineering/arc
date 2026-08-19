---
name: spec-interview
description: Use when a capability needs a specification and the decisions do not exist yet — scoping a new mechanism, defining an assistant or agent, or any work where an issue says "define X" rather than "build X". Covers the interview that produces the decisions, and the write-up that turns them into a document. Invoke before writing any spec longer than a page.
---

> **Copy — do not edit.** The source is [`skills/spec-interview/SKILL.md`](../../../skills/spec-interview/SKILL.md),
> which is what the plugin ships. This copy exists only so the skill is live in this repo
> before Arc is installed here. **Edit the source, then re-run `tools/sync-local-skills.sh`.**


# Interviewing for a spec, then writing one

Two distinct activities that fail in different ways.

| | Fails as |
|---|---|
| **The interview** — reaching the decisions | Escalating questions with no exit. The human runs out of patience before the scope is settled |
| **The write-up** — turning decisions into a document | Silent drift. The document contradicts decisions made an hour earlier, and nobody notices until a human reads it top to bottom |

> **The write-up is the one that goes wrong quietly.** A bad interview is obvious while it is
> happening. A drifted spec looks finished.

---

## Part 1 — the interview

### Work in labelled question sets

**Two to three questions per set, one set per exchange, each labelled with a letter and a
number.**

```text
V1 — Should unsolicited speech carry a prefix?
V2 — What are the length limits?
V3 — Which register: terse, colleague, or character?
```

The human answers `V1 - agreed`, `V2 - good limiters`, `V3 - colleague`. No restating the
question, no ambiguity about which answer belongs to what.

| Rule | |
|---|---|
| **A letter per subject** | V for voice, W for when-to-watch. The letter is a handle for the whole subject |
| **Two or three questions, never more** | Four is where a set stops being answerable in one pass |
| **Give a recommendation with each** | *"I lean three levels"* — the human agrees or overrides, which is faster than choosing from scratch |
| **State the tradeoff, not the survey** | One sentence per option. If it needs a table, the question is too big |

### One set at a time, and a set is not closed until they say so

A set can reopen. Reopening signals the answer was not actually reached — it is not a failure.

**Never open the next set while the previous one has an unanswered question in it.** Parallel
sets are how an interview becomes an interrogation.

### Write each answer into the spec before asking the next set

**This is the load-bearing rule.** The answer goes into the document while it is still exactly
what was said. Batching answers and writing them up later is where paraphrase enters.

It also gives the human a running artifact to review rather than a transcript to remember.

### Offer the exit

Escalating depth with no relief valve is the failure
[m41](../../docs/product-architecture/mechanisms/m41-relief-valve.md) exists for. Before a
set that goes deeper than the last:

> *"We are three questions into naming. Want me to pick and move, or is this worth settling?"*

**Depth that still serves the goal is not a defect** — it is the work being hard. Ask whether
the direction still holds before asking whether the depth is excessive.

### When the human corrects a premise, stop and rebuild

A correction to a premise invalidates the answers derived from it. Say so, name what is
affected, and re-derive — do not carry forward conclusions built on the corrected premise.

> *"My two-tier split was built on a false premise. Rebuilding it on what is actually true:"*

**Verify before asserting.** An asserted cost model, capability limit or platform behaviour
that turns out to be wrong costs more than the question would have.

---

## Part 2 — the write-up

### The failure this part exists to prevent

A spec written incrementally across a long interview accumulates **archaeological layers**: a
decision reversed at hour three leaves its hour-one text in place, and both read as current.

Observed defects, all from one document:

| Defect | Shape |
|---|---|
| A section contradicting a later decision | *"Form: an agent"* surviving the decision that it is not one |
| An artifact filed under the wrong owner | An event log documented inside its consumer's spec |
| A property merged with its opposite | Obligations filed under *"memory"*, when the whole point was that they are distinct |
| A heading counting wrong | *"Three artifacts"* over a list of four |
| An open question answered elsewhere | *"What is not designed: verbosity"* two hundred lines below the verbosity spec |

**Every one is a contradiction with another part of the same document** — which is what makes
them findable by a single top-to-bottom read, and invisible to incremental editing.

### Revise in place, then re-read whole

| Step | |
|---|---|
| 1 | Write each answer in as it arrives — Part 1's rule |
| 2 | When a decision **reverses** an earlier one, find and fix the earlier text in the same edit |
| 3 | When the interview ends, **read the entire document start to finish** before anyone else does |
| 4 | Check it against the *originating* statement of intent, not only against the decision list |

**Step 3 is not optional and cannot be delegated to the reviewer.** The human reading it is the
last line of defence, not the first.

### What to check on the full read

| Check | Catches |
|---|---|
| **Does each heading describe what is under it?** | Counts, scope words, stale titles |
| **Is every artifact filed under its actual owner?** | Things documented inside a consumer |
| **Does the open-questions section list anything now answered?** | The most common stale section |
| **Does any table's key column contradict a section below it?** | Initiator, status and ownership columns drift first |
| **Do cross-references still point at the right thing?** | A mechanism that moved, an issue that got rewritten |
| **Does it match the one-line summary in the product definition?** | The summary is the contract. If the spec does not read like it, the spec is wrong |

**The last check is the strongest one available.** A top-level synopsis written before the
detail is an independent statement of intent, and a spec that drifted will fail it visibly.

### Write it as a spec, not as a transcript

The document is read later by someone who was not in the conversation, and edited later by
someone looking for where to make a change.

| Not | Instead |
|---|---|
| *"You said you wanted a colleague"* | *"Colleague is selected"* |
| *"We decided to defer this"* | *"Deferred past arc 03"* |
| *"An earlier draft chose an agent, but then…"* | *"Documents, skills and hooks. A resident agent is deferred, not rejected"* |
| A chronology of how the decision was reached | The decision, and the constraint that produced it |

**Keep the reasoning; drop the narrative.** *Why* a decision holds is what makes it
maintainable. *When* it was made is noise — unless a dated revision marker stops someone
re-opening a settled question.

### Structure it for the editor, not the author

A spec grown by insertion ends in insertion order, which is nobody's reading order.

| | |
|---|---|
| **Related things sit together** | If five obligations are specified, all five are in one section |
| **Definition before detail** | What it is, then why, then how |
| **One home per subject** | If two sections derive the same constraint, merge them — duplication is where the next contradiction hides |
| **Open questions last, and honest** | Named gaps are a feature; a spec claiming completeness it lacks is not |

### Verbose only where verbosity earns it

| Deserves length | Deserves a line |
|---|---|
| A decision that reversed, and why | A decision nobody would question |
| A constraint that is not obvious | A restatement of something above |
| A worked example of the thing in use | A second worked example of the same thing |
| A named limitation | An assurance that it will be fine |

**A worked example of what the thing looks like in use is worth more than any amount of
description.** If the spec cannot show a concrete instance, the design is not settled.

### Every core-function section opens with a diagram

**A section that defines what the thing does starts with the diagram, before any table or
prose.** The reader looks at the picture first whether or not it is placed first — a diagram
below a table is a diagram most readers reach having already given up on the table.

> **The diagram is the primary channel. The prose elaborates it.**

| | |
|---|---|
| **Which sections** | Any defining a core function — what the thing does, decides, or produces |
| **Which do not** | Rationale, related work, open questions, anything historical |
| **Position** | Immediately under the heading. Tables and prose follow |
| **Content** | The whole function at one level of abstraction — trigger, decision, outcome |

#### The size budget

| Constraint | |
|---|---|
| **Text must be readable at normal zoom** | The binding constraint. Everything else follows from it |
| **No more than 75% of the vertical screen** | A diagram needing a scroll has stopped being one look |
| **Three or four nodes per row** | Five is where labels shrink past reading size |
| **Three tiers is fine** | Depth is cheap; width is what destroys legibility |

**When it will not fit, the section defines more than one function.** Split the section rather
than shrinking the diagram — a diagram too small to read has failed completely, while two
sections each with a legible diagram have cost nothing.

### Diagram where a relationship is easier shown

Mermaid, per repo convention. Highest-value cases:

| Diagram | When |
|---|---|
| Ownership and dataflow | Several artifacts with different owners, and state that must not be held |
| A decision ladder | Any classification with three or more outcomes |
| Sequential evaluation | Where the order between two checks is itself the decision |
| Trigger to behaviour | What causes the thing to act, and what it does — the reader's first question |

**Diagram what the thing does, not when it will be built.** Ship-now-versus-later is roadmap
and belongs in the issue. A diagram is the reader's instant answer to *what is this*, so it
must spend its space on behaviour.

#### A diagram must read cold

The reader looks at it before the prose around it. **Every label has to carry its own meaning**
— a node that only makes sense once the paragraph below has been read has failed.

| Fails | Reads cold |
|---|---|
| `Events — hooks. Ship first` | `Moments a hook can see` |
| `Precondition fires` | `Signals show the discussion has gone too deep` |
| `Camp fires m15` | `Camp triggers the handoff` |
| `m44 event log` | `The event log — every firing, kept whatever the setting` |

**Never put a bare identifier in a node.** `m15`, `m44`, a file path alone — the reader cannot
click it and it names nothing. Identifiers belong in prose, where they can be links.

#### A subgraph label states why those nodes are grouped

Splitting nodes into boxes to control width, without saying what separates them, reads as an
arbitrary distinction and costs more than the width saved.

| | |
|---|---|
| **Wrong** | Two boxes, one labelled, one blank — the split looks meaningful and is not |
| **Right** | *"Moments a hook can see"* beside *"Only visible in the conversation"* — the grouping is the argument |

**If a grouping cannot be named, it is layout rather than meaning** — use one box, or find the
real distinction.

#### Keep it readable at a glance

A diagram whose text renders too small to read has failed regardless of content.

| Problem | Fix |
|---|---|
| One long horizontal chain | Stack subgraphs, each with `direction LR`, three or four nodes per row |
| A tall vertical chain | Same — wrap it into rows |
| Mixed `TB` outer with `TB` inner | The inner direction must differ from the outer, or nothing wraps |

**Markdown bold does not render inside mermaid nodes.** Use `<b>` tags.

**Colour carries meaning, and the meaning is stated below the diagram.** If purple means *the
user decides*, say so in one line — otherwise it is decoration.

---

## The diagram is the acceptance test

A section's diagram is not only how the reader understands the feature — it is what the build
is checked against.

| | |
|---|---|
| **Draw it so it can be walked** | Every node should be something a builder can point at and say *that exists* |
| **A node with no deliverable behind it is a spec bug** | Found at build time, when it is expensive |
| **Mismatches escalate** | Either the spec was wrong or the build drifted. A human decides which |

**This is why the diagram must state behaviour rather than sequencing.** *"Ships in wave 2"*
cannot be walked against a working artifact; *"names what closing requires"* can.

---

## Closing the loop

| | |
|---|---|
| **Decompose after the spec is right, not during** | An issue filed against a drifting spec inherits the drift |
| **The interview transcript is K4** | Back it up before compaction. It is the only unfiltered record of what was agreed |
| **Where the document and the conversation disagree, the conversation wins** | Until the human has confirmed the document. A spec is a lossy copy until it has been read whole |
