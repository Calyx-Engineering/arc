#!/usr/bin/env bash
# hooks-off.sh — mute an Arc hook, in this repository, for a bounded window. Carries #202.
#
#   bash tools/hooks-off.sh <hook|all> [minutes]   mute; minutes defaults to 30, caps at 480
#   bash tools/hooks-off.sh status                 what is muted here, and when each lapses
#   bash tools/hooks-off.sh clear [<hook|all>]     end it now; with no argument, all of it
#   bash tools/hooks-off.sh selftest               the gate
#
# WHY A COMMAND AND NOT A FILE. Arc's kill switch was `touch ~/.claude/HOOKS_OFF`, and it
# failed on the one occasion it was reached for. Observed 2026-09-07: needed, attempted, and
# landed at `r:\arc\HOOKS_OFF.txt` — wrong directory, wrong name, no effect, and nothing said
# so. An extensionless file, in a hidden folder, created with a verb PowerShell does not have,
# on a platform where Explorer appends `.txt`, by someone already dealing with a broken
# guardrail. Four ways to get it wrong and feedback on none of them.
#
# A command removes exactly that: it refuses a hook name that does not exist and prints the
# ones that do, it writes where the hooks actually look, and it says what it did and when it
# lapses. One instruction works in PowerShell, cmd and bash — `bash tools/hooks-off.sh` — so
# there is one line to remember rather than one per shell.
#
# AND IT IS NOT THE OLD SWITCH WITH A WRAPPER. Three properties changed with it:
#
#   per-hook     muting `branch-guard` to get past it leaves `mode-guard` guarding
#   expiring     a forgotten mute heals itself; the old one disabled every guard indefinitely
#   repo-scoped  the state lives in this repository's git directory, so no other repository on
#                the machine is touched — and being inside `.git` it cannot be committed
#
# NEEDS NO AGENT. This is the escape hatch for the session that is being blocked, so anything
# invoked through that session would fail the same way. It is typed by a human, in whatever
# terminal is already open.
#
# The read side — what a hook consults — is `hooks/lib/hooks-off`, and it is the only thing
# that defines where the state lives. This script sources it rather than recomputing the path:
# a writer and a reader that each work the location out separately eventually disagree, and
# the failure is silent in the direction that matters — a switch that reports success and
# mutes nothing.

set -u

HERE="$(cd "$(dirname "$0")" && pwd)"
HOOKS_DIR="$(cd "$HERE/.." && pwd)/hooks"

DEFAULT_MINUTES=30
MAX_MINUTES=480

if ! . "$HOOKS_DIR/lib/hooks-off" 2>/dev/null; then
  echo "hooks-off: cannot read $HOOKS_DIR/lib/hooks-off — is this a complete checkout?" >&2
  exit 2
fi

usage() { sed -n '2,7p' "$0" | sed 's/^#\{1,\} \{0,1\}//'; }

# The state file for the repository the human is standing in — never CLAUDE_PROJECT_DIR, which
# inside a session belongs to the agent rather than to the terminal.
locate() {
  if ! _arc_hooks_off_locate "$PWD"; then
    echo "hooks-off: $PWD is not inside a git repository." >&2
    echo "           The switch is repo-scoped. Run this from the repository you want muted." >&2
    return 1
  fi
  STATE="$_ARC_HOOKS_OFF_FILE"
  return 0
}

now_epoch() {
  local t
  printf -v t '%(%s)T' -1 2>/dev/null
  case "$t" in ''|*[!0-9]*) t="$(date +%s)" ;; esac
  printf '%s' "$t"
}

# Local wall-clock for an epoch. The builtin first; `date -d @` only where it is absent.
stamp() {
  local t
  printf -v t '%(%Y-%m-%d %H:%M)T' "$1" 2>/dev/null
  case "$t" in ''|*'%'*) t="$(date -d "@$1" '+%Y-%m-%d %H:%M' 2>/dev/null)" ;; esac
  printf '%s' "${t:-epoch $1}"
}

relative() {
  local s="$1"
  if [ "$s" -lt 0 ]; then printf 'lapsed %d minutes ago' "$(( (0 - s + 59) / 60 ))"
  elif [ "$s" -lt 60 ]; then printf 'in under a minute'
  else printf 'in %d minutes' "$(( s / 60 ))"
  fi
}

