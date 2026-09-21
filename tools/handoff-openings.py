# handoff-openings.py — the reading half of tools/handoff-openings.sh. Not run directly.
#
# Reads the transcripts named by HANDOFF_DIRS and reports the cold starts in the window, each
# with the session that wrote the handoff it read. Definitions are in the .sh; the ones that
# decide a row are restated at the function that implements them.
import json, os, io, glob, re, sys

# The corpus carries em dashes and the user's own punctuation, and a Windows console defaults to
# cp1252 — printing a verbatim prompt there raises UnicodeEncodeError or mangles it. Ask for
# UTF-8 and fall back rather than lose the run over the report's own formatting.
try:
    sys.stdout.reconfigure(encoding="utf-8", errors="replace")
except Exception:
    pass

root = os.environ["HANDOFF_ROOT_DIR"]
since = os.environ.get("HANDOFF_SINCE") or ""
until = os.environ.get("HANDOFF_UNTIL") or ""
locators = os.environ.get("HANDOFF_LOCATORS") == "1"
dirs = [d.strip() for d in os.environ["HANDOFF_DIRS"].split("\n") if d.strip()]

# A pickup instruction. The wordings are the ones the corpus actually uses; the column is
# reported, never used to filter, so a miss here costs a "no" on a row and not a lost session.
PICKUP = re.compile(
    r"handoff|hand-off|hand off"
    r"|get (back )?up to speed"
    r"|where (are )?we (are )?at"
    r"|pick(ing)? up (from|where|today)"
    r"|left off"
    r"|handoff-resume",
    re.I,
)

WRITE_TOOLS = ("Write", "Edit", "MultiEdit", "NotebookEdit")


def text_of(o):
    c = (o.get("message") or {}).get("content")
    if isinstance(c, str):
        return c
    if isinstance(c, list):
        return "".join(x.get("text", "") for x in c if isinstance(x, dict) and x.get("type") == "text")
    return ""


def is_human_prompt(o):
    """A prompt the user typed. Not a loop dispatch, and not any of the envelopes that only
    look like turns.

    Everything below arrives on a "user" envelope and none of it is a typed prompt:

      tool_result       the result of a tool call             content[].type == "tool_result"
      skill injection   a SKILL.md body, injected on a fire   isMeta
      local command     a slash command's echo and stdout     no promptSource, no origin
      interrupt         a cancelled tool call                 text "[Request interrupted…"
      task notification a background agent finishing          origin.kind == "task-notification"
      loop dispatch     the driver's brief                    promptSource "sdk", no human origin

    The loop dispatch is the one this differs from skill-firing.py on, and deliberately: there
    it is a turn, because a dispatched prompt is still a prompt. Here it disqualifies a session
    from being a cold start at all — the driver handed that run an issue, not a handoff.
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
    return (o.get("origin") or {}).get("kind") == "human"


def is_dispatched_prompt(o):
    """A prompt the loop dispatched: the same envelope as a typed one, without a human origin.

    Needed only to answer *did anything drive this session before the human did*. A run the
    driver opened and a human later joined is not a cold start — its opening was a brief, not a
    handoff — and counting only human prompts cannot tell the two apart.
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
    if kind == "human" or kind == "task-notification":
        return False
    return o.get("promptSource") == "sdk"


def repo_of(d):
    """The repository a transcript directory belongs to.

    A worktree gets its own directory, `<slug>--claude-worktrees-<branch>`, and writes the same
    repository's handoff. Pairing per directory would lose a writer across that boundary.
    """
    return d.split("--claude-worktrees-")[0].lower()


sessions = []   # one entry per transcript read
writes = []     # (timestamp, repo, session-id, written-path, transcript-path) — every handoff write

