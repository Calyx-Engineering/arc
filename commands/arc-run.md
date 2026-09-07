---
description: Start the next workstream — names it, waits for a yes, then runs the loop
argument-hint: "[workstream issue number] [--max N]"
allowed-tools: Bash, Read
---

# Run a workstream

Start the next workstream of the current arc, or the one named in `$ARGUMENTS`.

## 1 Which arc

**The branch names it.** Every branch in an arc begins `arc/<nn>-<slug>` — the arc branch itself,
and every issue and direct-PR branch under it. Strip the `-issue-<NN>-` or `-pr<NN>-` suffix and
what is left is the arc.

```sh
BRANCH="$(git rev-parse --abbrev-ref HEAD)"
case "$BRANCH" in arc/*) ;; *) echo "not an arc branch: $BRANCH"; exit 1 ;; esac
ARC="${BRANCH%%-issue-*}"; ARC="${ARC%%-pr[0-9]*}"   # arc/04-dogfood
```

**Do not take the first open issue labelled `arc`.** That works only while exactly one arc is
open, and fails silently the moment two overlap — which is the case this repository will be in
the first time an arc is left open while another starts.

If the branch is not an arc branch, say so and stop. `/arc-run` from `main` has no arc to run.

The arc's tracker object is the open issue labelled `arc` whose milestone matches that arc:

```sh
gh issue list --label arc --state open --milestone "<the arc's milestone>" --json number,title
```

If more than one comes back, or none does, **report it and stop** rather than guessing.

## 2 Which workstream

**Order comes from the arc issue's ordered sub-issues, never from a numeric sort.** Issue numbers
are a creation counter: a workstream filed later would always sort last, and could never be
inserted between two existing ones.

```sh
gh api graphql -f query='{repository(owner:"OWNER",name:"REPO"){issue(number:ARC){
  subIssues(first:20){nodes{number title state}}}}}'
```

**The next workstream is the first child that is open and has open children of its own.** If
`$ARGUMENTS` names a number, use that instead — the plan says the workstreams after the first are
independent and may run in any order, so jumping is legitimate.

## 3 Say what you are about to do, and wait

Report, in one short block:

| | |
|---|---|
| The workstream | Number, title, how many children, how many closed |
| The first issue | Number and title — what the loop will actually start on |
| Blocked children | Any whose `Blocked by #NN` is still open, so the count is honest |
| The mode | That `tools/arc-loop.sh` will set the Execution mode row to Autonomous, bounded to this workstream, and back to Manual at the boundary |

**Then stop and wait for a yes.** This is the last point before unattended work begins.

## 4 Run it

```sh
bash tools/arc-loop.sh <parent> [--max N]
```

**Pass `--max 1` the first time the driver is used against a new workstream shape.** The dispatch
path has less coverage than the selection path, and thirteen issues is a long way to go before a
bad dispatch is noticed.

The script owns the mode row. Do not write it yourself — a run that sets its own mode to
autonomous is the failure `hooks/mode-guard` and [m40](../docs/product-architecture/mechanisms/m40-autonomy-switch.md) §4 exist to prevent.

## 5 When it returns

`arc-loop.sh` has already dispatched the report run and set the mode back to Manual. What is left
is to say so:

- Where the boundary report is — the arc-log's status section, and the workstream parent issue
- That **the parent issue is still open**, and closing it is the user's call after reading
- What the next workstream would be

**Never close the workstream parent.** All children closed is mechanical completion; the boundary
is a review.
