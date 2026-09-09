# topic-numbering.py — the scoring half of tools/topic-numbering.sh. Not run directly.
#
# Answers one question per turn: if this reply raised more than one topic, could the user
# answer it by number?
#
# THE DEFECT IT MEASURES. #160 — numbered discussion topics are used at the start of a reply
# and dropped part-way through. The user gets `V1` and `V2`, then three more topics with no
# labels, and has to restate the question to answer any of them. Two turns before this case's
# first turn, the same conversation shows the mechanism working: a reply numbered its topics
# D1 and D2 and the user's entire next message was "D1 - new / D2 - off".
#
# WHAT A TOPIC IS, STRUCTURALLY. Headings at the reply's shallowest heading level. A reply
# built out of two or more sibling sections is a multi-topic reply, which is the shape
# skills/chat-response says to label. Deeper headings are that topic's internals — a single
# `## Section` over two `### sub-points` is one topic, not two. The one exception is a lone
# level-1 heading: `# Title` over three `## sections` is a title, so it is dropped and the
# sections are the topic list.
#
#   THE BOLD FORM IS REAL AND IS MOSTLY UNGRADEABLE. The reply this whole case is built
#   around — session 0c28d2ed t127 — carries no headings at all. It numbers inline:
#
#       **D1 — new mechanism or extend m12?** I lean new. m12 is *issue linking* …
#       **D2 — does the flip default to on or off?** I lean **off, offered at arc start** …
#
#   The user answered it in four words: "D1 - new / D2 - off". So a bold lead-in CAN carry a
#   label the user answers by number. But the same construction is how ordinary emphasis
#   opens a paragraph — "**Fails closed.** Any check errors and it does not flip." — and that
#   reply contains five of those beside its two labels. Nothing structural separates an
#   emphasis lead-in from a dropped topic, so the three cases are split:
#
#       none labelled    NOTOPICS. No evidence of topics. The skill's own single-decision
#                        template is two unlabelled bold lines, and failing it would be wrong.
#       all labelled     NUMBERED. Nothing ambiguous — nothing was dropped.
#       some labelled    BOLDONLY, unscored. This is both the exemplar's shape and the
#                        defect's, and they cannot be told apart. Crediting it would score
#                        "labels the first few, then stops" as a pass, which is the one
#                        answer this instrument must never give.
#
#   PARTIAL is therefore detectable in the heading form only, which is the form the skill
#   documents. Recorded as a limit rather than papered over.
#
# WHAT A LABEL IS. `V1`, `A12`, `D2` — one or two capitals and a number, at the head of the
# section, followed by a separator or the end of the line. The separator is what keeps a
# component designator or a back-reference out: "F5 test plan" and "R3 estimate" are not
# labels, "Q2 — what you have to comply with" is. `.` and `)` count as separators, so
# "D1. first" and "D1) first" are labels — the model writes both and the skill names neither.
#
#   A BARE NUMBER IS NOT A LABEL. "## 1. Branch from the sub-branch" scores unlabelled and is
#   reported as such. skills/chat-response and CLAUDE.md both forbid it — issue numbers,
#   mechanism numbers and pass numbers appear in the same sentences, so `1` names nothing.
#
# PARTIAL IS A FAIL, NOT PART MARKS. It is counted in the denominator beside UNNUMBERED. A
# reply that labels two topics and drops the rest leaves the reader unable to tell which
# topics they may answer by number, so they restate all of them — no better than none, and it
# reads like progress, which is worse. #160 requires this explicitly.
#
# NOT SCORED, AND LOUDLY. SINGLE (one topic — nothing to number), NOTOPICS (no sections at
# all), BOLDONLY (the ungradeable shape above) and CUT (the runner truncated the reply) are
# counted in their own column and score in neither. Same reasoning as the thin floor in
# tools/response-length.py: a run made mostly of them is visibly not a measurement rather
# than a quiet pass.
#
# TWO MODES OVER ONE CASE SET, as in tools/response-length.py — replay reads the recorded
# transcript and is blind to any later edit, probe re-runs the turns live and is the only half
# that can see a change to the skill.
import io
import json
import os
import re
import sys

