#!/usr/bin/env bash
# verify-activation-log.sh — every hook writes one activation-log entry per firing.
#
#   tests/verify-activation-log.sh                   every hook that has a case directory
#   tests/verify-activation-log.sh hooks/mode-guard  one hook
#   tests/verify-activation-log.sh selftest          this checker's own cases
#
# WHY A SECOND SCRIPT AND NOT A BLOCK IN verify-hook.sh. `tools/verify-hook.sh` is on
# CLAUDE.md's never-edited-autonomously list. It asks one question — did the hook reach the
# right verdict — and this asks a different one: did it leave a record. Splitting them keeps
# the excluded gate untouched and keeps each script answering one question.
#
# WHAT IT ASSERTS, per case in `tools/hook-cases/<hook>/`:
#
#   one entry     exactly one entry appended per firing, on every path — allow, deny, report
#                 and malformed alike. Zero is the absence m44 exists to fix; two means an
#                 exit path logged twice
#   the shape     templates/event-log.md's — a header line, a `checked:` line and an
#                 `outcome:` line, with the artifact named by its file
#   compact       a firing that reached no declared check and reports nothing carries no
#                 `skipped:` line at all — neither the declaration copied back nor the skip
#                 reasons, which on such a firing restate the `outcome:` line. 50% of arc
#                 03's 4,643,015-byte log — #238. The entry is still asserted, one per
#                 firing on every path; only its length changed
#   invisible     no entry text reaches stdout. A PreToolUse hook's stdout is parsed as a
#                 permission decision, so an entry echoed there is a broken hook however
#                 good the log looks
#   fails open    an unwritable log path changes neither the verdict nor the exit code
#   kill switch   a mute suppresses the entry along with everything else
#
# And once, over the shared library every hook sources:
#
#   plugin-level  one log for every artifact, at `.claude/arc/log.md` — not a file per hook
#                 and not a directory under a consumer, which would imply an ownership no
#                 consumer has
#   a session      a firing with neither `ARC_EVENT_LOG` nor `CLAUDE_PROJECT_DIR` set writes
#                 nothing at all. Neither is set by a verifier, and a verifier's fixtures in
#                 the real log are indistinguishable from real firings — one `verify-hook.sh`
#                 run put ten fabricated entries in the tracked, append-only file before this
#                 assertion existed
#   no forks      the write path spawns no subprocess per field. Five hook registrations are
#                 on the Bash matcher, so anything here is paid five times per tool call —
#                 the first version cost +1.4s and m44 lists `cheap to append` as a requirement
#   verbosity     nothing on the write path reads a verbosity setting or the operating
#                 agreement. That independence is the whole of m44: turning the volume down
#                 must cost display and never data, and it is a property of the code rather
#                 than of anyone's intention, so it is asserted rather than asserted-to
#
# REPORTS BY EXIT CODE, like every other verifier here. It denies nothing.

set -u

cd "$(dirname "$0")/.." || exit 1

PASSED=0
FAILED=0

# ---- fixtures -------------------------------------------------------------------
# The same throwaway repos and placeholders `tools/verify-hook.sh` builds. Duplicated
# deliberately: that script cannot be edited to export them, and a payload substituted
# differently by the two runners would be a worse problem than the duplication.
FIXTURES="$(mktemp -d)"
trap 'rm -rf "$FIXTURES"' EXIT

make_repo() {
  local dir="$FIXTURES/$1" branch="$2"
  mkdir -p "$dir"
  git -C "$dir" init -q 2>/dev/null
  git -C "$dir" -c user.email=v@x -c user.name=v commit -q --allow-empty -m init 2>/dev/null
  git -C "$dir" checkout -q -B "$branch" 2>/dev/null
}

make_repo main   main
make_repo arc    arc/02-foundation
make_repo issue  arc/02-foundation-issue-10-skeleton
mkdir -p "$FIXTURES/norepo"

make_repo manual     main
make_repo autonomous main
make_repo badmode    main
mode_file() { printf '## Execution mode\n\n| | |\n|---|---|\n| **Mode** | **%s** |\n' "$2" > "$FIXTURES/$1/HANDOFF.md"; }
mode_file manual     Manual
mode_file autonomous Autonomous
mode_file badmode    Paused

p() { printf '%s' "$FIXTURES/$1" | tr '\\' '/'; }

