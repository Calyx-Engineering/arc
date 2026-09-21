# Issue #163 — fire when an issue closes

**Issue:** [#163](https://github.com/Calyx-Engineering/arc/issues/163)  ·  **PR:** [#232](https://github.com/Calyx-Engineering/arc/pull/232)

## Problem

`hooks/tracker-verify` matched `gh issue create|edit`, `gh pr create|edit` and `gh pr merge`. A close matched nothing, so the one moment where a missing branch↔issue or PR↔issue link is still visible — and past which it can no longer be fixed — was the one moment nothing looked.

## What the close arm asks

One question, and it is [`tests/verify-linked-branch.sh`](../../tests/verify-linked-branch.sh)'s one-argument form exactly: **is this issue linked to anything at all** — a branch record, or a PR that closes it.

**Shelled out, not re-implemented.** Which field holds the link took [#155](https://github.com/Calyx-Engineering/arc/issues/155) and [#206](https://github.com/Calyx-Engineering/arc/issues/206) to get right, because opening a PR *promotes* a branch link out of `linkedBranches` into the PR's closing reference. A second copy of that reading here would be a second copy to get wrong. That tool's own caveat — the one-argument form answers yes forever once a link has been promoted — does not bite at a close, where the question is whether the record shows anything at all.

Its three exit codes are kept distinct, which is the point of it: `0` linked, `1` no link, **anything else means the read could not be made and is not the same answer as "no link"**.

## The extraction was the whole difficulty

Naming the issue turned out to be harder than deciding about it. Three review passes each found the previous pass's extraction wrong.

| Written | Broke on | Why |
|---|---|---|
| `grep -oE 'issue close +#?[0-9]+'` | `gh issue close -R owner/repo 163`, and the URL form | Anchored on digits immediately after the subcommand. `--repo` is an inherited flag and may precede the argument; `gh issue close` takes `{<number> \| <url>}`. Both read as "no number" and **skipped the check in silence** — the exact shape #163 exists to catch |
| A whitespace token anchored `^#?[0-9]+$` | `gh issue close 163` | `CMD` is cut out of the raw payload and keeps what followed it: the last argument arrives as `163"}}` |
| A token, URL tried first | `gh issue close --comment "Closed by #224" 163` | The comment's number won. The hook would report a missing link **on an issue nobody touched**, and read it over the network to do so |

What is there now, in order: strip quoted spans (a `--comment` is where a stray number or URL realistically lives, and it is always quoted), then the bare token, then the URL. Trailing punctuation is allowed on the token; a trailing `-` or word character is not, so `2026-09-07` is not an issue number.

## Decisions and trade-offs

| | |
|---|---|
| **`check_close` returns, it does not exit** | An arm that exits unconditionally would stop `gh pr merge N && gh issue close M` reaching the PR checks. Measured against `HEAD`: that command was already silent for a different reason ([#231](https://github.com/Calyx-Engineering/arc/issues/231)), so this is parity, not a fix — but the arm no longer adds to the problem |
| **The network call is bounded, and only by GNU `timeout`** | Two GraphQL round trips, ~2.3 s warm, inside a synchronous `PostToolUse` hook. `command -v timeout` is not enough: on Windows it can resolve to `timeout.exe`, which rejects the syntax and exits **1** — the link tool's "no link" verdict. That would report a missing link the hook never read. `timeout --version \| grep -qi coreutils` separates them without running a child |
| **`cd` outside the `&&`** | Chained, a failed `cd` returns 1, which is again "no link". `(cd "$CWD" \|\| exit 3; …)` keeps the two apart |
| **`arc_test_linked` reused, no new fixture key** | It already meant "the tracker shows a closing reference". A close case and a PR case never reach each other's arm |

## Every case is decisive

A case that passes whether or not the line it guards is present proves nothing. Each was checked by breaking the line and confirming the case fails:

| Line disabled | Cases that flip |
|---|---|
| The quote strip | `pass/issue-close-stray-number-in-comment`, `pass/issue-close-stray-url-in-comment` — both go from silent to reporting the decoy's number |
| The token scan (old anchored regex restored) | `report/issue-close-repo-flag-first`, `report/issue-close-comment-flag` — both go silent |
| The URL fallback | `report/issue-close-url-form` — goes silent |

The two stray-decoy cases are not calls `gh` accepts. That is deliberate and the only shape that decides: with no argument of its own, a correct extraction finds no number and is silent, while a failed strip finds the decoy and reports. Their descriptions say so.

**`malformed/issue-close-truncated` does not reach the close arm** — it stops at the shared fixture-truncation guard, correctly, but that guard predates this issue. `malformed/issue-close-command-cut-off` was added to cover the arm itself: the payload is cut inside the command, `CMD` is the bare subcommand, and the intact `arc_test_linked":"0"` means any number the extractor invented would report.

## What the passes found

Three passes, three different questions, and each found something the last did not.

| Pass | Found |
|---|---|
| **1 — is every requirement met?** | The matcher was in, but hollow: two of the three documented invocation forms silently skipped the check |
| **2 — what did pass 1 introduce?** | The URL-first ordering and `grep -m1` both picked the wrong issue number out of a `--comment`. Also measured that the chained-command silence pre-dates this work |
| **3 — does each tick have evidence?** | Box 2's malformed case never entered the arm, and the `timeout` guard trusted any binary of that name |

**A skipped check is worse than a missing one**, and every defect above was one: the hook stayed silent and looked like it had passed.

## Not done

**`tools/verify-hook.sh` breaks after the first `report/` case**, so its kill-switch suppression test runs against `angle-bracket-placeholder.json` and never a close case. The switch is proven for the hook, not for this arm. That file is hard-excluded from autonomous edits — it comes to the user as a proposal.

## Spawned

| Issue | | |
|---|---|---|
| [#230](https://github.com/Calyx-Engineering/arc/issues/230) | `CMD` truncates at a comma, and the top matcher misses a flag between `gh` and the subcommand | Every arm, not just close |
| [#231](https://github.com/Calyx-Engineering/arc/issues/231) | A chained `gh pr merge … && gh issue close …` runs only the issue arm | Pre-dates #163, measured against `HEAD` |

## Evidence

```text
bash tools/verify-hook.sh hooks/tracker-verify   →  47 passed, 0 failed   exit 0
bash tests/verify-all.sh                         →  19 gates, all clean   exit 0
```

Live path, run standalone against the real tracker (no issue was closed):

```text
gh issue close 163      →  exit 0, silent      (linked)
gh issue close 175      →  exit 2, reports     (no branch record, no closing PR)
gh issue close 999999   →  exit 0, silent      (the read could not be made — not "no link")
```
