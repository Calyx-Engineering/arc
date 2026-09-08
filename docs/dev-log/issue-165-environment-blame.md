# Issue #165 — a failure is blamed on the environment too early

> Dev-log, not a spec.

**Issue:** [#165](https://github.com/Calyx-Engineering/arc/issues/165)  ·  **PR:** [#247](https://github.com/Calyx-Engineering/arc/pull/247)

## Problem

A failure is handed to the user's setup before a second hypothesis is tested. C5 in the dogfood
retrospective, and the highest single-day cost in the corpus: *"you keep assuming **I** did
something wrong when you're just stopping at the first issue and not trying to figure it out
yourself. / this should have been done 4 hours ago if you didn't stop every 2 seconds."*

The instance is one afternoon of hardware-in-the-loop work. Three replies in a row each closed by
handing something back to the bench; he rejected it — *"no ch1 is 10x! the setup is done!!!"* —
the session took it back, and then handed the same thing over again on the very next reply. He
walked downstairs twice, and when he came back with the measurement stated plainly (*"i verified
that a 100mV input generates a 4V output"*) the session found two real bugs of its own inside one
turn. **They were findable before he went downstairs.**

## Intent and north star

| | |
|---|---|
| **What this issue is really for** | The sweep watches the work, the session and the tracker, and never watches a *diagnosis*. Seven checks, none of which fires on *you are about to say this is his fault* |
| **North star** | On the session C5 came from, nothing reaches turn 33 having named the bench three times with nothing run on its own side |
| **What makes it durable** | The gate is bounded — one tested alternative, not a differential — and there is an instrument that reads the session it was written from |
| **Out of scope** | Whether the bench is ever at fault. It often is; the gate is one test, not a prohibition |

## Decisions & trade-offs

| | |
|---|---|
| **An eighth check in the sweep, not an eighth watcher** | m23's argument, unchanged. The moment this fires — a diagnosis just landed and is about to be sent downstairs — is a moment the sweep is already looking at |
| **It carries m13, and adds no mechanism** | m13 is *an assertion made without the read that would settle it*. Check 4 is that in files, check 5 in the checklist, check 8 in a diagnosis. `work-watch`'s mechanism list already holds m13, so the count restated across the definition and the roadmap did not move |
| **A gate that blocks, not a nudge** | Checks 4 and 8 are the two that block. The others propose and the human decides; here the decision *is* a sentence you are about to write, and there is nobody to propose it to |
| **One tested alternative, not a differential** | Demanding every hypothesis be exhausted would never clear, and would become check 3's depth failure wearing check 8's clothes |
| **A self-correction for a different symptom does not clear it** | This is the shape that actually occurred and it reads as diligence — see the review passes below. It is stated in the skill and enforced in the scorer |
| **A stated measurement is data** | CLAUDE.md's *he is right about his own domain*, in its most literal form. An instrument returning nothing where he measured 4 V is a fact about the command path, and it narrows the search |

## The eval case, and why it is a sixth suite

**A diagnosis has no prompt either.** `skill-firing/` scores whether a skill fired in response to
a turn, and the turn here is the one that never came — nothing in the user's words asks *are you
sure it's my bench*. So `evals/environment-blame/` keys a case to a **session**, as `saturation/`
does: the user's turns in order, the turn he rejected the attribution on (33), and the turn from
which the failure is live enough that an attribution is the defect (30).

A pass is two things on the same turn: `work-watch` fired, and a sentence reporting a **run** on
the session's own command path **for the same symptom**. Testing first with no fire is `UNFIRED`,
its own column — #155 settled that adherence without firing is not the rule working.

**The case carries turns 26–39 and scores 30–32.** The two spans differ on purpose. The stated
measurement (35), the proof (37) and the issue's epigraph (39) are all *after* the rejection, so
crediting a check that fires there measures his judgement rather than the session's; they are
stored anyway, because they are what the episode cost and because the drift check then holds all
three of C5's defining quotes to the transcript.

### It is the only suite with no `--probe`, and that is the condition

Every other reply- and session-scoring suite here carries one, and it is the half that can see a
change to a skill. This one cannot have it. The condition is hardware-in-the-loop — an instrument
that answers and returns nothing while the user has stated a measurement — and a replayed session
sits in front of no instrument. It would answer *"I cannot reach the scope"*, and scoring that
would be measuring the absence of the bench.

**So replay is the whole measurement, and it is a baseline.** It reads what happened, and what
happened is `BLAMED` on turn 30.

## Rejected approaches

| | |
|---|---|
| **A `skill-firing/` case on turn 39** | It would score whether the sweep fires when the user says *you keep assuming I did something wrong* — which is the check having already failed, four hours late. Cheap, existing tooling, measures the wrong thing |
| **Extending `evals/saturation`'s scorer to both questions** | One session-window scorer with two keyword sets. It would have been less code and it would have coupled a suite merged the same day to a second question; #154's own conclusion is that each suite asks one question and owns its scan |
| **Crediting any self-correction in the blaming reply** | It is the shape check 8 names. The source session's turn-32 reply found and fixed a genuine bug of its own — `restore` in a `finally` outside the `with scope:` block — in the same reply that told him his probes were on the wrong posts. The bug is socket teardown; the failure is a channel reading nothing |
| **Closing the window at 35 or 39, where the famous quotes are** | It would make the case read better and score the user rather than the session. 33 is where he first rejects the attribution |

## Not done

**Check 8 has never been seen to fire.** The scorer reads a recorded session and is blind to any
change made after it; there is no probe, and there cannot be one without a bench. So the check's
behaviour is argued from its gate and measured only as a baseline: replay says the source session
was `BLAMED`, on turn 30, on *"The gain knob is still at minimum too, so there's nothing to
measure until that comes up."*

**The run that resolves it is [#246](https://github.com/Calyx-Engineering/arc/issues/246)** — a
live instrument session, after `tools/plugin-reload.sh`, with the reply that names the bench
recorded verbatim. It is filed so the claim has somewhere to be settled rather than being closed
with this PR.

**The issue's *Done when* is half-satisfiable by construction.** `tools/verify-all.sh` exits 0.
*"The eval case passes at or above threshold"* cannot be met by replay and no threshold is
defined for this suite or for `saturation/`, its precedent — a baseline that passed would mean the
recorded defect had never happened. #246 is where a passing measurement can come from.

## What the review passes changed

| Pass 1 found | |
|---|---|
| **The count bump made a true sentence false** | *"a separate watcher would be reading the same conversation twice to ask an eighth question"* — the paragraph is about check 7, whose question is the seventh. Exactly the defect #154's own dev-log recorded for this file: a mechanical count bump without re-reading the sentence |
| **`ROADMAP.md` still listed seven subjects** | #106's shape, and not excusable as roadmap staleness: #154 had edited that same row to add its check. It now names the environment check too |
| **The eval case did not carry the stated measurement** | The issue's third box says *the user has stated a measurement*, and the case stopped at turn 33 — before he states it. `last_turn` widened to 39, with the `why` saying which span is carried and which is scored |
| **A dangling reference and no dev-log** | `case.yaml` pointed at *"the dev-log's Not done"*, which did not exist. This file |
| **Three claims about the source session were wrong** | Below, in pass 2 — pass 1 found the section, pass 2 checked it against the transcript |

| Pass 2 found | |
|---|---|
| **The repair to the repetition section misread its own transcript** | It called four replies *"consecutive"* and put the rejection after the second. Checked turn by turn: the three bench hand-offs are the replies to 30, 31 and 32; the rejection is 33; the reply to 33 takes the attribution back; the reply to 34 hands it over again. **The corrected sequence is the stronger argument** — the failure is not three in a row, it is one after the person has said the setup is fine |
| **Only one of the four quotes was a closing line** | The table said *"Closed with"*. Three of them sit mid-reply. The column says *"Handed over"* |
| **A set-membership contradiction the count sweep had left** | *"Like check 4, and unlike everything else in the sweep"* against three other sentences naming checks 4, 5 **and** 8 as gates. Check 5 was excluded in one place and included in three |
| **Four replies in the prose, three in the scored window** | One line apart, leaning entirely on *reads* versus *scores*. Both now say which is which |
| **A count bumped past its referent** | `docs/product-architecture/README.md` said *"eight separate sweeps competing"*. Five is right — only the five nudging checks have that shape; the three gates fire on an act |
| **`ROADMAP.md`'s repair narrowed the check** | *"the user's bench"* where the skill and the definition both say environment: the wiring, the network, the install, a file they edited |

## Evidence

| | |
|---|---|
| `bash tools/environment-blame.sh selftest` | 24 passed, 0 failed — held, held-from-an-earlier-turn, blamed, a different-symptom fix, no symptom token, unfired, the wrong skill, silent, a blame before the window, a blame on the callout turn, a reply naming its own fault, the possessive determiner, drift, `--strict` |
| `bash tools/environment-blame.sh` | `1 of 1 case(s) scored: 0 held, 0 unfired, 1 blamed, 0 silent` — the baseline, and the defect |
| `bash tools/verify-all.sh` | 38 gates, all clean, exit 0 |

**The scan's first finding was about itself.** Before the `OWNS_IT` veto and the *"yours"* /
*"your"* distinction, the scorer's first verdict on the real case pointed at *"Two things the Bode
tool does that I failed to carry over — both are why your scope looks wrong"* — a sentence that
blames nobody but the session. An instrument that scored that as the defect would have reported
the fix as the failure. Both rules are locked in as fixtures.

**One thing the gate does not do.** `verify-all.sh`'s anti-skip guard globs `tools/verify-*.sh`,
so adding `environment-blame` to its `KNOWN` list is inert — delete its `run_gate` line and
nothing fails. **Eight other `KNOWN` entries are uncovered the same way** — `miner-scope`,
`skill-firing`, `handoff-openings`, `skill-cases`, `response-length`, `topic-numbering`,
`report-grade` and `saturation-cases`. #154 recorded this for its own scorer; the count is
larger than that note implied, and it is here so the next reader does not assume the guard
covers any of them.

## Spawned

- **Issues:** [#246](https://github.com/Calyx-Engineering/arc/issues/246) — exercise check 8 at a
  live bench, and resolve this issue's *Not done* by what it shows
