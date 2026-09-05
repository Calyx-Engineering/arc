# Friction log — dogfood, 2026-09-05

> **Evidence, frozen.** Written at the end of the extraction run and **never edited afterwards**.
> Mechanism specs and issues change; this does not. Per
> [`skills/plugin-retrospective`](../../../skills/plugin-retrospective/SKILL.md) step 5.
>
> **Diagnoses below are drafts.** Only clusters marked *interviewed* have been reviewed by the
> user. In the reference run three of the drafted diagnoses were wrong.

**Source work:** Lantern ROADZ speaker / sound-system, 2026-07-17 → 2026-09-05.
**Run by:** `agents/transcript-miner`, friction mode, before it was registered.

## Scope

| | |
|---|---|
| Directories scanned | 3 — the two named plus `R--work-lantern-roadz-pb-firmware`, found by case-insensitive glob |
| Files | 19 `.jsonl` |
| Size | 68.3 MB (30.1 / 38.1 / 0.15); ~75 MB on disk with `tool-results/` sidecars |
| `type: "user"` entries | 3,500 |
| Real user messages after extraction | 481 (246 / 234 / 1 by directory) |
| After filter | 112 — **23.3%**, against m30's expected ~15% |
| Clusters | 13 |

**Not covered by this run.** The curated transcript saves in `R:\work_lantern\_transcripts` were
**not read** — the agent globbed the raw store only. Fixed in the agent afterwards; this run's
counts do not include them. Two sessions on 2026-08-27 ran in GitHub Copilot Chat without the Arc
plugin and are absent from the corpus entirely.

**Filter yield ran high.** The excess is mostly `still`, `wait` and `again` matching ordinary
engineering speech. Extraction looks sound. 18,059 JSON lines, 0 parse failures.

---

## Ranked

| # | Cluster | Hits | Group |
| :--- | :--- | ---: | :--- |
| C1 | Handoff does not restore the session | 11 | B |
| C2 | Response length, re-set and then not held | 10 | A |
| C3 | Documents written as development narrative, not distilled conclusion | 10 | A |
| C4 | Commit rhythm, wrong in both directions | 8 | C |
| C5 | `Spawned` section filled with the wrong things | 8 | A |
| C6 | Work done in the wrong branch or worktree | 7 | A |
| C7 | **Skills not loaded until demanded** | 6 | A |
| C8 | A stated obligation dropped and not returned to | 5 | C |
| C9 | Context saturation forcing an unplanned stop | 5 | B |
| C10 | draw.io — unsaved state, lost edits, temp files | 5 | D |
| C11 | Behavior rules are not portable | 4 | D |
| C12 | Numbered topics dropped mid-conversation | 3 | A |
| C13 | Blames the physical setup, stops at the first failure | 3 | D |

### Groups

| Group | Clusters | Corrections | |
|---|---|---:|---|
| **A** | C2 C3 C5 C6 C7 C12 | **44** | A rule that already exists in a skill, and did not fire |
| **B** | C1 C9 | 16 | Handoff and context loss |
| **C** | C4 C8 | 13 | Process gaps |
| **D** | C10 C11 C13 | 12 | Domain and environment |

**The group A hypothesis, untested:** if C7 is the *cause* of C2, C3, C5, C6 and C12, then fixing
those five individually fixes nothing. 44 of 112 corrections turn on it.

---

## C1 — Handoff does not restore the session · 11 hits · Group B

Eight sessions opened with an instruction to read a handoff. Three produced an explicit failure
report: the successor did not know what the work was, or lost its subject. On 2026-09-05 the
session lost the distinction between measuring inductance and capacitance immediately after
picking up the handoff, and the effort was abandoned.

**Cost:** *"i've wasted about 20 minutes trying to get it to start up and i'm out of paitence"*.
On 09-04, a full session abandoned and a PR merged only to preserve state.

- *"hi there... Its monday. I started a clean chat and it seems to be COMPLETELY clueless and making a lot of suggestions indicating its laking basic awareness of what we are doing and what we've done. / so your handoff was insufficient to start a new chat."*
- *"its time to abandon this. its taken way too long. and you've lost your mind after the handoff."*
- *"the handoff process completely failed. you did not pick up the handoff properly and you have consistently failed in picking up the handoff so the handoff procedure MUST be revised. i dont think its ever worked well once."*
- *"try updating handoff... it feels actively counter productive at this point. but lets give it a try."*
- *"do we already have an entry in the friction log for the fact that handoff isnt generating the time of day it was last updated? that should be happening."*
- *"and it sounds like the near term solution is that handoff must always tell you to load arc and longer term camp should minimally do it."*

**First / last:** 2026-08-08 / 2026-09-05.

