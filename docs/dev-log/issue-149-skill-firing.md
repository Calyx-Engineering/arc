# Issue #149 — measure how often each skill fires

**Issue:** [#149](https://github.com/Calyx-Engineering/arc/issues/149)  ·  **PR:** pending

## Problem

No change to a skill could be shown to have worked, because nothing measured whether a skill fires. Every Fire and Handoff issue is written as *"scores above threshold"* against an instrument that did not exist.

## The issue was wrong before it was blocked

It was designed around `claude plugin eval`, which returns *"currently in early access"* on every invocation. **That was not the real defect.** The arc-log's own §3.3 flagged the instrument as *"untested here"*, and 18 issues were built on it anyway without the command ever being run.

**The measurement already existed.** Every skill invocation is a `Skill` tool_use in the transcript:

```json
{"type":"tool_use","name":"Skill","input":{"skill":"arc:chat-response"}}
```

So a firing rate is a query over real openings — which is what this issue asked for in the first place: *cases drawn from real openings, not invented prompts*. `plugin eval` remains right for regression and is now [#181](https://github.com/Calyx-Engineering/arc/issues/181).

## Decisions and trade-offs

| | |
|---|---|
| **Three numbers per skill, not one** | Fires, sessions-it-fired-in, and sessions-it-fired-in-at-the-opening. A total without a denominator is unreadable, and *fired at all* and *fired when it was needed* are different failures |
| **An opening is the first 3 user turns** | Mechanical, so it cannot drift. Three because a session's subject is set by then — the handoff read, the correction, the first instruction. Past that a fire is mid-work |
| **A user turn excludes tool results** | They arrive on a user envelope. Counting them would make every opening look longer than it is, and the selftest asserts this directly |
| **A session is in the corpus if any part of it is at or after `--since`** | One that started before the boundary and ran past it is in. One that ended before it is out |
| **Scoped by `miner-scope.sh`** | [#141](https://github.com/Calyx-Engineering/arc/issues/141)'s rule, so this cannot repeat the prefix-glob defect |
| **The counting half is Python** | `tools/skill-firing.py`. JSON parsing per line across 11 transcripts is not bash work; the shell script holds the interface and the selftest |

## Verification

`tools/skill-firing.sh selftest` — 7 cases against a throwaway fixture tree. Covers the `--since` boundary, an unbriefed directory, a fire inside the opening, a fire outside it, the tool-result exclusion, a never-fired skill, and the never-fired list. Wired into `tests/verify-all.sh`; 10 gates, all clean.

## The baseline

[`skill-firing-baseline.md`](../arc-work/04-dogfood/skill-firing-baseline.md) — 11 post-install sessions across this repository and ROADZ.

**`handoff` fired at no opening in 11 sessions.** The retrospective inferred that from 8 openings; measured, it is worse. **`work-watch` fired once in 11**, against a description that says *use continuously while work is in progress*. **`chat-response` fired in 4 of 11**, and it governs every reply.

**Every skill fired at least once**, so the defect is frequency rather than discoverability. That is a sharper claim than the retrospective could make, and it is the number Fire is now measured against.

## Retrospective

**The blocker was a symptom.** Three exchanges were spent on how to get `plugin eval` enabled before the question *what is the real issue here* was asked. The answer was that the instrument had never been run, and a different one was already in the repository.

**Two heredocs failed to write the file at all** before switching to the file tool — the shell rejected the whole command, so nothing was created, and the second attempt failed identically. Worth one check earlier than the second identical failure.
