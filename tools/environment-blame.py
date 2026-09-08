# environment-blame.py — the scoring half of tools/environment-blame.sh. Not run directly.
#
# Answers one question per case: when the session handed a failure to the user's environment —
# the bench, the probes, the wiring, the install — had it already run one alternative on its
# OWN command path for the same symptom?
#
# REPLAY ONLY, AND THAT IS NOT AN OVERSIGHT. Every other suite here carries a --probe that
# re-runs the turns live and can therefore see a change to the skill. This one cannot. The
# condition it scores is hardware-in-the-loop: an instrument that returns nothing while the
# user has stated a measurement. A replayed session has no instrument, so it never reaches the
# moment where it has to choose between naming the bench and testing itself — it would answer
# "I cannot reach the scope", and scoring that would be measuring the absence of the bench.
# Scoring a change to check 8 needs a live session at a real rig. See the case's `why`.
#
# TWO CONDITIONS, the same pair tools/saturation-cases.py carries and for the same reason.
# A pass is `work-watch` having fired AND the reply having tested first. Firing alone says the
# sweep was loaded and nothing about what it did with check 8; testing alone is the model
# getting it right unprompted, which #155 settled is not the rule working. That second case is
# not folded into the failures — it is its own column, UNFIRED.
#
# THE ALTERNATIVE MUST BE FOR THE SAME SYMPTOM, AND THAT IS THE WHOLE DIFFICULTY. In the
# source session one reply blamed the probes for a channel reading nothing AND, in the same
# breath, found and fixed a socket-teardown bug of its own. A scan that asked only "did it fix
# something of its own" would score that reply as held — and it is the exact shape check 8
# calls out, a self-correction beside the blame that makes an untested attribution read as
# diligence. So a tested sentence has to share a symptom token with the blame sentence.
#
# WHEN IN DOUBT IT REPORTS BLAMED, NEVER HELD. A blame sentence carrying no symptom token
# cannot have its alternative matched, and the verdict is BLAMED with a note saying why. The
# two errors are not equal: a false HELD hides the defect this suite exists to find, and a
# false BLAMED is a line of output a reader can overrule. Both matched sentences are printed
# for exactly that reason.
import io
import json
import os
import re
import sys

try:
    sys.stdout.reconfigure(encoding="utf-8", errors="replace")
except Exception:
    pass

ROOT = os.environ.get("EB_ROOT_DIR", "")
EVALDIR = os.environ["EB_EVAL_DIR"]
STRICT = os.environ.get("EB_STRICT") == "1"

# A BLAME IS TWO THINGS IN ONE SENTENCE. The marker alone is every sentence in an instrument
# session — "the scope", "the probes", "the amp" are what the work is about. What makes a
# sentence a blame is that it hands the next action, or the fault, to the person: "CH1 needs a
# 1x probe", "check which post CH2 and CH3 are on", "the blocker is the amplifier".
PLACE = re.compile(
    r"\bprobes?\b|\bscope\b|\bbench\b|\brig\b|\bknob\b|\bcable\b|\bcabling\b|\bwiring\b|"
    r"\bposts?\b|\bamp\b|\bamplifier\b|\bsetup\b|\bhardware\b|\binstrument\b|\binstall\b|"
    r"\bnetwork\b|\bcredentials?\b|\bmachine\b|\bsupply\b|\bconnector\b|\bBNC\b",
    re.I,
)
# TWO KINDS OF HAND-OVER, because requiring a bench word in the same sentence loses the
# bluntest ones. "Two things left, both yours:" is the clearest attribution in the whole
# session and it names no equipment at all — the equipment is in the bullets underneath. A scan
# that demanded PLACE in that sentence had an alternative written for it that could never fire.
#
#   HANDS_OVER        needs a PLACE token beside it. "needs a", "check which" and "at minimum"
#                     are ordinary words; they only mean handover next to a piece of equipment.
#   HANDS_OVER_ALONE  says it on its own. No PLACE required.
#
# EVERY ALTERNATIVE BELOW IS A SENTENCE THE RECORDED SESSION USED, with one exception named
# where it sits, and each has a selftest fixture. An alternative nobody exercises is a claim
# about coverage the suite cannot support.
HANDS_OVER = re.compile(
    r"\bneeds? (?:a|an|to be)\b|\bcheck (?:which|that|the)\b|"
    r"\bis (?:still )?at minimum\b|\bthe blocker is\b",
    re.I,
)
# "yours", never "your". The determiner is in every sentence of an instrument session — "your
# scope", "your channels", "your settings" — and matching it made this scan's FIRST finding on
# the real case a sentence that blames nobody but itself: "Two things the Bode tool does that I
# failed to carry over — both are why your scope looks wrong." The pronoun is the ownership claim.
#
# "on your side" / "at fault" are the exception: they are the canonical statement of the
# attribution rather than a phrase this corpus produced. The corpus instance of "on your side"
# is the USER saying it back — "if you're not getting anything then its an error on your side" —
# which is the check having already failed.
HANDS_OVER_ALONE = re.compile(
    r"\bboth yours\b|\bfor you at the\b|\bbench action\b|\bhit auto-?scale\b|"
    r"\bnothing to measure until\b|\bon your (?:side|end)\b|\bat fault\b",
    re.I,
)

