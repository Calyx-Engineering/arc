#!/usr/bin/env bash
# verify-all.sh — run every gate this repo has, and report one exit code.
#
#   tools/verify-all.sh            every gate
#   tools/verify-all.sh --list     what it would run, and what it cannot
#
# WHY. The repo had four verifiers and nothing that ran them. "The gates are clean" in a PR
# body was a claim a reviewer took on trust, and the close sequence asked for it without
# giving anyone a command. This is that command.
#
# A NEW VERIFIER CANNOT BE SILENTLY SKIPPED. The invocations below are a table, because the
# scripts take different arguments — but the table is checked against `tools/verify-*.sh` on
# disk, and an unknown one fails the run. That is #68's lesson: a hardcoded list makes a new
# thing invisible, and the check whose job is catching a gap reports success instead.
#
# REPORTS, NEVER BLOCKS. Same precedent as every verifier it calls. Exit 1 marks findings for
# a human to read; nothing here denies a tool call or gates a merge on its own.

set -u

cd "$(dirname "$0")/.." || exit 1

LIST=0
[ "${1:-}" = "--list" ] && LIST=1

# name  →  how to invoke it. Scripts needing a per-target argument are expanded below.
KNOWN="verify-hook-source verify-case-reader verify-autonomy verify-skill-registry verify-tracker-body verify-hook verify-template-links verify-close-sequence verify-handoff-checks verify-handoff-rationale verify-handoff-archive verify-handoff-stamp verify-workspace-guard verify-branch-prefix verify-linked-branch verify-labels verify-mechanisms verify-dev-log-name verify-activation-log miner-scope skill-firing handoff-openings skill-cases response-length topic-numbering report-grade saturation-cases environment-blame verify-session-index verify-issue-boxes verify-report-budget verify-set-mode arc-claim plugin-reload arc-link-sweep skill-probe probe-handoff-checks verify-log-rotation"

RUN=0
FAILED=0
FAILED_NAMES=""

run_gate() {
  local label="$1"; shift
  RUN=$((RUN + 1))
  if [ "$LIST" = "1" ]; then
    echo "  would run   $label   ($*)"
    return
  fi
  local out status
  out="$("$@" 2>&1)"; status=$?
  if [ "$status" = "0" ]; then
    # The tail line of each verifier is its own summary; echoing more duplicates it.
    echo "  PASS  $label   $(printf '%s' "$out" | grep -E '[0-9]+ (passed|copied)|are current' | tail -n1)"
  else
    echo "  FAIL  $label"
    printf '%s\n' "$out" | sed 's/^/        /'
    FAILED=$((FAILED + 1))
    FAILED_NAMES="$FAILED_NAMES $label"
  fi
}

echo "verify-all — every gate in this repository"
echo

# ---- the table is checked against disk before anything runs ------------------------
# A verifier nobody wired in is worse than one that fails: it looks like coverage.
unknown=""
for f in tools/verify-*.sh; do
  [ -f "$f" ] || continue
  n="$(basename "$f" .sh)"
  [ "$n" = "verify-all" ] && continue
  case " $KNOWN " in
    *" $n "*) ;;
    *) unknown="$unknown $n" ;;
  esac
done
if [ -n "$unknown" ]; then
  echo "  FAIL  a verifier exists that this runner does not know:$unknown"
  echo "        add it to KNOWN and give it an invocation, or it is coverage nobody has."
  FAILED=$((FAILED + 1))
  FAILED_NAMES="$FAILED_NAMES unknown-verifier"
fi