known_hooks() {
  local f
  for f in "$HOOKS_DIR"/*; do
    [ -f "$f" ] || continue
    case "${f##*/}" in TEMPLATE|hooks.json|*.md|*.json) continue ;; esac
    printf '%s\n' "${f##*/}"
  done
}

# A name that is not a hook is the failure this command exists to remove: the old switch
# accepted every typo in silence. Refuse it, and say what the names are.
validate() {
  local want="$1"
  [ "$want" = "all" ] && return 0
  if known_hooks | grep -qxF -- "$want"; then return 0; fi
  echo "hooks-off: no hook named '$want'." >&2
  echo "           Hooks in $HOOKS_DIR:" >&2
  known_hooks | sed 's/^/             /' >&2
  echo "             all   (every hook)" >&2
  return 1
}

# Rewrite the state with the live entries, plus whatever ADD_HOOK/ADD_EXP add and minus
# whatever DROP names. Pruning on every write is why the file cannot silt up with entries
# that lapsed weeks ago.
rewrite() {
  local now exp who tmp add="${ADD_HOOK:-}" drop="${DROP:-}"
  now="$(now_epoch)"
  tmp="$STATE.$$"
  : > "$tmp" 2>/dev/null || return 1
  if [ -f "$STATE" ]; then
    while read -r exp who _; do
      case "$exp" in ''|*[!0-9]*) continue ;; esac
      [ "$exp" -gt "$now" ] || continue
      [ -n "$add" ] && [ "$who" = "$add" ] && continue
      [ -n "$drop" ] && { [ "$drop" = "all-entries" ] || [ "$drop" = "$who" ]; } && continue
      printf '%s %s\n' "$exp" "$who" >> "$tmp"
    done < "$STATE"
  fi
  [ -n "$add" ] && printf '%s %s\n' "${ADD_EXP}" "$add" >> "$tmp"
  if [ -s "$tmp" ]; then mv -f "$tmp" "$STATE"; else rm -f "$tmp" "$STATE"; fi
  return 0
}

cmd_status() {
  locate || return 1
  local now exp who any=0
  now="$(now_epoch)"
  echo "hooks-off — $STATE"
  echo
  if [ -f "$STATE" ]; then
    while read -r exp who _; do
      case "$exp" in ''|*[!0-9]*) continue ;; esac
      [ "$exp" -gt "$now" ] || continue
      printf '  %-18s lapses %s local, %s\n' "$who" "$(stamp "$exp")" "$(relative "$(( exp - now ))")"
      any=1
    done < "$STATE"
  fi
  [ "$any" = "0" ] && echo "  nothing is muted — every Arc hook in this repository is on."
  echo
  return 0
}

cmd_clear() {
  local what="${1:-all-entries}"
  [ "$what" != "all-entries" ] && { validate "$what" || return 2; }
  locate || return 1
  ADD_HOOK="" ADD_EXP="" DROP="$what"
  rewrite
  ADD_HOOK="" ADD_EXP="" DROP=""
  if [ "$what" = "all-entries" ]; then
    echo "hooks-off — cleared. Every Arc hook in this repository is on again."
  else
    echo "hooks-off — cleared '$what'. It is on again."
  fi
  return 0
}

cmd_mute() {
  local hook="$1" minutes="${2:-}" now exp top
  [ -z "$minutes" ] && minutes="$DEFAULT_MINUTES"
  validate "$hook" || return 2
  case "$minutes" in
    ''|*[!0-9]*) echo "hooks-off: minutes must be a whole number, got '$minutes'" >&2; return 2 ;;
  esac
  [ "$minutes" -lt 1 ] && minutes=1
  if [ "$minutes" -gt "$MAX_MINUTES" ]; then
    echo "hooks-off: $minutes minutes is over the $MAX_MINUTES-minute cap — using $MAX_MINUTES."
    minutes="$MAX_MINUTES"
  fi
  locate || return 1
  now="$(now_epoch)"
  exp=$(( now + minutes * 60 ))
  ADD_HOOK="$hook" ADD_EXP="$exp" DROP=""
  rewrite || { echo "hooks-off: could not write $STATE" >&2; return 1; }
  ADD_HOOK="" ADD_EXP=""

  top="$(git -C "$PWD" rev-parse --show-toplevel 2>/dev/null)"
  echo
  if [ "$hook" = "all" ]; then
    echo "hooks-off — EVERY Arc hook is muted in this repository."
  else
    echo "hooks-off — $hook is muted in this repository."
  fi
  echo
  printf '  hook       %s\n' "$hook"
  printf '  scope      %s  (this repository and every worktree of it, nothing else)\n' "${top:-$PWD}"
  printf '  lapses     %s local, %s\n' "$(stamp "$exp")" "$(relative "$(( exp - now ))")"
  printf '  state      %s\n' "$STATE"
  printf '  restore    bash tools/hooks-off.sh clear %s\n' "$hook"
  echo
  return 0
}

