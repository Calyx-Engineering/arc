#!/usr/bin/env bash
# arc-loop.sh — run one workstream's issues, one fresh session each, each in its own worktree.
#
# Each iteration is a cold `claude -p`: it reads run-instructions.md and one
# issue body, does the work, opens a PR, and exits. This script holds nothing
# but the position in the queue, and the position lives in GitHub — which
# sub-issues are still open. Kill it and restart; it resumes where it was.
#
#   tools/arc-loop.sh 145                    run the Fire workstream, next open issue first
#   tools/arc-loop.sh 145 --dry-run          print what it would dispatch, run nothing
#   tools/arc-loop.sh 145 --max 3            stop after three issues
#   tools/arc-loop.sh 145 --issues 183,210   one run, this batch, then stop — the playlist's call
#   tools/arc-loop.sh 145 --issues 183,210 --track S1.F1   …and the session is titled "arc/04 — S1.F1 · #183 #210"
#   tools/arc-loop.sh --status               every run under .arc-work/runs/, live or finished
#   tools/arc-loop.sh --report               the same as a markdown table with totals — for the arc-log
#   tools/arc-loop.sh --resume 160           continue a stopped run's session in its kept worktree
#   ARC_LOOP_RESUME_NOTE="PR #247 conflicts with the base — merge it, re-gate, mark ready" tools/arc-loop.sh --resume 201
#
# mode-guard: writes-outward
# mode-guard-read-only: --dry-run --status --report
#
# The declaration above is read by hooks/mode-guard. This script raises the execution mode in
# each worktree it creates and dispatches runs that commit, push, open PRs and merge them, so
# starting it in manual mode is one of those actions taken at one remove — #201. The three
# read-only switches report on runs and dispatch nothing, so they are exempt.
#
# Scope of one invocation is ONE workstream. When its children are all closed
# the script dispatches a report run and exits; the next workstream is a
# second invocation, after a human has read that report.
#
# HOW A RUN IS LAUNCHED — three things, measured into being on #155–#158
# (docs/dev-log/pr-215-loop-v2.md):
#
#   WORKTREE   Each run gets ../arc-wt/<id>, detached at the arc branch's remote tip. The run
#              creates and checks out its issue branch there. This tree's HEAD is never touched,
#              so the orchestrator keeps working and runs can overlap.
#   DETACHED   Started by PowerShell's Start-Process, not as a child of this shell. Three of four
#              first runs died at ~20 minutes with the session that launched them — ~35% of the
#              workstream's spend. This script polls for the run's exit file.
#   BATCHED    --issues hands one run several issues sharing one deliverable: one branch, one PR,
#              one commit per issue. Batching is by shared file, never by count.
#   RESUMED    A run that ends on a rate or usage limit is not lost: the loop waits, then
#              `claude -p --continue` in the same worktree carries the same session on.
#
# THE MODE ROW lives in the worktree. hooks/mode-guard reads HANDOFF.md from the payload's cwd,
# and HANDOFF.md is gitignored, so a fresh worktree has none and every commit is denied. The
# loop writes a minimal HANDOFF.md — the Execution mode table and nothing else — into each
# worktree. This tree's own HANDOFF.md is touched only around the report run, which works here.
#
# Exercised 2026-09-06 against the real milestone: selection and skipping on all
# five workstreams, and the three guards (no argument, an issue that is not a
# workstream, an issue that does not exist).
#
# 2026-09-07, first real dispatch: #155 under #145, --max 1. Selection, the mode row and
# both its exit paths worked. The dispatch did not — no --permission-mode, so the run was
# denied Write, Edit and every `bash tools/…`. It did the analysis and could save none of
# it. Fixed here; the flag has not itself been exercised yet.
#
# NOT yet exercised: the report run at workstream completion, the all-blocked stop,
# the same-issue-twice guard, and a run exiting non-zero.
#
# Reasoning: docs/arc-log/arc-04-dogfood.md §3.1
set -euo pipefail

HERE="$(cd "$(dirname "$0")" && pwd)"
REPO="Calyx-Engineering/arc"
INSTRUCTIONS="docs/arc-work/04-dogfood/run-instructions.md"

