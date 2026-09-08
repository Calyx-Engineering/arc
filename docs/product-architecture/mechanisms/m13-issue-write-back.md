# Mechanism — Tracker Write Verification

**Status:** specified. Carries the evaluation set for `issue-writing`.
**Home:** Arc — Authoring.
**Spawned from:** [friction-transcript-log.md](../../retrospectives/2026-08-plugin-line/friction-transcript-log.md) §2.7, and David's framing, 2026-08-16.

---

## David's framing

> *"So often i see you doing the fantastic work of checking that changes you intended to
> make actually happened. These are examples of where that didn't properly execute for
> the issue writing. So this should be used as an evaluation against the issue-writer."*

Two things follow:

1. **The verify-after-write behaviour was believed to exist** for file edits, and to be
   missing only for tracker writes. **Arc 03 disproved the first half** — see *Shape B
   occurs in files too* below. Both need the check.
2. **These cases are test cases.** They are a ready-made evaluation set for
   `issue-writing` — a skill that already exists and demonstrably does not close this
   gap.

---

## The failure has three distinct shapes

Six instances across four weeks split cleanly into the first two; the third was isolated later:

### Shape A — the write never happened

> *"i asked you to update #12 with the new component selection. i checked and that didn't
> happe. please do that before we forget again"* — 2026-08-11

> *"update this issue at the end of the check list to double check if this is still an
> issue once we've updated to the new pinout"* — 2026-08-03, an agreed action with no
> filing step

An action was agreed mid-conversation and never executed. Caught only because David
happened to check.

### Shape B — the write happened but stale content survived

> *"the cispr 25 class 3 plot still has placeholder values"* — 2026-08-11

> *"please update the conducted voltage against cispr figure for the actual limits and
> specifications (one example is it still has 3.3uH)"* — 2026-08-11

> *"note the 'date 10/26' doesn't make sense … Please update #38"* — 2026-08-13

An edit was made and reported as done; some part of the target was not actually updated.
**This is the more serious shape** — it reports success and is wrong, so it defeats the
human's assumption that a completed edit is complete.

Note both 2026-08-11 cases are the *same session*, minutes apart: a partial update
leaving placeholder values behind, twice.

### Shape C — the write happened, into a section that does not admit it

> *"you wandered again. in the \"spawned\" section of PR70 you're throwing down random
> decisions or thoughts. thats not what the section is for..."* — ROADZ, 2026-08-14

> *"why are you adding documents to the spawned section?"* — ROADZ

Eight distinct corrections between 2026-08-14 and 2026-09-05. The body was written, the write
landed, and the read-back confirmed it — because the read-back compares the body against
*intent*, and the intent was wrong. Documents, discarded approaches and loose thoughts were
filed as spawned work; issues that did belong were missed.

