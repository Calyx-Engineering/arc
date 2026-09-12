# response-length-probe.py — the live-run half of tools/response-length.sh --probe, and of
# tools/topic-numbering.sh --probe.
#
# Replays a case's turns as ONE conversation against the plugin as installed, and records what
# came back. Nothing here is length-specific: it produces the replies, and the scorer asks the
# question — tools/response-length.py counts their words, tools/topic-numbering.py reads their
# section labels. A second copy would be a second place for the allow/deny lists and the
# cut-detection to drift, so both probes call this one.
#
# WHY ONE SESSION AND NOT ELEVEN. The defect is that a budget stated on turn 1 stops being
# applied by turn 5. Eleven independent single-turn runs cannot see that at all — each one
# would carry the budget in its own first message. The whole measurement is the decay, so the
# turns have to share a session. --session-id opens it, --resume continues it.
#
# READ-ONLY TOOLS, ON PURPOSE. The turns came from a session doing real work in this repo, so
# a probe with no tools answers half of them with "I cannot see that" — replies short enough
# to score as held while proving nothing. Read, Grep and Glob let those turns be answered.
# Every writing and network tool is denied: a probe must not commit, push or edit.
#
# TURNS IT CANNOT ANSWER ARE NOT HIDDEN. A fresh session does not have the original
# conversation's state, so some replies will still be thin. The scorer's floor puts those in
# their own column rather than counting them as a pass.
#
# IT COSTS MONEY, and the cost grows per turn as the conversation does. RL_PROBE_BUDGET caps
# each turn. This is why --probe is not in tests/verify-all.sh.
import io
import json
import os
import subprocess
import sys
import time
import uuid

try:
    sys.stdout.reconfigure(encoding="utf-8", errors="replace")
except Exception:
    pass

CASE_DIR = sys.argv[1]
CASE_NAME = sys.argv[2]
OUT_PATH = sys.argv[3]

BUDGET = os.environ.get("RL_PROBE_BUDGET", "0.60")
TIMEOUT = int(os.environ.get("RL_PROBE_TIMEOUT", "600"))
CWD = os.environ.get("RL_PROBE_CWD") or os.getcwd()

# WHICH COPY OF THE PLUGIN THE PROBE MEASURES — #262.
#
# Without these, a probe measures whatever `claude plugin install` last wrote into
# ~/.claude/plugins/cache, and that is a machine-wide singleton. Two consequences, and the
# second is the one that cost this issue its design:
#
#   The candidate has to be installed to be measured, so comparing two wordings means
#   installing one, running, installing the other, running — and the marketplace entry for
#   this plugin is a DIRECTORY source pointing at the main checkout, so a worktree cannot
#   install its own branch at all without first pushing it through the main tree.
#
#   Every other session on the machine reads the same cache. Four arc worktrees were live
#   while #262 ran. Installing a candidate skill to measure it changes how they all behave,
#   and any of them reloading the plugin mid-run silently swaps the arm being measured.
#
# --plugin-dir loads a plugin from a directory FOR ONE SESSION. RL_PROBE_SETTINGS carries a
# settings file disabling the installed copy of the same plugin, so the session sees one
# chat-response rather than two. Verified 2026-09-11 from this worktree: with a marker word
# prepended to the arm's `description:`, the session quoted the marker back.
PLUGIN_DIR = os.environ.get("RL_PROBE_PLUGIN_DIR", "")
SETTINGS = os.environ.get("RL_PROBE_SETTINGS", "")

# Comma-separated, as ONE argument each. --allowedTools and --disallowedTools are both
# variadic, so two of them space-separated on the same command line run together and the
# second flag's names get read as the first's. The comma form has no such edge.
ALLOW = "Read,Grep,Glob,Skill"
DENY = "Write,Edit,NotebookEdit,WebFetch,WebSearch,Task,Agent,Bash,Artifact"


def turns(d):
    tdir = os.path.join(d, "turns")
    out = []
    for f in sorted(os.listdir(tdir), key=lambda x: int(x.split(".")[0])):
        if f.endswith(".md"):
            out.append((int(f.split(".")[0]),
                        io.open(os.path.join(tdir, f), encoding="utf-8").read()))
    return out