# The case scan and the fence rule, shared with the other three graders — #265. `tools/` is
# sys.path[0] because topic-numbering.sh runs this file by path.
import case_reader

try:
    sys.stdout.reconfigure(encoding="utf-8", errors="replace")
except Exception:
    pass

HEADING = re.compile(r"^\s{0,3}(#{1,6})\s+(.*?)\s*$")
# A bold run opening a line. Prose may follow it on the same line — that is how the exemplar
# in the header is written, and a pattern anchored to the end of the line cannot see it.
BOLD_LEAD = re.compile(r"^\s*\*{2,3}(.+?)\*{2,3}")
LABEL = re.compile(r"^\**([A-Z]{1,2}\d{1,3})\**\s*(?:[—–:.)-]|$)")
BARE = re.compile(r"^\**(\d{1,3})(?:[.)]|\s*[—–:-])")


def topics(text):
    """The reply's top-level section titles, and how they were found.

    Fenced blocks are skipped: a heading inside a code sample is sample text, not a section.
    The opening fence's character and length are remembered — so neither a ~~~ line inside a
    ``` block nor a ``` line inside a ```` block closes it. That rule is tools/case_reader.py's
    `Fence`, which is where it lives now for all four graders (#265).
    """
    heads, bolds, fence = [], [], case_reader.Fence()
    for line in (text or "").splitlines():
        if fence.delimiter(line):
            continue
        if fence.open:
            continue
        m = HEADING.match(line)
        if m:
            heads.append((len(m.group(1)), m.group(2)))
            continue
        b = BOLD_LEAD.match(line)
        if b:
            bolds.append(b.group(1))
    if heads:
        levels = sorted({h[0] for h in heads})
        # A lone `# Title` over three `## sections` is a title, so it is dropped and the
        # sections are the topics. Only a level-1 heading is treated this way: a single
        # `## Section` above two `### sub-points` is one topic with internals, and
        # descending into it would score a one-topic reply as two unlabelled ones.
        if levels[0] == 1 and sum(1 for h in heads if h[0] == 1) == 1 and len(levels) > 1:
            heads = [h for h in heads if h[0] != 1]
            levels = sorted({h[0] for h in heads})
        top = levels[0]
        return [t for lvl, t in heads if lvl == top], "headings"
    if len(bolds) >= 2:
        return bolds, "bold lead-ins"
    return [], "none"


def labelled(title):
    return bool(LABEL.match(title.strip()))


def verdict(text, cut, min_topics):
    """NUMBERED / PARTIAL / UNNUMBERED / SINGLE / NOTOPICS / BOLDONLY / CUT, with the titles."""
    if cut:
        return "CUT", [], "none", 0
    names, how = topics(text)
    bare = sum(1 for n in names if BARE.match(n.strip()))
    if not names:
        return "NOTOPICS", names, how, bare
    lab = [labelled(n) for n in names]
    if how == "bold lead-ins":
        # Three outcomes, because an unlabelled bold lead-in is genuinely ambiguous — it is
        # equally a dropped topic and an ordinary emphasis opening, and the skill's own
        # "**Decision needed.**" template is the second.
        #
        #   none labelled     no evidence of topics at all. NOTOPICS, as before this path
        #                     existed. Scoring it UNNUMBERED would fail every correctly
        #                     formed single-decision reply.
        #   all labelled      nothing is ambiguous: nothing was dropped. NUMBERED.
        #   some labelled     the ambiguous middle, and it is exactly the shape of the defect
        #                     as well as of the exemplar. BOLDONLY — reported, not guessed.
        #                     Crediting it would score "labels the first few, then stops" as
        #                     a pass, which is the defect #160 exists to catch.
        if not any(lab):
            return "NOTOPICS", names, how, bare
        if all(lab) and len(names) >= min_topics:
            return "NUMBERED", names, how, bare
        return "BOLDONLY", names, how, bare
    if len(names) < min_topics:
        return "SINGLE", names, how, bare
    if all(lab):
        return "NUMBERED", names, how, bare
    if any(lab):
        return "PARTIAL", names, how, bare
    return "UNNUMBERED", names, how, bare


