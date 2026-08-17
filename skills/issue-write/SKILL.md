---
name: issue-write
description: Use when creating or editing a tracker issue or pull request — GitHub, Jira, Linear or equivalent. Covers what a body contains, how issues link to each other and to a PR, which link mechanics silently do the wrong thing, and the read-back that catches a write that did not land. Invoke before writing any issue or PR body, and before choosing a closing keyword.
---

# Writing issues and pull requests

> **Every mechanism here fails silently.** A wrong closing keyword, a stale hand-made link,
> a scripted edit that never landed — each reports success and does the wrong thing. That is
> why the read-back is a step, not a courtesy.

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

---

## Closing keywords — the deliverable test

Before writing `Closes`, ask:

> **Does merging this ship the thing the issue asked for?**

| Answer | Keyword |
|---|---|
| Yes — the issue's deliverable is in this change | `Closes` |
| No — this informs, analyses, or partially advances it | `Refs` |

A design report, an investigation, or a spike almost never closes a capability issue. An
issue titled *"Add X capability"* closes when X ships, not when X is specified.

**When in doubt use `Refs`.** A missed auto-close costs one click; a wrong auto-close
silently closes live work and nobody notices until someone looks for it.

### Placement

The keyword needs the number immediately after it, on its own line, at the end of the body:

```text
Closes #42
```

Parsers do not understand prose. `Closes the block-diagram item of #26` creates **no link** —
the Development sidebar stays empty and the issue looks orphaned.

When a PR closes exactly one issue, cite it in the title: `<type>: <summary> (#42)`. When it
closes several, omit the number from the title and list them in the body. The title number
is cosmetic — the body still needs its own line.

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

Keep spawned work in a table at the end of the parent issue, and say plainly whether any of
it blocks the parent. It is also the raw material for the arc-log's tree.

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
