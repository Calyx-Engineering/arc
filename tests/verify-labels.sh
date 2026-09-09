#!/usr/bin/env bash
# verify-labels.sh — a label agrees with the title prefix, or it is not there.
#
#   tools/verify-labels.sh                 sweep this repository's open issues
#   tools/verify-labels.sh labels          the label set itself, against the sanctioned one
#   tools/verify-labels.sh selftest        the decision, on fixtures
#
# WHY. Seven title prefixes were in use, nine stock labels existed, and nothing mapped one to
# the other — so every `fix:` issue in the repo was unlabelled until a human noticed and
# labelled seven by hand. #84. The prefix is the source of truth: it is in the title, it is
# read by `verify-tracker-body.sh title`, and it cannot silently disagree with itself. A label
# is a query surface bolted onto it, and a label that disagrees with the prefix is worse than
# no label — it makes `label:bug` return work that is not a bug and hide work that is.
#
# SO THE CHECK IS AGREEMENT, NOT PRESENCE. Two failures, and both are real:
#
#   missing      the prefix licenses a type label and the issue does not carry it
#   contradicts  the issue carries a type label its prefix does not license
#
# ONLY TYPE LABELS ARE JUDGED. `priority: high`, `issue-discipline` and `in-progress` say
# something the title does not, so nothing here has an opinion about them. A check that swept
# every label would have to know what work is urgent, which is not decidable from a title.
#
# A PREFIX MAY LICENSE NOTHING, AND THAT IS A VERDICT. `scope:`, `chore:`, `refactor:` and
# `test:` carry no label because no query would use one — the test in #84 is whether a query
# would actually run, not whether a category exists. Licensing nothing is checked as strictly
# as licensing something: an issue titled `chore:` wearing `enhancement` fails.
#
# REPORTS, NEVER BLOCKS, AND NEVER WRITES. Same precedent as every other verifier here. Exit 1
# marks a finding for a human to read; nothing denies a tool call and nothing edits the tracker.
# A read that could not be made exits 2 — "the label is wrong" and "I could not tell" are
# different answers and only one is a defect.

set -u

# ---- the mapping -----------------------------------------------------------------
# prefix|label — the whole of it. An empty label means the prefix licenses none.
# `skills/issue-write` carries the same table in prose; this is the machine half.
MAP="
fix|bug
feat|enhancement
docs|documentation
arc|arc
workstream|workstream
scope|
chore|
refactor|
test|
"

# Every label this mapping can license. A label in this set on an issue whose prefix does not
# license it is the `contradicts` failure — which is why the set is derived from MAP rather
# than written out again.
type_labels() {
  printf '%s\n' "$MAP" | while IFS='|' read -r _ l; do
    [ -n "${l:-}" ] && printf '%s\n' "$l"
  done
}

# The label set this repository sanctions, beyond the type labels above. Each is here because a
# query uses it, and #84's constraint is that a label nobody filters on costs attention at every
# issue write.
EXTRA_LABELS="
in-progress
priority: high
issue-discipline
"

# The stock GitHub set, retired by #84: never used, never reviewed against how this repo works,
# and a label nobody filters on costs attention at every issue write. Named here rather than
# left to fall out as "sanctioned by nothing", so the finding carries the command that clears it
# and a reader can tell a decided retirement from a label someone invented last week.
RETIRED_LABELS="
duplicate
good first issue
help wanted
invalid
question
wontfix
"

usage() {
  cat >&2 <<'USAGE'
usage:
  tools/verify-labels.sh              sweep this repository's open issues
  tools/verify-labels.sh labels       the label set itself
  tools/verify-labels.sh selftest
USAGE
}

# ---- the prefix ------------------------------------------------------------------
# The first word of the title up to its colon, and nothing else. A title with no colon in its
# first word has no prefix, which is its own finding — `verify-tracker-body.sh title` does not
# require one and this is the only place it is asked for.
#
#   $1  title
prefix_of() {
  printf '%s' "$1" | sed -n 's/^\([a-z][a-z]*\):.*/\1/p'
}

