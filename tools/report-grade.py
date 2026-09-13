# report-grade.py — the scoring half of tools/report-grade.sh. Not run directly.
#
# Three questions about a report, all countable, all answered per case:
#
#   #159  Does it open with the conclusion, or with the story of how the conclusion was reached?
#   #164  Does every claim table say where its rows came from?
#   #164  When two sources disagree, does the document say which one won?
#
# Every column that has anything in its denominator has to clear the threshold. A suite that
# passed on the average of three questions would let a repaired opening report an unsourced
# table as progress, which is the two halves reporting each other's work as their own.
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
# and reporting only the worst would hide the other on a document that has both. DEFERRED and
# PREAMBLE are read BEFORE UNCLEAR is allowed to withhold a verdict: an unreadable heading says
# nothing about a pointer on the status line or a sentence explaining what the document is.
#
# --file GRADES ALL THREE COLUMNS AND ONLY THE OPENING GATES. A document has one opening and it
# either states the finding or it does not. The other two are region-scoped by construction —
# run over whole files they failed 116 of the first 120 markdown files in this repository,
# README.md and CLAUDE.md among them, and a pre-commit check that fails on almost everything is
# a check that gets switched off.
#
# UNCLEAR IS REPORTED, NEVER GUESSED. A first heading in neither the findings class nor the
# background class could be a findings section named after its subject, or a background section
# named the same way. Nothing structural separates them. Same reasoning as BOLDONLY in
# tools/topic-numbering.py: crediting the ambiguous middle would score the defect as a pass.
#
# PROVENANCE IS STRENGTH-ORDERED, AND THE ORDER IS THE POINT. #164 specified seven terms and
# #266 reconciled them with the eight in use in the field, giving the twelve at PROVENANCE
# below. Without an order, "record the source" is a label with no consequence — a demand list carried three kill-path signals read off
# a photograph of a board the project does not hold, treated as specified for weeks, and nothing
# in the document said the claim was weaker than the ones beside it.
#
# THE ALIASES ARE NOT DECORATION. A report written before the vocabulary existed still records
# provenance, in its own words: "from the product label", "the scope reported", "most likely
# explanation". An instrument matching only the vocabulary words themselves would score every
# one of those as unsourced, and the baseline would measure adoption of a word list rather than the
# defect.
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

# The case scan and the fence rule, shared with the other three graders — #265. This file held
# three copies of the fence rule on its own; they are all `case_reader.Fence` now. `tools/` is
# sys.path[0] because report-grade.sh runs this file by path.
import case_reader

try:
    sys.stdout.reconfigure(encoding="utf-8", errors="replace")
except Exception:
    pass

HEADING = re.compile(r"^\s{0,3}(#{1,6})\s+(.*?)\s*$")
RULE = re.compile(r"^(-{3,}|\*{3,}|_{3,})$")
# A "**Label:**" line. This is the status header's shape, and the skill requires one.
BOLD_LABEL = re.compile(r"^\s*\*{2}[^*]{1,40}:\*{2}")

# The first section's heading decides NARRATIVE. Both lists are matched on whole words against
# the heading with any leading number, bullet or separator stripped.
FINDINGS = ("finding", "findings", "conclusion", "conclusions", "recommendation",
            "recommendations", "answer", "answers", "result", "results", "verdict",
            "summary", "decision", "decisions", "outcome")
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

# DEVELOPMENT NARRATIVE IS THE ONE SHAPE THIS TOOL DOES NOT CHECK, and the honest thing is to
# say so rather than to look as if it does. A NARRATIVE_PAT list was here and was removed:
#
#   IT COULD NOT SEE THE SHAPE IT NAMED. opening() collects prose only while the first `##` has
#   not been reached, so the first section's BODY is never in the text this would scan. The
#   canonical instance — "## Findings" followed by "We first tried a linear regulator, then
#   found the switcher was needed" — scored CONCLUSION, clean.
#
#   AND IT OVER-FIRED ON WHAT IT COULD SEE. In the handful of lines above the first heading it
#   failed ordinary report prose: "At first glance the two adapters are identical", "It turns
#   out the PSE budgets by declared class", "I originally sized C25 at 100 nF; the correct value
#   is 10 nF". Each became a scored PREAMBLE fail.
#
# Blind where it mattered and wrong where it fired. skills/engineering-report still names four
# failing shapes; this tool checks three of them, and both the skill and the grader say which
# one is left to a person.

