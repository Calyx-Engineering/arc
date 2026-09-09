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
#   CLAIMED    Selection is not an interlock on its own. Two dispatchers read the same open list
#              on 2026-09-07 and both took #158. Before any work starts, `tools/arc-claim.sh`
#              claims the issue with a comment carrying an owner token and a TTL; selection
#              subtracts the claimed set, the wait loop heartbeats the claim, and every exit path
#              — including a kill — releases it. A dispatcher that dies leaks nothing past one
#              TTL. #214.
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
CLAIM="$HERE/arc-claim.sh"

# --- claims: which issues this dispatcher holds --------------------------------
# THE OPEN LIST IS NOT AN INTERLOCK. Two dispatchers reading it pick the same issue, which is
# what happened to #158 — one built and measured while the other committed that tree, opened the
# PR and merged it. So an issue is CLAIMED before any work starts, and the claim lives on the
# issue in GitHub rather than in this script, for the same reason the position does: kill the
# loop and restart, and the claim is still there. tools/arc-claim.sh holds the mechanism. #214.
#
# CLAIMS is "<issue>:<token>" per held claim. The token names this dispatcher process — two
# dispatchers run as the same GitHub user, so the account cannot be the identity.
CLAIMS=""
CLAIMED_SET=""
CLAIM_DIR=""

# ONE OWNER FOR THE WHOLE DISPATCHER, minted here rather than per `arc-claim.sh` invocation:
# every issue this loop holds then carries the same name, and the pid in the claim comment is
# this script's rather than that of a helper process which exited seconds later.
# THE `||` GOES INSIDE THE SUBSHELL, not after the assignment. Under `set -euo pipefail` a
# missing `hostname` makes the pipeline exit 127 and the script dies at this line — before the
# fallback on the next one can run, and before `--status` and `--report`, which need no owner
# at all, reach their early exit.
LOOP_HOST="$( (hostname 2>/dev/null || echo unknown) | tr -cd 'A-Za-z0-9.-' )"
[ -n "$LOOP_HOST" ] || LOOP_HOST="unknown"
LOOP_RAND="$( (od -An -N4 -tx1 /dev/urandom 2>/dev/null || echo "$RANDOM$RANDOM") | tr -cd 'a-f0-9' )"
[ -n "$LOOP_RAND" ] || LOOP_RAND="$$"
LOOP_OWNER="$LOOP_HOST/$$/${LOOP_RAND:0:8}"

claim_token() {  # claim_token <issue>
  local e
  for e in $CLAIMS; do
    case "$e" in "$1:"*) printf '%s' "${e#*:}"; return 0 ;; esac
  done
  return 1
}

# take_claim <issue> — 0 if it is ours, 1 if another dispatcher holds it, 2 if that could not be
# read. THE THREE ARE DISTINCT ALL THE WAY UP: arc-claim.sh separates "held" from "I could not
# tell" precisely so a caller can, and collapsing them here would dispatch on a rate limit.
#
# The token is recorded beside the run so that reclaim_claim below can find it. That file is
# identity, not queue position — losing it costs one TTL, never correctness.
take_claim() {  # take_claim <issue>
  local tok rc=0
  tok="$(ARC_CLAIM_OWNER="$LOOP_OWNER" bash "$CLAIM" take "$1")" || rc=$?
  [ "$rc" = 0 ] || return "$rc"
  CLAIMS="$CLAIMS $1:$tok"
  [ -n "$CLAIM_DIR" ] && { mkdir -p "$CLAIM_DIR"; printf '%s\n' "$tok" > "$CLAIM_DIR/claim-$1"; }
  return 0
}

# reclaim_claim <issue> — take it, but first try to pick up the token a KILLED dispatcher left.
# #214 requires that killing the loop and restarting resumes correctly; a fresh process mints a
# fresh token, so without this a restarted loop reads its own claim as somebody else's for a
# full TTL.
#
# ONLY `--resume` MAY CALL THIS, AND ONLY AFTER ITS LIVENESS GUARD. The token in the file is a
# bearer credential: `arc-claim.sh refresh` matches on the string, so anything that reads the
# file can refresh — and `$RUNS` is shared by every dispatcher started from this checkout. What
# makes it safe is the caller, which has already established that the run recorded in this
# directory is DEAD. `run_batch` deliberately does not call it: it refuses outright when the
# worktree or a live run is already there, so a dispatcher racing into another's run directory
# never reaches a claim at all.
#
# A refresh that could not be READ is not a refusal. Exit 2 means the tracker could not be
# reached; deleting the token file on that would destroy the one artifact the next restart
# needs, at the moment it is most likely to be needed.
reclaim_claim() {  # reclaim_claim <issue>
  local tok rc=0
  if [ -n "$CLAIM_DIR" ] && [ -f "$CLAIM_DIR/claim-$1" ]; then
    tok="$(cat "$CLAIM_DIR/claim-$1")"
    if [ -n "$tok" ]; then
      bash "$CLAIM" refresh "$1" "$tok" >/dev/null 2>&1 || rc=$?
      case "$rc" in
        0) CLAIMS="$CLAIMS $1:$tok"
           echo "  #$1 — reclaimed the claim a killed dispatcher left" >&2
           return 0 ;;
        2) return 2 ;;
        *) rm -f "$CLAIM_DIR/claim-$1" ;;
      esac
    else
      rm -f "$CLAIM_DIR/claim-$1"
    fi
  fi
  take_claim "$1"
}

