# Mechanism — Branch / Worktree Guard

**Status:** partial — one of three checks has a working precedent; the other two are
undesigned.
**Home:** Arc — Workspace guard.
**Src:** 🔥 observed.
**Covers:** m10.

---

## The friction

The single worst moment in four weeks of hardware work:

> **"CRAP!! we screwed up big time. and we both missed it. we are supposed to be working
> off the parent branch of interface-pcba/rev_b This just completely messed everything
> up."** — 2026-08-03

And a cluster of smaller instances of the same class:

- *"is there a reason teh working tree at the bottom says issue 39 instead of 1?"*
- *"dar it looks like it opened on the main branch … can you fix that so its on this branch?"*
- *"do i not have the updates from #44/#45/#46 because this branch was created before then?"*

**Eight-plus occurrences, ranked first in the friction log.** The 08-03 case cost a session
to recover; the others cost minutes each but recur.

---

## Three checks, not one

Each failure above is a different check:

| Check | Catches | Precedent |
|---|---|---|
| **Branch** — is this the right branch for the work? | Work landing on the wrong parent — the 08-03 incident | TimeScope's `block_source_edits.js` |
| **Worktree** — is this window the one opened for this issue? | Editing in a worktree opened for something else | None |
| **Base freshness** — was this branch cut before other work merged? | A silently stale branch | None |

**Ship the branch check first.** One working check beats three half-finished, and the branch
check is the one that maps to the session-costing failure.

---

## The precedent

TimeScope's `PreToolUse` hook denies source edits on coordination branches — `develop`,
`main`, and any `arc/<slug>`. Docs and `.claude/` stay writable so the spine can maintain
process files.

**What ports cleanly:**

- The `PreToolUse` shape, reading JSON on stdin and returning a deny decision
- Fail-open on any unexpected error — a guardrail bug must never block all edits
- A narrow source-path list, so the guard has a small surface

**What does not:** its idea of *correct* is a fixed list of protected branch names. Arc's
must come from the arc — which branch this issue belongs to, what the base should be. That
is supplied by Campaign, and it is the part with no precedent.

---

## Non-negotiables

From [CLAUDE.md](../../../CLAUDE.md), because a bad hook registration fires on every tool
call in every repo and can break the session needed to fix it:

| | |
|---|---|
| Kill switch | Every hook opens with `[ -f "$HOME/.claude/HOOKS_OFF" ] && exit 0` |
| Fail open | On any unexpected failure, exit 0. Deny only the specific condition |
| Verified before registering | `tools/verify-hook.sh` runs pass, deny and malformed cases; real output pasted before approval |
| One hook per commit | With the verify output in the commit body, so `git revert` is surgical |

---

## What is not decided

**Where the guard learns what is correct.** Branch naming is per-repo — ROADZ names arcs
after the product component being revised, TimeScope uses a free slug. The guard needs that
convention from somewhere: repo config, the arc-log, or inference from the current branch.

**Worktree identity.** No signal ties a Claude Code session to the worktree it was opened
for. The transcript directory slug encodes the working directory, which may be enough.

**Base freshness without noise.** A branch cut before other work merged is only a problem
if that work matters. Firing on every stale branch would be constant.

**Whether it denies or warns.** Denying a source edit on the wrong branch is correct for
software. In guided hardware work the "source" is a CAD file edited outside the session,
which the hook never sees.

---

## Related

- [friction-log §2.1](../../retrospectives/2026-08-plugin-line/friction-log.md#21-wrong-branch--worktree--the-most-expensive-failure) — the evidence
- [issue-linking](m12-issue-linking.md) — the other half of workspace correctness
- TimeScope `hooks/block_source_edits.js` — the porting source
