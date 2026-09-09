---
name: issue-write
description: Use when creating or editing a tracker issue or pull request — GitHub, Jira, Linear or equivalent. Covers what a body contains, how issues link to each other and to a PR, which link mechanics silently do the wrong thing, and the read-back that catches a write that did not land. Invoke before writing any issue or PR body, and before choosing a closing keyword.
camp-reports: [issue-create, issue-edit, pr-open, pr-edit]
checks: [arc-intent, title-size, base-branch, milestone, label, arc-prefix, closing-keyword, placeholder-scan, read-back, read-back-dispositions]
skips:
  - arc-prefix (base is not an arc branch)
  - closing-keyword (the change informs rather than delivers — Refs, not Closes)
  - arc-intent (the current arc has no arc-log)
  - read-back-dispositions (the write is an issue, not a PR)
  - title-size (editing a body, not a title)
  - label (the prefix licenses none — `scope:`, `chore:`, `refactor:`, `test:`)
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
| **Lists of related items are bullets** | Never comma-separated inline. The `Related` section is the exception — it is a table, below |
| **No development narrative** | Not "we tried X then found Y". State Y |

A body that survives this is usually a short paragraph plus one or two tables.

### A PR body carries one section the rules above do not

**The read-back's dispositions.** Step 5 of
[`close-sequence.md`](../../docs/product-architecture/close-sequence.md) reads every changed file
against the issue and returns findings; the body says what happened to each — acted on, or
declined with the reason. **A pass that returned nothing is recorded as having returned
nothing.** That step has no gate, because prose truth is not mechanically checkable, so the body
is the only place it is recorded at all — and silence there is indistinguishable from a step
nobody ran.

**One thing in the body is gated, and it is not the prose.** An unticked box named here as not
done, or as moved to the issue that owns it, is read back by `tools/verify-issue-boxes.sh` —
which [`hooks/tracker-verify`](../../hooks/tracker-verify) runs on `gh pr ready`.

**Copy the box's first eight words, unbroken and in order, then say what happened.** The quote
is what ties the disposition to the box; a reason with no quote reads as prose about something
else, and the check cannot match it to anything.

```markdown
- A read-back step in close-sequence.md, between step 4b — not done, it belongs to the skill
- Selftest cases for every shape the check can meet — moved to #250
```

**Then at least three words the box does not carry.** `— moved to #250` is three; the box pasted
back unchanged is none, and a copied checklist states nothing about what happened to it.
`Box 4: not done` fails on the quote, not the reason.

Punctuation, links and emphasis are all ignored in the comparison — only the words count, so a
box carrying a markdown link keeps the link's text and drops its target.

---

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
| `refactor:` · `test:` | Restructuring with no behaviour change · a gap in what is verified |
| `arc:` · `workstream:` | **Containers, not work.** They hold an ordered list of children and a boundary; nothing merges them. `arc: 04 dogfood — …`, `workstream: Fire — …` |

**A container's title is exempt from the checks below**, and `verify-tracker-body.sh title`
returns clean for both prefixes. Every check asks *does merging this ship the thing the title
names* — a question a container cannot answer, because it never merges. Its children do.

**A container closes when the user says so**, not when its children close. All children closed is
mechanical completion; the boundary is a review, and closing removes the surface it happens on.

**`scope:` is the one that has to exist** — without it a scoping issue takes `feat:` and
inherits a capability-sized title, which is the first failure above. **`spec:` is retired**:
one word per meaning, or the type sorts nothing. `tools/verify-labels.sh` reports an unmapped
prefix, so the retirement is enforced rather than remembered.

### Labels — the prefix decides, and only the prefix

**A label that disagrees with the prefix is worse than no label.** `label:bug` then returns
work that is not a bug and hides work that is.

| Prefix | Label |
|---|---|
| `fix:` | `bug` |
| `feat:` | `enhancement` |
| `docs:` | `documentation` |
| `arc:` | `arc` |
| `workstream:` | `workstream` |
| `scope:` · `chore:` · `refactor:` · `test:` | **none** |

**Licensing nothing is a decision, not an omission.** Nobody filters on a chore, so a label for
one costs attention at every issue write and returns nothing anyone asked for. The test is
whether a query would actually run.

Three labels say what a title cannot, and ride alongside the type label:

