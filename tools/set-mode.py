# set-mode.py — write HANDOFF.md's Execution mode row. Called by tools/arc-loop.sh.
#
#   python tools/set-mode.py <Manual|Autonomous> [boundary]
#
# A separate file rather than a heredoc inside the shell script. The first version was
# embedded, its escapes were mangled on the way in, and it raised a SyntaxError while the
# caller printed "execution mode set to Autonomous" — reporting success and doing nothing,
# which is the failure this repository's arc exists to fix. #194.
#
# Exits non-zero on anything it could not do. The caller must not swallow that.
import io
import re
import sys

if len(sys.argv) < 2 or sys.argv[1] not in ("Manual", "Autonomous"):
    sys.exit("usage: set-mode.py <Manual|Autonomous> [boundary]")

want = sys.argv[1]
boundary = sys.argv[2] if len(sys.argv) > 2 else ""
path = "HANDOFF.md"

try:
    s = io.open(path, encoding="utf-8").read()
except OSError as e:
    sys.exit("set-mode: cannot read %s — %s" % (path, e))

# The mode row is the first table row whose first cell names the mode. Same rule as
# hooks/mode-guard, which reads what this writes.
row = re.compile(r"^(\|[^|]*\bMode\b[^|]*\|)([^|]*)(\|.*)$", re.I | re.M)
m = row.search(s)
if not m:
    sys.exit("set-mode: %s has no Execution mode row" % path)

s = s[: m.start()] + "%s **%s** %s" % (m.group(1), want, m.group(3)) + s[m.end() :]

# The boundary row is rewritten with the mode, never left behind pointing at a spent grant.
s = re.sub(r"^\| Autonomous until \|.*$\n?", "", s, flags=re.M)
if want == "Autonomous" and boundary:
    m2 = row.search(s)
    s = s[: m2.end()] + "\n| Autonomous until | **%s** |" % boundary + s[m2.end() :]

io.open(path, "w", encoding="utf-8", newline="\n").write(s)

# Read back. A write that reported success and did nothing is what this file exists because of.
check = io.open(path, encoding="utf-8").read()
m3 = row.search(check)
if not m3 or want.lower() not in m3.group(2).lower():
    sys.exit("set-mode: wrote %s but the row does not say so — %r" % (want, m3.group(0) if m3 else None))
print("set-mode: %s%s" % (want, (" — until " + boundary) if (want == "Autonomous" and boundary) else ""))
