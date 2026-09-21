# Issue #183 — tracker-verify rejects a conforming PR base

**Issue:** [#183](https://github.com/Calyx-Engineering/arc/issues/183)  ·  **Parent:** [#145](https://github.com/Calyx-Engineering/arc/issues/145) — Fire

## The defect

The base rule fired when the PR's base equalled the **GitHub default branch**:

```sh
if [ -n "$DEFAULT" ] && [ "$BASE" = "$DEFAULT" ]; then
  add "PR #$NUM targets \`$DEFAULT\` from an issue branch. … base it on \`$ARCBASE\`"
```

[m42](../product-architecture/mechanisms/m42-default-branch-flip.md)'s flip points the default
at the active arc for the arc's lifetime, so mid-arc `$DEFAULT` **is** `arc/04-dogfood` — and
`$ARCBASE` is `arc/04-dogfood` too. The message named the branch the PR was already on. Four
firings in one session: [#178](https://github.com/Calyx-Engineering/arc/pull/178),
[#179](https://github.com/Calyx-Engineering/arc/pull/179),
[#180](https://github.com/Calyx-Engineering/arc/pull/180),
[#182](https://github.com/Calyx-Engineering/arc/pull/182).

## The fix

Compare against the arc branch the **head branch's own name carries**, not the GitHub default.
`arc/04-dogfood-issue-183-x` belongs on `arc/04-dogfood`; anything else is the finding.

That is stronger than what it replaced, not weaker. The old rule caught exactly one wrong base —
the default branch. The new one also catches a PR stacked on a sibling issue branch, which the
issue names as a genuine finding and which fired on nothing before.

**What did not change is when the rule runs at all.** Before and after, it is skipped unless
`git rev-parse HEAD` in the payload's `cwd` is an `arc/*-issue-*` branch. A `gh pr edit` issued
from the arc branch, or from a worktree that is not the PR's head branch, sees no base check.
That is a real limit, and it is the one this work did not touch.

`ARCBASE` now strips from the `-issue-<number>` marker instead of taking two hyphen-separated
segments. The old pattern returned nothing for an arc slug carrying an extra hyphen, and an
empty `ARCBASE` turns the check off silently.

**The closing-keyword rules still compare against `$DEFAULT`, deliberately.** GitHub parses a
closing keyword only on a PR targeting the repository default, so while the flip is on, the arc
branch is the right comparison there. Same variable, different question.

## The PR checks had no offline test path

`arc_test_body` and `arc_test_title` exercise the issue scanners without a network. Nothing
equivalent existed for the PR path, so `pr-base`, `milestone` and `arc-prefix` had **zero
cases** — the rule that misfired four times had never been run by the gate.

Four more fixture fields (`arc_test_pr_base`, `arc_test_default`, `arc_test_milestone`,
`arc_test_linked`) stand in for what `gh pr view` and `gh repo view` would have returned. The
head branch still comes from a real `git rev-parse` in a fixture repo, which is the half
`verify-hook.sh` insists on.

Two consequences worth naming:

| | |
|---|---|
| **`command -v gh` moved** | It now guards only the live path. A fixture case answers every question `gh` would have, and skipping it for want of `gh` turns a case that should report into a silent pass |
| **The cases say arc 02, not arc 04** | `verify-hook.sh` is excluded from autonomous edits, so its fixture repos are fixed. The four real firings are reproduced in shape — issue branch, base = its arc, default flipped onto that same arc — on `arc/02-foundation` |

**Be clear about what the four firing cases are worth.** They are one reproduction copied four
times, differing only in the PR number, which no code path reads for anything but the message.
Their value is provenance in the case comments, not test power; the discriminating coverage is
`pass/pr-base-is-arc-branch-default-flipped.json`. The shape was checked rather than assumed —
splicing the pre-fix `[ "$BASE" = "$DEFAULT" ]` comparison back in reproduces the #183 symptom
text on the case payload, and the current hook is silent on it.

## What the review passes caught

**The first malformed case was vacuous.** Truncated *before* the `command` key, it exited at
the command extraction and never reached the fixture path. Truncating *after* the command
exposed a defect this work had introduced:

```
- PR #200 targets `"arc_test_pr_base":"arc/02-found` from an issue branch of `arc/02-foundation`.
```

`field()` prints the line unchanged when its `sed` cannot parse it, so a value cut off mid-string
carries its own key and quotes into a user-facing finding.

The first fix guarded the base against characters no ref name has. The second pass was right
that this was the wrong verb and the wrong place: `exit 0` silences the whole hook rather than
one check, the class rejects ref names git accepts, and **the same leak was open on
`arc_test_body`** — where `scan_placeholders` echoes the matched line straight into the
finding — and on three other fields.

The fix is a `fixture()` extractor of its own, `sed -n … p`, so an unparseable value yields
nothing rather than itself. `field()` is left alone: it splits on commas, and its passthrough
is load-bearing for the comma-carrying bodies in the existing cases — replacing its `sed` broke
two of them. One guard then covers every field: a payload that names an `arc_test_` key and
yields no value from any of them is truncated, not an invocation, and stays silent rather than
sending a half-named PR to a live `gh` read.

As a side effect the two comma-carrying fixtures now parse whole. `arc_test_body` was being
truncated at its first comma all along.

**Three fixture fields were readable but driven by no case** — `arc_test_milestone`,
`arc_test_linked`, and the `default-branch` half of `closing-keyword`. `milestone` and both
halves of `closing-keyword` now have one each. Note the milestone sentinel is the quoted string
`"null"`, matching the shape `gh pr view` returns; a bare JSON `null` is not extractable and
would silently pass.

## A finding about the gate, not about this hook

The suite is intermittently red. Roughly one run in eight, one case flips from `report` to
`allow` — a different case each time, and re-running is green.

It is not this hook. `tools/verify-hook.sh` proves the kill switch by creating
`$HOME/.claude/HOOKS_OFF`, running a report case, and deleting it. **That path is global to the
user, not to the run.** Anything else invoking a hook during that window is silenced: another
gate run, another worktree, a live Claude Code session. Three were running here.

Measured on one case payload, 120 invocations each:

| `HOME` | silent runs |
|---|---|
| a private `mktemp -d` | **0 / 120** |
| the real `$HOME` | **18 / 120** |

The live-session half is the sharper edge — for the length of that window every Arc hook on the
machine is inert, and nothing says so. `tools/verify-hook.sh` is hard-excluded from autonomous
edits, so this is recorded rather than fixed. `docs/dev-log/issue-210-tracker-verify-trunk.md`'s
*Findings* carries it.

## Evidence

`bash tools/verify-hook.sh hooks/tracker-verify` — 31 passed, 0 failed, exit 0 **at this
commit**. #210 and the review passes add six more; the count on the merged branch is 37.
`bash tests/verify-all.sh` — 13 gates, all clean, exit 0.

The new pass cases were checked for vacuity rather than assumed: swapping one case's base to
`arc/09-other` and changing nothing else produces the base finding, and adding
`"arc_test_milestone":"null"` to an otherwise-identical payload produces the milestone finding.
The fixture path is live.
