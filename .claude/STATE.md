# eidolon — Work State
_Last updated: 2026-06-26_

## Done
- **Found + fixed the fatal root cause:** `pcb/footprints/xiao_ble.js` right column was reversed
  (5V/GND/3V3 ↔ R2/R3/D7-D9). Corrected + verified vs datasheet + DRC. Fixes BOTH halves.
- **Committed to `main` and pushed to origin** (7 commits ahead landed): `79fd69e` pcb pinout fix +
  removed stale gerbers (`git rm`); `99391d8` case resin-sample fit fixes; `ce14379` claude state.
- Regenerated ergogen output (`pcb/output/pcbs/eidolon_{left,right}.kicad_pcb`) has correct nets.
- Saved 2 memories: `pcb-routing-aesthetic`, `routing-faithfulness-standard`.

## In flight (updated 2026-06-27, session 3 — per-half pin maps)
- **Per-half pin assignment to declutter the right** (user-driven). Each half is an independent
  wireless unit, so the net→pin maps need not match. Right half now has its OWN `params` in
  `pcb/eidolon.yaml` (not the shared `&mcu_params`): all 4 rows on the matrix-facing edge
  (D7:R3 D8:R2 D9:R1 D10:R0, nested), columns on D0–D4. Left keeps R0/R1 on D5/D6.
- **Why:** with a cloned MCU each pin faces the matrix on one half / away on the other, so every
  matrix net crosses the MCU on exactly one half (total invariant = 9). Right's matrix-facing edge
  has only 4 GPIO → floor of 5 crossings there. Independent maps let the right hit that floor (only
  the 5 columns cross) while the left stays at 2 — R0/R1's old "west-about" boxed routes are gone.
