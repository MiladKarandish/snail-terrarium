// Bottle-fed cap chamber (the Thingiverse/MakerWorld approach), sized
// for THIS module rather than a 20 mm disc. Two parts: a cup the module
// drops into, and a top carrying the bottle socket + standpipe.
include <params.scad>
cc_id    = 58;                       // module 45 + fog clearance
cc_wall  = 1.6;
cc_od    = cc_id + 2*cc_wall;
cc_water = mm_module_h + 25;         // 70 mm: level the bottle mouth holds
cc_head  = 40;                       // fog headspace
cc_h     = cc_water + cc_head;
cc_flange= 3;

module cup() {
    difference() {
        union() {
            cylinder(d = cc_od, h = ch_floor + cc_h);
            translate([0,0,ch_floor + cc_h - 4])
                cylinder(d = cc_od + 2*cc_flange, h = 4);
        }
        translate([0,0,ch_floor]) cylinder(d = cc_id, h = cc_h + eps);
        translate([-cable_notch_w/2, -cc_od/2 - cc_flange - eps,
                   ch_floor + cc_h - cable_notch_h])
            cube([cable_notch_w, cc_flange + cc_wall + 2*eps, cable_notch_h + eps]);
    }
}
module top() {
    sp_len = cc_h - cc_water;
    difference() {
        union() {
            cylinder(d = cc_od + 2*cc_flange, h = plate_t);
            translate([0,0,-lid_spigot_h]) cylinder(d = cc_id - 2*lid_fit, h = lid_spigot_h);
            translate([12,0,-sp_len]) cylinder(d = sp_od, h = sp_len + plate_t);
            translate([-16,0,plate_t-eps])
                cylinder(d = fog_port_d + 2*fog_boss_wall, h = fog_collar_h);
        }
        translate([12,0,-sp_len-eps]) cylinder(d = sp_bore, h = sp_len + plate_t + 2*eps);
        translate([-16,0,-lid_spigot_h-eps])
            cylinder(d = fog_port_d, h = lid_spigot_h + plate_t + fog_collar_h + 2*eps);
        for (a=[70,110,250,290]) rotate([0,0,a]) translate([22,0,-lid_spigot_h-eps])
            cylinder(d = vl_vent_d, h = lid_spigot_h + plate_t + 2*eps);
    }
}
if (PART == "cup") cup(); else top();
