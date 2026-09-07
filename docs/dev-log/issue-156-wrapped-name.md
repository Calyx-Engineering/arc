# Issue #156 — an instruction wrapped around a skill name suppresses the match

**Issue:** [#156](https://github.com/Calyx-Engineering/arc/issues/156)  ·  **PR:** [#207](https://github.com/Calyx-Engineering/arc/pull/207)

## Problem

`arc:camp` fired at 2 of 4 real session openings that name Camp. The two that fired were the
whole message; the two that did not wrapped the name in front of other requests.

[#155](https://github.com/Calyx-Engineering/arc/issues/155) measured it and wrote the rule this
issue applies — **R3, a trigger clause must survive company.** `camp`'s description already said
*"Use when the user addresses Camp by name"*, so the name being present was never the problem.

## What changed

| File | |
| --- | --- |
| `skills/camp/SKILL.md` | The `description:` frontmatter, and nothing else. 384 → 827 characters |
| `docs/arc-log/arc-04-dogfood.md` | A soak row. The change ships unsoaked and cannot be soaked by any gate here |

**Three rules from [the decision](../arc-work/04-dogfood/skill-firing-decision.md) §1 changed the text:**

| | Applied as |
| --- | --- |
| **R1** — the trigger clause holds the user's own nouns and verbs | It now opens with six phrases lifted from the corpus — *"hey Camp"*, *"hi Camp"*, *"where are we at"*, *"where we are"*, *"what to do next"*, *"up to speed"*, *"pick up from where we left off"* |
| **R3** — a trigger clause must survive company | *"Fires when the name or the question is wrapped inside other instructions rather than being the whole message"*, with the observed shape named: a greeting to Camp followed by *"please read handoff"*, a goal for the day, or three further requests |
| **R4** — the user's word wins over the taxonomy's | The user's phrasings come first; *where the arc stands · what was decided · what comes next* still follow, unchanged |

**Nothing was removed.** All eight trigger phrases the old description carried are still in it.

## The result

The bare shape gains rather than loses, which is what box 3 asked for.

| Bare case | Word coverage, old → new | Longest contiguous run, old → new |
| --- | --- | --- |
| `camp-status-opening` — *"Hi Camp, where are we at?"* | 3/6 → **6/6** | `where` → **`where are we at`** |
| `camp-status-midsession` — *"Camp, where are we at?"* | 3/5 → **5/5** | `where` → **`where are we at`** |

**This is textual containment, not a firing measurement.** `tools/skill-cases.sh` scores frozen
transcripts, so it returns the same 13 rows before and after — it cannot see a description change
at all. The only instrument that could is `claude plugin eval`, and it is gated.

## Decisions and trade-offs

| | |
| --- | --- |
| **No lexical coverage gate was built** | It was the obvious instrument for box 3 and it would have been wrong — see below |
| **Only `camp` was touched** | Both cases expect `handoff` and `camp`, so neither goes green on this fix alone. `handoff`'s frontmatter is [#157](https://github.com/Calyx-Engineering/arc/issues/157)'s box, named in its `Required`. Editing it here would have taken another issue's work |
| **The decision document was not edited** | §1 R1's *Because* column overstates its evidence (below). The rule survives; the document is a closed issue's deliverable, and the correction is filed rather than applied |
| **Description length** | 827 characters against a previous repo maximum of 638. R1 requires quoting the user, and quoting costs length. `claude plugin validate .` exits 0 |

## Why no coverage gate

The instrument would have been: *does the expected skill's description contain the user's words?*
Measured against the seven wrapped cases, it mispredicts in both directions.

| Case | Skill | Longest run of the user's words in the description | Fired |
| --- | --- | --- | --- |
| `autonomous-mode-arc-next-later` | `autonomy-set` | `autonomous` — one word | **yes** |
| `retrospective-process` | `plugin-retrospective` | `retrospective` — one word | **yes** |
| `camp-handoff-conclude-40` | `camp` | `camp` — and the name is in the trigger clause | **no** |

**No text metric separates the passes from the misses.** `camp` scored at least as well as either
skill that fired and did not fire. That is R3's own claim — presence is not sufficient — and it
means a gate built on presence would have gone green on the exact description that failed.

[#155](https://github.com/Calyx-Engineering/arc/issues/155) §1 R1 credits the two wrapped passes
to prompts *"whose exact words are in the description"*. `autonomous mode` and `retrospective
process` are not contiguous in either description. The rule holds on nouns; the sentence claims
phrases.

## What is not done

**The `Done when` is not met, and is not executable on this machine.**

```
$ claude plugin eval --threshold 0.8 --case camp-handoff-conclude-40 --no-publish
`plugin eval` is currently in early access
exit 1
```

[#181](https://github.com/Calyx-Engineering/arc/issues/181) tracks access. One refinement for it:
#155 recorded `plugin eval init --bare` returning **0** while gated, which is the false-PASS trap.
The **run** form returns **1**. A gate wired to the run form fails closed, so that is the form to
wire.

## Evidence

| | |
| --- | --- |
| `bash tools/verify-all.sh` | **exit 0** — 12 gates, all clean, before and after |
| `claude plugin validate .` | **exit 0** |
| `bash tools/skill-cases.sh` | **exit 0** — no prompt drift, so both cases are verbatim. bare 3/3 · situation 2/3 · wrapped 2/7, unchanged, as expected of a transcript scorer |
| Frontmatter | Parses as YAML, 827 characters, three U+2014 em dashes, no cp1252 bytes, no `": "` that would break the plain scalar |

## What pass 3 found

**Box 2's tick linked the decision document at `blob/main/`, where it does not exist.** It merged
into `arc/04-dogfood`, not `main`. `git cat-file -e origin/main:…` returns *"exists on disk, but
not in 'origin/main'"*. Corrected to the branch ref and confirmed with `gh api …?ref=arc/04-dogfood`.

**A tick written from the tree still gets its links from memory.** The claim was right and the
citation was dead, which is the half a reader clicks first.

## What pass 1 found

Two defects in this session's own edit, both in the first draft of the description.

| | |
| --- | --- |
| **`"catch me up"` was invented** | It appears in **0** of the 13 corpus prompts. R1 says quoted, not paraphrased — and a phrase nobody typed is exactly the author-vocabulary failure the rule exists to stop. Removed. `"get up to speed"` became `"up to speed"`, which covers two prompts instead of one |
| **The trailing clause implied Camp answers the other requests** | *"load Camp first, answer the rest after"*. Camp does not — `SKILL.md`'s own table splits *"where are we"* from *"fix this · write this"*. Now *"load Camp first, then the main thread takes the rest"* |

## Retrospective

**The fix is one line and the verification is the hard part.** Three `Required` boxes resolved
against the tree, and the `Done when` cannot be run at all — so what ships is a change made to a
written rule, with no behavioural evidence behind it. That is worth stating plainly rather than
letting three green boxes imply the skill now fires.

**The instrument that was not built is the finding.** Box 3 wanted proof the bare shape did not
regress, and the natural gate — word overlap between prompt and description — was disproved by
the corpus in the same session it was designed. `camp` outscored both skills that fired. Building
it would have added a gate that goes green on the failure it was meant to catch.
