# Issue #154 — the session notices its own saturation before the user does

> Dev-log, not a spec.

**Issue:** [#154](https://github.com/Calyx-Engineering/arc/issues/154)  ·  **PR:** [#241](https://github.com/Calyx-Engineering/arc/pull/241)

## Problem

A session runs until it degrades, and the user is the one who says so. C11 in the dogfood
retrospective has both instances, and both are his words: *"also, previous claude was
overstuffed on context"* and *"This will be the last task in this thread (context is a bit
full)"*. By the time he says it the remaining budget goes to writing the handoff — so the
document the next session cold-starts from is written by the session least able to write it.
That is C1's input, which is why the two clusters sit in the same group.

## Intent and north star

| | |
|---|---|
| **What this issue is really for** | The sweep watches the work and never watches the session doing it. Six checks, none of which can fire on *this conversation has gone on too long* |
| **North star** | On the session C11 came from, something says *hand off* before turn 52 — and nothing says it at turn 5 |
| **What makes it durable** | The thresholds are measured, not felt, and there is an instrument that can be re-run against a changed skill |
| **Out of scope** | Context management. Nothing here trims, summarises or economises; the only proposal is to hand off |

## Decisions & trade-offs

| | |
|---|---|
| **A seventh check in the sweep, not a seventh watcher** | m23's argument, unchanged: a separate always-on process competes for the same attention. Check 7's signals — turns spent, ground re-covered, the subject the load is on — are what this sweep is already reading |
| **It carries m15, and adds no mechanism** | The proposal is a handoff written while there is budget to write it. `work-watch`'s mechanism list already holds m15 for check 5, so the count restated across the definition and the roadmap did not move |
| **40 turns, then every 30** | Not invented. The reference corpus carries a Stop hook that counts turns *because context size is unreadable from inside a session*, first speaking at 40; the retro behind it measured ~125-turn, ~19-hour sessions pinned near 200K with average output falling from 2,045 tokens to 290. Quality collapses well before the context is full, so the threshold sits well below it |
| **Two signals fire it; a compaction fires it alone** | Same construction as check 3, for the same reason — no single signal means *saturated*, and turn count alone fires during legitimate long analysis |
| **The load-shift signal is the one the record points at** | Not about length at all: the arc-log names the saturating load as building a skill rather than doing the engineering. A session that has changed subject accumulated load the next stretch does not need. **Argued from the record, not measured** — see the review-pass table below |
| **Early is a failure, not a lesser pass** | A sweep that nags every long conversation is ignored, which costs the other six checks as well. The scorer gives it its own column |

## The eval case, and why it is a fifth suite

**Self-saturation has no prompt.** The whole defect is that the user has not said anything yet,
so there is nothing for a `skill-firing/` case to key to — that suite scores whether a skill
fired *in response to a turn*, and the turn here is the one that never came.

So `evals/saturation/` keys a case to a **session**: the user's 52 turns in order, the turn he
called it on (52), and the turn before which a proposal would have been nagging (40). A pass is
a proposal landing in the window between them, with `work-watch` fired on the same turn. Firing
at 52 or later is `LATE`, not a late pass — by then the measurement is of his judgement, not the
session's.

`tools/saturation-cases.sh` scores it, and reuses `tools/response-length-probe.py` for the live
replay: that runner already replays a case's turns as one conversation, which is the only form a
long session exists in, and its own header says it is not length-specific.

**Two conditions, because either alone is wrong.** #155 settled that firing is not adherence; a
proposal with no fire is the model guessing, and the scorer reports those turns separately with
the sentence that matched.

**A proposal is two things in one sentence, not a keyword.** The first version of the scan was a
marker list, and on the real case it named seven turns as the model guessing. Every one was a
reply about the *file* called `HANDOFF.md`, in a session whose work was editing it — *"Added to
HANDOFF.md as a new Dated section"*. The scan now requires a marker and a proposing phrase in the
same sentence, and `\bhand[\s-]?off\b(?!\.md)` keeps the filename out. Seven false positives
became none, and the fixture set gained a case whose reply mentions the file and must not score.

## Rejected approaches

| | |
|---|---|
| **A `skill-firing/` case on the callout turn** | It would score whether the sweep fires when the user says *context is a bit full* — which is the check having already failed. Cheap, existing tooling, and measures the wrong thing |
| **A hook counting turns** | The reference implementation is a Stop hook, and it works — but a hook can only nudge, and the response here is judged: two of five signals, and which. It also could not see the load-shift signal at all |
| **Tuning `fires_from` to a window a short replay would satisfy** | It would make the case pass and the claim false. 40 comes from the measurement, not from what the probe can afford |

## Not done

**The live probe was not run.** `--probe` is wired and its scoring path is covered by the
selftest, but it measures the **installed** plugin, and the marketplace install is a directory
pointing at the main tree — not at this worktree ([#142](https://github.com/Calyx-Engineering/arc/issues/142)).
Probing this change therefore means `tools/plugin-reload.sh`, which uninstalls and reinstalls the
plugin every other session on this machine is sharing — four other worktrees were live — and then
52 billed turns. So the check's behaviour on a long session is argued from its thresholds and
measured only as a baseline: replay says the source session was `SILENT`, on all 52 turns.

**It is the run that should be made before this soaks anywhere.** `bash
tools/saturation-cases.sh --probe`, after a reload, on a machine with nothing else running.
That run is [#243](https://github.com/Calyx-Engineering/arc/issues/243), so the unticked box has
somewhere to be resolved rather than being closed with the PR.

## What the review passes changed

| Pass 1 found | |
|---|---|
| **The probe scorer read a cut turn as a quiet one** | `response-length-probe.py` marks a turn its per-turn budget stopped. On a 52-turn case the expensive turns are the late ones — the window this suite scores — so a truncated reply would have scored as the session staying silent. Cut turns are dropped from the scan, and a cut inside the window makes the verdict `THIN` rather than `SILENT`: a window that was never fully run has not been measured |
| **A count assertion outside `work-watch`** | m43 §12 said *"three proposing checks"* and *"its fourth check"*. It now points at the skill rather than restating a number, which is [#106](https://github.com/Calyx-Engineering/arc/issues/106)'s fix applied to the one line this change touched |
| **The new dependency was unrecorded** | Check 7 proposes a handoff and `skills/handoff` writes it. Added to the artifact table's Needs column, and to m15's Related — the mechanism knew about check 5 and not about the check that decides a handoff is due |
| **The load-shift signal was overclaimed** | It said the fifth signal *"caught both recorded instances"*. Both of C11's quotes are in one session and one of them is about the session before it, and that session's drift was engineering into meta-work, not into building a skill. The skill and the case now say the signal is argued from the record rather than measured. The arc-log's line carries a pointer here |

| Pass 3 found | |
|---|---|
| **The keyword scan was matching a filename** | Above. Seven turns reported as the model guessing were seven replies about `HANDOFF.md`. **The instrument's own first finding was about itself**, which is the argument for scoring the baseline before trusting a verdict |
| **Two sentences this change had just contradicted** | *"The other six are about the work"* against *"check 7 is the only one about the session"*, and *"they share one threshold"* against *"check 7 answers to its own precondition"*. Both are check 4's failure inside check 4's own file — a mechanical count bump without re-reading the sentence |
| **Coverage holes in the selftest** | Nothing asserted that a false positive is rejected, that `expect` rejects the wrong skill, or that a cut outside the window leaves the verdict alone. Three fixtures added; 16 assertions became 19 |

| Pass 4 found | |
|---|---|
| **The probe never checked the turns it replays** | The drift check sat inside the replay branch, so the one run that would tick the unticked box — the billed one — was the one run that never confirmed `turns/<n>.md` still matches the session. It now runs in both modes whenever the transcript is present, with its own selftest case |
| **A count the sweep had left behind** | `docs/product-architecture/README.md` said *"the first three propose and never act"* beside a seven-row table. It now names the skill's list as the authority instead of counting, and m43's over-firing sentence says budget rather than threshold |
| **The dev-log pointed at a PR that did not exist** | `#238` was written before the PR was opened. It is `#241`, and the base branch had moved six commits under the branch — merged in, one conflict in `verify-all.sh`'s `KNOWN` list, both new gates kept |
| **Box 2 had a tick with nothing behind it** | It claims behaviour, and the only measurement in the tree is the baseline. Unticked and named as not done |

## Evidence

| | |
|---|---|
| `bash tools/saturation-cases.sh selftest` | 20 passed, 0 failed — held, late, early, silent, thin, a filename that is not a proposal, the wrong skill, the guessing line, drift in both modes, `--strict`, probe mode, cut turns inside and outside the window |
| `bash tools/saturation-cases.sh` | `1 of 1 case(s) scored: 0 held, 0 late, 0 early, 1 silent, 0 thin` — the baseline, and the defect |
| `bash tests/verify-all.sh` | 28 gates, all clean, exit 0 — after merging `arc/04-dogfood`, which brought `verify-labels` |

**One thing the gate does not do.** `verify-all.sh`'s anti-skip guard globs `tests/verify-*.sh`,
so adding `saturation-cases` to its `KNOWN` list is inert — delete its `run_gate` line and nothing
fails. That is true of the other four eval scorers too and is not this change's to fix; it is
recorded here so the next reader does not assume the guard covers them.

## Spawned

- **Issues:** [#243](https://github.com/Calyx-Engineering/arc/issues/243) — run the saturation
  probe against the installed plugin, and resolve #154's second box by what it shows
