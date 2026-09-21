#!/usr/bin/env bash
# verify-public-audit.sh — the public audit says the same thing in all four of its sections.
#
#   tests/verify-public-audit.sh            check this repository's audit
#   tests/verify-public-audit.sh selftest   run the fixture cases
#
#   ARC_PRIVATE_DIR=DIR   where the audit lives once it has left this repository (#320). Unset and
#                         the audit absent, the live check reports SKIP and exits 0.
#
# WHY. `docs/arc-work/04-dogfood/public-audit.md` is #134's deliverable: a row per hit, each with
# a disposition, a summary table that counts them by file, a rules table that explains them, and
# a header claim about the total. A second run applies the dispositions, and a human edits the
# rows he disagrees with before it does. Both are edits to a 600-row document holding four
# internally-agreeing views of the same data — exactly the shape that drifts: a row retyped as
# `delete`, a summary count left at the old number, a rule id nobody defined.
#
# THE SWEEP IS NOT RUN HERE. `tools/audit-public.sh` greps every tracked file for nine classes and
# takes about seventy seconds — too slow for a gate that runs on every unit, and its answer moves
# with every commit anyway. So this checks the document against ITSELF, and
# `tests/verify-all.sh --list` records that the live sweep is the pre-publication step. Run
# `bash tools/audit-public.sh` before publishing; run this on every change to the document.
#
# WHY `delete` IS NAMED SEPARATELY. The disposition set is ship, anonymise, move and ask, and the
# issue says default to `anonymise`, never `delete`. A gate that only checked set membership would
# report a `delete` as "not a disposition"; naming it means the error says which rule was broken.
#
# EVERY PIPE IN THE AWK BELOW IS `[|]`, NEVER `\|`. The document is Markdown tables, so every
# pattern here has to match a pipe — and in awk `\|` is an undefined escape that gawk downgrades
# to plain `|`, which is alternation. Written that way the row pattern matches almost any line and
# the field extractions return fragments of the wrong cell. Measured, not guessed: the first
# version of this gate reported a mangled filename for
# `docs/product-architecture/archive/product-plan.md:129`.
#
# REPORTS, NEVER BLOCKS. Exit 1 names the section and the row. Same precedent as every verifier
# here.

set -u

SELF="$(cd "$(dirname "$0")" && pwd)/$(basename "$0")"
AUDIT="docs/arc-work/04-dogfood/public-audit.md"

