# Issue #198 — nothing verifies the mode row is actually written

> Dev-log, not a spec.

**Issue:** [#198](https://github.com/Calyx-Engineering/arc/issues/198)  ·  **PR:** [#256](https://github.com/Calyx-Engineering/arc/pull/256)

## Problem

`tools/set-mode.py` writes `HANDOFF.md`'s Execution mode row and nothing tested it. Its first
version failed silently on 2026-09-07 — a `SyntaxError` under a shell line reading `execution mode
set to Autonomous`. The rewrite's read-back is the only protection against that recurring, and it
had never been fired against a case where it should say no.

## Intent and north star

| | |
|---|---|
| **What this issue is really for** | The read-back is a branch that has never executed. A guard nobody has seen fire is a guard nobody knows works |
| **North star** | The read-back's rejection path runs in the suite, on a write that reports success and changes nothing — #194's failure, reproduced |
| **What makes it durable** | The round trip. `set-mode.py` and `hooks/mode-guard` carry separate regexes for one row; a case that writes with one and reads with the other is what keeps them from drifting apart unnoticed |
| **Out of scope** | Changing what the mode row looks like, or who may write it. The asymmetry — Claude may set Manual and never Autonomous — is [m40](../product-architecture/mechanisms/m40-execution-mode.md)'s and is not enforced here |

## Decisions & trade-offs

| | |
|---|---|
| **The read-back is fired by swallowing the write, not by breaking it** | A read-only file makes the write *raise*, which returns before the read-back ever runs — so the obvious case tests a different branch. The case that matters replaces `io.open` for one call so the write succeeds and lands nowhere. That is #194 exactly: success reported, nothing changed. Both cases are kept, and each says which branch it fires |
| **A control before the round trip** | Absence of a denial is read as "allow", so a hook that crashed or is inert would satisfy every allow assertion. The round trip now first asserts that `mode-guard` **denies** with no `HANDOFF.md` present. Only that makes a later allow mean anything |
| **A clean `HOME` rather than a skip** | Every Arc hook exits 0 when `~/.claude/HOOKS_OFF` exists. Skipping on that leaves `verify-all.sh` printing a pass with the round trip absent, which is the "looks like coverage" failure its own header warns about. `HOME` points at a fixture home instead, as `tools/verify-hook.sh` does, and `CLAUDE_PROJECT_DIR` and `ARC_EVENT_LOG` are dropped so a test firing cannot append to the tracked activation log |
| **A `tools/verify-set-mode.sh` wrapper** | `verify-all.sh` checks its invocation table against `tools/verify-*.sh` and fails on a verifier it does not know. A gate invoked as `python tools/x.py` sits outside that check entirely. Same shape as the other python-backed gates |

## Unplanned but needed

**The two regexes had already drifted, and the round trip found it.** `mode-guard` matches
`^\|[^|]*\bmode\b[^|]*\|` and takes the second field, so it reads `| Mode | Manual` — no closing
pipe — and gates on it. `set-mode.py` required a third group and refused that row as having no
mode row. **The mode could be read and could not be written.** The closing pipe is now optional
and the row is written back closed, so the file is normalised on the way through. Case 9c holds
it.

The refusal was the safe direction — it declined rather than writing into the wrong cell — which
is why nothing had noticed. A row with its cells the other way round is still refused, and case 5
says so: `mode-guard` reads the second cell of a row whose first cell names the mode, so writing
into a row shaped the other way would produce exactly the write-one-thing-read-another the round
trip exists to prevent.

## Retrospective

Twenty-one cases. The six the issue named, the read-back's decision function, the read-back branch
itself, a write that raises, a `HANDOFF.md` that is a directory, the liveness control, and eight
round-trip cases — emphasised row, plain row, no closing pipe, an empty value cell, a cell after
the mode's own, a CRLF file, and the payload's `cwd` read from a directory the hook was not run
from.

`set_mode` is now a function returning a message rather than a straight-line script calling
`sys.exit`, which is what makes the read-back reachable from a case. Behaviour is unchanged except
that a failing write and a failing read-back-read are reported instead of raising, and the
messages use an ASCII hyphen so they render the same on a Windows console as the rest of the
suite. `tools/arc-loop.sh` reads only the exit status.