def run(prompt, session, first):
    cmd = ["claude", "-p", prompt, "--output-format", "stream-json", "--verbose",
           "--permission-mode", "manual", "--max-budget-usd", BUDGET]
    cmd += ["--session-id", session] if first else ["--resume", session]
    cmd += ["--allowedTools", ALLOW, "--disallowedTools", DENY]
    # Both flags go on EVERY turn, not only the first. --resume continues a conversation, it
    # does not restore the flags the session was opened with, so a second turn without them
    # would answer out of the installed plugin while the first answered out of the arm — and
    # the decay this instrument exists to measure would be a change of skill halfway through.
    if PLUGIN_DIR:
        cmd += ["--plugin-dir", PLUGIN_DIR]
    if SETTINGS:
        cmd += ["--settings", SETTINGS]

    p = subprocess.Popen(cmd, cwd=CWD, stdout=subprocess.PIPE, stderr=subprocess.DEVNULL,
                         stdin=subprocess.DEVNULL, text=True, encoding="utf-8",
                         errors="replace")
    # Skill fires are recorded per turn, not because firing is the measurement — #155 settled
    # that it is neither necessary nor sufficient — but because a rule that lives in a skill
    # BODY is only in context on the turns the skill fired. Without this, a fix that moved
    # nothing cannot be told apart from a fix that was never loaded.
    blocks, fires, cost, cut, started = [], [], None, "", time.time()
    try:
        for line in p.stdout:
            if time.time() - started > TIMEOUT:
                break
            line = line.strip()
            if not line.startswith("{"):
                continue
            try:
                o = json.loads(line)
            except Exception:
                continue
            if o.get("type") == "result":
                cost = o.get("total_cost_usd")
                # A turn stopped by --max-budget-usd or a turn cap returns a TRUNCATED reply,
                # and a truncated reply is short. Scored as-is it reads as the budget being
                # held, which is the one wrong answer this instrument must not give. The
                # subtype travels with the reply so the scorer can drop the turn instead.
                subtype = o.get("subtype") or ""
                if subtype and subtype != "success":
                    cut = subtype
                elif o.get("is_error"):
                    cut = "error"
                break
            if o.get("type") != "assistant":
                continue
            for b in (o.get("message") or {}).get("content") or []:
                if not isinstance(b, dict):
                    continue
                if b.get("type") == "text" and b.get("text", "").strip():
                    blocks.append(b["text"].strip())
                elif b.get("type") == "tool_use" and b.get("name") == "Skill":
                    sk = ((b.get("input") or {}).get("skill") or "").split(":")[-1]
                    if sk and sk not in fires:
                        fires.append(sk)
    finally:
        try:
            p.terminate()
            p.wait(timeout=10)
        except Exception:
            try:
                p.kill()
            except Exception:
                pass
    # Everything the assistant said across the turn, which is what the user reads. The scorer
    # strips tables, code and headings before counting.
    return "\n".join(blocks), cost, fires, cut


session = str(uuid.uuid4())
replies, total = {}, 0.0
for i, (turn, prompt) in enumerate(turns(CASE_DIR)):
    text, cost, fires, cut = run(prompt, session, i == 0)
    replies[str(turn)] = {"text": text, "cut": cut, "fired": fires}
    if cost:
        total += cost
    print("    t%-4d %5d chars   $%-6s  fired: %-16s %s"
          % (turn, len(text), ("%.3f" % cost) if cost else "?",
             ", ".join(fires) or "—", ("CUT: " + cut) if cut else ""),
          flush=True)

existing = {}
if os.path.exists(OUT_PATH):
    try:
        existing = json.load(io.open(OUT_PATH, encoding="utf-8"))
    except Exception:
        existing = {}
existing[CASE_NAME] = replies
json.dump(existing, io.open(OUT_PATH, "w", encoding="utf-8"), ensure_ascii=False, indent=1)
print("    session %s   $%.3f total" % (session[:8], total), flush=True)