release_claim() {  # release_claim <issue>
  local tok rest e
  tok="$(claim_token "$1")" || return 0
  bash "$CLAIM" release "$1" "$tok" || true
  [ -n "$CLAIM_DIR" ] && rm -f "$CLAIM_DIR/claim-$1"
  rest=""
  for e in $CLAIMS; do
    case "$e" in "$1:"*) ;; *) rest="$rest $e" ;; esac
  done
  CLAIMS="$rest"
  return 0
}

# RELEASED ON EVERY EXIT PATH. run_batch drops its own claims when its run ends, so the next
# issue is dispatched with nothing stale held; this trap is the other paths — a `die` anywhere,
# a Ctrl-C, a kill, and the plain exits. Without it a killed loop leaves the issue locked until
# the TTL runs out, which is the failure a lock without an expiry has and this one must not.
# It never fails the script it is unwinding: a claim that cannot be deleted expires on its own.
release_claims() {
  local e
  for e in $CLAIMS; do
    bash "$CLAIM" release "${e%%:*}" "${e#*:}" || true
    [ -n "$CLAIM_DIR" ] && rm -f "$CLAIM_DIR/claim-${e%%:*}"
  done
  CLAIMS=""
  return 0
}
# EACH SIGNAL TRAP EXITS. A handler that returns hands control back to the line after the one
# that was interrupted, so `trap release_claims INT` would have turned Ctrl-C into "drop the
# claim on the issue whose run is still executing, then carry on and dispatch the next one" —
# strictly worse than the no-trap behaviour it replaced. 130 and 143 are the shell's own codes
# for the two signals. The EXIT trap then fires as well and finds nothing left to do.
trap release_claims EXIT
trap 'release_claims; exit 130' INT
trap 'release_claims; exit 143' TERM

# read_claimed — the set selection subtracts, refreshed once per pass rather than once per
# candidate. IT FAILS CLOSED. An unreadable claim list is indistinguishable from an empty one,
# and treating "I could not tell" as "nobody holds it" is the whole defect this guards against.
read_claimed() {
  local raw
  raw="$(bash "$CLAIM" claimed "$PARENT")"     || die "cannot read which issues other dispatchers hold — refusing to select blind"
  CLAIMED_SET=" $(printf '%s
' "$raw" | awk 'NF{print $1}' | tr '
' ' ') "
}

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

# CLAIMED_SET is read by the caller, not here: this runs inside a command substitution, so a
# `die` in it would kill only the subshell and read as "nothing eligible".
next_issue() {
  local n b
  for n in $(open_children); do
    case "$CLAIMED_SET" in
      *" $n "*) echo "  #$n claimed by another dispatcher" >&2; continue ;;
    esac
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
# THE HEARTBEAT. A claim's TTL is how long after this dispatcher dies before the issue is free,
# not how long a run may take — so while the run is alive the expiry is pushed out.
#
# A REFUSED REFRESH IS REPORTED. arc-claim.sh returns 1 to say "the claim you think you hold is
# gone" — reaped, or deleted by hand. Swallowing that leaves the dispatcher believing it holds an
# issue another one is free to take, which is the whole failure being fixed here.
heartbeat() {  # heartbeat <run-dir>
  local n tok rc
  for n in $(cat "$1/issues" 2>/dev/null); do
    tok="$(claim_token "$n")" || continue
    rc=0; bash "$CLAIM" refresh "$n" "$tok" || rc=$?
    # The two are not the same warning. 1 is "the claim you think you hold is gone"; 2 is "the
    # tracker could not be reached", which the next beat retries in five minutes.
    case "$rc" in
      0) ;;
      2) echo "  the claim on #$n could not be read this beat — retrying next beat" >&2 ;;
      *) echo "  WARNING: the claim on #$n is gone — another dispatcher may take it" >&2 ;;
    esac
  done
  return 0
}

# sleep_heartbeat <seconds> <run-dir> — a long wait, sliced so the claim never goes unrefreshed
# for longer than one slice. The rate-limit wait defaults to 600s against a 1800s TTL, but
# ARC_LOOP_RETRY_WAIT is a knob and nothing couples the two; slicing removes the coupling.
#
# A NON-INTEGER WAIT IS SLEPT WHOLE, NOT SKIPPED. `sleep` takes `10m`; `[ 10m -gt 0 ]` is an
# error, and a `while` whose condition errors runs no body at all — so slicing a value like that
# would turn the rate-limit wait into no wait, and fire MAX_RETRY resumes straight back into the
# limit that caused them.
sleep_heartbeat() {
  local left="$1" dir="$2" slice
  case "$left" in
    ''|*[!0-9]*)
      echo "  ARC_LOOP_RETRY_WAIT=$left is not a whole number of seconds — sleeping it unsliced," \
           "so the claim is not refreshed during the wait" >&2
      sleep "$left"
      heartbeat "$dir"
      return 0 ;;
  esac
  while [ "$left" -gt 0 ]; do
    slice=300; [ "$left" -lt 300 ] && slice="$left"
    sleep "$slice"
    left=$((left - slice))
    heartbeat "$dir"
  done
  return 0
}

