# Issue #227 — test: the registry checks have no negative case in verify-skill-registry's selftest

> Dev-log, not a spec.

**Issue:** [#227](https://github.com/Calyx-Engineering/arc/issues/227)  ·  **PR:** [#331](https://github.com/Calyx-Engineering/arc/pull/331)

## Problem

`tests/verify-skill-registry.sh` has four checks. #177 gave the two shadowing checks fixture
cases in `selftest` — `skill-shadow`/`skill-clean`, `command-shadow`/`command-clean` — but the
two registry checks (every shipping skill has a row; every row carries a mechanism number) had
only a positive case, `registry-row-present`. Neutering either registry check so it could never
fail left the selftest green at 6/6.

## Intent and north star

| | |
|---|---|
| **What this issue is really for** | The selftest has to be able to catch a broken registry check, not just confirm a working one passes |
| **North star** | Each registry check, mutated so it can never fail, turns its own case red — and only its own |
| **What makes it durable** | The cases build their fixture by hand rather than through `case_is`'s auto-row convention, since that convention is what would otherwise mask the missing-row case |
| **Out of scope** | Nothing — #177 left exactly this gap and it is the whole issue |

## Decisions & trade-offs

| | |
|---|---|
| **A second builder, `case_row`, not a `case_is` variant** | `case_is`'s plant loop always writes a mechanism-numbered row for every `skills/*/SKILL.md` it plants — that's what isolates the shadowing checks it exists for. The two new cases need the opposite: no row, or a row missing `m##`. Bending `case_is` to support both would have made its own isolation harder to read |
| **Shared verification tail, `assert_case`** | First draft duplicated the 16-line run/assert-exit/assert-text block between `case_is` and `case_row`. Pass 2 flagged it as real duplication (not fixture-isolation, just plumbing), so it's now one function both builders call after building their own fixture |
| **Verified by neutering, not just by reading the code** | Forced `missing=""` and separately `nomech=""` right before each check's `if`, reran the selftest each time, confirmed exactly one new case went red each time and the other six stayed green, then reverted |

## Spawned

Nothing.

## Retrospective

Straightforward test-authoring issue: the checks were already correct, they just had no case
proving they could fail. `tests/verify-all.sh` (66 gates) stayed green throughout. Evidence for
the "done when" clause is in the two neutering runs above, not just static reading — the fixture
mismatch pass 2 flagged (a hand-typed registry path drifting from the case name) would have
surfaced as a wrong-branch failure rather than a silent pass, so the two cases discriminate
correctly.
