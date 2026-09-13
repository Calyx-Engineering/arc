# Issue #315 — 0.67 rejects two out of three

Three instruments compare a rate to `0.67` with `>=`: `tools/report-grade.py`,
`tools/skill-probe.sh`, `tools/report-shape-probe.sh`. `0.67` is this repo's own shorthand for
*two out of three* — its comments already called it that before this issue existed — but `2/3`
is `0.6666…`, so `>= 0.67` rejects the exact ratio the constant was named for. Measured on
[#260](https://github.com/Calyx-Engineering/arc/issues/260): `2/3`, `4/6` and `6/9` all printed
`FAIL`.

## The decision

`0.67` means two-thirds, and the comparison gets a tolerance. Not a tolerance *band* around
0.67 — the fix is to round both sides to the threshold's own two-decimal precision before
comparing: `round(r, 2) >= round(threshold, 2)`. `round(2/3, 2) == round(0.67, 2) == 0.67`, so
`2/3`, `4/6` and `6/9` all read `PASS`. A rate compared at more precision than the constant it
is checked against claims to have is the bug — not the ratio, and not the threshold's value.

This is not a threshold change: `0.67` is untouched in all three files. #260's constraint
("not a way to pass a suite") holds — the fix makes the comparison as precise as the constant
already says it is, nothing more.

## The fix

Applied identically in one commit to all three instruments, so they cannot disagree:

| File | Site |
|---|---|
| `tools/report-grade.py` | the `cols` comprehension deciding the aggregate verdict |
| `tools/skill-probe.sh` | the per-case `python -c` verdict line |
| `tools/report-shape-probe.sh` | `row()`'s per-column `python -c` verdict line |

`tools/report-shape-probe.sh` carried a stale comment claiming the old rejection was "correct,
and the same way `tools/skill-probe.sh` fails it" — written when that was believed to be a
deliberate design choice, before this issue existed to say otherwise. Corrected in the same
edit. The three-decimal display precision beside the verdict is unchanged and still useful: it
is why `2/3` and `4/6` print as visibly the same rate rather than both collapsing to `0.67`.

## Selftests

Each instrument's selftest gains a `2/3` case:

| Instrument | Case | Shape |
|---|---|---|
| `tools/report-grade.sh` | "a 2/3 rate clears the 0.67 threshold, not just close to it" | 3 fixture cases, each column at 2/3 (2 pass + 1 fail) |
| `tools/skill-probe.sh` | "a 2 of 3 firing rate clears the 0.67 threshold" | `twothirds` fake mode: fires on runs 1-2, misses run 3 |
| `tools/report-shape-probe.sh` | one assertion per column, "a 2/3 rate clears the threshold on…" | `twothirds` fake mode: two good reports then one bad, same 2/3 on all three columns |

All were `FAIL` before the fix and are asserted `PASS` now — a selftest that would have caught
this issue had it existed when the comparison was written.

`bash tools/report-grade.sh selftest` — 73 → 74 cases (one added on top of #314's two).
`bash tools/skill-probe.sh selftest` — 20 → 21 cases.
`bash tools/report-shape-probe.sh selftest` — 35 → 36 cases.
All green.

## Spawned

`tools/response-length.py` and `tools/topic-numbering.py` default to the same `0.67` threshold
and the same bare `r >= threshold` comparison — `2/3` fails there too. Not fixed here: this
issue names exactly three instruments, and neither of these two was measured by #260's probe or
named by the issue. Recorded in #315's own Spawned table; not filed as a new issue in this run.

## Gates

`bash tests/verify-all.sh` — run once, covering both #314 and #315 in this batch; see below.
