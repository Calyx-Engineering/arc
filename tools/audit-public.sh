#!/usr/bin/env bash
# audit-public.sh — everything in this repository that a public copy would expose.
#
#   tools/audit-public.sh              the hit list, one row per hit
#   tools/audit-public.sh --summary    counts only: by class, then by file
#   tools/audit-public.sh --all        enumerate the bulk classes too
#   tools/audit-public.sh --markdown   the rows as a Markdown table, for the audit document
#   tools/audit-public.sh --root DIR   scan DIR instead of this repository
#   tools/audit-public.sh selftest     run the fixture cases
#
# WHY. Arc is private and installed from a local directory. Using it at another employer means
# publishing it, and the repository was built inside client work — it quotes real reports, names
# a real client's parts, and carries the user's own machine paths. #134 is the inventory; this is
# the instrument that produces it, so the sweep is repeatable after the fixes rather than a
# one-off read that goes stale the moment anything is edited.
#
# CLASSES ARE DISJOINT ONLY WHERE THAT IS TRUE. One line can expose two different things —
# `R:\work_lantern\roadz-sound-system` is a machine path AND a client name AND a product name —
# and each is a separate decision, so it produces a row per class. The one exception is
# `calyx-name`, tested against the line with the repository's own GitHub URLs removed: without
# that, every issue link in the repository reports as an organisation-name exposure.
#
# BULK CLASSES ARE COUNTED, NOT LISTED, unless --all. `calyx-url` is a thousand-odd links to this
# repository's own issues. Enumerating them buries the hits that need a human decision, and the
# decision on them is collective anyway: they are one row in the audit, not a thousand.
#
# EXCLUSIONS ARE MECHANICAL, AND THERE ARE THREE. This script, the audit document and the
# audit's gate all have to hold the terms in order to search for, record and check them.
# THEY ARE STILL EXPOSURE. The class table below is a dictionary of a real client's parts, and
# the audit document quotes every hit verbatim. All three are dispositioned by hand in the
# audit's section 2.1 — an exclusion is a limit on this instrument, never a decision that the
# file is safe.
#
# THE NAMED CLASSES CANNOT FIND A NAME NOBODY THOUGHT OF. `person`, `employer` and `client-hw`
# are literal lists, so each is exactly as complete as the last person to edit it. Review pass 1
# on #134 found `heliman` and the hyphenated `interface-pcba` by reading, not by running this;
# both are in the table now, and the next one will be found the same way.
#
# REPORTS, NEVER BLOCKS. Exit 0 when there are no hits, 1 when there are — the same precedent as
# every verifier here. Exit 1 is a list for a human to disposition, not a failure.

set -u

SELF="$(cd "$(dirname "$0")" && pwd)/$(basename "$0")"

# ---- the classes ------------------------------------------------------------------------
# id ~ bulk ~ ERE, matched case-insensitively ~ what it is. Tilde-separated: every regex here holds `|`.
#
# Held as a here-doc rather than an array so each line carries its own reason. A class added
# without a reason is a class nobody can review.
classes() {
  cat <<'CLASSES'
local-path~no~(^|[^A-Za-z0-9])[A-Za-z]:[\\/]~an absolute path on one machine
calyx-url~yes~github\.com/Calyx-Engineering~a link to this repository's own tracker
calyx-name~no~calyx~the author organisation's name, outside its own URLs
lantern~no~lantern~the client's parent company
roadz~no~roadz~the client's product
employer~no~dedrone~an employer named in the record
person~no~\b(chad|heliman)\b~a person other than the user
client-hw~no~\b(whelen|teltonika|quectel|skywire|airgain|bingfu|digikey|altium|rut241|yemn302q1a|nl-sw-lte[a-z0-9-]*|lcphoto|swa2100|np6bb|mso8204|bode_sweep|interface[ _-]pcba|interface-board|rad mode|ras rpi|cab tablet|lghts_nfault|ndusk_detect|roadz_pb_firmware|rp2040[a-z0-9_-]*|speaker-power|pin-allocation|gain-sweep|inductance-sweep|bom-analysis|dimmer-flasher)\b~a real client's hardware
profanity~no~\b(fuck[a-z]*|motherfuck[a-z]*|shit[a-z]*|bullshit|crap|damn(ed)?|goddamn|arse|arsehole|asshole|bastard|bugger|wank[a-z]*|twat|pissed|cunt|wtf|freaking|frigging)\b~an expletive
CLASSES
}

