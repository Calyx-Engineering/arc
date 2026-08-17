# Handoff — plugin architecture retrospective

**Written 2026-08-16, end of a long session.** Read this, then
[product-plan.md](product-plan.md).

**3,760 lines are on disk.** Every conclusion, mechanism spec, and piece of evidence was
written down as it was decided. This file covers what the documents do not: where the
review stopped, how to work with David, and the reasoning that never made it into a
document.

---

## 1. What happened

A retrospective mined 28 Claude Code transcripts from four weeks of ROADZ hardware work
(~91 MB → 474 David messages → 75 corrections) and turned them into a plugin
architecture. TimeScope's repo (`R:\vscode_customizations\timescope`) was read directly
for comparison.

| File | What it is | Reviewed? |
|---|---|---|
| [product-plan.md](product-plan.md) | **The conclusion.** Four plugins, 37 mechanisms, build order | §1–5 yes · §6–7 **no** |
| [friction-log.md](../retrospectives/2026-08-plugin-line/friction-log.md) | The evidence. Eight frictions with quotes | Yes, fully |
| [mechanisms/](mechanisms/) | Eleven specs | Written, not line-reviewed |
| [what-the-tools-do.md](what-the-tools-do.md) | Earlier framing — jobs the tools perform | Superseded, still useful |
| [archive/](archive/) | Superseded framings, kept for reference | Not current — do not cite |

Two skills written, both Arc mechanisms (rows 32, 33). They live in **lodestar's**
`.claude/skills/` and stay there until Arc's plugin is stable enough to install — dual-homed
on purpose, per David.

**Committed 2026-08-16.** Written in the lodestar repo, moved here the same day when the
plugin line split into three repos — Arc owns the cross-plugin architecture because the
Self-improve mechanisms that regenerate it are Arc's.

---

## 2. Where to pick up

**§1–§5 of product-plan.md are fully reviewed**, row by row, as of 2026-08-16. §6–§7 are
not.

The §4.1 pending-changes table has been removed — it existed to keep the table stable
while it was being read, and the review is done. Changes now go in directly.

**How David wants changes handled:** apply wording fixes inline immediately so he sees
them in the diff. Discuss structural changes — new rows, renumbering, anything that moves
counts — to a conclusion first, then apply. Do not stop to ask about word choice; pick
the option consistent with the surrounding documents and say what was picked.

---

## 3. How to work with David

Learned the hard way this session. **These matter more than any finding below.**

| | |
|---|---|
| **Short chat responses** | He reads slowly and deliberately. Lead with the answer; he pulls for detail. See `.claude/skills/chat-response/` |
| **Never commit unasked** | He reviews by diff in VS Code's source-control graph. An unrequested commit destroys that surface |
| **No development narrative** | Never "an earlier draft said…" or "you corrected me…". State the current conclusion. Applies to documents *and* chat. He confirmed this is worthless to both of us |
| **Wording fixes go in immediately** | He reviews in the diff. Discuss structural changes first, then apply; never stop to ask about word choice |
| **Verify before asserting** | Several documented beliefs were disproved by direct test this session |
| **Cite TimeScope by mechanism, never by name** | He does not remember its details. Say what it is and how it works in the same breath |
| **He is right about his own domain** | On EE substance, when he says an analysis is wrong, it is wrong. Do not re-litigate — ask what was missed |
| **Watch for saturation** | He will say when a context is degrading. He is a reliable judge of it; hand off rather than push through |

### Things he rejected, so they are not re-proposed

| Rejected | Why |
|---|---|
| Emoji for t-shirt sizes | No equivalent exists. Use the SVGs in `assets/`; canonical copies in `~/.claude/assets/tshirt/` |
| Five-level priority scale | Three only — high, medium, low |
| Red as an effort colour | Reserved; orange/amber/blue instead |
| `concerns/` as a folder name | Reads wrong to a human, and it is agent-facing |
| Concern-first folder structure | Subject is the folder, concern is a facet |
| A single deep-context document | Saturates a session by itself — hence the K1–K4 ladder |

---

## 4. The findings that matter

