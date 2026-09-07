## 5 · Classification measurement — results

| Pairs | V (V) | I (mA) | Class |
|---|---|---|---|
| Mode A | 16.907 | 40.63 | **4** |
| Mode B | 16.907 | 40.63 | **4** |
| Mode A, second point | 18.924 | 40.57 | **4** |

Live PSE confirmation (Section 5 of the bench procedure) was **not run — no 802.3af switch was
available at the time.** A switch was used later for the output test in Section 7, so this is now
runnable.

### The second point proves it is a real classification circuit

The extra point at 18.924 V was a good call. Current went *down* 0.06 mA over a 2.017 V rise —
essentially flat. A resistor would have given 45.48 mA at that voltage. Flat current across the
classification window is the signature of a **current source**, which is what a compliant PD
classification circuit is. This rules out the cheap alternative of a fixed resistor faking a
class.

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
