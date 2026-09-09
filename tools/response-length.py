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
# AND ONE CASE SHAPE THAT IS NEITHER. A budget can come from the repository's operating
# agreement instead of from a user turn — section 1, `Response verbosity`, the checked box is
# the value, the same mechanism skills/camp reads Report and Nudge verbosity through. No
# recorded session was ever governed by that clause, because the clause postdates the corpus,
# so such a case carries `source.kind: fixture` and stores its replies in replies/<n>.md. It
# is portable: no transcript, no corpus, scorable on any machine. #174.
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
    same trade as tools/skill-cases.py, and the format is fixed by evals/response-length.

    TWO SHAPES OF CASE, and the difference is where the budget came from.

      a stated budget   `budget: 20` and `source.session` — a user said a number in a real
                        conversation, and the case replays that transcript.
      an agreement one  `agreement: <file>` and `source.kind: fixture` — nothing was said in
                        conversation at all; the number is a clause in the repository's
                        operating agreement, and the replies are stored beside the case.

    The second shape needs no `source.session` because there is nothing to replay: the clause
    postdates the corpus, so no recorded session was ever governed by one.
    """
    c = {"budget": 0, "unit": "words", "session": "", "first": 0, "last": 0,
         "set_on": 0, "agreement": "", "kind": ""}
    section = None
    for raw in io.open(path, encoding="utf-8"):
        line = raw.rstrip("\n")
        if not line.strip() or line.lstrip().startswith("#"):
            continue
        if not line[:1].isspace():
            section = line.split(":", 1)[0].strip()
            m = re.match(r"budget:\s*(\d+)", line)
            if m:
                c["budget"] = int(m.group(1))
            m = re.match(r"unit:\s*(\S+)", line)
            if m:
                c["unit"] = m.group(1)
            m = re.match(r"agreement:\s*(\S+)", line)
            if m:
                c["agreement"] = m.group(1)
            continue
        s = line.strip()
        if section != "source":
            continue
        for key in ("session", "kind", "first_turn", "last_turn", "set_on"):
            m = re.match(key + r":\s*(\S+)", s)
            if m:
                v = m.group(1)
                if key in ("session", "kind"):
                    c[key] = v
                elif key == "first_turn":
                    c["first"] = int(v)
                elif key == "last_turn":
                    c["last"] = int(v)
                else:
                    c["set_on"] = int(v)
    c["set_on"] = c["set_on"] or c["first"]
    return c


# ---- the agreement clause -----------------------------------------------------------
# Section 1 of the operating agreement, `Response verbosity`, checked box is the value —
# the same mechanism skills/camp reads Report and Nudge verbosity through.
#
# THE NUMBER COMES OUT OF THE CLAUSE, NOT OUT OF THIS FILE. The whole point of the setting is
# that the user owns it, so a repository that edits `brief` down to 25 words is scored at 25.
# LEVEL_DEFAULT is what a level means when its line states no budget of its own, which is the
# only case where the scorer gets to decide.
#
# WHICH LEVEL IS A BUDGET IS THE LEVEL'S PROPERTY, NOT ITS LINE'S. Only `brief` and a number
# typed into `Other:` state one. `normal` is skills/chat-response's table — four figures for
# four kinds of reply, not one number — and `full` is uncapped; neither is a budget this
# instrument can score, so both return 0 whatever their line says and the case is reported as
# not scorable. `normal` is the SHIPPED state of the clause, so that is the path a repository
# which never edits its agreement takes, and it has to behave as it did before the clause
# existed.
#
# THE DISTINCTION MATTERS BECAUSE `normal`'S OWN LINE CARRIES NUMBERS. It reads "~150 words for
# a finding, ~200 for a proposal" — prose describing the table. The first version of this
# function scanned every checked line for a number, read 150 out of that sentence, and handed
# every shipped repository a flat 150-word budget nobody chose.
#
# THE SECOND VERSION REQUIRED THE NUMBER TO BE BOLD, and that was the same defect mirrored: a
# user editing `brief` to "25 words of prose" without the asterisks got 40 and no warning. So
# the level decides whether to look at all, and on a level that IS a budget any figure counts.
# LEVEL_DEFAULT is only what `brief` means when its line names no figure whatsoever.
LEVEL_DEFAULT = {"brief": 40}
NO_BUDGET_LEVELS = ("normal", "full")

CLAUSE_HEADING = re.compile(r"^\s{0,3}(#{2,6})\s*Response verbosity\b", re.I)
ANY_HEADING = re.compile(r"^\s{0,3}(#{1,6})\s")
CHECKED = re.compile(r"^\s*[-*]\s*\[[xX]\]\s*(.*)$")
WORD_BUDGET = re.compile(r"(\d+)\s*\**\s*words?\b", re.I)


def read_agreement_budget(path):
    """(level, budget) from an operating agreement, or (level-or-None, 0) when it sets none.

    A budget of 0 means the clause states no scorable number. The level says which flavour of
    that it is, and the caller reports it: `normal` and `full` are deliberate, an unrecognised
    level is a typo, `nothing checked` is a clause left blank, and None is no clause at all.
    An agreement that did not state a budget must never acquire one here.
    """
    lines = io.open(path, encoding="utf-8", errors="replace").read().splitlines()
    depth, block = 0, []
    for line in lines:
        if depth:
            m = ANY_HEADING.match(line)
            if m and len(m.group(1)) <= depth:
                break
            block.append(line)
            continue
        m = CLAUSE_HEADING.match(line)
        if m:
            depth = len(m.group(1))
    if not depth:
        return None, 0

    checked = []
    for line in block:
        m = CHECKED.match(line)
        if m:
            checked.append(m.group(1))
    if not checked:
        return "nothing checked", 0
    # "Check one per setting" is the section's own instruction. Two checked boxes is not a
    # value this can resolve — taking the first would make the answer depend on the order the
    # levels happen to be listed in, which is not a decision the user made.
    if len(checked) > 1:
        return "%d boxes checked" % len(checked), 0

    rest = checked[0]
    label = re.match(r"\*\*(.+?)\*\*", rest)
    level = (label.group(1) if label else rest.split(":")[0]).strip().lower()
    if level in NO_BUDGET_LEVELS:
        return level, 0
    if level == "other":
        n = WORD_BUDGET.search(rest.split(":", 1)[-1]) or re.search(r"(\d+)", rest.split(":", 1)[-1])
        return level, int(n.group(1)) if n else 0
    if level not in LEVEL_DEFAULT:
        return level, 0
    n = WORD_BUDGET.search(rest)
    return level, int(n.group(1)) if n else LEVEL_DEFAULT[level]


def fixture_rows(d, first, last):
    """(turn, prompt, prose words, prose words) from replies/<n>.md.

    Same tuple shape replay() returns, so the scoring below does not branch. The final-block
    count equals the total because a stored reply is one block — there is no tool narration to
    split it, which is itself a difference from a replayed turn and is why the two are labelled
    apart in the report.
    """
    rdir = os.path.join(d, "replies")
    if not os.path.isdir(rdir):
        return []
    out = []
    for f in sorted(os.listdir(rdir)):
        m = re.match(r"(\d+)\.md$", f)
        if not m:
            continue
        t = int(m.group(1))
        if not (first <= t <= last):
            continue
        n = prose_words(io.open(os.path.join(rdir, f), encoding="utf-8").read())
        out.append((t, "", n, n))
    return sorted(out)


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


def report(name, budget, floor, scored, breach, set_on, extra=None, standing=0):
    """`standing` is the first turn of a case whose budget came from the agreement.

    A stated budget has a turn it was stated on, and "held N turns" counts from there. A
    standing one was in force before the conversation opened, so it counts from the first
    reply — and no turn is marked as the one that stated it, because none did.
    """
    under = sum(1 for _, _, v in scored if v == "UNDER")
    over = sum(1 for _, _, v in scored if v == "OVER")
    thin = sum(1 for _, _, v in scored if v in ("THIN", "CUT"))
    cut = sum(1 for _, _, v in scored if v == "CUT")
    print(name)
    for turn, words, v in scored:
        note = ""
        if turn == set_on and not standing:
            note = "  <- budget stated here"
        elif turn == breach:
            note = "  <- first breach"
        print("  %-6s t%-4d %4d words%s" % (v, turn, words, note))
    if extra:
        for line in extra:
            print("  " + line)
    denom = under + over
    rate = ("%d/%d  %.2f" % (under, denom, under / denom)) if denom else "0/0  n/a"
    origin = standing or set_on
    held = (breach - origin) if breach is not None else len(scored)
    print("  held %s, first breach %s, thin %d (of which cut short by the runner: %d)" % (
        "%d turns %s" % (held, "after it came into force" if standing else "after it was stated"),
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
        case = read_case(cp)
        budget, session, first, last, set_on = (
            case["budget"], case["session"], case["first"], case["last"], case["set_on"])
        fixture = case["kind"] == "fixture"
        stored = case_turns(d)

        # An agreement case names no number of its own: the clause is the number, and reading
        # it here rather than copying it into case.yaml is the whole claim under test.
        level = ""
        if case["agreement"]:
            ap = os.path.join(d, case["agreement"])
            if not os.path.isfile(ap):
                missing.append("%s  (agreement %s is not beside the case)" % (name, case["agreement"]))
                continue
            level, budget = read_agreement_budget(ap)
            if not budget:
                missing.append("%s  (%s sets no scorable response verbosity — %s)"
                               % (name, case["agreement"], level or "no clause found"))
                continue

        if case["unit"] != "words":
            missing.append("%s  (unit %r is not scored; only words is)" % (name, case["unit"]))
            continue
        if not budget or not first or (not session and not fixture):
            missing.append("%s  (case.yaml names no budget, source.session or source.first_turn)" % name)
            continue
        floor = thin_floor(budget, configured_floor)

        if fixture:
            # No transcript to drift from — the replies ARE the case rather than a copy of
            # one. What can still go wrong is the two halves parting company: a reply added
            # with no turn asking for it, or a turn whose reply was deleted. Unchecked, the
            # first silently widens the case and the second silently narrows it, which is the
            # same failure the transcript drift check below exists to catch.
            rows = fixture_rows(d, first, last)
            # THE PAIRING CHECK RUNS BEFORE THE BAIL-OUT BELOW. Deleting one reply narrows the
            # case; deleting all of them narrows it to nothing, and that is the version worth
            # catching most. Reported after the bail-out it would be invisible in exactly that
            # case, which reads as "not scored" and exits 0.
            answered = {t for t, _, _, _ in rows}
            # Both sides bounded by first..last, the same window fixture_rows applies. A turn
            # kept outside the scored range is context, not a gap.
            asked = {t for t in stored if first <= t <= last}
            if not os.path.isdir(os.path.join(d, "turns")):
                # One line naming the directory, not one per reply blaming a turn that was
                # never supposed to exist individually.
                drift.append("%s  (fixture case has no turns/ directory)" % name)
            else:
                for t in sorted(asked | answered):
                    if t not in asked:
                        drift.append("%s t%d  (replies/%d.md with no turns/%d.md)" % (name, t, t, t))
                    elif t not in answered:
                        drift.append("%s t%d  (turns/%d.md with no replies/%d.md)" % (name, t, t, t))
            if not rows:
                missing.append("%s  (no replies/<n>.md in range t%d-t%d)" % (name, first, last))
                continue
            pairs = [(t, total) for t, _, total, _ in rows]
            scored, breach = verdicts(pairs, budget, floor)
            extra = ["budget from %s: %s, %d words" % (case["agreement"], level, budget)]
            u, o, th = report("%s  [fixture]" % name, budget, floor, scored, breach, set_on,
                              extra, standing=first)
            tot_under += u
            tot_over += o
            tot_thin += th
            continue

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
