# report-grade.py — the scoring half of tools/report-grade.sh. Not run directly.
#
# Answers one question per report: does it open with the conclusion, or with the story of how
# the conclusion was reached?
#
# THE DEFECT IT MEASURES. #159 — reports, READMEs and one spec written as an account of the
# exploration rather than as the current state of knowledge. Five post-install corrections, the
# third-largest cluster in the 2026-09 retrospective. skills/engineering-report has said
# "Findings first" since it was written; nothing has ever checked a document against it.
#
# WHY A FOURTH INSTRUMENT. The three that exist score REPLIES from a transcript —
# skill-cases.sh asks whether a skill fired, response-length.sh counts words, topic-numbering.sh
# counts labels. A report is not a reply. It is a file, it is edited over days, and the turn it
# was written on says nothing about the shape it ended up in. #155 recorded Fire-5 as
# "unmeasured" for exactly this reason: engineering-report fired once in fifteen sessions and no
# session has it firing while a report stayed narrative. Firing and shape are separate
# questions, and this is the instrument for the second one.
#
# IT DOES NOT NEED A MODEL TO GRADE IT, for the same reason response-length.py does not. "Is the
# first section of this document a findings section, and is there a sentence above it explaining
# what the document is" is countable. `claude plugin eval` is still gated (#181) and is still
# what a judgement-shaped grader would need; this is not one.
#
# WHAT IT READS. The OPENING — the document's first line through the end of its first `##`
# section. Nothing below is read. A conclusion in section 9 does not repair an opening; the
# reader who stops after the first screen never reaches it, and that reader is who the rule
# exists for.
#
# THREE PARTS OF AN OPENING, TOLD APART. A status header is required by the skill (its section 1:
# subject, related issue, author, date, status) and a safety callout is a finding. Neither is a
# framing preamble, and a check that failed them would be unusable on a correctly built report.
# So YAML front matter and bold-label lines ("**Status:** ...") are the status header,
# blockquotes are content, and what is left is prose — which is where a preamble hides.
#
#   THE DEFERRED CHECK READS THE WHOLE OPENING, INCLUDING THE STATUS HEADER. "**Status:**
#   complete. Conclusion in Section 9." is a status line and a deferred conclusion at once. The
#   preamble check exempts that line; the deferred check must not, or the clearest instance of
#   the defect in the corpus scores clean.
#
# EVERY FLAG IS PRINTED AND THE VERDICT IS THE WORST ONE. NARRATIVE > DEFERRED > PREAMBLE.
# Opening on the wrong section is a bigger failure than a spare sentence above the right one,
# and reporting only the worst would hide the other two on a document that has all three.
#
# UNCLEAR IS REPORTED, NEVER GUESSED. A first heading in neither the findings class nor the
# background class could be a findings section named after its subject, or a background section
# named the same way. Nothing structural separates them. Same reasoning as BOLDONLY in
# tools/topic-numbering.py: crediting the ambiguous middle would score the defect as a pass.
#
# THE EXCERPT IS THE CASE, AND THE CORPUS IS CHECKED AGAINST IT. Each case carries excerpt.md,
# copied verbatim from a document in another repository, plus the line range it came from. The
# excerpt is what gets scored, so the suite runs anywhere. When the corpus IS on the machine, the
# excerpt is compared against those lines and a mismatch fails the run — the same verbatim claim
# tools/topic-numbering.py makes about turns/<n>.md, checked the same way.
import io
import os
import re
import sys

try:
    sys.stdout.reconfigure(encoding="utf-8", errors="replace")
except Exception:
    pass

FENCE = re.compile(r"^\s*(`{3,}|~{3,})")
HEADING = re.compile(r"^\s{0,3}(#{1,6})\s+(.*?)\s*$")
RULE = re.compile(r"^(-{3,}|\*{3,}|_{3,})$")
# A "**Label:**" line. This is the status header's shape, and the skill requires one.
BOLD_LABEL = re.compile(r"^\s*\*{2}[^*]{1,40}:\*{2}")