report() {  # report <root>
  root="$1"
  echo "verify-public-audit — the audit's four views agree"
  echo

  if [ ! -f "$root/$AUDIT" ]; then
    echo "  FAIL  $AUDIT does not exist"
    return 1
  fi

  awk -v audit="$AUDIT" '
    # ---- section 4 rows:  | `class` | `path:line` | text | **disposition** Rnn |
    #
    # FIELDS COME OUT BY `split` AND `match`, NEVER BY A `sub` ENDING IN `.*$`. A row quoting a
    # Markdown table quotes its emoji too, and on
    # `docs/product-architecture/archive/product-plan.md:129` gawk reports `~` as matching while
    # the identical `sub` replaces nothing. Measured here, on that row.
    /^[|] `[a-z-]+` [|] `[^`]+:[0-9]+` [|]/ {
      nrow++
      line = $0

      # The location is the fourth backtick-delimited field, whatever the text cell holds.
      nb = split(line, tick, "`")
      loc = tick[4]
      sub(/:[0-9]+$/, "", loc)
      rowfile[loc]++

      if (match(line, /[|] \*\*[a-z]+\*\* R[0-9]+ [|]$/)) {
        split(substr(line, RSTART, RLENGTH), last, " ")
        d = last[2]; gsub(/\*/, "", d)
        r = last[3]
        used[r] = 1
        if (d == "delete") {
          bad[++nbad] = "line " NR ": disposition `delete` — the issue says default to anonymise, never delete"
        } else if (d != "ship" && d != "anonymise" && d != "move" && d != "ask") {
          bad[++nbad] = "line " NR ": `" d "` is not one of ship, anonymise, move, ask"
        }
        if (d == "ask") nask++
      } else {
        bad[++nbad] = "line " NR ": no `**disposition** Rnn` in the last cell"
      }
      next
    }

    # ---- section 3 summary:  | `path` | N | ship 3 · anonymise 2 |
    /^[|] `[^`]+` [|] [0-9]+ [|] [a-z]/ {
      split($0, tick, "`")
      split($0, bar, "|")
      sumfile[tick[2]] = bar[3] + 0
      nsum++
      next
    }

    # ---- section 2 rules:  | **R1** | ... |
    /^[|] \*\*R[0-9]+\*\* [|]/ {
      r = $0; sub(/^[|] \*\*/, "", r); sub(/\*\*.*$/, "", r)
      defined[r] = 1
      next
    }

    # ---- the header claim: "... and 473 need a decision"
    /need a decision/ && claim_rows == 0 {
      c = $0; sub(/^.*links and /, "", c); sub(/ need a decision.*$/, "", c)
      gsub(/[,*]/, "", c)
      claim_rows = c + 0
      next
    }

    # ---- section 5: the sentence telling the reader how many rows are his
    /`ask` rows, in/ { seen_ask_claim = 1; next }

    END {
      fails = 0

      # 1 — the header claim against the rows actually present. The number in the opening
      #     sentence is the first thing read and the last thing updated.
      if (claim_rows == 0) {
        print "  FAIL  the header does not state how many rows need a decision"; fails++
      } else if (claim_rows != nrow) {
        printf "  FAIL  the header claims %d rows; section 4 holds %d\n", claim_rows, nrow; fails++
      } else {
        printf "  PASS  the header claim matches section 4 — %d rows\n", nrow
      }

      # 2 — every disposition is legal.
      if (nbad > 0) {
        printf "  FAIL  %d row(s) with an unusable disposition\n", nbad
        for (i = 1; i <= nbad; i++) print "        " bad[i]
        fails++
      } else {
        print "  PASS  every row carries one of ship, anonymise, move, ask"
      }

      # 3 — every rule a row cites exists in the rules table. An invented rule id is what an
      #     edited row looks like when someone supplies a reason instead of adding one.
      undef = ""
      for (r in used) if (!(r in defined)) undef = undef " " r
      if (undef != "") {
        print "  FAIL  section 4 cites a rule section 2 does not define:" undef; fails++
      } else {
        print "  PASS  every rule cited by a row is defined in section 2"
      }

      # 4 — the summary and the rows cover the same files with the same counts. This is what
      #     catches an applied disposition removing rows and leaving the summary stale.
      missing = ""; extra = ""; wrong = ""
      for (f in rowfile) if (!(f in sumfile)) missing = missing "\n        " f
      for (f in sumfile) if (!(f in rowfile)) extra   = extra   "\n        " f
      for (f in rowfile) if ((f in sumfile) && sumfile[f] != rowfile[f])
        wrong = wrong sprintf("\n        %s — section 3 says %d, section 4 holds %d", f, sumfile[f], rowfile[f])
      if (missing != "") { print "  FAIL  a file has rows in section 4 and no line in section 3:" missing; fails++ }
      if (extra   != "") { print "  FAIL  a file has a line in section 3 and no row in section 4:" extra; fails++ }
      if (wrong   != "") { print "  FAIL  section 3 and section 4 disagree on a count:" wrong; fails++ }
      if (missing == "" && extra == "" && wrong == "")
        printf "  PASS  section 3 and section 4 agree on all %d files\n", nsum

      # 5 — section 5 has to say how many rows need the user. Without it the audit is a list with
      #     no call to action, which is how an inventory stops being read.
      if (!seen_ask_claim) {
        print "  FAIL  section 5 does not state how many `ask` rows there are"; fails++
      } else {
        printf "  PASS  section 5 states the ask count — section 4 holds %d ask row(s)\n", nask
      }

      print ""
      if (fails == 0) { printf "%s — %d rows, %d files, all views agree\n", audit, nrow, nsum; exit 0 }
      printf "%d check(s) failed\n", fails
      exit 1
    }
  ' "$root/$AUDIT"
}

