# Issue #189 — a hook denies a commit when the mode says manual

**Issue:** [#189](https://github.com/Calyx-Engineering/arc/issues/189)  ·  **PR:** not opened

## Problem

The execution mode was a word in a gitignored file that nothing read at the moment it mattered. On 2026-09-07, in manual mode, three PRs were committed, pushed, opened and merged without the user asking — hours after [#138](https://github.com/Calyx-Engineering/arc/issues/138) consolidated that rule into one sentence and shipped a verifier for it.

[#138](https://github.com/Calyx-Engineering/arc/issues/138) built one direction of the switch: it made a merge possible when the mode allows one, proved that by merging, and never built the half that stops one. `tools/verify-autonomy.sh` checks the rule is *stated* once — text, not behaviour — so it was green while the behaviour was broken.

## Decisions and trade-offs

| | |
|---|---|
| **Deny-biased matching** | The command match runs against the whole payload, not a parsed `command` field. Pulling it out with sed truncates at the first comma, and a truncated command that silently allows is the wrong way to be wrong. A false deny costs one message and names its own fix |
| **Absent mode denies, and that is not a fail-open violation** | Two conditions: the hook *failing* — crash, missing tool, malformed input — exits 0; the hook *reading and finding no mode* denies. "Absent means manual" is a documented answer, not an unexpected failure |
| **Every denial names its own fix** | Which is what makes denying on absent safe. Thirty seconds, not a wedged session |
| **The switch is asymmetric** | Claude may set the row to Manual, never to Autonomous. Dropping removes authority rather than granting it, so there is nothing to guard |
| **The asymmetry is a rule, not a gate, and is documented as one** | The hook sees a file change, not who asked. Gating writes to `HANDOFF.md` would block a file Claude legitimately maintains |
| **No second layer exists** | A static deny in `settings.json` would block autonomous permanently, and lifting one is an edit no agent may make. The hook's gaps — `HOOKS_OFF`, fail-open, Bash-only — are accepted, and the header says so |

## An edit to a hard-excluded file

`tools/verify-hook.sh` is on `CLAUDE.md`'s *never edited autonomously* list. It gained three fixtures — `manual`, `autonomous`, `badmode` — each a repo carrying a `HANDOFF.md` with a mode row, because no existing fixture has one and the hook's whole input is that file. The change is additive: three `make_repo` calls, a `mode_file` helper, three `substitute` patterns. It was written as a proposed diff first and applied under the user's explicit direction to execute, in manual mode.

## Verification

```
verify-hook.sh — hooks/mode-guard

pass — expect allow
  PASS  allow   autonomous mode, a commit — the mode permits it
  PASS  allow   autonomous mode, a merge — the mode permits it
  PASS  allow   manual mode, a command the mode does not govern — not this hook's business
  PASS  allow   manual mode, reading a PR rather than merging it

deny — expect deny
  PASS  deny    manual mode, a commit behind a cd and a comma — the truncation case
  PASS  deny    manual mode, a commit — the failure this hook exists for
  PASS  deny    manual mode, a merge — three of these landed unasked on 2026-09-07
  PASS  deny    manual mode, a push
  PASS  deny    no HANDOFF.md — unset means manual, and the denial names the fix
  PASS  deny    a mode row saying something this hook does not model — unreadable means manual

malformed — expect allow
  PASS  allow   an empty object — no command, nothing to govern
  PASS  allow   a truncated payload — the case a hook is most likely to meet and least likely written for

  PASS  kill switch present
  PASS  kill switch suppresses deny

14 passed, 0 failed
```

`tools/verify-all.sh` — 11 gates, all clean.

## What is not proven

**The hook has never fired in a live session.** It is registered in the working tree's `hooks/hooks.json`; the installed plugin still carries the previous manifest. Until `tools/plugin-reload.sh` runs and the session restarts, it guards nothing here — so the commit that lands this work is itself unguarded.

**The mode vocabulary has no state for what this session is running under.** The user's direction was *commit where you need to, but do not push to GitHub without me* — commits allowed, pushes and PRs not. `HANDOFF.md` has manual, autonomous and suspended, and none of them is that.
