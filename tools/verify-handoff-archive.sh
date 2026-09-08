#!/usr/bin/env bash
# verify-handoff-archive.sh — a handoff rewrite leaves the prior version on disk.
#
#   tools/verify-handoff-archive.sh            check this repository
#   tools/verify-handoff-archive.sh selftest   run the fixture cases
#
# WHY THIS EXISTS AND verify-hook.sh DOES NOT COVER IT. #152's "done when" is a claim about
# the filesystem: after a rewrite, the prior version is still there. verify-hook.sh scores a
# hook's VERDICT — allow, deny, report — which is the right question for a guard and the wrong
# one for a hook whose whole job is a side effect. A hook could report "archived" and copy
# nothing, and every case there would still pass. So the cases below run hooks/handoff-archive
# against real repositories and then read the archive back.
#
# ORDER IS PART OF THE PROPERTY. `verify-hook.sh` runs a case directory as an unordered set, so
# "the second edit does not retake the snapshot" cannot be expressed there — it needs a first
# edit to have happened. The sequencing cases live here, where each is driven explicitly.
#
# AND ITS KILL-SWITCH CHECK IS VACUOUS FOR THIS HOOK, WHICH IS WHY CASE 10 EXISTS. `verify-hook.sh`
# re-runs the first `report/` case with HOME pointed at a fixture holding HOOKS_OFF. That payload
# carries the session id the earlier run already used, so this hook's once-per-session marker is
# set and it is silent on the second run whether or not the kill switch works. Case 10 below uses
# a fresh repository and a fresh session, and asserts the switch suppresses THE COPY rather than
# the message — which is the half that matters for a hook whose job is a side effect.
#
# THE COLD-START CASE IS THE ONE THAT MATTERS. #152 asks for the copy at cold start rather than
# at write time, because a session that crashes never reaches write time. Case 3 is that: the
# session edits an unrelated file, never touches the handoff, and the handoff is already
# archived. A copy taken when the handoff is written would fail that case.
#
# WHAT IT CANNOT DO. It runs the hook as a program against fixture repositories. It does not
# prove the hook is invoked by a live session — no gate here does, tools/verify-all.sh --list
# says so. Registration in hooks/hooks.json is checked as text, which is presence and not
# firing.
#
# REPORTS, NEVER BLOCKS beyond its exit code. Same precedent as every verifier here.

set -u

SELF="$(cd "$(dirname "$0")" && pwd)/$(basename "$0")"
HOOK_REL=hooks/handoff-archive

