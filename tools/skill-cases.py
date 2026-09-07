# skill-cases.py — the scoring half of tools/skill-cases.sh. Not run directly.
#
# For each case under the eval dir: find the transcript and prompt turn it names, check the
# stored prompt still matches that turn verbatim, and report whether the expected skill fired
# IN RESPONSE TO THAT TURN — between it and the next prompt turn, not somewhere later.
import json, io, os, glob, sys, re

# The corpus carries em dashes and the user's own punctuation, and a Windows console defaults to
# cp1252 — printing a verbatim prompt there raises UnicodeEncodeError or mangles it. Ask for
# UTF-8 and fall back rather than lose the run over the report's own formatting.
try:
    sys.stdout.reconfigure(encoding="utf-8", errors="replace")
except Exception:
    pass

root = os.environ["CASES_ROOT_DIR"]
evaldir = os.environ["CASES_EVAL_DIR"]
strict = os.environ.get("CASES_STRICT") == "1"


def is_prompt_turn(o):
    """A turn that a prompt opened — typed by the user, or dispatched by the loop.

    Everything below arrives on a "user" envelope and none of it is a turn:

      tool_result       the result of a tool call             content[].type == "tool_result"
      skill injection   a SKILL.md body, injected on a fire   isMeta
      local command     a slash command's echo and stdout     no promptSource, no origin
      interrupt         a cancelled tool call                 text "[Request interrupted…"
      task notification a background agent finishing          origin.kind == "task-notification"

    Counting those inflates the denominator, and the inflation is not uniform: a session where
    a skill fires early gets its later turns pushed past the opening window by the injection
    that firing caused. Measuring "at opening" against it biases every number downward.
    """
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


def text(o):
    c = (o.get("message") or {}).get("content")
    if isinstance(c, str):
        return c
    if isinstance(c, list):
        return "\n".join(x.get("text", "") for x in c if isinstance(x, dict) and x.get("type") == "text")
    return ""


def read_case(p):
    """Read the four fields a case.yaml carries. Purpose-built, not a YAML parser.

    The format is fixed by evals/README.md and written by hand, so a general parser would add
    a dependency and a class of silent mis-reads in exchange for flexibility no case uses.
    An unrecognised line is ignored; a missing source fails loudly at the call site.
    """
    shape, expect, session, turn = "?", [], "", 0
    section = None
    for raw in io.open(p, encoding="utf-8"):
        line = raw.rstrip("\n")
        if not line.strip() or line.lstrip().startswith("#"):
            continue
        if not line[:1].isspace():
            section = line.split(":", 1)[0].strip()
            m = re.match(r"shape:\s*(\S+)", line)
            if m:
                shape = m.group(1)
            continue
        s = line.strip()
        if section == "expect" and s.startswith("- "):
            expect.append(s[2:].strip())
        elif section == "source":
            m = re.match(r"session:\s*(\S+)", s)
            if m:
                session = m.group(1)
            m = re.match(r"turn:\s*(\d+)", s)
            if m:
                turn = int(m.group(1))
    return shape, expect, session, turn


def find_session(stem):
    # An exact session id, not a topic search — #141's prefix-glob trap does not apply here,
    # because a session id belongs to exactly one directory.
    hits = sorted(glob.glob(os.path.join(root, "*", stem + "*.jsonl")))
    return hits[0] if hits else None


def parse(path):
    out = []
    for ln in io.open(path, encoding="utf-8", errors="replace"):
        try:
            out.append(json.loads(ln))
        except Exception:
            continue
    return out


def turn_and_fires(parsed, turn):
    """Text of prompt turn N, and every Skill fired before prompt turn N+1."""
    n, body, fires, capturing = 0, None, [], False
    for o in parsed:
        if is_prompt_turn(o):
            n += 1
            if n == turn:
                body, capturing = text(o), True
            elif capturing:
                break
            continue
        if not capturing or o.get("type") != "assistant":
            continue
        c = (o.get("message") or {}).get("content")
        if not isinstance(c, list):
            continue
        for x in c:
            if isinstance(x, dict) and x.get("type") == "tool_use" and x.get("name") == "Skill":
                fires.append((x.get("input") or {}).get("skill", "").split(":")[-1])
    return body, fires


