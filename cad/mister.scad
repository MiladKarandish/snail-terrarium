// ─────────────────────────────────────────────────────────────
//  Bottle-fed mist body — the Orchidee arrangement, sized to the
//  MEASURED module (Ø45 x 45 mm, water held at 47 mm).
//
//  PART="body"  the chamber: module drops in the top, feed conduit
//               up the outside, fan pad one side, nozzle the other
//  PART="lid"   closes the bore, carries the bottle socket
//  PART="fan30" adapter so a 30 mm fan fits the 40 mm pad
//
//  The feed port at the water line is what sets the level: water
//  leaves the bottle until it seals that port, then no air can get
//  in and flow stops. Nothing measures anything.
//
//  Print body upright, open end up. Fan pad and nozzle bores are
//  teardrops so nothing needs support.
// ─────────────────────────────────────────────────────────────
include <params.scad>

PART = "body";
ch_h  = ch_floor + ch_inner_h;

module feed_column(d, h, z0) { translate([feed_centre, 0, z0]) cylinder(d = d, h = h); }

module body() {
    difference() {
        union() {
            cylinder(d = ch_od, h = ch_h);
            translate([0, 0, ch_h - ch_flange_h]) cylinder(d = ch_flange_od, h = ch_flange_h);
            // conduit: a slim tube that flares conically into the bottle
            // socket, so the wider boss is self-supporting when printed
            feed_column(feed_od, feed_top - 24, 0);
            translate([feed_centre, 0, feed_top - 24 - eps])
                cylinder(d1 = feed_od, d2 = socket_od, h = 16 + eps);
            translate([feed_centre, 0, feed_top - 8 - eps])
                cylinder(d = socket_od, h = 8 + sp_socket_depth);
            // fan pad, flat so a fan can actually seat on it
            translate([-ch_od/2 - fan_pad_t + 1.5, -fan_pad/2, fan_z - fan_pad/2])
                cube([fan_pad_t, fan_pad, fan_pad]);
            // nozzle spigot
            translate([0, ch_od/2 - eps, nozzle_z])
                teardrop(nozzle_d + 2*nozzle_wall, nozzle_len);
        }
        translate([0, 0, ch_floor]) cylinder(d = ch_id, h = ch_inner_h + eps);   // bore
        translate([0, 0, -eps]) cylinder(d = mm_module_od + 1.5, h = mm_recess_d + eps);
        feed_column(feed_id, feed_top - ch_floor, ch_floor);        // conduit bore
        translate([feed_centre, 0, feed_top - eps])                 // bottle neck socket
            cylinder(d = sp_bore, h = sp_socket_depth + 2*eps);
        // feed port — its height IS the water level. It must stop INSIDE
        // the conduit bore, never punch out through the conduit's far wall.
        translate([ch_id/2 - 4, 0, ch_floor + water_hold])
            rotate([0, 90, 0])
                cylinder(d = feed_port_d, h = feed_centre - (ch_id/2 - 4) + 4);
        // fan bore + screw holes
        translate([-ch_od/2 - 6, 0, fan_z]) rotate([0, 90, 0])
            cylinder(d = fan_bore, h = ch_od);
        for (x = [-1, 1], y = [-1, 1])
            translate([-ch_od/2 - 6, x*fan_pitch/2, fan_z + y*fan_pitch/2])
                rotate([0, 90, 0]) cylinder(d = fan_screw_d, h = 12);
        // nozzle bore — teardrop extrudes along +Y, so no rotation
        translate([0, 0, nozzle_z]) teardrop(nozzle_d, ch_od/2 + nozzle_len + 2);
        // cable notch in the rim
        // notch the NEAR wall only; cutting the full width leaves a
        // zero-thickness sliver at the far surface
        translate([-cable_notch_w/2, -ch_flange_od/2 - eps, ch_h - cable_notch_h])
            cube([cable_notch_w, (ch_flange_od - ch_id)/2 + ch_wall + 3,
                  cable_notch_h + eps]);
    }
}

module lid() {
    difference() {
        union() {
            cylinder(d = ch_flange_od, h = lid_t);
            // spigot is a RING, not a disc: it only has to locate the lid
            translate([0, 0, -lid_spigot_h]) difference() {
                cylinder(d = ch_id - 2*lid_fit, h = lid_spigot_h);
                translate([0, 0, -eps])
                    cylinder(d = ch_id - 2*lid_fit - 4, h = lid_spigot_h + 2*eps);
            }
        }
        translate([-cable_notch_w/2, -ch_flange_od/2 - eps, -lid_spigot_h - eps])
            cube([cable_notch_w, ch_flange_od/2 - ch_id/2 + ch_wall + 4,
                  lid_spigot_h + lid_t + 2*eps]);
        translate([0, ch_flange_od/2 + lid_finger_d*0.3, -lid_spigot_h - eps])
            cylinder(d = lid_finger_d, h = lid_spigot_h + lid_t + 2*eps);
    }
}

module fan30() {                        // 30 mm fan (24 mm pitch) on the 40 mm pad
    difference() {
        cube([fan_pad, fan_pad, 3], center = true);
        cylinder(d = 26, h = 9, center = true);
        for (x = [-1, 1], y = [-1, 1]) {
            translate([x*fan_pitch/2, y*fan_pitch/2, 0])
                cylinder(d = fan_screw_d, h = 9, center = true);
            translate([x*12, y*12, 0]) cylinder(d = fan_screw_d, h = 9, center = true);
        }
    }
}

if (PART == "body") body();
else if (PART == "lid") lid();
else fan30();
