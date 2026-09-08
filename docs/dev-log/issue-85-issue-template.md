# Issue #85 — issue template

> Dev-log, not a spec. Started at plan time, finalised as a retrospective at PR time.

**Issue:** [#85](https://github.com/Calyx-Engineering/arc/issues/85)  ·  **PR:** [#237](https://github.com/Calyx-Engineering/arc/pull/237)

## Problem

`templates/` held arc-log, dev-log, event-log, handoff and Camp's three documents. The issue —
the most frequently written artifact in the repository — had none, so each body was assembled
from rules scattered across four sections of `skills/issue-write`. Nine issues were written in
one session with `Spawned` mid-body on #76, appended to four times before anyone noticed. The
positional rule was the one furthest from the section list.

## Intent and north star

| | |
|---|---|
| **What this issue is really for** | Making the assembled shape copyable, so the positional rules cannot be the ones that get lost |
| **North star** | A body is produced by copying a file, not by remembering four sections of a skill — and the fields that live on the issue rather than in it are named where the body is written |
| **What makes it durable** | The gates already in the repository. `verify-template-links.sh` refuses a template with no destination row; `verify-tracker-body.sh body` refuses a shape it would report in a real body |
| **Out of scope** | `.github/ISSUE_TEMPLATE`. That serves a human filing in the web UI; this serves an agent writing a body to a file |

## Decisions & trade-offs

**Two files, not one.** `templates/issue.md` and `templates/pr.md`. A single file cannot hold
both: the PR shape ends with `Closes #<NN>` on the last line and the issue shape does not, so
one of the two would sit after the other's terminal section — the exact defect
`verify-tracker-body.sh body` reports. Both files now pass that gate, which makes the templates
subject to the same check as the bodies they produce.

**`Closes` is named in the issue template and belongs to the PR.** The order table names it as
*a PR's last line, never an issue's*, because the rule most often got confused was which unit
carries it.

**The destination is `.`** — a body file the agent writes at the working root, then
`--body-file`. That is honest rather than tidy: an issue body has no directory it lands in, and
inventing one would put a false row in the map. Every link in both templates is an absolute URL,
so they resolve wherever the file is written.

**The skill lost its section-order table.** `What a good issue contains` now points at the
template instead of restating the four sections. The constraint runs both ways — the template
does not restate the skill's judgement, and the skill no longer carries the shape.

## Rejected approaches

**Worked examples: all three options rejected**, recorded on the issue as
[a comment](https://github.com/Calyx-Engineering/arc/issues/85#issuecomment-5578626803).

| | Why not |
|---|---|
| Annotated example body in the template | Voice is judgement, and judgement is the skill's by this issue's own constraint. It also doubles the length against *draft, then delete* |
| Reference real issues by number | They drift as issues are edited, and a reader outside the repo cannot see them |
| Transcript excerpts in `R:\arc-transcripts\` | Uncommitted and outside the repo, so the reference is unresolvable for anyone else |

**One template with the PR delta inline** — rejected for the gate reason above.

## Spawned

- **Issues:** none

## Retrospective

Four artifacts: the two templates, a `MAP` row each in `tools/verify-template-links.sh` with a
matching row in `templates/README.md`, and four cross-references in `skills/issue-write` — at
*What a good issue contains*, *Placement*, *Verify* and *Related — one table, four kinds*, which
are the four places #85 named as scattered.

**The selftest fixture had to grow with the map.** `verify-template-links.sh selftest` builds a
fixture tree holding every template `MAP` names; adding two rows without adding two fixture
files would have failed the selftest on *mapped but not on disk*. The gate that refuses an
unmapped template is the same gate that refuses a map row with no file, which is why the fixture
is part of the change rather than a follow-up.
