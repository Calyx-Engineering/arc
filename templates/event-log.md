# Event log — &lt;arc branch&gt;

> **Append-only.** Every Arc artifact firing, recorded regardless of verbosity. Newest at the
> bottom. **Never edit or reorder an existing entry** — a correction is a new entry.
>
> Format and rules: this file · Spec: [m44](../docs/product-architecture/mechanisms/m44-event-log.md)

**Arc:** `arc/&lt;NN&gt;-&lt;slug&gt;` · **Rotated:** &lt;YYYY-MM-DD&gt; · **Previous:** &lt;link or "none"&gt;

---

&lt;entries, oldest first&gt;

---

# The format

**This section is the authority.** It is deleted from a live log; it lives here so the shape
has one definition rather than being inferred from examples.

## An entry

Two or three lines. Plain text, not a table — appending a table row means finding the header
first, and an append that has to read the file is an append that gets skipped under load.

```text
&lt;timestamp&gt;  &lt;artifact&gt;  &lt;event&gt;  &lt;subject&gt;
  checked: &lt;name&gt;=&lt;value&gt; · &lt;name&gt; · &lt;name&gt; — &lt;how they came out&gt;
  outcome: &lt;ok | denied | repaired | failed&gt; — &lt;detail&gt;
  skipped: &lt;check&gt; (&lt;why&gt;)
```

| Field | | Example |
|---|---|---|
| `timestamp` | UTC, minute precision, ISO 8601 | `2026-08-19T09:41Z` |
| `artifact` | The file that fired, by its directory name | `issue-write` · `branch-guard` |
| `event` | What happened, lowercase and hyphenated | `pr-open` · `branch-create` · `edit-denied` |
| `subject` | What it happened to. `key=value`, space separated. Omit if there is none | `pr=51 issue=39` |
| `checked` | **Every check the artifact declared**, passes included | see below |
| `outcome` | One of `ok` · `denied` · `repaired` · `failed`, then detail | `denied — branch is main` |
| `skipped` | A declared check that did not run, and why. Omit the line when none | `placeholder-scan (no body edit)` |

## The checked line is the point

**State what was checked, not only what was found.**

Only recording failures makes a silent artifact indistinguishable from a working one. A log
of passes is the evidence the machinery ran at all.

```text
✗  outcome: milestone missing
✓  checked: milestone · arc-prefix · closing-keyword — milestone not set, rest ok
   outcome: repaired — milestone set to "Arc 03"
```

## What an artifact logs

**One `camp-reports:` declaration drives both the spoken report and the log entry.** An
artifact does not maintain two lists — the header names its checks, and the same names appear
on the `checked` line.

| | |
|---|---|
| **Declared, ran, passed** | On the `checked` line |
| **Declared, ran, failed** | On the `checked` line, and in `outcome` |
| **Declared, did not run** | On the `skipped` line, with the reason |
| **Not declared** | Not logged. An artifact with no `camp-reports:` header writes nothing |

**Verbosity never reaches this file.** It governs what surfaces in conversation. A `quiet`
session and a `loud` one produce identical logs — which is what makes turning the volume down
safe.

## Rotation

**One log per arc, at `.claude/arc/log.md`.**

| At | Do |
|---|---|
| Arc open | Create the file with the header above. `Previous:` links the log the closing arc left |
| Arc close | Move it to `docs/arc-log/events/arc-&lt;NN&gt;-&lt;slug&gt;.log.md` beside that arc's arc-log |

Retention past that is **not decided** — m44 names it as open. The move preserves the file
until it is.

## Writing an entry cheaply

Append. Never read, never rewrite.

```sh
printf '%s  %s  %s  %s\n  checked: %s\n  outcome: %s\n' \
  "$(date -u +%Y-%m-%dT%H:%MZ)" issue-write pr-open "pr=$PR" \
  "milestone · arc-prefix · closing-keyword — all set" \
  "ok — Closes #$ISSUE bound" >> .claude/arc/log.md
```

**A log that costs a tool call per entry is a log that gets skipped.** If an artifact cannot
append in one operation, it logs less often, and a partial record is worse than a known-absent
one.

## What does not go here

| | Where instead |
|---|---|
| What was **decided** | The [arc-log](../docs/arc-log/) — this file records what *occurred* |
| Why a choice was made | The issue's [dev-log](../docs/dev-log/) |
| Conversation | Nowhere. The transcript is its own record |

**Development drift is the gap between this file and the arc-log**, which is why a
retrospective needs both.
