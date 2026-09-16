// ─────────────────────────────────────────────────────────────
//  Bottle-fed mist chamber, sized to the module in MIST-MAKER.md
//  (ECA 3791 / CL-24 class, Ø45 x 45 mm, 550 mL/h).
//
//  PART="body"    the chamber: module drops in the top, Mariotte
//                 conduit up the outside, fan pad one side,
//                 fog nozzle the other, bottle socket on top of
//                 the column
//  PART="lid"     closes the bore, passes the module's cable
//  PART="spacer"  optional trim disc under the module
//
//  The feed port at the water line sets the level: water leaves
//  the bottle until it seals that port, then no air can get in
//  and flow stops. Nothing measures anything.
//
//  PRINTING
//    Body   upright, open end up, on the foot. No support.
//    Lid    plate-top-down. No support.
//    Both   PETG, >=4 perimeters, 0.2 mm layers, >=30% infill.
//  Every horizontal hole is a teardrop and every step outward is
//  a 45° cone, so nothing on either part overhangs past 45°.
// ─────────────────────────────────────────────────────────────
include <params.scad>

PART = "body";

// ── shared profiles ──────────────────────────────────────────

// The feed column is joined to the barrel by a solid web, not by
// two cylinders grazing each other. The web has to be wider than
// the feed port: if the port broke out of the web's side, air
// would reach the conduit directly and the Mariotte would drain
// instead of regulating.
module feed_profile(w) {
    hull() {
        translate([feed_web_x, -w/2]) square([2, w]);
        translate([feed_centre, 0]) circle(d = feed_od);
    }
}

// Flat-faced boss for the fan, filled solid back to the barrel so
// the whole 42 x 42 face seats. A plate merely floating off the
// barrel touches it along a sliver and snaps at the joint.
module fan_boss() {
    intersection() {
        translate([0, 0, duct_z - fan_pad/2]) linear_extrude(fan_pad)
            difference() {
                translate([-(ch_od/2 + fan_pad_t), -fan_pad/2])
                    square([ch_od/2 + fan_pad_t + 2, fan_pad]);
                circle(d = ch_od - 0.4);  // overlap the barrel, never graze it
            }
        // 45° chamfer under it: the pad's flat underside would otherwise be
        // the one horizontal ceiling on the part
        translate([0, 0, duct_z - fan_pad/2])
            cylinder(d1 = ch_od, d2 = ch_od + 4*fan_pad, h = 2*fan_pad);
    }
}

// A cylinder on the tilted nozzle axis, from s0 out to s1 measured
// along that axis from the chamber's centreline.
module nozzle_axis(d, s1, s0) {
    translate([0, 0, nozzle_axis_z]) rotate([nozzle_tilt, 0, 0])
        rotate([-90, 0, 0]) translate([0, 0, s0]) cylinder(d = d, h = s1 - s0);
}

// ── body ─────────────────────────────────────────────────────
module body() {
    union() {
        difference() {
            union() {
                // foot: the bottle is 520 g on a 41 mm arm, and this is
                // also what anchors a 130 mm tall print to the bed
                linear_extrude(foot_t)
                    hull() {
                        circle(d = foot_d);
                        translate([feed_centre, 0]) circle(d = foot_pad_d);
                    }
                // barrel, then a 45° cone out to the rim flange
                cylinder(d = ch_od, h = ch_h - ch_flange_h);
                translate([0, 0, ch_h - ch_flange_h])
                    cylinder(d1 = ch_od, d2 = ch_flange_od, h = ch_flange_cham);
                translate([0, 0, ch_h - ch_flange_h + ch_flange_cham])
                    cylinder(d = ch_flange_od, h = ch_flange_h - ch_flange_cham);
                // feed column: wide web where the port is bored through
                // it, necking down to a rib above. Narrowing as it rises
                // is free - it is a step INWARD, never an overhang.
                linear_extrude(feed_web_top) feed_profile(feed_web_w);
                linear_extrude(feed_rib_top) feed_profile(feed_rib_w);
                // past the rim, only the round tube: that is all the lid's
                // relief can clear
                translate([feed_centre, 0, feed_rib_top - eps])
                    cylinder(d = feed_od, h = socket_cone_z - feed_rib_top + eps);
                // bottle socket, clear of the seated lid
                translate([feed_centre, 0, socket_cone_z])
                    cylinder(d1 = feed_od, d2 = socket_od, h = socket_cone_h);
                translate([feed_centre, 0, socket_cone_z + socket_cone_h - eps])
                    cylinder(d = socket_od, h = socket_top - socket_cone_z
                                                 - socket_cone_h + eps);
                fan_boss();
                // fog nozzle, tilted up. It starts well inside the bore so
                // it intersects the wall solidly; the bore cut trims the
                // surplus. The previous revision butted a flat-backed
                // spigot against the barrel and bonded over 0.2 mm3.
                nozzle_axis(nozzle_od, ch_od/2/cos(nozzle_tilt) + nozzle_len,
                            20);
            }
            // ── cuts ──────────────────────────────────────────
            translate([0, 0, ch_floor]) cylinder(d = ch_id, h = ch_inner_h + eps);
            // conduit bore, continuous from the floor into the cap pocket.
            // The previous revision stopped it 3 mm short of the pocket and
            // left a solid slug: the bottle could never feed the chamber.
            translate([feed_centre, 0, ch_floor])
                cylinder(d = feed_id, h = pocket_z - ch_floor + eps);
            // Cap socket, in two diameters. The lower Ø32.4 is a ribbed
            // grip that any standard cap drops into; above it the bore
            // opens to Ø34.5 so the bottle's Ø33 neck support ring has
            // somewhere to go whatever the cap height turns out to be.
            // The ring is wider than the cap and can never enter the
            // grip, which is why a single-diameter pocket had to be cut
            // to one measured cap. Widening as it rises, this costs
            // nothing in overhang.
            translate([feed_centre, 0, pocket_z])
                cylinder(d = cap_pocket_id, h = cap_grip_h + eps);
            translate([feed_centre, 0, pocket_z + cap_grip_h])
                cylinder(d = neck_bore_id,
                         h = pocket_depth - cap_grip_h + eps);
            // feed port: teardrop, APEX on the water line, stopping
            // inside the conduit bore and never through its far wall
            translate([feed_port_x0, 0, water_z - feed_port_d/2*1.42])
                teardrop_x(feed_port_d, feed_port_len);
            // fan bore, teardrop so it needs no support
            translate([-(ch_od/2 + fan_pad_t + eps), 0, duct_z])
                teardrop_x(fan_bore, ch_od/2 + fan_pad_t + 10);
            // fan screws: BLIND in the pad, all three bolt patterns, so
            // a 30, 40 or 50 mm fan bolts straight on. They must never
            // reach the bore - the previous revision ran them 12 mm deep,
            // through the wall and into the water. The NARROWEST pattern
            // is the dangerous one: that is where the barrel curves
            // closest to the pad.
            for (p = [fan_pitch_30, fan_pitch_40, fan_pitch_50],
                 y = [-1, 1], z = [-1, 1])
                translate([-(ch_od/2 + fan_pad_t + eps), y*p/2, duct_z + z*p/2])
                    teardrop_x(fan_screw_d, fan_screw_depth + eps);
            // nozzle bore, straight through from the cavity
            nozzle_axis(nozzle_d, ch_od/2/cos(nozzle_tilt) + nozzle_len + eps, 0);
        }
        // added after the bore is cut, so the bore does not eat them
        module_lugs();
        cap_ribs();
    }
}

