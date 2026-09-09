# Issue #238 — The activation log's volume

> Dev-log, not a spec. Started at plan time, finalised as a retrospective at PR time.

**Issue:** [#238](https://github.com/Calyx-Engineering/arc/issues/238)  ·  **PR:** [#303](https://github.com/Calyx-Engineering/arc/pull/303)

## Problem

[m44](../product-architecture/mechanisms/m44-event-log.md) named volume control undesigned and
deferred it "until real volume exists". The log rotated out at arc 03's close holds **14,734
entries in 4,643,015 bytes**, and **11,156 of them (75%)** recorded a hook that returned before
any declared check ran. Every archive number here is measured against
[that file](../arc-log/events/arc-03-camp.log.md) as committed, counting an entry from its
timestamp line to the next; the before-and-after byte counts in the retrospective are live
firings instead, and say so.

## Intent and north star

| | |
|---|---|
| **What this issue is really for** | The log is read by a human before any tooling reads it (m44's second consumer). At 4.6 million bytes of which half is one repeated line, that consumer is the one the volume defeats |
| **North star** | m44's *volume control* leaves *what is not designed*, and every firing still writes exactly one entry |
| **What makes it durable** | An assertion in `tests/verify-activation-log.sh`, in both directions. A compression nothing checks is a compression the next hook undoes |
| **Out of scope** | Where the live log *lives* — [#273](https://github.com/Calyx-Engineering/arc/issues/273), the third commit on this branch. Retention after an arc closes — still open in m44, and it needs the rotation [#239](https://github.com/Calyx-Engineering/arc/issues/239) builds before it can be answered |

## Decisions & trade-offs

| | |
|---|---|
| **The rate is kept; the entry got smaller** | The hooks fire at that rate because the tool calls happen at that rate. Nothing about five entries per Bash call is wrong — 4,643,015 bytes of them was, and 51% of that was one line |
| **The whole `skipped:` line goes when nothing ran** | Not only the unreached names. It held two things and neither is evidence about the firing: the hook's own `checks:` declaration copied back — `tracker-verify` declares seventeen today, and in a live firing that line ran to 543 bytes on an entry whose content was "not a tracker write" — and `arc_log_skip` reasons, which on a firing that reached nothing restate the `outcome:` line. 1,213,851 and 1,004,622 bytes of the archived log respectively |
| **Only when the outcome is `ok`** | `denied`, `failed` and `repaired` keep the full line whatever else is true. **A guard, not a measurement** — no entry in that log was both, because a hook that reports something has reached a check first. It costs nothing and keeps the compression off the entries a human actually reads |
| **A partially-run hook is untouched** | [#166](https://github.com/Calyx-Engineering/arc/issues/166) built `not reached` so a hook running two of its seventeen checks does not read as a hook that has two. That is still what happens — the line only goes when the count is zero, where it says nothing |
| **The `checked: — none reached` line stays** | Two bytes saved against a format change to the one line that distinguishes "nothing ran" from "the line was dropped". `verify-activation-log.sh`'s shape assertion is unchanged as a result |

## Rejected approaches

| | |
|---|---|
| **Sample** | A missing entry becomes ordinary, so a hook that stopped firing is indistinguishable from one that was not sampled — the absence m44 exists to fix. It also ends `verify-activation-log.sh` as a gate: *one entry per firing* is only assertable if it is true on every path |
| **Log at a lower rate** | The sampling case wearing different clothes. A hook that logs only sometimes has the same hole |
| **Drop the entry entirely when nothing ran** | The largest saving and the wrong one. A hook that fires and writes nothing looks exactly like a hook that does not fire, which is [#37](https://github.com/Calyx-Engineering/arc/issues/37)'s original defect |

## Spawned

**Torn entries under concurrent appends — found while measuring, not fixed here.** **96 entries**
in the rotated arc-03 log have a header line and no `outcome:` line at all
(`2026-09-09T07:03Z tracker-verify`, `07:24Z camp-branch-check` among them), and review pass 2
counted 50 more carrying two `outcome:` lines from merged concurrent writes. The library writes
one entry as a single `printf` to an `O_APPEND` stream, which is atomic only up to the pipe
buffer; five worktrees were running concurrently against one log. **This contradicts the one
contract `tests/verify-activation-log.sh` asserts** — one entry per firing — and the gate cannot
see it, because it runs one hook at a time against a fixture log. It is a defect in the record
itself and wants its own issue.

## Retrospective

The compression is one branch in `hooks/lib/activation-log`'s write, and it took the declaration
read — an open and scan of the hook file — off the most common firing with it, so the cheapest
entry to write is now also the one written most.

One ordinary Bash payload put through this tree's five `Bash`-matcher hooks directly — hand-fired,
not observed in a session, because the installed plugin is another tree — went **1629 → 707
bytes**, 43%. `tracker-verify` alone **656 → 113**; its 543-byte `skipped:` line is a
seventeen-check firing, which only this tree's copy produces. `mode-guard` is unchanged at 213,
and that is the narrow condition working — it reaches its checks on that call, so it keeps its
full entry.

The same stale claim was corrected in three places: the library's header and two lines of
`tests/verify-activation-log.sh` said three hooks were on the `Bash` matcher, where `hooks.json`
has five registrations.
