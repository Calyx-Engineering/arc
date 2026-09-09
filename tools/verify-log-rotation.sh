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
#   archive    the arc BEFORE this one has its log in `docs/arc-log/events/`. This is the
#              assertion that survives #273: the archive is tracked, so it reads the same in a
#              fresh clone, in CI, and in a worktree five minutes old — where the live log is
#              either absent or headerless and can say nothing. An arc that closed without
#              anyone rotating its log is exactly what fails here, next arc, in every tree
#   header     `.claude/arc/log.md`'s `**Arc:**` names the arc the current branch belongs to.
#              A work branch counts as its arc: arc/04-dogfood-issue-238-x is arc/04-dogfood.
#              Only where a header exists — see below
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
#                      checkout. Reported as a note naming the header to add — see the code.
#                      The `archive` assertion above is what covers those trees instead: it
#                      reads tracked files, so it does not need the live log to exist at all
#   a header edited    someone who retypes the `**Arc:**` line without moving the file passes.
#   in place           A gate reading one file cannot tell that from a rotation: the entries
#                      above the line are the evidence, and nothing reads those
#
# THE HEADER HALF IS A DEVELOPER-MACHINE CHECK; THE ARCHIVE HALF IS NOT. The live log is
# gitignored (#273), so CI has no header to read and those two assertions go quiet there — and
# quiet in a new worktree too, which is most of them. `archive` is the answer to that: it reads
# only tracked files, so it is the half that fires everywhere, and it is the half that catches
# the omission #239 opened on.
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
# entry as the header answers about whatever was logged last. Thirty lines rather than twelve
# for headroom only: the header block is nine lines today and a note added ABOVE the `**Arc:**`
# line — the archived arc-03 log carries one below it — would push it out of a tight window and
# read a headed file as headerless. Both reads are anchored, so the extra lines add no exposure:
# every entry line starts with a timestamp or two spaces, and neither pattern can match one.
header_arc() {
  sed -n '1,30p' "$1" 2>/dev/null \
    | sed -n 's/^\*\*Arc:\*\* *`\([^`]*\)`.*/\1/p' | head -n1
}

# `Previous:` as written in the header: a markdown link's target, or the literal word when
# there is no link. Only a link is checkable.
header_previous_link() {
  sed -n '1,30p' "$1" 2>/dev/null \
    | sed -n 's/^\*\*Arc:\*\*.*\*\*Previous:\*\* *\[[^]]*\](\([^)]*\)).*/\1/p' | head -n1
}

# ---- the archive ----------------------------------------------------------------
# THE ARC BEFORE THIS ONE HAS ITS LOG IN `docs/arc-log/events/`. Everything else this script
# reads is the live log, which #273 made untracked — so in a fresh clone, in CI, and in a
# worktree created five minutes ago there is no header to compare and the header check can
# only stay quiet. That is most trees. This assertion reads tracked files only, so it says the
# same thing everywhere, and it fails on exactly the omission #239 opened on: an arc that
# closed without anyone moving its log.
#
# THE PREVIOUS ARC, NOT EVERY ARC. `docs/arc-log/arc-02-foundation.md` exists and there is no
# `events/arc-02-foundation.log.md`, correctly — arc 02 closed before the event log did, and
# arc 03's own header records `Previous: none — this is the first`. A rule that demanded one
# per arc-log would open red on a fact nobody can change. So: the highest-numbered arc below
# this one, and only once something has been archived at all.
check_archive() {
  local root="$1" arc="$2" num prev="" prevnum=0 f b n
  num="${arc#arc/}"; num="${num%%-*}"

  # Nothing archived yet anywhere: this repository has not reached its first rotation, and a
  # missing file is not evidence of a skipped step.
  set -- "$root"/docs/arc-log/events/arc-*.log.md
  if [ ! -e "$1" ]; then
    note "docs/arc-log/events/ holds no archived log yet — nothing has been rotated to compare against"
    return
  fi

  for f in "$root"/docs/arc-log/arc-*.md; do
    [ -f "$f" ] || continue
    b="${f##*/}"; b="${b%.md}"          # arc-03-camp
    n="${b#arc-}"; n="${n%%-*}"         # 03
    case "$n" in ''|*[!0-9]*) continue ;; esac
    if [ "$n" -lt "$num" ] && [ "$n" -gt "$prevnum" ]; then prevnum="$n"; prev="$b"; fi
  done

  if [ -z "$prev" ]; then
    note "$arc is the first arc with an arc-log — no earlier arc to have rotated"
  elif [ -f "$root/docs/arc-log/events/$prev.log.md" ]; then
    ok "the arc before this one is archived — docs/arc-log/events/$prev.log.md"
  else
    bad "$arc is open and $prev's event log was never rotated out of .claude/arc/log.md" \
        "docs/arc-log/events/$prev.log.md does not exist" \
        "templates/event-log.md, § Rotation — at arc close the live log moves there"
  fi
}

