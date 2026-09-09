#!/usr/bin/env bash
# verify-hook-source.sh — a hook's source parses, and no code line carries an unbalanced backtick.
#
#   tools/verify-hook-source.sh              every file in hooks/ and hooks/lib/
#   tools/verify-hook-source.sh hooks/x      one file
#   tools/verify-hook-source.sh selftest     this checker's own cases
#
# WHY. #305: a header comment in hooks/tracker-verify was written with real control characters
# where the escapes for newline, tab and return were meant. The line after the break began with
# a bare backtick outside any comment, bash read it as code, and every backtick span in the
# comments that followed became a command — a real commit and a live `gh issue close` on every
# Bash tool call the fixtures sent. `bash -n` passed, because the file was valid shell. So this
# asks the question bash -n does not: does any line that is not a comment carry an odd number of
# backticks. Reports and fails; never edits.
#
# WHAT COUNTS. A backtick outside single quotes, not preceded by a backslash. Single-quote state
# is carried across lines, so an awk or sed program spanning lines is read as the string it is.
# Backticks inside double quotes count — bash expands them there, which is the whole defect.
#
# mode-guard-read-only: selftest
set +e
cd "$(dirname "$0")/.." || exit 1

# Prints the 1-based numbers of lines with an odd backtick count, space-separated.
odd_lines() {
  awk '
    BEGIN { insq = 0 }
    {
      n = split($0, ch, ""); odd = 0; code = 0
      for (i = 1; i <= n; i++) {
        c = ch[i]
        if (insq) { if (c == "\047") insq = 0; continue }
        if (c == "\\") { i++; code = 1; continue }
        if (c == "\047") { insq = 1; code = 1; continue }
        if (c == "#" && !code) break
        if (c == "`") odd = !odd
        if (c != " " && c != "\t") code = 1
      }
      if (odd) printf "%d ", NR
    }' "$1"
}

check_file() {
  local f="$1" bad
  if ! bash -n "$f" 2>/dev/null; then
    echo "  FAIL  $f does not parse (bash -n)"; return 1
  fi
  bad="$(odd_lines "$f")"
  if [ -n "$bad" ]; then
    echo "  FAIL  $f — odd backtick count outside a comment on line(s): $bad"
    echo "        a bare backtick in code opens a command substitution that swallows the comments after it (#305)"
    return 1
  fi
  echo "  PASS  $f"; return 0
}

if [ "${1:-}" = "selftest" ]; then
  t="$(mktemp -d)"; pass=0; fail=0
  {
    echo '#!/usr/bin/env bash'
    echo '# a comment with `one` and `two` spans'
    echo 'x="$(date +%s)"'
    echo 'exit 0'
  } > "$t/good"
  {
    echo '#!/usr/bin/env bash'
    echo "y=\"\$(awk '"
    echo '/^(```|~~~)/ { f = !f; next }'
    echo "' \"\$1\")\""
    printf 'msg="not a \\`gh pr merge\\`"\n'
    echo "case \"\$n\" in *['|&;()<>\$\`']*) : ;; esac"
    echo 'exit 0'
  } > "$t/good-quoted"
  {
    echo '#!/usr/bin/env bash'
    echo '# comment with `'
    echo '` `x`'
    echo '` stray — see the'
    echo '# `gh issue close 163` here'
    echo 'exit 0'
  } > "$t/bad-stray"
  {
    echo '#!/usr/bin/env bash'
    echo 'echo "unterminated'
  } > "$t/bad-parse"
  check_file "$t/good"        >/dev/null && pass=$((pass+1)) || { fail=$((fail+1)); echo "  selftest: good file reported"; }
  check_file "$t/good-quoted" >/dev/null && pass=$((pass+1)) || { fail=$((fail+1)); echo "  selftest: quoted program reported"; }
  check_file "$t/bad-stray"   >/dev/null && { fail=$((fail+1)); echo "  selftest: stray backtick missed"; } || pass=$((pass+1))
  check_file "$t/bad-parse"   >/dev/null && { fail=$((fail+1)); echo "  selftest: parse failure missed"; } || pass=$((pass+1))
  rm -rf "$t"
  echo "$pass passed, $fail failed"
  [ "$fail" -eq 0 ]; exit
fi

rc=0
if [ -n "${1:-}" ]; then files="$1"; else files="$(ls hooks/* hooks/lib/* 2>/dev/null | grep -vE '/(hooks\.json|TEMPLATE)$')"; fi
for f in $files; do [ -f "$f" ] || continue; check_file "$f" || rc=1; done
exit $rc
