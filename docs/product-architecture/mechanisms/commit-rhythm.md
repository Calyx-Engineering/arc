# Mechanism — Commit Rhythm

**Status:** specified.
**Home:** Arc — Workspace guard.
**Spawned from:** [friction-log.md](../../retrospectives/2026-08-plugin-line/friction-log.md) §2.5.

---

## The problem is two-sided

§2.5 of the friction log recorded only half of it. Reading every commit-related message
across four weeks (~30 of them) shows a symmetric failure:

| Failure | Cost | Evidence |
|---|---|---|
| **Over-commit** — agent commits unasked, or too often | Destroys the review surface | *"i can't tell what you changed"* |
| **Under-commit** — nothing committed because nobody asked | Work at risk; sync blocked | Every commit in four weeks was user-initiated |

**Both are the same defect:** commit timing is entirely on the human, so it tracks
attention rather than the state of the work.

### Over-commit

> *"could you wait before making these commits? i know you got scared when you thought
> you lost it before. but you commit before [I can review]"* — 2026-08-13

> *"its good for you to ask me and remind. but i need to be able to review — if there are
> 200 commits in git then it fills the git log with so much noise. its taking development
> that's being iterated live and pushing all that live iteration noise into the log."*
> — 2026-08-13

> *"i never squash merge. we will leave for now and take it as a lesson learned. but
> critical note here — because there is so much noise here i can't tell what you changed"*

**The mechanism behind it, in David's words:** an agent that has previously lost work
commits defensively. That instinct is what produces log noise.

### Under-commit

Every one of roughly 30 commits in four weeks was requested by David. Several arrived
late, prompted by an external event rather than by the work reaching a natural point:

> *"commit the current state because this might be my stopping point for the day"*

> *"ok lets commit and push because i'm going to pull this up on my laptop so i need to
> sync from github"*

> *"i need to get ready for an interview. please commit all … and then generate PR"*

The trigger in each case is David's calendar, not the state of the work. Nothing
watched for a good capture point, so capture happened when he happened to think of it.

---

## The rule David already stated

> **"i think we want to commit at the first semi-mature state. not when it is first
> created."** — 2026-08-12, said twice in the same session

That is the whole design, and it names the failure precisely. Committing at creation
captures churn. Committing at a semi-mature state captures a reviewable unit.

**And the delegation is explicit:**

> *"its good for you to ask me and remind"*

> *"I have found you to be brilliant and intuitive. So i can trust you to help reason
> when to remind me to commit (good capture points)."* — 2026-08-16

**Posture: propose, never act.** The agent judges when a capture point has arrived and
says so. The human decides. This mirrors the capture-trigger stance in Lodestar's own
design — nudge, never silent write.

---

## What a capture point looks like

Derived from what David actually accepted or requested across four weeks:

| Signal | Why it is a capture point |
|---|---|
| A document reached "good enough to read" | Most common accepted commit in the log |
| An issue's work is functionally complete | Often paired with `Closes #NN` |
| A distinct sub-analysis finished | *"the flicker exposure md looks good lets commit"* |
| About to change branch or worktree | Prevents the §2.1 disaster class |
| About to start unrelated work | *"commit everything except the emi we just started so we have a clean slate"* |
| Session is ending | Frequently requested; better anticipated |
| Before a long or risky operation | Rollback point |

### What is not a capture point

- A file was created but is still being drafted
- A typo fix mid-iteration
- Every turn, or every tool call
- The agent feels uncertain and wants a safety net ← **the over-commit cause**

---

## Mechanical rules, learned the hard way

Each of these cost real time and belongs in whatever ships:

| Rule | Evidence |
|---|---|
| **Never commit unasked** | Standing instruction; violated repeatedly |
| **Check files are saved first** | *"darn there were unsaved changes … you should always check that the files are saved before committing"* — see §Unsaved buffers below |
| **Never squash merge** | *"i never squash merge"* — destroys reviewability |
| **Verify the commit identity** | *"we are supposed to be on my davidcalyx ID … it makes no sense to be committing as davidcalyx and commenting as heliman"* |
| **Watch for silently dropped staged files** | *"did you remove the logs that i staged?"* and *"why does the logs.jsonl keep not getting committed??"* — recurred twice, weeks apart |
| **Verify the issue actually closed** | *"with a commit that says it closes #11 is there a reason that #11 didn't automatically get closed"* |

The staged-file and issue-link failures are both **silent** — they report success and
do the wrong thing. Same failure class as the tracker mechanics in §2.8.

---

## Unsaved buffers — the root cause behind the conflicts

**David's finding, 2026-08-16.** Several conflicts traced to the same sequence: he
edited a markdown file in VS Code, did not save, then asked for work on it. The agent
read stale content from disk, wrote its own version, and the two diverged. **Those
conflicts are what produced the defensive over-committing** documented above — so this
is upstream of half the problem on this page.

### Can unsaved buffers be detected?

**No.** VS Code exposes no live signal for dirty buffers to an external process.
`AppData/Roaming/Code/Backups/` holds hot-exit state written when a window closes, not
while editing. Checked directly, 2026-08-16.

### Fix the cause instead

| Approach | Effect | Verdict |
|---|---|---|
| `files.autoSave: onFocusChange` | Saves when focus leaves the editor — including clicking into the chat | **Best fit.** Saves at the exact failure moment, at a natural boundary |
| `files.autoSave: afterDelay` (1000 ms) | Saves continuously | Works, but mid-keystroke states land in the diff |
| Compare file mtime before acting | Detects *saved* changes the agent did not make | Useful, but does not touch unsaved buffers |
| Ask before writing a file the user may have open | Weak, and irritating at volume | Not recommended |

**Recommendation:** ship `"files.autoSave": "onFocusChange"` in the repo's
`.vscode/settings.json` as part of setup. It eliminates the failure rather than
detecting it, and it saves at a boundary rather than mid-edit — which matters when the
user reviews by diff.

**Caveat to state at setup:** autosave means editor changes land in the working tree
continuously. On `onFocusChange` that boundary is a deliberate action, so diff noise
stays low.

---

## Proposed shape

| Part | Form | Behavior |
|---|---|---|
| **Capture-point detection** | Agent judgment, not a rule engine | Recognise the signals above; say "this looks like a capture point" |
| **Pre-commit checklist** | Hook or mandatory step | Files saved · identity correct · nothing unintentionally staged or dropped · issue link will resolve |
| **Never-commit-unasked** | Standing rule | Propose, wait |
| **Post-commit verification** | Hook | Confirm the issue closed and the link formed; fail loudly if not |

**Why judgment rather than rules.** "Semi-mature" is not mechanically detectable — it is
exactly the kind of call David has said he trusts the model to make. A rule engine would
either fire constantly or miss the interesting cases.

---

## Open questions

| Question | Notes |
|---|---|
| How often may it propose before becoming noise? | Over-prompting recreates the annoyance in a new form |
| Does it propose the commit message too? | Probably — but the message must survive the "no development narrative" rule |
| Interaction with the handoff | A session-end capture point and a handoff update are the same moment ([handoff-spine](handoff-spine.md)) |
| Does the pre-commit checklist belong in a hook? | Yes for the mechanical items; the judgment cannot be hooked |

---

## Related

- [friction-log.md](../../retrospectives/2026-08-plugin-line/friction-log.md) §2.5, §2.8
- [handoff-spine.md](handoff-spine.md) — session-end capture points coincide
- ROADZ `CLAUDE.md` — tracker link mechanics
