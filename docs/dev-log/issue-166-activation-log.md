# Issue #166 — An activation log

> Dev-log, not a spec. Started at plan time, finalised as a retrospective at PR time.

**Issue:** [#166](https://github.com/Calyx-Engineering/arc/issues/166)  ·  **PR:** __PR__

## Problem

[#37](https://github.com/Calyx-Engineering/arc/issues/37) built the format and the file.
It closed with the one thing it could not do written into its own retrospective: *"that
anything writes to it"*. A year of format with no producer — `.claude/arc/log.md` held three
hand-written entries and nothing else. Three friction-log rows said the same thing from three
directions: nothing says which artifact fired, when, or whether it was right.

The registered hooks were the producers that did not exist. There were five when this branch
was cut and six by the time it merged — `handoff-archive` landed on the base via
[#151](https://github.com/Calyx-Engineering/arc/issues/151) in between, which review pass 3
caught before "every hook" quietly became false.

## Decisions & trade-offs

| | |
|---|---|
| **One sourced library, not a line in each hook** | `hooks/lib/activation-log`. Six hooks, forty-odd exit paths, one entry format — the alternative is six copies that drift, and the format authority is already a file elsewhere. It is also what made instrumenting the sixth hook a ten-line change rather than a re-derivation |
| **The write is an EXIT trap** | The requirement is *before exit, success or failure*. `tracker-verify` has fourteen exit paths — thirteen `exit` statements, one of them inside a subshell, plus three `report` call sites; instrumenting them one at a time instruments thirteen of them. A trap installed once covers every path including a crash, and it is the only shape that stays correct when someone adds an exit later |
| **The trap ends with `exit "$_arc_rc"`** | Bash restores the pre-trap status on its own, but a guardrail must not depend on that: a PostToolUse hook's exit 2 is how it speaks, and an EXIT trap that swallowed it would turn a report into silence |
| **The `checks:` header is read, not restated** | The library parses the hook's own `camp-reports:` declaration for the check list. One declaration already drives the spoken report; a second list in the logging call would be the thing that goes stale |
| **A declared check nobody marked is `not reached`** | This is what makes a partially-run hook honest. `tracker-verify` declares thirteen checks and runs two on a typical firing — without the default, the entry would look like a hook that only has two |
| **Each hook marks its checks at the point they run** | `arc_log_pass` / `arc_log_fail` / `arc_log_skip`, at the branch that decided. A check marked from the top of the hook is a claim about code that had not run yet |
| **`scan_title`'s five findings are matched back to the five checks that produced them** | `verify-tracker-body.sh title-findings` returns prose. Marking all five failed because one fired would put four checks on the record as having found something they did not |
| **A second verifier, not a block in `verify-hook.sh`** | That script is on CLAUDE.md's never-edited-autonomously list. It also asks a different question — did the hook reach the right verdict — where this asks whether it left a record. `tools/verify-activation-log.sh` reuses the same case directories and is wired into `verify-all.sh` |
| **The fixture builder is duplicated between the two verifiers** | Deliberate, and commented as such. The excluded script cannot be edited to export it, and two runners substituting the same payload differently would be a worse problem than the duplication |
| **`ARC_EVENT_LOG` overrides the path** | The harness needs to read what a firing wrote. Nothing else sets it, and the default stays the single plugin-level file m44 names |
| **The gate asserts verbosity independence structurally** | Not by reading the library's intent but by grepping its code for `operating-agreement`, `verbosity`, `loud`, `quiet`. m44's whole claim is that turning the volume down costs display and never data; that is a property of the code, so it is checked as one |

## Rejected approaches

| Rejected | Why |
|---|---|
| A `printf >> log` at each `exit` | Thirty-odd sites, and the next exit anyone adds is unlogged. It is also five copies of the format |
| Editing `hooks/TEMPLATE` | On the never-edited-autonomously list. It comes as `docs/arc-work/proposed-template-activation-log.md`, the same shape as the standing `proposed-verify-hook-declaration-check.md` |
| Adding the assertion to `tools/verify-hook.sh` | Same list. And splitting keeps each script answering one question |
| A `log/` subdirectory of new cases per hook | `verify-hook.sh` iterates `pass deny report malformed` and would ignore it, so a separate runner was needed either way — and the existing 106 cases already exercise every path worth asserting on |
| Running all four assertions on all 106 cases | Four process spawns per case is ~7 minutes on Windows. `one entry`, the shape and the stdout check run per case; fails-open and the kill switch are library properties and run once per kind |
| Comparing stdout against the same run with logging disabled | It catches an asymmetry, not noise: a hook that echoes its entry unconditionally passes that comparison. The gate greps stdout for entry text directly instead |
| Marking `tracker-verify`'s title checks as a group | Four false records to avoid one prose match |

## What was verified

| | |
|---|---|
| `bash tools/verify-all.sh` | **37 gates, all clean**, exit 0 — which runs `verify-hook.sh` against all six hooks, unchanged from before this work |
| `bash tools/verify-activation-log.sh` | **392 passed, 0 failed** — every case in all six case directories, plus the library checks |
| `bash tools/verify-activation-log.sh selftest` | **7 passed, 0 failed**. A control that logs one correct entry and reads as a pass, and six fake hooks with known defects — logs nothing, logs twice, echoes its entry to stdout, no `checked`/`outcome` line, logs through the kill switch, speaks up when the log is unwritable — each read as a failure. A checker that cannot fail is a checker nobody should read a pass from |
| A hook invoked as Claude Code invokes one | `CLAUDE_PROJECT_DIR` set, a real payload on stdin: one entry, in `templates/event-log.md`'s format |
| Cost per firing | +24ms `mode-guard`, +18ms `tracker-verify`, +24ms `camp-branch-check`, +25ms `handoff-archive`, each against the same hook with the `arc_log_*` calls stubbed out, 20 runs each. ~+91ms per Bash tool call, since four of the six are on that matcher |

**What could not be verified — and this is the important half.** *That a real session produces
a line per firing.* The installed plugin is the main tree (`~/.claude/settings.json` points the
marketplace at `R:\arc`), which does not carry the library, and `tools/plugin-reload.sh` says a
running session does not pick up a reload. So no hook has fired in a session with this code.
That is the soak, and it happens after this merges — CLAUDE.md's rule that a change made at PR
time soaks on the next work stretch.

Also unverifiable: that the template proposal works, because nothing executes a template. The
gate's assertion that every registered hook sources the library is the backstop — a new hook
that omits it fails, it just fails later than the template would have prevented.

## Retrospective

Two of the gate's own structural checks failed on their first run — the kill-switch check and
the verbosity check — and both were right to. The kill switch check was reading the library's
header comment rather than its code, and the library's first line of code was an initialiser
rather than the switch. Both fixed: the library now opens with the `HOOKS_OFF` test, and the
gate reads code only. A checker that reads a file's explanation as the thing being explained
fails every well-documented file, which is most of this repo.

**Review pass 1 found the claim above was originally the opposite, and it was wrong.** The
first version of this dev-log, and of the issue body, recorded live firing as verified. It was
not: the ~330 entries offered as evidence were the verifiers' own fixtures. The library
defaulted the log path to `$PWD/.claude/arc/log.md`, so every `verify-hook.sh` run appended
fabricated entries to the tracked, append-only file — 2228 lines of them, staged for this PR,
in a file whose header reads *"Never edit or reorder an existing entry."* Not one carried a real
command or file path.

Two fixes came out of it. The library writes only when `ARC_EVENT_LOG` or `CLAUDE_PROJECT_DIR`
is set, so a verifier leaves no trace; and the gate asserts that by running a hook with neither
set and comparing the log file's size in bytes before and after. Not `git status` — a modified
file reads as modified on both sides, so a status comparison is blind in exactly the state the
defect produced. Review pass 2 caught that second version and demonstrated it: with the fallback
re-injected and the log already dirty, the assertion passed.

**A record that cannot tell a test run from a session is worse than no record, because it is
read as one** — and the log was the thing being built.

The same pass measured the first version at **+1.4s per Bash tool call** — about twenty-five
process spawns per firing, from `printf | tr | sed` in a command substitution per field and a
five-process pipeline to read the declaration. m44 lists *cheap to append* as a requirement, and
`hooks/tracker-verify:48-50` had already rejected exactly this shape for exactly this reason.
The write path is now parameter expansion and builtins throughout: **+66ms per Bash call**,
measured the same way.

Volume is the finding that survives. m44 named it undesigned and deferred it *"until real volume
exists"*. Four of the six hooks are on the Bash matcher, so a session appends four entries per
Bash call — `mode-guard` and `handoff-archive` before it, `tracker-verify` and
`camp-branch-check` after — most recording that nothing ran. Spawned as
[#238](https://github.com/Calyx-Engineering/arc/issues/238) rather than solved here — the issue
asked for a line per firing and got one; whether every firing deserves a line is the next
question. What the real rate is can only be measured once the soak has happened.

The live log also still carries `arc/03-camp` in its header, five months of arc later.
Rotation is m44's, at arc open, and nothing performs it —
[#239](https://github.com/Calyx-Engineering/arc/issues/239).
