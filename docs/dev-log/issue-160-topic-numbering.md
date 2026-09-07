# Issue #160 — numbered topics are dropped mid-reply

**Issue:** [#160](https://github.com/Calyx-Engineering/arc/issues/160)  ·  **Parent:** [#145](https://github.com/Calyx-Engineering/arc/issues/145) — Fire

## Problem

A reply raises several topics, labels the first few, and stops. The user cannot answer by
number, so they restate the question — which is the work the label exists to remove.

The corpus holds the cost and the benefit in one conversation. Session `0c28d2ed`, turn 127,
was answered with two numbered topics; turn 128 is the user's entire reply:

```text
D1 - new
D2 - off
```

Four words for two decisions. Three turns later the same conversation answered on six
subjects, then seven, then three — **sixteen topics, not one of them labelled.**

## There was no instrument, so the first half of the work was building one

`tools/response-length.sh` counts words and `tools/skill-cases.sh` counts activations.
Neither can see whether the sections of a reply carry labels. `tools/topic-numbering.sh` is
the third question and the third instrument, built to the same shape as the second — replay
against the recorded transcript for the baseline, `--probe` for anything that has to see a
change to the skill.

**It needs no model to grade it,** for the reason `response-length.sh` needs none: *does every
top-level section start with a label* is countable. [#181](https://github.com/Calyx-Engineering/arc/issues/181)
is not a blocker for this any more than it was for #158.

Five decisions in it are worth keeping:

| | |
|---|---|
| **A topic is a heading at the reply's shallowest heading level** | A reply built out of sibling sections is the multi-topic shape the skill governs. Deeper headings are that topic's internals — one `## Section` over two `### sub-points` is one topic — and headings inside a fence are sample text. The one exception is a lone `# Title` over three `## sections`: that is a title, so it is dropped and the sections are the topics |
| **Partial is a fail, in the denominator** | Required by the issue, and right on its own: labels on the first two topics and none on the rest tell the reader numbering is available and then withhold it, so they restate everything. It also *reads* like progress, which is why scoring it as half a pass would let the defect appear as improvement |
| **A bare number is not a label** | `## 1. Branch from the sub-branch` scores unlabelled. `CLAUDE.md` and the skill both forbid it: issue numbers, mechanism numbers and pass numbers share those sentences, so `1` names nothing. The count of bare numbers is printed beside the verdict rather than folded into it |
| **The inline-bold form counts, and mostly cannot be graded** | The exemplar above carries no headings: it labels inline, `**D1 — …**` with prose following, and the user answered it by number. But it also carries five ordinary emphasis openings — `**Fails closed.**` — and nothing structural separates one of those from a dropped topic. So: **none** labelled is `NOTOPICS` (the skill's own single-decision template is two unlabelled bold lines, and failing it would be wrong); **all** labelled is `NUMBERED` (nothing was dropped); **some** labelled is `BOLDONLY`, unscored. Crediting that middle would score *labels the first few, then stops* as a pass — the one answer this instrument must never give. **`PARTIAL` is therefore detectable in the heading form only**, which is the form the skill documents |
| **Four ways to be unscorable, all loud** | `SINGLE` (one topic — nothing to number), `NOTOPICS` (no sections at all), `BOLDONLY` (above) and `CUT` (the runner truncated the reply) score in neither column and each print their own number. Same reasoning as `response-length.py`'s thin floor: a run made mostly of them is visibly not a measurement |

**The probe runner is shared, not copied.** `--probe` calls `tools/response-length-probe.py`.
Nothing in that file is length-specific: it replays a case's turns as one session and records
what came back. A second copy would be a second place for the allow/deny tool lists and the
cut-detection to drift.

## What changed in the skill

The rule went in the **`description:`** — [#158](https://github.com/Calyx-Engineering/arc/issues/158)
established that a standing conversational rule binds through the description and not through
the body, because the body is only in context on turns the skill fired. The body gained *It
applies to the whole reply, not only to a block*, which is the *when it applies* half: the
question block is where the rule is easiest to see, but the rule is about the reply.

## Measured

Baseline is replay. The fix is `--probe`, **three runs each side**, matched — same cap, same
case, same worktree, the only difference being which `SKILL.md` was in front of the run.

| | Every topic labelled | Turns that could not be scored |
|---|---|---|
| **Replay — what actually happened** | **0/3 · 0.00** · 16 topics, none labelled | 0 of 3 |
| **Probe, skill before this change** | 7/7 · 1.00 | 2 of 9 — one `NOTOPICS`, one `BOLDONLY` |
| **Probe, skill after** | 9/9 · 1.00 | 0 of 9 |

`chat-response` fired on t130 in **3 of 3** runs after, against **1 of 3** before.

Per run, with the raw replies retained this time via `TN_PROBE_OUT`:

| Run | Skill | Scored | Unscored | Fired |
|---|---|---|---|---|
| 1 | before | 2/2 · 1.00 | 1 `NOTOPICS` on t130 | no turn |
| 2 | before | 2/2 · 1.00 | 1 `BOLDONLY` on t130 | no turn |
| 3 | before | 3/3 · 1.00 | 0 | t130 |
| 4 | after | 3/3 · 1.00 | 0 | t130 |
| 5 | after | 3/3 · 1.00 — t131 scored **by bold lead-ins**, all 8 labelled | 0 | t130 |
| 6 | after | 3/3 · 1.00 | 0 | t130 |

Every run: `RL_PROBE_BUDGET=0.80`, cwd `R:/arc-wt/160`, one case, three turns, one session each.

`verify-all.sh`: 14 gates, all clean, exit 0. `topic-numbering.sh selftest`: 35 passed, 0
failed, exit 0.

### The result is negative, and that is the finding

**The case cannot measure this change.** Before and after both score 1.00. The `Done when` —
*the multi-topic case grades numbering at or above threshold* — is met by the unmodified skill
as thoroughly as by the changed one, so meeting it says nothing about the fix.

**Why there is no headroom.** The recorded defect is at turn 130 of a 391-turn session. The
probe replays three turns cold, and a cold model handed a long list of the user's thoughts
organises it into a labelled block unprompted. What the case measures is a cold model's
default, not the decay the issue is about.

**The one asymmetry is firing, not adherence.** `chat-response` fired on t130 in three of
three runs with the added description text and one of three without. [#155](https://github.com/Calyx-Engineering/arc/issues/155)
already established firing is neither necessary nor sufficient for the rule to hold, so this
is a weak signal about a mechanism, not evidence of the fix working.

**The skill change stands on the recorded defect and on #158's mechanism, not on this
measurement.** Sixteen unlabelled topics across three real replies is the defect; the
description is the only surface a standing rule binds through. The eval case is worth having
as a regression floor. It is not evidence, and this dev-log does not claim it is.

### An earlier version of this section reported 0.88 against 0.83. Those numbers are withdrawn

Six earlier probe runs were scored by an instrument that could not see the inline-bold form —
`**D1 — …** prose on the same line` — which is exactly how the reply this case is built around
is written. Runs it reported as *"no sections at all"* were in several cases numbered replies
the tool could not read. Review pass 1 caught it. The instrument was fixed, all six runs
re-taken, and the table above is the re-measurement.

**Review pass 2 then corrected the correction, and this time nothing had to be re-run.** Its
first finding was that the new bold path credited two labelled lead-ins as `NUMBERED` while
ignoring six unlabelled ones beside them — scoring *labels the first few, then stops* as a
pass, which is the defect the issue is named after. The path was rebuilt on the three-way rule
above, and the six runs were **re-scored from the JSON `TN_PROBE_OUT` had kept**. That is the
whole argument for keeping it: an instrument correction cost nothing the second time, against
roughly $7 the first time.

The re-score moved the control from 8/8 to 7/7 and left the conclusion untouched.

### The description wording was corrected after the probe ran

The probed text opened *"EVERY TOPIC IN A REPLY IS LABELLED, OR NONE IS."* Review pass 1 caught
that this is satisfied by labelling nothing — which is the 0/3 baseline this issue exists to
fix, and which the tool grades `UNNUMBERED`, a fail. The rule the model read and the rule the
tool graded disagreed. It now reads *"LABEL EVERY TOPIC IN A MULTI-TOPIC REPLY."*

**No result depends on which wording was in front of the runs**, because the runs found no
difference between the changed skill and the unchanged one either way.

## Limits on the above

| | |
|---|---|
| **n = 3 per side** | Enough to see that the case passes and that the control passes too. Not enough to rank two descriptions — the same limit #158 recorded, and the same reason: a rate over three turns swings hard |
| **The case is one case, three turns** | The suite is not a suite yet. A second case (`045b77e5` t26–t28, 0/4, 0/5, 0/6 at baseline) exists in the corpus and was left unbuilt to keep this unit one issue wide |
| **A cold probe cannot reproduce a long-context decay** | Recorded in the issue's `Spawned`. The defect lives at turn 130; nothing here replays 130 turns |
| **The probe is billed** | ~$1.00–1.40 per run for this case. Twelve runs including the six withdrawn ones, roughly $14. This is why `--probe` is not in `verify-all.sh`, and why `TN_PROBE_OUT` now exists — the first six runs' replies were not kept and could not be re-scored after the instrument was fixed |
| **The corpus is local** | Transcripts live under `~/.claude/projects` on one machine. Only the selftest is portable, which is the part wired into the gate |

## A probe cannot see a worktree's edit — [#211](https://github.com/Calyx-Engineering/arc/issues/211)'s surface

`tools/plugin-reload.sh` reinstalls from the marketplace, and the `calyx-engineering`
marketplace is a `directory` source at `R:\arc` — **the main tree**. Run from a worktree it
installs the main tree's content, so it would have measured the branch this work is not on.
`docs/arc-work/04-dogfood/run-instructions.md` §4 forbids `cd` to the main tree, and rightly:
another run is working in it.

What was done instead: the candidate `skills/chat-response/SKILL.md` was copied into
`~/.claude/plugins/cache/calyx-engineering/arc/0.1.0/`, the probe run, and the file restored
from a byte-compared backup. No main-tree write, and the before/after runs differ in exactly
one file.

**Every `--probe` number produced from a worktree in this arc was taken under this
constraint.** Filed in the issue's `Spawned` as needing its own issue.

## `tools/verify-hook.sh` left the global hook kill switch on

Two gates that had been clean all session — `mode-guard` 14/14 and `tracker-verify` 22/22 —
began failing **every** deny case at once, while nothing in this branch touched a hook.

The cause is in the verifier. It creates `~/.claude/HOOKS_OFF` to prove the kill switch works,
then cleans up conditionally:

```bash
KS_PREEXISTING=0
[ -f "$KS" ] && KS_PREEXISTING=1
touch "$KS"
...
[ "$KS_PREEXISTING" -eq 0 ] && rm -f "$KS"
```

**Any run that starts while the file already exists refuses to remove it.** Three worktrees
share one `$HOME`, so two overlapping runs leave `HOOKS_OFF` on disk permanently — and every
hook in every repo and every session is then inert, silently, because a kill switch that fires
produces no output by design.

Cleared by hand; `verify-all.sh` returned to 14 gates clean, exit 0, and a clean sequential run
does not leak the file.

**Not fixed here.** `CLAUDE.md` lists the verify script among the things never edited
autonomously. Filed in the issue's `Spawned`.
