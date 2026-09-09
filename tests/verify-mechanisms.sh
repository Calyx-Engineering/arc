#!/usr/bin/env bash
# verify-mechanisms.sh — check the product definition's mechanism table against the specs.
#
#   tests/verify-mechanisms.sh            check this repository
#   tests/verify-mechanisms.sh selftest   run the fixture cases
#
# WHY. The mechanism table in docs/product-architecture/README.md and the specs in
# docs/product-architecture/mechanisms/ are kept in agreement by hand. Nothing read them
# together: verify-all.sh ran nine gates and not one of them opened a mechanism spec. A spec
# whose Status line says `undefined` could sit behind a row marked implemented indefinitely,
# and the document that is the authority on what Arc is made of would say two things at once.
#
# WHAT IT CHECKS. Four failures, each naming the identifier that carries it — #143:
#
#   no row      a spec file in mechanisms/ that no table row links to
#   no file     a table row whose spec link resolves to nothing
#   status      a row's glyph and its spec's own `Status:` line contradict each other
#   partial     a spec with named holes sitting behind a row the table shows as complete
#
# Three more fall out of reading the pair at all, and are reported rather than passed over:
# a spec with no `Status:` line, which the README's "Spec completeness" section requires of
# every spec; a Status word outside the vocabulary; and a row without the table's six columns.
#
# ONE STATE LADDER. The table's glyphs are the ladder — ⚪ Todo, 🔵 Implemented, ✅ Matured.
# This script adds no second scale. What it holds is a compatibility map between that ladder
# and the Status vocabulary the specs already use, read off the specs as they stand:
#
#   spec says     compatible with   because
#   undefined     ⚪                 there is nothing to have built
#   partial       ⚪ 🔵              holes are named, so it cannot be Matured — the #143 case
#   specified     ⚪ 🔵 ✅           buildable; any implementation state is consistent
#   built         🔵 ✅              the spec claims it is in Arc, and ⚪ says it is not
#   definition    ⚪ 🔵 ✅           a definition file, not a build target — knowledge-tiers.md
#
# A Status word outside that list is reported, not guessed at. Adding a word here is a
# deliberate act; silently accepting one is how the two documents drift apart again. The same
# five words are named in the definition's *Spec completeness* section, which is where an author
# reads them — a vocabulary a gate enforces and only a shell script documents is a trap.
#
# THE STATUS LINE IS READ FROM THE SPEC'S HEADER — everything above its first `## ` heading.
# A spec may carry a `**Status:**` line on a subsection of its own, and that is not the
# document's state; m43-camp-assistant.md has one 470 lines down. A line count would work today
# and break on the first spec with a long preamble, so the boundary is the first section.
#
# ONLY LINKS INTO mechanisms/ ARE ASKED FOR A STATUS LINE. A row whose spec is a skill —
# m11, m18, m38 — uses that skill as its spec, per CLAUDE.md, and a SKILL.md carries
# frontmatter rather than a Status line. Its link is still resolved, because a skill link
# pointing at nothing is the same defect as a spec link pointing at nothing.
#
# REPORTS, NEVER REWRITES. Same precedent as every verifier here. Exit 1 names the mismatch
# and stops; which side of it is wrong is the author's call, not this script's. A read that
# could not be made at all exits 2 — "the table and the specs disagree" and "I could not find
# the table" are different answers, and only one of them is a defect in the documents.

set -u

DEFINITION="docs/product-architecture/README.md"
SPECDIR="docs/product-architecture/mechanisms"

# The header row that starts the mechanism table. Matched whole, so a table with different
# columns is never silently parsed as this one.
TABLE_HEADER='| ID | Mechanism | Src | Payoff | Spec | Status |'

FAILED=0
FINDINGS=""

finding() {
  FINDINGS="$FINDINGS
  $1"
  FAILED=$((FAILED + 1))
}

# Absolute path of something that may not exist. Echoes nothing when its directory does not.
abspath() {
  local d b
  d="$(dirname "$1")"
  b="$(basename "$1")"
  [ -d "$d" ] || return 1
  printf '%s/%s' "$(cd "$d" && pwd -P)" "$b"
}

# ---- the compatibility map --------------------------------------------------------------
# Named glyphs, so findings read as words and the map in the header stays the only place the
# pairing is written down.
glyph_name() {
  case "$1" in
    "⚪") echo "Todo" ;;
    "🔵") echo "Implemented" ;;
    "✅") echo "Matured" ;;
    *)    echo "" ;;
  esac
}

