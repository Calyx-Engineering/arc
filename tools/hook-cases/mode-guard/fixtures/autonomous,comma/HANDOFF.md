# Fixture — an autonomous mode row, in a directory whose name carries a comma

Read by `tools/hook-cases/mode-guard/pass/autonomous-cwd-comma.json`, the mirror of
`report/manual-cwd-comma.json`. THE PAIR IS THE POINT. A reader that stops at the first comma
yields no `cwd`, and the hook falls back to the session's own tree — whose mode row is
whatever that tree happens to declare, or absent, which denies. Either fixture alone can go
green against the broken reader by accident; one of the two always goes red.

## Execution mode

| | |
|---|---|
| **Mode** | **Autonomous** |
