## Confidence


### Verified in primary documents

- Wire functions, +12 V ignition-controlled supply, chassis ground, the VIOLET output
  driving a High/Low Power control wire, and the flange dimensions — [Whelen Form 14B33 (101917)](https://whelen.widen.net/view/pdf/ruq0vidbb4/14B33.pdf),
  full text read
- Trip threshold 50 lux, and the VIOLET output levels — 0 VDC in light, V<sub>in</sub> −
  0.5 V in dark — Whelen `LCPHOTO` specification sheet, attached to
  [#1](https://github.com/Lantern-Systems/roadz-sound-system/issues/1). **Form 14B33 does
  not carry the electrical specification**; it is a separate document
- Whelen High/Low Power inputs are asserted by positive voltage — `ULF44` Form 14103B,
  quoted in [`reference-whelen-flasher-architecture.md`](reference-whelen-flasher-architecture.md) §3
- `LTV-814S-TA1-A`, 1.5 kΩ series and 2.7 kΩ pull-up are the board's existing 12 V input
  interface — `nIGNTN_DETECT`, rev A schematic, and the [Lite-On LTV-8x4 datasheet](https://optoelectronics.liteon.com/upload/download/DS-70-96-0013/LTV-8X4%20series%20201509.pdf)
- The switched `VIN_FILT` rail exists and carries three consumers — the RUT241, retained as
  a fallback should the onboard cellular module not perform, the PoE switch, and this
  sensor. Rail sizing and switching behaviour are
  [#38](https://github.com/Lantern-Systems/roadz-sound-system/issues/38)
- GP26 – GP28 carry I²S and GP29 is not brought out on the Pico module — project schematic
  and RP2040 datasheet §4.9


### Measured

Nothing electrical. The unit in hand was photographed and its label read: `01-026D205-00A`,
which supersedes the `01-066D205-01` cited in #1.


### Not established

| Unknown | What would settle it |
| --- | --- |
| Whether the output holds V<sub>in</sub> − 0.5 V at 7.7 mA, or needs a larger series resistor | Load the output while measuring its voltage |
| Whether 50 lux is a usable trip point at the trailer's real mounting position | Dusk observation against a light meter, at the mounting |
| Hysteresis, and whether the output latches or follows | Sweep the level in both directions and watch the reversal points |
| `LCPHOTO` internal supply current | Meter the RED wire, light and dark |
| Settling interval after its supply comes up | Time the output against rail application |
| Whether it responds to the heads' 1.3 kHz PWM as modulation rather than integrating it | Illuminate it from a dimmed head at several duty values |
