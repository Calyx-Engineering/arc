# Issue #349 — feat: handoff-write and handoff-resume replace arc-next

> Dev-log, not a spec. Started at plan time, finalised as a retrospective at PR time.

**Issue:** [#349](https://github.com/Calyx-Engineering/arc/issues/349)  ·  **PR:** TBD

## Problem

`/arc-next` predates the handoff — a manual command for jumping the main chat between
windows before arcs, orchestrators and runs existed. The handoff skill later took it as its
reading path, but the name never changed. A user who types `/hand` to find the handoff sees
nothing, and the command that resumes a handoff shares no word with the skill or with the
wording that fires it.

## Intent and north star

| | |
|---|---|
| **What this issue is really for** | Give the handoff mechanism (m15) two typed openings that share its own name — one per direction — so `/hand` finds both |
| **North star** | `/handoff-resume` and `/handoff-write` exist, hold no rule of their own, and `/arc-next` is gone everywhere it shipped |
| **What makes it durable** | Both commands stay thin wrappers — `skills/handoff` still carries every rule, so a future change to the read or write path needs one edit, not two |
| **Out of scope** | Rewriting `docs/arc-log`, `docs/dev-log`, `docs/arc-work` or `docs/retrospectives` — those are historical record and the issue says they stay as written |

## Decisions & trade-offs

- **`resume`, not `read`.** Picking up a handoff runs the staleness checks and executes the
  ordered actions — it is not a passive read. The overlap with Claude Code's own `--resume`
  is wanted, not a collision to avoid.
- **Both commands share the skill's stem** (`handoff-*`) so typing `/hand` surfaces both,
  decided 2026-09-13 over `/pickup`, `/handoff-read` and `/handoff-go`.
- **The next-chat prompt collapses to `/handoff-resume` alone.** The three-line prompt
  (`Read HANDOFF.md first...`, branch, next step) restated state the command now reads for
  itself out of `HANDOFF.md` — restating it created a second copy that could drift from the
  file. Updated in `skills/handoff/SKILL.md` and `templates/handoff.md`.

## Spawned

Nothing filed. `docs/arc-log`, `docs/dev-log`, `docs/arc-work` and `docs/retrospectives`
were left untouched per the issue's own note that historical records stay as written, even
though several still say `/arc-next` — that is why they read stale below and not a miss.

## Retrospective

`commands/handoff-resume.md` and `commands/handoff-write.md` replace `commands/arc-next.md`,
each invoking `skills/handoff` and holding no rule of its own — same shape the old command
had. Every shipped reference moved: `README.md`'s command table, `docs/product-architecture/README.md`'s
artifact registry, m15, m40, `skills/autonomy-set`, `tests/verify-handoff-checks.sh`,
`tests/verify-skill-registry.sh`, `tools/handoff-openings.py`, `tools/probe-handoff-checks.sh`,
and the `evals/skill-firing/wrapped/` case (renamed `autonomous-mode-handoff-resume-later`).
`tests/verify-handoff-checks.sh` now walks both command files (and their `.claude/commands/`
shadows) instead of one; `tests/verify-skill-registry.sh`'s shadow-detection selftest fixtures
were renamed off `arc-next.md` to keep the test's own text honest. Both scripts' selftests and
live runs pass. `docs/arc-log`, `docs/dev-log`, `docs/arc-work` and `docs/retrospectives` were
left untouched, as instructed.

**`tests/verify-all.sh` exit code:** 1 of 73 gates fails — `skill method`, on
`docs/arc-log/arc-04-dogfood.md:698` still citing a retired 180-line figure. Confirmed
pre-existing and unrelated to this issue: `git diff` shows this branch never touches that
file, and the failure is about a body-length limit, not `/arc-next`. Not fixed here —
`docs/arc-log` is named in the issue as staying as written, and fixing it would be a second
unit of work this issue was not given. Every other gate, including `verify-skill-registry.sh`
(the one named in Required), passes clean.
