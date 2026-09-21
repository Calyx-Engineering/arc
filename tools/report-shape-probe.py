# report-shape-probe.py — the billed half of tools/report-shape-probe.sh. Not run directly.
#
# Opens ONE session against the plugin as installed, hands it the fixed brief, and keeps the
# report that session writes. It scores nothing: tools/report-grade.sh --file does that, and
# the split is deliberate — the grader stays byte-identical between the frozen suite and the
# probe, so a figure from one can be set beside a figure from the other.
#
# WHY IT WRITES A FILE INSTEAD OF SCORING THE REPLY. The reply text was the first design and it
# is unmeasurable. A `-p` reply carries the session's conversational wrapper — "Here is the
# report:" — and that wrapper scores as PREAMBLE, which is one of the three shapes being
# measured. Telling the model not to write a preamble contaminates the measurement of the
# preamble flag. A file written by Write has no wrapper: what is in it is what the session
# considered the document to be.
#
# THE BRIEF IS CHRONOLOGICAL ON PURPOSE. It states the work in the order it happened —
# reproduce, then the datasheet, then the capacitance, then the confirmation — because a
# session that does not apply the rule reproduces the order it was given. A brief already in
# report order would score CONCLUSION whether the skill loaded or not, and measure nothing.
# Same reason it names no section, asks for no Provenance column, and never says "conclusion
# first": the brief supplies raw material, the skill supplies shape, and a shape instruction
# here is the probe grading its own prompt.
#
# TWO TOOLS, AND THE REST DENIED. Write, because the report is a file. Skill, because the rule
# under test lives in a skill BODY and a session that cannot invoke one cannot read it. Read is
# allowed so the session can check back what it wrote. Everything else is denied — a probe must
# not commit, push, edit this tree or reach the network — and it runs in a temp directory, so
# the one file it may write lands nowhere that matters.
#
# `fired` IS A DIAGNOSTIC, NOT THE MEASUREMENT. #155 settled that firing and shape move
# independently, and this instrument's question is shape. It is recorded for one reason: a rule
# that lives in a skill BODY is only in context on the runs where the skill fired, so a change
# that moved nothing cannot be told from a change that was never loaded. Same reasoning as
# tools/response-length-probe.py.
#
# A RUN THE CLI CUT SHORT IS NOT A NARRATIVE REPORT. It is no measurement at all, and the shape
# it leaves — a missing or half-written report.md — would grade as NOSECTION or worse and land
# in a column as a fail. #213 lost two billed runs to that confusion one instrument over. The
# `result` line's subtype and is_error are read, a cut run backs off RSP_BACKOFF seconds and
# runs ONCE more, and a second failure travels out as `unusable` for the loop to abandon on.
#
# IT COSTS MONEY. One report per run, RSP_BUDGET per session. That is why this is not in
# tests/verify-all.sh; the selftest of the loop around it is.
import io
import json
import os
import shutil
import subprocess
import sys
import tempfile
import threading
import time

try:
    sys.stdout.reconfigure(encoding="utf-8", errors="replace")
except Exception:
    pass

# `selftest` takes no paths, and reading argv[2] before checking for it made the selftest
# crash on an IndexError rather than run. A missing argument on the live path is still an
# error, and says which one.
SELFTEST = len(sys.argv) > 1 and sys.argv[1] == "selftest"
if not SELFTEST and len(sys.argv) < 3:
    raise SystemExit("usage: report-shape-probe.py <brief.md> <out.md> | selftest")
BRIEF_PATH = "" if SELFTEST else sys.argv[1]
OUT_PATH = "" if SELFTEST else sys.argv[2]

# MEASURED, NOT GUESSED. 0.60 was borrowed from tools/response-length-probe.py and is a
# PER-TURN budget there. Here one run is a whole session that loads a 400-line skill and
# writes a page of markdown, and 0.60 killed the first two attempts of #260's before side
# with `error_max_budget_usd` — two billed runs that measured nothing. A budget set below
# what the work costs does not save money; it spends it on cut sessions.
BUDGET = os.environ.get("RSP_BUDGET", "3.00")
TIMEOUT = int(os.environ.get("RSP_TIMEOUT", "600"))
TURNCAP = int(os.environ.get("RSP_TURN_CAP", "12"))
BACKOFF = int(os.environ.get("RSP_BACKOFF", "60"))

# Comma-separated, as ONE argument each. --allowedTools and --disallowedTools are both
# variadic, so two space-separated names after the same flag run together and the second flag's
# list is read as the first's — tools/response-length-probe.py carries the same note.
ALLOW = "Write,Read,Skill"
DENY = "Bash,Edit,NotebookEdit,WebFetch,WebSearch,Task,Agent,Artifact,Glob,Grep,TodoWrite"