# The first section's heading decides NARRATIVE. Both lists are matched on whole words against
# the heading with any leading number, bullet or separator stripped.
FINDINGS = ("finding", "findings", "conclusion", "conclusions", "recommendation",
            "recommendations", "answer", "answers", "result", "results", "verdict",
            "summary", "decision", "decisions", "outcome", "state", "status")
BACKGROUND = ("question", "questions", "background", "context", "problem", "purpose",
              "introduction", "intro", "overview", "method", "methods", "methodology",
              "approach", "history", "scope", "investigation", "motivation", "premise")

# A sentence that says what the document is. The reader opened it; they know.
PREAMBLE_PAT = [
    re.compile(r"^(this|the following)\s+(document|report|note|page|study|section|write-?up)\b",
               re.I),
    re.compile(r"\bthis\s+(document|report|note|page|study)\s+"
               r"(is|was|describes|covers|records|asks|explains|sets out|captures|presents|"
               r"summari[sz]es|contains|holds)\b", re.I),
    re.compile(r"^(findings and conclusions|conclusions and findings|investigation only|"
               r"background|for reference|reference only|notes only|working notes|"
               r"what follows|the purpose of)\b", re.I),
    re.compile(r"\bwhat\s+(this|the)\s+(document|report|note|page)\s+(is|does|covers|holds)\b",
               re.I),
]

# The conclusion, somewhere else. A pointer where the answer should be.
DEFERRED_PAT = [
    re.compile(r"\b(conclusion|conclusions|recommendation|answer|finding|findings|verdict|"
               r"result|results)\s+(?:is\s+|are\s+)?in\s+(?:section|sec\.?|§)\s*\d", re.I),
    re.compile(r"\bsee\s+(?:section|sec\.?|§)\s*\d+\s+for\s+the\s+"
               r"(conclusion|recommendation|answer|finding|result|verdict)", re.I),
    re.compile(r"\b(conclusion|recommendation|answer|verdict)\s+(?:is\s+)?(?:in|at)\s+the\s+"
               r"(end|bottom)\b", re.I),
]


def strip_front_matter(lines):
    """YAML front matter is a status header in another notation. Returns (body, header)."""
    if lines and lines[0].strip() == "---":
        for i in range(1, len(lines)):
            if lines[i].strip() == "---":
                return lines[i + 1:], lines[:i + 1]
    return lines, []


def opening(text):
    """(header lines, prose lines, first heading, whether a `##` was found).

    The opening is the document's start through the end of its first `##` section. Fenced
    blocks are skipped so a heading inside a code sample is not mistaken for the section.
    """
    lines, header = strip_front_matter((text or "").splitlines())
    prose, first, seen, fence = [], None, 0, ""
    for line in lines:
        f = FENCE.match(line)
        if f:
            run = f.group(1)
            if not fence:
                fence = run
            elif run[0] == fence[0] and len(run) >= len(fence):
                fence = ""
            continue
        if fence:
            if first is None:
                prose.append(line)
            continue
        m = HEADING.match(line)
        if m:
            level = len(m.group(1))
            if level >= 2:
                seen += 1
                if seen == 1:
                    first = m.group(2)
                elif seen == 2:
                    break
            elif first is None:
                header.append(line)          # a lone `# Title` is the title, not prose
            continue
        if first is None:
            (header if BOLD_LABEL.match(line) else prose).append(line)
    return header, prose, first, first is not None


def heading_class(title):
    """"findings", "background" or "" — decided by the words the heading leads with."""
    t = re.sub(r"^[\s#*_`]*[0-9IVXivx]+\s*[.)·—–:-]*\s*", "", (title or "")).strip()
    t = t.lower().replace("’", "'")
    words = re.findall(r"[a-z']+", t)
    if not words:
        return ""
    # Only the first three words decide it. "Summary of findings" is a findings section and so
    # is "Findings — background to the sweep"; a background word deep in a long heading is
    # describing the subject, not the section.
    for w in words[:3]:
        if w in FINDINGS:
            return "findings"
        if w in BACKGROUND:
            return "background"
    return ""


