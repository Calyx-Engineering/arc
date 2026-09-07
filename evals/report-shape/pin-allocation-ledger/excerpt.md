## The ledger

| GP | Status | Provenance | Rev A function | Rev B function | Description | Notes |
| --- | --- | --- | --- | --- | --- | --- |
| 13 | claimed | report — PR [#48](https://github.com/Lantern-Systems/roadz-sound-system/pull/48) | `LGHTS_ON` | `LIGHTS_ON` | Static on/off enable becomes **PWM intensity** | Same pin, same direction — the change is the function. See [GP13 — the PWM change](#gp13--the-pwm-change) |
| 14 | claimed | report — PR [#48](https://github.com/Lantern-Systems/roadz-sound-system/pull/48) | `LGHTS_nFAULT` | `nDUSK_DETECT` | Light fault in, replaced by night detect from the Whelen `LCPHOTO`, active low | Fault line **deleted**, not moved. 2.7 kΩ pull-up to **always-on** 3V3 — it must read daylight before the switched rail is up. A swap, not a free. Firmware still calls this pin `lights_fault` |
| 16 | claimed | datasheet, p8/p16/p20 · firmware | `PND_LTC.CTRL` | **`nHARD_KILL`** | LTC4331 `CTRL` out, replaced by the hard-kill assert | **`U4.CTRL` is left unconnected — confirmed 2026-08-26 from the datasheet.** We are the local side; `CONFIG.CTRL_SEL = 1` makes the LTC4331 ignore the local pin entirely and drive the remote `CTRL` from `CTRL.SW_CTRL` (`07h`) over the link. Nothing uses the function today, and a firmware implementation would reach for the register anyway. The freed pin takes the one signal rev B adds. **Pin choice provisional** — GP18 and GP20 are equivalent alternatives |
| 18 | **available** | drawing — [#8](https://github.com/Lantern-Systems/roadz-sound-system/issues/8), reviewed | `PND.PWR_EN` | — | Pendant 5V load switch | Pendant power follows ignition in rev B. [#9](https://github.com/Lantern-Systems/roadz-sound-system/issues/9) closed won't-do |
| 19 | claimed | thread [#24](https://github.com/Lantern-Systems/roadz-sound-system/issues/24) · drawing [#8](https://github.com/Lantern-Systems/roadz-sound-system/issues/8) | `5V_EN` | `WAKE_EN` | **Wakes the processing system. Active high** | Absorbs `3V3_D2_EN`; one pin now gates both rails — Pi, cellular, accessory rail. Feeds `SYS_EN` alongside `nHARD_KILL` |
| 20 | **available** | firmware | `RTC_CLK` | — | RV-3028 `CLKOUT` | Nothing has ever read it. Also disable CLKOUT in firmware — it free-runs at 32.768 kHz for no consumer |
| 22 | claimed | thread — [#24](https://github.com/Lantern-Systems/roadz-sound-system/issues/24) | `3V3_D2_EN` | `IGNTN_OUT` | Ignition-derived enable out of the RP2040 | **Not amp-only** — several downstream devices may be driven from it. ~2 A on the amp leg |

**Balance: 25 allocated, 2 spare — GP18 and GP20.** `nHARD_KILL` is the only signal rev B
adds, and it takes GP16. **All 36 open issues were re-swept 2026-08-25** and none adds another;
[#38](https://github.com/Lantern-Systems/roadz-sound-system/issues/38)'s accessory rail and [#35](https://github.com/Lantern-Systems/roadz-sound-system/issues/35)'s Pi power-down both resolve to the existing `WAKE_EN` on GP19.

**The I²C expander is no longer needed.** That reverses the study's earlier conclusion, and
two decisions did it: [#12](https://github.com/Lantern-Systems/roadz-sound-system/issues/12)'s SSR is ignition-driven, so it commands nothing; and its
current sense reads over I²C on the existing bus, so it takes no ADC pin. Nothing is left that
an expander would carry.

---