// Locate the module without thinning the floor. Gaps between the
// lugs let its cable leave at any angle.
module module_lugs() {
    for (i = [0 : lug_n - 1])
        rotate([0, 0, i*360/lug_n])
            translate([0, 0, ch_floor - 1])
                rotate_extrude(angle = lug_arc)
                    translate([lug_id/2, 0]) square([lug_w, lug_h + 1]);
}

// Anti-rotation ribs, in the grip section only - they must stop
// below the neck-ring counterbore or they would foul the ring
// they exist to make room for. They crush 0.2 mm on the widest
// standard cap and key the epoxy on the narrowest.
module cap_ribs() {
    for (i = [0 : cap_rib_n - 1])
        translate([feed_centre, 0, pocket_z - 1])
            rotate([0, 0, i*360/cap_rib_n])
                translate([cap_pocket_id/2, 0, 0])
                    cylinder(d = cap_rib_d, h = cap_grip_h + 1);
}

// ── lid ──────────────────────────────────────────────────────
// Printed plate-top-down: the spigot rises from the bed, the
// cable countersink narrows as it rises, and the face that seats
// on the rim is bed-flat. Not one overhang on the part.
module lid() {
    difference() {
        union() {
            cylinder(d = ch_flange_od, h = lid_t);
            translate([0, 0, -lid_spigot_h]) difference() {
                cylinder(d = ch_id - 2*lid_fit, h = lid_spigot_h + eps);
                translate([0, 0, -eps])
                    cylinder(d = ch_id - 2*lid_fit - 2*lid_spigot_w,
                             h = lid_spigot_h + 3*eps);
            }
        }
        // relief for the feed conduit. It opens to the lid's edge, so
        // the lid lifts a millimetre and slides sideways off the
        // column rather than having to pass the socket above it.
        translate([feed_centre, 0, -lid_spigot_h - eps])
            cylinder(d = feed_od + 2*lid_feed_clear,
                     h = lid_spigot_h + lid_t + 2*eps);
        // cable exit: a vertical hole prints round and takes the
        // conical bung the module already ships with. A notch in the
        // rim instead just leaks fog down the outside of the chamber.
        translate([-cable_hole_r, 0, -lid_spigot_h - eps])
            cylinder(d = cable_hole_d, h = lid_spigot_h + lid_t + 2*eps);
        translate([-cable_hole_r, 0, -eps])
            cylinder(d1 = cable_cs_d, d2 = cable_hole_d,
                     h = cable_cs_depth + eps);
        // finger scallop, opposite the conduit
        translate([-(ch_flange_od/2 + lid_finger_d*0.28), 0,
                   -lid_spigot_h - eps])
            cylinder(d = lid_finger_d, h = lid_spigot_h + lid_t + 2*eps);
    }
}

// ── optional trim spacer ─────────────────────────────────────
// Raises the module, which is the same as lowering the water.
// Fit it only if the real level lands high.
module spacer() {
    difference() {
        cylinder(d = trim_spacer_d, h = trim_spacer_t);
        for (i = [0 : 5]) rotate([0, 0, i*60])
            translate([trim_spacer_d/4, 0, -eps])
                cylinder(d = 7, h = trim_spacer_t + 2*eps);
        // relief so the module's cable is never pinched under it
        translate([-mm_cable_od, trim_spacer_d/2 - 4, -eps])
            cube([2*mm_cable_od, 6, trim_spacer_t + 2*eps]);
    }
}

// Every part is exported lying the way it prints, because a print
// service slices the file as uploaded and offers no way to rotate it.
// The lid is modelled as it sits on the chamber, so it is turned over
// here - a rotation, never a mirror, or the cable hole would swap sides.
if      (PART == "body")   body();
else if (PART == "lid")    translate([0, 0, lid_t]) rotate([180, 0, 0]) lid();
else if (PART == "spacer") spacer();
