# Issue #37 — The event log

> Decision log, not a spec. Started at plan time, finalised as a retrospective at PR time.

**Issue:** [#37](https://github.com/Calyx-Engineering/arc/issues/37)  ·  **PR:** [#52](https://github.com/Calyx-Engineering/arc/pull/52)

## Problem

Verbosity governs what surfaces in conversation. At `quiet` nothing surfaces, so nothing is
retained — a display setting deciding what is kept.

[m44](../product-architecture/mechanisms/m44-event-log.md) shipped `partial` with three items
open: entry format, rotation, and volume control. Building the artifact required settling the
first two.

## Decisions & trade-offs

| | |
|---|---|
| **Plain lines, not a markdown table** | The deciding constraint is *cheap to append*. A table row must be inserted under a header, so the writer has to locate it first — an append that reads the file is one that gets skipped under load. Flat lines append with a single `>>` |
| **Three lines per entry, `skipped` optional** | Timestamp/artifact/event/subject on line one; `checked` and `outcome` indented beneath. Readable unaided, and greppable by artifact or event name without tooling |
| **UTC to the minute** | Second precision implies an ordering the file does not have — entries are appended by separate sessions. Minute precision is honest about the resolution |
| **Four outcome values** — `ok` · `denied` · `repaired` · `failed` | `repaired` is the one that would otherwise be lost: `issue-write` finding a missing milestone and setting it is neither a pass nor a failure, and it is the most useful signal in the file |
| **The template is the format authority, not m44** | m44 names the fields; `templates/event-log.md` defines the serialisation. Stating the format in both guarantees drift. m44 now points at the template and does not restate it |
| **Rotation moves the file, does not delete it** | Retention is still undesigned. Moving to `docs/arc-log/events/` at arc close preserves the log beside the arc-log that explains it, and defers the retention question without losing data |
| **The live log was backfilled with this arc's three real events** | PRs #50 and #51 and the #51 merge already happened. An empty log would have been the first thing a reader of this PR saw |

## Rejected approaches

| Rejected | Why |
|---|---|
| A markdown table | Fails *cheap to append* — see above. It reads better, and that is the only thing it wins on |
| JSONL | Fails *readable unaided*, which m44 lists as a requirement precisely because a human is the first consumer |
| Defining `camp-reports:` here | [#45](https://github.com/Calyx-Engineering/arc/issues/45) owns the header. This issue specifies what the log needs *from* a declaration — one declaration drives both the report and the entry — and #45 satisfies it |
| Logging at second precision | Implies an ordering guarantee across concurrent sessions that does not exist |

## Retrospective

Two files: `.claude/arc/log.md` live, `templates/event-log.md` as the format authority. m44
updated — status revised, entry format and rotation moved out of *what is not designed*, and
the serialisation decision recorded with its reasoning.

**What was verified:** the append snippet was executed against a scratch file and produced
output matching the documented format exactly. Every relative link in both new files resolves.
The live log is plugin-level rather than under `camp/`, is not gitignored, and carries no
template scaffolding.

**What could not be verified:** that anything writes to it. No artifact declares
`camp-reports:` yet — that is #45. Until then the log is a format with three hand-written
entries and no producer. The `checked`-line discipline, which is the file's whole value, is
also unenforced until an artifact emits it.

**One thing a future reader needs:** the `skipped` line is what makes a declared-but-unrun
check visible. It is the difference between an artifact that was quiet because everything
passed and one that was quiet because it never ran — and it only works if #45's header names
every check, including the ones that usually do not fire.
