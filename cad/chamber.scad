// ─────────────────────────────────────────────────────────────
//  Fog chamber — cylindrical, fed by the Mariotte standpipe in
//  the lid. Prints upright, open end up: no support anywhere.
//  PETG, 100 um, >=4 perimeters.
// ─────────────────────────────────────────────────────────────
include <params.scad>

module chamber() {
    difference() {
        union() {
            cylinder(d = ch_od, h = ch_floor + ch_inner_h);
            // rim flange: gives the lid a real seat on a thin-walled tube
            translate([0, 0, ch_floor + ch_inner_h - ch_flange_h])
                cylinder(d = ch_flange_od, h = ch_flange_h);
            translate([0, ch_od/2 - eps, ch_floor + fog_port_z])
                teardrop(fog_port_d + 2*fog_boss_wall, fog_boss_len);
        }
        // cavity
        translate([0, 0, ch_floor])
            cylinder(d = ch_id, h = ch_inner_h + eps);
        // fog outlet bore
        translate([0, 0, ch_floor + fog_port_z])
            teardrop(fog_port_d, ch_od);
        // module locating recess
        translate([0, 0, -eps])
            cylinder(d = mm_module_od + 1.0, h = mm_recess_d + eps);
        // cable exit notch in the rim — no penetration below water
        translate([-cable_notch_w/2, -ch_flange_od/2 - eps,
                   ch_floor + ch_inner_h - cable_notch_h])
            cube([cable_notch_w, ch_flange_w + ch_wall + 2*eps, cable_notch_h + eps]);
    }
}
chamber();
