// Cut-away: chamber + lid/standpipe + module + water + bottle neck.
include <params.scad>
use <chamber.scad>
use <lid.scad>
difference() {
    union() {
        color("SteelBlue") chamber();
        color("SlateGray") translate([0,0,lid_pos_z]) lid();
        color("DimGray")   translate([0,0,ch_floor-mm_recess_d])
                               cylinder(d=mm_module_od, h=mm_module_h);
        color("DeepSkyBlue",0.35) translate([0,0,ch_floor])
                               cylinder(d=ch_id, h=water_level);
        // bottle stand-in: neck inserted into the standpipe socket
        color("Silver",0.5) translate([sp_offset,0,lid_pos_z+lid_t-sp_socket_depth])
            union() {
                cylinder(d=27.4, h=sp_socket_depth+6);
                translate([0,0,sp_socket_depth+6]) cylinder(d1=27.4, d2=bottle_body_d, h=25);
                translate([0,0,sp_socket_depth+31]) cylinder(d=bottle_body_d, h=70);
            }
    }
    translate([-ch_od, -ch_od, -5]) cube([2*ch_od, ch_od, 400]);
}
