---
name: &lt;skill-name&gt;
description: Use when &lt;the trigger — the situation, not the topic&gt;. Covers &lt;what it decides&gt;. &lt;What it is not for.&gt;
camp-reports: [&lt;event&gt;, &lt;event&gt;]
checks: [&lt;check-name&gt;, &lt;check-name&gt;]
skips:
  - &lt;check-name&gt; (&lt;condition&gt;)
---

# &lt;Title — what the skill produces, not its name&gt;

> **&lt;The one thing a reader must take away.&gt;** &lt;Why the naive approach fails.&gt;

&lt;A paragraph, or a table, stating what this governs. Delete this line.&gt;

---

## &lt;The rules&gt;

| Rule | |
|---|---|
| **&lt;imperative&gt;** | &lt;why, in the fewest words that make it actionable&gt; |

---

## &lt;Traps&gt;

&lt;Failures that have actually happened, each with what to do instead. A trap nobody has hit
is speculation — leave it out.&gt;

---

## Related

- &lt;links&gt;

---

# Writing this skill

**Delete this section before shipping.** It is here so the conventions are carried by the
template rather than learned from a neighbouring skill.

## The frontmatter

| Field | |
|---|---|
| `name` | Directory name. Lowercase, hyphenated |
| `description` | **When to use it, not what it is.** Starts *"Use when…"*. This is the only text the model sees when deciding whether to load the skill, so it names the triggering situation and, where it is easily confused with another skill, what it is *not* for |
| `camp-reports` | The events this skill reports on. Omit if it never acts — a skill that only advises has nothing to declare |
| `checks` | Every check it performs, hyphenated. **Including the ones that usually pass** |
| `skips` | Conditional checks, each with its condition |

**One declaration drives both the spoken report and the event-log entry.** Name every check,
including the ones that always pass: only reporting failures makes a silent skill
indistinguishable from a working one.

Format: [`docs/product-architecture/camp-reports.md`](https://github.com/Calyx-Engineering/arc/blob/main/docs/product-architecture/camp-reports.md).

## The body

| | |
|---|---|
| **Tables over prose** | Prose is the fallback. A rule in a table row is one a reader can act on without parsing a paragraph |
| **State the rule, not its justification** | Delete every sentence a competent engineer already knows |
| **Real failures only** | A trap that has actually happened, with what to do instead. Speculation dilutes the ones that matter |
| **No development narrative** | Not *"an earlier version did X"*. State the current rule |
| **Verify steps are steps** | If a write can silently not land, the read-back is a numbered step, not a closing remark |

## Where it lives

`skills/` — the plugin ships it. **A copy must not live in `.claude/skills/`**: where Arc is
installed, a copy loads alongside the plugin's and selection sees two identical candidates.

**A new skill needs one thing before its PR:** a row in the product definition's artifact table,
with a mechanism number. `tools/verify-skill-registry.sh` fails without it — a skill the
definition does not name is one nothing traces to.
