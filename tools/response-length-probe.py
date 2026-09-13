# response-length-probe.py — the live-run half of tools/response-length.sh --probe, and of
# tools/topic-numbering.sh --probe.
#
# Replays a case's turns as ONE conversation against the plugin as installed, and records what
# came back. Nothing here is length-specific: it produces the replies, and the scorer asks the
# question — tools/response-length.py counts their words, tools/topic-numbering.py reads their
# section labels. A second copy would be a second place for the allow/deny lists and the
# cut-detection to drift, so both probes call this one.
#
# WHY ONE SESSION AND NOT ELEVEN. The defect is that a budget stated on turn 1 stops being
# applied by turn 5. Eleven independent single-turn runs cannot see that at all — each one
# would carry the budget in its own first message. The whole measurement is the decay, so the
# turns have to share a session. --session-id opens it, --resume continues it.
#
# READ-ONLY TOOLS, ON PURPOSE. The turns came from a session doing real work in this repo, so
# a probe with no tools answers half of them with "I cannot see that" — replies short enough
# to score as held while proving nothing. Read, Grep and Glob let those turns be answered.
# Every writing and network tool is denied: a probe must not commit, push or edit.
#
# TURNS IT CANNOT ANSWER ARE NOT HIDDEN. A fresh session does not have the original
# conversation's state, so some replies will still be thin. The scorer's floor puts those in
# their own column rather than counting them as a pass.
#
# IT COSTS MONEY, and the cost grows per turn as the conversation does. RL_PROBE_BUDGET caps
# each turn. This is why --probe is not in tests/verify-all.sh.
#
# A RATE LIMIT IS NOT A MISS, AND #213 LOST TWO BILLED 11-TURN RUNS TO THE DIFFERENCE — every
# turn came back `CUT`, one at $0.000, nothing warned and nothing retried. #269 fixed the same
# shape in tools/skill-probe.py; this file is the runner #213 actually lost its money through,
# named as the follow-on there because the box that issue closed named the other file.
#
# THE RETRY UNIT IS THE CASE, NOT THE TURN. A case's turns share one session (--session-id,
# then --resume), so a turn that comes back cut leaves that session dead — there is nothing a
# per-turn retry could resume. run_case() stops the moment a turn is cut, before the next one
# is billed, and with_retry() re-runs the WHOLE case once, fresh session, after a stated
# back-off. A second cut stops for good; ported from skill-probe.py's unusable()/with_retry()
# rather than a second copy of the rule.
#
# THE DEADLINE IS A WATCHDOG, NOT A CHECK IN THE LOOP. The old in-loop check only advanced when
# a line ARRIVED, so a CLI blocked on its own rate-limit retry never reached it — the read
# blocks forever and the whole probe hangs with nothing printed. A threading.Timer that kills
# the child is the only thing that ends a blocked read; the in-loop check stays for the other
# shape, a stream that keeps talking past the deadline.
#
#   RL_PROBE_BACKOFF=60   seconds to wait before the one case-level retry
#
#   python tools/response-length-probe.py selftest    the stop-and-retry rule, no network, no billing
import io
import json
import os
import subprocess
import sys
import tempfile
import threading
import time
import uuid

try:
    sys.stdout.reconfigure(encoding="utf-8", errors="replace")
except Exception:
    pass

BUDGET = os.environ.get("RL_PROBE_BUDGET", "0.60")
TIMEOUT = int(os.environ.get("RL_PROBE_TIMEOUT", "600"))
BACKOFF = int(os.environ.get("RL_PROBE_BACKOFF", "60"))
CWD = os.environ.get("RL_PROBE_CWD") or os.getcwd()

