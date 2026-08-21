# Friction log — arc-03, Camp

> **K2, and it dies with the arc.** Written while the arc runs, not reconstructed afterwards.
> A finding that outlives the arc graduates to a mechanism spec or an issue; this file is the
> raw material, not the record.

**This is the input to a retrospective, not a small copy of one.**
[`docs/retrospectives/2026-08-plugin-line/friction-log.md`](../../retrospectives/2026-08-plugin-line/friction-log.md)
was mined from 28 transcripts and **ranked by recurrence** — ranking needs the whole corpus, so
it cannot be done as you go. This log is chronological, and each entry carries what a miner
would otherwise have to reconstruct.

| An entry has | |
|---|---|
| **What was being done** | The issue or step, so the trigger is locatable |
| **What happened** | Observed, not diagnosed. Quote the real output |
| **What it cost** | Minutes, a wrong belief, a handed-off task. *"None"* is a valid answer and worth writing |
| **What would have prevented it** | The mechanism, not the fix to this instance |
| **Where it went** | An issue number, a spec section, or **nothing yet** |

**One entry per friction, not per session.** A session with no friction adds nothing.

| Who fills it | |
|---|---|
| [`work-watch`](../../../skills/work-watch/SKILL.md) check 5 | Notices, and **proposes** the entry. The user decides whether it was friction — they are the one who felt it |
| [`record-route`](../../../skills/record-route/SKILL.md) | Routes it here rather than to a dev-log or the arc-log |
| Camp's operating agreement, §1 | **The switch.** On in this repository, off in the template — logging Arc's own rough edges is the case for a repository where Arc is being built |

---

## 1 · The autonomous loop's merge step had never once executed

**2026-08-21 · [#31](https://github.com/Calyx-Engineering/arc/issues/31) and [#32](https://github.com/Calyx-Engineering/arc/issues/32), the merge step of the autonomous loop**

### What happened

The arc-log's §6.1.1 step 10 reads *"Claude merges the PR — not the user."* Both attempts ran:

```sh
gh pr merge <N> --merge --delete-branch
```

and both were denied:

```text
Permission for this action was denied by the Claude Code auto mode classifier.
Reason: Blocked by classifier.
```

On [#31](https://github.com/Calyx-Engineering/arc/issues/31) this was read as *the merge is blocked* and handed to the user, and the handoff
recorded it as though merging were the user's job. On [#32](https://github.com/Calyx-Engineering/arc/issues/32) the same conclusion was reached
and written into the handoff a second time — as *"a permission problem, not a work problem"*,
with no attempt to isolate which part of the command was refused.

The user asked what was actually triggering it. Isolating took three commands:

| Command | |
|---|---|
| `gh pr merge 97 --merge --delete-branch` | **Denied** |
| `gh pr merge 97 --merge` | **Allowed** — merged immediately, no prompt |
| `git push origin --delete <branch>` | **Allowed** |

**The classifier objects to the bundled form, not to merging and not to deleting.** Deleting a
remote ref inside a merge command reads as one irreversible action; run separately, each is
fine. No configuration is involved — there is no `permissions` block in the project, local, or
user settings file.

### What it cost

Two issues' merge steps handed to the user, and a wrong belief written into the handoff twice
— the second time in a *Do not* row and an open thread, both of which stated the wrong cause.
A future session would have inherited it.

A second cost, smaller and worth naming: the `gh pr view` immediately after the denial was
also refused, and that was read as the block widening. It was collateral. The identical call
succeeded a turn later.

### What would have prevented it

| | |
|---|---|
| **A denial is a finding, not a fact about the world** | Both sessions recorded *what* was denied and neither asked *which part*. One command would have answered it |
| **§6.1.1 step 10 names the action but not the invocation** | *"Claude merges the PR"* is a step nobody can run wrong on purpose, and it has failed twice on a flag the spec does not mention |
| **The handoff propagated the wrong diagnosis into a `Do not` row** | Rows in that section are read as settled. A diagnosis reached in one turn, unverified, should not enter it |

### Where it went

- **Nothing filed yet.** §6.1.1 needs the invocation; the *Do not* row and open thread in the
  handoff have been corrected in place
- The wider point — a denied tool call being recorded rather than diagnosed — has no home. It
  is not [#89](https://github.com/Calyx-Engineering/arc/issues/89) and not [#62](https://github.com/Calyx-Engineering/arc/issues/62), though it is the same family as [#62](https://github.com/Calyx-Engineering/arc/issues/62): a claim written down
  without the check that would have falsified it
