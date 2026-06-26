# Eidolon Case

> **Warning: the changes listed below have not yet been physically verified. Print and test before ordering in quantity.**

## Changes from original design

### Bottom shell — bumpon pockets

Four 8.4mm diameter × 1.8mm deep pockets added to the bottom face for standard 8mm rubber bumpons. Positions (KiCad coords):

| Location | Position |
|---|---|
| Upper-right (MCU corner) | [141, 38] |
| Lower-right (thumb cluster) | [125, 91] |
| Upper-left | [50, 28] |
| Lower-left | [52, 84] |

All positions have ≥7.5mm clearance from nut pocket edges. The pocket depth matches the nut pockets (`m2_nut_h` = 1.8mm), leaving 0.2mm of floor material below (`floor_t` = 2.0mm).

### Reverted: thicker floor / deeper bolt-head pockets

An earlier revision raised `floor_t` 2.0 → 2.8mm (and `m2_head_h` 2.0 → 3.3mm to keep an M2×12 bolt flush) over a JLC thin-wall flag on the 0.2mm ceiling above the nut pockets. A resin-printed sample showed the thin walls print fine, so both values are reverted to the original design. The bottom floor is back to 2.0mm and M2 bolt heads sit flush with the deck.

## Fit fixes from the resin sample

A resin-printed sample confirmed the top-case switch recesses, M2 bolt recesses/holes
and PCB fit are all good. The following mating features were too tight or missing
clearance and have been corrected (case geometry only — the PCB is unchanged). All
new clearances are biased generous for easy, no-force assembly.

### Bottom shell

- **Hot-swap socket pockets** — the pocket was traced from the socket's *plastic*
  silkscreen only; the two metal SMD solder tabs overhang it by ~2.6mm at each end
  and had no clearance (the socket wouldn't seat). The pocket now cuts the plastic
  body **plus** both pad rectangles, and `socket_clr` is 0.3 → **0.6mm**.
- **Choc v1 plastic-pin pockets** (`switch_pin_pockets`) — new clearance for the
  central pole (Ø4.0) and two locating legs (Ø2.4) that poke below the PCB into the
  lip; previously absent.
- **Power-switch leg pockets** (`power_leg_pockets`) — new clearance slot for the
  three trimmed/soldered through-hole legs below the PCB.
- **XIAO underside-joint pocket** (`xiao_underside_pocket`) — shallow 1.2mm recess
  in the lip under the XIAO so its castellation fillets and the BAT/GND access-hole
  solder joints don't bear on the solid lip.

### Top shell

- **XIAO cavity** — was `20.0 × 17.5mm`, *smaller than the 21.0 × 17.78mm board*.
  Now board size + `xiao_clr` 0.4 → **0.6mm**/side (≈ 19.0 × 22.2mm window).
- **USB-C cutout** — was tight; now **+1.5mm wide** (9.0 → 10.5) and **+1.5mm tall**
  (4.0 → 5.5). Bottom edge unchanged, so the lip below stays ~1.75mm.
- **Power-switch body** — the visible rounded slot in the wall is unchanged (8 × 4mm).
  The switch body (just over 9mm wide, overhanging the PCB edge ~0.5mm) wouldn't fit,
  so a separate internal `power_body_pocket` (11mm) clears it; it reaches into the
  wall for the overhang and **merges with the XIAO cavity** (no dividing wall — the
  body and XIAO drop into one continuous opening, which also eases insertion). The
  body sits below the acrylic rebate, so the cover's top retention lip is preserved.

### Assembly notes (no case change)

- **XIAO** mounts flush on the PCB top via **castellated edge half-holes** (solder at
  the board edge, no under-board reflow). Its underside **BAT+/BAT− pads must be
  soldered up through the PCB access holes** beneath them — this completes the
  battery/charge path (the copper routing to the switch and battery pads is already
  present).
- **Battery**: solder the LiPo leads to the two battery pads (+ = RAW_BATT,
  − = GND, 5mm pitch). No jumper to the XIAO is needed.

## Remaining known issues (unresolved)

- `plate_t16 = 0.75mm` — the thin switch plate counterbore section under each switch hole. May be flagged by JLC depending on print process.
- `lip_t = 0.6mm` — acrylic retention lips on the XIAO cover slot. Thin for FDM; may need increasing if not printing in resin.
