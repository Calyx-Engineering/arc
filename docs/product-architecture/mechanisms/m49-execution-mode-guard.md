# Mechanism — Execution Mode Guard

**Status:** built — ships as `hooks/mode-guard` ([#189](https://github.com/Calyx-Engineering/arc/issues/189)). Manual asks rather than denies, and the gating command is read out of the command rather than matched in its text, since [#364](https://github.com/Calyx-Engineering/arc/issues/364). The wrapper-script gating that catches a gating command hidden inside an invoked script was added in [#201](https://github.com/Calyx-Engineering/arc/issues/201); the gaps it still carries are named in its own section below.
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

## Manual asks — it does not deny

**Manual means nothing is committed, pushed, opened or merged *unasked*.** A `PreToolUse` hook
cannot see the chat, so a deny could not tell a commit the user asked for from one nobody did.
On the client repo, 2026-09-15 and 2026-09-19, the user asked for a commit three times and
every attempt was denied; the only ways through were a mute typed in another terminal, or a
standing Autonomous grant when what was asked for was one commit —
[#364](https://github.com/Calyx-Engineering/arc/issues/364).

So in manual the hook returns `permissionDecision: "ask"`. The harness puts the command in front
of the user, and their yes is the ask, made observable.

| | |
|---|---|
| **Per command, nothing remembered** | The next commit, push, PR or merge asks again. A standing grant is what Autonomous is for |
| **The reason is written to the user** | An `ask` reason is shown to the user and never to Claude — it says what is about to run, why they are being asked, and what a no does |
| **Auto permission mode still prompts** | A hook's `ask` forces the prompt there; the classifier can still refuse the call and cannot approve it silently (Claude Code v2.1.211 and later) |
| **An unattended run in manual commits nothing** | In a `-p` run with no permission host, a call that would prompt is denied |

Source for the last three rows: Claude Code's hooks reference, *PreToolUse decision control*, and
its headless reference, *Turn off permission prompts in unattended runs* — read 2026-09-20.
**Not yet observed in a live session** — the cases under `tools/hook-cases/mode-guard/` prove the
hook's output, not the harness's handling of it.

**Ask-biased, where this was deny-biased.** A false ask costs one click and says what it is
about. A false allow is the failure this exists to prevent.

## The command being run, not the words in its text

The gating-command match was a string match over the whole payload, on the reasoning that
pulling `command` out of JSON truncated at the first comma and a truncated command silently
allows. The payload reader has been quote-aware since
[#300](https://github.com/Calyx-Engineering/arc/issues/300), so that reason is gone — and the
string match denied a Python edit whose source carried the words and an issue whose body did,
while allowing `git -C path commit`, which holds no `git commit`.

The command is now read the way a shell reads it, in one awk process that runs only when the
payload could hold a gating command at all:

| | |
|---|---|
| **Text is not a command** | Quotes, comments and here-document bodies |
| **Split into invocations** | At `;` `&` `\|` `(` `)` `{` `}`, a backtick and a line break |
| **Stepped over** | Leading `VAR=x` assignments, wrapper words, shell keywords (`if`, `then`, `while`, `!`…), and `git`'s and `gh`'s own global options |
| **Gating** | `git` with `commit` or `push` as the subcommand · `gh pr` with `create`, `merge` or `ready` |
| **Followed in, because a shell would run it** | `$( )` or a backtick inside double quotes · the argument of `bash -c` · the arguments of `eval` · a here-document whose opening line names a shell |

| Gap | Consequence |
|---|---|
| `xargs git commit`, `find -exec git push`, an alias, a function, a command held in a variable | A false allow — the gating command is never in command position in the text |
| Another interpreter running it — `python -c "subprocess.run(['git','commit'])"` | A false allow |
| A here-document piped to a shell on a later line than the one that opens it | A false allow |
| A here-document of documentation opened on a line carrying the word `bash` | A false ask. The prompt shows the command |

## The command string is not the whole command

A script can commit, push and open a PR while the command that invokes it holds
none of those words — `tools/new-direct-pr.sh` does exactly that, and in manual mode the guard
never fired, found running [PR #200](https://github.com/Calyx-Engineering/arc/pull/200) — #201.

**A script declares itself; an undeclared one is not gated.** Scanning a script's *text* for
`git commit` looks more thorough and is wrong: `tests/verify-activation-log.sh` carries that
string inside a test payload, and a content match would gate a read-only verifier. So a
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
| The hook-root fallback resolves against Arc's own copy | In a consumer repo, a relative path that does not exist there can still gate if Arc ships a script of that name. A false ask, and it names the file it read |

## Absent mode asks, and that is not a fail-open violation

Two different conditions, on purpose:

| | Result |
|---|---|
| The hook fails — a crash, a missing tool, malformed input | `exit 0`, fail open |
| The hook reads and finds no mode at all | Ask — absence is a documented state, read as Manual |

"Absent means manual" is an answer, not an unexpected failure. A row that says neither word is
read the same way, and the question quotes the row.

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
- [#364](https://github.com/Calyx-Engineering/arc/issues/364) — manual denied a commit the user asked for; the ask, and the command read in place of the string match
- [m40 — Autonomy switch](m40-autonomy-switch.md) — the three-state mode this hook reads, and where the asymmetry rule lives
- [branch-guard](m10-branch-guard.md) — the sibling workspace guard, same `PreToolUse` shape
