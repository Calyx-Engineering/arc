#!/usr/bin/env bash
# verify-report-budget.sh — a workstream boundary report fits its 200-word budget.
#
#   tools/verify-report-budget.sh            check every boundary report in docs/arc-log/
#   tools/verify-report-budget.sh selftest   run the fixture cases
#   tools/verify-report-budget.sh --root D   check another tree
#   tools/verify-report-budget.sh --count F  print each report's count in one file
#
# WHY. The budget is stated in three documents — docs/arc-work/04-dogfood/run-instructions.md
# §6.2, the arc-log's execution section, and execution-process.md — and nothing read any of them.
# A fourth statement sits in the plan, which is the human's forest view and not an execution
# input. Loop's first boundary report was 302 words against 200, and the user caught it. #185.
# That is the arc's own subject in miniature: a rule written down three times, loaded, and not
# fired.
#
# WHAT IT COUNTS, so the number is reproducible. Between a `### <n> <Workstream> — boundary
# report` heading and its `*End of ... boundary report.*` line, a word is a whitespace-separated
# token holding at least one letter or digit — after these are removed:
#
#   the diagram          a `####`-or-deeper section whose number ends in 7, or whose whole title
#                        is `What it changed`, from its heading to the next heading of that depth
#                        or shallower — and every fenced block anywhere.
#                        run-instructions.md §6.2 already says the diagram does not count; this
#                        agrees with that rule rather than reinterpreting it
#   section headings     `#### 6.2.1 Delivered` is the report's scaffolding, not its prose
#   the frame            the `**Workstream:** ...` metadata line and the `*End of ...*` line
#   ordered-list markers a leading `1.` at the start of a line, so a numbered list is not charged
#                        one word per item where a bulleted one is charged none. A bullet needs
#                        no rule — `-` holds no letter or digit
#   table pipes          `|`, and delimiter rows (`|---|---|`) entirely
#   link syntax          `[text](url)` counts as `text`; a bare URL counts as nothing
#   emphasis markers     `*`, `_`, backtick, `#`
#
# Separators carry no letter or digit, so `·`, `—` and `→` are not words. Against the three
# reports already written this returns 195, 186 and 194 where their own headers claim 199, 200 and
# 200. THE HEADERS ARE HAND COUNTS AND THIS IS NOT A CHECK ON THEM — a writer near the limit is
# several words out in either direction, and failing a report over that would be a finding about
# tokenisation. What the agreement shows is that the rule is the one those reports were written
# to; what binds is the number this prints.
#
# REPORTS, NEVER TRUNCATES. #185's constraint is explicit: a gate that silently cuts a report is
# worse than one that names it. This prints the count and the overage and exits 1. It edits
# nothing.
#
# WHAT IT CANNOT DO. It counts words. It does not check that a report has its seven sections, in
# order, or that its sections are lists where they should be lists — that is tools/report-grade.sh
# on a different corpus. It does not check a report's self-declared word count against the count
# it makes: the two differ by a token here and there, and failing a report over that would be a
# finding about tokenisation rather than about length.

set -u

SELF="$(cd "$(dirname "$0")" && pwd)/$(basename "$0")"

BUDGET=200
ARCLOG_REL=docs/arc-log
INSTRUCTIONS_REL=docs/arc-work/04-dogfood/run-instructions.md

# ---- the counter ---------------------------------------------------------------------------
# Two stages on purpose. Which lines survive is a decision about MARKDOWN STRUCTURE — a fence,
# a heading, a delimiter row — so it runs first, while `#` and `*` still mean what they mean.
# Only then are the survivors flattened into words, which destroys exactly those characters.

