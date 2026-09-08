# Issue #168 — the dev-log template calls itself a decision log

> Dev-log, not a spec. Started at plan time, finalised as a retrospective at PR time.
> Keep it short — capture the *why*, not a blow-by-blow. Skip any section that doesn't apply.

**Issue:** [#168](https://github.com/Calyx-Engineering/arc/issues/168)  ·  **PR:** [#236](https://github.com/Calyx-Engineering/arc/pull/236)

## Problem

`templates/dev-log.md` opened by calling itself a *decision log*. The file is `dev-log.md`, the
artifact is the dev-log in [m17](../product-architecture/mechanisms/m17-k1-upkeep.md) and
everywhere else, and the banner at line three is the first thing a cold session reads — so the
document disagreed with itself about its own name, at the one place the name is load-bearing.

## Intent and north star

| | |
|---|---|
| **What this issue is really for** | One name for one artifact, in the place a cold session reads it |
| **North star** | No live artifact calls the dev-log a decision log, and the grep that says so runs in `verify-all.sh` |
| **What makes it durable** | The stub generator, not the sweep. Every new dev-log is written by `tools/new-direct-pr.sh`, so the old name would have come back on the next direct PR |
| **Out of scope** | The archive, another system's vocabulary, and the plan entry that names the defect in order to describe it |

## Decisions & trade-offs

| | |
|---|---|
| **`Dev-log, not a spec`** | The contrast the sentence exists to draw is with a *spec*, and that half was never wrong. Only the self-name changes, so the three mechanism specs that quote the banner stay accurate quotes |
| **A gate, not just a sweep** | `tools/new-direct-pr.sh:100` writes the banner into every stub it opens. The issue did not name it; the grep did. A rename with a generator still emitting the old name is a rename that lasts until the next direct PR — which is why *Required*'s second box is the load-bearing one |
| **Case-insensitive** | "decision log" is as wrong as "Decision log". A check matching only the capitalised form would leave a rename half done and report clean |
| **Named exceptions, in the header, with reasons** | Not a variable holding a list. `verify-template-links.sh` set this precedent — "One named exception with a reason, never a list — a list is what made a new skill invisible to the parity check". They fall into two kinds: whole areas that are not this repository's live vocabulary, and documents whose subject *is* this rename |
| **This dev-log is one of the exceptions** | Found by review pass 4: the gate failed on the very file documenting the rename, which cannot describe the defect without naming it. Cases 8b and 8c cover it — and 8c pins that the exception is this one file, not `docs/dev-log/` |
| **The exception is the archive *directory*** | Anchored at `docs/product-architecture/archive/`, not at a filename. A suffix match on `HANDOFF.md` would have exempted the live handoff at the repository root, and case 9 is that case |

## Rejected approaches

| | |
|---|---|
| **Renaming the artifact to *decision record*** | It would collide with `ddr/`, and it is the file and the mechanism that would have to move, not the banner. The banner is the thing that is wrong |
| **Sweeping the dev-logs and leaving the generator** | Fastest, and it fails on the next direct PR. This is the whole reason the second `Required` box says *every place* |
| **Grepping in `verify-all.sh` itself** | The issue's words are "checked by grep in `tools/verify-all.sh`", and `run_gate` takes a command, so an inline grep would have been an unreadable one-liner with nowhere to put the three exceptions or their cases. A small verifier that `verify-all.sh` runs satisfies the same sentence and can be tested |

## Evidence

| | |
|---|---|
| `bash tools/verify-dev-log-name.sh selftest` | 11 passed, 0 failed |
| `bash tools/verify-dev-log-name.sh` | `PASS no artifact calls the dev-log a 'decision log'`, exit 0 |
| `bash tools/verify-all.sh` | 26 gates, all clean, exit 0 |
| **The Done-when, measured** | With the old banner restored in `templates/dev-log.md` alone: `26 gates, 1 failed — dev-log name`, exit **1**, naming `templates/dev-log.md:3`. Reverted after the measurement |

**Scale of the sweep:** 42 files — the template, m15, m16, m17, `tools/new-direct-pr.sh`, and 37
existing dev-logs. m17's copy was missed by the first pass because its quote wraps across a line
break, and was found by re-running the grep rather than by reading the diff.

## Spawned

- **Issues:** none filed.
