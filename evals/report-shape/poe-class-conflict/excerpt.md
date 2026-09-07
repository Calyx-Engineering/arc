## 6 · Anomaly — af-labeled product presenting a class 4 signature

**This is the finding with a downstream cost, and it needs a decision from #38.**

The label, the model suffix, and the PCB silkscreen all say 802.3af. But 802.3af defines classes
0–3 only; **class 4 is reserved and af PDs are not permitted to use it.** Class 4 was introduced
by 802.3at to mean "Type 2 PD, wants 25.5 W." This unit consumes at most 10 W.

Consequences depend entirely on what it is plugged into:

| PSE type | Behavior | Allocated | Actually needed | Waste |
|---|---|---|---|---|
| Type 1 (802.3af) | Must treat class 4 as class 0 | 12.95 W | ≤10 W | ~3 W |
| Type 2+ (802.3at / bt) | Reads class 4 as a Type 2 PD | 25.5 W | ≤10 W | **~15.5 W per port** |

Most likely explanation: PROCET uses one PD front end across the `PT-PGC-*` family and did not
change the class-setting resistor on the `-AF` variant. This is also the most plausible origin of
the listing's "30 W" claim.

**Why this matters to the RAD-mode design.** A managed PSE budgets power by *declared class*, not
by measured draw. If the internal PoE switch sees class 4 on each of these adapters, it reserves
25.5 W per port for a 10 W load. Across several ports that is enough to drive the switch into
budget exhaustion — and to oversize its upstream supply, which is precisely the rail #38 is
trying to specify.

Open items this creates:
