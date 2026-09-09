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

// A full bottle, inverted on the socket. Its shoulder is where the
// neck reaches full body diameter.
module bottle() {
    translate([feed_centre, 0, socket_top + bottle_shoulder])
        cylinder(d = bottle_body_d, h = 250);
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
// A 0.5 L bottle on the socket must not foul the lid or the rim.
else if (TEST == "bottle")
    intersection() {
        union() { body(); translate([0, 0, ch_h]) lid(); }
        bottle();
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
