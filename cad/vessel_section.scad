// Cut-away: cut PET bottle as the chamber + vessel_lid + reservoir bottle.
include <params.scad>
use <vessel_lid.scad>
sp_len = vessel_cut_h - water_level;
difference() {
    union() {
        // the cut bottle (free): walls ~0.3 mm, drawn 1 mm to be visible
        color("LightSteelBlue", 0.45) difference() {
            cylinder(d = vessel_od, h = vessel_cut_h);
            translate([0,0,2]) cylinder(d = vessel_od - 2, h = vessel_cut_h);
        }
        color("DeepSkyBlue", 0.40)
            translate([0,0,2]) cylinder(d = vessel_od - 2, h = water_level - 2);
        color("DimGray")  translate([0,0,2]) cylinder(d = mm_module_od, h = mm_module_h);
        color("SlateGray") translate([0,0,vessel_cut_h]) vessel_lid();
        // reservoir: 0.5 L bottle, neck plugged into the standpipe socket
        color("Silver", 0.5)
            translate([sp_offset, 0, vessel_cut_h + plate_t - sp_socket_depth])
            union() {
                cylinder(d = 27.4, h = sp_socket_depth + 8);
                translate([0,0,sp_socket_depth+8]) cylinder(d1=27.4, d2=bottle_body_d, h=28);
                translate([0,0,sp_socket_depth+36]) cylinder(d=bottle_body_d, h=95);
            }
    }
    translate([-100, -120, -5]) cube([200, 120, 500]);
}
