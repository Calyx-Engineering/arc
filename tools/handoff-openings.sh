#!/usr/bin/env bash
# handoff-openings.sh — enumerate the post-install cold starts, and pair each with the session
# that wrote the handoff it read.
#
#   tools/handoff-openings.sh <briefed-slug> [<briefed-slug>...] [--since <ISO8601>] [--until <ISO8601>]
#   tools/handoff-openings.sh <briefed-slug> ... --locators      # absolute paths, for a reader
#   tools/handoff-openings.sh selftest
#
# WHY THIS EXISTS. #150: the handoff format has been rewritten three or four times with no
# instrument to say whether any rewrite helped. Scoring needs a corpus that is the same set every
# time it is asked for — a hand-listed one drifts, and the score then measures the list.
#
# WHAT IT IS NOT. It does not score. It says which sessions are cold starts and which session
# wrote the handoff each of them read; whether the opening was *correct* is a judgement made
# from the transcripts, recorded in docs/arc-work/04-dogfood/handoff-baseline.md.
#
# DEFINITIONS, because the count is meaningless without them.
#   cold start   a session that STARTS at or after --since, and whose first prompt turn was
#                typed by a human. Two further exclusions, each of which is a real session in
#                the store and not a hypothetical:
#                  - fewer than 2 human prompt turns. This drops the session that ran
#                    `/plugin install` (no prompt turn at all) and the one-shot session that
#                    asked for a transcript to be copied. Neither picks up any work
#                  - a loop-dispatched run. Its prompt carries promptSource "sdk" with no human
#                    origin: the driver handed it an issue, not a handoff
#                A session that STARTED before --since is out even if it ran past it. It began
#                its cold start against a pre-install handoff, so its opening says nothing
#                about the installed plugin.
#   handoff-read a cold start whose first prompt instructs the session to pick up — read the
#     opening    handoff, get up to speed, say where we are. Reported as a column, NOT used to
#                filter: a cold start that did NOT ask for a handoff read is still a cold start,
#                and #150's corpus is all 8 of them.
#   writer       the session whose last write to a HANDOFF file landed most recently BEFORE the
#                cold start's first prompt, within the same repository. That is the handoff the
#                cold start actually read. "None" is a finding, not a gap — an opening that read
#                a handoff no transcript wrote (a pre-install one, or one edited outside Claude)
#                cannot be scored against a writing session, and #150 asks for the pair.
#   repository   the briefed slug with any "--claude-worktrees-…" tail removed. A worktree gets
#                its own transcript directory but writes the same repository's handoff, so
#                pairing per directory would lose the writer across a worktree boundary.
#
# THE WINDOW IS COMPARED AGAINST THE SESSION'S FIRST ENVELOPE, not against the opening prompt,
# and both bounds are plain string comparisons on ISO timestamps. So a bare date means that date
# at 00:00: `--until 2026-09-06` keeps everything that started before midnight on the 6th and
# drops the whole of the 6th. Say the instant if you mean one.
#
# Scope comes from tools/miner-scope.sh — briefed directories only, never a prefix glob (#141).
# A briefed slug that matches no directory is a wrong brief, and this refuses to report rather
# than print a smaller corpus that looks clean: a re-run with one slug fat-fingered would
# otherwise read as "a row moved".
#
# Transcripts are read in place and never copied: they carry client material (#16's constraint).
#
# HANDOFF_ROOT overrides the directory this runs from. Nothing here reads a repository file, so
# it exists only for parity with the other tools; MINER_PROJECTS_ROOT is the one that matters.

set -u

# Resolved BEFORE the cd. Resolving "$0" after it turns a relative invocation into a wrong path,
# and the failure then surfaces as "no directory in scope" — a miner-scope result, from a
# miner-scope that was never found.
HERE="$(cd "$(dirname "$0")" && pwd)"
cd "${HANDOFF_ROOT:-$HERE/..}" || exit 1

SINCE=""
UNTIL=""
LOCATORS=0
SLUGS=""
SELFTEST=0

# An option that takes a value must be given one, and a flag is not a value. Without this,
# `--since --locators` sets SINCE to "--locators" and silently drops the flag, and `--since` as
# the last argument sets it empty — both of which change the corpus and exit 0.
need() {  # need <flag> <the-next-argument>
  case "${2:-}" in
    ""|-*) echo "$1 needs a value" >&2; exit 2 ;;
  esac
}

while [ "$#" -gt 0 ]; do
  case "$1" in
    selftest)   SELFTEST=1 ;;
    --since)    need --since "${2:-}"; shift; SINCE="$1" ;;
    --until)    need --until "${2:-}"; shift; UNTIL="$1" ;;
    --locators) LOCATORS=1 ;;
    # The header block, however long it grows. A fixed line range goes stale the first time the
    # comment is edited, and prints `set -u` as though it were documentation.
    -h|--help)  awk 'NR > 1 && /^#/ { print; next } NR > 1 { exit }' "$0"; exit 0 ;;
    -*) echo "unknown option: $1" >&2; exit 2 ;;
    *) SLUGS="$SLUGS $1" ;;
  esac
  shift
done

report() {  # report <projects-root> <briefed-slug>...
  local root="$1"
  shift
  local dirs status
  # miner-scope exits 1 when a briefed slug matched no directory. Discarding that status is how
  # a mistyped slug produces a smaller corpus that looks clean — and the whole point of the
  # baseline is that a later re-run compares like with like. Its stderr names the slug, so it
  # is left to flow rather than captured.
  dirs="$(MINER_PROJECTS_ROOT="$root" bash "$HERE/miner-scope.sh" "$@")"; status=$?
  if [ "$status" != "0" ]; then
    echo "refusing to report a corpus: a briefed slug matched no directory." >&2
    return 1
  fi
  dirs="$(printf '%s\n' "$dirs" | sed -n "s/^IN  *//p")"
  if [ -z "$dirs" ]; then
    echo "no directory in scope for: $*" >&2
    return 1
  fi
  HANDOFF_DIRS="$dirs" HANDOFF_ROOT_DIR="$root" \
  HANDOFF_SINCE="$SINCE" HANDOFF_UNTIL="$UNTIL" HANDOFF_LOCATORS="$LOCATORS" \
  python "$HERE/handoff-openings.py"
}

