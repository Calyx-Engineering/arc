# Arc 04 playlist — what runs together, what runs alongside

## 1 Terms

| | |
|---|---|
| **Track** | One run: one worktree, one branch, one PR, one or more issues sharing a deliverable. `tools/arc-loop.sh <ws> --issues a,b --track S2.F4` |
| **Set** | Tracks dispatched concurrently. A set closes when every track's PR is merged |
| **Playlist** | Ordered sets, per workstream, plus which workstreams may overlap |

## 2 What shapes it

| Constraint | Effect on the playlist |
|---|---|
| Two issues edit one file | Same track, or different sets. Never two tracks in one set |
| `Blocked by #NN` | A later set than the blocker's |
| **The installed plugin is one machine-wide cache** — `plugin-reload.sh` then `skill-probe.sh` / `response-length.sh --probe` | At most **one probe track per set**. Two runs reloading the cache measure each other's edits. Since #211 the reload also refuses on a dirty tree, naming what it would install — commit first, or `--force` |
| [#190](https://github.com/Calyx-Engineering/arc/issues/190) moves every verifier and case directory into `tests/` | Runs alone, last, nothing else in flight — its own constraint |
| One merge target, `arc/04-dogfood` | Orchestrator merges, one PR at a time, each rebased on the arc tip first |
| **Cap: 5 tracks per set** | Wall time is the constraint the user named. The ceiling is the usage window, not the graph — a limit-hit run is resumed by `arc-loop.sh`, not lost |

## 3 Tracks, by workstream

### 3.1 Fire — [#145](https://github.com/Calyx-Engineering/arc/issues/145)

Merged: [#155](https://github.com/Calyx-Engineering/arc/issues/155) · [#156](https://github.com/Calyx-Engineering/arc/issues/156) · [#157](https://github.com/Calyx-Engineering/arc/issues/157) · [#158](https://github.com/Calyx-Engineering/arc/issues/158)

| Track | Issues | Edits | Probe | Set |
|---|---|---|---|---|
| **F1 tracker-verify** | [#183](https://github.com/Calyx-Engineering/arc/issues/183) [#210](https://github.com/Calyx-Engineering/arc/issues/210) [#163](https://github.com/Calyx-Engineering/arc/issues/163) | `hooks/tracker-verify`, its cases, `verify-all.sh` | — | **S1** — running now as #183+#210. #163 is **F1b**, in S3 |
| **F2 camp-branch-check** | [#162](https://github.com/Calyx-Engineering/arc/issues/162) | `hooks/camp-branch-check`, its cases | — | **S1** |
| **F3 chat-response** | [#160](https://github.com/Calyx-Engineering/arc/issues/160) [#213](https://github.com/Calyx-Engineering/arc/issues/213) | `skills/chat-response`, `evals/response-length` | probe | **S1** — the set's probe slot |
| **F4 branch-guard** | [#161](https://github.com/Calyx-Engineering/arc/issues/161) | `hooks/branch-guard`, its cases, `verify-all.sh` | — | **S2** — `verify-all.sh` keeps it out of S1 with F1 |
| **F5 engineering-report** | [#159](https://github.com/Calyx-Engineering/arc/issues/159) [#164](https://github.com/Calyx-Engineering/arc/issues/164) | `skills/engineering-report`, `skills/record-route` | probe | **S2** — probe slot |
| **F6 handoff** | [#208](https://github.com/Calyx-Engineering/arc/issues/208) | `skills/handoff`, `commands/arc-next.md` | — | **S2** |
| **F7 activation log** | [#166](https://github.com/Calyx-Engineering/arc/issues/166) | **every hook** | — | **S4**, the only hook track in its set. Blocked by #163; touches what F1 F2 F4 touch |
| **F8 work-watch** | [#165](https://github.com/Calyx-Engineering/arc/issues/165) | `skills/work-watch` | probe | **S5**. Blocked by [#154](https://github.com/Calyx-Engineering/arc/issues/154), Handoff's H3, which runs in S4 |

**Why not the brief's #162+#183+#210:** #162 is a different hook in a different file. #163 edits `tracker-verify` too and was unscoped when the brief was written.

### 3.2 Handoff — [#146](https://github.com/Calyx-Engineering/arc/issues/146)

| Track | Issues | Edits | Probe | After |
|---|---|---|---|---|
| **H1 baseline** | [#150](https://github.com/Calyx-Engineering/arc/issues/150) | a report under `docs/`; sub-agent reads transcripts | — | Nothing. Docs only — can run beside anything |
| **H2 the handoff document** | [#151](https://github.com/Calyx-Engineering/arc/issues/151) [#152](https://github.com/Calyx-Engineering/arc/issues/152) [#153](https://github.com/Calyx-Engineering/arc/issues/153) | `skills/handoff`, `templates/handoff.md` | — | H1 (#151 is blocked by #150) and Fire's F6 (#208, same skill) |
| **H3 saturation check** | [#154](https://github.com/Calyx-Engineering/arc/issues/154) | `skills/work-watch` | probe | Nothing. Unblocks Fire's F8 — same file, same check count; F8 runs in the set after |
| **H4 session index** | [#16](https://github.com/Calyx-Engineering/arc/issues/16) | new `hooks/session-index`, `hooks.json`, `agents/transcript-miner` | — | Fire's F7 (#166 instruments every hook) |
| **H5 handoff, live** | [#252](https://github.com/Calyx-Engineering/arc/issues/252) [#253](https://github.com/Calyx-Engineering/arc/issues/253) | probe run on the eight openings; a scored live cold start on a real `HANDOFF.md` | probe | H2, F6. Filed after Handoff's boundary report: *no score moved, nothing soaked live* |

### 3.3 Tracker — [#147](https://github.com/Calyx-Engineering/arc/issues/147)

| Track | Issues | Edits | Probe | After |
|---|---|---|---|---|
| **T1 read-back step** | [#140](https://github.com/Calyx-Engineering/arc/issues/140) | `docs/product-architecture/close-sequence.md` | — | Nothing. Before T2 — #199 narrows #140's constraint |
| **T2 tracker-verify II** | [#199](https://github.com/Calyx-Engineering/arc/issues/199) [#83](https://github.com/Calyx-Engineering/arc/issues/83) | `hooks/tracker-verify`, new `tests/verify-issue-boxes.sh`, `verify-all.sh` | — | Fire's F1 and T1 |
| **T3 issue-write rules** | [#87](https://github.com/Calyx-Engineering/arc/issues/87) [#135](https://github.com/Calyx-Engineering/arc/issues/135) [#193](https://github.com/Calyx-Engineering/arc/issues/193) | `skills/issue-write`, `verify-tracker-body.sh`, `tests/tracker-cases/` | probe (#135's m13 case) | Nothing |
| **T4 issue shape** | [#84](https://github.com/Calyx-Engineering/arc/issues/84) [#85](https://github.com/Calyx-Engineering/arc/issues/85) | `skills/issue-write`, new `templates/issue.md`, GitHub labels | — | T3 (same skill) |
| **T5 manual linking** | [#136](https://github.com/Calyx-Engineering/arc/issues/136) | `m12`, `skills/issue-write`, `hooks/tracker-verify` | — | T2, T4. **Low priority — the issue says it may leave the arc** |

### 3.4 Upkeep — [#148](https://github.com/Calyx-Engineering/arc/issues/148)

| Track | Issues | Edits | Probe | After |
|---|---|---|---|---|
| **U1 branch link read-back** | [#206](https://github.com/Calyx-Engineering/arc/issues/206) | `run-instructions.md` §4, `m12`, `new-direct-pr.sh` | — | Nothing. **Early** — every run's branch↔issue link depends on it |
| **U2 verifiers I** | [#143](https://github.com/Calyx-Engineering/arc/issues/143) [#167](https://github.com/Calyx-Engineering/arc/issues/167) [#168](https://github.com/Calyx-Engineering/arc/issues/168) | three new `tests/verify-*.sh`, `verify-all.sh`, `templates/dev-log.md` | — | Not beside another `verify-all.sh` track |
| **U3 verifiers II** | [#185](https://github.com/Calyx-Engineering/arc/issues/185) [#198](https://github.com/Calyx-Engineering/arc/issues/198) | `verify-report-budget.sh`, `set-mode.py` selftest, `verify-all.sh`, a `mode-guard` case | — | U2 |
| **U4 shadow commands** | [#177](https://github.com/Calyx-Engineering/arc/issues/177) | `.claude/commands/`, `verify-skill-registry.sh` | — | Nothing |
| **U5 mode-guard scripts** | [#201](https://github.com/Calyx-Engineering/arc/issues/201) | `hooks/mode-guard`, its cases | — | Fire's F7 |
| **U6 branch-guard prefix** | [#203](https://github.com/Calyx-Engineering/arc/issues/203) | `hooks/branch-guard`, the operating agreement | — | Fire's F4 and F7 |
| **U7 milestone rule** | [#204](https://github.com/Calyx-Engineering/arc/issues/204) | `hooks/tracker-verify`, `skills/issue-write`, ten PRs' milestones | — | T2, T4 |
| **U8 verbosity setting** | [#174](https://github.com/Calyx-Engineering/arc/issues/174) | operating agreement, `skills/chat-response` | probe | Fire's F3 |
| **Human** | [#134](https://github.com/Calyx-Engineering/arc/issues/134) [#175](https://github.com/Calyx-Engineering/arc/issues/175) [#202](https://github.com/Calyx-Engineering/arc/issues/202) | Decisions (#134, #175); `hooks/TEMPLATE` is never edited autonomously (#202) | — | David at the keyboard, any time. #202 after U6 |
| **U10 plugin reload** | [#211](https://github.com/Calyx-Engineering/arc/issues/211) | `tools/plugin-reload.sh` | — | Nothing. Not beside a probe track |
| **U11 one run per issue** | [#214](https://github.com/Calyx-Engineering/arc/issues/214) | `tools/arc-loop.sh` — refuse an `in-progress` issue | — | Nothing |
| **U9 move to `tests/`** | [#190](https://github.com/Calyx-Engineering/arc/issues/190) | every verifier, every case directory, every citation | — | **Everything. Alone. Last.** `verify-hook.sh`'s move is a proposal to David |

## 4 The sets — whole arc, in order

Workstreams are **not** the parallel unit; the track is. Each set mixes workstreams where the files allow. Five tracks, at most one probe.

| Set | Tracks | Workstreams | Probe slot |
|---|---|---|---|
| **S1** (running) | F1 · F2 · F3 | Fire | F3 |
| **S2** | F4 · F5 · F6 · T1 · U1 | Fire · Tracker · Upkeep | F5 |
| **S3** | F1b (#163) · H1 · T3 · U2 · U4 | Fire · Handoff · Tracker · Upkeep | T3 |
| **S4** | F7 (the only hook track) · H2 · H3 · T4 | Fire · Handoff · Tracker | H3 |
| **S5** | F8 · T2 · H4 · U5 · U6 | Fire · Tracker · Handoff · Upkeep | F8 |
| **S6** | U7 · U3 · U8 · U11 | Upkeep | U8 |
| **S7** | H5 · U10 · T5 · human (#134 #175 #202) | Handoff · Upkeep · Tracker | H5 |
| **S8** | U9 alone | Upkeep | — |

```mermaid
flowchart LR
  S1 --> S2 --> S3 --> S4 --> S5 --> S6 --> S7 --> S8
  S5 -.-> RF["Fire report"]
  S7 -.-> RH["Handoff report"]
  S7 -.-> RT["Tracker report"]
  S8 -.-> RU["Upkeep report"]
```

A workstream's report run fires when its last child closes — Fire after S5, Handoff and Tracker after S7, Upkeep after S8. The boundary is a review, not a scheduling unit.

**Eight sets at ~45 min if the sub-agent passes hold: a working day of wall time, against thirty-plus serial runs.**

## 5 The orchestrator's loop

| | |
|---|---|
| 1 | Take the next set. For each track, `tools/arc-loop.sh <ws> --issues … --track S2.F4` in the background; `--status` shows them. The track label is the session's title — `arc/04 — S2.F4 · #161` |
| 2 | On a track's exit: read the usage summary. PR ready → rebase on the arc tip, merge, confirm the issues closed. Not ready → read `.arc-work/runs/<id>/err.log`, decide: relaunch, hand to a human, or park |
| 3 | A worktree left behind is evidence; read it before `git worktree remove --force` |
| 4 | Append the run's usage line to the arc-log — the soak record |
| 5 | Set closed → next set, without asking. A workstream's last child closed → its report run, `tools/arc-loop.sh <ws>` — and stop there: the boundary report is the review, and the next set waits for the yes that follows it |

David's input: this document, a yes per workstream boundary, and the report at each.
