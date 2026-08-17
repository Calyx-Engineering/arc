# Mechanism — Tracker Linking Without the Default-Branch Trick

**Status:** proposed. Key assumption **tested and disproved**, 2026-08-16.
**Home:** Arc.
**Spawned from:** [friction-log.md](../friction-log.md) §2.8, and David's requirement, 2026-08-16.

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

Same silent-failure class, different symptom. ROADZ hit it once:

> *"A PR merged to `main` splits the milestone across two branches — this happened once
> (PR #41) and needed a recovery merge."* — ROADZ `CLAUDE.md`

A wrong base is accepted without complaint and only surfaces when the arc branch turns
out to be missing work. **The check is cheap and belongs at PR creation**, beside the
link verification — one moment, one sweep.

Note this interacts with the default-branch finding below: with the arc branch as repo
default, the base is right by accident. Remove that crutch and the check becomes
load-bearing.

---

## The test that changes the design

ROADZ currently sets the arc branch as repo default so `gh` auto-links `Closes #NN`.
CLAUDE.md records the belief that GitHub *only* honours the keyword when the PR base is
the default branch.

**Measured directly, 2026-08-16.** Two merged PRs, both based on
`interface-pcba/rev_b` (not `main`):

| PR | Base | `closingIssuesReferences` | Created |
|---|---|---|---|
| **#55** | `interface-pcba/rev_b` | **Linked to #54** | *After* the default switch |
| **#48** | `interface-pcba/rev_b` | **Empty** | *Before* the default switch |

Same base branch. Opposite outcomes.

### What this actually proves

> **`Closes #NN` works against a non-default base branch.** GitHub parses the keyword
> **when the PR body is written**, against whatever the default branch was *at that
> moment*.

It is a **parse-time quirk, not a base-branch restriction.** The ROADZ workaround was
solving the right symptom with the wrong model — and CLAUDE.md's own recovery note
(*"Changing the default does not re-parse PRs opened before the switch. Re-save the body
to force it"*) is the clue that this is about parse timing.

**Consequence: the default-branch switch is not required.** What is required is that the
link is *verified after creation*, and re-triggered by a body re-save if absent.

---

## What the API supports

Tested against the live repo:

| Capability | Endpoint | Status |
|---|---|---|
| Read PR → closing issues | `gh pr view N --json closingIssuesReferences` | ✅ works |
| Read issue → linked branches | GraphQL `issue.linkedBranches` | ✅ works |
| Sub-issues | `repos/{o}/{r}/issues/{n}/sub_issues` | ✅ responds |
| Force re-parse | Re-save the PR body (`gh pr edit --body`) | ✅ documented in ROADZ CLAUDE.md |
| Create branch↔issue link | GraphQL `createLinkedBranch` | ✅ **Tested and works** — see below |
| Remove a link | GraphQL `deleteLinkedBranch`, or delete the branch | ✅ Deleting the branch clears the link automatically |

### `createLinkedBranch` — tested 2026-08-16

Verified against the live repo, then cleaned up.

```graphql
mutation {
  createLinkedBranch(input: {
    issueId: "I_kwDOPx0jIM8AAAABMoIu6Q",
    oid: "<commit sha to branch from>",
    name: "interface-pcba/rev_b-issue-54-..."
  }) { linkedBranch { id ref { name } } }
}
```

**Two properties that shape the design:**

1. **It creates the branch.** This is not "link an existing branch to an issue" — it is
   "create a branch, linked." No API was found to attach a link to a branch that already
   exists.
2. **Deleting the branch removes the link.** No dangling records; cleanup is automatic.

**Consequence for the workflow:** branch creation should go through this mutation
**instead of `git checkout -b`**, then fetch locally. One call yields the branch and the
link together. Retrofitting a link onto an existing branch is not possible, so this must
happen at creation time.

### The measured state of ROADZ

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
gh pr view <N> --json closingIssuesReferences   # empty ⇒ the link did not form
```

Run after every PR creation and after any body edit. **Report loudly on failure.** This
is the same silent-success class as
[tracker-write-verification](issue-write-back.md).

### 2. Repair rather than reconfigure

If the link is absent, the fix is a body re-save — not a repo setting change:

```sh
gh pr edit <N> --body "$(gh pr view <N> --json body -q .body)"
gh pr view <N> --json closingIssuesReferences   # confirm it took
```

### 3. Link the branch to the issue explicitly

Do not rely on branch-name convention alone. GraphQL `createLinkedBranch` makes the
relationship real and queryable, which is what makes an arc's shape visible from the
issue side.

### 4. Verify at the moments that already exist

| Moment | Check |
|---|---|
| Branch created | Branch↔issue link established |
| PR created | `closingIssuesReferences` non-empty; base is the arc branch, not `main` |
| PR merged | Issue actually closed |
| Arc checkpoint | Sweep all arc issues for missing links |

The arc checkpoint sweep is the one that catches drift accumulated across days.

### 5. Retire the default-branch switch

Once verification is in place, the workaround is unnecessary — and it is the part that
breaks in multi-user repos, since default branch is repo-global state used to encode
per-arc intent.

ROADZ issue #42 already tracks restoring `main` as default at rev B close.

---

## Why this generalises

David's stated goal is **consistent operation across repositories and in multi-user
environments.** Verification-based linking achieves that where the workaround cannot:

| | Default-branch trick | Verify-and-repair |
|---|---|---|
| Multi-user safe | ❌ Repo-global state, per-arc intent | ✅ Per-PR |
| Portable across repos | ❌ Needs admin rights to switch | ✅ Needs only PR write |
| Fails loudly | ❌ Silent | ✅ By design |
| Works on Jira / other trackers | ❌ GitHub-specific | ✅ Pattern transfers |

The last column matters for Dedrone — Atlassian, not GitHub. The *mechanism* (assert the
link, verify it, repair it) transfers even though the API does not.

---

## Open questions

| Question | Notes |
|---|---|
| Hook or skill? | Verification is mechanical → hook at PR create/merge. Repair needs judgment |
| What if the user lacks permissions? | David hit this already — *"i dont have authority to do it so i asked chad"* |
| Sub-issues for in-arc structure? | Lodestar CLAUDE.md already decided sub-issues track in-arc progress. Same API family |
| Multi-user conflict | Two people opening PRs into one arc branch — does anything break? |

---

## Related

- [friction-log.md](../friction-log.md) §2.8
- [issue-write-back.md](issue-write-back.md) — same silent-failure class
- [handoff-spine.md](handoff-spine.md) — arc structure, Projects over Milestones
- ROADZ `CLAUDE.md` — the workaround this replaces; issue #42 tracks its removal
