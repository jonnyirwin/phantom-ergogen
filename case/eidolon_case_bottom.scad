// Eidolon case — BOTTOM SHELL.
// Nests inside eidolon_case.scad. Sits below the PCB and pushes it up against
// the top case's plate. Shares outline / switches / bolts / plate_bot with
// the top SCAD via `include` (SUPPRESS_TOP=true skips the top render).
//
//   openscad -o eidolon_case_bottom_left.stl case/eidolon_case_bottom.scad
//
// Geometry (z-up, KiCad y-down — final mirror flips y):
//   z ∈ [-floor_t, 0] : exterior plate, outer = outline + gap + wall, matches
//                       the top case outer so the seam at z=0 is flush.
//   z ∈ [0, lip_h]    : nesting lip, outer = outline + gap - fit_clr, slips
//                       into the top case cavity from below.
//   lip_h = plate_bot - pcb_t = 2.10mm  (PCB underside rest plane).
// Cutouts:
//   - Kailh PG1350 hot-swap socket pockets at each switch — TOTEM silkscreen
//     outline (Z-shape, two bulges). The pockets cut all the way through the
//     lip (z=0 → z=lip_h) so a 1.8mm-tall socket fits, but the exterior
//     plate seals them at the bottom, so the sockets are not visible from
//     outside. Socket bottom ends ~0.3mm above the floor top.
//   - M2 hex-nut pockets in the bottom face at the four corner bolts.
//   - M2 shaft holes through the whole shell.

SUPPRESS_TOP = true;
include <eidolon_case.scad>;

// === bottom-shell dimensions ===
pcb_t           = 1.6;                 // PCB thickness
floor_t         = 2.0;                 // exterior plate below z=0 (2mm min wall)
lip_h           = plate_bot - pcb_t;   // 2.10mm — nesting lip top = PCB underside
fit_clr         = 0.1;                 // lip-to-top-case-cavity slip clearance

// Kailh PG1350 hot-swap socket body outline in switch local frame, traced from
// TOTEM's Kailh_socket_PG1350_optional.kicad_mod silkscreen — a Z-shape with
// two rectangular bulges (one around each SMD pad) connected by curves. Pads
// are at (-3.275, -5.95) and (8.275, -3.75). The polygon hugs the body; a
// small inflation by socket_clr is applied at use to give plastic clearance.
socket_outline = [
    [-2.0,    -4.2  ], [-2.0,    -7.7  ],
    [-1.5,    -8.2  ], [ 1.5,    -8.2  ],
    [ 2.0,    -7.7  ], [ 2.0,    -6.7  ],
    [ 2.1464, -6.3464],                     // arc midpoint (lower inner corner)
    [ 2.5,    -6.2  ], [ 7.0,    -6.2  ],
    [ 7.0,    -1.5  ], [ 2.5,    -1.5  ],
    [ 2.5,    -2.2  ],
    [ 2.0607, -3.2607],                     // arc midpoint (upper inner corner)
    [ 1.0,    -3.7  ], [-1.5,    -3.7  ]
];
socket_clr = 0.6;  // inflate the outline by this much for socket plastic+metal slop

// M2 hex nut: 4.0mm across flats. Hex circumradius = 4/√3 ≈ 2.31, plus slack.
m2_nut_af = 4.0;
m2_nut_h  = 1.8;   // nut thickness; pocket depth from the bottom face upward

module bottom_body()
    union() {
        translate([0, 0, -floor_t])
            linear_extrude(floor_t)
                offset(r = gap + wall) polygon(outline);
        linear_extrude(lip_h)
            offset(r = gap - fit_clr) polygon(outline);
    }

// === clearance pockets cut into the lip (z = 0 .. lip_h) ===
// All of the below pierce the full lip height so parts protruding below the PCB
// fit; the exterior floor seals the cuts from outside. Straight (no chamfer) —
// the fit is set by clearance alone.

// Hot-swap socket pocket footprint: the hand-traced plastic body PLUS the two
// metal SMD solder tabs (2.6mm sq at the pad centres), which overhang the plastic
// by ~2.6mm at each end and previously had no clearance. socket_clr inflates it.
// The sockets do NOT mirror on the right-half PCB, but the footprint is chiral, so
// for the right build the profile is mirrored LOCALLY and the global mirror([1,0,0])
// cancels it — leaving the pocket in the physical socket's chirality.
sock_pad_d = 2.6;
sock_pads  = [[-3.275, -5.95], [8.275, -3.75]];
module socket_full() {
    polygon(socket_outline);
    for (p = sock_pads) translate(p) square(sock_pad_d, center = true);
}
module socket_2d() {
    if (right) mirror([1, 0]) offset(r = socket_clr) socket_full();
    else                      offset(r = socket_clr) socket_full();
}
module socket_pockets()
    for (s = switches)
        translate([s[0], s[1], 0])
            rotate([0, 0, -s[2]])
                linear_extrude(lip_h + 0.02) socket_2d();