substitute() {
  sed -e "s#__FIXTURE_MAIN__#$(p main)#g" \
      -e "s#__FIXTURE_ARC__#$(p arc)#g" \
      -e "s#__FIXTURE_ISSUE__#$(p issue)#g" \
      -e "s#__FIXTURE_NOREPO__#$(p norepo)#g" \
      -e "s#__FIXTURE_MANUAL__#$(p manual)#g" \
      -e "s#__FIXTURE_AUTONOMOUS__#$(p autonomous)#g" \
      -e "s#__FIXTURE_BADMODE__#$(p badmode)#g" \
      -e "s#__FIXTURE_PR__#$(p pr)#g"
}

# The kill switch is repo-scoped and expiring (#202), so the case points CLAUDE_PROJECT_DIR at a
# throwaway repository carrying an unexpired `all` entry. Nothing global is written — the same
# reasoning verify-hook.sh records for its own kill-switch test.
make_repo ks main
printf '%s all\n' "$(( $(date +%s) + 600 ))" > "$FIXTURES/ks/.git/arc-hooks-off"

# A path whose parent is a regular file. `mkdir -p` and `>>` both fail on it, on every
# platform, without needing chmod to mean anything.
printf 'not a directory\n' > "$FIXTURES/blocked"
UNWRITABLE="$FIXTURES/blocked/log.md"

# Every assertion below runs the same payload more than once, so anything a hook leaves in
# the fixtures has to go between runs. Three hooks leave something: `camp-session-start` a
# once-per-session marker, `branch-guard` a base-freshness stamp, `handoff-archive` a marker
# per session and per file archived. A second run that finds one takes a different path from
# the first, which reads as an inconsistency the hook does not have — `handoff-archive`
# reported on the first run and was silent on the second, and the difference was read as the
# log having changed the verdict.
reset_state() {
  rm -f "$FIXTURES"/*/.git/arc-camp-session-* 2>/dev/null
  rm -f "$FIXTURES"/*/.git/arc-archive-* 2>/dev/null
  rm -rf "$FIXTURES"/*/.git/arc-branch-guard 2>/dev/null
  rm -rf "$FIXTURES"/*/.arc-work 2>/dev/null
  return 0
}

# The two runs of a case are a second or so apart, and a hook may legitimately put the clock
# in its own output — `handoff-archive` names the archive directory, which is stamped to the
# second. Comparing those raw reads a real difference as an inconsistency, so both sides are
# reduced first. Only a timestamp is normalised; everything else still has to match exactly.
undate() {
  printf '%s' "$1" | sed -E \
    -e 's/20[0-9]{6}-[0-9]{6}/<stamp>/g' \
    -e 's/20[0-9]{2}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}(:[0-9]{2})?Z?/<ts>/g'
}

ok()  { printf '  PASS  %s\n' "$1"; PASSED=$((PASSED + 1)); }
bad() { printf '  FAIL  %s\n' "$1"; shift; for m in "$@"; do [ -n "$m" ] && printf '        %s\n' "$m"; done; FAILED=$((FAILED + 1)); }

# An entry's header line: timestamp, two spaces, artifact, two spaces, event.
HEADER_RE='^[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}Z  [a-z0-9-]+  [a-z0-9-]+'

entries() { grep -cE "$HEADER_RE" "$1" 2>/dev/null; }

# ---- the shared library ---------------------------------------------------------
LIB=hooks/lib/activation-log

