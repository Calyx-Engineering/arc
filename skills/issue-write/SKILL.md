---
name: issue-write
description: Use when creating or editing a tracker issue or pull request — GitHub, Jira, Linear or equivalent. Covers what a body contains, how issues link to each other and to a PR, which link mechanics silently do the wrong thing, and the read-back that catches a write that did not land. Invoke before writing any issue or PR body, and before choosing a closing keyword.
camp-reports: [issue-create, issue-edit, pr-open, pr-edit]
checks: [arc-intent, title-size, base-branch, milestone, arc-prefix, closing-keyword, placeholder-scan, read-back]
skips:
  - arc-prefix (base is not an arc branch)
  - closing-keyword (the change informs rather than delivers — Refs, not Closes)
  - arc-intent (the current arc has no arc-log)
  - title-size (editing a body, not a title)
---

# Writing issues and pull requests

> **Every mechanism here fails silently.** A wrong closing keyword, a stale hand-made link,
> a scripted edit that never landed — each reports success and does the wrong thing. That is
> why the read-back is a step, not a courtesy.

---

## Before the write — does this belong in the arc?

Filing an issue and opening a PR are two of the intent check's firing moments. **Run
[`arc-intent`](../arc-intent/SKILL.md) before the write, not after**, and let it classify.

**It never blocks the write.** An *escalate* is a question put to the user with the body ready
to go — what it prevents is filing silently while the arc's stated scope says otherwise.

---

## Body content

| Rule | |
|---|---|
| **State the defect, the work, the constraints** | Nothing else |
| **Cut every sentence explaining why a problem is a problem** | If the defect is stated, the reader supplies the why |
| **Tables and checklists over prose** | Prose is the fallback, not the default |
| **Draft, then delete** | Remove every line a competent engineer already knows. This usually halves it |
| **Lists of related items are bullets** | Never comma-separated inline |
| **No development narrative** | Not "we tried X then found Y". State Y |

A body that survives this is usually a short paragraph plus one or two tables.

## Titles

**A title names the deliverable, at the size merging actually delivers it.** The reader is
scanning a milestone list weeks later — no body, no conversation, no arc context.

**The check is the closing keyword's, asked one step earlier:**

> **Does merging this ship the thing the title names?**

`Closes` asks it of a change; the title asks it of the issue.

### Two failures, one rule

| | **Claims more than merging delivers** | **Describes the deliverable instead of naming it** |
|---|---|---|
| **Looks like** | `feat: Camp — the delivery assistant`, on an issue that delivered a scoping decision | `feat: carry work navigation in issue-write, decompose, chat-response, record-route, CLAUDE.md and m21 (m46)` |
| **Costs** | The parent stays open across every child, so the milestone shows one perpetually incomplete item instead of steady progress | Word salad — harder to scan than the vague title it replaced |
| **Instead** | `scope: Camp — obligations, documents, and the build decomposition` | `feat: work navigation artifacts (m46)` |

**Only the second is visible in the title alone.** *"the delivery assistant"* is a fine name
for something that ships in one merge — what makes it a false promise is the body underneath
it. `verify-tracker-body.sh title` needs the body file to catch the first, and even then only
where the body says outright that it decomposes. The first failure is judgement; the second is
mechanical.

### A name, not a summary

**The second failure is what *comprehensible cold* over-corrects into.** Told a title must
stand alone, the reflex is to put the explanation in it — the mechanism, the consequence, the
affected files, every one of them body material.

| | |
|---|---|
| **A title identifies; the body explains** | It has to be findable in a list, not understood from the list |
| **Length is the tell** | Past roughly eight words it has stopped naming and started explaining. `verify-tracker-body.sh title` reports at twelve — the mechanical check takes only the cases judgement would not argue about |
| **No clause after the deliverable** | *"…and nothing catches it"*, *"…so X applies without being taught"* — cut at the deliverable |
| **Do not list the files** | Six artifacts in a title is the body's table, inlined |
| **No invented vocabulary** | A term coined in the conversation that produced it means nothing in a list |
| **A verb the work performs** | *"Add"*, *"keep"*, *"say"*, *"verify"* — not a bare noun phrase |