# ---- selftest -------------------------------------------------------------------
# The writer and the reader are checked against each other, because agreement between them is
# the only property that matters: a mute the hooks do not see is worse than no mute at all.
selftest() {
  # T, O, N and wt are deliberately NOT local: the EXIT trap below runs after this function
  # has returned, and a local is gone by then — the cleanup would fail on an unbound name.
  local P F rc out
  P=0; F=0
  T="$(mktemp -d)"
  O="$(mktemp -d)"
  N="$(mktemp -d)"
  wt="${T}-wt"
  trap 'git -C "$T" worktree remove --force "$wt" >/dev/null 2>&1; rm -rf "$T" "$O" "$N" "$wt"' EXIT

  ok()  { echo "  PASS  $1"; P=$((P + 1)); }
  bad() { echo "  FAIL  $1"; shift; for l in "$@"; do echo "        $l"; done; F=$((F + 1)); }

  git -C "$T" init -q 2>/dev/null
  git -C "$T" -c user.email=v@x -c user.name=v commit -q --allow-empty -m init 2>/dev/null
  git -C "$O" init -q 2>/dev/null

  # Does a hook, reading through the library, agree that <name> is muted in <dir>?
  reads_muted() {
    ( cd "$1" && CLAUDE_PROJECT_DIR="$1" bash -c '. "$1/lib/hooks-off"; arc_hooks_off "$2"' _ "$HOOKS_DIR" "$2" )
  }

  echo "hooks-off selftest"
  echo

  out="$( cd "$T" && bash "$HERE/hooks-off.sh" branch-guard 30 2>&1 )"
  if [ -f "$T/.git/arc-hooks-off" ]; then ok "a mute writes the repository's state file"
  else bad "a mute writes the repository's state file" "$out"; fi

  case "$out" in
    *lapses*local*) ok "it says when the mute lapses" ;;
    *)              bad "it says when the mute lapses" "$out" ;;
  esac
  case "$out" in
    *"$T/.git/arc-hooks-off"*) ok "it says where it wrote" ;;
    *)                         bad "it says where it wrote" "$out" ;;
  esac
  case "$out" in
    *"hooks-off.sh clear branch-guard"*) ok "it says how to restore" ;;
    *)                                   bad "it says how to restore" "$out" ;;
  esac

  if reads_muted "$T" branch-guard; then ok "a hook reads the mute the command wrote"
  else bad "a hook reads the mute the command wrote" "$(cat "$T/.git/arc-hooks-off" 2>&1)"; fi

  if reads_muted "$T" mode-guard; then bad "per-hook — another hook is NOT muted" "mode-guard read as muted"
  else ok "per-hook — another hook is NOT muted"; fi

  out="$( cd "$T" && bash "$HERE/hooks-off.sh" status 2>&1 )"
  case "$out" in
    *branch-guard*lapses*) ok "status reads the mute back" ;;
    *)                     bad "status reads the mute back" "$out" ;;
  esac

  # A second mute of the same hook replaces its entry. Two entries for one hook leaves the
  # earlier expiry unreachable, so `clear` and the cap both stop meaning anything.
  ( cd "$T" && bash "$HERE/hooks-off.sh" branch-guard 45 >/dev/null 2>&1 )
  if [ "$(grep -c 'branch-guard' "$T/.git/arc-hooks-off")" = "1" ]; then
    ok "re-muting replaces the entry rather than stacking one"
  else
    bad "re-muting replaces the entry rather than stacking one" "$(cat "$T/.git/arc-hooks-off")"
  fi

  # Expiry, read by the hook — the property the old switch had no version of.
  printf '%s branch-guard\n' "$(( $(now_epoch) - 60 ))" > "$T/.git/arc-hooks-off"
  if reads_muted "$T" branch-guard; then bad "an expired mute is inert" "still read as muted"
  else ok "an expired mute is inert"; fi

  # And pruned the next time anything is written, so the file cannot silt up.
  ( cd "$T" && bash "$HERE/hooks-off.sh" mode-guard 5 >/dev/null 2>&1 )
  if grep -q 'branch-guard' "$T/.git/arc-hooks-off"; then
    bad "an expired entry is pruned on the next write" "$(cat "$T/.git/arc-hooks-off")"
  else
    ok "an expired entry is pruned on the next write"
  fi

  ( cd "$T" && bash "$HERE/hooks-off.sh" clear >/dev/null 2>&1 )
  if [ -f "$T/.git/arc-hooks-off" ]; then bad "clear removes the state" "file still present"
  else ok "clear removes the state"; fi

  # The typo case. This is the failure the command exists for: a name that is not a hook used
  # to be accepted in silence, and the guard stayed on with nothing saying why.
  out="$( cd "$T" && bash "$HERE/hooks-off.sh" branchguard 2>&1 )"; rc=$?
  if [ "$rc" != "0" ] && printf '%s' "$out" | grep -q 'branch-guard'; then
    ok "an unknown hook name is refused, and the real names are printed"
  else
    bad "an unknown hook name is refused, and the real names are printed" "exit $rc" "$out"
  fi
  if [ -f "$T/.git/arc-hooks-off" ]; then
    bad "a refused name writes nothing" "state file was created"
  else
    ok "a refused name writes nothing"
  fi

  # The cap. A mute nobody can make permanent is the whole of the expiry property.
  out="$( cd "$T" && bash "$HERE/hooks-off.sh" all 100000 2>&1 )"
  if printf '%s' "$out" | grep -q -- "$MAX_MINUTES-minute cap"; then
    ok "an over-long window is capped, and the cap is announced"
  else
    bad "an over-long window is capped, and the cap is announced" "$out"
  fi
  ( cd "$T" && bash "$HERE/hooks-off.sh" clear >/dev/null 2>&1 )

  # Repository scope, from the reader's side.
  ( cd "$O" && bash "$HERE/hooks-off.sh" all 30 >/dev/null 2>&1 )
  if reads_muted "$T" branch-guard; then
    bad "another repository's mute does not reach this one" "cross-repository leak"
  else
    ok "another repository's mute does not reach this one"
  fi

  # Worktree scope, from the writer's side: one repository, one switch, whichever tree the
  # human is standing in. Five worktrees run on this machine, and the terminal already open is
  # rarely the one that is stuck.
  git -C "$T" worktree add -q "$wt" -b wtbranch 2>/dev/null
  if [ -d "$wt" ]; then
    ( cd "$wt" && bash "$HERE/hooks-off.sh" mode-guard 30 >/dev/null 2>&1 )
    if [ -f "$T/.git/arc-hooks-off" ] && reads_muted "$T" mode-guard; then
      ok "a mute set from a worktree reaches the main tree"
    else
      bad "a mute set from a worktree reaches the main tree" "no shared state file"
    fi
  else
    bad "a mute set from a worktree reaches the main tree" "git worktree add failed"
  fi
  ( cd "$T" && bash "$HERE/hooks-off.sh" clear >/dev/null 2>&1 )

  # Outside a repository it refuses rather than writing somewhere arbitrary.
  out="$( cd "$N" && bash "$HERE/hooks-off.sh" all 2>&1 )"; rc=$?
  if [ "$rc" != "0" ] && printf '%s' "$out" | grep -qi 'not inside a git repository'; then
    ok "outside a repository it refuses and says why"
  else
    bad "outside a repository it refuses and says why" "exit $rc" "$out"
  fi

  echo
  echo "$P passed, $F failed"
  [ "$F" = "0" ]
}

case "${1:-}" in
  ""|-h|--help) usage; exit 0 ;;
  selftest)     selftest; exit $? ;;
  status)       cmd_status; exit $? ;;
  clear)        cmd_clear "${2:-all-entries}"; exit $? ;;
  -*)           echo "hooks-off: unknown option '$1'" >&2; usage >&2; exit 2 ;;
  *)            cmd_mute "$1" "${2:-}"; exit $? ;;
esac