# ---- the live check ---------------------------------------------------------------------
report() {
  local root="$1"
  local hook="$root/$HOOK_REL" json="$root/hooks/hooks.json"
  local passed=0 failed=0

  pass() { echo "  PASS  $1"; passed=$((passed + 1)); }
  fail() { echo "  FAIL  $1"; shift; for l in "$@"; do echo "        $l"; done; failed=$((failed + 1)); }

  echo "verify-handoff-archive — the prior version survives the rewrite"
  echo

  if [ ! -f "$hook" ]; then
    fail "$HOOK_REL exists" "no such file"
    echo; echo "$passed passed, $failed failed"; return 1
  fi
  pass "$HOOK_REL exists"

  # The kill switch, asserted rather than trusted. verify-hook.sh checks this too; a hook that
  # writes to disk is the one where losing it matters most, so it is checked at both gates.
  if grep -q 'HOOKS_OFF' "$hook"; then
    pass "the kill switch line is present"
  else
    fail "the kill switch line is present" "HOOKS_OFF must make this hook inert"
  fi

  # Registered, and on the tools that replace file content.
  if [ ! -f "$json" ]; then
    fail "hooks/hooks.json exists" "no such file"
  elif grep -q 'handoff-archive' "$json"; then
    if grep -q 'Edit|Write|NotebookEdit' "$json"; then
      pass "the hook is registered on Edit|Write|NotebookEdit"
    else
      fail "the hook is registered on Edit|Write|NotebookEdit" \
           "registered, but not on the matcher that catches a file being replaced"
    fi
    # Registered on Bash as well, or `cat > HANDOFF.md`, `mv` and `rm` destroy the file with no
    # copy taken — the edit tools never see a redirect.
    #
    # Scoped to the Bash block, not counted across the file. Counting occurrences passes when the
    # hook is listed twice inside the edit-tools block, which is not registration on Bash at all —
    # the assertion has to look where it claims to look.
    # PostToolUse has a "Bash" matcher of its own, so the file is cut at PostToolUse first — a
    # greedy match reads the wrong block and reports the opposite of the truth. Then each matcher
    # block is a record, and the Bash one must carry this hook.
    local preblock
    preblock="$(tr -d ' \n\t' < "$json" | sed 's/"PostToolUse".*//')"
    if printf '%s' "$preblock" \
         | awk 'BEGIN{RS="\"matcher\":\""} /^Bash"/ && /handoff-archive/{f=1} END{exit !f}'; then
      pass "the hook is registered on the Bash matcher too"
    else
      fail "the hook is registered on the Bash matcher too" \
           "registered only on the edit tools, a shell overwrite of the handoff takes no copy" \
           "handoff-archive does not appear between \"matcher\":\"Bash\" and the next matcher"
    fi
  else
    fail "the hook is registered in hooks/hooks.json" \
         "an unregistered hook never fires, however well it is tested"
  fi

  # #152: the copy location is gitignored too — this is recovery, not record.
  if git -C "$root" check-ignore -q ".arc-work/archive/20260101-000000/HANDOFF.md" 2>/dev/null; then
    pass "the archive location is gitignored"
  else
    fail "the archive location is gitignored" \
         "a recovery copy that enters the record is the record growing a stale file — #152" \
         "git check-ignore said .arc-work/archive/... is not ignored"
  fi

  # ...and a CONSUMING repository is told to ignore it too. The probe above only speaks for this
  # repository. The skill's setup step said "add HANDOFF.md to .gitignore", one entry, written
  # before this store existed — so every other repo would have committed the recovery copies and
  # the requirement would have been true here and false everywhere it ships.
  local skill="$root/skills/handoff/SKILL.md"
  if [ ! -f "$skill" ]; then
    fail "the skill's setup step exists" "no skills/handoff/SKILL.md"
  elif grep -qF '.arc-work/' "$skill" && grep -n 'gitignore' "$skill" >/dev/null 2>&1; then
    if grep -A4 -iE '^\*\*Add .*gitignore' "$skill" | grep -qF '.arc-work/'; then
      pass "a new repo is told to ignore the archive as well as the handoff"
    else
      fail "a new repo is told to ignore the archive as well as the handoff" \
           "the setup step names only the handoff, so a consuming repo commits every copy" \
           "expected .arc-work/ within the 'Add ... to .gitignore' setup step"
    fi
  else
    fail "a new repo is told to ignore the archive as well as the handoff" \
         "the skill never names .arc-work/"
  fi

  echo
  echo "$passed passed, $failed failed"
  [ "$failed" = "0" ] || return 1
  return 0
}