def is_prompt_turn(o):
    """A turn a prompt opened. Same discriminators as tools/response-length.py, same reasons —
    tool results, skill injections, interrupts and task notifications all arrive as "user"
    and none of them is a turn."""
    if o.get("type") != "user" or o.get("isMeta"):
        return False
    c = (o.get("message") or {}).get("content")
    if isinstance(c, list):
        if any(isinstance(x, dict) and x.get("type") == "tool_result" for x in c):
            return False
        joined = "".join(x.get("text", "") for x in c
                         if isinstance(x, dict) and x.get("type") == "text")
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
        return "\n".join(x.get("text", "") for x in c
                         if isinstance(x, dict) and x.get("type") == "text")
    return ""


def read_case(path):
    """The fields a topic-numbering case.yaml carries.

    The scan is tools/case_reader.py's — one reader for the four graders, #265 — and the same
    trade it always made: purpose-built, not a YAML parser, because the format is fixed by
    evals/topic-numbering. What is left here is which fields this suite wants.

    `first_turn` and `last_turn` go through `int()` rather than `leading_int`, because they
    always did: a turn number with trailing text is a broken case and should say so.
    """
    min_topics, session, first, last = 2, "", 0, 0
    for section, key, value in case_reader.fields(path):
        if not section:
            if key == "min_topics":
                min_topics = case_reader.leading_int(value, min_topics)
            continue
        if section != "source":
            continue
        t = case_reader.token(value)
        if not t:
            continue
        if key == "session":
            session = t
        elif key == "first_turn":
            first = int(t)
        elif key == "last_turn":
            last = int(t)
    return min_topics, session, first, last


