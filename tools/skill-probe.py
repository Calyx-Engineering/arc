# skill-probe.py — the running half of tools/skill-probe.sh. Not run directly.
#
# Re-runs a case's prompt.md against the plugin AS IT IS ON DISK NOW and records which skills
# fired. tools/skill-cases.py scores frozen transcripts and therefore cannot see a description
# change at all; this can. It is the instrument #156 said did not exist on this machine.
#
# HOW A PROBE ENDS. The grader asks whether the skill was invoked BEFORE the answer, so the
# probe stops when that is decided: at the first assistant message that answers with no tool
# call, or at a turn cap. Reading further buys nothing and every extra turn is billed.
#
# IT DOES NOT STOP AT THE FIRST FIRE. An earlier draft did, and it was wrong in exactly the
# case this suite is about — a prompt that names Camp and asks for a handoff read wants BOTH,
# and stopping at `camp` recorded `handoff` as a miss it never gave the model a chance to
# make. `load-all-skills` expects eight or more and would have scored one. Every Skill call
# up to the answer is collected.
import json, os, subprocess, sys, time, tempfile

sys.stdout.reconfigure(encoding="utf-8", errors="replace")

PROMPT = sys.argv[1]
BUDGET = os.environ.get("PROBE_BUDGET", "0.30")
TURNCAP = int(os.environ.get("PROBE_TURN_CAP", "4"))
TIMEOUT = int(os.environ.get("PROBE_TIMEOUT", "300"))

# The prompt sits immediately after -p, and --disallowedTools goes LAST. That flag is
# variadic: anything after it is read as another tool name, and a prompt placed there is
# swallowed silently — the run then starts with no prompt and exits before the first turn.
cmd = [
    "claude", "-p", PROMPT, "--output-format", "stream-json", "--verbose",
    "--permission-mode", "manual", "--max-budget-usd", BUDGET,
    # The measurement is activation, not the work. Denying the working tools keeps a probe
    # from wandering into a task it cannot finish and cannot be billed for twice.
    "--disallowedTools", "Bash", "Read", "Write", "Edit", "Glob", "Grep",
    "WebFetch", "WebSearch", "Task", "NotebookEdit", "TodoWrite", "Agent",
]

cwd = tempfile.mkdtemp(prefix="skill-probe-")
p = subprocess.Popen(cmd, cwd=cwd, stdout=subprocess.PIPE, stderr=subprocess.DEVNULL,
                     stdin=subprocess.DEVNULL, text=True, encoding="utf-8", errors="replace")

fires, turns, cost, started = [], 0, None, time.time()
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
            break
        if o.get("type") != "assistant":
            continue
        turns += 1
        blocks = (o.get("message") or {}).get("content") or []
        tool_uses = [b for b in blocks if isinstance(b, dict) and b.get("type") == "tool_use"]
        for b in tool_uses:
            if b.get("name") == "Skill":
                sk = ((b.get("input") or {}).get("skill") or "").split(":")[-1]
                if sk and sk not in fires:
                    fires.append(sk)
        # An assistant message with prose and no tool call is the answer. Whatever fired
        # before it is the whole of what fired before the answer.
        if not tool_uses and any(b.get("type") == "text" and b.get("text", "").strip() for b in blocks):
            break
        if turns >= TURNCAP:
            break
finally:
    try:
        p.terminate()
        p.wait(timeout=10)
    except Exception:
        try:
            p.kill()
        except Exception:
            pass

print(json.dumps({"fired": fires, "turns": turns, "cost": cost}))
