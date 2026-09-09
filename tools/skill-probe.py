# skill-probe.py — the running half of tools/skill-probe.sh. Not run directly, except for
# `selftest` below, which tools/verify-all.sh runs.
#
# Re-runs a case's prompt.md against the plugin AS IT IS ON DISK NOW and records which skills
# fired. tools/skill-cases.py scores frozen transcripts and therefore cannot see a description
# change at all; this can. It is the instrument #156 said did not exist on this machine.
#
# HOW A PROBE ENDS. The grader asks whether the skill was invoked BEFORE the answer. Reading
# stops at the session's `result` line, at PROBE_TURN_CAP turns, at PROBE_TIMEOUT seconds, or
# when the stream runs out without a `result` line — whichever comes first — and everything
# found up to there is reported. Nothing is filtered out afterwards; the paragraph two below is
# why nothing needs to be. The last two endings are not measurements and are marked `cut`.
#
# A TEXT-ONLY TURN IS NOT PROOF OF AN ANSWER, AND ASSUMING IT WAS COST #252 ITS FIRST READING.
# `superpowers:using-superpowers` is injected into every session on this machine by a
# SessionStart hook and instructs the model to ANNOUNCE "Using [skill] to [purpose]" before
# invoking it. That announcement is a text-only turn, and an earlier draft broke on it and
# recorded a miss for a skill that fired on the very next turn — one probe answered
# "Using arc:handoff to read handoff and run staleness checks" and scored handoff 0/1.
#
# The discriminator cannot be read off the turn itself; it is what comes next, so reading
# continues instead of breaking. It is close to free — when the text really is the answer,
# `claude -p` emits `result` immediately after it, so no extra turn is billed.
#
# NOTHING NEEDS CUTTING BACK AFTERWARDS, AND THE REASON IS THE `-p` STREAM ITSELF. The obvious
# worry about reading further is that a Skill call AFTER the answer would now be counted, which
# is not what the grader asks. It cannot arise: `claude -p` is one-shot and terminates at the
# answer, so a text-only turn followed by more tool calls is a preamble every time. There is no
# structural difference between "announced, then invoked" and "answered, then kept working" —
# only the second never occurs here. Machinery to tell them apart was written for this file and
# removed as dead; it could not have fired on any of #252's 27 dumps, none of which has the
# shape. `answered` is therefore reported and not acted on.
#
# IT DOES NOT STOP AT THE FIRST FIRE. An earlier draft did, and it was wrong in exactly the
# case this suite is about — a prompt that names Camp and asks for a handoff read wants BOTH,
# and stopping at `camp` recorded `handoff` as a miss it never gave the model a chance to
# make. `load-all-skills` expects eight or more and would have scored one. Every Skill call
# up to the answer is collected.
#
# IT CAN KEEP THE RAW STREAM. Set PROBE_TRANSCRIPT to a path and every stream-json line is
# written there as it is read. The `fired` list says a skill was invoked; it cannot say what
# the session then READ, and #252 asks exactly that — whether the staleness checks travelled
# with the firing.
#
# THE STREAM DOES NOT CONTAIN THE SKILL TEXT, which was measured rather than assumed: the
# `Skill` tool_result is 28 bytes, `Launching skill: arc:handoff`, and the session's own
# `.jsonl` under ~/.claude/projects/ holds no line matching any of the seven staleness checks
# either. What the dump does carry is the QUALIFIED name, and that names the file.
# tools/probe-handoff-checks.sh takes it from here.
#
# Off unless the variable is set: a probe that always wrote transcripts would scatter session
# text across the disk, and run-instructions §5 keeps transcripts local.
#
# A RATE LIMIT IS NOT A MISS, AND #213 LOST TWO BILLED RUNS TO THE DIFFERENCE. Both came back
# with every turn `CUT`, one at $0.000. Nothing warned and nothing retried, because the shape a
# killed session leaves here — an empty `fired` list — is the same shape an honest miss leaves.
# The `result` line is the only place they differ, so its `subtype` and `is_error` are now read
# alongside its cost and reported as `cut`. A run that is `cut`, or that produced no assistant
# turn at all, is `unusable`: it says so on stderr, waits PROBE_BACKOFF seconds, and runs ONCE
# more. A second failure stops and reports rather than retrying — a probe is billed per attempt
# and a rate limit does not clear on a schedule this tool can know. `unusable` travels out in
# the JSON so tools/skill-probe.sh abandons the case instead of tallying a miss nobody measured.
#
#   PROBE_BACKOFF=60    seconds to wait before the one retry
#   PROBE_TIMEOUT=300   seconds before the child is killed and the run marked `cut`
#
#   python tools/skill-probe.py selftest    the scan loop, no network, no billing
import io, json, os, subprocess, sys, threading, time, tempfile

