# Handoff — &lt;YYYY-MM-DD&gt;

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

## Read these, in this order

1. **`CLAUDE.md`** — how this repo works
2. **`docs/arc-log/arc-&lt;slug&gt;.md`** — the arc's shape and its load-bearing decisions
3. **`docs/dev-log/issue-&lt;N&gt;-&lt;slug&gt;.md`** — this issue's *why*. **If it does not exist,
   writing it is step one of the work** — do not infer the scope from elsewhere
4. Whatever those name — **only when the work touches it**

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

## Next action

&lt;One line. Concrete enough to start on without asking anything.&gt;
