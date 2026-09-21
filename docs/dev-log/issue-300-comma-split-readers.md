# Issue #300 — the comma-split payload reader, in the skeleton and the four hooks copied from it

> Dev-log, not a spec. Started at plan time, finalised as a retrospective at PR time.

**Issue:** [#300](https://github.com/Calyx-Engineering/arc/issues/300)  ·  **PR:** [#337](https://github.com/Calyx-Engineering/arc/pull/337)

## Problem

`hooks/TEMPLATE` carried a `field()` helper built from `tr ',{}' '\n\n\n' | grep -m1 | sed`, and
four deployed hooks were written from that skeleton. [#230](https://github.com/Calyx-Engineering/arc/issues/230)
replaced the same reader in `hooks/tracker-verify` and recorded the rest as *Spawned*; this is that
rest.

**The reader was wrong twice, and the second defect is the one the issue does not name.**

| | |
|---|---|
| **Truncation** | The `tr` split the whole payload on commas, so a value carrying one was cut at it |
| **The fragment is handed back as the value** | When the `sed` could not parse the comma-split fragment it printed that fragment **unchanged**. `docs/notes,draft.md` came back as `"file_path":"docs/notes` — non-empty, so every `[ -z ]` guard downstream passed |

The second is worse than the first. A truncated value is short; a fragment-as-value is a
syntactically valid string that no `[ -z ]` check rejects, so guards written to be silent on
half a payload spoke instead.

## Intent and north star

| | |
|---|---|
| **What this issue is really for** | The skeleton is the product. Four hooks inherited this reader because `hooks/TEMPLATE` shipped it, and a fifth would have |
| **North star** | One reader shape, the one `tracker-verify` proved, carried by the skeleton so the next hook gets it for free |
| **Out of scope** | `hooks/handoff-archive:123` and `hooks/session-index:159`, which carry a *different* `field()` — the naive first-quote form, not a comma split. Recorded under *Findings not acted on* |

## What was built

Five commits, one file of hook source each, which is `CLAUDE.md`'s rule and also what makes
`git revert` surgical here.

**The reader is `tracker-verify`'s `json_string`, renamed `field`.** The five copies are
byte-identical to each other; against `tracker-verify`'s they differ in the function name, a
six-line comment block and the whitespace of two `case` arms, and in nothing else. It walks the JSON
string in parameter expansion: the value ends at the first quote whose preceding backslash run
is even, and `\"`, `\\`, `\n`, `\t` and `\r` are resolved because the resolved form
is what the caller acts on. No closing quote yields **nothing**, never the rest.

Keeping the name `field` mattered. Three of these hooks already define a `json_string()` that
**encodes** a string for the deny reason; `tracker-verify` has no such function, which is why the
name was free there and is not here. Two functions, one name, opposite directions is how a later
edit picks the wrong one.

### What changed beyond the reader itself

| | |
|---|---|
| `camp-branch-check` | Two readers, not one. `CMD` was a second inline copy — the one the issue names at line 68 — and is now `field command`. Its `CWD` line dropped a hand-rolled `sed -e 's/\\\\/\\/g'` that `field` now does |
| `branch-guard` | `file_path` stops arriving with its separators doubled: `r:\\arc\\src\\index.ts` used to reach `tr '\\' '/'` as written and normalise to `r://arc//src//index.ts`, which is the string every pattern below then matched against. `CWD` gained the same unescape, and that one changes nothing — see *What was measured, against what was assumed* |
| `camp-session-start` | Its `grep` was **unquoted** — `grep -m1 -- "$1"` — so any fragment containing the letters `cwd` answered for `"cwd"`. The new reader quotes the key itself. A corrupt session id also named the once-per-session `MARKER` file, which no verdict shows |
| `mode-guard` | A *second* reader, inline, written because `field` truncated at commas. Deleted. Its `\t`/`\r` flattening stayed as an explicit line, because `field` yields those raw and `set -- $SEG` splits on IFS, which holds a tab but not a carriage return |

### The cases

One per hook, each written **before** the fix and each measured against the pre-change hook.

| Hook | Case | Field carrying the comma | Pre-fix |
|---|---|---|---|
| `camp-branch-check` | `report/comma-in-command.json` | `command` | `FAIL allow` |
| `branch-guard` | `pass/comma-in-path.json` | `file_path` | `FAIL deny` |
| `camp-session-start` | `malformed/truncated-comma-value.json` | `session_id` | `FAIL report` |
| `mode-guard` | `deny/manual-cwd-comma.json` + `pass/autonomous-cwd-comma.json` | `cwd` | `FAIL` on one of the pair |

**Of the four, only `camp-branch-check` read a `command` through the broken reader.** The issue's
third box says "a case per hook … for a command carrying a comma"; `branch-guard` and
`camp-session-start` never read a command at all, and `mode-guard` read its own with a quote-aware
inline walker that had no comma defect — `deny/manual-commit-chained.json` covers that and passes
before and after. So the case that discriminates in each hook is the field that hook actually read
through `field`, and that is what was written.

**`camp-session-start`'s case is a `malformed/` one, and that is the point.** The hook already
guards against a half-written payload by requiring both a session id and a tool name. The old
reader defeated that guard: on a payload cut off inside a comma-carrying value it returned
`"session_id":"verify` — non-empty — so the hook classified a branch and spoke on input that was
never a hook call.

**`mode-guard` needed a PAIR, and one case there is a trap.** Against the broken reader both
cases fall back to `$PWD` and return the **same** verdict — whatever the ambient tree's mode row
says, or a deny where there is no `HANDOFF.md`, which is every fresh clone since it is gitignored.
A single deny case would have gone green on a clean machine for the wrong reason. With the mirror,
exactly one of the two is wrong whatever the ambient state, so the pair goes red anywhere.

The deny case is named `manual-cwd-comma.json` rather than `comma-in-cwd.json` because it must not
sort first in `deny/`: `tools/verify-hook.sh:235-236` runs only the **first** speaking case for all
seven kill-switch assertions, and those payloads carry a repo-relative `cwd`. Named
`comma-in-cwd.json` it sorted first and took four kill-switch assertions red with it.

## What was measured, against what was assumed

**The Windows-`cwd` claim was wrong, and pass 4 caught it in the PR body, two commit bodies and
this file.** The assumption was that the old reader's doubled separators made `[ -d ]` fail, so a
Windows session fell through to `$PWD`. Measured on this machine, against a payload carrying real
JSON-escaped separators:

```
old value=[R:\\arc-wt\\300]
[ -d ]   -> TRUE
git -C   -> arc/04-dogfood-issue-300-comma-split-readers
```

Windows collapses the doubled separator, so neither `[ -d ]` nor `git -C` cared. The unescape
matters where a value is **walked as a string**: `camp-branch-check` does that in its `CLAUDE.md`
walk-up — `${dir%/*}`, and `R:\\arc-wt\\300` contains no `/` — which is why
[#162](https://github.com/Calyx-Engineering/arc/issues/162) unescaped by hand there, and why
`branch-guard` and `camp-session-start`, which do no walk-up, never noticed. For `branch-guard`'s
`file_path` it does matter, because that value is normalised with `tr` and then pattern-matched.

**No case in this PR exercises a Windows `cwd`**, so the claim was unevidenced as well as wrong.
Three documents carried it because one sentence was written once and copied.

## Evidence

| | |
|---|---|
| `bash tests/verify-all.sh` | exit 0 |
| `bash tools/verify-hook.sh hooks/camp-branch-check` | 34 passed, 0 failed |
| `bash tools/verify-hook.sh hooks/branch-guard` | 25 passed, 0 failed |
| `bash tools/verify-hook.sh hooks/camp-session-start` | 15 passed, 0 failed |
| `bash tools/verify-hook.sh hooks/mode-guard` | 41 passed, 0 failed |
| Each case against its pre-change hook | one new failure each — the full runs are in the commit bodies |

`hooks/TEMPLATE` has no `verify-hook.sh` run, because it has no case directory and is skipped by
name at `tests/verify-all.sh:210` and `tests/verify-activation-log.sh:230,440`. `bash -n` and a
direct exercise of the spliced reader stand in its commit body instead.

## What the passes found

| | |
|---|---|
| **Pass 1** | The `mode-guard` case could not discriminate alone (above), and the same file's glob position had taken the kill-switch block with it |
| **Pass 2** | A fixture header still naming the pre-rename case file; a commit body asserting a collation-dependent file order as if it were fixed; and a commit body citing `862a26d^` as its measurement baseline — a sha orphaned by the amend that wrote it. The branch was rebuilt to fix all three, and the baseline is now named by relationship rather than by sha |
| **Pass 2, on the skeleton** | `hooks/TEMPLATE`'s reader comment read "which is what this was" — history a hook copied from the skeleton has never had. Reworded to say what the skeleton propagated and when it stopped |
| **Pass 3** | Three ticks whose evidence was real and whose wording overstated it: a line number two off, "byte-identical" where the copies are identical to each other and not to their source, and "three readers" in `mode-guard` where two were payload readers and the third was the deny encoder. It also caught that `pass/autonomous-cwd-comma.json` is green against the pre-change hook **on this tree**, which is the pair argument working rather than a defect |
| **Pass 4** | Read as a reviewer who was not here, it found the PR's own defects rather than the code's: a milestone on a PR that closes an issue (#204 forbids it — the issue is the unit), a title missing the `arc-04:` prefix and naming two deliverables, two required sections absent, and the Windows-`cwd` claim above — which is the one that mattered, because it was a belief nobody had tested |

## Findings not acted on

| | |
|---|---|
| **`field` now means two contracts inside `hooks/`** | `handoff-archive:123` and `session-index:159` keep a naive first-quote reader under the same name. Not comma splits, so outside #300 — but a future author reading one and editing the other has no signal. `handoff-archive`'s own comment already admits "a value containing an escaped quote would truncate" |
| **Nothing stops the reader coming back** | `tests/verify-hook-source.sh` already sweeps `hooks/` and `hooks/lib/` and is the natural home for a rejection of `tr ','`-as-payload-read. It would not have covered the skeleton — line 96 excludes `TEMPLATE` — which is the row below. Without one, the sixth copy re-enters as silently as the first five did |
| **The skeleton's 60-line reader is verified by nothing** | `TEMPLATE` is skipped by every gate by name, so the file every future hook is copied from now carries an unchecked parser where it carried a three-line pipeline. A `tools/hook-cases/TEMPLATE/` directory would close it |
| **`tools/verify-hook.sh:193-198` understates its own constraint** | Its comment explains that `cd` is not the lever because "several of `camp-branch-check`'s payloads carry a repo-RELATIVE `cwd`". `mode-guard` now has two. The file is on `CLAUDE.md`'s never-edited-autonomously list, so the correction is proposed in the PR |
| **The reader skips spaces after the colon, not tabs or newlines** | `"cwd":\t"/a/b"` yields empty, silently. Inherited verbatim from `tracker-verify`; not introduced here, and no producer of these payloads emits one |
| **Five verbatim copies, not `hooks/lib/`** | `hooks/lib/` exists and all five files already source it, so a sixth copy is now cheaper to make than the first five were. The skeleton is why it stayed inline: `hooks/TEMPLATE` is copied into repositories that may not take `hooks/lib/` with it, and a skeleton whose reader is one missing `.` from silence is a skeleton that ships broken. **That argument covers `TEMPLATE` and not the four deployed hooks**, which could source one |
| **The issue's *Done when* names `tools/verify-all.sh`** | The gate is `tests/verify-all.sh`. `tools/verify-all.sh` does not exist |

## One thing a future reader needs

**A case that goes green against the broken code proves nothing, and two of the four first drafts
did exactly that.** `branch-guard`'s first attempt put the comma in a path that was source work
either way, and `camp-session-start`'s first attempt asserted a verdict the corrupt session id did
not change. Both were rewritten only because each case was run against the pre-change hook before
being kept. That measurement is cheap — `git show <commit>^:hooks/<name>` into a scratchpad
directory alongside a copy of `hooks/lib`, then `tools/verify-hook.sh` at it — and it is the only
thing separating a regression test from a decoration.
