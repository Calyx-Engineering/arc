#!/usr/bin/env bash
# verify-camp-agreement-links.sh — every anchored link out of the local operating agreement
# resolves to a heading that exists in its target file today.
#
#   tests/verify-camp-agreement-links.sh
#
# WHY THIS EXISTS. verify-template-links.sh checks templates/ — whether a link resolves at the
# directory the template is copied INTO. .claude/arc/camp/operating-agreement.md is not a
# template; it already IS the landed file in this repo, and nothing checked whether its anchors
# still point at real headings. #42 renamed the five obligations and eight of this file's nine
# links into m43 went stale silently. #258 fixed the anchors; this is the gate so the next
# rename is caught instead of found by hand again.
#
# WHAT IT CHECKS. Every `](path#anchor)` link out of the agreement whose path resolves to
# another markdown file in this repo: the anchor must match the GitHub slug of one of that
# file's headings, computed the way GitHub computes one — lowercase, drop everything but
# letters, digits, spaces and hyphens, spaces become hyphens. Consecutive hyphens are NOT
# collapsed: an em dash sitting between two spaces removes to leave a double hyphen, and GitHub
# keeps it — see the relief-valve anchor this issue fixed.
#
# WHAT IT CANNOT DO. It reads headings as plain `#` lines, so it does not resolve GitHub's
# duplicate-heading suffixing (`-1`, `-2`) — this file's targets have no duplicate headings
# today. It does not fetch anything; a target path is resolved against this repository's tree.
#
# REPORTS, NEVER BLOCKS. Same as every verifier here. Exit 1 marks a finding to read.

set -u

SELF="$(cd "$(dirname "$0")" && pwd)/$(basename "$0")"

headings_of() {  # headings_of <file> — one GitHub slug per line, one python call for the whole file
  local f="$1"
  [ -f "$f" ] || return
  # One process for every heading in the file made this gate re-spawn python roughly 500 times
  # on m43-camp-assistant.md's ~59 headings across the agreement's nine links into it — #333
  # pass 4 measured it as the reason a live verify-all.sh run stalled. One process per FILE
  # instead, and the caller below caches the result per target so a file linked from several
  # anchors (m43 is, nine times) is still only read once per run.
  #
  # Windows python opens stdout in text mode and rewrites \n to \r\n — strip it back off so a
  # slug compares equal to an anchor typed with plain \n line endings.
  python -c '
import io, re, sys
with io.open(sys.argv[1], encoding="utf-8") as fh:
    for line in fh:
        if not line.startswith("#"):
            continue
        text = re.sub(r"^#+\s*", "", line).strip().lower()
        s = "".join(ch for ch in text if ch.isalnum() or ch in " -")
        print(s.replace(" ", "-"))
' "$f" | tr -d '\r'
}

