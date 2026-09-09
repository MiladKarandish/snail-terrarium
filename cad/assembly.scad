// ─────────────────────────────────────────────────────────────
//  ASSEMBLY — for looking at, not for printing.
//
//  Everything here is driven from params.scad and mister.scad, so
//  it cannot drift away from the parts that actually get printed:
//  change a dimension and this picture changes with it.
//
//  The bought parts are modelled from their own documentation --
//  the mist module from MIST-MAKER.md §4, the bottle as a standard
//  0.5 L PET finish -- so the fits you see are the real fits.
//
//    EXPLODE  0 = assembled, 1 = fully apart
//    SECTION  1 = cut the near half away
//    BOTTLE   0 = leave the reservoir off (it is 190 mm of the height)
//
//  Renders:
//    openscad -o out.png --imgsize=1200,1600 --camera=... assembly.scad
// ─────────────────────────────────────────────────────────────
include <params.scad>
use <mister.scad>

EXPLODE = 0;     // 0 .. 1
SECTION = 0;
BOTTLE  = 1;
$fa = 3; $fs = 0.6;

E = EXPLODE;

// ── colours ──────────────────────────────────────────────────
PRINTED  = "#4a7ebb";      // PETG
PRINTED2 = "#6f9ad3";
POTTING  = "#2c2c30";      // the module's black epoxy
CERAMIC  = "#d8d2c0";
METAL    = "#b8bcc4";
PET      = [0.80, 0.88, 0.92, 0.35];
WATER    = [0.25, 0.62, 0.85, 0.45];
RUBBER   = "#3a3a3a";
FANBODY  = "#35383d";

// ─────────────────────────────────────────────────────────────
//  BOUGHT PARTS
// ─────────────────────────────────────────────────────────────

// Mist module, per MIST-MAKER.md §4: Ø45 x 45, a 25 mm potted base
// carrying a 20 mm splash collar, with the Ø20 ceramic disc
// recessed in the well 22 mm above the base and the conductivity
// probe standing beside it.
mm_base_h    = 25;
mm_collar_d  = 30;
mm_well_d    = 22;
mm_disc_z    = 22;

module mist_module() {
    color(POTTING) {
        difference() {
            union() {
                cylinder(d = mm_module_od, h = mm_base_h);
                translate([0, 0, mm_base_h - eps])
                    cylinder(d = mm_collar_d, h = mm_module_h - mm_base_h + eps);
            }
            translate([0, 0, mm_disc_z])
                cylinder(d = mm_well_d, h = mm_module_h);
        }
        // strain relief where the cable leaves the side
        translate([mm_module_od/2 - 3, 0, 7]) rotate([0, 90, 0])
            cylinder(d1 = 9, d2 = 5.5, h = 7);
    }
    color(CERAMIC) translate([0, 0, mm_disc_z - 0.9])
        cylinder(d = 20, h = 1.0);
    color(METAL)   translate([7.5, 0, mm_disc_z])
        cylinder(d = 1.6, h = 16);            // conductivity probe
}

// 1.4 m of UL2464, Ø3.8. Drawn as the run it actually takes: out of
// the module, up the inside of the chamber and out through the lid.
module cable() {
    pts = [[mm_module_od/2 + 3, 0, ch_floor + 7],
           [ch_id/2 - 4,        0, ch_floor + 9],
           [ch_id/2 - 4,        2, ch_floor + 34],
           [-cable_hole_r + 3,  1, ch_h - 16],
           [-cable_hole_r,      0, ch_h + lid_t + 4],
           [-cable_hole_r,      0, ch_h + lid_t + 26]];
    color(RUBBER) for (i = [0 : len(pts) - 2])
        hull() {
            translate(pts[i])     sphere(d = mm_cable_od);
            translate(pts[i + 1]) sphere(d = mm_cable_od);
        }
}

// The conical bung the cable ships with, seated in the lid's
// countersink. This is why the cable leaves through the lid.
module bung() {
    color(RUBBER) difference() {
        union() {
            cylinder(d1 = bung_d_min, d2 = bung_d_max, h = 6);
            translate([0, 0, 6 - eps]) cylinder(d = 8, h = 3);
        }
        translate([0, 0, -eps]) cylinder(d = mm_cable_od, h = 12);
    }
}

// Standard PET cap, captured in the socket and drilled through.
// It sits closed-face DOWN on the pocket floor, threads up, so the
// bottle's own liner does the sealing.
module bottle_cap() {
    color("#2f6f3f") difference() {
        cylinder(d = cap_od, h = cap_h);
        translate([0, 0, 2]) cylinder(d = cap_od - 3.6, h = cap_h);
        translate([0, 0, -eps]) cylinder(d = 10, h = 4);   // the hole you drill
        for (i = [0 : 59]) rotate([0, 0, i*6])             // knurl
            translate([cap_od/2, 0, -eps]) cylinder(d = 0.8, h = cap_h + 2*eps);
    }
}