def prose_text(prose):
    """Prose with blockquote callouts and horizontal rules dropped. A `> [!WARNING]` block is a
    finding — the PoE report's damaged-DUT caveat is why the skill has a safety section — and
    failing a report for carrying one would invert the rule."""
    out = []
    for line in prose:
        s = line.strip()
        if not s or s.startswith(">") or RULE.match(s):
            continue
        out.append(s)
    return "\n".join(out)


def grade_opening(text):
    """(verdict, flags, first heading, heading class)."""
    header, prose, first, found = opening(text)
    if not found:
        return "NOSECTION", [], first, ""
    body = prose_text(prose)
    whole = "\n".join(header + prose)
    flags = []
    if any(p.search(body) for p in PREAMBLE_PAT):
        flags.append("preamble")
    if any(p.search(whole) for p in DEFERRED_PAT):
        flags.append("deferred")
    cls = heading_class(first)
    if cls == "background":
        flags.append("background-first")
        return "NARRATIVE", flags, first, cls
    if cls == "":
        return "UNCLEAR", flags, first, cls
    if "deferred" in flags:
        return "DEFERRED", flags, first, cls
    if "preamble" in flags:
        return "PREAMBLE", flags, first, cls
    return "CONCLUSION", flags, first, cls


def read_case(path):
    """corpus, document, lines. Purpose-built, not a YAML parser — the same trade as
    tools/topic-numbering.py, and the format is fixed by evals/report-shape."""
    out = {"corpus": "", "document": "", "lines": ""}
    for raw in io.open(path, encoding="utf-8"):
        line = raw.rstrip("\n")
        if not line.strip() or line.lstrip().startswith("#") or line[:1].isspace():
            continue
        k, _, v = line.partition(":")
        if k.strip() in out:
            out[k.strip()] = v.strip()
    return out["corpus"], out["document"], out["lines"]


def corpus_lines(root, corpus, document, rng):
    """The named lines of the source document, or None when the corpus is not on this machine."""
    if not root or not corpus or not document or not rng:
        return None
    m = re.match(r"(\d+)\s*-\s*(\d+)$", rng)
    if not m:
        return None
    path = os.path.join(root, corpus, *document.split("/"))
    if not os.path.isfile(path):
        return None
    lines = io.open(path, encoding="utf-8", errors="replace").read().splitlines()
    return "\n".join(lines[int(m.group(1)) - 1:int(m.group(2))])


def grade_one(path):
    """--file: grade a single document, so the rule the skill states can be run against the
    report being written rather than only against the suite."""
    text = io.open(path, encoding="utf-8", errors="replace").read()
    verdict, flags, first, cls = grade_opening(text)
    print("report-grade — %s" % path)
    print()
    print("  %-10s %s" % (verdict, ("  flags: " + ", ".join(flags)) if flags else ""))
    print("  first section: %s%s" % (
        (first or "(none)")[:70], ("  [%s]" % cls) if cls else "  [unclassified]"))
    print()
    if verdict == "CONCLUSION":
        print("  The opening states the finding. skills/engineering-report, The opening.")
    elif verdict in ("UNCLEAR", "NOSECTION"):
        print("  Not scored — read it yourself. skills/engineering-report, The opening.")
    else:
        print("  Read skills/engineering-report, The opening. This is #159's defect.")
    # The exit code is the verdict here, unlike the suite: one document has one answer, and a
    # caller checking a report before committing it wants that answer in $?.
    raise SystemExit(0 if verdict in ("CONCLUSION", "UNCLEAR", "NOSECTION") else 1)