# TWO SWITCHES ARE BOTH CALLED "MODE", and setting only one is what broke the first real
# dispatch. HANDOFF.md's Execution mode row governs commit, push, PR and merge, through
# hooks/mode-guard — set_mode below writes it. Claude Code's --permission-mode governs
# whether the run may call Write, Edit or Bash at all. A `claude -p` cannot prompt, so with
# no flag every request is denied: the run for #155 was authorised to merge a PR it had no
# permission to write, and produced an analysis it could not save.
PERMISSION_MODE="${ARC_LOOP_PERMISSION_MODE:-auto}"
MODEL="${ARC_LOOP_MODEL:-}"
# A run that ends on a rate or usage limit is resumed, not restarted: wait, then
# `claude -p --continue` in its worktree. A session limit resets on a five-hour window, and
# twelve waits of ten minutes gave up twenty minutes short of one on 2026-09-08 — three runs
# stopped with their worktrees kept. Thirty-six waits is six hours.
RETRY_WAIT="${ARC_LOOP_RETRY_WAIT:-600}"
# An extra line for the resume prompt — what the orchestrator saw that the run did not, e.g.
# "PR #247 is CONFLICTING against arc/04-dogfood: merge the base, re-run the gates, mark ready."
RESUME_NOTE="${ARC_LOOP_RESUME_NOTE:-}"
MAX_RETRY="${ARC_LOOP_MAX_RETRY:-36}"
DRY=0
MAX=0
ISSUES=""
TRACK=""
STATUS=0
REPORT=0
RESUME=""
PARENT="${1:-}"
shift || true
[ "$PARENT" = "--status" ] && { STATUS=1; PARENT=""; }
[ "$PARENT" = "--report" ] && { REPORT=1; PARENT=""; }
[ "$PARENT" = "--resume" ] && { RESUME="${1:-}"; shift || true; PARENT=""; }
while [ $# -gt 0 ]; do
  case "$1" in
    --dry-run) DRY=1 ;;
    --max) shift; MAX="${1:-0}" ;;
    --issues) shift; ISSUES="$(printf '%s' "${1:-}" | tr ', ' '\n\n' | grep -E '^[0-9]+$' | tr '\n' ' ')" ;;
    --model) shift; MODEL="${1:-}" ;;
    --track) shift; TRACK="${1:-}" ;;
    --status) STATUS=1 ;;
    --report) REPORT=1 ;;
    --resume) shift; RESUME="${1:-}" ;;
    *) echo "unknown option: $1" >&2; exit 2 ;;
  esac
  shift
done

die() { echo "arc-loop: $*" >&2; exit 1; }

ROOT="$(git rev-parse --show-toplevel)"
# Same path form as $ROOT (R:/arc on Windows), so worktree paths read the same everywhere.
WT_ROOT="$(dirname "$ROOT")/arc-wt"
RUNS="$ROOT/.arc-work/runs"

# The mode row is written by this script and never by a run. A human ran it, which is the same
# explicitness as saying "switch to autonomous" in chat — so the script may raise it. A run
# dispatched by it never may: m40 §4's asymmetry, and hooks/mode-guard enforces the half that
# can be enforced. Issue runs get the row in their worktree (write_worktree_mode); this tree's
# row is raised only for the report run, which works here, and restored to Manual after it.
set_mode() {  # set_mode <Manual|Autonomous> [boundary]
  [ -f HANDOFF.md ] || die "no HANDOFF.md — the mode lives in its Execution mode row"
  python "$HERE/set-mode.py" "$1" "${2:-}" || die "could not set the execution mode to $1"
}

# --- runs: status, liveness, usage ---------------------------------------------
alive() {  # alive <pid> — Windows first, POSIX fallback
  if command -v tasklist >/dev/null 2>&1; then
    tasklist //FI "PID eq $1" //NH 2>/dev/null | grep -q "^[^ ]* *$1 "
  else
    kill -0 "$1" 2>/dev/null
  fi
}

