# Mechanism — Execution Mode Guard

**Status:** built — ships as `hooks/mode-guard` ([#189](https://github.com/Calyx-Engineering/arc/issues/189)). The wrapper-script gating that catches a gating command hidden inside an invoked script was added in [#201](https://github.com/Calyx-Engineering/arc/issues/201); the gaps it still carries are named in its own section below.
**Home:** Arc — Workspace guard.
**Src:** 🔥 observed.
**Covers:** m49.

---

## The friction

The execution mode was a word in a gitignored file that nothing read at the moment it
mattered. On 2026-09-07, in manual mode, three PRs were committed, pushed, opened and merged
without the user asking — hours after an earlier fix consolidated the mode rule into a single
sentence and shipped a verifier for it. That verifier checked the rule was *stated* once: text,
not behaviour. It was green while the behaviour was broken.

This hook is the behaviour half — `HANDOFF.md`'s Execution mode row is read before every
commit, push, PR and merge, so the mode is read at the moment of the action rather than
recalled from earlier in the conversation.

## Deny-biased on purpose

A false deny costs one message and names its own fix. A false allow is the failure this exists
to prevent, so the command match runs against the whole payload rather than a value pulled out
of JSON — an early version split the payload on commas and truncated a `command` value that
happened to contain one, which is a truncated command silently allowed: the wrong way to be
wrong.

## The command string is not the whole command

A direct `git commit`/`git push`/`gh pr create|merge|ready` in the payload is a plain string
match. But a script can commit, push and open a PR while the command that invokes it holds
none of those words — `tools/new-direct-pr.sh` does exactly that, and in manual mode the guard
never fired, found running [PR #200](https://github.com/Calyx-Engineering/arc/pull/200) — #201.

**A script declares itself; an undeclared one is not gated.** Scanning a script's *text* for
`git commit` looks more thorough and is wrong: `tests/verify-activation-log.sh` carries that
string inside a test payload, and a content match would deny a read-only verifier. So a
gating script opts in instead:

```bash
# mode-guard: writes-outward
# mode-guard-read-only: --dry-run --status --report
```

The hook asks the script rather than guessing about it, and an unrecognised script fails open.

**The command is split at `&`, `;`, `|`, `(`, `)`, `` ` `` and `{`/`}`, one segment per
invocation**, so a mention is not an invocation: `cat tools/arc-loop.sh` and
`grep -n "bash tools/arc-loop.sh" notes.md` never reach the check. Each segment steps over
leading `VAR=x` assignments and wrapper words (`command`, `env`, `exec`, `nohup`, `time`,
`sudo`, `builtin`), then an interpreter and its flags (`bash -n` is a parse-only read and is
skipped), before resolving whatever lands in command position against the payload's `cwd`,
this hook's own root, and the literal path — in that order. The first `.sh` file found there
is read for the declaration; a declared read-only flag (matched against that invocation's own
arguments) is a way into the script that writes nothing outward.

**What this half cannot do, named rather than discovered later:**

| Gap | Consequence |
|---|---|
| A new outward-writing script that omits the declaration | Invisible. Only the two [#201](https://github.com/Calyx-Engineering/arc/issues/201) named carry one — `tools/arc-default-branch.sh` and `tests/verify-tracker-body.sh` also write outward under some subcommands and do not |
| `cd tools && bash arc-loop.sh` | Not caught — resolution is against the payload's `cwd`, and nothing here sees an earlier `cd` in the same command |
| A path held in a variable, or displaced by a flag's own argument (`bash -o errexit tools/x.sh`) | Not caught |
| The command field is found by the first `"command"` in the payload | A description carrying that quoted word ahead of the real field mis-parses. The one false allow in this half that is not closed |
| The hook-root fallback resolves against Arc's own copy | In a consumer repo, a relative path that does not exist there can still gate if Arc ships a script of that name. A false deny, and it names the file it read |

## Absent mode is denied, and that is not a fail-open violation

Two different conditions, on purpose:

| | Result |
|---|---|
| The hook fails — a crash, a missing tool, malformed input | `exit 0`, fail open |
| The hook reads and finds no mode at all | Deny — absence is a documented state, read as Manual |

"Absent means manual" is an answer, not an unexpected failure, and every denial names its own
fix — the mode row — so a wrong one costs a message rather than a wedged session.

## The asymmetry this hook does not enforce

The mode switch is asymmetric — [m40](m40-autonomy-switch.md) §4: Claude may set the row to
Manual and may never set it to Autonomous; only the user raises it, by saying so. This hook
sees a file change, not who asked for it, so it cannot check who is allowed to have made it —
that stays a rule stated elsewhere rather than something mechanical here. What it enforces is
narrower: that the row, whatever it says and however it got there, is read at the moment of
the gated action rather than recalled. (`tools/arc-loop.sh` writing the row because a human ran
the script is the one case m40 §4 itself does not name — an accepted exception, not a
documented one.)

## What this cannot do

`hooks/hooks-off.sh mode-guard` mutes it for a bounded window. It sees Bash and nothing else,
so a gated action that never goes through Bash is unguarded. It stops the command, never the
decision behind it. There is no second layer — a static deny in `settings.json` would block
autonomous mode permanently, and lifting one is an edit no agent may make — so this is the only
mechanism, and its gaps are accepted rather than patched over.

---

## Related

- [#189](https://github.com/Calyx-Engineering/arc/issues/189) — the incident that produced this hook
- [#201](https://github.com/Calyx-Engineering/arc/issues/201) — the wrapper-script gap, and the declaration convention that closes it
- [m40 — Autonomy switch](m40-autonomy-switch.md) — the three-state mode this hook reads, and where the asymmetry rule lives
- [branch-guard](m10-branch-guard.md) — the sibling workspace guard, same `PreToolUse` shape
