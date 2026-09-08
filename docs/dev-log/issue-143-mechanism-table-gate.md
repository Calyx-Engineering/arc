# Issue #143 — verify the mechanism table against its specs

> Dev-log, not a spec. Started at plan time, finalised as a retrospective at PR time.
> Keep it short — capture the *why*, not a blow-by-blow. Skip any section that doesn't apply.

**Issue:** [#143](https://github.com/Calyx-Engineering/arc/issues/143)  ·  **PR:** [#236](https://github.com/Calyx-Engineering/arc/pull/236)

## Problem

The mechanism table in [the product definition](../product-architecture/README.md) and the specs
in `docs/product-architecture/mechanisms/` were kept in agreement by hand. Before this change
`verify-all.sh` ran nineteen gates and not one of them opened a mechanism spec, so a row and its
spec could say two different things indefinitely — in the document that is the authority on what
Arc is made of.

## Intent and north star

| | |
|---|---|
| **What this issue is really for** | The definition's two halves — the table and the specs — become checkable against each other, so drift fails loudly instead of accumulating |
| **North star** | `verify-all.sh` opens every mechanism spec, and a row that disagrees with its spec names the identifier that carries the disagreement |
| **What makes it durable** | The check reads the tree in both directions. A spec nobody linked is as much a finding as a link pointing at nothing — the half a hardcoded list cannot see |
| **Out of scope** | Deciding which side of a mismatch is wrong. The gate reports; the author decides |

## Decisions & trade-offs

| | |
|---|---|
| **A `selftest` subcommand, not a second file** | The issue asks for a self-test "in the shape of `tools/verify-sync-parity.sh`". That file no longer exists — [#142](https://github.com/Calyx-Engineering/arc/issues/142) deleted it with the local skill copies. Its shape was recovered from `git show 42b04d5^` and fitted to the `selftest` subcommand the surviving verifiers use (`verify-linked-branch.sh`, `verify-tracker-body.sh`). What the issue actually pins down — fixture trees under `mktemp`, never the live tree — is unchanged |
| **A compatibility map, not a new scale** | The constraint forbids a second state ladder. The table's glyphs stay the only ladder; what the script adds is a statement of which of the specs' *existing* Status words each glyph is compatible with. The vocabulary was read off the specs as they stand — `undefined`, `partial`, `specified`, `built`, `definition` — not designed |
| **`partial` is incompatible with ✅ only** | "Complete" in the glyph ladder is ✅ Matured, which means soaked. 🔵 Implemented is explicitly *waiting on* the soak, so a spec with named holes sitting at 🔵 is consistent. Case 5b pins this: without it, the gate could reject every `partial` spec and case 5 would still pass |
| **A Status word outside the vocabulary is reported, not guessed at** | Silently accepting an unrecognised word is how the two documents drift apart again, one word at a time |
| **Skill-linked rows are not asked for a Status line** | `CLAUDE.md` makes a skill its own spec for m11, m18 and m38, and a `SKILL.md` carries frontmatter rather than a `Status:` line. Their links are still resolved — a skill link pointing at nothing is the same defect as a spec link pointing at nothing, and case 9b exists so case 9 cannot pass for a gate that skipped skill rows entirely |
| **Two `run_gate` calls, one `KNOWN` entry** | The selftest proves the gate works; the live run checks the tree. Both are cheap and they answer different questions |

## Rejected approaches

| | |
|---|---|
| **Mapping Status words onto the glyphs one-to-one** | They are different axes. `partial`/`specified` describe how finished the *spec* is; ⚪/🔵/✅ describe how far the *mechanism* is into Arc. A one-to-one map would have forced a second scale, which the issue forbids. A compatibility relation says the checkable thing without inventing anything |
| **Failing on every spec whose Status word is outside `partial`/`specified`** | Those two are the only words the README's *Spec completeness* section names, but five are in use. Failing on the other three would have reported thirteen mismatches on the first run, none of which are the drift this gate is for |
| **Rewriting the side the gate judges wrong** | Explicitly forbidden by the issue, and right: the gate cannot know whether the row or the spec is the stale one |

## Defects found by building this

**`m40-autonomy-switch.md` had no `Status:` line at all** — found by the gate's first live run.
The definition's *Spec completeness* section requires one of every spec ("Each one states its own
state at the top"), and m40 was the only spec that did not have one. The table's 🔵 is the correct
side: `hooks/mode-guard` and `skills/autonomy-set` both exist, and `mode-guard` gated this run.
The line was added to the spec, in the shape m10 uses.

**The Status vocabulary was enforced by the gate and documented nowhere.** *Spec completeness*
named two words; five are in use across the specs. An author following the document would write
`implemented`, and the gate would reject a word they had no way to know was illegal. The section
now carries all five and a *Compatible with* column — which is also the only place the relation
between the two ladders is written down, rather than living in a shell script's comment.

**Neither `sed` nor `grep -F` here can *match* a four-byte UTF-8 character.** 🔵 is U+1F535; ⚪
(U+26AA) and ✅ (U+2705) are three bytes and match fine. Writing a four-byte character works —
only matching fails — and it cost three separate things before the pattern was recognised:

| Where it bit | What it looked like |
|---|---|
| A fixture mutating a glyph with `sed -i` | The mutation changed nothing and the case passed against an unmodified fixture |
| Two mutation tests | Reported as *survivors*, i.e. as gaps in the selftest, when the mutation had never applied |
| `case_is`, which asserted with `grep -qF` | Any assertion naming 🔵 was unmatchable. A case expecting failure could only fail; one expecting success would have passed without testing anything |

The fixture builder now takes the glyphs as arguments rather than sed-ing them, `case_is` uses
bash's `[[ == *…* ]]`, which matches all three widths, and **every mutation is diffed against the
original before its result is believed** — a mutation that did not apply proves nothing.

**Tab is IFS whitespace, so `read` collapses empty fields.** The row reader emitted
`id<TAB>glyph<TAB>spec<TAB>count`, and a row with an empty Spec or Status cell — the exact drift
this gate is for — shifted every field left and was reported as *malformed row: m50 has -2
columns*. The delimiter is now `\037`, which is not IFS whitespace. Found by review pass 1, and
two cases now pin it.

## Evidence

| | |
|---|---|
| `bash tools/verify-mechanisms.sh selftest` | 29 passed, 0 failed |
| `bash tools/verify-mechanisms.sh` | exit 0 — after the m40 fix; exit 1 before it, naming `no status: m40` |
| `bash tools/verify-all.sh` | all gates clean, exit 0 |
| **Mutation testing** | 20 deliberate mutations of the script applied and run against the selftest. **19 are caught.** The survivor is equivalent — see below |

**The one survivor is an equivalent mutant, not a gap.** `specified) return 0` in place of the
explicit `⚪ 🔵 ✅` list cannot be observed, because those three glyphs are the whole ladder. The
explicit form is kept anyway: it is what the definition's *Compatible with* column states, and an
unconditional pass would agree with that column by coincidence and stop the day a fourth glyph
joins. `undefined) return 0` looked like the same shape and was not — it survived because no
fixture paired `undefined` with 🔵. Case 5c is that pairing, and the mutation is now caught.

**Mutation testing earned its keep three times.** It found a case that asserted nothing
(`grep -m1` → `tail -n1` survived, exposing a fixture whose second `Status:` line sat where the
header boundary hid it); it found the untested `undefined` arm above; and its own two false
"survivors" are how the four-byte matching limitation was found.

## Review passes

Each pass was read by a sub-agent carrying the issue body and the changed-file list, per the
run instructions. **The gate's own selftest was green before every one of them.** That is the
argument for the passes, and the reason the count of real defects below is worth stating.

| | Asked | Found |
|---|---|---|
| **Pass 1** | Is every requirement met? | 9 findings, 6 real defects: the tab-delimiter collapse, the undocumented vocabulary, an escaped pipe making a legitimate row unparseable, an anchored link reported as missing, the header window as an untested magic constant, and one defect producing two findings |
| **Pass 2** | What did pass 1's fixes introduce? | 8 findings, 6 acted on: a URL-only Spec cell reported as *no spec link*, `/^## /` not bounding an h3 spec, a decorative case, a malformed row vouching for a spec and masking a genuine orphan, the `\001` sentinel not round-tripping, and two README rows agreeing with the code only by coincidence |
| **Pass 3** | Does each ticked box have evidence in the tree? | Boxes 1–6 verified against the emitters and their cases; box 7's case count was stale. Two cases named as unable to fail, both confirmed independently by mutation, both now discriminating |

Pass 2's finding that `hooks/mode-guard` has no row in the definition's artifact table is real and
is **not** fixed here — that table is [#124](https://github.com/Calyx-Engineering/arc/issues/124)'s
unit.

## Spawned

- **Issues:** none filed. The findings above were fixed in place, each being one line of the
  change this issue already owns.
- **Recorded, not fixed:** `hooks/mode-guard` is missing from the definition's artifact table.
  Noted on [#143](https://github.com/Calyx-Engineering/arc/issues/143) and belonging to
  [#124](https://github.com/Calyx-Engineering/arc/issues/124).
