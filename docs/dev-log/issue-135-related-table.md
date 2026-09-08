# Issue #135 — Spawned accepts things that are not work

> Decision log, not a spec.

**Issue:** [#135](https://github.com/Calyx-Engineering/arc/issues/135)  ·  **PR:** written in when it opens  ·  **Batch:** #87 #135 #193, one PR

## Problem

`skills/issue-write` defined `Spawned` by a positive cause test — *this effort caused it to
exist* — and never said what is inadmissible. A positive test alone admits anything
session-shaped. Observed in ROADZ: eight corrections between 2026-08-14 and 2026-09-05, with
documents, a discarded approach the dev-log had already ruled out, and loose decisions all
filed as spawned work, while issues that did belong were missed.

The skill also still specified two sections — a bulleted `Related` and a separate `Spawned` at
the end — while practice had moved to one `Related` table with the kind in the left column.

## What changed

| | |
|---|---|
| **`skills/issue-write`** | *Spawned versus related* replaced by *Related — one table, four kinds*. One section, one table, four kinds, the negative case stated, the keep-marked rule carried over onto the table shape |
| **`tools/verify-tracker-body.sh`** | `body` gains a second rule: a `Spawned` heading followed by any other heading is reported |
| **`tools/tracker-cases/body/`** | Three fixtures — one fail, two pass |
| **m13** | Shape C and evaluation case 7 — the write landed, into a section that does not admit it |

## Decisions

### The two halves of the issue disagreed, and the later one wins

`Required` says *"`Spawned` is stated as the **last** section, in an explicit section order"*.
The 2026-09-07 block below it says there is **no separate `Spawned` heading** — one `Related`
table instead.

Resolved by reading the first as a statement about **where the spawn rows sit**, not about a
heading:

- The section order is stated explicitly, as a numbered table: Opening, `Required`,
  Constraints, `Related`.
- `Related` is last, and the spawn rows live in it, **so the spawn edges are the last thing in
  the body** — which is what the box was protecting.

The box is ticked on that reading. If the intent was a literal `Spawned` heading placed last,
this is the half to look at.

### The check reports the heading, never the rows

Whether a row is a unit of work is not decidable from text — it is exactly the judgement the
skill now teaches. Where the section sits **is** decidable. So the check reports a `Spawned`
heading with a heading after it and says nothing about content, which is the issue's
*reports, never rewrites* constraint.

Two details worth keeping:

| | |
|---|---|
| **Fenced blocks are skipped** | A `# comment` in a shell snippet after the `Spawned` heading would otherwise read as a later section. The awk pass tracks the fence |
| **`body` keeps one exit code** | Both rules run and both print; the caller wants every finding in one read, not the first one. `check_body` became a dispatcher over `check_keyword_placement` and `check_spawned_last` |

### `Blocked by #NN` stays as a bare line as well as a table row

`| Blocked by | [#136](…) |` splits the words from the number across two cells, so a grep for
`Blocked by #[0-9]+` finds nothing. The table is for the reader, the bare line is for the
driver, and neither substitutes for the other.

### The four kinds are closed

`Spawned by`, `Spawned`, `Blocked by`, `Related`. *Creates*, *Depends on* and *See also* were
each reached for during this work and are each a synonym for one of the four. One word per
meaning, or the first column sorts nothing.

## What the review passes found

Pass 1 established that the first version of the check was **inert on every body the new skill
produces.** It fired only on a `Spawned` heading, and the skill it enforces abolishes that
heading in favour of rows inside `Related`. It printed `PASS  no Spawned heading` — a pass whose
text was an assumption, not a reading.

Two consequences, both fixed:

| | |
|---|---|
| **`Related` is a terminal section too** | The rule is *the spawn edges are last*, and the check now reports a heading after either `Related` or `Spawned`. Two more fixtures — one fail, one pass |
| **The title has to be the whole heading** | A substring match reported `### Spawned versus related` as the section and then flagged every heading after it. Anchored to the complete title, bold and backticks stripped. A third fixture covers it |

Pass 2 then reviewed those fixes and found two more, both in the fix rather than in the original:

| | |
|---|---|
| **`head -n1` picked the wrong terminal section** | A body in the older two-section shape carries `Related` and then `Spawned`. It is the **last** of them that has to be last, and taking the first reported a correctly-formed legacy body as a defect — the very shape the widened check claims to support. `tail -n1`, plus a fixture |
| **Anchoring the title made the match CR-sensitive** | The pre-fix regex had no `$`, so a trailing `
` was harmless. A body read out of `gh pr view --json body` is CRLF — this file's own `live_norm` exists for that reason — so the documented flow would have fed the check input on which every terminal heading is invisible, and it would have printed a pass. `tr -d '
'` |

**A note on the commit message for `f0b6ce7`.** It claims a fix for a `grep -inE` whose index
shadowed the file's line number. That bug was real but was introduced and removed inside the same
editing session; it never reached a commit, so the message describes a fix to code no reviewer
could find. The fixtures caught it, which is what they are for — but it was not a review finding.

## Evidence

`bash tools/verify-all.sh` — 19 gates, all clean. `tracker body rules` went from 19 cases to
26: three fixtures for the `Spawned` heading, and three more from the review passes.

## Not done

Every box in `Required` is ticked. One is ticked on a reading rather than on a literal match:
*"`Spawned` is stated as the last section"* is satisfied by `Related` being last with the spawn
rows in it, because the same issue abolishes the `Spawned` heading. That reasoning is above, and
it is the box to look at if the intent was a literal heading.
