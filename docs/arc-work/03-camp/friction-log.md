# Friction log — arc-03, Camp

> **K2, and it dies with the arc.** Written while the arc runs, not reconstructed afterwards.
> A finding that outlives the arc graduates to a mechanism spec or an issue; this file is the
> raw material, not the record.

**This is the input to a retrospective, not a small copy of one.**
[`friction-transcript-log.md`](../../retrospectives/2026-08-plugin-line/friction-transcript-log.md)
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

## 1 · The merge step has never once executed, and the first diagnosis of why was wrong

**2026-08-21 · [#31](https://github.com/Calyx-Engineering/arc/issues/31) and [#32](https://github.com/Calyx-Engineering/arc/issues/32), the merge step of the autonomous loop**

### What happened

The arc-log's §6.1.1 step 10 reads *"Claude merges the PR — not the user."* It has been
reached twice and executed zero times. Both sessions hit:

```text
Permission for this action was denied by the Claude Code auto mode classifier.
Reason: Blocked by classifier.
```

Both handed the merge to the user. [#32](https://github.com/Calyx-Engineering/arc/issues/32)'s handoff went further and wrote the block into a
*Do not* row and an open thread as *"a permission problem, not a work problem"*.

**Asked what was actually triggering it, I isolated it in three commands and got it wrong.**

| Session | Command | |
|---|---|---|
| [#32](https://github.com/Calyx-Engineering/arc/issues/32) | `gh pr merge 97 --merge --delete-branch` | **Denied** |
| [#32](https://github.com/Calyx-Engineering/arc/issues/32) | `gh pr merge 97 --merge` | **Allowed** — merged immediately |
| [#32](https://github.com/Calyx-Engineering/arc/issues/32) | `git push origin --delete <branch>` | **Allowed** |
| [#31](https://github.com/Calyx-Engineering/arc/issues/31) | `gh pr merge 95 --merge` | **Denied** |

The first three rows say *the `--delete-branch` flag is the cause*, and that went into this
log, the arc-log and the handoff. **The fourth row falsifies it** — [#31](https://github.com/Calyx-Engineering/arc/issues/31) ran the flagless
form and was refused. It was one `grep` of a transcript that was already saved, run during
the review pass, after the wrong version was committed.

### What is actually established

| | |
|---|---|
| **A `gh pr merge` denial is not stable** | The same command succeeded moments after being refused, in one session. Whatever varies, it is not the command text |
| **No configuration is involved** | Both sessions checked independently: no `permissions` key in the user settings, and no `.claude/settings.json` at all. [#31](https://github.com/Calyx-Engineering/arc/issues/31)'s session reached this conclusion first and proposed an allow-list as the fix |
| **`--delete-branch` is not the explanatory variable** | It correlated once. One counter-example is enough |
| **What does vary is unknown** | Session permission mode, classifier context, or per-call nondeterminism. Not isolated, and this entry does not claim it is |

### What it cost

Two merge steps handed to the user. A wrong cause committed to three documents and corrected
only because a review pass checked a claim it could have accepted.

**And [#31](https://github.com/Calyx-Engineering/arc/issues/31)'s work was repeated.** That session had already ruled out every settings
file and proposed the fix. None of it reached [#32](https://github.com/Calyx-Engineering/arc/issues/32), which re-derived the same conclusion
from scratch, because the handoff carried *what was decided* and not *what was ruled out*.

### What would have prevented it

| | |
|---|---|
| **A denial is a finding, not a fact about the world** | Both sessions recorded *what* was denied. Neither asked *what varies* |
| **Three data points in one session are one data point** | The falsifying case was in the previous session's transcript, saved and named in the handoff. Checking the prior transcript before diagnosing is one command |
| **The handoff records conclusions, not eliminations** | *"The merge is the user's"* survived. *"No settings file exists; an allow-list is the fix"* did not. The second is what stops the next session repeating the work |
| **§6.1.1 step 10 names the action but not what to do when it fails** | A step that has never executed reads, in the spec, exactly like one that always works |

### Where it went

- **Nothing filed yet.** §6.1.1 needs a failure path, and the handoff needs somewhere for
  *what was ruled out*
- Same family as [#62](https://github.com/Calyx-Engineering/arc/issues/62) — a claim written down without the check that would have
  falsified it — but [#62](https://github.com/Calyx-Engineering/arc/issues/62) is about an edit contradicting itself within a file, and this is
  a diagnosis contradicted by a file nobody opened
