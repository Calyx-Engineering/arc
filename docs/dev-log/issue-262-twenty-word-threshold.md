# Issue #262 — a 20-word budget at threshold

**Issue:** [#262](https://github.com/Calyx-Engineering/arc/issues/262)  ·  **Parent:** [#145](https://github.com/Calyx-Engineering/arc/issues/145) — Fire  ·  **Follows:** [#213](https://github.com/Calyx-Engineering/arc/issues/213)

## The question, and the answer

**Is firing the lever?** No. It gets the skill's body into context and does nothing more.
The lever is what the rule says once it is there.

The decisive pair is arms B and C below. **B fires on 9 of 9 runs and scores 0.37. C fires on
10 of 10 and scores 0.72.** Firing is saturated on both sides, so the whole difference between
them is the wording of the rule. And B against A — 9 of 9 firing against 4 of 10 — is worth
nothing at all: 0.37 against 0.34, `p=0.72`.

The 20-word case alone is **72/100 · 0.72** over ten runs of the shipped file, against
[#213](https://github.com/Calyx-Engineering/arc/issues/213)'s 15/33 · 0.45.

The suite clears the threshold. **88/114 · 0.77** on the file that ships, median run 0.77, and
all five runs `PASS`.

## What the four arms are

Each arm is a whole copy of the plugin, differing from the one before it inside
`skills/chat-response/SKILL.md` and nowhere else. `diff -rq` between arm directories reports one
file, every time.

| Arm | Changed from | What changed |
|---|---|---|
| **A** | — | The skill as [#213](https://github.com/Calyx-Engineering/arc/issues/213) left it. The control |
| **B** | A, one line | The `description:` reordered so the invocation instruction leads instead of trailing at word 400. Same length either way — 500 words against 505 |
| **C** | B, the rule | The count-and-cut rule, in the `description:` and the body |
| **D** | C, its own figures | Review found C's body quoting the draft arm's 60-word score and its `description:` attributing arms A and B's medians to a rule neither of them has. Corrected, and **re-measured rather than shipped on C's numbers**. `armC-to-armD.diff` is the whole change. **What ships** |

**D exists because the alternative was shipping an unmeasured file and calling it C.** Two
review passes edited the measured artifact; that is how a PR reaches the state where three
documents say *what ships* about a file nobody ran. Ten more runs cost less than the sentence
explaining why they were not done.

The raw replies of every run are in
[`evals/response-length/runs/issue-262`](../../evals/response-length/runs/issue-262), with each
arm's `description:` beside them. [#213](https://github.com/Calyx-Engineering/arc/issues/213)
recorded not being able to do that — *"the raw replies are not in the tree, so no reviewer can
re-derive them from the repository"* — and every probed score below comes out of those files.
**Two things do not.** The `agreement-brief-long-answer` column of the suite is a fixture scored
from its own stored replies, never probed and never billed; and the cost figures are summed from
the runner's terminal output, which is not retained, over nine runs that produced no case entry
at all — the preflights that proved `--plugin-dir`, and one early run.

## Measured

`--probe`, matched: same cap (`RL_PROBE_BUDGET=0.80`), same worktree, same case, the only
difference being which arm directory `--plugin-dir` pointed at. The 20-word case,
`evals/response-length/too-many-words-20-words`, eleven turns of one conversation.

| Arm | Runs | Median run rate | Pooled turns | Per-run range | Fired on t11 |
|---|---|---|---|---|---|
| A | 10 | 0.29 | 37/109 · **0.34** | 0.09 – 0.91 | 4 of 10 |
| B | 9 | 0.36 | 35/95 · **0.37** | 0.09 – 0.82 | 9 of 9 |
| C | 10 | 0.79 | 76/106 · **0.72** | 0.36 – 1.00 | 10 of 10 |
| **D** — ships | 10 | **0.71** | 72/100 · **0.72** | **0.40 – 1.00** | 10 of 10 |

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
| **D against A** | 10 vs 10 | 89.0 of 100 | **0.0021** | **D** — the file that ships, against the control |
| D against C | 10 vs 10 | 48.0 of 100 | **0.91** | **No**, and that is the claim: correcting C's own figures changed its behaviour by nothing measurable |

**The count is n = 10 on A and C and n = 9 on B, and it is enough.** Complete separation at 10
against 10 reaches `p = 0.0001`; B against A is not close to separating at any count this
instrument could pay for, because the effect is not there. [#213](https://github.com/Calyx-Engineering/arc/issues/213)'s
constraint asked for a count that could rank two wordings — this one ranks three, and says which
pair cannot be ranked because they are the same.

### The suite

`tools/response-length.sh --probe` over all three cases, arm D — the file that ships — five runs.

| Run | 20-word | 60-word | Suite | Verdict |
|---|---|---|---|---|
| 1 | 7/10 · 0.70 | 10/11 · 0.91 | 18/24 · 0.75 | PASS |
| 2 | 7/10 · 0.70 | 7/8 · 0.88 | 15/21 · 0.71 | PASS |
| 3 | 8/11 · 0.73 | 8/8 · 1.00 | 17/22 · 0.77 | PASS |
| 4 | 9/11 · 0.82 | 9/10 · 0.90 | 19/24 · 0.79 | PASS |
| 5 | 8/10 · 0.80 | 10/10 · 1.00 | 19/23 · 0.83 | PASS |
| **Pooled** | 39/52 · 0.75 | 44/47 · 0.94 | **88/114 · 0.77** | — |

**The suite has a third case, and the two columns above do not add up to it.**
`agreement-brief-long-answer` is a fixture — its budget comes from an operating agreement, it has
no session to probe, and it is scored from stored replies — so it contributes the same **1/3** to
every run and to the pooled figure, unchanged by anything here. 39 + 44 + 5 = 88, 52 + 47 + 15 =
114.

Against [#213](https://github.com/Calyx-Engineering/arc/issues/213)'s 33/55 · 0.60. **These five
runs are the first five of the twenty-word case's ten**, which is why its column here reads
39/52 · 0.75 and its own row above reads 72/100 · 0.72 — a subset and its whole, not two
measurements.

**What has not narrowed is the spread.** Arm D's ten runs span 0.40 to 1.00, against C's 0.36 to
1.00 and A's 0.09 to 0.91. The floor has risen and the range has not closed; arm C's five suite
runs included one at 0.60 that failed, and D's five did not, which at five runs each is a
difference nothing here is entitled to call real.

## Why C works, and how it was found

The score says which arm is better. It does not say what to change. The per-turn distribution
does, and it is free to read out of runs already paid for.

| | Median prose, turns after the budget was set | Median breach | Breaches in the 21–25 band |
|---|---|---|---|
| [#213](https://github.com/Calyx-Engineering/arc/issues/213), before its undershoot rule | 55 words | **58 words** | 3 of 26 |
| Arms A and B, 19 runs | **26 words** | **30 words** | **37 of 131 · 28%** |

**The skill was describing a failure it no longer had.** Its body said *"the median reply that
breaks a 20-word ceiling runs to 58 words — nearly three times over, not one word over… there
is nothing to trim afterwards."* True of the skill #213 measured. Measured against the skill
that shipped out of #213, the median breach is 30 and the median reply is 26 — half as much
again, one clause over, and there is plenty to trim afterwards.

So arm C replaces *build the margin in before the sentence is written* with **count the prose
after writing it and delete until the number fits**, and replaces the 58 with the measured 30.
A rule aimed at a 3× overrun, given to a model overrunning by 30%, is aimed past the failure.

**Correcting a figure in the body does not move the score, and that was tested twice rather
than assumed.** The first time, two figures were corrected after C's first ten runs: 0.63 against
0.72, `U=58.5`, `p=0.53`. The second time, review found more of them, and arm D is the corrected
file re-measured: 0.72 against 0.72, `U=48.0`, `p=0.91`. Every set of runs is kept — `armC-draft`,
`armC` and `armD` — because *"we corrected only prose"* is a claim, and this is what checking it
looks like.

## The firing question, answered

| `chat-response` on the turn the budget was stated | Runs | Rate | Pooled |
|---|---|---|---|
| Fired | 33 | 0.09 – 1.00 | 200/345 · 0.58 |
| Did not fire | 6 | 0.09 – 0.91 | 20/65 · 0.31 |

`U=157.5`, `p=0.020`. An association, at n=39 across four arms — and **not the lever**, for two
reasons the pooled figure hides. Note first what the split is made of: **all six non-firing runs
are arm A**, because B, C and D fire on essentially every run. The comparison is therefore part
of the control against everything else, not firing against not-firing within an arm.

| | |
|---|---|
| **Firing saturated without moving the score** | Arm B raised firing from 4 of 10 to 9 of 9 and moved the rate from 0.34 to 0.37, `p=0.72`. If firing were the lever that is where it would have shown |
| **The gain came with firing held constant** | B, C and D all fire on essentially every run. All of C's 0.37 → 0.72 happened with the surface unchanged |

**[#213](https://github.com/Calyx-Engineering/arc/issues/213)'s clean split does not survive
the run count.** It reported *no overlap* — fired 0.36–0.91, did not fire 0.09–0.27, n=4 either
side. At n=39 the two ranges are 0.09–1.00 and 0.09–0.91: they overlap almost entirely. The
single widest-scoring run in arm A, 0.91, is a run where the skill never fired.

**What it does do is put the body in context.** C's rule is in the `description:` *and* the
body, and no arm separates the two, so nothing here shows which of them carries the gain —
C-draft against C is the only body-only contrast in the tree and it is null. Building C on B's
ordering rather than A's is therefore a choice, made because a rule that is only in the body is
worth nothing on a turn the skill does not fire, and not a finding.

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
| **The spread has not closed** | Ten identical runs of the shipped arm span 0.40 to 1.00. All five of its suite runs pass and the pooled figure clears the threshold, but arm C's fifth suite run scored 0.60 and failed, and nothing here makes five passes evidence that the next one will |
| **n = 10 on A and C, 9 on B** | Enough to rank C against both others at `p < 0.006`, and enough to say A and B do not differ. Not enough to put an interval on any single arm's rate |
| **The firing split is observational** | Nothing here randomises firing. Runs are grouped by something the run did, so a difference is an association — which is exactly the reading [#213](https://github.com/Calyx-Engineering/arc/issues/213) took further than it should have been taken |
| **The probe can read the tree it runs in** | `Read`, `Grep` and `Glob` are allowed so the turns can be answered, and the worktree held arm C's `SKILL.md` throughout. No turn in the case asks about `chat-response` and no reply quoted it, but a run could in principle have read a skill other than the one `--plugin-dir` gave it |
| **The 60-word case is five runs** | 44/47 · 0.94 on the shipped arm. No matched control, so it is a candidate-side number |
| **It cost about `$120`** | `$96.11` across the 58 runs logged before review, at `$1.66` mean, and fifteen more for arm D. [#213](https://github.com/Calyx-Engineering/arc/issues/213) spent `$18.01` on ten. The count is what the second box asked for, and the count is what it costs |

## Findings

| Finding | Where it routes |
|---|---|
| **Firing is not the lever, and #213's split was a small-n artefact.** Fired 0.09–1.00 against did not fire 0.09–0.91, n=29 — overlapping, where #213 reported no overlap at n=4 either side. Arm B saturated firing and moved nothing. #213's third box called it *a finding to test, not a proven mechanism*; tested, it does not hold | Answered here. The claim is **not** propagated into `skills/chat-response` |
| **The skill carried a measurement of its own previous version.** Its body described a 58-word median breach — true of the skill before #213's undershoot rule, false of the skill that shipped from it, where the breach is 30. A rule aimed at a 3× overrun was being given to a model overrunning by 30%, and correcting the aim is most of this issue's gain | Fixed in this PR. **A skill that quotes a measurement of itself goes stale the moment it works**, and nothing checks for it — needs an issue |
| **A candidate skill could not be measured without mutating a machine-wide singleton.** `claude plugin install` writes one cache directory shared by every session; the `calyx-engineering` marketplace is a directory source pointing at the main checkout, so a worktree could not install its own branch at all. `--plugin-dir` plus a generated settings file replaces it | Done in this PR. `tools/response-length.sh` |
| **Ten identical runs of the shipped skill span 0.40 to 1.00.** The floor rose from 0.09 and the range did not close. The threshold is met on the pooled figure and on the median; run-to-run variance of that size is untouched by anything in this issue, and it is what stands between *clears the threshold* and *holds the budget* | Needs an issue. It is the next question after this one |
| **The instrument could not aggregate.** Every figure in #158 and #213 was a person reading terminal scrollbacks, which is why neither could raise its run count. `tools/response-length-rank.py` is the aggregator, and `RL_PROBE_OUT` per run is what feeds it | Done in this PR |