# The JSON `claude -p --output-format json` prints on exit carries num_turns, duration_ms,
# total_cost_usd and usage. This is the measurement the loop never had.
summarise() {  # summarise <run-dir>
  python - "$1" <<'PY'
import json, sys, os
sys.stdout.reconfigure(encoding="utf-8", errors="replace")  # a run's last words are not cp1252
d = sys.argv[1]
out = os.path.join(d, "out.json")
if not os.path.exists(out) or os.path.getsize(out) == 0:
    print("  no out.json yet"); sys.exit(0)
txt = open(out, encoding="utf-8", errors="replace").read().strip()
try:
    r = json.loads(txt)
except json.JSONDecodeError:
    r = None
    for line in reversed(txt.splitlines()):
        try: r = json.loads(line); break
        except json.JSONDecodeError: continue
if not isinstance(r, dict):
    print("  out.json is not a JSON object — read it by hand"); sys.exit(0)
u = r.get("usage") or {}
inp = u.get("input_tokens", 0); cr = u.get("cache_read_input_tokens", 0)
cw = u.get("cache_creation_input_tokens", 0); o = u.get("output_tokens", 0)
tot = inp + cr + cw
print("  turns        %s" % r.get("num_turns"))
print("  minutes      %.1f" % ((r.get("duration_ms") or 0) / 60000))
print("  input tokens %s  (cache read %s%%)" % (f"{tot:,}", round(100 * cr / tot) if tot else 0))
print("  output       %s" % f"{o:,}")
print("  cost USD     %s" % r.get("total_cost_usd"))
print("  is_error     %s" % r.get("is_error"))
res = (r.get("result") or "").strip().replace("\n", " ")
if res: print("  last words   %s" % res[:200])
PY
}

show_status() {
  [ -d "$RUNS" ] || { echo "arc-loop: no runs"; return 0; }
  local d id pid state
  for d in "$RUNS"/*/; do
    [ -f "$d/pid" ] || continue
    id="$(basename "$d")"; pid="$(cat "$d/pid")"
    if [ -f "$d/exit" ]; then state="exited $(cat "$d/exit")"
    elif alive "$pid"; then state="running (pid $pid)"
    else state="gone — no exit file, pid $pid dead"; fi
    echo "run $id  issues $(tr '\n' ' ' < "$d/issues") $state"
    [ -f "$d/exit" ] && summarise "$d"
  done
  return 0
}

# Every finished run, as the table the arc-log's boundary report wants. Runs before this
# script kept usage (#155–#158) are not here; docs/dev-log/pr-215-loop-v2.md has them.
show_report() {
  python - "$RUNS" <<'PY'
import json, sys, os, glob
sys.stdout.reconfigure(encoding="utf-8", errors="replace")
rows = []
for d in sorted(glob.glob(os.path.join(sys.argv[1], "*", ""))):
    out = os.path.join(d, "out.json")
    if not os.path.exists(out) or os.path.getsize(out) == 0: continue
    try: r = json.loads(open(out, encoding="utf-8", errors="replace").read())
    except json.JSONDecodeError: continue
    ip = os.path.join(d, "issues")
    issues = open(ip, encoding="utf-8").read().split() if os.path.exists(ip) else []
    u = r.get("usage") or {}
    tot = u.get("input_tokens", 0) + u.get("cache_read_input_tokens", 0) + u.get("cache_creation_input_tokens", 0)
    rows.append(dict(run=os.path.basename(os.path.dirname(d)), issues=" ".join("#" + i for i in issues), n=len(issues),
        turns=r.get("num_turns") or 0, mins=(r.get("duration_ms") or 0) / 60000, tot=tot,
        cache=(100 * u.get("cache_read_input_tokens", 0) / tot) if tot else 0, out=u.get("output_tokens", 0),
        usd=r.get("total_cost_usd") or 0, ok=not r.get("is_error")))
if not rows:
    print("no finished runs"); sys.exit(0)
print("| Run | Issues | Turns | Min | Input (M) | Cache | Output (K) | USD | Per issue (M) |")
print("|---|---|---|---|---|---|---|---|---|")
for x in rows:
    flag = "" if x["ok"] else " (error)"
    print(f"| {x['run']}{flag} | {x['issues']} | {x['turns']} | {x['mins']:.0f} | {x['tot']/1e6:.1f} | {x['cache']:.0f}% | {x['out']/1e3:.0f} | {x['usd']:.2f} | {x['tot']/1e6/max(1, x['n']):.1f} |")
N = sum(x["n"] for x in rows); T = sum(x["tot"] for x in rows)
print(f"| **Total** | {N} issues, {len(rows)} runs | {sum(x['turns'] for x in rows)} | {sum(x['mins'] for x in rows):.0f} | {T/1e6:.1f} | | {sum(x['out'] for x in rows)/1e3:.0f} | {sum(x['usd'] for x in rows):.2f} | {T/1e6/max(1, N):.1f} |")
PY
}

[ "$STATUS" = 1 ] && { show_status; exit 0; }
[ "$REPORT" = 1 ] && { show_report; exit 0; }


[ -n "$PARENT" ] || [ -n "$RESUME" ] || die "usage: tools/arc-loop.sh <workstream-parent-issue> [--dry-run] [--max N] [--issues 183,210] | --status"
[ -f "$INSTRUCTIONS" ] || die "missing $INSTRUCTIONS — run from the repository root"
command -v gh >/dev/null || die "gh not found"
[ "$DRY" = 1 ] || command -v powershell >/dev/null || die "powershell not found — detaching a run needs Start-Process"

# The arc branch runs nest under: the checked-out arc branch, with any work-branch tail removed.
BASE="$(git rev-parse --abbrev-ref HEAD)"
case "$BASE" in
  arc/*-issue-*|arc/*-pr[0-9]*) BASE="$(printf '%s' "$BASE" | sed -E 's/-(issue-|pr)[0-9].*$//')" ;;
  arc/*) ;;
  *) die "\`$BASE\` is not an arc branch — check the arc out first" ;;
esac
# "arc/04" — the first line of every prompt, which is the title every session list shows.
ARC="$(printf '%s' "$BASE" | sed -E 's#^(arc/[0-9]+).*#\1#')"

if [ -z "$RESUME" ]; then
# --- the parent must actually be a workstream -------------------------------
labels=$(gh issue view "$PARENT" -R "$REPO" --json labels --jq '[.labels[].name]|join(",")') \
  || die "cannot read issue #$PARENT"
case ",$labels," in
  *,workstream,*) ;;
  *) die "#$PARENT is not labelled 'workstream' — it is not an execution queue" ;;
esac

parent_title=$(gh issue view "$PARENT" -R "$REPO" --json title --jq .title)
echo "arc-loop: #$PARENT $parent_title — runs nest under $BASE"
[ "$DRY" = 1 ] && echo "arc-loop: dry run — nothing dispatched, no worktree, no mode row"
fi

# --- queue reads --------------------------------------------------------------
open_children() {
  gh api graphql -f query="{repository(owner:\"${REPO%%/*}\",name:\"${REPO##*/}\"){
    issue(number:$PARENT){subIssues(first:50){nodes{number state}}}}}" \
    --jq '.data.repository.issue.subIssues.nodes[] | select(.state=="OPEN") | .number'
}

