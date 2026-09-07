# response-length.py — the scoring half of tools/response-length.sh. Not run directly.
#
# Answers one question per turn: was the reply within the budget the user stated, counted the
# way skills/chat-response says to count it — prose only, tables and code blocks and headings
# excluded, because the skill exempts them and a grader that did not would be measuring a rule
# nobody wrote.
#
# TWO MODES OVER ONE CASE SET.
#
#   replay   Read the transcript the case came from. Free, deterministic, and blind to any
#            change made after the session was recorded — exactly like tools/skill-cases.py.
#            This is the baseline: it is what happened.
#   probe    Re-run the case's turns as one live conversation, so a change to the skill can
#            be seen. Billed. tools/response-length.sh owns the invocation.
#
# WHY A THIN FLOOR. A reply that declines, or says it has no context, is short — and a scorer
# that counted short as held would report the fix working every time the model failed to
# answer. Replies below the floor are counted in neither column and printed as their own
# number, so a run with many of them is visibly not a measurement.
#
# AND WHY IT IS RELATIVE TO THE BUDGET. A flat 15 words is a sane floor against a 60-word
# budget and nonsense against a 20-word one, where it is three quarters of the whole
# allowance. #213 added a rule telling the model to aim at two-thirds of a tight budget —
# about 13 words for 20 — and a flat floor then discarded every turn that obeyed it, as THIN,
# out of the rate. The instrument was deleting the successes of the rule it was grading:
# the same runs score 0.38 at a flat 15 and 0.45 at min(15, budget // 2).
#
# So the floor is min(RL_THIN_FLOOR, budget // 2), per case, and the effective value is
# printed beside each case rather than only the configured one.
import io
import json
import os
import re
import sys

try:
    sys.stdout.reconfigure(encoding="utf-8", errors="replace")
except Exception:
    pass

FENCE = re.compile(r"^\s*(```|~~~)")
HEADING = re.compile(r"^\s{0,3}#{1,6}\s")
TABLE_ROW = re.compile(r"^\s*\|")


def prose_words(text):
    """Word count of body text only.

    skills/chat-response: "Prose means body text. Tables, code blocks, and headings are not
    budgeted — they are the form the answer should take." The budget is stated against that
    rule, so the count has to honour it or the two disagree about what 60 words means.
    """
    n, in_fence = 0, False
    for line in (text or "").splitlines():
        if FENCE.match(line):
            in_fence = not in_fence
            continue
        if in_fence or HEADING.match(line) or TABLE_ROW.match(line):
            continue
        n += len(line.split())
    return n


def is_prompt_turn(o):
    """A turn a prompt opened. Same discriminators as tools/skill-cases.py, same reasons —
    tool results, skill injections, interrupts and task notifications all arrive as "user"
    and none of them is a turn."""
    if o.get("type") != "user" or o.get("isMeta"):
        return False
    c = (o.get("message") or {}).get("content")
    if isinstance(c, list):
        if any(isinstance(x, dict) and x.get("type") == "tool_result" for x in c):
            return False
        joined = "".join(x.get("text", "") for x in c if isinstance(x, dict) and x.get("type") == "text")
        if joined.startswith("[Request interrupted"):
            return False
    kind = (o.get("origin") or {}).get("kind")
    if kind == "task-notification":
        return False
    return o.get("promptSource") == "sdk" or kind == "human"


def turn_text(o):
    c = (o.get("message") or {}).get("content")
    if isinstance(c, str):
        return c
    if isinstance(c, list):
        return "\n".join(x.get("text", "") for x in c if isinstance(x, dict) and x.get("type") == "text")
    return ""


def read_case(path):
    """The fields a response-length case.yaml carries. Purpose-built, not a YAML parser —
    same trade as tools/skill-cases.py, and the format is fixed by evals/response-length."""
    budget, unit, session, first, last, set_on = 0, "words", "", 0, 0, 0
    section = None
    for raw in io.open(path, encoding="utf-8"):
        line = raw.rstrip("\n")
        if not line.strip() or line.lstrip().startswith("#"):
            continue
        if not line[:1].isspace():
            section = line.split(":", 1)[0].strip()
            m = re.match(r"budget:\s*(\d+)", line)
            if m:
                budget = int(m.group(1))
            m = re.match(r"unit:\s*(\S+)", line)
            if m:
                unit = m.group(1)
            continue
        s = line.strip()
        if section != "source":
            continue
        for key, setter in (("session", "session"), ("first_turn", "first"),
                            ("last_turn", "last"), ("set_on", "set_on")):
            m = re.match(key + r":\s*(\S+)", s)
            if m:
                v = m.group(1)
                if setter == "session":
                    session = v
                elif setter == "first":
                    first = int(v)
                elif setter == "last":
                    last = int(v)
                else:
                    set_on = int(v)
    return budget, unit, session, first, last, (set_on or first)


