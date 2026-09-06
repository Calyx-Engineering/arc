# Issue #138 — duplicated mode rules defeat Arc's own merge permission

**Issue:** [#138](https://github.com/Calyx-Engineering/arc/issues/138)  ·  **PR:** [#172](https://github.com/Calyx-Engineering/arc/pull/172)

## Problem

`gh pr merge` has been denied four times in this repository — #95, #97, #114, #137 — by the Claude Code auto mode classifier. The permission allowlist already grants it. In the same sessions `gh pr create`, `gh issue edit` and `git push` all passed.

## What the evidence says

**The corpus is every transcript on the machine — 8 project directories, 25 classifier denials in total.**

| Where | Denials | What |
|---|---|---|
| arc | 22 | Four `gh pr merge`, plus branch deletes, a branch rename, `.claude/settings.json` writes, transcript copies, several plain file reads |
| ROADZ | 3 | All three are copying a `.jsonl` transcript. **Zero merges** |

ROADZ ran 12 merges and none was denied. Transcript-copy denial is a different gate — a data-egress shape, not an authorization one — and it was wrongly folded into this issue before being dropped.

### The variable is how many times the prohibition is stated

ROADZ was fixed on install day, [`44dbb06`](https://github.com/Lantern-Systems/roadz-sound-system/commit/44dbb06): *"Two copies of the same rule drift, and the copy an agent reads first wins."* It deleted two repo-local skills duplicating Arc's, and reduced `CLAUDE.md` to pointers plus one sentence with the override inside it.

| | arc | ROADZ |
|---|---|---|
| Mode rule stated in | 5 artifacts | 1 |
| `CLAUDE.md` | Restates rules the skills own | *"Invoke them rather than reproducing their rules here"* |
| Merge denials | 4 | 0 |

**This reverses [m40](../product-architecture/mechanisms/m40-autonomy-switch.md)'s central decision.** m40 chose to duplicate deliberately — *"the rule appears beside every prohibition it overrides"* — on the reasoning that a cross-reference is read once and an adjacent clause every time. Sound in isolation. But five prohibitions each carrying an override is still five prohibitions, and the base instruction permits an outward-facing action only when it is *durably authorized*.

`tools/verify-autonomy.sh` enforces the duplication: it fails an artifact that omits the override. It has to fail one that states the prohibition at all.

### Two of five artifacts ship

`docs/` is not part of the plugin. A consumer repo receives the prohibition from `skills/work-watch` and `templates/handoff.md`, and collides with whatever its own `CLAUDE.md` already says. Arc's own repository is the worst case at five, and it is the only repository with denials.

## Decisions and trade-offs

| | |
|---|---|
| **The transcript-copy denials are not evidence here** | Same error string, different gate. Folding them in was a conflation, corrected |
| **Scope is the local half only** | Fix the overlaps here, verify what ships does not reintroduce them. Detecting the collision at install is [#173](https://github.com/Calyx-Engineering/arc/issues/173), filed to *Onboarding — m47*, out of this milestone |
| **`--delete-branch` was a wrong diagnosis, twice recorded** | Blamed in 2026-08, disproved, and this arc's merge of PR #133 used the flag and passed |

## Retrospective