library_checks() {
  echo "$LIB"

  if [ ! -f "$LIB" ]; then
    bad "$LIB is missing — every hook sources it"
    echo
    return
  fi

  # Code only, from here down. The header above it says what the kill switch is and what
  # verbosity independence means, and a checker that reads the explanation as the thing
  # being explained fails every well-documented file.
  code() { grep -vE '^[[:space:]]*(#|$)' "$LIB"; }

  # The kill switch, first, as CLAUDE.md requires of anything a hook runs.
  if code | head -n1 | grep -q 'hooks-off'; then
    ok "kill switch is the first line of code"
  else
    bad "$LIB does not open with the hooks-off kill switch" "first line of code: $(code | head -n1)"
  fi

  # Plugin-level: one path, and it is the one m44 names.
  if code | grep -qF 'CLAUDE_PROJECT_DIR/.claude/arc/log.md'; then
    ok "plugin-level — the default path is .claude/arc/log.md"
  else
    bad "$LIB does not default to .claude/arc/log.md — m44 names one log for every artifact"
  fi

  # Verbosity cannot reach the write path. Nothing here may read the agreement or a level.
  if code | grep -qiE 'operating-agreement|verbosity|\bloud\b|\bquiet\b'; then
    bad "$LIB reads a verbosity setting — the log must be written regardless of one (m44)"
  else
    ok "verbosity-independent — nothing on the write path reads a level"
  fi

  # A firing outside a session leaves no trace. This is asserted against a real hook rather
  # than by reading the library, because the defect it catches was a `$PWD` fallback that
  # looked correct in the code and silently wrote fixtures into the tracked log.
  local probe before after
  probe="$(ls hooks/* 2>/dev/null | grep -v 'TEMPLATE\|\.json\|lib' | head -n1)"
  if [ -n "$probe" ]; then
    # THE BYTES, NOT `git status`. A modified file reads as modified before and after, so a
    # `git status` comparison passes the regression whenever the log is already dirty — which
    # is exactly the state the original defect produced, 2228 uncommitted lines of it.
    before="$(wc -c < .claude/arc/log.md 2>/dev/null)"
    printf '{"tool_name":"Bash","tool_input":{"command":"git commit -m x"}}' \
      | env -u ARC_EVENT_LOG -u CLAUDE_PROJECT_DIR bash "$probe" >/dev/null 2>&1
    after="$(wc -c < .claude/arc/log.md 2>/dev/null)"
    if [ "$before" = "$after" ]; then
      ok "a firing with no session and no override writes nothing"
    else
      bad "$(basename "$probe") wrote to the real .claude/arc/log.md with no session set" \
          "$before bytes before, $after after" \
          "a verifier's fixtures are indistinguishable from real firings once they are in the file"
    fi
  fi

  # No subprocess per field on the write path. `$(` and backticks anywhere below the public
  # entry points are what cost +1.4s per Bash tool call in the first version — and scoping this
  # to the three helpers left `_arc_log_write` itself, the function that does the per-firing
  # work, as the one place a fork could come back unseen.
  #
  # The single allowance is the `date` fallback, which runs only where the shell has no time
  # builtin. It is matched by name so that adding a second fork does not inherit the exemption.
  if code | grep -vF 'date -u +%Y-%m-%dT%H:%MZ' | grep -qE '\$\(|`|\| *(sed|tr|awk|grep|cut)'; then
    bad "$LIB forks a subprocess per field — m44 requires the append to be cheap" \
        "five hook registrations are on the Bash matcher, so every fork here is paid five times per tool call"
  else
    ok "no subprocess per field on the write path"
  fi

  # Every registered hook sources it. A hook that logs its own way is a second format.
  #
  # A HOOK HAS NO EXTENSION — `hooks/*.sh` is a command about hooks (the kill switch, #202)
  # and `hooks/lib/` holds what hooks source. Neither fires, so neither has a firing to log.
  local h n
  for h in hooks/*; do
    [ -f "$h" ] || continue
    n="$(basename "$h")"
    case "$n" in TEMPLATE|*.json|*.sh) continue ;; esac
    if grep -q 'lib/activation-log' "$h"; then
      ok "$n sources the library"
    else
      bad "$n does not source $LIB — it will fire without leaving a record"
    fi
  done
  echo
}

# ---- one hook -------------------------------------------------------------------
check_hook() {
  local hook="$1" cases_dir="$2" name
  name="$(basename "$hook")"

  echo "$name"

  local any=0 f kind log desc payload first
  local out_logged rc_logged out_other rc_other n shape_bad
  for kind in pass deny report malformed; do
    [ -d "$cases_dir/$kind" ] || continue
    # `one entry` and the shape are per-case: each is a different path through the hook.
    # The library-level properties — fails open, kill switch — are asserted once per kind.
    # Every case runs the hook, and on Windows a spawn is the whole cost of this gate.
    first=1
    for f in "$cases_dir/$kind"/*.json; do
      [ -e "$f" ] || continue
      any=1
      desc="$(head -n1 "$f" | sed 's/^# *//')"
      payload="$(tail -n +2 "$f" | substitute)"

      log="$FIXTURES/case-log.md"
      : > "$log"
      reset_state
      out_logged="$(printf '%s' "$payload" | ARC_EVENT_LOG="$log" bash "$hook" 2>/dev/null)"
      rc_logged=$?

      n="$(entries "$log")"
      if [ "$n" = "1" ]; then
        ok "$kind  one entry          $desc"
      else
        bad "$kind  $n entries         $desc" "expected exactly 1 entry" "$(head -c 300 "$log")"
      fi

      if [ "$n" = "1" ]; then
        shape_bad=""
        grep -qE '^  checked: ' "$log" || shape_bad="$shape_bad checked-line"
        grep -qE '^  outcome: (ok|denied|repaired|failed)' "$log" || shape_bad="$shape_bad outcome-line"
        grep -qE "^[0-9-]+T[0-9:]+Z  $name  " "$log" || shape_bad="$shape_bad artifact-name"
        if [ -z "$shape_bad" ]; then
          ok "$kind  entry shape        $desc"
        else
          bad "$kind  entry shape        $desc" "missing:$shape_bad" "$(head -c 300 "$log")"
        fi

        # #238's compression, asserted so it cannot come back unnoticed. The entry is not at
        # stake — `one entry` above is what holds that line — only whether an entry that
        # reached nothing and reports nothing drags the whole declaration with it.
        #
        # `ok` and no check reached is the condition, and it is the narrow one on purpose: a
        # `denied` or `failed` entry keeps its list, so this assertion must not fire on one.
        if grep -qE '^  checked: — none reached' "$log" && grep -qE '^  outcome: ok' "$log"; then
          if grep -qE '^  skipped: ' "$log"; then
            bad "$kind  a no-op entry carried the unreached list   $desc" \
                "$(grep -E '^  skipped: ' "$log" | head -c 240)" \
                "nothing ran and nothing was reported — the line restates the outcome and the declaration"
          else
            ok "$kind  no-op entry compact  $desc"
          fi
        fi
      fi

      # The entry must not reach stdout. A PreToolUse hook's stdout is parsed as a decision,
      # so an entry echoed there is a broken hook however good the log looks.
      if printf '%s' "$out_logged" | grep -qE "$HEADER_RE|^ *(checked|outcome|skipped): "; then
        bad "$kind  an entry reached stdout   $desc" "$(printf '%s' "$out_logged" | head -c 200)"
      else
        ok "$kind  entry not on stdout  $desc"
      fi

      [ "$first" = "1" ] || continue
      first=0

      # Fails open: an unwritable log path must change neither stdout nor the exit code.
      # This is also the assertion that logging did not change what the caller sees.
      reset_state
      out_other="$(printf '%s' "$payload" | ARC_EVENT_LOG="$UNWRITABLE" bash "$hook" 2>/dev/null)"
      rc_other=$?
      if [ "$(undate "$out_logged")" = "$(undate "$out_other")" ] && [ "$rc_logged" = "$rc_other" ]; then
        ok "$kind  fails open           $desc"
      else
        bad "$kind  an unwritable log changed the verdict   $desc" \
            "writable:   rc=$rc_logged $(printf '%s' "$out_logged" | head -c 120)" \
            "unwritable: rc=$rc_other $(printf '%s' "$out_other" | head -c 120)"
      fi

      # The kill switch suppresses the entry, not only the decision.
      : > "$log"
      reset_state
      printf '%s' "$payload" | ARC_EVENT_LOG="$log" CLAUDE_PROJECT_DIR="$FIXTURES/ks" bash "$hook" >/dev/null 2>&1
      if [ "$(entries "$log")" = "0" ]; then
        ok "$kind  kill switch quiet    $desc"
      else
        bad "$kind  kill switch wrote an entry   $desc" "$(head -c 300 "$log")"
      fi
    done
  done

  [ "$any" = "1" ] || bad "$name has a case directory with no cases in it"
  echo
}

