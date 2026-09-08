# Issue #10 — plugin skeleton, hook harness, and the branch guard

> Dev-log, not a spec.

**Issue:** [#10](https://github.com/Calyx-Engineering/arc/issues/10)  ·  **PR:** [#20](https://github.com/Calyx-Engineering/arc/pull/20)

## Problem

Nothing loaded and no hook could be tested. First functional code in the repo.

## Decisions & trade-offs

**Bash, not Node.** TimeScope's precedent is Node, but a hook that shells out to a runtime
adds a failure mode — a missing or wrong-version interpreter denies every tool call. Bash is
already required by the verify script and by Git Bash on this machine. The payload parsing is
three `sed` calls, which is cheap enough not to want `jq` as a dependency.

**The kill switch and the fail-open wrapper live in a template, not a checklist.** A
checklist item can be skipped; a copied file cannot omit what it already contains. This is
the difference between a rule and a mechanism, and it is the same distinction the whole
product turns on.

**The verify script builds real git repos rather than mocking `rev-parse`.** More setup,
but a mocked branch proves nothing about a hook whose entire job is reading the branch.
This decision is what caught the bug below.

**Markdown is writable on every branch.** The guard's protected-path list is inverted from
TimeScope's: rather than enumerating source paths to deny, it enumerates the record paths to
allow and denies the rest. Arc's file types are not knowable in advance — it runs against
hardware repos with CAD, scripts, and BOMs — so a deny-list of source extensions would leak.

## Rejected approaches

**A gate hook that validates hook changes.** The instinct is right and the mechanism is
wrong: a hook validating hook changes can be broken by the change it is validating, and
`HOOKS_OFF` would disable the gate along with everything else. A script works with hooks off
and produces output a human can read.

**Shipping all three checks.** Worktree identity and base freshness have no precedent and
open design questions. One working check beats three half-finished.

## Spawned

- **Arc work:** [closing keywords and the base branch](../arc-work/02-foundation/closing-keywords-and-base-branch.md) — found while verifying this issue's own PR

## Retrospective

Shipped the manifest, the hook template, the verify harness with eleven payload cases and
two kill-switch assertions, and the branch check. 13 passed, 0 failed.

**The harness earned itself on first run.** `arc/*` matched issue branches as well as arc
branches, because git refs cannot nest — issue branches are named
`arc/02-foundation-issue-10-skeleton`, with a dash. The guard was denying source edits on
exactly the branch it tells you to create. A mocked `rev-parse` would have passed that case
vacuously.

**`.gitattributes` was not in the issue scope and is load-bearing.** Without `eol=lf`, a
CRLF checkout makes bash fail with `bad interpreter: /usr/bin/env bash^M` — which, on a
`PreToolUse` hook, means every tool call errors. On Windows this is not a theoretical risk;
git warned about it during staging.

**Not registered in anyone's settings.** `hooks/hooks.json` declares the hook for plugin
install. Nothing fires until Arc is installed as a plugin.
