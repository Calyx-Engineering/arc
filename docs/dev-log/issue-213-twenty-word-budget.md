# Issue #213 — a 20-word budget is not held

**Issue:** [#213](https://github.com/Calyx-Engineering/arc/issues/213)  ·  **Parent:** [#145](https://github.com/Calyx-Engineering/arc/issues/145) — Fire  ·  **Follows:** [#158](https://github.com/Calyx-Engineering/arc/issues/158)

## The question, and the answer

**Is a 20-word budget reachable through the `description:` alone?** Yes — and it is not held
through it. Both halves are load-bearing, and the issue's either/or has no branch for them.

The existence proof is one probe run. With an undershoot rule in the description, the reply
after the budget was set broke it at 30 words, and then **every one of the next nine turns
landed between 13 and 18**:

```text
t11  t12  t13 t14 t15 t16 t17 t18 t19 t20 t21
 19   30   15  16  18  14  16  13  13  15  16
      ^ the one breach
```

Nine of the ten turns after the budget was set were inside it; the run scored **10/11**. So the
surface can do it. The next run, same skill, same cap, decayed to 128 words by t21.

## The grader was deleting the evidence, and that had to be fixed first

`tools/response-length.py` discarded any reply below a **flat 15-word floor** as `THIN`,
counted in neither column. The floor exists for a good reason — a reply that declines is short,
and counting short as held would report success every time the model failed to answer.

But 15 words is three quarters of a 20-word budget. And the rule under test tells the model to
aim at **13**. So the instrument was dropping exactly the turns that obeyed the rule it was
grading: in the run above, the 14, 13 and 13 were all thrown away, and it scored 7/8 instead of
10/11.

**The floor is now `min(RL_THIN_FLOOR, budget // 2)`** — 10 words for the 20-word case,
unchanged at 15 for the 60-word one, and printed per case rather than only as the configured
value. Half the budget is the most a floor can be and still mean *too short to be an attempt*.

Every number below is at the corrected floor. The flat floor put the candidate arm at 0.38; it
is 0.45 measured properly, and the denominators stop shrinking as replies get shorter.

## Measured

`--probe`, matched: same cap (`RL_PROBE_BUDGET=0.80`), same worktree, same cases, the only
difference being which `SKILL.md` was staged in the installed plugin.

| Case | Skill | Runs | Within budget |
|---|---|---|---|
| 20-word | before — the skill as [#160](https://github.com/Calyx-Engineering/arc/issues/160) left it | 3 | **6/32 · 0.19** |
| 20-word | after — undershoot rule added | 3 | **15/33 · 0.45** |
| 60-word | after | 2 | **18/22 · 0.82** |
| **Suite** | after | 5 | **33/55 · 0.60** — below the 0.67 threshold |

Per run, from the JSON `RL_PROBE_OUT` kept. **Rate counts every scoreable turn including the
one the budget was stated on, and excludes `THIN` and `CUT` turns** — that is the scorer's
denominator, not a choice made here:

| Run | Case | Skill | Rate | First breach | `chat-response` fired |
|---|---|---|---|---|---|
| 1 | 20-word | before | 3/11 · 0.27 | t12 | no turn |
| 2 | 20-word | before | 1/10 · 0.10 | t12 | no turn |
| 3 | 20-word | before | 2/11 · 0.18 | t12 | no turn |
| 4 | 20-word | after | 10/11 · 0.91 | t12 | t11 |
| 5 | 20-word | after | 1/11 · 0.09 | t12 | no turn |
| 6 | 20-word | after | 4/11 · 0.36 | t12 | t11 |
| 7 | 60-word | after | 10/11 · 0.91 | t73 | t72 |
| 8 | 60-word | after | 8/11 · 0.73 | t72 | t72 |

### The overruns are not near misses

`skills/chat-response` and [#158](https://github.com/Calyx-Engineering/arc/issues/158)'s
dev-log both described the 20-word failure as replies clustering *just over* the ceiling. **They
do not.** This table counts the turns **after** the budget was set — t12 to t21, a different
population from the rate above, which includes t11 and drops thin turns:

| | Turns | Median prose | Within 20 | Median breach | Breaches in the 21–25 band |
|---|---|---|---|---|---|
| Before | 29 | **55 words** | 3 | **58 words** | 3 of 26 |
| After | 30 | **30 words** | 12 | **42 words** | 1 of 18 |

The median breach before the change is 58 words — nearly three times the budget, not one word
over. The undershoot rule roughly halves it and does not close it. A fix aimed at *shave two
words off* would have been aimed at a failure that is not happening.

### The one invariant across all six 20-word runs

**Held one turn, first breach t12, every time.** Six runs, three with the rule and three
without. The budget is stated on t11, honoured on t11, and broken on t12 — and the rule changes
what happens on t13 onward without ever changing that. Whatever holds a budget on the turn it
is set is not what carries it to the next one.

### Firing separates the runs cleanly, which #158 did not see

| `chat-response` | Runs | Rate |
|---|---|---|
| Fired on the turn the budget was set | 4 | **0.36 – 0.91** |
| Did not fire | 4 | **0.09 – 0.27** |

No overlap. #158 measured the 60-word case, found the skill fired on no turn in either run, and
concluded the effect came entirely from the description. That conclusion holds for 60 words. It
does not extend to 20: at this ceiling, the runs that held are the runs where the body was in
context.

**The description's best contribution was making the skill fire at all** — 2 of 3 candidate
runs against 0 of 3 control. That is a mechanism worth naming, and it is the opposite of the
one #158 recorded.

### This disagrees with #158's corrected numbers, and the disagreement is not resolved here

`0e2586a`, two commits back on this branch, corrected #158's dev-log to a 20-word case of
**21/37 · 0.57** over four runs and a suite of **53/70 · 0.76 — above threshold**. Measuring
what should be a very similar skill, this issue gets **6/32 · 0.19** and a suite of **0.60,
below it**.

Both cannot be right, and nothing here establishes which is. Three candidates, none tested:

| | |
|---|---|
| The `description:` grew | [#160](https://github.com/Calyx-Engineering/arc/issues/160) added roughly 90 words to it, and #213 has now added more. The budget rule competes inside a longer description — which is the dilution this dev-log theorises about below |
| Different per-turn cap | #158's runs were taken at a different `RL_PROBE_BUDGET`, and its own dev-log records the cap corrupting the measurement once already |
| The flat thin floor | Corrected above. It moved this issue's candidate arm 0.38 → 0.45, and #158's numbers were taken under the uncorrected floor |

**Nothing in either dev-log should be cited as the 20-word rate until one run settles it.**

## What surface would work

**One that is loaded every turn without depending on activation.** The description is in
context always but is a paragraph competing with everything else in a long description; the
body carries the detail and loads only when the skill fires, which was 4 of the 8 runs.

Not a longer `description:`. The issue forbids widening it on hope and is right to: the
candidate rule already moved the 20-word case 0.19 → 0.45 and stalled there, and the remaining
gap is not a wording problem.

## Limits on the above

| | |
|---|---|
| **n = 3 and n = 2** | The 20-word rate swings 0.09 to 0.91 across identical runs. Three runs establish that the ceiling is reachable and not reliably held; they cannot rank two wordings, which is exactly what #213's constraint said |
| **The firing split is n = 4 either side** | Clean, with no overlap, and still four runs. Recorded as a finding to test, not a proven mechanism |
| **The 60-word case was measured after only** | Two runs, candidate skill. No matched control, so the suite figure is a candidate-side number, not a before/after |
| **The probe is billed** | $1.25–3.00 per run at 11 turns. Ten runs, of which two were destroyed by a rate limit and one of those cost nothing: **$18.01** total, summed from the runner's own per-run figures |
| **Two runs were destroyed by a rate limit** | Both came back with all 11 turns `CUT`, one at `$0.000`. The scorer refused them rather than reading truncation as a held budget — the `CUT` rule from #158 doing its job — and they were re-run |

## `RL_PROBE_OUT`, ported from `tools/topic-numbering.sh`

[#160](https://github.com/Calyx-Engineering/arc/issues/160) added an option to keep the probe's
raw replies, and it paid for itself there when the scorer had to be corrected after six billed
runs. `tools/response-length.sh` had no equivalent, so #158's runs were unrecoverable and this
issue's would have been too. Added before the first billed run here.

Every number in this document was re-derived from the retained JSON rather than copied from a
terminal.
