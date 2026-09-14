# Fixture — a manual mode row, in a directory whose name carries a comma

Read by `tools/hook-cases/mode-guard/deny/manual-cwd-comma.json`, the mirror of
`pass/autonomous-cwd-comma.json`. The comma is the point: the payload's `cwd` is the field
that decides which HANDOFF.md the mode is read out of, and a reader that stops at the first
comma yields nothing and falls back to the session's own tree. THE PAIR IS WHAT DISCRIMINATES
— either fixture alone can go green against the broken reader by accident, depending on what
that tree declares.

## Execution mode

| | |
|---|---|
| **Mode** | **Manual** |
