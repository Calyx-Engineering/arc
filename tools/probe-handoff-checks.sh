#!/usr/bin/env bash
# probe-handoff-checks.sh — did the staleness checks travel with the firing?
#
#   PROBE_TRANSCRIPT_DIR=<dir> tools/skill-probe.sh --openings --runs 3
#   tools/probe-handoff-checks.sh <dir>
#   tools/probe-handoff-checks.sh selftest
#
# WHY. #157 measured that `skills/handoff` fires at an opening. #208 then moved the seven
# staleness checks INTO that skill. Those are two different claims, and a firing rate cannot
# join them: a rate says a skill was invoked, never what the session then had in front of it.
# #252 asks the joined question, and this answers it.
#
# THE TRANSCRIPT DOES NOT CARRY THE SKILL TEXT. Measured 2026-09-09 against a real probe: the
# `Skill` tool_result in the stream is 28 bytes, `Launching skill: arc:handoff`, and the
# session's own `.jsonl` under ~/.claude/projects/ carries no line matching any of the seven
# checks either. The CLI injects SKILL.md by a path neither file records. So a grep of the
# transcript for `git status --short` answers NO for a session that read all seven, and taking
# #252's third box literally produces a false negative.
#
# WHAT IS DECIDABLE INSTEAD, AND WHY IT IS STRONGER. The transcript records WHICH skill was
# launched, fully qualified — `arc:handoff`, not merely `handoff`. That name resolves to one
# installed directory, and that directory holds the exact bytes the session was given. So this
# identifies the file by install path and sha1 and checks THOSE bytes, rather than searching a
# transcript for a copy of them that was never written there. A grep could only ever find text;
# this names the file.
#
# THE QUALIFIED NAME IS LOAD-BEARING. Two marketplaces can serve the same skill — this machine
# carried `arc:handoff` from R:\arc and `arc-scratch:handoff` from another run's scratch
# marketplace at the same time. A bare `handoff` cannot say which copy's text was read, and the
# two need not agree. So the name is taken with its namespace intact, from the raw dump rather
# than from tools/skill-probe.py's summary line — that keeps this readable against a dump from
# any version of the probe, including one predating the `qualified` field the probe now also
# prints for the run log.
#
# THE CONTENT CHECK IS tools/verify-handoff-checks.sh's, not a second copy of the seven
# literals. One list, tuned in one place — the same argument #208 made against keeping the
# checks in two artifacts.
#
# REPORTS, NEVER BLOCKS beyond its exit code. Exit 1 is a finding. Exit 2 is "I could not
# tell", which is a different answer and must not read as a defect.

set -u

HERE="$(cd "$(dirname "$0")" && pwd)"
INSTALLED="${PROBE_INSTALLED_JSON:-$HOME/.claude/plugins/installed_plugins.json}"

usage() {
  cat >&2 <<'USAGE'
usage:
  tools/probe-handoff-checks.sh <transcript-dir>
  tools/probe-handoff-checks.sh selftest
USAGE
}

# ---- reading one dump ------------------------------------------------------------
# Prints one line per Skill call, fully qualified. Nothing at all when none fired, which is a
# legitimate outcome — a case where the skill did not fire has no skill text to check.
#
# Reads the RAW stream, not skill-probe.py's summary line, so this stays usable on a dump
# captured by any run of the probe.
qualified_fires() {
  python "$HERE/probe-handoff-checks.py" fires "$1"
}

# ---- resolving a qualified name to the bytes the session was given ---------------
# `arc:handoff` names the PLUGIN `arc`, not the marketplace. installed_plugins.json keys are
# `<plugin>@<marketplace>`, so the lookup matches on the part before the `@` and reports every
# hit — an ambiguous name is reported, never silently resolved to the first match.
plugin_path() {
  python "$HERE/probe-handoff-checks.py" path "$1" "$INSTALLED"
}

