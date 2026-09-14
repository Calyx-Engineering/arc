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
#   reply contains five of those beside its two labels. Nothing structural separates a PLAIN
#   emphasis lead-in from a dropped topic.
#
#   SO THE REPLY HAS TO EVIDENCE ITS SECTIONS, AND THERE ARE TWO WAYS IT CAN. Every lead-in
#   labelled — nothing was dropped. Or two or more UNLABELLED lead-ins numbered: prose does
#   not open a paragraph with a number and a separator, so `**2 — What this repo is trying to
#   do.**` is an enumeration, and one such line is a figure in a sentence while two is a list.
#
#   Evidenced, a bold reply is graded exactly as a heading reply is, PARTIAL included.
#   Unevidenced, no verdict is invented: nothing labelled is NOTOPICS (the skill's own
#   single-decision template is two unlabelled bold lines, and failing it would be wrong), and
#   the partly labelled middle is BOLDONLY — that is both the exemplar's shape and the
#   defect's, and crediting it would score "labels the first few, then stops" as a pass, which
#   is the one answer this instrument must never give.
#
#   #160 RECORDED PARTIAL AS REACHABLE IN THE HEADING FORM ONLY. #259 found the case where
#   that was too cautious: a probe reply enumerated `0 —` through `5 —` with not one label on
#   it was scored NOTOPICS — the defect this file exists to catch, counted as having no topics
#   at all. On the enumeration evidence the ambiguity is absent, so the verdict is not
#   withheld. Once a reply is on the scored path a plain emphasis lead-in beside the numbered
#   ones counts as an unlabelled topic: the reply is enumerated, so a section that opted out
#   of the enumeration is the dropped topic this measures.
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
# NOT SCORED, AND LOUDLY. SINGLE (fewer topics than the case's min_topics — nothing to number
# at that width), NOTOPICS (no sections at
# all), BOLDONLY (the ungradeable shape above) and CUT (the runner truncated the reply) are
# counted in their own column and score in neither. Same reasoning as the thin floor in
# tools/response-length.py: a run made mostly of them is visibly not a measurement rather
# than a quiet pass.
#
# TWO MODES OVER ONE CASE SET, as in tools/response-length.py — replay reads the recorded
# transcript and is blind to any later edit, probe re-runs the turns live and is the only half
# that can see a change to the skill.
#
# AND A THIRD THAT SCORES TWO PROBES AGAINST EACH OTHER — #259. A rate on its own does not say
# whether the rule earned it. `camp-thoughts-multi-topic` scores 1.00 under --probe with #160's
# rule and 1.00 without it: the case passes, and passing means nothing, because the control
# passes too. Compare mode reads the two probe JSONs TN_PROBE_OUT already keeps, scores every
# case under both, prints the rates side by side, and answers the only question that separates
# a measurement from a regression floor — DOES THE RATE MOVE WHEN THE RULE IS REMOVED?
#
#   It bills nothing. Both sides are already-recorded runs, so a scorer correction re-scores
#   them for free — the argument that put TN_PROBE_OUT in #160 in the first place, after six
#   billed runs had to be re-taken.
#   It does not know which side is which. `before` is whichever JSON is named first; the run
#   that produced it is the run's own record to state. The tool reports the pair, not a claim
#   about a commit.
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
        # THE BOLD FORM TURNS ON ONE QUESTION: are these lead-ins sections, or is this prose?
        # A bold run opening a paragraph is how ordinary emphasis reads — `**Fails closed.**
        # Any check errors and it does not flip.` — and the skill's own single-decision
        # template is two unlabelled bold lines. Guessing wrong in one direction fails every
        # correctly formed reply; guessing wrong in the other scores the defect as a pass.
        #
        # So the reply has to EVIDENCE its sections, and there are two ways it can:
        #
        #   every lead-in labelled       `**D1 — …**`, `**D2 — …**`. Nothing was dropped.
        #   two or more UNLABELLED
        #   lead-ins numbered            `**2 — What this repo is trying to do.**` — #259.
        #                                Prose does not open a paragraph with a number and a
        #                                separator, so these are an enumeration and not
        #                                emphasis. Two, because one is a figure in a sentence.
        #
        # Evidenced, the reply is graded exactly as the heading form is, PARTIAL included.
        # #160 recorded PARTIAL as reachable in the heading form only; it is reachable here on
        # the same evidence, and withholding it scored a live probe reply enumerated `0 —`
        # through `5 —`, with not one label on it, as having no topics at all — the defect
        # this file exists to catch, counted as no topics. That run is in #259's dev-log.
        #
        # Unevidenced, no verdict is invented: nothing labelled is NOTOPICS, and the partly
        # labelled middle — the exemplar's shape AND the defect's, indistinguishable — is
        # BOLDONLY. Both score in neither column.
        #
        # TWO IS THE EVIDENCE BAR AND IT IS NOT min_topics, which is a different question:
        # how many topics a case requires before a reply is multi-topic at all. That gate is
        # applied below, to this path and the heading path alike, so the same reply cannot be
        # SINGLE as headings and a fail as lead-ins.
        # `not l and` is redundant TODAY — LABEL wants a leading capital and BARE a leading
        # digit, so the two cannot both match. It is written anyway because the rule is about
        # the UNLABELLED lead-ins, and a later loosening of LABEL would otherwise change this
        # verdict silently through a line that does not mention it.
        bare_unlabelled = sum(1 for n, l in zip(names, lab)
                              if not l and BARE.match(n.strip()))
        if not (all(lab) or bare_unlabelled >= 2):
            return ("BOLDONLY" if any(lab) else "NOTOPICS"), names, how, bare
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


