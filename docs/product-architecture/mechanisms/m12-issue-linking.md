# Mechanism — Tracker Linking Without the Default-Branch Trick

**Status:** partial. Its founding reading of the 2026-08-16 data was struck 2026-09-11 — see
[the test that changes the design](#the-test-that-changes-the-design) — and the `linkedBranches`
read was re-measured and corrected 2026-09-07 — see [the link's lifecycle](#the-links-lifecycle--measured-2026-09-07).
**Home:** Arc — Workspace guard.

**Read `specified` from 2026-08-16 to 2026-09-09, and nothing carried it.**
[#25](https://github.com/Calyx-Engineering/arc/issues/25) shipped
[m42](m42-default-branch-flip.md) in its place — *"this replaces the auto-close hook originally
specced here"* — and closed without touching this file, so the spec read buildable while the
build had gone somewhere else. What exists now, and what does not:

| §4 row | | |
|---|---|---|
| Branch created | `tests/verify-linked-branch.sh <NN> <branch>` | built |
| PR created | `hooks/tracker-verify`'s `closing-keyword` and `pr-base` | built |
| PR merged | `hooks/tracker-verify`'s `merge-close` — a work PR merged with its issue still open | built |
| Arc checkpoint | `tools/arc-link-sweep.sh <milestone>` | built |
| §1–§2's verify-and-repair loop | the re-save, and the judgement about when to repair | **unbuilt** — `skills/issue-write` carries it as instructions to a session |
| §3's link at branch creation | the `createLinkedBranch` call itself | **unbuilt** — `docs/arc-work/04-dogfood/run-instructions.md` §4 tells a run to make it; no artifact does |

**Spawned from:** [friction-transcript-log.md](../../retrospectives/2026-08-plugin-line/friction-transcript-log.md) §2.8, and David's requirement, 2026-08-16.

---

## The requirement

> *"i'm hoping we can establish some more 'manual' control on our part to support this
> arc concept so that we dont have to change default branches. linking issues to PR and
> issues to branches is really powerful and effectively required. having claude *ensure*
> all this is happening will produce consistent operation across repositories and in
> multi-user environments."*

Four things must hold:

1. No repo-global setting changed to make per-arc linking work
2. Issue ↔ PR and issue ↔ branch links both established
3. **The PR targets the right base** — the arc branch, not `main`
4. The agent **verifies** all of it exists, rather than assuming

### Why the merge target belongs here

Same silent-failure class, different symptom. The client repo hit it once:

> *"A PR merged to `main` splits the milestone across two branches — this happened once
> (PR #41) and needed a recovery merge."* — the client repo's `CLAUDE.md`

A wrong base is accepted without complaint and only surfaces when the arc branch turns
out to be missing work. **The check is cheap and belongs at PR creation**, beside the
link verification — one moment, one sweep.

Note this interacts with the default-branch finding below: with the arc branch as repo
default, the base is right by accident. Where [m42](m42-default-branch-flip.md)'s flip is off —
§5 — the check is load-bearing.

---

## The test that changes the design

The client repo set the arc branch as repo default so `gh` auto-links `Closes #NN`, and its CLAUDE.md
records the rule that GitHub *only* honours the keyword when the PR base is the default
branch. This section once read that rule as a belief to be tested; it is the measured rule.

**Measured 2026-08-16.** Two merged PRs, both based on `widget-board/rev_b` (not `main`):

| PR | Base | `closingIssuesReferences` | Created |
|---|---|---|---|
| **#55** | `widget-board/rev_b` | **Linked to #54** | *After* the default switch |
| **#48** | `widget-board/rev_b` | **Empty** | *Before* the default switch |

Same base branch. Opposite outcomes.

### What it proves, and what it was read as proving

This section used to conclude from that table that *"`Closes #NN` works against a non-default
base branch"* — a parse-time quirk, not a base-branch restriction — and that the default-branch
switch was therefore not required. **That reading was wrong, and
[#287](https://github.com/Calyx-Engineering/arc/issues/287) struck it.** PR #55 was opened
*after* the switch, so its base **was** the default at parse time: the table shows
[m42](m42-default-branch-flip.md)'s rule, not an exception to it. Both readings fit the client repo's
data, which is why a re-reading could not settle it.

**Isolated 2026-09-11, in this repository**, on a base that had never been the default —
[`tests/tracker-cases/binding/never-default-base-keyword.md`](../../../tests/tracker-cases/binding/never-default-base-keyword.md):

| PR | Base | Default at the time | `closingIssuesReferences` |
|---|---|---|---|
| [#323](https://github.com/Calyx-Engineering/arc/pull/323) | `probe/287-base`, created for the run | `arc/04-dogfood`, throughout | **Empty** before the merge, after it, and after an unchanged body re-save. The merge left [#322](https://github.com/Calyx-Engineering/arc/issues/322) open |

**So the rule is m42's: a closing keyword binds only when the PR targets the repository's
default branch.** Three states are measured, and they are all that is known:

| Base | Binds | Measured |
|---|---|---|
| Never the default | **No** — not at open, not at merge, not on re-save | #323, above |
| The default throughout | Yes, and a re-save after the merge binds too | [m42](m42-default-branch-flip.md) 2026-08-17; [`merged-pr-keyword-bind.md`](../../../tests/tracker-cases/binding/merged-pr-keyword-bind.md) 2026-09-07 |
| Became the default after the PR was opened | **No** — the flip did not re-parse, and a re-save did not rescue | m42 2026-08-17, five PRs. The client repo's CLAUDE.md claims a re-save does rescue in that repository; not re-run |

The client-repo table above is the second and third rows seen from one repository, not a third rule.

**Consequence: on a base that was never the default, nothing makes the keyword bind.** Not a
re-save, not the merge. Where the flip is not in force the link is verified after creation and,
when absent, made by hand — §5. The earlier consequence stated here, that the switch was not
required, was the claim #287 suspected `skills/issue-write` had inherited. It had not — the skill
already stated m42's rule — and it now cites the measurement.

### A commit message binds too — measured 2026-09-12

**GitHub does not care which write puts the keyword next to the number.** Commit `81b5a41`
([PR #301](https://github.com/Calyx-Engineering/arc/pull/301)) put the word *resolve* and #300's
number in one prose clause of its body. The commit reached the default branch — during an arc
that is the arc branch itself, [m42](m42-default-branch-flip.md)'s flip — and GitHub closed
[#300](https://github.com/Calyx-Engineering/arc/issues/300) with all four of its boxes still
unticked. Same keyword set as a PR body, same parser, and none of the review a PR body gets.
[#336](https://github.com/Calyx-Engineering/arc/issues/336) filed it; `hooks/tracker-verify`
reports a `git commit` whose message carries a closing keyword and a number anywhere but a bare
line, and `skills/issue-write` carries the placement rule.

---

## What the API supports

Tested against the live repo:

| Capability | Endpoint | Status |
|---|---|---|
| Read PR → closing issues | `gh pr view N --json closingIssuesReferences` | ✅ works |
| Read issue → linked branches | GraphQL `issue.linkedBranches` | ⚠️ works, **but only until a PR is opened on the branch** — see [the lifecycle](#the-links-lifecycle--measured-2026-09-07) |
| Sub-issues | `repos/{o}/{r}/issues/{n}/sub_issues` | ✅ responds |
| Force re-parse | Re-save the PR body (`gh pr edit --body`) | ✅ on a base that is the default — measured after a merge, 2026-09-07. On a base that never was, nothing to re-parse — #323 |
| Create branch↔issue link | GraphQL `createLinkedBranch` | ✅ **Tested and works** — see below |
| Remove a link | GraphQL `deleteLinkedBranch`, or delete the branch | ✅ Deleting the branch clears the link automatically — silently, with no timeline event |
| Verify a link, either side | `tests/verify-linked-branch.sh <NN> <branch>` | ⚠️ reads both fields and says which holds the link — but **decisive only before the PR opens**, for the reason in the row above. Not an API capability; a script in this repo |

### `createLinkedBranch` — tested 2026-08-16

Verified against the live repo, then cleaned up.

```graphql
mutation {
  createLinkedBranch(input: {
    issueId: "<issue node id>",
    oid: "<commit sha to branch from>",
    name: "widget-board/rev_b-issue-54-..."
  }) { linkedBranch { id ref { name } } }
}
```

**Three properties that shape the design:**

1. **It creates the branch.** This is not "link an existing branch to an issue" — it is
   "create a branch, linked." No API was found to attach a link to a branch that already
   exists.
2. **Deleting the branch removes the link.** No dangling records; cleanup is automatic.
3. **Opening a PR on the branch moves the link.** It does not survive in `linkedBranches`.
   Measured 2026-09-07 — the next section.

**Consequence for the workflow:** branch creation should go through this mutation
**instead of `git checkout -b`**, then fetch locally. One call yields the branch and the
link together. Retrofitting a link onto an existing branch is not possible, so this must
happen at creation time.

### The link's lifecycle — measured 2026-09-07

`createLinkedBranch` returns a `linkedBranch` node on success. **That return value is not
evidence the tracker holds a link** — it reports what the mutation was asked to do. The run for
[#155](https://github.com/Calyx-Engineering/arc/issues/155) took it as evidence, read
`issue.linkedBranches`, got `totalCount: 0` while the branch was still on the remote, and
concluded the mutation was broken. It was not. **The link had already moved.**

Measured live on [#206](https://github.com/Calyx-Engineering/arc/issues/206) in this repo:

| Moment | `issue.linkedBranches` | PR `closingIssuesReferences` |
|---|---|---|
| After `createLinkedBranch` | the branch, **within one second** | no PR yet |
| After commits are pushed to it | the branch | no PR yet |
| After a **force**-push | the branch | no PR yet |
| **After a PR is opened on the ref** | **empty** | **the issue** |
| After that PR is closed again | empty | the issue |
| After the ref is deleted | empty | the issue |

**Opening a PR from a linked branch promotes the link.** GitHub converts the branch record into
that PR's closing reference, and the branch record is gone from `linkedBranches`. Three
properties of the promotion:

1. **It is one-way.** Closing the PR does not give the branch record back.
2. **It needs no closing keyword.** The probe PR's body was edited down to *"Throwaway probe. No
   issue reference in this body at all"* and `closingIssuesReferences` still read `[206]`. That
   is how a promoted link is told apart from a parsed one.
3. **It is the only `ConnectedEvent` either side gets.** `createLinkedBranch` emits **no**
   timeline event at all, and neither does deleting the ref. So a timeline read cannot
   distinguish a branch link from a PR link — #155's other inference, and also wrong.

**Consequence: an empty `linkedBranches` is a defect before a PR exists and correct after one
does.** Any check that reads one field at one moment reports the opposite of the truth half the
time. `tests/verify-linked-branch.sh` reads both and names which one holds the link; its
selftest is a gate in `tests/verify-all.sh`.

#### The check is only decisive at branch creation

`closedByPullRequestsReferences` is fed by a **keyword-parsed** reference as well as a promoted
one, and every arc PR is required to end with `Closes #NN`. So the moment that keyword exists,
the two are indistinguishable from the tracker. Measured on
[#17](https://github.com/Calyx-Engineering/arc/issues/17), whose branch was made with
`git checkout -b` and which reads as linked through PR
[#139](https://github.com/Calyx-Engineering/arc/pull/139)'s keyword.

| What the read finds | What it proves |
|---|---|
| The branch in `issue.linkedBranches` | The mutation formed the link. **Decisive** |
| A closing PR on that branch whose body has **no** keyword | The link came from the branch — nothing else could have put it there. **Decisive** |
| A closing PR on that branch **with** a keyword | Only that the PR closes the issue. Says nothing about whether the branch was ever linked |

**So the read-back after `createLinkedBranch` is the load-bearing one**, and the same check at PR
time verifies the issue↔PR binding rather than the branch↔issue one. `verify-linked-branch.sh`
prints which of the three it found rather than collapsing them to one verdict.

**What this does to the client-repo survey below is unmeasured.** Its conclusion — `git checkout -b`
never made a link — is unaffected, because a branch that was never linked has nothing to promote.
But the survey counted `linkedBranches` alone, and any client-repo issue whose link *had* been promoted
would have been counted as unlinked. Re-running it needs both fields. Not re-run here; this is the
arc repo.

### The measured state of the client repo

Surveyed all 30 recent issues:

| | Count |
|---|---|
| Issues with a linked branch | **1** (#39) |
| Issues without | **29** |

**#39 is the only one created through GitHub's web UI** ("Create a branch for this
issue"). Every branch made with `git checkout -b` produced no link.

**So issue→branch linking is not broken — it is simply never invoked from the CLI.**
That is the half of the linkage that would make an arc's structure visible from the
issue side, and it is currently unused.

---

## Proposed shape

### 1. Verify, never assume

The core of David's requirement — *"having claude ensure all this is happening."*

```sh
gh pr view <N> --json closingIssuesReferences   # what it means depends on the base — below
```

Run after every PR creation and after any body edit. **Report loudly on failure.** This
is the same silent-success class as
[tracker-write-verification](m13-issue-write-back.md).

**An empty array is not a verdict on its own.** On the default branch it is the defect; on an
arc branch it is the expected reading and closure defers to the arc PR. `hooks/tracker-verify`'s
`closing-keyword` check compares the base before it says which, and a verification that skipped
that comparison would report a finding on every issue PR in an arc — which is a check that gets
turned off.

### 2. Repair rather than reconfigure

If the link is absent **on a base that can carry one**, the fix is a body re-save — not a repo
setting change:

```sh
gh pr edit <N> --body "$(gh pr view <N> --json body -q .body)"
gh pr view <N> --json closingIssuesReferences   # confirm it took — poll; one read is a false negative
```

**On a base that was never the default branch there is nothing to re-parse**, and a re-save is
not a slow repair but no repair at all — measured on
[#323](https://github.com/Calyx-Engineering/arc/pull/323), whose unchanged re-save after the
merge read `[]` on every poll. [m42](m42-default-branch-flip.md) measured the neighbour: five
merged PRs whose base became the default only after a flip stayed unbound, and a re-save did not
rescue those either. §5's manual route is the repair in both states: the Development-panel
click, then the close.

#### A keyword added after the merge — measured 2026-09-07

**A `Closes #NN` line added to an already-merged PR still binds**, provided the base was the
default branch — the parse is not tied to the merge. Measured on
[#192](https://github.com/Calyx-Engineering/arc/pull/192) and again on
[#215](https://github.com/Calyx-Engineering/arc/pull/215). `skills/issue-write` carries the
guarded command; what the two runs showed is here.

| | |
|---|---|
| **The read-back is not instant** | The read immediately after the edit returns an empty array; seconds later it returns the binding. **One read is a false negative** — poll before concluding the recovery failed |
| **It links, it does not close** | The merge event that closes an issue has already fired. #225 stayed open with the reference bound. `gh issue close` is the third command, and the reason this is not the two-command fix it first looked like |
| **It is a keyword link, not a hand-attached one** | `closingIssuesReferences(first:5,userLinkedOnly:true)` comes back empty, so nothing was clicked. The distinction matters because a hand-attached link cannot be removed through the API |
| **Removing the keyword unbinds** | Symmetric, and the reason the check below can restore what it changed |

**What changed is that the documented remedy was hand-linking through the UI**, which needs a
human and cannot run unattended. This can. A missed keyword is still a defect, caught at PR open.

**The claim is a test, not a memory.**
[`tests/tracker-cases/binding/merged-pr-keyword-bind.md`](../../../tests/tracker-cases/binding/merged-pr-keyword-bind.md)
carries it, and `tests/verify-tracker-body.sh live-bind <merged-pr> <issue>` runs it against the
live API and restores what it changed. `verify-all.sh` does not run it — it writes to the
tracker — and `selftest` names it as not covered rather than passing over it.

### 3. Link the branch to the issue explicitly

Do not rely on branch-name convention alone. GraphQL `createLinkedBranch` makes the
relationship real and queryable, which is what makes an arc's shape visible from the
issue side.

### 4. Verify at the moments that already exist

| Moment | Check | Field that holds the answer |
|---|---|---|
| Branch created | Branch↔issue link established — `tests/verify-linked-branch.sh <NN> <branch>` | `issue.linkedBranches` |
| PR created | `closingIssuesReferences` non-empty; base is the arc branch, not `main` | `closingIssuesReferences` — the branch record is gone by now, and that is correct |
| PR merged | Issue actually closed — `hooks/tracker-verify`'s `merge-close`, on a PR whose base is neither the default branch nor the trunk | `issue.state` |
| Arc checkpoint | Sweep all arc issues for missing links — `tools/arc-link-sweep.sh <milestone>` | **both** — an issue before its PR has only the branch record, one after it has only the PR. A `git checkout -b` branch is **not** distinguishable here once its PR carries the keyword |

The arc checkpoint sweep is the one that catches drift accumulated across days.

**Row 3 is the one that only exists where the flip is off.** With [m42](m42-default-branch-flip.md)'s
default-branch flip on, a work PR's keyword binds and GitHub closes the issue at the merge, so
the check would be asking about a state GitHub is already producing. With the flip off nothing
closes it, the merge reports success, and the issue stays open behind a correct-looking
`Closes #NN` in the PR that did the work.

**So the gate is the base against two branches, not one.** A trunk-only test gets the flipped
case backwards, because the flip makes the default branch and the trunk two different branches:

| Base | | |
|---|---|---|
| **= the default branch** | skip | GitHub parses the keyword and the merge closes the issue. With the flip on this is the **arc** branch, so a trunk-only test would run the check here and report that a keyword cannot bind on a base that is the default |
| **= the trunk** | skip | The arc PR. `arc-merge-keyword` is its check |
| neither, or either unreadable | run, or skip on the unreadable | The work PR this row is for. Nothing closes its issue |

**The sweep asks a weaker question than a per-branch check, and permanently so.** Promotion
survives its PR being closed, so an issue that ever had a closing PR reads as linked forever —
[#206](https://github.com/Calyx-Engineering/arc/issues/206) carries closed probe PR
[#219](https://github.com/Calyx-Engineering/arc/pull/219), which closed nothing. Nothing detaches
it: the whole mutation list was grepped 2026-09-07 and holds `createLinkedBranch` and
`deleteLinkedBranch` only, both of which act on branch records, not on closing references. A sweep
therefore finds issues linked to **nothing at all**; asking whether a particular branch is linked
means naming that branch, and getting a decisive answer means asking before the PR exists.

### 5. The default-branch switch is the other option, not a thing to retire

**This mechanism and [m42](m42-default-branch-flip.md) are alternatives, and the choice is made
per repository.** An earlier version of this section said the switch became unnecessary once
verification was in place. That was wrong in both directions: verification does not make a
keyword bind, and the switch is genuinely the cheaper route wherever its preconditions pass.

| | m42 — the flip | m12 — the manual route |
|---|---|---|
| **What it costs** | An admin operation, once at arc start and once at arc close | A click per work PR, and a `gh issue close` after it |
| **What it buys** | Keywords bind natively. Nothing to remember per PR | Nothing repo-global moves |
| **Needs admin rights** | Yes — changing a default branch is an admin operation | No. Closing an issue and attaching a link are not |
| **Multi-collaborator** | No. `git clone` hands a collaborator the arc branch | Yes |
| **Protected trunk** | No. Rules keyed to "the default branch" follow the flip | Yes |
| **Retroactive** | No. [m42](m42-default-branch-flip.md) — the flip must precede the arc's first PR, or that arc's early issues are permanently unlinked | Yes. A merged PR can be hand-linked and its issue closed at any time |
| **Fails** | Silently, if the restore is forgotten | Silently, if nobody clicks — which is what `merge-close` is for |

**Neither is removed and neither is a default.** m42 states that Arc never flips a default branch
on its own; this route is what runs when it has not. Every arc PR targets an arc branch either
way — this repository ran arc 04 with the flip on, `arc/04-dogfood` the default on 2026-09-11.

**The manual route in full**, for a work PR merged into a non-default base:

1. Merge the PR. The `Closes #NN` line in its body binds nothing — see below
2. On the PR, open the **Development** panel and attach the issue. **No API does this** — no
   mutation creates or removes a hand-attached link, tested in
   [m42](m42-default-branch-flip.md), and `POST /repos/{o}/{r}/issues/{n}/links` does not exist
3. `gh issue close <NN>`
4. `tools/arc-link-sweep.sh <milestone>` at the checkpoint, for the ones nobody did

**`Closes #NN` still belongs in the body.** On a non-default base it is recorded intent and not
a working link: it says which issue this PR was for, so a reader of the merged PR — and the arc
PR that later collects it — can see the binding that the tracker does not hold. Leaving it out
to avoid implying a link that does not exist loses the only machine-readable statement of what
the PR was for. `skills/issue-write` carries the same rule for the session that writes it.

The client repo's issue #42 tracks restoring `main` as default at rev B close — that is m42's restore step,
not a step in retiring this.

---

## Why this generalises

David's stated goal is **consistent operation across repositories and in multi-user
environments.** This route reaches repositories [m42](m42-default-branch-flip.md) cannot — which
is why both exist, per §5, rather than why one wins:

| | Default-branch flip | Verify, link and close by hand |
|---|---|---|
| Multi-user safe | ❌ Repo-global state, per-arc intent | ✅ Per-PR |
| Portable across repos | ❌ Needs admin rights to switch | ✅ Needs only PR write |
| Fails loudly | ❌ Silent | ✅ By design |
| Works on Jira / other trackers | ❌ GitHub-specific | ✅ Pattern transfers |
| Cost per work PR | ✅ None | ❌ A click, and a `gh issue close` |
| Cost per arc | ❌ Two admin operations, and a restore that is invisible when forgotten | ✅ None |

**The last two rows are the ones this table used to omit**, and they are why the flip is worth
having: where its preconditions pass it is the cheaper route by a wide margin, and none of the
four ❌ above it apply. The rows above matter for an employer on Atlassian, not GitHub, where the
*mechanism* (assert the link, verify it, repair it) transfers even though the API does not, and
the flip has no analogue at all.

---

## Open questions

| Question | Notes |
|---|---|
| Hook or skill? | Verification is mechanical → hook at PR create/merge. Repair needs judgment |
| What if the user lacks permissions? | David hit this already — *"i dont have authority to do it so i asked [a colleague]"* |
| Sub-issues for in-arc structure? | Lodestar CLAUDE.md already decided sub-issues track in-arc progress. Same API family |
| Multi-user conflict | Two people opening PRs into one arc branch — does anything break? |

---

## Related

- [friction-transcript-log.md](../../retrospectives/2026-08-plugin-line/friction-transcript-log.md) §2.8
- [default-branch-flip.md](m42-default-branch-flip.md) — the other option, §5. Not a replacement in
  either direction; the user chooses per repository
- [issue-write-back.md](m13-issue-write-back.md) — same silent-failure class
- [handoff-spine.md](m15-handoff-spine.md) — arc structure, Projects over Milestones
- [`skills/issue-write`](../../../skills/issue-write/SKILL.md) — the manual route as instructions
  to the session that writes the PR
- The client repo's `CLAUDE.md` — the same workaround, applied there before either mechanism existed; issue
  #42 tracks restoring its default branch