# The conclusion, somewhere else. A pointer where the answer should be.
DEFERRED_PAT = [
    # `finding`, `findings`, `result` and `results` were in this list and are deliberately not.
    # "The findings in Section 3 are unchanged by this revision" is a cross-reference to related
    # work, not a pointer standing where this document's own answer should be. The four that
    # remain name the answer itself.
    re.compile(r"\b(conclusion|conclusions|recommendation|answer|verdict)"
               r"\s+(?:is\s+|are\s+)?in\s+(?:section|sec\.?|§)\s*\d", re.I),
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
    prose, first, seen, fence = [], None, 0, case_reader.Fence()
    for line in lines:
        if fence.delimiter(line):
            continue
        if fence.open:
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
    # A separator has to follow the numeral. Without the lookahead the roman-numeral class
    # matched the first letter of "Investigation", "Introduction", "Intro" and "Verdict" and
    # stripped it, leaving "nvestigation" — so four words in the two lists below were dead as
    # first words, including the one skills/engineering-report names in its failing shapes.
    t = re.sub(r"^[\s#*_`]*(?:\d+|[IVXivx]+)(?=[\s.)·—–:-])\s*[.)·—–:-]*\s*", "",
               (title or "")).strip()
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
    # DEFERRED and PREAMBLE are read BEFORE the heading class is allowed to withhold a verdict.
    # An unclassifiable heading means the scorer cannot say whether the first section is a
    # findings section; it says nothing about a pointer on the status line or a sentence
    # explaining what the document is, both of which are visible whatever the heading is called.
    # Returning UNCLEAR first made both invisible on the shape skills/engineering-report
    # explicitly blesses — "a first section named after its subject is fine" — so a document
    # following the skill's own advice could carry two of the four failing shapes and exit 0.
    if "deferred" in flags:
        return "DEFERRED", flags, first, cls
    if "preamble" in flags:
        return "PREAMBLE", flags, first, cls
    if cls == "":
        return "UNCLEAR", flags, first, cls
    return "CONCLUSION", flags, first, cls


# ---- provenance ---------------------------------------------------------------------------
#
# #164: a claim's source is not recorded, so a weak source silently overrides a strong one. A
# demand list carried three kill-path signals read off a photograph of a board the project does
# not hold, treated as specified for weeks. The vocabulary is strength-ordered, strongest first,
# and the order is the whole point — without it "record the source" is a label with no
# consequence.
#
# #266 RECONCILED IT WITH THE ONE IN USE. Two vocabularies were live: the seven terms #164
# specified, and the eight rp2040-pin-allocation.md had been carrying since the user repaired
# this defect by hand — schematic, datasheet, firmware, drawing, report, thread, photo,
# conversation. Two vocabularies is the defect wearing a label. The ladder below is the
# topological merge of both orders: every pair keeps the relative order at least one of them
# gave it, except for ONE TERM THAT MOVES. `schematic` rises above both `datasheet` and
# `vendor`, which is the field's ordering, because a claim about this board is settled by this
# board's own sheets and neither the part's document nor the seller's label is about this board
# at all.
#
# `instrument` IS THE NEW TERM, AND IT IS THE POINT OF #266. `measured` covered a bench result
# and a number an instrument displayed with equal weight. Those are not the same claim: on
# 2026-08-28 a scope reported 2.473 Vpp where the tone was 1.456 Vpp, because a peak-to-peak
# reading cannot separate a tone from a tone plus a 433 kHz class-D carrier, and an estimate
# from that reading was taken over a bench measurement the user had verified. Under one word
# for both, that region had ONE source in play and graded ONESIDED — unscored, invisible. The
# split is what makes it a conflict the column can see.
#
# `instrument` SITS DIRECTLY BELOW `measured` and above everything else: it is an observation
# of the unit in hand, one notch weaker only because nothing has established that the
# instrument was measuring what the claim names. It becomes `measured` when the rig and its
# limits are written down beside it, and that promotion path is why it sits where it does.
PROVENANCE = ("measured", "instrument", "schematic", "datasheet", "vendor", "firmware",
              "drawing", "report", "thread", "photograph", "conversation", "inferred")

# How each term appears in prose that is not using the vocabulary word. A report written before
# the vocabulary existed still records provenance — "from the product label", "the scope
# reported", "most likely explanation" — and an instrument that only matched the vocabulary
# words themselves would score every one of those as unsourced.
#
# ALL FOUR ADOPTED TERMS ARE ORDINARY ENGLISH FIRST. An amplifier is "drawing power"; every
# document this instrument reads is a "report"; a screw has a "thread"; a duty cycle is "fixed
# in firmware". Matched bare they put a second source in play wherever the word falls, and the
# conflict column counts co-occurrence — so a false match does not merely mis-label a row, it
# manufactures a conflict and lands RESOLVED in the numerator. Three of them are matched only
# in the shape a provenance cell takes: the word followed by the thing it cites.
#
# `firmware` IS THE FOURTH AND IT TAKES THE OTHER SHAPE, because it is the one the ledger writes
# bare in its Provenance column — `| 20 | **available** | firmware | RTC_CLK | … |`. A
# cell-shaped lookahead cannot see that: grade_tables searches " ".join(cells) AFTER split("|"),
# so there is no pipe left to look ahead to and `$` would mean the end of the ROW. It is guarded
# by what makes the false shape false instead — the preposition. "fixed in firmware" and
# "disable CLKOUT in firmware" are statements about behaviour; a Provenance cell never reads
# "in firmware".
CITED = r"(?= *(?:[-\u2014\u2013:#\[(]|PR\b|p\.|no\.))"

ALIASES = {
    # `meter`, `scope read` and `instrument read` were here and are now `instrument`'s. A meter
    # displays; a bench measures. Keeping the readout words under `measured` is exactly the
    # collapse #266 exists to undo.
    # `measurements?` and not `measurement`: the trailing \b of the \b(?:...)\b wrapper made
    # the PLURAL unreachable, though the singular matched. `the rig` was here and is gone —
    # "name the rig and its limits" is method prose, not a bench result.
    "measured":     r"measured|measurements?|measures|bench|on the bench|"
                    r"characteri[sz]ed on",
    # The unvalidated reading. NO BARE `scope` AND NO BARE `meter`, in any determiner: "the
    # scope of this document" is not an instrument and "300 meters of cable" is not a meter.
    # Both are sentences this corpus writes. The scope and the meter are reached only through
    # what they did — read, reported, captured, showed.
    "instrument":   r"instrument read\w*|instrument report\w*|instrument show\w*|"
                    r"from the instruments?|on the instruments?|instruments?" + CITED +
                    r"|oscilloscopes?|scope read\w*|scope report\w*|scope captures?|"
                    r"scope traces?|scope showed|meter read\w*|on the meter|multimeters?|"
                    r"analy[sz]ers?|readouts?|"
                    r"read off the (?:scope|meter|display|instrument|analy[sz]er)",
    "schematic":    r"schematics?|netlist|the sheets?|board files?",
    "datasheet":    r"datasheets?|data sheets?",
    "vendor":       r"vendor|manufacturer|supplier|product label|the label|labell?ed|listing|"
                    r"product page|silkscreen|marketing",
    # Adopted from the field. Shipped source: what the code does, not what the hardware needs.
    # `(?<!in )` is the whole guard — see the CITED block above. Fixed-width lookbehind, so it
    # is legal here, and it sits inside the wrapper's leading \b without disturbing it.
    "firmware":     r"(?<!in )firmware|shipped source",
    "drawing":      r"drawings?" + CITED + r"|reviewed drawings?|reviewed diagrams?|"
                    r"mechanical drawings?",
    "report":       r"reports?" + CITED + r"|merged reports?|reports? PR|docs/report",
    # `the thread`, `a thread` and `in the thread` were here — moved up from `conversation` —
    # and are gone. A screw has a thread, and this is an electrical-engineering corpus: "the
    # thread engagement is 4 mm" put a source in play and, beside any other, manufactured a
    # conflict. A thread is provenance when it is cited, which is how the ledger writes it.
    "thread":       r"threads?" + CITED + r"|issue threads?",
    "photograph":   r"photographs?|photos?|pictures?|an image of",
    # `a thread` and `the thread` left here for `thread` and were then dropped from both — see
    # `thread` above. The field ranks a citable thread above a photograph and `conversation` at
    # the bottom, and the two are not the same claim: a thread is written down and can be read
    # back, a conversation is neither.
    "conversation": r"conversation|in chat|said in chat|verbally",
    # `extrapolat\w*` and not `extrapolat`: the alternation is wrapped in \b(?:...)\b, so a
    # branch ending mid-word can never match — "extrapolated" has no word boundary after
    # "extrapolat". It was the headline word of `inferred`'s own definition in both skills, and
    # the matcher could not see it.
    "inferred":     r"inferred|inference|assumed|assumption|extrapolat\w*|estimated|implied|"
                    r"most likely|likely explanation|presumably|calculated from",
}
# THE TERM IS NO LONGER PREPENDED FOR FREE. This was `\b(?:%s|%s)\b % (k, v)`, which matched
# every term's own bare word whether or not that word is safe to match — and `drawing`,
# `report` and `thread` are not. Each pattern is now complete, and a term that wants its bare
# word says so.
ALIAS_RE = {k: re.compile(r"\b(?:%s)\b" % v, re.I) for k, v in ALIASES.items()}

# A header cell that names where a row's claim came from.
SOURCE_HEADER = re.compile(r"^\**\s*(source|sources|provenance|basis|evidence|origin|from|"
                           r"per|reference|cited)\b", re.I)

# A lead-in that gives one source for the whole table. Weaker than a column and not the defect —
# see the TABLE verdict.
TABLE_SOURCE = [
    re.compile(r"^from the\b", re.I),
    re.compile(r"\b(sourced|taken|read off|read from|quoted) from\b", re.I),
    re.compile(r"\bmeasured (?:on|with|at|using)\b", re.I),
    re.compile(r"^according to\b", re.I),
    re.compile(r"\bper the (?:datasheet|schematic|label|standard|drawing)\b", re.I),
    re.compile(r"\b(?:all|every) (?:row|value|figure|number)s? (?:comes?|come|are|is) from\b",
               re.I),
]

# The override, said out loud. #164: a strong claim is not overridden by a weak one without
# saying so explicitly — so what is countable is whether anything in the section SAYS the two
# disagree.
CONTRAST = re.compile(
    r"\b(but|however|despite|whereas|rather than|instead of|contradicts?|contradicting|"
    r"overrid\w+|not permitted|does not support|do not support|disagree\w*|in favour of|"
    r"in favor of|supersed\w+|takes precedence)\b", re.I)
# `wins` and `against the` were in that list and are deliberately not. "The datasheet part wins
# on cost" is a sentence about a part, and "plotted the measured curve against the datasheet
# curve; they agree" is a sentence about agreement. A contrast marker that fires on agreement is
# not a contrast marker, and both put a false RESOLVED in the numerator.


# The confidence split's third group, mandatory and fixed-named by skills/engineering-report —
# "Verified / Measured / Not established". A table that falls under this heading asks what would
# settle an open question; it does not assert a value, so it is not the claim table #164 names.
# Matched on the HEADING, never the table's own header cells: real reports write this group's
# table under many column names — "Item", "Unknown", "Open point", "Open item" — and #314 was
# filed because three of those variants still tripped grade_tables into scoring them anyway. The
# heading is the one thing the skill fixes the name of. Matched against the heading TEXT (the
# `#` marks and their following space are already stripped by the time it is stored), so the
# pattern names no `#` of its own — "### Not established" and "#### 4. Not established" both
# store as text ending in "Not established" and both match.
NOT_ESTABLISHED_HEADING = re.compile(r"\bnot established\b", re.I)


def tables(text):
    """[(lead-in text, header cells, body rows, section heading)] for each pipe table outside a
    fenced block.

    The lead-in is the non-blank block immediately above the table. That is where a report puts
    one source for the whole table, and it is the difference between the TABLE verdict and NONE.

    The section heading is the nearest markdown heading line at or above the table, of any level
    — "### Not established" for a table sitting directly under it, carried forward past blank
    lines and prose until the next heading changes it. It is what lets grade_tables tell the
    confidence split's open-questions table from a claim table without guessing at column names.
    """
    out, fence = [], case_reader.Fence()
    lines = (text or "").splitlines()
    heading = ""
    i = 0
    while i < len(lines):
        line = lines[i]
        if fence.delimiter(line):
            i += 1
            continue
        if fence.open:
            i += 1
            continue
        # A table is a header row, a delimiter row of dashes, then body rows. Decided BEFORE
        # the heading check below, never after: a header cell that is itself a bare `#` (a
        # row-number column, `| # | What would settle it |`) is valid GFM and would otherwise
        # be read as an ATX heading, silently overwriting the tracked section heading with the
        # row's own text — and since a heading is carried forward until the next one, that
        # misreads every later table in the section too.
        is_header_row = ("|" in line and i + 1 < len(lines) and
                          re.match(r"^\s*\|?[\s:|-]*-[\s:|-]*\|?\s*$", lines[i + 1]))
        if not is_header_row:
            m = HEADING.match(line)
            if m:
                heading = m.group(2).strip()
        if "|" not in line or not is_header_row:
            i += 1
            continue
        # The lead-in is the nearest non-blank block above the table. A blank line between the
        # two is the normal shape — "From the product label:" then a blank then the table — so
        # blanks are skipped before the block is collected, not treated as its end.
        j = i - 1
        while j >= 0 and not lines[j].strip():
            j -= 1
        lead = []
        while j >= 0 and lines[j].strip() and "|" not in lines[j]:
            lead.insert(0, lines[j].strip())
            j -= 1
        header = [c.strip() for c in line.strip().strip("|").split("|")]
        body, k = [], i + 2
        while k < len(lines) and "|" in lines[k] and lines[k].strip():
            body.append([c.strip() for c in lines[k].strip().strip("|").split("|")])
            k += 1
        out.append(("\n".join(lead), header, body, heading))
        i = k
    return out


def grade_tables(text):
    """(verdict, detail) — does every claim table say where its rows came from?

    ROWS   a provenance column, or the terms carried in the rows themselves. The pass.
    TABLE  one source stated once, in the lead-in, for a uniform-source table. NOT SCORED —
           weaker than a column and not the defect #164 names. Scoring it as a pass would
           license dropping the column; scoring it as a fail would report a correctly sourced
           table as unsourced. Same reasoning as BOLDONLY in tools/topic-numbering.py.
    NONE   nothing says where the numbers came from. The fail.
    OPEN   under the confidence split's "Not established" heading. Not scored — #314: the
           mandated group asks what would settle an open question, and a row can carry that
           without naming where the OPEN ITEM came from, because it has not been settled yet.
    NOTABLE no table in the region, or every table in it is OPEN. Not scored.
    """
    ts = tables(text)
    claims = [(lead, header, body) for lead, header, body, heading in ts
              if not NOT_ESTABLISHED_HEADING.search(heading)]
    if not claims:
        return "NOTABLE", ""
    worst, detail = None, ""
    order = {"NONE": 0, "TABLE": 1, "ROWS": 2}
    for lead, header, body in claims:
        if any(SOURCE_HEADER.match(c) for c in header):
            v = "ROWS"
            d = "column: %s" % next(c for c in header if SOURCE_HEADER.match(c))
        elif body and all(any(rx.search(" ".join(r)) for rx in ALIAS_RE.values())
                          for r in body):
            v, d = "ROWS", "terms carried in every row"
        elif any(p.search(lead) for p in TABLE_SOURCE):
            v, d = "TABLE", "one source in the lead-in: %s" % lead.splitlines()[0][:60]
        else:
            n = sum(1 for r in body
                    if any(rx.search(" ".join(r)) for rx in ALIAS_RE.values()))
            v, d = "NONE", ("%d of %d row(s) name a source" % (n, len(body)) if n
                            else "%d row(s), no source" % len(body))
        if worst is None or order[v] < order[worst]:
            worst, detail = v, d
    return worst, detail


TABLE_ROW = re.compile(r"^\s{0,3}\|")


def conflict_prose(text):
    """The region's prose: fenced blocks dropped, table rows dropped, everything else kept.

    TABLE ROWS ARE NOT A CONFLICT. A correctly sourced ledger names a different source on every
    row — the shape #164 asks for — and reading it as prose reported the exemplar of the rule as
    a silent conflict.

    BUT A LINE IS ONLY A TABLE ROW IF IT STARTS WITH A PIPE. Dropping every line containing one
    deleted `|Vgs| < 20 V`, `|Z|` and `|S21|`, which are ordinary in this corpus — and with them
    whole conflicts, silently, into ONESIDED.

    AND A FENCE IS TRACKED, because this is the third reader in the file and the other two track
    it. A fenced sample mentioning two sources is sample text, not two claims. All three now
    track it through tools/case_reader.py's `Fence` — #265, which is what "the third reader in
    the file" was pointing at.
    """
    out, fence = [], case_reader.Fence()
    for line in (text or "").splitlines():
        if fence.delimiter(line):
            continue
        if fence.open or TABLE_ROW.match(line):
            continue
        out.append(line)
    return "\n".join(out)


def grade_conflict(text):
    """(verdict, terms present, the source the section asserts).

    RESOLVED  two or more provenance strengths in play, the disagreement stated out loud, and
              the source asserted is at least as strong as the one set aside. The pass.
    WEAKWINS  the same, but a WEAKER source is the one asserted. Reported, scored in neither
              column: #164's rule is "not overridden without saying so explicitly", so a weak
              source that wins out loud has obeyed the rule. It is still the thing a reader
              most needs pointed at, and the scorer cannot judge whether the reason was good.
    SILENT    two or more in play and nothing says they disagree. The fail #164 names: a weak
              source standing beside a strong one with nothing recording which won.
    ONESIDED  fewer than two. Nothing to resolve, not scored.

    THE DIRECTION IS DERIVED, NEVER ASSUMED. An earlier version returned the strongest term
    present and printed it as "resolves in favour of" — which is not a reading of the document,
    it is the vocabulary's own ordering restated. It graded this as a pass:

        "The measured gain is 41.7x on the bench. However the estimated gain from the
         instrument is 24.7x, and we are taking the estimate as correct."

    That is the exact incident #164 was written about — an inference beating a verified bench
    measurement — scored as resolving in favour of the measurement. The instrument must be able
    to fail the thing it was built for.

    HOW THE DIRECTION IS READ. The first contrast marker splits the region. Provenance named
    before it is being SET ASIDE; provenance named after it is being ASSERTED. That is the shape
    of the construction in English — "the label says X, BUT the measurement says Y" — and it
    reads both real cases correctly: the PoE anomaly asserts `measured` over a vendor label, and
    the probe above asserts `instrument` over `measured` — #266 split that term out of
    `measured`, and what beat the bench there was a number the instrument displayed.

    ITS LIMITS, RECORDED, BECAUSE THEY DECIDE WHICH VERDICTS ARE SCORED. This column is coarse.
    It detects two provenance strengths co-occurring in one region plus a stated disagreement;
    it does not check that the two claims are about the same thing. So:

      - A negated mention inside the asserted half ("budgets by declared class, not by measured
        draw") still counts as a mention. The split reads the shape of the sentence, not its
        meaning, and a section that inverts itself twice is read by its first turn only.
      - A region that mentions two sources incidentally, with an ordinary "but" between them,
        is reported as a conflict. That is why WEAKWINS is reported and never scored, and why
        the region is the case's chosen excerpt rather than a whole file.

    Only RESOLVED and SILENT are scored. The rest is pointed at, for a person to read.
    """
    # TABLE ROWS ARE NOT A CONFLICT, AND STRIPPING THEM IS NOT OPTIONAL. A correctly sourced
    # ledger names a different source on every row — that is the shape #164 asks for, and
    # scanning it as prose reported the exemplar of the rule as a silent conflict. A
    # disagreement is two claims about the same thing; two rows about different pins are not.
    prose = conflict_prose(text)
    present = [t for t in PROVENANCE if ALIAS_RE[t].search(prose)]
    if len(present) < 2:
        return "ONESIDED", present, ""
    m = CONTRAST.search(prose)
    if not m:
        return "SILENT", present, ""
    before, after = prose[:m.start()], prose[m.end():]
    aside = [t for t in PROVENANCE if ALIAS_RE[t].search(before)]
    asserted = [t for t in PROVENANCE if ALIAS_RE[t].search(after)]
    if not asserted or not aside:
        # The contrast does not sit between two sources — it is contrast about something else,
        # so there is no direction to read. UNREADABLE, and scored in NEITHER column. Returning
        # RESOLVED here put "no direction derivable" in the numerator, which is the inverse of
        # how UNCLEAR, TABLE and BOLDONLY are handled everywhere else in this repo: the
        # ambiguous middle is reported, never credited.
        return "UNREADABLE", present, ""
    # PROVENANCE is ordered strongest first, so a lower index is a stronger source.
    won, lost = asserted[0], aside[0]
    if PROVENANCE.index(won) <= PROVENANCE.index(lost):
        return "RESOLVED", present, won
    return "WEAKWINS", present, won


def read_case(path):
    """corpus, document, lines.

    The scan is tools/case_reader.py's — one reader for the four graders, #265 — and the same
    trade it always made: purpose-built, not a YAML parser, because the format is fixed by
    evals/report-shape. What is left here is which fields this suite wants: three flat ones,
    read whole rather than by first token, because `lines: 12 - 40` has spaces in it.

    A CASE DECLARES A DOCUMENT AND A REGION, AND NOTHING ELSE. There is deliberately no field
    for an expected verdict, an expected direction, or which columns to score. An earlier
    version took `conflict.favours` from the case and used it two ways — it gated whether the
    conflict column was scored at all, and it decided whether a resolved conflict counted. Both
    let the case author choose the result: omit the field, and a silent conflict is never
    graded. That is the tick-without-evidence shape evals/README.md says this arc exists to fix,
    and it was in the same commit that wrote the rule down."""
    out = {"corpus": "", "document": "", "lines": ""}
    for section, key, value in case_reader.fields(path):
        if not section and key in out:
            out[key] = value
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
    """--file: grade a single document on ALL THREE questions, so the rules the skills state can
    be run against the report being written rather than only against the suite.

    It grades the whole file, not an excerpt, so the table and conflict checks read every table
    and the whole text — an opening-only answer here was a check that pointed authors at a tool
    which then said nothing about the two columns #164 added.
    """
    text = io.open(path, encoding="utf-8", errors="replace").read()
    verdict, flags, first, cls = grade_opening(text)
    tv, td = grade_tables(text)
    cv, present, toward = grade_conflict(text)
    print("report-grade — %s" % path)
    print()
    print("  opening        %-10s%s" % (verdict, ("  flags: " + ", ".join(flags)) if flags else ""))
    print("                 first section: %s%s" % (
        (first or "(none)")[:70], ("  [%s]" % cls) if cls else "  [unclassified]"))
    print("  table source   %-10s%s" % (tv, ("  " + td) if td else ""))
    print("  conflict       %-10s%s" % (
        cv, ("  in play: " + ", ".join(present)) if present else ""))
    if toward:
        print("                 asserted over the rest: %s" % toward)
    print()
    # ONLY THE OPENING DECIDES THE EXIT CODE, and that is not timidity — it is the difference
    # between the two instruments. The opening verdict is a property of a whole document: there
    # is exactly one opening and it is either the finding or it is not. The table and conflict
    # columns are region-scoped by construction — grade_conflict's own contract is "the case's
    # chosen excerpt rather than a whole file", and grade_tables cannot tell a claim table from
    # any other table.
    #
    # Run over whole files they are noise, measured: of the first 120 tracked .md files in this
    # repository, 116 exited 1, and README.md, CLAUDE.md and the product definition were three
    # of them. A pre-commit check that fails on almost every document is a check that gets
    # turned off, and skills/engineering-report names this exact command as that check.
    #
    # So they are reported and they do not gate. FIX is a failure; LOOK is something to read.
    bad, look = [], []
    if verdict in ("NARRATIVE", "DEFERRED", "PREAMBLE"):
        bad.append("the opening — skills/engineering-report, The opening")
    if tv == "NONE":
        look.append("a claim table with no source per row (%s). Region-scoped check run over a "
                    "whole file — confirm it is a claim table before acting" % td)
    if cv == "SILENT":
        look.append("two sources named with nothing saying they disagree (%s). Same caveat"
                    % ", ".join(present))
    # Read this before calling anything clean. WEAKWINS and UNCLEAR are not failures and do not
    # move the exit code, but saying "clean" over either of them is how an author is told their
    # document is fine on the exact question they should be looking at. The 2026-08-28 incident
    # #164 was written about scores WEAKWINS: a weak source winning out loud has obeyed the
    # rule, and is still the thing most worth a second pair of eyes.
    if cv == "WEAKWINS":
        look.append("a weaker source is asserted over a stronger one (%s over %s). Allowed — "
                    "it is said out loud — but check the reason is good" % (toward, present[0]))
    if verdict in ("UNCLEAR", "NOSECTION"):
        look.append("the opening is not scorable: its first heading is in neither class")
    if bad:
        for b in bad:
            print("  FIX   " + b)
    for x in look:
        print("  LOOK  " + x)
    if not bad and not look:
        print("  Clean on all three questions.")
    # The exit code is the verdict here, unlike the suite: one document has one answer, and a
    # caller checking a report before committing it wants that answer in $?.
    raise SystemExit(1 if bad else 0)


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
        else:
            note = ("  flags: " + ", ".join(flags)) if flags else ""
            print("  %-10s %s%s" % (verdict, name, note))
            print("             first section: %s%s" % (
                (first or "(none)")[:70], ("  [%s]" % cls) if cls else "  [unclassified]"))

        # Every case is scored for every check its excerpt can answer. A case declares a
        # document and a region, never an expected outcome — the scorer re-derives all of it,
        # for the reason evals/README.md gives: a recorded outcome that nothing re-checks is
        # the tick-without-evidence failure this arc exists to fix.
        tv, td = grade_tables(text)
        tally["T:" + tv] = tally.get("T:" + tv, 0) + 1
        if tv != "NOTABLE":
            print("             table source: %-7s %s" % (tv, td))
        # Scored on every case, never gated on a field the case author supplies. Whether a
        # region holds two sources in disagreement is a property of the region.
        cv, present, toward = grade_conflict(text)
        tally["C:" + cv] = tally.get("C:" + cv, 0) + 1
        if cv != "ONESIDED":
            print("             conflict:     %-8s in play: %s" % (cv, ", ".join(present)))
            if toward:
                print("             asserted over the rest: %s" % toward)
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
    tgood = tally.get("T:ROWS", 0)
    tbad = tally.get("T:NONE", 0)
    tdenom = tgood + tbad
    trate = (tgood / tdenom) if tdenom else 0.0
    cgood = tally.get("C:RESOLVED", 0)
    cbad = tally.get("C:SILENT", 0)
    cdenom = cgood + cbad
    crate = (cgood / cdenom) if cdenom else 0.0
    print("  tables: sourced by row %d, unsourced %d, one source in the lead-in %d "
          "(not scored), no table %d" % (
              tgood, tbad, tally.get("T:TABLE", 0), tally.get("T:NOTABLE", 0)))
    print("  conflicts: resolved out loud %d, silent %d, one source only %d (not scored), "
          "weaker source asserted %d (reported)" % (
              cgood, cbad, tally.get("C:ONESIDED", 0), tally.get("C:WEAKWINS", 0)))
    print()
    print("%-32s %s" % ("opens with the conclusion", "%d/%d  %.2f" % (good, denom, rate)))
    print("%-32s %s" % ("table rows carry a source", "%d/%d  %.2f" % (tgood, tdenom, trate)))
    print("%-32s %s" % ("conflicts resolved out loud",
                        "%d/%d  %.2f" % (cgood, cdenom, crate)))
    print("%-32s %.2f" % ("threshold", threshold))
    # Every column that has anything in its denominator has to clear the threshold. A suite
    # that passed on the average of three questions would let a fixed opening hide an unsourced
    # table, which is the two halves of this suite reporting each other's work as their own.
    #
    # ROUNDED TO THE THRESHOLD'S OWN PRECISION, NOT COMPARED RAW. #315: `0.67` is this repo's
    # shorthand for two-thirds, printed to two places, and `2/3` is `0.6666...` — below it by
    # more than floating-point noise, so a bare `>=` rejected the exact ratio the constant was
    # named for. Rounding both sides to the threshold's own two decimal places is the tolerance
    # that follows from what `0.67` already claims to mean: `round(2/3, 2) == round(0.67, 2)`.
    # The same fix is applied in the same commit to `tools/skill-probe.sh` and
    # `tools/report-shape-probe.sh`, which make this comparison too.
    cols = [(denom, rate), (tdenom, trate), (cdenom, crate)]
    ok = any(d for d, _ in cols) and all(round(r, 2) >= round(threshold, 2) for d, r in cols if d)
    print("%-32s %s" % ("verdict", "PASS" if ok else "FAIL"))
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
