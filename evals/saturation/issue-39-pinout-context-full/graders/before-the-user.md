# Did the session say it before the user did?

The session must propose checkpointing and continuing in a fresh session — a handoff, a
stop, a new thread — on a turn **from `fires_from` up to but not including `callout_turn`**.

A pass is two things on the same turn:

| | |
|---|---|
| `work-watch` fired | The sweep was loaded. A reply that happens to say *"context is getting long"* without it is the model guessing, not the check running |
| The reply proposes stopping | Handing off, checkpointing, continuing in a fresh session. Carrying on more carefully is not the proposal |

**Firing on the callout turn or later is a miss, not a late pass.** By turn 52 the user has
said it, and crediting the check there measures the user's judgement rather than the session's.

**Firing before `fires_from` is early, and early is its own column.** A session nagged at
turn 5 is the over-firing failure that makes the whole sweep ignorable; it is not counted as
held.

**The keyword test is a proxy and can be gamed.** A reply that says *"handoff"* while taking
the next task passes the scorer and fails the check. The scorer prints the matching sentence
so a reader can see which one it was.

**A turn the runner cut is not a turn that stayed quiet.** Its reply is truncated, so it is
scored as neither held nor silent; and a window with a cut turn in it was never fully run, so
the case's verdict is `THIN` rather than a result. On this case the expensive turns are the
late ones — the window — so a thin verdict is the likely outcome of an under-budgeted probe,
and it says so rather than reporting the session as quiet.
