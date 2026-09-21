# skill-firing.py — the counting half of tools/skill-firing.sh. Not run directly.
#
# Reads the transcripts named by FIRING_DIRS and reports, per shipping skill, how often it
# fired, in how many sessions, and in how many of those it fired at the session's opening.
import json, os, io, glob, sys

# The corpus carries em dashes and the user's own punctuation, and a Windows console defaults to
# cp1252 — printing a verbatim prompt there raises UnicodeEncodeError or mangles it. Ask for
# UTF-8 and fall back rather than lose the run over the report's own formatting.
try:
    sys.stdout.reconfigure(encoding="utf-8", errors="replace")
except Exception:
    pass

root = os.environ["FIRING_ROOT_DIR"]
skdir = os.environ["FIRING_SKILLS"]
since = os.environ.get("FIRING_SINCE") or ""
opening = int(os.environ.get("FIRING_OPENING") or 3)
dirs = [d.strip() for d in os.environ["FIRING_DIRS"].split("\n") if d.strip()]

skills = sorted(
    os.path.basename(os.path.dirname(p))
    for p in glob.glob(os.path.join(skdir, "*", "SKILL.md"))
)
fires = {s: 0 for s in skills}
insess = {s: set() for s in skills}
atopen = {s: set() for s in skills}
unknown = {}
sessions = 0


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


for d in dirs:
    for f in sorted(glob.glob(os.path.join(root, d, "*.jsonl"))):
        parsed = []
        for ln in io.open(f, encoding="utf-8", errors="replace"):
            try:
                parsed.append(json.loads(ln))
            except Exception:
                continue
        stamps = [o.get("timestamp", "") for o in parsed if o.get("timestamp")]
        # A session is in the corpus when any part of it falls at or after --since. One that
        # started earlier and ran past the boundary is in; one that ended before it is out.
        if since and (not stamps or max(stamps) < since):
            continue
        sessions += 1
        sid = os.path.basename(f)
        userseen = 0
        for o in parsed:
            if is_prompt_turn(o):
                userseen += 1
            if o.get("type") != "assistant":
                continue
            c = (o.get("message") or {}).get("content")
            if not isinstance(c, list):
                continue
            for x in c:
                if not isinstance(x, dict):
                    continue
                if x.get("type") != "tool_use" or x.get("name") != "Skill":
                    continue
                name = (x.get("input") or {}).get("skill", "")
                bare = name.split(":")[-1]
                if bare in fires:
                    fires[bare] += 1
                    insess[bare].add(sid)
                    if userseen <= opening:
                        atopen[bare].add(sid)
                else:
                    unknown[name] = unknown.get(name, 0) + 1

head = "corpus: %d sessions in %d directorie(s)" % (sessions, len(dirs))
if since:
    head += ", since " + since
head += "  |  opening = first %d prompt turns" % opening
print(head)
print()
print("%-24s%7s%12s%14s" % ("skill", "fires", "sessions", "at opening"))
for s in skills:
    print(
        "%-24s%7d%12s%14s"
        % (
            s,
            fires[s],
            "%d/%d" % (len(insess[s]), sessions),
            "%d/%d" % (len(atopen[s]), sessions),
        )
    )
never = [s for s in skills if fires[s] == 0]
print()
print("never fired: " + (", ".join(never) if never else "none"))
if unknown:
    print(
        "fired but not shipped here: "
        + ", ".join("%s (%d)" % (k, v) for k, v in sorted(unknown.items()))
    )
