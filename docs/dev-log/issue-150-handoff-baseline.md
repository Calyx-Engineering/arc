# Issue #150 — measure handoff spin-up time and accuracy

**Issue:** [#150](https://github.com/Calyx-Engineering/arc/issues/150)  ·  **PR:** pending

## Problem

The handoff format has been rewritten three or four times with no instrument to say whether any
rewrite helped. [#146](https://github.com/Calyx-Engineering/arc/issues/146) states the two
criteria for a working handoff; nothing measured either of them.

## The result

**Five of the eight post-install cold starts got their first action right with no correction,
three did not** — the 5/3 split #150 recalled, from the *first action* criterion alone. Full
table and per-cell evidence in
[`handoff-baseline.md`](../arc-work/04-dogfood/handoff-baseline.md).

**No single score satisfies the "Done when" as written.** The issue defines a working handoff as
correct first action **and** able to say why. Requiring both scores 3 good and 5 bad, inverting
the recollection. The `Expected split` constraint says that when the score does not reproduce the
memory the instrument is wrong — so the instrument was changed rather than the memory: C1 and C2
are reported as two columns and never combined into a verdict.

**C1 agrees with the recollection because agreement is why it was kept.** That is a calibration,
not evidence that C1 is the right criterion, and the document says so rather than presenting the
match as a result. What carries the weight instead is the appendix: the quote behind every cell,
with a session id and a timestamp.

## The reading that was not scored

#150's C2 wording — *"can state why"* — admits both *did state, unprompted* and *could have
stated if asked*. Only the first is observable in a transcript; the second asks what a session
would have answered to a question nobody put to it. It is the reading that might have made the
composite reproduce 5/3, and it is **not ruled out — it is unmeasurable from this corpus.**
Scoring it means re-running the openings against a live model, which is
[#181](https://github.com/Calyx-Engineering/arc/issues/181).

## Decisions and trade-offs

| | |
|---|---|
| **The corpus is enumerated by a tool, not by hand** | `tools/handoff-openings.sh`. A hand-listed corpus drifts, and the score then measures the list |
| **A cold start is defined by the session, not by the opening's wording** | Starts in the window, opens with a human at the keyboard, at least two human prompt turns. Filtering on *asked for a handoff read* gives 6, not 8, and drops two real cold starts that opened on new work |
| **Two human prompt turns, not one** | Set from what the excluded sessions *are* — one ran `/plugin install`, one asked for a transcript to be copied — not from the count it yields. The count agreeing with #150's 8 is a weak check, since this threshold is the knob that produces it |
| **A loop-dispatched run is not a cold start** | Its prompt carries `promptSource: "sdk"` with no human origin. The driver handed it an issue, not a handoff. This is the one rule where `handoff-openings.py` deliberately differs from `skill-firing.py`, which counts a dispatched prompt as a turn |
| **The human has to have opened it** | A dispatched run a human later joined has two human prompts too, so the count alone admits it. Any dispatched prompt before the first typed one disqualifies the session. Found at PR time: the tool's header claimed this and the code did not do it |
| **A session that started before `--since` is out even if it ran past it** | It began its cold start against a pre-install handoff. `skill-firing.py` keeps such a session; here it would be measuring the wrong document |
| **Pairing is per repository, not per directory** | A worktree gets its own transcript directory and writes the same repository's handoff. Pairing per directory loses the writer across that boundary |
| **`--until` closes the corpus** | So a later run compares like with like. Without it, a human cold start after the boundary would change the denominator silently |
| **The evidence is committed, the transcripts are not** | Transcripts carry client and employer material and stay on the machine. A quote with a session id and a timestamp is the most that can be recorded, and without it the score is unauditable — five of the eight rows had no quotable evidence in the tree until the appendix was written |
| **Eight read-only sub-agents, one per pair** | `Explore`, which has no edit tools — the issue requires the reader to edit nothing, and an agent type that *cannot* is better evidence than an instruction not to |

## What the reading found

**Five openings are bad by the issue's definition** — the three C1 failures plus two that acted
correctly and could not say why. Per-opening answers to *was the wrong answer in the handoff* are
in the baseline; the shape of them:

- **The format records decisions without reasons.** Every handoff in the corpus has a
  *Load-bearing decisions — do not re-litigate* section holding what was decided. In three of the
  four C2 failures the reason was simply not in the file.
- **#4 is the sharpest case.** The handoff was correct and the session still got it wrong: it
  gave the step order and no reason for it, so the session re-derived a reason from the dependency
  graph and inverted the order.
- **Stating the why does not prevent the wrong action.** #7 gave the correct rationale unprompted
  and built the wrong rig four minutes later.
- **Age does not predict either column.** The two extremes, 0.2 h and 304.7 h, sit on opposite
  sides of C1.

**Two of the eight read a handoff that no Claude session wrote.** #4's was last edited by GitHub
Copilot Chat; #5's is headed later still than that, so something edited it again and left no
transcript at all. The writer→reader chain has a hole in it, and the tool's `writer` column names
the last *Claude* writer, which is not the same thing. It is reported as such rather than
silently.

## Evidence

```
bash tools/handoff-openings.sh selftest        33 passed, 0 failed
bash tools/verify-all.sh                       20 gates, all clean   (exit 0)
```

**The selftest was mutation-tested.** Nine rules were deleted one at a time from
`handoff-openings.py` — `repo_of`'s `.lower()`, the handoff basename match, the `--since` and
`--until` filters, the `tool_result`, `isMeta` and interrupt guards, the two-prompt threshold,
and the rule that a human must have opened the session. All nine turned the selftest red. **The
first version of the selftest caught none of the last seven**, which is why the mutation run
exists at all — 15 green assertions were guarding four rules.

## What this does not do

**It measures what happened; it cannot re-run an opening against a changed handoff format.**
That is [#181](https://github.com/Calyx-Engineering/arc/issues/181), gated behind early access.

**The enumeration re-runs; the score does not.** The command re-derives the same eight pairs. The
appendix is what a later run compares its own reading against — re-scoring means reading the same
eight pairs again.

**C2 is calibrated against nothing**, and its by-date result has a confound this corpus cannot
separate: the format was rewritten several times inside the same window, n = 8, no control.

**Transcripts were located by globbing the raw store**, because
[#16](https://github.com/Calyx-Engineering/arc/issues/16)'s session index is not shipped. The
corpus reaches outside this worktree, which is the condition #16 was named a prerequisite for;
`miner-scope.sh` bounds the glob so [#141](https://github.com/Calyx-Engineering/arc/issues/141)'s
defect cannot recur, but a deleted worktree's orphaned directory would still be found only by
luck.