sys.stdout.reconfigure(encoding="utf-8", errors="replace")


def scan(lines, turncap, sink=None, clock=None, timeout=None, started=None):
    """Read a stream-json stream and decide what fired before the answer.

    Split out of the run loop so it can be exercised with canned lines — the stop condition is
    the part of this tool that was wrong, and a defect that only appears against a live billed
    session is a defect with no regression test.

    `lines` is any iterable of raw strings. `sink` is an open file the raw lines are copied to.
    """
    fires, qualified, turns, cost, answered, cut = [], [], 0, None, False, ""
    for line in lines:
        if clock and timeout is not None and started is not None and clock() - started > timeout:
            cut = "timeout"
            break
        line = line.strip()
        if not line.startswith("{"):
            continue
        # Copied BEFORE the type filter, so the `user` messages carrying tool_result are kept.
        # Filtering first is how a transcript ends up holding every assistant turn and none of
        # what came back to it.
        if sink:
            print(line, file=sink)
        try:
            o = json.loads(line)
        except Exception:
            continue
        if o.get("type") == "result":
            cost = o.get("total_cost_usd")
            # A run the CLI stopped for its own reasons — a rate limit, a spent budget, an
            # error mid-execution — returns a truncated session. Its `fired` list is empty for
            # a reason that has nothing to do with the model's decision, and that is exactly
            # what an honest miss looks like. The subtype is the only place the two differ.
            subtype = o.get("subtype") or ""
            if subtype and subtype != "success":
                cut = subtype
            elif o.get("is_error"):
                cut = "error"
            break
        if o.get("type") != "assistant":
            continue
        turns += 1
        blocks = (o.get("message") or {}).get("content") or []
        tool_uses = [b for b in blocks if isinstance(b, dict) and b.get("type") == "tool_use"]
        for b in tool_uses:
            if b.get("name") == "Skill":
                raw = (b.get("input") or {}).get("skill") or ""
                sk = raw.split(":")[-1]
                if sk and sk not in fires:
                    fires.append(sk)
                if raw and raw not in qualified:
                    qualified.append(raw)
        # `answered` is reported, never acted on — see the header. It says one narrow thing:
        # whether the LAST assistant turn read was prose with no tool call. It is not a
        # completion flag and must not be read as one; a run killed at its turn cap can end on
        # prose, and a run that read its `result` line can end on a turn mixing text with a
        # tool call. `cost` is the completion signal — it is None unless a `result` was read.
        if tool_uses:
            answered = False
        elif any(b.get("type") == "text" and b.get("text", "").strip() for b in blocks):
            answered = True
        if turns >= turncap:
            break
    else:
        # THE STREAM RAN OUT WITH NO `result` LINE. Every deliberate ending above breaks: the
        # result line, the turn cap, the timeout. Falling off the end instead means the CLI
        # stopped talking — it died, or it was killed — and the turns collected so far are a
        # fragment of a session, not a session. Without this the fragment is indistinguishable
        # from a run that answered and invoked nothing, which is the exact confusion #269 is
        # about. The turn cap is NOT this: a capped run stopped because this tool said so.
        cut = "no result line"
    return {"fired": fires, "qualified": qualified, "turns": turns,
            "answered": answered, "cost": cost, "cut": cut}


def _warn(message):
    """Warnings go to stderr; stdout is the JSON tools/skill-probe.sh parses."""
    print(message, file=sys.stderr, flush=True)


def unusable(out):
    """Why this run is not a measurement, or "" if it is one.

    Two shapes, both from #213's lost pair: the `result` line says the CLI stopped the session,
    or the session produced no assistant turn at all. A run that answered and invoked nothing
    is neither — it is a MISS, the thing this instrument exists to record, and must never end
    up here.
    """
    if out.get("cut"):
        return out["cut"]
    if not out.get("turns"):
        return "no assistant turns"
    return ""


