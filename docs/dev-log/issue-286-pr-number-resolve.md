# Issue #286 — `tracker-verify`'s PR checks were silently off when the command named no PR number

> Dev-log, not a spec. Written at PR time as a retrospective.

**Issue:** [#286](https://github.com/Calyx-Engineering/arc/issues/286)  ·  **Spawned by:** [#136](https://github.com/Calyx-Engineering/arc/issues/136)

## Problem

`hooks/tracker-verify` resolved its target out of the command string, and a `gh pr merge` that named
no number — `gh pr merge --squash --delete-branch`, the ordinary form when a run merges its own PR from
its own worktree — reached `[ -n "$NUM" ] || return 0`. The activation-log entry was written with every
check `(not reached)`: the record said the hook fired and nothing about why it decided nothing.
`merge-close` ([#136](https://github.com/Calyx-Engineering/arc/issues/136)) is the check most exposed.

## What #231 had already landed

Two of the five requirements were met on `arc/04-dogfood` before this branch, by
[#231](https://github.com/Calyx-Engineering/arc/issues/231):

| Requirement | Where | Pinned here by |
|---|---|---|
| The number is found anywhere after the subcommand | `invocation_number`, which reads `GH_ARGS` token by token | `report/pr-merge-flag-before-number.json` — exits 2 against the base hook too |
| A chained command runs each arm against its own number | the per-arm `read_invocation … "$WRITE_N"` loops | `report/chained-merge-then-close-issue-form.json` — entry reads `chained: pr-merge · issue-close`, `close-link=issue-10`, `merge-close` on `pr-200`, identical on base and new |

Measured by firing each case against `git show origin/arc/04-dogfood:hooks/tracker-verify`.

## What was built

| | |
|---|---|
| `payload_merged_number` | The PR `gh pr merge` said it merged, read out of `tool_response` — `merged pull request owner/repo#200 (…)`, or `#200` from an older `gh`. Asked **first**, because `--delete-branch` leaves the checkout on the base, where the current branch's PR is the arc PR or nothing |
| `current_pr_number` | The current branch's PR via `gh pr view`, bounded by GNU `timeout` where present. One reader, now shared with `check_pr_ready`, which had its own copy. A fixture supplies it as `arc_test_pr_number` |
| `skip_arm` | Every check of the arm marked `arc_log_skip` with one reason, and the reason kept in `SKIP_WHY` for the entry's `outcome:` line — because `lib/activation-log`'s volume rule writes no `skipped:` line when no check ran, so the outcome line is the only carrier |
| Skips, not bare returns | No number for an issue arm; no PR resolvable; `gh` absent; the PR or the issue body unreadable — each was a `return 0` |

The `outcome:` write sits **after** `report`, deliberately: `report` records `failed` only where no outcome
stands, so an `ok` written first would turn a firing with findings into a clean entry.

## What the review passes found

| Pass | Finding | Fix |
|---|---|---|
| 1 | `payload_merged_number` grepped the whole payload, so `--subject "revert pull request #300"` beat `gh`'s own output — a quoted span winning, which the quote strip in `read_invocation` exists to prevent | Grep only the part of `INPUT` after `"tool_response"`. `pass/pr-merge-no-number-quoted-number-does-not-win.json` — no output, no fixture number, quoted `#300`: silent, where a read of the quoted number would report on PR #300 |
| 1 | `gh` absent still hit a bare `return 0` | `skip_arm "gh is not on PATH"` |
| 2 | The fallback was gated on `GH_SUB = pr`, so a `gh pr create` whose output carried no URL went to `gh pr view` and could run the create checks against a PR the command did not write | Gated on `GH_VERB != create` |
| 2 | A merge that **failed** — `is not mergeable`, or `--auto` queued it — printed no merged PR, the branch was still checked out, `current_pr_number` resolved it, and the hook reported "merged and the issue is still open" about a merge nobody made | For `merge`, a `tool_response` naming no merged PR skips: `the merge's output names no merged PR, so nothing merged`. An absent `tool_response` is a fixture and falls through to the branch read. `pass/pr-merge-no-number-merge-did-not-happen.json` |
| 4 | The failed-merge output **does** name the PR — `X Pull request …#200 is not mergeable` — and the case passed only because the grep was case-sensitive and `Pull` is capitalised | The reader anchors on `merged pull request`, case-insensitive, which every success prints and no failure does |
| 4 | No case exercised the after-`tool_response` slice from pass 1: the quoted-span case carried no output, so the reader returned before the slice | `pass/pr-merge-no-number-quoted-number-with-output.json` — a failed merge whose quoted `--subject` carries `merged pull request #300`: read from the output alone it skips; read from the whole payload, #300 wins and it would report |

**Pre-existing and not fixed here:** the same false report exists for a **numbered** merge that fails —
`gh pr merge 200 --squash` against an unmergeable PR runs `merge-close` on #200 as if it merged. The
number is in the command, so nothing here touches it. A finding, not a unit of work; recorded here rather
than filed.

## Evidence

```
$ bash tools/verify-hook.sh hooks/tracker-verify
132 passed, 0 failed

$ bash tests/verify-all.sh
64 gates, all clean
exit=0
```

Before the fix the two no-number `report/` cases were the only red: `129 passed, 2 failed`, both `allow`
where `report` was expected.

Event-log read-back, `ARC_EVENT_LOG` set, three cases fired in order — nothing resolvable, a failed merge,
and a merge whose output names the PR:

```
tracker-verify  pr-merge
  checked: — none reached
  outcome: ok — pr merge: the command names no PR and none could be resolved from its output or the current branch
tracker-verify  pr-merge
  checked: — none reached
  outcome: ok — pr merge: the merge's output names no merged PR, so nothing merged
tracker-verify  pr-merge
  checked: placeholder-scan=pr-200 · date-sanity=pr-200 · milestone=pr-200:none · pr-base=pr-200:arc/02-foundation · arc-prefix=pr-200:arc-02 · closing-keyword=pr-200:bound · merge-close=issue-10 — merge-close found something
  outcome: failed — the write landed, with findings
```

The same third payload against the base hook: exit 0, `checked: — none reached`, `outcome: ok — nothing
to report`. That entry is the defect the issue describes.

The chained case, `gh pr merge 200 && gh issue close 10`, fired the same way — one entry, both arms, each
against its own number:

```
tracker-verify  pr-merge  chained: pr-merge · issue-close
  checked: close-link=issue-10 · placeholder-scan=pr-200 · date-sanity=pr-200 · milestone=pr-200:none · pr-base=pr-200:arc/02-foundation · arc-prefix=pr-200:arc-02 · closing-keyword=pr-200:bound · merge-close=issue-10 — merge-close found something
  outcome: failed — the write landed, with findings
```

## Findings about the run

- The dispatch prompt this run received named `tools/verify-all.sh` and `tools/verify-linked-branch.sh`,
  neither of which exists. `run-instructions.md` on the base already says `tests/` for both, since
  `865f989` on 2026-09-09 — the prompt the driver hands a run is a copy, and it was stale. The run used
  the `tests/` paths.
- The `tracker-verify` that fired on this run's `gh pr create` was `R:\arc/hooks/tracker-verify` — the
  main tree's copy, checked out on `arc/04-dogfood-issue-145-fire-review` with a hook from before #204 —
  and it reported "PR #328 has no milestone" on a PR that closes an issue, which the current hook passes.
  A hook fires from wherever the plugin is registered, not from the worktree whose change it is meant to
  soak; a soak line for this change has to come from a session whose main tree carries it.
- `tests/verify-all.sh` takes over ten minutes here, past the Bash tool's 600 s ceiling, so it ran in the
  background with its exit code written to a file and read back at the end.
- `tools/verify-hook.sh` judges the verdict class only, so a case cannot pin **which** PR a finding is
  about. The quoted-span case is decisive only because it is a `pass/` case with no other resolvable
  number; the chained case's per-arm numbers are pinned by the event-log entry above, not by the gate.
