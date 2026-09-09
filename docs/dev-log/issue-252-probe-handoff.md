# Issue #252 — probe handoff firing after the staleness checks moved

**Issue:** [#252](https://github.com/Calyx-Engineering/arc/issues/252)  ·  **Parent:** [#146](https://github.com/Calyx-Engineering/arc/issues/146) — Handoff

## Problem

[#157](https://github.com/Calyx-Engineering/arc/issues/157) measured `skills/handoff` firing at
an opening. [#208](https://github.com/Calyx-Engineering/arc/issues/208) then moved the seven
staleness checks into that skill. No probe had run since, so two things were unmeasured: whether
the rate held, and whether the checks now travel with a firing.

## Before and after, beside #157's numbers

Eight cold-start openings, three runs each, plugin reloaded first. Same eight cases #157 used —
the `wrapped` openings whose `expect:` names `handoff`.

| | `handoff` | `camp` |
|---|---|---|
| **#157, after its fix** | 22/24 · 0.92 | 10/12 · 0.83 |
| **#252, after #208 moved the checks** | **24/24 · 1.00** | **12/12 · 1.00** |

Threshold 0.83. The rate did not fall, so the description is unchanged — the issue's constraint,
and [#213](https://github.com/Calyx-Engineering/arc/issues/213)'s failure was widening one on hope.

**A ninth handoff opening has been cased since #157** — `situation/copy-transcript-opening`, the
only one that never says the word. It is reported separately rather than folded in, because
folding it in would make the two rows above stop comparing the same thing. It scores 3/3, so the
nine together are **27/27**.

**`wrapped/handoff-updated-elsewhere` was #157's one below-threshold case** — `camp` 3/5 · 0.60,
left rather than tuned. It is now 3/3 for both skills. Nothing was done to that case.

**Two things changed between the measurements, not one.** #208 moved the checks, and this run
also fixed the instrument — see below. The rise cannot be attributed to #208 alone, and the
instrument's error was in the direction of under-counting, so the honest reading is that the rate
is at least as high as #157's, not that #208 raised it.

**The bar was compared by hand.** No invocation passed `--threshold`, so every printed `PASS` was
scored against the tool's 0.67 default. 0.83 is the issue's bar and the fractions clear it
outright; the tool's own verdict is not what says so.

### The controls, because 27/27 is the shape of a broken instrument

| Case | `handoff` | `camp` | Also |
|---|---|---|---|
| `situation/branch-up-to-date` — the silence control | 0/3 | 0/3 | nothing fired at all |
| `situation/side-project-opening` — the widened-clause control | 0/3 | 0/3 | `brainstorming` once |

`spec-interview` scores 0/3 on the second control. #157 records that `brainstorming` and
`chat-response` fired there and that neither `handoff` nor `camp` did; it does not record a
`spec-interview` score, so this is a new reading rather than an unchanged one. Not this issue's
to fix either way.

## The instrument was wrong, and it read a fire as a miss

**This is the finding worth most here.** The first probe run of this issue scored
`wrapped/handoff-then-do-these-in-order` at **handoff 0/1** — against a case that had been
passing. The skill had fired. The instrument could not see it.

`tools/skill-probe.py` stopped at the first assistant message carrying text and no tool call, on
the reasoning that such a message is the answer and whatever fired before it is the whole of what
fired before the answer. On this machine that reasoning is false.
`superpowers:using-superpowers` is injected into every session by a `SessionStart` hook and
instructs the model to **announce** *"Using [skill] to [purpose]"* before invoking it. The
announcement is a text-only turn. The probe read it as the answer and stopped one turn before the
`Skill` call.

The transcript of that run is one line long:

> `Using arc:handoff to read handoff and run staleness checks before acting.`

**The discriminator is not in the turn; it is in what comes next.** So a text-only turn is now
held as a *candidate* answer and reading continues. A following turn with a tool call proves it
was a preamble and clears it; a `result` line proves it was the answer. This is exact rather than
a heuristic on the wording, and it costs nothing — when the text really is the answer, `claude -p`
emits `result` immediately after it.

Same prompt, same installed plugin, before and after the fix: **0/1 → 1/1**.

**What this means for #157's numbers.** They are a floor, not a level. Any of its 2/24 misses may
have been the same artefact. This is not a reason to re-run #157 — its conclusion was that the
rate rose, and an instrument that under-counts cannot manufacture a rise.

The stop condition now has a regression test. `python tools/skill-probe.py selftest` replays
canned stream lines through the scan loop — 13 cases, no network, no billing. The announce case is
the first of them.

**A cut-back that turned out to be unnecessary was written and removed.** Reading past the answer
raises an obvious worry: a `Skill` call *after* the answer would now be counted, which is looser
than the criterion #157 measured under. Machinery to trim the report back to what had fired before
the answer was written, and it cannot work — "text, then tool calls" is structurally identical for
*announced, then invoked* and for *answered, then kept working*. It is also unnecessary: `claude -p`
is one-shot and terminates at the answer, so only the first shape occurs. All 27 dumps were checked
and none has the second. The reasoning is in the file rather than the machinery, and `answered` is
reported without being acted on.

## The box that could not be answered as written

> *In every firing transcript, the staleness checks are in the skill text the session read*

**The transcript does not carry the skill text.** Measured, not assumed:

| Where the skill text was looked for | What is there |
|---|---|
| The `Skill` tool_result in the stream | 28 bytes — `Launching skill: arc:handoff` |
| The session's own `.jsonl` under `~/.claude/projects/` | no line matching any of the seven checks |

The CLI injects `SKILL.md` by a path neither file records. Grepping a transcript for
`git status --short` answers *no* for a session that read all seven, so taking the box literally
produces a false negative and would have reported #208 as not having landed.

**What is decidable is stronger.** The dump records which skill was launched, *fully qualified* —
`arc:handoff`, not merely `handoff`. That name resolves to one installed directory holding the
exact bytes the session was given. `tools/probe-handoff-checks.sh` resolves it, pins the sha1, and
runs the content check. 27/27 firings, `arc:handoff`, sha1 `5a9b650c5e46`, all seven checks in the
read-path slice. Exit 0.

**The qualified name is load-bearing, and this run is why it exists.** The machine carried two
plugins serving a `handoff` skill at once: `arc@calyx-engineering` from `R:\arc`, and
`arc-scratch@calyx-scratch` from another live run's scratch marketplace. A bare `handoff` cannot
say which was read. Both copies happened to be byte-identical here — checked — but that was luck,
and the next run's need not be.

## Decisions & trade-offs

**The content check is `tools/verify-handoff-checks.sh`'s, not a second copy of the seven
literals.** One list, tuned in one place — #208's own argument against keeping the checks in two
artifacts, applied to the tool that checks them.

**`--expect <skill>` was added to `tools/skill-probe.sh`.** Without it, re-measuring one skill's
rate means running every opening — most about other skills, billed the same — or naming nine cases
by hand and adding the tallies up afterwards, which is how a reported rate stops being one command
anyone can re-run.

**Exit 2 is kept distinct from exit 1** in the new tool. *The checks are missing* and *I could not
tell which file was read* are different answers, and only one is a defect. Same precedent as
`tools/verify-linked-branch.sh`.

**Both new selftests are registered in `tools/verify-all.sh`.** Its unregistered-verifier guard
scans `tools/verify-*.sh` only, so a tool named `probe-handoff-checks.sh` slips past it by
filename. Cited as evidence and never run again is how a gate becomes decoration; neither invokes
`claude`, so neither bills. What stays out of `verify-all.sh` is the live probe, not the logic
that reads its output.

**The issue's own premise carries the wrong number.** It says #157 "measured openings loading
`skills/handoff` at 0.83". 0.83 is #157's `camp` rate; its `handoff` rate is 22/24 · 0.92. The
higher figure is used here, so the bar was raised rather than lowered by the correction.

**The plugin was not un-installed to remove the `arc-scratch` confound.** Another run owns it and
was live. It is recorded and measured around instead — the qualified name makes it visible rather
than silent.

## Evidence

| | |
|---|---|
| `bash tools/plugin-reload.sh` | exit 0. Installed `skills/handoff/SKILL.md` sha1 `5a9b650c5e46`, byte-identical to this branch's and to the marketplace source `R:\arc` |
| `bash tools/skill-probe.sh --case <each of nine> --runs 3` | 27 runs, `handoff` 27/27 |
| `bash tools/probe-handoff-checks.sh <dir>` | 27 dumps, 27 resolved, all seven checks present, exit 0 |
| `bash tools/probe-handoff-checks.sh selftest` | 16 cases, 16 passed, exit 0 — including the deny case, a fixture skill with one check cut out, which reports CHECKS MISSING and exit 1 |
| `python tools/skill-probe.py selftest` | 13 cases, 13 passed, exit 0 |
| `bash tools/verify-all.sh` | 49 gates, all clean, exit 0 |

The single equivalent of the nine per-case invocations is
`PROBE_TRANSCRIPT_DIR=<dir> bash tools/skill-probe.sh --openings --expect handoff --runs 3`. It was
run case by case only because each invocation had to finish inside this session's command timeout.

**Transcripts stayed local.** The 27 dumps are in this run's scratchpad and are not committed.

## Not done

- **#157's numbers were not re-measured with the fixed instrument.** They are a floor. Re-running
  them would cost 24 further billed sessions to restate a conclusion the fix cannot have reversed
- **The probe still cannot see the skill text itself**, only the file the qualified name resolves
  to. A session given a skill and then compacting it away would read as a pass here
- `spec-interview` remains 0/3 on `situation/side-project-opening` — #157's finding, untouched