for d in dirs:
    for f in sorted(glob.glob(os.path.join(root, d, "*.jsonl"))):
        parsed = []
        for ln in io.open(f, encoding="utf-8", errors="replace"):
            try:
                parsed.append(json.loads(ln))
            except Exception:
                continue
        stamps = [o.get("timestamp", "") for o in parsed if o.get("timestamp")]
        if not stamps:
            continue
        # The store names a transcript <uuid>.jsonl, and the first 8 characters of the uuid are
        # what the retrospective and the dev-logs cite. Strip the extension first, or a short
        # name loses its tail to it.
        sid = os.path.splitext(os.path.basename(f))[0][:8]
        repo = repo_of(d)

        for o in parsed:
            if o.get("type") != "assistant":
                continue
            c = (o.get("message") or {}).get("content")
            if not isinstance(c, list):
                continue
            for x in c:
                if not isinstance(x, dict) or x.get("type") != "tool_use":
                    continue
                if x.get("name") not in WRITE_TOOLS:
                    continue
                p = str((x.get("input") or {}).get("file_path", ""))
                if "HANDOFF" in os.path.basename(p.replace("\\", "/")).upper():
                    writes.append((o.get("timestamp", ""), repo, sid, p, f))

        prompts = [o for o in parsed if is_human_prompt(o)]
        dispatched = [o for o in parsed if is_dispatched_prompt(o)]
        sessions.append(
            {
                "sid": sid,
                "dir": d,
                "repo": repo,
                "path": f,
                "start": min(stamps),
                "end": max(stamps),
                "prompts": prompts,
                "dispatched": dispatched,
            }
        )

writes.sort()


def is_cold_start(s):
    """A session that began, in the window, with a human at the keyboard and went on to work.

    Two prompts rather than one is what separates a session that picked something up from a
    one-shot errand — in the real store, `/plugin install` (no prompt at all) and "please copy
    this transcript" (exactly one). Both are post-install sessions and neither is a cold start.

    And the human has to have opened it. A loop run that a human joined later has two human
    prompts too, and its opening was the driver's brief — so any dispatched prompt before the
    first typed one disqualifies the session.
    """
    if len(s["prompts"]) < 2:
        return False
    first_human = s["prompts"][0].get("timestamp", "")
    if any(o.get("timestamp", "") < first_human for o in s["dispatched"]):
        return False
    if since and s["start"] < since:
        return False
    if until and s["start"] > until:
        return False
    return True


corpus = sorted((s for s in sessions if is_cold_start(s)), key=lambda s: s["start"])

for s in corpus:
    opening = s["prompts"][0]
    s["opened"] = opening.get("timestamp", "")
    s["first"] = " ".join(text_of(opening).split())
    s["pickup"] = "yes" if PICKUP.search(s["first"]) else "no"
    prior = [w for w in writes if w[1] == s["repo"] and w[0] and w[0] < s["opened"]]
    s["writer"] = prior[-1] if prior else None


def when(ts):
    return ts[:10] + " " + ts[11:16] if len(ts) >= 16 else ts


head = "corpus: %d cold start(s) in %d directorie(s)" % (len(corpus), len(dirs))
if since:
    head += ", since " + since
if until:
    head += ", until " + until
print(head)
print("read %d session(s); %d handoff write(s) seen" % (len(sessions), len(writes)))
print()

print("%-3s%-18s%-10s%-40s%-14s" % ("#", "opened", "session", "directory", "handoff-read"))
for i, s in enumerate(corpus, 1):
    print("%-3d%-18s%-10s%-40s%-14s" % (i, when(s["opened"]), s["sid"], s["dir"][:38], s["pickup"]))

print()
print("pairs — the handoff each cold start read, and the session that wrote it")
print()
print("%-3s%-10s%-10s%-18s%s" % ("#", "reader", "writer", "written", "age at the read"))
for i, s in enumerate(corpus, 1):
    if s["writer"]:
        ts, _, wsid, _, _ = s["writer"]
        # Hours, from the two ISO strings. Both are UTC in the store, so a string subtraction
        # via datetime is safe and no timezone is guessed.
        try:
            from datetime import datetime

            a = datetime.fromisoformat(ts[:19])
            b = datetime.fromisoformat(s["opened"][:19])
            age = "%.1fh" % ((b - a).total_seconds() / 3600.0)
        except Exception:
            age = "?"
        print("%-3d%-10s%-10s%-18s%s" % (i, s["sid"], wsid, when(ts), age))
    else:
        print("%-3d%-10s%-10s%-18s%s" % (i, s["sid"], "--", "none", "no transcript wrote it"))

print()
print("openings, verbatim")
for i, s in enumerate(corpus, 1):
    print()
    print("%d  %s  %s" % (i, when(s["opened"]), s["sid"]))
    print("   " + s["first"][:400])

if locators:
    print()
    print("locators")
    for i, s in enumerate(corpus, 1):
        print("%-3d reader  %s" % (i, s["path"]))
        if s["writer"]:
            # The writer's own transcript path, carried on the write record. Looking it up by
            # session id would take the first match across every repository, and an id is the
            # first 8 characters of a filename — short enough to collide.
            print("    writer  %s" % s["writer"][4])