def main():
    one = os.environ.get("RG_FILE", "")
    if one:
        grade_one(one)
    evaldir = os.environ["RG_EVAL_DIR"]
    root = os.environ.get("RG_CORPUS_DIR", "")
    strict = os.environ.get("RG_STRICT") == "1"
    threshold = float(os.environ.get("RG_THRESHOLD", "0.67"))

    cases = []
    for dirpath, _, files in os.walk(evaldir):
        if "case.yaml" in files:
            cases.append(os.path.join(dirpath, "case.yaml"))
    cases.sort()
    if not cases:
        print("no cases under %s" % evaldir, file=sys.stderr)
        raise SystemExit(2)

    drift, absent = [], []
    tally = {}

    print("report-grade — %d case(s) under %s" % (len(cases), evaldir))
    print()

    for cp in cases:
        d = os.path.dirname(cp)
        name = os.path.relpath(d, evaldir).replace(os.sep, "/")
        corpus, document, rng = read_case(cp)
        xp = os.path.join(d, "excerpt.md")
        if not os.path.isfile(xp):
            absent.append("%s  (no excerpt.md)" % name)
            continue
        text = io.open(xp, encoding="utf-8", errors="replace").read()

        src = corpus_lines(root, corpus, document, rng)
        if src is None:
            absent.append("%s  (corpus %s not on this machine — scored from excerpt.md)"
                          % (name, corpus))
        elif src.rstrip("\n") != text.rstrip("\n"):
            drift.append("%s  (%s lines %s no longer match excerpt.md)" % (name, document, rng))

        # Only a region that starts at line 1 is an opening. A case cut from the middle of a
        # document is evidence about something else — a table, a section — and grading it for
        # conclusion-first would score the absence of a status header as a defect.
        if not re.match(r"1\s*-", rng or ""):
            verdict, flags, first, cls = "NOTOPENING", [], None, ""
        else:
            verdict, flags, first, cls = grade_opening(text)
        tally[verdict] = tally.get(verdict, 0) + 1
        if verdict == "NOTOPENING":
            print("  %-10s %s  (region %s does not start at line 1)" % (verdict, name, rng))
            continue
        note = ("  flags: " + ", ".join(flags)) if flags else ""
        print("  %-10s %s%s" % (verdict, name, note))
        print("             first section: %s%s" % (
            (first or "(none)")[:70], ("  [%s]" % cls) if cls else "  [unclassified]"))
    print()

    good = tally.get("CONCLUSION", 0)
    bad = tally.get("NARRATIVE", 0) + tally.get("DEFERRED", 0) + tally.get("PREAMBLE", 0)
    unscored = (tally.get("UNCLEAR", 0) + tally.get("NOSECTION", 0)
                + tally.get("NOTOPENING", 0))
    denom = good + bad
    rate = (good / denom) if denom else 0.0
    print("  narrative %d, deferred %d, preamble %d" % (
        tally.get("NARRATIVE", 0), tally.get("DEFERRED", 0), tally.get("PREAMBLE", 0)))
    print("  not scored %d (unclear heading %d, no section %d, not an opening %d)" % (
        unscored, tally.get("UNCLEAR", 0), tally.get("NOSECTION", 0),
        tally.get("NOTOPENING", 0)))
    print()
    print("%-32s %s" % ("opens with the conclusion", "%d/%d  %.2f" % (good, denom, rate)))
    print("%-32s %.2f" % ("threshold", threshold))
    print("%-32s %s" % ("verdict", "PASS" if denom and rate >= threshold else "FAIL"))
    print()
    print("A rate here is a property of the DOCUMENTS, not of a skill. Whether")
    print("engineering-report fired while one was written is tools/skill-cases.sh's question —")
    print("#155 settled that the two answers move independently.")
    print("The exit code reports excerpt drift and, with --strict, an absent corpus. Not the score.")

    if drift:
        print()
        print("EXCERPT DRIFT — a stored excerpt.md no longer matches its source document:")
        for x in drift:
            print("  " + x)
    if absent:
        print()
        print("CORPUS NOT CHECKED:")
        for x in absent:
            print("  " + x)

    raise SystemExit(1 if (drift or (absent and strict)) else 0)


main()
