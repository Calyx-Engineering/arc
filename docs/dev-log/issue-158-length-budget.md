# Issue #158 — response length is not held after it is set

**Issue:** [#158](https://github.com/Calyx-Engineering/arc/issues/158)  ·  **Parent:** [#145](https://github.com/Calyx-Engineering/arc/issues/145) — Fire

## Problem

A stated response-length budget was met on the turn it was set and lost immediately after.
It recurred inside the retrospective that recorded it.

[#155](https://github.com/Calyx-Engineering/arc/issues/155) had already ruled out the obvious
fix: `chat-response` fired on a 2251-character reply, and a 60-word budget was met in 54 words
with the skill never firing. **Firing is neither necessary nor sufficient**, so making the skill
fire more often would not have closed this.

## There was no instrument, so the first half of the work was building one

`tools/skill-probe.sh` and `tools/skill-cases.sh` both measure activation. Neither can grade a
reply's length, and the issue said so. The gated grader in
[#181](https://github.com/Calyx-Engineering/arc/issues/181) was assumed to be the blocker.

**It was not.** Length is arithmetic. "Is this reply 60 words or fewer" needs counting, not
judgement, so `tools/response-length.sh` closes the `Done when` without `claude plugin eval`.

Four decisions in it are worth keeping:

| | |
|---|---|
| **Prose only** | `skills/chat-response` exempts tables, code blocks and headings from the budget. A counter that counted them would be measuring a rule nobody wrote |
| **A thin floor** | A reply that declines or says it has no context is short. Counting short as held would report the fix working every time the model failed to answer. Below 15 words is reported in its own column and scored in neither |
| **CUT is not held** | A turn the runner stopped has a truncated reply, and a truncated reply is short. This was not theoretical — a probe run at `RL_PROBE_BUDGET=0.10` truncated all eleven turns, and every one was correctly refused rather than scored as a pass |
| **The verbatim claim is checked** | Every `turns/<n>.md` is compared against the turn it copies, both directions. A case cannot silently drift from, or narrow against, its transcript |

**Replay and probe are not interchangeable.** Replay reads the recorded transcript: free,
deterministic, and blind to any edit made after the session — it is the baseline, not a test of
the fix. `--probe` replays the turns as **one** live conversation, which is the only way to see
a budget decay. Eleven separate runs cannot: each would carry the budget in its own first
message.

## What changed in the skill

A section stating that a stated budget replaces the default table and survives the work, a
change of subject, and having been met once — and the same rule, compressed, at the front of
the **description**.

## Measured

Baseline is replay; the fix is `--probe`, one run per case, against the installed plugin after
`tools/plugin-reload.sh`.

| Case | Baseline | With the fix |
|---|---|---|
| `verbose-again-60-words` | 5/11 · 0.45 · held **0** turns | **11/11 · 1.00 · held 11 turns** |
| `too-many-words-20-words` | 1/10 · 0.10 · held 1 turn | 2/9 · 0.22 · held 1 turn |

`verify-all.sh`: 13 gates, all clean, exit 0.

### The finding: it works through the description, not through firing

**`chat-response` fired on no turn in either probe run.** The section in the body was never in
context. The entire measured effect comes from the description, which is loaded every turn
whether or not the skill is invoked.

That is the mechanism #155 was circling. A rule in a skill **body** is only in force on turns
the skill fired, which for a conversational rule is almost none. A rule in the **description**
is in force always. For a standing constraint, the description is the only surface that works.

### The 20-word case still fails, and the suite does not pass

Scored together the two cases are **13/20 · 0.65**, just under the 0.67 threshold. The 20-word
case is what holds it down.

It did improve, and by a lot — the overruns collapsed from 85 / 178 / 193 / 219 words to
26 / 92 / 24 / 23. But the replies cluster at 23–30 words against a 20-word ceiling, so they
score OVER while being roughly a seventh of their former length. One turn (t16, 187 words)
broke down completely.

**A 20-word budget is not reliably held.** A 60-word one is.

## Limits on the above

| | |
|---|---|
| **n = 1 per case** | One probe run each. Enough to see 0 turns become 11; not enough to rank two wordings of a description against each other |
| **The probe is billed** | ~$1.20–1.90 per case, growing per turn as the conversation does. This is why it is not in `verify-all.sh` |
| **The corpus is local** | Transcripts live under `~/.claude/projects` on one machine. Only the selftest is portable, which is the part wired into the gate |
| **Two citations were corrected after the probe ran** | The skill and one `case.yaml` claimed "140 words" and "194" where the instrument measures 85 and 193. Corrected to the measured values. Both are inside the skill **body**, which never loaded, so the measurement is unaffected |

## `tools/plugin-reload.sh` destroyed uncommitted work — [#211](https://github.com/Calyx-Engineering/arc/issues/211)

Running it with an uncommitted edit to `skills/chat-response/SKILL.md` reverted that file to its
`HEAD` content. No git operation caused it: `git stash list` was empty and the reflog showed
only the branch checkout.

| | |
|---|---|
| Reverted | `skills/chat-response/SKILL.md` — inside a plugin component directory |
| Survived | `tools/verify-all.sh`, and untracked files under `evals/` and `tools/` |

The `calyx-engineering` marketplace is registered as `{"source": "directory", "path": "R:\arc"}`
with `installLocation: R:\arc`, so uninstall/install operates on the repository itself.

Recovery was only possible because the diff was still on screen. **Commit before reloading**
until #211 lands.