# ---- selftest -------------------------------------------------------------------
# Fake hooks with known defects, to prove the checker fails on each. A checker that cannot
# fail is a checker nobody should read a pass from.
SELF=""

write_hook() {
  printf '#!/usr/bin/env bash\n. "${0%%/*}/lib/hooks-off" 2>/dev/null && arc_hooks_off && exit 0\nset +e\ncat >/dev/null 2>&1\nL="${ARC_EVENT_LOG:-/dev/null}"\n%s\nexit 0\n' "$2" > "$SELF/hooks/$1"
}

# A well-formed entry, written the way a hook writes one: append, never read.
self_entry() {
  printf 'printf "%%s  %s  fired  \\n  checked: none — nothing declared\\n  outcome: ok — allowed\\n" "$(date -u +%%Y-%%m-%%dT%%H:%%MZ)" >> "$L" 2>/dev/null' "$1"
}

run_self() {
  local label="$1" hookname="$2" expect="$3" before_f=$FAILED before_p=$PASSED got=fail
  check_hook "$SELF/hooks/$hookname" "$SELF/cases" >/dev/null 2>&1
  [ "$FAILED" = "$before_f" ] && got=pass
  PASSED=$before_p; FAILED=$before_f
  if [ "$got" = "$expect" ]; then
    ok "selftest — $label reads as $expect"
  else
    bad "selftest — $label read as $got, expected $expect"
  fi
}

