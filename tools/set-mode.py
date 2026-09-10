# set-mode.py — write HANDOFF.md's Execution mode row. Called by tools/arc-loop.sh.
#
#   python tools/set-mode.py <Manual|Autonomous> [boundary]
#   python tools/set-mode.py selftest
#
# A separate file rather than a heredoc inside the shell script. The first version was
# embedded, its escapes were mangled on the way in, and it raised a SyntaxError while the
# caller printed "execution mode set to Autonomous" — reporting success and doing nothing,
# which is the failure this repository's arc exists to fix. #194.
#
# Exits non-zero on anything it could not do. The caller must not swallow that.
#
# THE READ-BACK IS THE ONLY PROTECTION AND IT IS TESTED. `python tools/set-mode.py selftest`
# runs the cases, against throwaway fixtures and never against a real HANDOFF.md — that file is
# gitignored session state, and a test that edited it would leave a session in the wrong mode.
# The cases include one where the write does not land, which is the case the read-back exists for
# and had never been fired. #198.
#
# WRITTEN TO RUN UNDER EITHER PYTHON. `tools/arc-loop.sh` invokes bare `python`, which is python 3
# on the machines this has run on and is not guaranteed to be. Hence `(OSError, IOError)`, `%`
# formatting and no `nonlocal` — cheap here, and the alternative is a mode switch that fails on
# the one machine where `python` is 2.
import io
import os
import re
import stat
import subprocess
import sys

PATH = "HANDOFF.md"

# The mode row is the first table row whose first cell names the mode. Same rule as
# hooks/mode-guard, which reads what this writes — and the round trip between the two is a case
# below, because two parsers of one format drift and a drift here means the mode is written and
# not read.
#
# THE CLOSING PIPE IS OPTIONAL, AND THAT IS A DRIFT THIS CLOSED. mode-guard matches
# `^\|[^|]*\bmode\b[^|]*\|` and takes the second field, so it reads `| Mode | Manual` — no
# trailing pipe — and gates on it. This required the third group, refused that row as having no
# mode row, and the result was a mode that could be read and could not be written. The row is now
# accepted and written back with its closing pipe, so the two parsers agree and the file is
# normalised on the way through.
ROW = re.compile(r"^(\|[^|]*\bMode\b[^|]*\|)([^|]*)(\|.*)?$", re.I | re.M)


class NoModeRow(Exception):
    """The text carries no row this and hooks/mode-guard would both read as the mode."""


def apply_mode(s, want, boundary):
    """The whole edit, as a function of the text. Raises NoModeRow if there is no mode row."""
    m = ROW.search(s)
    if not m:
        raise NoModeRow()
    s = s[: m.start()] + "%s **%s** %s" % (m.group(1), want, m.group(3) or "|") + s[m.end():]
    # The boundary row is rewritten with the mode, never left behind pointing at a spent grant.
    s = re.sub(r"^\| Autonomous until \|.*$\n?", "", s, flags=re.M)
    if want == "Autonomous" and boundary:
        m2 = ROW.search(s)
        s = s[: m2.end()] + "\n| Autonomous until | **%s** |" % boundary + s[m2.end():]
    return s


def row_says(text, want):
    """The read-back's decision, on its own so a case can fire it. True when the row read back
    carries the mode that was written."""
    m = ROW.search(text)
    return bool(m) and want.lower() in m.group(2).lower()


def set_mode(want, boundary, path=PATH):
    """Returns None on success, or the message to exit with."""
    try:
        s = io.open(path, encoding="utf-8").read()
    except (OSError, IOError) as e:
        return "set-mode: cannot read %s - %s" % (path, e)

    try:
        s = apply_mode(s, want, boundary)
    except NoModeRow:
        return "set-mode: %s has no Execution mode row" % path

    try:
        io.open(path, "w", encoding="utf-8", newline="\n").write(s)
    except (OSError, IOError) as e:
        # Reported, never announced as success. The whole of #194 was a write that did not
        # happen under a line saying it had.
        return "set-mode: cannot write %s - %s" % (path, e)

    # Read back. A write that reported success and did nothing is what this file exists because
    # of, and this is the branch #198 fires against a write that does not land.
    try:
        check = io.open(path, encoding="utf-8").read()
    except (OSError, IOError) as e:
        return "set-mode: wrote %s and cannot read it back - %s" % (want, e)
    if not row_says(check, want):
        m3 = ROW.search(check)
        return "set-mode: wrote %s but the row does not say so - %r" % (
            want, m3.group(0) if m3 else None)
    return None