def with_retry(attempt, backoff, sleep=time.sleep, say=None):
    """One attempt; if it measured nothing, say so, wait the stated back-off, try once more.

    ONE retry, then stop. A probe is billed per attempt and a rate limit does not clear on a
    schedule this tool can know, so retrying until it works is a way to spend money without
    a bound. The second failure is reported, not retried — `unusable` travels out in the JSON
    so tools/skill-probe.sh can abandon the case rather than tally a 0 that was never measured.

    `sleep` and `say` are injected so the back-off is assertable without waiting for it.
    """
    say = say or _warn
    out = attempt()
    out["retried"] = ""
    out["unusable"] = unusable(out)
    if not out["unusable"]:
        return out
    reason = out["unusable"]
    say("skill-probe: this run measured nothing (%s). Backing off %ss, then ONE retry."
        % (reason, backoff))
    sleep(backoff)
    out = attempt()
    out["retried"] = reason
    out["unusable"] = unusable(out)
    if out["unusable"]:
        say("skill-probe: the retry measured nothing either (%s). Stopping — this run is not "
            "a measurement and must not be scored as a miss." % out["unusable"])
    else:
        say("skill-probe: the retry measured a run; reporting it.")
    return out


def selftest():
    """The stop condition, against the shapes that actually occur.

    The announce case is the regression: `superpowers:using-superpowers` is injected by a
    SessionStart hook on this machine and tells the model to announce before invoking, so a
    probe that treats the first text-only turn as the answer reports a miss for a skill that
    fires on the very next turn. That is what it did, on a real run, before this test existed.
    """
    A_SKILL = '{"type":"assistant","message":{"content":[{"type":"tool_use","name":"Skill","input":{"skill":"arc:handoff"}}]}}'
    A_CAMP = '{"type":"assistant","message":{"content":[{"type":"tool_use","name":"Skill","input":{"skill":"arc:camp"}}]}}'
    A_TEXT = '{"type":"assistant","message":{"content":[{"type":"text","text":"Using arc:handoff to read handoff."}]}}'
    A_ANSWER = '{"type":"assistant","message":{"content":[{"type":"text","text":"The branch is clean."}]}}'
    A_EMPTY = '{"type":"assistant","message":{"content":[{"type":"text","text":"   "}]}}'
    A_BASH = '{"type":"assistant","message":{"content":[{"type":"tool_use","name":"Bash","input":{"command":"ls"}}]}}'
    RESULT = '{"type":"result","total_cost_usd":0.25}'
    SYSTEM = '{"type":"system","subtype":"init"}'
    JUNK = 'not json at all'

    cases = [
        ("an announcement then a firing is a firing",
         [A_TEXT, A_SKILL, RESULT], {"fired": ["handoff"], "answered": False}),
        ("a plain answer with nothing before it is a miss",
         [A_ANSWER, RESULT], {"fired": [], "answered": True}),
        ("a firing then an answer is a firing",
         [A_SKILL, A_ANSWER, RESULT], {"fired": ["handoff"], "answered": True}),
        ("two skills on one turn are both kept",
         [A_SKILL, A_CAMP, A_ANSWER, RESULT], {"fired": ["handoff", "camp"], "answered": True}),
        # The empty turn must come LAST. With a Skill turn after it, `answered` is reset by
        # that turn and the case passes whether or not whitespace is treated as prose — it
        # named the guard without touching it.
        ("a whitespace-only turn is not an answer",
         [A_SKILL, A_EMPTY, RESULT], {"fired": ["handoff"], "answered": False}),
        ("another tool is not a firing",
         [A_BASH, A_ANSWER, RESULT], {"fired": [], "answered": True}),
        ("non-assistant lines are not turns",
         [SYSTEM, SYSTEM, A_SKILL, RESULT], {"fired": ["handoff"], "turns": 1}),
        ("junk lines are skipped, not fatal",
         [JUNK, A_SKILL, RESULT], {"fired": ["handoff"]}),
        ("the qualified name keeps its marketplace",
         [A_SKILL, RESULT], {"qualified": ["arc:handoff"]}),
        ("the cost comes off the result line",
         [A_SKILL, RESULT], {"cost": 0.25}),
        # `answered` reports the shape of the LAST turn read, and nothing else. These two pin
        # what it is not, because the tempting reading — "the run reached its answer" — is
        # false in both directions and a later edit acting on it would be scoring a different
        # thing. `cost` is what says a `result` line was read.
        ("a run killed at its turn cap can still end on prose",
         [A_TEXT, A_SKILL, A_ANSWER, RESULT], {"answered": True, "cost": None}, 1),
        ("a completed run can end on a turn that called a tool",
         [A_SKILL, RESULT], {"answered": False, "cost": 0.25}, 4),
    ]

    run = passed = failed = 0
    print("skill-probe selftest — the stop condition")
    print("")
    for case in cases:
        # A case is (name, lines, want) and may carry a fourth element, the turn cap, for the
        # two cases that are about the cap itself.
        name, lines, want = case[0], case[1], case[2]
        cap = case[3] if len(case) > 3 else 4
        run += 1
        got = scan(lines, turncap=cap)
        wrong = {k: (v, got.get(k)) for k, v in want.items() if got.get(k) != v}
        if wrong:
            failed += 1
            print("  FAIL  " + name)
            for k, (w, g) in wrong.items():
                print("        " + k + ": wanted " + repr(w) + ", got " + repr(g))
        else:
            passed += 1
            print("  ok    " + name)

    # The turn cap is the only bound on a session that never stops calling tools.
    run += 1
    got = scan([A_BASH] * 20, turncap=3)
    if got["turns"] == 3:
        passed += 1
        print("  ok    the turn cap bounds a session that only ever calls tools")
    else:
        failed += 1
        print("  FAIL  turn cap — wanted 3 turns, got " + repr(got["turns"]))

    # A RUN DESTROYED BY A RATE LIMIT IS NOT A MISS, AND #213 PAID TO LEARN IT.
    #
    # Two billed runs there came back with every turn `CUT`, one at $0.000. Nothing warned and
    # nothing retried. The shape a rate limit leaves here is an empty `fired` list, which is
    # what an honest miss looks like too — so the two have to be told apart on the `result`
    # line, not on the tally. The last case below is the one that matters in the other
    # direction: a session that answered without invoking anything is a MISS and must keep
    # being reported as one.
    RESULT_CUT = '{"type":"result","subtype":"error_during_execution","total_cost_usd":0.0}'
    RESULT_ERR = '{"type":"result","subtype":"success","is_error":true,"total_cost_usd":0.0}'

    def check(name, got, want):
        nonlocal run, passed, failed
        run += 1
        if got == want:
            passed += 1
            print("  ok    " + name)
        else:
            failed += 1
            print("  FAIL  " + name)
            print("        wanted " + repr(want) + ", got " + repr(got))

    check("a non-success result subtype marks the run cut",
          scan([A_SKILL, RESULT_CUT], turncap=4)["cut"], "error_during_execution")
    check("a success result is not cut",
          scan([A_SKILL, RESULT], turncap=4)["cut"], "")
    check("is_error marks the run cut even when the subtype says success",
          scan([A_SKILL, RESULT_ERR], turncap=4)["cut"], "error")
    check("a cut run measured nothing",
          unusable(scan([A_SKILL, RESULT_CUT], turncap=4)), "error_during_execution")
    check("a run with no assistant turns measured nothing",
          unusable(scan([RESULT], turncap=4)), "no assistant turns")
    check("a run that fired and completed measured something",
          unusable(scan([A_SKILL, RESULT], turncap=4)), "")
    check("a run that answered without firing is a MISS, not a cut run",
          unusable(scan([A_ANSWER, RESULT], turncap=4)), "")
    # The three ways a stream can end that are NOT a result line. Two are the tool's own doing
    # and leave a real measurement; the third is the CLI dying mid-session, which does not.
    check("a stream that ends without a result line is a cut run",
          scan([A_TEXT, A_SKILL], turncap=9)["cut"], "no result line")
    check("a run stopped at its turn cap is not cut",
          scan([A_BASH] * 20, turncap=3)["cut"], "")
    check("a run stopped by the timeout is cut",
          scan([A_SKILL, A_SKILL], turncap=9,
               clock=iter([0, 5]).__next__, timeout=1, started=0)["cut"], "timeout")

    # The retry, on canned attempts. Injecting `sleep` and `say` is what makes the back-off
    # assertable at all: a retry whose wait is real cannot be tested, and a back-off nobody
    # states is the half of this that #213 needed and did not have.
    def canned(*outs):
        seq = list(outs)
        return lambda: seq.pop(0)

    good = {"fired": ["handoff"], "turns": 1, "cost": 0.25, "cut": ""}
    bad = {"fired": [], "turns": 0, "cost": 0.0, "cut": "error_during_execution"}

    # ONE list, not two. Recording sleeps and warnings separately cannot see their ORDER, and
    # order is the whole of "after a stated back-off" — a say() moved below the sleep, or below
    # the retry itself, left every case green while the operator learned of the wait only once
    # it was over.
    def trace():
        ev = []
        return ev, (lambda n: ev.append(("slept", n))), (lambda m: ev.append(("said", m)))

    ev, sleep, say = trace()
    out = with_retry(canned(dict(good)), 60, sleep=sleep, say=say)
    check("a run that measured something is not retried",
          (out["retried"], out["unusable"], ev), ("", "", []))

    ev, sleep, say = trace()
    out = with_retry(canned(dict(bad), dict(good)), 60, sleep=sleep, say=say)
    check("a cut run is retried once and the retry is what gets reported",
          (out["fired"], out["unusable"], out["retried"]),
          (["handoff"], "", "error_during_execution"))
    # Padded, so a mutation that removes BOTH warnings fails the case instead of raising an
    # IndexError out of the gate — an unreadable failure is a failure nobody diagnoses.
    ev = ev + [("", "")] * 2
    check("the back-off is stated, with its reason, and only THEN waited out",
          ([k for k, _ in ev[:2]], ev[1][1],
           "60" in str(ev[0][1]), "error_during_execution" in str(ev[0][1])),
          (["said", "slept"], 60, True, True))

    ev, sleep, say = trace()
    out = with_retry(canned(dict(bad), dict(bad)), 60, sleep=sleep, say=say)
    check("a second cut run stops and reports instead of retrying again",
          (out["unusable"], [k for k, _ in ev]),
          ("error_during_execution", ["said", "slept", "said"]))

    print("")
    print(str(run) + " cases, " + str(passed) + " passed, " + str(failed) + " failed")
    return 0 if failed == 0 else 1


