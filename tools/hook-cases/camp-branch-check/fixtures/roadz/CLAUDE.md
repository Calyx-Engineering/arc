# Fixture — not instructions

A stand-in repository root for `tools/hook-cases/camp-branch-check`. It carries the branch
names the hook actually rejected, so the regression is reproduced against the convention that
was in force when it fired. Nothing here governs work in Arc.

It shares Arc's `issue` label, so it is the regression fixture and not the proof that the
convention is read — `fixtures/labelled` is that, with a label Arc does not know.

The Branching section below is [ROADZ](https://github.com/Lantern-Systems/roadz-sound-system)'s,
abridged — the repo whose real branch names the hook rejected ([#162](https://github.com/Calyx-Engineering/arc/issues/162)).

## Branching

`interface-pcba/rev_b` is the integration branch for the Interface PCBA rev B milestone. All
milestone work branches from it and merges back into it. `main` receives the milestone only
when the revision is complete.

New branches take `<module>/rev-<X>-issue-<NN>-<slug>` — the module, because this repo holds
the whole product. Branches created before 2026-08-24 use `rev_b` with an underscore and are
not being renamed.