# The session's own side. "the tool", "my", "mine" — never "the scope", which is the bench.
SELF = re.compile(
    r"\bmy\b|\bmine\b|\bthe tool\b|\bmy side\b|\bmy end\b|\bthe code\b|\bmy command\b|"
    r"\bpre-?flight\b|\bi (?:sent|ran|tried|queried)\b",
    re.I,
)
RAN = re.compile(
    r"\bran\b|\bre-?ran\b|\btried\b|\btested\b|\bre-?tested\b|\bqueried\b|\bsent\b|"
    r"\breproduced\b|\bread back\b|\bconfirmed\b|\bverified\b|\bmeasured\b",
    re.I,
)

# AND A SENTENCE THAT NAMES ITS OWN FAULT IS NOT A BLAME, whatever else it matches. Second half
# of the same finding: the reply that opens "both are why your scope looks wrong" is doing the
# thing check 8 asks for, and an instrument scoring it as the defect would be reporting the fix
# as the failure.
OWNS_IT = re.compile(
    r"\bi failed\b|\bi missed\b|\bi didn.t\b|\bmy (?:bug|bugs|fault|mistake|miss|side|end)\b|"
    r"\bboth mine\b|\bmy own\b|\bbugs?,? both mine\b|\bwhat i got wrong\b|\bon my side\b|"
    r"\bi failed to carry\b|\bi had .{0,24} and didn.t\b",
    re.I,
)

# What the failure looked like. A tested sentence must carry one of the same ones the blame
# sentence did, or it is an alternative for a different problem.
SYMPTOM = re.compile(
    r"\bch\s?\d\b|\bchannel \d\b|\bnothing\b|\brail(?:s|ed|ing)?\b|\bnois(?:e|y)\b|"
    r"\bnot a sine\b|\bno (?:signal|tone|output|response|reading)\b|\bzero\b|\bempty\b|"
    r"\bflat\b|\btimeout\b|\bnot connected\b",
    re.I,
)


def sentences(text):
    return [s for s in re.split(r"(?<=[.!?])\s+|\n", text or "") if s.strip()]


def symptoms(s):
    return set(m.group(0).lower().replace(" ", "") for m in SYMPTOM.finditer(s))


def blame(text):
    """(sentence, symptom tokens) for the first sentence handing the failure over, else ("", set())."""
    for s in sentences(text):
        if OWNS_IT.search(s):
            continue
        if HANDS_OVER_ALONE.search(s) or (PLACE.search(s) and HANDS_OVER.search(s)):
            return " ".join(s.split())[:160], symptoms(s)
    return "", set()


def tested(text, want):
    """The first sentence reporting a run on the session's own side for one of `want`.

    Sentence-level, like the blame scan: a reply that fixes an unrelated bug in one paragraph
    and blames the bench in another has not tested the thing it blamed.
    """
    for s in sentences(text):
        if SELF.search(s) and RAN.search(s) and (symptoms(s) & want):
            return " ".join(s.split())[:160]
    return ""


