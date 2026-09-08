# Issue #84 — issues carry no type label

> Dev-log, not a spec. Started at plan time, finalised as a retrospective at PR time.

**Issue:** [#84](https://github.com/Calyx-Engineering/arc/issues/84)  ·  **PR:** [#237](https://github.com/Calyx-Engineering/arc/pull/237)

## Problem

Seven title prefixes were in use, nine stock labels existed, and nothing mapped one to the
other. `skills/issue-write` did not mention labels at all. Every `fix:` issue in the repository
was unlabelled until the user noticed and labelled seven by hand.

## Intent and north star

| | |
|---|---|
| **What this issue is really for** | Making the prefix and the label one fact instead of two, so a label cannot silently disagree with the title above it |
| **North star** | A query someone actually runs — `label:bug`, `label:in-progress` — returns the right issues, and every label on the tracker is one a query uses |
| **What makes it durable** | A gate. A mapping written only into a skill is a convention, and the convention is what already failed |
| **Out of scope** | Closed issues. Retitling `spec:` issues that already merged buys nothing and churns the record |

## Decisions & trade-offs

**Three type labels, not seven.** `fix:` → `bug`, `feat:` → `enhancement`, `docs:` →
`documentation`. `scope:`, `chore:`, `refactor:` and `test:` license **none**. The issue's own
test is whether a query would actually run; nobody filters for a chore, and a `chore` label
would cost attention at every issue write to return something nobody asked for. Licensing
nothing is checked as strictly as licensing something — a `chore:` issue wearing `enhancement`
fails, which is how #90 was found.

**`test:` was in use and #84 did not list it.** #198 and #227 are `test:` issues that arrived
after the issue was written, both wearing `bug`. Added to the mapping with no label, and both
unlabelled.

**Containers get a label, and it earns its place harder than any type label does.** `arc:` →
`arc`, `workstream:` → `workstream`. A sweep of work has to exclude them, and #204 —
issue-closing PRs double-counting in the milestone — is that failure class.

**Three labels beyond type survive.** `in-progress` (the driver reads it), `priority: high`
(high only — medium is the absence of a label, and nobody queries for the absence of urgency),
and `issue-discipline` (the one area label; a second one has to name a query that would run).

**The arc stays the milestone.** No label duplicates it — the issue's own constraint.

**`spec:` is retired, `scope:` survives.** One word per meaning. The skill already said so in
prose; what changed is that an unmapped prefix is now a reported finding, so the retirement is
enforced rather than remembered. Nothing open carries `spec:`, so no retitling was needed.

**The six stock labels are retired but still on the tracker.** `duplicate`, `good first issue`,
`help wanted`, `invalid`, `question`, `wontfix` — nothing wears any of them, checked against
every issue and PR, open and closed. **The delete was blocked by the permission classifier in
this run**, so `verify-labels.sh labels` names them as retired and prints the command:

```sh
for l in duplicate "good first issue" "help wanted" invalid question wontfix; do
  gh label delete "$l" --yes
done
```

That gate is red until a human runs it. It is not in `verify-all.sh` — only the selftest is —
so a standing finding does not turn the whole runner red.

## Rejected approaches

| | Why not |
|---|---|
| **A label per prefix** | Creates `chore`, `refactor`, `test` and `scope` labels nobody would filter on. The issue's constraint is that a label has to earn its place |
| **No type labels at all**, on the grounds that the prefix is already in the title | GitHub's issue list filters on labels, not title substrings. `label:bug` is the query people run |
| **`priority: medium` and `priority: low`** | The three-level scale is the repo's; a label per level is not. Medium is the default and nobody queries for it |
| **Deleting the six stock labels via `gh api --method DELETE`** | The same action by another name. The classifier's denial was respected and reported instead |

## Spawned

- **Issues:** none

## Retrospective

The gate is the deliverable, not the sweep. `tools/verify-labels.sh` carries the mapping as
`MAP`, sweeps every open issue, and checks the label set itself; `skills/issue-write` carries
the same table in prose and says outright that the two are one fact.

**The selftest found nothing and running the sweep found the real defect.** `classify` was
correct from the first draft; the sweep read `gh` output as tab-separated fields, and a tab is
IFS whitespace, so bash collapsed the empty label field of every unlabelled issue — the title
landed in `labels` and the title read empty. Twenty issues reported "no type prefix" against an
empty string. The parse was the untested half, so it now has its own fixture cases and a unit
separator instead of a tab.

Seventeen open issues were brought into line — ten labels added, seven removed — and the sweep
reads clean at 59 of 59.
