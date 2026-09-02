// ─────────────────────────────────────────────────────────────
//  Fog chamber — holds the mist maker under a regulated water
//  column. Prints upright, open side up: no support anywhere.
//  Material: PETG, 100 um, >=4 perimeters, >=40% infill.
// ─────────────────────────────────────────────────────────────
include <params.scad>

module chamber() {
    difference() {
        union() {
            // shell
            rbox(ch_outer, ch_outer, ch_floor + ch_inner_h, ch_corner_r);
            // fog outlet spigot
            translate([ch_outer/2, ch_outer - eps, ch_floor + fog_port_z])
                rotate([0,0,0])
                    teardrop(fog_port_d + 2*fog_boss_wall, fog_boss_len);
        }

        // ── cavity ───────────────────────────────────────────
        translate([ch_wall, ch_wall, ch_floor])
            rbox(ch_inner, ch_inner, ch_inner_h + eps, max(ch_corner_r - ch_wall, 1));

        // ── lid rebate: widen the top so the lid spigot drops in
        translate([ch_wall - lid_clear, ch_wall - lid_clear,
                   ch_floor + ch_inner_h - lid_lip_h])
            rbox(ch_inner + 2*lid_clear, ch_inner + 2*lid_clear,
                 lid_lip_h + eps, max(ch_corner_r - ch_wall, 1));

        // ── fog outlet bore ──────────────────────────────────
        translate([ch_outer/2, ch_inner/2, ch_floor + fog_port_z])
            teardrop(fog_port_d, ch_outer);

        // ── module locating recess in the floor ──────────────
        translate([ch_outer/2, ch_outer/2, -eps])
            cylinder(d = mm_module_od + 1.0, h = 1.5 + eps);

        // ── cable exit notch in the rim (no wall penetration) ─
        translate([ch_outer/2 - cable_notch_w/2, -eps,
                   ch_floor + ch_inner_h - cable_notch_h])
            cube([cable_notch_w, ch_wall + 2*eps, cable_notch_h + eps]);

        // ── water-level witness marks, engraved outside ──────
        for (z = [water_refill, water_fill])
            translate([-eps, ch_outer/2 - 12, ch_floor + z])
                cube([0.6, 24, (z == water_fill) ? 1.2 : 0.8]);
    }
}

chamber();