wait_run() {
  local id="$1" dir="$2" wt="$3" model_flag="$4" pid attempt=0 ticks=0
  while :; do
    pid="$(cat "$dir/pid")"
    while [ ! -f "$dir/exit" ]; do
      alive "$pid" || { echo "  run $id died without an exit code — see $dir/err.log" >&2; return 1; }
      sleep 30
      # Every tenth poll: five minutes against a TTL measured in tens of them.
      ticks=$((ticks + 1))
      [ "$((ticks % 10))" = 0 ] && heartbeat "$dir"
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
    sleep_heartbeat "$RETRY_WAIT" "$dir"
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
  # CLAIMED BEFORE ANY WORK, INCLUDING THE CHECKS BELOW. Two dispatchers validating the same
  # issue is the state that produced #158; the claim is what makes the second one stop. Return 3
  # rather than 1 — losing a race is not a failed run, and the caller picks something else. A
  # read that could not be made is neither: it stops the dispatcher rather than guessing.
  # THESE TWO GUARDS COME FIRST, ahead of the claim. They are what says this run directory is
  # nobody else's, and a claim taken before them is a claim taken inside another dispatcher's
  # workspace — then released by the `die` on the next line.
  [ -d "$wt" ] && die "worktree $wt already exists — remove it first: git worktree remove --force $wt"
  [ -f "$dir/pid" ] && alive "$(cat "$dir/pid")" && die "run $id is still alive (pid $(cat "$dir/pid"))"

  CLAIM_DIR="$dir"
  local crc
  for n in "$@"; do
    crc=0; take_claim "$n" || crc=$?
    if [ "$crc" = 2 ]; then
      release_claims
      die "could not read whether #$n is claimed — refusing to dispatch blind"
    fi
    if [ "$crc" != 0 ]; then
      echo "  #$n is claimed by another dispatcher — nothing dispatched" >&2
      release_claims
      return 3
    fi
  done

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
  local rc=0
  wait_run "$id" "$dir" "$wt" "$model_flag" || rc=1

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
  if [ "$rc" = 0 ] && [ "$(cat "$dir/exit")" != 0 ]; then rc=1; fi

  # RELEASED HERE, not left to the trap: the loop dispatches the next issue before this shell
  # exits, and a claim outliving its run says work is underway when none is. The trap is for the
  # paths that never reach this line.
  for n in "$@"; do release_claim "$n"; done
  return "$rc"
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
  # A resume is a dispatch: it claims what it is about to work on, or stops. Without this the
  # one path that skips selection is the one path with no interlock. CLAIM_DIR first, so a run
  # whose dispatcher was killed reclaims its own token instead of colliding with itself.
  # `reclaim_claim`, not `take_claim`: the guard three lines above has established that this
  # run's process is dead, which is the only condition under which picking up its token is safe.
  CLAIM_DIR="$dir"
  for n in $(cat "$dir/issues"); do
    crc=0; reclaim_claim "$n" || crc=$?
    [ "$crc" = 2 ] && die "could not read whether #$n is claimed — refusing to resume blind"
    [ "$crc" = 0 ] || die "#$n is claimed by another dispatcher — not resuming run $RESUME"
  done
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
  release_claims
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
  rc=0
  # shellcheck disable=SC2086
  run_batch $ISSUES || rc=$?
  [ "$rc" = 3 ] && die "the batch is claimed by another dispatcher — nothing dispatched"
  [ "$rc" = 0 ] || { echo "arc-loop: the batch run exited non-zero" >&2; exit 1; }
  echo "arc-loop: batch done. Selection, --max and the report run are the plain invocation's."
  exit 0
fi

# --- the loop -------------------------------------------------------------------
count=0
last=""
# A lost race costs a pass, and a pass is several `gh` calls. Bounded so a dispatcher that keeps
# losing stops rather than spinning on the API.
lost=0
while :; do
  read_claimed
  if ! issue=$(next_issue); then
    if [ -n "$(open_children)" ]; then
      if [ -n "$(printf '%s' "$CLAIMED_SET" | tr -d ' ')" ]; then
        echo "arc-loop: every remaining issue is blocked or claimed by another dispatcher —" \
             "claimed:$CLAIMED_SET— stopping"
      else
        echo "arc-loop: every remaining issue is blocked — stopping"
      fi
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
  rc=0
  run_batch "$issue" || rc=$?
  # A lost race is not a failed run. The claimed set is re-read at the top of the next pass, so
  # this issue is skipped there and something else is picked; `count` is put back because
  # nothing was dispatched.
  if [ "$rc" = 3 ]; then
    count=$((count - 1))
    lost=$((lost + 1))
    [ "$lost" -ge 5 ] && die "lost the race for an issue five times — another dispatcher is taking this workstream; stopping"
    sleep 5
    continue
  fi
  lost=0
  if [ "$rc" != 0 ]; then
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