# ---- the decision ----------------------------------------------------------------
# A pure function over a title and a label list, so the selftest exercises the part that was
# wrong in #84 — which label a prefix licenses — with no network and no repository.
#
#   $1  title
#   $2  comma-separated labels, possibly empty
classify() {
  local title="$1" labels="$2"
  local pfx want have wrong found

  pfx="$(prefix_of "$title")"
  if [ -z "$pfx" ]; then
    echo "FAIL  no type prefix — \"$title\""
    return 1
  fi

  # An unmapped prefix is reported, never guessed at. Adding a prefix is a deliberate act;
  # silently accepting one is how seven prefixes and nine labels drifted apart in the first place.
  case "$MAP" in
    *"
$pfx|"*) ;;
    *)
      echo "FAIL  \`$pfx:\` is not a type this repository uses — add it to MAP or retitle"
      return 1 ;;
  esac

  want="$(printf '%s\n' "$MAP" | awk -F'|' -v p="$pfx" '$1 == p { print $2; exit }')"

  # Which type labels are actually on it. `,` on both sides so a substring cannot match —
  # `bug` must not be found inside `debug`.
  have=""
  while IFS= read -r l; do
    [ -n "$l" ] || continue
    case ",$labels," in *",$l,"*) have="$have $l" ;; esac
  done <<EOF
$(type_labels)
EOF

  found=0
  wrong=""
  for l in $have; do
    if [ "$l" = "$want" ]; then found=1; else wrong="$wrong $l"; fi
  done

  if [ -n "$wrong" ]; then
    if [ -n "$want" ]; then
      echo "FAIL  contradicts — \`$pfx:\` licenses \`$want\`, not$wrong"
    else
      echo "FAIL  contradicts — \`$pfx:\` licenses no type label, and it carries$wrong"
    fi
    return 1
  fi

  if [ -n "$want" ] && [ "$found" = "0" ]; then
    echo "FAIL  missing — \`$pfx:\` licenses \`$want\` and it carries none"
    return 1
  fi

  if [ -z "$want" ]; then
    echo "PASS  \`$pfx:\` licenses no type label, and it carries none"
  else
    echo "PASS  \`$pfx:\` and \`$want\` agree"
  fi
  return 0
}

# ---- live ------------------------------------------------------------------------
# EVERY READ THAT DECIDES A VERDICT IS CHECKED. An empty answer from a failed read is
# indistinguishable from a repository with no open issues, and reporting "all clean" for a read
# that never happened is the failure this whole file is derived from.
gh_read() {
  local what="$1"; shift
  local out
  if ! out="$("$@" 2>&1)"; then
    echo "the $what read failed — cannot tell whether the labels agree:" >&2
    printf '%s\n' "$out" >&2
    exit 2
  fi
  printf '%s' "$out"
}

# THE FIELD SEPARATOR IS A UNIT SEPARATOR, NEVER A TAB. A tab is IFS whitespace, so bash
# collapses a run of them into one delimiter — an issue carrying no labels arrives as
# `36<tab><tab>feat: …` and `read num labels title` puts the TITLE into `labels` and leaves the
# title empty. Every unlabelled issue then reported "no type prefix" against an empty string,
# which is the exact class of false finding this file exists to remove. Found by running the
# sweep, not by reading it.
US="$(printf '\037')"

# Reads rows on stdin, one issue per line: <number><US><labels><US><title>. Separated from the
# `gh` read so the selftest can feed it fixture rows — the parse is where the defect was, and a
# selftest that only exercised `classify` passed while the sweep was wrong.
sweep_stream() {
  local passed=0 failed=0 num labels title out status
  while IFS="$US" read -r num labels title; do
    [ -n "${num:-}" ] || continue
    out="$(classify "${title:-}" "${labels:-}")"; status=$?
    if [ "$status" = "0" ]; then
      passed=$((passed + 1))
    else
      failed=$((failed + 1))
      echo "  #$num  ${out#FAIL  }"
      echo "        ${title:-(no title)}"
    fi
  done

  echo
  if [ "$failed" = "0" ]; then
    echo "$passed open issues, all agree with their prefix"
    return 0
  fi
  echo "$((passed + failed)) open issues, $failed disagree with their prefix"
  return 1
}

sweep() {
  command -v gh >/dev/null 2>&1 || { echo "gh not on PATH" >&2; exit 2; }
  local rows

  rows="$(gh_read "open issues" gh issue list --state open --limit 500 \
    --json number,title,labels \
    --jq '.[] | "\(.number)\u001f\(.labels | map(.name) | join(","))\u001f\(.title)"')" || exit $?

  echo "verify-labels — open issues, prefix against type label"
  echo

  sweep_stream <<EOF
$rows
EOF
  exit $?
}