# 0 = the pairing is consistent, 1 = it contradicts, 2 = the word is not in the vocabulary.
status_permits() {
  local word="$1" glyph="$2"
  case "$word" in
    undefined)  case "$glyph" in "⚪") return 0 ;; *) return 1 ;; esac ;;
    partial)    case "$glyph" in "⚪"|"🔵") return 0 ;; *) return 1 ;; esac ;;
    built)      case "$glyph" in "🔵"|"✅") return 0 ;; *) return 1 ;; esac ;;
    # Spelled out rather than `return 0`. The definition's *Spec completeness* table states
    # these three glyphs for both words; an unconditional pass would keep agreeing with it by
    # coincidence, and stop the moment a fourth glyph joined the ladder.
    specified)  case "$glyph" in "⚪"|"🔵"|"✅") return 0 ;; *) return 1 ;; esac ;;
    definition) case "$glyph" in "⚪"|"🔵"|"✅") return 0 ;; *) return 1 ;; esac ;;
    *)          return 2 ;;
  esac
}

# ---- reading a spec's Status line ---------------------------------------------------------
# The first `**Status:**` above the spec's first section heading. Both halves matter: the
# boundary keeps a subsection's own status line out, and `-m1` decides it when a header carries
# two.
#
# `##+`, not `##`. A spec whose first heading is `### 1 Scope` would otherwise have no boundary
# at all, and a `**Status:**` line inside that section would be read as the document's own.
spec_status_word() {
  awk '/^##+ /{exit} {print}' "$1" \
    | grep -m1 -E '^\*\*Status:\*\*' \
    | sed -E 's/^\*\*Status:\*\*[[:space:]]*//; s/[[:space:]].*$//; s/[.,;:]+$//' \
    | tr '[:upper:]' '[:lower:]'
}