# an issue is eligible when every "Blocked by #NN" line names a closed issue
blocked() {
  local body blockers n st
  body=$(gh issue view "$1" -R "$REPO" --json body --jq .body)
  blockers=$(printf '%s\n' "$body" | grep -oiE '^Blocked by #[0-9]+' | grep -oE '[0-9]+' || true)
  for n in $blockers; do
    st=$(gh issue view "$n" -R "$REPO" --json state --jq .state 2>/dev/null || echo OPEN)
    [ "$st" = "OPEN" ] && { echo "$n"; return 0; }
  done
  return 1
}

next_issue() {
  local n b
  for n in $(open_children); do
    if b=$(blocked "$n"); then
      echo "  #$n blocked by #$b" >&2
    else
      echo "$n"; return 0
    fi
  done
  return 1
}

# --- dispatch -----------------------------------------------------------------
write_worktree_mode() {  # write_worktree_mode <worktree> <issues...>
  local wt="$1"; shift
  cat > "$wt/HANDOFF.md" <<EOF
# Run $1 — execution mode

This file exists so \`hooks/mode-guard\` finds a mode in this worktree. It is not a session
handoff: the run reads \`$INSTRUCTIONS\` and its issue bodies, nothing here.

## Execution mode

| | |
|---|---|
| **Mode** | **Autonomous** |
| Autonomous until | **$(printf '#%s ' "$@")merged** |

Written by \`tools/arc-loop.sh\`, which a human ran — m40 §4. Removed with the worktree.
EOF
}

# launch_run <run-dir> <worktree> <model-flag> <prompt-file> <extra-flags>
# The launcher script. `bash -l` so the profile puts claude on PATH. The exit code lands in a
# file because the launcher outlives this shell and nothing is waiting on it.
launch_run() {
  local dir="$1" wt="$2" model_flag="$3" prompt="$4" extra="$5" pid
  cat > "$dir/run.sh" <<EOF
#!/usr/bin/env bash
cd "$wt" || { echo 1 > "$dir/exit"; exit 1; }
date -u +%FT%TZ >> "$dir/started"
claude -p $extra --permission-mode "$PERMISSION_MODE" --output-format json $model_flag \\
  < "$prompt" > "$dir/out.json" 2>> "$dir/err.log"
echo \$? > "$dir/exit"
date -u +%FT%TZ >> "$dir/ended"
EOF
  rm -f "$dir/exit"
  pid="$(powershell -NoProfile -Command \
    "(Start-Process -FilePath bash -ArgumentList '-l','$dir/run.sh' -WindowStyle Hidden -PassThru).Id" 2>/dev/null | tr -d '\r')"
  [ -n "$pid" ] || die "Start-Process returned no pid — the run did not launch"
  echo "$pid" > "$dir/pid"
  echo "  launched pid $pid — worktree $wt, log $dir/err.log${extra:+ ($extra)}"
}

# limit_hit <run-dir> — did the run end on a rate or usage limit rather than on its own?
limit_hit() {
  python - "$1" <<'PY'
import json, sys, os, re
d = sys.argv[1]
txt = ""
for name in ("out.json", "err.log"):
    p = os.path.join(d, name)
    if os.path.exists(p):
        txt += open(p, encoding="utf-8", errors="replace").read()[-4000:]
err = False
try:
    r = json.loads(open(os.path.join(d, "out.json"), encoding="utf-8").read())
    err = bool(r.get("is_error")); txt = (r.get("result") or "") + txt
except Exception:
    err = True
pat = re.compile(r"rate.?limit|usage.?limit|limit (?:reached|exceeded)|hit your limit|\b429\b|\b529\b|overloaded", re.I)
sys.exit(0 if (err and pat.search(txt)) else 1)
PY
}

# wait_run <id> <run-dir> <worktree> <model-flag> — block until the run exits; on a rate or
# usage limit wait and resume the same session, up to MAX_RETRY times.
wait_run() {
  local id="$1" dir="$2" wt="$3" model_flag="$4" pid attempt=0
  while :; do
    pid="$(cat "$dir/pid")"
    while [ ! -f "$dir/exit" ]; do
      alive "$pid" || { echo "  run $id died without an exit code — see $dir/err.log" >&2; return 1; }
      sleep 30
    done
    echo "  run $id exited $(cat "$dir/exit")"
    summarise "$dir"
    limit_hit "$dir" || return 0
    if [ "$attempt" -ge "$MAX_RETRY" ]; then
      echo "  rate limit again after $MAX_RETRY resumes — giving up; worktree kept" >&2
      return 0
    fi
    attempt=$((attempt + 1))
    echo "  rate limit — waiting ${RETRY_WAIT}s, then resuming the same session ($attempt/$MAX_RETRY)"
    mv -f "$dir/out.json" "$dir/out.$(date +%H%M%S).json"
    sleep "$RETRY_WAIT"
    resume_run "$dir" "$wt" "$model_flag"
  done
}

# resume_run <run-dir> <worktree> <model-flag> — `claude -p --continue` in the worktree picks up
# that run's own transcript, so it carries on rather than starting the issue over.
resume_run() {
  printf '%s\n' "Your session ended before the run finished — a limit, or a turn that ended while waiting on background work. Continue the run from where it stopped." \
    "Read the issue checklists on GitHub and git status for the current state before acting; do not redo ticked boxes." \
    "Run sub-agents in the foreground: a claude -p session ends when you end your turn, and a background task's notification never arrives." \
    ${RESUME_NOTE:+"$RESUME_NOTE"} \
    > "$1/resume.md"
  launch_run "$1" "$2" "$3" "$1/resume.md" "--continue"
}

# run_batch <issue> [issue...] — one worktree, one detached `claude -p`, blocks until it exits.
# Returns the run's exit code. The worktree is removed only if every issue closed.
run_batch() {
  local id="$1" wt="$WT_ROOT/$1" dir="$RUNS/$1" n st pid model_flag=""
  [ -n "$MODEL" ] && model_flag="--model $MODEL"

  if [ "$DRY" = 1 ]; then
    echo "  would dispatch issue run for $(printf '#%s ' "$@")into $wt (--permission-mode $PERMISSION_MODE${MODEL:+ --model $MODEL})"
    return 0
  fi
  [ -d "$wt" ] && die "worktree $wt already exists — remove it first: git worktree remove --force $wt"
  [ -f "$dir/pid" ] && alive "$(cat "$dir/pid")" && die "run $id is still alive (pid $(cat "$dir/pid"))"
  for n in "$@"; do
    st="$(gh issue view "$n" -R "$REPO" --json state --jq .state)" || die "cannot read issue #$n"
    [ "$st" = "OPEN" ] || die "#$n is $st"
  done

  mkdir -p "$dir"
  git fetch -q origin "$BASE" || die "fetch of $BASE failed"
  git worktree add --detach -q "$wt" "origin/$BASE" || die "git worktree add failed"
  write_worktree_mode "$wt" "$@"

  # The prompt goes to a file: a detached process has no stdin from us. Its first line is the
  # session's name in every session list, so it says what the run is rather than what the
  # instructions file is called.
  {
    echo "$ARC — ${TRACK:+$TRACK · }$(printf '#%s ' "$@")"; echo
    cat "$INSTRUCTIONS"; echo; echo "---"; echo
    echo "# You are an issue run"; echo
    if [ $# -eq 1 ]; then
      echo "Sections 1 to 5 above are yours; section 6 is not. The issue is #$id."
    else
      echo "Sections 1 to 5 above are yours; section 6 is not. The driver has handed you a **batch**:"
      printf '#%s ' "$@"; echo "— in that order. One branch, named for #$id; one PR closing every one;"
      echo "one commit per issue. Finish an issue's checklist before starting the next."
    fi
    echo
    echo "You are in a worktree of your own at \`$wt\`, detached at \`$BASE\`. Create and check out"
    echo "your branch here. Never \`cd\` to the main tree."
    echo
    for n in "$@"; do
      echo "---"; echo
      gh issue view "$n" -R "$REPO" --json title,body --jq '"## #'"$n"' — " + .title + "\n\n" + .body'
      echo
    done
  } > "$dir/prompt.md"

  printf '%s\n' "$@" > "$dir/issues"
  printf '%s\n' "$BASE" > "$dir/base"

  # Launch, wait, and on a rate limit wait again and resume. The resumed run is the SAME
  # session — `claude -p --continue` in the worktree picks up its own transcript — so it carries
  # on from where the limit stopped it rather than starting the issue over.
  launch_run "$dir" "$wt" "$model_flag" "$dir/prompt.md" ""
  wait_run "$id" "$dir" "$wt" "$model_flag" || return 1

  # Keep the worktree if anything is still open: the branch and its uncommitted state are the
  # evidence of where the run stopped.
  local open=""
  for n in "$@"; do
    st="$(gh issue view "$n" -R "$REPO" --json state --jq .state 2>/dev/null || echo OPEN)"
    [ "$st" = "OPEN" ] && open="$open #$n"
  done
  if [ -z "$open" ]; then
    git worktree remove --force "$wt" && echo "  every issue closed — removed $wt"
  else
    echo "  still open:$open — worktree kept at $wt"
  fi
  [ "$(cat "$dir/exit")" = 0 ]
}

run_report() {
  local prompt
  prompt=$(echo "$ARC — report · #$PARENT $parent_title"; echo;
           cat "$INSTRUCTIONS"; echo; echo "---"; echo;
           cat <<EOF
# You are a report run

Every issue under #$PARENT ($parent_title) is closed.

**Do no work.** Section 6 above is yours; sections 1 to 5 are not. Follow 6.1's
seven steps in order and write the report to 6.2's shape. The workstream is
$parent_title.
EOF
  )
  if [ "$DRY" = 1 ]; then
    echo "  would dispatch report run for #$PARENT (--permission-mode $PERMISSION_MODE)"
    return 0
  fi
  # The report run works in this tree — it writes the arc-log — so this tree's row is raised
  # for it if it was not already, and put back the way it was found. Dropping it to Manual
  # unconditionally cost the orchestrator its own grant on 2026-09-08: the user had raised the
  # row for the whole playlist, Fire's report run ran here, and every merge after it was denied.
  local prev_mode
  prev_mode="$(grep -m1 -iE '^\|[^|]*mode[^|]*\|' HANDOFF.md 2>/dev/null | awk -F'|' '{print $3}' | tr -d '*` ' | tr '[:upper:]' '[:lower:]')"
  if [ "$prev_mode" = autonomous ]; then
    printf '%s' "$prompt" | claude -p --permission-mode "$PERMISSION_MODE"
  else
    set_mode Autonomous "#$PARENT $parent_title report"
    printf '%s' "$prompt" | claude -p --permission-mode "$PERMISSION_MODE" || { set_mode Manual; return 1; }
    set_mode Manual
  fi
}

