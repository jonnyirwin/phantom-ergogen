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

## Addendum (2026-06-27): mirrored-half via exceptions to "power bundle: no vias"

Re-deriving the fan-out for the corrected pinout exposed crossings the original (old-pinout)
routing never had, because GND moved from the column's south end to pad13 at the north end and
R2/R3 moved to the south. These force a small, bounded number of vias beyond the brief's
"power bundle / boxed rows: no vias" ideal. Accepted as faithful (matches "minimal vias", not
"zero at any cost"); each is local and documented in `river.py`:

- **Left R2** (+1 via): must cross the B.Cu GND rail without shorting, so it crosses on F.Cu
  then vias to B.Cu to duck the near column. Left half is **0 DRC, 0 unconnected** — done.
- **Right GND↔RAW_BATT** (+1 via, right only): the mirrored battery/switch/MCU layout makes one
  GND/RAW crossing *topologically unavoidable* (forcing GND to the inner lane only relocates the
  short). Chosen resolution: put it at the open battery end and cross on F.Cu (GND leaves its TH
  battery pad on F.Cu, vias once to B.Cu past RAW). Gated so the left is untouched.
- **Right R2/R3 near-rows** (pending): destinations are inverted vs pad order (R2→D7 mid, R3→D15
  thumb), forcing one F.Cu/F.Cu crossing — will need the same one-hop-to-B.Cu treatment.
- **Right GND access-pad jumper** (pending): the under-MCU neck at x≈117.6 is occupied on *both*
  layers (R0/R1 F.Cu dives + C1–C4 B.Cu column lanes), walling off the access pad; needs the
  jumper rerouted around the column river or the R0/R1 dives shifted.

Status at addendum time: left half complete; right half 3 DRC violations, 0 unconnected.