# ---- the check ----------------------------------------------------------------------------
# $1 — the tree to check. Findings accumulate in FAILED/FINDINGS; the return code says only
# whether the documents could be read at all.
check_tree() {
  local root="$1"
  local def="$root/$DEFINITION" specdir="$root/$SPECDIR"

  [ -f "$def" ] || { echo "cannot read: $def" >&2; return 2; }
  [ -d "$specdir" ] || { echo "cannot read: $specdir" >&2; return 2; }
  grep -qF "$TABLE_HEADER" "$def" || { echo "cannot find the mechanism table in $DEFINITION" >&2; return 2; }

  local defdir specdir_abs
  defdir="$(cd "$(dirname "$def")" && pwd -P)"
  specdir_abs="$(cd "$specdir" && pwd -P)"

  local work
  work="$(mktemp -d)" || return 2

  # Every row of the table as: id US glyph US spec-cell US field-count, where US is the unit
  # separator. NOT a tab: tab is IFS whitespace, so `read` collapses a run of them and a row
  # with an empty Spec or Status cell — exactly the drift this gate is for — would shift every
  # field left and be reported as a malformed row with a negative column count.
  #
  # An escaped `\|` is content, not a column edge. The Payoff column is free prose, and one
  # pipe in it would otherwise make a legitimate row unparseable and its spec unchecked.
  #
  # `\\` IS HIDDEN FIRST, and that order is the whole correctness of it. In `\\|` the backslash
  # is escaped and the pipe is a real column edge; substituting `\|` first would eat that edge
  # and merge two columns. A line that already contains either sentinel is reported rather than
  # rewritten — silently turning a source byte into a column edge is worse than saying so.
  awk -v hdr="$TABLE_HEADER" '
    index($0, hdr) == 1 { intable = 1; next }
    intable && $0 !~ /^\|/ { intable = 0 }
    intable {
      line = $0
      if (line ~ /[\001\002]/) { printf "%s\037\037\037-1\n", "?"; next }
      gsub(/\\\\/, "\002", line)      # an escaped backslash is content
      gsub(/\\\|/, "\001", line)      # an escaped pipe is content, not a column edge
      n = split(line, f, "|")
      id = f[2]; gsub(/^ +| +$/, "", id)
      if (id !~ /^m[0-9]+$/) next
      spec = (n >= 6 ? f[6] : ""); glyph = (n >= 7 ? f[7] : "")
      gsub(/^ +| +$/, "", spec);  gsub(/^ +| +$/, "", glyph)
      gsub(/\001/, "\\|", spec);  gsub(/\001/, "\\|", glyph)
      gsub(/\002/, "\\\\", spec); gsub(/\002/, "\\\\", glyph)
      printf "%s\037%s\037%s\037%d\n", id, glyph, spec, n
    }
  ' "$def" > "$work/rows"

  if [ ! -s "$work/rows" ]; then
    rm -rf "$work"
    echo "the mechanism table has no rows in $DEFINITION" >&2
    return 2
  fi

  : > "$work/linked"
  local US; US="$(printf '\037')"

  local id glyph spec nf gname targets target path resolved word
  while IFS="$US" read -r id glyph spec nf; do
    [ -n "$id" ] || continue

    # A malformed row is judged before anything is read out of it. Its columns have shifted, so
    # `f[6]` is not the Spec column — resolving its links would file whatever prose happened to
    # land there as a real link, and a genuine orphan elsewhere would go unreported because a
    # broken row appeared to link it. This is why a malformed row is the one case that still
    # produces two findings: nothing on it can be trusted to name a spec.
    if [ "$nf" != "8" ]; then
      if [ "$nf" = "-1" ]; then
        finding "unparseable row: a row contains a raw \\001 or \\002 byte, which the parser uses as a sentinel"
      else
        finding "malformed row: $id has $((nf - 2)) columns, the table has 6"
      fi
      continue
    fi

    # ---- resolve this row's links FIRST, before any check can `continue` past them ---------
    # A row that fails a LATER check still links its spec. Recording that only after the checks
    # made one defect produce two findings: the bad glyph, and a spurious "no row" for the spec
    # the row plainly links.
    targets="$(printf '%s' "$spec" | grep -oE '\]\([^)]+\)' | sed -E 's/^\]\(//; s/\)$//')"
    : > "$work/resolved"
    if [ -n "$targets" ]; then
      printf '%s\n' "$targets" > "$work/targets"
      while IFS= read -r target; do
        [ -n "$target" ] || continue
        # A URL or a bare anchor is a link, just not one that names a file in this tree. It is
        # recorded as such: dropping it silently made a cell holding only a URL report "no spec
        # link", which says the opposite of what is true.
        case "$target" in http://*|https://*|mailto:*)
          printf '%s%s%s\n' "$target" "$US" "EXTERNAL" >> "$work/resolved"; continue ;;
        esac
        path="${target%%#*}"       # an anchor is not part of the filename
        if [ -z "$path" ]; then
          printf '%s%s%s\n' "$target" "$US" "EXTERNAL" >> "$work/resolved"; continue
        fi
        resolved="$(abspath "$defdir/$path" 2>/dev/null || true)"
        printf '%s%s%s\n' "$target" "$US" "${resolved:-}" >> "$work/resolved"
        if [ -n "$resolved" ] && [ -f "$resolved" ]; then
          case "$resolved" in "$specdir_abs"/*) printf '%s\n' "$resolved" >> "$work/linked" ;; esac
        fi
      done < "$work/targets"
    fi

    # ---- now the checks --------------------------------------------------------------------
    if [ -z "$glyph" ]; then
      finding "no status glyph: $id has an empty Status cell"
      continue
    fi
    gname="$(glyph_name "$glyph")"
    if [ -z "$gname" ]; then
      finding "unknown status glyph: $id shows '$glyph', not one of ⚪ 🔵 ✅"
      continue
    fi

    # A dash is a spec that does not exist yet. The README calls that a gap, not a defect.
    case "$spec" in ""|"—"|"-") continue ;; esac

    if [ ! -s "$work/resolved" ]; then
      finding "no spec link: $id has '$spec' in its Spec column, which is neither a link nor a dash"
      continue
    fi

    while IFS="$US" read -r target resolved; do
      [ -n "$target" ] || continue
      [ "$resolved" = "EXTERNAL" ] && continue

      if [ -z "$resolved" ] || [ ! -f "$resolved" ]; then
        finding "no file: $id links $target, which resolves to no file"
        continue
      fi

      case "$resolved" in
        "$specdir_abs"/*) ;;
        *) continue ;;   # a skill spec — resolved above, but never asked for a Status line
      esac

      word="$(spec_status_word "$resolved")"
      if [ -z "$word" ]; then
        finding "no status: $id — ${resolved##*/} states no '**Status:**' line in its header"
        continue
      fi

      status_permits "$word" "$glyph"
      case "$?" in
        0) ;;
        2) finding "unknown status word: $id — ${resolved##*/} says '$word', which is not in the vocabulary" ;;
        *)
          if [ "$word" = "partial" ]; then
            finding "partial: $id — ${resolved##*/} is partial, and the table shows $glyph $gname"
          else
            finding "status: $id — the table shows $glyph $gname, ${resolved##*/} says '$word'"
          fi
          ;;
      esac
    done < "$work/resolved"
  done < "$work/rows"

  # ---- the other direction: a spec nothing links -----------------------------------------
  # The half a hardcoded list cannot see. #68's lesson, one document over.
  local f abs
  for f in "$specdir_abs"/*.md; do
    [ -f "$f" ] || continue
    abs="$f"
    if ! grep -qxF "$abs" "$work/linked"; then
      finding "no row: ${abs##*/} is a spec that no row in the mechanism table links"
    fi
  done

  rm -rf "$work"
  return 0
}