# ---- the self-test ----------------------------------------------------------------------
if [ "${1:-}" = "selftest" ]; then
  HOOK="$(cd "$(dirname "$SELF")/.." && pwd)/$HOOK_REL"
  passed=0; failed=0
  WORK="$(mktemp -d)"; trap 'rm -rf "$WORK"' EXIT
  # A fixture HOME with no kill switch, so a real HOOKS_OFF on the machine running this gate
  # cannot silence the hook and turn every case below into a false pass.
  RUN_HOME="$WORK/home"; mkdir -p "$RUN_HOME/.claude"

  ok()  { echo "  PASS  $1"; passed=$((passed + 1)); }
  bad() { echo "  FAIL  $1"; shift; for l in "$@"; do echo "        $l"; done; failed=$((failed + 1)); }

  make_repo() {  # make_repo <name> [handoff-content] — a repo with a tracked file
    local dir="$WORK/$1"
    mkdir -p "$dir/src"
    git -C "$dir" init -q 2>/dev/null
    printf 'tracked\n' > "$dir/src/a.c"
    printf '.arc-work/\n' > "$dir/.gitignore"
    git -C "$dir" add -A 2>/dev/null
    git -C "$dir" -c user.email=v@x -c user.name=v commit -q -m init 2>/dev/null
    [ "$#" -ge 2 ] && printf '%s' "$2" > "$dir/HANDOFF.md"
    printf '%s' "$dir"
  }

  fire() {  # fire <session> <cwd> <tool> <file_path>
    printf '{"session_id":"%s","cwd":"%s","tool_name":"%s","tool_input":{"file_path":"%s"}}' \
      "$1" "$2" "$3" "$4" | HOME="$RUN_HOME" bash "$HOOK" 2>&1
  }

  archived_copies() {  # archived_copies <repo> <relpath>
    find "$1/.arc-work/archive" -type f -path "*/$2" 2>/dev/null | sort
  }

  echo "verify-handoff-archive selftest — real repositories, the hook run as a program"
  echo

  # ---- 1 · the property #152 names: a rewrite leaves the prior version on disk -----------
  ORIG='# Handoff — 2026-09-07 14:00