# WHICH COPY OF THE PLUGIN THE PROBE MEASURES — #262.
#
# Without these, a probe measures whatever `claude plugin install` last wrote into
# ~/.claude/plugins/cache, and that is a machine-wide singleton. Two consequences, and the
# second is the one that cost this issue its design:
#
#   The candidate has to be installed to be measured, so comparing two wordings means
#   installing one, running, installing the other, running — and the marketplace entry for
#   this plugin is a DIRECTORY source pointing at the main checkout, so a worktree cannot
#   install its own branch at all without first pushing it through the main tree.
#
#   Every other session on the machine reads the same cache. Four arc worktrees were live
#   while #262 ran. Installing a candidate skill to measure it changes how they all behave,
#   and any of them reloading the plugin mid-run silently swaps the arm being measured.
#
# --plugin-dir loads a plugin from a directory FOR ONE SESSION. RL_PROBE_SETTINGS carries a
# settings file disabling the installed copy of the same plugin, so the session sees one
# chat-response rather than two. Verified 2026-09-11 from this worktree: with a marker word
# prepended to the arm's `description:`, the session quoted the marker back.
PLUGIN_DIR = os.environ.get("RL_PROBE_PLUGIN_DIR", "")
SETTINGS = os.environ.get("RL_PROBE_SETTINGS", "")

# Comma-separated, as ONE argument each. --allowedTools and --disallowedTools are both
# variadic, so two of them space-separated on the same command line run together and the
# second flag's names get read as the first's. The comma form has no such edge.
ALLOW = "Read,Grep,Glob,Skill"
DENY = "Write,Edit,NotebookEdit,WebFetch,WebSearch,Task,Agent,Bash,Artifact"


def turns(d):
    tdir = os.path.join(d, "turns")
    out = []
    for f in sorted(os.listdir(tdir), key=lambda x: int(x.split(".")[0])):
        if f.endswith(".md"):
            out.append((int(f.split(".")[0]),
                        io.open(os.path.join(tdir, f), encoding="utf-8").read()))
    return out


def run(prompt, session, first):
    cmd = ["claude", "-p", prompt, "--output-format", "stream-json", "--verbose",
           "--permission-mode", "manual", "--max-budget-usd", BUDGET]
    cmd += ["--session-id", session] if first else ["--resume", session]
    cmd += ["--allowedTools", ALLOW, "--disallowedTools", DENY]
    # Both flags go on EVERY turn, not only the first. --resume continues a conversation, it
    # does not restore the flags the session was opened with, so a second turn without them
    # would answer out of the installed plugin while the first answered out of the arm — and
    # the decay this instrument exists to measure would be a change of skill halfway through.
    if PLUGIN_DIR:
        cmd += ["--plugin-dir", PLUGIN_DIR]
    if SETTINGS:
        cmd += ["--settings", SETTINGS]

    p = subprocess.Popen(cmd, cwd=CWD, stdout=subprocess.PIPE, stderr=subprocess.DEVNULL,
                         stdin=subprocess.DEVNULL, text=True, encoding="utf-8",
                         errors="replace")
    # A blocked read never reaches an in-loop clock check — see the header. Only a timer that
    # can kill the child from outside the read ends it.
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
    # Skill fires are recorded per turn, not because firing is the measurement — #155 settled
    # that it is neither necessary nor sufficient — but because a rule that lives in a skill
    # BODY is only in context on the turns the skill fired. Without this, a fix that moved
    # nothing cannot be told apart from a fix that was never loaded.
    blocks, fires, cost, cut = [], [], None, ""
    try:
        for line in p.stdout:
            line = line.strip()
            if not line.startswith("{"):
                continue
            try:
                o = json.loads(line)
            except Exception:
                continue
            if o.get("type") == "result":
                cost = o.get("total_cost_usd")
                # A turn stopped by --max-budget-usd or a turn cap returns a TRUNCATED reply,
                # and a truncated reply is short. Scored as-is it reads as the budget being
                # held, which is the one wrong answer this instrument must not give. The
                # subtype travels with the reply so the scorer can drop the turn instead.
                subtype = o.get("subtype") or ""
                if subtype and subtype != "success":
                    cut = subtype
                elif o.get("is_error"):
                    cut = "error"
                break
            if o.get("type") != "assistant":
                continue
            for b in (o.get("message") or {}).get("content") or []:
                if not isinstance(b, dict):
                    continue
                if b.get("type") == "text" and b.get("text", "").strip():
                    blocks.append(b["text"].strip())
                elif b.get("type") == "tool_use" and b.get("name") == "Skill":
                    sk = ((b.get("input") or {}).get("skill") or "").split(":")[-1]
                    if sk and sk not in fires:
                        fires.append(sk)
        else:
            # The stream ran out with no `result` line — the CLI died, or the watchdog killed
            # it. A blocked-then-killed read looks the same here; `expired` below says which.
            if not cut:
                cut = "no result line"
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
    if expired:
        cut = "timeout"
    # Everything the assistant said across the turn, which is what the user reads. The scorer
    # strips tables, code and headings before counting.
    return "\n".join(blocks), cost, fires, cut


