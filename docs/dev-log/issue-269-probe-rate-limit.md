# Issue #269 — the probe runner warns or retries on a rate limit

**Issue:** [#269](https://github.com/Calyx-Engineering/arc/issues/269)  ·  **Parent:** [#145](https://github.com/Calyx-Engineering/arc/issues/145) — Fire  ·  **From:** [#213](https://github.com/Calyx-Engineering/arc/issues/213)

## The defect

A rate limit during #213 destroyed two billed probe runs. Nothing warned, nothing retried, and
the reason it went unnoticed is the shape a killed session leaves behind: an **empty `fired`
list**, which is exactly what an honest miss leaves. The tally cannot tell them apart, so a run
that never happened was scored as a skill that did not fire.

The `result` line is the only place the two differ. `tools/skill-probe.py` was reading its
`total_cost_usd` and discarding everything else on it.

## What it now detects, and what the issue called it

The checklist says *an all-`CUT` run*. That vocabulary is `tools/response-length.py`'s — `CUT`
there is a per-turn verdict on a reply's length, and `tools/skill-probe.py` never scores turns
or lengths. The box is satisfied by a **run-level** verdict instead, which is the same idea one
level up and covers more shapes than the phrase does:

| Shape | Detected by |
| :--- | :--- |
| `result` line with a non-`success` `subtype` | its `subtype` |
| `result` line with `is_error` set | its `is_error` |
| the stream ends with no `result` line at all | the `for`/`else` in `scan()` |
| `PROBE_TIMEOUT` elapses | the watchdog in `attempt()` |
| the session produced no assistant turn | `unusable()` |

A session that answered and invoked nothing is **none of these**. It stays a miss, which is the
one thing this instrument exists to record, and there is a case pinning it in both directions.

**The named file is not the one that lost the money.** #213's two runs were 11-turn
`response-length.sh --probe` runs, so the code that cost $18.01 with no warning is
`tools/response-length-probe.py`, which `tools/skill-probe.py:95-106` is copied from. It still
has no warning and no retry. The box names `tools/skill-probe.py`, so the unit was done as
written and the other runner is filed as [#297](https://github.com/Calyx-Engineering/arc/issues/297).

## The retry

One attempt; if it measured nothing, say so **on stderr before the wait**, sleep
`PROBE_BACKOFF` (default 60s), attempt once more, then stop and report. Not a loop: a probe is
billed per attempt and a rate limit does not clear on a schedule this tool can know.

`unusable` and `retried` travel out in the JSON, so `tools/skill-probe.sh` abandons the case
rather than tallying a miss nobody measured — and then **stops the whole suite**. Stopping at
the case boundary is not enough: a limit still in force would cost two more billed attempts and
another back-off for every one of the remaining twelve cases, after the tool already knew.

## The deadline had to become a watchdog

`PROBE_TIMEOUT` was checked at the top of the read loop, so it only advanced when a line
*arrived*. A CLI blocking on an internal retry-after emits nothing, `__next__` blocks forever,
and the whole suite hangs with nothing printed — the #269 shape exactly, with the timeout that
was supposed to catch it never evaluated. A `threading.Timer` that kills the child is the only
thing that ends a blocked read. The in-loop check stays for the other shape, a stream that keeps
talking past the deadline.

## What the review passes cost

The first implementation passed its own selftest and the gate. Three read-only passes then found
**sixteen defects in it**, of which these mattered:

| | |
| :--- | :--- |
| The timeout could not fire on a hang | Above. Found by pass 2, in code pass 1 had just added |
| A crashed runner was scored as a miss | `skill-probe.py` exiting non-zero, printing nothing, or printing non-JSON all read as `fired: []`. #213's failure one level up, reintroduced in the fix for it |
| JSON with no `fired` key, likewise | Defaulting a missing key to `[]` is the same defect one line after closing it |
| The abandon message claimed a retry that never happened | True only when the JSON says so; a runner that died made one attempt, not two |
| The halt never reached the exit status | A wrapper redirecting to a file recorded a suite that stopped on its first case as a clean run. Now exit 2 — "could not measure", never 1, which marks a finding here |
| Two selftest assertions were vacuous | One named the whitespace guard and could not test it — a later `Skill` turn reset the flag either way. One forbade a string the code cannot print |
| `--help` truncated mid-sentence | It printed a fixed line range that the header outgrew twice in one issue. Now computed from where the code starts |

Every fix above is mutation-tested: the assertion was checked to fail with the behaviour removed
before being kept.

## Gates

| | |
| :--- | :--- |
| `python tools/skill-probe.py selftest` | 27 cases, 27 passed — was 13 |
| `bash tools/skill-probe.sh selftest` | 20 cases, 20 passed — **new**. The script's header used to say there was nothing in it to test without a billed session; the abandon branch, the halt, the denominator and the guards are all JSON in and text out, and `PROBE_PY` swaps the billed half for a canned one |
| `bash tools/verify-all.sh` | 53 gates, all clean, exit 0 |

## Billed by accident, and worth recording

Two stub attempts to test the live path cost four real sessions. `subprocess.Popen` on Windows
appends `.exe` and nothing else, so neither an extensionless script nor a `.cmd` on `PATH` can
stand in for `claude` — both were skipped and the real CLI ran, cut short by `--max-budget-usd`.
The working substitution is one level up: replace `skill-probe.py` through `PROBE_PY`, which is
what the new selftest does and what the header now says to do.
