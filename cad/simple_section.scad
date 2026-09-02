// Cut-away: cut PET bottle + simple_lid. No reservoir, no seals.
include <params.scad>
difference() {
    union() {
        color("LightSteelBlue",0.45) difference() {
            cylinder(d = vessel_od, h = vessel_cut_h + 40);
            translate([0,0,2]) cylinder(d = vessel_od - 2, h = vessel_cut_h + 40);
        }
        color("DeepSkyBlue",0.40) translate([0,0,2])
            cylinder(d = vessel_od-2, h = mm_module_h + water_max - 2);
        color("SkyBlue",0.25) translate([0,0,mm_module_h + water_min])
            cylinder(d = vessel_od-2, h = water_max - water_min);
        color("DimGray") translate([0,0,2]) cylinder(d=mm_module_od, h=mm_module_h);
        color("SlateGray") translate([0,0,vessel_cut_h+40]) import("stl/simple_lid.stl");
    }
    translate([-100,-120,-5]) cube([200,120,500]);
}