def run_case(turn_list, run_turn=run):
    """Run every turn of one case in a fresh session, stopping the moment one comes back cut.

    The retry unit is the case: turns share a session, so a turn that comes back cut leaves
    that session dead and there is nothing a per-turn retry could resume. Stopping here is what
    keeps the remaining turns from being billed into the same limit — #213 lost two 11-turn
    runs because nothing did.
    """
    session = str(uuid.uuid4())
    replies, total, cut = {}, 0.0, ""
    for turn, prompt in turn_list:
        text, cost, fires, tcut = run_turn(prompt, session, not replies)
        replies[str(turn)] = {"text": text, "cut": tcut, "fired": fires}
        if cost:
            total += cost
        print("    t%-4d %5d chars   $%-6s  fired: %-16s %s"
              % (turn, len(text), ("%.3f" % cost) if cost else "?",
                 ", ".join(fires) or "—", ("CUT: " + tcut) if tcut else ""),
              flush=True)
        if tcut:
            cut = tcut
            break
    return {"session": session, "replies": replies, "total": total, "cut": cut}


def _warn(message):
    print(message, file=sys.stderr, flush=True)


def unusable(out):
    """Why this case's run is not a measurement, or "" if it is one.

    A cut turn stops run_case() before the remaining turns are billed, which leaves the case
    with an incomplete session rather than a wrong one — it must be retried, not scored as
    though the missing turns held short replies.
    """
    return out.get("cut", "")


def with_retry(attempt, backoff, sleep=time.sleep, say=None):
    """One attempt at a whole case; if it measured nothing, say so, back off, try once more.

    ONE retry, then stop. A probe is billed per attempt and a rate limit does not clear on a
    schedule this tool can know, so retrying until it works is a way to spend money without a
    bound. Ported from tools/skill-probe.py's own with_retry() rather than a second copy of the
    rule — `sleep` and `say` are injected there for the same reason: the back-off has to be
    assertable without waiting for it.
    """
    say = say or _warn
    out = attempt()
    out["retried"] = ""
    out["unusable"] = unusable(out)
    if not out["unusable"]:
        return out
    reason = out["unusable"]
    say("response-length-probe: this case measured nothing past turn %s (%s). Backing off %ss, "
        "then ONE retry." % (len(out["replies"]), reason, backoff))
    sleep(backoff)
    out = attempt()
    out["retried"] = reason
    out["unusable"] = unusable(out)
    if out["unusable"]:
        say("response-length-probe: the retry measured nothing either (%s). Stopping — this "
            "case is not a measurement." % out["unusable"])
    else:
        say("response-length-probe: the retry completed; reporting it.")
    return out


