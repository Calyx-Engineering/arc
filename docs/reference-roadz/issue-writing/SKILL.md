---
name: issue-writing
description: Use when creating or editing a tracker issue or pull request — GitHub, Jira, Linear or equivalent. Covers what an issue body contains, how issues link to each other and to a PR, and which link mechanics silently do the wrong thing. Invoke before writing any issue or PR body, and before choosing a closing keyword.
---

# Writing issues and pull requests

> **Every mechanism here fails silently.** A wrong closing keyword, a stale hand-made
> link, a scripted edit that never landed — each reports success and does the wrong
> thing. That is why verification is a step, not a courtesy.


## Body content

| Rule | |
| --- | --- |
| **State the defect, the work, the constraints** | Nothing else |
| **Cut every sentence explaining why a problem is a problem** | If the defect is stated, the reader supplies the why |
| **Tables and checklists over prose** | Prose is the fallback, not the default |
| **Draft, then delete** | Remove every line a competent engineer already knows. This usually halves it |
| **Lists of related items are bullets** | Never comma-separated inline |
| **No development narrative** | Not "we tried X then found Y". State Y |

A body that survives this is usually a short paragraph plus one or two tables.

**The tracker owns actions.** Acceptance criteria, checklists, next steps and owners
live in the issue and nowhere else. A report states what is known; an issue states what
must happen. Mixing them means neither is trustworthy.


### What a good issue contains

| Section | Holds |
| --- | --- |
| Opening | The defect or the need, in one or two sentences |
| **Required** | What must be true when this is done. Checklist if there are several |
| Constraints | Numbers, parts, interfaces, standards — as a table |
| Related | Bulleted issue links, each with a few words on the relationship |

---


## Closing keywords — the deliverable test

Before writing `Closes`, ask:

> **Does merging this ship the thing the issue asked for?**

| Answer | Keyword |
| --- | --- |
| Yes — the issue's deliverable is in this change | `Closes` |
| No — this informs, analyses, or partially advances it | `Refs` |

A design report, an investigation, or a spike almost never closes a capability issue.
An issue titled *"Add X capability"* closes when X ships, not when X is specified.

**When in doubt use `Refs`.** A missed auto-close costs one click; a wrong auto-close
silently closes live work and nobody notices until someone looks for it.


### Placement

The keyword needs the number immediately after it, on its own line, at the end of the
body:

```text
Closes #42
```

Parsers do not understand prose. `Closes the block-diagram item of #26` creates **no
link** — the issue's Development sidebar stays empty and the issue looks orphaned.

When a PR closes exactly one issue, cite it in the title: `<type>: <summary> (#42)`.
When it closes several, omit the number from the title and list them in the body. The
title number is cosmetic — the body still needs its own line.

---


## Traps

These have each caused a real failure. None are guessable.


### Negation is not understood

**You cannot write "does not close #42".** The parser matches the keyword and the
number and ignores everything around it, including the word *not*. Writing a sentence
that disclaims closure is one of the ways to accidentally close an issue.

To say it in prose, avoid the keyword entirely:

- ✗ "Does not close #42"
- ✗ "This does not fix #42"
- ✓ "This does not complete the capability — the deliverable in #42 is …"


### Manual links are separate from body keywords

A tracker link can come from **two independent places**: the body keyword, and a link
attached by hand in the UI. Editing the body has no effect on the second kind.

Symptom: you remove the keyword, and the link is still there. Blanking the entire body
does not clear it either.

On GitHub, tell them apart with:

```sh
gh api graphql -f query='{repository(owner:"OWNER",name:"REPO"){
  pullRequest(number:NN){closingIssuesReferences(first:5,userLinkedOnly:true){nodes{number}}}}}'
```

`userLinkedOnly:true` returns only hand-attached links. **These cannot be removed
through the API** — no public mutation exists. Say so and hand the user the click:
PR → Development panel → ✕.


### The base branch may decide whether the link binds

On GitHub a closing keyword is reported to bind only when the PR targets the
repository's **default branch**. On a long-lived integration branch, PRs then fail to
link and the failure is invisible unless checked.

Changing the default later does not re-parse existing PRs; re-save the body to force
it.

*Observed on one repository, not isolated as a variable. Treat as a likely cause when a
correctly formed keyword produces no link, and confirm by query rather than assuming
either way.*


### Verify, always

Never assume a link formed. After creating or editing:

```sh
gh pr view NN --json closingIssuesReferences
```

Empty array when you expected a link, or a link when you expected none, are both
common. This check costs one call and catches every trap above.

---


## Spawned versus related

When work uncovers new work, record it — but classify it by **cause, not by subject**.

| | Test |
| --- | --- |
| **Spawned** | This effort caused the issue to exist. It would not have been filed otherwise |
| **Related** | It exists independently and touches the same area |

The common error is filtering on topic: rejecting a spawned issue because its subject
looks unrelated to the parent. A documentation cleanup discovered while editing a
diagram, or a test campaign generated by an analysis, are **spawned** — the parent
effort is why they exist, regardless of what they are about.

Keep spawned work in a table at the end of the parent issue, and say plainly whether
any of it blocks the parent.

---


## Editing an existing body

Read it first and patch the section you mean to change — bodies drift and other people
edit them. Then read it back: a scripted edit that never landed reports success.

When a PR's content has moved past its description, rewrite the description to describe
**the endpoint, not the starting point**. Reviewers read it before the diff.

---


## Tracker mechanics

Everything above is tracker-agnostic. Syntax and quirks per platform:

- GitHub — [`references/github.md`](references/github.md)
- Jira — [`references/jira.md`](references/jira.md)

Repository-specific facts — which branch is default, which milestone is live, project
naming — belong in the repository's own instructions, not here.
