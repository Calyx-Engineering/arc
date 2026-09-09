# Issue #230 · #231 — how `tracker-verify` decides what a command invoked

> Dev-log, not a spec. Started at plan time, finalised as a retrospective at PR time.

**Issues:** [#230](https://github.com/Calyx-Engineering/arc/issues/230) · [#231](https://github.com/Calyx-Engineering/arc/issues/231)  ·  **PR:** _pending_

## Problem

`hooks/tracker-verify` decided what a Bash command invoked in two steps, and both were wrong.

| | |
|---|---|
| **The read** | `CMD` was cut out of the payload with `tr ',' '\n' \| grep -m1 '"command"' \| sed`. The payload was split on commas and the first fragment carrying `"command"` was kept, so `gh issue close --comment "done, merged" 163` arrived truncated at the comma |
| **The dispatch** | `case "$CMD" in *"gh issue close"*)` — a literal substring. `gh -R Calyx-Engineering/arc issue close 163` matched no arm at all, on every arm, and a chained command matched only the first arm the `case` happened to list |

Three consequences, all silent:

- A comma anywhere in a command truncated it. Where the truncation took the number with it, every
  check that needed one was skipped; where it took the subcommand, the invocation reached no arm.
- A flag between `gh` and the subcommand — the ordinary form when a merge is run from another
  worktree — was invisible.
- `gh pr merge 201 && gh issue close 163` ran the issue arm only, **with the PR's number**: the
  hook read issue #201, because `NUM` was resolved once for the whole command from
  `(issue|pr) (edit|merge|view) +#?[0-9]+`, which matched `pr merge 201`.

Measured 2026-09-07 against `HEAD` and against #163's branch. All three pre-date #163, which fixed
the equivalent gap *inside* the close arm only.

## Intent and north star

| | |
|---|---|
| **What these issues are really for** | A guardrail that reports nothing because it did not recognise the command is worse than no guardrail: it reads as a clean run. Every one of these failures was a silent pass |
| **North star** | The hook understands what a command invoked the way a shell does — words, not substrings — and runs the checks owed to **every** invocation the command names, each with its own number |
| **Out of scope** | The five sibling hooks that carry the same comma-split reader. Recorded under *Spawned*, not fixed here |

## What was built

### #230 — the reader and the dispatch

**`json_string <key>` replaces both `field()` and the `tr ','` command read.** One reader for the
`command` and the `cwd`, walking a JSON string in parameter expansion: the value ends at the first
quote that is *not* escaped, so the scan counts the backslash run in front of each quote instead of
stopping at the first one. `\"`, `\\`, `\n`, `\t` and `\r` are then resolved.

*No closing quote yields nothing, never the rest* — `fixture()`'s existing rule, for `fixture()`'s
reason. Half a command is the shape this hook exists to catch.

**`read_invocation` replaces the substring `case`.** Quoted spans are stripped, every run of shell
chain characters becomes one `__ARC_CHAIN__` token, and the command is walked as words: `gh`, then
`issue`/`pr`, then a verb from a closed list. It takes an optional second argument naming the arm
to look for, so the close and the ready arms are asked for by name and a chain reaches both.

`invocation_number` is the one number reader for every arm that needs one. `check_close`,
`check_pr_ready` and the issue and PR arms each had their own; two of the four were never fixed and
read a number belonging to a different invocation than the arm they served.

## Decisions & trade-offs

**The verb is a known word, not "the first token that is not a flag".** A flag between the
SUBCOMMAND and the verb — `gh issue -R owner/repo close 163`, equally valid, confirmed against the
real binary — puts the flag's *value* where the verb belongs. A first-non-flag rule reads
`owner/repo` as the verb and drops the invocation exactly as the substring match did. Two
positions, one defect; fixing one and leaving the other is how
[#17](https://github.com/Calyx-Engineering/arc/issues/17) shipped. The list covers every verb
`gh issue` and `gh pr` ship, the reads included — a read has to be recognised in order to be
passed over.

**A chain operator is a token, not a cut.** An operator is routinely glued to what it separates —
`gh pr merge 200&&gh issue close 163`. Cutting the string there loses the invocation *after* the
operator along with the one before it; a marker token ends only the one before it.

**`GH_ARGS` is accumulated from tokens, never cut out of the string.** The first version used
`${stripped#*$GH_SUB $GH_VERB}`. With a flag between the subcommand and the verb that literal never
appears, `#` matches nothing, and the expansion hands back the **whole command** — so
`gh pr view 200 && gh issue -R o/r close 163` reported a missing link on issue **#200**, an issue
nobody touched, and made two GraphQL calls to do it. A wrong finding read over the network is worse
than the silence it replaced.

**`\n` is resolved to a real newline.** The old dispatch was a substring match and did not care.
The new one splits on words, and a `\n` left as the two characters `\` and `n` glues the token
before a line break to the first word after it: `cd /repo\ngh issue close 163` yields the token
`/repo\ngh`, which is not `gh`. Every multi-line command, and every heredoc-carrying
`gh issue create`, is that shape. No case file had a newline in a command, which is why the suite
was green while this was broken.

**A create is asked for no number.** `gh` prints the URL on a create and the payload carries it, so
`invocation_number` is skipped there. Asking `GH_ARGS` for a number on a create reads whatever bare
number the flags happen to hold — `gh pr create --fill --draft && sleep 2` resolved PR #2.

## Rejected approaches

| | Why |
|---|---|
| **Keep `tr ','` and fix only the close arm's extraction** | What #163 did. The defect is in the shared read, so every arm has it |
| **`sed`/`awk` for the JSON string** | This runs on every Bash tool call in the session. The old form cost four processes; parameter expansion costs none |
| **Cut `GH_ARGS` at the chain operator with `%%&&*` after the fact** | Only correct when the string strip matched in the first place, which is exactly the case a flag breaks. Above |
| **Fix the sibling hooks' comma-split readers here** | Not rejected — deferred. `run-instructions.md` §5: a discovery is not permission to widen the unit |

## The gate

```
bash tools/verify-hook.sh hooks/tracker-verify   →  exit 0, 106 passed, 0 failed
```

Baseline before any change: `78 passed, 0 failed`.

Both shapes #230 names, run against the live hook with `arc_test_linked":"0"`:

```
gh issue close --comment "done, merged" 163      before: exit 0, silent   after: exit 2, close-link on #163
gh -R Calyx-Engineering/arc issue close 163      before: exit 0, silent   after: exit 2, close-link on #163
```

## Spawned

**This heading is `templates/dev-log.md`'s, not an issue body's.**

- **The comma-split reader is in five other places.** `hooks/camp-branch-check:53,68`,
  `hooks/branch-guard:51`, `hooks/camp-session-start:41`, `hooks/mode-guard:69` and — the one that
  matters most — `hooks/TEMPLATE:48`, which propagates it into every hook written from the
  skeleton. `camp-branch-check:68` is the exact `CMD` read #230 names, in a sibling `PostToolUse`
  hook on `Bash`. Filed, and not fixed here: this unit is `tracker-verify`.

## Retrospective

_Written at PR time._
