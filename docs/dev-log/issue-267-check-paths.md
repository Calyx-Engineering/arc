# Issue #267 — the handoff's six pre-existing checks declare a path

**Issue:** [#267](https://github.com/Calyx-Engineering/arc/issues/267)  ·  **PR:** <link>

## Problem

`skills/handoff` declares thirteen checks across two paths and only seven of them said which
path they run on. [#208](https://github.com/Calyx-Engineering/arc/issues/208) added its seven
staleness checks with `(the write path — no handoff is being acted on)`; the six that predate it
were bare. `camp-reports.md` reads a bare name as having run, so a `handoff-read` report claimed
the transcript had been saved and stale rows removed — neither of which a read performs.

## Intent and north star

| | |
|---|---|
| **What this issue is really for** | A declaration split across two paths is not complete until every check names its path. The half-annotated list reported confidently and wrongly on both paths, which is worse than reporting nothing |
| **North star** | Every name in `checks:` resolves to a path, and a gate fails when the next check is added bare |
| **What makes it durable** | `tools/verify-handoff-checks.sh` parses the frontmatter rather than grepping the file, and asserts the path rather than the presence of an entry — so a check added bare, or with a condition naming no path, fails the run that added it |
| **Out of scope** | Extending `camp-reports.md`'s three fields. A `paths:` field would be a definition change routed through the product definition, and `skips` already carries a condition — a path is one |

Pass 2, after reading `camp-reports.md` and `hooks/mode-guard`: unchanged. The hook's own
declaration uses the same shape — `skips: mode-row (the command is not one the mode governs)` —
so a path stated as a skip condition is the established form, not a new one.

## Decisions & trade-offs

**The path is declared as a `skips:` condition, not as a new field.** `camp-reports.md` gives
`skips` one job: make a declared-but-unrun check visible, with the condition that suppressed it.
"The write path" *is* that condition. Twelve of the thirteen checks are path-exclusive, so
twelve entries.

**`ordered-actions-present` is the only both-path check, and it is named in the body.** It is
read before the ordered actions are executed and required when the handoff is written, so it
skips on neither and has no `skips:` entry to carry its path. A check with no entry would
otherwise be indistinguishable from the defect this issue fixes, so the skill states the
both-path set explicitly and the gate reads that line.

**`graduated-to-record` keeps its original condition and gains a path.** Its skip was
content-conditional — nothing in the handoff outlives the arc — and that is a reason to skip on a
write. The entry now opens with the path it never runs on and keeps the content condition after
it, because dropping either would lose a real one. It names one path, not two: an entry naming
both would declare a check that never runs, and the gate cannot tell that from a correct one.

**The gate parses the frontmatter and asserts the count first.** A membership test over an empty
parse passes for free. It reads the `checks:` line, the `skips:` block and the both-path line,
and fails in both directions: a declared check with no path, and a skip naming a check the skill
no longer declares.

**The gate ships a selftest, because the denial runs were otherwise prose.** Its two sibling
handoff gates carry one and this did not, so nothing in the tree reproduced the four ad-hoc
fixture runs the first draft of this dev-log cited. `tools/verify-handoff-checks.sh selftest` is
seven cases — the skill as it stands, and six mutations of it — wired into `verify-all.sh`
beside the gate itself.

**The condition must *open* with the path, not merely contain the words.** Matching them anywhere
is the same hole one step further in — `(only when a body was edited on the read path)` would
pass a condition that declares no exclusivity at all.

## Rejected approaches

**Annotating the `checks:` line itself** — `checks: [handoff-exists (read), ...]`. It puts the
path where the issue's wording points, and it breaks the field for every other artifact: the
list is a list of names, and `verify-hook.sh` and Camp both read it as one.

**Leaving the both-path check bare and treating absence as "runs on both".** That is the state
this issue is fixing, one check smaller. Absence is what a forgotten annotation also looks like.

## Spawned

- **Issues:** none.

## Retrospective

The gate was written before the frontmatter, and it failed on the five bare names —
`ordered-actions-present` among them — reproducing the defect mechanically before any fix. It
passed `graduated-to-record`, whose entry carried a condition and no path: five-sixths of the
six the issue names, and the missing sixth is the same hole the next paragraph reports.

**Two defects in the gate itself, both found by pass 1 rather than by a run.** It read `--` out
of the frontmatter terminator as a check name, and — the expensive one — it asserted that a
check *has* a `skips:` entry, not that the entry names a path. `camp-reports.md`'s own example
condition, `placeholder-scan (only when a body was edited)`, would have satisfied it while
leaving the requirement unmet. The six denial cases now in the selftest each exit 1: a bare name, a condition
naming no path, a content condition with `on the read path` appended to it, a skip for a check
the frontmatter no longer declares, a name declared both-path and skipped at once, and the
both-path line deleted. The control case — the skill as it stands — exits 0.