# ---- the check, against one root and one branch ---------------------------------
# Taken as arguments rather than read from the environment, so the selftest below runs the
# same code the repository run does. A checker whose fixtures exercise a copy of its logic is
# a checker that passes while the real path is broken.
check_tree() {
  local root="$1" branch="$2" log="$1/.claude/arc/log.md" arc hdr prev

  if ! arc="$(arc_of "$branch")"; then
    note "branch $branch is not an arc branch — no arc to compare anything against"
    return
  fi

  check_archive "$root" "$arc"

  if [ ! -f "$log" ]; then
    note "no live log at .claude/arc/log.md — a fresh tree has none, and the archive above is what covers it"
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
  elif [ -f "$root/docs/arc-log/events/$archived" ]; then
    # THE REMEDY MUST NOT OVERWRITE. The live log is per-worktree (#273), so several trees can
    # each hold a divergent log headed the same closed arc, and each derives the same archive
    # name from it. `mv` onto an existing tracked archive clobbers it without asking, and the
    # `git add` on the next line would stage the clobber. Say what is true instead.
    bad "the live log is headed $hdr, this branch belongs to $arc, and $hdr is ALREADY archived" \
        "docs/arc-log/events/$archived exists and holds another tree's copy of that log" \
        "do not mv onto it — this worktree's log is a per-worktree slice, not the record" \
        "open a fresh .claude/arc/log.md headed $arc, and keep this file only if its entries are wanted"
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
# EVERY CASE NAMES ITS VERDICT, AND THERE ARE THREE OF THEM. A case that only asks "did FAILED
# go up" cannot tell an `ok` from a `note`, and this script emits notes on purpose — so the two
# cases added to pin the fresh-clone behaviour both passed against a version with the fix taken
# back out. `expect` is `ok` (at least one assertion passed, none failed), `note` (nothing
# asserted either way) or `fail`.
selftest() {
  local F; F="$(mktemp -d)"
  trap 'rm -rf "$F"' RETURN

  # <name> <header-arc or -> [previous-link]. `-` builds the tree with no live log at all.
  fixture() {
    local d="$F/$1"
    mkdir -p "$d/.claude/arc" "$d/docs/arc-log/events"
    printf '# arc-log\n' > "$d/docs/arc-log/arc-03-camp.md"
    printf '# arc-log\n' > "$d/docs/arc-log/arc-04-dogfood.md"
    [ "$2" = "-" ] && return 0
    if [ -n "${3:-}" ]; then
      printf '# Event log — %s\n\n**Arc:** `%s` · **Rotated:** 2026-09-09 · **Previous:** [%s](%s)\n\n---\n' \
        "$2" "$2" "$3" "$3" > "$d/.claude/arc/log.md"
    else
      printf '# Event log — %s\n\n**Arc:** `%s` · **Rotated:** 2026-09-09 · **Previous:** none\n\n---\n' \
        "$2" "$2" > "$d/.claude/arc/log.md"
    fi
  }

  # The arc before this one, archived. Without it every case below fails the archive assertion,
  # which is correct behaviour and would drown the case it is not about.
  archived_prev() { printf 'entries\n' > "$F/$1/docs/arc-log/events/arc-03-camp.log.md"; }

  run_case() {  # <label> <fixture> <branch> <expect ok|note|fail>
    local before_f=$FAILED before_p=$PASSED got
    check_tree "$F/$2" "$3" >/dev/null 2>&1
    if [ "$FAILED" -gt "$before_f" ]; then got=fail
    elif [ "$PASSED" -gt "$before_p" ]; then got=ok
    else got=note; fi
    PASSED=$before_p; FAILED=$before_f
    if [ "$got" = "$4" ]; then
      ok "selftest — $1 reads as $4"
    else
      bad "selftest — $1 read as $got, expected $4"
    fi
  }

  fixture current arc/04-dogfood; archived_prev current
  run_case "a log headed the arc it is on" current arc/04-dogfood ok
  run_case "a log headed the arc a WORK branch belongs to" current arc/04-dogfood-issue-238-log-volume ok
  run_case "a log headed the arc a pr work branch belongs to" current arc/04-dogfood-pr302-rotation ok

  fixture stale arc/03-camp
  run_case "a log left headed the previous arc, nothing archived" stale arc/04-dogfood-issue-238-log-volume fail
  run_case "a stale log read from a non-arc branch" stale main note
  run_case "a stale log read from a detached HEAD" stale HEAD note

  # The clobber case: this tree's log is headed a closed arc whose archive already exists,
  # which is every sibling worktree once one of them has rotated. The remedy must not be `mv`.
  fixture clobber arc/03-camp; archived_prev clobber
  run_case "a stale log whose archive already exists" clobber arc/04-dogfood fail
  local out
  out="$(check_tree "$F/clobber" arc/04-dogfood 2>&1)"
  case "$out" in
    *"do not mv onto it"*) ok "selftest — the remedy refuses to overwrite an existing archive" ;;
    *) bad "selftest — the remedy for an already-archived arc still says mv" "$out" ;;
  esac

  # A fresh tree, which after #273 is every new clone and every new worktree: no live log at
  # all. The archive assertion is the one that has to carry it, so this reads as `ok`.
  fixture missing -; archived_prev missing
  run_case "no live log, previous arc archived" missing arc/04-dogfood ok

  # The same tree before anything was ever rotated. Nothing to compare: a note, not a failure.
  fixture virgin -
  run_case "no live log and nothing archived yet" virgin arc/04-dogfood note

  # THE OMISSION THIS GATE EXISTS FOR, in the shape a fresh clone sees it: arc 04 is open, arc
  # 03 was never rotated, and something else has been archived so the floor rule does not
  # excuse it. No live log is involved at all — this is the half that fires in CI.
  fixture skipped -
  printf 'entries\n' > "$F/skipped/docs/arc-log/events/arc-02-foundation.log.md"
  run_case "an arc closed without its log being rotated" skipped arc/04-dogfood fail

  # The floor rule: arc 02 has no archived log and correctly never will, because it closed
  # before the event log existed. Working on arc 03 must not fail on that.
  fixture floor -
  printf '# arc-log\n' > "$F/floor/docs/arc-log/arc-02-foundation.md"
  run_case "the arc before the first event log" floor arc/03-camp note

  # A firing created the live log before rotation opened it: entries and no header. This is
  # what a new worktree holds seconds after checkout, and failing on it fails verify-all there.
  fixture headerless -; archived_prev headerless
  printf '2026-09-09T14:45Z  mode-guard  mode-check\n  checked: — none reached\n  outcome: ok — nothing\n' \
    > "$F/headerless/.claude/arc/log.md"
  run_case "a live log a firing created, entries and no header" headerless arc/04-dogfood ok
  out="$(check_tree "$F/headerless" arc/04-dogfood 2>&1)"
  case "$out" in
    *"no **Arc:** header"*) ok "selftest — a headerless log is named in a note rather than passed over" ;;
    *) bad "selftest — a headerless log produced no note" "$out" ;;
  esac

  # A header pushed down by a note block above it still has to read. Twelve lines was the old
  # window; this fixture is what would have been called headerless under it.
  fixture noted arc/04-dogfood; archived_prev noted
  {
    head -n 1 "$F/noted/.claude/arc/log.md"
    i=0; while [ $i -lt 12 ]; do printf '> a note line that pushes the header down\n'; i=$((i + 1)); done
    tail -n +2 "$F/noted/.claude/arc/log.md"
  } > "$F/noted/.claude/arc/log.md.new" && mv "$F/noted/.claude/arc/log.md.new" "$F/noted/.claude/arc/log.md"
  run_case "a header pushed past line twelve by a note block" noted arc/04-dogfood ok
  # And decisively: with a twelve-line window this same fixture reads headerless, so the case
  # asserts the header was FOUND rather than that nothing failed.
  out="$(check_tree "$F/noted" arc/04-dogfood 2>&1)"
  case "$out" in
    *"the live log is headed arc/04-dogfood"*) ok "selftest — the header below a note block is the one that was read" ;;
    *) bad "selftest — the header below a note block was not read" "$out" ;;
  esac

  fixture dangling arc/04-dogfood ../../docs/arc-log/events/arc-03-camp.log.md
  run_case "Previous: naming a file that is not there" dangling arc/04-dogfood fail
  archived_prev dangling
  run_case "Previous: naming a file that is" dangling arc/04-dogfood ok
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