# ---- the report ------------------------------------------------------------------
report() {
  dir="$1"
  [ -d "$dir" ] || { echo "no such directory: $dir" >&2; exit 2; }

  dumps="$(find "$dir" -name '*.jsonl' | sort)"
  [ -n "$dumps" ] || { echo "no .jsonl dumps in $dir — run skill-probe.sh with PROBE_TRANSCRIPT_DIR set" >&2; exit 2; }

  echo "probe-handoff-checks — the checks in the bytes each firing was given"
  echo

  total=0; fired=0; checked=0; bad=0; undecided=0

  while IFS= read -r f; do
    [ -n "$f" ] || continue
    total=$((total + 1))
    names="$(qualified_fires "$f")"
    hnames="$(printf '%s\n' "$names" | awk -F: 'NF && $NF == "handoff"')"
    if [ -z "$hnames" ]; then
      printf '  %-44s no handoff firing\n' "$(basename "$f")"
      continue
    fi
    fired=$((fired + 1))
    for n in $hnames; do
      plug="${n%%:*}"
      res="$(plugin_path "$plug")"
      case "$res" in
        NONE|ERROR*)
          printf '  %-44s %-22s UNRESOLVED (%s)\n' "$(basename "$f")" "$n" "$res"
          undecided=$((undecided + 1))
          continue ;;
      esac
      count="$(printf '%s\n' "$res" | grep -c '^PATH ')"
      if [ "$count" != "1" ]; then
        printf '  %-44s %-22s AMBIGUOUS (%s install paths)\n' "$(basename "$f")" "$n" "$count"
        undecided=$((undecided + 1))
        continue
      fi
      root="$(printf '%s\n' "$res" | sed -n 's/^PATH //p')"
      skill="$root/skills/handoff/SKILL.md"
      if [ ! -f "$skill" ]; then
        printf '  %-44s %-22s UNRESOLVED (no SKILL.md under the install path)\n' "$(basename "$f")" "$n"
        undecided=$((undecided + 1))
        continue
      fi
      sha="$(sha1sum < "$skill" | cut -c1-12)"
      checked=$((checked + 1))
      if HANDOFFCHK_ROOT="$root" bash "$HERE/verify-handoff-checks.sh" >/dev/null 2>&1; then
        printf '  %-44s %-22s CHECKS PRESENT  sha1 %s\n' "$(basename "$f")" "$n" "$sha"
      else
        printf '  %-44s %-22s CHECKS MISSING  sha1 %s\n' "$(basename "$f")" "$n" "$sha"
        bad=$((bad + 1))
      fi
    done
  done <<EOF
$dumps
EOF

  echo
  echo "$total dump(s), $fired with a handoff firing, $checked resolved to installed bytes"
  [ "$undecided" -gt 0 ] && echo "$undecided firing(s) could not be resolved to a file"
  echo
  echo "The transcript does not hold the skill text; this reports the bytes the named plugin"
  echo "serves. Content verified by tools/verify-handoff-checks.sh — one list of the seven."

  if [ "$bad" -gt 0 ]; then
    echo
    echo "FAIL  $bad firing(s) read a handoff skill whose read path is missing checks"
    exit 1
  fi
  if [ "$checked" = "0" ]; then
    echo
    echo "UNDECIDED  no firing resolved to a file — nothing was checked"
    exit 2
  fi
  echo
  echo "PASS  every resolved firing read a skill carrying all seven checks"
  exit 0
}

