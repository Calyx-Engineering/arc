# Issue #266 — the provenance vocabulary, spec and field reconciled

**Issue:** [#266](https://github.com/Calyx-Engineering/arc/issues/266)  ·  **PR:** [#313](https://github.com/Calyx-Engineering/arc/pull/313)

## Problem

Two findings [#164](https://github.com/Calyx-Engineering/arc/issues/164) left behind, both about
the same table.

| | |
| --- | --- |
| **No term for a reading that is not a measurement** | `measured` covered a bench result and a number an instrument displayed with equal weight. On 2026-08-28 a scope reported 2.473 Vpp where the tone was 1.456 Vpp — a peak-to-peak reading cannot separate a tone from a tone plus a 433 kHz class-D carrier — and an estimate from that reading was taken over a bench measurement the user had verified. Under one word for both, that region held **one** source and graded `ONESIDED`: unscored, and invisible |
| **Two vocabularies were live** | The seven #164 specified, and the eight `rp2040-pin-allocation.md` had carried since the user repaired this defect by hand. Four of the field's terms had no rank at all, and a reader could not tell whether a row reading `schematic` outranked one reading `datasheet` |

**Two vocabularies is the defect wearing a label.**

## Decisions & trade-offs

| Decision | Why |
| :--- | :--- |
| **`instrument`, directly below `measured`** | It is an observation of the unit in hand — one notch weaker only because nothing has established the instrument was measuring what the claim names. It **becomes** `measured` when the rig and its limits are written down beside it, and that promotion path is what fixes its position |
| **Twelve terms, not a shorter merge** | Every one of the field's eight is a source this project genuinely has. #164's own extension rule says a project places a new term *in the order*; that is what this does, for four terms at once |
| **`thread` adopted, not mapped to `conversation`** | A thread is written down and can be read back; a conversation is neither. The field ranks it above a photograph, and it is right |
| **`schematic` rises above `datasheet` and `vendor`** | The only term that moves, and the field's ordering. A claim about *this board* is settled by this board's own sheets; neither the part's document nor the seller's label is about this board at all. Every other pair keeps the order at least one of the two vocabularies gave it |
| **The readout words moved off `measured`** | `meter`, `scope read`, `instrument read` were `measured`'s aliases. Leaving them there is exactly the collapse this issue exists to undo — the new term would have been a word in a table with no consequence in the matcher |
| **Guards, not bare words, for the adopted four** | See *What the review passes found* |

## Rejected approaches

| | |
| :--- | :--- |
| **A cell-shaped lookahead for `firmware`** | Written and removed. `grade_tables` joins a row's cells with a space **after** splitting them on the pipe, so there is no pipe left to look ahead to and `$` means the end of the row. It matched the fixture and would not have matched the ledger row it was written for |
| **Leaving the ordering conflict for the user** | It is the half that makes a merged list one list. Recorded here rather than deferred, because the field ordering is the user's own and adopting it defers to him |

## What the review passes found

Pass 1, on the shipped column:

| | |
| --- | --- |
| **Four aliases fired on ordinary English** | `the scope` on *"the scope of this document"* — the exact sentence its own comment claimed it excluded; `the meter` on *"300 meters of cable"*; `read off the` on *"read off the schematic"*; `the rig` on *"name the rig and its limits"*. Each puts a second source in play, and because the conflict column counts co-occurrence a false match does not mis-label a row — **it manufactures a conflict and lands `RESOLVED` in the numerator** |
| **`thread` was guarded and its own bare branches were not** | `the thread`, `a thread`, `in the thread` came across from `conversation` unguarded. A screw has a thread, in an electrical-engineering corpus, constantly |
| **`measurement` matched, `measurements` could not** | The trailing `\b` of the `\b(?:…)\b` wrapper. The same class as `extrapolat`, which #164 found and fixed one line below |
| **Four statements described the old vocabulary** | Including the file header's ordering line, which stated the seven in the present tense above a `PROVENANCE` of twelve |

Pass 2, on pass 1's own fixes:

| | |
| --- | --- |
| **The `firmware` guard could not fire on the row it was written for** | See *Rejected approaches*. Replaced with `(?<!in )` — *"fixed in firmware"* and *"disable CLKOUT in firmware"* are statements about behaviour, and a Provenance cell never reads *"in firmware"* |
| **`the instrument` survived the narrowing that removed `the scope` and `the meter`** | Same determiner-plus-noun shape, and this repo calls its own graders instruments |
| **Two negative fixtures could not go red** | `nt` is a global-absence check, and one pattern was also printed by a *positive* fixture. The other was keyed to `thread` when reverting the branches to `conversation` would print `conversation` |
| **One assertion was not pinned to its case** | `conflictweak` prints `asserted over the rest: instrument` too, so a regression in `instrumentreading` would have stayed green. `tc` exists for this and had not been used on it |
| **"One inversion" undercounted** | `schematic` rose above `vendor` as well as `datasheet` |

Pass 3, auditing the checklist against the tree:

| | |
| --- | --- |
| **The ladder's one move had no case behind it** | Nothing paired `schematic` with `datasheet` or `vendor`. It could be put back below both and the selftest stayed green — on the decision the issue calls the ladder's only move. Three fixtures now pin it, and `instrument`'s slot with it |
| **`phototerm` is decorative and now says so** | `photos?` was already an alias of `photograph`; #266 added the word *mapped* to three tables, not a matcher change. Kept, with the claim removed |
| **The body's own numbers were stale** | `63 passed` when the tree said 68, and *six new fixtures* when the diff had twelve. Corrected, and it is the exact defect this pass exists to catch |

## The result

```text
report-grade selftest        71 passed, 0 failed        (56 before)
tools/report-grade.sh        byte-identical to the baseline on all six real cases
```

**Reverting the ladder is what proves the fixtures.** `schematic` back below `datasheet` and
`vendor`, `instrument` to the bottom: **64 passed, 7 failed**.

**The real suite does not move, and that is the honest reading.**
`pin-allocation-ledger` scores `ROWS` off its `Provenance` header, so the adopted-term matching
never runs on it; every other case's verdict is unchanged. **The change is carried by fifteen
selftest fixtures, not by a corpus case** — recorded in the issue body as not done rather than
closed with an invented case.

## Findings

| Finding | Where it routes |
| --- | --- |
| **The 2026-08-28 document still cannot be an eval case.** `instrument` makes it a two-source region, which was the blocker #164 recorded — but `pr-68-gain-sweep-tool.md` carries no contrast marker across that pair, so it grades `SILENT` rather than a resolved conflict. The shape that cost the most is still the shape with no scoreable artifact | Needs an issue. It is #164's box 5, still unmet, for a **different** reason than before |
| **Bare `firmware` still matches an inference.** *"a firmware implementation would reach for the register"* is a hypothesis about code that does not exist, and reads as firmware-sourced. `(?<!in )` catches the preposition, not the mood | Recorded in the grader |
| **A guard the corpus cannot exercise is a guard held by fixtures alone.** Seven of the fifteen new fixtures are negative, and every one is synthetic. The real suite's six cases contain none of the false shapes | Recorded in the grader |

## Retrospective

**The vocabulary was the easy half; making it consequential in the matcher was the work.** A
term added to a table and not to `ALIASES` is #164's own warning — a word and not a rule — and
four of the five aliases the first draft wrote for the adopted terms fired on ordinary English
instead. *Drawing power*, *this report*, *a screw thread*, *the scope of this document*: each one
manufactures a conflict, and `RESOLVED` is the scored bucket, so a false positive is worse here
than a missed source. A missed source leaves a region unscored; a false one puts a fabricated
pass in the numerator.

**The three review passes found progressively narrower things and the last was the sharpest.**
Pass 3 asked only whether each ticked box had evidence behind it, and the answer for the ladder's
one move was no — three artifacts stated `schematic` above `datasheet` and nothing tested it.
That is a tick describing intent rather than the tree, which is the failure the pass exists for.
