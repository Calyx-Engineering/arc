# Issue #270 — a run's findings go to the dev-log, never a `Spawned` table

> Dev-log, not a spec. Started at plan time, finalised as a retrospective at PR time.

**Issue:** [#270](https://github.com/Calyx-Engineering/arc/issues/270)  ·  **PR:** [#288](https://github.com/Calyx-Engineering/arc/pull/288)

## Problem

Nine of arc 04's Fire children carry a `Spawned` heading and eight of those hold findings —
observations, defects spotted in passing, premises that turned out wrong — rather than units of
work. `skills/issue-write` says there is no separate `Spawned` heading and that `Spawned` holds
units of work only.

The cause was one sentence. `docs/arc-work/04-dogfood/run-instructions.md` §5 told every run
*"Record it in the issue's `Spawned` table"*, and a run reads that file and its issue body and
nothing else. Nine runs did what they were told.

## Intent and north star

**Written before the plan, in two passes.** Pass 1 from the issue body alone; pass 2 after reading
`skills/issue-write`'s *Related — one table, four kinds*, `templates/issue.md`, and
`hooks/tracker-verify`. Pass 2 changed one thing: the fix is not only the sentence. The sentence
is why nine bodies are wrong, but nothing mechanical would have caught the tenth, so the issue's
second box asks for the hook.

| | |
|---|---|
| **What this issue is really for** | The instruction a run reads and the check that fires on what it writes have to agree. One sentence in `run-instructions.md` disagreed with the skill, and the tracker recorded nine bodies in a shape this repo does not have |
| **North star** | A run told to record something routes a finding to the dev-log and a filed issue to a `Related` row, is shown one row shape, and gets a finding from `tracker-verify` if it writes a `Spawned` heading anyway |
| **What makes it durable** | The check is mechanical and fires on the write. A prose rule that nine runs walked past is not evidence that the tenth will not |
| **Out of scope** | **The nine existing bodies are not rewritten** — that is a tracker edit across nine issues in another workstream's children, and this unit is the instruction and the guard. **`tests/verify-tracker-body.sh body` does not learn the rule** — three of its pass cases carry a `Spawned` heading deliberately, because `check_spawned_last` exists to place a *legacy* section correctly, and teaching `body` to reject the shape would flip all three. **§6's boundary report keeps its `Spawned` section** — that is a report's own heading, not an issue body |

## Decisions & trade-offs

**The check lives in the hook, not in `tests/verify-tracker-body.sh`.** The precedent runs the
other way — the title rules are shelled out to that script so one copy of a threshold exists —
so this needed a reason. It is that `check_body`'s existing `check_spawned_last` *tolerates* a
`Spawned` section by design, and its cases prove it:

```
tests/tracker-cases/body/pass/legacy-two-sections.md:8:## Spawned
tests/tracker-cases/body/pass/spawned-heading-last.md:9:## Spawned
tests/tracker-cases/body/pass/spawned-word-inside-a-fence.md:3:## Spawned
```

Adding the rule to `check_body` flips three passing cases to failing. The two questions are
genuinely different — *where is the section* versus *is there a section at all* — so they are
answered in different places rather than one of them being weakened.

**The heading, never the rows.** `| **Spawned** | [#NN](…) | … |` stays silent. Whether a given
row is a unit of work is the author's judgement and is not decidable from text; whether a section
exists is. The same division `check_spawned_last` already draws.

**The title must be the whole heading, matched case-insensitively.** `## Spawned versus related`
is prose about the section, not the section. Bold and backticks are stripped, nothing else is
allowed after the word, and headings inside a fenced block are not headings — a body quoting the
wrong shape in order to say it is wrong must not be reported for quoting it.

### The fixture-body newline, which cost the most time here

`hooks/tracker-verify`'s `fixture()` reads a case payload with parameter expansion and nothing
unescapes it, so **a fixture body carries literal `\n` and a live body carries real newlines.**
Measured, not assumed:

```
RAW: [## Required\n- [ ] x\n\n## Spawned\n]
--- line count:
1
```

Every other scanner in that hook is a line-agnostic `grep`, so none of them ever noticed. This one
is anchored at `^`, so it would have passed every case and then fired correctly in a live session
— or the reverse — with the case suite green either way. The scan splits on the escape when the
body carries no real newline, and leaves a live body alone: a live body may legitimately contain a
literal `\n` inside a fence, and rewriting that would move the fence markers.

### The gate

```
bash tests/verify-all.sh                        → exit 0, 47 gates, all clean
bash tools/verify-hook.sh hooks/tracker-verify  → exit 0, 70 passed, 0 failed
```

Before the hook change, with the two report cases already written: `67 passed, 2 failed`.

## Rejected approaches

| | Why |
|---|---|
| **Teach `verify-tracker-body.sh body` the rule** | Flips three deliberate pass cases. Above |
| **A new `spawned-heading` subcommand in `verify-tracker-body.sh`, called by the hook** | The shared-home argument applies to *thresholds* that drift. This is a heading regex with one caller, and the extra subcommand buys a second dispatch path and a second set of cases for nothing |
| **`printf '%b'` to unescape the fixture body** | Interprets every backslash escape, not only `\n`. A live one-line body carrying `\t` or `\\` would be silently rewritten |
| **Rewrite the nine existing bodies** | Nine tracker edits in another workstream's children. Recorded as a finding below, not done here |

## Spawned

**This heading is `templates/dev-log.md`'s, not an issue body's** — it holds what the work produced beyond the diff, which is where this issue says a finding goes. Nothing was filed. Two findings:

- **The nine existing Fire children still carry the wrong shape.** `hooks/tracker-verify` fires on
  `gh issue edit`, so the next edit of any of them reports it. Nobody has to sweep them, and
  nobody will fix them by accident either.
- **A finding that was retracted, kept because retracting it is the point.** Mid-run this dev-log
  said `tools/verify-hook.sh`'s output interleaves — the new cases' description lines were missing
  from the captured output and an earlier `tail` showed duplicated half-lines. Both readings were
  of a file the run was still writing. On a completed run every description renders in order.
  **The tool was fine; the observation was taken too early.** Left here rather than deleted,
  because a dev-log that only records findings that survived is a dev-log nobody can calibrate.

## Retrospective

Three boxes, two files, six cases. The instruction and the guard both landed, and the cases went
in before the hook did — the two report cases failed on the unfixed hook, which is the only
evidence that they test anything.

### What the review passes changed

Pass 1 found eight things and four of them changed the tree.

| | |
|---|---|
| **The pattern is anchored at `$` and nothing stripped the CR** | A live body out of `gh issue view --json body` is CRLF, and a carriage return before the anchor makes every heading invisible. `tr -d '\r'` now runs before the awk — what `tests/verify-tracker-body.sh`'s placement check already did, for the reason it already states. **The failure is not reproducible on this machine**: Git Bash's gawk strips the CR itself, so the length of a CRLF line reads there the same as an LF one. The guard is asserted from the sibling check's stated reason and from the anchor, not from a local failure — and no case can cover it, because a JSON fixture body cannot hold a raw CR |
| **Case-sensitive where the check it claimed parity with is not** | `## SPAWNED` passed. Now matched with `tolower($0) ~ /…/`, so the two tools cannot disagree about whether a legacy body has a section |
| **Nothing pinned the issue-only gating** | The scan is deliberately gated to issue writes on both paths — an inner `case` on the fixture path, the outer `*"gh issue"*` arm on the live one — and every case still passed with that gating removed. `pass/pr-edit-spawned-heading.json` is the case that fails if it is hoisted out. **It pins the fixture path only.** The live gate needs a live `gh issue view`, so no fixture can reach it |
| **Two cross-references were loose** | §5 said findings go where "§2 step 7 already sends it". Step 7 does write the dev-log — it reads *"Dev-log, commit, open the PR as a draft"* — so the old sentence was vague rather than false; it now says "the dev-log it writes at §2 step 7". The second was the real one: §5 told a run to add a `Spawned` row without mentioning that `tracker-verify` also reports a `gh issue create` whose body carries no `Spawned by`, a finding on the very write §5 had just asked for. That is this issue's own north star one level down |

**Pass 2's subject was pass 1's own edits, and it found real damage — in this file.** The script
that rewrote these sections was a Python heredoc, and the `\r` and `\n` it was documenting reached
the file as a raw carriage return and a raw newline, splitting a table row in two and deleting the
escape from the sentence whose whole subject was that escape. It also caught a measurement quoted
in support of the CR guard that was simply wrong, and a claim that a cross-reference was broken
when the text quoted alongside it showed it was not. **A scripted edit to a document about escape
sequences will eat the escape sequences**; the repair used `chr(92)` rather than a literal.

**`pass/issue-edit-spawned-row-not-heading.json` is intent documentation, not evidence.** It guards
a line starting with `|`, which a `^#+` anchor cannot match under any plausible variant of the
regex. `tools/verify-hook.sh` verdicts on the exit code alone, so every `pass/` case in this suite
would pass with the check deleted; the fence case and the prose-heading case still earn their keep
because each fails against a realistic regex mistake. This one does not. Kept, and named here so
nobody counts it as coverage.

### The one thing a future reader needs

**The fixture path and the live path of `tracker-verify` hand a body to a scanner in two different
shapes**, and only a line-anchored check can tell: fixtures carry a literal `\n` and no CR, live
bodies carry real newlines and CRLF. Anything added to that hook which reads the body by line has
to handle both, and the case suite can only ever prove one of them.