| | |
|---|---|
| `in-progress` | A run is working it now. The driver reads it |
| `priority: high` | Blocks or degrades other work. High only — medium is the absence of a label, and nobody queries for the absence of urgency |
| `issue-discipline` | The area. A second area label has to name a query that would run |

**The arc is the milestone, never a label.** A label duplicating it is one more thing to set,
one more thing to get wrong, and nothing the milestone view does not already show.

```sh
tools/verify-labels.sh             every open issue, prefix against label
tools/verify-labels.sh labels      the label set itself
```

**The table above and the script's `MAP` are the same fact.** A new prefix needs both.

**Titles go stale — do not copy them.** When referencing an issue from a document, link the
number and describe it in the document's own words. A copied title silently diverges the
moment the issue is renamed.

**The tracker owns actions.** Acceptance criteria, checklists, next steps and owners live in
the issue and nowhere else. A report states what is known; an issue states what must happen.
Mixing them means neither is trustworthy.

### Retitling — the rule differs by unit, and the units must be named

**An issue title and a PR title are governed in opposite directions.** Both rules below are
right; applying either to the other unit is the failure.

| Unit | Rule | Why |
|---|---|---|
| **An issue** | **Retitle before children exist, not after.** Size it at filing | The title is an identifier other things point at. Once comments, documents and other issues reference it, changing it costs more than the wrong title does |
| **A PR** | **Retitle as the unit grows — mandatory, not a courtesy** | The title is a description of a diff still being written. Nothing points at it but the review about to happen |

**A PR that grows and keeps its first title is unreviewable, whatever its size.**

> **The anti-pattern is not a big PR. It is a unit that grew without its title and description
> growing with it.** A four-file PR that expanded four times and still carries the name of its
> first commit tells the reviewer to expect one thing and hands them another.

**The trigger is a descent** — a discovery that changes what this unit *is*, folded into the
same branch rather than split off. When that happens the title and the description are both
rewritten; *Editing an existing body* below governs the description.

| | |
|---|---|
| **Retitle at the descent, not at review time** | The moment the scope changed is the moment it is cheapest to name, and the only moment you still remember what it was before |
| **A tangent does not trigger it** | Something spotted and recorded as a `Spawned` row, or fixed on this branch because it could not wait, leaves the unit what it was. Only a change to what the unit *is* forces the retitle |
| **The same test applies** | The retitled PR still has to pass *A name, not a summary* above. A title that grew by accretion is the other failure |

### What a good issue contains

**The shape is [`templates/issue.md`](../../templates/issue.md)** — four sections, in order,
each with its purpose, and [`templates/pr.md`](../../templates/pr.md) for a PR. **Copy it; do
not assemble one from memory.** The rules here are grouped by subject, so the positional one —
where `Related` sits — is the furthest from the section list.

**This skill is the judgement and the template is the shape.** Neither repeats the other.

**Spawned work lives in `Related`'s rows, and `Related` is the body's last section — so the
spawn edges are in the last section, at the top of its table.** Not "at the end" as a habit —
last in a stated order, which is what makes a heading appearing after that section a reportable
defect rather than a matter of taste. `tools/verify-tracker-body.sh body`
reports a heading that follows the `Related` section — or a `Spawned` section, in a body written
before this shape. *Related — one table, four kinds* below gives the table's shape.

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
is the higher of the latest issue and the latest PR, plus one.

```sh
tools/new-direct-pr.sh <hint-slug> "<PR title>"
```

**Steps 1 to 4 are one command, and they have to be** — by hand the sequence takes minutes with
a real race running underneath it, which makes *the window is seconds wide* false.

| | |
|---|---|
| 1 | Branch with the predicted number |
| 2 | Commit a **stub** dev-log — a PR needs a commit to exist, and a merged unit needs a dev-log anyway. Writing the real one first is what reintroduces the delay |
| 3 | **Open it as a draft, before doing the work** |
| 4 | Confirm the PR's number against the branch's — **a mismatch is recorded, never retried** |
| 5 | Then work, fill in the dev-log, and mark it ready |

**The draft comes before the work.** Branching, building for an hour and opening the PR at the
end leaves the number unclaimed for that hour, and puts the check *after* everything has landed
on a possibly-wrong branch.

**A miss is never retried.** Retrying burns a real number to buy a tidier branch name, and the
name was only ever a pointer — an explained mismatch points just as well. **The notification is
the fix**, in three places:

| | |
|---|---|
| **The PR body, near the top** | *"Branch says `pr112`, this is PR #114."* Unexplained, the branch is silently wrong. Explained, it is merely inexact |
| **The dev-log** | It already exists — it was the first commit. One line under the problem statement |
| **The friction log**, where the repository keeps one | `docs/arc-work/<arc-slug>/friction-log.md` — [`record-route`](../record-route/SKILL.md) routes it. A race is a fact about the repository and reaches nobody unless written down |

**Rename nothing, close nothing.** See the warning above.

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

**Where that line sits in the body is [`templates/pr.md`](../../templates/pr.md)'s** — last
line, after the spawn rows.

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

**There are two routes, and the repository chooses one.**
[m42](../../docs/product-architecture/mechanisms/m42-default-branch-flip.md) points the default
branch at the arc for its lifetime, and where that is in force keywords bind normally and the
rest of this section does not apply. Where it is not — more than one collaborator, a protected
trunk, no admin rights, or simply nobody flipped it — the manual route below is what runs.
[m12](../../docs/product-architecture/mechanisms/m12-issue-linking.md) §5 holds the comparison.
**Neither is a fallback for the other**; do not propose switching a repository's default branch
because a keyword did not bind.

Two consequences:

- On an issue PR into an arc branch, write the `Closes #NN` line anyway and say in the PR
  that closure defers to the arc PR. See *What the keyword is still for* below.
- **The arc PR into the default branch needs a `Closes` line for every issue the arc
  consumed.** That is the one PR where an empty array is a real bug, and the only place the
  issues actually close.

### The manual route — when a work PR merges into a non-default base

**Do all three, in this order, immediately after the merge.** Not at the arc's close: the click
is the one nobody remembers, and an issue left open reads as work not done.

| | |
|---|---|
| 1 | **Merge the PR.** Nothing binds and nothing closes. `gh pr merge` reports success either way |
| 2 | **Attach the link by hand.** The merged PR → the **Development** panel on its right-hand side → the issue. **No API does this.** No mutation creates or removes a hand-attached link, and `POST /repos/{o}/{r}/issues/{n}/links` does not exist — it 404s with full `repo` scope. This step needs a human, and saying so is part of the step |
| 3 | **`gh issue close <NN>`.** Closing an issue is not an admin operation and needs no special right. Do it after step 2, not before — a closed issue with no link is what `hooks/tracker-verify`'s `close-link` check reports |

**Do not skip step 2 because step 3 closes the issue anyway.** The link is what makes the work
findable from the issue: without it the Development panel stays empty, and an issue that looks
orphaned is indistinguishable from one that was forgotten.

**Two things watch for the step nobody did.** Neither can do it for you.

| | |
|---|---|
| `hooks/tracker-verify`'s `merge-close` | Fires on `gh pr merge` of a PR whose base is neither the default branch nor the trunk — that is, one where no keyword can bind — and reports when the issue its head branch names is still open |
| `tools/arc-link-sweep.sh <milestone>` | The arc-checkpoint sweep — every issue in the milestone that is linked to nothing at all. m12 §4 |

### What the keyword is still for

**On a PR whose base is not the default branch, `Closes #NN` is recorded intent, not a working
link.** It binds nothing, the merge closes nothing, and `closingIssuesReferences` comes back
empty. Write it anyway, on its own last line — *Placement* above is unchanged by the base branch.

| | |
|---|---|
| **What it does** | States which issue this PR was for, in one machine-readable line, in the record that outlives the branch |
| **Who reads it** | The arc PR that later collects this work · `tools/verify-issue-boxes.sh`, which reads the bodies of the PRs that close an issue · a reviewer asking what a merged PR was for |
| **What it does not do** | Close the issue, form a link, or populate the Development panel |

**Say so in the PR body as well as writing the line**, so a reader is not left concluding the
link failed: *"Closure defers to the arc PR — a keyword cannot bind on a base of `arc/NN-slug`."*
Leaving the keyword out to avoid implying a link that does not exist is the wrong trade: it
removes the only statement of what the PR was for and leaves the issue looking orphaned anyway.

**Re-saving the body forces a re-parse, and the parse is not tied to the merge.** It cannot
create a link the base branch forbids — that much still holds, and a failed re-save on an
unflipped base is not a transient problem. But on a base that *is* the default branch it works
after the merge as well as before, which the next section is about. The earlier wording here
implied the opposite.

### A missed keyword is recoverable after the merge

