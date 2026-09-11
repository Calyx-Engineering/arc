# Issue #287 — a closing keyword on a base that was never the default

> Dev-log, not a spec.

**Issue:** [#287](https://github.com/Calyx-Engineering/arc/issues/287)  ·  **PR:** [#324](https://github.com/Calyx-Engineering/arc/pull/324)  ·  **Spawned by:** [#136](https://github.com/Calyx-Engineering/arc/issues/136)

## Problem

m12 and m42 stated opposite rules for the same 2026-08-16 data and neither cited the other. m12
read ROADZ PR #55 as proof that a keyword binds on a non-default base; m42 quotes GitHub's
documentation saying it does not. PR #55 was opened after its base became the default, so it
could not tell the two apart. `skills/issue-write` already stated m42's rule, but without a
measurement that isolated the base.

## The live test

| | |
|---|---|
| **Probe issue** | [#322](https://github.com/Calyx-Engineering/arc/issues/322), open for the run |
| **Base** | `probe/287-base`, pushed from the `arc/04-dogfood` tip for this run. Never the default — `defaultBranchRef` read `arc/04-dogfood` at PR open and after the merge |
| **Head** | `probe/287-head`, one empty commit ahead via `git commit-tree`, so no checkout moved |
| **PR** | [#323](https://github.com/Calyx-Engineering/arc/pull/323), body ending `Closes #322` on its own last line |

| Read | `closingIssuesReferences` |
|---|---|
| Before the merge, five polls over 15 s | `[]` |
| After `gh pr merge --merge`, six polls over 24 s | `[]` |
| After an unchanged `gh pr edit --body-file`, six polls over 24 s | `[]` |
| `userLinkedOnly:true` | `[]` |
| #322 after the merge | `OPEN` — closed by hand |

**m42's rule holds. m12's parse-time reading is struck.** The keyword form is the one this
repository's checker accepts, and the same form on a default base binds and closes at the merge
(m42, 2026-08-17) and binds after it (`live-bind`, 2026-09-07). The base is the only variable.

## What changed

| | |
|---|---|
| **m12 *The test that changes the design*** | Rewritten in place. The ROADZ table stays; the section now says what it was read as proving, why that reading was wrong, cites #323, and states m42's rule with the timing half the ROADZ data adds. The bolded consequence — *the default-branch switch is not required* — replaced. Status line updated |
| **m42 opening** | One sentence citing the isolation and m12's struck reading, so the two specs cite each other |
| **`skills/issue-write`** | *The base branch decides whether the link binds* cites #323 and the case; *What is still not recoverable* says the re-save result is measured |
| **`tests/tracker-cases/binding/never-default-base-keyword.md`** | The case: both claims with their predictions, the eight-step procedure, the run, and what it does not measure |

## Decisions

| | |
|---|---|
| **A fresh base, not an existing PR** | `arc/04-dogfood` is the default today. Whether it was at any given PR's parse time is history, not a measurement, so no existing PR isolates the base |
| **Merged into the probe base, not the arc branch** | Nothing lands in `arc/04-dogfood`; the probe base was deleted after the read. The head was deleted by the merge |
| **No runner** | The issue asks for the case. A runner would create an issue, two branches and a PR on every run; the procedure is eight commands and is recorded in the case |
| **The retrospective is untouched** | `docs/retrospectives/2026-08-plugin-line/friction-transcript-log.md` §2.8 still carries the parse-time reading. It is a record of what was believed on 2026-08-16, not a spec |
| **The case lives in `tests/`** | The issue names `tools/tracker-cases/binding/`; #190 moved the directory after the issue was written. Ticked with the actual path |

## Seen, not touched

| | |
|---|---|
| `skills/issue-write` | Two later sentences still say *"closure defers to the arc PR"* in the wording the section itself calls corrected. Pre-existing, outside the section the issue names |
| m13's evaluation set | `skills/issue-write` calls the base-branch case the eighth entry; m42 calls it the seventh. Pre-existing |
| `docs/arc-work/04-dogfood/public-audit.md` | Its R17 row points at m12 line 80 for the struck sentence, which moved. An audit table, not a spec |

## What the hooks said

`tracker-verify` reported #322 with no spawn edge at creation; a `Spawned by #287` line was
added and read back. Its `close-link` check ran on `gh issue close 322` — the probe issue was
never linked, which is the finding the run exists to produce.
