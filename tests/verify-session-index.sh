#!/usr/bin/env bash
# verify-session-index.sh — a session's transcript stays findable after its worktree is gone.
#
#   tests/verify-session-index.sh            check this repository
#   tests/verify-session-index.sh selftest   run the fixture cases
#
# WHY THIS EXISTS AND verify-hook.sh DOES NOT COVER IT. Same shape as verify-handoff-archive.sh:
# #16's "done when" is a claim about a file on disk, and `verify-hook.sh` scores a hook's VERDICT —
# allow, deny, report. `hooks/session-index` never denies anything and is silent on every path, so
# every case there passes whether or not a single entry was ever written. The cases below run the
# hook against real repositories and real fixture transcript stores, and then read the index back.
#
# ORDER IS THE WHOLE PROPERTY. #16's constraint is "write at creation, mark orphaned when the
# worktree goes — do not write then". That cannot be expressed in an unordered case directory: it
# needs a firing while the worktree exists, then the worktree removed, then a later firing. Case 7
# is that sequence, and its first half is what fails if the entry is written at deletion instead.
#
# THE MACHINE-SCOPING CASE IS THE SUBTLE ONE. The index is committed and the transcripts are not
# (m32's cross-machine open question), so a laptop pulling the desktop's index sees worktree paths
# that never existed there. Marking those orphaned would be the index lying about a live worktree
# on another machine. The rule the hook implements, and case 8 asserts: an entry is only marked
# orphaned when its worktree is absent AND its transcript directory is present on THIS machine —
# the transcript directory is what proves this machine ran that session.
#
# WHAT IT CANNOT DO. It runs the hook as a program against fixtures. It does not prove the hook is
# invoked by a live session — no gate here does, and tests/verify-all.sh --list says so.
# Registration in hooks/hooks.json is checked as text, which is presence and not firing. It also
# cannot check the slug derivation against Claude Code itself: case 2 asserts the rule measured off
# the real store on 2026-09-08 (R:/arc-wt/16 is stored as R--arc-wt-16), which is evidence rather
# than a contract. If Claude Code changes the derivation, this gate stays green and the index goes
# stale — the hook's own directory probe is what catches that, not this script.
#
# AND IT DOES NOT TEST MUTUAL EXCLUSION. The hook takes a `mkdir` lock around read-rewrite-move.
# Exclusion is a property of two processes interleaving, and nothing here can make that interleaving
# happen on demand; a case that fired two hooks and hoped would be flaky, which is worse than an
# absent one. Case 18 asserts the CLEANUP CONTRACT — the lock is released on both branches, a lock
# this session does not own is not deleted, and a stale one does not block the write — and would
# pass against a hook with the lock deleted outright. That is stated at the case as well, so the
# line is not read as coverage it is not.
#
# ONE CASE CAN SKIP RATHER THAN PASS. Case 16b drives the unreadable-index guard with `chmod 000`,
# which does nothing on Windows; where reads are still permitted the case reports SKIP rather than
# a green it has not earned. On this machine that guard has no executed coverage, and the SKIP line
# is the only place that says so.
#
# REPORTS, NEVER BLOCKS beyond its exit code. Same precedent as every verifier here.

set -u

SELF="$(cd "$(dirname "$0")" && pwd)/$(basename "$0")"
HOOK_REL=hooks/session-index
INDEX_REL=.claude/arc/sessions.md