// 0.5 L PET bottle, inverted. Neck finish, support ring, shoulder,
// body. Its mouth seats inside the captured cap.
module bottle() {
    body_h = bottle_ml * 1000 / (PI/4 * bottle_body_d*bottle_body_d);
    color(PET) {
        cylinder(d = 27, h = 17);                        // threaded neck
        translate([0, 0, 17]) cylinder(d = 33, h = 2.5); // support ring
        translate([0, 0, 19.5]) cylinder(d = 25, h = 4.5);
        translate([0, 0, 24])
            cylinder(d1 = 25, d2 = bottle_body_d, h = bottle_shoulder);
        translate([0, 0, 24 + bottle_shoulder])
            cylinder(d = bottle_body_d, h = body_h);
        translate([0, 0, 24 + bottle_shoulder + body_h - eps])
            cylinder(d1 = bottle_body_d, d2 = bottle_body_d - 14, h = 7);
    }
}

// 40 mm fan, blowing INTO the chamber.
module fan40() {
    color(FANBODY) difference() {
        hull() for (x = [-1, 1], y = [-1, 1])
            translate([x*16, y*16, 0]) cylinder(r = 4, h = 10);
        translate([0, 0, -eps]) cylinder(d = 38, h = 10 + 2*eps);
        for (x = [-1, 1], y = [-1, 1])
            translate([x*fan_pitch_40/2, y*fan_pitch_40/2, -eps])
                cylinder(d = 3.4, h = 12);
    }
    color("#22242a") {
        cylinder(d = 15, h = 9);
        for (i = [0 : 6]) rotate([0, 0, i*360/7])
            translate([0, 0, 2]) rotate([12, 0, 0])
                translate([6, 0, 0]) cube([12, 1.2, 5], center = true);
    }
}

module m3_screw(len) {
    color(METAL) {
        cylinder(d = 3, h = len);
        translate([0, 0, len - 2.4]) cylinder(d = 5.5, h = 2.4);
    }
}

// Ø25 ID fog hose, swept along the path it really takes: off the
// 45° nozzle, over, and DOWNHILL to the tank so condensate drains
// forward instead of back into the chamber.
module hose() {
    a  = nozzle_tilt;
    s0 = ch_od/2/cos(a) + nozzle_len - 3;      // distance ALONG the tilted axis
    p0 = [0, s0*cos(a), nozzle_axis_z + s0*sin(a)];
    // a few control points, then resampled so the hull chain is smooth
    k   = [[0,0], [8,8], [18,14], [30,17], [42,16], [54,10], [64,0], [72,-14],
           [78,-30]];
    pts = [for (i = [0 : len(k) - 1]) p0 + [0, k[i][0], k[i][1]]];
    color([0.15, 0.15, 0.17, 0.85])
        for (i = [0 : len(pts) - 2]) hull() {
            translate(pts[i])     sphere(d = nozzle_od + 6);
            translate(pts[i + 1]) sphere(d = nozzle_od + 6);
        }
}

// What the chamber actually holds, with the module displacing it.
module water() {
    difference() {
        translate([0, 0, ch_floor]) cylinder(d = ch_id - 0.6, h = water_hold);
        translate([0, 0, ch_floor - eps]) mist_module();
        translate([0, 0, ch_floor - eps]) cylinder(d = mm_module_od, h = mm_base_h);
    }
}

// ─────────────────────────────────────────────────────────────
//  THE ASSEMBLY
// ─────────────────────────────────────────────────────────────
// Section each part INSIDE its own color(), so the cut faces take that
// colour instead of OpenCSG's default. Cutting the whole assembly with one
// difference() paints every cut face the same warning orange, and a full
// --render throws the colours away altogether.
module sect() {
    if (SECTION) {
        difference() {
            children();
            translate([-200, -400, -20]) cube([400, 400, 600]);
        }
        // Cut faces come out in the colour scheme's cutout colour, not the
        // part's. Capping them with a real projection() cross-section looks
        // better but costs a CGAL render per part, which is minutes.
    } else children();
}

module assembly() {
    // printed chamber
    color(PRINTED) sect() body();

    // module, standing on the floor inside the locating lugs
    translate([0, 0, ch_floor + E*150]) rotate([0, 0, 150]) sect() mist_module();
    if (E < 0.02) color(WATER) sect() water();

    // lid, lifted straight up
    translate([0, 0, ch_h + E*115]) color(PRINTED2) sect() lid();
    translate([-cable_hole_r, 0, ch_h + lid_t - 2 + E*135]) sect() bung();
    if (E < 0.02 && !SECTION) cable();

    // captured cap and the bottle screwed into it
    translate([feed_centre, 0, pocket_z + E*55]) sect() bottle_cap();
    if (BOTTLE)
        translate([feed_centre, 0, pocket_z + 2 + E*120]) sect() bottle();

    // fan on its pad, blowing inward, with its screws
    if (!SECTION) translate([-(ch_od/2 + fan_pad_t) - E*70, 0, duct_z])
        rotate([0, -90, 0]) fan40();
    if (!SECTION) for (y = [-1, 1], z = [-1, 1])
        translate([-(ch_od/2 + fan_pad_t) - 10 - E*95,
                   y*fan_pitch_40/2, duct_z + z*fan_pitch_40/2])
            rotate([0, 90, 0]) m3_screw(14);

    // fog hose
    if (!SECTION)
        translate([0, E*70*cos(nozzle_tilt), E*70*sin(nozzle_tilt)]) hose();

    // the optional trim spacer, shown only when exploded
    if (E > 0.02)
        translate([0, 0, ch_floor + E*105]) color("#8fb0d8") sect() spacer();
}

if (SECTION)
    difference() { assembly(); translate([-200, -400, -20]) cube([400, 400, 600]); }
else
    assembly();
