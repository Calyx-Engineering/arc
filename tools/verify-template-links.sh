#!/usr/bin/env bash
# verify-template-links.sh — every template link resolves from where the template LANDS.
#
#   tools/verify-template-links.sh
#
# WHY THIS EXISTS. A template is the only artifact whose links must be correct somewhere it is
# not. `templates/camp/operating-agreement.md` is copied to `.claude/arc/camp/`, so a link that
# reads correctly beside the template is two directories wrong at the destination. Eighteen such
# links shipped, eleven of them in the document m43 requires a user to read and approve, and every
# review that read them read them in place — where they were fine. #119 found them; #122 is this.
#
# TWO KINDS OF LINK, AND ONLY ONE IS A DEPTH QUESTION.
#
#   the target is a PLUGIN document  →  absolute URL. A consuming repo has no docs/ at ANY depth,
#                                       so re-basing produces a plausible path that is still dead
#   the target is in the CONSUMING repo  →  relative, and it must resolve from the destination
#
# That distinction is why sync-local-skills.sh's re-basing is the wrong instrument here rather
# than an unapplied one: it fixes depth, and depth is not what is wrong with fourteen of them.
#
# A TEMPLATE WITH NO MAP ROW FAILS. Same shape as verify-all.sh failing on a hook with no case
# directory: a template nobody mapped is one nobody checks, and it looks like coverage.
#
# WHAT IT CANNOT DO. It resolves paths against THIS repository's tree, so it proves a relative
# link is well-formed for a repo laid out like this one. It does not fetch absolute URLs, and it
# cannot know whether a consuming repo has a docs/arc-log/ yet.
#
# REPORTS, NEVER BLOCKS. Exit 1 marks a finding to read.

set -u

cd "${TEMPLATE_ROOT:-$(dirname "$0")/..}" || exit 1

# template  →  the directory it is copied INTO, relative to the consuming repo root.
# Add a row when a template is added. A missing row is a failure, not a skip.
MAP="
templates/arc-log.md|docs/arc-log
templates/dev-log.md|docs/dev-log
templates/handoff.md|.
templates/event-log.md|.claude/arc
templates/SKILL.md|skills/SKILLNAME
templates/camp/operating-agreement.md|.claude/arc/camp
templates/camp/voice.md|.claude/arc/camp
templates/camp/notes.md|.claude/arc/camp
"

PASSED=0
FAILED=0
pass() { echo "  PASS  $1"; PASSED=$((PASSED + 1)); }
fail() { echo "  FAIL  $1"; shift; for l in "$@"; do echo "        $l"; done; FAILED=$((FAILED + 1)); }

# ---- every template on disk has a map row ------------------------------------------
# README.md is the one file here that is documentation ABOUT templates rather than a template.
# It is never copied anywhere, so it has no destination and no map row. One named exception with
# a reason, never a list — a list is what made a new skill invisible to the parity check.
missing=""
while IFS= read -r f; do
  [ -f "$f" ] || continue
  [ "$f" = "templates/README.md" ] && continue
  case "$MAP" in
    *"$f|"*) ;;
    *) missing="$missing $f" ;;
  esac
done <<EOF
$(find templates -type f -name '*.md' | sed 's|\\|/|g' | sort)
EOF
if [ -n "$missing" ]; then
  fail "every template is mapped" \
       "these have no destination row, so nothing checks them:$missing" \
       "add a row to MAP naming the directory each is copied into."
else
  pass "every template is mapped"
fi

# ---- resolve each link from the destination ----------------------------------------
printf '%s\n' "$MAP" | while IFS='|' read -r tpl dest; do
  [ -n "${tpl:-}" ] || continue
  [ -f "$tpl" ] || { echo "  FAIL  $tpl" ; echo "        mapped but not on disk"; continue; }
  # Strip fenced blocks and inline code first: a skill or template documenting link syntax is
  # full of link-shaped text that is not a link. #119's first checker chased one for real.
  bad=""
  links="$(
    sed -e '/^```/,/^```/d' "$tpl" \
    | sed -e 's/`[^`]*`//g' \
    | grep -oE '\]\([^)]+\)' \
    | sed -e 's/^](//' -e 's/)$//'
  )"
  for t in $links; do
    case "$t" in
      http://*|https://*|mailto:*|\#*) continue ;;
      *'<'*|*'&lt;'*) continue ;;     # a placeholder path inside the template's own example
    esac
    path="${t%%#*}"
    [ -n "$path" ] || continue
    case "$dest" in
      */SKILLNAME) resolved="$(dirname "$dest")/x/$path" ;;
      *) resolved="$dest/$path" ;;
    esac
    # normalise ./ and ../ without requiring realpath on a path that may not exist
    resolved="$(printf '%s' "$resolved" | awk -F/ '{n=0; for(i=1;i<=NF;i++){ if($i==""||$i==".") continue; if($i==".."){ if(n>0) n--; else out[++n]=".."; } else out[++n]=$i } s=""; for(i=1;i<=n;i++) s=s (i>1?"/":"") out[i]; print s}')"
    if [ ! -e "$resolved" ]; then
      bad="$bad
        $t
          lands on: $resolved"
    fi
  done
  if [ -n "$bad" ]; then
    echo "  FAIL  $tpl → $dest/"
    echo "        a link here must be an absolute URL if it points at a plugin document,"
    echo "        or resolve from $dest/ if it points inside the consuming repo:$bad"
    echo "F" >> "${TMPDIR:-/tmp}/vtl.$$"
  else
    echo "  PASS  $tpl → $dest/"
    echo "P" >> "${TMPDIR:-/tmp}/vtl.$$"
  fi
done

# The while loop above runs in a subshell, so its counters do not survive. The marker file does.
MARK="${TMPDIR:-/tmp}/vtl.$$"
if [ -f "$MARK" ]; then
  PASSED=$((PASSED + $(grep -c '^P' "$MARK")))
  FAILED=$((FAILED + $(grep -c '^F' "$MARK")))
  rm -f "$MARK"
fi

echo
if [ "$FAILED" = "0" ]; then
  echo "$PASSED passed, 0 failed — every template link resolves where it lands"
  echo "Does not prove a consuming repo has the relative targets yet, and does not fetch URLs."
  exit 0
fi
echo "$PASSED passed, $FAILED failed — a link does not resolve where its template lands"
exit 1