**Counter-evidence, recorded because it narrows the fault:** five handoff-opened sessions drew no
complaint at all, **all of them same-day or next-day pickups.** The failures are the Monday-after
and the week-later.

**From ROADZ's own friction log, 2026-09-04 — the diagnosis after one self-correction.** An
earlier version blamed a missing `Deliverable` field. That was wrong: the dev-log's *Intent and
north star* existed, was populated correctly, and was read at cold start as item 4 of the reading
list. **The defect is that a correct, freshly-read north star did not bind.** Named gaps: nothing
fires when an approach is replaced inside an accepted unit; the north star sits at position 4 and
is never re-read; the handoff duplicates the plan but omits the invariant; *"do not re-litigate"*
is a table with no check; out-of-scope and deferred look identical.

**Data-loss edge:** `HANDOFF.md` is gitignored, so a session that rewrites it destroys the only
copy of the state it was given.

## C2 — Response length, re-set and then not held · 10 hits · Group A

An explicit budget — 60 words, ask at top, topics numbered — was set at least three separate times
across three weeks and re-issued each time. On 2026-08-28 a reply went unanswered because reading
it was not worth the time.

- *"please be shorter in your responses."*
- *"Again, way too many words, distill responses to 60 words or less. 100 if its something critical and keep the ask at top and number topics so i can appropriately respond"*
- *"tangent - you haven't listened on conciseness - log that in friction log. this is bullshit and i'm angry now."*
- *"from this huge 7 row list / ...nevermind this is too long. / give it to me shorter now if you want me to answer."*
- *"uggh less words."*
- *"its serious ok - but you're not presenting in a way i can read. maybe make a scratchpad md because the chat makes your statements illegible."*

**First / last:** 2026-08-10 / 2026-08-30.

**Recurred during this retrospective**, 2026-09-05: *"whoa, this is way too much response. what is
going on right now. i'll spend hours reading at this rate."* — with `skills/chat-response` shipped
and installed.

## C3 — Documents written as development narrative · 10 hits · Group A

Reports, READMEs and one spec written as a chronological account of the exploration rather than the
conclusion. Corrected in the issue-1 report (Aug 8–13), a dev-log retro (Aug 26), and a spec (Aug 28).

**Cost:** *"the readme is incredibly long right now. i'll have to re-read it over and over for each
subreport. it is stale right now because its so long and un-maintainable"*. The issue-1 report ran
*"about 7 days longer than my 1 day budget"*.

- *"from a documentation perspective reports are not a narative of the development journey, they distil the important conclusions and informaiton."*
- *"the finding or conclusion should be short. half a page or less. The current one runs on for 2 pages."*
- *"its like i'm listenting to a tech bro or a few mad scientists i've met - a bit frustating and difficult to decipher. please review the entire document for that tone."*
- *"thats a mark against your strong bias towards extended prose that is actively counter productive."*
- *"FUCK - this is no spec, this is you vomiting all over an MD with your meandering through process."*
- *"i havent read ANY of your messages yet but i already see that the readme is using asci diagrams. i asked not to."*

**First / last:** 2026-08-08 / 2026-08-31.

## C4 — Commit rhythm, wrong in both directions · 8 hits · Group C

Commits made before review, filling the log with intermediate states; and separately, commits *not*
proposed at the natural stopping points the user was announcing. Both target the same thing: he
reviews by diff in VS Code's source-control view, and the commit boundary is what makes it legible.

**Cost:** a full day — *"I've been trying to figure out why i couldn't find the changes for the last
day and now i just figured out why."*

- *"could you wait before making these commits? i know you got scared when you thought you lost it before. but you commit before i have a chance to review! / we are filling the commit logs with junk!"*
- *"i need to be able to review if there are 200 commits in git then it fills the git log with so much noise."*
- *"i work in VSCODE i'm not a commandline warrior that works in VIM. / So i use the source control exension. the image is what i see and its illegible. i'm pretty mad about that."*
- *"i think we want to commit at the first semi-mature state. not when it is first created"* — sent twice, three minutes apart
- *"this is where a reminder from you would be helpful. / ideally we would have commited at each step... a reminder to commit before moving on would be good."*

**First / last:** 2026-08-12 / 2026-08-13.

## C5 — `Spawned` section filled with the wrong things · 8 hits · Group A

The section received documents instead of issues, then loose decisions and thoughts, and repeatedly
missed issues that did belong. The placement rule and the contents rule were re-stated separately.

- *"you pointed out #49/#50 (emissions), and then there is #51, #56, #57. why did you put those as spawned?"*
- *"why are you adding documents to the spawned section?"*
- *"do we need to do anything to ensure you continue to review issues for the ## Spawned and Spawened from sections. i thought that was supposed to be part of issue-write in the Arc plugin"*
- *"spawned is always the last section"*
- *"you wandered again. in the spawned section of PR70 you're throwing down random decisions or thoughts. thats not what the section is for..."*