# ---- the label set itself --------------------------------------------------------
# The other half of #84: a label nobody filters on costs attention at every issue write, so a
# label outside the sanctioned set is reported even when nothing wears it. Reported, never
# deleted — this script does not write to the tracker.
label_set() {
  command -v gh >/dev/null 2>&1 || { echo "gh not on PATH" >&2; exit 2; }
  local have want extra missing

  have="$(gh_read "label list" gh label list --limit 200 --json name --jq '.[].name')" || exit $?
  want="$(printf '%s\n%s\n' "$(type_labels)" "$EXTRA_LABELS" | grep -v '^[[:space:]]*$' | sort)"

  extra=""; missing=""
  while IFS= read -r l; do
    [ -n "$l" ] || continue
    printf '%s\n' "$want" | grep -qxF -- "$l" || extra="$extra
        $l"
  done <<EOF
$have
EOF
  while IFS= read -r l; do
    [ -n "$l" ] || continue
    printf '%s\n' "$have" | grep -qxF -- "$l" || missing="$missing
        $l"
  done <<EOF
$want
EOF

  echo "verify-labels — the label set"
  echo

  # A retired label is separated from an unrecognised one. Both are findings, and they need
  # different answers: one is deleted, the other is a decision nobody has made yet.
  retired=""; unknown=""
  while IFS= read -r l; do
    [ -n "$l" ] || continue
    if printf '%s\n' "$RETIRED_LABELS" | grep -qxF -- "$l"; then
      retired="$retired
        $l"
    else
      unknown="$unknown
        $l"
    fi
  done <<EOF
$(printf '%s' "$extra" | sed 's/^ *//')
EOF

  local bad=0
  if [ -n "$missing" ]; then
    echo "  FAIL  sanctioned but absent from the tracker:$missing"
    bad=1
  fi
  if [ -n "$retired" ]; then
    echo "  FAIL  retired by #84 and still on the tracker:$retired"
    echo
    echo "        Deleting a label strips it from everything wearing it, and this check reads"
    echo "        only the label list. CHECK FIRST — nothing wore any of the six when #84"
    echo "        retired them, which was true then and is not a claim about now. Issues and"
    echo "        PRs both, because a delete takes it off both:"
    echo
    echo "        for l in duplicate \"good first issue\" \"help wanted\" invalid question wontfix; do"
    echo "          echo \"\$l: \$(gh issue list --state all --label \"\$l\" --limit 1 --json number --jq length) issue(s), \\"
    echo "                   \$(gh pr list --state all --label \"\$l\" --limit 1 --json number --jq length) PR(s)\""
    echo "        done"
    echo
    echo "        Then, if every count is 0:"
    echo
    echo "        for l in duplicate \"good first issue\" \"help wanted\" invalid question wontfix; do"
    echo "          gh label delete \"\$l\" --yes"
    echo "        done"
    bad=1
  fi
  if [ -n "$unknown" ]; then
    echo "  FAIL  present but sanctioned by nothing — a label nobody queries costs attention"
    echo "        at every issue write. Delete it, or add it to MAP or EXTRA_LABELS:$unknown"
    bad=1
  fi
  [ "$bad" = "0" ] && echo "  PASS  the tracker's labels are exactly the sanctioned set"
  echo
  exit "$bad"
}

