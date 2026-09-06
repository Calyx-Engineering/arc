# Retrospective — dogfood, 2026-09-05

> **Diagnoses are drafts.** Only clusters marked *interviewed* have been reviewed by the user.

**Source work:** Lantern ROADZ speaker / sound-system.
**Window:** 2026-08-24 09:40 → 2026-09-05 — **from the moment Arc was installed.** `v0.1.0`
released 2026-08-21.
**Run by:** `agents/transcript-miner`, friction mode.

**Only post-install corrections count.** Before the boundary no Arc skill or hook existed, so a
correction from that window says a capability was missing, not that one failed. Pre-install hits
are excluded throughout.

## Scope

| | |
|---|---|
| Sources | 23 files · 86.6 MB — two transcript directories plus the 5 curated saves in `R:\work_lantern\_transcripts`, deduplicated on text and timestamp |
| Excluded | `R--work-lantern-roadz-pb-firmware` — a different repository. [#141](https://github.com/Calyx-Engineering/arc/issues/141) |
| `type: user` records | 4,987 → 544 after dropping tool results and deduplicating |
| Post-install, after filter | **84** |
| Post-install, clustered | **47** |
| Unclassified | 37 of 84 |

**The filter is deliberately permissive.** A false positive costs one read; a missed correction
costs a finding. Two passes: correction phrasing, and intensity markers — shouting, profanity,
repeated punctuation, exasperation. The intensity pass over-matches on EE part numbers and
standards (`RP2040`, `CISPR`, `HIZ`), which is the correct trade.

**37 of 84 post-install messages fit none of the clusters below.** Either the cluster set is
incomplete or the filter is loose. Recorded, not resolved.

---

## Ranked

| # | Cluster | Post-install | Group |
|:---|:---|---:|:---|
| [C1](#c1--handoff-does-not-restore-the-session) | Handoff does not restore the session | **not measurable — see below** | B |
| [C2](#c2--a-stated-obligation-dropped-and-not-returned-to) | A stated obligation dropped and not returned to | 11 | C |
| [C3](#c3--documents-written-as-development-narrative) | Documents written as development narrative | 5 | A |
| [C4](#c4--skills-not-loaded-until-demanded) | Skills not loaded until demanded | 5 | A |
| [C5](#c5--blames-the-physical-setup-stops-at-the-first-failure) | Blames the physical setup, stops at the first failure | 5 | D |
| [C6](#c6--response-length-re-set-and-then-not-held) | Response length, re-set and then not held | 4 | A |
| [C7](#c7--spawned-section-filled-with-the-wrong-things) | `Spawned` section filled with the wrong things | 3 | A |
| [C8](#c8--drawio-unsaved-state-lost-edits-temp-files) | draw.io — unsaved state, lost edits, temp files | 3 | D |
| [C9](#c9--commit-rhythm-wrong-in-both-directions) | Commit rhythm, wrong in both directions | 2 | C |
| [C10](#c10--work-done-in-the-wrong-branch-or-worktree) | Work done in the wrong branch or worktree | 2 | A |
| [C11](#c11--context-saturation-forcing-an-unplanned-stop) | Context saturation forcing an unplanned stop | 2 | B |
| [C12](#c12--behavior-rules-are-not-portable) | Behavior rules are not portable | 2 | D |
| [C13](#c13--numbered-topics-dropped-mid-conversation) | Numbered topics dropped mid-conversation | 2 | A |

**C1 is first despite having no usable count.** Ranking it by correction frequency would put it
last, and that is an artefact of the instrument, not a fact about the work — see its section.

### Groups

| Group | Clusters | Post-install | |
|---|---|---:|---|
| **A** | C3 C4 C6 C7 C10 C13 | **21** | A rule that already exists in a skill, and did not fire |
| **C** | C2 C9 | **13** | Process gaps |
| **D** | C5 C8 C12 | **10** | Domain and environment |
| **B** | C1 C11 | **2 + C1** | Handoff and context loss |

**Group A leads, and it is the group the boundary was drawn for.** *"The rule did not fire"* is
only sayable after the skills existed. C4 and C13 have **zero pre-install hits** — Arc-era
failures with no pre-Arc analogue.

---

## C1 — Handoff does not restore the session

**Correction-counting cannot measure this cluster, and its count should not be used.**

Handoff failure costs the user at session start — 20 minutes of a session that does not know what
it is doing, before there is anything specific to object to. By the time a correction is written,
the loss has already happened and is being reported once, not repeatedly. **A cluster whose damage
is lost time at spin-up produces corrections in inverse proportion to its cost.**

The user's position: *"handoff session restore effectively always failed."*

### What measuring it actually requires

Not correction density. Three things, per session opening:

| | |
|---|---|
| **The intent that went in** | Read the transcript that *wrote* the handoff — what the session knew and meant to carry forward |
| **The time to spin up** | From session open to the first turn that does correct work on the actual subject |
| **The accuracy of the spin-up** | Whether the resumed session pursued the deliverable, or a different one |

That is a different instrument from the friction filter and does not exist. Tracked as work.

### The evidence that does exist

- *"the handoff process completely failed. you did not pick up the handoff properly and you have consistently failed in picking up the handoff so the handoff procedure MUST be revised. i dont think its ever worked well once."* — `2026-09-04-arc-rev-b-pr70-closeout.jsonl` · 09-04 21:30

On 09-04 the session read `HANDOFF.md` end to end, reported status correctly, then redesigned the
measurement twice — neither redesign checked against what the unit exists to produce. It ended
with the work abandoned and a PR merged only to preserve state.

**The defect is not a missing field.** The dev-log's *Intent and north star* existed, was correct,
and was read at cold start as item 4 of the reading list. Named gaps: nothing fires when an
approach is replaced inside an accepted unit; the north star sits at position 4 and is never
re-read; the handoff duplicates the plan but omits the invariant; *"do not re-litigate"* is a table
with no check; out-of-scope and deferred look identical.

**Data-loss edge:** `HANDOFF.md` is gitignored, so a session that rewrites it destroys the only
copy of the state it was given.

## C2 — A stated obligation dropped and not returned to

Work acknowledged and then not done, surfacing only when the user checked days later. He began
carrying the tracking himself — *"i'll copy paste a reminder into my notepad"*.

- *"the log creation should have been part of onboarding. can you do it now?"* — `2026-08-26-...-issue-39-pinout.jsonl` · 08-26 10:33
- *"hmmmm did you re-check the readme for the mso tool? it calls out plotly ... can you add to the friction log that we REALLY need to have a final review of the modified files before PR to ensure everything got updated. thats a P1"* — `2026-08-28-...-earlier.jsonl` · 08-27 20:31
- *"hmmm, you walked in the opposite direct ion i asked. / the documentation was pretty good before, now its all gone! and the one thing you kept is what i asked you to drop!!!!"* — `2026-08-28-...-pr68-gain-sweep-tool.jsonl` · 08-28 13:16

## C3 — Documents written as development narrative

Reports, READMEs and one spec written as an account of the exploration rather than the conclusion.

- *"that whole discussion there with signal names called out is lacking all context - both you and i coming back to read this row of the table even 1 week later would not understand this at all"* — `2026-08-26-...-issue-39-pinout.jsonl` · 08-26 11:53
- *"yaml sweep values - there is too much in there. it looks like you're running real calculations and examples that are centered around an anxiety of overdriving the resistor"* — `2026-08-28-...-pr68-gain-sweep-tool.jsonl` · 08-28 13:09
- *"and AGAIN - what does `No alternative offered ... the opposite is a title nobody can act on.` mean???"* — `2026-09-04-arc-rev-b-pr70-closeout.jsonl` · 09-04 22:30

## C4 — Skills not loaded until demanded

**Zero pre-install hits** — the skills did not exist before the boundary.

- *"MOTHER FUCKER!!!! / LOAD ALL YOUR FUCKING SKILLS!!!! / you mis-labeled the branch so you're not using your issure writing skill or SOMETHING!"* — `2026-08-28-...-pr68-gain-sweep-tool.jsonl` · 08-28 10:36
- *"i mean... i literally said we are writing a spec here - and you didn't load spec-interview?????????????????? i'm very angry."* — same file · 08-28 10:44
- *"ooof - that is a lot of words. please load all the skills from Arc"* — `c4fe2b5c-....jsonl` · 08-30 13:39

**The shape is more specific than unreliable.** From counting `Skill` tool-use blocks:

| | |
|---|---|
| **Camp addressed by name at 4 session openings** | Fired on **2** — both bare *"where are we at"*. Did **not** fire on the two whose address carried further instruction: *"hey camp - i want to conclude measurements on issue 40 today. please read handoff, get up to speed, and tell me where we are at"* (08-28) and *"Hey Camp, please read handoff and get back up to speed"* (09-05) |
| **`arc:handoff`** | Fired **3 times in the corpus, never at a session opening**, against 8 openings instructing a handoff read |
| **08-28** | **920 assistant turns, 4 skill invocations.** Two landed 4 seconds after a demand |
| **08-30** | Eleven skills loaded within 9 seconds of *"please load all the skills from Arc"* |

**Skills fire on a bare explicit demand and not on a situation, and an instruction wrapped around
the name suppresses the match.** The two openings it missed are the two sessions C1 centres on.

## C5 — Blames the physical setup, stops at the first failure

**Zero pre-install hits.** Hardware-in-the-loop instrument work, 2026-08-28. Failures attributed
to a bench the user had verified by hand; he went downstairs to check the rig twice.

- *"the physical setup - i verified that a 100mV input generates a 4V output. if you're not getting anything then its an error on your side. / you might have broken the scope like yesterday with Bode dev"* — `2026-08-28-...-pr68-gain-sweep-tool.jsonl` · 08-28 15:15
- *"third is me re-setting everything and PROOVING to you that 100mvpp in = 4.167vpp out...since you won't believe me. / you keep setting bad ranges so you just rail..."* — same file · 08-28 15:32
- *"you keep assuming **I** did something wrong when you're just stopping at the first issue and not trying to figure it out yourself. / this should have been done 4 hours ago if you didn't stop every 2 seconds"* — same file · 08-28 15:54

## C6 — Response length, re-set and then not held

- *"Again, way too many words, distill responses to 60 words or less. 100 if its something critical and keep the ask at top and number topics so i can appropriately respond"* — `2026-08-26-...-issue-39-pinout.jsonl` · 08-25 17:54
- *"tangent - you haven't listened on conciseness - log that in friction log. this is bullshit and i'm angry now."* — `2026-08-28-...-pr68-gain-sweep-tool.jsonl` · 08-28 10:30
- *"uggh less words."* — same file · 08-28 14:48

## C7 — `Spawned` section filled with the wrong things

- *"why are you adding documents to the spawned section?"* — `bfd1177f-....jsonl` · 08-25 15:58
- *"hmmmm i dont think spawned in dev-log means that. can you point to something that supports the assertion?"* — same file · 08-25 15:59
- *"you wandered again. in the spawned section of PR70 you're throwing down random decisions or thoughts. thats not what the section is for..."* — `2026-09-04-arc-rev-b-pr70-closeout.jsonl` · 09-04 21:45

## C8 — draw.io: unsaved state, lost edits, temp files

- *"hmmm that works but not quite what i wanted. i want to see it in the draw.io when i open it there, but if the draw.io.svg is rendered into an md i dont want that note displayed"* — `bfd1177f-....jsonl` · 08-25 12:00
- *"also we need to exclude the temp draw.io files in gititgnore (i believe that is .dtmp)"* — same file · 08-25 14:52
- *"ok 2 things, it looks like both needed to be re-saved (i had draw.io desktop open)."* — same file · 08-25 15:57

## C9 — Commit rhythm, wrong in both directions

Commits made before review, and not proposed at the stopping points the user announced. He
reviews by diff in VS Code's source-control view; the commit boundary is what makes it legible.

- *"commit now before applying changes ."* — `bfd1177f-....jsonl` · 08-24 15:38
- *"ok this looks good. go ahead and commit."* — same file · 08-25 13:55

## C10 — Work done in the wrong branch or worktree

- *"ensure that we do not work in a stale branch"* — `2026-08-26-...-issue-66-bode-tool.jsonl` · 08-26 13:42
- *"i cant check you on this we are in the wrong branch right now ... next step - get me back into the right 68 branch"* — `2026-08-28-...-pr68-gain-sweep-tool.jsonl` · 08-28 12:53

## C11 — Context saturation forcing an unplanned stop

Sessions ran to a full context, the user noticed the degradation before any prompt did, and the
remaining budget went to writing a handoff rather than doing work. **This feeds C1** — a handoff
written under a shrinking budget is the input to the next session's failure.

- *"also, previous claude was overstuffed on context."* — `2026-08-26-...-issue-39-pinout.jsonl` · 08-25 16:25
- *"make sure handoff is really well set up for next steps and getting the context spun up again. This will be the last task in this thread (context is a bit full)"* — same file · 08-26 12:09

## C12 — Behavior rules are not portable

- *"i accidentally started work in \"Chat\" (i think that is github copilot) and it does NOT have the arc plugin running."* — `2026-08-28-...-earlier.jsonl` · 08-27 13:29
- *"bear in mind that it was written by a less capable AI with out the benefit of Arc to help guide it."* — same file · 08-27 14:12

## C13 — Numbered topics dropped mid-conversation

**Zero pre-install hits.**

- *"your table - (NOTE you stopped numbering items so i can't respond accurately to you)"* — `2026-08-28-...-pr68-gain-sweep-tool.jsonl` · 08-28 10:08
- *"ok for heavnes sake what do you need to do now? i asked a question about using my phone"* — same file · 08-28 14:30

---

## Recurred during this retrospective

With the plugin installed, 2026-09-05.

| Cluster | |
|---|---|
| **C6** | *"whoa, this is way too much response. what is going on right now. i'll spend hours reading at this rate."* A 600-word reply, with `chat-response` installed |
| **C7** | [#134](https://github.com/Calyx-Engineering/arc/issues/134) filed with no spawn edge. Caught by the user |
| **C13** | Issue numbers written bare rather than linked, against `chat-response`'s own rule. Caught by the user |
| **C2** | [#17](https://github.com/Calyx-Engineering/arc/issues/17) shipped missing two of five requirements. Found only when the user asked for a re-review |
| **C2** | Two issues were drafted, title-checked, announced as *"filing both now"* — and never filed. Found four hours later, by chance. Now [#142](https://github.com/Calyx-Engineering/arc/issues/142) and [#143](https://github.com/Calyx-Engineering/arc/issues/143) |

**Four clusters reproduced inside the session that was analysing them.** Every rule involved was
shipped, installed and loadable.

## Corroborating artifacts

Both transcript directories carry a `memory/` folder of promoted corrections:

`do-not-auto-commit.md` · `prefer-tables-over-prose.md` · `spawned-is-last-section.md` ·
`number-every-chat-list.md` · `load-chat-response-every-session.md` ·
`no-chat-synopsis-of-written-docs.md` · `diagrams-belong-in-artifacts.md` ·
`options-are-not-decisions.md`

**A promoted memory per cluster is itself evidence for group A** — the rule was written twice and
still did not hold.

## For the next run

A cluster that disappears after a mechanism ships is the only honest evidence the mechanism
repaid. Record these so the comparison is possible.

| Metric | This run |
|---|---|
| Post-install corrections after filter | 84 |
| Clustered | 47 |
| Unclassified | 37 |
| Group A share | 21 / 47 |
| **C1, by this instrument** | **Not measurable.** Do not compare its count across runs |