# ---- the gates ---------------------------------------------------------------------
run_gate "case reader cases" bash tools/verify-case-reader.sh selftest
run_gate "skill registry" bash tools/verify-skill-registry.sh
run_gate "skill registry cases" bash tools/verify-skill-registry.sh selftest
run_gate "miner scope cases" bash tools/miner-scope.sh selftest
run_gate "skill firing cases" bash tools/skill-firing.sh selftest
# The three selftests around the probe. None invokes `claude`, so none bills — what is excluded
# from this file is tools/skill-probe.sh's live run, not the logic that reads its output. #252
# added the first two and cited both as evidence; unregistered, nothing would ever run them
# again. The third is #269's: tools/skill-probe.sh became testable when the abandon branch,
# the halt and the measured-runs denominator were added to it, all of which are JSON in and
# text out. It replaces the billed half through PROBE_PY.
#
# Their names ARE in KNOWN, alongside the dozen others there that the guard cannot check. It
# globs `tools/verify-*.sh` and never asks after a file named anything else, so those entries
# are for the reader, not for the guard. The gap is real and it is the guard's: a selftest whose
# file is not named `verify-*` can only be noticed by reading this file.
run_gate "skill probe cases" python tools/skill-probe.py selftest
run_gate "skill probe loop cases" bash tools/skill-probe.sh selftest
run_gate "probe handoff check cases" bash tools/probe-handoff-checks.sh selftest
run_gate "handoff opening cases" bash tools/handoff-openings.sh selftest
run_gate "skill eval cases" bash tools/skill-cases.sh selftest
run_gate "response length cases" bash tools/response-length.sh selftest
run_gate "topic numbering cases" bash tools/topic-numbering.sh selftest
run_gate "report shape cases" bash tools/report-grade.sh selftest
run_gate "saturation cases" bash tools/saturation-cases.sh selftest
run_gate "environment blame cases" bash tools/environment-blame.sh selftest
run_gate "issue claim cases" bash tools/arc-claim.sh selftest
run_gate "plugin reload cases" bash tools/plugin-reload.sh selftest
run_gate "link sweep cases" bash tools/arc-link-sweep.sh selftest
run_gate "autonomy switch" bash tools/verify-autonomy.sh
run_gate "tracker body rules" bash tools/verify-tracker-body.sh selftest
run_gate "template links" bash tools/verify-template-links.sh
run_gate "template link cases" bash tools/verify-template-links.sh selftest
run_gate "close-sequence count" bash tools/verify-close-sequence.sh
run_gate "handoff staleness checks" bash tools/verify-handoff-checks.sh
run_gate "handoff rationale cases" bash tools/verify-handoff-rationale.sh selftest
run_gate "handoff rationale" bash tools/verify-handoff-rationale.sh
run_gate "handoff archive cases" bash tools/verify-handoff-archive.sh selftest
run_gate "handoff archive" bash tools/verify-handoff-archive.sh
run_gate "handoff stamp cases" bash tools/verify-handoff-stamp.sh selftest
run_gate "handoff stamp" bash tools/verify-handoff-stamp.sh
run_gate "session index cases" bash tools/verify-session-index.sh selftest
run_gate "session index" bash tools/verify-session-index.sh
run_gate "workspace guard" bash tools/verify-workspace-guard.sh
run_gate "branch prefix" bash tools/verify-branch-prefix.sh
run_gate "linked-branch cases" bash tools/verify-linked-branch.sh selftest
run_gate "issue box cases" bash tools/verify-issue-boxes.sh selftest
run_gate "label cases" bash tools/verify-labels.sh selftest
run_gate "mechanism table cases" bash tools/verify-mechanisms.sh selftest
run_gate "mechanism table" bash tools/verify-mechanisms.sh
run_gate "dev-log name cases" bash tools/verify-dev-log-name.sh selftest
run_gate "dev-log name" bash tools/verify-dev-log-name.sh
run_gate "hook source cases" bash tools/verify-hook-source.sh selftest
run_gate "hook source" bash tools/verify-hook-source.sh
run_gate "activation log cases" bash tools/verify-activation-log.sh selftest
run_gate "activation log" bash tools/verify-activation-log.sh
run_gate "log rotation cases" bash tools/verify-log-rotation.sh selftest
run_gate "log rotation" bash tools/verify-log-rotation.sh
run_gate "set-mode cases" bash tools/verify-set-mode.sh selftest
run_gate "report budget cases" bash tools/verify-report-budget.sh selftest
run_gate "report budget" bash tools/verify-report-budget.sh

