# Issue #353 — docs: handoff-archive and mode-guard get mechanism rows

> Dev-log, not a spec. Started at plan time, finalised as a retrospective at PR time.

**Issue:** [#353](https://github.com/Calyx-Engineering/arc/issues/353)  ·  **PR:** TBD

## Problem

`hooks/handoff-archive` and `hooks/mode-guard` name an issue in their headers — #152, #189/#201
— where `branch-guard` names m10. Neither had a row in the product definition's mechanism
table or an entry in its artifact table, so the definition did not say they exist.

## Decisions & trade-offs

- **New numbers, claimed from the shared cross-plugin registry**, not "highest in Arc's own
  table plus one" — `docs/suite-architecture/README.md`'s mechanism-numbering table said 48
  was next free. Claimed m48 (`hooks/handoff-archive`) and m49 (`hooks/mode-guard`), then
  updated the registry to `38–49 | Arc` / next free `50`, since the number space is shared
  with Lodestar and Bench.
- **Both filed under Workspace guard, not Knowledge.** m48 was drafted under Knowledge first
  (recovery, alongside `session-preservation`), but review pass 2 pointed out that piece's own
  *Prevents*/*Form*/*Fires* columns don't match what the hook does, while Workspace guard's do
  almost verbatim — "a revision nobody can reconstruct," "hooks, mechanical, no judgment," "on
  every tool call." Moved both the mechanism-table row and the artifact-table row before commit.
- **The spec describes the mechanism, not the artifact** — per CLAUDE.md's constraint. Each
  file states the friction that produced the hook, the design decisions, and the gaps the hook
  names in its own comments, rather than restating "this hook exists and does X."

## What review found before commit

Pass 2 read the new spec files adversarially against the actual hook source and found the
m49 spec materially incomplete: it described only the flat `git commit`/`git push`/`gh pr ...`
string match and omitted `hooks/mode-guard`'s wrapper-script gating entirely — the half that
reads a script's own `# mode-guard: writes-outward` declaration, splits a compound command into
segments, and resolves an invocation to a file — roughly 40% of the hook's body, added for
[#201](https://github.com/Calyx-Engineering/arc/issues/201) after `tools/new-direct-pr.sh`
bypassed the guard by never using a gated word directly. A reader of the spec alone would not
have known that subsystem existed.

Also found and fixed: a citation claiming `m40` §4 documents the `tools/arc-loop.sh` mode-write
exception, when that section names only a human saying so in chat — the hook's own comment
makes the same overclaim, but a fresh canonical spec should not repeat it. And m48's first
draft dropped two gaps the hook names in its own header (unpruned `.git/` markers; the
Windows backslash-unescape branch no fixture exercises) while otherwise being thorough about
this exact class of caveat.

## Verification

- `tests/verify-mechanisms.sh` — **PASS**, table and specs agree (Status word ↔ table glyph,
  every link resolves, m48/m49 each appear exactly once).
- Mechanism-table row count: 37, matching the "Thirty-seven mechanisms" line.
- `docs/suite-architecture/README.md`'s registry: `38–49 | Arc`, next free `50`.

## Spawned

Nothing filed. The wrapper-script gating's own named gaps (an undeclared outward-writing
script, `cd`-then-invoke, a path held in a variable) are pre-existing, documented in
`hooks/mode-guard` itself, and now also carried in m49's spec — not new findings from this
issue.