**This shape is invisible to every check above.** A placeholder scan finds nothing, a date
check finds nothing, and the link bound correctly. What is wrong is that content sits under a
heading whose definition excludes it — and a definition given only as a positive test
("something this effort caused") admits anything session-shaped. The fix is a stated negative
case and a section order, [#135](https://github.com/Calyx-Engineering/arc/issues/135).

---

---

## Why it matters more for trackers than for files

| | File edit | Tracker write |
|---|---|---|
| Verification | The tool errors if the *match* fails — never that the *claim* is complete | API returns success regardless |
| Visibility | The diff is in front of the user | Lives on a website nobody re-opens |
| Detection | Immediate, if the person reads the whole diff | Only when someone happens to look |
| Existing behaviour | **Not verified** — see below | **Not verified** |

The asymmetry originally claimed here was that files are verified routinely and trackers
are not. **That is wrong, and the correction matters more than the original finding.**

### Shape B occurs in files too

An edit tool erroring on a failed string match proves the string was replaced. It proves
nothing about the other places the same claim appears — a summary row, a diagram label, a
count in a sentence. A partial edit reports success exactly as a tracker write does.

Arc 03, one session, one file: **four consecutive edits reported complete while another
surface of the same file still said the opposite.** Each was caught by the person, not by
any check.

The check is a `grep` for the *replaced* string before reporting done — zero hits, or the
edit is not finished. It lives in
[`skills/work-watch`](../../../skills/work-watch/SKILL.md) as check 4, because the moment it
fires is the moment an edit is about to be called done.

**Check 5 is this mechanism's other half.** Write-back is what makes the tracker *correct*;
check 5 is what makes it *current* — ticking a done item and reading it back, so the checklist
still says where the work is. Both fire on an act rather than a pause.

**Same failure class as §2.8** (tracker mechanics) and the dropped-staged-files case in
[commit-rhythm](m14-commit-rhythm.md): mechanisms that **report success and do the wrong
thing**. `issue-writing` already opens with exactly this warning —

> *"Every mechanism here fails silently."*

— and the skill still did not prevent these six cases.

---

## The evaluation set

Each row is a real case with a checkable outcome. Any change to `issue-writing` should
be tested against these.

| # | Date | Case | Correct behaviour |
|---|---|---|---|
| 1 | 2026-08-11 | Agreed to update #12 with component selection; never done | Action filed at agreement time; verified before session end |
| 2 | 2026-08-03 | Agreed to add a checklist item to an issue | Same |
| 3 | 2026-08-11 | Figure updated, placeholder values remained | Re-read after write; detect placeholder patterns |
| 4 | 2026-08-11 | Figure updated, stale `3.3uH` remained | Re-read after write; diff against intended change |
| 5 | 2026-08-13 | Issue #38 carried a nonsensical date | Sanity-check dates against reality |
| 6 | 2026-07-26 | Comment on #1 referenced the wrong commit | Verify referenced commit exists and is the right one |
| 7 | 2026-08-14 | `Spawned` populated with documents, a discarded approach, and loose decisions | Reject what is not a unit of work; route each to where it belongs. `tools/verify-tracker-body.sh body` reports the section's placement, the author judges the rows |

**Pattern in shapes:** cases 1–2 are *never written*; cases 3–6 are *written wrong and
reported right*; case 7 is *written right into the wrong section*, which no read-back catches.

---

## Proposed shape

### 1. Read back after every tracker write

The behaviour that already exists for files, applied to trackers.

```sh
gh issue view <N> --json body,title
gh pr view <N> --json body,closingIssuesReferences
```

Compare against intent. Report the mismatch, do not silently retry.

### 2. Detect placeholders and staleness

Cases 3–5 are mechanically catchable — scan written content for:

- `TBD`, `XXX`, `placeholder`, `<value>`, `TODO`
- Numbers that were meant to change but did not (diff old against new)
- Dates that are impossible or inconsistent with the current date

### 3. Capture agreed actions at agreement time

Cases 1–2 are not verification failures — the write never started. The action was
agreed in conversation and had nowhere to go.

**Same structural problem as requirements capture:** something said in conversation,
with no natural moment to bind a mechanism to. Candidates:

| Option | Note |
|---|---|
| Running action list in the handoff | Fits [handoff-spine](m15-handoff-spine.md); no new artifact |
| Checkpoint sweep — "these were agreed; filed?" | A moment that already exists |
| File immediately on agreement | Fastest, but risks tracker noise from provisional talk |

Leaning: capture into the handoff immediately, file at a checkpoint.

### 4. Verify the link actually formed

Already known and documented in ROADZ `CLAUDE.md` — `Closes #NN` silently fails against
a non-default base branch.

```sh
gh pr view <N> --json closingIssuesReferences   # empty means it did not link
```

---

## Open questions

| Question | Notes |
|---|---|
| Hook or skill step? | Read-back is mechanical → hook. Judging "did this match intent" → skill |
| Where do agreed-but-unfiled actions live before filing? | Handoff is the leading candidate |
| Does this extend to wiki and report writes? | Same silent-success risk wherever content is written and not re-read |
| How is the evaluation set run? | No harness exists yet. Manual until one does |

---

## Related

- [friction-transcript-log.md](../../retrospectives/2026-08-plugin-line/friction-transcript-log.md) §2.7, §2.8
- [commit-rhythm.md](m14-commit-rhythm.md) — dropped staged files, same silent-failure class
- [handoff-spine.md](m15-handoff-spine.md) — proposed home for pending actions
- ROADZ `.claude/skills/issue-writing/SKILL.md` — the skill under evaluation
