# Friction log — arc-04, dogfood

> **K2, and it dies with the arc.** Written while the arc runs, not reconstructed afterwards.
> A finding that outlives the arc graduates to a mechanism spec or an issue; this file is the
> raw material, not the record.

**This is the input to a retrospective, not a small copy of one.**
[`friction-transcript-log.md`](../../retrospectives/2026-08-plugin-line/friction-transcript-log.md)
was mined from 28 transcripts and **ranked by recurrence** — ranking needs the whole corpus, so
it cannot be done as you go. This log is chronological, and each entry carries what a miner
would otherwise have to reconstruct.

| An entry has | |
|---|---|
| **What was being done** | The issue or step, so the trigger is locatable |
| **What happened** | Observed, not diagnosed. Quote the real output |
| **What is established, and what is not** | The diagnosis, kept apart from the observation — and naming outright what has *not* been isolated. Entry 1 exists because these two were merged once |
| **What it cost** | Minutes, a wrong belief, a handed-off task. *"None"* is a valid answer and worth writing |
| **What would have prevented it** | The mechanism, not the fix to this instance |
| **Where it went** | An issue number, a spec section, or **nothing yet** |

**One entry per friction, not per session.** A session with no friction adds nothing.

| Who fills it | |
|---|---|
| [`work-watch`](../../../skills/work-watch/SKILL.md) check 5 | Notices, and **proposes** the entry. The user decides whether it was friction — they are the one who felt it |
| [`record-route`](../../../skills/record-route/SKILL.md) | Routes it here rather than to a dev-log or the arc-log |
| Camp's operating agreement, §1 | **The switch.** On in this repository, off in the template — logging Arc's own rough edges is the case for a repository where Arc is being built |


## 1 · A boundary report that fails basic report logic, and the user has to teach the same rules again

**2026-09-13 · [#146](https://github.com/Calyx-Engineering/arc/issues/146), the Handoff boundary-report review**

### What happened

The review of the Handoff report took about ninety minutes of the user's time and eight corrections, each on a rule that is not new:

| The user had to say | What was in the report |
|---|---|
| *"one workstream, one report"* | Two reports for one workstream — §6.4 and §6.5 — because the workstream closed twice |
| *"a report tells us where we ended up, not a progression"* | *22/24 → 24/24*, *filed at the review*, *after a second closing (first …)* |
| *"it's a contradiction to call this Spawned and have 60% be things that were not spawned"* | Three of five rows read *Unfiled* — findings with no issue behind them |
| *"you don't use C1, C2 anywhere else"* | Labels coined for one table, in the summary and the evidence |
| *"what is it?"* | *Two commands use it* — an ambiguous pronoun where a noun belonged, then a 30-word rewrite instead of one specific word |
| *"give me the words for the goal, then a table"* | Four rewrites of a two-sentence summary before the user wrote it himself |
| *"link the issue numbers"* | Bare numbers in chat, twice, after the rule had been restated that session |
| *"why do we say `/arc-next`?"* — asked three times | Three wrong answers about a command the user and this plugin's own history had defined |

Each rule already exists in writing: `engineering-report` (state the conclusion, no development narrative), `issue-write` (Spawned holds units of work only), `chat-response` (every issue number is a link; no invented vocabulary), the user's own instructions (*he reads slowly*). The user's words: *"you're not applying basic logic. logic that I have to repeatedly revisit."*

### What is established, and what is not

**Established:** the report was written by a Sonnet report run and reviewed by this session before the user saw it, and neither applied the rules above. The rules were loaded — `chat-response` was invoked in this session on request — and still not applied to a document. The failure is not missing rules; it is that a rule for chat was not carried to a report, a rule for issues was not carried to a report's Spawned table, and a rule about narrative was not applied to a document that grew by annotation.

**Not established:** whether a self-review pass with the rules stated as a checklist would have caught them. Six review passes were asked for at the end and found seven defects the first pass had not, which says the rules are checkable; it does not say the first pass would have found them with the checklist in hand.

### What it cost

Ninety minutes of the user's review time on one workstream out of six; an angry user; two spawn rows filed a day late; the same command-name confusion answered wrongly three times.

### What would have prevented it

A report shape check that runs before a report is posted: one report per workstream (a second closing appends to the one section, it does not open another); Spawned rows carry issue numbers or do not exist; no progression phrases (*→*, *was*, *after the fix*, *found at the review*); no identifier used exactly once; the exec summary's goal line and before/after table present. `tools/report-grade.py` grades some of a report's shape already; none of these five.

### Where it went

Nothing yet. A candidate for [#279](https://github.com/Calyx-Engineering/arc/issues/279)'s review of `engineering-report`, arc 05, and for the report run's §6.2 in `run-instructions.md`.
