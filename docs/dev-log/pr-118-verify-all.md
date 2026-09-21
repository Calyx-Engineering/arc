# PR #118 — one command runs every gate

> Dev-log, not a spec. No issue behind it — the runner is a prerequisite for
> [#117](https://github.com/Calyx-Engineering/arc/issues/117) and smaller than an issue.

**Issue:** none  ·  **PR:** [#118](https://github.com/Calyx-Engineering/arc/pull/118)

## Problem

The repo had **four verifiers and nothing that ran them.** No CI, no task runner, no aggregate
script — each invoked by hand, each mentioned only in prose.

`close-sequence.md` and `CLAUDE.md` both ask for gates to be clean before a PR. Neither gives
anyone a command, so *"the gates are clean"* in a PR body was a claim a reviewer took on trust.

## Intent and north star

> **The order slipped, and saying so is cheaper than pretending it did not.** §6.1.1 puts the
> intent passes and the plan before the implementation. The instruction to execute arrived
> mid-turn with the script already drafted, so the passes below were written against a diff
> that existed. **Pass 2 still changed the design** — the disk check and the uncased-hook
> failure are both its output — but the guard §6.1.2 provides was weaker here than it should
> have been.

### Pass 1 — from the request alone

| | |
|---|---|
| **What this is for** | A command that runs the four verifiers, so the close sequence's *"gates clean"* stops being a claim |
| **North star (pass 1)** | One command, one exit code, and the failing gate named |

### Pass 2 — after reading `close-sequence`, `CLAUDE.md`'s hook rules, and all four verifiers

**Three things changed.**

| | |
|---|---|
| **A runner is a coverage claim, and coverage claims are what keep failing here** | `--check` exited 0 with no copy on disk ([#68](https://github.com/Calyx-Engineering/arc/issues/68)); a spec declared a mode nothing read ([#73](https://github.com/Calyx-Engineering/arc/issues/73)). A green run that silently skips a verifier is the same shape, one level up |
| **`CLAUDE.md` requires cases before a hook is registered** | So a hook with no case directory must **fail**, not be skipped. Skipping would report coverage for precisely the hook that has none |
| **What it cannot run has to be printed on success** | Nothing here fires a hook in a live session or invokes a skill. A runner that lists only what it did reads as a complete picture, and this one is emphatically not |

**North star.** One command answers *are the gates clean*, names which one is not, and states
plainly what it does **not** cover — so nobody reads a green run as proof of something it never
touched. **A verifier added tomorrow cannot be silently skipped.**

| | |
|---|---|
| **What makes it durable** | The invocation table is checked against the verifiers on disk — `tools/verify-*.sh` when this shipped, both that and `tests/verify-*.sh` since [#190](https://github.com/Calyx-Engineering/arc/issues/190) — so it fails on a verifier it does not know rather than quietly running the rest |
| **Out of scope** | CI. That is [#117](https://github.com/Calyx-Engineering/arc/issues/117), filed into *Self-improvement*, and blocked until the plugin is released — `hooks/hooks.json` resolves `${CLAUDE_PLUGIN_ROOT}` |

### Intent check

**Derived.** No issue, and the arc is scoped to Camp and the tracker fixes. It follows directly
from [#117](https://github.com/Calyx-Engineering/arc/issues/117) naming it as a prerequisite,
and from this arc having added two of the four verifiers it runs. Admitting it changes nothing
in *Why this arc exists*.

## Plan

| | |
|---|---|
| 1 | `tests/verify-all.sh` — every gate, one exit code, the failing one named |
| 2 | The invocation table checked against disk, so an unknown verifier fails |
| 3 | A hook with no case directory fails rather than being skipped |
| 4 | `--list` prints the plan and the two un-covered classes |
| 5 | Provoke all four failure paths rather than asserting them |
| 6 | `CLAUDE.md` and `close-sequence` point at it, and the arc-log records it |

## Decisions & trade-offs

| | |
|---|---|
| **A table of invocations, checked against disk** | The scripts take different arguments, so a pure glob cannot call them. But a bare table is [#68](https://github.com/Calyx-Engineering/arc/issues/68) again — so the verifiers on disk are enumerated — `tools/verify-*.sh` when this shipped, both directories since [#190](https://github.com/Calyx-Engineering/arc/issues/190) — and **an unknown one fails the run.** The list cannot rot without saying so |
| **A hook with no case directory fails, rather than being skipped** | `CLAUDE.md` requires pass, deny and malformed cases before a hook is registered. Skipping an uncased hook would report coverage for the one hook that has none |
| **The un-covered half is printed on success** | A green run ends with *"Not covered: hooks in a live session, and every skill."* A runner that only lists what it did is read as a complete picture, and here it is emphatically not one |
| **Reports, never blocks** | Every verifier it calls does. Exit 1 is a finding, and the runner does not gate a merge on its own |
| **Each gate's own summary line is echoed, not its full output** | 99 individual cases across 8 gates. Printing all of them buries the one that failed, and the failing gate's output is printed in full |

## Rejected approaches

| | |
|---|---|
| **A pure `for f in tools/verify-*.sh` loop** | `verify-hook.sh` needs a hook path and `verify-tracker-body.sh` needs `selftest`. A loop calling them bare would report usage errors as failures |
| **A `Makefile` or task runner** | A second toolchain for four bash scripts. `CLAUDE.md`'s hook rules already assume bash and `gh` and nothing else |
| **Doing CI in the same change** | It is blocked on the release, and CI covering the `tools/` gates while the hook-carried checks cannot run invites trusting it for both. Filed as [#117](https://github.com/Calyx-Engineering/arc/issues/117) with that constraint written into the body |

## Retrospective

**Running it found nothing wrong, which is the useful result.** 8 gates, 99 cases, all clean —
the first time anyone could say that from one command rather than by adding up four PR bodies.

The four failure paths were each provoked deliberately, because a runner that has never failed
is indistinguishable from one that cannot:

| Provoked | Result |
|---|---|
| A `tools/verify-ghost.sh` the table does not know | `FAIL — a verifier exists that this runner does not know` |
| A `hooks/ghost-hook` with no case directory | `FAIL — no case directory` |
| `CLAUDE.md`'s auto arm stripped | `FAIL — autonomy switch`, named in the summary line |
| `--list` | Prints the plan and the two un-covered classes, exit 0 |

**It is slow** — roughly ninety seconds, because each hook verifier builds throwaway git repos
per case. That is the cost of the hooks being tested against real `git rev-parse` rather than a
mock, and it is the right trade. It matters for [#117](https://github.com/Calyx-Engineering/arc/issues/117)
only as a CI runtime, not here.