# The file the brief asks for. Named here and in the brief, and the two have to agree — a
# mismatch is a run that bills and produces nothing to grade.
REPORT_NAME = "report.md"


def _warn(message):
    """Warnings go to stderr; stdout is the JSON tools/report-shape-probe.sh parses."""
    print(message, file=sys.stderr, flush=True)


def scan(lines, turncap, clock=None, timeout=None, started=None):
    """Read one session's stream-json. Returns what the run produced, scoring nothing.

    Stops at the `result` line, at `turncap` assistant turns, or at the deadline. A stream that
    ends without a `result` line is `cut`: the same shape a killed session leaves, and the one
    thing that must never be read as a report the session chose not to write.
    """
    fires, turns, cost, cut = [], 0, None, ""
    saw_result = False
    for line in lines:
        if clock and timeout is not None and clock() - started > timeout:
            cut = "timeout"
            break
        line = line.strip()
        if not line.startswith("{"):
            continue
        try:
            o = json.loads(line)
        except Exception:
            continue
        if o.get("type") == "result":
            saw_result = True
            cost = o.get("total_cost_usd")
            subtype = o.get("subtype") or ""
            if subtype and subtype != "success":
                cut = subtype
            elif o.get("is_error"):
                cut = "error"
            break
        if o.get("type") != "assistant":
            continue
        turns += 1
        for b in (o.get("message") or {}).get("content") or []:
            if not isinstance(b, dict):
                continue
            if b.get("type") == "tool_use" and b.get("name") == "Skill":
                sk = ((b.get("input") or {}).get("skill") or "").split(":")[-1]
                if sk and sk not in fires:
                    fires.append(sk)
        if turns >= turncap:
            cut = "turn cap"
            break
    if not saw_result and not cut:
        cut = "no result line"
    return {"fired": fires, "turns": turns, "cost": cost, "cut": cut}


def unusable(out):
    """Why this run is not a measurement, or "" if it is one.

    Three shapes. The CLI stopped the session; the session produced no assistant turn at all;
    or it produced turns and no report. The third is this instrument's own: a session that
    answered in prose and never called Write has written no document, and there is nothing to
    grade. It is NOT a narrative opening and must not be scored as one.
    """
    if out.get("cut"):
        return out["cut"]
    if not out.get("turns"):
        return "no assistant turns"
    if not out.get("file"):
        return "the session wrote no %s" % REPORT_NAME
    return ""


def keep(cut, wrote, out_path):
    """(where the report is copied, what `file` reports) — the run's report, filed.

    A CUT RUN'S REPORT IS KEPT ASIDE, NOT UNDER THE SIDE'S NAME. Measured on #260's before
    side: `error_max_budget_usd` arrived AFTER the session had written a complete report, so the
    file existed and the run was still not a measurement. Nothing here can tell a finished
    document from one the budget stopped mid-sentence, and grading it is the guess this
    instrument must not make.

    Left under the side's name it did worse than not being graded: the loop's overwrite guard
    saw a report for `--label before` and refused the re-run, so a cut side could not be
    measured again without deleting files by hand. `.cut` keeps it readable and out of the way.
    """
    if not wrote:
        return "", ""
    if cut:
        return out_path + ".cut", ""
    return out_path, out_path


def with_retry(attempt, backoff, sleep=time.sleep, say=None):
    """One attempt; if it measured nothing, say so, wait the stated back-off, try once more.

    ONE retry, then stop — tools/skill-probe.py's rule and its reason: a probe is billed per
    attempt and a rate limit does not clear on a schedule this tool can know. The second
    failure travels out as `unusable` so the loop can abandon rather than tally a column
    position that was never measured.
    """
    say = say or _warn
    out = attempt()
    out["retried"] = ""
    out["unusable"] = unusable(out)
    if not out["unusable"]:
        return out
    reason = out["unusable"]
    say("report-shape-probe: this run measured nothing (%s). Backing off %ss, then ONE retry."
        % (reason, backoff))
    sleep(backoff)
    out = attempt()
    out["retried"] = reason
    out["unusable"] = unusable(out)
    if out["unusable"]:
        say("report-shape-probe: the retry measured nothing either (%s). Stopping — this run "
            "is not a measurement and must not be graded." % out["unusable"])
    else:
        say("report-shape-probe: the retry measured a run; reporting it.")
    return out