- **Router:** `route_boxed_rows` partitions boxed-vs-near by matrix proximity (returns [] when all
  rows are matrix-facing); `route_near_rows` e<0 fans all 4 right rows nested into their diodes
  (south-side pad-2 entry; one B.Cu hop for R0's long top-row traverse over the home-row link).
- **FIRMWARE: the two halves now need DIFFERENT `MATRIX_ROW_PINS`** (left rows D5–D8, right D7–D10).
- Committed: phantom-router `0505490`; D7↔D8 swap `1fe5a42`/`04269a6` earlier. Both halves 0 DRC / 0
  unconnected. Boards re-landed into `pcb/` + gerbers re-exported.

## In flight (updated 2026-06-27, session 2)
- **BOTH HALVES ROUTED: 0 DRC violations, 0 unconnected, faithful.** Committed in
  `~/git/phantom-router` (now a git repo): `1fe5a42` (re-route + left done + right to 2),
  `04269a6` (right access-pad jumper through the neck → right to 0). `routed_{left,right}.kicad_pcb`
  are the clean boards.
- **FAB-PREP DONE:** landed `routed_{left,right}.kicad_pcb` → `pcb/eidolon_{left,right}.kicad_pcb`
  (final DRC 0/0 in place), re-exported `pcb/eidolon_{left,right}_gerbers.zip` (all layers +
  Excellon drill via kicad-cli). Both committed to eidolon. **Fab-ready.**

### How each half was resolved (faithful, minimal vias)
- **LEFT half: DONE — 0 DRC, 0 unconnected, faithful.** Reverted keepout to whole-module
  (`extract.add_gnd_pours`); restored explicit B.Cu margin GND rail (battery→south-margin→rise
  INBOARD of east column at `outer.x-2.6` to clear the 2.75mm-wide pads→jog into pad13→F.Cu jumper
  to access pad) in `river.route_power`. Re-derived R2 to cross the rail on F.Cu (stays F.Cu past
  R3's B.Cu drop so their unavoidable mutual crossing is F/B, not a short; then vias to B.Cu to duck
  the near column) and stopped R3 dipping south over R2 (`route_boxed_rows`, e>0 branch). R2 = 2 vias
  (rail crossing forces +1 over the spine via). `routed_left.kicad_pcb` regenerated + DRC-clean.
- **RIGHT half: 3 DRC violations, 0 unconnected** (down from 7). RESOLVED faithfully this session:
  - Lane rule: GND always INNER, RAW always OUTER (`raw_outer=True`) — GND peels into the MCU without
    crossing RAW along the margin. `rise_x = outer.x + ib*2.4` (ib toward inner pad, NOT e-scaled) —
    threads the ~0.5mm gap between the column-pad west edge (118.77) and the C4 lane (117.63). Fixed
    the C4 clearance + the thumb-S15 short.
  - **GND↔RAW crossing is TOPOLOGICALLY UNAVOIDABLE on the right** (proven: forcing GND-inner only
    MOVES the short to the battery end). DECIDED (user: "decide faithfully"): relocate it to the open
    battery end and cross on F.Cu — GND leaves its TH battery pad on F.Cu, vias to B.Cu just past RAW
    toward the MCU. ONE via, right half only (gated on `raw_between`; left untouched). Documented as a
    mirrored-half exception to the brief's "power bundle: no vias" — needs adding to decision 001.
- **Right half REMAINING (3 violations) — congested under-MCU neck, needs coordinated rework + render:**
  1+2. F.Cu GND jumper (pad13→access pad) crosses R0/R1 — on the right R0/R1 are the BOXED rows
     (`_route_boxed_rows_right`), diving on F.Cu at x≈117.35/117.95. Tried B.Cu jumper: WORSE (9) —
     the neck at x≈117.6 is occupied on BOTH layers (R0/R1 F.Cu dives + C1–C4 B.Cu column lanes), so
     the access GND pad is walled off. Needs rerouting the access-pad connection (around the column
     river / through the SWD-keepout gap) or shifting R0/R1 dive_x — coordinated, render-driven.
  3. R2/R3 (NEAR rows on the right, → D7/D15) short each other on F.Cu near (125,-8..2), east of the
     MCU. In `route_near_rows`/row-spine — not yet investigated; likely independently fixable.
- Decision 001 + memory `routing-faithfulness-standard` govern: match design values, minimal vias.

## In flight (original)
- **Re-routing the MCU fan-out in `~/git/phantom-router`** (separate repo) for the corrected pinout.
  `river.py` + `extract.py` have UNCOMMITTED, partially-reverted, NON-faithful interim changes.
- **User course-corrected → redo FAITHFULLY** (decision 001 + memory `routing-faithfulness-standard`):
  revert the antenna-keepout shrink back to whole-module keepout; restore explicit hand-shaped GND
  rails (battery→margin→MCU GND pad→F.Cu jumper); drive vias to minimal; arc-shape every path; redo
  BOTH halves (incl. the left, which currently uses shortcuts). User confirmed: whole-module keepout.
- Genuine new constraint: corrected pinout puts R2/R3 at the stack's SOUTH end, between battery(south)
  and GND pad(north) — choreograph so R2/R3 cross the B.Cu GND rail on F.Cu via spine-vias they
  already need (0 extra vias).
- **NOT fab-ready:** committed `pcb/eidolon_{left,right}.kicad_pcb` are STILL the OLD BUGGY routed
  boards; gerbers are now removed. Don't fab until re-routed + re-exported.
- Note: this STATE.md was edited after the last commit — it's an uncommitted change now.

## Next
1. `~/git/phantom-router`: revert `extract.add_gnd_pours` keepout to whole-module; restore explicit
   GND rails in `river.py route_power`.
2. Re-derive R2/R3 (+ R0/R1 on the right via `_route_boxed_rows_right`) faithfully, minimal vias, arcs.
3. Re-route both to 0 DRC: `cd ~/git/phantom-router && python3 -m router.cli
   /home/jonny/git/eidolon/pcb/output/pcbs/eidolon_left.kicad_pcb -o routed_left.kicad_pcb --render
   check_left.png` then `kicad-cli pcb drc --severity-error routed_left.kicad_pcb` (same for right).
4. Land routed boards into `pcb/eidolon_{left,right}.kicad_pcb`; re-export gerbers; final DRC; commit.

## References
- Related decisions: .claude/decisions/001-xiao-pinout-fix-and-routing-faithfulness.md
- Router repo: ~/git/phantom-router (river.py = fan-out; extract.py = GND pours/keepout)
- Push note: SSH keys absent here; pushed via `gh` HTTPS credential helper. Normal `git push` uses SSH.
