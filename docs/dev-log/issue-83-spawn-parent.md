# Issue #83 — a spawned issue records no parent

> Dev-log, not a spec.

**Issue:** [#83](https://github.com/Calyx-Engineering/arc/issues/83)  ·  **PR:** [#251](https://github.com/Calyx-Engineering/arc/pull/251)

## Problem

An issue filed while working on another issue left no record on its parent unless somebody
remembered to write one. [`skills/issue-write`](../../skills/issue-write/SKILL.md) says to and
[m46 §6](../product-architecture/mechanisms/m46-work-navigation.md) makes it the mechanism's
core, and nothing enforced it.

**Observed 2026-08-20.** Four issues — [#78](https://github.com/Calyx-Engineering/arc/issues/78),
[#79](https://github.com/Calyx-Engineering/arc/issues/79),
[#80](https://github.com/Calyx-Engineering/arc/issues/80),
[#81](https://github.com/Calyx-Engineering/arc/issues/81) — were filed during
[#76](https://github.com/Calyx-Engineering/arc/issues/76)'s cold review. None was recorded until
the user noticed the section was empty. The session that wrote the mechanism broke it.

## Intent and north star

| | |
|---|---|
| **Why a hook and not a rule** | A lost spawn edge cannot be reconstructed with confidence. Recovery means reading a transcript and inferring which issue caused which, and nothing then distinguishes an edge that was recorded from one guessed at later. An unrecorded spawn is not a degraded record; it is an absent one |
| **North star** | The arc tree is built out of what records its own parent, and every new tracker object either records one or says out loud that it did not |
| **Reports, never denies** | Not every issue is spawned. A false deny blocks legitimate work, and the finding is the whole value |

## The decision the issue left open

**What counts as recorded: the child's `Spawned by`, not the parent's `Spawned` row.**
[m46 §6](../product-architecture/mechanisms/m46-work-navigation.md) records both directions and
only one of them is answerable at create time.

| | |
|---|---|
| **The child's line** | Sits in the body the write just landed, which this hook already reads for the placeholder and date scans. It costs nothing |
| **The parent's row** | m46 §6: *a row gets its number later — at spawn time, not at spot time*. The parent may legitimately name this child by description and not by number, so a parent-side read is **false-negative by design** — and it would cost a second network call inside a synchronous `PostToolUse` hook to be wrong |

**Any `Spawned by` satisfies it, not specifically the branch's number.** Work is genuinely
spawned from something other than the branch's issue — a review of a third issue, somebody
else's PR — and demanding the branch's own number would report those as defects. The branch
decides whether the question is worth asking; the body answers it.

**The link forms are matched loosely** because the repository writes this two ways:
`skills/issue-write` puts it in the `Related` table as `| **Spawned by** | [#194](…) |`, and m46
writes a bare `Spawned by #NN` line. Both are the record.

## Where it asks, and where it does not

| | |
|---|---|
| `gh issue create`, branch names an issue or a PR | Ask. m46 §9's two forms both resolve — `-issue-<NN>` and `-pr<NN>` — and m46 §4 row 3 says a parent may be a PR |
| `gh issue create`, branch carries no number | Silent. Nothing names the current work, so there is no parent to record |
| `gh issue edit` | Silent. An edit is not a spawn. Asking again on every edit would report the same finding indefinitely on an issue that legitimately has no parent |
| `gh pr create`, no keyword and no link | Ask, **unconditionally** |
| `gh pr create`, closes an issue | Silent. That PR is the issue's work, and the issue carries the edge |

**The no-issue PR is the one place the branch does not decide.** `tools/new-direct-pr.sh` names
that branch `arc/<nn>-<slug>-pr<NN>-<hint>` after the PR *itself* — m46 §9, the number names
whichever identifier exists first — so the branch names no parent there by construction. Gating
on it would have turned the check off in exactly the case m46 §6 calls *the only record when the
child has no issue*.

## Unplanned but needed — a defect in `pr-base`

**`arc/03-camp-pr75-no-issue-pr` was read as an issue branch.** The guard was `arc/*-issue-*`,
which matches the literal `-issue-` inside `-no-issue-pr`. The strip that follows looks for
`-issue-<digits>`, found none, and returned the branch name unchanged — so `ARCBASE` became the
whole branch and the check reported a correctly based PR as misbased. Both patterns now require
a digit after `-issue-`.

**It surfaced because the branch name is m46 §9's own example**, written into a case for this
check. It is a live defect, not a fixture artifact: `tools/new-direct-pr.sh` produces exactly
that shape. Recorded in [#83](https://github.com/Calyx-Engineering/arc/issues/83)'s `Spawned`
table, fixed here rather than filed, because the case for this issue could not pass around it.

## The branch fixture

`arc_test_branch` was added alongside the existing `arc_test_*` keys. m46 §9 has **two** branch
forms and `tools/verify-hook.sh` builds fixture repositories for one of them — and that file is
on `CLAUDE.md`'s never-edited-autonomously list, so the `pr<NN>` form is untestable through a
fixture repository. A case names the branch instead, and `head_branch()` is now the single
reader both this check and `pr-base` go through.

## Evidence

```text
$ bash tools/verify-hook.sh hooks/tracker-verify
60 passed, 0 failed

$ bash tests/verify-activation-log.sh hooks/tracker-verify
191 passed, 0 failed
```

## Rejected approaches

| | |
|---|---|
| **Reading the parent's `Spawned` section** | False-negative by design — m46 §6 lets the row exist with no number yet — and a second network call inside a synchronous hook to be wrong |
| **Requiring the branch's own number in `Spawned by`** | Reports every issue genuinely spawned from something else |
| **Denying instead of reporting** | Not every issue is spawned. The issue rules it out, and a false deny blocks real work |
| **Asking on `gh issue edit` too** | The same finding, forever, on an issue that has no parent |
| **Renaming the case's branch to dodge the `pr-base` collision** | A fixture chosen to avoid a bug is the silence this arc exists to fix. The bug is in the hook, not the branch name |

## Not done

Nothing in `Required` is outstanding.