# ---- the self-test --------------------------------------------------------------------------
# Fixture documents under mktemp, never the real audit. The real one passes, which is why it
# cannot show any of these checks failing.
if [ "${1:-}" = "selftest" ]; then
  passed=0; failed=0
  WORK="$(mktemp -d)"; trap 'rm -rf "$WORK"' EXIT

  make_audit() {  # make_audit <name> — a miniature audit that passes
    root="$WORK/$1"
    mkdir -p "$root/docs/arc-work/04-dogfood"
    cat > "$root/$AUDIT" <<'DOC'
# Public audit

**4 hits**, of which 1 are this repository's own tracker links and 3 need a decision.

## 2 The disposition rules

| Rule | Path | Class | Disposition | Why |
| :--- | :--- | :--- | :--- | :--- |
| **R1** | `docs/x/` | any | `move` | a reason |
| **R17** | any | `product` | `anonymise` | a reason |

## 3 Summary by file

| File | Hits | Dispositions |
| :--- | ---: | :--- |
| `docs/x/a.md` | 2 | move 2 |
| `docs/y/b.md` | 1 | anonymise 1 |

## 4 Every hit

| Class | Location | Text | Disposition |
| :--- | :--- | :--- | :--- |
| `product` | `docs/x/a.md:1` | some text | **move** R1 |
| `client` | `docs/x/a.md:9` | more text | **move** R1 |
| `product` | `docs/y/b.md:4` | other text | **anonymise** R17 |

## 5 What you tick

**Three `ask` rows, in one group.**
DOC
    printf '%s' "$root"
  }

  case_is() {
    name="$1"; want_status="$2"; want_text="$3"; got_status="$4"; got="$5"
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

  run() { TERM=dumb bash "$SELF" --root "$1" 2>&1; }

  echo "verify-public-audit selftest — fixture documents, never the real audit"
  echo

  # 1 — a consistent audit passes.
  root=$(make_audit clean)
  out=$(run "$root"); status=$?
  case_is "a consistent audit passes" 0 "all views agree" "$status" "$out"

  # 2 — the missing document. The gate's own precondition, and the state the repository was in
  #     before #134.
  root="$WORK/absent"; mkdir -p "$root"
  out=$(run "$root"); status=$?
  case_is "a missing audit fails" 1 "does not exist" "$status" "$out"

  # 3 — `delete` is named, not merely rejected. The issue's rule is "never delete", so the error
  #     has to say that rather than "not in the set".
  root=$(make_audit deleted)
  sed -i 's/\*\*anonymise\*\* R17/**delete** R17/' "$root/$AUDIT"
  out=$(run "$root"); status=$?
  case_is "a delete disposition fails, and says why" 1 "never delete" "$status" "$out"

  # 4 — any other word is out of the set.
  root=$(make_audit bogus)
  sed -i 's/\*\*anonymise\*\* R17/**redact** R17/' "$root/$AUDIT"
  out=$(run "$root"); status=$?
  case_is "a word outside the set fails" 1 "is not one of ship, anonymise, move, ask" "$status" "$out"

  # 5 — a rule id no rules table defines.
  root=$(make_audit undefined)
  sed -i 's/\*\*move\*\* R1 /**move** R42 /' "$root/$AUDIT"
  out=$(run "$root"); status=$?
  case_is "a rule the rules table does not define fails" 1 "does not define: R42" "$status" "$out"

  # 6 to 8 — the three ways the summary and the rows can drift. The second run applies
  #          dispositions and removes rows; each of these is what it leaves if it forgets one.
  root=$(make_audit sumcount)
  sed -i 's#^| `docs/x/a.md` | 2 |#| `docs/x/a.md` | 5 |#' "$root/$AUDIT"
  out=$(run "$root"); status=$?
  case_is "a summary count that disagrees with the rows fails" 1 "section 3 says 5, section 4 holds 2" "$status" "$out"

  root=$(make_audit sumextra)
  printf '| `docs/z/c.md` | 1 | ship 1 |\n' >> "$root/$AUDIT"
  out=$(run "$root"); status=$?
  case_is "a summary line with no rows fails" 1 "no row in section 4" "$status" "$out"

  root=$(make_audit summissing)
  sed -i '/anonymise 1 |$/d' "$root/$AUDIT"
  out=$(run "$root"); status=$?
  case_is "rows with no summary line fail" 1 "no line in section 3" "$status" "$out"

  # 9 — the header claim.
  root=$(make_audit header)
  sed -i 's/and 3 need a decision/and 300 need a decision/' "$root/$AUDIT"
  out=$(run "$root"); status=$?
  case_is "a stale header count fails" 1 "claims 300 rows; section 4 holds 3" "$status" "$out"

  # 10 — section 5 has to tell the reader how many rows are his.
  root=$(make_audit noask)
  sed -i '/`ask` rows, in/d' "$root/$AUDIT"
  out=$(run "$root"); status=$?
  case_is "a section 5 with no ask count fails" 1 "does not state how many" "$status" "$out"

  # 11 — a path containing spaces. The audit holds a real one — a client document filed under
  #      its own title — and a naive field split drops it from the coverage check.
  root=$(make_audit spaces)
  sed -i 's#docs/y/b.md#docs/y/a file.md#g' "$root/$AUDIT"
  out=$(run "$root"); status=$?
  case_is "a path with spaces is matched in both sections" 0 "all views agree" "$status" "$out"

  # 12 — a row whose last cell lost its disposition. It still reads as a normal table row, so
  #      without this case an edited row that dropped a column would be counted as fine.
  root=$(make_audit nodisp)
  sed -i 's/| \*\*anonymise\*\* R17 |/| |/' "$root/$AUDIT"
  out=$(run "$root"); status=$?
  case_is "a row with no disposition fails" 1 "no \`**disposition** Rnn\`" "$status" "$out"

  # 13 — a row whose TEXT cell quotes a `path:line` of its own, and holds escaped pipes. This is
  #      the real shape that broke the first version of this gate: the location has to be read
  #      from the second cell, never from the first thing in the line that looks like one.
  root=$(make_audit nested)
  cat >> "$root/$AUDIT" <<'ROW'
| `product` | `docs/x/a.md:129` | \| **Source** \| see `docs/other/z.md:7` \| \| | **move** R1 |
ROW
  sed -i 's#^| `docs/x/a.md` | 2 |#| `docs/x/a.md` | 3 |#' "$root/$AUDIT"
  sed -i 's/and 3 need a decision/and 4 need a decision/' "$root/$AUDIT"
  out=$(run "$root"); status=$?
  case_is "a nested path and escaped pipes in the text cell parse" 0 "all views agree" "$status" "$out"

  echo
  echo "$passed passed, $failed failed"
  [ "$failed" = "0" ] || exit 1
  exit 0
fi

# `--root` exists for the selftest. The live invocation takes no arguments.
if [ "${1:-}" = "--root" ]; then
  report "${2:-.}"
  exit $?
fi

ROOT="$(cd "$(dirname "$0")/.." && pwd)"

# #320: the audit quotes every hit verbatim, so it left the repository with the rest of the
# private corpus. Absent here is the published state, not a defect — which is why this is decided
# at the live invocation and `report` still fails a root that was named and holds no audit.
# ARC_PRIVATE_DIR says where the private copy is; without it nothing is checked, and saying so
# plainly is the point: a silent pass would read as "the audit agrees with itself".
if [ ! -f "$ROOT/$AUDIT" ]; then
  if [ -n "${ARC_PRIVATE_DIR:-}" ]; then
    report "$ARC_PRIVATE_DIR"
    exit $?
  fi
  echo "verify-public-audit — SKIP  $AUDIT is not in this repository; it is private corpus."
  echo "                      Set ARC_PRIVATE_DIR to the directory that holds it to check it."
  exit 0
fi

report "$ROOT"
exit $?
