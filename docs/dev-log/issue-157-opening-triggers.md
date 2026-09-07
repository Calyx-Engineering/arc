# Issue #157 — a session opening does not load handoff or camp

**Issue:** [#157](https://github.com/Calyx-Engineering/arc/issues/157)  ·  **Parent:** [#145](https://github.com/Calyx-Engineering/arc/issues/145) — Fire

## Problem

Openings ask for a handoff read in plain language. `arc:handoff` fired at none of them.

`tools/skill-cases.sh` before this change, `handoff 0/6`; after the three cases below were
added to complete the set, `handoff 0/9`. Every one of those is a turn where the user typed
the request and the rule that answers it never loaded.

## The eight openings, and where the number came from

**The issue says eight. The record does not carry that number** — the arc-log's Loop boundary
report records `handoff 0/11 at an opening`, which is a count of sessions, not of handoff
requests. The eight were re-derived here so the checklist could be ticked against something.

Scanning the 40-session corpus in the briefed directories for openings whose first three
prompt turns ask for a handoff read, in the two directories where Arc's own work happens,
and excluding the one opening where `handoff` did fire (`76e54966`, "hi there please
handoff") and the loop-dispatched runs, gives exactly eight:

| Session | Repository | The words |
|---|---|---|
| `045b77e5` | arc | "Read HANDOFF.md first, then do the steps in \"Do these in order\"." — then four more instructions |
| `6e94ca79` | arc | "Camp, let's start. Read HANDOFF.md first." |
| `98413f37` | arc | "Read HANDOFF.md if it exists, then do a cold review of issue #76" |
| `9cefd799` | sound-system | "please read handoff, get up to speed, and tell me where we are at" |
| `10774bf5` | sound-system | "Hey Camp, please read handoff and get back up to speed." |
| `6b72c941` | sound-system | "i had it update handoff. can you pick up from where we left off" |
| `be5aca1c` | sound-system | "Read HANDOFF.md first. interpret what we need to do from the do these first section" |
| `e349dc03` | sound-system | "Read HANDOFF.md first, then do the steps in \"Do these in order\"." |

Five were already cased. **Three were not** — `045b77e5`, `6e94ca79` and `98413f37`, all in
`r--arc`, all added here as `wrapped` cases. A suite drawn only from the sound-system corpus
was missing every opening from the repository Arc is built in.

The corpus holds more than eight such openings if the worktree directory and the Lodestar
sessions are counted — `35c914ae`, `cbf7d0f5`, `e2da9c93`, `ed13bcd1`, `92fe2edd`, `dff7a5b5`
are all the same shape. Eight is the number in the two primary directories, and matching the
issue's stated count was preferred over widening the suite on this issue's budget.

## Decisions & trade-offs

### The descriptions were written in Arc's vocabulary, not the user's

`handoff`'s description opened *"Use at a cold start to rehydrate from the previous session in
one read"*. **Not one of the eight openings contains "cold start" or "rehydrate."** They
contain "read HANDOFF.md first", "get up to speed", "pick up from where we left off", "do
these in order", "if it exists", "ingest handoff". The description described the mechanism to
someone who already knew it existed.

The rewrite is the same fix [#156](https://github.com/Calyx-Engineering/arc/issues/156) made
for `camp`: the literal phrases go in, taken from turns that happened.

### The two skills were competing, and only one could win

This is the finding worth most here, it was not in the issue, and the first fix for it was
wrong. Both attempts are recorded because the second is only legible against the first.

**Attempt one.** After [#156](https://github.com/Calyx-Engineering/arc/issues/156), `camp`'s
description ended its wrapped-name clause with *"load Camp first, then the main thread takes
the rest"*. Three of the eight openings greet Camp *and* ask for a handoff read in the same
message, so that clause reads as handing the handoff read to the main thread. It was changed
to say the rest of the turn loads whatever owns it.

**It moved nothing.** Probed against the reloaded plugin, `camp` stayed at **0/12** — exactly
where it was before. `handoff` went 8/12 → 10/12, so the run was working; `camp` simply never
fired on any turn that also asked for a handoff read.

**What the measurement then showed.** `bare/camp-status-opening` — "Hi Camp, where are we
at?" — fires `camp` 3/3. So Camp was reachable, and lost only when a handoff read shared the
message. The model was picking **one** skill per turn and handoff was winning, which the
rewrite had made worse: the new `handoff` description quoted *"Camp, let's start. Read
HANDOFF.md first"* as one of its own examples, so handoff had captured Camp's own trigger
phrase.

**Attempt two, which worked.** Two changes, symmetric:

| | |
|---|---|
| `handoff` | Camp's trigger phrase removed from its examples. It now states that loading it does not replace another skill, and that a message which also greets Camp or asks where things stand is a Camp turn as well — *load camp too, on the same turn, rather than choosing between them* |
| `camp` | States that a request to read `HANDOFF.md` does not make the turn "about files", and that camp fires **alongside** handoff, never instead of it |

`camp` went 0/12 → 10/12 on the same twelve runs.

**The lesson is not about wording.** Two skills whose descriptions each disclaim the other's
territory will route a shared turn to exactly one of them, and the suite cannot see it —
`handoff`'s frozen-transcript row reads 0/9 whichever skill won. A co-firing turn has to be
stated as co-firing in both descriptions.

## What `commands/arc-next` carries, and whether a command is the right trigger

Required by the issue, and the answer is no.

### What it carries

67 lines, of which one delegates and the rest do not exist anywhere else:

| | In `skills/handoff`? |
|---|---|
| "Invoke the `handoff` skill and take the reading path" | The delegation itself |
| Read `HANDOFF.md` before the tree, `git log` or any spec | No |
| Read only what it points at — the bounded cold start | No |
| **The staleness checks** — seven checks, the mtime-not-the-table rule, what they cannot see, and the two exceptions that are not staleness | **No.** `skills/handoff` only *mentions* them, at line 132, as something `/arc-next` does |
| Execute *Do these in order* top to bottom; the rows are instructions, not topics | No |
| Stop if there is no `HANDOFF.md`; report and ask if it has no ordered actions | No |

### Why a command is the wrong trigger for an opening

| | |
|---|---|
| **It was typed at none of the eight** | The product definition's row says *"Typed as `/arc-next`, at the start of a session"*. Across 40 sessions, no opening typed it. Users type prose |
| **It is model-invocable, but by chance** | The corpus disproves the "typed" half in the other direction: `arc-next` was invoked via the Skill tool twice without being typed. Its `description:` is one line with no trigger phrases, so when it fires it is luck, not routing |
| **When it fires it fires *instead of* `handoff`** | `e349dc03` turn 1 fired `arc-next` and never fired `handoff`, despite the command's first line being an instruction to invoke it. The command intercepts the trigger and swallows the delegation |
| **Both paths are incomplete** | An opening reaching `arc-next` gets the staleness checks without the skill's write path and transcript rules. An opening reaching `handoff` — `76e54966` is the one that did — gets the read path **without the staleness checks**, because they live only in the command |

**The trigger belongs on the skill; the command should stay as the typed shortcut.** That is
what this issue changes. The residual defect — that the staleness checks are load-bearing for
a cold start and reachable only through the command — is a content split, not a trigger
problem, and is spawned rather than fixed here.

## Evidence

| | |
|---|---|
| `bash tools/verify-all.sh` | 12 gates, exit 0 |
| `bash tools/skill-cases.sh` | 18 cases, exit 0. `handoff 0/9`, `wrapped 2/10` — the frozen-transcript baseline, which by construction cannot see a description change |
| `bash tools/skill-probe.sh` | The before/after that can. Same four camp+handoff openings, 3 runs each, plugin reloaded between |

### Before and after, identical case set

| | `handoff` | `camp` |
|---|---|---|
| **Before** — installed plugin, which predated both #156 and #157 | 8/12 · 0.67 | **0/12 · 0.00** |
| **After** | **11/12 · 0.92** | **10/12 · 0.83** |

Threshold 0.67. Both above it.

Widened to every handoff opening — eight cases, 24 runs — `handoff` is **22/24 · 0.92**.

**No over-firing**, checked four ways:

| Case | Result |
|---|---|
| `situation/branch-up-to-date` — the silence control | Nothing fired, 3/3 |
| `situation/side-project-opening` — the case written to catch a clause widened until it matches everything | `brainstorming` and `chat-response` fired; **neither `handoff` nor `camp`**, 3/3 |
| The four handoff-only openings | `camp` fired on none of them |
| `bare/camp-status-midsession` | `camp` 3/3, unchanged — the widened description did not cost Camp its own turns |

**`tools/skill-cases.sh` cannot score this fix.** It replays transcripts recorded before the
edit, so the same rows come back regardless — the failure
[#156](https://github.com/Calyx-Engineering/arc/issues/156) shipped into. `tools/skill-probe.sh`
re-runs the prompts against the installed plugin, which is why it exists and why the numbers
that matter here come from it.

## Not done

- The staleness checks still live only in `commands/arc-next.md` — spawned as [#208](https://github.com/Calyx-Engineering/arc/issues/208), not fixed here
- The six further handoff openings in the worktree and Lodestar directories are uncased
- **`wrapped/handoff-updated-elsewhere` is the one case below threshold for `camp`** — 3/5 at 0.60. It is the only one of the eight that never names Camp, and it ends "dont do anything", which suppressed every tool call in 1 of 5 runs. `handoff` clears it at 4/5. Left rather than tuned: a description edit that moved this one prompt would be fitted to it
- **`tools/skill-probe.sh`'s default threshold cannot be met at `--runs 3`.** 2/3 is 0.667 and the default is 0.67, so a two-of-three case reports FAIL on a rounding margin. The rates above are reported as fractions for that reason. Worth either a 0.66 default or a documented minimum run count