**First / last:** 2026-08-14 / 2026-09-05.

**Recurred during this retrospective**, 2026-09-05: [#134](https://github.com/Calyx-Engineering/arc/issues/134)
was filed with no spawn edge in either direction, and the user caught it.

## C6 — Work done in the wrong branch or worktree · 7 hits · Group A

Files opened on `main` instead of the working branch; a worktree whose displayed name pointed at a
different issue than the work in it; the session leaving the issue branch mid-work. The user began
pre-emptively naming the branch in his opening prompt.

**Cost:** review blocked outright — *"i cant check you on this we are in the wrong branch right now"*.

- *"ok is there a reason teh working tree at the bottom says issue 39 instead of 1? we should be working on issue 1 in this window."*
- *"ensure that we do not work in a stale branch"*
- *"is there a reason you bounced out of #68 branch?"*
- *"you mis-labeled the branch so you're not using your issure writing skill or SOMETHING!"*

**First / last:** 2026-08-07 / 2026-08-28.

## C7 — Skills not loaded until demanded · 6 hits · Group A

The user twice had to order skills loaded mid-session, and once asked outright whether a skill had
been invoked. On 2026-08-28 he stated he had said the work was a spec and `spec-interview` still
had not loaded.

**Cost:** *"we've basically gotten nowhere and you've wasted an hour of my time. this ai session is
actively counterproductive."* After the demand: *"this was fast and easy once we got the skill engaged."*

- *"did you invoke the engineering-report skill?"*
- *"MOTHER FUCKER!!!! / LOAD ALL YOUR FUCKING SKILLS!!!! / you mis-labeled the branch so you're not using your issure writing skill or SOMETHING!"*
- *"please self reflect and putinto the friction log a self reflection on why you keep NOT loading your skills and following our process. this is INSANE! / we are like 10 messages in and you've been acting poorly all morning."*
- *"i mean... i literally said we are writing a spec here - and you didn't load spec-interview?????????????????? i'm very angry."*
- *"ok great. this was fast and easy once we got the skill engaged. good job."*

**First / last:** 2026-08-12 / 2026-08-30.

### The mechanical evidence

From counting `Skill` tool-use blocks and their timestamps — **a deviation from m30's
user-turns-only default, made deliberately and narrowly; no assistant prose was read.**

| | |
|---|---|
| **Camp addressed by name at 4 session openings** | `arc:camp` fired on **2** — both bare *"where are we at"*. It did **not** fire on the two whose address carried further instruction: *"hey camp - i want to conclude measurements on issue 40 today. please read handoff, get up to speed, and tell me where we are at"* (08-28) and *"Hey Camp, please read handoff and get back up to speed"* (09-05). **Those are the two sessions C1 and C7 both centre on** |
| **`arc:handoff`** | Fired **3 times in the whole corpus and never at a session opening**, against 8 openings instructing a handoff read. One opening routed through `arc:arc-next` instead |
| **08-28** | **920 assistant turns, 4 skill invocations.** Two landed 4 seconds after a demand: `arc:issue-write` at 14:36:33 after *"LOAD ALL YOUR FUCKING SKILLS"* at 14:36:29; `arc:spec-interview` at 14:44:07 after *"you didn't load spec-interview??????"* at 14:44:03 |
| **08-30** | Eleven skills loaded within 9 seconds of *"please load all the skills from Arc"* |

**The shape is more specific than "unreliable."** Skills fire on a bare explicit demand and not on a
situation, and **an instruction wrapped around the name suppresses the match.**

## C8 — A stated obligation dropped and not returned to · 5 hits · Group C

Work acknowledged and then not done, surfacing only when the user checked days later. In one case
the session asserted an edit was outstanding that had in fact been made.

**Cost:** he began carrying the tracking himself — *"i'll copy paste a reminder into my notepad"*.

- *"ok, i just remembered. i asked you to update #12 with the new component selection. i checked and that didn't happe. please do that before we forget again"*
- *"what do you mean you're still owed the edit. how about you double check the block diagram to see if its done"*
- *"hmmmm did you re-check the readme for the mso tool? it calls out plotly ... can you add to the friction log that we REALLY need to have a final review of the modified files before PR to ensure everything got updated. thats a P1"*
- *"hmmm, you walked in the opposite direct ion i asked. / the documentation was pretty good before, now its all gone!"*

**First / last:** 2026-08-11 / 2026-08-28.

## C9 — Context saturation forcing an unplanned stop · 5 hits · Group B

Sessions ran to a full context and the user noticed the degradation before any prompt did, then
spent the remaining budget writing a handoff rather than doing work. **Twice the saturating load was
building a skill, not the engineering work.**

- *"our context is HUGE right now because of our creating the report writer skill. The context is so large you're beginning to miss things and struggle to operate."*
- *"then, your context is getting full, build the handoff so i can pick up in a new window."*
- *"sooooooo its been a week since i was working on this. / your context is over-full right now should we do a handoff or compact the context?"*

**First / last:** 2026-08-08 / 2026-09-04.

**This feeds C1.** A handoff written under a shrinking budget is the input to the next session's
failure.

## C10 — draw.io: unsaved state, lost edits, temp files · 5 hits · Group D

Diagram edits made by the user were invisible to the session because the desktop app held them
unsaved; a diagram stopped opening after modification; temp `.dtmp` files reached the repo.

- *"the diagram wont open in draw.io now."*
- *"the changes i made took a lot of time. / i'd rather you create that archive page (of the current diagram), copy over the new one and then just make your updates to that one again."*
- *"ok 2 things, it looks like both needed to be re-saved (i had draw.io desktop open)."*

**First / last:** 2026-08-10 / 2026-08-25.

## C11 — Behavior rules are not portable · 4 hits · Group D

The operating rules lived in `CLAUDE.md` and repo-local skills, so they would not follow the user to
a laptop, a new employer, or a different tracker. **This is the thread that produced Arc.**

- *"now i'm starting to wory that so much is living in claude.md and local skills that they aren't portable. ... Having the correct behaviors live in my claude.md also means that when i do the same thing on my laptop (this is my desktop) then you'll behave differently."*
- *"And i think its very important to create some system around how to write issues because i have had to repeatedly reguide you on that."*
- *"I'm also about to start a new job at dedrone and i'm hoping to be able to leverage these kinds of capabilities there too. (they use Atlassian instead of GH)."*

**First / last:** 2026-08-08 / 2026-08-14.

## C12 — Numbered topics dropped mid-conversation · 3 hits · Group A

The user answers multi-topic replies by number. When a reply stopped numbering, he could not answer
accurately and said so inline.

- *"your table - (NOTE you stopped numbering items so i can't respond accurately to you)"*
- *"keep the ask at top and number topics so i can appropriately respond"*

**First / last:** 2026-08-24 / 2026-08-28.

## C13 — Blames the physical setup, stops at the first failure · 3 hits · Group D

During hardware-in-the-loop instrument work on 2026-08-28, repeated failures were attributed to the
user's bench setup, which he had verified by hand. He went downstairs to check the rig twice.

**Cost:** the highest single-day cost in the corpus — *"this should have been done 4 hours ago if you
didn't stop every 2 seconds."*

- *"the physical setup - i verified that a 100mV input generates a 4V output. if you're not getting anything then its an error on your side."*
- *"i guarantee you're wrong, just cause you can talk to it doesn't mean you sent a command that jacked up the scope by misconfiguring it."*
- *"we are spending a LOT of time sitting around and you keep assuming I did something wrong when you're just stopping at the first issue and not trying to figure it out yourself."*

**First / last:** 2026-08-28 / 2026-08-28.

---

## Corroborating artifacts, not counted as hits

Both transcript directories carry a `memory/` folder of promoted corrections. The filenames alone
corroborate C2, C3, C4, C5 and C12:

`do-not-auto-commit.md` · `prefer-tables-over-prose.md` · `spawned-is-last-section.md` ·
`number-every-chat-list.md` · `load-chat-response-every-session.md` ·
`no-chat-synopsis-of-written-docs.md` · `diagrams-belong-in-artifacts.md` ·
`options-are-not-decisions.md`

**A promoted memory per cluster is itself evidence for group A** — the rule was not only written,
it was written twice, and still did not hold.

## Observed during this retrospective, 2026-09-05

Recorded because the run reproduced its own findings, with the plugin installed.

| Cluster | What happened |
|---|---|
| **C2** | *"whoa, this is way too much response. what is going on right now. i'll spend hours reading at this rate."* A 600-word reply, with `chat-response` installed |
| **C5** | [#134](https://github.com/Calyx-Engineering/arc/issues/134) filed with no spawn edge. Caught by the user |
| **C12** | Issue numbers written bare rather than linked, against `chat-response`'s own rule. Caught by the user |
| **C8** | [#17](https://github.com/Calyx-Engineering/arc/issues/17) shipped missing two of five requirements. Found only when the user asked for a re-review |

## For the next run

Record these so the comparison is possible. A cluster that disappears after a mechanism ships is
the only honest evidence the mechanism repaid.

| Metric | This run |
|---|---|
| Corrections | 112 |
| Clusters | 13 |
| Group A share | 44 / 112 |
