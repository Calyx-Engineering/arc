# case_reader.py — the one case reader and the one fence tracker the graders share.
#
#   import case_reader
#   for section, key, value in case_reader.fields(path): ...
#   fence = case_reader.Fence()
#
# WHY IT EXISTS. `read_case` was written four times — report-grade.py, topic-numbering.py,
# response-length.py, skill-cases.py — and the CommonMark fence rule three more times inside
# report-grade.py alone, whose own docstring says "this is the third reader in the file and the
# other two track it". Four copies of one parser is four places a format change has to land and
# three places it can be forgotten. Raised on #159, raised again on #213, done as #265.
#
# IT IS A MODULE, NOT A SCRIPT. Every grader is run as `python "$HERE/<name>.py"` from its `.sh`
# wrapper, which puts `tools/` first on `sys.path`, so a bare `import case_reader` resolves with
# no path juggling. The underscore in the filename is load-bearing: `case-reader.py` cannot be
# imported, and every other file here is hyphenated because every other file here is a script.
#
# STILL NOT A YAML PARSER. The trade the four readers each made separately is kept, not undone:
# the case format is fixed by evals/README.md and written by hand, so a real parser would add a
# dependency and a class of silent mis-reads in exchange for flexibility no case uses. What is
# shared is the scan; what each grader's fields MEAN stays in that grader, next to the suite it
# scores. An unrecognised line is ignored here and a missing field fails loudly at the call site,
# which is where the reader knows what it needed.
#
# ITS OWN CASES ARE `python tools/case_reader.py selftest`, wrapped by tests/verify-case-reader.sh
# so verify-all.sh's `tests/verify-*.sh` sweep can see them.

import io
import re
import sys

FENCE = re.compile(r"^\s*(`{3,}|~{3,})")


class Fence:
    """Tracks whether the reader is inside a fenced block, by the CommonMark rule.

    A fence closes on a run of the SAME character, at least as long as the opener. So a ~~~ line
    inside a ``` block does not close it, and neither does a ``` line inside a ```` block — both
    are shapes this corpus produces, because a reply showing a fenced example wraps it in a
    longer fence. A naive `in_fence = not in_fence` toggle gets both wrong and silently swaps
    which half of the document is content.

    Usage is two lines at the top of the loop:

        if fence.delimiter(line):
            continue          # a delimiter is never content
        if fence.open:
            continue          # ...and neither is anything between two of them
    """

    def __init__(self):
        self.marker = ""

    @property
    def open(self):
        """True while a fence is open."""
        return bool(self.marker)

    def delimiter(self, line):
        """True when `line` is a fence delimiter — opener or closer — state updated either way.

        The caller skips the line on True: the fence line itself belongs to neither side.
        """
        m = FENCE.match(line)
        if not m:
            return False
        run = m.group(1)
        if not self.marker:
            self.marker = run
        elif run[0] == self.marker[0] and len(run) >= len(self.marker):
            self.marker = ""
        return True


def fields(path):
    r"""Yield (section, key, value) for every meaningful line of a case.yaml.

    Blank lines and `#` comments are dropped. Indentation is the only structure the format has,
    so it is the only structure read:

      section   "" on a top-level line; on an indented one, the top-level key above it. A caller
                reads its flat fields off `section == ""` and its nested ones off the section it
                cares about, which is what all four readers did with their own `section` variable
      key       the text before the first `:`, stripped — or "-" for a `- item` list entry
      value     everything after that `:`, stripped — or the item's text for a list entry

    VALUE IS THE WHOLE REMAINDER, not the first token. The four readers disagreed about this:
    report-grade took `v.strip()` because `lines: 12 - 40` has spaces in it, and the other three
    matched `(\S+)` or `(\d+)`. Handing over the remainder keeps the looser one working and lets
    the stricter ones ask for what they meant through `token` and `leading_int`, rather than this
    function guessing which suite it is reading for.

    TWO LINES YIELD NOTHING, because all four readers ignored both and a caller cannot tell
    either from a real field once it arrives:

      an empty list entry     `-`, `-:`, or anything else whose key is a lone dash. With key
                              "-" and value "" it is indistinguishable from a real item, and the
                              one caller that collects items would put "" in a list that then
                              matches nothing — turning a control case that expects silence into
                              one that can never pass. The test is the KEY, after the split: `-:`
                              is not the string "-" and reached the caller when it was not
      an indented line with   `section` is falsy — nothing above it, or a top-level line whose
      no usable section       own key was empty, as `: something` is. Every reader dropped both:
                              report-grade skipped indented lines outright, and the other three
                              had nothing for their `section` to equal

    WHITESPACE BEFORE THE COLON IS NOW ACCEPTED, uniformly. `shape : opening` reads as `shape`
    here; three of the four `re.match(r"key:\s*...")` readers rejected it and report-grade, which
    already used `partition`, took it. One behaviour rather than two is the point of the module,
    and this is the direction that loses no case.
    """
    section = ""
    for raw in io.open(path, encoding="utf-8"):
        line = raw.rstrip("\n")
        if not line.strip() or line.lstrip().startswith("#"):
            continue
        if not line[:1].isspace():
            k, _, v = line.partition(":")
            section = k.strip()
            yield "", section, v.strip()
            continue
        if not section:
            continue
        s = line.strip()
        if s.startswith("- "):
            yield section, "-", s[2:].strip()
            continue
        k, _, v = s.partition(":")
        k = k.strip()
        if k == "-":
            continue
        yield section, k, v.strip()


