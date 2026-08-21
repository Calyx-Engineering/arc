# Issue #122 — template links break where the template lands

> Decision log, not a spec. Started at plan time, finalised as a retrospective at PR time.

**Issue:** [#122](https://github.com/Calyx-Engineering/arc/issues/122)  ·  **PR:** —

## Problem

**18 relative links across five templates resolve to nothing once the template is copied.** Eleven
are in `templates/camp/operating-agreement.md`, which lands at `.claude/arc/camp/` and is the
document [m43](../product-architecture/mechanisms/m43-camp-assistant.md) requires a user to read
and approve. **They are dead in this repository right now.**

Found by [#119](https://github.com/Calyx-Engineering/arc/issues/119), the first pre-release review.
It is the one blocking finding, so [#120](https://github.com/Calyx-Engineering/arc/issues/120)
waits on this.

## Intent and north star

### Pass 1 — from the issue body alone

| | |
|---|---|
| **What this is really for** | Not repairing 18 links. **A template is the only artifact whose links must be correct somewhere it is not**, and nothing in the repo knew that — the links read correctly where they sit, which is why they survived every review that read them in place |
| **North star (pass 1)** | Every template link is correct **at the destination**, and a gate says so on every run rather than a reviewer noticing once |

### Pass 2 — after reading the review's §7.1, the five templates, and `sync-local-skills.sh`

**Two things changed. The first decides the fix.**

| | |
|---|---|
| **Only some of these are depth errors** | `templates/event-log.md`'s `../docs/arc-log/` points at the **consuming repo's own** arc-log — right target, wrong depth from `.claude/arc/`. The other fourteen point at `docs/product-architecture/`, which **a consuming repo does not have at any depth**. Re-basing would fix three links and silently ship eleven still-broken ones, which is worse than leaving them: a plausible depth reads as correct |
| **`sync-local-skills.sh`'s re-basing is the wrong instrument, not an unapplied one** | It exists and works, and applying it here is the mistake. The distinction the fix turns on is **what the link points at**, not how deep it is |

**So the rule is not one rule.** It is a test applied per link:

| The target lives in | Becomes |
|---|---|
| **The plugin** — a spec, a skill, a reference | An **absolute URL** to this repository. There is no relative path from a consuming repo to a plugin document |
| **The consuming repo** — its own arc-log, dev-log, scratch | **Relative, resolved from the destination.** `templates/arc-log.md` and `templates/dev-log.md` are already correct and are the worked examples |

**North star.** A template's links are correct where the template lands, the rule that decides
which form a link takes is written down, and a gate resolves every one of them from the
destination on every run — so this cannot recur silently the way it arrived.

| | |
|---|---|
| **What makes it durable** | The gate holds a **destination map**, so a new template is covered by adding one row rather than by someone remembering. It survives a consuming repo having no `docs/` at all, which is the case that broke it |
| **Out of scope** | The other five findings. [#123](https://github.com/Calyx-Engineering/arc/issues/123)–[#126](https://github.com/Calyx-Engineering/arc/issues/126) own them. **Not re-basing skill copies** — that already works |

### Intent check

**Agreed.** Filed by [#119](https://github.com/Calyx-Engineering/arc/issues/119) inside this arc,
in the milestone, and it is the finding that gates the arc's last step. The review's own process
document says a blocking finding is one the release waits on; proceeding to
[#120](https://github.com/Calyx-Engineering/arc/issues/120) instead would make the review
decorative.

## The plan

| # | | |
|---|---|---|
| 1 | **The rule, in `templates/` itself** | Which form a link takes, and why. A rule that lives only in this dev-log is one the next template omits |
| 2 | **Repair the 18** | 15 to absolute URLs, 3 to the correct depth |
| 3 | **`tools/verify-template-links.sh`** | The destination map, and every link resolved from where it lands. Fails on a template with no map row — the same shape as `verify-all.sh` failing on a hook with no case directory |
| 4 | **Into `tools/verify-all.sh`** | A ninth gate. A check nobody runs is what produced this |
| 5 | **Repair `.claude/arc/camp/*`** | The live copies in this repo carry all eleven |

## Retrospective

*Written at PR time.*
