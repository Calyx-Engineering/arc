# saturation-cases.py — the scoring half of tools/saturation-cases.sh. Not run directly.
#
# Answers one question per case: did the session propose handing off BEFORE the user said the
# context was full — and did it wait long enough to be answering the session's state rather
# than nagging every long conversation.
#
# TWO MODES OVER ONE CASE SET, the same pair tools/response-length.py carries.
#
#   replay   Read the transcript the case came from. Free, deterministic, and blind to any
#            change made after the session was recorded. This is the baseline: it is what
#            happened, and for the case in this suite what happened is that nothing fired.
#   probe    Score the replies tools/response-length-probe.py produced by replaying the case's
#            turns as one live conversation. Billed. tools/saturation-cases.sh owns it.
#
# WHY TWO CONDITIONS AND NOT ONE. A pass is the skill firing AND the reply proposing a stop.
# Firing alone says the sweep was loaded and says nothing about what it did with check 7; a
# proposal alone is the model guessing, which is the reading #155 settled — firing is not
# adherence, and adherence without firing is not the rule working.
#
# THE PROPOSAL TEST IS A KEYWORD PROXY AND IS PRINTED, NOT SUMMARISED. A reply that says
# "handoff" while taking the next task passes it. So the matching sentence goes in the output:
# a reader can see what was matched, which is the only defence a keyword scan has.
#
# EARLY IS ITS OWN COLUMN, NOT A PASS. The check has two failure directions — never firing,
# and firing at every pause until the sweep is ignorable. A scorer with one column would call
# the second one success.
import io
import json
import os
import re
import sys

try:
    sys.stdout.reconfigure(encoding="utf-8", errors="replace")
except Exception:
    pass

ROOT = os.environ.get("SAT_ROOT_DIR", "")
EVALDIR = os.environ["SAT_EVAL_DIR"]
MODE = os.environ.get("SAT_MODE", "replay")
PROBE_JSON = os.environ.get("SAT_PROBE_JSON", "")
STRICT = os.environ.get("SAT_STRICT") == "1"

# A PROPOSAL IS TWO THINGS IN ONE SENTENCE, not a keyword. The first draft of this scan was
# the MARKER list alone, and on the real case it matched seven turns — every one of them a
# reply about the FILE called HANDOFF.md, in a session whose work was editing it. It reported
# those as the model guessing at the check. A scan that cannot tell "added to HANDOFF.md" from
# "want me to hand off" is measuring the corpus's filenames.
#
# So a sentence has to carry both: the thing being proposed, and the fact that it is being
# proposed. "Committed as a checkpoint of the pinout table" keeps the marker and loses the
# proposal, which is the distinction that was missing.
MARKER = re.compile(
    r"\bhand[\s-]?off\b(?!\.md)|\bhanding off\b|\bcheckpoint\b|\bfresh session\b|"
    r"\bnew session\b|\bnew thread\b|\bnext session\b|\bwrap (?:up|this session|the session)\b|"
    r"\bstop here\b|\bpick (?:this|it) up (?:in|next)\b",
    re.I,
)
PROPOSE = re.compile(
    r"\bwant me to\b|\bshall i\b|\bshould (?:i|we)\b|\bdo you want\b|\bpropose\b|\bsuggest\b|"
    r"\brecommend\b|\bworth\b|\btime to\b|\blet'?s\b|\bi can\b|\bi'?d\b|\bbefore (?:we|i) "
    r"(?:go|carry|continue)\b|\brather than (?:carry|push|take)\b|\bor push on\b",
    re.I,
)


def proposal(text):
    """The sentence proposing a stop, or "".

    Sentence-level, not document-level: a reply that edits HANDOFF.md in one paragraph and asks
    an unrelated question in another must not be read as having proposed anything.
    """
    for s in re.split(r"(?<=[.!?])\s+|\n", text or ""):
        if MARKER.search(s) and PROPOSE.search(s):
            return " ".join(s.split())[:160]
    return ""


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
    """The fields a saturation case.yaml carries. Purpose-built, not a YAML parser — the same
    trade tools/skill-cases.py makes, and for the same reason: the format is fixed by
    evals/saturation's own cases and written by hand.

      callout_turn   the turn the user said it himself. Firing here or later is not a pass
      fires_from     the earliest turn a proposal is noticing rather than nagging
      expect         the skill that has to have fired on the same turn
      source         the transcript, and the turn range the case carries
    """
    callout, fires_from, expect = 0, 0, []
    session, first, last = "", 0, 0
    section = None
    for raw in io.open(path, encoding="utf-8"):
        line = raw.rstrip("\n")
        if not line.strip() or line.lstrip().startswith("#"):
            continue
        if not line[:1].isspace():
            section = line.split(":", 1)[0].strip()
            m = re.match(r"callout_turn:\s*(\d+)", line)
            if m:
                callout = int(m.group(1))
            m = re.match(r"fires_from:\s*(\d+)", line)
            if m:
                fires_from = int(m.group(1))
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
    return callout, fires_from, expect, session, first, last


def case_turns(d):
    """turns/<n>.md, keyed by the SOURCE turn number — the same keying and the same reason as
    evals/response-length: the drift check reads the filename and needs no second mapping."""
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

    "text" is everything the assistant said between this prompt turn and the next, because
    that is what the user read. "fired" is every Skill invoked in the same span, which is the
    half of the pass condition a reply's words cannot answer.
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


def from_probe(blob, name):
    """The probe's per-turn record, in the shape replay() returns."""
    rows = {}
    for k, v in (blob.get(name) or {}).items():
        try:
            rows[int(k)] = {"prompt": "", "text": v.get("text", ""),
                            "fired": v.get("fired") or [], "cut": v.get("cut") or ""}
        except ValueError:
            continue
    return rows, max(rows) if rows else 0


