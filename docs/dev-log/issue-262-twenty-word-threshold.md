# Issue #262 — a 20-word budget at threshold

**Issue:** [#262](https://github.com/Calyx-Engineering/arc/issues/262)  ·  **Parent:** [#145](https://github.com/Calyx-Engineering/arc/issues/145) — Fire  ·  **Follows:** [#213](https://github.com/Calyx-Engineering/arc/issues/213)

## The question, and the answer

**Is firing the lever?** No. It gets the skill's body into context and does nothing more.
The lever is what the rule says once it is there.

The decisive pair is arms B and C below. **B fires on 9 of 9 runs and scores 0.37. C fires on
10 of 10 and scores 0.72.** Firing is saturated on both sides, so the whole difference between
them is the wording of the rule. And B against A — 9 of 9 firing against 4 of 10 — is worth
nothing at all: 0.37 against 0.34, `p=0.72`.

The suite clears the threshold. **93/119 · 0.78**, median run 0.87, four of five runs `PASS`.

## What the three arms are

Each arm is a whole copy of the plugin, differing from the one before it inside
`skills/chat-response/SKILL.md` and nowhere else. `diff -rq` between arm directories reports one
file, every time.

| Arm | Changed from | What changed |
|---|---|---|
| **A** | — | The skill as [#213](https://github.com/Calyx-Engineering/arc/issues/213) left it. The control |
| **B** | A, one line | The `description:` reordered so the invocation instruction leads instead of trailing at word 400. Same length either way — 500 words against 505 |
| **C** | B, the rule | The count-and-cut rule, in the `description:` and the body. **What ships** |

The raw replies of every run are in
[`evals/response-length/runs/issue-262`](../../evals/response-length/runs/issue-262), with each
arm's `description:` beside them. [#213](https://github.com/Calyx-Engineering/arc/issues/213)
recorded not being able to do that — *"the raw replies are not in the tree, so no reviewer can
re-derive them from the repository"* — and every figure below comes out of those files.

## Measured

`--probe`, matched: same cap (`RL_PROBE_BUDGET=0.80`), same worktree, same case, the only
difference being which arm directory `--plugin-dir` pointed at. The 20-word case,
`evals/response-length/too-many-words-20-words`, eleven turns of one conversation.

| Arm | Runs | Median run rate | Pooled turns | Fired on t11 |
|---|---|---|---|---|
| A | 10 | 0.29 | 37/109 · **0.34** | 4 of 10 |
| B | 9 | 0.36 | 35/95 · **0.37** | 9 of 9 |
| **C** | 10 | **0.79** | 76/106 · **0.72** | 10 of 10 |

**The run is the unit, not the turn.** Eleven turns inside one run are not eleven independent
observations — a run that decays breaks every turn after it decays. Pooling turns would make 29
runs look like 310 samples and shrink the interval by three and a half times over what the
design earns, so the ranking is over per-run rates and the pooled figure is printed beside it
as the suite number it is.

### The ranking

Mann-Whitney over per-run rates, against the exact null rather than the normal approximation —
at these n the approximation's tail is wrong by enough to change the answer.
`tools/response-length-rank.py`.

| | n | U | exact p | Ranked |
|---|---|---|---|---|
| B against A | 9 vs 10 | 50.0 of 90 | **0.72** | **No.** The two wordings do not differ |
| C against A | 10 vs 10 | 88.5 of 100 | **0.0021** | **C** |
| C against B | 10 vs 9 | 78.0 of 90 | **0.0057** | **C** |

**The count is n = 10 per arm, and it is enough.** Complete separation at 10 against 10 reaches
`p = 0.0001`; B against A is not close to separating at any count this instrument could pay for,
because the effect is not there. [#213](https://github.com/Calyx-Engineering/arc/issues/213)'s
constraint asked for a count that could rank two wordings — this one ranks three, and says which
pair cannot be ranked because they are the same.

### The suite

`tools/response-length.sh --probe` over all three cases, shipped skill, five runs.

| Run | 20-word | 60-word | Suite | Verdict |
|---|---|---|---|---|
| 1 | 5/10 · 0.50 | 10/10 · 1.00 | 16/23 · 0.70 | PASS |
| 2 | 10/11 · 0.91 | 9/9 · 1.00 | 20/23 · 0.87 | PASS |
| 3 | 10/11 · 0.91 | 9/9 · 1.00 | 20/23 · 0.87 | PASS |
| 4 | 11/11 · 1.00 | 10/11 · 0.91 | 22/25 · 0.88 | PASS |
| 5 | 5/11 · 0.45 | 9/11 · 0.82 | 15/25 · 0.60 | FAIL |
| **Pooled** | — | 47/50 · 0.94 | **93/119 · 0.78** | — |

Against [#213](https://github.com/Calyx-Engineering/arc/issues/213)'s 33/55 · 0.60. The 20-word
case alone is **76/106 · 0.72** over ten runs, so the suite is not being carried by the 60-word
case the way it was there. **One run in five still fails**, and the spread within one arm —
0.36 to 1.00 across ten identical runs — has not narrowed.

## Why C works, and how it was found

The score says which arm is better. It does not say what to change. The per-turn distribution
does, and it is free to read out of runs already paid for.

| | Median prose, turns after the budget was set | Median breach | Breaches in the 21–25 band |
|---|---|---|---|
| [#213](https://github.com/Calyx-Engineering/arc/issues/213), before its undershoot rule | 55 words | **58 words** | 1 of 18 |
| Arms A and B, 19 runs | **26 words** | **30 words** | **37 of 131 · 28%** |

**The skill was describing a failure it no longer had.** Its body said *"the median reply that
breaks a 20-word ceiling runs to 58 words — nearly three times over, not one word over… there
is nothing to trim afterwards."* True of the skill #213 measured. Measured against the skill
that shipped out of #213, the median breach is 30 and the median reply is 26 — half as much
again, one clause over, and there is plenty to trim afterwards.

So arm C replaces *build the margin in before the sentence is written* with **count the prose
after writing it and delete until the number fits**, and replaces the 58 with the measured 30.
A rule aimed at a 3× overrun, given to a model overrunning by 30%, is aimed past the failure.

**The two corrected figures are not what did it.** They were corrected after C's first ten
runs, and the corrected file was measured again: 0.63 against 0.72, `U=58.5`, `p=0.53` —
indistinguishable, as a change to two descriptive numbers in a body should be. Both sets of
runs are kept, as `armC-draft` and `armC`.

## The firing question, answered

| `chat-response` on the turn the budget was stated | Runs | Rate | Pooled |
|---|---|---|---|
| Fired | 23 | 0.09 – 1.00 | 128/245 · 0.52 |
| Did not fire | 6 | 0.09 – 0.91 | 20/65 · 0.31 |

`U=106.5`, `p=0.041`. An association, at n=29 across three arms — and **not the lever**, for two
reasons the pooled figure hides:

| | |
|---|---|
| **Firing saturated without moving the score** | Arm B raised firing from 4 of 10 to 9 of 9 and moved the rate from 0.34 to 0.37, `p=0.72`. If firing were the lever that is where it would have shown |
| **The gain came with firing held constant** | B and C both fire on essentially every run. All of C's 0.37 → 0.72 happened with the surface unchanged |

**[#213](https://github.com/Calyx-Engineering/arc/issues/213)'s clean split does not survive
the run count.** It reported *no overlap* — fired 0.36–0.91, did not fire 0.09–0.27, n=4 either
side. At n=29 the two ranges are 0.09–1.00 and 0.09–0.91: they overlap almost entirely. The
single widest-scoring run in arm A, 0.91, is a run where the skill never fired.

**What it does do is put the body in context**, and the body is where the rule that worked
lives. That is worth keeping, which is why C is built on B's ordering rather than A's. It is a
precondition, not a cause.

## What was built to measure it

| | |
|---|---|
| **`tools/response-length-rank.py`** | Aggregates many `RL_PROBE_OUT` files into per-run rates, the exact Mann-Whitney ranking, and the firing split. Imports `tools/response-length.py`'s scorer rather than copying it — one thin floor, one fence rule, one `CUT` rule. Selftest on synthetic JSON, no `claude`, in `tests/verify-all.sh` |
| **`tools/response-length.sh --probe --plugin-dir <dir>`** | Measures the plugin in a directory for the probe's sessions only, writing a settings file that disables every installed copy of the same plugin name. Before this, measuring a candidate meant installing it into `~/.claude/plugins/cache` — one directory shared by every session on the machine, which four live arc worktrees were reading at the time, and which a worktree cannot install its own branch into at all because the marketplace source is a directory pointing at the main checkout |
| **A run the rate limit destroyed is refused** | [#213](https://github.com/Calyx-Engineering/arc/issues/213) lost two billed runs returning all eleven turns `CUT`, one at `$0.000`. The ranker voids a run that is more than half cut, or has fewer than three scoreable turns, and names it. None of this issue's runs was void |

The `--plugin-dir` mechanism was verified before any run was billed: with a marker word
prepended to an arm's `description:`, a session started from a directory holding no repository
files quoted the marker back, and each arm quoted its own opening words.

## Limits on the above

| | |
|---|---|
| **One run in five still fails the suite** | And ten identical runs of the shipped arm span 0.36 to 1.00. The threshold is cleared on the pooled figure and on the median; it is not cleared every time |
| **n = 10 per arm** | Enough to rank C against both others at `p < 0.006`, and enough to say A and B do not differ. Not enough to put an interval on any single arm's rate |
| **The firing split is observational** | Nothing here randomises firing. Runs are grouped by something the run did, so a difference is an association — which is exactly the reading [#213](https://github.com/Calyx-Engineering/arc/issues/213) took further than it should have been taken |
| **The probe can read the tree it runs in** | `Read`, `Grep` and `Glob` are allowed so the turns can be answered, and the worktree held arm C's `SKILL.md` throughout. No turn in the case asks about `chat-response` and no reply quoted it, but a run could in principle have read a skill other than the one `--plugin-dir` gave it |
| **The 60-word case is five runs** | 47/50 · 0.94, shipped arm only. No matched control, so it is a candidate-side number |
| **It cost `$96.11`** | 58 logged runs at `$1.66` mean, plus preflights. [#213](https://github.com/Calyx-Engineering/arc/issues/213) spent `$18.01` on ten. The count is what the second box asked for, and the count is what it costs |

## Findings

| Finding | Where it routes |
|---|---|
| **Firing is not the lever, and #213's split was a small-n artefact.** Fired 0.09–1.00 against did not fire 0.09–0.91, n=29 — overlapping, where #213 reported no overlap at n=4 either side. Arm B saturated firing and moved nothing. #213's third box called it *a finding to test, not a proven mechanism*; tested, it does not hold | Answered here. The claim is **not** propagated into `skills/chat-response` |
| **The skill carried a measurement of its own previous version.** Its body described a 58-word median breach — true of the skill before #213's undershoot rule, false of the skill that shipped from it, where the breach is 30. A rule aimed at a 3× overrun was being given to a model overrunning by 30%, and correcting the aim is most of this issue's gain | Fixed in this PR. **A skill that quotes a measurement of itself goes stale the moment it works**, and nothing checks for it — needs an issue |
| **A candidate skill could not be measured without mutating a machine-wide singleton.** `claude plugin install` writes one cache directory shared by every session; the `calyx-engineering` marketplace is a directory source pointing at the main checkout, so a worktree could not install its own branch at all. `--plugin-dir` plus a generated settings file replaces it | Done in this PR. `tools/response-length.sh` |
| **One run in five still fails the suite, and ten identical runs span 0.36 to 1.00.** The threshold is met on the pooled figure and on the median, not run by run. Whatever produces that spread is untouched by anything in this issue | Needs an issue. It is the next question after this one |
| **The instrument could not aggregate.** Every figure in #158 and #213 was a person reading terminal scrollbacks, which is why neither could raise its run count. `tools/response-length-rank.py` is the aggregator, and `RL_PROBE_OUT` per run is what feeds it | Done in this PR |
