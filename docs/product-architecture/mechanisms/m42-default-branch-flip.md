# Mechanism — Default Branch Flip

**Status:** partial — the capability is verified by direct test; the restore-failure detection
and the setup conversation are undesigned.
**Home:** Arc — Workspace guard.
**Src:** 🔥 observed.
**Covers:** m42.

---

## The friction

Repeated across weeks, and disbelieved each time it was raised:

> *"i've spoke to you (Claude) about this many times now and keep getting told i'm crazy.
> This is part of the need for this plugin. the 'Closes' doesnt work when it isnt into the
> default branch."* — 2026-08-17

**GitHub ignores a closing keyword unless the PR targets the repository's default branch.**
Their documentation states it outright: *"If the pull request targets any other branch, then
these keywords are ignored, no links are created, and merging the pull request has no effect
on the issues."*

An arc runs issue branches into an arc branch, and the arc branch into the trunk. **Every
issue PR in an arc therefore targets a non-default base by construction** — so every one of
them reports success and links nothing.

| Consequence | |
|---|---|
| Issues stay open after their work merges | Closure waits for the arc PR, or a manual click |
| The Development sidebar stays empty | An issue that looks orphaned is indistinguishable from one that was forgotten |
| Nothing warns you | The keyword is correct, the API accepts it, the PR merges |

---

## What was ruled out first

Three candidates, each tested rather than reasoned about. This section exists so they are not
re-proposed.

| Candidate | Result |
|---|---|
| `POST /repos/{owner}/{repo}/issues/{n}/links` | **The endpoint does not exist.** 404 with full `repo` scope; absent from the issue object's own URL fields |
| A GraphQL mutation attaching a PR to an issue | **None exists.** `createLinkedBranch` covers branches only |
| `tkt-actions/add-issue-links` | **Writes `Resolve #NN` into the PR body** — the exact text GitHub ignores on a non-default base |
| A repository or organisation setting | None found. The behaviour is not configurable |

**The manual UI link is real** — the Development panel accepts a hand-attached link on any
base — but no API creates or removes one, so it cannot be automated.

---

## The mechanism

**Point the default branch at the arc branch for the life of the arc, and restore it at arc
close.**

Verified by direct test, 2026-08-17: with `arc/02-foundation` set as the repository default,
a PR into that branch bound `Closes #25` and produced a real sidebar link. With `main` as
default, the identical PR body bound nothing.

### It is off by default

**Arc never flips a default branch on its own.** It detects that the preconditions pass and
offers once, at arc start. Silently repointing a repository's default branch is not something
a tool should do because it happens to be safe.

---

## Preconditions — all queryable, all must pass

The guard does not ask the user to judge whether it is safe. It checks.

| Check | Query | Why |
|---|---|---|
| **Single collaborator** | `gh api repos/{o}/{r}/collaborators --jq length` == 1 | A second person cloning mid-arc lands on in-progress work instead of the trunk |
| **No branch protection on the trunk** | `gh api repos/{o}/{r}/branches/{trunk}/protection` | Rules keyed to "the default branch" follow the flip |
| **No open PRs targeting the trunk from outside the arc** | `gh pr list --base {trunk}` | Their keywords would begin binding while the default is moved |
| **The arc branch exists on the remote** | `git ls-remote --heads origin {arc}` | A missing branch cannot be made default |

**Fails closed.** Any check failing — or erroring — means no flip, and a stated reason. The
arc still runs; it simply keeps the degraded behaviour that is the status quo today, which is
known-good.

---

## The restore is the dangerous half

A crashed or abandoned session leaves the default pointed at a branch that may later be
deleted. Nothing about that state is visible in ordinary work.

| Guard | |
|---|---|
| **Restore at arc close** | Part of the arc-close checklist, beside the K2/K3 sweep |
| **Standing detection** | Notice *default ≠ trunk while no arc is active* and say so. The handoff is read every cold start, which makes it the natural home |

**The failure is silent, so the detection cannot be.**

---

## What the setup conversation must say

When Arc configures itself in a repository, the offer states the trade plainly — not a
documentation line, an actual conversation with a recorded answer.

| Buys | Costs |
|---|---|
| Closing keywords bind on issue PRs | `git clone` gives a collaborator the arc branch, not the trunk |
| Real Development sidebar links | Branch protection and CI keyed to "default" follow the flip |
| Native auto-close on merge — no hook needed | Forgetting to restore is invisible |
| Milestone and cross-reference unaffected | |

**The single-user condition is what makes it safe**, and it is the first thing that stops
being true as a project grows.

### Every prompt names what kind of thing it is talking about

The offer is printed by a script, and a script loads no skill — so the phrasing rule lives
here and in the strings, not only in `skills/chat-response`.

> *"i know through sentence context i should realize `arc/03-camp` is the **name** of a
> branch, but its a lot of extra cognitive load to search through all of my memory to figure
> out what type of thing `arc/03-camp` could be… then finally make an assesment on your
> question."* — 2026-08-18, [#31](https://github.com/Calyx-Engineering/arc/issues/31)

| ✗ | ✓ |
|---|---|
| Flip the default to `arc/03-camp`? | Point the default branch at arc branch `arc/03-camp`? |
| `main` is protected | trunk branch `main` is protected |
| `arc/03-camp` is not pushed | arc branch `arc/03-camp` is not pushed |

**The qualifier is one or two words** — *arc branch*, *trunk branch*, *the default branch*.
If it needs more, the sentence is built wrong and should be reworded rather than prefixed
with a definition. The identifier itself stays wherever someone has to type or verify it.

**This binds every line the script prints**, not only the question. A PASS line the user
skims is where they learn what kind of thing the token is.

---

## What is not decided

**Whether the flip should also move at arc *switch*.** Two arcs open at once means one of
them has the default and the other does not, which is a worse asymmetry than neither having
it. Possibly the offer is only made when exactly one arc is active.

**Retroactivity is not available and must be stated.** Changing the default does not re-parse
existing PRs — verified: five merged PRs stayed unbound after the flip, and a body re-save
did not rescue them. **The flip must happen before the arc's first PR is opened**, or that
arc's early issues are permanently unlinked.

**Where the restore detection lives.** The handoff is read every cold start, but a repo with
no active arc may have no handoff at all — which is exactly the state where the default was
left flipped.

---

## Related

- [m12](m12-issue-linking.md) — the verification loop this removes most of the work from
- [m13](m13-issue-write-back.md) — the base-branch case is the seventh entry in its evaluation set
- [closing keywords and the base branch](../../arc-work/02-foundation/closing-keywords-and-base-branch.md) — the isolating comparison
- [GitHub: linking a pull request to an issue](https://docs.github.com/en/issues/tracking-your-work-with-issues/using-issues/linking-a-pull-request-to-an-issue)
