# Issue #177 — delete the local command copies

**Issue:** [#177](https://github.com/Calyx-Engineering/arc/issues/177)  ·  **PR:** [#228](https://github.com/Calyx-Engineering/arc/pull/228)

## Problem

`.claude/commands/` held `arc-next.md` and `camp.md`, byte-identical to the shipping `commands/`. Arc is installed in this repository, so both trees loaded and `/arc-next` and `/camp` each resolved to two identical candidates. It is [#142](https://github.com/Calyx-Engineering/arc/issues/142)'s defect in the one directory #142's scope did not name.

`verify-skill-registry.sh` already saw the shadowing. It printed a `NOTE` and exited 0, so the gate had been green over the defect since #142.

## Intent and north star

| | |
|---|---|
| **What this issue is really for** | Not the two files. The gate that watched them and could not fail |
| **North star** | A shadowing command cannot reach `main` green. The issue's own words: *exits 1 on a planted shadowing command, and 0 with none present* |
| **What makes it durable** | The check is a state to hold, not an event. A copy that comes back has to turn a gate red without anyone reading output |
| **Out of scope** | The registry checks beside it, and the `arc-run.md` that never had a copy |

Pass 2 changed nothing: the issue links only #142, whose dev-log already routed the commands here.

## Decisions & trade-offs

| | |
|---|---|
| **The NOTE became a check** | A finding that cannot change the exit code is one nothing acts on |
| **A repo-local command is still allowed** | The test is `commands/$c` existing, not `.claude/commands/$c` existing. `command-local-only` pins it |
| **The check does not diff the files** | Identical copies are the defect. Selection sees two candidates either way |
| **`verify-handoff-checks.sh` kept its shadow probes** | Both loops already guarded with `[ -f ]`. They are now a guard against the copy returning, and the header says so instead of describing a file that is there |
| **The glob stays flat** | `.claude/commands/*.md`, where the skills check walks `*/`. A namespaced copy would be invisible to it, and cannot shadow anything while `commands/` is flat |

## Rejected approaches

**Editing #208's dev-log, which asserts the copy is the one that fires here and records deleting it as rejected.** Both are now false of the tree. The record stands and carries a forward pointer instead — history says what was true when it was written.

## The selftest

Each case builds a throwaway root and re-runs the file against it through `SKILLREG_ROOT`, so what is exercised is the gate's real exit code rather than a copy of its logic. Written before the fix: three command cases red, two skill cases green.

Two of the six then passed for the wrong reason, and the fixtures now hold two invariants:

- **A fixture isolates one check.** Planting `skills/camp/SKILL.md` against an empty registry also tripped the *missing row* check, so `skill-shadow` exited 1 whether or not the shadowing check existed. Fixtures write a registry row for every skill they plant.
- **Every case asserts the `PASS`/`FAIL` prefix.** Four checks print into one stream and one exit code, so exit 1 alone does not say which of them fired.

The `--` separator in `case_is` documented an invariant it did not hold — a call omitting the empty second slot silently asserted `--` as its wanted text. Checked now, and the check verified by mutation.

## Spawned

- **Issues:** [#227](https://github.com/Calyx-Engineering/arc/issues/227) — the two registry checks have no negative case. Neutering both leaves the selftest at 6/6. #142's gap; the harness to close it now exists

## Retrospective

**A `NOTE` is a finding with no consumer.** This one named the exact defect, in the gate's own output, for as long as the defect existed. Nothing read it. The lesson is not about commands — it is that a verifier's non-blocking tier needs an owner, or it is decoration.

Gates: 20, all clean.