if [ "$SELFTEST" = "1" ]; then
  T="$(mktemp -d)"
  trap 'rm -rf "$T"' EXIT
  P="$T/projects"
  # The worktree directory is deliberately UPPERCASE, as the real store writes it beside a
  # lowercase parent. It makes repo_of()'s .lower() load-bearing.
  mkdir -p "$P/r--fixture" "$P/R--FIXTURE--claude-worktrees-wt" "$P/r--second" "$P/r--other"

  # Envelope shapes, copied from the store. Only u() is a human prompt turn.
  #
  # The three rejected shapes below are given a HUMAN origin, which is the one condition in
  # which each shape's own guard is load-bearing. As the store writes them they carry no human
  # origin and the final clause of is_human_prompt() rejects them anyway — so a fixture built
  # from the store's shape would pass with that shape's guard deleted, and assert nothing.
  u()      { printf '{"type":"user","promptSource":"sdk","origin":{"kind":"human"},"timestamp":"%s","message":{"content":"%s"}}\n' "$1" "${2:-typed by the user}"; }
  disp()   { printf '{"type":"user","promptSource":"sdk","timestamp":"%s","message":{"content":"dispatched by the loop"}}\n' "$1"; }
  cmd()    { printf '{"type":"user","timestamp":"%s","message":{"content":[{"type":"text","text":"<command-name>/plugin</command-name>"}]}}\n' "$1"; }
  resh()   { printf '{"type":"user","origin":{"kind":"human"},"timestamp":"%s","message":{"content":[{"type":"tool_result","content":"x"}]}}\n' "$1"; }
  metah()  { printf '{"type":"user","origin":{"kind":"human"},"isMeta":true,"timestamp":"%s","message":{"content":"Base directory for this skill: ..."}}\n' "$1"; }
  intrh()  { printf '{"type":"user","origin":{"kind":"human"},"timestamp":"%s","message":{"content":[{"type":"text","text":"[Request interrupted by user]"}]}}\n' "$1"; }
  wr()     { printf '{"type":"assistant","timestamp":"%s","message":{"content":[{"type":"tool_use","name":"Write","input":{"file_path":"%s"}}]}}\n' "$1" "$2"; }

  H='r:\\repo\\HANDOFF.md'
  O='r:\\repo\\docs\\notes.md'
  # A directory whose NAME contains HANDOFF, holding a file that is not one. Matching the whole
  # path rather than the basename would make this the most recent writer for everyone after it.
  HD='r:\\repo\\HANDOFF-notes\\scratch.md'

  # ---- one session per rule, each built so the wrong answer scores differently ---------------

  # wrote-01 writes the handoff. Its own opening predates --since, so it is a writer and not a
  # corpus member — the #150 case where a pre-install session hands off into the measured window.
  { u 2026-08-20T09:00; u 2026-08-20T09:05; wr 2026-08-23T18:00 "$H"; } > "$P/r--fixture/wrote-01.jsonl"
  # read-01 is a clean handoff-read cold start, paired to wrote-01.
  { u 2026-08-25T10:00 "Read HANDOFF.md first, then do the steps"; u 2026-08-25T10:30; wr 2026-08-25T20:00 "$H"; } > "$P/r--fixture/read-01.jsonl"
  # read-02 is a cold start whose opening is new work, not a pickup. In the corpus, "no" in the
  # handoff-read column — dropping it is how a corpus of 8 becomes a corpus of 6.
  { u 2026-08-26T10:00 "lets build an inductance meter this weekend"; u 2026-08-26T11:00; } > "$P/r--fixture/read-02.jsonl"
  # skip-ins is the install session: a slash command echo and nothing typed. Not a cold start.
  { cmd 2026-08-27T10:00; cmd 2026-08-27T10:01; } > "$P/r--fixture/skip-ins.jsonl"
  # skip-cpy is the one-shot utility session — a single human prompt. Not a cold start.
  { u 2026-08-27T12:00 "please copy this transcript"; } > "$P/r--fixture/skip-cpy.jsonl"
  # skip-loop is a loop-dispatched run. Four prompts, none human. Not a cold start.
  { disp 2026-08-28T10:00; disp 2026-08-28T10:01; disp 2026-08-28T10:02; disp 2026-08-28T10:03; } > "$P/r--fixture/skip-loo.jsonl"
  # skip-join is the harder one: a dispatched run that a human joined. It has two human prompts,
  # so the count alone admits it — but the driver opened it, and its opening was a brief.
  { disp 2026-08-28T11:00; disp 2026-08-28T11:01; u 2026-08-28T11:30 "actually, read handoff"; u 2026-08-28T11:40; } > "$P/r--fixture/skip-joi.jsonl"
  # One human prompt plus two of the envelope under test, each carrying a human origin. A cold
  # start iff that envelope is miscounted as a prompt — one session per rejected shape, so a
  # deleted guard names itself.
  { u 2026-08-27T13:00; resh  2026-08-27T13:01; resh  2026-08-27T13:02; } > "$P/r--fixture/skip-res.jsonl"
  { u 2026-08-27T14:00; metah 2026-08-27T14:01; metah 2026-08-27T14:02; } > "$P/r--fixture/skip-met.jsonl"
  { u 2026-08-27T15:00; intrh 2026-08-27T15:01; intrh 2026-08-27T15:02; } > "$P/r--fixture/skip-int.jsonl"
  # skip-oth writes files that are not handoffs, more recently than any real write. Neither may
  # become a writer: one is an ordinary path, the other has HANDOFF in a DIRECTORY name.
  { u 2026-08-29T09:00; wr 2026-08-29T09:10 "$O"; wr 2026-08-29T12:00 "$HD"; } > "$P/r--fixture/skip-oth.jsonl"
  # read-03 is a cold start in the worktree directory, paired back across the worktree boundary
  # to its repository's last handoff write, in read-01.
  { u 2026-08-30T10:00 "please read handoff and get back up to speed"; u 2026-08-30T10:30; } > "$P/R--FIXTURE--claude-worktrees-wt/read-03.jsonl"
  # read-04 is a cold start in a SECOND briefed repository, which has no handoff write of its
  # own. r--fixture wrote one before it, and pairing across repositories would be wrong.
  { u 2026-08-31T10:00 "where are we at?"; u 2026-08-31T10:30; } > "$P/r--second/read-04.jsonl"
  # An unbriefed directory. Neither read nor available as a writer.
  { wr 2026-08-30T23:00 "$H"; u 2026-08-30T23:01; u 2026-08-30T23:02; } > "$P/r--other/skip-dir.jsonl"

  SINCE="2026-08-24T09:40"
  UNTIL=""
  LOCATORS=0
  out="$(report "$P" r--fixture r--second 2>&1)"

  # A second run with the corpus closed early, and a third with locators on. Both options change
  # the answer, and neither is exercised by the run above.
  UNTIL="2026-08-30"
  out_until="$(report "$P" r--fixture r--second 2>&1)"
  UNTIL=""
  LOCATORS=1
  out_loc="$(report "$P" r--fixture r--second 2>&1)"
  LOCATORS=0

  Pc=0
  Fc=0
  t() {  # t <label> <extended-regex that must match>
    if printf '%s' "$out" | grep -qE -- "$2"; then
      echo "  PASS  $1"; Pc=$((Pc + 1))
    else
      echo "  FAIL  $1"; echo "        wanted /$2/"; echo "        got:"
      printf '%s\n' "$out" | sed 's/^/          /'; Fc=$((Fc + 1))
    fi
  }
  nt() {  # nt <label> <extended-regex that must NOT match>
    if printf '%s' "$out" | grep -qE -- "$2"; then
      echo "  FAIL  $1"; echo "        did not want /$2/"; echo "        got:"
      printf '%s\n' "$out" | sed 's/^/          /'; Fc=$((Fc + 1))
    else
      echo "  PASS  $1"; Pc=$((Pc + 1))
    fi
  }
  tin() {  # tin <label> <the-output-to-search> <extended-regex that must match>
    if printf '%s' "$2" | grep -qE -- "$3"; then
      echo "  PASS  $1"; Pc=$((Pc + 1))
    else
      echo "  FAIL  $1"; echo "        wanted /$3/"; echo "        got:"
      printf '%s\n' "$2" | sed 's/^/          /'; Fc=$((Fc + 1))
    fi
  }
  ntin() {  # ntin <label> <the-output-to-search> <extended-regex that must NOT match>
    if printf '%s' "$2" | grep -qE -- "$3"; then
      echo "  FAIL  $1"; echo "        did not want /$3/"; echo "        got:"
      printf '%s\n' "$2" | sed 's/^/          /'; Fc=$((Fc + 1))
    else
      echo "  PASS  $1"; Pc=$((Pc + 1))
    fi
  }
  te() {  # te <label> <expected-exit> <args to this script...>
    local label="$1" want="$2"; shift 2
    MINER_PROJECTS_ROOT="$P" bash "$0" "$@" >/dev/null 2>&1
    local got=$?
    if [ "$got" = "$want" ]; then echo "  PASS  $label"; Pc=$((Pc + 1))
    else echo "  FAIL  $label"; echo "        wanted exit $want, got $got"; Fc=$((Fc + 1)); fi
  }

  echo "handoff-openings selftest"
  echo
  t  "the corpus is the cold starts and nothing else"        "corpus: 4 cold start"
  nt "a session that started before --since is not one"      "^[0-9]+ +[-0-9: ]+wrote-01"
  t  "a clean handoff-read opening is in, and says yes"      "^1 +2026-08-25 10:00 +read-01 .*yes"
  t  "an opening that is new work is in, and says no"        "^2 +2026-08-26 10:00 +read-02 .*no"
  nt "the install session's slash echo is not a prompt turn" "^[0-9]+ +[-0-9: ]+skip-ins"
  nt "a single-human-prompt session is not a cold start"     "^[0-9]+ +[-0-9: ]+skip-cpy"
  nt "a loop-dispatched run is not a cold start"             "^[0-9]+ +[-0-9: ]+skip-loo"
  nt "a dispatched run a human joined is not a cold start"   "^[0-9]+ +[-0-9: ]+skip-joi"
  t  "a worktree's cold start is in the corpus"              "^3 +2026-08-30 10:00 +read-03 .*yes"
  t  "the writer is the last handoff write before the read"  "^1 +read-01 +wrote-01 +2026-08-23 18:00"
  t  "the pre-window write is still the handoff that was read" "^1 +read-01 +wrote-01 .*40\.0h"
  t  "a write to a non-handoff file does not make a writer"  "^3 +read-03 +read-01 +2026-08-25 20:00"
  nt "a worktree does not pair outside its own repository"   "read-03 +skip-oth"
  t  "a cold start whose repository has no write pairs none" "^4 +read-04 +-- +none"
  t  "an unbriefed directory is neither read nor paired"     "in 3 directorie"
  nt "an unbriefed directory's handoff write is not a writer" "skip-dir"
  nt "a tool_result is not a prompt turn, even from a human"  "^[0-9]+ +[-0-9: ]+skip-res"
  nt "a skill injection is not a prompt turn, even from a human" "^[0-9]+ +[-0-9: ]+skip-met"
  nt "an interrupt marker is not a prompt turn, even from a human" "^[0-9]+ +[-0-9: ]+skip-int"
  nt "HANDOFF in a directory name does not make a writer"     "read-03 +skip-oth"

  # --until, which closes the corpus. Without it the baseline cannot be re-run like for like.
  tin  "--until drops a cold start that started after it" "$out_until" "corpus: 2 cold start"
  ntin "--until leaves the later cold start out entirely" "$out_until" "read-03"
  tin  "--until keeps the ones before it"                 "$out_until" "^2 +2026-08-26 10:00 +read-02"

  # --locators, which is how a reader is handed the pair.
  tin "--locators prints the reader's transcript path"    "$out_loc" "reader .*read-01\.jsonl"
  tin "--locators prints the writer's transcript path"    "$out_loc" "writer .*wrote-01\.jsonl"
  tin "--locators pairs a worktree reader to its writer"  "$out_loc" "writer .*read-01\.jsonl"
  ntin "--locators invents no writer for an unpaired row" "$out_loc" "writer .*read-04\.jsonl"

  # Exit codes. A brief that matched nothing must not read as a smaller corpus.
  te "a briefed slug matching no directory exits 1, not 0" 1 r--fixture r--typo-not-here
  te "a valid brief exits 0"                               0 r--fixture
  te "--since with no value exits 2"                       2 r--fixture --since
  te "--since swallowing the next flag exits 2"            2 r--fixture --since --locators
  te "--until with no value exits 2"                       2 r--fixture --until
  te "no arguments exits 2"                                2
  echo
  echo "$Pc passed, $Fc failed"
  [ "$Fc" = "0" ] || exit 1
  exit 0
fi

if [ -z "$SLUGS" ]; then
  echo "usage: tools/handoff-openings.sh <briefed-slug> [...] [--since ISO] [--until ISO] [--locators]" >&2
  echo "       a briefed slug is a directory name under ~/.claude/projects" >&2
  exit 2
fi

# shellcheck disable=SC2086
report "${MINER_PROJECTS_ROOT:-$HOME/.claude/projects}" $SLUGS