cases = sorted(glob.glob(os.path.join(evaldir, "*", "*", "case.yaml")))
if not cases:
    print("no cases under %s" % evaldir, file=sys.stderr)
    raise SystemExit(2)

shapes, rows, drift, missing = {}, [], [], []
per_skill = {}

for cp in cases:
    d = os.path.dirname(cp)
    slug = os.path.basename(d)
    shape, raw_expect, stem, turn = read_case(cp)
    expect = [e for e in raw_expect if e != "none"]
    if not stem or not turn:
        missing.append("%s/%s  (case.yaml names no source.session or source.turn)" % (shape, slug))
        continue

    path = find_session(stem)
    if not path:
        missing.append("%s/%s  (session %s not on this machine)" % (shape, slug, stem))
        continue

    body, fires = turn_and_fires(parse(path), turn)
    if body is None:
        missing.append("%s/%s  (prompt turn %d not in %s)" % (shape, slug, turn, stem))
        continue

    stored = io.open(os.path.join(d, "prompt.md"), encoding="utf-8").read()
    if stored.rstrip("\n") != body.rstrip("\n"):
        drift.append("%s/%s" % (shape, slug))

    got = set(fires)
    if not expect:
        ok = not fires                      # control: silence is the pass
        detail = "nothing fired" if ok else "fired: " + ", ".join(sorted(got))
    elif expect == ["*>=8"]:
        ok = len(got) >= 8
        detail = "%d distinct skills" % len(got)
    else:
        ok = all(e in got for e in expect)
        miss = [e for e in expect if e not in got]
        detail = ("fired: " + ", ".join(sorted(got))) if got else "nothing fired"
        if miss:
            detail += "  |  missed: " + ", ".join(miss)

    for e in expect:
        if e == "*>=8":
            continue
        hit, tot = per_skill.get(e, (0, 0))
        per_skill[e] = (hit + (1 if e in got else 0), tot + 1)

    s = shapes.setdefault(shape, [0, 0])
    s[1] += 1
    s[0] += 1 if ok else 0
    rows.append((shape, slug, ok, stem, turn, detail))

w = max([len(r[1]) for r in rows] or [20])
print("skill-cases — %d cases scored under %s" % (len(rows), evaldir))
print()
last = None
for shape, slug, ok, stem, turn, detail in rows:
    if shape != last:
        print(shape)
        last = shape
    print("  %-4s %-*s  %s t%-3d  %s" % ("PASS" if ok else "FAIL", w, slug, stem, turn, detail))

print()
print("%-12s%10s" % ("shape", "fired"))
for shape in sorted(shapes):
    hit, tot = shapes[shape]
    print("%-12s%10s" % (shape, "%d/%d" % (hit, tot)))

print()
print("%-24s%10s" % ("skill expected", "fired"))
for s in sorted(per_skill):
    hit, tot = per_skill[s]
    print("%-24s%10s" % (s, "%d/%d" % (hit, tot)))

print()
print("A FAIL above is the measurement, not a broken run — this is a baseline, not a gate.")
print("The exit code reports prompt drift and, with --strict, an absent transcript. Nothing else.")

if drift:
    print()
    print("PROMPT DRIFT — stored prompt.md no longer matches the transcript turn:")
    for x in drift:
        print("  " + x)
if missing:
    print()
    print("NOT SCORED — the transcript is not on this machine:")
    for x in missing:
        print("  " + x)
    print("  A case is scored where its corpus lives. This is not a failure without --strict.")

# Drift is always a failure: it means the verbatim claim is false. An absent transcript is not,
# unless --strict was asked for.
raise SystemExit(1 if (drift or (missing and strict)) else 0)
