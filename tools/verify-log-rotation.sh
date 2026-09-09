#!/usr/bin/env bash
# verify-log-rotation.sh — the live event log names the arc that is writing to it.
#
#   tools/verify-log-rotation.sh            check this repository
#   tools/verify-log-rotation.sh selftest   run the fixture cases
#
# WHY. `templates/event-log.md` specifies rotation at arc open and at arc close, and nothing
# performed either. `.claude/arc/log.md` carried `**Arc:** arc/03-camp` in its header for the
# whole of arc 04 — 14,734 entries, most of them arc 04's, filed under arc 03's name. #239.
#
# ROTATION CANNOT BE A HOOK, WHICH IS WHY IT NEEDS THIS. An arc opens when a human decides one
# has opened; there is no tool call to hang the move on, and a hook that guessed from a branch
# name would rotate on the first push of a topic branch. So rotation stays a step someone
# performs — and a step nobody performs is a step nobody notices, until a gate says the header
# and the branch disagree.
#
# WHAT IT ASSERTS
#
#   header     `.claude/arc/log.md`'s `**Arc:**` names the arc the current branch belongs to.
#              A work branch counts as its arc: arc/04-dogfood-issue-238-x is arc/04-dogfood
#   previous   where the header's `Previous:` names a file, that file exists. A rotation that
#              moved the old log somewhere else leaves a link into nothing, and the chain back
#              through the arcs is the only thing making the archived logs findable
#
# WHAT IT DOES NOT ASSERT, and each silence is deliberate:
#
#   no live log        nothing to check. The live log is untracked (#273), so a fresh clone
#                      has none and a checkout that has not run a hook yet has none. Absence
#                      is the normal state of a file git does not carry
#   a non-arc branch   `main`, a topic branch, a detached HEAD. There is no arc to compare
#                      against, and inventing one from the directory name would fail every
#                      checkout that is not mid-arc
#   the archive's      whether `docs/arc-log/events/` holds a log per closed arc. That is
#   completeness       retention, which m44 still lists as undesigned
#   a headerless log   what a firing creates on its own in a fresh clone, seconds after
#                      checkout. Reported as a note naming the header to add — see the code
#   a header edited    someone who retypes the `**Arc:**` line without moving the file passes.
#   in place           A gate reading one file cannot tell that from a rotation: the entries
#                      above the line are the evidence, and nothing reads those
#
# IT IS A DEVELOPER-MACHINE GATE, NOT A CI ONE. The live log is gitignored (#273), so CI has
# no file to read and this passes silently there. It fires where the work happens, which is
# also where the omission happens.
#
# REPORTS, NEVER BLOCKS. Exit 1 names the disagreement and the two commands that fix it. Same
# precedent as every verifier here; nothing about rotation should deny a tool call.

set -u

cd "$(dirname "$0")/.." || exit 1
ROOT="$PWD"

PASSED=0
FAILED=0

ok()  { printf '  PASS  %s\n' "$1"; PASSED=$((PASSED + 1)); }
bad() { printf '  FAIL  %s\n' "$1"; shift; for m in "$@"; do [ -n "$m" ] && printf '        %s\n' "$m"; done; FAILED=$((FAILED + 1)); }
note(){ printf '  ----  %s\n' "$1"; }

# The arc a branch belongs to. `arc/04-dogfood-issue-238-log-volume` and
# `arc/03-camp-pr115-transcript-staleness` are both work branches off an arc branch, and
# CLAUDE.md's two forms are the whole vocabulary — a name that is neither is not an arc branch.
# Returns 1 rather than guessing, and every caller treats that as "nothing to compare".
arc_of() {
  local b="$1"
  case "$b" in arc/[0-9][0-9]-*) ;; *) return 1 ;; esac
  b="${b%%-issue-*}"
  b="${b%%-pr[0-9]*}"
  printf '%s' "$b"
}