def selftest():
    """The case-level stop-and-retry rule, against the shape #213 actually produced.

    No `claude`, no network, no billing — a canned `run_turn` stands in for the subprocess so
    the loop-stop and the retry can be asserted without a live session.
    """
    def canned(*results):
        seq = list(results)
        return lambda prompt, session, first: seq.pop(0)

    def canned_attempts(*outs):
        seq = list(outs)
        return lambda: seq.pop(0)

    def trace():
        ev = []
        return ev, (lambda n: ev.append(("slept", n))), (lambda m: ev.append(("said", m)))

    ran = passed = failed = 0

    def check(name, got, want):
        nonlocal ran, passed, failed
        ran += 1
        if got == want:
            passed += 1
            print("  ok    " + name)
        else:
            failed += 1
            print("  FAIL  " + name)
            print("        wanted " + repr(want) + ", got " + repr(got))

    print("response-length-probe selftest — the case-level stop-and-retry rule")
    print("")

    turn_list = [(1, "p1"), (2, "p2"), (3, "p3")]

    rt = canned(("reply one", 0.1, [], ""), ("", 0.0, [], "error_during_execution"))
    out = run_case(turn_list, run_turn=rt)
    check("a cut turn stops the loop before the next turn is billed",
          (sorted(out["replies"].keys()), out["cut"]), (["1", "2"], "error_during_execution"))

    rt = canned(("r1", 0.1, [], ""), ("r2", 0.1, [], ""), ("r3", 0.1, [], ""))
    out = run_case(turn_list, run_turn=rt)
    check("a clean case runs every turn", (sorted(out["replies"].keys()), out["cut"]),
          (["1", "2", "3"], ""))

    check("a cut case is unusable", unusable({"cut": "timeout", "replies": {}}), "timeout")
    check("a clean case is usable", unusable({"cut": "", "replies": {}}), "")

    good = {"replies": {"1": {}}, "total": 0.1, "cut": ""}
    bad = {"replies": {"1": {}}, "total": 0.0, "cut": "error_during_execution"}

    ev, sleep, say = trace()
    out = with_retry(lambda: dict(good), 60, sleep=sleep, say=say)
    check("a case that measured something is not retried",
          (out["retried"], out["unusable"], ev), ("", "", []))

    ev, sleep, say = trace()
    out = with_retry(canned_attempts(dict(bad), dict(good)), 60, sleep=sleep, say=say)
    check("a cut case is retried once and the retry is what gets reported",
          (out["cut"], out["unusable"], out["retried"]), ("", "", "error_during_execution"))
    ev = ev + [("", "")] * 2
    check("the back-off is stated, with its reason, and only THEN waited out",
          ([k for k, _ in ev[:2]], ev[1][1],
           "60" in str(ev[0][1]), "error_during_execution" in str(ev[0][1])),
          (["said", "slept"], 60, True, True))

    ev, sleep, say = trace()
    out = with_retry(canned_attempts(dict(bad), dict(bad)), 60, sleep=sleep, say=say)
    check("a second cut case stops and reports instead of retrying again",
          (out["unusable"], [k for k, _ in ev]),
          ("error_during_execution", ["said", "slept", "said"]))

    # main() is the wiring nothing above touches: argv parsing, the JSON read-modify-write, the
    # summary line. A stubbed case_runner exercises it with no `claude` and no case directory —
    # a NameError or a wrong key here shipped once already with every other check green.
    tmp_out = os.path.join(tempfile.gettempdir(),
                            "rl-probe-selftest-%d.json" % os.getpid())
    try:
        stubbed = lambda: {"session": "abcdef12", "replies":
                            {"1": {"text": "hi", "cut": "", "fired": []}},
                            "total": 0.1, "cut": ""}
        main(["ignored-case-dir", "mycase", tmp_out], case_runner=stubbed)
        written = json.load(io.open(tmp_out, encoding="utf-8"))
        check("main() writes the stubbed case's replies to OUT_PATH",
              written.get("mycase", {}).get("1", {}).get("text"), "hi")
    finally:
        try:
            os.remove(tmp_out)
        except Exception:
            pass

    print("")
    print(str(ran) + " cases, " + str(passed) + " passed, " + str(failed) + " failed")
    return 0 if failed == 0 else 1


def main(argv, case_runner=None):
    """Run one case end to end: replay its turns, retry once on a cut, write OUT_PATH.

    `case_runner` is injected so selftest() can exercise this wiring — the retry, the JSON
    read-modify-write, the summary line — without a live `claude` session. It defaults to the
    real path, one full pass over the case's turns.
    """
    case_dir, case_name, out_path = argv[0], argv[1], argv[2]
    case_runner = case_runner or (lambda: run_case(turns(case_dir)))
    out = with_retry(case_runner, BACKOFF)

    existing = {}
    if os.path.exists(out_path):
        try:
            existing = json.load(io.open(out_path, encoding="utf-8"))
        except Exception:
            existing = {}
    existing[case_name] = out["replies"]
    json.dump(existing, io.open(out_path, "w", encoding="utf-8"), ensure_ascii=False, indent=1)
    print("    session %s   $%.3f total%s"
          % (out["session"][:8], out["total"],
             ("   UNUSABLE: " + out["unusable"]) if out["unusable"] else ""),
          flush=True)
    return out


if len(sys.argv) > 1 and sys.argv[1] == "selftest":
    raise SystemExit(selftest())

main(sys.argv[1:])