**The test: read the title alone, out loud, to someone who has not seen the body.** If they
cannot say what would change when it merges, it is too vague. If they need a second breath,
it is too long. `fix: a spawned issue records no parent` passes both.

### Types

| | |
|---|---|
| `scope:` | The output is a decision or a decomposition — the specification, not the thing it specifies |
| `feat:` · `fix:` · `docs:` · `chore:` | New construction · repair · documentation · housekeeping |

**`scope:` is the one that has to exist** — without it a scoping issue takes `feat:` and
inherits a capability-sized title, which is the first failure above. **Not `spec:`**: one
word per meaning, or the type sorts nothing. Whether the rest of the conventional set earns
its keep stays open until a month of real use answers it.

**Retitle before children exist, not after** — once a title is referenced from comments,
documents and other issues, changing it costs more than the wrong title does. Size it at
filing.

**Titles go stale — do not copy them.** When referencing an issue from a document, link the
number and describe it in the document's own words. A copied title silently diverges the
moment the issue is renamed.

**The tracker owns actions.** Acceptance criteria, checklists, next steps and owners live in
the issue and nowhere else. A report states what is known; an issue states what must happen.
Mixing them means neither is trustworthy.

### What a good issue contains

| Section | Holds |
|---|---|
| Opening | The defect or the need, in one or two sentences |
| **Required** | What must be true when this is done. Checklist if there are several |
| Constraints | Numbers, parts, interfaces, standards — as a table |
| Related | Bulleted issue links, each with a few words on the relationship |

**A `scope:` issue carries one more thing: the question inventory.** Every subject the spec
cannot be written without, as a checklist, checked off as each is settled.
[`spec-interview`](../spec-interview/SKILL.md) owns the loop; the issue is where its count
lives, because a chat window ends and the tracker does not.

---

## Closing keywords — the deliverable test

Before writing `Closes`, ask:

> **Does merging this ship the thing the issue asked for?**

| Answer | Keyword |
|---|---|
| Yes — the issue's deliverable is in this change | `Closes` |
| No — this informs, analyses, or partially advances it | `Refs` |
| There is no issue | **Neither.** A PR can stand alone |

A design report, an investigation, or a spike almost never closes a capability issue. An
issue titled *"Add X capability"* closes when X ships, not when X is specified.

**When in doubt use `Refs`.** A missed auto-close costs one click; a wrong auto-close
silently closes live work and nobody notices until someone looks for it.

**Not every PR needs an issue.** A small fix found while doing something else goes branch to
PR directly — filing an issue to close it in the same hour is ceremony. File one when the work
needs scheduling, discussion, or a place to accumulate before it starts.

**A no-issue PR's branch still carries a number.** The branch name is often the only reference
visible — an editor's status bar truncates early, and it is where the work is named while the
PR is being read in a browser.

```text
arc/<nn>-<slug>-issue-<NN>-<hint>    an issue exists — use its number
arc/<nn>-<slug>-pr<NN>-<hint>        no issue — the PR number is the only identifier
```

**The `pr` label is not decoration.** Issues and PRs share one counter, so a bare number does
not say which object it names.

**The number does not exist yet when you branch — predict it, then confirm.** The next number
is the higher of the latest issue and the latest PR, plus one. Branch with it, open the PR
immediately, and check the two agree. If they drifted, **close the PR and re-open on a
corrected branch** — one number burned, nothing merged.

> **Never rename the branch of an open PR. It closes the PR.** Tested: the rename succeeds,
> the branch moves, and GitHub closes the PR whose head just disappeared.

[m46 §9.1](../../docs/product-architecture/mechanisms/m46-work-navigation.md) carries the
detail. **A branch naming a PR that is not its own is worse than one naming nothing.**

### Placement

The keyword needs the number immediately after it, on its own line, at the end of the body:

```text
Closes #42
```

Parsers do not understand prose. `Closes the block-diagram item of #26` creates **no link** —
the Development sidebar stays empty and the issue looks orphaned.

When a PR closes exactly one issue, cite it in the title: `<type>: <name> (#42)`. When it
closes several, omit the number from the title and list them in the body. The title number
is cosmetic — the body still needs its own line.