selftest() {
  SELF="$FIXTURES/self"
  mkdir -p "$SELF/cases/pass" "$SELF/hooks/lib"
  # The fake hooks open with the real kill-switch line, so they need the real library beside
  # them — `. "${0%/*}/lib/hooks-off"`. Without it the source fails, every fake hook logs
  # through an unexpired mute, and the three cases that should read as a pass read as a fail.
  cp "$(dirname "$LIB")/hooks-off" "$SELF/hooks/lib/hooks-off"
  printf '# a trivial payload\n{"tool_name":"Bash"}\n' > "$SELF/cases/pass/one.json"

  write_hook good "$(self_entry good)"
  run_self "a hook that logs one entry" good pass

  write_hook silent ':'
  run_self "a hook that logs nothing" silent fail

  write_hook twice "$(self_entry twice)
$(self_entry twice)"
  run_self "a hook that logs twice" twice fail

  write_hook noisy "$(self_entry noisy)
printf '%s  noisy  fired  \\n' \"\$(date -u +%Y-%m-%dT%H:%MZ)\""
  run_self "a hook that echoes its entry to stdout" noisy fail

  write_hook shapeless 'printf "%s  shapeless  fired  \n" "$(date -u +%Y-%m-%dT%H:%MZ)" >> "$L" 2>/dev/null'
  run_self "a hook whose entry has no checked or outcome line" shapeless fail

  # The kill-switch line deleted: it logs when everything should be inert.
  write_hook nokill "$(self_entry nokill)"
  sed -i.bak '2d' "$SELF/hooks/nokill" && rm -f "$SELF/hooks/nokill.bak"
  run_self "a hook that logs through the kill switch" nokill fail

  # #238, both directions. A no-op entry that drags every declared check behind it reads as a
  # failure; the same entry without the list reads as a pass. Both are needed — an assertion
  # that only ever fires one way is one nobody can tell from a constant.
  write_hook noopfat 'printf "%s  noopfat  fired  \n  checked: — none reached\n  outcome: ok — nothing to report\n  skipped: alpha (not reached) · beta (not reached)\n" "$(date -u +%Y-%m-%dT%H:%MZ)" >> "$L" 2>/dev/null'
  run_self "a no-op entry carrying the unreached list" noopfat fail

  write_hook noopthin 'printf "%s  noopthin  fired  \n  checked: — none reached\n  outcome: ok — nothing to report\n" "$(date -u +%Y-%m-%dT%H:%MZ)" >> "$L" 2>/dev/null'
  run_self "a no-op entry with no list" noopthin pass

  # And the narrowness: a DENIED entry keeps its list, so the assertion above must be silent
  # on one. Without this the cheapest way to pass is to ban the skipped line outright.
  write_hook deniedfat 'printf "%s  deniedfat  fired  \n  checked: — none reached\n  outcome: denied — the branch is main\n  skipped: alpha (not reached)\n" "$(date -u +%Y-%m-%dT%H:%MZ)" >> "$L" 2>/dev/null'
  run_self "a denied entry that keeps its list" deniedfat pass

  # No 2>/dev/null on the append, and a message when it fails: an unwritable log speaks up.
  write_hook fragile 'printf "%s  fragile  fired  \n  checked: none — nothing declared\n  outcome: ok — allowed\n" "$(date -u +%Y-%m-%dT%H:%MZ)" >> "$L" || printf "log write failed\n"'
  run_self "a hook that speaks up when the log is unwritable" fragile fail
}

# ---- run ------------------------------------------------------------------------
echo "verify-activation-log.sh — one entry per firing, on every path"
echo

TARGET="${1:-}"
if [ "$TARGET" = "selftest" ]; then
  selftest
elif [ -n "$TARGET" ]; then
  [ -f "$TARGET" ] || { echo "no such hook: $TARGET" >&2; exit 2; }
  D="tools/hook-cases/$(basename "$TARGET")"
  [ -d "$D" ] || { echo "no case directory: $D" >&2; exit 2; }
  # The library is checked here too. It is what the named hook is being checked THROUGH, and
  # a one-hook run is how someone iterates — finding out at the end of a full run that the
  # library regressed is finding out too late to be useful.
  library_checks
  check_hook "$TARGET" "$D"
else
  library_checks
  for h in hooks/*; do
    [ -f "$h" ] || continue
    n="$(basename "$h")"
    case "$n" in TEMPLATE|*.json|*.sh) continue ;; esac
    if [ -d "tools/hook-cases/$n" ]; then
      check_hook "$h" "tools/hook-cases/$n"
    else
      bad "$n has no case directory"
    fi
  done
fi

echo "$PASSED passed, $FAILED failed"
[ "$FAILED" -eq 0 ] || exit 1
