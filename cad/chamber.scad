// ─────────────────────────────────────────────────────────────
//  Fog chamber — holds the mist maker under its water column.
//  Prints upright, open side up: no support anywhere.
//  Material: PETG, 100 um, >=4 perimeters, >=40% infill.
// ─────────────────────────────────────────────────────────────
include <params.scad>

mark_len_fill   = 30;   // longer rib = FILL TO HERE
mark_len_refill = 16;   // shorter rib = REFILL WHEN LEVEL REACHES HERE
mark_out        = 0.8;  // protrusion into the cavity
mark_h          = 1.5;

module chamber() {
    difference() {
        union() {
            rbox(ch_outer, ch_outer, ch_floor + ch_inner_h, ch_corner_r);
            // fog outlet spigot (teardrop = self-supporting)
            translate([ch_outer/2, ch_outer - eps, ch_floor + fog_port_z])
                teardrop(fog_port_d + 2*fog_boss_wall, fog_boss_len);
            // level ribs, RAISED on the inner wall so they neither thin the
            // wall nor trap grime, and are visible with the lid off
            for (m = [[water_fill, mark_len_fill], [water_refill, mark_len_refill]])
                translate([ch_wall, ch_outer/2 - m[1]/2, ch_floor + m[0]])
                    cube([mark_out, m[1], mark_h]);
        }

        // cavity
        translate([ch_wall, ch_wall, ch_floor])
            rbox(ch_inner, ch_inner, ch_inner_h + eps, max(ch_corner_r - ch_wall, 1));


        // fog outlet bore
        translate([ch_outer/2, ch_inner/2, ch_floor + fog_port_z])
            teardrop(fog_port_d, ch_outer);

        // module locating recess
        translate([ch_outer/2, ch_outer/2, -eps])
            cylinder(d = mm_module_od + 1.0, h = mm_recess_d + eps);

        // cable exit notch in the rim — no wall penetration below water
        translate([ch_outer/2 - cable_notch_w/2, -eps,
                   ch_floor + ch_inner_h - cable_notch_h])
            cube([cable_notch_w, ch_wall + 2*eps, cable_notch_h + eps]);
    }
}

chamber();
