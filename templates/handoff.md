# Handoff — &lt;YYYY-MM-DD HH:MM&gt;

> Session-scoped working file. **Gitignored — not part of the record.** Delete it when the
> arc closes; anything worth keeping graduates to the arc-log or a dev-log first.
>
> Read this first at a cold start, then only what it points at.

---

## Where we are

| | |
|---|---|
| Arc | &lt;name&gt; — `arc/&lt;NN&gt;-&lt;slug&gt;` |
| Issue | [#&lt;N&gt;](&lt;link&gt;) &lt;title&gt; |
| Branch | `arc/&lt;NN&gt;-&lt;slug&gt;-issue-&lt;N&gt;-&lt;slug&gt;` |
| Just finished | &lt;one line&gt; |
| **This issue is for** | &lt;one line — what it is for, not a summary of its body&gt; |

The last row exists because a dev-log is written at plan time, so the first session on an
issue arrives before one exists. Delete the row once the dev-log does.

## Execution mode

**Required. Manual is the default** — a handoff that omits this row hands the next session
no mode, and it will stop at the first action needing approval.

| | |
|---|---|
| Mode | **Manual** · **Autonomous** |
| Defined in | `docs/arc-log/arc-&lt;slug&gt;.md` § *How this arc is executed* — **read it before acting on the rows below** |
| Autonomous until | &lt;the break point in the execution order where it stops&gt; |

Autonomous means the next session runs the execution order without per-issue approval,
merges its own PRs, and stops only at a marked break. Never infer it — if this row does not
say autonomous, it is manual.

**This row is the state, not a note about it.** A mid-session switch rewrites it immediately.

**Autonomous suspends for a conversation and does not end.** A question, a correction, or a
request scoped to anything other than the next ordered action is answered rather than executed
— nothing is committed, pushed or merged as a side effect of answering. It resumes when the
user points back at the work, never because the conversation stopped.
[`autonomy-set`](https://github.com/Calyx-Engineering/arc/blob/main/skills/autonomy-set/SKILL.md) holds the rules; [m40](https://github.com/Calyx-Engineering/arc/blob/main/docs/product-architecture/mechanisms/m40-autonomy-switch.md) is the spec.

## Do these in order

The numbered actions the next session executes top to bottom. **An action, not a topic** —
concrete enough to start without asking. Ordered by dependency. Rows come off the top and
the rest renumber.

| # | | |
|---|---|---|
| 1 | **&lt;action&gt;** | &lt;issue, branch, and the one constraint that changes how it is done&gt; |
| 2 | **&lt;action&gt;** | &lt;…&gt; |

## Read these, in this order

1. **`CLAUDE.md`** — how this repo works
2. **`docs/arc-log/arc-&lt;slug&gt;.md`** — the arc's shape and its load-bearing decisions
3. **The spec of the mechanism the active issue traces to** — the arc-log names the
   mechanism, the product-architecture registry carries its spec link. A dash there means no
   spec exists; read the artifacts the issue names instead
4. **`docs/dev-log/issue-&lt;N&gt;-&lt;slug&gt;.md`** — this issue's *why*. **If it does not exist,
   writing it is step one of the work** — do not infer the scope from elsewhere
5. Whatever those name — **only when the work touches it**

Do not read the whole record. Older arcs and closed issues are history, not context.

## The tree

Issues and what spawned them. Classify by cause, not subject.

| # | Issue | Status |
|---|---|---|
| [#&lt;N&gt;](&lt;link&gt;) | &lt;title&gt; | &lt;not started · in progress · merged to arc&gt; |

## Load-bearing decisions — do not re-litigate

What was settled and must not be re-opened. **What** was decided, not why — the why is in
the dev-log.

| | |
|---|---|
| &lt;decision&gt; | &lt;the constraint it imposes&gt; |

## Open threads

Agreed but unfiled, and unresolved. This is the buffer between "we said we'd do that" and a
filed issue — the thing whose absence caused *"i asked you to update #12 … that didn't
happen"*.

| | |
|---|---|
| &lt;thread&gt; | &lt;what it is waiting on&gt; |

## Do not

Live traps. Corrections already given, so they are not repeated.

| | |
|---|---|
| &lt;trap&gt; | &lt;why&gt; |

## Transcripts

&lt;Destination directory — outside the repo, never committed.&gt; Named
`YYYY-MM-DD-arc&lt;NN&gt;-&lt;topic&gt;.jsonl`. Source is the live session file,
`~/.claude/projects/&lt;project-slug&gt;/&lt;session-id&gt;.jsonl`, newest by mtime.

Saved at a break, **before** writing this file.

**The saved copy is stale the moment it is written.** It stops at the save. When reading a
transcript for a decision, read the live source, not the copy.

**This table is curated — the transcripts worth reading, not every file in the directory.**
Nothing compares it against that directory; `/arc-next` uses mtimes.

| Worth reading | |
|---|---|
| `&lt;filename&gt;.jsonl` | &lt;what it covers&gt; |

## Next action

&lt;One line. Concrete enough to start on without asking anything.&gt;

## The prompt for the next chat

**This file is the payload; the prompt is a pointer.** Three lines, carrying nothing that is
already above.

```text
Read HANDOFF.md first, then do the steps in "Do these in order".
Branch is &lt;branch&gt;.
Next is #&lt;N&gt; — &lt;the next step, named&gt;.
```

Add a line only for something with no home in this file — a standing approval, or an
instruction for how the next session should run.