### PR titles inside an arc take the arc's prefix

An issue PR inside an arc is titled:

```text
arc-02: feat: the handoff (#13)
```

**Without it a flat PR list has no thread back to the arc.** Five PRs sharing no visible
name read as five unrelated features, and a human scanning the list cannot see the effort.
The prefix groups arc PRs together and leaves non-arc fixes grouping separately — no labels
needed.

`hooks/tracker-verify` reports a PR into an `arc/*` base whose title lacks it.

---

## The base branch decides whether the link binds

**A closing keyword binds only when the PR targets the repository's default branch.**
Isolated 2026-08-17: two PRs, identical keyword form, one into `main` bound five issues and
one into an arc branch bound none.

This is not a corner case in a nested-branch workflow — it is *every* issue PR.

| Base | Empty `closingIssuesReferences` means |
|---|---|
| The default branch | **A defect.** The link should have formed |
| An arc or integration branch | **Expected.** The link cannot form; it defers to the arc PR |

**The fix is [m42](../../docs/product-architecture/mechanisms/m42-default-branch-flip.md):
point the default branch at the arc for its lifetime.** Where that is in force, keywords bind
normally and the rest of this section does not apply. Where it is not — more than one
collaborator, protected trunk — the following holds.

Two consequences:

- On an issue PR into an arc branch, write the `Closes #NN` line anyway and say in the PR
  that closure defers to the arc PR. The line documents intent even where it cannot bind.
- **The arc PR into the default branch needs a `Closes` line for every issue the arc
  consumed.** That is the one PR where an empty array is a real bug, and the only place the
  issues actually close.

Re-saving the body forces a re-parse of a *stale* link. It cannot create a link the base
branch forbids — do not read a failed re-save as a transient problem.

---

## Verify — the step that is not optional

Never assume a write landed. This is the same behaviour already applied routinely to file
edits, and the asymmetry is the whole finding:

| | File edit | Tracker write |
|---|---|---|
| Verification | The tool errors if the match fails | The API returns success regardless |
| Visibility | The diff is in front of the user | Lives on a website nobody re-opens |
| Detection | Immediate | Only when someone happens to look |

**Set the milestone at creation.** `gh pr create --milestone "<name>"`. A PR without one
drops out of the milestone view, which is the only place a human sees the arc as one unit.
This is unrelated to the base-branch problem and purely an omission — every PR in this
repo's first two arcs was missing it.

After **every** create or edit:

```sh
gh issue view <N> --json body,title
gh pr view <N> --json body,closingIssuesReferences,baseRefName
```

Compare against intent and **report the mismatch — do not silently retry.** A silent retry
turns one visible failure into two invisible ones.

### Scan what you wrote

Three of the six evaluation cases are mechanically catchable. Before and after writing:

| Pattern | |
|---|---|
| `TBD` · `XXX` · `TODO` · `placeholder` · `<value>` · `<link>` | Template scaffolding that survived |
| A number that was meant to change and did not | Diff the old body against the new |
| A date inconsistent with reality | Compare against the current date |
| A referenced commit or issue that does not exist | Check it resolves |
| A closing keyword anywhere but the last line | `tools/verify-tracker-body.sh body <file>` |
| A title that promises what merging will not deliver | `tools/verify-tracker-body.sh title "<title>" [file]` |

The first four patterns are *scaffolding survived*. The last two are the opposite shape —
text that is complete and correct-looking and promises something it should not. Each needs
its own check, because reading for the first four does not surface either.

```sh
tools/verify-tracker-body.sh title "fix: a spawned issue records no parent" body.md
tools/verify-tracker-body.sh body body.md      # before the write
tools/verify-tracker-body.sh binding 54 refs   # after — did intent match what bound?
```

All three report and none blocks. `binding` is the only one that has to run after the write
— it reads the API. `title` and `body` are decidable from text, so running them afterwards
means the wrong thing is already in the tracker.

`hooks/tracker-verify` runs the mechanical half at branch create, PR open, and PR merge.
The judgement half — *does this match what we agreed* — is this skill's.

---

## Actions agreed in conversation

Two of the six cases are not verification failures. **The write never started.** Something
was agreed mid-conversation and had nowhere to go.

