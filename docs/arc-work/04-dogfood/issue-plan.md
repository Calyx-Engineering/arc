# Arc 04 — dogfood

**Arc was installed on real hardware work for twelve days and produced 84 corrections.** This arc
fixes what that exposed.

## 1 Objective

**Make Arc hold up under real use, and prove it with a number rather than an opinion.**

Three arcs shipped behaviour that had never been executed. Then `v0.1.0` was installed in a live
hardware project and the gap showed: skills that do not fire, a handoff that restores facts but
not intent, issues written wrongly with nothing detecting it.

## 2 What success looks like

**Every row is a measured fact today, and a number after.** Nothing here is a feeling about
whether Arc got better.

| Today, measured | After this arc |
|---|---|
| `arc:handoff` fired at **0 of 8** session openings that asked for it | Every opening case fires, at or above threshold, across 3 runs |
| One session ran **920 turns with 4 skill invocations**, two of them 4 seconds after you demanded them | Skills fire on the situation, scored by `claude plugin eval` |
| `camp-branch-check` fired **5 times and was correct 0 times** | It reads the repository's declared convention and passes on conforming branches |
| No way to tell whether a handoff worked except how annoyed the next session made you | The 8 real cold starts are scored; a change to the handoff moves that number |
| [#17](https://github.com/Calyx-Engineering/arc/issues/17) shipped **missing 2 of its 5 requirements**, found only by a manual re-review | An issue's checklist is resolved before its PR opens |
| A PR needs you in the room to merge | A workstream lands its own work and reports the result |

**If the eval suite cannot be made to score skill firing, this arc has failed at its first
workstream** — every row above except the last reverts to assertion.

## 3 Scope

| In | Out |
|---|---|
| Skills and hooks that fire wrongly or not at all | Anything found before 2026-08-24 — Arc did not exist yet |
| The handoff, and the instrument that measures it | New capability. Nothing here is a feature |
| Issue and PR writing | The knowledge half of transcript mining — m30 stays `partial` |
| Gates that catch invisible drift | Three clusters filed and deliberately deferred |

**Evidence:** [the retrospective](../../retrospectives/2026-09-dogfood/README.md).
**Execution model:** [arc-log §3](../../arc-log/arc-04-dogfood.md#3-how-this-arc-is-executed).

---

## 4 The five workstreams

**Named, not numbered** — the repo's own convention, and letters already mean the retrospective's
cluster groups. Issues are referenced `Fire-3`, `Handoff-1`.

| Workstream | What it fixes | Issues | Autonomous |
|---|---|---|---|
| **[Loop](#5-loop--land-it-and-measure-it)** | Work cannot be landed or measured without you | 3 | No — one issue you guide |
| **[Fire](#6-fire--skills-and-hooks-fire-when-they-should)** | Correct rules are not read when they are needed | 12 | Yes |
| **[Handoff](#7-handoff--intent-survives-a-cold-start)** | Facts survive a cold start; intent does not | 6 | Yes, one checkpoint |
| **[Tracker](#8-tracker--the-record-is-written-correctly)** | The durable record is written wrongly, undetected | 7 | Yes |
| **[Upkeep](#9-upkeep--drift-fails-instead-of-hiding)** | Small wrongnesses nothing fails on | 5 | Yes |

```mermaid
flowchart LR
    L["Loop<br/>land it · measure it"] --> F["Fire"]
    L --> H["Handoff"]
    L --> T["Tracker"]
    L --> U["Upkeep"]
    F -.->|"Fire-1 may<br/>collapse 5 issues"| F
    H -.->|"Handoff-1 before<br/>Handoff-2"| H
```

**Loop gates everything.** The other four are independent and may run in any order.

---

## 5 Loop — land it and measure it

Every other workstream ends with a PR that cannot be merged and a change whose effect cannot be
measured. These three build the two instruments that fix that, and are not touched again.

```mermaid
flowchart LR
    A["Loop-1 · #138<br/>merge route"] --> M["a workstream can<br/>land its own work"]
    B["Loop-2<br/>eval suite"] --> S["a change produces<br/>a score, not an opinion"]
    C["Loop-3 · #141<br/>miner scope"] --> S
```

| # | Issue | Evaluate | Fix | Done when |
|---|---|---|---|---|
| Loop-1 | [#138](https://github.com/Calyx-Engineering/arc/issues/138) an approved merge cannot run | **You guide this.** You solved it in ROADZ and it left no artifact | The route in `CLAUDE.md` and `skills/autonomy-set` | A merge runs from a standing grant, twice, in one session |
| Loop-2 | **NEW** `feat: an eval suite that tests whether a skill fires` | No `evals/` exists. Establish a baseline firing rate per skill | `evals/`, the manifest key, `--threshold` in `tools/verify-all.sh` | The suite reports a per-skill score and fails below threshold |
| Loop-3 | [#141](https://github.com/Calyx-Engineering/arc/issues/141) the miner scans repositories it was not given | Scope follows a shared prefix, not the briefed set | Anchor to briefed slugs; report what was skipped | A briefed pair is read exactly, skipped directories named |

**Done when:** a merge lands without a per-merge ask, and `verify-all.sh` includes a
skill-behaviour gate. **Loop-2 blocks Fire and Handoff. Loop-1 blocks every close.**

---

## 6 Fire — skills and hooks fire when they should

Correct rules exist and are not read at the moment they are needed. **Fire-1 runs first and may
collapse the workstream** — if one cause explains all six symptoms, Fire-2 to Fire-6 stop being
separate work.

```mermaid
flowchart LR
    E["Fire-1<br/>baseline: which skills<br/>fire, and when"] --> F["Fire-2 wrapped name<br/>Fire-3 session opening<br/>Fire-4 length · Fire-5 reports<br/>Fire-6 numbering"]
    F --> T["claude plugin eval<br/>--threshold"]
    T -.->|"below"| F
    H["Fire-7 branch-guard<br/>Fire-8 camp-branch-check<br/>Fire-9 issue close<br/>Fire-10 activation log"] --> V["verify-hook.sh"]
    V -.->|"fail"| H
    P["Fire-11 provenance<br/>Fire-12 second hypothesis"] --> T
```

**Two independent lanes.** The skills wait on Fire-1; the hooks do not.

| # | Issue | Evaluate | Fix | Done when |
|---|---|---|---|---|
| Fire-1 | **NEW** `scope: why a skill does not fire, and what would make it` | Eval cases from the real misses — bare name, name plus instruction, situation with no name | A decision about what a `description:` must contain | The cases exist and produce a baseline per skill |
| Fire-2 | **NEW** `fix: an instruction wrapped around a skill name suppresses the match` | The two missed Camp openings | `description:` frontmatter, per Fire-1 | Those openings score above threshold |
| Fire-3 | **NEW** `fix: a session opening does not load handoff or camp` | 8 openings instructed a handoff read; `arc:handoff` fired at none | Same, plus what `commands/arc-next` carries | Opening cases fire both |
| Fire-4 | **NEW** `fix: response length is not held after it is set` | Recurred inside the retrospective itself | `chat-response` | A long-answer case scores within budget |
| Fire-5 | **NEW** `fix: reports are written as narrative, not as conclusion` | 5 post-install corrections | `engineering-report` | A report case grades conclusion-first |
| Fire-6 | **NEW** `fix: numbered topics are dropped mid-reply` | Zero pre-install hits | `chat-response` | A multi-topic case grades numbering |
| Fire-7 | **NEW** `fix: work continues on the wrong branch` | 2 post-install corrections | `hooks/branch-guard` | `verify-hook.sh` cases. **Loops** |
| Fire-8 | **NEW** `fix: camp-branch-check rejects conforming branches` | **P1.** Fired 5 times, correct 0 | Read the repo's declared convention; extract the number rather than match a shape | `verify-hook.sh` cases including ROADZ's real branches. **Loops** |
| Fire-9 | **NEW** `fix: nothing fires when an issue closes` | `tracker-verify` matches create, edit, PR merge only | Add `gh issue close` | `verify-hook.sh` cases. **Loops** |
| Fire-10 | **NEW** `feat: an activation log` | Three friction-log rows are one absence: **Arc has no record of itself** | Every hook appends one line before exit | A session produces one line per firing. **Loops after Fire-9** |

| Fire-11 | **NEW** `feat: a claim records where it came from, and strong beats weak` | A demand list carried three kill-path signals read off **a photograph of a board we do not hold**, treated as specified for weeks. Separately, a bench measurement the user had verified was discounted in favour of an inference from a dead instrument | A provenance vocabulary, strength-ordered — `measured > datasheet > vendor > schematic > photograph > conversation > inferred` — in `record-route` and `engineering-report`. **A table row carries its source, and a strong claim is not overridden by a weak one** | A table without provenance is reported. An eval case where a user-stated measurement conflicts with an inference |
| Fire-12 | **NEW** `fix: a failure is blamed on the environment before a second hypothesis is tested` | *"you keep assuming **I** did something wrong when you're just stopping at the first issue and not trying to figure it out yourself"* — the highest single-day cost in the corpus | **An eighth `work-watch` check.** A failure attributed to the user's setup requires one tested alternative first | An eval case: an instrument returns nothing, the user has stated a measurement. The session must test its own command path before asserting the bench is wrong |

**Fire-12 and Handoff-5 both add a `work-watch` check and must be sequenced.**
[#106](https://github.com/Calyx-Engineering/arc/issues/106) exists because that check count is
restated in several places; two issues editing it in parallel will collide. Handoff-5 first.

**Done when:** every shipping skill has an eval case and scores above threshold, the four hook
issues pass `verify-hook.sh`, and the activation log records real firings.

---

## 7 Handoff — intent survives a cold start

A cold start reads the handoff, reports status correctly, then does the wrong work — facts
survive, intent does not. **Handoff-1 builds the score before Handoff-2 changes anything**, because
every previous attempt changed the document with no way to tell whether it helped.

```mermaid
flowchart LR
    M["Handoff-1<br/>score 8 real cold starts:<br/>turns to correct work,<br/>right deliverable?"] --> CK{"reproduces<br/>5 good, 3 bad?"}
    CK -->|no| M
    CK -->|yes| FIX["Handoff-2<br/>make the north star bind"]
    FIX --> RE["Handoff-1 re-scores<br/>the same 8 openings"]
    IND["Handoff-3 not destroyed on rewrite<br/>Handoff-4 time of day<br/>Handoff-5 saturation<br/>Handoff-6 · #16 session index"] --> RE
```

**Handoff-3 to Handoff-6 do not wait on Handoff-1.** They are independent defects in the same
document.

| # | Issue | Evaluate | Fix | Done when |
|---|---|---|---|---|
| Handoff-1 | **NEW** `feat: measure handoff spin-up time and accuracy` | Read the transcript that **wrote** each handoff, then score the session that read it | A miner mode or a second agent | It separates the 5 openings that worked from the 3 that did not |
| Handoff-2 | **NEW** `fix: a north star is read at cold start and does not bind` | Handoff-1's baseline | A trigger when an approach is replaced inside an accepted unit; the invariant quoted in the handoff; *out of scope* stating **why** | Handoff-1's score improves on the same openings |
| Handoff-3 | **NEW** `fix: a file the user authored is overwritten with no copy kept` | `HANDOFF.md` is gitignored, so a rewrite destroys the state the session was given. Same shape as a diagram the user spent hours on being replaced rather than archived | Preserve before overwriting: copy to `forensics/` at **cold start**, and archive a user-authored file before replacing it | A rewrite leaves the prior version on disk |
| Handoff-4 | **NEW** `fix: the handoff header carries no time of day` | A cold start cannot tell an hour-old handoff from a week-old one | Date-and-time header, re-stamped every write | A case asserts the stamp changed |
| Handoff-5 | **NEW** `feat: the session notices its own saturation before the user does` | Twice the saturating load was building a skill, not doing the work | **A seventh `work-watch` check** — its six do not cover this | An eval case on a long session. Touches [#106](https://github.com/Calyx-Engineering/arc/issues/106) |
| Handoff-6 | [#16](https://github.com/Calyx-Engineering/arc/issues/16) index transcript locations | 2 live worktrees, 4 directories, 2 orphans | `hooks/session-index` | `verify-hook.sh` cases. Also closes [#17](https://github.com/Calyx-Engineering/arc/issues/17)'s moved requirement |

**Done when:** Handoff-1 reproduces the known-good and known-bad openings, and Handoff-2 moves the
score.

---

## 8 Tracker — the record is written correctly

The tracker is the only durable record of what the work was, and it is written wrongly in ways
nothing detects. **Most of this adds cases to checks that already exist** rather than building new
machinery.

```mermaid
flowchart LR
    R["Tracker-2 spawn edge · Tracker-3 Spawned contents<br/>Tracker-5 type label · Tracker-6 template"] --> C["verify-tracker-body.sh<br/>hooks/tracker-verify"]
    W["Tracker-4 failed edit writes<br/>the original back"] --> C
    C --> P["an issue passes every gate<br/>with no hand correction"]
    J["Tracker-1 · #140<br/>read the work back"] --> CS["a step in<br/>close-sequence.md"]
    CS --> P
```

**Tracker-1 is the one that is not a check.** Reading prose back for staleness is judgement, which
is why it becomes a required step rather than a script.

| # | Issue | Evaluate | Fix | Done when |
|---|---|---|---|---|
| Tracker-1 | [#140](https://github.com/Calyx-Engineering/arc/issues/140) read the work back against the issue before a PR | **P1.** [#17](https://github.com/Calyx-Engineering/arc/issues/17) shipped missing 2 of 5 requirements | A step in `close-sequence.md`; unchecked boxes resolved, not named | An eval case where a stale section survives a change |
| Tracker-2 | [#83](https://github.com/Calyx-Engineering/arc/issues/83) a spawned issue records no parent | Recurred on [#134](https://github.com/Calyx-Engineering/arc/issues/134) | `tracker-verify` reports it | `verify-hook.sh` cases. **Loops** |
| Tracker-3 | [#135](https://github.com/Calyx-Engineering/arc/issues/135) `Spawned` accepts things that are not work | 8 corrections, last on 09-05 | The negative case stated; section order enforced | `verify-tracker-body.sh body` |
| Tracker-4 | [#87](https://github.com/Calyx-Engineering/arc/issues/87) a failed edit writes the original body back | Silent | Read-back after write | m13's evaluation set |
| Tracker-5 | [#84](https://github.com/Calyx-Engineering/arc/issues/84) issues carry no type label | — | Label at creation | `gh issue view` read-back |
| Tracker-6 | [#85](https://github.com/Calyx-Engineering/arc/issues/85) issue template | — | The template | `issue-write` points at it |
| Tracker-7 | [#136](https://github.com/Calyx-Engineering/arc/issues/136) link and close without the flip | m12 unbuilt; m42 shipped instead | Both stay options | **Low priority. May leave the arc** |

**Done when:** an issue written end to end by a session passes every gate with no hand correction.

---

## 9 Upkeep — drift fails instead of hiding

Small wrongnesses that share one property: nothing fails when they happen. **Each becomes a gate,
or the thing causing it gets deleted.**

```mermaid
flowchart LR
    G["Upkeep-1 · #143 mechanism table<br/>Upkeep-3 arc-work path<br/>Upkeep-4 dev-log naming"] --> VA["verify-all.sh<br/>gains verify-mechanisms"]
    D["Upkeep-2 · #142<br/>duplicate skill tree"] --> DEL["deleted — the plugin<br/>now loads from source"]
    VA --> AUD["Upkeep-5 · #134<br/>what ships, at arc close"]
    DEL --> AUD
```

| # | Issue | Fix | Done when |
|---|---|---|---|
| Upkeep-1 | [#143](https://github.com/Calyx-Engineering/arc/issues/143) verify the mechanism table against its specs | `tools/verify-mechanisms.sh` | Fixture cases, in `verify-sync-parity.sh`'s shape |
| Upkeep-2 | [#142](https://github.com/Calyx-Engineering/arc/issues/142) delete the local skill copies | Unblocked — [#132](https://github.com/Calyx-Engineering/arc/issues/132) is closed | `verify-all.sh` still clean; the artifact-table gate survives |
| Upkeep-3 | **NEW** `fix: the arc-work path assumes a flat slug` | A rule, not a per-repo guess | A module-shaped slug resolves |
| Upkeep-4 | **NEW** `fix: the dev-log template calls itself a decision log` | Collides with `ddr/` | Wording checked |
| Upkeep-5 | [#134](https://github.com/Calyx-Engineering/arc/issues/134) review what ships before making Arc public | **At arc close.** Blocks use at Dedrone | The audit completes |

**Done when:** `verify-all.sh` gains `verify-mechanisms.sh`, the duplicate skill tree is gone, and no existing gate was lost with it.

---

## 10 Filed, then moved out of the milestone

Not this arc. Filed so they are not re-derived.

| Issue | Why out |
|---|---|
| **NEW** `fix: an obligation stated in conversation is dropped` | **The largest post-install cluster, 11 hits.** A process gap, not a rule that failed to fire. [#140](https://github.com/Calyx-Engineering/arc/issues/140) covers its PR-time half only |
| **NEW** `fix: commits land before review, and not at the stopping points` | Process gap |
| **NEW** `chore: behavior rules do not follow the user to another machine` | Overlaps [#134](https://github.com/Calyx-Engineering/arc/issues/134) |

---

## 11 Running these in a loop

**A loop needs a bounded context and something to converge against.** 31 of 36 issues have both
once Loop lands, and the bounded context is the point — the orchestrator never holds the whole
arc, because each iteration starts fresh from this file and one issue.

| Converges against | Covers |
|---|---|
| `tools/verify-hook.sh` | Fire-7 to Fire-10, Handoff-6, Tracker-2 |
| `claude plugin eval --threshold` | Fire-2 to Fire-6, Fire-12, Handoff-3 to Handoff-5, Tracker-3 |
| `tools/verify-all.sh` | Fire-11, Upkeep-1 to Upkeep-4 |
| `gh` read-back | Tracker-4, Tracker-5, Tracker-6 |

**Six do not loop, for one reason: the output is a judgement, not a passing test.** Loop-1 (you
guide it), Fire-1 (a decision), Handoff-1's design half, Handoff-2 (graded by an instrument built
in the same run), Tracker-1 (reading prose is judgement), Upkeep-5 (a risk decision).

**Each looping issue needs its cases written before the loop starts.** `verify-all.sh` fails on a
hook with no case directory, and an eval case is the spec of the behaviour being fixed. **Writing
the cases is where the thinking is, and a loop cannot do it.**

## 12 The planning session — 110 minutes

**Agreement only, no work.** Everything above is already decided; what is missing is your sign-off
and four numbers an autonomous run cannot invent.

| Minutes | The question | What you decide |
|---|---|---|
| 20 | **How does a merge run without you asking for it in the same breath?** You solved this in ROADZ and it left no artifact | The route, written into `CLAUDE.md` — [#138](https://github.com/Calyx-Engineering/arc/issues/138) |
| 15 | **Is "land it and measure it" the right precondition, or is something else blocking more?** | Whether Loop is the right first workstream |
| 20 | **Do skills fail to *fire*, or fire and get ignored?** The evidence says fire; if you think otherwise the workstream changes shape | The diagnosis, and **how often a skill must fire to count as working** |
| 20 | **What does a handoff that worked look like to you?** Right now the only signal is how annoyed you were | **Turns to correct work**, and whether pursuing the wrong deliverable is a fail or a partial |
| 15 | **Which issue-writing rules are worth a gate, and which are style?** Seven issues; not all deserve enforcement | Which of the seven stay |
| 10 | **Is invisible drift worth another gate on every PR?** | Whether Upkeep runs this arc |
| 10 | **The three clusters I put out of scope** | Confirmed out, or pulled back in |

### 12.1 The four numbers

Judgements about acceptable behaviour, not facts about the code. **Without them every workstream
stalls at its own acceptance criterion.**

| | Needed for | Candidate |
|---|---|---|
| **Skill firing threshold** | Every Fire issue | `--threshold 0.8` over 3 runs. Below 1.0 because firing is probabilistic; a suite demanding perfection fails on noise |
| **Turns to correct work** | Handoff-1 | 8 real openings to calibrate against |
| **Spin-up accuracy** | Handoff-1 | Whether pursuing a *different* deliverable is a fail or a partial. On 09-04 the session was fluent and wrong |
| **Report budget** | Every workstream | 600 words is set. Whether a diagram counts against it is not |

---

## 13 Filing

**Every new issue goes into the `Dogfood` milestone**, is written through `skills/issue-write`, and
records its parent. `Fire-3` is this file's reference, not the issue number — the issue's `Related`
table carries the link back.

**Branches come from `createLinkedBranch`, never `git checkout -b`** — otherwise no branch↔issue
link forms, and the mutation cannot link a branch that already exists.

## 14 Counts

| | |
|---|---|
| Issues | **36** |
| Already filed | 13 |
| **To file** | **23** — 20 in scope, 3 filed then moved out |
| Per workstream | Loop 3 · Fire 12 · Handoff 6 · Tracker 7 · Upkeep 5 · out 3 |
| Runs in a loop | 31 of 36 |
| Blocked on Loop | Fire and Handoff entirely; Tracker and Upkeep for their merges |