if len(sys.argv) > 1 and sys.argv[1] == "selftest":
    raise SystemExit(selftest())

PROMPT = sys.argv[1]
BUDGET = os.environ.get("PROBE_BUDGET", "0.30")
TURNCAP = int(os.environ.get("PROBE_TURN_CAP", "4"))
TIMEOUT = int(os.environ.get("PROBE_TIMEOUT", "300"))
TRANSCRIPT = os.environ.get("PROBE_TRANSCRIPT", "")
BACKOFF = int(os.environ.get("PROBE_BACKOFF", "60"))

# The prompt sits immediately after -p, and --disallowedTools goes LAST. That flag is
# variadic: anything after it is read as another tool name, and a prompt placed there is
# swallowed silently — the run then starts with no prompt and exits before the first turn.
cmd = [
    "claude", "-p", PROMPT, "--output-format", "stream-json", "--verbose",
    "--permission-mode", "manual", "--max-budget-usd", BUDGET,
    # The measurement is activation, not the work. Denying the working tools keeps a probe
    # from wandering into a task it cannot finish and cannot be billed for twice.
    "--disallowedTools", "Bash", "Read", "Write", "Edit", "Glob", "Grep",
    "WebFetch", "WebSearch", "Task", "NotebookEdit", "TodoWrite", "Agent",
]


