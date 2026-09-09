# Issue #230 · #231 — how `tracker-verify` decides what a command invoked

> Dev-log, not a spec. Started at plan time, finalised as a retrospective at PR time.

**Issues:** [#230](https://github.com/Calyx-Engineering/arc/issues/230) · [#231](https://github.com/Calyx-Engineering/arc/issues/231)  ·  **PR:** [#301](https://github.com/Calyx-Engineering/arc/pull/301)

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

**Two commits, and what was still broken between them.** #230 landed the reader and the
word-based dispatch, including the by-name lookup for the close and the ready arms — so
`gh pr merge 201 && gh issue close 163` already reached both of those, and each already resolved
its own number. What #230 left is what #231 fixes: **only one body-carrying write ran.**
`gh issue edit 38 --body-file b.md && gh pr merge 200` checked the issue and never read the
merge; `gh pr edit 200 … && gh pr edit 201 …` checked 200 twice rather than 200 and then 201.

Three of the chained case files first claimed to demonstrate the pre-#230 defect. Measured
against the commit they actually follow, they do not, and they say so now.

**Exactly one case decides #231, and that is a limit of the harness rather than of the cases.**
Run against #230's hook, the whole suite gives `113 passed, 1 failed`, and the one that fails is
`chained-issue-edit-then-merge`. `chained-two-pr-writes` and
`chained-two-pr-creates-take-their-own-urls` emit one finding on the broken hook where they emit
two on the fixed one — but `tools/verify-hook.sh` compares the verdict class and never the
finding text, so both still pass. Their evidence is in this dev-log and in the PR body, not in
the gate.

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

### #231 — every write the command names

`read_invocation` takes a third argument, how many matching invocations to walk past, and the four
call sites became `while` loops. The whole write region — some four hundred lines — is now
`check_write()`, called once per write the command names.

**Its body is not indented and not otherwise changed.** Four hundred lines re-indented is four
hundred lines of diff over a change that is a loop, and the diff is the review surface. For the
same reason nothing in it is `local`: a declaration list that long goes stale, so every variable a
second call could read from the first is cleared on entry instead.

`payload_url_number` gives a create its number from the Nth URL **of the right kind** in the
payload. A single `(issues|pull)` grep taking the first match sends an issue's number to
`gh pr view` when a create of each is chained, and gives two chained creates of the same kind the
same number — so the second is never checked and the first's findings print twice.

`add()` suppresses a finding already present, matched at both ends so a finding that is a proper
prefix of another still lands: a chain naming the same object twice runs the shared checks in both
arms and printed each finding verbatim twice.

`LOG_OBJ` qualifies every check name in the activation-log entry with the object it was about.
Two bare `placeholder-scan` marks in one entry cannot say which arm failed, and `arc-merge-keyword`
landed in `checked:` as a pass and in `skipped:` as *not a `gh pr merge`* in the same entry — a
record contradicting itself. A single-arm firing's entry is unchanged, because `LOG_OBJ` is empty
there.

```
pr-write  chained: pr-write · pr-write
  checked: placeholder-scan=pr-200 · milestone=pr-200:Dogfood · … · milestone=pr-201:Dogfood
```

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
| **Fix the sibling hooks' comma-split readers here** | Not rejected — deferred to [#300](https://github.com/Calyx-Engineering/arc/issues/300). `run-instructions.md` §5: a discovery is not permission to widen the unit |
| **Re-indent `check_write`'s body** | Four hundred lines of diff over a change that is a loop |
| **`local` on `check_write`** | A twenty-two-name declaration list goes stale the first time a variable is added. Cleared on entry instead, which is one place a reviewer can check against the body |

## The gate

```
bash tools/verify-hook.sh hooks/tracker-verify   →  exit 0, 117 passed, 0 failed
bash tests/verify-all.sh                         →  exit 0, 53 gates, all clean
```

Baseline before any change: `78 passed, 0 failed`. After #230's commit: `106 passed, 0 failed`.

Every case in the suite runs **offline**: with a shim `gh` first on `PATH` that logs its argv and
exits 1, the whole suite logs zero invocations.

Both shapes #230 names, run against the live hook with `arc_test_linked":"0"`:

```
gh issue close --comment "done, merged" 163      before: exit 0, silent   after: exit 2, close-link on #163
gh -R Calyx-Engineering/arc issue close 163      before: exit 0, silent   after: exit 2, close-link on #163
```

## Spawned

**This heading is `templates/dev-log.md`'s, not an issue body's.**

- **[#300](https://github.com/Calyx-Engineering/arc/issues/300) — the comma-split reader is in four other hooks and the template.** `hooks/camp-branch-check:53,68`,
  `hooks/branch-guard:51`, `hooks/camp-session-start:41`, `hooks/mode-guard:69` and — the one that
  matters most — `hooks/TEMPLATE:48`, which propagates it into every hook written from the
  skeleton. `camp-branch-check:68` is the exact `CMD` read #230 names, in a sibling `PostToolUse`
  hook on `Bash`. Filed, and not fixed here: this unit is `tracker-verify`.

## Retrospective

Six boxes across two issues, one hook, 36 new cases. The cases went in before the code each time,
and the ones that decide were confirmed silent against the hook they replace.

### What the review passes changed

**Pass 1 on #230 found four defects and every one of them changed the tree.** The two that
mattered: `read_invocation` read the verb as *the first token that is not a flag*, which drops
`gh issue -R owner/repo close 163` exactly as the substring match did; and `NUM` had started
reading any bare numeric token after the verb, so `gh pr create --fill && sleep 2` resolved PR #2.

**Pass 2's subject was pass 1's own edits, and it found two regressions pass 1 had introduced.**
Pass 4 then found a third of the same shape, which is the one worth reading twice.

| | |
|---|---|
| **`
` left unresolved made every multi-line command invisible** | The old dispatch was a substring match and did not care. The new one splits on words, so `cd /repo
gh issue close 163` yields the token `/repo
gh`. No case file had a newline in a command, so the suite was green while this was broken |
| **`GH_ARGS` cut out of the string fell back to the whole command** | `${stripped#*$GH_SUB $GH_VERB}` cannot match when a flag sits between the two, and a `#` that matches nothing hands back everything. `gh pr view 200 && gh issue -R o/r close 163` then reported a missing link on issue **#200** — an issue nobody touched — and made two GraphQL calls to do it. **A wrong finding read over the network is worse than the silence it replaced** |

**Pass 4 found the resolved `
`'s second victim.** The quote strip was a `sed`, and `sed` is
line-based. Once `json_string` resolved `
` into a real newline, a quoted span containing one
stopped being stripped — so a multi-line commit message or `--body` named an arm and sent the
hook to the network about a number inside it. `git commit -m "fix: x

Verified:
gh issue
close 42"` reported a missing link on issue #42. **That is the shape the strip exists to prevent,
and the shape every heredoc-carrying write has.** It is now parameter expansion, which spans
lines by construction and drops the four `sed` forks a firing was paying.

**Pass 3 audited the boxes and caught the claims, not the code.** Three chained case descriptions
said they demonstrated the pre-#230 defect; run against the commit they actually follow, they
report identically before and after. They are regression cover and now say so. It also found two
case files reaching for a live `gh issue view` — a rule this hook states about itself — and the
`payload_url_number` doc block sitting where `invocation_number`'s belonged.

### Findings not acted on

| | |
|---|---|
| **A chain reports on writes that did not run** | `gh pr merge 1 \|\| gh pr merge 2` checks both, though only one executed. Nothing reads a per-segment exit status and `PostToolUse` supplies none. Before this change exactly one arm was exposed; now every arm is |
| **Cost is linear in the number of arms** | Measured, offline: one arm 844 ms, five 1772 ms, ten 2935 ms, fifty 12.5 s. On the live path each close arm adds its own 20-second-bounded GraphQL call. **No regression on the path that matters** — `ls -la`, `git status` and `gh pr view` each cost one `printf \| sed`, the same as before |
| **Two arms naming the same base still write two identical `pr-base=` marks** | `LOG_OBJ` removes the contradiction, not every ambiguity |
| **`tools/verify-hook.sh` verdicts on the exit code alone** | A case asserting *each arm reports about its own number* passes when only one arm reports. Two of this branch's cases are in that position. The script is on `CLAUDE.md`'s never-edited-autonomously list |
| **`_ARC_LOG_FAILED` repeats a check name once per failing arm** | `milestone, milestone found something`. Accurate — two objects failed — and it reads badly. `hooks/lib/activation-log`'s, not this hook's |

### One thing a future reader needs

**The fixture keys are payload-wide, so one case can exercise one kind of arm offline.** A payload
carrying `arc_test_pr_base` takes the PR path and any issue arm in the same command goes to the
network; drop it and the mirror happens. That is why `chained-issue-edit-then-merge` names no
number on its issue edit, and why no case covers an issue create chained with a PR create. A
chained case that needs both arms to *report* cannot be written against the fixtures as they are.

### The branch history

`009b4a5` is titled `wip: #231 loop (temporary)`. The base branch moved four times during the run
and each merge had to happen with a clean tree, so the #231 hook change was parked under that name
and the merge landed on top of it — after which the message could no longer be corrected without
rewriting a merge. **It carries #231's whole change to `hooks/tracker-verify` and its cases**, so
`git revert 009b4a5` is still surgical; only the name is wrong.