# --resume: a run that stopped — limit, crash, gave up — continues its own session.
if [ -n "$RESUME" ]; then
  dir="$RUNS/$RESUME"; wt="$WT_ROOT/$RESUME"
  [ -f "$dir/issues" ] || die "no run $RESUME under $RUNS"
  [ -d "$wt" ] || die "worktree $wt is gone — the session cannot continue; dispatch the issues afresh"
  [ -f "$dir/pid" ] && alive "$(cat "$dir/pid")" && die "run $RESUME is still alive"
  model_flag=""; [ -n "$MODEL" ] && model_flag="--model $MODEL"
  echo "arc-loop: resuming run $RESUME — $(tr '\n' ' ' < "$dir/issues")"
  mv -f "$dir/out.json" "$dir/out.$(date +%H%M%S).json" 2>/dev/null || true
  resume_run "$dir" "$wt" "$model_flag"
  wait_run "$RESUME" "$dir" "$wt" "$model_flag" || exit 1
  open=""
  for n in $(cat "$dir/issues"); do
    st="$(gh issue view "$n" -R "$REPO" --json state --jq .state 2>/dev/null || echo OPEN)"
    [ "$st" = "OPEN" ] && open="$open #$n"
  done
  if [ -z "$open" ]; then git worktree remove --force "$wt" && echo "  every issue closed — removed $wt"
  else echo "  still open:$open — worktree kept at $wt"; fi
  exit 0