def case_turns(d):
    """turns/<n>.md, keyed by the SOURCE turn number.

    Naming them by their source number rather than 01..11 means the drift check reads the
    filename and needs no second mapping to keep in sync with case.yaml.
    """
    out = {}
    tdir = os.path.join(d, "turns")
    if not os.path.isdir(tdir):
        return out
    for f in sorted(os.listdir(tdir)):
        m = re.match(r"(\d+)\.md$", f)
        if m:
            out[int(m.group(1))] = io.open(os.path.join(tdir, f), encoding="utf-8").read()
    return out


def replay(path, first, last):
    """(turn, prompt text, total reply prose words, final-block prose words) for each turn.

    TOTAL is the scored number. Everything the assistant says between one prompt turn and the
    next is text the user reads, including narration around tool calls — a reply split over
    four blocks is not shorter for being split. The final block is reported beside it because
    it is what a reader remembers as "the answer", and the two diverging is worth seeing.
    """
    objs = []
    for ln in io.open(path, encoding="utf-8", errors="replace"):
        ln = ln.strip()
        if ln.startswith("{"):
            try:
                objs.append(json.loads(ln))
            except Exception:
                pass
    rows, n, cur, blocks = [], 0, "", []
    for o in objs:
        if is_prompt_turn(o):
            if n and first <= n <= last:
                rows.append((n, cur, blocks))
            n += 1
            cur, blocks = turn_text(o), []
            continue
        if o.get("type") != "assistant":
            continue
        c = (o.get("message") or {}).get("content") or []
        t = "".join(x.get("text", "") for x in c
                    if isinstance(x, dict) and x.get("type") == "text").strip()
        if t:
            blocks.append(t)
    if n and first <= n <= last:
        rows.append((n, cur, blocks))
    return [(i, q, prose_words("\n".join(b)), prose_words(b[-1] if b else "")) for i, q, b in rows]


