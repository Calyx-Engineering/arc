# Light Dimming — PWM Approach

**Relates to:** [#1 — PCBA respin: Add dimmer/flasher capability](https://github.com/Lantern-Systems/roadz-sound-system/issues/1)
**Author:** David Class · **Date:** 2026-08-05, rewritten 2026-08-13 · **Status:** Current approach

Findings and conclusions. The derivations are in the companion notes listed in §6.

---


## 1. Findings

**PWM on the light's supply dims the Pioneer NP6BB directly.** The light heads, their
connectors and their harness are unchanged, and no RP2040 pins are added. What rev B adds
is a new light driver, per-channel protection, a box-input filter and an external light
sensor on its own connector — §2.

| | Finding | Detail |
| --- | --- | --- |
| **Mechanism** | Supply PWM dims the head. 10 / 60 / 80 % duty draws 0.17 / 0.80 / 1.42 A at 12.02 V | [`test-light-pwm-ssr.md`](test-light-pwm-ssr.md) |
| **PWM frequency** | **1.3 kHz minimum.** Set by IEEE 1789 and confirmed by operator exposure — 200 Hz produced headache within 10 s on the bench | [`safety-flicker-exposure.md`](safety-flicker-exposure.md) |
| **Rev A cannot do it** | `SLG59H1128V` minimum rise time is 336 – 546 µs with its slew capacitor removed. No value of C25 is fast enough, so **the driver must be replaced** | [`test-load-switch-rev-a.md`](test-load-switch-rev-a.md) |
| **Replacement** | One [`TPS1200-Q1`](https://www.digikey.com/en/products/detail/texas-instruments/TPS12000QDGXRQ1/25881327) driving one [`TPH1R306P1`](https://www.digikey.com/en/products/detail/toshiba-semiconductor-and-storage/TPH1R306P1-L1Q/10447088) for all six channels, 2 mΩ shunt | [`analysis-driver.md`](analysis-driver.md) |
| **Channel protection** | **One PTC per channel** — [`2920L500/16MR`](https://www.digikey.com/en/products/detail/littelfuse-inc/2920L500-16MR/3997238), 5 A hold against a 4 A channel maximum. A short at a light head draws **33 A**, and the PTC limits that channel locally so the other five stay lit | [`analysis-driver-switching.md`](analysis-driver-switching.md) |
| **Edge rate** | **5 – 7.7 µs.** Above 7.7 µs the 10 % minimum duty cannot be held. The 5 µs lower bound is a working target, not a limit — a 5 µs edge costs 3.7 dB against 8.9 dB of filtered margin | [`analysis-emi-budget.md`](analysis-emi-budget.md) |
| **Emissions** | A `1 µH + 12 µF` box-input filter is required. **8.9 dB margin**, the smallest margin in the study | [`analysis-emi-budget.md`](analysis-emi-budget.md) |
| **Night trigger** | Whelen `LCPHOTO`, fixed 50 lux, read through the board's existing optocoupler | [`analysis-night-detect.md`](analysis-night-detect.md) |
| **Cost in pins** | **Zero.** GP13 changes function, GP14 is reused | §3 |

**The lights are enabled by the power amplifier's ignition signal.** They cannot be operated
while the amplifier is off. This follows from the enable source in §3, and it is a product
behaviour rather than only a wiring detail.

**Certification does not constrain this.** The NP6BB is a scene light with no SAE Class 1
rating, so reducing its output raises no compliance question. Dimming a *warning* head is a
different problem with a different solution, archived in
[`archive-t-series-lights.md`](archive-t-series-lights.md).

---


