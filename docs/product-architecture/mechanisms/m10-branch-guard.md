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

## Safe hook development

**Settled 2026-08-16.** The design goal is that a mistake is *survivable*, not that mistakes
are prevented by review skill — the user is explicit about not being a hook author.

> *"i'm not skilled at writing hooks. i need a way for you to do it safely."*

A bad hook registration fires on every tool call in every repo and can break the very
session needed to fix it. Three layers, cheapest first.

### 1. The kill switch — the one thing that must exist

```bash
[ -f "$HOME/.claude/HOOKS_OFF" ] && exit 0
```

`touch ~/.claude/HOOKS_OFF` from any terminal makes every hook inert. No editing JSON while
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
| It is the one thing the kill switch disables | `HOOKS_OFF` turns off the guard along with everything else |
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

- [friction-transcript-log §2.1](../../retrospectives/2026-08-plugin-line/friction-transcript-log.md#21-wrong-branch--worktree--the-most-expensive-failure) — the evidence
- [issue-linking](m12-issue-linking.md) — the other half of workspace correctness
- TimeScope `hooks/block_source_edits.js` — the porting source