def case_turns(d):
    """turns/<n>.md, keyed by the SOURCE turn number — the drift check reads the filename."""
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
    """(turn, prompt text, everything the assistant said) for each turn in range.

    Every block counts, not only the last one. A reply split over four blocks around tool
    calls is one reply to the reader, and a topic raised in the third block is a topic.
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
                rows.append((n, cur, "\n\n".join(blocks)))
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
        rows.append((n, cur, "\n\n".join(blocks)))
    return rows


def report(name, scored, extra=None):
    tally = {}
    for _, v, _, _, _ in scored:
        tally[v] = tally.get(v, 0) + 1
    print(name)
    for turn, v, names, how, bare in scored:
        lab = sum(1 for n in names if labelled(n))
        note = ""
        if names:
            note = "  %d/%d labelled, by %s" % (lab, len(names), how)
            if bare:
                note += ", %d bare number%s" % (bare, "" if bare == 1 else "s")
        print("  %-10s t%-4d%s" % (v, turn, note))
        for n in names:
            print("             %s %s" % ("LABEL " if labelled(n) else "      ", n[:88]))
    if extra:
        for line in extra:
            print("  " + line)
    good = tally.get("NUMBERED", 0)
    bad = tally.get("PARTIAL", 0) + tally.get("UNNUMBERED", 0)
    unscored = (tally.get("SINGLE", 0) + tally.get("NOTOPICS", 0)
                + tally.get("BOLDONLY", 0) + tally.get("CUT", 0))
    denom = good + bad
    rate = ("%d/%d  %.2f" % (good, denom, good / denom)) if denom else "0/0  n/a"
    print("  partial %d (fails, not part marks), unnumbered %d" % (
        tally.get("PARTIAL", 0), tally.get("UNNUMBERED", 0)))
    print("  not scored %d (single topic %d, no sections %d, unlabelled bold lead-ins %d, "
          "cut short by the runner %d)" % (
              unscored, tally.get("SINGLE", 0), tally.get("NOTOPICS", 0),
              tally.get("BOLDONLY", 0), tally.get("CUT", 0)))
    print("  every topic labelled: %s" % rate)
    print()
    return good, bad, unscored


def main():
    evaldir = os.environ["TN_EVAL_DIR"]
    mode = os.environ.get("TN_MODE", "replay")
    threshold = float(os.environ.get("TN_THRESHOLD", "0.67"))
    strict = os.environ.get("TN_STRICT") == "1"

    cases = []
    for dirpath, _, files in os.walk(evaldir):
        if "case.yaml" in files:
            cases.append(os.path.join(dirpath, "case.yaml"))
    cases.sort()
    if not cases:
        print("no cases under %s" % evaldir, file=sys.stderr)
        raise SystemExit(2)

    drift, missing = [], []
    tot_good = tot_bad = tot_unscored = 0

    print("topic-numbering — %d case(s) under %s, mode %s" % (len(cases), evaldir, mode))
    print()

    for cp in cases:
        d = os.path.dirname(cp)
        name = os.path.relpath(d, evaldir).replace(os.sep, "/")
        min_topics, session, first, last = read_case(cp)
        stored = case_turns(d)
        if not session or not first:
            missing.append("%s  (case.yaml names no source.session or source.first_turn)" % name)
            continue

        root = os.environ.get("TN_ROOT_DIR", "")
        hits = []
        if root and os.path.isdir(root):
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
        got = {t: q for t, q, _ in rows}
        for t, text in sorted(stored.items()):
            if t not in got:
                drift.append("%s t%d  (turn not in %s)" % (name, t, session))
            elif got[t].rstrip("\n") != text.rstrip("\n"):
                drift.append("%s t%d" % (name, t))
        for t, _, _ in rows:
            if t not in stored:
                drift.append("%s t%d  (turn in the transcript, no turns/%d.md)" % (name, t, t))

        if mode == "probe":
            live = json.load(io.open(os.environ["TN_PROBE_JSON"], encoding="utf-8"))
            scored, fired = [], {}
            for k, v in sorted(live.get(name, {}).items(), key=lambda kv: int(kv[0])):
                vd, names, how, bare = verdict(v.get("text", ""), v.get("cut", ""), min_topics)
                scored.append((int(k), vd, names, how, bare))
                fired[int(k)] = v.get("fired") or []
            if not scored:
                missing.append("%s  (no probe output for this case)" % name)
                continue
            # Firing is not the measurement — #155 settled that — but a rule in a skill BODY
            # is only in context on the turns the skill fired. #158 measured the whole effect
            # of a length fix coming from the description, on runs where it fired on no turn.
            hit = [t for t in fired if "chat-response" in fired[t]]
            extra = ["chat-response fired on: " + (" ".join("t%d" % t for t in sorted(hit))
                                                   if hit else "no turn")]
            g, b, u = report("%s  [probe]" % name, scored, extra)
        else:
            scored = []
            for t, _, reply in rows:
                vd, names, how, bare = verdict(reply, "", min_topics)
                scored.append((t, vd, names, how, bare))
            g, b, u = report("%s  [replay]" % name, scored)
        tot_good += g
        tot_bad += b
        tot_unscored += u

    denom = tot_good + tot_bad
    rate = (tot_good / denom) if denom else 0.0
    print("%-32s %s" % ("all cases, every topic labelled",
                        "%d/%d  %.2f" % (tot_good, denom, rate)))
    print("%-32s %d" % ("not scored", tot_unscored))
    print("%-32s %.2f" % ("threshold", threshold))
    print("%-32s %s" % ("verdict", "PASS" if denom and rate >= threshold else "FAIL"))
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