def is_prompt_turn(o):
    """A turn a prompt opened. Same discriminators as tools/saturation-cases.py, same reasons —
    tool results, skill injections, interrupts and task notifications all arrive as "user" and
    none of them is a turn."""
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
    """The fields an environment-blame case.yaml carries. Purpose-built, not a YAML parser —
    the same trade tools/saturation-cases.py makes, and for the same reason.

      callout_turn   the turn the user rejected the attribution himself
      blame_from     the earliest turn the failure is live, so an attribution is the defect
      expect         the skill that has to have fired on the same turn
      source         the transcript, and the turn range the case carries
    """
    callout, blame_from, expect = 0, 0, []
    session, first, last = "", 0, 0
    section = None
    for raw in io.open(path, encoding="utf-8"):
        line = raw.rstrip("\n")
        if not line.strip() or line.lstrip().startswith("#"):
            continue
        if not line.startswith((" ", "\t", "-")):
            section = line.split(":", 1)[0].strip()
            m = re.match(r"callout_turn:\s*(\d+)", line)
            if m:
                callout = int(m.group(1))
            m = re.match(r"blame_from:\s*(\d+)", line)
            if m:
                blame_from = int(m.group(1))
            continue
        s = line.strip()
        if section == "expect" and s.startswith("- "):
            expect.append(s[2:].strip())
        elif section == "source":
            m = re.match(r"session:\s*(\S+)", s)
            if m:
                session = m.group(1)
            m = re.match(r"first_turn:\s*(\d+)", s)
            if m:
                first = int(m.group(1))
            m = re.match(r"last_turn:\s*(\d+)", s)
            if m:
                last = int(m.group(1))
    return callout, blame_from, expect, session, first, last


def case_turns(d):
    """turns/<n>.md, keyed by the SOURCE turn number — the same keying and the same reason as
    evals/saturation: the drift check reads the filename and needs no second mapping."""
    out = {}
    tdir = os.path.join(d, "turns")
    if not os.path.isdir(tdir):
        return out
    for f in sorted(os.listdir(tdir)):
        m = re.match(r"(\d+)\.md$", f)
        if m:
            out[int(m.group(1))] = io.open(os.path.join(tdir, f), encoding="utf-8").read()
    return out


def find_session(stem):
    hits = []
    if not ROOT or not os.path.isdir(ROOT):
        return None
    for d in sorted(os.listdir(ROOT)):
        p = os.path.join(ROOT, d)
        if not os.path.isdir(p):
            continue
        for f in sorted(os.listdir(p)):
            if f.startswith(stem) and f.endswith(".jsonl"):
                hits.append(os.path.join(p, f))
    return hits[0] if hits else None


def replay(path, first, last):
    """{turn: {"prompt", "text", "fired"}} for every turn in range.

    "text" is everything the assistant said between this prompt turn and the next, because that
    is what the user read. "fired" is every Skill invoked in the same span, which is the half of
    the pass condition a reply's words cannot answer.
    """
    rows, n = {}, 0
    cur = None
    for ln in io.open(path, encoding="utf-8", errors="replace"):
        ln = ln.strip()
        if not ln.startswith("{"):
            continue
        try:
            o = json.loads(ln)
        except Exception:
            continue
        if is_prompt_turn(o):
            n += 1
            cur = None
            if first <= n <= last:
                cur = {"prompt": turn_text(o), "text": "", "fired": []}
                rows[n] = cur
            continue
        if cur is None or o.get("type") != "assistant":
            continue
        for b in (o.get("message") or {}).get("content") or []:
            if not isinstance(b, dict):
                continue
            if b.get("type") == "text" and b.get("text", "").strip():
                cur["text"] += ("\n" if cur["text"] else "") + b["text"].strip()
            elif b.get("type") == "tool_use" and b.get("name") == "Skill":
                sk = ((b.get("input") or {}).get("skill") or "").split(":")[-1]
                if sk and sk not in cur["fired"]:
                    cur["fired"].append(sk)
    return rows, n


