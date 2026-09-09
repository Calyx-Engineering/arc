# Issue #204 — A milestone item is one unit of work

> Dev-log, not a spec. Started at plan time, finalised as a retrospective at PR time.

**Issue:** [#204](https://github.com/Calyx-Engineering/arc/issues/204)  ·  **PR:** [#257](https://github.com/Calyx-Engineering/arc/pull/257)

## Problem

Every PR in the Dogfood milestone also had a milestone, including the ones that close an
issue. The issue and its PR are the same unit of work, so each landed twice: percent complete
climbed twice against a denominator that had counted the same thing twice. The milestone view
also had no way to tell a direct PR from an issue-closing one, because every PR was in it.

`hooks/tracker-verify` enforced exactly the wrong thing — a milestone on **every** PR.

## Intent and north star

| | |
|---|---|
| **What this issue is really for** | The milestone view is the only place a human sees the arc as one unit. It has to count units of work, not tracker objects |
| **North star** | A PR in the milestone is, by definition, a direct PR. Nothing else has to be read to know it |
| **What makes it durable** | The hook reports both directions — a missing milestone on a direct PR, and a present one on a closing PR. A rule with only one half enforced drifts back through the unenforced half |
| **Out of scope** | The arc-02 and arc-03 milestones, which still hold 22 issue-closing PRs. The issue names Dogfood |

## Decisions & trade-offs

| | |
|---|---|
| **The keyword decides it, never `closingIssuesReferences`** | On a base other than the default nothing binds and closure defers to the arc PR — but the issue exists and carries the milestone either way. Reading the link would hand every issue PR in an arc its milestone back |
| **The answer and the name are two variables** | `null` and `set` are both legal milestone titles. `HAS_MILESTONE` holds the answer; `MILESTONE` holds the name the finding prints. One string cannot do both without a milestone called `null` reading as no milestone at all |
| **Three states, not two** | A `META` carrying neither `"milestone":null` nor `"milestone":{` means the field could not be read, and neither default is safe — absent-means-set invents a milestone on a closing PR, absent-means-none demands one on a direct PR. It skips, and the `skips:` header says so |
| **Eleven existing cases gained an explicit `arc_test_milestone`** | The fixture default is `set`, and those cases all carry `Closes #10`. Left alone, each would have flipped to a milestone finding — the four new cases would have passed while eleven neighbours silently changed meaning |
| **The rule went into `templates/pr.md` and `close-sequence.md` too** | The issue named `skills/issue-write`. A rule stated in the skill and contradicted at the point the field is actually set is not stated |

## Rejected approaches

| Rejected | Why |
|---|---|
| Keying the check on `closingIssuesReferences` | It is empty on every issue PR based on an arc branch, so every one of them would be told to carry a milestone |
| Leaving `report/pr-no-milestone.json` where it was | Its body carries `Closes #10`, so under the new rule it is the *passing* case. Renamed to `pr-direct-no-milestone.json` and rewritten, rather than left asserting the opposite of the rule |
| Widening the closing-keyword regex to `owner/repo#42` and issue URLs | GitHub's parser accepts forms this regex does not, and the double count survives them. But the regex is shared with the `closing-keyword` and `arc-merge-keyword` checks, and what GitHub accepts is a claim that needs a live test rather than a guess. On the issue's `Spawned` table |

## What the passes found

**Four defects, three of them in the live `gh pr view` field extraction — which no case can reach.**

**Pass 1** found the finding printed `carries milestone \`set\``: `MILESTONE` was a sentinel on
the live path and only ever the milestone's real name on the fixture path. The case proved a
string the live path could not produce.

**Pass 2**, on pass 1's own fix, found three more. The close-sequence row had been made wrong in
the opposite direction — unconditionally "no milestone", which is false for a direct PR, the
exact unit `tools/new-direct-pr.sh` exists to open. The isolating `sed` silently no-opped when
the milestone key was absent and handed back a neighbour's title as the milestone's name. And
`TITLE` had been multi-line since before this change: `gh` returns the fields sorted, so a
closing issue's title and the milestone's title both arrive before the PR's own, and
`grep -q "^arc-$ARCNUM:"` matched the arc prefix on **any** of the three lines — a PR missing
its prefix passed whenever a neighbour had one.

**Found while fixing those:** `BODY`'s terminator was `s/","baseRefName.*//`, and `baseRefName`
sorts *before* `body`, so it never matched. The extracted body ran to the end of the payload,
carrying the milestone's description and the PR's own title. The milestone check greps that body
for a closing keyword, so a PR whose title read `… fixes #12` was classified as closing an issue.
Fixed to `","closingIssuesReferences"`, verified against PR #245 live.

**Pass 3** confirmed all five boxes against the tree and the live tracker, and caught the stale
number in box 3 — see below.

## The strip

The issue said ten issue-closing PRs in a 73-item milestone. By the time the work ran it was
**45 PRs in a 120-item milestone, 35 of them carrying a closing keyword.** Ten is the count of
*direct* PRs, not closing ones.

All 35 were stripped, each `gh pr edit --remove-milestone` exiting 0. Read back: the milestone
now holds 85 items — 75 issues and exactly the 10 direct PRs (133, 176, 180, 184, 186, 187, 188,
200, 215, 245), each confirmed to carry no closing keyword. No direct PR was stripped, which is
the issue's stated constraint.

**The box was left ticked and the real number written beside it.** A tick is a claim about the
tree; a reader auditing "ten" against the milestone would find ten of something else entirely.

## Retrospective

**Every defect this unit found was in code no verifier case can reach.** The four cases the
issue asked for all passed on the first run of the finished check. What the three passes found
was the `gh pr view` field extraction — `BODY`, `TITLE`, the milestone read — where every hook
case takes the fixture branch and the live branch is exercised only against the real API. Two
of those defects predate this change and had been silently mis-answering the `arc-prefix` and
`closing-keyword` checks. That gap is on the issue's `Spawned` table.

**The premise number was wrong by 3.5×, and only pass 3 asked.** The issue's arithmetic was
true when it was filed. Nothing in the sequence re-reads a premise, and a run that had trusted
"ten" would have stripped ten PRs and left twenty-five double-counting.

**Unsoaked.** The hook fires from the installed plugin copy, current only after
`tools/plugin-reload.sh`, and other runs are working in parallel worktrees off this base.
`gh pr ready` on this unit's own PR runs the main tree's copy, without this change. Everything
asserted here is the harness plus five live probes of the extraction against PRs #245 and #249.
**The next work stretch in this repo is its first exercise**, and the thing to read is whether
`.claude/arc/log.md` carries `milestone=Dogfood` — a name — rather than `milestone=set`.

**And it was measured, not predicted.** `gh pr create` on this unit's own PR fired the installed
copy, which reported *"PR #257 has no milestone. It will not appear in the milestone view"* — the
old rule, on the PR that removes it. The stale-installed-copy row in the arc-log's §10 stops
being a prediction here: the hook that denies this PR's correct state is the one this PR fixes.

**Gates:** `bash tools/verify-all.sh` → exit 0, 43 gates clean.
`bash tools/verify-hook.sh hooks/tracker-verify` → exit 0, 63 passed, 0 failed.
`bash tools/verify-activation-log.sh hooks/tracker-verify` → exit 0, 201 passed, 0 failed.