def verdict(rows, expect, fires_from, callout):
    """(verdict, turn, sentence, turns that proposed unloaded, turns the runner cut).

    Scanned in turn order, so the FIRST qualifying turn decides. A session that nagged at turn
    5 and proposed properly at turn 44 is still a session that nagged at turn 5.

    A CUT TURN IS NOT A QUIET TURN, AND A WINDOW OF THEM IS NOT A SILENT SESSION.
    tools/response-length-probe.py marks a turn its per-turn budget or a turn cap stopped. Its
    reply is truncated, so it carries no proposal — and on a 52-turn case the cost per turn
    grows with the conversation, which puts the cut turns in exactly the window this suite
    scores. Two consequences, and both are handled here rather than in the report:

      a cut turn is dropped from the scan   its truncated text can still match PROPOSAL, and
                                            crediting or blaming a turn the runner stopped
                                            measures the budget, not the session
      a cut inside the window makes the     THIN, not SILENT. A session whose scoring window
      verdict THIN                          was never fully run has not been measured, and
                                            reporting that as "it stayed quiet" is the one
                                            wrong answer this instrument must not give
    """
    unloaded, cuts = [], []
    for n in sorted(rows):
        r = rows[n]
        if r.get("cut"):
            cuts.append(n)
            continue
        fired = any(s in r["fired"] for s in expect) if expect else bool(r["fired"])
        said = proposal(r["text"])
        if said and not fired:
            unloaded.append((n, said))
            continue
        if not (fired and said):
            continue
        if n < fires_from:
            return "EARLY", n, said, unloaded, cuts
        if n >= callout:
            return "LATE", n, said, unloaded, cuts
        return "HELD", n, said, unloaded, cuts
    if any(fires_from <= c < callout for c in cuts):
        return "THIN", 0, "", unloaded, cuts
    return "SILENT", 0, "", unloaded, cuts


def main():
    cases = []
    for d in sorted(os.listdir(EVALDIR)):
        p = os.path.join(EVALDIR, d)
        if os.path.isfile(os.path.join(p, "case.yaml")):
            cases.append((d, p))
    if not cases:
        print("no cases under " + EVALDIR)
        return 2

    blob = {}
    if MODE == "probe":
        if not PROBE_JSON or not os.path.exists(PROBE_JSON):
            print("probe mode needs SAT_PROBE_JSON pointing at the runner's output")
            return 2
        blob = json.load(io.open(PROBE_JSON, encoding="utf-8"))

    print("saturation — did the session say it before the user did?   mode: %s" % MODE)
    print()

    tally = {"HELD": 0, "LATE": 0, "EARLY": 0, "SILENT": 0, "THIN": 0}
    absent, drift = 0, 0

    for name, d in cases:
        callout, fires_from, expect, session, first, last = read_case(os.path.join(d, "case.yaml"))
        stored = case_turns(d)
        if not callout or not session:
            print("  %-34s case.yaml is missing callout_turn or source.session" % name)
            drift += 1
            continue

        if MODE == "probe":
            rows, seen = from_probe(blob, name)
            if not rows:
                print("  %-34s no probe replies recorded" % name)
                absent += 1
                continue
        else:
            path = find_session(session)
            if not path:
                print("  %-34s transcript %s not on this machine — skipped" % (name, session))
                absent += 1
                continue
            rows, seen = replay(path, first, last)
            # The verbatim claim is checked, not trusted. Same rule as tools/skill-cases.py:
            # "drawn from a session that happened" stops being true the moment a turn is tidied.
            for n, body in sorted(stored.items()):
                if n not in rows:
                    print("  %-34s PROMPT DRIFT — turn %d is not in the transcript (it has %d turns)"
                          % (name, n, seen))
                    drift += 1
                    break
                if body.strip() != (rows[n]["prompt"] or "").strip():
                    print("  %-34s PROMPT DRIFT — turn %d does not match the transcript" % (name, n))
                    print("        stored:     %s" % " ".join(body.split())[:100])
                    print("        transcript: %s" % " ".join((rows[n]["prompt"] or "").split())[:100])
                    drift += 1
                    break

        v, turn, said, unloaded, cuts = verdict(rows, expect, fires_from, callout)
        tally[v] += 1
        print("  %-34s %-7s turns %d-%d   user called it on %d, earliest fire %d"
              % (name, v, first, last, callout, fires_from))
        if turn:
            print("        turn %d: %s" % (turn, said or "(no sentence captured)"))
        for u, said_u in unloaded:
            # With its sentence, always. The keyword half of this scan is the part most likely
            # to be wrong, and a bare turn number hides which words it fired on.
            print("        turn %d proposed with no skill fire — the model guessing: %s"
                  % (u, said_u))
        if cuts:
            inside = [c for c in cuts if fires_from <= c < callout]
            print("        %d turn(s) cut by the runner and not scored: %s%s"
                  % (len(cuts), ", ".join(str(c) for c in cuts),
                     "" if not inside else
                     " — %d inside the window, so the window was never fully run"
                     % len(inside)))

    print()
    # Scored, then total. A suite that printed only the total would read as full coverage on a
    # machine holding none of the corpus.
    print("%d of %d case(s) scored: %d held, %d late, %d early, %d silent, %d thin"
          % (sum(tally.values()), len(cases),
             tally["HELD"], tally["LATE"], tally["EARLY"], tally["SILENT"], tally["THIN"]))
    if MODE == "replay":
        print("Replay is the baseline — it reads what happened and cannot see a change to the skill.")
    if absent:
        print("%d case(s) skipped: the corpus is on one machine." % absent)
    print()

    if drift:
        return 1
    if STRICT and absent:
        return 1
    return 0


sys.exit(main())
