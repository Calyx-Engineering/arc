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

## Evidence

`bash tools/verify-hook.sh hooks/tracker-verify` — 31 passed, 0 failed, exit 0.
`bash tools/verify-all.sh` — 13 gates, all clean, exit 0.

The new pass cases were checked for vacuity rather than assumed: swapping one case's base to
`arc/09-other` and changing nothing else produces the finding, and setting
`arc_test_milestone: null` produces the milestone finding. The fixture path is live.