def thin_floor(budget, configured):
    """The floor actually applied to this case.

    Half the budget is the most a floor can be and still mean "too short to be an attempt".
    Above that it starts rejecting replies for being the length they were asked to be.
    """
    return max(1, min(configured, budget // 2))


def verdicts(rows, budget, floor):
    """UNDER / OVER / THIN / CUT per turn, and the first turn that breached.

    CUT is a turn the runner stopped — a spent budget or a turn cap. Its reply is truncated,
    so it is short for a reason that has nothing to do with the user's budget. Counting it as
    held is the one wrong answer this instrument must never give.
    """
    out, breach = [], None
    for row in rows:
        turn, words = row[0], row[1]
        cut = row[2] if len(row) > 2 else ""
        if cut:
            v = "CUT"
        elif words < floor:
            v = "THIN"
        elif words <= budget:
            v = "UNDER"
        else:
            v = "OVER"
            if breach is None:
                breach = turn
        out.append((turn, words, v))
    return out, breach


def report(name, budget, floor, scored, breach, set_on, extra=None):
    under = sum(1 for _, _, v in scored if v == "UNDER")
    over = sum(1 for _, _, v in scored if v == "OVER")
    thin = sum(1 for _, _, v in scored if v in ("THIN", "CUT"))
    cut = sum(1 for _, _, v in scored if v == "CUT")
    print(name)
    for turn, words, v in scored:
        note = ""
        if turn == set_on:
            note = "  <- budget stated here"
        elif turn == breach:
            note = "  <- first breach"
        print("  %-6s t%-4d %4d words%s" % (v, turn, words, note))
    if extra:
        for line in extra:
            print("  " + line)
    denom = under + over
    rate = ("%d/%d  %.2f" % (under, denom, under / denom)) if denom else "0/0  n/a"
    held = (breach - set_on) if breach is not None else len(scored)
    print("  held %s, first breach %s, thin %d (of which cut short by the runner: %d)" % (
        "%d turns after it was stated" % held,
        ("t%d" % breach) if breach is not None else "none",
        thin, cut))
    print("  within budget (%d %s): %s   thin floor %d words" % (budget, "words", rate, floor))
    print()
    return under, over, thin


def main():
    evaldir = os.environ["RL_EVAL_DIR"]
    mode = os.environ.get("RL_MODE", "replay")
    configured_floor = int(os.environ.get("RL_THIN_FLOOR", "15"))
    threshold = float(os.environ.get("RL_THRESHOLD", "0.67"))
    strict = os.environ.get("RL_STRICT") == "1"

    cases = []
    for dirpath, _, files in os.walk(evaldir):
        if "case.yaml" in files:
            cases.append(os.path.join(dirpath, "case.yaml"))
    cases.sort()
    if not cases:
        print("no cases under %s" % evaldir, file=sys.stderr)
        raise SystemExit(2)

    drift, missing = [], []
    tot_under = tot_over = tot_thin = 0

    print("response-length — %d case(s) under %s, mode %s, thin floor min(%d, budget/2)"
          % (len(cases), evaldir, mode, configured_floor))
    print()

    for cp in cases:
        d = os.path.dirname(cp)
        name = os.path.relpath(d, evaldir).replace(os.sep, "/")
        budget, unit, session, first, last, set_on = read_case(cp)
        stored = case_turns(d)
        if not budget or not session or not first:
            missing.append("%s  (case.yaml names no budget, source.session or source.first_turn)" % name)
            continue
        if unit != "words":
            missing.append("%s  (unit %r is not scored; only words is)" % (name, unit))
            continue
        floor = thin_floor(budget, configured_floor)

        root = os.environ.get("RL_ROOT_DIR", "")
        hits = []
        if root:
            for sub in sorted(os.listdir(root)):
                p = os.path.join(root, sub)
                if not os.path.isdir(p):
                    continue
                hits += sorted(os.path.join(p, f) for f in os.listdir(p)
                               if f.startswith(session) and f.endswith(".jsonl"))
        if not hits:
            missing.append("%s  (session %s not on this machine)" % (name, session))
            continue

        rows = replay(hits[0], first, last)
        got = {t: q for t, q, _, _ in rows}
        for t, text in sorted(stored.items()):
            if t not in got:
                drift.append("%s t%d  (turn not in %s)" % (name, t, session))
            elif got[t].rstrip("\n") != text.rstrip("\n"):
                drift.append("%s t%d" % (name, t))
        for t, _, _, _ in rows:
            if t not in stored:
                drift.append("%s t%d  (turn in the transcript, no turns/%d.md)" % (name, t, t))

        if mode == "probe":
            live = json.load(io.open(os.environ["RL_PROBE_JSON"], encoding="utf-8"))
            pairs, fired = [], {}
            for k, v in sorted(live.get(name, {}).items(), key=lambda kv: int(kv[0])):
                pairs.append((int(k), prose_words(v["text"]), v.get("cut", "")))
                fired[int(k)] = v.get("fired") or []
            if not pairs:
                missing.append("%s  (no probe output for this case)" % name)
                continue
            scored, breach = verdicts(pairs, budget, floor)
            # Firing is not the measurement — #155 settled that — but a rule that lives in a
            # skill BODY is only in context on the turns the skill fired. A run where it
            # never fired is a run where only the description was in play.
            hits = [t for t in fired if "chat-response" in fired[t]]
            extra = ["chat-response fired on: " + (" ".join("t%d" % t for t in sorted(hits))
                                                  if hits else "no turn")]
            u, o, th = report("%s  [probe]" % name, budget, floor, scored, breach, set_on, extra)
        else:
            pairs = [(t, total) for t, _, total, _ in rows]
            finals = {t: fin for t, _, _, fin in rows}
            scored, breach = verdicts(pairs, budget, floor)
            extra = ["final block only: " + " ".join("t%d=%dw" % (t, finals[t]) for t, _, _ in scored)]
            u, o, th = report("%s  [replay]" % name, budget, floor, scored, breach, set_on, extra)
        tot_under += u
        tot_over += o
        tot_thin += th

    denom = tot_under + tot_over
    rate = (tot_under / denom) if denom else 0.0
    print("%-28s %s" % ("all cases, within budget", "%d/%d  %.2f" % (tot_under, denom, rate)))
    print("%-28s %d" % ("thin, not scored", tot_thin))
    print("%-28s %.2f" % ("threshold", threshold))
    print("%-28s %s" % ("verdict", "PASS" if denom and rate >= threshold else "FAIL"))
    print()
    if mode == "replay":
        print("A replay score is history. It cannot see a change to skills/chat-response —")
        print("the transcript was recorded before the edit. Use --probe for that.")
    print("The exit code reports turn drift and, with --strict, an absent transcript. Not the score.")

    if drift:
        print()
        print("TURN DRIFT — a stored turns/<n>.md no longer matches the transcript:")
        for x in drift:
            print("  " + x)
    if missing:
        print()
        print("NOT SCORED:")
        for x in missing:
            print("  " + x)

    raise SystemExit(1 if (drift or (missing and strict)) else 0)


main()