// Choc v1 plastic protrusions poking below the PCB: central pole + two locating
// legs, on the switch y=0 axis. (The electrical pin holes sit inside the socket
// pocket already, so only these three plastic features need clearing.)
pole_d = 4.0;   // central pole Ø3.429 + clearance
leg_d  = 2.4;   // locating legs Ø1.702 + clearance
module switch_pins_2d() {
    circle(d = pole_d, $fn = 64);
    translate([ 5.5, 0]) circle(d = leg_d, $fn = 48);
    translate([-5.5, 0]) circle(d = leg_d, $fn = 48);
}
module switch_pin_pockets()
    for (s = switches)
        translate([s[0], s[1], 0])
            rotate([0, 0, -s[2]])
                linear_extrude(lip_h + 0.02) switch_pins_2d();

// MSK-12D19 trimmed-leg clearance: the 3 through-hole legs (2.5mm pitch along y)
// protrude below the PCB into the lip. Rounded slot at sw_pos; the global mirror
// handles the right build, as with power_slot().
module power_legs_2d()
    offset(r = 1.0) square([0.5, 5.5], center = true);   // -> 2.5 x 7.5 rounded
module power_leg_pockets()
    translate([sw_pos[0], sw_pos[1], 0])
        linear_extrude(lip_h + 0.02) power_legs_2d();

// XIAO underside solder-joint clearance: shallow recess in the lip top under the
// XIAO so the castellation fillets and the BAT/GND access-hole joints (soldered up
// through the PCB) don't bear on the solid lip. Leaves ~0.9mm of lip below.
xiao_uj_depth = 1.2;
module xiao_underside_pocket()
    translate([xiao_pos[0], xiao_pos[1], lip_h - xiao_uj_depth])
        rotate([0, 0, -xiao_rot])
            linear_extrude(xiao_uj_depth + 0.02)
                square([xiao_w + 1, xiao_l + 1], center = true);

// Hex nut pockets in the bottom face (z = -floor_t), m2_nut_h deep upward.
module nut_pockets()
    for (b = bolts)
        translate([b[0], b[1], -floor_t - 0.01])
            linear_extrude(m2_nut_h + 0.01)
                circle(r = m2_nut_af / sqrt(3) + 0.07, $fn = 6);

// Bolt shaft holes — all the way through so the bolt can engage the nut.
module bolt_shafts()
    for (b = bolts)
        translate([b[0], b[1], -floor_t - 1])
            linear_extrude(lip_h + floor_t + 2)
                circle(d = m2_shaft_d, $fn = 96);

// Bumpon (rubber foot) pockets — 8.4mm dia, on the bottom face.
// Same depth as the nut pockets (m2_nut_h), leaving 0.2mm of floor below.
bumpon_d     = 8.4;
bumpon_depth = m2_nut_h;
bumpons = [
    [141,  38],   // upper-right — MCU corner
    [125,  91],   // lower-right — thumb cluster corner
    [ 50,  28],   // upper-left  — 7.7mm from TL bolt, 9.5mm from top wall
    [ 52,  84],   // lower-left  — 7.5mm from BL bolt, 15mm from left wall
];

module bumpon_pockets()
    for (b = bumpons)
        translate([b[0], b[1], -floor_t - 0.01])
            linear_extrude(bumpon_depth + 0.01)
                circle(d = bumpon_d, $fn = 96);

module bottom_case()
    mirror([0, 1, 0])
        difference() {
            bottom_body();
            socket_pockets();
            switch_pin_pockets();
            power_leg_pockets();
            xiao_underside_pocket();
            nut_pockets();
            bolt_shafts();
            bumpon_pockets();
        }

// Preview: render top + bottom together for fit check. EXPLODED > 0 lifts the
// top by that many mm; 0 = fully assembled. `right` (from the included top
// SCAD, or -D right=true) mirrors the build for the right half:
//   openscad -D right=true -o eidolon_case_bottom_right.stl case/eidolon_case_bottom.scad
PREVIEW  = false;
EXPLODED = 6;

module bottom_build() {
    if (PREVIEW) {
        bottom_case();
        translate([0, 0, EXPLODED]) top_case();
    } else {
        bottom_case();
    }
}

if (right) mirror([1, 0, 0]) bottom_build();
else bottom_build();
