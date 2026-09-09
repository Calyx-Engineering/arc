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

`tests/verify-autonomy.sh` enforces the duplication: it fails an artifact that omits the override. It has to fail one that states the prohibition at all.

### Two of five artifacts ship

`docs/` is not part of the plugin. A consumer repo receives the prohibition from `skills/work-watch` and `templates/handoff.md`, and collides with whatever its own `CLAUDE.md` already says. Arc's own repository is the worst case at five, and it is the only repository with denials.

## Decisions and trade-offs

| | |
|---|---|
| **The transcript-copy denials are not evidence here** | Same error string, different gate. Folding them in was a conflation, corrected |
| **Scope is the local half only** | Fix the overlaps here, verify what ships does not reintroduce them. Detecting the collision at install is [#173](https://github.com/Calyx-Engineering/arc/issues/173), filed to *Onboarding — m47*, out of this milestone |
| **`--delete-branch` was a wrong diagnosis, twice recorded** | Blamed in 2026-08, disproved, and this arc's merge of PR #133 used the flag and passed |

## What changed

| File | |
|---|---|
| `CLAUDE.md` | 231 → 148 lines. Mode stated once in ROADZ's shape; five preference rows, the branch mechanics, the gap-routing steps and the local-copies rationale removed as things the plugin or the product definition owns |
| `skills/work-watch` | The `Never commit unasked` row deleted. A pointer under the mechanical-rules table says whether you commit is the mode's call |
| `skills/autonomy-set` | *The rule appears beside every prohibition* replaced by *This skill is the only place the rule is stated*. New: on a denial, name which of the three gates stopped it |
| `docs/…/m40-autonomy-switch.md` | §9 reversed, original reasoning kept in full. §10's "nothing runs a skill" corrected — Arc is installed here |
| `tests/verify-autonomy.sh` | Six per-row checks replaced by a census. Both failure modes tested |

`templates/handoff.md` was left alone — it defines what *suspended* means, which is the state's semantics rather than a standing prohibition.

**Out of scope, deliberately:** `m14` §3 and `close-sequence.md` steps 8–9 keep the old shape. They are in `docs/`, opened deliberately rather than loaded every turn, and the verifier's header says so.

## Retrospective

**Five of six requirements landed as text changes. The sixth is a behavioural test that cannot be run by asking for it** — a merge has to be attempted without the user requesting that merge, which means the test runs exactly once per session and the user has to not participate.

**Two conflations were caught during the work.** Transcript-copy denials were folded into the evidence and pulled back out — same error string, different gate. And the ROADZ regression claim was withdrawn: ROADZ never had a merge problem, because it was fixed there on install day.

**The user was right and the first search was wrong.** Three widening passes were needed — literal `gh pr merge`, then every denial on the machine, then the user's actual instruction, which was to search for *my* mentions of `CLAUDE.md` and read the surrounding discussion. The third pass found it in one query.

**The largest contributor may still be unaddressed.** Arc is installed in this repository and `.claude/skills/` still holds 13 copies, so every skill is in context twice. [#142](https://github.com/Calyx-Engineering/arc/issues/142) was Upkeep housekeeping; it is now second in Loop behind this issue.