def score_probe(live, name, min_topics):
    """(scored rows, which skills fired per turn) for one case out of one probe JSON."""
    scored, fired = [], {}
    for k, v in sorted(live.get(name, {}).items(), key=lambda kv: int(kv[0])):
        vd, names, how, bare = verdict(v.get("text", ""), v.get("cut", ""), min_topics)
        scored.append((int(k), vd, names, how, bare))
        fired[int(k)] = v.get("fired") or []
    return scored, fired


def fired_note(fired):
    """Firing is not the measurement — #155 settled that — but a rule in a skill BODY is only
    in context on the turns the skill fired. #158 measured the whole effect of a length fix
    coming from the description, on runs where it fired on no turn. Without this line a fix
    that moved nothing cannot be told apart from a fix that was never loaded."""
    hit = [t for t in fired if "chat-response" in fired[t]]
    return "chat-response fired on: " + (" ".join("t%d" % t for t in sorted(hit))
                                         if hit else "no turn")


def rate(good, bad):
    denom = good + bad
    return ("%d/%d  %.2f" % (good, denom, good / denom)) if denom else "0/0  n/a"


def separated(bg, bb, ag, ab, threshold):
    """Did this case's rate move from below the threshold to at or above it?

    Returns (verdict, why). THREE VERDICTS, NOT TWO — "it did not separate" covers situations
    that are not the same finding, and collapsing them loses the one that matters:

      YES   the before side is below the threshold and the after side is at or above it.
      NO    the before side is below the threshold and the after side did not reach it. The
            case HAD headroom and the change did not use it. That is a result about the change.
      n/a   the case had no headroom, for one of two quite different reasons, which is why the
            reason travels with the verdict rather than being inferred from it:
              · a side could not be scored at all — every turn CUT, or unscorable by shape;
              · the before side was already at or above the threshold.
                `camp-thoughts-multi-topic` is the second, 1.00 against 1.00, and is the whole
                reason #259 exists. Filing a saturated regression floor as NO would make a
                suite-level verdict unreachable for any suite that keeps one.

    A side where every turn was unscorable has no rate at all. Treating that as 0.00 would read
    "nothing could be measured" as "measured, and it failed" — which is exactly the answer the
    before side is expected to give, so it is the one that must not be guessed.
    """
    if not (bg + bb) and not (ag + ab):
        return "n/a", "neither side had a scorable turn"
    if not (bg + bb):
        return "n/a", "the before side had no scorable turn"
    if not (ag + ab):
        return "n/a", "the after side had no scorable turn"
    before = bg / (bg + bb)
    if before >= threshold:
        return "n/a", "the before side already scored at or above the threshold"
    if (ag / (ag + ab)) >= threshold:
        return "YES", "below the threshold before, at or above it after"
    return "NO", "had headroom and did not cross the threshold"


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
    print("  partial %d (fails, not part marks), unnumbered %d" % (
        tally.get("PARTIAL", 0), tally.get("UNNUMBERED", 0)))
    print("  not scored %d (single topic %d, no sections %d, unlabelled bold lead-ins %d, "
          "cut short by the runner %d)" % (
              unscored, tally.get("SINGLE", 0), tally.get("NOTOPICS", 0),
              tally.get("BOLDONLY", 0), tally.get("CUT", 0)))
    print("  every topic labelled: %s" % rate(good, bad))
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
    base_good = base_bad = base_unscored = 0
    per_case = []
    only = os.environ.get("TN_ONLY", "")

    print("topic-numbering — %d case(s) under %s, mode %s" % (len(cases), evaldir, mode))
    if mode == "compare":
        # Loaded once, not per case: two files read N times each is N chances for the pair
        # scored in the summary to differ from the pair scored in the blocks above it.
        before_path = os.environ["TN_PROBE_JSON_BASE"]
        after_path = os.environ["TN_PROBE_JSON"]
        before = json.load(io.open(before_path, encoding="utf-8"))
        after = json.load(io.open(after_path, encoding="utf-8"))
        print("  before  %s" % before_path)
        print("  after   %s" % after_path)
        print("  Which skill produced each is the run's record to state, not this tool's.")
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
        # REPLAY NEEDS THE TRANSCRIPT. PROBE AND COMPARE DO NOT — #259. Their scores come from
        # a probe JSON; the transcript is only what the drift check reads. Skipping the case
        # outright meant a pair of kept billed runs could not be re-scored on a machine
        # without the corpus, which is the whole claim TN_PROBE_OUT is sold on. The absence is
        # still reported, and --strict still fails on it: what is lost is the verbatim check,
        # not the measurement, and saying which is the point of separating them.
        #
        # The note is NOT written here. A case with no transcript may still turn out to have no
        # probe output either, and "scored anyway" printed beside "no probe output for this
        # case" is two contradictory lines about one case. It is written where the case is
        # actually scored.
        rows = []
        unchecked = not hits
        if unchecked:
            if mode == "replay":
                missing.append("%s  (session %s not on this machine)" % (name, session))
                continue
        else:
            rows = replay(hits[0], first, last)
        if hits:
            got = {t: q for t, q, _ in rows}
            for t, text in sorted(stored.items()):
                if t not in got:
                    drift.append("%s t%d  (turn not in %s)" % (name, t, session))
                elif got[t].rstrip("\n") != text.rstrip("\n"):
                    drift.append("%s t%d" % (name, t))
            for t, _, _ in rows:
                if t not in stored:
                    drift.append("%s t%d  (turn in the transcript, no turns/%d.md)"
                                 % (name, t, t))

        # --case NARROWS WHAT IS SCORED, NEVER WHAT IS CHECKED. The drift check and the
        # transcript lookup above have already run for every case, so `--case` cannot quietly
        # turn a drifted turns/<n>.md or a --strict failure into a clean exit. What it selects
        # is which case's score is reported, which is the question it is asked.
        if only and name != only and mode in ("compare", "probe"):
            continue

        if mode == "compare":
            bs, bf = score_probe(before, name, min_topics)
            as_, af = score_probe(after, name, min_topics)
            if not bs or not as_:
                side = "before" if not bs else "after"
                missing.append("%s  (no probe output for this case on the %s side)"
                               % (name, side))
                continue
            bg, bb, bu = report("%s  [before]" % name, bs, [fired_note(bf)])
            g, b, u = report("%s  [after]" % name, as_, [fired_note(af)])
            # SEPARATION IS A PROPERTY OF ONE CASE, NEVER OF THE POOL. Pooling the suite's
            # turns would let `camp-thoughts-multi-topic` — a deliberate 1.00/1.00 regression
            # floor — carry a case that did not move over the threshold, and print YES about
            # the very question this mode was built to answer. Each case decides for itself
            # and the summary counts them.
            sep, why = separated(bg, bb, g, b, threshold)
            per_case.append((name, sep, why))
            if unchecked:
                missing.append("%s  (session %s not on this machine; scored anyway from the "
                               "probe JSONs, turns unchecked)" % (name, session))
            print("  %-26s %-14s %s" % ("", "before", "after"))
            print("  %-26s %-14s %s" % ("every topic labelled", rate(bg, bb), rate(g, b)))
            print("  %-26s %-14d %d" % ("not scored", bu, u))
            print("  %-26s %s" % ("separates", sep))
            print()
            base_good += bg
            base_bad += bb
            base_unscored += bu
        elif mode == "probe":
            live = json.load(io.open(os.environ["TN_PROBE_JSON"], encoding="utf-8"))
            scored, fired = score_probe(live, name, min_topics)
            if not scored:
                missing.append("%s  (no probe output for this case)" % name)
                continue
            if unchecked:
                missing.append("%s  (session %s not on this machine; scored anyway from the "
                               "probe JSON, turns unchecked)" % (name, session))
            g, b, u = report("%s  [probe]" % name, scored, [fired_note(fired)])
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
    overall = (tot_good / denom) if denom else 0.0
    if mode == "compare":
        base_denom = base_good + base_bad
        base_overall = (base_good / base_denom) if base_denom else 0.0
        scope = "the case compared" if only else "all cases compared, pooled"
        print("%-32s %-14s %s" % (scope, "before", "after"))
        print("%-32s %-14s %s" % ("every topic labelled",
                                  rate(base_good, base_bad), rate(tot_good, tot_bad)))
        print("%-32s %-14d %d" % ("not scored", base_unscored, tot_unscored))
        print("%-32s %.2f" % ("threshold", threshold))
        # THE RATES ABOVE ARE POOLED AND THE VERDICT IS NOT. Each case answered for itself;
        # these lines repeat the answers and count them. A suite keeping a saturated
        # regression floor must be able to pass — the floor answers n/a, not NO, so it neither
        # lends its passes to a case that did not move nor withholds a verdict from one that
        # did. PASS means at least one case had headroom and used it, which is the question
        # #259 asks of this suite.
        moved = [n for n, s, _ in per_case if s == "YES"]
        stuck = [n for n, s, _ in per_case if s == "NO"]
        for n, s, why in per_case:
            print("%-32s %-6s %s" % ("  %s" % n, s, why))
        if not per_case:
            note = "NO   nothing was compared"
        elif moved:
            note = "YES  %s" % ", ".join(moved)
            if stuck:
                note += "  ·  did not move: %s" % ", ".join(stuck)
        elif stuck:
            note = ("NO   %s had headroom and did not cross the threshold"
                    % ", ".join(stuck))
        else:
            note = ("NO   no case had headroom, so neither side can show the rule working — "
                    "the reason is beside each case above")
        print("%-32s %s" % ("separates", note))
        print("%-32s %s" % ("verdict", "PASS" if moved else "FAIL"))
    else:
        print("%-32s %s" % ("all cases, every topic labelled",
                            "%d/%d  %.2f" % (tot_good, denom, overall)))
        print("%-32s %d" % ("not scored", tot_unscored))
        print("%-32s %.2f" % ("threshold", threshold))
        print("%-32s %s" % ("verdict", "PASS" if denom and overall >= threshold else "FAIL"))
    print()
    if mode == "replay":
        print("A replay score is history. It cannot see a change to skills/chat-response —")
        print("the transcript was recorded before the edit. Use --probe for that.")
    if mode == "compare":
        print("Neither side is billed here — both are runs TN_PROBE_OUT already kept. Which")
        print("skill produced each is the run's own record; this tool reports the pair.")
    print("The exit code reports turn drift and, with --strict, an absent transcript — whether")
    print("or not the case was scored anyway, and whether or not --case selected it. Not the score.")

    if drift:
        print()
        print("TURN DRIFT — a stored turns/<n>.md no longer matches the transcript:")
        for x in drift:
            print("  " + x)
    # Two headings, because they are two different things and one of them used to be filed
    # under the other's name: a case nobody could score, and a case that WAS scored from a
    # probe JSON while its transcript was not on this machine to check the turns against.
    # Printing "scored anyway" under NOT SCORED told the reader the opposite of what happened.
    scored_unchecked = [x for x in missing if "scored anyway" in x]
    not_scored = [x for x in missing if "scored anyway" not in x]
    if not_scored:
        print()
        print("NOT SCORED:")
        for x in not_scored:
            print("  " + x)
    if scored_unchecked:
        print()
        print("SCORED, TURNS NOT CHECKED — the transcript is not on this machine, so the")
        print("verbatim claim was not verified. --strict fails on this:")
        for x in scored_unchecked:
            print("  " + x)

    raise SystemExit(1 if (drift or (missing and strict)) else 0)


main()