fi

# --- a handed batch: one run, then stop ---------------------------------------------
# The playlist decides what shares a run; this script does not. Every issue must be a child
# of the workstream, so a batch cannot smuggle work in from outside the queue.
if [ -n "$ISSUES" ]; then
  children=" $(open_children | tr '\n' ' ') "
  for n in $ISSUES; do
    case "$children" in *" $n "*) ;; *) die "#$n is not an open child of #$PARENT" ;; esac
  done
  echo "arc-loop: batch run for $(printf '#%s ' $ISSUES)"
  # shellcheck disable=SC2086
  run_batch $ISSUES || { echo "arc-loop: the batch run exited non-zero" >&2; exit 1; }
  echo "arc-loop: batch done. Selection, --max and the report run are the plain invocation's."
  exit 0
fi

# --- the loop -------------------------------------------------------------------
count=0
last=""
while :; do
  if ! issue=$(next_issue); then
    if [ -n "$(open_children)" ]; then
      echo "arc-loop: every remaining issue is blocked — stopping"
      exit 1
    fi
    echo "arc-loop: workstream complete, dispatching report run"
    run_report
    # The report run leaves the parent issue open — closing it is the user's, after they have
    # read the report.
    echo "arc-loop: done. #$PARENT stays open until you close it."
    echo "arc-loop: the next workstream is a separate invocation."
    exit 0
  fi

  # a run that does not close its issue would otherwise loop forever
  if [ "$issue" = "$last" ]; then
    echo "arc-loop: #$issue still open after its run — stopping rather than repeating" >&2
    exit 1
  fi

  count=$((count + 1))
  echo "arc-loop: [$count] issue run for #$issue"
  if ! run_batch "$issue"; then
    echo "arc-loop: the run for #$issue exited non-zero — stopping" >&2
    exit 1
  fi
  last="$issue"

  if [ "$MAX" != 0 ] && [ "$count" -ge "$MAX" ]; then
    echo "arc-loop: reached --max $MAX — stopping"
    exit 0
  fi

  # a dry run never closes anything; one pass is the whole demonstration
  [ "$DRY" = 1 ] && { echo "arc-loop: dry run stops after one selection"; exit 0; }
done
