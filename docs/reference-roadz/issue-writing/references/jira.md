# Jira mechanics

Syntax and quirks. The discipline is in [`../SKILL.md`](../SKILL.md).

> **Status: unverified.** This file was written from documentation rather than from
> use, unlike [`github.md`](github.md) whose traps were all observed directly. Confirm
> against the actual instance before relying on any specific here — Jira behaviour
> varies by version (Cloud vs Data Center), workflow configuration and installed apps.
> Correct this file as things are confirmed, and delete this banner when it has been
> used in anger.


## The model differs from GitHub

| | GitHub | Jira |
| --- | --- | --- |
| Close on merge | Keyword in the PR body | Smart commit in the **commit message**, or a workflow transition |
| Link types | One closing relation, plus loose references | A configurable **set** — blocks, relates to, duplicates, causes … |
| Issue hierarchy | Flat, plus task lists | Epic → Story → Sub-task, enforced |
| Identifier | `#42` | `PROJ-42`, project-prefixed and globally unique |

The practical consequence: **Jira expresses relationships that GitHub cannot**, so the
spawned-versus-related distinction maps onto a real link type rather than a table
convention. Prefer the native link type over prose.


## Smart commits

Act from the commit message, not the PR body:

```text
PROJ-42 #comment Fixed the threshold calculation
PROJ-42 #time 2h 30m
PROJ-42 #close
```

Constraints to check on the instance:

- Smart commits must be **enabled** for the repository integration; they are commonly
  off
- The transition name (`#close`, `#done`, `#resolve`) must match a transition that is
  **valid from the issue's current status** in its workflow
- The committer's email must map to a Jira account with permission to transition
- Multiple issue keys in one message are allowed

**The deliverable test from the parent skill applies unchanged.** A design document
does not `#close` a capability issue.


## Link types

Typical defaults — instances customise these:

| Relation | Use for |
| --- | --- |
| **relates to** | Same area, independent existence |
| **blocks / is blocked by** | Hard dependency. Use it; Jira reports on it |
| **causes / is caused by** | Closest native fit for **spawned** work |
| **duplicates** | Same request filed twice |

Where GitHub needs a hand-maintained "Spawned issues" table, Jira has a link type.
Use it, and keep the table only if the team reads it.


## Formatting

- Jira Cloud uses ADF (Atlassian Document Format) through the API, not Markdown.
  Tables, panels and checklists exist but are not Markdown syntax
- The UI editor accepts some Markdown-like input and converts it on entry
- **Do not assume a Markdown body will render.** Check how it lands before writing a
  long one


## Tooling

- `acli` (Atlassian CLI) and the REST API are the scripted paths
- The MCP Atlassian server, where available, is usually the least friction from an
  agent
- Whatever the transport, the **verify-after-write** rule from the parent skill still
  holds: read the issue back and confirm the link and status are what you intended