BULK_IDS="$(classes | awk -F'~' '$2=="yes" {printf "%s ", $1}')"

# ---- the scan ---------------------------------------------------------------------------
# Tracked files only. An untracked file is not published by publishing the repository, and
# `git ls-files` is also what keeps the scan off .git/ and off build residue.
scan() {  # scan <root> — prints "class|file|line|text" per hit, sorted
  root="$1"
  ( cd "$root" 2>/dev/null || return 0
    files="$(git ls-files 2>/dev/null)"
    [ -n "$files" ] || files="$(find . -type f 2>/dev/null | sed 's|^\./||')"

    printf '%s\n' "$files" \
      | grep -v '^tools/audit-public\.sh$' \
      | grep -v '^tests/verify-public-audit\.sh$' \
      | grep -v '^docs/arc-work/04-dogfood/public-audit\.md$' \
      > "$TMP/files"

    classes | while IFS='~' read -r id bulk re why; do
      [ -n "$id" ] || continue
      if [ "$id" = "calyx-name" ]; then
        # The organisation's name minus its own URLs. Every issue link in the repository
        # carries `Calyx-Engineering`; those are the calyx-url class, decided once.
        xargs -a "$TMP/files" -d '\n' grep -nHiE -- "$re" 2>/dev/null \
          | sed -E 's#https?://github\.com/Calyx-Engineering[^ )"`,]*##g; s#Calyx-Engineering/[A-Za-z0-9_.-]+##g' \
          | grep -iE -- "$re" \
          | sed -E "s/^([^:]*):([0-9]+):/${id}|\\1|\\2|/"
      else
        xargs -a "$TMP/files" -d '\n' grep -nHiE -- "$re" 2>/dev/null \
          | sed -E "s/^([^:]*):([0-9]+):/${id}|\\1|\\2|/"
      fi
    done | sort -t'|' -k1,1 -k2,2 -k3,3n
  )
}

markdown() {  # markdown <root> — the non-bulk rows as a Markdown table
  # The disposition column is deliberately empty. This script is an instrument: which hit is
  # shipped, anonymised, moved or asked about is a human decision, and encoding it here would
  # make a regeneration silently overwrite one. The audit document fills the column from its
  # own rules table.
  scan "$1" > "$TMP/md"
  echo '| Class | Location | Text | Disposition |'
  echo '| :--- | :--- | :--- | :--- |'
  while IFS='|' read -r id file line text; do
    case " $BULK_IDS " in *" $id "*) continue ;; esac
    # A pipe inside the text closes the cell; a backtick run breaks the code span. Escape the
    # first, collapse the second — the file and line are the authority on the exact bytes.
    cell="$(printf '%s' "$text" | tr -s ' \t' '  ' | sed 's/^ *//; s/|/\\|/g; s/`//g' | cut -c1-160)"
    printf '| `%s` | `%s:%s` | %s | |\n' "$id" "$file" "$line" "$cell"
  done < "$TMP/md"
}

report() {  # report <root> <mode: list|summary|all>
  root="$1"; mode="$2"
  hits="$(scan "$root")"

  echo "audit-public — what a public copy of this repository would expose"
  echo

  if [ -z "$hits" ]; then
    echo "  CLEAN  no hit in any class"
    return 0
  fi

  total="$(printf '%s\n' "$hits" | wc -l | tr -d ' ')"

  # ---- by class -------------------------------------------------------------------------
  echo "  by class"
  printf '%s\n' "$hits" > "$TMP/hits"
  classes | while IFS='~' read -r id bulk re why; do
    [ -n "$id" ] || continue
    n="$(grep -c "^$id|" "$TMP/hits")" || n=0
    [ "$n" = "0" ] && continue
    tag="  "
    [ "$bulk" = "yes" ] && tag="* "
    printf '    %s%-11s %5s   %s\n' "$tag" "$id" "$n" "$why"
  done
  echo "    * counted, not listed — pass --all to enumerate"
  echo

  # ---- by file --------------------------------------------------------------------------
  echo "  by file"
  awk -F'|' '{print $2}' "$TMP/hits" | sort | uniq -c | sort -rn -k1,1 \
    | awk '{ n = $1; sub(/^ *[0-9]+ +/, ""); printf "    %5s   %s\n", n, $0 }'
  echo

  if [ "$mode" = "summary" ]; then
    echo "  $total hit(s)"
    return 1
  fi

  # ---- the rows -------------------------------------------------------------------------
  echo "  hits"
  while IFS='|' read -r id file line text; do
    if [ "$mode" != "all" ]; then
      case " $BULK_IDS " in *" $id "*) continue ;; esac
    fi
    # Collapse whitespace and clip: a hit is a locator, and the file is the authority on
    # what the line says.
    printf '    %-11s %s:%s  %s\n' "$id" "$file" "$line" \
      "$(printf '%s' "$text" | tr -s ' \t' '  ' | cut -c1-140)"
  done < "$TMP/hits"
  echo
  echo "  $total hit(s)"
  return 1
}

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

