# Reference — TimeScope

**Copied verbatim from `R:\vscode_customizations\timescope`, 2026-08-16.** These are
TimeScope's real working files, not Arc's. They are here as the **source material** for
extraction — five of Arc's mechanisms are ports of what is in this folder.

**Do not edit these to change Arc's behavior.** Edit Arc's own artifacts once they
exist; these stay as a fixed reference point. They also use TimeScope's own conventions,
which are not always ours.

| File | Ports to | Product-plan row |
|---|---|---|
| `agent-process-foundation.md` | Agent roster + dispatch tiers | 25 |
| | Briefs down / packets up | 26 |
| `agent-process.md` · `processes.md` | Kickoff + scope gate · worktree waves · human gate | 9, 27, 28 |
| `skill-delegate/` | The delegation skill itself | 25 |
| `hooks/block_source_edits.js` | Branch / worktree guard — **partial**; Arc needs three checks, this covers one | 10 |
| `hooks/dev_log_pr_link_gate.js` | Issue linking · K1 upkeep | 12, 17 |
| `hooks/f5_staging_gate.js` · `f5_receipt.js` | Human gate — F5 is TimeScope's; hardware's is a bench | 28 |
| `hooks/session_start_role_check.js` | Context ladder / handoff | 15 |
| `hooks/session_budget_nudge.js` | No Arc row yet — worth reading before designing the design-time evaluator | — |

**The hooks are the most valuable thing here.** They are working examples of the form
Arc has the least experience with, and `agent-process-foundation.md` was deliberately
written to be dropped into another repo.
