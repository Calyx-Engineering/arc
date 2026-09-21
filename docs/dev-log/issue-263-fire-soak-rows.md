# Issue #263 — soak lines for Fire's merged changes

> Dev-log, not a spec.

**Issue:** [#263](https://github.com/Calyx-Engineering/arc/issues/263)  ·  **Parent:** [#145](https://github.com/Calyx-Engineering/arc/issues/145) — Fire

## What a Fire merge is, and how the set was fixed

Fifteen merges closed Fire's eighteen closed sub-issues. The set was read from the tracker,
not from the issue plan or the boundary report: for each sub-issue, the `ClosedEvent`'s `closer`
and its `mergeCommit`.

| PR | Closes | PR | Closes |
|---|---|---|---|
| 205 | #155 | 221 | #161 |
| 207 | #156 | 224 | #159 · #164 |
| 209 | #157 | 232 | #163 |
| 212 | #158 | 244 | #166 |
| 216 | #183 · #210 | 248 | #165 |
| 217 | #162 | 291 | #265 |
| 218 | #160 · #213 | 220 | #208 |
| 295 | #264 | | |

**Three already had rows** — #156, #165 and #166, the last with two. Each states its own status in
its own words, so none is a neighbour's row reused and none was rewritten. **Twelve rows were
added**, one per remaining merge.

[#265](https://github.com/Calyx-Engineering/arc/issues/265) merged on 2026-09-09, after Fire's
boundary report closed. It is a Fire sub-issue and a Fire merge, so it gets a row; leaving it out
would have left a merge with none, which is what the issue's second box forbids.

**A fifteenth merge landed mid-run.** [#264](https://github.com/Calyx-Engineering/arc/issues/264)
closed at `2026-09-09T09:59Z`, between the tracker read that fixed the set and this branch's merge
of the base. It gets a row too, and the row says what is true of it: PR #295 merged five files and
none of them runs — a dev-log correction, a new dev-log and a proposal — so there is nothing to
exercise. `tools/verify-hook.sh` was not changed. The set was re-read rather than assumed, which is
the only reason it was caught.

## The check

`#263` names no gate, so one was written before the rows and run against the tree — red first:

```text
FAIL  PR 205 (closes 155) — no row in §10
...
ok    PR 244 — #166(2)
ok    PR 248 — #165(2)
FAILED
```

Eleven merges with no row, three covered. After the rows: `PASS  every Fire merge has a row`,
exit 0. It reads §10 only, so a number cited in §6.3's boundary report does not satisfy it. It
lives in the scratchpad rather than `tools/` — a Fire-merge list is a one-issue assertion, not a
standing gate, and the issue names no artifact to add.

## Where the evidence came from

| Source | What it settles |
|---|---|
| `.claude/arc/log.md` at `arc/04-dogfood` `801b8be` | Every hook figure. One `awk` pass classifying each line by the entry above it, so the parts sum: 10,159 entries — `handoff-archive` 2,150, `mode-guard` 1,878, `camp-branch-check` 1,852, `tracker-verify` 1,844, `session-index` 1,842, `branch-guard` 299, `camp-session-start` 291, `issue-write` 3 |
| `git merge-base --is-ancestor` against `arc/04-dogfood-issue-145-fire-review` | Whether the **installed** copy carries a change. The main tree is the installed plugin, so a hook merge inside that branch is a hook merge that fired |
| `docs/dev-log/issue-253-live-cold-start.md` and the reader transcript | The one live cold start — the only live exercise any Fire *skill* has had |
| `docs/dev-log/issue-265-shared-case-reader.md` | The four graders' scores, run twice in two trees |
| `docs/dev-log/issue-160-*.md`, `issue-213-*.md` | Twenty-two billed probe runs and what they cost |

**The containment check is what makes the hook rows soaks rather than predictions.** Four §10 rows
above these say a hook change *cannot* be soaked by the run that makes it, because the installed
copy is the main tree without the change. That is still true of [#204](https://github.com/Calyx-Engineering/arc/issues/204)
and [#136](https://github.com/Calyx-Engineering/arc/issues/136). It is **not** true of Fire's five
hook merges: all five are ancestors of the main tree's checked-out branch, and all five landed
before the first of the 1,844 entries. So those firings ran that code.

## What the exercise found

Four Fire merges have been exercised hard enough to produce a defect, and the defects are the
answer to the issue's *what was seen*:

| Merge | What the exercise found |
|---|---|
| #161 `branch-guard` | **Ten real denials** at 1, 4, 5, 6, 7 and 12 commits behind — the only Fire check that has stopped work. And one false denial: a `Write` to a path in **no repository at all**, because `path-is-source` denies before the worktree check can exempt it ([#272](https://github.com/Calyx-Engineering/arc/issues/272)) |
| #158 response-length | Two probe runs came back with every turn `CUT` on a rate limit, one at $0.000. **The scorer refused both** — the `CUT` rule doing its job. Nothing warned and nothing retried ([#269](https://github.com/Calyx-Engineering/arc/issues/269)) |
| #208 staleness checks | All seven ran and **all seven passed**; both findings are in what they assume. The stamp was not re-stamped on the last write, and `find -newer HANDOFF.md` trips on the writing session's own live transcript |
| #163 issue-close arm | The event exists in the record where nothing fired before, and the check inside it still has not run. Reviewing it found the two extraction defects that silence **every** arm ([#230](https://github.com/Calyx-Engineering/arc/issues/230), [#231](https://github.com/Calyx-Engineering/arc/issues/231)) |

**The single hardest reading is #157's.** The eval scores an opening that loads *handoff and camp*
at 0.83. At the one live opening, `arc:handoff` was the first tool call and **`arc:camp` never
fired at all** — verified by listing every `Skill` call in session `d8fadd56`'s transcript, not by
reading the log, which records no skill.

## The review passes, and what they cost

**Every pass found defects the pass before it introduced**, and all of them were in the figures
rather than the prose.

| Pass | Found |
|---|---|
| 1 | The rows drew a contrast with "the four hook rows above" that the same evidence disproves — the installed copy carries #83, #199 and #203 as well. Live counts with no as-of stamp. A ratio whose numerator counted `outcome:` lines and whose denominator counted entry headers, so it could not divide |
| 2 | Pass 1's fixes introduced four positional references that were off by two, thirteen and two rows; named `branch-kind` for a deny that `path-is-source` emits; called 1,844 and 1,852 "the same count"; and claimed #157 removed the clause #156 shipped, which still ships |
| 3 | The disclaimer pass 1 asked for was **backwards**. #165's run's 1,285 activations are not inside the 1,844 — PR 248 merged with **ten** entries in the file, the bulk having been taken back out. The suite is 18 cases, not 17; 17 is the `opening: true` subset |

**None of the three was visible from re-reading the rows.** Each needed the log re-counted, the
dev-logs re-read, or `git merge-base` run.

## Out of scope, and done anyway

**One three-line paragraph after `*End of Fire's boundary report.*`.** §6.3.6 reads *Everything
merged unsoaked*; §10 now says otherwise for every Fire merge, and a reader landing on §6.3.6 had
nothing pointing forward. The frozen report is untouched — the note sits after its `*End of …*`
line, which is where `tests/verify-report-budget.sh` stops counting, and Fire still measures 186
words against a budget of 200.

## Findings about Arc, filed nowhere

Recorded here rather than as `Spawned` rows, per [#270](https://github.com/Calyx-Engineering/arc/issues/270).

| | |
|---|---|
| **Two §10 rows are stale and were left alone** | [#203](https://github.com/Calyx-Engineering/arc/issues/203)'s says *"no entry in the tree does yet"* of `prefix=` on `branch-guard edit-checked`; 233 entries in the committed log carry it. [#199](https://github.com/Calyx-Engineering/arc/issues/199)'s says the next session is `issue-boxes`' first exercise; four `pr-ready` entries have reached it. Both merges are outside Fire, so both rows are outside this issue |
| **Six `branch-guard` entries carry no `outcome:` line** | `2026-09-09T05:39Z`–`06:32Z`, all on `arc/04-dogfood-issue-136-manual-linking`. 283 ok + 10 denied = 293, against 299 headers. Concurrent appends from parallel worktrees interleave, which is [#273](https://github.com/Calyx-Engineering/arc/issues/273)'s shape as much as [#238](https://github.com/Calyx-Engineering/arc/issues/238)'s |
| **A soak table has no gate** | Nothing in `tools/` reads §10, so a merge shipping with no row is invisible until someone counts. That is the same shape as `close-sequence.md` step 7's row two above these — *a sequence nothing fires is a sequence that gets skipped* — restated about the record instead of the step |

## Evidence

| | |
|---|---|
| `bash tests/verify-all.sh` | **52 gates, all clean, exit 0** |
| `bash tests/verify-report-budget.sh` | 4 passed, 0 failed — Fire 186 words, budget 200 |
| The issue's own check | Fourteen merges, fourteen rows, exit 0. Red before the rows, green after |
| Table shape | Every §10 row one line, three columns, four pipes |

**`.claude/arc/log.md` is deliberately not in this commit.** It gained thousands of machine lines
while the run worked, and the #166 first-exercise row already records what happens when `git add -u`
sweeps them into a review diff. `.claude/arc/sessions.md` is committed: it is one row per worktree,
written by `hooks/session-index`, and #16's row asks for exactly that reading.