| # | Finding | Where |
|---|---|---|
| 1 | **The switch is autonomy, not hardware/software.** Only one of eight frictions was hardware-specific. What differs is whether work runs unattended between checkpoints | friction-log §3.2b |
| 2 | **Silent success is the recurring failure mode.** Five of eight frictions reported success and did the wrong thing. Design rule: assert, then verify | friction-log §3.7 |
| 3 | **Trigger + template + enforcement.** Everything that works has all three; everything that failed has at most one | friction-log §3.7 |
| 4 | **Four jobs have no natural moment** to bind enforcement to — requirements capture, hardware verification, the hardware DDR, hardware's second gate. Solve it once, it pays four times | friction-log §3.7 |
| 5 | **Lodestar is invention; everything else is extraction.** Zero working mechanisms; the other two mostly port what already runs | product-plan §5 |
| 6 | **Star is queried during analysis**, not read as files. That makes Lodestar an active participant in delivery | friction-log §3.4 |

---

## 5. Reasoning that is only in the transcript

Everything above is documented. These are judgement calls that shaped the work but were
never written into a document.

**Why the friction log and product plan are separate files.** The friction log is
*evidence* and freezes when the retrospective ends. The plan is *the plan* and changes
every time a mechanism ships. Merging them would make it unclear which parts are still
true.

**Why mechanism specs are one-per-file rather than sections.** They are consumed
individually when building. A single document forces reading everything to find one
thing.

**Why the review is row-by-row.** David asked for it explicitly after re-reading the same
material several times. It works: §1–§5 found four rows whose stated provenance was wrong
and produced three new mechanism specs.

**What the transcript scan cannot see.** Mechanisms that already work leave no trace,
because working things produce no corrections. Roughly a third of the plan came from
reading TimeScope and the Lodestar design docs, not from friction.

**Why the build order is uncomfortable.** Evidence says build Arc's Agents group first and Lodestar
third, but Lodestar is the thing David wants most and the repo this lives in. The
counter-argument — momentum is a real asset — is genuine and unresolved.

---

## 6. Not done

- product-plan §6–§7 unreviewed (build order, open questions)
- Nothing committed
- **No issues filed anywhere** — deliberate, per the original constraint
- **Hardware configuration management is deferred, deliberately.** Row 22 stays in Arc.
  The software half is solved (branches, PRs, releases); the hardware half — component
  versions, BOM state — has no design and no evidence behind it. **File it as an issue in
  the Arc plugin repo once that repo exists.** Not Bench: that is domain analysis, not
  revision bookkeeping
- Execution-phase hardware work unobserved; all evidence is discovery-phase
- ROADZ issue #1's worktree transcript is **not yet distilled** — David planned to delete
  that worktree, and it holds the richest discovery-phase reasoning in the repo. The
  knowledge-mining backstop applies

---

## 7. Open questions

| Question | Where |
|---|---|

| Does `Bench` stay right if the domain-persona pattern generalises beyond EE? | product-plan §7 |
| Does report style transfer between hardware and software? | friction-log §6.1 |
| Same issue format at different granularity, or different formats? | friction-log §6.2 |
| Where do requirements actually live today? | friction-log §5 |
| Does hardware's gate latency break the human-gate model? | product-plan §7 |

---

## 8. Context David may need re-supplied

He has largely forgotten TimeScope's mechanisms. If a fresh session cites one, state what
it is:

| Mechanism | What it actually is |
|---|---|
| **Spine** | A chat window on the integration branch, coordination only, never edits source. Its durable state is the arc-log |
| **Arc-log** | A committed file: north-star architecture, wave-by-wave build order, live status table (issue → dev-log → PR) |
| **Dev-log** | Per-issue decision log — Problem · Decisions & trade-offs · Rejected approaches · Retrospective. Deliberately short |
| **Delegation tiers** | **T0-Inline** · **T1-Squad** (scout/planner/builder/reviewer) · **T2-Wave** (parallel worktrees on disjoint files). Distinct from the K1–K4 knowledge tiers — see [knowledge-tiers](mechanisms/knowledge-tiers.md) |
| **Human gate** | One verification step only the human can run — F5 in TimeScope, a bench in hardware |
| **`agent-process-foundation.md`** | TimeScope's portable orchestration model, already written to be dropped into other repos. The largest thing Arc's Agents group ships |
