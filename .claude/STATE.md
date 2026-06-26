# eidolon — Work State
_Last updated: 2026-06-26_

## Done
- **Found + fixed the fatal root cause:** `pcb/footprints/xiao_ble.js` right column was reversed
  (5V/GND/3V3 ↔ R2/R3/etc). Edited to correct order; verified vs datasheet + DRC. Fixes BOTH halves.
- Regenerated ergogen output (`pcb/output/pcbs/eidolon_{left,right}.kicad_pcb`) — correct nets confirmed.
- Saved 2 memories: `pcb-routing-aesthetic`, `routing-faithfulness-standard`.

## In flight
- **Re-routing the MCU fan-out in `~/git/phantom-router`** (separate repo) for the corrected pinout.
  `river.py` + `extract.py` have UNCOMMITTED, partially-reverted changes — currently a mix of the
  interim (non-faithful) approach. Left reached 0 DRC but via shortcuts; right at 3 violations + 1
  unconnected.
- **User course-corrected:** redo it FAITHFULLY (see decision 001 + memory). Revert the antenna-keepout
  shrink → whole-module keepout; restore explicit hand-shaped GND rails (battery→margin→MCU GND pad→
  F.Cu jumper); drive vias to minimal; arc-shape every path; redo BOTH halves (incl. the left).
- Open Q answered: user wants whole-module keepout. Genuine new constraint: corrected pinout puts
  R2/R3 at the SOUTH end of the stack, between battery(south) and GND pad(north) — GND rail must be
  choreographed so R2/R3 cross it on F.Cu via spine-vias they already need (0 extra vias).
- **NOT YET DONE:** the committed `pcb/eidolon_{left,right}.kicad_pcb` + `*_gerbers.zip` are STILL the
  OLD BUGGY boards. Do not fab. Routed output not yet landed into the eidolon repo.

## Next
1. In `~/git/phantom-router`: revert `extract.add_gnd_pours` keepout to whole-module (was ANT_Y strip);
   restore explicit GND rails in `river.py route_power`.
2. Re-derive R2/R3 (and R0/R1 on the right via `_route_boxed_rows_right`) faithfully, minimal vias.
3. Re-route both halves to 0 DRC; verify with: `cd ~/git/phantom-router && python3 -m router.cli
   /home/jonny/git/eidolon/pcb/output/pcbs/eidolon_left.kicad_pcb -o routed_left.kicad_pcb --render
   check_left.png` then `kicad-cli pcb drc --severity-error routed_left.kicad_pcb`.
4. Land routed boards into `pcb/eidolon_{left,right}.kicad_pcb`; re-export both gerbers; final DRC + pad-net check.

## References
- Related decisions: .claude/decisions/001-xiao-pinout-fix-and-routing-faithfulness.md
- Router repo: ~/git/phantom-router (river.py = fan-out; extract.py = GND pours/keepout)
- STATE.md is untracked + not gitignored — your call whether to commit or ignore it.