Load-bearing: the 3.3 V rail cannot source 500 mA.'
  repo=$(make_repo rewrite "$ORIG")
  fire s1 "$repo" Write "$repo/HANDOFF.md" >/dev/null
  printf '# Handoff — rewritten, everything above destroyed\n' > "$repo/HANDOFF.md"   # the overwrite
  copy=$(archived_copies "$repo" "HANDOFF.md" | head -n1)
  if [ -z "$copy" ]; then
    bad "a handoff rewrite leaves the prior version on disk" "nothing was archived"
  elif [ "$(cat "$copy")" = "$ORIG" ]; then
    ok "a handoff rewrite leaves the prior version on disk, byte for byte"
  else
    bad "a handoff rewrite leaves the prior version on disk, byte for byte" \
        "a copy exists but its content is not what the session was given" \
        "archived: $(head -c 80 "$copy")"
  fi

  # ---- 2 · and the copy is taken BEFORE the write, not after ----------------------------
  # Case 1 would also pass if the copy were taken afterwards. This one cannot: the hook is
  # fired, the file is overwritten, and nothing fires again.
  if [ -n "$copy" ] && ! grep -q 'rewritten' "$copy" 2>/dev/null; then
    ok "the copy predates the overwrite — it does not contain the new content"
  else
    bad "the copy predates the overwrite" "the archive holds the post-rewrite text"
  fi

  # ---- 3 · cold start: the handoff is copied at the first edit of an UNRELATED file ------
  # This is #152's "not at write time". A session that crashes here never reaches a handoff
  # write, and the copy already exists.
  repo=$(make_repo coldstart "$ORIG")
  fire s2 "$repo" Edit "$repo/src/a.c" >/dev/null
  if [ -n "$(archived_copies "$repo" "HANDOFF.md")" ]; then
    ok "the handoff is archived at the first edit of an unrelated file, not at write time"
  else
    bad "the handoff is archived at the first edit of an unrelated file, not at write time" \
        "the copy waits for a handoff write, which a crashing session never reaches — #152"
  fi

  # ---- 4 · once per session ---------------------------------------------------------------
  # The first copy holds what the USER wrote. A second would hold this session's own edits and
  # would push the real one down the list.
  printf 'session edit one\n' > "$repo/HANDOFF.md"
  fire s2 "$repo" Edit "$repo/src/a.c" >/dev/null
  n=$(archived_copies "$repo" "HANDOFF.md" | wc -l | tr -d ' ')
  if [ "$n" = "1" ]; then
    ok "a second edit in the same session does not retake the snapshot"
  else
    bad "a second edit in the same session does not retake the snapshot" "found $n copies, wanted 1"
  fi

  # ---- 5 · a new session takes its own ----------------------------------------------------
  fire s3 "$repo" Edit "$repo/src/a.c" >/dev/null
  n=$(archived_copies "$repo" "HANDOFF.md" | wc -l | tr -d ' ')
  if [ "$n" -ge 2 ]; then
    ok "a new session takes its own snapshot"
  else
    bad "a new session takes its own snapshot" "still $n copy/copies after a second session"
  fi

  # ---- 6 · any user-authored file, not only the handoff ----------------------------------
  repo=$(make_repo anyfile)
  printf 'a diagram the user spent hours on\n' > "$repo/diagram.excalidraw"
  fire s4 "$repo" Write "$repo/diagram.excalidraw" >/dev/null
  copy=$(archived_copies "$repo" "diagram.excalidraw" | head -n1)
  if [ -n "$copy" ] && grep -q 'hours on' "$copy"; then
    ok "an untracked file that is not the handoff is archived before it is replaced"
  else
    bad "an untracked file that is not the handoff is archived before it is replaced" \
        "#152 asks for any user-authored file, not only HANDOFF.md"
  fi

  # ---- 7 · a tracked file is not archived — git is already the copy ----------------------
  fire s5 "$repo" Edit "$repo/src/a.c" >/dev/null
  if [ -z "$(archived_copies "$repo" "src/a.c")" ]; then
    ok "a tracked file is not archived — git can restore it"
  else
    bad "a tracked file is not archived" \
        "duplicating what git already holds makes the store noise and hides the real recoveries"
  fi

  # ---- 8 · a file in a subdirectory keeps its path, so recovery is a plain copy -----------
  repo=$(make_repo nested)
  mkdir -p "$repo/docs/notes"
  printf 'user notes\n' > "$repo/docs/notes/bench.md"
  fire s6 "$repo" Write "$repo/docs/notes/bench.md" >/dev/null
  if [ -n "$(archived_copies "$repo" "docs/notes/bench.md")" ]; then
    ok "the archived copy keeps its path under the repo root"
  else
    bad "the archived copy keeps its path under the repo root" \
        "a flattened name makes recovery a guess when two files share a basename"
  fi

  # ---- 9 · the archive is never archived into itself --------------------------------------
  # Without the guard, editing a recovered copy folds the store into itself on every edit.
  before=$(find "$repo/.arc-work/archive" -type f 2>/dev/null | wc -l | tr -d ' ')
  inner=$(find "$repo/.arc-work/archive" -type f -name "bench.md" 2>/dev/null | head -n1)
  fire s7 "$repo" Write "$inner" >/dev/null
  after=$(find "$repo/.arc-work/archive" -type f 2>/dev/null | wc -l | tr -d ' ')
  if [ "$before" = "$after" ]; then
    ok "editing a file inside the archive does not archive the archive"
  else
    bad "editing a file inside the archive does not archive the archive" \
        "$before files before, $after after"
  fi

  # ---- 10 · the kill switch really suppresses the copy, not only the report ---------------
  repo=$(make_repo killswitch "$ORIG")
  KS="$WORK/ks"; mkdir -p "$KS/.claude"; touch "$KS/.claude/HOOKS_OFF"
  printf '{"session_id":"s8","cwd":"%s","tool_name":"Write","tool_input":{"file_path":"%s"}}' \
    "$repo" "$repo/HANDOFF.md" | HOME="$KS" bash "$HOOK" >/dev/null 2>&1
  if [ -z "$(archived_copies "$repo" "HANDOFF.md")" ]; then
    ok "HOOKS_OFF suppresses the copy, not just the message"
  else
    bad "HOOKS_OFF suppresses the copy, not just the message" \
        "the kill switch has to reach the side effect, or it is not a kill switch"
  fi

  # ---- 10b · a Bash call takes the snapshot too -------------------------------------------
  # `cat > HANDOFF.md`, `mv`, `sed -i` and `rm` never reach Edit or Write. Registered only on the
  # edit tools, the hook missed every one of them: the handoff would be gone and no copy taken.
  repo=$(make_repo bashpath "$ORIG")
  printf '{"session_id":"sb1","cwd":"%s","tool_name":"Bash","tool_input":{"command":"cat > HANDOFF.md"}}' \
    "$repo" | HOME="$RUN_HOME" bash "$HOOK" >/dev/null 2>&1
  copy=$(archived_copies "$repo" "HANDOFF.md" | head -n1)
  if [ -n "$copy" ] && [ "$(cat "$copy")" = "$ORIG" ]; then
    ok "a Bash call takes the snapshot before a shell overwrite"
  else
    bad "a Bash call takes the snapshot before a shell overwrite" \
        "the edit-tool matchers alone never see a redirect, an mv or an rm"
  fi

  # ---- 10c · a Bash call is SILENT even when it archives ----------------------------------
  # `permissionDecision: "allow"` approves the call rather than annotating it. On the edit tools
  # that is the house shape; on Bash it would auto-approve the session's first shell command as a
  # side effect of taking a snapshot, and that command can be anything.
  out=$(fire sb2 "$(make_repo bashquiet "$ORIG")" Bash ""); rc=$?
  if [ "$rc" = "0" ] && [ -z "$out" ]; then
    ok "a Bash call says nothing — speaking there would auto-approve the command"
  else
    bad "a Bash call says nothing — speaking there would auto-approve the command" \
        "exit $rc, output: $out"
  fi

  # ---- 10d · the fast-path marker is written even with no handoff to copy -----------------
  # The marker used to be written only inside archive_file, past its own early returns, so it
  # existed only where there HAD been an untracked handoff. Every repo without one — every
  # non-Arc repo the plugin is installed into — then ran the whole body on every Bash call.
  # Asserted on the marker itself: exit code and silence are identical on both paths.
  repo=$(make_repo nohandoff_fast)
  fire sb3 "$repo" Bash "" >/dev/null
  if [ -e "$repo/.git/arc-archive-sb3-handoff" ]; then
    ok "the fast-path marker is written in a repo with no handoff at all"
  else
    bad "the fast-path marker is written in a repo with no handoff at all" \
        "without it the fast path never fires where there is nothing to copy — the common case"
  fi

  # ---- 11 · no repository, and malformed input — silent, and no crash --------------------
  mkdir -p "$WORK/norepo"
  out=$(fire s9 "$WORK/norepo" Edit "$WORK/norepo/a.txt"); rc=$?
  if [ "$rc" = "0" ] && [ -z "$out" ]; then
    ok "outside a git repository the hook is silent and exits 0"
  else
    bad "outside a git repository the hook is silent and exits 0" "exit $rc, output: $out"
  fi

  out=$(printf 'not json at all' | HOME="$RUN_HOME" bash "$HOOK" 2>&1); rc=$?
  if [ "$rc" = "0" ]; then
    ok "malformed input exits 0 — a crashing PreToolUse hook blocks every edit"
  else
    bad "malformed input exits 0" "exit $rc, output: $out"
  fi

  # ---- 12 · a repo whose handoff does not exist is not an error --------------------------
  repo=$(make_repo nohandoff)
  out=$(fire s10 "$repo" Edit "$repo/src/a.c"); rc=$?
  if [ "$rc" = "0" ] && [ -z "$out" ]; then
    ok "a repository with no handoff is silent"
  else
    bad "a repository with no handoff is silent" "exit $rc, output: $out"
  fi

  echo
  echo "$passed passed, $failed failed"
  [ "$failed" = "0" ] || exit 1
  exit 0
fi

if [ "${1:-}" = "--root" ]; then
  report "${2:-.}"
  exit $?
fi

report "$(cd "$(dirname "$0")/.." && pwd)"
exit $?
