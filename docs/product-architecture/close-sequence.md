# The close sequence, and starting the next issue

> **The authority on the order.** `skills/camp` names these steps and points here rather
> than restating them, so there is one list to change.

**The point is invariance.** Two different sessions closing two different issues produce the
same nine steps in the same order — so the process does not vary with how much context the
session still holds. A session that is nearly full closes an issue the same way a fresh one
does.

**Camp performs none of these.** It names which remain, in order, and confirms each landed
before naming the next. Every step is already owned by an artifact.

---

## Closing — nine steps

| # | Step | Owned by | Confirmed by |
|---|---|---|---|
| 1 | Checklist items still unchecked, or explicitly dropped | Camp names them | The issue body |
| 2 | The `dev-log` written for this issue | [`skills/record-route`](../../skills/record-route/SKILL.md) | The file exists |
| 3 | The `arc-log` status row updated | [`skills/record-route`](../../skills/record-route/SKILL.md) | The row says what merged |
| 4 | Changes committed — nothing uncommitted in the tree | [`skills/work-watch`](../../skills/work-watch/SKILL.md) | `git status --short` is empty |
| 5 | PR opened, titled with the arc prefix, milestone set | [`skills/issue-write`](../../skills/issue-write/SKILL.md) | `gh pr view` |
| 6 | `Closes #NN` present, and **verified to have bound** | [`hooks/tracker-verify`](../../hooks/tracker-verify) | **See below** |
| 7 | Soak line appended, if the change touched the plugin | The repo's `CLAUDE.md` soak rule | The arc-log |
| 8 | **User merges** | The user | — |
| 9 | Branch deleted once merged | The user, after Camp confirms | — |

**Steps 1 to 7 are Camp's to name. Steps 8 and 9 are the user's to perform.** An issue is not
closed because the work is done; it is closed because someone merged it.

**Obligation 0 fires inside step 5, not as a tenth step.** `issue-write` runs
[`skills/arc-intent`](../../skills/arc-intent/SKILL.md) before it writes the PR body — *does
what this delivers serve the arc.* It is a checkpoint that already existed, which is why it
adds no step and cannot change the count.

### Step 6 is the one that fails silently

A closing keyword on a PR into an arc branch **reports success and binds nothing** — the
keyword only binds against the repository's default branch. See
[m42](mechanisms/m42-default-branch-flip.md).

```sh
gh pr view <N> --json closingIssuesReferences
```

**An empty array means the issue is not closed, whatever the body says.** Read the array, not
the keyword.

> **Camp refuses to call an issue closeable while step 6 is unverified.** This is the one step
> phrased as a refusal, because a silently unbound keyword is the failure the whole sequence
> exists to catch — and it is invisible in every other surface.

### Naming what remains

Camp names the steps still outstanding, in order, and stops at the first one that is not
done. It does not list all nine every time; a session three steps in hears about steps 4
onward.

```text
**Camp here —** #41 looks closeable. Four steps remain:
  4 · two files uncommitted
  5 · no PR yet
  6 · unverified — check closingIssuesReferences after it opens
  7 · plugin change, so a soak line is due
```

---

## Starting the next issue — four steps

| # | Step | Owned by |
|---|---|---|
| 1 | The next issue, from the arc-log's order and its merged dependencies | Camp names it |
| 2 | Branch created from the arc branch, `arc/<nn>-<slug>-issue-<NN>-<slug>` | The main thread, after approval |
| 3 | The record loaded — arc intent, the issue, the handoff if one exists | Camp |
| 4 | The issue checklist becomes the session's working state | [`skills/work-watch`](../../skills/work-watch/SKILL.md) |

**A dependency that has not merged is a blocker, not a note.** Step 1 checks merge state, not
whether an issue exists.

**The crossing completes at step 4, not step 2.** An issue being open and a branch existing is
not the same as a session being ready to work on it.

---

## The handoff at a transition

A transition is exactly the moment the record must survive. [`skills/handoff`](../../skills/handoff/SKILL.md)
owns what a handoff contains and how it is written. **Camp owns noticing one is due, and
confirming it landed.**

| Step | Owner |
|---|---|
| Recognising a transition is happening | **Camp** |
| Writing the handoff | `skills/handoff` |
| Confirming it was written, and is current | **Camp** |
| Reading it back at the next session's start | `skills/handoff`, invoked by Camp |

**Camp never authors the handoff.** It fires the mechanism that does and verifies the result —
the same posture as obligation 4, where the artifact does the work and Camp reports on it.

### When it fires, and when it does not

| | Fires a handoff |
|---|---|
| A session is ending mid-arc | **Yes** |
| A planned break at a wave boundary | **Yes** |
| Moving to the next issue in the same session | **No** |

Firing one at an issue boundary inside a live session produces a file that duplicates context
the session already holds — and a second source that drifts from the record.

### Two reads when work resumes

| | Holds | When it exists |
|---|---|---|
| **The handoff** | Where the last session left off | Only when a session ended mid-arc. Session-scoped, gitignored |
| **The record** | The arc's intent, the `dev-log`, the issue | Always |

**Camp loads the record either way, and the handoff when one exists** — which is why the two
are named separately rather than treated as one step.

---

## Status — what it is assembled from

**Camp holds no state of its own.** Status is assembled per invocation:

| Source | Gives |
|---|---|
| The `arc-log` status table | What merged, what is next, where the breaks are |
| The `dev-log` for the current issue | This issue's *why* and its open questions |
| Open issues on the tracker | Real merge state, rather than what a table claims |
| The handoff, when one exists | Where the last session stopped |

A cached status is a second source that drifts from the record. **Anything Camp reports is
re-read at the moment it is asked.**

An answer is three or four lines — which issues are open, what merged, what is next.

---

## Related

- [m43 §3.2](mechanisms/m43-camp-assistant.md) — obligation 1, which this implements
- [m42](mechanisms/m42-default-branch-flip.md) — why step 6 fails silently
- [`camp-reports.md`](camp-reports.md) — the declaration every acting artifact carries
