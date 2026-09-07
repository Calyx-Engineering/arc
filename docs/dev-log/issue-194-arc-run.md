# Issue #194 — start a workstream with one command

**Issue:** [#194](https://github.com/Calyx-Engineering/arc/issues/194)  ·  **PR:** not opened

## Problem

Starting a workstream took four steps across two surfaces: restart the session, tell Claude to switch to autonomous, open a terminal, remember which workstream was next, and run `tools/arc-loop.sh <parent>`. Nothing connected the mode grant to the loop that needed it, and the user had to hold the order in their head.

The order was also wrong in principle. It was the parent issue numbers — a creation counter. A workstream filed later always sorted last and **could never be inserted between two existing ones**, which is inconsistent with the level below, where issues inside a workstream are ordered explicitly with `reprioritizeSubIssue`.

## An assertion that was wrong

I said `claude -p` could not usefully run from inside a session — *"a session inside a session"* — and designed a terminal-only workflow around it. Tested instead of assumed:

```
$ printf "Reply with exactly: NESTED OK\n" | claude -p
NESTED OK
exit=0
```

It works. The whole thing can be driven from chat, which is what made `/arc-run` possible at all.

## Decisions and trade-offs

| | |
|---|---|
| **`arc-loop.sh` writes the mode row** | A human ran the script, which is the same explicitness as saying *switch to autonomous* in chat. m40 §4's asymmetry holds: no agent raises its own switch on its own reading |
| **It writes Manual on every exit path** | Boundary reached, `--max` hit, a run exiting non-zero, all-blocked, and the same-issue-twice guard. A script that raises the mode and dies leaves it raised |
| **`--dry-run` does not touch the row** | Inspecting the queue is not starting work |
| **Order lives in an arc parent issue** | [#196](https://github.com/Calyx-Engineering/arc/issues/196), labelled `arc`, its five ordered children being the workstreams. Same mutation as one level down, and it gives the arc a tracker object it did not have — nothing in GitHub said these five were one arc except a shared milestone |
| **`/arc-run` stops and waits** | It names the workstream, the first issue, the blocked count and what it will do to the mode, then waits. That is the last point before unattended work |
| **`--max 1` on a first run** | The dispatch path has less coverage than the selection path, and thirteen issues is a long way to go before a bad dispatch is noticed |

## A gate overruled, correctly

The user asked for the process document to be folded into this issue. `verify-tracker-body.sh title` rejected the combined title — *"names more than one deliverable"* — and I split the issue anyway, then had to fold it back.

**A gate is a report, not a veto.** The user's instruction outranks it, and the right response was to note the finding and comply.

## A silent failure, in the code written to prevent silent failures

`set_mode` was first written as a Python heredoc inside `arc-loop.sh`. Its escapes were mangled on the way in, so it raised a `SyntaxError` — and the shell printed `execution mode set to Autonomous` anyway. **It reported success and changed nothing**, which is the failure this arc exists to fix, in the function built to enforce the rule.

It was found only because the user asked whether `/arc-run` would actually work. Every prior test had been `--dry-run`, which skips the mode write deliberately.

Now `tools/set-mode.py`, a real file rather than a heredoc, **with a read-back**: it re-reads `HANDOFF.md` after writing and exits non-zero if the row does not say what it just wrote.

## Verification

`bash tools/verify-all.sh` — 11 gates, all clean. `arc-loop.sh --dry-run` selects [#155](https://github.com/Calyx-Engineering/arc/issues/155) for Fire and leaves the mode row untouched.

**End to end, for the first time**, against the real `HANDOFF.md`:

| | |
|---|---|
| `set-mode.py Autonomous` | Row flips, boundary row added |
| `hooks/mode-guard` on a `git commit` payload | **allows** |
| `set-mode.py Manual` | Row flips back, boundary row removed |
| `hooks/mode-guard` on the same payload | **denies** |
| `HANDOFF.md` afterwards | Byte-identical to the backup |

The arc derivation was tested on five branch shapes — the arc branch, an issue branch, a direct-PR branch, a second arc, and `main`, which correctly refuses.

## What is not proven

**The driver has still never dispatched a real run**, and `/arc-run` has never been invoked — it is a command file in the working tree, not yet in the installed plugin. A fresh chat sees it only after this merges, `tools/plugin-reload.sh` runs, and the session restarts. **The first run should pass `--max 1`.**

**`set-mode.py` has no selftest.** Its read-back is the protection, and it is the thing that just failed silently. A case directory belongs in `tools/verify-all.sh` and is not here.

[`execution-process.md`](../arc-work/04-dogfood/execution-process.md) §7 is the full list, and the arc-log's close checklist now says the process graduates on that section being shorter — not on the document existing.