# `fired` holds bare skill names because that is what the case files expect. `qualified` keeps
# the plugin namespace alongside it: two marketplaces can serve the same skill — this machine
# carried `arc:handoff` and `arc-scratch:handoff` at once — and a bare name cannot say which
# copy's text the session read.
def attempt():
    """One billed session, opened and read to its end.

    A retry opens a new session in a new working directory, and overwrites PROBE_TRANSCRIPT —
    the kept stream belongs to the run that gets reported, and a stream from a session the
    CLI cut short is not one anything downstream can read.

    THE DEADLINE IS A WATCHDOG, NOT A CHECK IN THE LOOP. scan()'s own clock only advances when
    a line ARRIVES, so a session that goes silent — which is what a CLI blocking on a
    rate-limit retry looks like from here — never reaches it: the read blocks forever and the
    whole suite hangs with nothing printed. A timer that kills the child is the only thing that
    ends a blocked read. scan()'s check stays for the other shape, a stream that keeps talking
    past the deadline.
    """
    cwd = tempfile.mkdtemp(prefix="skill-probe-")
    p = subprocess.Popen(cmd, cwd=cwd, stdout=subprocess.PIPE, stderr=subprocess.DEVNULL,
                         stdin=subprocess.DEVNULL, text=True, encoding="utf-8",
                         errors="replace")
    tf = io.open(TRANSCRIPT, "w", encoding="utf-8", errors="replace") if TRANSCRIPT else None
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
        out = scan(p.stdout, TURNCAP, sink=tf,
                   clock=time.time, timeout=TIMEOUT, started=time.time())
        # The killed child's stream just ends, which scan() reads as "no result line". It is a
        # timeout, and saying which one it was is the difference between an operator waiting
        # and an operator backing off.
        if expired:
            out["cut"] = "timeout"
        return out
    finally:
        wd.cancel()
        if tf:
            tf.close()
        try:
            p.terminate()
            p.wait(timeout=10)
        except Exception:
            try:
                p.kill()
            except Exception:
                pass


print(json.dumps(with_retry(attempt, BACKOFF)))
