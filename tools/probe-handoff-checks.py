# probe-handoff-checks.py — the reading half of tools/probe-handoff-checks.sh. Not run directly.
#
# Two subcommands, both pure reads that print lines the shell half can branch on:
#
#   fires <dump.jsonl>          every Skill call in a raw probe stream, fully qualified
#   path  <plugin> <index.json> where that plugin is installed
#
# It lives in Python rather than jq because this repository cannot assume jq on Windows, and in
# a separate file rather than a heredoc because the shell half has a selftest that must be able
# to call each subcommand on its own.
import json
import sys

LF = chr(10)


def fires(path):
    """Every distinct `Skill` invocation in a raw stream-json dump, in order.

    THE NAME COMES FROM THE TOOL CALL, NEVER FROM PROSE. A session on this machine announces
    "Using arc:handoff to ..." in a text-only turn before invoking it — that announcement is
    not a firing, and counting it would make this instrument agree with itself for the wrong
    reason.

    A malformed line is skipped rather than fatal: a probe killed at its turn cap leaves a
    half-written last line, and that is the normal shape of a dump, not a corrupt one.
    """
    seen = []
    with open(path, encoding="utf-8", errors="replace") as fh:
        for line in fh:
            line = line.strip()
            if not line.startswith("{"):
                continue
            try:
                o = json.loads(line)
            except Exception:
                continue
            if o.get("type") != "assistant":
                continue
            for b in (o.get("message") or {}).get("content") or []:
                if not isinstance(b, dict) or b.get("type") != "tool_use":
                    continue
                if b.get("name") != "Skill":
                    continue
                raw = (b.get("input") or {}).get("skill") or ""
                if raw and raw not in seen:
                    seen.append(raw)
    for s in seen:
        print(s)


def path_of(plugin, index):
    """Where `plugin` is installed, as `PATH <dir>` lines.

    `NONE` when the index holds no such plugin and `ERROR <why>` when the index cannot be read
    — two different answers, and the shell half treats neither as a defect. EVERY match is
    printed: `installed_plugins.json` is keyed `<plugin>@<marketplace>`, so one plugin name can
    have several install paths, and resolving that to the first one would silently attribute a
    firing to the wrong copy of the skill.
    """
    try:
        with open(index, encoding="utf-8") as fh:
            d = json.load(fh)
    except Exception as e:
        print("ERROR " + str(e))
        return
    hits = []
    for key, entries in (d.get("plugins") or {}).items():
        if key.split("@")[0] != plugin:
            continue
        for e in entries or []:
            p = e.get("installPath")
            if p and p not in hits:
                hits.append(p)
    if not hits:
        print("NONE")
        return
    for h in hits:
        print("PATH " + h)


if __name__ == "__main__":
    # The explicit newline is not cosmetic. Windows would otherwise end every line with CR, and
    # the shell half feeds these lines straight into `sed -n 's/^PATH //p'` to build a
    # filesystem path — a trailing CR makes that path miss, and makes an equal string compare
    # in the selftest fail while printing two identical-looking values.
    sys.stdout.reconfigure(encoding="utf-8", errors="replace", newline=LF)
    if len(sys.argv) >= 3 and sys.argv[1] == "fires":
        fires(sys.argv[2])
    elif len(sys.argv) >= 4 and sys.argv[1] == "path":
        path_of(sys.argv[2], sys.argv[3])
    else:
        print("usage: probe-handoff-checks.py fires <dump> | path <plugin> <index>",
              file=sys.stderr)
        raise SystemExit(2)
