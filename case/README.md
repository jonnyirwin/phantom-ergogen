# Eidolon Case

> **Warning: the changes listed below have not yet been physically verified. Print and test before ordering in quantity.**

## Changes from original design

### Bottom shell — thicker floor (`floor_t` 2.0 → 2.8mm)

The original 2.0mm floor left only 0.2mm of material above the M2 hex nut pockets. This is both unprintable (JLC flags it) and structurally unsound — the nut bears against that ceiling when the bolt is tightened, and 0.2mm would fail immediately. Increasing to 2.8mm gives a 1.0mm ceiling above each nut pocket.

The nesting lip (2.10mm) is unchanged, so the top case requires no modification to the cavity or plate geometry. The seam at z=0 remains flush. Total external height increases from 14.5mm to 15.3mm assembled.

### Bottom shell — bumpon pockets

Four 8.4mm diameter × 2mm deep pockets added to the bottom face for standard 8mm rubber bumpons. Positions (KiCad coords):

| Location | Position |
|---|---|
| Upper-right (MCU corner) | [141, 38] |
| Lower-right (thumb cluster) | [125, 91] |
| Upper-left | [50, 28] |
| Lower-left | [52, 84] |

All positions have ≥7.5mm clearance from nut pocket edges. The 2mm pocket depth leaves 0.8mm of floor material below.

### Top shell — deeper bolt head pockets (`m2_head_h` 2.0 → 3.3mm)

With the deeper floor, an M2×12 bolt (the correct length for the original design) would only engage 0.5mm of thread — barely one turn. Sinking the bolt head 1.3mm further into the deck (head now recessed below the deck surface rather than flush) restores full thread engagement:

- Bolt tip sits exactly flush with the case bottom face
- 1.8mm of thread engagement (full nut height)
- M2×12 socket cap bolts required

No other top case geometry is affected.

## Remaining known issues (unresolved)

- `plate_t16 = 0.75mm` — the thin switch plate counterbore section under each switch hole. May be flagged by JLC depending on print process.
- `lip_t = 0.6mm` — acrylic retention lips on the XIAO cover slot. Thin for FDM; may need increasing if not printing in resin.
