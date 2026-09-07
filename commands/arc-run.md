---
description: Run the next set of the arc's playlist — names its tracks, waits for a yes, then dispatches them in parallel
argument-hint: "[set label, e.g. S2] [--model <model>]"
allowed-tools: Bash, Read
---

# Run a set

Dispatch the next set of the current arc's playlist, or the one named in `$ARGUMENTS`. A set is
several tracks — each one run, one worktree, one PR — that the playlist says may run at once.

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

## 2 Which set

**The playlist decides.** `docs/arc-work/<arc-slug>/playlist.md` §4 lists the sets in order and §3
maps every track to its issues and its workstream. Read both — they are the only schedule.

**The next set is the first whose tracks still have an open issue.** Check every issue in the set:

```sh
gh issue view <NN> --json state,labels --jq '{state:.state, inprogress:([.labels[].name]|index("in-progress"))}'
```

A track whose issues are all closed is done. A track with `in-progress` on an issue is running
or was abandoned — `bash tools/arc-loop.sh --status` says which. If `$ARGUMENTS` names a set,
use that instead.

**Do not order by workstream.** The workstream is the reporting unit; the track is the parallel
unit, and one set mixes workstreams where the files allow — that is the whole point of the playlist.

## 3 Say what you are about to do, and wait

Report, in one short block:

| | |
|---|---|
| The set | Its label, and one row per track: label, issues with titles, workstream, whether it is the set's probe track |
| Skipped | Any track already done, or still running from an earlier set |
| Blocked | Any issue whose `Blocked by #NN` is still open — the set should not have been reached, so say so |
| The mode | That each run gets an Autonomous row in **its own worktree's** `HANDOFF.md`, written by `arc-loop.sh`; this tree's row is not touched |

**Then stop and wait for a yes.** This is the last point before unattended work begins.

## 4 Run it

One invocation per track, each in the background, each polling its own run:

```sh
bash tools/arc-loop.sh <workstream> --issues <a,b> --track <Sn.Xn> [--model <model>]
```

`<workstream>` is the track's parent issue from playlist §3 — the script refuses an issue that is
not that workstream's open child. `--track` becomes the session's title in every session list.
`bash tools/arc-loop.sh --status` shows every run, live or finished, with its usage.

The script owns the mode row. Do not write it yourself — a run that sets its own mode to
autonomous is the failure `hooks/mode-guard` and [m40](../docs/product-architecture/mechanisms/m40-autonomy-switch.md) §4 exist to prevent.

## 5 When a track returns

`arc-loop.sh` prints the run's usage and removes the worktree if every issue closed. For each:

| | |
|---|---|
| Closed | Confirm on GitHub — a run merges its own PR. Append the usage line to the arc-log's status section: the soak record |
| Still open | The worktree is kept. Read `.arc-work/runs/<id>/err.log` and the worktree's diff before deciding: relaunch, hand to David, or park. Never redo the issue by hand from this tree |
| Rate-limited | The script already waited and resumed the same session. Nothing to do unless it gave up |

**When a workstream's last child closes**, dispatch its report run — `bash tools/arc-loop.sh
<workstream>` with no `--issues` finds nothing to select and runs §6. Then say where the
boundary report is — the arc-log and the workstream parent — and that **the parent issue is still
open**, closing it being the user's call after reading.

**When the set closes**, name the next set and stop. Each set is its own yes.

**Never close the workstream parent.** All children closed is mechanical completion; the boundary
is a review.
