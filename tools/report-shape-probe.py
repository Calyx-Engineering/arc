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

BRIEF_PATH = sys.argv[1]
OUT_PATH = sys.argv[2]

BUDGET = os.environ.get("RSP_BUDGET", "0.60")
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
    out["file"] = ""
    if os.path.isfile(src):
        os.makedirs(os.path.dirname(os.path.abspath(OUT_PATH)) or ".", exist_ok=True)
        shutil.copyfile(src, OUT_PATH)
        out["file"] = OUT_PATH
    shutil.rmtree(cwd, ignore_errors=True)
    return out


print(json.dumps(with_retry(attempt, BACKOFF)))