# ---- the report ---------------------------------------------------------------------------
report() {
  local root="$1"
  local status

  echo "verify-mechanisms — the mechanism table against its specs"
  echo

  check_tree "$root"
  status=$?

  if [ "$status" = "2" ]; then
    echo "  could not read the documents — nothing was checked"
    return 2
  fi

  if [ "$FAILED" = "0" ]; then
    echo "  PASS  the mechanism table and its specs are current"
    return 0
  fi

  echo "  FAIL  $FAILED mismatch(es) between the mechanism table and its specs"
  printf '%s\n' "$FINDINGS"
  echo
  echo "  Which side is wrong is the author's call. This gate reports; it does not rewrite."
  return 1
}

# ---- the self-test --------------------------------------------------------------------------
# Fixture trees, never this repository's own — the shape tests/verify-sync-parity.sh used
# before #142 removed it, recovered from git and fitted to the `selftest` subcommand the
# surviving verifiers use. Every case builds a complete miniature product definition under
# mktemp and runs the real check against it, so a failed run leaves no residue and a case
# cannot pass because the live tree happens to be clean.
SELFTEST_WORK=""

selftest() {
  local passed=0 failed=0
  SELFTEST_WORK="$(mktemp -d)"
  trap 'rm -rf "$SELFTEST_WORK"' EXIT

  # A tree with two rows: m10 `built`, and m20 `partial`. Their glyphs are arguments, because
  # GNU sed here cannot MATCH a four-byte UTF-8 character — 🔵 is U+1F535 — though it writes
  # one correctly. A case that mutated a glyph with sed silently changed nothing and passed
  # against an unmodified fixture. Building the tree the case wants removes the whole class.
  #
  #   make_tree <name> [m10 glyph] [m20 glyph]      defaults: 🔵 and ⚪, both consistent
  make_tree() {
    local root="$SELFTEST_WORK/$1"
    # `${2-…}`, not `${2:-…}` — a case that passes an EMPTY glyph on purpose must get one.
    local m10g="${2-🔵}" m20g="${3-⚪}"
    mkdir -p "$root/$SPECDIR" "$root/skills/alpha"

    cat > "$root/$DEFINITION" <<FIXTURE
# Fixture product definition

| | State | Means |
|---|---|---|
| ⚪ | **Todo** | Not in Arc |
| 🔵 | **Implemented** | In Arc, waiting on the soak |
| ✅ | **Matured** | Soaked |

| ID | Mechanism | Src | Payoff | Spec | Status |
|---|---|---|---|---|---|
| | **A SECTION** | | | | |
| m10 | Fixture guard | 🔥 | **A payoff.** *A gloss* | [spec](mechanisms/m10-guard.md) | $m10g |
| m20 | Fixture decomposition | 📐 | **A payoff.** *A gloss* | [spec](mechanisms/m20-decomp.md) | $m20g |

Trailing prose, which ends the table.
FIXTURE

    printf '# m10 — Fixture guard\n\n**Status:** built — the checks fire.\n' \
      > "$root/$SPECDIR/m10-guard.md"
    printf '# m20 — Fixture decomposition\n\n**Status:** partial — one hole, named here.\n' \
      > "$root/$SPECDIR/m20-decomp.md"

    printf -- '---\nname: alpha\n---\n\n# alpha\n' > "$root/skills/alpha/SKILL.md"

    printf '%s' "$root"
  }

  # Run the real check against a fixture, in a subshell so its findings never leak between
  # cases. The subshell is why FAILED/FINDINGS can be globals in the first place.
  run() (
    FAILED=0
    FINDINGS=""
    report "$1"
  )

  # Cases assert on exit status and on a substring of the output, because the output is what
  # a human acts on. A gate that exits 1 with an unreadable reason is not a gate.
  #
  # THE SUBSTRING TEST IS BASH'S, NOT `grep -qF`. Measured here: `grep -F` cannot match a
  # four-byte UTF-8 character — `grep -qF -- "shows 🔵 Implemented"` finds nothing in a line
  # that plainly contains it, while ⚪ and ✅ (three bytes) match. Every assertion naming 🔵
  # would have been unmatchable, so a case expecting failure could only fail and a case
  # expecting success would pass without testing anything. `[[ == *…* ]]` matches all three.
  # Same underlying limitation as the one that stopped `sed` mutating a glyph.
  case_is() {
    local name="$1" want_status="$2" want_text="$3" got_status="$4" got="$5"
    if [ "$got_status" = "$want_status" ] && [[ "$got" == *"$want_text"* ]]; then
      echo "  PASS  $name"
      passed=$((passed + 1))
    else
      echo "  FAIL  $name"
      echo "        wanted exit $want_status containing: $want_text"
      echo "        got exit $got_status:"
      printf '%s\n' "$got" | sed 's/^/        | /'
      failed=$((failed + 1))
    fi
  }

  echo "verify-mechanisms selftest — fixture trees, never the live tree"
  echo

  local root out status

  # 1 — a tree whose table and specs agree.
  root=$(make_tree clean)
  out=$(run "$root"); status=$?
  case_is "an agreeing tree passes" 0 "the mechanism table and its specs are current" "$status" "$out"

  # 2 — #143's first bullet: a spec file with no row in the table.
  root=$(make_tree orphanspec)
  printf '# m99 — Unrowed\n\n**Status:** specified.\n' > "$root/$SPECDIR/m99-unrowed.md"
  out=$(run "$root"); status=$?
  case_is "a spec with no row fails" 1 "no row: m99-unrowed.md" "$status" "$out"

  # 3 — #143's second bullet: a row whose spec link resolves to no file.
  root=$(make_tree deadlink)
  rm "$root/$SPECDIR/m20-decomp.md"
  out=$(run "$root"); status=$?
  case_is "a spec link resolving to no file fails" 1 "no file: m20 links mechanisms/m20-decomp.md" "$status" "$out"

  # 4 — #143's third bullet: the glyph and the Status line contradict. The spec says built,
  #     the table says the mechanism is not in Arc at all.
  root=$(make_tree glyphdisagrees "⚪")
  out=$(run "$root"); status=$?
  case_is "a glyph disagreeing with the Status line fails" 1 "status: m10 — the table shows ⚪ Todo, m10-guard.md says 'built'" "$status" "$out"

  # 5 — #143's fourth bullet: a partial spec the table shows as complete. Complete is ✅
  #     Matured — soaked — and a spec with named holes cannot be that.
  root=$(make_tree partialcomplete "🔵" "✅")
  out=$(run "$root"); status=$?
  case_is "a partial spec shown as Matured fails" 1 "partial: m20 — m20-decomp.md is partial, and the table shows ✅ Matured" "$status" "$out"

  # 5b — the same spec at 🔵 is NOT a failure. Implemented is not complete; without this the
  #      previous case would pass for a gate that simply rejected every partial spec.
  root=$(make_tree partialimplemented "🔵" "🔵")
  out=$(run "$root"); status=$?
  case_is "a partial spec shown as Implemented passes" 0 "are current" "$status" "$out"

  # 5c — `undefined` is the tightest word: ⚪ only. Nothing can have been built from a spec that
  #      does not exist yet, so 🔵 contradicts it. Without this case the `undefined` arm of
  #      status_permits could return 0 unconditionally and every other case would still pass.
  root=$(make_tree undefinedimplemented "🔵" "🔵")
  printf '# m20 — Fixture decomposition\n\n**Status:** undefined — deferred pending an interview.\n' \
    > "$root/$SPECDIR/m20-decomp.md"
  out=$(run "$root"); status=$?
  case_is "an undefined spec shown as Implemented fails" 1 "status: m20 — the table shows 🔵 Implemented, m20-decomp.md says 'undefined'" "$status" "$out"

  # 6 — a spec with no Status line at all. The README requires one of every spec, and m40
  #     in the live tree had none — found by this gate on its first run.
  root=$(make_tree nostatus)
  printf '# m20 — Fixture decomposition\n\nNo status line anywhere.\n' > "$root/$SPECDIR/m20-decomp.md"
  out=$(run "$root"); status=$?
  case_is "a spec with no Status line fails" 1 "no status: m20" "$status" "$out"

  # 7 — a Status word outside the vocabulary is reported, never guessed at.
  root=$(make_tree unknownword)
  printf '# m20\n\n**Status:** halfway — invented.\n' > "$root/$SPECDIR/m20-decomp.md"
  out=$(run "$root"); status=$?
  case_is "a Status word outside the vocabulary fails" 1 "unknown status word: m20" "$status" "$out"

  # 8 — a row that does not have the table's six columns. Parsed confidently, a row like
  #     this reads its Spec cell out of the wrong column and reports a defect that is not there.
  #     The count is asserted too: a malformed row is the ONE case that legitimately produces
  #     two findings, because nothing on it can be trusted to name a spec. Case 18 asserts the
  #     complementary half — every other failing row produces exactly one.
  root=$(make_tree malformedrow)
  sed -i 's#^| m20 .*$#| m20 | Fixture decomposition | 📐 | [spec](mechanisms/m20-decomp.md) | ⚪ |#' "$root/$DEFINITION"
  out=$(run "$root"); status=$?
  case_is "a row without six columns fails" 1 "malformed row: m20" "$status" "$out"
  case_is "a malformed row reports its spec unlinked too" 1 "FAIL  2 mismatch(es)" "$status" "$out"

  # 8b — a malformed row's links are NOT filed as seen. Its columns have shifted, so filing them
  #      would let a broken row vouch for a spec nothing really links — hiding a genuine orphan
  #      behind a defect the gate already reported.
  root=$(make_tree malformedmasks)
  printf '# m99 — Unrowed\n\n**Status:** specified.\n' > "$root/$SPECDIR/m99-orphan.md"
  sed -i 's#^| m20 .*$#| m20 | X | 📐 | [old](mechanisms/m99-orphan.md) | ⚪ |#' "$root/$DEFINITION"
  out=$(run "$root"); status=$?
  case_is "a malformed row does not vouch for a spec" 1 "no row: m99-orphan.md" "$status" "$out"

  # 9 — a skill-linked row. CLAUDE.md makes the skill its own spec, and a SKILL.md carries
  #     frontmatter rather than a Status line, so it must not be asked for one.
  root=$(make_tree skillrow)
  sed -i 's#^| m20 \(.*\)| \[spec\](mechanisms/m20-decomp.md) | ⚪ |#| m20 \1| [skill](../../skills/alpha/SKILL.md) | 🔵 |#' "$root/$DEFINITION"
  rm "$root/$SPECDIR/m20-decomp.md"
  out=$(run "$root"); status=$?
  case_is "a skill-linked row is not asked for a Status line" 0 "are current" "$status" "$out"

  # 9b — but a skill link pointing at nothing is the same defect as a spec link pointing at
  #      nothing. Without this, case 9 would pass for a gate that skipped skill rows entirely.
  root=$(make_tree deadskillrow)
  sed -i 's#^| m20 \(.*\)| \[spec\](mechanisms/m20-decomp.md) | ⚪ |#| m20 \1| [skill](../../skills/ghost/SKILL.md) | 🔵 |#' "$root/$DEFINITION"
  rm "$root/$SPECDIR/m20-decomp.md"
  out=$(run "$root"); status=$?
  case_is "a skill link resolving to no file fails" 1 "no file: m20 links ../../skills/ghost/SKILL.md" "$status" "$out"

  # 10 — a dash in the Spec column is a gap the README names as such, not a defect. m39 is one.
  root=$(make_tree dashspec)
  sed -i 's#^| m20 \(.*\)| \[spec\](mechanisms/m20-decomp.md) | ⚪ |#| m20 \1| — | ⚪ |#' "$root/$DEFINITION"
  rm "$root/$SPECDIR/m20-decomp.md"
  out=$(run "$root"); status=$?
  case_is "a dash in the Spec column passes" 0 "are current" "$status" "$out"

  # 11 — a row carrying two spec links. m16 has one of these, and a check reading only the
  #      first would never open the second.
  root=$(make_tree twolinks)
  sed -i 's#^| m20 \(.*\)| \[spec\](mechanisms/m20-decomp.md) | ⚪ |#| m20 \1| [a](mechanisms/m20-decomp.md) · [b](mechanisms/m20-second.md) | ⚪ |#' "$root/$DEFINITION"
  printf '# second\n\n**Status:** built — contradicts the ⚪ on its row.\n' > "$root/$SPECDIR/m20-second.md"
  out=$(run "$root"); status=$?
  case_is "the second link on a row is read too" 1 "m20-second.md says 'built'" "$status" "$out"

  # 12b — two Status lines INSIDE the header, which the boundary alone cannot separate. The
  #       first wins. Without this case `grep -m1` could become `tail -n1` and case 12 would
  #       still pass, because the boundary would hide the change — measured by mutation.
  root=$(make_tree twostatus)
  printf '# m20\n\n**Status:** partial — the real one.\n\nBody.\n\n**Status:** built — a second one, still above the first heading.\n\n## 1 A section\n' \
    > "$root/$SPECDIR/m20-decomp.md"
  out=$(run "$root"); status=$?
  case_is "the first Status line in the header wins" 0 "are current" "$status" "$out"

  # 12c — a spec whose ONLY Status line sits below the first heading has none in its header.
  #       This is the case that pins the boundary: with it removed, the line below is read as
  #       the document's own and the spec looks fine. Measured by mutation.
  root=$(make_tree statusbelowheading)
  printf '# m20\n\n## 1 A section\n\n**Status:** partial — too late to count.\n' \
    > "$root/$SPECDIR/m20-decomp.md"
  out=$(run "$root"); status=$?
  case_is "a Status line only below the heading is missing" 1 "no status: m20" "$status" "$out"

  # 12d — the same, under an h3. `/^## /` does not match `### `, so a spec whose first heading
  #       is `### 1 Scope` would have no boundary at all and its whole body would be scanned.
  root=$(make_tree h3heading)
  printf '# m20\n\n### 1 A subsection first\n\n**Status:** built — must not be read.\n' \
    > "$root/$SPECDIR/m20-decomp.md"
  out=$(run "$root"); status=$?
  case_is "an h3 also bounds the header" 1 "no status: m20" "$status" "$out"

  # 14 — an empty Status cell. Tab is IFS whitespace, so an earlier version of the row reader
  #      collapsed the empty field, shifted every column left and reported this as a malformed
  #      row with a NEGATIVE column count. A missing glyph is the drift this gate is for.
  root=$(make_tree emptyglyph "")
  out=$(run "$root"); status=$?
  case_is "an empty Status cell is reported as a missing glyph" 1 "no status glyph: m10 has an empty Status cell" "$status" "$out"

  # 15 — an empty Spec cell, the other half of the same parsing defect. The row is a gap, and
  #      the spec nothing links is the only finding. Asserting the COUNT is what separates a
  #      correct read from the collapsed one, which produced a malformed row as well.
  root=$(make_tree emptyspec)
  sed -i 's#^| m20 \(.*\)| \[spec\](mechanisms/m20-decomp.md) | ⚪ |#| m20 \1|  | ⚪ |#' "$root/$DEFINITION"
  out=$(run "$root"); status=$?
  case_is "an empty Spec cell yields exactly one finding" 1 "FAIL  1 mismatch(es)" "$status" "$out"

  # 16 — an escaped pipe in the Payoff column is content, not a column edge. The Payoff column
  #      is free prose, and one pipe would otherwise make a legitimate row unparseable.
  root=$(make_tree escapedpipe)
  sed -i 's#\*\*A payoff.\*\* \*A gloss\*#**A payoff.** *Reads `a \\| b`*#' "$root/$DEFINITION"
  out=$(run "$root"); status=$?
  case_is "an escaped pipe in the Payoff column parses" 0 "are current" "$status" "$out"

  # 17 — a link carrying an anchor. The anchor is not part of the filename, and treating it as
  #      one reported a valid link as missing AND its spec as unlinked — two findings, no defect.
  root=$(make_tree anchoredlink)
  sed -i 's@(mechanisms/m20-decomp.md)@(mechanisms/m20-decomp.md#3-the-holes)@' "$root/$DEFINITION"
  out=$(run "$root"); status=$?
  case_is "a link with an anchor resolves" 0 "are current" "$status" "$out"

  # 17b — a Spec cell holding only a URL. It is a link, just not one naming a file here.
  #        Dropping it silently made the cell report "no spec link", which says the opposite of
  #        what is true.
  root=$(make_tree urlspec)
  sed -i 's@\[spec\](mechanisms/m20-decomp.md)@[spec](https://example.invalid/m20.md)@' "$root/$DEFINITION"
  rm "$root/$SPECDIR/m20-decomp.md"
  out=$(run "$root"); status=$?
  case_is "a URL in the Spec column is not 'no spec link'" 0 "are current" "$status" "$out"

  # 16b — an ESCAPED backslash IMMEDIATELY before a real column edge. In `\\|` the backslash is
  #       escaped and the pipe is a genuine edge; substituting `\|` first eats that edge and
  #       merges two columns. The adjacency is the whole case — with anything between the
  #       backslashes and the pipe the sequence `\|` never occurs and the fixture proves nothing.
  root=$(make_tree escapedbackslash)
  sed -i 's#\*A gloss\* | \[spec\]#*A gloss* \\\\| [spec]#' "$root/$DEFINITION"
  grep -q 'A gloss\* \\\\| \[spec\]' "$root/$DEFINITION" \
    || { echo "  FAIL  fixture escapedbackslash did not apply"; failed=$((failed + 1)); }
  out=$(run "$root"); status=$?
  case_is "an escaped backslash does not eat the next column edge" 0 "are current" "$status" "$out"

  # 16c — the sentinels are restored on the way out. A Spec cell carrying an escaped pipe and no
  #       link is echoed back in the finding, and without the restore it would read 'a \001 b'.
  root=$(make_tree sentinelrestore)
  sed -i 's#| \[spec\](mechanisms/m20-decomp.md) | ⚪ |#| a \\| b | ⚪ |#' "$root/$DEFINITION"
  rm "$root/$SPECDIR/m20-decomp.md"
  out=$(run "$root"); status=$?
  case_is "a sentinel is restored before it is reported" 1 "has 'a \\| b' in its Spec column" "$status" "$out"

  # 16d — a raw sentinel byte in the source. The parser uses \001 and \002 internally, so a line
  #       already holding one cannot be rewritten safely. Saying so beats silently turning a
  #       source byte into a column edge.
  root=$(make_tree rawsentinel)
  awk -v row="$(printf '| m30 | X | 📐 | pay\001load | [spec](mechanisms/m10-guard.md) | ⚪ |')" \
    '{print} /^\| m20 /{print row}' "$root/$DEFINITION" > "$root/def.tmp" && mv "$root/def.tmp" "$root/$DEFINITION"
  out=$(run "$root"); status=$?
  case_is "a raw sentinel byte is reported, not rewritten" 1 "unparseable row" "$status" "$out"

  # 18 — one defect, one finding. A row that fails a check still links its spec, and recording
  #      that only after the checks made the row ALSO draw a spurious "no row" for a spec it
  #      plainly links. A malformed row is the exception and stays two findings: its columns
  #      have shifted, so which cell held the spec link is no longer knowable.
  root=$(make_tree onefinding "X")
  out=$(run "$root"); status=$?
  case_is "a bad glyph does not also report its spec as unlinked" 1 "FAIL  1 mismatch(es)" "$status" "$out"

  # 13 — no mechanism table at all is "I could not tell", not "they disagree". Exit 2, so a
  #      missing document never reads as a clean gate or as a real mismatch.
  root=$(make_tree notable)
  printf '# Fixture with no mechanism table\n' > "$root/$DEFINITION"
  out=$(run "$root" 2>&1); status=$?
  case_is "a definition with no table exits 2" 2 "could not read the documents" "$status" "$out"

  echo
  echo "$passed passed, $failed failed"
  [ "$failed" = "0" ] || return 1
  return 0
}

# ---- entry ---------------------------------------------------------------------------------
case "${1:-}" in
  selftest)
    selftest
    exit $?
    ;;
  ""|--check)
    report "${MECH_ROOT:-$(cd "$(dirname "$0")/.." && pwd -P)}"
    exit $?
    ;;
  *)
    cat >&2 <<'USAGE'
usage:
  tests/verify-mechanisms.sh            check this repository
  tests/verify-mechanisms.sh selftest   run the fixture cases
USAGE
    exit 2
    ;;
esac
