# Arc: dogfood — the first real use, and what it broke

> **Arc log**, not a spec. The spine above the per-issue [dev-logs](../dev-log/) — it holds
> what spans issues.

**Milestone:** [Dogfood](https://github.com/Calyx-Engineering/arc/milestone/6)  ·  **Branch:** `arc/04-dogfood`  ·  **Started:** 2026-09-05

## 1 Why this arc exists

**Three arcs shipped behaviour that had never been observed.** `pre-release-review.md` §1 says
it plainly: *"Almost nothing Arc ships has ever run."* Then `v0.1.0` was cut, the plugin was
installed, and three weeks of real hardware work ran against it in ROADZ.

That work produced a friction log and 68 MB of transcripts. **This arc is what the evidence
says to fix.**

The stated intent, against which [`arc-intent`](../../skills/arc-intent/SKILL.md) classifies
everything spawned here:

> **Mine three weeks of real work for friction Arc caused, and fix what the evidence ranks
> highest.** Not: build what the roadmap says comes next.

**There are more findings than time.** Thirteen clusters, 112 corrections. The arc is scoped by
what the ranked list puts on top, not by what is filed.

## 2 Target architecture

```mermaid
flowchart LR
    W["Real work<br/>ROADZ, 3 weeks"] --> T["Transcripts<br/>68 MB, 19 files"]
    W --> F["friction-log.md<br/>hand-written, distilled"]
    T --> M["agents/transcript-miner<br/>#17"]
    F --> M
    M --> P["Ranked packet<br/>13 clusters, quoted"]
    P --> I["Interview<br/>the human diagnoses"]
    I --> S["Mechanism specs<br/>+ issues"]
    S --> A["Arc fixes<br/>this milestone"]
    A -.soak.-> W
    I --> L["docs/retrospectives/<br/>frozen evidence"]
```

**The loop closes at the dashed line.** A fix that never runs against real work again is
unsoaked, and unsoaked is the state three arcs shipped in.

## 3 How this arc is executed

**Manual until [#138](https://github.com/Calyx-Engineering/arc/issues/138) lands, then autonomous
per workstream.** Decomposition and acceptance criteria are in
[the plan](../arc-work/04-dogfood/issue-plan.md); this section is how a run behaves.

| | |
|---|---|
| Mode | **Manual** until the merge route is fixed. Autonomous per workstream after |
| The unit of a run | **One issue, not one workstream.** A workstream is 5–12 issues; running it in one context is how C11 happened — twice, the load that saturated a session was building a skill rather than doing the engineering. [#154](https://github.com/Calyx-Engineering/arc/issues/154) went looking for those two transcripts and found C11's pair sitting in one session, one of them about the session before it — [its dev-log](../dev-log/issue-154-saturation-check.md) records what is measured and what is argued |
| Where it stops | At a workstream boundary. Handoff also stops once, at Handoff-1's scores |
| What a run reads | **[`run-instructions.md`](../arc-work/04-dogfood/run-instructions.md), then the issue, and only what the issue names.** Not the plan — that is the human's forest view, and making it an execution input puts it back in the sync-drift path |
| Sub-agents | **Read and return only.** For large reads that collapse to a small answer — Fire-1's baseline, Handoff-1's scoring. A sub-agent that edits files and reports *done* is the failure this arc exists to fix |

### 3.1 How a run knows which issue is next

**The driver is a shell script — [`tools/arc-loop.sh`](../../tools/arc-loop.sh).** It picks the next issue,
starts a fresh `claude -p` session with
[`run-instructions.md`](../arc-work/04-dogfood/run-instructions.md) and that issue's body, and
repeats when the session exits. **It is the only thing that survives between runs** — every session
is cold, and the script holds the position in the queue. Not the orchestrator: a session that picks
and dispatches accumulates the whole workstream in its context, which is the failure this avoids.

**The driver picks; the run never does.** A run that selects its own work has read the whole
milestone to do it, which is the context blow-up this loop exists to avoid.

**The queue is GitHub sub-issues.** One parent issue per workstream, labelled `workstream`, its
issues attached as ordered children. One label, not five — it is a structural type every arc reuses,
and it is how the driver finds the parents without hardcoding numbers. Verified on this repo: `addSubIssue`, `removeSubIssue` and **`reprioritizeSubIssue`** all
exist, so order is native and no label, project board or queue file is needed.

| | |
|---|---|
| **Finding the parents** | `gh issue list --label workstream --milestone <name>` |
| **Next issue** | First open sub-issue of the current workstream's parent |
| **Order** | The sub-issue list order — `reprioritizeSubIssue` sets it |
| **Blocked** | An issue whose `Blocked by #NN` issues are still open is skipped, not started |
| **Workstream done** | No open children left. The driver dispatches a report run, then stops |
| **Where the report lands** | A comment on the parent, and [§6](#6-status) |
| **Scope of one invocation** | **One workstream.** `tools/arc-loop.sh <parent-issue>` runs its children, dispatches the report run, exits. The next workstream is a second invocation, after the user has read the report — the stop is mechanical, not remembered |
| **The driver holds no state** | Position is *which sub-issues are still open*, which lives in GitHub. Kill it mid-workstream and restarting resumes at the first open child with nothing lost |
| **Two drivers cannot take one issue** | The open list is a queue, not an interlock — two dispatchers read it and both picked [#158](https://github.com/Calyx-Engineering/arc/issues/158). An issue is **claimed** before any work starts, by a comment carrying an owner token and a TTL; selection subtracts the claimed set, the holder heartbeats while its run is alive, and every exit path releases. A killed dispatcher's claim expires on its own, so a restart still resumes — `--resume` at once, a plain restart within one TTL. `tools/arc-claim.sh`, [#214](https://github.com/Calyx-Engineering/arc/issues/214) |

**Labels were rejected** — five arc-scoped labels pollute a space the user reads, for something that
expires with the arc. **Projects was rejected** for this arc — a board that outlives the arc is a
larger decision and is not needed to run the loop.

### 3.2 The inside of an iteration

**`CLAUDE.md` says how to branch, commit, soak and edit hooks safely. It does not say how to do the
work well.** That sequence was missing when [#17](https://github.com/Calyx-Engineering/arc/issues/17)
shipped missing two of its five requirements, and it is what the user has been supplying by hand by
asking for another look.

**It lives in [`run-instructions.md`](../arc-work/04-dogfood/run-instructions.md)** — the file a
loop iteration reads ahead of its issue. Restating it here would give it two sources, and the one
nobody executes is the one that drifts.

**If it survives the arc it graduates to a mechanism.** It is arc-scoped for now because it is
unproven.

### 3.3 The report at a workstream boundary

**200 words maximum**, written into [§6](#6-status) under that workstream's own number. Durable
there in a way a PR comment is not, and posted on the workstream parent issue, which is where it
is read. **`bash tools/verify-report-budget.sh` counts it, and `verify-all.sh` runs that** — the
budget was stated in three documents, this one, `run-instructions.md` §6.2 and
`execution-process.md`, and read by none of them, which is how Loop's first report reached
302 words ([#185](https://github.com/Calyx-Engineering/arc/issues/185)).

**The boundary is a handover.** The mode drops to manual, the parent issue stays open until the
user closes it, and the next workstream is a separate grant. Sections, shapes and the ordered
sequence are in
[`run-instructions.md` §6](../arc-work/04-dogfood/run-instructions.md#6-a-report-run--the-workstream-boundary).

### 3.4 What is least certain, and why

| | |
|---|---|
| **Whether one cause explains six clusters** | Response length, narrative prose, `Spawned` misuse, wrong branch, skills-not-loaded and dropped numbering are all *a rule that exists in a skill and did not fire* — 21 of 47 post-install corrections. Fire-1 tests it. If it is one cause, five issues stop being separate work |
| **Whether the handoff can be fixed at all** | The user's position is that it has never worked once. A populated, correct, freshly-read north star did not bind — a worse defect than a missing field |
| **Whether skill firing can be scored at all** | Everything autonomous rests on `claude plugin eval` producing a usable number. Untested here |

## 4 Load-bearing decisions

| | |
|---|---|
| **Findings are frozen; fixes are not** | The friction log and the miner's packet are evidence and are dated. Unbuilt findings are backlog, not loss. This is what makes the time-box safe |
| **Priorities are set after the ranked list, not before** | The user named handoff and skill-triggering up front and explicitly held them open pending the full ranking |
| **The interview is not skippable** | `plugin-retrospective` step 4. Three of the reference run's diagnoses were wrong and only review caught them. Where the time-box bites, it bites on interview *breadth* — top clusters interviewed, the tail recorded unreviewed |
| **m12 and m42 are both options, neither is retired** | The default-branch flip is the convenience where its preconditions pass; manual linking is what works multi-user and without admin rights. m12 §5's *retire the switch* is wrong and is corrected in [#136](https://github.com/Calyx-Engineering/arc/issues/136) |
| **The default branch was flipped to `arc/04-dogfood` mid-arc** | Started on `main` deliberately, which tested the manual route and proved it — [#132](https://github.com/Calyx-Engineering/arc/issues/132) and [#17](https://github.com/Calyx-Engineering/arc/issues/17) were closed and linked by hand. Flipped at T+107 so later PRs bind natively. **Not retroactive:** [PR #137](https://github.com/Calyx-Engineering/arc/pull/137) and [PR #139](https://github.com/Calyx-Engineering/arc/pull/139) stay unlinked forever, which is why the manual links were necessary. All four m42 preconditions passed |
| **A merge runs only on an explicit request** | **Superseded 2026-09-07.** Held for four denials. After [#138](https://github.com/Calyx-Engineering/arc/issues/138) reduced the mode rule from five statements to one, [PR #172](https://github.com/Calyx-Engineering/arc/pull/172) merged unasked with no denial. One observation — statement count is the leading explanation, not proof |
| **Branches are created through `createLinkedBranch`, and the link is read back** | `git checkout -b` produces no branch↔issue link, and the mutation cannot link a branch that already exists. Proven both ways on [#132](https://github.com/Calyx-Engineering/arc/issues/132) and [#17](https://github.com/Calyx-Engineering/arc/issues/17). **The mutation's success is not the link** — `bash tools/verify-linked-branch.sh <NN> <branch>` immediately after, which is the only moment the answer is decisive ([#206](https://github.com/Calyx-Engineering/arc/issues/206)) |
| **A working handoff is defined by behaviour, not by content** | Settled by interview 2026-09-06. First action correct with no correction, **and** the session can state *why* the current approach was chosen without being told. Not re-proposing ruled-out work is wanted, not required. Every previous attempt changed the document instead, with no way to tell whether it helped |
| **Rationale is not narrative** | Leading hypothesis for why a correct handoff produces the opposite conclusion: *"we tried X then Y"* is cut as development narrative and the constraint that produced the decision goes with it. In hardware the constraint is what makes the next decision correct. Unproven — Handoff-1 tests it |
| **The manual process the handoff replaced worked** | A cold start that began by reading the previous session's transcript produced good results, and inspired the handoff. The document is a distillation of that transcript — **distillation is where the rationale is lost**, which is the same finding as the row above, arrived at from the other direction |
| **No standing merge grant has ever existed here** | Since Arc was installed, no merge has run without an explicit per-merge request. [#138](https://github.com/Calyx-Engineering/arc/issues/138) is building a route, not recovering a lost one |
| **Issue writing is in scope** | The user's call: *"good issue writing and naming has become a critical core to the development workflow."* Six issues carry it |

### 4.1 Judgement calls made unattended — 2026-09-07, workstream #145

**These were decided without the user, during an overnight autonomous run of [#145](https://github.com/Calyx-Engineering/arc/issues/145).** The grant was explicit — *"try to answer any questions yourself… what is most important is that any subjective things are documented so i can probe them later."* Every row is a call that could reasonably have gone the other way. **Each is reversible; none is load-bearing until reviewed.**

| Call | Made because | Reverse by |
|---|---|---|
| **[#156](https://github.com/Calyx-Engineering/arc/issues/156) merged with its `Done when` unverified** | `claude plugin eval` is gated and exits non-zero, so no behavioural evidence was obtainable. The change is purely additive — all eight prior trigger phrases survive — and the half that *is* measurable improved: bare-shape coverage 3/6 → 6/6 under `tools/skill-cases.sh`. Blocking on it would have stalled [#157](https://github.com/Calyx-Engineering/arc/issues/157)–[#160](https://github.com/Calyx-Engineering/arc/issues/160) identically; [#181](https://github.com/Calyx-Engineering/arc/issues/181) tracks the gate. **The call was wrong on the merits and [#157](https://github.com/Calyx-Engineering/arc/issues/157) proved it four hours later** — `tools/skill-probe.sh` measured the shipped description at camp **0/12 → 0/12**. The fix did nothing; the real cause was `camp` and `handoff` competing for one turn, and #157 fixed both. **Nothing to revert — #157 supersedes the description.** The lesson is that *unmeasurable* was treated as *probably fine* | — |
| **The dead run's uncommitted work was kept, not discarded** | The [#157](https://github.com/Calyx-Engineering/arc/issues/157) run was killed mid-work by a session limit, leaving `tools/skill-probe.*` and two eval cases uncommitted with no commits on the branch. A clean restart was the safer default; the work was inspected first and `skill-probe.sh` read as coherent and directly aimed at the gap in the row above. **Vindicated** — it produced #157's before/after measurement and is what disproved the #156 call | Nothing to reverse. The tool is merged and measuring |
| **[#158](https://github.com/Calyx-Engineering/arc/issues/158) was annotated rather than re-scoped** | The [#155](https://github.com/Calyx-Engineering/arc/issues/155) run recommended re-scoping it from activation to adherence. Reading it, it was already adherence-framed — what it lacked was #155's evidence, so a run would rediscover it. #155's two disproving sessions were added to the body, plus an explicit instruction to stop rather than tick an unmeasurable `Done when`. **Editing the Required boxes was the more invasive option and the evidence did not demand it** | Revert the issue body; the boxes are unchanged |

## 5 The tree

Classified by cause. [PR #133](https://github.com/Calyx-Engineering/arc/pull/133) is the
retrospective itself, so everything the evidence produced hangs off it.

```mermaid
flowchart TD
    P133["PR #133<br/>the dogfood retrospective"] --> I134["#134 what ships before public"]
    P133 --> I135["#135 Spawned accepts non-work"]
    P133 --> I136["#136 link and close without the flip"]
    P133 --> I138["#138 an approved merge cannot run"]
    P133 --> I140["#140 read the work back"]
    I17["#17 transcript-miner"] --> I138
    I16["#16 session index"] --> I17
```

**[#138](https://github.com/Calyx-Engineering/arc/issues/138) is blocked on
[#17](https://github.com/Calyx-Engineering/arc/issues/17)** — the fix that worked in ROADZ left
no artifact and exists only in transcripts.

**[#16](https://github.com/Calyx-Engineering/arc/issues/16) carries one of
[#17](https://github.com/Calyx-Engineering/arc/issues/17)'s requirements**, moved rather than
left unticked: the miner reads the index instead of globbing.

## 6 Status

**The only status surface.** [The plan](../arc-work/04-dogfood/issue-plan.md) holds decomposition
and acceptance criteria and carries no status — one fact, one place. The arc's tracker object is
[#196](https://github.com/Calyx-Engineering/arc/issues/196), whose ordered children are the
workstreams below; how the whole thing runs is
[`execution-process.md`](../arc-work/04-dogfood/execution-process.md).

Each workstream's 200-word boundary report lands here when it closes.

| Workstream | Parent | Issues | Status |
|---|---|---|---|
| **Loop** | [#144](https://github.com/Calyx-Engineering/arc/issues/144) | 5 | **5 of 5 closed.** Report in [§6.2](#62-loop--boundary-report). The parent stays open until the user closes it |
| **Fire** | [#145](https://github.com/Calyx-Engineering/arc/issues/145) | 13 | **In progress.** [#163](https://github.com/Calyx-Engineering/arc/issues/163) closed; [#166](https://github.com/Calyx-Engineering/arc/issues/166) — the activation log, every hook leaving a record — is in [#244](https://github.com/Calyx-Engineering/arc/pull/244); [#165](https://github.com/Calyx-Engineering/arc/issues/165) — `work-watch` check 8, one tested alternative before a failure is blamed on the user's environment — is in [#248](https://github.com/Calyx-Engineering/arc/pull/248); [#272](https://github.com/Calyx-Engineering/arc/issues/272) — `branch-guard` denying a write to a path in no repository, because the path-is-source check ran before the worktree check could exempt it — is in [#296](https://github.com/Calyx-Engineering/arc/pull/296). Spawned [#238](https://github.com/Calyx-Engineering/arc/issues/238), [#239](https://github.com/Calyx-Engineering/arc/issues/239), [#246](https://github.com/Calyx-Engineering/arc/issues/246) and [#294](https://github.com/Calyx-Engineering/arc/issues/294) |
| **Handoff** | [#146](https://github.com/Calyx-Engineering/arc/issues/146) | 6 | **6 of 6 closed.** Report in [§6.4](#64-handoff--boundary-report). The parent stays open until the user closes it. [#243](https://github.com/Calyx-Engineering/arc/issues/243), spawned by [#154](https://github.com/Calyx-Engineering/arc/issues/154), is open and not a sub-issue |
| **Tracker** | [#147](https://github.com/Calyx-Engineering/arc/issues/147) | 7 | **In progress.** [#199](https://github.com/Calyx-Engineering/arc/issues/199) — `tools/verify-issue-boxes.sh`, the box count `hooks/tracker-verify` runs on `gh pr ready` — and [#83](https://github.com/Calyx-Engineering/arc/issues/83) — the same hook reporting a tracker object that records no parent — are built. [#136](https://github.com/Calyx-Engineering/arc/issues/136) — linking and closing without the default-branch flip, m12 §5 rewritten as the choice between it and m42, plus `merge-close` and `tools/arc-link-sweep.sh` — is in [#290](https://github.com/Calyx-Engineering/arc/pull/290), which spawned [#286](https://github.com/Calyx-Engineering/arc/issues/286) and [#287](https://github.com/Calyx-Engineering/arc/issues/287). [#140](https://github.com/Calyx-Engineering/arc/issues/140)'s *not a gate script* constraint is narrowed to the prose half |
| **Upkeep** | [#148](https://github.com/Calyx-Engineering/arc/issues/148) | 9 | **In progress.** [#203](https://github.com/Calyx-Engineering/arc/issues/203) — the coordination prefix becomes an operating-agreement setting rather than a constant in `hooks/branch-guard` — merged in [#249](https://github.com/Calyx-Engineering/arc/pull/249). [#185](https://github.com/Calyx-Engineering/arc/issues/185) — the boundary report's word budget, counted — and [#198](https://github.com/Calyx-Engineering/arc/issues/198) — `set-mode.py`'s read-back and its round trip to `hooks/mode-guard` — are in [#256](https://github.com/Calyx-Engineering/arc/pull/256). [#204](https://github.com/Calyx-Engineering/arc/issues/204) — a milestone item is one unit of work, so an issue-closing PR carries no milestone — is in [#257](https://github.com/Calyx-Engineering/arc/pull/257); 35 issue-closing PRs stripped, Dogfood down from 120 items to 85 |

### 6.1 The retrospective and the plan

The arc's scoping phase. Two of its three units were tooling the retrospective could not run without.

| Unit | Dev-log | |
|---|---|---|
| [#132](https://github.com/Calyx-Engineering/arc/issues/132) local edits never reach the installed plugin | [issue-132-plugin-reload](../dev-log/issue-132-plugin-reload.md) | **Merged** — [PR #137](https://github.com/Calyx-Engineering/arc/pull/137). Closed and linked by hand |
| [#17](https://github.com/Calyx-Engineering/arc/issues/17) transcript-miner, friction mode | [issue-17-transcript-miner](../dev-log/issue-17-transcript-miner.md) | **Merged** — [PR #139](https://github.com/Calyx-Engineering/arc/pull/139). Closed and linked by hand |
| The retrospective, the plan, `run-instructions.md` and the driver | [pr-133-dogfood-retrospective](../dev-log/pr-133-dogfood-retrospective.md) | **Merged** — [PR #133](https://github.com/Calyx-Engineering/arc/pull/133) |

**The planning session collapsed from 110 minutes to about 15.** Five of its seven questions were
asking the user to re-approve decisions already made. The two that were real — the merge route,
and what a working handoff is — were settled in conversation.

---

### 6.2 Loop — boundary report

**Workstream:** Loop · **Closed:** 2026-09-07 · **199 words**, diagram excluded

#### 6.2.1 Delivered

Three preconditions for every other workstream. None existed.

1. Commits, pushes, PRs and merges run when the mode allows them
2. They stop when it does not
3. A number for how often each skill fires

#### 6.2.2 Spawned

| Issue | | Routed to |
|---|---|---|
| [#173](https://github.com/Calyx-Engineering/arc/issues/173) | Onboarding detects duplicated rules | **Out** — m47 |
| [#174](https://github.com/Calyx-Engineering/arc/issues/174) | Agreement tunes verbosity | Upkeep |
| [#175](https://github.com/Calyx-Engineering/arc/issues/175) | Cold-start reading path | Upkeep |
| [#177](https://github.com/Calyx-Engineering/arc/issues/177) | Delete command copies | Upkeep |
| [#181](https://github.com/Calyx-Engineering/arc/issues/181) | `plugin eval` gate — blocked | **Out** — no milestone |
| [#183](https://github.com/Calyx-Engineering/arc/issues/183) | `tracker-verify` false positive | Fire |
| [#185](https://github.com/Calyx-Engineering/arc/issues/185) | Report budget unchecked | Upkeep |
| [#190](https://github.com/Calyx-Engineering/arc/issues/190) | Verifiers into `tests/` | Upkeep |

#### 6.2.3 Unexpected

- [#149](https://github.com/Calyx-Engineering/arc/issues/149) rested on `claude plugin eval`, and **the command had never been run**. The measurement was already in the transcripts
- In manual mode, [PR #186](https://github.com/Calyx-Engineering/arc/pull/186), [#187](https://github.com/Calyx-Engineering/arc/pull/187) and [#188](https://github.com/Calyx-Engineering/arc/pull/188) merged **unasked**, hours after [#138](https://github.com/Calyx-Engineering/arc/issues/138) consolidated that rule
- [#138](https://github.com/Calyx-Engineering/arc/issues/138) built only the permitting half of the switch

#### 6.2.4 Unplanned but needed

| | |
|---|---|
| [#189](https://github.com/Calyx-Engineering/arc/issues/189) | `mode-guard` reads the mode before every commit, push, PR and merge. The switch is asymmetric: Claude may set Manual, never Autonomous |
| `CLAUDE.md` | 231 → 141 lines |
| `verify-autonomy.sh` | Inverted — it enforced what was removed |

#### 6.2.5 Evidence

| | |
|---|---|
| `verify-all.sh` | 11 gates, exit 0 |
| `mode-guard` | 14 passed, 0 failed |
| Baseline | `handoff` 0/11 at an opening · `work-watch` 1 in 11 |

#### 6.2.6 Not done

- `plugin eval` regression — [#181](https://github.com/Calyx-Engineering/arc/issues/181), awaiting early access
- `mode-guard` has never fired live — needs a session restart

#### 6.2.7 What it changed

```mermaid
flowchart LR
    A["#138 mode rule<br/>5 statements → 1"] --> M["commit, push, PR and merge<br/>happen when permitted,<br/>and only then"]
    B["#142 delete 13<br/>duplicate skills"] --> M
    N["#189 mode-guard<br/>reads the mode<br/>before each of them"] --> M
    C["#141 miner scope"] --> D["a briefed run reads<br/>only what it was given"]
    G["#149 skill-firing<br/>baseline"] --> H["Fire · 13<br/>Handoff · 6<br/>unblocked"]
    E["#181 plugin eval"]:::blocked -.->|"early access"| I["regression gate"]:::blocked
    classDef blocked fill:#fff3cd,stroke:#e0a800,color:#111
```

*End of Loop's boundary report.*

---

### 6.3 Fire — boundary report

**Workstream:** Fire · **Closed:** 2026-09-08 · **200 words**, diagram excluded

#### 6.3.1 Delivered

1. Openings load `handoff` and `camp`: 0/12 to 0.83
2. Four graders: length, numbering, report shape, environment blame
3. 60-word budgets hold; 20-word do not
4. Three hooks stop misreporting; `branch-guard` gains two checks
5. Every hook logs its firing

#### 6.3.2 Spawned

| | | Routed |
|---|---|---|
| [#208](https://github.com/Calyx-Engineering/arc/issues/208) · [#210](https://github.com/Calyx-Engineering/arc/issues/210) · [#213](https://github.com/Calyx-Engineering/arc/issues/213) | Closed | Fire |
| [#230](https://github.com/Calyx-Engineering/arc/issues/230) · [#231](https://github.com/Calyx-Engineering/arc/issues/231) · [#238](https://github.com/Calyx-Engineering/arc/issues/238) · [#239](https://github.com/Calyx-Engineering/arc/issues/239) | Hook extraction; log volume, rotation | Fire — open, **not sub-issues** |
| [#211](https://github.com/Calyx-Engineering/arc/issues/211) · [#246](https://github.com/Calyx-Engineering/arc/issues/246) | Reload reverts edits; check 8 live | Dogfood — open |
| Unfiled | Eleven *needs an issue* findings | Nowhere |

#### 6.3.3 Unexpected

- Firing and adherence move independently ([#155](https://github.com/Calyx-Engineering/arc/issues/155)), except at 20 words ([#213](https://github.com/Calyx-Engineering/arc/issues/213)). Unresolved
- `createLinkedBranch` succeeds; `linkedBranches` reads 0, four times
- `verify-hook.sh` left `HOOKS_OFF` on once; every hook inert
- [#166](https://github.com/Calyx-Engineering/arc/issues/166) first claimed live firing off fixtures

#### 6.3.4 Unplanned but needed

| | |
|---|---|
| Five instruments | None existed |
| `skill-firing.py` | Miscounted turns |
| Log write cost | 1.4 s per call, now 91 ms |

#### 6.3.5 Evidence

| | |
|---|---|
| `verify-all.sh` | 11 → 38 gates, exit 0 every merge |
| Live here | Exit 1 — local `grep -q` aborts; one gate reads an ignored file |
| Baselines | Opening 1/3 · provenance 1/4 · topics 0/3 · environment `BLAMED` |
| Activation log | 455 live entries today — first soak |

#### 6.3.6 Not done

- *Done when* unmet: [#156](https://github.com/Calyx-Engineering/arc/issues/156), [#159](https://github.com/Calyx-Engineering/arc/issues/159), [#213](https://github.com/Calyx-Engineering/arc/issues/213), [#165](https://github.com/Calyx-Engineering/arc/issues/165)
- Boxes unticked: [#164](https://github.com/Calyx-Engineering/arc/issues/164), [#210](https://github.com/Calyx-Engineering/arc/issues/210), [#166](https://github.com/Calyx-Engineering/arc/issues/166)
- [#160](https://github.com/Calyx-Engineering/arc/issues/160)'s case cannot discriminate
- Everything merged unsoaked
- `TEMPLATE`, `verify-hook.sh` edits proposed only

#### 6.3.7 What it changed

```mermaid
flowchart LR
    A["#155 three shapes<br/>wrapped 2/7"] --> B["#156 #157 #208<br/>openings load<br/>handoff + camp"]
    A --> C["#158 #213 length<br/>#160 numbering<br/>#159 #164 report shape<br/>#165 environment"]
    C --> D["four graders,<br/>baselines measured,<br/>none passing yet"]
    E["#162 #183 #210 #163<br/>hooks read the repo,<br/>the arc, the close"] --> F["#166 every hook<br/>leaves a record"]
    G["#161 branch-guard<br/>worktree + base"] --> F
    H["#181 plugin eval"]:::blocked -.->|"gated"| B
    classDef blocked fill:#fff3cd,stroke:#e0a800,color:#111
```

*End of Fire's boundary report.*

---


### 6.4 Handoff — boundary report

**Workstream:** Handoff · **Closed:** 2026-09-08 · **200 words**, diagram excluded

#### 6.4.1 Delivered

1. Baseline: 8 cold starts, first action 5/8, states why 4/8
2. Decisions carry what would have to change; a swap trigger
3. `handoff-archive` copies what git cannot restore
4. Title re-stamped every write
5. `work-watch` check 7: self-saturation, 52-turn eval
6. `session-index` commits transcript locations for the miner

#### 6.4.2 Spawned

| | | Routed |
| --- | --- | --- |
| [#243](https://github.com/Calyx-Engineering/arc/issues/243) | Saturation probe | Dogfood — open, **not a sub-issue** |
| Unfiled | Undelivered handoff; false claims; re-score unrouted | Handoff |
| Unfiled | Bash overwrites unarchived; 147 ms tax; `SessionStart` variant | Handoff — needs the user |
| Unfiled | Hooks carry issue numbers, not mechanism ids | Product architecture |

#### 6.4.3 Unexpected

- Rationale-stripping: 2 of 5 bad openings, and a written rule
- Both criteria together invert the recalled split
- Two handoffs last edited by Copilot Chat
- 17 orphaned transcript directories; m32 said 2
- Pass 2 caught two silent disables

#### 6.4.4 Unplanned but needed

| | |
| --- | --- |
| `Bash` matcher, both hooks | Shell overwrites skip edit tools |
| `templates/dev-log.md` | Exclusions need a reason |
| `verify-all.sh` | Fails on an unknown gate |

#### 6.4.5 Evidence

| | |
| --- | --- |
| `verify-all.sh` | 20 → 41 gates, exit 0 |
| `verify-handoff-rationale.sh` | 5 failed before, green after |
| Saturation baseline | `SILENT`, 52 turns |
| Mutation test | 9 deleted, 9 caught |

#### 6.4.6 Not done

- [#146](https://github.com/Calyx-Engineering/arc/issues/146)'s *Done when*: no score moved; the live re-run is unrouted
- [#154](https://github.com/Calyx-Engineering/arc/issues/154) box 2: check 7 never seen firing
- Openings 1, 2 out of reach
- Nothing soaked live
- Backfilling the 17

#### 6.4.7 What it changed

```mermaid
flowchart LR
    A["#150 baseline<br/>5/8 · 4/8"] --> B["#151 constraint column,<br/>Why here, swap trigger"]
    C["#152 handoff-archive"] --> D["#153 re-stamp gate<br/>needs the archived copy"]
    E["#154 work-watch check 7"] --> F["#243 probe run"]:::blocked
    G["#16 session-index"] --> H["transcript-miner<br/>reads the index"]
    I["#181 plugin eval"]:::blocked -.->|"re-score unrouted"| B
    classDef blocked fill:#fff3cd,stroke:#e0a800,color:#111
```

*End of Handoff's boundary report.*

---

## 7 Related analysis

- [`friction-log.md`](https://github.com/Lantern-Systems/roadz-sound-system/blob/main/docs/arc-work/interface-pcba-rev-b/friction-log.md) — ROADZ's hand-written log, 296 lines, the higher-signal half of the evidence
- `docs/retrospectives/2026-09-dogfood/` — **owed.** The frozen friction log for this run, written at interview time

## 8 Future capabilities — designed for, not in scope

| | |
|---|---|
| **The knowledge filter** | m30's other half. The miner ships friction mode only; m30 stays `partial`. Its open question — whether both filters can share extraction — is untouched |
| **`agents/improver`, `hooks/mining-trigger`** | m31 and m19. The miner is built to be called by them; neither exists |
| **Two-agent split** | m30 suggests mid-tier for extraction, top for clustering. One agent for now — splitting adds a handoff before there is evidence the cost matters |

## 9 At arc close

- [ ] Status table reflects reality
- [ ] Tree regenerated
- [ ] The retrospective's friction log written and **frozen** under `docs/retrospectives/2026-09-dogfood/`
- [ ] Cluster counts recorded, so the next run can measure which mechanisms repaid
- [ ] Unbuilt clusters filed as issues outside this milestone, not lost with the session
- [ ] K2 and K3 swept
- [ ] **Milestone closed by hand.** GitHub does not close it when its last issue closes
- [ ] **The execution process graduates, or is deleted with a reason.** [`execution-process.md`](../arc-work/04-dogfood/execution-process.md) §8 carries the table: the run kinds, queue and driver to **m25**; `mode-guard` and the asymmetry to **m40**; the boundary sequence and report shape to m20 or m43, undecided; `skill-firing` to m33's territory, undecided. **It graduates on §7 being shorter, not on the document existing**
- [ ] **Default branch restored** — `tools/arc-default-branch.sh restore`. **It was flipped to `arc/04-dogfood` on 2026-09-05 and must be pointed back at `main`.** A crashed session leaves it on a branch that may later be deleted, and nothing about that state is visible in ordinary work

## 10 Soak

**Per `CLAUDE.md`: a plugin change runs against real work before it leaves the machine.**
Committed is not exercised. Unsoaked means a commit here with no soak line from any repo.

| Change | Soaked on | Result |
|---|---|---|
| `tools/plugin-reload.sh` ([#132](https://github.com/Calyx-Engineering/arc/issues/132)) | Its own test, then nothing since | **Partially soaked.** The uninstall-plus-reinstall pair was verified by marker on a real skill and reverted. **The claim it exists to serve — that a plugin fix can be exercised in the repo that hit the friction — is untested**, because no fix has been reloaded into ROADZ yet |
| `agents/transcript-miner` ([#17](https://github.com/Calyx-Engineering/arc/issues/17)) | **This arc's own extraction**, 68 MB, 19 files, before it was registered | **Fired correctly, and the soak paid for itself.** Three defects surfaced from the run and were fixed before merge: curated transcript saves were not read at all, intensity markers were invisible to the filter, and quotes carried no locator. **None was visible from reading the agent** |
| `agents/transcript-miner` — the ranked table and `Proposed mechanism` column | — | **Unsoaked.** Added after the run, in response to a re-read of [#17](https://github.com/Calyx-Engineering/arc/issues/17)'s checklist. The next mining run is its first exercise |
| `agents/transcript-miner` — pass B, intensity markers | — | **Unsoaked, and marked so in the file.** Reasoned from the corpus, not measured. The agent reports pass A and pass B counts separately so the next run produces the evidence to keep, tune or drop it |
| `hooks/camp-branch-check` · `hooks/tracker-verify` | **A live session, for the first time in three arcs** | **Both fired.** `camp-branch-check` on `arc/04-dogfood`'s creation, `tracker-verify` on every `gh pr create`. This closes `pre-release-review.md` §2.2's *a hook fires* row, which no gate here could establish. **One false report each:** `tracker-verify` asked for an explanation the PR body already carried, and fired on `verify-tracker-body.sh`, which is not a tracker write |
| `skills/issue-write` — titles, bodies, spawn edges | Six issues written this arc | **Fired correctly where it was run, and did not fire on its own.** Every title passed `verify-tracker-body.sh title`. **The spawn edge was missed on [#134](https://github.com/Calyx-Engineering/arc/issues/134) until the user caught it** — which is [#83](https://github.com/Calyx-Engineering/arc/issues/83), unbuilt, and evidence for it |
| `docs/product-architecture/close-sequence.md` — the nine steps | Two issues closed this arc | **Two steps were missed on both units.** Step 3, the arc-log status row — this file did not exist until [#17](https://github.com/Calyx-Engineering/arc/issues/17) had already merged. Step 7, the soak line — same. **A sequence nothing fires is a sequence that gets skipped**, which is C7's shape applied to the close sequence itself |
| `docs/product-architecture/close-sequence.md` — step 5, the read-back ([#140](https://github.com/Calyx-Engineering/arc/issues/140)) | **Its own unit**, three dispatches before its PR | **Fired, and found what the session could not.** 12 findings on pass 1, 16 on pass 2, and two contradictions left by pass 2's own fixes on pass 3. One was load-bearing: the constraint says the step is *confirmed in the PR body*, and `skills/issue-write` had no section for it — the step was unsatisfiable as first implemented. **None of the three passes was visible to the session from re-reading its own files** |
| `skills/camp` — the `description:` rewrite ([#156](https://github.com/Calyx-Engineering/arc/issues/156)) | — | **Unsoaked, and unsoakable here.** The change is a trigger clause, so the only thing that exercises it is a real session opening that wraps Camp's name in an instruction. No gate in this repository invokes a skill, and `claude plugin eval` is gated ([#181](https://github.com/Calyx-Engineering/arc/issues/181)). **The next opening of this kind is its first exercise** — and the two prompts in `evals/skill-firing/wrapped/` say exactly what one looks like |
| `hooks/lib/activation-log` and all six hooks ([#166](https://github.com/Calyx-Engineering/arc/issues/166)) | — | **Unsoaked, and it cannot be soaked from inside its own run.** The installed plugin is the main tree, which does not carry the library, and `tools/plugin-reload.sh` says a running session does not pick up a reload — so no hook has fired in a real session with this code. Everything asserted is the harness: 37 gates clean, 392 assertions over 115 cases, and a selftest that proves the gate can fail. **The next work stretch in this repo is its first exercise**, and the thing to read is whether `.claude/arc/log.md` fills with entries carrying real commands and file paths rather than fixtures — which is exactly the distinction the first version of this library got wrong |
| `hooks/lib/activation-log` — first exercise | **[#165](https://github.com/Calyx-Engineering/arc/issues/165)'s run**, one `claude -p` session | **All six hooks fired, and the entries are real.** 1,285 activations in one issue run: `handoff-archive` 335, `mode-guard` 294, `tracker-verify` 287, `camp-branch-check` 287, `camp-session-start` 41, `branch-guard` 41. Every one carries its `checked:` / `outcome:` / `skipped:` lines against a real command — the fixture-versus-real distinction #166 asked to be read holds. **Two findings.** The volume is the story: ~5,000 lines from one issue, and the run's first commit swept them into the review diff because `git add -u` picked the file up. And `tracker-verify` was the only hook whose output a human acted on — it caught PR #248's missing `arc-04:` title prefix, which no gate here checks. **The bulk of it was taken back out of the PR** — a machine record is not review surface — and it cannot be taken out entirely: the hooks fire on the `git add` and `git commit` that would remove it, so 26 lines came back with the removal. Chasing zero is a race against the thing being measured |
| `hooks/session-index` ([#16](https://github.com/Calyx-Engineering/arc/issues/16)) | **Its own run**, as a program against this worktree | **Soaked as a program, not as a hook, and the difference matters here.** It was run with this session's real `session_id` and `transcript_path` and wrote the first real row — `R--arc-wt-16` on `arc/04-dogfood-issue-16-session-index`, `#16`, `live` — with `.claude/arc/log.md` carrying the matching `session-indexed` entry, and re-firing left the file at one row. What it did **not** get is a live firing: the installed plugin is the main tree, and `tools/plugin-reload.sh` would have swapped the plugin under the five worktrees running concurrently. **Two findings.** The review passes found a guard that would have stopped the mechanism permanently and silently — it counted only the rows a rewrite touched, so any index holding a row for another live worktree looked like a loss — and every existing case stayed green because each fixture had one row. And the first regression case written for it was itself vacuous, because a *blocked* write leaves the row count exactly as unchanged as a correct one does. **The next work stretch in this repo is its first live exercise**, and the thing to read is whether `.claude/arc/sessions.md` gains a row per worktree without anyone asking |
| `skills/work-watch` check 8 ([#165](https://github.com/Calyx-Engineering/arc/issues/165)) | — | **Unsoaked, and it cannot be soaked in this repository.** The check gates a diagnosis about a user's *instrument*, and nothing here has one. `evals/environment-blame/` reads the session the check was written from and reports `BLAMED` — the defect, not the fix — and it carries no probe, because a replayed session sits in front of no bench. **The first exercise is a live instrument session**, filed as [#246](https://github.com/Calyx-Engineering/arc/issues/246), and the thing to read is whether the reply that names the bench also names what it ran first |
| `hooks/mode-guard` — the script-declaration half ([#201](https://github.com/Calyx-Engineering/arc/issues/201)) | **Its own unit**, four review passes | **Fired, and every pass found a defect the one before it introduced.** Pass 1: the read-only exemption matched the whole payload, so a real dispatch was allowed by a `--dry-run` in the description Claude wrote itself, and quoted reads were denied. Pass 2, on pass 1's fixes: the same class in a new shape — one script named twice, the first invocation's `--dry-run` exempting the second. Pass 4, as a reviewer: a payload carries a newline as `\n`, so **every line after the first was glued to its predecessor and never read as a command** — which is most of the surface the issue set out to close. **None of the four was visible from re-reading the hook** |
| `tools/verify-issue-boxes.sh` and `hooks/tracker-verify`'s `gh pr ready` check ([#199](https://github.com/Calyx-Engineering/arc/issues/199)) | **The tool: its own unit, live.** **The hook: this PR's own `gh pr ready`, and it did not fire** | **Split result, and the second half is the useful one.** The tool read #140, #194 and #199 as real issues over the real GraphQL reads the selftest can only fixture — and `--pr 251` resolved both this PR's issues through its own closing keywords, which is the arc case the first draft got wrong. **The hook did not fire at all.** `gh pr ready 251` produced a `tracker-verify` entry reading `outcome: ok — not a tracker write`, with the old thirteen-check `skipped:` line — the installed plugin is the main tree, so the copy that ran is the one without this change. That is [#166](https://github.com/Calyx-Engineering/arc/issues/166)'s row restated as a measurement rather than a prediction: **a hook change cannot be soaked by the run that makes it**, and the next session in this repo is `issue-boxes`' first exercise |
| `hooks/tracker-verify`'s `spawn-parent` check ([#83](https://github.com/Calyx-Engineering/arc/issues/83)) | **Its own build** — the case was written against [m46 §9](../product-architecture/mechanisms/m46-work-navigation.md)'s own example branch name | **The build found a live defect in a neighbouring check.** `pr-base`'s guard was `arc/*-issue-*`, which matches the literal `-issue-` in `arc/03-camp-pr75-no-issue-pr` — the shape `tools/new-direct-pr.sh` produces — so a correctly based no-issue PR was reported as misbased. Fixed here. **The hook half is otherwise unsoaked, and this run measured why.** `gh pr ready` on this unit's own PR produced a `tracker-verify` entry reading `not a tracker write` — the installed copy is the main tree's, without this change. The next session in this repo is `spawn-parent`'s first exercise |
| `hooks/branch-guard` — the coordination prefix read from the agreement ([#203](https://github.com/Calyx-Engineering/arc/issues/203)) | — | **Unsoaked, and not soakable from inside its own run.** The hook fires from the installed plugin copy, current only after `tools/plugin-reload.sh`, and five runs were working in parallel worktrees off this base — reloading from one of them would change what the other four are running under. Everything asserted is the harness: 39 gates clean, and a new `tools/verify-branch-prefix.sh` at 17 cases whose decisive one fails when its guard is removed. **The next work stretch in this repo is its first exercise**, and the thing to read is whether `.claude/arc/log.md` carries `prefix=` on its `edit-checked` entries — no entry in the tree does yet |
| `hooks/tracker-verify` — the milestone check, both directions ([#204](https://github.com/Calyx-Engineering/arc/issues/204)) | — | **Unsoaked, and not soakable from inside its own run.** The hook fires from the installed plugin copy, current only after `tools/plugin-reload.sh`, and other runs are working in parallel worktrees off this base. `gh pr ready` on this unit's own PR runs the main tree's copy, without this change. **The harness could not reach the defects either:** every hook case takes the fixture path, so all four of this unit's review-pass findings were in the live `gh pr view` field extraction — a `MILESTONE` that could only ever print `set`, a `sed` that handed back a neighbour's title when the field was absent, a multi-line `TITLE` that let a PR missing its `arc-04:` prefix pass on a neighbour's, and a `BODY` terminator that never matched because `gh` sorts its fields. The last two predate this change and had been silently mis-answering `arc-prefix` and `closing-keyword`. Asserted instead by five live probes against PRs #245 and #249, and 43 gates clean. **The next work stretch in this repo is its first exercise**, and the thing to read is whether `.claude/arc/log.md` carries `milestone=Dogfood` — a name — rather than `milestone=set` |
| `tools/arc-claim.sh` and `tools/arc-loop.sh`'s claim wiring ([#214](https://github.com/Calyx-Engineering/arc/issues/214)) | **The tool: live, on #214 and #134.** **The wiring: not at all** | **Split, and the live half found the defect the harness could not.** `take`, `check`, `claimed`, `refresh` and `release` were run against the real tracker: a second dispatcher was refused, `release` left both issues with zero comments, and `arc-loop.sh 148 --dry-run` skipped a claimed #134 and selected #198 instead. That live read is what surfaced the bug — `read_comments` ended `printf '%s'`, so command substitution stripped the trailing newline and `while read` dropped the **last** comment, which is the only one a race turns on. A live #214 holding exactly one claim read as `free` while 40 fixture cases were green, because the fixture's `sort` re-terminated its output. **The wiring is unsoaked and unsoakable from inside this run:** `--dry-run` returns before `run_batch`'s claim block, so `take_claim`, `reclaim_claim`, the heartbeat, the per-issue release and all three traps have executed only as source-text checks. **The next `tools/arc-loop.sh` dispatch from the main tree is their first exercise**, and the thing to read is whether a claim comment appears on the dispatched issue and is gone when the run ends |
| `hooks/tracker-verify` — `merge-close`, and `tools/arc-link-sweep.sh` ([#136](https://github.com/Calyx-Engineering/arc/issues/136)) | **The sweep on the live Dogfood milestone**, 2026-09-09. The hook check on its own cases only | **The sweep is soaked and paid for itself; the hook check is not.** The sweep read 102 issues across three pages and found **47 linked to nothing at all** — the number m12 §4 row 4 existed to produce and nobody had — which also exercised the pagination the selftest cannot reach. `merge-close` has fired on no real merge: this PR's own merge into `arc/04-dogfood` is its first, and what to read there is whether it names #136 and stays silent on the arc PR. Its first draft was wrong in the way only a live flipped repo would show — it skipped on the trunk alone, so under m42's flip it would have run on every work PR and reported that a keyword cannot bind on a base that is the default. Pass 1 caught that on the cases, not in the wild |
| `hooks/branch-guard` — the no-repository exemption ([#272](https://github.com/Calyx-Engineering/arc/issues/272)) | — | **Unsoaked, and not soakable from inside its own run**, for the reason [#203](https://github.com/Calyx-Engineering/arc/issues/203)'s row above gives for the same hook: it fires from the installed plugin copy, current only after `tools/plugin-reload.sh`, and parallel runs are working off this base. **The defect itself is the soak evidence.** It was not found by a gate — it was hit in a live session, as a denied `Write` to a scratchpad `.py`, which is what four arcs of cases never produced. Asserted here by the harness: 52 gates clean, `verify-hook.sh` 19 cases and `verify-activation-log.sh` 69, with the new case the only one in the directory that flips against the base. **The next work stretch in this repo is its first exercise**, and the thing to read is whether `.claude/arc/log.md` carries `outcome: ok — the path is in no repository` on a real out-of-tree write rather than only on a fixture |

> **The miner's row is the first soak in this repository where the exercise found defects the
> author could not see by reading.** That is what the soak rule is for, and it is the first
> time it has done it.
