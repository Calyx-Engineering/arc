# Issue #177 — delete the local command copies

**Issue:** [#177](https://github.com/Calyx-Engineering/arc/issues/177)  ·  **PR:** pending

## Problem

`.claude/commands/` held `arc-next.md` and `camp.md`, byte-identical to the shipping `commands/`. Arc is installed in this repository, so both trees loaded and `/arc-next` and `/camp` each resolved to two identical candidates. It is [#142](https://github.com/Calyx-Engineering/arc/issues/142)'s defect in the one directory #142's scope did not name.

`verify-skill-registry.sh` already saw the shadowing. It printed it as a `NOTE` and exited 0, so the gate had been green over the defect since #142.

## Decisions and trade-offs

| | |
|---|---|
| **The NOTE became a check** | A finding that cannot change the exit code is a finding nothing acts on. It now fails, with the same wording as the skills check beside it |
| **A repo-local command is still allowed** | The test is `commands/$c` existing, not `.claude/commands/$c` existing. `command-local-only` is the case that pins it |
| **Two copies that agree are not better than two that have drifted** | The check does not diff the files. Identical copies are the defect — selection sees two candidates either way |
| **`verify-handoff-checks.sh` kept its shadow probes** | Both loops already guarded with `[ -f ]`, so the deletion is invisible to them. They are now a guard against the copy returning, and the header says so instead of describing a file that is there |

## Writing the test first, again

`verify-skill-registry.sh` gained a `selftest`: each case builds a throwaway root and re-runs the file against it through `SKILLREG_ROOT`, so what is exercised is the gate's real exit code rather than a copy of its logic. Run before the fix, the three command cases were red and the two skill cases green — the harness proving itself on the half that already worked. A sixth case, `registry-row-present`, came out of the review below.

**Two findings came out of reviewing that selftest, and both were about a case passing for the wrong reason.**

- A fixture planting `skills/camp/SKILL.md` against an empty registry also tripped the *missing row* check, so `skill-shadow` exited 1 whether or not the shadowing check existed. Fixtures now write a registry row for every skill they plant.
- The exit-0 cases asserted a bare label, which greps identically against a `PASS` line and a `FAIL` line. Every case now asserts the prefix — four checks print into one stream and one exit code, so exit 1 alone does not say which of them fired.

**The `--` separator in `case_is` was decorative and is now checked.** It documented an invariant it did not hold: a call that omitted the empty second slot silently asserted `--` as its wanted text. Verified by mutation — removing a `--` from one call turns that case red and the suite exits 1.

## What is not covered

The two registry checks have no negative case. Neutering both so they can never fail leaves the selftest at 6/6. That is #142's gap rather than this one's — the harness to close it now exists, and it is filed as [#227](https://github.com/Calyx-Engineering/arc/issues/227).

Gates: 20, all clean — the registry selftest is the twentieth.
