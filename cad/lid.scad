// ─────────────────────────────────────────────────────────────
//  Chamber lid — plate seats on the chamber rim, spigot locates
//  it in the cavity, fill collar points DOWN into the headspace.
//
//  PRINT PLATE-TOP-DOWN (the smooth face on the bed). Spigot and
//  collar both rise from the bed: zero overhangs, and the seating
//  face is a bed-flat surface rather than a drooping ledge.
//
//  Origin is the plate's underside = the chamber rim.
// ─────────────────────────────────────────────────────────────
include <params.scad>

fill_port_d   = 38;
fill_collar_h = 8;
fill_wall     = 2.5;

spigot        = ch_inner - 2*lid_fit;
fill_cx       = ch_outer/2;
fill_cy       = ch_outer*0.34;
vent_ring_r   = fill_port_d/2 + fill_wall + 5;

module lid() {
    difference() {
        union() {
            translate([0, 0, 0])
                rbox(ch_outer, ch_outer, lid_t, ch_corner_r);
            // locating spigot, into the cavity
            translate([(ch_outer - spigot)/2, (ch_outer - spigot)/2, -lid_spigot_h])
                rbox(spigot, spigot, lid_spigot_h + eps, max(ch_corner_r - ch_wall, 1));
            // fill collar, downward
            translate([fill_cx, fill_cy, -fill_collar_h])
                cylinder(d = fill_port_d + 2*fill_wall, h = fill_collar_h + eps);
        }
        // fill port
        translate([fill_cx, fill_cy, -fill_collar_h - eps])
            cylinder(d = fill_port_d, h = fill_collar_h + lid_t + 2*eps);
        // make-up air vents
        translate([fill_cx, fill_cy, -lid_spigot_h - eps])
            for (i = [0 : vent_n - 1])
                rotate([0, 0, i*360/vent_n])
                    translate([vent_ring_r, 0, 0])
                        cylinder(d = vent_d, h = lid_spigot_h + lid_t + 2*eps);
        // cable notch, aligned with the chamber's
        translate([ch_outer/2 - cable_notch_w/2, -eps, -lid_spigot_h - eps])
            cube([cable_notch_w, ch_wall + eps, lid_spigot_h + lid_t + 2*eps]);
        // finger cutout for lifting
        translate([ch_outer/2, ch_outer + lid_finger_d*0.32, -lid_spigot_h - eps])
            cylinder(d = lid_finger_d, h = lid_spigot_h + lid_t + 2*eps);
    }
}

lid();