# ---- the self-test ------------------------------------------------------------------------
# Fixture trees under mktemp, never this repository's own. A live run cannot show a class can
# stay silent, because the live tree hits nearly all of them.
if [ "${1:-}" = "selftest" ]; then
  passed=0; failed=0
  WORK="$(mktemp -d)"
  trap 'rm -rf "$TMP" "$WORK"' EXIT

  make_tree() {  # make_tree <name> — a clean miniature repository
    root="$WORK/$1"
    mkdir -p "$root/docs" "$root/skills"
    printf 'A plugin for engineering delivery.\n' > "$root/README.md"
    printf 'Nothing sensitive here.\n' > "$root/docs/notes.md"
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

  case_not() {  # case_not <name> <text that must be absent> <output>
    if [[ "$3" == *"$2"* ]]; then
      echo "  FAIL  $1"; failed=$((failed + 1))
    else
      echo "  PASS  $1"; passed=$((passed + 1))
    fi
  }

  run()     { TERM=dumb bash "$SELF" --root "$1" 2>&1; }
  run_all() { TERM=dumb bash "$SELF" --root "$1" --all 2>&1; }
  run_sum() { TERM=dumb bash "$SELF" --root "$1" --summary 2>&1; }

  echo "audit-public selftest — fixture trees, never the live tree"
  echo

  # 1 — a clean tree is clean. Without this the script could report a hit on everything.
  root=$(make_tree clean)
  out=$(run "$root"); status=$?
  case_is "a clean tree reports no hit" 0 "no hit in any class" "$status" "$out"

  # 2 to 8 — one case per non-bulk class, because a class that never matches is a class that
  #          silently covers nothing.
  root=$(make_tree lantern)
  printf 'built during the Lantern work\n' > "$root/docs/notes.md"
  out=$(run "$root"); status=$?
  case_is "the client's parent company is a hit" 1 "lantern     docs/notes.md:1" "$status" "$out"

  root=$(make_tree roadz)
  printf 'the ROADZ speaker system\n' > "$root/docs/notes.md"
  out=$(run "$root"); status=$?
  case_is "the client's product is a hit" 1 "roadz       docs/notes.md:1" "$status" "$out"

  root=$(make_tree path)
  printf 'copied from R:\\work_x\\thing\n' > "$root/docs/notes.md"
  out=$(run "$root"); status=$?
  case_is "an absolute machine path is a hit" 1 "local-path  docs/notes.md:1" "$status" "$out"

  # 4b — and a URL scheme is not one. `http://` ends in `p:/`, so a naive drive-letter pattern
  #      reports every link in the repository as a machine path.
  root=$(make_tree scheme)
  printf 'see https://example.com/a and http://example.com/b\n' > "$root/docs/notes.md"
  out=$(run "$root"); status=$?
  case_is "a URL scheme is not a machine path" 0 "no hit in any class" "$status" "$out"

  root=$(make_tree person)
  printf 'Request review from Chad.\n' > "$root/docs/notes.md"
  out=$(run "$root"); status=$?
  case_is "a person other than the user is a hit" 1 "person      docs/notes.md:1" "$status" "$out"

  root=$(make_tree employer)
  printf 'Dedrone uses Atlassian.\n' > "$root/docs/notes.md"
  out=$(run "$root"); status=$?
  case_is "an employer is a hit" 1 "employer    docs/notes.md:1" "$status" "$out"

  root=$(make_tree hw)
  printf 'the Whelen LCPHOTO on the Interface PCBA\n' > "$root/docs/notes.md"
  out=$(run "$root"); status=$?
  case_is "a real client part is a hit" 1 "client-hw   docs/notes.md:1" "$status" "$out"

  # 7b — the same board written the way the repository actually writes it. `interface pcba` with
  #      a space is the report's prose; `interface-pcba/rev_b` is the branch, the wiki page and
  #      the milestone, and it is the form that appears most. Review pass 1 on #134 found more
  #      53 lines holding the board name, 39 of them invisible to the space-only pattern.
  #
  #      ONE TERM PER FIXTURE FILE. Review pass 2 found the first version of this case putting
  #      three new alternatives on one line, so reverting any one of them left the case green.
  root=$(make_tree hyphenated)
  printf 'the integration branch is interface-pcba/rev_b\n' > "$root/docs/board.md"
  printf 'see rp2040-pin-allocation.md\n'                   > "$root/docs/mcu.md"
  printf 'the speaker-power wiki page\n'                    > "$root/docs/wiki.md"
  printf 'the gain-sweep, then the inductance-sweep\n'      > "$root/docs/bench.md"
  printf 'bom-analysis, dimmer-flasher, interface-board\n'  > "$root/docs/parts.md"
  out=$(run "$root"); status=$?
  case_is "the hyphenated board name is a hit"      1 "client-hw   docs/board.md:1" "$status" "$out"
  case_is "the client's MCU is a hit"               1 "client-hw   docs/mcu.md:1"   "$status" "$out"
  case_is "a client wiki page name is a hit"        1 "client-hw   docs/wiki.md:1"  "$status" "$out"
  case_is "the two bench sweeps are hits"           1 "client-hw   docs/bench.md:1" "$status" "$out"
  case_is "the remaining client artifacts are hits" 1 "client-hw   docs/parts.md:1" "$status" "$out"

  # 7c — a second identity of the user's is a person, not a Calyx name. Found by review pass 1:
  #      `heliman` was reported only as `calyx-name`, took `ship`, and would have survived.
  root=$(make_tree identity)
  printf 'committing as davidcalyx and commenting as heliman\n' > "$root/docs/notes.md"
  out=$(run "$root"); status=$?
  case_is "a second GitHub identity is a person hit" 1 "person      docs/notes.md:1" "$status" "$out"

  root=$(make_tree swear)
  printf 'this is bullshit and i am angry now\n' > "$root/docs/notes.md"
  printf 'you took too freaking long\n'          > "$root/docs/mild.md"
  out=$(run "$root"); status=$?
  case_is "an expletive is a hit" 1 "profanity   docs/notes.md:1" "$status" "$out"
  # A euphemism is one too — the issue says *any* expletive. Its own case, because until review
  # pass 2 said so, reverting `freaking` broke nothing in this suite.
  case_is "a euphemism is a hit too" 1 "profanity   docs/mild.md:1" "$status" "$out"

  # 9 — the user's own name is NOT a hit. The issue excludes it, and a sweep that flags every
  #     mention of him reports the whole repository.
  root=$(make_tree david)
  printf 'How David works: edit in place.\n' > "$root/docs/notes.md"
  out=$(run "$root"); status=$?
  case_is "the user's own name is not a hit" 0 "no hit in any class" "$status" "$out"

  # 10 — one line, three exposures, three rows. `R:\work_lantern\roadz` is a machine path and a
  #      client name and a product name, and each is a separate disposition.
  root=$(make_tree multi)
  printf 'copied from R:\\work_lantern\\roadz-sound-system\n' > "$root/docs/notes.md"
  out=$(run "$root"); status=$?
  case_is "one line, three exposures — the path"    1 "local-path  docs/notes.md:1" "$status" "$out"
  case_is "one line, three exposures — the client"  1 "lantern     docs/notes.md:1" "$status" "$out"
  case_is "one line, three exposures — the product" 1 "roadz       docs/notes.md:1" "$status" "$out"

  # 11 — the repository's own issue links are NOT an organisation-name exposure. This is the
  #      exception that keeps a thousand links out of the rows that need deciding.
  root=$(make_tree ownlinks)
  printf 'see [#12](https://github.com/Calyx-Engineering/arc/issues/12)\n' > "$root/docs/notes.md"
  out=$(run_all "$root"); status=$?
  case_is  "an own-repository link is the calyx-url class" 1 "calyx-url   docs/notes.md:1" "$status" "$out"
  case_not "an own-repository link is not also a name exposure" "calyx-name" "$out"

  # 12 — but the bare organisation name still is. Without this the exception above would
  #      swallow the manifest's author field, which is the one that actually needs a decision.
  root=$(make_tree orgname)
  printf '"author": { "name": "Calyx Engineering" }\n' > "$root/docs/notes.md"
  out=$(run "$root"); status=$?
  case_is "the bare organisation name is a hit" 1 "calyx-name  docs/notes.md:1" "$status" "$out"

  # 13 — a bulk class is counted, not listed, until --all. The default output is for a human
  #      deciding dozens of things, not for reading a thousand links.
  root=$(make_tree bulk)
  printf 'see [#12](https://github.com/Calyx-Engineering/arc/issues/12)\n' > "$root/docs/notes.md"
  out=$(run "$root"); status=$?
  case_is  "a bulk class is still counted by class" 1 "calyx-url       1" "$status" "$out"
  case_not "a bulk class is not listed by default" "calyx-url   docs/notes.md:1" "$out"

  # 14 — --summary drops the rows and keeps both summaries. The audit's summary-by-file section
  #      is generated from it, so a change that loses it is a change that breaks #134.
  root=$(make_tree summary)
  printf 'the ROADZ speaker system\n' > "$root/docs/notes.md"
  out=$(run_sum "$root"); status=$?
  case_is  "--summary keeps the by-file summary" 1 "1   docs/notes.md" "$status" "$out"
  case_not "--summary does not print the rows" "docs/notes.md:1  the ROADZ" "$out"

  # 15 — --markdown emits table rows with an empty disposition cell, and no bulk row. The audit
  #      document is built from this, so a row that arrives already dispositioned would let a
  #      regeneration overwrite a decision the user made.
  root=$(make_tree md)
  printf 'the ROADZ system | with a pipe and a `tick`\n' > "$root/docs/notes.md"
  printf 'see [#12](https://github.com/Calyx-Engineering/arc/issues/12)\n' > "$root/docs/links.md"
  out=$(TERM=dumb bash "$SELF" --root "$root" --markdown 2>&1); status=$?
  case_is  "--markdown exits 0 — it is a formatter, not a gate" 0 "| Class | Location |" "$status" "$out"
  case_is  "--markdown escapes a pipe and drops backticks in the text cell" 0 \
           'the ROADZ system \| with a pipe and a tick | |' "$status" "$out"
  case_not "--markdown omits the bulk class" "calyx-url" "$out"

  # 16 — the three exclusions. Each file has to hold the terms in order to do its job, and a
  #      sweep that reports them reports itself forever.
  root=$(make_tree exclusions)
  mkdir -p "$root/tools" "$root/tests" "$root/docs/arc-work/04-dogfood"
  printf 'roadz lantern Chad\n' > "$root/tools/audit-public.sh"
  printf 'roadz lantern Chad\n' > "$root/tests/verify-public-audit.sh"
  printf 'roadz lantern Chad\n' > "$root/docs/arc-work/04-dogfood/public-audit.md"
  out=$(run "$root"); status=$?
  case_is "the instrument, its gate and the audit exclude themselves" 0 "no hit in any class" "$status" "$out"

  # 17 — but only those three. A neighbouring file in the same directory is scanned, or the
  #      exclusion is a directory nobody decided to exempt.
  root=$(make_tree neighbour)
  mkdir -p "$root/tools"
  printf 'roadz\n' > "$root/tools/other.sh"
  out=$(run "$root"); status=$?
  case_is "a neighbouring file is not covered by the exclusion" 1 "tools/other.sh:1" "$status" "$out"

  echo
  echo "$passed passed, $failed failed"
  [ "$failed" = "0" ] || exit 1
  exit 0
fi

# ---- invocation ---------------------------------------------------------------------------
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
MODE="list"
while [ $# -gt 0 ]; do
  case "$1" in
    --root)    ROOT="$2"; shift 2 ;;
    --summary)  MODE="summary"; shift ;;
    --all)      MODE="all"; shift ;;
    --markdown) MODE="markdown"; shift ;;
    *) echo "audit-public: unknown argument '$1'" >&2; exit 2 ;;
  esac
done

if [ "$MODE" = "markdown" ]; then
  markdown "$ROOT"
  exit 0
fi

report "$ROOT" "$MODE"
exit $?