check_file() {  # check_file <agreement-md> — prints findings, returns count of bad links
  local file="$1" dir bad=0
  dir="$(dirname "$file")"
  # Cache headings_of's output per target path — the agreement links into m43 nine times, and
  # without this every one of those nine re-read and re-sluggified the same file.
  local -A slug_cache=()
  links="$(
    sed -e '/^```/,/^```/d' "$file" \
    | sed -e 's/`[^`]*`//g' \
    | grep -oE '\]\([^)]+\)' \
    | sed -e 's/^](//' -e 's/)$//'
  )"
  # `while read` rather than `for t in $links` — a link is one line each, and this way a path
  # or anchor containing a space is read whole instead of split on it, and never glob-expanded.
  while IFS= read -r t; do
    [ -n "$t" ] || continue
    case "$t" in
      http://*|https://*|mailto:*) continue ;;
    esac
    case "$t" in
      *'#'*) : ;;
      *) continue ;;  # no anchor — nothing for this gate to check
    esac
    path="${t%%#*}"
    anchor="${t#*#}"
    [ -n "$anchor" ] || continue
    if [ -z "$path" ]; then
      target="$file"
    else
      target="$dir/$path"
      case "$target" in /*) prefix="/" ;; *) prefix="" ;; esac
      target="$prefix$(printf '%s' "$target" | awk -F/ '{n=0; for(i=1;i<=NF;i++){ if($i==""||$i==".") continue; if($i==".."){ if(n>0) n--; else out[++n]=".."; } else out[++n]=$i } s=""; for(i=1;i<=n;i++) s=s (i>1?"/":"") out[i]; print s}')"
    fi
    if [ ! -f "$target" ]; then
      echo "        $t"
      echo "          target file does not exist: $target"
      bad=$((bad + 1))
      continue
    fi
    if [ -z "${slug_cache[$target]+set}" ]; then
      slug_cache[$target]="$(headings_of "$target")"
    fi
    slugs="${slug_cache[$target]}"
    case "
$slugs
" in
      *"
$anchor
"*) ;;
      *)
        echo "        $t"
        echo "          #$anchor matches no heading in $target"
        bad=$((bad + 1))
        ;;
    esac
  done <<< "$links"
  return "$bad"
}

if [ "${1:-}" = "selftest" ]; then
  passed=0; failed=0
  WORK="$(mktemp -d)"; trap 'rm -rf "$WORK"' EXIT

  case_is() {
    local name="$1" want_status="$2" want_text="$3" got_status="$4" got="$5"
    if [ "$got_status" = "$want_status" ] && [[ "$got" == *"$want_text"* ]]; then
      echo "  PASS  $name"; passed=$((passed + 1))
    else
      echo "  FAIL  $name"
      echo "        wanted exit $want_status containing: $want_text"
      echo "        got exit $got_status:"
      printf '%s\n' "$got" | sed 's/^/        | /'
      failed=$((failed + 1))
    fi
  }

  run() { AGREEMENT_FILE="$1" bash "$SELF" 2>&1; }

  echo "verify-camp-agreement-links selftest — fixture files, never the live agreement"
  echo

  # 1 — an anchor that matches the target's current heading passes.
  root="$WORK/matches"; mkdir -p "$root"
  printf '### 3.6 The relief valve — a skill now, an agent later\n' > "$root/target.md"
  printf '[m43 §3.6](target.md#36-the-relief-valve--a-skill-now-an-agent-later)\n' > "$root/agreement.md"
  out=$(run "$root/agreement.md"); status=$?
  case_is "an anchor matching the current heading passes" 0 "0 failed" "$status" "$out"

  # 2 — #258's own case. The heading was renamed and the anchor was not, so it points at a
  #     slug that used to exist and no longer does.
  root="$WORK/stale"; mkdir -p "$root"
  printf '### 3.6 The relief valve — a skill now, an agent later\n' > "$root/target.md"
  printf '[m43 §3.6](target.md#36-the-relief-valve-a-skill-now-an-agent-later)\n' > "$root/agreement.md"
  out=$(run "$root/agreement.md"); status=$?
  case_is "a stale anchor from before a heading rename fails" 1 "matches no heading" "$status" "$out"

  # 3 — a link with no anchor at all is not this gate's concern; verify-template-links.sh (or
  #     a plain existence check) covers whether the file itself exists.
  root="$WORK/noanchor"; mkdir -p "$root"
  printf '### Something\n' > "$root/target.md"
  printf '[m43](target.md)\n' > "$root/agreement.md"
  out=$(run "$root/agreement.md"); status=$?
  case_is "a link with no anchor is skipped" 0 "0 failed" "$status" "$out"

  # 4 — the target file itself is missing.
  root="$WORK/missing"; mkdir -p "$root"
  printf '[m43](nope.md#anything)\n' > "$root/agreement.md"
  out=$(run "$root/agreement.md"); status=$?
  case_is "a link into a missing file fails" 1 "does not exist" "$status" "$out"

  # 5 — an em-dash heading produces a double hyphen, and the anchor must carry it too.
  root="$WORK/doublehyphen"; mkdir -p "$root"
  printf "### 3.1 The intent check — holding the arc's intent\n" > "$root/target.md"
  printf '[m43 §3.1](target.md#31-the-intent-check--holding-the-arcs-intent)\n' > "$root/agreement.md"
  out=$(run "$root/agreement.md"); status=$?
  case_is "an em-dash heading's double hyphen is required" 0 "0 failed" "$status" "$out"

  echo
  echo "$passed passed, $failed failed"
  [ "$failed" = "0" ] || exit 1
  exit 0
fi

cd "$(dirname "$0")/.." || exit 1
FILE="${AGREEMENT_FILE:-.claude/arc/camp/operating-agreement.md}"

if [ ! -f "$FILE" ]; then
  echo "  FAIL  $FILE does not exist"
  exit 1
fi

OUT="$(check_file "$FILE")"; BAD=$?

if [ "$BAD" = "0" ]; then
  echo "  PASS  $FILE"
  echo
  echo "0 failed — every anchored link resolves to a real heading"
  exit 0
fi
echo "  FAIL  $FILE"
printf '%s\n' "$OUT"
echo
echo "$BAD failed — an anchor points at a heading that does not exist"
exit 1
