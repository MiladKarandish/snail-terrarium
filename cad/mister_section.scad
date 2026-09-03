include <params.scad>
use <mister.scad>
difference() {
    union() {
        color("Peru")      mister_body_ref();
        color("SlateGray") translate([0,0,ch_floor+ch_inner_h]) mister_lid_ref();
        color("DimGray")   translate([0,0,ch_floor-mm_recess_d])
                               cylinder(d=mm_module_od, h=mm_module_h);
        color("DeepSkyBlue",.4) translate([0,0,ch_floor])
                               cylinder(d=ch_id-.4, h=water_hold);
    }
    translate([-90,-120,-5]) cube([200,120,220]);
}
module mister_body_ref(){ import("stl/mister_body.stl"); }
module mister_lid_ref(){ import("stl/mister_lid.stl"); }