# The header's `**Arc:** `arc/NN-slug`` value, from the first lines only. The rest of the file
# is entries, one of which could quote an arc name in a subject — and a checker that reads an
# entry as the header answers about whatever was logged last. Thirty lines rather than twelve:
# a header can carry a note block, as the rotated arc-03 log does, and a window that stops at
# twelve reads a headed file as headerless.
header_arc() {
  sed -n '1,30p' "$1" 2>/dev/null \
    | sed -n 's/^\*\*Arc:\*\* *`\([^`]*\)`.*/\1/p' | head -n1
}

# `Previous:` as written in the header: a markdown link's target, or the literal word when
# there is no link. Only a link is checkable.
header_previous_link() {
  sed -n '1,30p' "$1" 2>/dev/null \
    | sed -n 's/.*\*\*Previous:\*\* *\[[^]]*\](\([^)]*\)).*/\1/p' | head -n1
}

# ---- the check, against one root and one branch ---------------------------------
# Taken as arguments rather than read from the environment, so the selftest below runs the
# same code the repository run does. A checker whose fixtures exercise a copy of its logic is
# a checker that passes while the real path is broken.
check_tree() {
  local root="$1" branch="$2" log="$1/.claude/arc/log.md" arc hdr prev

  if [ ! -f "$log" ]; then
    note "no live log at .claude/arc/log.md — nothing to rotate, and nothing to check"
    return
  fi

  if ! arc="$(arc_of "$branch")"; then
    note "branch $branch is not an arc branch — no arc to compare the header against"
    return
  fi

  # `arc/03-camp` names the file `arc-03-camp.log.md` — the slash is the only difference, and
  # printing the name with it left in sends someone to a path that cannot exist.
  local archived
  hdr="$(header_arc "$log")"
  archived="arc-${hdr#arc/}.log.md"
  if [ -z "$hdr" ]; then
    # NOT A FAILURE, and this case decides whether the gate is usable at all. The library only
    # ever appends, so in a fresh clone or a new worktree the FIRST hook firing creates this
    # file with no header — seconds after checkout, before anyone could have rotated anything.
    # Failing here fails tools/verify-all.sh on every new tree in the arc. The library cannot
    # write the header either: it names the arc, and deriving that needs `git`, which is a fork
    # on a write path that forbids them.
    note "the live log has no **Arc:** header — a firing created it, rotation did not open it"
    note "give it templates/event-log.md's header, naming $arc"
  elif [ "$hdr" = "$arc" ]; then
    ok "the live log is headed $hdr, and this branch belongs to $arc"
  else
    bad "the live log is headed $hdr and this branch belongs to $arc" \
        "rotate it — templates/event-log.md, § Rotation:" \
        "  mv .claude/arc/log.md docs/arc-log/events/$archived" \
        "  git add docs/arc-log/events/$archived      # the live log itself is untracked — #273" \
        "  then open .claude/arc/log.md headed $arc, with Previous: linking the file you just moved"
  fi

  prev="$(header_previous_link "$log")"
  if [ -z "$prev" ]; then
    note "the header's Previous: names no file — nothing to resolve"
  elif [ -f "$root/.claude/arc/$prev" ] || [ -f "$root/$prev" ]; then
    ok "Previous: resolves — $prev"
  else
    bad "the header's Previous: names $prev, and no such file exists" \
        "the chain back through the arcs is what makes an archived log findable"
  fi
}