# One per hook that has a case directory. A hook without cases is reported rather than
# skipped — CLAUDE.md requires pass, deny and malformed cases before a hook is registered.
for h in hooks/*; do
  [ -f "$h" ] || continue
  n="$(basename "$h")"
  case "$n" in TEMPLATE|*.json) continue ;; esac
  if [ -d "tools/hook-cases/$n" ]; then
    run_gate "hook: $n" bash tools/verify-hook.sh "$h"
  else
    echo "  FAIL  hook: $n   no case directory — CLAUDE.md requires pass, deny and malformed cases"
    FAILED=$((FAILED + 1))
    FAILED_NAMES="$FAILED_NAMES hook:$n"
  fi
done

if [ "$LIST" = "1" ]; then
  cat <<'CANNOT'

  cannot run — and no gate here should be read as covering them:
    hooks in a live session   Arc is installed here, so hooks do fire — camp-branch-check and
                              tracker-verify were both observed. The cases above still run each
                              hook standalone against the WORKING TREE; a live firing uses the
                              installed copy, which is only current after tools/plugin-reload.sh
    any skill                 no gate here invokes one. Every skill-carried rule is checked as
                              text, never as behaviour. tools/skill-firing.sh measures how often
                              each skill fired in real sessions, and tools/skill-cases.sh scores
                              evals/skill-firing per prompt — both are history rather than a
                              test; re-running a case against a changed skill needs
                              claude plugin eval, gated behind early access — #181
    the eval cases themselves the gates above run the SELFTESTS of skill-cases.sh,
                              response-length.sh, topic-numbering.sh, report-grade.sh,
                              saturation-cases.sh and environment-blame.sh, on fixtures. Scoring
                              the real cases needs the corpus — the transcripts, and for
                              report-grade.sh the source repositories — which live on
                              one machine. Run bash tools/skill-cases.sh, bash
                              tools/response-length.sh, bash tools/topic-numbering.sh, bash
                              tools/saturation-cases.sh, bash tools/environment-blame.sh and
                              bash tools/report-grade.sh there.
                              report-grade.sh alone still scores from its stored excerpts when
                              the corpus is absent; it just cannot check them against their
                              source
    whether a skill FIRES     tools/skill-probe.sh re-runs a case's prompt against the plugin
    against a CHANGED         as installed and records whether the Skill tool was invoked. It
    description               is the only instrument here that can see a description edit, and
                              every run is a real billed session, so it is not a gate. The
                              three gates above — skill probe cases, skill probe loop cases,
                              probe handoff check cases — are its selftests on canned input;
                              they say the reader and the loop around it are right, never that
                              a skill fired. tools/probe-handoff-checks.sh then says
                              which installed file a firing read, not what the session did with
                              it
    three questions against   response-length.sh --probe, topic-numbering.sh --probe and
    a CHANGED skill — reply   saturation-cases.sh --probe re-run a case's turns live and score
    length, topic numbering,  the replies. All three bill per turn, and the saturation case is
    and whether a session     52 turns long, so none of them is a gate here
    notices its own
    saturation
    check 8 against a         environment-blame.sh has no --probe at all, and that is the
    CHANGED skill             condition, not an omission: it scores a session in front of an
                              instrument that answers and returns nothing, and a replayed
                              session has no instrument. Scoring a change to work-watch check 8
                              needs a live session at a real bench — #246
    a real branch↔issue link  verify-linked-branch.sh selftest runs its decision on fixtures. The
                              live read needs GitHub and a real issue — run
                              bash tools/verify-linked-branch.sh <NN> <branch> after creating one
    a label against its       verify-labels.sh selftest runs its decision on fixtures. The sweep
    prefix, and the label set of real open issues, and the label set itself, both read GitHub —
                              run bash tools/verify-labels.sh and
                              bash tools/verify-labels.sh labels
    two dispatchers against   arc-claim.sh selftest drives take, release, refresh and the race
    the real tracker          through a fixture backend, and one case drives the live path
                              behind a stubbed gh. A real one needs two loops, a live
                              workstream and a real issue — run
                              bash tools/arc-claim.sh check <NN> against one
    arc-loop's own claim      no case dispatches a run, so take_claim, reclaim_claim, the
    wiring                    heartbeat, the per-issue release and the three traps are checked
                              as source text only — tools/arc-claim.sh selftest's structural
                              cases. --dry-run reaches selection and stops before the claim
    a real issue's boxes      verify-issue-boxes.sh selftest runs the whole script against a
    against its PR body       fixture backend. The live read needs GitHub, a real issue and the
                              PR that closes it — run bash tools/verify-issue-boxes.sh <NN> at
                              PR-ready time, which is also where hooks/tracker-verify calls it
    an arc's issues against   arc-link-sweep.sh selftest runs its decision on fixtures. The sweep
    both link fields          itself searches GitHub and paginates — run
                              bash tools/arc-link-sweep.sh <milestone> at an arc checkpoint
CANNOT
  exit 0
fi

echo
if [ "$FAILED" = "0" ]; then
  echo "$RUN gates, all clean"
  echo
  echo "Not covered: hooks in a live session, and every skill. See --list."
  exit 0
fi

echo "$RUN gates, $FAILED failed —$FAILED_NAMES"
exit 1