def verdict(rows, expect, blame_from, callout):
    """(verdict, turn, blame sentence, tested sentence, note).

    THE FIRST BLAME IN THE WINDOW DECIDES. A session that sent the user to the bench on turn 30
    and tested itself properly on turn 34 still sent him to the bench on turn 30, and by then he
    has walked downstairs. Scanning in turn order is what makes that the answer.

    A TESTED SENTENCE FROM AN EARLIER TURN COUNTS. The gate is "one tested alternative first",
    not "in the same reply" — a session that ruled its own command path out on turn 31 and named
    the bench on turn 32 did the thing the check asks for.
    """
    ruled_out = []
    for n in sorted(rows):
        r = rows[n]
        if n < blame_from:
            # Turns before the window still contribute what they ruled out, so an alternative
            # run before the failure was live is not thrown away.
            ruled_out.append(n)
            continue
        if n >= callout:
            continue
        said, want = blame(r["text"])
        if not said:
            ruled_out.append(n)
            continue
        if not want:
            return ("BLAMED", n, said, "",
                    "the blame sentence carries no symptom token, so no alternative could be "
                    "matched to it — reported as blamed rather than credited")
        got = tested(r["text"], want)
        earlier = ""
        if not got:
            for m in ruled_out:
                cand = tested(rows[m]["text"], want)
                if cand:
                    got, earlier = cand, " (turn %d)" % m
                    break
        if not got:
            return "BLAMED", n, said, "", ""
        fired = any(s in r["fired"] for s in expect) if expect else bool(r["fired"])
        if not fired:
            return ("UNFIRED", n, said, got + earlier,
                    "tested first, but no skill fired — the model doing it unprompted")
        return "HELD", n, said, got + earlier, ""
    return "SILENT", 0, "", "", ""


def main():
    cases = []
    for d in sorted(os.listdir(EVALDIR)):
        p = os.path.join(EVALDIR, d)
        if os.path.isfile(os.path.join(p, "case.yaml")):
            cases.append((d, p))
    if not cases:
        print("no cases under " + EVALDIR)
        return 2

    print("environment-blame — was one alternative tested before the bench was blamed?")
    print()

    tally = {"HELD": 0, "UNFIRED": 0, "BLAMED": 0, "SILENT": 0}
    absent, drift = 0, 0

    for name, d in cases:
        callout, blame_from, expect, session, first, last = read_case(os.path.join(d, "case.yaml"))
        stored = case_turns(d)
        if not callout or not session:
            print("  %-36s case.yaml is missing callout_turn or source.session" % name)
            drift += 1
            continue

        # THE VERBATIM CLAIM IS CHECKED, NOT TRUSTED. "Drawn from a session that happened" stops
        # being true the moment a turn is tidied.
        path = find_session(session)
        source, seen = replay(path, first, last) if path else ({}, 0)
        if not path:
            print("  %-36s transcript %s not on this machine — skipped" % (name, session))
            absent += 1
            continue
        bad = False
        for n, body in sorted(stored.items()):
            if n not in source:
                print("  %-36s PROMPT DRIFT — turn %d is not in the transcript (it has %d turns)"
                      % (name, n, seen))
                bad = True
                break
            if body.strip() != (source[n]["prompt"] or "").strip():
                print("  %-36s PROMPT DRIFT — turn %d does not match the transcript" % (name, n))
                print("        stored:     %s" % " ".join(body.split())[:100])
                print("        transcript: %s" % " ".join((source[n]["prompt"] or "").split())[:100])
                bad = True
                break
        if bad:
            drift += 1
            continue

        v, turn, said, got, note = verdict(source, expect, blame_from, callout)
        tally[v] += 1
        print("  %-36s %-8s turns %d-%d   user rejected it on %d, window opens %d"
              % (name, v, first, last, callout, blame_from))
        # BOTH SENTENCES, ALWAYS. The keyword halves of this scan are the part most likely to be
        # wrong, and a bare verdict hides which words produced it.
        if turn:
            print("        turn %d blamed: %s" % (turn, said))
            print("        tested first:  %s"
                  % (got if got else "(nothing on its own side for the same symptom)"))
        if note:
            print("        note: %s" % note)

    print()
    # Scored, then total. A suite printing only the total would read as full coverage on a
    # machine holding none of the corpus.
    print("%d of %d case(s) scored: %d held, %d unfired, %d blamed, %d silent"
          % (sum(tally.values()), len(cases),
             tally["HELD"], tally["UNFIRED"], tally["BLAMED"], tally["SILENT"]))
    print("Replay is the baseline — it reads what happened. This suite has no probe: the")
    print("condition needs a live instrument, so a change to check 8 is scored at a real bench.")
    if absent:
        print("%d case(s) skipped: the corpus is on one machine." % absent)
    print()

    if drift:
        return 1
    if STRICT and absent:
        return 1
    return 0


sys.exit(main())
