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
# That distinction is why re-basing is the wrong instrument here rather than an unapplied one:
# it fixes depth, and depth is not what is wrong with fourteen of them.
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

SELF="$(cd "$(dirname "$0")" && pwd)/$(basename "$0")"

# ---- the self-test -------------------------------------------------------------------------
# Fixture trees under mktemp, never this repository's own. It runs the real script through
# TEMPLATE_ROOT, which already existed for exactly this. The arc-work derivation (#167) is what
# needs cases: the live tree resolves, so a live run alone cannot show the check can fail.
if [ "${1:-}" = "selftest" ]; then
  passed=0; failed=0
  WORK="$(mktemp -d)"; trap 'rm -rf "$WORK"' EXIT

  # Every template MAP names must exist, or the script reports a mapped template missing from
  # disk — so a fixture is the whole set, with only dev-log.md carrying the link under test.
  make_tree() {  # make_tree <name> <the arc-work link to put in dev-log.md>
    local root="$WORK/$1" link="$2"
    mkdir -p "$root/templates/camp" "$root/docs/arc-log" "$root/docs/dev-log"
    local f
    for f in arc-log handoff event-log SKILL; do printf '# fixture\n' > "$root/templates/$f.md"; done
    for f in operating-agreement voice notes; do printf '# fixture\n' > "$root/templates/camp/$f.md"; done
    printf '# fixture dev-log\n\n- **Arc work:** [&lt;topic&gt;](%s)\n' "$link" > "$root/templates/dev-log.md"
    printf '%s' "$root"
  }

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

  run() { TEMPLATE_ROOT="$1" bash "$SELF" 2>&1; }

  echo "verify-template-links selftest — fixture trees, never the live tree"
  echo

  # 1 — the derived path resolves: the arc-work root is where the `../` lands, and it holds a
  #     real arc slug for <arc-slug> to name.
  root=$(make_tree resolves '../arc-work/&lt;arc-slug&gt;/&lt;topic&gt;.md')
  mkdir -p "$root/docs/arc-work/04-dogfood"
  out=$(run "$root"); status=$?
  case_is "a derived arc-work path that resolves passes" 0 "0 failed" "$status" "$out"

  # 2 — #167's case. The `../` count assumes the template lands one level under docs/; two
  #     levels up lands outside it entirely, and nothing reported that before.
  root=$(make_tree wrongdepth '../../arc-work/&lt;arc-slug&gt;/&lt;topic&gt;.md')
  mkdir -p "$root/docs/arc-work/04-dogfood"
  out=$(run "$root"); status=$?
  case_is "an arc-work path at the wrong depth fails" 1 "the arc-work root does not resolve from here" "$status" "$out"

  # 3 — no arc-work root at all.
  root=$(make_tree noroot '../arc-work/&lt;arc-slug&gt;/&lt;topic&gt;.md')
  out=$(run "$root"); status=$?
  case_is "a missing arc-work root fails" 1 "the arc-work root does not resolve from here" "$status" "$out"

  # 4 — the root resolves but holds no slug, so <arc-slug> can name nothing. Without this the
  #     check would pass on an empty directory and prove only that `..` was counted right.
  root=$(make_tree noslug '../arc-work/&lt;arc-slug&gt;/&lt;topic&gt;.md')
  mkdir -p "$root/docs/arc-work"
  out=$(run "$root"); status=$?
  case_is "an arc-work root with no arc slug fails" 1 "holds no arc slug" "$status" "$out"

  # 5 — a NESTED arc slug. This is the shape #167 names: the path is derived from the tree
  #     rather than assumed to be one flat segment, so a slug that is itself nested resolves.
  root=$(make_tree nested '../arc-work/&lt;arc-slug&gt;/&lt;topic&gt;.md')
  mkdir -p "$root/docs/arc-work/04-dogfood/s3-upkeep"
  out=$(run "$root"); status=$?
  case_is "a nested arc slug resolves" 0 "0 failed" "$status" "$out"

  # 6 — a placeholder link that is not an arc-work path is still skipped. The derivation is
  #     scoped, and this case says so rather than leaving it to be inferred.
  root=$(make_tree otherplaceholder '../scratch/issue-&lt;N&gt;/&lt;topic&gt;.md')
  out=$(run "$root"); status=$?
  case_is "a non-arc-work placeholder is not derived" 0 "0 failed" "$status" "$out"

  echo
  echo "$passed passed, $failed failed"
  [ "$failed" = "0" ] || exit 1
  exit 0
fi

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
    esac
    case "$t" in
      *'<'*|*'&lt;'*)
        # A PLACEHOLDER PATH IS DERIVED, NOT SKIPPED — #167. `../arc-work/<arc-slug>/<topic>.md`
        # was skipped whole by this rule, so nothing checked that the fixed half of it lands
        # anywhere: the `../` assumed the template lands exactly one level under docs/, and a
        # template that moved, or an arc-work root that did not, would report nothing at all.
        #
        # Only the arc-work path is derived here, and that is a scope statement rather than a
        # special case: the placeholder is expanded against the arc slugs THIS repository has,
        # and arc-work is the one K2 directory it actually populates. `../scratch/` and
        # `../report/` carry the same shape with no instances to expand against, so there is
        # nothing to derive them from — see this issue's Spawned note.
        case "$t" in
          *arc-work/*) ;;
          *) continue ;;
        esac
        # the fixed half of the path: everything up to and including the arc-work segment
        aw="${t%%arc-work/*}arc-work"
        case "$dest" in
          */SKILLNAME) awres="$(dirname "$dest")/x/$aw" ;;
          *) awres="$dest/$aw" ;;
        esac
        awres="$(printf '%s' "$awres" | awk -F/ '{n=0; for(i=1;i<=NF;i++){ if($i==""||$i==".") continue; if($i==".."){ if(n>0) n--; else out[++n]=".."; } else out[++n]=$i } s=""; for(i=1;i<=n;i++) s=s (i>1?"/":"") out[i]; print s}')"
        if [ ! -d "$awres" ]; then
          bad="$bad
        $t
          the arc-work root does not resolve from here: $awres"
        elif [ -z "$(find "$awres" -mindepth 1 -maxdepth 1 -type d -print -quit 2>/dev/null)" ]; then
          # The placeholder names an arc slug. With no slug under the root there is nothing it
          # could name, so the derived path cannot resolve for any value of it.
          bad="$bad
        $t
          $awres holds no arc slug, so <arc-slug> names nothing"
        fi
        continue
        ;;
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
