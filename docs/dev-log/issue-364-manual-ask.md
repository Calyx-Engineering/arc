# Issue #364 — fix: manual mode denies a commit the user asked for

> Dev-log, not a spec. Started at plan time, finalised as a retrospective at PR time.

**Issue:** [#364](https://github.com/Calyx-Engineering/arc/issues/364)  ·  **PR:** TBD  ·  **Branch:** `arc/04-dogfood-issue-364-manual-ask`

## Problem

`hooks/mode-guard` denied every gated command while `HANDOFF.md` said Manual, and its denial
said *to proceed the user asks* — but a `PreToolUse` hook cannot see the chat, so the user
asking changed nothing. On roadz-sound-system, 2026-09-15 and 2026-09-19, a commit the user
asked for was denied three times. The same string match denied a Python edit and the filing
of #364 itself, because the words appeared in the command's text.

## Intent and north star

| | |
|---|---|
| **What this issue is really for** | Manual was built as *the agent never commits* and was always meant as *the agent never commits unasked*. The hook had no way to observe the ask, so it enforced the wrong rule |
| **North star** | In manual, a commit the user asked for costs them one click and no second terminal; a commit nobody asked for still cannot land without them seeing it |
| **What makes it durable** | The ask is the harness's own permission prompt, not a token file or a phrase the hook has to recognise — nothing Arc maintains can drift |
| **Out of scope** | Step 2b's script-declaration splitter, which is still blind to quotes — it looks for a path in command position and a quoted mention has never landed there. `tools/verify-hook.sh` gaining an `ask` verdict — that file is never edited without the user's approval, so it is proposed, not done |

Pass 2, after reading m49, m40 and the hook: nothing changed, except that the issue's fourth box
— *the denial text names only routes that exist* — is met by there being no denial text left.

## Decisions & trade-offs

- **`permissionDecision: "ask"`, of the two routes the issue offers.** The other was *exit 0 and
  let the harness's own prompt be the gate*. That one is silent wherever the user has allowed
  `git commit` in `settings.json` or runs in auto permission mode — which is exactly the setup
  the 2026-09-07 incident happened under. `ask` forces the prompt in both. Source: Claude Code
  hooks reference, *PreToolUse decision control* — *"A hook's `ask` also forces a permission
  prompt in auto mode: the classifier can still deny the tool call, but it can't approve the
  call silently"*, v2.1.211 and later; this machine runs 2.1.263. **Read, not yet observed.**
- **Every manual-equivalent state asks — no handoff, no row, unreadable row.** *Absent means
  manual* was already the rule; a state that means manual and behaves differently from manual
  is a second rule.
- **An unattended run in manual still commits nothing.** Headless reference: *"In a `-p` run
  with no host, these requests are denied either way."* The loop's runs carry an Autonomous row
  in their own worktree, so they never reach the ask.
- **The command is read the way a shell reads it, in awk.** Quote state needs a character scan,
  and a character scan in bash parameter expansion is quadratic on a multi-kilobyte heredoc.
  One awk process, behind a case-pattern pre-filter, so a Bash call that could not hold a
  gating command still forks nothing.
- **Measured 2026-09-20, this machine:** a plain `ls` costs the hook 0.10 s, unchanged — the
  pre-filter misses and nothing forks. A 24 KB heredoc of 400 lines that all mention the
  commands costs 1.8 s, of which awk is 0.10 s; the rest is `field` resolving 400 `\n` escapes
  by parameter expansion, which step 2b already paid on any payload holding `.sh`. Left.
- **What a shell would run from inside a string is followed in** — `$( )` and backticks inside
  double quotes, `bash -c`, `eval`, a here-document on a line naming a shell. Reading quotes as
  text without this would have turned the fix into a false allow for `bash -c "git commit"`.
- **`git -C path commit` was a false allow under the old match** — it holds no `git commit`.
  Found writing the cases; closed by stepping over `git`'s global options.
- **A new outcome word, `asked`, in the activation log.** Logging an ask as `denied` would make
  the event log wrong about the one thing this issue changes.
- **The manual cases moved from `deny/` to `report/`.** `tools/verify-hook.sh` reads an `ask`
  with a reason as its `report` verdict. That verdict cannot tell an `ask` from an `allow`
  carrying a reason, so the exact decision is asserted in `tools/set-mode.py selftest`'s round
  trip instead, which already drove the real hook.

## Rejected approaches

- **An approval file the user writes per commit.** A second terminal again — the escape the
  issue exists to remove.
- **Recognising the user's request in the transcript.** The hook is handed `transcript_path`,
  but deciding that a message *asks for a commit* is judgement, and a hook that guesses at
  consent is worse than one that asks for it.

## Retrospective

TBD at PR time.
