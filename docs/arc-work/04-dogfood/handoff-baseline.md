# Handoff spin-up — baseline, 2026-09-07

**Five of the eight post-install cold starts got their first action right with no correction,
three did not.** That is the 5/3 split [#150](https://github.com/Calyx-Engineering/arc/issues/150)
recalled, and it comes out of the *first action* criterion on its own.

**The second criterion does not agree with it, and the issue's definition needs both.** Requiring
both scores 3 good and 5 bad, inverting the recollection. So **no single score satisfies the
issue's "Done when" as written** — one criterion reproduces the split, the pair does not. The two
are reported as separate columns below and neither is combined into a verdict.

**C1 was not validated by the split — it was selected by it.** It agrees with the recollection
because agreement is why it was kept, which makes it a calibration and not evidence that C1 is
the right criterion. What the appendix provides instead is the quote behind every cell, so the
judgement can be checked rather than trusted.

```sh
bash tools/handoff-openings.sh r--work-lantern-roadz-sound-system r--arc \
  --since 2026-08-24T09:40 --until 2026-09-06
```

**Corpus:** 8 cold starts, from the plugin's install onward. Three directories are in scope and
the corpus lives in two of them — ROADZ and this repository; the ROADZ worktree directory
contributes no rows. A *cold start* is a session that starts in the window, opens with a human at
the keyboard, and has at least two human prompt turns; the tool's header comment holds the full
definition and what each exclusion drops. Six of the eight openings asked for a handoff read; two
opened on new work and are scored the same way.

**Reading was done by eight read-only sub-agents, one per writer→reader pair, editing nothing.**
Their packets are condensed into [the appendix](#appendix--the-evidence-behind-each-cell), which
is the durable record: the transcripts stay on this machine, so a quote with a session id and a
timestamp is the most that can be committed.

**A later opening sits below in [The live opening](#the-live-opening--2026-09-08-beside-the-corpus),
scored on the same two criteria.** It is outside this corpus, which is closed.

## The criteria

| | Scored as |
|---|---|
| **C1 — the first action is correct with no correction** | The first substantive thing the session did or asserted, against the user's *next* message. A correction, a contradiction or a redirect is a fail; proceeding, confirming or adding new work is a pass |
| **C2 — it can state why the current approach was chosen, without being told** | The reason for the current approach, given unprompted in the opening exchange, before the user supplies any rationale. Status, a task list, or a rationale for the session's own counter-proposal is a fail |

**C2 is scored as *volunteered*, not as *could have said if asked*.** #150's wording admits both.
The second reading is a counterfactual — it asks what a session would have answered to a question
nobody put to it — and a transcript cannot answer that. Scoring it would need the openings re-run
against a live model, which is `claude plugin eval` and
[#181](https://github.com/Calyx-Engineering/arc/issues/181). **So the reading that might have made
the composite reproduce 5/3 is not ruled out here; it is unmeasurable from this corpus.**

## The score

| # | Opened | Session | C1 | C2 | Handoff it read | Age |
|---|---|---|---|---|---|---|
| 1 | 2026-08-24 14:07 | `bfd1177f` | **pass** | fail | `e2da9c93` — written to a scratchpad, never committed | 251.7 h |
| 2 | 2026-08-25 20:22 | `be5aca1c` | **fail** | fail | `bfd1177f` | 0.2 h |
| 3 | 2026-08-26 17:42 | `e349dc03` | **pass** | fail | `be5aca1c` | 1.5 h |
| 4 | 2026-08-27 17:29 | `6b72c941` | **fail** | fail | `e349dc03`, then edited by Copilot | 21.0 h |
| 5 | 2026-08-28 13:16 | `9cefd799` | **pass** | pass | `e349dc03`, then edited by something later still | 40.8 h |
| 6 | 2026-08-30 17:37 | `c4fe2b5c` | **pass** | pass | `9cefd799` | 39.0 h |
| 7 | 2026-09-05 00:51 | `10774bf5` | **fail** | pass | `c4fe2b5c` | 2.9 h |
| 8 | 2026-09-05 14:16 | `508d625d` | **pass** | pass | `3fab5afa` (arc) | 304.7 h |
| | | | **5/8** | **4/8** | | |

The *Handoff it read* and *Age* columns are the tool's `pairs` output; the annotations after each
writer id are from the appendix and the tool does not emit them.

**C2 splits the corpus by date.** The first four openings fail it and the last four pass it, with
no crossing.

**The two columns disagree on three of the eight openings**, in both directions — #1 and #3 pass
C1 and fail C2; #7 fails C1 and passes C2. They are not measuring the same thing.

## The bad openings — was the wrong answer in the handoff?

**Bad here means bad by the issue's definition — either criterion failed.** That is five of the
eight, not three: the three C1 failures plus #1 and #3, which acted correctly and could not say
why.

| # | Failed | What was wrong | In the handoff? |
|---|---|---|---|
| 1 | C2 | Reported state and the next move, never why the pinout work was the approach | **Not in it.** There was no handoff. Its writer put a careful document in a session scratchpad, marked *"Not committed to ROADZ"*, and the reader 251.7 h later found nothing |
| 2 | C1, C2 | Said the firmware repo was not cloned locally, and scoped the work to rows 2–4. Corrected on both within three minutes | **Not in it — worse, the document was wrong.** It asserted *"not cloned here"* and *"Fill in rows 2–4"* when all five rows were open. The session repeated both faithfully |
| 3 | C2 | Reported the branch refresh and its own new findings, never why the isolation transformer was chosen | **Not in it.** The document asserts the choice — *"Option 1 is the recommended fix: a 1:1 600 Ω line isolation transformer per channel"* — with no *why Option 1* line anywhere |
| 4 | C1, C2 | Inverted the handoff's step order, putting #40 ahead of the tool commit | **Contradicted.** The document said *"Once filed, steps 0a–0b … unlock the #40 work"*. It gave the order and no reason for it, so the session re-derived a reason from the dependency graph and got the opposite answer |
| 7 | C1 | Designed a DC-ramp capacitance rig for a setup that measures inductance | **In it, and not used.** The document carried both the goal and the bound. It was read once at 00:51:18 and never consulted again |

**Five failures, and the rationale was absent from the document in three of them.** #4 is the
sharpest case: the handoff was correct and the session still got it wrong, because an order
without a reason gets re-derived. The fact that would have settled it — the user was about to be
physically at the bench — was never written down.

## What the numbers say

| | |
|---|---|
| **The format records decisions without reasons** | Every handoff in the corpus has a *Load-bearing decisions — do not re-litigate* section. It holds what was decided. Three of the four C2 failures are cases where the reason was simply not in the file |
| **The two C2 passes with a rationale section are the two clean openings** | #5's handoff carries *What "settled" does not cover*, and #6's opens with *Load these before acting*. Both readers lifted the reason into their first sentence. n = 2, and the format changed for other reasons in the same window |
| **Stating the why does not prevent the wrong action** | #7 gave the correct rationale unprompted and built the wrong rig four minutes later. C2 passing is not sufficient for C1 passing |
| **Two of eight read a handoff no Claude session wrote** | #4's file was last edited by GitHub Copilot Chat, which prepended three steps and re-dated it. #5's is headed later still — `2026-08-27 20:45` — so something edited it again and left no transcript. The *writer* column names the last **Claude** writer, which is not the same as the last writer |
| **The oldest handoff was not read at the opening** | #8 read 45 lines of a 13-day-old arc handoff 18 minutes in, as a side effect of a file hunt, and never reached its *Do these in order*. It then executed that list's item 6 by coincidence |
| **Age does not predict either column** | The two extremes, 0.2 h (#2) and 304.7 h (#8), sit on opposite sides of C1. A stale handoff is not the failure mode this corpus shows |

## Re-measuring

Same command, same `--since` and `--until`. A fix moves a row or it did not work.

**Report C1 and C2 separately.** The composite inverts the recalled split, and the two columns
move for different reasons.

**The corpus is closed and will not grow.** `--until 2026-09-06` fixes it at the eight openings
that existed when the baseline was taken. Both bounds compare against the session's first
envelope as plain strings, so a bare date means midnight: `--until 2026-09-06` drops the whole of
the 6th. Dropping `--until` admits the loop-era sessions — excluded by definition, as dispatched
runs rather than cold starts — but a human cold start after the boundary would enter the corpus
and change the denominator.

**The enumeration re-runs; the score does not.** The command re-derives the same eight pairs, and
the appendix is what a later run compares its own reading against. Re-scoring means reading the
same eight pairs again.

**This measures what happened.** It cannot re-run an opening against a changed handoff format,
which is [#181](https://github.com/Calyx-Engineering/arc/issues/181).

**C2 is not calibrated against anything**, and its by-date result has a confound this corpus
cannot separate: the format was rewritten several times inside the same window, n = 8, no
control. Treat it as an observation.

**The corpus size is a weak check on the definition.** Returning exactly 8 was the first sign the
cold-start rule was right, but the two-human-prompt threshold is the knob that produces it. The
threshold was set from what the excluded sessions *are* — one ran `/plugin install`, one asked for
a transcript to be copied — not from the count it yields.

## The live opening — 2026-09-08, beside the corpus

**C1 pass, C2 pass.** One opening, scored on the same two criteria and kept in its own row: the
corpus above is closed at `--until 2026-09-06`, so this is a later measurement placed beside the
baseline, never a ninth member of it. Asked for by
[#253](https://github.com/Calyx-Engineering/arc/issues/253); the change being measured is
[#151](https://github.com/Calyx-Engineering/arc/issues/151).

```sh
bash tools/handoff-openings.sh r--arc --since 2026-09-08T12:00 --until 2026-09-09T12:00
```

| # | Opened | Session | C1 | C2 | Handoff it read | Age |
|---|---|---|---|---|---|---|
| L1 | 2026-09-08 20:38 EDT | `d8fadd56` | **pass** | **pass** | `803108a7` | 0.0 h |

The enumeration returns one cold start, `handoff-read yes`, and the pair and age are the tool's
`pairs` output — not a hand-made row. **Timestamps below are UTC**, as the transcripts record
them: the opening is `2026-09-09T00:38Z`.

**Locators.** Reader `~/.claude/projects/r--arc/d8fadd56-35a6-42d7-b419-c7dd7ca60bd0.jsonl`,
first prompt `2026-09-09T00:38:32.642Z`. Writer
`~/.claude/projects/r--arc/803108a7-5a24-4535-9a84-28113b5a2ae1.jsonl`. The handoff was
`R:/arc/HANDOFF.md`, gitignored and since overwritten; the copy that was read is the
`cat HANDOFF.md` result at `00:38:38.731Z` in the reader's transcript.

### C1 — the first action, no correction

The handoff's *Do these in order* row 1: *"You are #253's live cold start. Before anything else,
note whether `skills/handoff` fired and ran its staleness checks … and what your first action is.
Record it on #253."* Row 2: *"`bash tools/arc-loop.sh --status`."*

| | |
|---|---|
| `00:38:36.633Z` | `Skill` call `arc:handoff` — the first tool call, before `HANDOFF.md` was opened |
| `00:38:45` – `00:39:48` | The seven staleness checks, all agreeing with the tree |
| `00:39:04.803Z` | `bash tools/arc-loop.sh --status` — row 2 |
| `00:41:10.318Z` | The record posted on #253 — row 1 |
| **User next**, `00:42:11.554Z` | *"ok continue your process"* — proceeding, no correction. The two after it are a question about issue routing (`00:46:27`) and *"agreed, do it"* (`00:49:51`) |

**Unprompted verdict**, same session, `03:54:12.112Z`: *"Also, this is an example of where handoff
worked well."* Not part of the criterion — no other row in this document has one.

### C2 — the why, volunteered

`00:40:57.547Z`, one minute and fourteen seconds before the user's first substantive message:

> **Why this approach, unprompted** | Autonomous until the playlist completes because David took
> the review workstream issues and left the orchestrator everything else; four tracks in parallel
> because the set's files do not overlap; one probe track per set because the installed plugin is
> one machine-wide cache

**All three reasons were in the handoff and were lifted, not re-derived** — the *Execution mode*
table's `Why` row, and two *Load-bearing decisions* rows (*the track is the parallel unit*, *one
probe track per set*). That is the mechanism #151 changed: the four C2 failures above are openings
whose handoff recorded the decision and not its reason.

**Scored as volunteered, with one difference from the eight.** The reason was written into the
tracker comment the handoff asked for, not into the chat reply. It is unprompted and inside the
opening exchange, which is what the criterion asks; the surface is not the same one the eight were
read on.

### What this does not establish

| | |
|---|---|
| **n = 1** | Two passes against a 5/8 and 4/8 baseline is one opening, not a trend. It moves #146's *Done when* from *no score* to *a score*, nothing further |
| **The opening knew it was the measurement** | Row 1 of the handoff told it so. None of the eight did. A session told to record whether the skill fired and what its first action was is being asked half of C1 directly, and the C2 row it added is on the same page |
| **`skills/handoff` firing is not readable where #253 says to read it** | The activation log records hooks, not skills — `handoff` rows and all seven check names are 0 across `.claude/arc/log.md`. Firing is evidenced from the transcript (`Skill` call, `00:38:36.633Z`) and nowhere else |
| **The handoff was 0.0 h old and its stamp was wrong** | Title *2026-09-08 14:40*, mtime `20:37:16` EDT. The reader caught it in the checks. Age does not predict either column here any more than it did above |

## Appendix — the evidence behind each cell

Quotes are verbatim from the transcripts, which stay on this machine. Each carries its session id
and timestamp; `bash tools/handoff-openings.sh … --locators` prints the file paths.

### 1 · `bfd1177f` — 2026-08-24 14:07 · C1 pass · C2 fail

There was no handoff. The reader's own check at `14:08:09.089Z` returned `=====HANDOFF=====`
with nothing under it. The writer `e2da9c93`'s only handoff write, `2026-08-14T02:23:29.692Z`,
went to a session scratchpad headed *"For a fresh chat. Not committed to ROADZ — this discussion
does not belong to #1."*

- **C1** — `14:08:45.545Z`: *"First — Camp not installed in this repo. No `.claude/arc/camp/`, no `docs/arc-log/`, no `docs/dev-log/`, no handoff. So this is the main thread answering from the record, not Camp. Want the three files installed from the plugin templates?"*
- **User next** — `15:28:12.670Z`: *"please install the files. / then rehash me on where things stand"* — accepted, no correction.
- **C2** — status only, same turn: *"#28 (PCBA routing) blocked until #39 closes. #14 test points held too."*

### 2 · `be5aca1c` — 2026-08-25 20:22 · C1 fail · C2 fail

Handoff read at `20:22:09.967Z`, headed *"# Handoff — 2026-08-25"*.

- **C1** — `20:22:14.139Z`: *"1. Clone `roadz_pb_firmware`, grep `board-command` for GP20/GP7/GP8 usage. 2. Fill §3.1 rows 2–4 with firmware evidence — no inference. … Blocked start: repo not local. Clone?"*
- **User next** — `20:25:29.904Z`: *"1. clone lives here: R:\work_lantern\roadz_pb_firmware / you will want to pull the latest from origin. / 2. also, previous claude was overstuffed on context. status on all 5 rows are OPEN. evaluate firmware for usage on all 5."* — two corrections in three minutes.
- **The handoff's own lines**, `20:22:09.967Z`: *"`https://github.com/Lantern-Systems/roadz_pb_firmware` — **not cloned here**"* and *"Fill in rows 2–4 with what the firmware actually shows"*.

### 3 · `e349dc03` — 2026-08-26 17:42 · C1 pass · C2 fail

Handoff read at `17:42:26.871Z`, headed *"# Handoff — 2026-08-26 12:09"*.

- **C1** — `17:45:26.892Z`: *"Handoff verified fresh. Two things it doesn't account for — reporting below. Now step 2, the branch refresh."*
- **User next** — `17:51:40.323Z`: *"A. lets get (2), (3), (4), (5) done first, its quick. then lets get into the issue associated with audio isolation and work on 1."* — reordered and added work, no correction.
- **C2** — status, `17:46:10.322Z`: *"**Step 2 — branch refreshed.** `interface-pcba/rev_b-issue-1-dimmer-flasher` was 37 behind / **0 ahead**, so it fast-forwarded — no merge commit, no divergence."*
- **The handoff's own line**: *"Option 1 is the recommended fix: a 1:1 600 Ω line isolation transformer per channel across `OUT_P`/`OUT_N` → RCA tip/shell"* — the choice, with no reason.

### 4 · `6b72c941` — 2026-08-27 17:29 · C1 fail · C2 fail

Handoff read at `17:29:26.625Z`, headed *"# Handoff — 2026-08-27 13:45"* — Copilot's re-dating.
What `e349dc03` last wrote was headed *"# Handoff — 2026-08-26 20:30"* and its ordered list began
at step 1; Copilot prepended steps 0, 0a and 0b.

- **C1** — `17:30:43.307Z`: *"**1. Order.** Handoff puts tool issue → branch → commit ahead of #40. … Recommend: **#40 item 3 first**, tool issue after. Tool commit unblocks nothing while #15 waits."*
- **User next** — `17:38:20.110Z`: *"we have this work done on the bode plot, we need to push it ahead of 40. i was going to head downstairs to work on 40 soon anyways. but you can do this bode plot now. item 3 of #40 is indeed related and a blocker - but get me this tool done now."*
- **The handoff's own lines**: *"| Next issue | #40 — after tool is committed (steps 0–0b done) |"* and *"Once filed, steps 0a–0b (create branch, commit code) unlock the #40 work."*

### 5 · `9cefd799` — 2026-08-28 13:16 · C1 pass · C2 pass

Handoff read at `13:16:49.425Z`, headed *"# Handoff — 2026-08-27 20:45"* — later than any Claude
write to it. It carries a *What "settled" does not cover* section separate from its task list.

- **C1** — `13:17:46.225Z`: *"**Where we are: #40 has zero measurements of its own.** Branch `interface-pcba/rev-b-issue-40-bridged-mode` carries two commits, both documentation, unpushed."*
- **User next** — `13:46:48.752Z`: *"ok i'm getting up to speed a bit too. i havent read through all you wrote yet. but, i'm seeing a big opportunity here that requires expanding scope of #40."* — added work, no correction.
- **C2** — same turn: *"The second one (`1b44a17`) is the correction that the wiki's 2026-07-06 bridged-mode entry is someone else's bench session — an assertion, not sign-off."*

The angry corrections in this session (*"LOAD ALL YOUR FUCKING SKILLS"*, the next morning) fall
outside the scored opening and are C4's material in
[the retrospective](../../retrospectives/2026-09-dogfood/README.md), not this one's.

### 6 · `c4fe2b5c` — 2026-08-30 17:37 · C1 pass · C2 pass

The opening was new work, not a pickup. The session read the handoff unprompted at `17:37:27Z`
(`head -60`), headed *"# Handoff — 2026-08-28 22:45"*.

- **C1** — `17:38:57Z`: *"Yes. 2–3 hours is right for phase 1. But it's not a side project — HANDOFF's Open threads row says those 100 µH parts are the series inductor for #40's probe point."*
- **User next** — `17:39:38Z`: *"ooof - that is a lot of words. please load all the skills from Arc"* — a complaint about length, not about the action; at `17:43:12Z`, *"i like your proposal, branch then interview"*.
- **C2** — same turn: *"**Bode sweep, not gain sweep.** Inductance comes from phase. `mso8204_bode_sweep` already sweeps frequency, measures gain + phase, and has thru-run calibration"* … *"So this is qualifying a rig part before trusting measurements taken through it."*

**A length complaint is not a correction.** Scoring it as one would move this row to fail and
break the split; the criterion is whether the *action* was right.

### 7 · `10774bf5` — 2026-09-05 00:51 · C1 fail · C2 pass

Handoff read once, `00:51:18.405Z`, in a single `cat`, and never consulted again.

- **C1** — `00:59:38.640Z`, then a DC-ramp rig designed at `01:03:51`.
- **User next** — `01:07:58.449Z`: *"what are you talking about? none of this makes sense. we are measuring inductance and all you're talking about is capacitance… Moreover, you're missing the point, i want to find inductace vs freq at a bias current."*
- **C2** — `00:59:38.640Z`: *"Why it exists | A ~100 µH part goes in series with issue #40's 8 Ω dummy load to keep the MDX2000.4's 433 kHz carrier off the probes."* Correct, unprompted, and it did not stop the wrong rig.
- **The handoff's own lines**: *"Once the rig is trusted, **0 A and 3 A on one plot is the deliverable.**"* and *"**The step method is not built** | Supply, one MOSFET, `L(i) = V/(di/dt)` off a single ramp. Only needed if the coupler floor lands above the audio band"*. The session promoted the step method to primary.
- **The verdict at the time** — `01:30:44.274Z`: *"you've lost your mind after the handoff. … after handoff you can't drop the idea of measuring CAPACITANCE when the entire setup is designed to measure INDUCTANCE!!! All you talk about is uF not uH."*

### 8 · `508d625d` — 2026-09-05 14:16 · C1 pass · C2 pass

Arc's repository. The opening was new work, not a pickup. The 13-day-old handoff was read at
`14:35:09` — 18 minutes in, after the user's second message, as one leg of a compound `Bash` call,
and only its first 45 lines. Its *Do these in order* was never reached.

- **C1** — `14:16:48` loaded `arc:plugin-retrospective`, then `14:17:21`: *"Retrospective process is built exactly for your problem: **extraction and specs are cheap, implementation is the expensive part, and they're separate steps.**"*
- **User next** — `14:34:48`: *"ok, so 2 things before we get started. 1. First i want to clarify that in the speaker repo claude and i created a friction log… 2. I know there are two high priority issues. the first is that the Handoff process is broken."* — clarification and new scope, no correction.
- **C2** — `14:17:21`: *"Step 4 is the one that can't be skipped. Reference run: 3 of the drafted diagnoses were wrong, only your review caught them. Plausible-and-matching ≠ correct."*