# ---- the live check ---------------------------------------------------------------------
report() {
  local root="$1"
  local hook="$root/$HOOK_REL" json="$root/hooks/hooks.json"
  local passed=0 failed=0

  pass() { echo "  PASS  $1"; passed=$((passed + 1)); }
  fail() { echo "  FAIL  $1"; shift; for l in "$@"; do echo "        $l"; done; failed=$((failed + 1)); }

  echo "verify-session-index — the mapping outlives the worktree"
  echo

  if [ ! -f "$hook" ]; then
    fail "$HOOK_REL exists" "no such file"
    echo; echo "$passed passed, $failed failed"; return 1
  fi
  pass "$HOOK_REL exists"

  # The kill switch, asserted rather than trusted. A hook that writes to disk is the one where
  # losing the switch matters most, so it is checked at both gates.
  if grep -q 'lib/hooks-off' "$hook"; then
    pass "the kill switch line is present"
  else
    fail "the kill switch line is present" "hooks/lib/hooks-off must make this hook inert"
  fi

  # Registered, and on both matchers. A session that only ever runs Bash — every `claude -p` run
  # in this arc reaches for Bash long before it edits anything — would otherwise never be indexed.
  if [ ! -f "$json" ]; then
    fail "hooks/hooks.json exists" "no such file"
  elif grep -q 'session-index' "$json"; then
    # SCOPED TO ITS OWN MATCHER BLOCK, like the Bash check below it. An unscoped
    # `grep -q 'Edit|Write|NotebookEdit'` over the whole file passes whatever this hook is
    # registered on, because `branch-guard` and `camp-session-start` keep that matcher string in
    # the file regardless — the check would have reported parity it did not have.
    local preblock
    preblock="$(tr -d ' \n\t' < "$json" | sed 's/"PostToolUse".*//')"
    if printf '%s' "$preblock" \
         | awk 'BEGIN{RS="\"matcher\":\""} /^Edit\|Write\|NotebookEdit"/ && /session-index/{f=1} END{exit !f}'; then
      pass "the hook is registered on Edit|Write|NotebookEdit"
    else
      fail "the hook is registered on Edit|Write|NotebookEdit" \
           "registered somewhere, but not inside the edit-tools matcher block"
    fi
    # Scoped to the PreToolUse Bash block, not counted across the file — PostToolUse has a "Bash"
    # matcher of its own, so the file is cut at PostToolUse first. Counting occurrences passes when
    # the hook is listed twice inside the edit-tools block, which is not registration on Bash.
    if printf '%s' "$preblock" \
         | awk 'BEGIN{RS="\"matcher\":\""} /^Bash"/ && /session-index/{f=1} END{exit !f}'; then
      pass "the hook is registered on the Bash matcher too"
    else
      fail "the hook is registered on the Bash matcher too" \
           "a session that only runs Bash before it is interrupted leaves no index entry at all" \
           "session-index does not appear between the Bash matcher and the next one"
    fi
  else
    fail "the hook is registered in hooks/hooks.json" \
         "an unregistered hook never fires, however well it is tested"
  fi

  # #16: committed to the repo, so the mapping outlives both the worktree and the machine. The
  # inverse of the handoff archive's requirement, and the reason it is checked at all: `.claude/`
  # sits beside two gitignored session stores, and one added line would silence this mechanism
  # while every other gate stayed green.
  if git -C "$root" check-ignore -q "$INDEX_REL" 2>/dev/null; then
    fail "the index is committable" \
         "$INDEX_REL is gitignored — the mapping then dies with the machine, which is #16" \
         "git check-ignore matched it"
  else
    pass "the index location is not gitignored"
  fi

  # NOT IGNORED IS NOT TRACKED, and only one of the two is what #16 asked for. The hook creates
  # the index untracked, so a repository can pass the check above forever while every row it has
  # ever written sits outside the record and dies with the worktree. Checked only when the file
  # exists: a repository where the hook has not yet fired has nothing to track.
  if [ ! -f "$root/$INDEX_REL" ]; then
    pass "the index has not been written here yet, so there is nothing to track"
  elif git -C "$root" ls-files --error-unmatch -- "$INDEX_REL" >/dev/null 2>&1; then
    pass "the index is tracked, not merely un-ignored"
  else
    fail "the index is tracked, not merely un-ignored" \
         "$INDEX_REL exists and git does not know about it — git add it" \
         "#16 requires it committed; un-ignored and untracked satisfies none of that"
  fi

  # And a repository the plugin ships into is told to do the same, once. The gitignore setup step
  # is where a new repo already learns what to do with the two session stores, so the third
  # instruction belongs beside them rather than in a file nobody opens at setup.
  local hskill="$root/skills/handoff/SKILL.md"
  if [ ! -f "$hskill" ]; then
    fail "the setup step exists" "no skills/handoff/SKILL.md"
  elif grep -qF "$INDEX_REL" "$hskill"; then
    pass "a new repo is told to track the index alongside the two it must ignore"
  else
    fail "a new repo is told to track the index alongside the two it must ignore" \
         "skills/handoff's setup step never names $INDEX_REL" \
         "every consuming repo then writes an index nobody commits"
  fi

  # ...and the marker store IS, or every session drops an empty file into the record. The hook
  # keys `once per session` under .arc-work/, which skills/handoff's setup step already tells a
  # consuming repo to ignore — asserted here because this hook now depends on that being true.
  if git -C "$root" check-ignore -q ".arc-work/session-index/abc" 2>/dev/null; then
    pass "the once-per-session marker store is gitignored"
  else
    fail "the once-per-session marker store is gitignored" \
         "the markers are empty files, one per session, and they would enter the record"
  fi

  # AND THE SCRATCH FILES GO THERE TOO, not beside the index. `.claude/arc/` is tracked, so a lock
  # or a temporary file left there by a crashed session appears as untracked next to the record and
  # rides into the first `git add .` someone runs. Asserted as text because the failure is a path
  # in the source, and it regresses the moment someone writes the obvious `"$INDEX.lock"`.
  if grep -qE '^(LOCK|TMP)="\$INDEX' "$hook"; then
    fail "the lock and the temporary file live in the gitignored working directory" \
         "one of them is derived from \$INDEX, which puts it in the tracked .claude/arc/" \
         "a crashed session then leaves debris beside the record"
  else
    pass "the lock and the temporary file live in the gitignored working directory"
  fi

  # The format has one definition, in the template, and the template is mapped. Same rule as every
  # other template here — a template with no MAP row is one nobody checks.
  if [ ! -f "$root/templates/session-index.md" ]; then
    fail "templates/session-index.md exists" \
         "the format would then be inferred from whatever the hook last wrote"
  else
    pass "templates/session-index.md exists"
    if grep -q 'session-index' "$root/tests/verify-template-links.sh" 2>/dev/null; then
      pass "the template has a MAP row in verify-template-links.sh"
    else
      fail "the template has a MAP row in verify-template-links.sh" \
           "an unmapped template is one no gate reads"
    fi

    # THE TEMPLATE SAYS IT IS THE AUTHORITY ON THE FORMAT, AND THE HOOK HOLDS A SECOND COPY OF IT.
    # The column-name line is the one that carries the format: the field order, and what every
    # reader of the table splits on. Two copies of it with nothing comparing them is a claim of
    # authority the file cannot back, and the divergence is silent — the hook keeps writing its
    # own spelling and the template keeps documenting a table nobody produces.
    local tpl_cols hook_cols
    tpl_cols="$(grep -m1 '^| Transcript |' "$root/templates/session-index.md" 2>/dev/null)"
    hook_cols="$(grep -m1 "^  printf '| Transcript |" "$hook" 2>/dev/null \
                 | sed -e "s/^  printf '//" -e "s/\\\\n'\$//")"
    if [ -z "$tpl_cols" ] || [ -z "$hook_cols" ]; then
      fail "the hook and the template agree on the column names" \
           "one of the two has no column-name line to compare" \
           "template: ${tpl_cols:-<none>}" "hook:     ${hook_cols:-<none>}"
    elif [ "$tpl_cols" = "$hook_cols" ]; then
      pass "the hook writes the columns the template documents, character for character"
    else
      fail "the hook writes the columns the template documents, character for character" \
           "template: $tpl_cols" "hook:     $hook_cols"
    fi
  fi

  # #16's fifth requirement. The consumer has to actually read what the producer writes, or this
  # ships a file nothing opens.
  local miner="$root/agents/transcript-miner.md"
  if [ ! -f "$miner" ]; then
    fail "agents/transcript-miner.md exists" "no such file"
  elif grep -qF "$INDEX_REL" "$miner"; then
    # The old text named the index as unbuilt and told the agent to glob instead. Leaving that
    # paragraph in place beside the new one would mean the agent reads two contradictory
    # instructions and follows whichever it hits first.
    if grep -qiE 'is not built|not built . issue #16' "$miner"; then
      fail "the miner reads the index rather than globbing blind" \
           "it names the index and still describes it as unbuilt — one of the two is stale"
    else
      pass "the miner names the index by path and reads it"
    fi
  else
    fail "the miner reads the index rather than globbing blind" \
         "agents/transcript-miner.md never names $INDEX_REL, so the index ships unread — #16"
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

  # A fixture HOME, for two reasons. It is not the machine's, so nothing there
  # running this gate cannot turn every case below into a false pass. And the hook reads the
  # transcript store from $HOME/.claude/projects, so the fixture store is what the orphan sweep
  # sees — the machine's real one is never touched, and never read.
  RUN_HOME="$WORK/home"; mkdir -p "$RUN_HOME/.claude/projects"

  ok()  { echo "  PASS  $1"; passed=$((passed + 1)); }
  bad() { echo "  FAIL  $1"; shift; for l in "$@"; do echo "        $l"; done; failed=$((failed + 1)); }

  make_repo() {  # make_repo <name> [branch] — a git repo with .arc-work/ ignored
    local dir="$WORK/$1"
    mkdir -p "$dir/src"
    git -C "$dir" init -q 2>/dev/null
    printf 'tracked\n' > "$dir/src/a.c"
    printf '.arc-work/\n' > "$dir/.gitignore"
    git -C "$dir" add -A 2>/dev/null
    git -C "$dir" -c user.email=v@x -c user.name=v commit -q -m init 2>/dev/null
    [ "$#" -ge 2 ] && git -C "$dir" checkout -q -B "$2" 2>/dev/null
    printf '%s' "$dir"
  }

  fire() {  # fire <session> <cwd> <tool> [file_path]
    printf '{"session_id":"%s","cwd":"%s","tool_name":"%s","tool_input":{"file_path":"%s"}}' \
      "$1" "$2" "$3" "${4:-}" | HOME="$RUN_HOME" CLAUDE_PROJECT_DIR="$2" bash "$HOOK" 2>&1
  }

  index() { printf '%s' "$1/.claude/arc/sessions.md"; }

  rows() {  # rows <repo> — the entry rows only, header and alignment rule excluded
    grep -E '^\| `' "$(index "$1")" 2>/dev/null
  }

  col() {  # col <row> <n> — the nth cell, trimmed of spaces and backticks
    printf '%s' "$1" | awk -F'|' -v n="$2" '{gsub(/^[ `]+|[ `]+$/,"",$(n+1)); print $(n+1)}'
  }

  slug_of() { printf '%s' "$1" | tr -c 'A-Za-z0-9' '-'; }

  echo "verify-session-index selftest — real repositories, the hook run as a program"
  echo

  # ---- 1 · a firing writes one entry carrying all seven fields ---------------------------
  repo=$(make_repo w1 arc/04-dogfood-issue-16-session-index)
  fire s1 "$repo" Edit "$repo/src/a.c" >/dev/null
  n=$(rows "$repo" | wc -l | tr -d ' ')
  if [ "$n" = "1" ]; then
    ok "the first tool call of a session writes exactly one entry"
  else
    bad "the first tool call of a session writes exactly one entry" "found $n rows, wanted 1"
  fi

  row=$(rows "$repo" | head -n1)
  want_slug=$(slug_of "$repo")
  # Every cell asserted against its VALUE, not merely against being non-empty. `[ -n ]` on the
  # worktree path let a hook write any path at all and still pass — and that cell is the one the
  # whole orphan sweep keys on, so a wrong value there marks live worktrees dead and leaves dead
  # ones live. The date span is matched as two real dates for the same reason: `*[0-9]*[0-9]*`
  # accepts any string with two digits in it.
  missing=""
  [ "$(col "$row" 1)" = "$want_slug" ] || missing="$missing transcript-slug"
  [ "$(col "$row" 2)" = "$repo" ]      || missing="$missing worktree-path"
  [ "$(col "$row" 3)" = "arc/04-dogfood-issue-16-session-index" ] || missing="$missing branch"
  [ "$(col "$row" 4)" = "#16" ]            || missing="$missing issue"
  [ "$(col "$row" 5)" = "arc/04-dogfood" ] || missing="$missing arc"
  case "$(col "$row" 6)" in
    [0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]" to "[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]) ;;
    *) missing="$missing date-span" ;;
  esac
  [ "$(col "$row" 7)" = "live" ]           || missing="$missing status"
  if [ -z "$missing" ]; then
    ok "the entry carries slug, worktree, branch, issue, arc, date span and status"
  else
    bad "the entry carries slug, worktree, branch, issue, arc, date span and status" \
        "wrong or missing:$missing" "row: $row"
  fi

  # ---- 2 · the slug is Claude Code's, not an invention ------------------------------------
  # Measured off the real store 2026-09-08: R:/arc-wt/16 is stored as R--arc-wt-16, so every
  # character that is not [A-Za-z0-9] becomes a hyphen. A slug this hook computes differently is
  # a slug that points at no directory, and the index is then a table of dead names.
  if [ "$(col "$row" 1)" = "$want_slug" ]; then
    ok "the transcript slug is the working directory with every non-alphanumeric hyphenated"
  else
    bad "the transcript slug is the working directory with every non-alphanumeric hyphenated" \
        "wanted $want_slug" "got    $(col "$row" 1)"
  fi

  # ---- 3 · once per session ---------------------------------------------------------------
  # ASSERTED ON THE MARKER, NOT THE ROW COUNT. A row count is the wrong instrument here: with the
  # marker removed entirely the second firing still matches on (slug, branch), rewrites that one
  # row, and leaves the count at 1 — so the case passed while testing nothing the marker does. The
  # marker is what makes every later tool call of the session cost two file tests instead of a git
  # call, a store listing and two passes over the index.
  if [ -e "$repo/.arc-work/session-index/s1" ]; then
    ok "the once-per-session marker is written, so later calls take the fast path"
  else
    bad "the once-per-session marker is written, so later calls take the fast path" \
        "without it every tool call of the session pays the full rewrite"
  fi
  before_mtime=$(ls -l --time-style=+%s "$(index "$repo")" 2>/dev/null | awk '{print $6}')
  fire s1 "$repo" Edit "$repo/src/a.c" >/dev/null
  n=$(rows "$repo" | wc -l | tr -d ' ')
  after_mtime=$(ls -l --time-style=+%s "$(index "$repo")" 2>/dev/null | awk '{print $6}')
  if [ "$n" = "1" ] && [ "$before_mtime" = "$after_mtime" ]; then
    ok "a second tool call in the same session does not touch the index at all"
  else
    bad "a second tool call in the same session does not touch the index at all" \
        "$n rows (wanted 1); mtime $before_mtime then $after_mtime"
  fi

  # ---- 4 · a second session on the same branch updates the entry, never duplicates it ------
  # The unit is the working directory and its branch, not the session: one transcript DIRECTORY
  # holds every session run there, so a row per session would be a row per firing of the hook.
  fire s2 "$repo" Bash "" >/dev/null
  n=$(rows "$repo" | wc -l | tr -d ' ')
  if [ "$n" = "1" ]; then
    ok "a later session in the same worktree updates the entry rather than adding one"
  else
    bad "a later session in the same worktree updates the entry rather than adding one" \
        "found $n rows, wanted 1"
  fi

  # ---- 5 · a different branch in the same directory gets its own entry ---------------------
  # m32's measured case: ROADZ's #39 was worked on a branch in the main repo, so eighteen
  # transcripts piled into one shared directory spanning every branch ever checked out there. One
  # row per (directory, branch) is what gives that directory any per-issue boundary at all.
  git -C "$repo" checkout -q -B arc/04-dogfood-issue-99-other 2>/dev/null
  fire s3 "$repo" Bash "" >/dev/null
  n=$(rows "$repo" | wc -l | tr -d ' ')
  if [ "$n" = "2" ]; then
    ok "a new branch in the same directory gets its own entry — the shared-directory case"
  else
    bad "a new branch in the same directory gets its own entry" "found $n rows, wanted 2"
  fi
  second=$(rows "$repo" | sed -n 2p)
  if [ "$(col "$second" 4)" = "#99" ]; then
    ok "the second entry carries its own issue number"
  else
    bad "the second entry carries its own issue number" "row: $second"
  fi

  # ---- 6 · the index is a committable file under the repo, not a gitignored one ------------
  if git -C "$repo" check-ignore -q ".claude/arc/sessions.md" 2>/dev/null; then
    bad "the index is committable" "it is gitignored, so the mapping dies with the machine"
  else
    ok "the index sits at a path git will track"
  fi

  # ---- 7 · marked orphaned when the worktree goes — and written BEFORE it did -------------
  # The whole of #16's second constraint. The worktree here is deleted after its entry exists;
  # a later firing from ANOTHER repository flips the status. Nothing is written at deletion.
  wt=$(make_repo gone arc/04-dogfood-issue-42-doomed)
  gone_slug=$(slug_of "$wt")
  mkdir -p "$RUN_HOME/.claude/projects/$gone_slug"   # this machine ran that session
  fire s4 "$wt" Edit "$wt/src/a.c" >/dev/null
  # The entry is copied into a surviving repository's index, because the worktree that wrote it is
  # about to be deleted — which is the real sequence: the branch merges, the index merges with it,
  # then the worktree is removed.
  survivor=$(make_repo survivor arc/04-dogfood-issue-43-alive)
  mkdir -p "$survivor/.claude/arc"
  cp "$(index "$wt")" "$(index "$survivor")"
  if grep -q 'live' "$(index "$survivor")"; then
    ok "the entry was written while the worktree existed, and says live"
  else
    bad "the entry was written while the worktree existed, and says live" \
        "nothing to mark orphaned later — #16 forbids writing the entry at deletion time"
  fi

  rm -rf "$wt"
  fire s5 "$survivor" Bash "" >/dev/null
  doomed=$(rows "$survivor" | awk -F'|' -v s="$gone_slug" '{c=$2; gsub(/^[ `]+|[ `]+$/,"",c); if (c==s) print}')
  if [ -n "$doomed" ] && [ "$(col "$doomed" 7)" = "orphaned" ]; then
    ok "a later firing marks the deleted worktree's entry orphaned"
  else
    bad "a later firing marks the deleted worktree's entry orphaned" \
        "row: ${doomed:-<the entry disappeared>}"
  fi
  # `grep -- ` is not decoration. A POSIX slug begins with a hyphen (`/tmp/x` is stored as
  # `-tmp-x`), so an unguarded pattern is read as an option and the case fails on the tool rather
  # than on the hook. Real Linux transcript directories are all of this shape.
  if printf '%s' "$doomed" | grep -qF -- "$gone_slug"; then
    ok "the orphaned entry still names the transcript directory, which is the point of the index"
  else
    bad "the orphaned entry still names the transcript directory" "row: $doomed"
  fi
  if [ "$(col "$doomed" 4)" = "#42" ] && [ "$(col "$doomed" 3)" = "arc/04-dogfood-issue-42-doomed" ]; then
    ok "and it still names the branch and issue, which is what a deletion could not have supplied"
  else
    bad "and it still names the branch and issue" "row: $doomed"
  fi

  # ---- 8 · another machine's entry is left alone ------------------------------------------
  # The index is committed and the transcripts are not, so a pulled index carries worktree paths
  # that never existed on this machine. Marking those orphaned would make the index lie about a
  # live worktree elsewhere. The transcript directory's presence is what says "this machine".
  other='| `Z--elsewhere-arc-wt-7` | `Z:/elsewhere/arc-wt/7` | `arc/04-dogfood-issue-7-x` | #7 | `arc/04-dogfood` | 2026-09-01 to 2026-09-01 | live |'
  printf '%s\n' "$other" >> "$(index "$survivor")"
  fire s6 "$survivor" Bash "" >/dev/null
  foreign=$(rows "$survivor" | grep -F 'Z--elsewhere-arc-wt-7')
  if [ "$(col "$foreign" 7)" = "live" ]; then
    ok "an entry whose transcript directory is not on this machine keeps its status"
  else
    bad "an entry whose transcript directory is not on this machine keeps its status" \
        "the index is committed and shared; this one belongs to another machine" "row: $foreign"
  fi

  # ---- 9 · the mute suppresses the WRITE, not just a message ------------------------------
  # This hook is silent on every path, so a kill switch that only stopped it speaking would be
  # indistinguishable from one that worked. Repo-scoped and expiring (#202): the mute lives in
  # the fixture repository, and the second half proves it lapses on its own.
  repo=$(make_repo killswitch arc/04-dogfood-issue-50-ks)
  printf '%s session-index\n' "$(( $(date +%s) + 600 ))" > "$repo/.git/arc-hooks-off"
  printf '{"session_id":"s7","cwd":"%s","tool_name":"Edit","tool_input":{"file_path":"%s"}}' \
    "$repo" "$repo/src/a.c" | CLAUDE_PROJECT_DIR="$repo" ARC_EVENT_LOG=/dev/null bash "$HOOK" >/dev/null 2>&1
  if [ ! -f "$(index "$repo")" ]; then
    ok "an unexpired mute suppresses the write, not just the message"
  else
    bad "an unexpired mute suppresses the write, not just the message" \
        "the kill switch has to reach the side effect, or it is not a kill switch"
  fi

  printf '%s session-index\n' "$(( $(date +%s) - 600 ))" > "$repo/.git/arc-hooks-off"
  printf '{"session_id":"s7b","cwd":"%s","tool_name":"Edit","tool_input":{"file_path":"%s"}}' \
    "$repo" "$repo/src/a.c" | CLAUDE_PROJECT_DIR="$repo" ARC_EVENT_LOG=/dev/null bash "$HOOK" >/dev/null 2>&1
  if [ -f "$(index "$repo")" ]; then
    ok "an expired mute does not — the hook indexes again"
  else
    bad "an expired mute does not — the hook indexes again" \
        "a switch that never lapses is the one this replaced"
  fi
  rm -f "$repo/.git/arc-hooks-off"

  # ---- 10 · silent on every matcher --------------------------------------------------------
  # `permissionDecision: "allow"` APPROVES a call rather than annotating it. On Bash that would
  # auto-approve the session's first shell command as a side effect of indexing. This hook has
  # nothing to say to the user at all, so it says nothing on either matcher.
  repo=$(make_repo quiet arc/04-dogfood-issue-51-quiet)
  out=$(fire s8 "$repo" Bash ""); rc=$?
  if [ "$rc" = "0" ] && [ -z "$out" ]; then
    ok "a Bash call is silent — speaking there would auto-approve the command"
  else
    bad "a Bash call is silent" "exit $rc, output: $out"
  fi
  repo=$(make_repo quiet2 arc/04-dogfood-issue-52-quiet)
  out=$(fire s9 "$repo" Edit "$repo/src/a.c"); rc=$?
  if [ "$rc" = "0" ] && [ -z "$out" ]; then
    ok "an Edit call is silent too — the index is a record, not a report"
  else
    bad "an Edit call is silent too" "exit $rc, output: $out"
  fi

  # ---- 11 · malformed input, and no repository — silent, no crash, nothing written --------
  out=$(printf 'not json at all' | HOME="$RUN_HOME" bash "$HOOK" 2>&1); rc=$?
  if [ "$rc" = "0" ]; then
    ok "malformed input exits 0 — a crashing PreToolUse hook blocks every tool call"
  else
    bad "malformed input exits 0" "exit $rc, output: $out"
  fi

  mkdir -p "$WORK/norepo"
  out=$(printf '{"session_id":"s10","cwd":"%s","tool_name":"Edit","tool_input":{"file_path":"%s"}}' \
        "$WORK/norepo" "$WORK/norepo/a.txt" | HOME="$RUN_HOME" bash "$HOOK" 2>&1); rc=$?
  if [ "$rc" = "0" ] && [ ! -f "$(index "$WORK/norepo")" ]; then
    ok "outside a git repository nothing is written and the hook exits 0"
  else
    bad "outside a git repository nothing is written and the hook exits 0" \
        "exit $rc, output: $out"
  fi

  # ---- 12 · a detached HEAD is recorded, not skipped ---------------------------------------
  # tools/arc-loop.sh hands a run a worktree at a detached HEAD, and the run checks its branch out
  # afterwards. A hook that fired first and bailed on the detached state would miss the arc's own
  # worktrees — which is every worktree this index exists for. The entry is corrected on the next
  # session, once the branch is checked out; a skipped one never is.
  repo=$(make_repo detached)
  git -C "$repo" checkout -q --detach 2>/dev/null
  fire s11 "$repo" Bash "" >/dev/null
  if [ "$(rows "$repo" | wc -l | tr -d ' ')" = "1" ]; then
    ok "a detached HEAD is still indexed — arc-loop.sh hands every run one"
  else
    bad "a detached HEAD is still indexed" "arc-loop.sh hands every run a detached worktree"
  fi

  # ---- 13 · a branch naming no issue is recorded without one -------------------------------
  repo=$(make_repo topic some-topic-branch)
  fire s12 "$repo" Bash "" >/dev/null
  row=$(rows "$repo" | head -n1)
  if [ -n "$row" ] && [ "$(col "$row" 3)" = "some-topic-branch" ]; then
    ok "a topic branch is indexed with no issue rather than skipped"
  else
    bad "a topic branch is indexed with no issue rather than skipped" "row: ${row:-<none>}"
  fi

  # ---- 14 · the on-disk directory name wins over the computed one --------------------------
  # The real store holds `r--arc` for R:/arc and `R--arc-wt-16` for R:/arc-wt/16 — the same
  # machine, two cases, because an older Claude Code lowercased the slug. The computed name is a
  # guess about a directory that either exists or does not; when one exists, its real name is the
  # locator the miner has to open, so that is what gets recorded.
  #
  # THIS CASE IS WHY THE HOOK LISTS THE STORE RATHER THAN PROBING IT. `[ -d "$PROJECTS/$SLUG" ]`
  # returns true here — this machine's /tmp is case-insensitive — so a probe reports the computed
  # spelling confirmed when no directory of that name exists at all.
  repo=$(make_repo Cased arc/04-dogfood-issue-53-case)
  lower=$(slug_of "$repo" | tr 'A-Z' 'a-z')
  mkdir -p "$RUN_HOME/.claude/projects/$lower"
  fire s13 "$repo" Bash "" >/dev/null
  row=$(rows "$repo" | head -n1)
  if [ "$(col "$row" 1)" = "$lower" ]; then
    ok "an existing transcript directory's real name is recorded, not the computed spelling"
  else
    bad "an existing transcript directory's real name is recorded" \
        "wanted $lower" "got    $(col "$row" 1)"
  fi

  # ---- 15 · transcript_path in the payload beats any derivation ----------------------------
  # Claude Code hands a hook the .jsonl it is writing, so the parent directory IS the transcript
  # directory and no rule has to be inferred. Case 2's derivation is the fallback for a payload
  # that carries none; this is the path a live session actually takes, and it is the one that
  # keeps the index correct if Claude Code ever changes how a slug is spelled.
  repo=$(make_repo tpath arc/04-dogfood-issue-54-tp)
  mkdir -p "$RUN_HOME/.claude/projects/Some--Real--Slug"
  printf '{"session_id":"s14","cwd":"%s","tool_name":"Bash","transcript_path":"%s","tool_input":{}}' \
    "$repo" "$RUN_HOME/.claude/projects/Some--Real--Slug/abc.jsonl" \
    | HOME="$RUN_HOME" CLAUDE_PROJECT_DIR="$repo" bash "$HOOK" >/dev/null 2>&1
  row=$(rows "$repo" | head -n1)
  if [ "$(col "$row" 1)" = "Some--Real--Slug" ]; then
    ok "transcript_path names the directory, so no derivation is involved when one is given"
  else
    bad "transcript_path names the directory" \
        "wanted Some--Real--Slug" "got    $(col "$row" 1)"
  fi

  # ---- 16 · rows this session did not touch survive the rewrite ----------------------------
  # THE REGRESSION CASE FOR THE WORST DEFECT THIS HOOK HAS HAD. The rewrite's row count was once
  # incremented only for rows it REWROTE — matched, swept, appended — while the count it is
  # compared against covers every row the file held. Any index carrying a row for another live
  # worktree then looked like a loss, the guard blocked the write, and because the next session
  # read the same unchanged file and reached the same conclusion, the mechanism stopped for good
  # and said nothing. It survived a full green selftest because every fixture here had one row.
  repo=$(make_repo passthrough arc/04-dogfood-issue-55-pass)
  fire s15 "$repo" Bash "" >/dev/null
  live_a=$(make_repo neighbour_a arc/04-dogfood-issue-60-a)
  live_b=$(make_repo neighbour_b arc/04-dogfood-issue-61-b)
  for n in "$live_a:60" "$live_b:61"; do
    d="${n%:*}"; num="${n##*:}"
    printf '| `%s` | `%s` | `arc/04-dogfood-issue-%s-x` | #%s | `arc/04-dogfood` | 2026-09-01 to 2026-09-01 | live |\n' \
      "$(slug_of "$d")" "$d" "$num" "$num" >> "$(index "$repo")"
  done
  before=$(rows "$repo" | wc -l | tr -d ' ')
  # Fired from a NEW branch, so a correct rewrite must ADD a row. Asserting only that the count is
  # unchanged does not work: a guard that wrongly blocks the write leaves the file frozen at the
  # same three rows, which reads identically to a correct pass-through. The reverted defect passes
  # that weaker assertion — checked by reverting it — and fails this one.
  git -C "$repo" checkout -q -B arc/04-dogfood-issue-63-second 2>/dev/null
  fire s16 "$repo" Edit "$repo/src/a.c" >/dev/null
  after=$(rows "$repo" | wc -l | tr -d ' ')
  if [ "$before" = "3" ] && [ "$after" = "4" ]; then
    ok "rows for other live worktrees survive, and a new row still lands beside them"
  else
    bad "rows for other live worktrees survive, and a new row still lands beside them" \
        "$before rows before, $after after — wanted 3 then 4" \
        "at 3 and 3 the guard blocked the write and the index is frozen; at 4 rows minus the" \
        "neighbours, the rewrite dropped rows it did not touch"
  fi

  # ---- 16b · an index that cannot be read is left exactly as it is --------------------------
  # The guard's row count alone cannot catch this: the same failure feeds the pre-scan, so the
  # count it compares against comes back 0 and any rewrite looks like a gain. It is caught by
  # noticing that a non-empty file yielded no lines at all.
  #
  # SKIPPED, NOT FAKED, WHERE chmod DOES NOTHING. On this machine's /tmp — Windows — `chmod 000`
  # leaves the file readable, so the case cannot be driven and reporting it green would be a false
  # pass on the one property that protects the whole record.
  repo=$(make_repo unreadable arc/04-dogfood-issue-57-io)
  fire s19 "$repo" Bash "" >/dev/null
  printf '| `other-slug` | `/gone/elsewhere` | `arc/04-dogfood-issue-62-x` | #62 | `arc/04-dogfood` | 2026-09-01 to 2026-09-01 | live |\n' \
    >> "$(index "$repo")"
  before=$(rows "$repo" | wc -l | tr -d ' ')
  chmod 000 "$(index "$repo")" 2>/dev/null
  if head -n1 "$(index "$repo")" >/dev/null 2>&1; then
    chmod 644 "$(index "$repo")" 2>/dev/null
    echo "  SKIP  an unreadable index is left alone — chmod does not block reads on this filesystem"
  else
    fire s20 "$repo" Bash "" >/dev/null
    chmod 644 "$(index "$repo")" 2>/dev/null
    after=$(rows "$repo" | wc -l | tr -d ' ')
    if [ "$after" = "$before" ]; then
      ok "an unreadable index is left exactly as it was, not rewritten from nothing"
    else
      bad "an unreadable index is left exactly as it was, not rewritten from nothing" \
          "$before rows before, $after after — the hook destroyed the mapping it exists to keep"
    fi
  fi

  # ---- 17 · a header-stripped index gets a WELL-FORMED header back --------------------------
  # Rows under no column names and no alignment rule stop rendering as a table: the miner's row
  # match still works, so nothing fails loudly, and a human reading the file simply cannot.
  #
  # Asserting only that a `| Transcript |` line exists is not enough — the first repair prepended
  # the whole header block, which left the old title and note duplicated BELOW the new ones with
  # the rows stranded under prose, and that assertion passed. So: exactly one title, and the
  # alignment rule immediately above the first row.
  repo=$(make_repo noheader arc/04-dogfood-issue-56-hdr)
  fire s17 "$repo" Bash "" >/dev/null
  grep -Ev '^\| (Transcript|:---)' "$(index "$repo")" > "$(index "$repo").x" \
    && mv "$(index "$repo").x" "$(index "$repo")"
  fire s18 "$repo" Edit "$repo/src/a.c" >/dev/null
  titles=$(grep -c '^# Session index' "$(index "$repo")")
  aligned=$(grep -A1 '^| :---' "$(index "$repo")" | grep -c '^| `')
  if [ "$titles" = "1" ] && [ "$aligned" -ge 1 ]; then
    ok "an index that lost its header gets a well-formed one back, with the rows under it"
  else
    bad "an index that lost its header gets a well-formed one back, with the rows under it" \
        "$titles title line(s), and the alignment rule is followed by $aligned entry row(s)" \
        "a duplicated title with the rows stranded under prose still does not render"
  fi

  # ---- 18 · the lock's CLEANUP CONTRACT, which is not the same as mutual exclusion ---------
  # SAY WHAT THIS COVERS AND WHAT IT DOES NOT. Mutual exclusion is a property of two processes
  # interleaving, and nothing here can make that interleaving happen on demand — a case that fired
  # two hooks and hoped would be flaky, which is worse than an absent one. So these three assert
  # the cleanup contract only, and the fact that the lock cannot make things worse.
  #
  # Read them knowing that: a hook with the lock code deleted outright would still pass all three.
  # They exist to catch the release being dropped from one branch, and the stale-lock path
  # blocking forever — the two ways this code has actually been wrong. The exclusion itself is
  # named in *what it cannot do* at the top of this file rather than claimed here.
  if [ ! -d "$repo/.arc-work/session-index/sessions.lock" ]; then
    ok "no lock is left behind after a rewrite [cleanup contract, not exclusion]"
  else
    bad "no lock is left behind after a rewrite" \
        "a stale lock costs every later session the full backoff before it writes anyway"
  fi

  # A lock this session does not own is neither waited on forever nor deleted. Deleting it is the
  # tempting cleanup and it is wrong: it hands the next arrival a free lock while the holder is
  # still writing, which is the race the lock was added for.
  repo=$(make_repo stale arc/04-dogfood-issue-58-stale)
  fire s21 "$repo" Bash "" >/dev/null
  mkdir -p "$repo/.arc-work/session-index/sessions.lock"
  git -C "$repo" checkout -q -B arc/04-dogfood-issue-59-stale2 2>/dev/null
  fire s22 "$repo" Bash "" >/dev/null
  if [ "$(rows "$repo" | wc -l | tr -d ' ')" = "2" ]; then
    ok "a stale lock does not block the write — the hook waits, gives up, and records anyway"
  else
    bad "a stale lock does not block the write" \
        "one crashed session would otherwise stop every later one from being indexed"
  fi
  if [ -d "$repo/.arc-work/session-index/sessions.lock" ]; then
    ok "and a lock this session never acquired is left where it is, not deleted"
  else
    bad "and a lock this session never acquired is left where it is, not deleted" \
        "deleting another writer's lock frees it mid-write and reintroduces the race"
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