**A `Closes #NN` line added to an already-merged PR still binds** — provided the base was the
repository's default branch. Re-saving the body re-parses it, and the parse is not tied to the
merge. Measured on [#192](https://github.com/Calyx-Engineering/arc/pull/192) and again on
[#215](https://github.com/Calyx-Engineering/arc/pull/215), 2026-09-07.

```sh
gh pr view NN --json body --jq .body > body.md \
  && [ -s body.md ] \
  && cp body.md body.before \
  && printf '\n\nCloses #MM\n' >> body.md \
  && ! cmp -s body.before body.md \
  && gh pr edit NN --body-file body.md

gh pr view NN --json state,closingIssuesReferences        # read it back — then read it AGAIN
gh issue close MM                                          # the link came back; the closure did not
```

| | |
|---|---|
| **The read-back is not instant** | The read immediately after the edit returns an empty array; seconds later it returns the binding. **One read is a false negative** — poll before concluding the recovery failed |
| **It links, it does not close** | The merge event that closes an issue has already fired. #225 stayed open with the reference bound. `gh issue close` is the third command, and the reason this is not the two-command fix it first looked like |
| **It is a keyword link, not a hand-attached one** | `closingIssuesReferences(first:5,userLinkedOnly:true)` comes back empty, so nothing was clicked. The distinction matters because a hand-attached link cannot be removed through the API |
| **Removing the keyword unbinds** | Symmetric, and the reason the check below can restore what it changed |

**This is the repair, not the practice.** A missed keyword is still a defect — it is caught at
PR open, by *Verify* above. What changed is that the documented remedy was hand-linking through
the UI, which needs a human and cannot run unattended. This can.

#### What is still not recoverable

**A PR whose base was never the default branch.** The keyword cannot bind at all, so there is
nothing for a re-save to re-parse — the base-branch rule above is not a timing problem and no
edit gets around it. **The fix is *The manual route* above** — the click and the close, which
work on any base and need no admin right. It is the same route whether the keyword was missed
or could never have bound.

[m42](../../docs/product-architecture/mechanisms/m42-default-branch-flip.md) removes the
question for a whole arc, but only if the flip is already in place before that arc's first PR is
opened — it does not re-parse existing PRs. **So it is never the answer to a PR that has already
merged, and never something to propose because one keyword did not bind.** Whether a repository
runs with the flip is a decision made once, at arc start, by the user.

**The claim is a test, not a memory.**
[`tools/tracker-cases/binding/merged-pr-keyword-bind.md`](../../tools/tracker-cases/binding/merged-pr-keyword-bind.md)
carries it, and `tools/verify-tracker-body.sh live-bind <merged-pr> <issue>` runs it against the
live API and restores what it changed. `verify-all.sh` does not run it — it writes to the
tracker — and `selftest` names it as not covered rather than passing over it.


---

## Verify — the step that is not optional

Never assume a write landed. This is the same behaviour already applied routinely to file
edits, and the asymmetry is the whole finding:

| | File edit | Tracker write |
|---|---|---|
| Verification | The tool errors if the match fails | The API returns success regardless |
| Visibility | The diff is in front of the user | Lives on a website nobody re-opens |
| Detection | Immediate | Only when someone happens to look |

**A milestone item is one unit of work, so a PR that closes an issue takes no milestone.**
The issue is the unit and already carries it; giving the PR one counts the same work twice and
ticks twice when it lands. A direct PR has no issue behind it, so it is the unit — set its
milestone at creation, `gh pr create --milestone "<name>"`, or it drops out of the milestone
view, which is the only place a human sees the arc as one unit.

| PR | Milestone |
|---|---|
| Carries a closing keyword | None |
| No closing keyword — a direct PR | Required |

**The keyword decides it, not whether the link bound.** On a base other than the default
nothing binds and closure defers to the arc PR — but the issue exists and carries the
milestone either way.

**Side effect worth having: a PR in the milestone is, by definition, a direct PR.** The view
had no other way to tell the two apart. `hooks/tracker-verify`'s `milestone` check reports
both directions. #204.

**The fields set at creation rather than written into the body — milestone, base, label — are
listed at the top of [`templates/issue.md`](../../templates/issue.md) and
[`templates/pr.md`](../../templates/pr.md).** Each is invisible once missed, which is why they
are named where the body is assembled and not only here.

After **every** create or edit:

```sh
gh issue view <N> --json body,title
gh pr view <N> --json body,closingIssuesReferences,baseRefName
```

Compare against intent and **report the mismatch — do not silently retry.** A silent retry
turns one visible failure into two invisible ones.

### Scan what you wrote

Three of the seven evaluation cases are mechanically catchable. Before and after writing:

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

`hooks/tracker-verify` runs the mechanical half on `gh issue create|edit|close`, on
`gh pr create|edit`, on `gh pr ready` and on `gh pr merge`. The judgement half — *does this
match what we agreed* — is this skill's.

---

## Actions agreed in conversation

Two of the seven cases are not verification failures. **The write never started.** Something
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
gh issue view NN --json body --jq .body > body.md \
  && [ -s body.md ] \
  && cp body.md body.before \
  && python edit.py body.md \
  && ! cmp -s body.before body.md \
  && gh issue edit NN --body-file body.md

gh issue view NN --json body --jq .body | grep -n 'the thing you changed'
```

**The commands are independent, and that is the trap.** Run separately, a middle command that
dies leaves the last one running against the file an earlier one wrote — `gh` writes the
**original** body back and reports success. **Guard the write-back:** chain it on the edit's
exit status, or compare the file against a copy taken before the edit. The snippet above does
both, because neither alone covers everything: `&&` misses an edit that exits 0 having changed
nothing, and `cmp` misses nothing but is the one people drop.

**Guard the read as well, in the same chain.** A failed `gh issue view` leaves an empty
`body.md` — the redirect truncated it before the command failed — and no `body.before` at
all. `cmp` against a missing file exits **2**, so `! cmp` is *true* and the write-back runs
anyway. `[ -s body.md ]` stops it, and it has to be **one chain**: split in two, the read's
failure never reaches the write.

**The failure is the edit step failing, not only a path the next step cannot see.** A reader
who wrote the file to a shared, visible path concludes the trap does not apply, and it still
does. 2026-08-20, three times in one session: twice the editing step raised `SyntaxError`
before touching the file, once a redirect went somewhere the interpreter could not see. Every
time `gh` printed the issue URL and every time the body was unchanged.

| Why the edit step dies | |
|---|---|
| **A Windows path in a non-raw string literal** | The repeat offender. `"C:\Users\..."` and `"R:\arc-transcripts\"` — `\U` and `\a` are escapes and a trailing `\` eats the closing quote, so the interpreter fails at **parse** time, before any edit runs. Use a raw string, forward slashes, or keep the path out of the source |
| **A path a later step cannot see** | Write the temp file somewhere the shell and any helper agree on. Git Bash's `/tmp` is not a Windows interpreter's `/tmp` |

**The read-back stays mandatory regardless.** It is the detector, not the fix — it caught all
three, and nothing else would have. The guard stops the bad write; the read-back proves it.

### Non-ASCII and the console

Emoji and en-dashes survive `gh` but can be mangled by a Windows console codepage. Write the
body to a file rather than passing it inline.

---

## Related — one table, four kinds

**A body has one `Related` section, it is a table, and it is the last thing in the body.**
There is no separate `Spawned` heading. Spawned work is a row like every other edge, which is
what keeps the spawn edges inside the last section, where the arc-log's tree reads them. **The
section is last; the spawn rows are first within it.**

**The table's shape and its position are [`templates/issue.md`](../../templates/issue.md)'s.**
What follows is which row a given edge takes — the judgement the template does not carry.

**Why the spawn edge is the table's first row:** the first question asked of an issue is where
it came from, and a table is scanned down its first column.

### Four kinds. There is no fifth

| | Means |
|---|---|
| **Spawned by** | The parent — the effort that caused this issue to exist. First row |
| **Spawned** | This effort caused that one to exist |
| **Blocked by** | This cannot start until that one lands |
| **Related** | It exists independently and touches the same area |

**A fifth word is a synonym for one of these.** *Creates*, *Depends on* and *See also* were
each reached for and are each wrong. One word per meaning, or the column sorts nothing.

**The parent's rows use the same table.** The edge is written from both ends and both ends
look identical, so neither side has a second shape to learn.

### `Blocked by #NN` also goes in the body as a bare line

Under the table, on its own line:

```text
Blocked by #136
```

**The driver greps for it.** `| Blocked by | [#136](…) |` splits the words from the number
across two cells, so nothing matching `Blocked by #[0-9]+` finds it. The table is for the
reader and the bare line is for the machine; dropping either loses one of them.

### Spawned — the test is cause, not subject and not surprise

| | Test |
|---|---|
| **Spawned** | This effort caused it to exist. It would not have been filed otherwise |
| **Related** | It exists independently and touches the same area |

**A deliverable counts, not only a discovery.** Something the work needed to exist is spawned
whether or not it was foreseen — [#196](https://github.com/Calyx-Engineering/arc/issues/196)
was created by [#194](https://github.com/Calyx-Engineering/arc/issues/194) and belongs in
#194's `Spawned` rows. *Unplanned* is not the test; *caused* is.

The common error the other way is filtering on **topic** — rejecting a spawned issue because
its subject looks unrelated to the parent. A documentation cleanup discovered while editing a
diagram is spawned: the parent effort is why it exists, whatever it is about.

**Spawned work is not always an issue.** A small fix taken branch-to-PR is spawned work and
gets a row like any other. Two things then carry the link:

| | |
|---|---|
| **The parent's `Spawned` row** | Names the PR, exactly as it would an issue |
| **The PR body** | Carries `Spawned by #NN` — the only place the relationship exists when there is no issue |

Without both, a no-issue PR is invisible to the arc's tree: the tree is built from what
records its own parent, and a PR nobody linked records nothing.

### `Spawned` holds units of work. Nothing else

**A unit of work is an issue, or a PR with no issue.** That is the whole admissible set, and
it has to be stated as a negative — a cause test on its own admits anything session-shaped.

| Not a unit of work | Where it belongs |
|---|---|
| **A discarded approach** | The dev-log, as a decision. Ruling something out is not filing work |
| **An option raised in conversation** | Nowhere yet. Writing it down does not promote it to work |
| **A document produced by the work** | Nowhere. It is an output of the unit, not a unit of its own |
| **A known limitation of a tool** | The dev-log. It becomes a row only when someone files the issue to fix it |

**Observed in ROADZ: eight corrections between 2026-08-14 and 2026-09-05.** Documents, a
discarded approach the dev-log had already ruled out, and loose decisions were all added as
spawned work — while issues that did belong were missed. It is case 7 of the evaluation set.

**This does not weaken the rule below.** A row for real work that was decided against stays,
marked. What is barred is a row that was never work.

### A row that was decided against stays, marked

**Never delete a `Spawned` row.** When the work is abandoned — folded into something else,
ruled out, or overtaken — mark it in the first column and leave it where it is.

```markdown
| **Spawned — abandoned**, folded into #78 | #94 | a dev-log for every merged unit |
| **Spawned — abandoned**, disproved by PR #111 | #102 | the shared `temp/` branch, to retarget a PR's head |
```

| | |
|---|---|
| **At the front of the row**, never at the end | A table is scanned down its first column. A marker in the last cell is found only by someone already reading the row they were going to read anyway |
| **Say what happened to it**, not only that it stopped | *Abandoned* alone leaves the next reader to re-derive whether it was wrong, done elsewhere, or deferred — which is the work the row exists to save |
| **A deleted row loses the spawn edge** | The tree is built from recorded relationships, so a removed row does not become an unspawned discovery. It becomes one nobody can see was ever considered |

**A record of what was chosen against is worth more than a tidy table.** The spawn rows are a
growing definition of what this work turned out to be, not a to-do list that gets cleared
down — so length is evidence, and pruning it destroys the evidence.

---

## Editing an existing body

Read it first and patch the section you mean to change — bodies drift and other people edit
them.

When a PR's content has moved past its description, rewrite the description to describe **the
endpoint, not the starting point.** Reviewers read it before the diff.

---

## The evaluation set

Seven real cases with checkable outcomes, in
[m13](../../docs/product-architecture/mechanisms/m13-issue-write-back.md). **Any change to
this skill is tested against them.** Cases 1–2 are *never written*; cases 3–6 are *written
wrong and reported right*; case 7 is *written right into the wrong place* — spawn rows
populated with things that were never work, which no read-back catches because the body
matches the intent and the intent was wrong.

The base-branch case above is the eighth, and the first isolated by this repo's own work.

---

## Platform mechanics

Everything above is tracker-agnostic. Syntax and quirks:

- GitHub — [`references/github.md`](references/github.md)

Repository-specific facts — which branch is default, which milestone is live — belong in the
repository's own instructions, not here.
