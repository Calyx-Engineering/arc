# Issue #265 — one case reader shared by the four graders

> Dev-log, not a spec.

**Issue:** [#265](https://github.com/Calyx-Engineering/arc/issues/265)  ·  **PR:** written in after it opened

## Problem

`read_case` was written four times — `tools/report-grade.py`, `tools/topic-numbering.py`,
`tools/response-length.py`, `tools/skill-cases.py` — and fence tracking five times: three inside
`report-grade.py` alone, one in `topic-numbering.py`, and one in `response-length.py` that was not
the same rule at all (below). `report-grade.py`'s third copy says so in its own docstring:

> AND A FENCE IS TRACKED, because this is the third reader in the file and the other two track it.

Raised on [#159](https://github.com/Calyx-Engineering/arc/issues/159), raised again on
[#213](https://github.com/Calyx-Engineering/arc/issues/213).

## What was built

`tools/case_reader.py` — a module, not a script. Three things:

| | |
|---|---|
| `fields(path)` | Yields `(section, key, value)` for every meaningful line of a `case.yaml`. `section` is `""` on a top-level line and the enclosing top-level key on an indented one; `key` is `"-"` for a `- item` list entry |
| `Fence` | The CommonMark rule: a fence closes on a run of the **same character**, at least as long as the opener. `fence.delimiter(line)` is true on the delimiter itself; `fence.open` is true between two |
| `token` / `leading_int` | The two value readings the four graders wanted. `token` is what `re.match(r"key:\s*(\S+)")` read; `leading_int` is what `re.match(r"key:\s*(\d+)")` read |

**The scan is shared; what a field MEANS is not.** Each grader keeps its own `read_case` — 5, 17,
18 and 24 code lines, docstrings and comments excluded — mapping `fields()` onto the tuple or dict
that suite scores from. That is the half that is genuinely per-suite, and moving it into the module
would have made one function that has to know which of four callers it is serving.

**Value is the whole remainder, not the first token.** The four readers disagreed: `report-grade`
took `v.strip()` because `lines: 12 - 40` has spaces in it, and the other three matched `(\S+)` or
`(\d+)`. Handing over the remainder keeps the looser one working and lets the stricter ones ask
for what they meant.

### The underscore in the filename

`case-reader.py` cannot be imported. Every other file in `tools/` is hyphenated because every
other file in `tools/` is a script run by path from its `.sh` wrapper. This one is imported, so it
is `case_reader.py`. No `sys.path` juggling is needed: each wrapper runs `python "$HERE/<name>.py"`,
which puts `tools/` first on `sys.path`.

## The fence toggle that was wrong before it fired

`response-length.py` did not use the CommonMark rule. It counted with:

```python
n, in_fence = 0, False
for line in (text or "").splitlines():
    if FENCE.match(line):
        in_fence = not in_fence
```

against `FENCE = re.compile(r"^\s*(```|~~~)")`. A toggle cannot see that a fence closes only on a
run of the same character at least as long as the opener, so a `~~~` line inside a ``` ``` ``` block
flipped it and everything after was counted on the wrong side of the budget. It is now
`case_reader.Fence` like the other four sites.

**The suite scores identically either way** — no case in `evals/response-length` nests a fence — so
this is a defect removed before it fired, not a score corrected. Recording it because a silent
behaviour change inside a refactor is exactly what the "identical before and after" box is for.

### The other three behaviour changes, all on input no case file contains

| | |
|---|---|
| **Whitespace before the colon now reads** | `shape : opening` is `shape`. Three of the four readers matched `re.match(r"key:\s*…")` and rejected it; `report-grade` already used `partition` and took it. One behaviour instead of two, in the direction that loses no case |
| **A lone dash yields nothing** | It did in all four readers. The first draft of `fields()` yielded it as an empty list item, which would have put `""` into `skill-cases`' `expect` list and turned a control case expecting silence into one that can never pass. Found by pass 1. Pass 2 then found the fix tested the raw line, so `-:` still reached the caller; the test is now the key, after the split |
| **An indented line with no usable section above it yields nothing** | It belongs to no section. `report-grade` skipped indented lines outright and the other three had nothing for their `section` to equal. The first draft emitted it as a top-level field, so `  budget: 99` on line 1 would have been read as the budget. Found by pass 1. Pass 2 found the fix covered only "before the first key", so a top-level line with an empty key — `: something` — still adopted every nested line after it; the guard is now falsiness, which covers both |

## Evidence

Every suite run twice: once against `git archive HEAD` — 047b3d5, which carries none of this work
— extracted to a scratch tree, once against the working tree. Output compared with `diff`, not by
eye. Both halves of each suite, the live one and `selftest`, exit 0 in both trees.

| Suite | Score | Before vs after |
|---|---|---|
| `tools/report-grade.sh` | opens with the conclusion **1/3 0.33** · table rows carry a source **1/4 0.25** · conflicts resolved out loud **2/2 1.00** · verdict FAIL | byte-identical |
| `tools/topic-numbering.sh` | all cases, every topic labelled **0/3 0.00** · verdict FAIL | byte-identical |
| `tools/response-length.sh` | all cases, within budget **8/25 0.32** · verdict FAIL | byte-identical |
| `tools/skill-cases.sh` | all opening cases **6/17** | byte-identical |

A FAIL in that column is the measurement each suite exists to report, not a broken run — the
scores are what they were before this issue and this issue did not set out to move them.

| Gate | Result |
|---|---|
| `bash tests/verify-case-reader.sh` | 28 passed, 0 failed, exit 0 |
| `bash tests/verify-all.sh` | 48 gates, all clean, exit 0 |

`tests/verify-case-reader.sh` is a thin wrapper over `python tools/case_reader.py selftest`, the
shape `verify-set-mode.sh` already uses: `verify-all.sh` checks its invocation table against
`tests/verify-*.sh` on disk and fails on a verifier it does not know, so a gate invoked as
`python tools/x.py` would sit outside that check. It is wired into `KNOWN` and given an
invocation in the same commit.

## Not done, deliberately

**Two more copies of the same scan survive**, both outside the four graders the issue enumerates:

| | |
|---|---|
| `tools/saturation-cases.py` | `callout_turn`, `fires_from`, an `expect` list, a `source` section. Its docstring names `skill-cases.py` as the trade it is copying |
| `tools/environment-blame.py` | `callout_turn`, `blame_from`, the same two sections. Its docstring names `saturation-cases.py`. Its top-level test differs — `not line.startswith((" ", "\t", "-"))` rather than `not line[:1].isspace()` — so a top-level `- item` is nested there and top-level in the other five |

The issue enumerates four graders and its checklist says four; converting these is work nobody
scoped. Both are filed as [#285](https://github.com/Calyx-Engineering/arc/issues/285), carried as
#265's `Spawned` row. The second was found by pass 1, after #285 was filed for the first.

## A finding about Arc, not about this change

**`hooks/tracker-verify` and `templates/pr.md` disagree about the milestone on an issue PR.** The
hook reported PR #291 as having none; the template says a PR closing an issue takes none, because
the issue is the unit of work — which is [#204](https://github.com/Calyx-Engineering/arc/issues/204)'s
finding, shipped by PR [#257](https://github.com/Calyx-Engineering/arc/pull/257), itself milestone-less.
The template was followed and the milestone left unset. Merged arc-04 PRs are split roughly evenly
between the two, so the hook is reporting against a rule the repository changed under it.

No issue filed: which of the two is wrong is a decision, not a defect with an obvious fix, and
[#270](https://github.com/Calyx-Engineering/arc/issues/270) has just moved this class of record
into the dev-log rather than a `Spawned` row.