def main(argv):
    if len(argv) < 2 or argv[1] not in ("Manual", "Autonomous"):
        sys.exit("usage: set-mode.py <Manual|Autonomous> [boundary]   or   set-mode.py selftest")
    want = argv[1]
    boundary = argv[2] if len(argv) > 2 else ""
    err = set_mode(want, boundary)
    if err:
        sys.exit(err)
    print("set-mode: %s%s" % (
        want, (" - until " + boundary) if (want == "Autonomous" and boundary) else ""))


# ---- the cases -------------------------------------------------------------------------------
# Every one runs the real script in a throwaway directory, so what is exercised is the file the
# loop calls and not an import of half of it.

HANDOFF_MANUAL = """# Run 185 — execution mode

## Execution mode

| | |
|---|---|
| **Mode** | **Manual** |

Written by `tools/arc-loop.sh`.
"""

HANDOFF_AUTONOMOUS = """# Run 185 — execution mode

## Execution mode

| | |
|---|---|
| **Mode** | **Autonomous** |
| Autonomous until | **#185 merged** |

Written by `tools/arc-loop.sh`.
"""


def selftest():
    import atexit
    import shutil
    import tempfile

    here = os.path.dirname(os.path.abspath(__file__))
    root = os.path.dirname(here)
    passed = [0]
    failed = [0]
    skipped = [0]

    def ok(name):
        print("  PASS  %s" % name)
        passed[0] += 1

    def bad(name, *lines):
        print("  FAIL  %s" % name)
        for l in lines:
            print("        %s" % l)
        failed[0] += 1

    def skip(name, why):
        # COUNTED, and named in the tail line. verify-all.sh echoes only that line, so a case
        # that quietly stopped running would otherwise be reported as a clean gate.
        print("  SKIP  %s" % name)
        print("        %s" % why)
        skipped[0] += 1

    work = tempfile.mkdtemp()
    # Registered the moment the directory exists, so an exception anywhere in the cases below
    # still takes the fixtures with it. A cleanup line at the end runs only on the happy path.
    atexit.register(shutil.rmtree, work, True)

    def fixture(name, text):
        d = os.path.join(work, name)
        os.mkdir(d)
        if text is not None:
            io.open(os.path.join(d, PATH), "w", encoding="utf-8", newline="\n").write(text)
        return d

    def run(d, *args):
        p = subprocess.Popen([sys.executable, os.path.join(here, "set-mode.py")] + list(args),
                             cwd=d, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
        out = p.communicate()[0].decode("utf-8", "replace")
        return p.returncode, out

    def handoff(d):
        f = os.path.join(d, PATH)
        return io.open(f, encoding="utf-8").read() if os.path.exists(f) else None

    # Held here rather than inside the one case that patches io.open, so a later case that needs
    # a real open does not depend on that case having run.
    real_open = io.open

    print("set-mode selftest - the row, the read-back, and the round trip to mode-guard")
    print("")

    # 1 — Manual to Autonomous, with a boundary.
    d = fixture("to-auto", HANDOFF_MANUAL)
    st, out = run(d, "Autonomous", "#185 #198 merged")
    t = handoff(d)
    if st == 0 and row_says(t, "Autonomous") and "| Autonomous until | **#185 #198 merged** |" in t:
        ok("Manual to Autonomous writes the mode and the boundary")
    else:
        bad("Manual to Autonomous writes the mode and the boundary", "exit %s" % st, out, t)

    # 2 — Autonomous to Manual, and THE BOUNDARY ROW GOES WITH IT. A spent grant left on the page
    #     reads as a live one.
    d = fixture("to-manual", HANDOFF_AUTONOMOUS)
    st, out = run(d, "Manual")
    t = handoff(d)
    if st == 0 and row_says(t, "Manual") and "Autonomous until" not in t:
        ok("Autonomous to Manual removes the boundary row")
    else:
        bad("Autonomous to Manual removes the boundary row", "exit %s" % st, out, t)

    # 3 — no HANDOFF.md at all.
    d = fixture("absent", None)
    st, out = run(d, "Autonomous", "x")
    if st != 0 and "cannot read" in out and not os.path.exists(os.path.join(d, PATH)):
        ok("no HANDOFF.md is reported, and none is created")
    else:
        bad("no HANDOFF.md is reported, and none is created", "exit %s" % st, out)

    # 4 — a file with no mode row is left alone.
    d = fixture("norow", "# Notes\n\nNo table here.\n")
    before = handoff(d)
    st, out = run(d, "Manual")
    if st != 0 and "no Execution mode row" in out and handoff(d) == before:
        ok("a file with no mode row is reported and left unchanged")
    else:
        bad("a file with no mode row is reported and left unchanged", "exit %s" % st, out)

    # 5 — A MODE ROW IN A DIFFERENT CELL ORDER IS REFUSED, not written into. hooks/mode-guard
    #     reads the SECOND cell of a row whose FIRST cell names the mode; writing the mode into
    #     the second cell of a row shaped the other way produces a row this writes and that reads
    #     as something else, which is the drift both parsers exist to avoid.
    d = fixture("swapped", "# H\n\n| | |\n|---|---|\n| **Autonomous** | Mode |\n")
    before = handoff(d)
    st, out = run(d, "Manual")
    if st != 0 and "no Execution mode row" in out and handoff(d) == before:
        ok("a mode row with its cells the other way round is refused, not half-written")
    else:
        bad("a mode row with its cells the other way round is refused, not half-written",
            "exit %s" % st, out, handoff(d))

    # 6 — an invalid argument.
    d = fixture("badarg", HANDOFF_MANUAL)
    before = handoff(d)
    st, out = run(d, "Auto")
    if st != 0 and "usage:" in out and handoff(d) == before:
        ok("an invalid mode is refused and the file is untouched")
    else:
        bad("an invalid mode is refused and the file is untouched", "exit %s" % st, out)
    st, out = run(d)
    if st != 0 and "usage:" in out:
        ok("no argument at all is refused")
    else:
        bad("no argument at all is refused", "exit %s" % st, out)

    # 7 — THE READ-BACK'S OWN DECISION, fired directly.
    if not row_says(HANDOFF_MANUAL, "Autonomous") and row_says(HANDOFF_MANUAL, "Manual"):
        ok("the read-back says no when the row does not carry what was written")
    else:
        bad("the read-back says no when the row does not carry what was written")
    if not row_says("# H\n\nno table\n", "Manual"):
        ok("the read-back says no when there is no row at all")
    else:
        bad("the read-back says no when there is no row at all")

    # 7b — AND THE READ-BACK BRANCH ITSELF, FIRED. This is the case #198 is about, and it is the
    #      one the other two do not reach: case 7 tests the decision function and case 8 below
    #      makes the WRITE raise, which returns before the read-back ever runs.
    #
    #      #194's failure was a write that reported success and changed nothing. That is
    #      reproduced exactly here — the write is swallowed, everything else is real — and what
    #      must happen is that set_mode reports rather than returns clean.
    d = fixture("swallowed", HANDOFF_MANUAL)
    f = os.path.join(d, PATH)
    before = handoff(d)

    class _Sink(object):
        """A file that accepts a write and keeps nothing. The context-manager and flush methods
        are here so the case survives set_mode being rewritten to the `with` form — without them
        that rewrite would make this case raise instead of exercising the read-back."""

        def write(self, _):
            return 0

        def flush(self):
            pass

        def close(self):
            pass

        def __enter__(self):
            return self

        def __exit__(self, *exc):
            return False

    def swallowing_open(path, mode="r", *a, **kw):
        if "w" in mode:
            return _Sink()
        return real_open(path, mode, *a, **kw)

    io.open = swallowing_open
    try:
        err = set_mode("Autonomous", "#198 merged", path=f)
    finally:
        io.open = real_open
    if err and "does not say so" in err and handoff(d) == before:
        ok("a write that lands nowhere is caught by the read-back, not reported as success")
    else:
        bad("a write that lands nowhere is caught by the read-back, not reported as success",
            "returned %r" % err)

    # 8 — the other half of the same failure: a write that RAISES. The file is read-only, so the
    #     write fails outright rather than silently. Non-zero, no success line, file unchanged.
    d = fixture("readonly", HANDOFF_MANUAL)
    f = os.path.join(d, PATH)
    before = handoff(d)
    os.chmod(f, stat.S_IREAD)
    try:
        writable = True
        try:
            real_open(f, "a", encoding="utf-8").close()
        except (OSError, IOError):
            writable = False
        if writable:
            # Running as root, or on a filesystem that ignores the read-only bit. The case cannot
            # be set up, and a case that cannot be set up is a skip and never a pass.
            skip("a write that cannot land is reported, never announced as success",
                 "the read-only bit does not stop a write here")
        else:
            st, out = run(d, "Autonomous", "x")
            if st != 0 and "set-mode: Autonomous" not in out and handoff(d) == before:
                ok("a write that cannot land is reported, never announced as success")
            else:
                bad("a write that cannot land is reported, never announced as success",
                    "exit %s" % st, out)
    finally:
        os.chmod(f, stat.S_IWRITE | stat.S_IREAD)

    # 8b — a HANDOFF.md that is not a file at all. It fails at the READ, not at the write, and
    #      the case says so — the message it asserts is the read's.
    d = fixture("notafile", None)
    os.mkdir(os.path.join(d, PATH))
    st, out = run(d, "Manual")
    if st != 0 and "cannot read" in out and "set-mode: Manual" not in out:
        ok("a HANDOFF.md that is a directory is reported at the read")
    else:
        bad("a HANDOFF.md that is a directory is reported at the read", "exit %s" % st, out)

    # 9 — THE ROUND TRIP. set-mode.py writes the row and hooks/mode-guard reads it, each with its
    #     own regex. Nothing else here proves the two agree.
    guard = os.path.join(root, "hooks", "mode-guard")
    if not os.path.exists(guard):
        # A FAILURE, NOT A SKIP. mode-guard ships in this repository, so its absence is a defect
        # rather than a condition of the machine — and everything below it is box 5 of #198. A
        # skip here would collapse the control and seven cases into one line and still exit 0.
        bad("the round trip to mode-guard", "no hooks/mode-guard in this tree — box 5 cannot run")
    else:
        # A CLEAN ENVIRONMENT, so the round trip is never silently inert. Two things are
        # dropped and one is replaced.
        #
        # CLAUDE_PROJECT_DIR is dropped, and that is what isolates the kill switch: with it
        # unset, mode-guard resolves the switch from its own working directory, which every
        # call below sets to a fixture under `work` — outside any repository, so no mute can
        # reach it. It also stops hooks/lib/activation-log writing, and a test firing must not
        # append to the tracked log; that file's own header records a verifier run that
        # appended ten fabricated entries. ARC_EVENT_LOG is dropped for the same reason.
        #
        # HOME is pointed at a fixture as well. Nothing mode-guard reads lives there any more —
        # the switch it consults is repo-scoped (#202) — but the guard-live control below is
        # what actually proves the hook ran, and it is cheap to leave the machine's ~/.claude
        # out of reach of a gate that runs a hook seven times.
        home = os.path.join(work, "home")
        os.makedirs(os.path.join(home, ".claude"))
        env = dict(os.environ)
        env["HOME"] = home
        env["USERPROFILE"] = home
        for k in ("CLAUDE_PROJECT_DIR", "ARC_EVENT_LOG"):
            env.pop(k, None)

        def guard_says(d, run_from=None):
            # Forward slashes: the payload is read by a sed pipeline, and a Windows path's
            # backslashes arrive escaped. `run_from` is the process's own directory, which is
            # deliberately NOT the payload's cwd in the case below — mode-guard falls back to
            # $PWD when it cannot read the cwd field, and while the two are the same directory a
            # broken field is indistinguishable from a working one.
            payload = ('{"tool_name":"Bash","cwd":%s,'
                       '"tool_input":{"command":"git commit -m \\"work\\"","description":"Commit"}}'
                       % io_json(d.replace("\\", "/")))
            p = subprocess.Popen(["bash", guard], cwd=(run_from or d), env=env,
                                 stdin=subprocess.PIPE, stdout=subprocess.PIPE,
                                 stderr=subprocess.PIPE)
            o = p.communicate(payload.encode("utf-8"))[0].decode("utf-8", "replace")
            return "deny" if '"permissionDecision":"deny"' in o else "allow"

        # THE CONTROL, FIRST. Absence of a denial is what this reads as "allow", so a guard that
        # crashed, exited early or is inert would satisfy every allow assertion below. With no
        # HANDOFF.md at all the guard must deny — an unset mode is manual — and that is the one
        # reading that proves it ran.
        d = fixture("guard-live", None)
        if guard_says(d) == "deny":
            ok("mode-guard is live - with no HANDOFF.md it denies, so an allow means something")
        else:
            bad("mode-guard is live - with no HANDOFF.md it denies, so an allow means something",
                "it allowed, so every allow below proves nothing")

        d = fixture("roundtrip", HANDOFF_MANUAL)
        st, out = run(d, "Autonomous", "#198 merged")
        said = guard_says(d)
        if st == 0 and said == "allow":
            ok("mode-guard reads Autonomous out of what set-mode wrote")
        else:
            bad("mode-guard reads Autonomous out of what set-mode wrote",
                "set-mode exit %s" % st, out, "mode-guard said %s" % said)

        st, out = run(d, "Manual")
        said = guard_says(d)
        if st == 0 and said == "deny":
            ok("mode-guard reads Manual out of what set-mode wrote")
        else:
            bad("mode-guard reads Manual out of what set-mode wrote",
                "set-mode exit %s" % st, out, "mode-guard said %s" % said)

        # 9b — and the round trip holds for a row written without emphasis. Both regexes claim to
        #      read the cell rather than its markdown, and only a case says so.
        d = fixture("plainrow", "# H\n\n| | |\n|---|---|\n| Mode | Manual |\n")
        st, out = run(d, "Autonomous", "#198 merged")
        said = guard_says(d)
        if st == 0 and said == "allow" and row_says(handoff(d), "Autonomous"):
            ok("a row written without emphasis round-trips too")
        else:
            bad("a row written without emphasis round-trips too",
                "set-mode exit %s" % st, out, "mode-guard said %s" % said)

        # 9c — A ROW WITH NO CLOSING PIPE. mode-guard has always read it; this refused it as
        #      having no mode row, so the mode could be read and not written — one format, two
        #      parsers, disagreeing. The row is now accepted and written back closed.
        d = fixture("nopipe", "# H\n\n| | |\n|---|---|\n| Mode | Manual\n")
        said_before = guard_says(d)
        st, out = run(d, "Autonomous", "#198 merged")
        t = handoff(d)
        said = guard_says(d)
        if (said_before == "deny" and st == 0 and said == "allow"
                and row_says(t, "Autonomous") and t.count("| **Autonomous** |") == 1):
            ok("a mode row with no closing pipe is read by both, and written back closed")
        else:
            bad("a mode row with no closing pipe is read by both, and written back closed",
                "guard before: %s" % said_before, "set-mode exit %s" % st, out,
                "guard after: %s" % said, t)

        # 9d — THE PAYLOAD'S cwd IS THE THING READ, not the process's own directory. mode-guard
        #      falls back to $PWD when it cannot read the cwd field, so with the two always equal
        #      a field that stopped parsing would look exactly like one that works.
        auto = fixture("cwd-auto", HANDOFF_AUTONOMOUS)
        man = fixture("cwd-manual", HANDOFF_MANUAL)
        from_auto = guard_says(man, run_from=auto)
        from_man = guard_says(auto, run_from=man)
        if from_auto == "deny" and from_man == "allow":
            ok("the mode is read from the payload's cwd, not from where the hook was run")
        else:
            bad("the mode is read from the payload's cwd, not from where the hook was run",
                "manual payload run from an autonomous directory: %s" % from_auto,
                "autonomous payload run from a manual directory: %s" % from_man)

        # 9e — the row shapes the optional closing pipe newly admits, written and read back. An
        #      empty second cell is unreadable to mode-guard beforehand and a mode afterwards.
        d = fixture("emptycell", "# H\n\n| | |\n|---|---|\n| Mode |\n")
        said_before = guard_says(d)
        st, out = run(d, "Autonomous", "#198 merged")
        said = guard_says(d)
        if said_before == "deny" and st == 0 and said == "allow" and row_says(handoff(d), "Autonomous"):
            ok("a mode row with an empty value cell is filled in, not refused")
        else:
            bad("a mode row with an empty value cell is filled in, not refused",
                "guard before: %s" % said_before, "set-mode exit %s" % st, out,
                "guard after: %s" % said, handoff(d))

        # 9e(ii) — A CRLF FILE IS REWRITTEN LF THROUGHOUT. The read takes universal newlines and
        #          the write pins "\n", so the whole file changes and not only the mode row. That
        #          is the behaviour, recorded here rather than discovered in a diff: the row still
        #          round-trips, and the rest of the file keeps its content and loses its endings.
        d = fixture("crlf", None)
        io.open(os.path.join(d, PATH), "w", encoding="utf-8", newline="\r\n").write(HANDOFF_MANUAL)
        st, out = run(d, "Autonomous", "#198 merged")
        t = handoff(d)
        raw = open(os.path.join(d, PATH), "rb").read()
        if st == 0 and row_says(t, "Autonomous") and guard_says(d) == "allow" and b"\r\n" not in raw:
            ok("a CRLF handoff round-trips, and is rewritten with LF endings throughout")
        else:
            bad("a CRLF handoff round-trips, and is rewritten with LF endings throughout",
                "set-mode exit %s" % st, out, "CRLF still present: %s" % (b"\r\n" in raw))

        # 9f — and a trailing cell beyond the mode's own is preserved. That is the expression the
        #      optional group changed, and losing a cell would be a silent edit to the file.
        d = fixture("thirdcell", "# H\n\n| | | |\n|---|---|---|\n| Mode | Manual | set by hand |\n")
        st, out = run(d, "Autonomous", "#198 merged")
        t = handoff(d)
        if st == 0 and row_says(t, "Autonomous") and "set by hand" in t and guard_says(d) == "allow":
            ok("a cell after the mode's own survives the write")
        else:
            bad("a cell after the mode's own survives the write", "set-mode exit %s" % st, out, t)

    print("")
    tail = "%d passed, %d failed" % (passed[0], failed[0])
    if skipped[0]:
        tail += ", %d skipped" % skipped[0]
    print(tail)
    return 1 if failed[0] else 0


def io_json(s):
    """One JSON string, quoted. The payload is built by hand rather than with json.dumps so the
    fixture reads as the thing mode-guard is given."""
    return '"%s"' % s.replace("\\", "\\\\").replace('"', '\\"')


if __name__ == "__main__":
    if len(sys.argv) > 1 and sys.argv[1] == "selftest":
        sys.exit(selftest())
    main(sys.argv)