def token(value):
    r"""The first whitespace-delimited token, or "" — what `re.match(r"key:\s*(\S+)", line)` read.

    Returning "" rather than None for an empty value is deliberate: every caller's guard is
    `if t:`, which is the same guard the regex gave them by not matching at all.
    """
    parts = value.split()
    return parts[0] if parts else ""


def leading_int(value, default=None):
    r"""The leading digits as an int, or `default` — what `re.match(r"key:\s*(\d+)", line)` read.

    `20 words` is 20 and `words` is `default`, exactly as the regexes it replaces behaved. It is
    NOT `int(value)`: a reader that used `(\d+)` tolerated trailing text and one that used
    `(\S+)` then `int()` did not, and those two are kept apart at the call site rather than
    flattened here — a case file that starts crashing, or stops, is a change to a suite's score.
    """
    m = re.match(r"(\d+)", value)
    return int(m.group(1)) if m else default


# ---- cases -------------------------------------------------------------------------------
# Fixtures only. This module reads case files and text; it needs no corpus and no transcripts,
# so `selftest` and a bare run are the same run.

def selftest():
    import atexit
    import os
    import shutil
    import tempfile

    passed = [0]
    failed = [0]

    def ok(name):
        print("  PASS  %s" % name)
        passed[0] += 1

    def bad(name, *lines):
        print("  FAIL  %s" % name)
        for l in lines:
            print("        %s" % l)
        failed[0] += 1

    def eq(name, got, want):
        if got == want:
            ok(name)
        else:
            bad(name, "want  %r" % (want,), "got   %r" % (got,))

    work = tempfile.mkdtemp()
    atexit.register(shutil.rmtree, work, True)
    seq = [0]

    def case(text):
        seq[0] += 1
        p = os.path.join(work, "case%d.yaml" % seq[0])
        io.open(p, "w", encoding="utf-8", newline="\n").write(text)
        return list(fields(p))

    print("case_reader — the scan, the fence, the two field helpers")
    print()

    # ---- the scan ------------------------------------------------------------------------
    eq('a top-level field is section ""',
       case(u"shape: opening\n"),
       [("", "shape", "opening")])

    eq("an indented field carries the key above it",
       case(u"source:\n  session: abc123\n  turn: 42\n"),
       [("", "source", ""), ("source", "session", "abc123"), ("source", "turn", "42")])

    eq('a list item is key "-"',
       case(u"expect:\n  - handoff\n  - camp\n"),
       [("", "expect", ""), ("expect", "-", "handoff"), ("expect", "-", "camp")])

    eq("blank lines and comments are dropped, indented ones too",
       case(u"# a header comment\n\nshape: opening\n  # an indented comment\n\n"),
       [("", "shape", "opening")])

    eq("the value is the whole remainder, not the first token",
       case(u"lines: 12 - 40\n"),
       [("", "lines", "12 - 40")])

    # `- ` needs the space, and a bare `-` yields nothing at all — yielded as an empty item it
    # would put "" into an expect list that then never matches anything, which turns a control
    # case expecting silence into one that can never pass.
    eq("a bare - yields nothing",
       case(u"expect:\n  -\n"),
       [("", "expect", "")])

    eq("-x without the space is a key, not a list item",
       case(u"expect:\n  -x\n"),
       [("", "expect", ""), ("expect", "-x", "")])

    eq("a lone dash with a colon yields nothing either",
       case(u"expect:\n  -:\n  - camp\n"),
       [("", "expect", ""), ("expect", "-", "camp")])

    eq("a dash and a space alone yields nothing",
       case(u"expect:\n  - \n"),
       [("", "expect", "")])

    eq("an indented line above every top-level key yields nothing",
       case(u"  budget: 99\nsource:\n  session: s\n"),
       [("", "source", ""), ("source", "session", "s")])

    # `: ignore` is a top-level line whose own key is empty. Yielding what follows it as
    # `section == ""` would hand every caller a nested line dressed as a top-level field.
    eq("a section with an empty name takes no nested lines",
       case(u": ignore\n  budget: 99\n"),
       [("", "", "ignore")])

    eq("whitespace before the colon reads as the key",
       case(u"shape : opening\n"),
       [("", "shape", "opening")])

    eq("a top-level line with no colon still opens a section",
       case(u"notes\n  a: b\n"),
       [("", "notes", ""), ("notes", "a", "b")])

    eq("a second top-level key closes the first section",
       case(u"source:\n  session: s\nshape: opening\n"),
       [("", "source", ""), ("source", "session", "s"), ("", "shape", "opening")])

    eq("a tab indents as well as a space",
       case(u"source:\n\tsession: s\n"),
       [("", "source", ""), ("source", "session", "s")])

    # ---- the fence -----------------------------------------------------------------------
    def inside(text):
        """The lines a reader tracking fences would keep — content outside every fence."""
        f = Fence()
        out = []
        for line in text.splitlines():
            if f.delimiter(line):
                continue
            if f.open:
                continue
            out.append(line)
        return out

    tick3 = u"`" * 3
    tick4 = u"`" * 4
    tick5 = u"`" * 5

    eq("a fence hides what is between its delimiters",
       inside(u"a\n%s\nhidden\n%s\nb\n" % (tick3, tick3)), ["a", "b"])

    eq("~~~ inside a fenced block does not close it",
       inside(u"a\n%s\n~~~\nstill hidden\n%s\nb\n" % (tick3, tick3)), ["a", "b"])

    eq("a 3-tick line inside a 4-tick block does not close it",
       inside(u"a\n%s\n%s\nstill hidden\n%s\n%s\nb\n" % (tick4, tick3, tick3, tick4)), ["a", "b"])

    eq("a longer run closes a shorter opener",
       inside(u"a\n%s\nhidden\n%s\nb\n" % (tick3, tick5)), ["a", "b"])

    eq("an unclosed fence swallows the rest of the document",
       inside(u"a\n%s\nhidden\nmore\n" % tick3), ["a"])

    eq("an indented fence is still a fence",
       inside(u"a\n  %s\nhidden\n  %s\nb\n" % (tick3, tick3)), ["a", "b"])

    f = Fence()
    st = (f.open, f.delimiter(tick3), f.open,
          f.delimiter(u"text"), f.open, f.delimiter(tick3), f.open)
    eq("delimiter() reports the delimiter line and open the state",
       st, (False, True, True, False, True, True, False))

    # ---- the field helpers ---------------------------------------------------------------
    eq("token takes the first word", token(u"abc def"), "abc")
    eq('token of an empty value is the falsy ""', token(u"   "), "")
    eq("leading_int tolerates trailing text", leading_int(u"20 words"), 20)
    eq("leading_int returns its default on no digits", leading_int(u"words", 7), 7)
    eq("leading_int returns its default on an empty value", leading_int(u"", 2), 2)
    eq("leading_int does not read digits that do not lead", leading_int(u"t20", 3), 3)

    print()
    print("  %d passed, %d failed" % (passed[0], failed[0]))
    return 1 if failed[0] else 0


if __name__ == "__main__":
    # Only when run, never on import. report-grade.py and skill-cases.py each do this at module
    # scope for themselves; a module that did it would be reaching into whichever script imported
    # it and changing how ITS output encodes, which is not a shared-reader's business.
    try:
        sys.stdout.reconfigure(encoding="utf-8", errors="replace")
    except Exception:
        pass
    if len(sys.argv) > 1 and sys.argv[1] != "selftest":
        sys.stderr.write("unknown argument: %s\n" % sys.argv[1])
        sys.exit(2)
    sys.exit(selftest())