> *"i asked you to update #12 with the new component selection. i checked and that didn't
> happe. please do that before we forget again"*

**Capture immediately into the handoff's open threads; file at a checkpoint.** Filing every
provisional remark produces tracker noise; forgetting produces the case above. The handoff
is the buffer between them.

A checkpoint is: issue close, branch change, PR open, session end.

---

## Traps

Each has caused a real failure. None are guessable.

### Negation is not understood

**You cannot write "does not close #42".** The parser matches the keyword and the number and
ignores everything around it, including the word *not*. To say it in prose, avoid the
keyword entirely:

- ✗ "Does not close #42"
- ✓ "This does not complete the capability — the deliverable in #42 is …"

**This trap shipped a defect while this section was loaded and read.** Prose does not stop
it, so the rule is placement rather than phrasing: one keyword, on the last line, checked by
`tools/verify-tracker-body.sh body` before the write. Escaping the keyword is a workaround
for writing *about* the trap in a document, not a fix.

### Hand-attached links are separate from body keywords

A link can come from two independent places: the body keyword, and a link attached by hand
in the UI. **Editing the body has no effect on the second kind** — blanking the entire body
does not clear it.

```sh
gh api graphql -f query='{repository(owner:"OWNER",name:"REPO"){
  pullRequest(number:NN){closingIssuesReferences(first:5,userLinkedOnly:true){nodes{number}}}}}'
```

`userLinkedOnly:true` returns only hand-attached links. **These cannot be removed through
the API** — no public mutation exists. Say so and hand the user the click: PR → Development
panel → ✕.

### A body edit replaces the whole body

`gh issue edit` and `gh pr edit` do not patch. To change one section, read the body out,
edit the file, write it back — and read it back again:

```sh
gh issue view NN --json body --jq .body > body.md
gh issue edit NN --body-file body.md
gh issue view NN --json body --jq .body | grep -n 'the thing you changed'
```

**A redirect to a path a later step cannot see produces an unmodified body, and `gh`
reports success.** Write the temp file somewhere the shell and any helper agree on.

### Non-ASCII and the console

Emoji and en-dashes survive `gh` but can be mangled by a Windows console codepage. Write the
body to a file rather than passing it inline.

---

## Spawned versus related

When work uncovers new work, classify it by **cause, not by subject**.

| | Test |
|---|---|
| **Spawned** | This effort caused the issue to exist. It would not have been filed otherwise |
| **Related** | It exists independently and touches the same area |

The common error is filtering on topic — rejecting a spawned issue because its subject looks
unrelated to the parent. A documentation cleanup discovered while editing a diagram is
**spawned**: the parent effort is why it exists, regardless of what it is about.

Keep spawned work in a `Spawned` section at the end of the parent issue, and say plainly
whether any of it blocks the parent. It is also the raw material for the arc-log's tree.

**Spawned work is not always an issue.** A small fix taken branch-to-PR is spawned work too,
and it belongs in the parent's `Spawned` section like any other row. Two things then carry the link:

| | |
|---|---|
| **The parent's `Spawned` section** | Gets a row naming the PR, same as it would an issue |
| **The PR body** | Carries `Spawned by #NN` — the only place the relationship exists when there is no issue |

Without both, a no-issue PR is invisible to the arc's tree: the tree is built from what
records its own parent, and a PR nobody linked records nothing.

---

## Editing an existing body

Read it first and patch the section you mean to change — bodies drift and other people edit
them.

When a PR's content has moved past its description, rewrite the description to describe **the
endpoint, not the starting point.** Reviewers read it before the diff.

---

## The evaluation set

Six real cases with checkable outcomes, in
[m13](../../docs/product-architecture/mechanisms/m13-issue-write-back.md). **Any change to
this skill is tested against them.** Cases 1–2 are *never written*; cases 3–6 are *written
wrong and reported right*.

The base-branch case above is the seventh, and the first isolated by this repo's own work.

---

## Platform mechanics

Everything above is tracker-agnostic. Syntax and quirks:

- GitHub — [`references/github.md`](references/github.md)

Repository-specific facts — which branch is default, which milestone is live — belong in the
repository's own instructions, not here.