keep_lines() {  # stdin: a report region -> stdout: the lines that hold countable prose
  # SECTION 7 IS FOUND BY DEPTH, NOT BY ITS NUMBER ALONE. `### 6.7 Upkeep — boundary report` is a
  # REPORT heading whose own number ends in 7; a rule that only matched the digit latched on the
  # region's first line and scored every such workstream at zero words — a report that could never
  # fail. Sections are `####` and deeper, the report itself is `###`, so depth separates them.
  #
  # AND THE LATCH IS RELEASED at the next heading of the same depth or shallower. Section 7 is
  # last in a well-formed report and the release never fires; where the `*End of ...*` line is
  # missing the region runs on to the next report or to EOF, and a latch with no release would
  # make everything past the diagram free — the way past the budget this is meant to close.
  awk '
    function level(s,   n) { n = 0; while (substr(s, n + 1, 1) == "#") n++; return n }
    /^[[:space:]]*```/     { fence = !fence; next }
    fence                  { next }
    /^#/ {
      lv = level($0)
      if (sec7 && lv <= sec7lv) sec7 = 0
      # The 7 has to be the LAST component of the number: `6.7.1 Delivered` is section 1 of the
      # report numbered 6.7, and a trailing `[^0-9]` accepted the dot and read it as a diagram.
      # The title rule is for an unnumbered report and is anchored at both ends — as a substring
      # it latched on `#### 6.2.3 What it changed and why`, which is section 3.
      if (!sec7 && lv >= 4 && ($0 ~ /^#+[ \t]+([0-9]+\.)+7([^0-9.]|$)/ \
                            || $0 ~ /^#+[ \t]+([0-9.]+[ \t]+)?[Ww]hat it changed[ \t]*$/)) {
        sec7 = 1; sec7lv = lv
      }
      next
    }
    sec7                   { next }
    /^\*\*Workstream:\*\*/ { next }
    /^\*End of /           { next }
    /^\|[[:space:]]*:?-+/  { next }
    { print }
  '
}

to_words() {  # stdin: prose -> stdout: one word per line
  # An ordered list's `1.` carries a digit, so without the first rule a numbered list would be
  # charged one word per item and a bulleted list nothing — and §6.2 mandates numbered lists for
  # section 1 and bullets for 3 and 6. A bullet needs no rule: `-` and `+` hold no letter or
  # digit, so the final grep drops them already.
  #
  # TWO DIGITS, NOT ANY NUMBER. `2026. the year` opens with a number that is content, and an
  # unbounded marker rule ate it. A report's numbered list does not reach 100 items.
  # Line-anchored, so a numbered item written inside a table cell still pays for its marker.
  tr -d '\r' \
  | sed -e 's/^[[:space:]]*[0-9]\{1,2\}\.[[:space:]]\{1,\}/ /' \
        -e 's/\[\([^][]*\)\]([^)]*)/\1/g' \
        -e 's|https\?://[^ )]*||g' \
        -e 's/|/ /g' \
        -e 's/[*`_#]/ /g' \
  | tr -s ' \t' '\n\n' \
  | grep '[A-Za-z0-9]'
}

count_region() {  # stdin: a report region -> stdout: the word count
  local n
  n="$(keep_lines | to_words | grep -c '')" || n=0
  printf '%s' "$n"
}

# ---- finding the reports in a file -----------------------------------------------------------
# A report starts at its own heading and ends at its End-of line, or at the next report, or at
# the end of the file. The last two are not tidy shapes, and a report missing its End-of line is
# still counted rather than skipped — a malformed frame must not become a way past the budget.

