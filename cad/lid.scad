// ─────────────────────────────────────────────────────────────
//  Lid + Mariotte standpipe, one part.
//  PRINT PLATE-TOP-DOWN. Origin = plate underside = chamber rim.
// ─────────────────────────────────────────────────────────────
include <params.scad>

sp_len = lid_pos_z - (ch_floor + water_level);   // lid down to the level

module lid() {
    difference() {
        union() {
            cylinder(d = ch_od, h = lid_t);
            translate([0, 0, -lid_spigot_h])
                cylinder(d = ch_id - 2*lid_fit, h = lid_spigot_h + eps);
            translate([sp_offset, 0, -sp_len])
                cylinder(d = sp_od, h = sp_len + eps);
        }
        // uniform bore: bottle neck socket at the top, air/water path below
        translate([sp_offset, 0, -sp_len - eps])
            cylinder(d = sp_bore, h = sp_len + lid_t + 2*eps);
        // make-up air vents (chamber must breathe or the siphon stalls)
        for (i = [0 : vent_n - 1])
            rotate([0, 0, i*360/vent_n + 40])
                translate([ch_id/2 - 8, 0, -lid_spigot_h - eps])
                    cylinder(d = vent_d, h = lid_spigot_h + lid_t + 2*eps);
        // cable notch, aligned with the chamber's
        translate([-cable_notch_w/2, -ch_od/2 - eps, -lid_spigot_h - eps])
            cube([cable_notch_w, ch_wall + eps, lid_spigot_h + lid_t + 2*eps]);
        // finger cutout
        translate([0, ch_od/2 + lid_finger_d*0.30, -lid_spigot_h - eps])
            cylinder(d = lid_finger_d, h = lid_spigot_h + lid_t + 2*eps);
    }
}
lid();
