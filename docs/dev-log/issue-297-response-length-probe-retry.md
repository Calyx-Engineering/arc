# Issue #297 — response-length-probe.py warns or retries on a rate limit

**Issue:** [#297](https://github.com/Calyx-Engineering/arc/issues/297)  ·  **Spawned by:** [#269](https://github.com/Calyx-Engineering/arc/issues/269) — fixed `tools/skill-probe.py` for the same defect, named there as unfinished because the checklist box named the wrong file  ·  **Related:** [#213](https://github.com/Calyx-Engineering/arc/issues/213) — the two runs it lost

## The defect

`#213` lost two billed 11-turn probe runs to a rate limit — every turn came back `CUT`, one at
$0.000, nothing warned and nothing retried. `#269`'s checklist named `tools/skill-probe.py` and
fixed it there. `tools/response-length-probe.py` is the runner #213 actually spent its money
through — it drives `response-length.sh --probe`, `topic-numbering.sh --probe` and
`saturation-cases.sh --probe` — and was left unchanged.

## What changed

Ported `tools/skill-probe.py`'s `unusable()` / `with_retry()` rather than writing a second copy:

- **`run_case()`** replays one case's turns in a fresh session and `break`s the loop the moment a
  turn comes back cut — the remaining turns are never billed into the same limit.
- **The retry unit is the case, not the turn.** Turns share one session (`--session-id`, then
  `--resume`); a turn that comes back cut leaves that session dead, so there is nothing a
  per-turn retry could resume. `with_retry()` re-runs the *whole* case once, fresh session,
  after a stated back-off, then stops and reports on a second failure.
- **The deadline is now a watchdog.** The old check was `time.time() - started > TIMEOUT` at
  the top of the read loop — it only advances when a line *arrives*, so a CLI blocked on its
  own rate-limit retry never reaches it and the read blocks forever. A `threading.Timer` that
  kills the child from outside the read is the only thing that ends a blocked one; ported from
  `skill-probe.py`'s `attempt()`.

## What review found

**Pass 1 found a `NameError` on every real invocation.** The bottom-of-file rewrite left the
*old* module-level block in place underneath the new one — a second read-modify-write of
`OUT_PATH` referencing `replies`, `session` and `total`, names that no longer existed as
globals once that logic moved into `run_case()`. The new selftest passed because it exits via
`raise SystemExit(selftest())` before the dead block's line is ever reached; every real call —
cut or clean — would have hit the `NameError` and, since all three callers run
`... || exit 1`, aborted the calling shell script right after writing correct JSON. Deleted the
dead block.

**That gap — a selftest that cannot see the wiring it selftests — was itself a finding.** The
module-level script logic was pulled into `main(argv, case_runner=None)` so a stubbed
`case_runner` can exercise the real argv parsing, the `with_retry` call, and the JSON
read-modify-write without a live `claude` session. A new selftest case asserts the stubbed
case's reply lands in `OUT_PATH` under the right key — the exact shape of bug pass 1 found would
now fail this case with a `NameError` instead of shipping silent.

Passes 2 and 3 found nothing further: the fix was clean, and all four checklist boxes have real
evidence in the tree (the audit ran independently against the code, not against this file's
claims).

## Gates

| | |
| :--- | :--- |
| `python tools/response-length-probe.py selftest` | 9 cases, 9 passed — was 8 before the wiring gap above was closed |
| `bash tests/verify-all.sh` | see PR for exit code — no `claude`, no billing; this file's own gate is `run_gate "response length probe cases" python tools/response-length-probe.py selftest` |

## Not done

| | |
| :--- | :--- |
| A cut case still exits 0 and writes its partial replies | `skill-probe.py`'s `unusable`/`retried` fields travel out in JSON for its shell wrapper to abandon the whole suite on a still-live rate limit — #269's own reasoning for why a per-case stop is not enough. The three shell callers here (`response-length.sh`, `topic-numbering.sh`, `saturation-cases.sh`) were not touched; each still does `... || exit 1` on this script's own exit code, which stays 0 even when a case is unusable after its retry. Fixing that is a change to three wrapper scripts, not this issue's checklist, and is left as a follow-on |
