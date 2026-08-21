# Issue #45 — Announcing completed actions

> Decision log, not a spec. Started at plan time, finalised as a retrospective at PR time.

**Issue:** [#45](https://github.com/Calyx-Engineering/arc/issues/45)  ·  **PR:** [#54](https://github.com/Calyx-Engineering/arc/pull/54)

## Problem

Arc's artifacts operate without announcing themselves. The user cannot tell whether Arc
helped, was absent, or was wrong — and invisible tooling produces no improvement signal,
because a user only corrects machinery they knew was running.

## Decisions & trade-offs

| | |
|---|---|
| **A standalone reference, not a section inside a skill** | `docs/product-architecture/camp-reports.md`. The templates, seven artifacts and `verify-hook.sh` all point at it. Putting the format inside `skills/camp` would make Camp the authority on a convention that applies to hooks, which Camp neither owns nor reads |
| **Three fields — `camp-reports`, `checks`, `skips`** | `checks` alone cannot express a conditional check, and a conditional check that silently does not run is the exact ambiguity the report exists to remove |
| **YAML frontmatter in skills, a comment block in hooks** | Hooks are bash. A comment block directly under the description is greppable with `grep -q '^# camp-reports:'`, which is all the detection needs |
| **Check names taken from what each artifact actually does** | `tracker-verify`'s five names were read out of its `add` calls; `branch-guard`'s two out of its deny branches. A plausible-looking list would have made the declaration decorative |
| **`skips` entries carry the condition, not just the name** | *"`arc-prefix` (base is not an arc branch)"*. A skipped check with no reason is indistinguishable from a broken one |
| **The gate reports, never denies** | A missing declaration makes an artifact invisible, not wrong. Blocking would make the convention a cost paid at the moment someone is trying to fix something else |

## `verify-hook.sh` was proposed before it was edited

CLAUDE.md excludes `tools/verify-hook.sh` from autonomous edits, alongside `settings.json`, the
hook template and any `SessionStart` hook. The change was written up first —
[`proposed-verify-hook-declaration-check.md`](../arc-work/proposed-verify-hook-declaration-check.md),
naming the block, its placement and the three cases — and applied on approval.

**The check reports and never fails.** It sits outside the `PASSED`/`FAILED` tally and the exit
code, because a missing declaration makes a hook invisible rather than wrong. All three cases
were run; the note appears only on the undeclared hook, and `exit=0` is unchanged.

## A YAML bug in #40, found here

Camp's `description` from [#40](https://github.com/Calyx-Engineering/arc/issues/40) contained an
unquoted colon — *"…from the conversation: where the arc stands…"* — which makes the frontmatter
fail to parse. Every other skill parsed; only Camp's did not.

Rewritten to use an em-dash. **All nine skills now parse**, checked with `yaml.safe_load` across
both `skills/` and `.claude/skills/`.

This is the first defect this arc's own work has caught in this arc's own work, and it was found
by adding a field that forced the frontmatter to be parsed rather than read.

## The artifact count was already wrong

The product definition said *"Twenty-four artifacts"* against a table holding thirty. The
sentence had not been updated as rows were added — including `.claude/arc/log.md` from
[#37](https://github.com/Calyx-Engineering/arc/issues/37) two issues ago. Now thirty-one rows and
a sentence that says thirty-one.

## Rejected approaches

| Rejected | Why |
|---|---|
| A fourth verbosity level for per-artifact suppression | m43 §7.1 — that is an agreement clause, not an extension of the level scheme |
| Camp narrating each artifact's completion | m43 §3.5 — the artifact speaks in Camp's voice; Camp narrating would make it the second narrator the voice section exists to prevent |
| Deriving `checks` from reading each artifact's code at report time | Fragile, and it defeats the point — a declaration is a promise the artifact can be held to, not a description of its current implementation |
| Failing `verify-hook.sh` on a missing declaration | The issue is explicit: reports, never denies |

## Retrofitted

| Artifact | Declares |
|---|---|
| `hooks/branch-guard` | `edit-denied` · 2 checks · 2 skips (both unbuilt follow-ups) |
| `hooks/tracker-verify` | 3 events · 5 checks · 3 skips |
| `skills/issue-write` | 4 events · 6 checks · 2 skips |
| `skills/record-route` | 3 events · 4 checks · 1 skip |
| `skills/handoff` | 2 events · 4 checks · 1 skip |
| `skills/engineering-report` | 2 events · 3 checks · 1 skip |
| `skills/work-watch` | 3 events · 3 checks · no skips |
| `skills/camp` | 2 events · 3 checks |

`chat-response` and `spec-interview` declare nothing — neither acts, so neither has anything to
report. That is the correct outcome, not an omission.

## Retrospective

Three new files — the format reference, `templates/SKILL.md`, and the `verify-hook.sh`
proposal — plus the stub in `hooks/TEMPLATE` and eight retrofits.

**What was verified:** all nine skills' frontmatter parses as YAML, in both trees. Both hooks
and the template carry a greppable declaration, and a file without one is correctly detected.
`--check` passes.

**What could not be verified:** that any artifact actually reports. Nothing here executes, so
whether a hook emits the skipped line, whether verbosity is honoured, and whether the report
reaches the event log are all unknown. The issue's acceptance criteria are written as runtime
behaviour and none of them can be run in this repository.

## A closing keyword in a heading binds

The first draft of this PR opened with `## ⚠️ This does not close #45`. GitHub bound it — the
parser matches the keyword and the number and ignores the word *not*, which is the trap
`skills/issue-write` names explicitly with that exact string as its worked example.

The skill was loaded and the rule was broken anyway. **The lesson is placement, not wording:**
a keyword-plus-number belongs only in the final bare line. Prose that needs to discuss closure
avoids the keyword entirely — *"this does not complete the capability"*.

The binding was initially misattributed to the branch name's `issue-NN` segment. That remains
untested: every PR in this arc carried a body keyword as well, so the two are confounded.

**The criterion to check first on real use:** *"a hook written from `hooks/TEMPLATE` reports
without its author knowing the convention existed."* That is the one that proves the convention
propagates rather than decays, and it is the reason the stub sits beside the kill switch rather
than in documentation.
