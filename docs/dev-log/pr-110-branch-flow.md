# PR #110 — The branch-naming flow, drawn and corrected

> Decision log, not a spec. A no-issue PR is a unit of work like any other
> ([m46 §6.1](../product-architecture/mechanisms/m46-work-navigation.md)).

**Issue:** none  ·  **PR:** [#110](https://github.com/Calyx-Engineering/arc/pull/110)

## Problem

[m46 §9.1](../product-architecture/mechanisms/m46-work-navigation.md) shipped in
[PR #108](https://github.com/Calyx-Engineering/arc/pull/108) as prose, a numbered list and two
tables. It is a flow with a decision point and a failure branch, and
[`spec-interview`](../../skills/spec-interview/SKILL.md) says a core-function section opens
with a diagram. `CLAUDE.md` prefers Mermaid where a flow is easier shown than described.

**Caught by the user, not by the write-up's own full read** — which asks *does each heading
describe what is under it*, and does not ask whether a process was drawn.

## What drawing it exposed

**The written process did not match the one actually executed.** §9.1 said:

> *"Branch with it, and open the PR immediately. The window in which someone else can take the
> number is the only risk, and it is seconds wide."*

What [PR #108](https://github.com/Calyx-Engineering/arc/pull/108) did: branched, implemented
the hook change, the spec change, the skill change, ran the verify ceremony, ran the rename
probe, committed, pushed — **then** opened the PR, over an hour later.

| | |
|---|---|
| **The window was hours, not seconds** | The safety argument for predicting the number was simply false as practised |
| **The confirmation happened last** | By the time the number could be checked, every change had already landed on a branch that might have been named wrong |
| **The prediction held, which hid it** | 108 was correct, so nothing failed and nothing drew attention to the gap |

**Drawing a process is a check on it.** Prose can say *immediately* and be read past; an arrow
from `Branch` straight to `Open the PR` has to be either true or visibly wrong.

## Decisions & trade-offs

| | |
|---|---|
| **The draft PR comes before the work, not after** | It is the only step that makes *the window is seconds wide* true. It also moves the number check to a point where being wrong costs nothing |
| **The dev-log is the first commit** | A PR needs a commit to exist, and [§6.1](../product-architecture/mechanisms/m46-work-navigation.md) requires a dev-log of every merged unit regardless. The requirement and the mechanism happen to be the same act |
| **A wrong prediction loops back to *predict*, not to *branch*** | The first diagram sent the correction path back to the dev-log step, which would re-use the burned number. Caught reading the diagram back |
| **The negative path is drawn, not only written** | `Rename the branch` is a dotted edge to `The PR closes`. The thing the [PR #108](https://github.com/Calyx-Engineering/arc/pull/108) test disproved is now visible in the picture rather than only in a blockquote |
| **One retry, then accept** | The user's call, and it is principled rather than arbitrary: attempt 1 can be wrong from a stale counter read, attempt 2 cannot. A second miss is a property of the repository, and a third attempt does not address it |
| **An accepted mismatch is said twice** | The PR body near the top, and the friction log where one exists. **Unexplained, the branch is silently wrong** — the exact failure §9 exists to prevent. Explained, it is a record |

## The shared `temp/` branch — tested, and it fails twice

Proposed as an alternative: open every PR against one throwaway branch, take the number, then
point the PR at the real branch. **It does not work, and the first failure is silent.**

| Tested on [PR #111](https://github.com/Calyx-Engineering/arc/pull/111) | Result |
|---|---|
| `PATCH /repos/{o}/{r}/pulls/111` with `head` | **200, and the field ignored.** Head stayed `temp/pr-probe` |
| A second PR from the same head | **Rejected** — one already exists for that head-and-base pair |

**A PR's `head` is fixed at creation; only `base` can be changed.** The advice this came from is
almost certainly about `base`. So one shared branch serialises every direct PR to one at a
time, and the retarget that would free it silently does nothing.

**Two probes, two numbers burned** — [PR #109](https://github.com/Calyx-Engineering/arc/pull/109) for the rename, [PR #111](https://github.com/Calyx-Engineering/arc/pull/111) for this. Both
disproved something that was about to be written down as true.

## What this says about the write-up checklist

`spec-interview`'s full-read asks six questions. **None of them is *is this a process, and is
it drawn?*** The rule exists — *every core-function section opens with a diagram* — but the
checklist that is supposed to enforce it does not mention it.

**Not fixed here.** It is a change to the checklist rather than to this flow, and it wants its
own scope. Named so it is not lost.