report_starts() {  # report_starts <file> -> "lineno<TAB>title"
  # Fence-aware, like the counter. run-instructions.md §6.2 hands the writer the frame to copy
  # inside a ```markdown block, and a heading in an example is not a report.
  # THE DASH IS TAKEN IN ANY OF ITS THREE SHAPES. The frame writes an em dash; a heading typed
  # with a hyphen or an en dash used to match nothing, and a report nobody recognises is counted
  # nowhere and reported nowhere — silence, which is the way past the budget this closes.
  awk '
    /^[[:space:]]*```/ { fence = !fence; next }
    fence { next }
    /^#+[[:space:]]+.*(—|–|-)[[:space:]]*boundary report[[:space:]]*$/ {
      t = $0
      sub(/^#+[[:space:]]*/, "", t)
      sub(/[[:space:]]*(—|–|-)[[:space:]]*boundary report[[:space:]]*$/, "", t)
      print NR "\t" t
    }
  ' "$1" 2>/dev/null
}

report_end() {  # report_end <file> <start> <next-start-or-0> -> the last line of the region
  local f="$1" start="$2" next="$3" last e
  # Not `wc -l`, whose output is padded on the BSD userland and would be interpolated straight
  # into the sed range below.
  last="$(awk 'END{print NR}' "$f")"
  [ "$next" -gt 0 ] && last=$((next - 1))
  # Fence-aware, like report_starts. The frame §6.2 hands writers to copy carries its `*End of*`
  # line inside the same fenced example as its heading; skipping the heading and honouring the
  # End-of line would cut a real report short at someone else's example.
  e="$(sed -n "${start},${last}p" "$f" | awk '
        /^[[:space:]]*```/ { fence = !fence; next }
        fence { next }
        /^\*End of / { print NR; exit }
      ')"
  [ -n "$e" ] && last=$((start + e - 1))
  printf '%s' "$last"
}

# An unbalanced fence inside a region is malformed markdown, and it is the one shape that turns
# the diagram exclusion into a way past the budget: the fence never closes, every later line is
# swallowed, and the report counts near zero. Reported rather than counted — #185's constraint is
# that a gate names what it finds.
fences_balanced() {  # stdin: a report region
  local n
  n="$(grep -c '^[[:space:]]*```' || true)"
  [ $((n % 2)) = 0 ]
}

# ---- one file ---------------------------------------------------------------------------------
# 0  every report in it is inside budget            1  one or more is over
# 2  the file holds no boundary report at all       — "no report yet" is not a failure
#
# It calls `pass` and `fail`, which the live run and the selftest each define. The scan and the
# reporting shell around it are separated so a case can drive the scan without printing.
check_file() {  # check_file <file> [<label-prefix>]
  local f="$1" prefix="${2:-}" found=0 over=0
  local starts n_start n_next n_end title count

  starts="$(report_starts "$f")"
  [ -n "$starts" ] || return 2

  while IFS="$(printf '\t')" read -r n_start title; do
    [ -n "$n_start" ] || continue
    found=1
    n_next="$(printf '%s\n' "$starts" | awk -F'\t' -v s="$n_start" '$1 > s {print $1; exit}')"
    [ -n "$n_next" ] || n_next=0
    n_end="$(report_end "$f" "$n_start" "$n_next")"
    if ! sed -n "${n_start},${n_end}p" "$f" | fences_balanced; then
      fail "$prefix$title — a fenced block is not closed" \
           "everything after an unclosed fence is read as code and counted as nothing" \
           "$f lines $n_start-$n_end. Close the fence, then the count means something"
      over=1
      continue
    fi
    count="$(sed -n "${n_start},${n_end}p" "$f" | count_region)"
    if [ "$count" -gt "$BUDGET" ]; then
      fail "$prefix$title — $count words" \
           "the budget is $BUDGET; this is $((count - BUDGET)) over" \
           "$f lines $n_start-$n_end. Cut it — nothing here truncates a report" \
           "what is counted, and what is not, is in the header of verify-report-budget.sh"
      over=1
    else
      pass "$prefix$title — $count words, budget $BUDGET"
    fi
  done < <(printf '%s\n' "$starts")
  # A process substitution rather than a heredoc: an unquoted heredoc expands `$` and backticks,
  # and a report title is free text — `### 6.5 \`verify-all\` — boundary report` would be run.

  [ "$found" = "1" ] || return 2
  [ "$over" = "0" ] || return 1
  return 0
}

