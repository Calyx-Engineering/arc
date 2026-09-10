# Mechanism — Branch / Worktree Guard

**Status:** built — all three checks fire in `hooks/branch-guard` ([#161](https://github.com/Calyx-Engineering/arc/issues/161)).
The coordination prefix comes from the operating agreement's *branch prefix* clause ([#203](https://github.com/Calyx-Engineering/arc/issues/203)); a work branch is recognised by an `issue-<N>` or `pr<N>` segment in its name, with or without a prefix before it ([#200](https://github.com/Calyx-Engineering/arc/pull/200)).
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

| Check | Catches | Built as |
|---|---|---|
| **Branch** — is this the right branch for the work? | Work landing on the wrong parent — the 08-03 incident | Branch kind against a writable-path list |
| **Worktree** — is this window the one opened for this issue? | Editing in a worktree opened for something else | An absolute path landing in another worktree of the *same* repository |
| **Base freshness** — was this branch cut before other work merged? | A silently stale branch | `HEAD..<base>` count — `origin/<base>` if it is there, the local ref otherwise — said once per base commit |

**The branch check shipped first**, and the other two followed in
[#161](https://github.com/Calyx-Engineering/arc/issues/161) once each had a condition narrow
enough to deny on. All three deny only their own condition; anything the guard cannot classify
is allowed.

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

## Safe hook development

**Settled 2026-08-16.** The design goal is that a mistake is *survivable*, not that mistakes
are prevented by review skill — the user is explicit about not being a hook author.

> *"i'm not skilled at writing hooks. i need a way for you to do it safely."*

A bad hook registration fires on every tool call in every repo and can break the very
session needed to fix it. Three layers, cheapest first.

### 1. The kill switch — the one thing that must exist

```bash
. "${0%/*}/lib/hooks-off" 2>/dev/null && arc_hooks_off && exit 0
```

`bash hooks/hooks-off.sh <hook> 30` from any terminal makes that hook inert for a bounded
window, in this repository only. No editing JSON while
the broken thing fights back. **This is what makes the rest safe to attempt.**

**It is a chat obligation, not only a README line.** The agent states the kill switch in
chat *before proposing any hook change* — the reminder fires at the moment it is needed.

> *"that NEEDs to make it into the plugin readme. probably as a reminder in chat before
> everytime we re-write set a hook."*

A README line alone is a rule with no trigger, which is the failure mode this whole plan
exists to fix.

### 2. Fail open — a template obligation, not a checklist item

A hook that errors must not deny the tool call. Deny only on the specific condition it was
written to catch; on any unexpected failure, exit 0.

A broken guard that lets work through is an annoyance. A broken guard that blocks
everything is a dead session.

**The agent writes hooks from a skeleton that already contains the kill-switch line and the
error wrapper**, so it cannot be omitted. Not a thing to check for — a thing that cannot be
left out.

### 3. Verified before registering — a script, deliberately not a hook

A hook is a program reading JSON on stdin, so it runs standalone:

```bash
echo '{"tool_name":"Edit","tool_input":{"file_path":"x.md"}}' | hooks/branch-guard
```

`tools/verify-hook.sh <hook>` runs the cases — one that should pass, one that should deny,
one malformed — and exits non-zero on failure. **The agent must run it and paste the real
output before asking for approval.**

**Why a script and not a gate hook.** The instinct to make the gate itself a hook that can
never be touched is right in spirit and wrong in mechanism:

| | |
|---|---|
| A hook validating hook changes | Can be broken by the change it is validating |
| It is the one thing the kill switch disables | A mute naming it, or `all`, turns the guard off for as long as that mute lasts |
| A script works with hooks off | And produces output the user can see, rather than a silent pass |

### 4. One hook per commit

With the verify output in the commit body, so `git revert` is surgical.

### 5. Hard-excluded from autonomous edits

The "can never be touched" instinct applies here instead — to the things that make the
process safe:

| Never edited autonomously | Why |
|---|---|
| `settings.json` outside the plugin's own hooks block | Blast radius beyond the plugin |
| `tools/verify-hook.sh` | The thing that validates changes |
| The hook template | Carries the kill switch and the wrapper |
| Any `SessionStart` hook | Runs before the user can intervene, so a mistake is hardest to escape |

Changes to these come to the user as a proposal, always.

### What this permits

With all five in place, the agent **may** write hook registration — provided it shows the
verify output, confirms the kill-switch line is present, and changes one hook per commit.

The user reviews the diff like anything else: **checking that it tested, not auditing
bash.**

---

## Decided in the build

**Worktree identity — decided by narrowing, not by a session signal.** Nothing ties a Claude
Code session to the worktree it was opened for, and the guard does not need it to: the payload's
`cwd` names the tree the session is in, so an absolute path landing in a *different worktree of
the same repository* is the failure, and that is what it denies. A different clone stays allowed —
mirrored files are edited in two repos in one session by design.

**Base freshness without noise — said once per base commit.** A stale branch is only worth a
word when the base actually moved, and only once: the deny is stamped under the worktree's git
dir, keyed on the base's sha, so the next merge into the base speaks again and nothing else does.
The stamp is written before the deny, so a stamp that cannot be written means silence rather than
a branch nobody can edit.

---

## What is not decided

**One convention, read from two places.** `branch-guard` takes the coordination prefix from
the operating agreement; `camp-branch-check` derives the labels a work branch may number
itself with from `CLAUDE.md`'s branching section. Which file is the authority is not settled,
and the two are not read against each other.

**Which labels mark a work branch.** `branch-guard` compiles in `issue` and `pr`. A repo that
declares a prefix and numbers its work branches some other way — `feat/ticket-12-slug` — has
them classified as coordination and its source edits denied, while `camp-branch-check` accepts
the same name. The prefix became a setting in #203; the label set did not.

**Whether it denies or warns in a hardware repo.** Denying a source edit on the wrong branch
is correct for software, and that is what ships. In guided hardware work the "source" is a CAD
file edited outside the session, which the hook never sees — so what the guard should do there
is still open.

---

## Related

- [friction-transcript-log §2.1](../../retrospectives/2026-08-plugin-line/friction-transcript-log.md#21-wrong-branch--worktree--the-most-expensive-failure) — the evidence
- [issue-linking](m12-issue-linking.md) — the other half of workspace correctness
- TimeScope `hooks/block_source_edits.js` — the porting source
