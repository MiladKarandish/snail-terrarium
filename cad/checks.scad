// ─────────────────────────────────────────────────────────────
//  Geometry that exists only to be measured by verify.py.
//  Nothing here is printed.
//
//  Each test renders a solid whose VOLUME or BODY COUNT answers a
//  yes/no question about the real parts. Several run twice: once
//  as built, and once with a defect deliberately introduced. The
//  defective run MUST fail. A test that cannot fail is not a test
//  - that is how the earlier harness passed a chamber whose lid
//  could not be fitted.
// ─────────────────────────────────────────────────────────────
include <params.scad>
use <mister.scad>

TEST = "leak";
CTL  = 0;      // 1 = inject the defect this test is supposed to catch

// The body, optionally drilled through the wall below the water
// line - exactly the defect the previous revision shipped, where
// two fan screw holes opened into the chamber under water.
module body_ctl() {
    difference() {
        body();
        if (CTL)
            translate([-ch_od, 0, water_z - 6]) rotate([0, 90, 0])
                cylinder(d = 3, h = 2*ch_od);
    }
}

// A full bottle, inverted on the socket - INCLUDING the neck
// finish, which is the part that actually has to get past the
// socket. ISBT PCO-1881 (drawing 3784253-21): Ø27.4 thread, and a
// Ø33.00 support ring H = 15.24 below the sealing face. That ring
// is WIDER than the cap, so it can never enter the cap pocket.
//
// The old model was a bare cylinder starting ABOVE socket_top. It
// could not see a neck collision at all, and it passed while a
// 16.5 mm cap put the support ring 0.26 mm inside the socket.
//
// `neck_straight` is the ONE dimension here the drawing does not
// cover: ISBT specifies the finish down to the support ring and no
// further. It matches assembly.scad so the harness and the drawing
// agree. Drop it and the shoulder starts at the ring, which no real
// bottle does - and which invents a collision at the socket rim.
// The bottle seats as deep as the cap lets it: its sealing face
// lands one cap floor above the pocket floor.
module bottle(rz = -1) {
    h  = (rz < 0) ? neck_ring_h : rz;     // seal face to support ledge
    sh = h + 2.5 + neck_straight;         // where the shoulder starts
    translate([feed_centre, 0, pocket_z + cap_floor_t]) {
        cylinder(d = 27.4, h = h);                              // threaded neck
        translate([0, 0, h])
            cylinder(d = neck_ring_d, h = 2.5);                 // support ring
        translate([0, 0, h + 2.5])
            cylinder(d = 25, h = neck_straight);                // transfer bead
        translate([0, 0, sh])
            cylinder(d1 = 25, d2 = bottle_body_d, h = bottle_shoulder);
        translate([0, 0, sh + bottle_shoulder])
            cylinder(d = bottle_body_d, h = 250);
    }
}

// The counterbore back as solid material: the plain single-diameter
// pocket this design replaced.
module counterbore_plug() {
    translate([feed_centre, 0, pocket_z + cap_grip_h])
        difference() {
            cylinder(d = neck_bore_id, h = pocket_depth - cap_grip_h);
            translate([0, 0, -eps])
                cylinder(d = cap_pocket_id, h = pocket_depth - cap_grip_h + 2*eps);
        }
}

// ── 1. WATERTIGHTNESS, as a topology question ────────────────
// Take a box up to the water line and remove the body. What is
// left must be exactly TWO voids: the wetted cavity (joined to
// the feed conduit through the port, which is the whole point of
// the port) and the outside air. Three means the port never
// connected. One means the wall is breached and it leaks.
if (TEST == "leak")
    difference() {
        translate([-100, -100, 0]) cube([200, 200, water_z]);
        body_ctl();
    }

// ── 2. THE FEED IS ACTUALLY OPEN ─────────────────────────────
// Probe the conduit with a rod slightly under bore size. If the
// bore runs from the floor into the cap pocket it comes back as
// ONE body spanning that whole height. The previous revision left
// a 3 mm slug below the pocket, so the bottle fed nothing.
else if (TEST == "feed")
    difference() {
        translate([feed_centre, 0, 0]) cylinder(d = feed_id - 0.4, h = socket_top);
        // CTL: plug the bore just under the pocket, as before
        union() {
            body();
            if (CTL) translate([feed_centre, 0, pocket_z - 3])
                cylinder(d = feed_id, h = 3);
        }
    }