# ---- the live run ------------------------------------------------------------------------------
report() {
  local root="$1"
  local passed=0 failed=0

  pass() { echo "  PASS  $1"; passed=$((passed + 1)); }
  fail() { echo "  FAIL  $1"; shift; for l in "$@"; do echo "        $l"; done; failed=$((failed + 1)); }
  skip() { echo "  SKIP  $1"; shift; for l in "$@"; do echo "        $l"; done; }

  echo "verify-report-budget — every boundary report inside $BUDGET words"
  echo

  # ---- 1 · the reports themselves ------------------------------------------------------------
  local dir="$root/$ARCLOG_REL" any=0 f st
  if [ ! -d "$dir" ]; then
    skip "boundary reports are inside budget" "no $ARCLOG_REL directory in this tree"
  else
    for f in "$dir"/*.md; do
      [ -f "$f" ] || continue
      check_file "$f" "$(basename "$f"): "
      st=$?
      # `fail` has already counted each over-budget report; st is only asked whether the file
      # held a report at all.
      [ "$st" = 2 ] || any=1
    done
    if [ "$any" = "0" ]; then
      # No report yet is the ordinary state of an arc that has closed no workstream. A gate that
      # failed on it would fire on every arc-log the day it is created.
      skip "boundary reports are inside budget" "no boundary report in $ARCLOG_REL yet"
    fi
  fi

  # ---- 2 · and the rule the other half of #185 is about --------------------------------------
  # The same boundary produced two uncaught failures. The budget is the one with a number; this
  # is the one with a sentence, and a sentence with no check is how the first one got out.
  local ins="$root/$INSTRUCTIONS_REL"
  if [ ! -f "$ins" ]; then
    skip "the parent-closes rule is stated" "no $INSTRUCTIONS_REL in this tree"
  elif grep -qiE 'parent[^.]*closes when the user says so' "$ins"; then
    pass "run-instructions says a workstream parent closes when the user says so"
  else
    fail "run-instructions says a workstream parent closes when the user says so" \
         "#144 was closed the moment its children closed, which buried its report in a closed issue" \
         "looked for: parent ... closes when the user says so, in $INSTRUCTIONS_REL"
  fi

  echo
  echo "$passed passed, $failed failed"
  [ "$failed" = "0" ] || return 1
  return 0
}

# ---- the self-test -------------------------------------------------------------------------------
if [ "${1:-}" = "selftest" ]; then
  passed=0; failed=0
  WORK="$(mktemp -d 2>/dev/null || true)"
  if [ -z "$WORK" ] || [ ! -d "$WORK" ]; then
    # Said out loud, and with the summary line the runner greps for. An exit with no output makes
    # verify-all.sh print a FAIL with an empty body.
    echo "  FAIL  mktemp -d gave nothing to work in"
    echo
    echo "0 passed, 1 failed"
    exit 1
  fi
  trap 'rm -rf "$WORK"' EXIT

  ok()  { echo "  PASS  $1"; passed=$((passed + 1)); }
  bad() { echo "  FAIL  $1"; shift; for l in "$@"; do echo "        $l"; done; failed=$((failed + 1)); }

  words_of() { printf '%s\n' "$1" | count_region; }

  # A report of N prose words, built rather than typed, so a case says what it is testing.
  body_of() {  # body_of <n-words>
    local n="$1" i=0 out=""
    while [ "$i" -lt "$n" ]; do out="$out word"; i=$((i + 1)); done
    printf '%s' "$out"
  }
  report_of() {  # report_of <n-words> [diagram]
    printf '### 6.2 Loop — boundary report\n\n'
    printf '**Workstream:** Loop · **Closed:** 2026-09-07 · **%s words**, diagram excluded\n\n' "$1"
    printf '#### 6.2.1 Delivered\n\n'
    printf '%s\n\n' "$(body_of "$1")"
    if [ "${2:-}" = diagram ]; then
      printf '#### 6.2.7 What it changed\n\n'
      printf '```mermaid\nflowchart LR\n    A["one two three four five six seven eight"] --> B["nine ten eleven twelve"]\n```\n\n'
    fi
    printf '*End of Loop%ss boundary report.*\n' "'"
  }

  echo "verify-report-budget selftest — the counter, the scan, and the live tree"
  echo

  # 1 — the counter counts words. If this is wrong nothing below means anything.
  n=$(words_of "$(report_of 10)")
  if [ "$n" = 10 ]; then ok "ten words count as ten"; else bad "ten words count as ten" "got $n"; fi

  # 2 — the frame does not count. The metadata line alone is nine words; a counter that took it
  #     would spend 5% of every report's budget on its own header.
  n=$(words_of "$(report_of 0)")
  if [ "$n" = 0 ]; then ok "the heading, metadata line and End-of line are not words"
  else bad "the heading, metadata line and End-of line are not words" "got $n"; fi

  # 3 — THE DIAGRAM DOES NOT COUNT. #185's first constraint, and the one a naive counter breaks.
  a=$(words_of "$(report_of 10)"); b=$(words_of "$(report_of 10 diagram)")
  if [ "$a" = "$b" ]; then ok "a diagram changes nothing — 10 words with it and without"
  else bad "a diagram changes nothing" "without: $a, with: $b"; fi

  # 4 — table pipes are not words, and neither is the delimiter row. A table's HEADER row is,
  #     though: `Issue` and `Routed to` are three of this report's words, written by its author.
  #     Only the `|---|---|` scaffolding is free.
  tbl='### 6.2 X — boundary report

| Issue | | Routed to |
|---|---|---|
| one | two | three |

*End of X boundary report.*'
  n=$(words_of "$tbl")
  if [ "$n" = 6 ]; then ok "table pipes are not words; the header and body cells are"
  else bad "table pipes are not words; the header and body cells are" "wanted 6, got $n"; fi

  n2=$(words_of "$(printf '%s\n' "$tbl" | grep -v '^|---')")
  if [ "$n2" = "$n" ]; then ok "the delimiter row costs nothing"
  else bad "the delimiter row costs nothing" "with: $n, without: $n2"; fi

  # 5 — a link counts its text and not its URL. Reports are dense with issue links; counting the
  #     URLs would put every one of them over budget on syntax alone.
  n=$(words_of '### 6.2 X — boundary report

[#173](https://github.com/Calyx-Engineering/arc/issues/173) onboarding detects duplicated rules

*End of X boundary report.*')
  if [ "$n" = 5 ]; then ok "a link counts its text, never its URL"
  else bad "a link counts its text, never its URL" "wanted 5, got $n"; fi

  # 6 — separators are not words.
  n=$(words_of '### 6.2 X — boundary report

one · two — three → four

*End of X boundary report.*')
  if [ "$n" = 4 ]; then ok "the separators are not words"; else bad "the separators are not words" "wanted 4, got $n"; fi

  # 6b — a numbered list and a bulleted one of the same words cost the same. §6.2 makes section 1
  #      numbered and sections 3 and 6 bulleted, so a rule that charged `1.` would tax section 1.
  num=$(words_of '### 6.2 X — boundary report

1. alpha beta
2. gamma delta

*End of X boundary report.*')
  bul=$(words_of '### 6.2 X — boundary report

- alpha beta
- gamma delta

*End of X boundary report.*')
  # The bulleted half is the control, not a second rule under test: a bullet was never counted.
  if [ "$num" = 4 ] && [ "$bul" = 4 ]; then ok "an ordered-list marker costs what a bullet costs — nothing"
  else bad "an ordered-list marker costs what a bullet costs — nothing" "numbered: $num, bulleted: $bul, wanted 4 each"; fi

  # 6b(ii) — and a leading number that is CONTENT is not a marker.
  n=$(words_of '### 6.2 X — boundary report

2026. the year it happened

*End of X boundary report.*')
  if [ "$n" = 5 ]; then ok "a leading year is content, not a list marker"
  else bad "a leading year is content, not a list marker" "wanted 5, got $n"; fi

  # 6b(iii) — a section whose TITLE contains the diagram's words is not the diagram. As a
  #           substring test this latched on section 3 and made the rest of it free.
  n=$(words_of '### 6.2 X — boundary report

#### 6.2.3 What it changed and why

one two three

#### 6.2.4 Next

four five

*End of X boundary report.*')
  if [ "$n" = 5 ]; then ok "a section merely mentioning the diagram's title is counted"
  else bad "a section merely mentioning the diagram's title is counted" "wanted 5, got $n"; fi

  # 6c — A REPORT WHOSE OWN NUMBER ENDS IN 7. `### 6.7 Upkeep — boundary report` is a report
  #      heading, not a section 7. Matching the digit without the depth latched the diagram rule
  #      on the region's first line and scored every such workstream at zero — a report that
  #      could never fail. Arc 04 reaches 6.6; the next arc reaches this.
  n=$(words_of '### 6.7 Upkeep — boundary report

**Workstream:** Upkeep · **Closed:** 2026-09-08 · **4 words**, diagram excluded

#### 6.7.1 Delivered

one two three four

*End of Upkeep boundary report.*')
  if [ "$n" = 4 ]; then ok "a report numbered 6.7 is counted, not read as a diagram"
  else bad "a report numbered 6.7 is counted, not read as a diagram" "wanted 4, got $n"; fi

  # 6c(ii) — SECTION 7 IS EXCLUDED BY ITS HEADING, not only by its fence. Every other case here
  #          puts the diagram in a ```mermaid block, which the fence rule would exclude on its
  #          own — so without this case the whole section-7 rule could be deleted and the suite
  #          would stay green. Unfenced prose under the diagram's heading, and nowhere else.
  n=$(words_of '### 6.2 X — boundary report

#### 6.2.1 Delivered

one two three

#### 6.2.7 What it changed

a caption under the diagram heading, unfenced

*End of X boundary report.*')
  if [ "$n" = 3 ]; then ok "section 7 is excluded by its heading, fence or no fence"
  else bad "section 7 is excluded by its heading, fence or no fence" "wanted 3, got $n"; fi

  # 6d — section 7 ends at the next heading of its own depth or shallower. Without the release,
  #      a report missing its End-of line hands everything after the diagram to the next report,
  #      or to the end of the file, free.
  n=$(words_of '### 6.2 X — boundary report

#### 6.2.1 Delivered

one two

#### 6.2.7 What it changed

```mermaid
flowchart LR
    A["not counted"] --> B["nor this"]
```

## 7 Related analysis

three four five')
  if [ "$n" = 5 ]; then ok "the diagram exclusion ends at the next same-or-shallower heading"
  else bad "the diagram exclusion ends at the next same-or-shallower heading" "wanted 5, got $n"; fi

  # ---- the scan, against fixture trees ---------------------------------------------------------
  mk() {  # mk <name> — a tree with the instructions rule in place; the caller writes the arc-log
    local r="$WORK/$1"
    mkdir -p "$r/docs/arc-log" "$r/docs/arc-work/04-dogfood"
    printf 'A workstream parent closes when the user says so, not when its children do.\n' \
      > "$r/docs/arc-work/04-dogfood/run-instructions.md"
    printf '%s' "$r"
  }
  run() { TERM=dumb bash "$SELF" --root "$1" 2>&1; }

  # 7 — under budget passes.
  r=$(mk under); report_of 150 > "$r/docs/arc-log/arc-04.md"
  out=$(run "$r"); st=$?
  if [ "$st" = 0 ] && [[ "$out" == *"150 words"* ]]; then ok "a report under budget passes"
  else bad "a report under budget passes" "exit $st" "$out"; fi

  # 8 — OVER BUDGET FAILS, and 302 is the number that started this. Loop's first report.
  r=$(mk over); report_of 302 > "$r/docs/arc-log/arc-04.md"
  out=$(run "$r"); st=$?
  if [ "$st" = 1 ] && [[ "$out" == *"302 words"* ]] && [[ "$out" == *"102 over"* ]]; then
    ok "a 302-word report fails, and the output names the overage"
  else bad "a 302-word report fails, and the output names the overage" "exit $st" "$out"; fi

  # 9 — the boundary itself. 200 passes and 201 does not; a budget compared with >= would reject
  #     two of the three reports already written.
  r=$(mk exact); report_of 200 > "$r/docs/arc-log/arc-04.md"
  out=$(run "$r"); st=$?
  if [ "$st" = 0 ]; then ok "exactly 200 words passes"; else bad "exactly 200 words passes" "$out"; fi
  r=$(mk plusone); report_of 201 > "$r/docs/arc-log/arc-04.md"
  out=$(run "$r"); st=$?
  if [ "$st" = 1 ]; then ok "201 words fails"; else bad "201 words fails" "exit $st" "$out"; fi

  # 10 — A REPORT WITH A DIAGRAM, end to end: 190 words of prose and a diagram whose words would
  #      push it over. It passes, because run-instructions.md §6.2 says the diagram is excluded.
  r=$(mk diagram); report_of 190 diagram > "$r/docs/arc-log/arc-04.md"
  out=$(run "$r"); st=$?
  if [ "$st" = 0 ] && [[ "$out" == *"190 words"* ]]; then ok "a report with a diagram is scored on its prose"
  else bad "a report with a diagram is scored on its prose" "exit $st" "$out"; fi

  # 11 — NO REPORT YET is the ordinary state of an open arc, and is not a failure.
  r=$(mk none); printf '# arc 04\n\n## 6 Status\n\nNothing closed yet.\n' > "$r/docs/arc-log/arc-04.md"
  out=$(run "$r"); st=$?
  if [ "$st" = 0 ] && [[ "$out" == *"no boundary report"* ]]; then ok "no report yet passes, and says so"
  else bad "no report yet passes, and says so" "exit $st" "$out"; fi

  # 12 — two reports in one file, one of each. The bad one is named and the good one is not.
  r=$(mk both)
  { report_of 150; printf '\n---\n\n'; report_of 260 | sed 's/6\.2 Loop/6.3 Fire/'; } \
    > "$r/docs/arc-log/arc-04.md"
  out=$(run "$r"); st=$?
  # The assertion has to bind the verdict to the report. `*"PASS"*` alone is true of every run
  # here — the parent-closes check passes on each fixture — and would stay green if the
  # under-budget report started failing.
  if [ "$st" = 1 ] \
     && printf '%s\n' "$out" | grep -qE '^  PASS  .*Loop — 150 words' \
     && printf '%s\n' "$out" | grep -qE '^  FAIL  .*Fire — 260 words'; then
    ok "one over-budget report among two is the one named"
  else bad "one over-budget report among two is the one named" "exit $st" "$out"; fi

  # 13 — a report missing its End-of line is still counted. Otherwise deleting one line is a way
  #      past the budget.
  r=$(mk noend); report_of 260 | grep -v '^\*End of ' > "$r/docs/arc-log/arc-04.md"
  out=$(run "$r"); st=$?
  if [ "$st" = 1 ] && [[ "$out" == *"260 words"* ]]; then ok "a report with no End-of line is still counted"
  else bad "a report with no End-of line is still counted" "exit $st" "$out"; fi

  # 13a — AN UNCLOSED FENCE IS REPORTED, not counted. It is the one shape that turns the diagram
  #       exclusion into a way past the budget: everything after it reads as code and scores zero.
  r=$(mk unfenced)
  { printf '### 6.2 Loop — boundary report\n\n#### 6.2.1 Delivered\n\none two\n\n'
    printf '```mermaid\nflowchart LR\n\n'
    printf '%s\n\n*End of Loop boundary report.*\n' "$(body_of 400)"
  } > "$r/docs/arc-log/arc-04.md"
  out=$(run "$r"); st=$?
  if [ "$st" = 1 ] && [[ "$out" == *"fenced block is not closed"* ]]; then
    ok "an unclosed fence is named, not silently counted as nothing"
  else bad "an unclosed fence is named, not silently counted as nothing" "exit $st" "$out"; fi

  # 13b — and a report missing its End-of line does not get everything after its diagram free.
  #       The region then runs to the end of the file, which is where the trailing words are.
  r=$(mk noend2)
  { report_of 190 diagram | grep -v '^\*End of '
    printf '## 7 Related analysis\n\n%s\n' "$(body_of 20)"
  } > "$r/docs/arc-log/arc-04.md"
  out=$(run "$r"); st=$?
  if [ "$st" = 1 ] && [[ "$out" == *"210 words"* ]]; then
    ok "an unterminated report counts what follows its diagram"
  else bad "an unterminated report counts what follows its diagram" "exit $st" "$out"; fi

  # 13d — a heading typed with a hyphen instead of an em dash is still a report. It used to match
  #       nothing, and a report the scan does not recognise is never counted and never named.
  r=$(mk hyphen); report_of 260 | sed 's/6\.2 Loop — boundary/6.2 Loop - boundary/' \
    > "$r/docs/arc-log/arc-04.md"
  out=$(run "$r"); st=$?
  if [ "$st" = 1 ] && [[ "$out" == *"260 words"* ]]; then
    ok "a heading dashed with a hyphen is still a report"
  else bad "a heading dashed with a hyphen is still a report" "exit $st" "$out"; fi

  # 13c — THE FRAME IN AN EXAMPLE IS NOT A REPORT. run-instructions.md §6.2 hands the writer the
  #       block to copy inside a fence; scanning it would score the prose after it as a report.
  r=$(mk fenced)
  { printf '# arc 04\n\n## 6 Status\n\nNothing closed yet.\n\n'
    printf '```markdown\n'
    printf -- '---\n\n### <n> <Workstream> — boundary report\n\n**Workstream:** <name>\n\n'
    printf -- '*End of <Workstream>'"'"'s boundary report.*\n\n---\n'
    printf '```\n\n%s\n' "$(body_of 400)"
  } > "$r/docs/arc-log/arc-04.md"
  out=$(run "$r"); st=$?
  if [ "$st" = 0 ] && [[ "$out" == *"no boundary report"* ]]; then
    ok "the frame inside a fence is an example, not a report"
  else bad "the frame inside a fence is an example, not a report" "exit $st" "$out"; fi

  # 14 — the other half of #185: the parent-closes rule, missing.
  r=$(mk noparent); report_of 150 > "$r/docs/arc-log/arc-04.md"
  printf 'Leave the parent issue open.\n' > "$r/docs/arc-work/04-dogfood/run-instructions.md"
  out=$(run "$r"); st=$?
  if [ "$st" = 1 ] && [[ "$out" == *"closes when the user says so"* ]]; then
    ok "run-instructions without the parent-closes rule fails"
  else bad "run-instructions without the parent-closes rule fails" "exit $st" "$out"; fi

  # 15 — and this repository's own reports, which is what the live gate runs.
  ROOT="$(cd "$(dirname "$SELF")/.." && pwd)"
  out=$(run "$ROOT"); st=$?
  if [ "$st" = 0 ]; then ok "this repository's own boundary reports are inside budget"
  else bad "this repository's own boundary reports are inside budget" "$out"; fi

  echo
  echo "$passed passed, $failed failed"
  [ "$failed" = "0" ] || exit 1
  exit 0
fi

if [ "${1:-}" = "--count" ]; then
  pass() { echo "  $1"; }
  fail() { echo "  OVER  $1"; shift; for l in "$@"; do echo "        $l"; done; }
  check_file "${2:-}" ""
  exit $?
fi

if [ "${1:-}" = "--root" ]; then
  report "${2:-.}"
  exit $?
fi

report "$(cd "$(dirname "$0")/.." && pwd)"
exit $?