def attempt():
    """One billed session in a temp directory, read to its end, and the report it wrote kept.

    THE DEADLINE IS A WATCHDOG, NOT A CHECK IN THE LOOP. scan()'s clock only advances when a
    line arrives, so a session that goes silent — a CLI blocking on a rate-limit retry, seen
    from here — never reaches it. A timer that kills the child is the only thing that ends a
    blocked read. scan()'s own check stays for the other shape, a stream that keeps talking.
    """
    brief = io.open(BRIEF_PATH, encoding="utf-8").read()
    cmd = ["claude", "-p", brief, "--output-format", "stream-json", "--verbose",
           "--permission-mode", "acceptEdits", "--max-budget-usd", BUDGET,
           "--allowedTools", ALLOW, "--disallowedTools", DENY]
    cwd = tempfile.mkdtemp(prefix="report-shape-probe-")
    p = subprocess.Popen(cmd, cwd=cwd, stdout=subprocess.PIPE, stderr=subprocess.DEVNULL,
                         stdin=subprocess.DEVNULL, text=True, encoding="utf-8",
                         errors="replace")
    expired = []

    def watchdog():
        expired.append(True)
        try:
            p.kill()
        except Exception:
            pass

    wd = threading.Timer(TIMEOUT, watchdog)
    wd.daemon = True
    wd.start()
    try:
        out = scan(p.stdout, TURNCAP, clock=time.time, timeout=TIMEOUT, started=time.time())
        # A killed child's stream just ends, which scan() reads as "no result line". Saying
        # which it was is the difference between an operator waiting and one backing off.
        if expired:
            out["cut"] = "timeout"
    finally:
        wd.cancel()
        try:
            p.terminate()
            p.wait(timeout=10)
        except Exception:
            try:
                p.kill()
            except Exception:
                pass
    # The report is copied out of the temp directory BEFORE anything grades it, and it is kept
    # whatever the verdict. #158's and #160's billed runs could not be re-scored when their
    # numbers had to be revisited, because the raw output died with the temp directory.
    src = os.path.join(cwd, REPORT_NAME)
    dest, out["file"] = keep(out["cut"], os.path.isfile(src), OUT_PATH)
    if dest:
        os.makedirs(os.path.dirname(os.path.abspath(dest)) or ".", exist_ok=True)
        shutil.copyfile(src, dest)
    shutil.rmtree(cwd, ignore_errors=True)
    return out


def selftest():
    """The parts that do not bill: which runs are measurements, and where a report is filed.

    Everything else here needs a billed session and is not covered — tools/report-shape-probe.sh
    selftest covers the loop that reads this file's JSON. Both run in tests/verify-all.sh.
    """
    n = [0, 0]

    def check(name, got, want):
        n[0] += 1
        if got == want:
            print("  ok    %s" % name)
        else:
            n[1] += 1
            print("  FAIL  %s" % name)
            print("        got %r, want %r" % (got, want))

    print("report-shape-probe.py selftest — which runs are measurements, and where a report goes")
    print()
    good = {"cut": "", "turns": 3, "file": "/o/r.md"}
    check("a run that answered and wrote a report is a measurement", unusable(good), "")
    check("a cut run is not, and says which cut",
          unusable(dict(good, cut="error_max_budget_usd")), "error_max_budget_usd")
    check("a session with no assistant turn is not",
          unusable(dict(good, turns=0)), "no assistant turns")
    # The shape unique to this instrument. A session that answered in prose and never called
    # Write produced no document: there is nothing to grade, and grading nothing lands in every
    # column as a fail.
    check("a run that wrote no report is not",
          unusable(dict(good, file="")), "the session wrote no report.md")
    # `cut` is read BEFORE the missing file, so a budget-killed run is reported as the budget
    # and not as a session that declined to write. The operator raises the budget; they do not
    # go looking for a skill that did not fire.
    check("a cut run reports the cut, not the missing file",
          unusable(dict(good, cut="timeout", file="")), "timeout")

    check("a measured run's report is kept under the side's name",
          keep("", True, "/o/before-run1.md"), ("/o/before-run1.md", "/o/before-run1.md"))
    check("a cut run's report is kept aside and reported as no file",
          keep("error_max_budget_usd", True, "/o/before-run1.md"), ("/o/before-run1.md.cut", ""))
    check("a run that wrote nothing files nothing",
          keep("", False, "/o/before-run1.md"), ("", ""))

    # The back-off is asserted without waiting for it, and without opening a session.
    waited, said = [], []
    tries = [dict(good, cut="error_during_execution"), dict(good)]
    out = with_retry(lambda: dict(tries.pop(0)), 60, sleep=waited.append, say=said.append)
    check("a cut run is retried once and the retry is what is reported",
          (out["unusable"], out["retried"], waited), ("", "error_during_execution", [60]))
    tries = [dict(good, cut="a"), dict(good, cut="b")]
    out = with_retry(lambda: dict(tries.pop(0)), 60, sleep=waited.append, say=said.append)
    check("a second failure is reported, never retried again",
          (out["unusable"], out["retried"], len(waited)), ("b", "a", 2))

    print()
    print("%d cases, %d passed, %d failed" % (n[0], n[0] - n[1], n[1]))
    return 1 if n[1] else 0


if SELFTEST:
    raise SystemExit(selftest())

print(json.dumps(with_retry(attempt, BACKOFF)))
