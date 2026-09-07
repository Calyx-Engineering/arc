# Issue #155 — why a skill does not fire, and what would make it

**Issue:** [#155](https://github.com/Calyx-Engineering/arc/issues/155)  ·  **PR:** [#205](https://github.com/Calyx-Engineering/arc/pull/205)

## Problem

The premise was an inference: *skills fire on a bare explicit demand and not on a situation, and
an instruction wrapped around a skill's name appears to suppress the match.* Nothing measured it.
[#149](https://github.com/Calyx-Engineering/arc/issues/149) gave a firing rate per skill over
whole sessions, which cannot tell a match from a bulk load, and cannot see the shape of the
prompt at all.

**If one cause explained all six Fire symptoms, Fire-2 to Fire-6 would stop being separate work.**
That was the question worth answering.

## What changed

| File | |
| --- | --- |
| `evals/skill-firing/` | 13 cases, verbatim from real turns, in three shape directories. `prompt.md` + `case.yaml` + `graders/` — `claude plugin eval`'s layout, so the port is a rename |
| `evals/README.md` | The case format, and why the prompts are not invented |
| `tools/skill-cases.sh`, `.py` | Scores each case against the turn it came from: did the expected skill fire **before the next prompt turn**. Checks every prompt still matches its source. 11 selftests |
| `tools/skill-firing.py`, `.sh` | `is_prompt_turn()` replaces `is_user_turn()`. Selftest rebuilt: 12 cases, one session per rule |
| `tools/verify-all.sh` | The new selftest is a gate. 12 gates, all clean |
| `docs/arc-work/04-dogfood/skill-firing-decision.md` | The four rules, the per-shape baseline, the one-cause answer |
| `docs/arc-work/04-dogfood/skill-firing-baseline.md` | Corrected in place, with the defect stated and the numbers re-measured |

## The result

| Shape | Fired |
| --- | --- |
| **bare** — the name *is* the demand | **3/3** |
| **wrapped** — the name is inside an instruction | **2/7** |
| **situation** — no name at all | 2/3, but one is the control and the other fired inside a chain. **Neither fired on the situation alone** |

`handoff` fired at **0 of 5** prompts that asked for it. `camp` fired at **2 of 5**.

**The sharpest comparison is `camp` against itself.** Its description already says *"Use when the
user addresses Camp by name"*. Four real prompts name Camp; the two where the name is the whole
demand fired, and the two where it is a greeting in front of other requests did not.

## Decisions and trade-offs

| | |
| --- | --- |
| **A pass is a fire before the *next* prompt turn** | A fire twenty turns later credits the skill for the user's persistence. `handoff` "fired" in `be5aca1c` — at turn 52, after the user had asked four more times |
| **`case.yaml` records no outcome** | The scorer re-derives it from the transcript. A recorded outcome nothing re-checks is the tick-without-evidence failure |
| **The verbatim claim is enforced, not asserted** | Every `prompt.md` is compared to its source turn on every run, and drift fails the run. Otherwise *"drawn from real openings"* decays the first time someone tidies a typo |
| **A control case, where silence is the pass** | A suite scored on *fire more* is satisfied by firing everything. `situation/branch-up-to-date` fails if anything fires |
| **Cases live in `plugin eval`'s layout even though it cannot run** | `--help` works, every real invocation returns `` `plugin eval` is currently in early access `` — [#181](https://github.com/Calyx-Engineering/arc/issues/181). The prompts are the expensive half and they are portable |
| **The exit code is not the score** | It reports drift only. A baseline where failures fail the run is a gate, and this issue's output is a decision handed to the user |

## Unplanned but needed

**The instrument counted a skill's own firing as a user turn.** When a skill fires, its `SKILL.md`
body is injected on a `user` envelope — as are tool results, slash-command echoes, interrupt
markers and task notifications. `is_user_turn()` counted all of them, so a skill firing early
pushed the session's later turns out of the opening window and biased **at opening** downward.

The baseline this issue owes could not be produced with it, so it was fixed here rather than
filed. `origin.kind` and `promptSource` are the discriminators.

| Skill | At opening, before | After |
| --- | --- | --- |
| `arc-intent` | 0/15 | 2/15 |
| `issue-write` | 1/15 | 4/15 |
| `handoff` | 0/15 | 1/15 |
| six others | 0/15 | 1–2/15 |

**The corrected column still needs reading with care**, which is the point of the per-shape score.
Most of the movement is one session where the user typed *"please load all the skills from Arc"*
and eleven fired at once. `handoff`'s single at-opening fire is that bulk load.

## What testing the tests found

Three defects that a green selftest was hiding, each found by deleting the rule and checking the
suite went red:

- **Five assertions asserted the same regex** against a fixture where the wrong answer scored
  identically. Deleting the guard left them green
- **A guard in the docstring was never implemented.** The interrupt-marker exclusion was
  described and absent; real interrupts were excluded by a different clause, so nothing showed
- **Two assertions carried each other's labels.** The one reading *"a fire belonging to the next
  turn does not score this one"* was pointed at the fixture that proves the opposite

**A fixture where the wrong answer scores the same as the right one asserts nothing.** Every
exclusion now has a session built so that including it moves the skill out of the window, and the
mutation run — delete a guard, expect red — is what proved it.

## Hooks that fired

| Hook | |
| --- | --- |
| `tracker-verify` on the issue write | *"the title names more than one deliverable."* Correct as a rule — the title does name two. Left as written; splitting an issue mid-run would orphan the branch |
| `tracker-verify` on the PR | *"targets `arc/04-dogfood` from an issue branch. It belongs to its arc — base it on `arc/04-dogfood`."* The PR **is** based on `arc/04-dogfood`. This is [#183](https://github.com/Calyx-Engineering/arc/issues/183), reproduced |
| `tracker-verify` on the PR | No milestone, and no `arc-04:` prefix. Both correct, both fixed |

## Retrospective

**The premise was half right, and the wrong half was the load-bearing one.** *Bare fires* held at
3/3. *Situations do not fire* held. But the failing shape is neither: it is **wrapped**, at 2/7,
and wrapped is how the user actually opens — 8 of 11 human openings in this corpus name something
inside an instruction. The work was aimed at the shape that is rare and the fix belongs on the
shape that is common.

**One cause does not explain six symptoms.** It explains three. Fire-4 is disproved outright —
`chat-response` fired and the reply it governed drew *"ooof - that is a lot of words"*, while a
60-word budget was met in a session where it never fired at all. Fire-5 and Fire-6 have no session
where the skill fired and the symptom still occurred, so firing is untested as their remedy.
**Collapsing them into one fix would have shipped three fixes for one cause and called it done.**

**Pass 1 found a false claim in this issue's own decision document** — that `record-route`'s
description never says *log*. It says it three times, inside `dev-log` and `arc-log`. The point
survived; the sentence did not, and it was the kind a reader checks first.
