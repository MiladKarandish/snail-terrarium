// ─────────────────────────────────────────────────────────────
//  Chamber lid — drops into the rebate, lifts off for service.
//  Fill port lets you top up without disturbing the fog duct.
//  Prints flat, no support.
// ─────────────────────────────────────────────────────────────
include <params.scad>

fill_port_d   = 38;
fill_collar_h = 6;
fill_wall     = 2.5;
tab_d         = 16;

module lid() {
    difference() {
        union() {
            rbox(ch_outer, ch_outer, lid_t, ch_corner_r);
            // locating spigot
            translate([ch_wall, ch_wall, -lid_lip_h])
                rbox(ch_inner, ch_inner, lid_lip_h + eps,
                     max(ch_corner_r - ch_wall, 1));
            // fill-port collar
            translate([ch_outer/2, ch_outer*0.34, lid_t - eps])
                cylinder(d = fill_port_d + 2*fill_wall, h = fill_collar_h);
        }
        // fill port bore
        translate([ch_outer/2, ch_outer*0.34, -lid_lip_h - eps])
            cylinder(d = fill_port_d,
                     h = lid_t + fill_collar_h + lid_lip_h + 2*eps);
        // make-up air vents, ring around the fill collar
        translate([ch_outer/2, ch_outer*0.34, -lid_lip_h - eps])
            for (i = [0 : vent_n - 1])
                rotate([0, 0, i*360/vent_n + 30])
                    translate([fill_port_d/2 + fill_wall + 5, 0, 0])
                        cylinder(d = vent_d, h = lid_t + lid_lip_h + 2*eps);
        // cable notch, aligned with the body's
        translate([ch_outer/2 - cable_notch_w/2, -eps, -lid_lip_h - eps])
            cube([cable_notch_w, ch_wall + lid_clear + 2*eps,
                  lid_lip_h + lid_t + 2*eps]);
        // finger recess for lifting
        translate([ch_outer/2, ch_outer - 14, lid_t])
            sphere(d = tab_d);
    }
}

lid();
