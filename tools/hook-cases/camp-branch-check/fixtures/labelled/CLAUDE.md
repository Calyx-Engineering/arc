# Fixture — not instructions

A stand-in repository root for `tools/hook-cases/camp-branch-check`. Nothing here governs work
in Arc.

It declares a convention that labels its numbers with a word **Arc does not know** — `ticket`,
not `issue` or `pr`. The pair of cases is what proves the read: `pass/declared-label` alone
would also be green if the hook never opened this file, since every unread path exits silent.
`report/declared-label-missing` is the half that can only be green if it was read.

The branching section below is a fixture's, not a rule. Nothing in it applies to Arc.

## Branch protection

`main` is protected. This heading exists because it names a branch and comes first: the hook
must still prefer the section below, whose whole subject is branching.

## Branching

`release/2026-q4` is the integration branch. Work branches take
`feat/ticket-<NN>-<slug>` — the ticket number, always, because nothing else links a branch to
the tracker.