# ---- selftest --------------------------------------------------------------------
# The two things that were wrong in drafting are both here: taking the name from the tool call
# rather than from prose, and refusing to guess when one plugin name has two install paths.
# Neither needs a network or a real probe.
selftest() {
  tmp="$(mktemp -d)"
  # `set -u` does not object to an empty string, and the fixture block below builds directories
  # under $tmp and deletes it at the end. An empty $tmp would put those at the filesystem root.
  [ -n "$tmp" ] && [ -d "$tmp" ] || { echo "could not make a temp directory" >&2; exit 2; }
  run=0; passed=0; failed=0
  ok()  { passed=$((passed + 1)); echo "  ok    $1"; }
  bad() { failed=$((failed + 1)); echo "  FAIL  $1"; }

  fires_is() {
    want="$1"; name="$2"; body="$3"
    run=$((run + 1))
    printf '%s\n' "$body" > "$tmp/case.jsonl"
    got="$(qualified_fires "$tmp/case.jsonl" | tr '\n' ' ' | sed 's/  *$//')"
    if [ "$got" = "$want" ]; then ok "$name — [$got]"; else
      bad "$name — wanted [$want], got [$got]"; fi
  }

  echo "probe-handoff-checks selftest"
  echo

  SKILLCALL='{"type":"assistant","message":{"content":[{"type":"tool_use","name":"Skill","input":{"skill":"arc:handoff"}}]}}'
  SCRATCH='{"type":"assistant","message":{"content":[{"type":"tool_use","name":"Skill","input":{"skill":"arc-scratch:handoff"}}]}}'
  ANNOUNCE='{"type":"assistant","message":{"content":[{"type":"text","text":"Using arc:handoff to read the handoff."}]}}'
  OTHERTOOL='{"type":"assistant","message":{"content":[{"type":"tool_use","name":"Bash","input":{"command":"ls"}}]}}'
  RESULT='{"type":"result","total_cost_usd":0.1}'
  TRUNC='{"type":"assist'

  # The name is taken from the tool call, never from prose. An announcement naming the skill is
  # exactly what the probe first mistook for an answer, and it is not a firing either.
  fires_is ""                    "an announcement alone is not a firing" "$ANNOUNCE
$RESULT"
  fires_is "arc:handoff"         "announcement then firing"              "$ANNOUNCE
$SKILLCALL
$RESULT"
  fires_is "arc:handoff"         "a bare firing"                         "$SKILLCALL"

  # The marketplace half of the name is what says which copy was read, so it must survive.
  fires_is "arc-scratch:handoff" "the scratch copy is not the arc copy"  "$SCRATCH"
  fires_is "arc:handoff arc-scratch:handoff" "both, in order"            "$SKILLCALL
$SCRATCH"

  # A Skill call is not any tool call.
  fires_is ""                    "another tool is not a firing"          "$OTHERTOOL
$RESULT"

  # A truncated dump is the normal result of a killed probe and must not crash the reader.
  fires_is "arc:handoff"         "a truncated line is skipped"           "$SKILLCALL
$TRUNC"

  # Resolution refuses rather than guesses.
  run=$((run + 1))
  cat > "$tmp/installed.json" <<'JSON'
{"plugins":{"arc@calyx-engineering":[{"installPath":"/one"}],"arc@other":[{"installPath":"/two"}]}}
JSON
  out="$(PROBE_INSTALLED_JSON="$tmp/installed.json" INSTALLED="$tmp/installed.json" \
         python "$HERE/probe-handoff-checks.py" path arc "$tmp/installed.json")"
  if [ "$(printf '%s\n' "$out" | grep -c '^PATH ')" = "2" ]; then
    ok "two install paths for one plugin are both reported, not resolved to the first"
  else
    bad "ambiguous plugin — expected 2 PATH lines, got: $out"
  fi

  run=$((run + 1))
  out="$(python "$HERE/probe-handoff-checks.py" path nosuchplugin "$tmp/installed.json")"
  if [ "$out" = "NONE" ]; then ok "an unknown plugin is NONE, not empty"; else
    bad "unknown plugin — wanted NONE, got: $out"; fi

  run=$((run + 1))
  out="$(python "$HERE/probe-handoff-checks.py" path arc "$tmp/does-not-exist.json")"
  case "$out" in
    ERROR*) ok "an unreadable install index is ERROR, not NONE" ;;
    *)      bad "unreadable index — wanted ERROR..., got: $out" ;;
  esac

  # ---- report(), which is the path that could make this a rubber stamp ------------
  # The verdict cases above are pure functions. `report` is the one that decides PASS, and a
  # selftest that never reaches it would pass on a tool that could only ever say PASS. So the
  # fixtures below stand in for an installed plugin: one carrying the checks, one not.
  # `local` here and not in the older helpers above: these names — `name`, `want`, `out`, `dir`
  # — are shared with `fires_is`, and today nothing breaks only because every `fires_is` case
  # runs before the first `report_is`. A case added below in the older style would read
  # clobbered values, which is a test that lies rather than one that fails.
  report_is() {
    local want="$1" want_text="$2" name="$3" dir="$4" index="$5" out status
    run=$((run + 1))
    out="$(PROBE_INSTALLED_JSON="$index" bash "$HERE/probe-handoff-checks.sh" "$dir" 2>&1)"; status=$?
    if [ "$status" != "$want" ]; then
      bad "$name — wanted exit $want, got $status"; return
    fi
    if ! printf '%s' "$out" | grep -qF -- "$want_text"; then
      bad "$name — exit $status is right but the report never says \"$want_text\""; return
    fi
    ok "$name"
  }

  # A fixture plugin whose skill and command are the real ones: the checks are present.
  REAL="$(cd "$HERE/.." && pwd)"
  mkdir -p "$tmp/good/skills/handoff" "$tmp/good/commands"
  cp "$REAL/skills/handoff/SKILL.md" "$tmp/good/skills/handoff/SKILL.md" 2>/dev/null
  cp "$REAL/commands/arc-next.md"    "$tmp/good/commands/arc-next.md"    2>/dev/null

  # The same, with one check cut out of the read path. This is the drift #208 exists to catch,
  # and it is the case that makes a PASS above mean anything.
  mkdir -p "$tmp/bad/skills/handoff" "$tmp/bad/commands"
  grep -v -- '-newer HANDOFF.md' "$REAL/skills/handoff/SKILL.md" > "$tmp/bad/skills/handoff/SKILL.md" 2>/dev/null
  cp "$REAL/commands/arc-next.md" "$tmp/bad/commands/arc-next.md" 2>/dev/null

  # THE DENY CASE IS THE ONE THAT CAN PASS FOR THE WRONG REASON. If the sources ever move, both
  # copies fail silently — there is no `set -e` here — and the bad fixture becomes an EMPTY
  # file, which reports CHECKS MISSING and exits 1 exactly as a real regression would. The good
  # case would fail loudly, so the breakage gets noticed, but the deny case's green would be
  # meaningless. So the fixtures are asserted before they are used: both non-empty, and
  # different from each other.
  run=$((run + 1))
  if [ -s "$tmp/good/skills/handoff/SKILL.md" ] && [ -s "$tmp/bad/skills/handoff/SKILL.md" ] &&
     ! cmp -s "$tmp/good/skills/handoff/SKILL.md" "$tmp/bad/skills/handoff/SKILL.md"; then
    ok "the fixtures built: both non-empty, and the deny copy differs from the pass copy"
  else
    bad "the fixtures did not build from $REAL — every report case below is now meaningless"
  fi

  FIRED='{"type":"assistant","message":{"content":[{"type":"tool_use","name":"Skill","input":{"skill":"arc:handoff"}}]}}'

  mkdir -p "$tmp/dumps-good" "$tmp/dumps-bad" "$tmp/dumps-none" "$tmp/dumps-empty"
  printf '%s\n' "$FIRED" > "$tmp/dumps-good/a-run1.jsonl"
  printf '%s\n' "$FIRED" > "$tmp/dumps-bad/a-run1.jsonl"
  printf '%s\n' '{"type":"result"}' > "$tmp/dumps-none/a-run1.jsonl"

  printf '{"plugins":{"arc@m":[{"installPath":"%s"}]}}\n' "$tmp/good" > "$tmp/idx-good.json"
  printf '{"plugins":{"arc@m":[{"installPath":"%s"}]}}\n' "$tmp/bad"  > "$tmp/idx-bad.json"
  printf '{"plugins":{}}\n' > "$tmp/idx-empty.json"

  report_is 0 "CHECKS PRESENT" "a firing on a skill carrying the checks passes"  "$tmp/dumps-good"  "$tmp/idx-good.json"
  report_is 1 "CHECKS MISSING" "a firing on a skill missing one check fails"     "$tmp/dumps-bad"   "$tmp/idx-bad.json"
  report_is 2 "UNDECIDED"      "dumps with no firing decide nothing"             "$tmp/dumps-none"  "$tmp/idx-good.json"
  report_is 2 "no .jsonl"      "an empty directory is undecided, not a pass"     "$tmp/dumps-empty" "$tmp/idx-good.json"
  report_is 2 "UNRESOLVED"     "a firing naming an uninstalled plugin is undecided" "$tmp/dumps-good" "$tmp/idx-empty.json"

  rm -rf "$tmp"
  echo
  if [ "$failed" = "0" ]; then
    echo "$run cases, $passed passed, 0 failed"
    return 0
  fi
  echo "$run cases, $passed passed, $failed failed"
  return 1
}

case "${1:-}" in
  selftest)  [ "$#" -eq 1 ] || { echo "selftest takes no arguments" >&2; usage; exit 2; }
             selftest ;;
  -h|--help) usage; exit 0 ;;
  '')        usage; exit 2 ;;
  *)         [ "$#" -eq 1 ] || { echo "too many arguments" >&2; usage; exit 2; }
             report "$1" ;;
esac
