---
date: 2026-06-26
status: accepted
---

# XIAO pinout fix + faithful re-route of the MCU fan-out

## Decision

The `pcb/footprints/xiao_ble.js` **right castellated column was reversed** end-for-end.
Physically: top→bottom should be `5V, GND, 3V3, D10, D9, D8(R3), D7(R2)`; the footprint
had `D7, D8, D9, D10, 3V3, GND, 5V`. Consequence on the (buggy) committed boards: VBUS-5V
landed on the R2 matrix row, GND on R3, and real GPIOs D7/D8/D9 were tied to 5V/GND/3V3 —
dead matrix rows + an over-voltage path that can kill the nRF52840 on USB power. **Both
halves identical** (the right MCU is `asym: clone`d un-mirrored), so the single footprint
edit fixes both. Fix applied and verified (datasheet-confirmed pinout + internal adjacency
consistency + KiCad DRC clean on the regenerated netlist).

The routed boards must be regenerated. The routing is produced by the **`~/git/phantom-router`**
autorouter (a separate repo); re-running it on the corrected ergogen output gives correct
nets but the MCU fan-out (`river.py` boxed-rows + power) was hand-tuned to the *old* pad
positions, so it must be re-derived.

**Chosen routing standard (after a course-correction):** re-derive the fan-out **faithfully**
to the original's design decisions, NOT with correctness-driven shortcuts. Keep the
whole-module GND keepout, explicit hand-shaped GND rails, minimal vias, arc-cornered curves.

## Why

- The pinout error is fatal and not firmware-fixable; power/GND on GPIOs risks hardware damage.
- The user prioritises matching the original routing's design decisions and visual aesthetic
  with high attention to detail (see memory `routing-faithfulness-standard`). The interim
  fixes (antenna-keepout shrink, an added "hop" via, jumper+pour grounding) were lower-quality
  than the original and are to be redone.

## Alternatives rejected

- **Hand-patch the committed routed boards' copper directly** — rejected: would not match the
  curved aesthetic and is error-prone; the router is the source of the look.
- **Pour-grounding via a shrunk antenna-only keepout** (implemented on the left, 0 DRC) —
  rejected as the final approach: deviates from the original's whole-module keepout decision
  and trades BLE conservatism for routing ease. Kept only as a fallback idea.
- **Unify both halves through one e-scaled fan-out** — rejected: the mirror reassigns which
  rows sit on which stack (R2/R3 are *boxed* on the left but *near* on the right), so the
  halves genuinely need separate handling.