# ---- selftest --------------------------------------------------------------------
# Cases inline: each is a title and a label list, and a file per case would be more scaffolding
# than case. EVERY CASE ASSERTS THE MESSAGE, NOT ONLY THE EXIT CODE — naming which of the two
# failures it found is the tool's job, and an exit-code-only selftest passes with `missing` and
# `contradicts` swapped.
selftest() {
  run=0; passed=0; failed=0

  ok()  { passed=$((passed + 1)); echo "  ok    $1"; }
  bad() { failed=$((failed + 1)); echo "  FAIL  $1"; }

  case_is() {
    local want="$1" want_text="$2" name="$3" title="$4" labels="$5"
    run=$((run + 1))
    local out status
    out="$(classify "$title" "$labels")"; status=$?
    if [ "$status" != "$want" ]; then
      bad "$name — wanted exit $want, got $status: $out"; return
    fi
    if ! printf '%s' "$out" | grep -qF -- "$want_text"; then
      bad "$name — exit $status is right but the message never says \"$want_text\": $out"; return
    fi
    ok "$name — $out"
  }

  echo "verify-labels selftest"
  echo

  # The three prefixes that license a label.
  case_is 0 "agree"       "fix carries bug"            "fix: a thing is wrong"        "bug"
  case_is 0 "agree"       "feat carries enhancement"   "feat: a new thing"            "enhancement"
  case_is 0 "agree"       "docs carries documentation" "docs: write it down"          "documentation"

  # #84's own case: every `fix:` in the repo was unlabelled.
  case_is 1 "missing"     "fix carries nothing"        "fix: a thing is wrong"        ""

  # The failure that is worse than no label at all.
  case_is 1 "contradicts" "fix wearing enhancement"    "fix: a thing is wrong"        "enhancement"
  case_is 1 "contradicts" "docs wearing bug"           "docs: write it down"          "bug"

  # Licensing nothing is a verdict, checked as strictly as licensing something.
  case_is 0 "no type label" "scope carries nothing"    "scope: decide the shape"      ""
  case_is 0 "no type label" "chore carries nothing"    "chore: tidy the tree"         ""
  case_is 0 "no type label" "test carries nothing"     "test: nothing verifies X"     ""
  case_is 1 "contradicts"   "chore wearing enhancement" "chore: tidy the tree"        "enhancement"
  case_is 1 "contradicts"   "test wearing bug"          "test: nothing verifies X"    "bug"

  # Containers. They are labelled precisely so a sweep of work can exclude them.
  case_is 0 "agree"       "arc carries arc"             "arc: 04 dogfood — the first" "arc"
  case_is 0 "agree"       "workstream carries it"       "workstream: Fire — make it"  "workstream"
  case_is 1 "contradicts" "workstream wearing arc"      "workstream: Fire — make it"  "arc"

  # Non-type labels say something the title does not, so nothing here judges them.
  case_is 0 "agree"       "priority rides along"        "fix: a thing is wrong"       "bug,priority: high"
  case_is 0 "agree"       "in-progress rides along"     "feat: a new thing"           "in-progress,enhancement"
  case_is 0 "no type label" "area label on a chore"     "chore: tidy the tree"        "issue-discipline"

  # `spec:` was retired in favour of `scope:` — one word per meaning. An unmapped prefix is
  # reported rather than passed over, which is what makes the retirement enforceable.
  case_is 1 "is not a type" "spec is retired"           "spec: define the shape"      ""
  case_is 1 "is not a type" "an invented prefix"        "wip: half a thing"           ""
  case_is 1 "no type prefix" "no prefix at all"         "Add the thing"               ""

  # A substring must not match a label name. `debug` is not `bug`.
  case_is 1 "missing"     "debug is not bug"            "fix: a thing is wrong"       "debug"

  # Order in the label list must not decide the verdict.
  case_is 0 "agree"       "type label last"             "fix: a thing is wrong"       "issue-discipline,bug"

  # ---- the parse, which is where the defect actually was ------------------------
  # `classify` was right and the sweep was wrong: rows arrived tab-separated, bash collapsed
  # the empty label field, and every UNLABELLED issue reported "no type prefix" against an
  # empty title. Twenty false findings in one run. A selftest that stopped at `classify`
  # passed the whole time, so the parse gets its own cases.
  row() { printf '%s%s%s%s%s\n' "$1" "$US" "$2" "$US" "$3"; }

  stream_is() {
    local want="$1" want_text="$2" name="$3" rows="$4"
    run=$((run + 1))
    local out status
    out="$(printf '%s\n' "$rows" | sweep_stream)"; status=$?
    if [ "$status" != "$want" ]; then
      bad "$name — wanted exit $want, got $status: $out"; return
    fi
    if ! printf '%s' "$out" | grep -qF -- "$want_text"; then
      bad "$name — exit $status is right but the output never says \"$want_text\": $out"; return
    fi
    ok "$name"
  }

  stream_is 0 "1 open issues, all agree" "a labelled row parses" \
    "$(row 42 "bug" "fix: a thing is wrong")"

  # THE CASE THAT WAS THE BUG. An empty middle field must stay empty and the title must stay
  # in the third position.
  stream_is 1 "missing — \`fix:\` licenses \`bug\`" "an unlabelled row keeps its title" \
    "$(row 42 "" "fix: a thing is wrong")"

  # The reported title is the issue's, not an empty string — the tell that the fields shifted.
  stream_is 1 "fix: a thing is wrong" "the failing row names its title" \
    "$(row 42 "" "fix: a thing is wrong")"

  # A title containing the separator's near-neighbours must not split. A tab inside a title is
  # unlikely; a comma and a colon are not.
  stream_is 0 "all agree" "commas and colons in a title" \
    "$(row 42 "bug" "fix: a thing, and another thing: really")"

  stream_is 1 "2 open issues, 1 disagree" "several rows, one bad" \
    "$(row 42 "bug" "fix: right")
$(row 43 "" "feat: wrong")"

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
  labels)    [ "$#" -eq 1 ] || { usage; exit 2; }; label_set ;;
  '')        sweep ;;
  -h|--help) usage; exit 0 ;;
  *)         usage; exit 2 ;;
esac