# ---- selftest -------------------------------------------------------------------
# One fixture per verdict, and both directions for each. A checker that only ever passes is
# indistinguishable from one that does nothing.
selftest() {
  local F; F="$(mktemp -d)"
  trap 'rm -rf "$F"' RETURN

  fixture() {  # <name> <header-arc or ->  [previous-link]
    local d="$F/$1"
    mkdir -p "$d/.claude/arc" "$d/docs/arc-log/events"
    [ "$2" = "-" ] && return 0
    if [ -n "${3:-}" ]; then
      printf '# Event log — %s\n\n**Arc:** `%s` · **Rotated:** 2026-09-09 · **Previous:** [%s](%s)\n\n---\n' \
        "$2" "$2" "$3" "$3" > "$d/.claude/arc/log.md"
    else
      printf '# Event log — %s\n\n**Arc:** `%s` · **Rotated:** 2026-09-09 · **Previous:** none\n\n---\n' \
        "$2" "$2" > "$d/.claude/arc/log.md"
    fi
  }

  run_case() {  # <label> <fixture> <branch> <expect pass|fail>
    local before_f=$FAILED before_p=$PASSED got=fail
    check_tree "$F/$2" "$3" >/dev/null 2>&1
    [ "$FAILED" = "$before_f" ] && got=pass
    PASSED=$before_p; FAILED=$before_f
    if [ "$got" = "$4" ]; then
      ok "selftest — $1 reads as $4"
    else
      bad "selftest — $1 read as $got, expected $4"
    fi
  }

  fixture current arc/04-dogfood
  run_case "a log headed the arc it is on" current arc/04-dogfood pass
  run_case "a log headed the arc a WORK branch belongs to" current arc/04-dogfood-issue-238-log-volume pass
  run_case "a log headed the arc a pr work branch belongs to" current arc/04-dogfood-pr302-rotation pass

  fixture stale arc/03-camp
  run_case "a log left headed the previous arc" stale arc/04-dogfood-issue-238-log-volume fail
  run_case "a stale log read from a non-arc branch" stale main pass
  run_case "a stale log read from a detached HEAD" stale HEAD pass

  fixture missing -
  run_case "no live log at all" missing arc/04-dogfood pass

  # The fresh-clone case, and the reason it is a pass rather than a failure: a firing creates
  # this file before any human has touched the tree. This case reading as `fail` is the gate
  # failing tools/verify-all.sh on every new worktree in the arc.
  fixture headerless arc/04-dogfood
  sed -i.bak '3d' "$F/headerless/.claude/arc/log.md" && rm -f "$F/headerless/.claude/arc/log.md.bak"
  run_case "a live log a firing created, with no **Arc:** header" headerless arc/04-dogfood pass

  # A header pushed down by a note block still has to read. The rotated arc-03 log carries one,
  # so a twelve-line window would have called the file this gate itself produced headerless.
  fixture noted arc/04-dogfood
  {
    head -n 1 "$F/noted/.claude/arc/log.md"
    i=0; while [ $i -lt 12 ]; do printf '> a note line that pushes the header down\n'; i=$((i + 1)); done
    tail -n +2 "$F/noted/.claude/arc/log.md"
  } > "$F/noted/.claude/arc/log.md.new" && mv "$F/noted/.claude/arc/log.md.new" "$F/noted/.claude/arc/log.md"
  run_case "a header pushed past line twelve by a note block" noted arc/04-dogfood pass

  fixture dangling arc/04-dogfood ../../docs/arc-log/events/arc-03-camp.log.md
  run_case "Previous: naming a file that is not there" dangling arc/04-dogfood fail
  printf 'x\n' > "$F/dangling/docs/arc-log/events/arc-03-camp.log.md"
  run_case "Previous: naming a file that is" dangling arc/04-dogfood pass
}

# ---- run ------------------------------------------------------------------------
echo "verify-log-rotation.sh — the live event log names the arc writing to it"
echo

if [ "${1:-}" = "selftest" ]; then
  selftest
else
  BRANCH="$(git -C "$ROOT" rev-parse --abbrev-ref HEAD 2>/dev/null)"
  [ -n "$BRANCH" ] || BRANCH=HEAD
  check_tree "$ROOT" "$BRANCH"
fi

echo
echo "$PASSED passed, $FAILED failed"
[ "$FAILED" -eq 0 ] || exit 1