// ── 3. THE LID SEATS ─────────────────────────────────────────
// Empty when the lid is on its rim; NOT empty with the lid 1 mm
// low. Without that control an interference test that silently
// measures nothing passes forever.
else if (TEST == "fit")
    intersection() {
        body();
        translate([0, 0, ch_h - (CTL ? 1 : 0)]) lid();
    }

// ── 4. THE LID COMES OFF ─────────────────────────────────────
// Lift the lid until its spigot is clear of the bore, then sweep it
// sideways off the column. The socket flare above has to start high
// enough that this window exists: the relief slot only clears the
// slim conduit, not the flare.
else if (TEST == "lift")
    intersection() {
        body();
        translate([-12, 0, ch_h + lid_spigot_h + 1]) lid();
    }

// ── 5. THE BOTTLE FITS ───────────────────────────────────────
// A 0.5 L bottle on the socket must not foul the lid, the rim, or
// - the one this used to miss - the socket itself, with its neck
// support ring.
else if (TEST == "bottle")
    intersection() {
        union() { body(); translate([0, 0, ch_h]) lid(); }
        bottle();
    }

// ── 5b. THE COUNTERBORE EARNS ITS KEEP ───────────────────────
// A PCO-1881 ring lands ABOVE the socket, in free air, so it does
// not exercise the counterbore at all. What does is a short neck -
// a water finish - whose ring sits down inside it.
//
// Rather than invent a dimension for a finish I have no drawing
// for, this seats the SAME neck at the lowest ring that can
// physically occur: a cap has to clear its own support ring to
// screw on, so the ring is never below cap_h_min. That is the
// design envelope, tested at its worst point.
//
// CTL fills the counterbore back to the plain single-diameter
// pocket this design replaced. The Ø33 ring MUST then collide.
else if (TEST == "ring")
    intersection() {
        union() {
            body();
            if (CTL) counterbore_plug();
        }
        bottle(cap_h_min - cap_floor_t);
    }

// ── 6. THE MODULE FITS ───────────────────────────────────────
// Ø45 x 45 module standing on the floor, plus the trim spacer.
else if (TEST == "module")
    intersection() {
        body();
        translate([0, 0, ch_floor]) cylinder(d = mm_module_od,
                                             h = mm_module_h + trim_spacer_t);
    }

// ── 7. WETTED VOLUME ─────────────────────────────────────────
// What the chamber actually holds with the module in it: sets how
// long a burst can run before the Mariotte has to keep up.
else if (TEST == "water")
    difference() {
        translate([0, 0, ch_floor]) cylinder(d = ch_id, h = water_hold);
        body();
        translate([0, 0, ch_floor - eps]) cylinder(d = mm_module_od,
                                                   h = mm_module_h + eps);
    }

// ── 8. THE HOSE ACTUALLY GOES ON ─────────────────────────────
// Slide a length of hose down the nozzle axis until it fouls the
// barrel. A tilted spigot leaves a round barrel unevenly - the top
// of it is buried far deeper than the bottom - and the SHORT side
// is what the hose end stops against, so that is the engagement
// you really get. Eyeballing the render will not tell you.
module hose_sleeve(engage) {
    s1 = ch_od/2/cos(nozzle_tilt) + nozzle_len;
    translate([0, 0, nozzle_axis_z]) rotate([nozzle_tilt, 0, 0])
        rotate([-90, 0, 0]) translate([0, 0, s1 - engage])
            difference() {
                cylinder(d = nozzle_od + 2*hose_wall, h = engage + 25);
                translate([0, 0, -eps])
                    cylinder(d = nozzle_od + 0.3, h = engage + 25 + 2*eps);
            }
}
if (TEST == "hosefit")
    intersection() { body(); hose_sleeve(CTL ? hose_engage + 8 : hose_engage); }
