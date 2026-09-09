// Exports one component of the assembly at a time, in ASSEMBLY
// COORDINATES, at a tessellation coarse enough for a web viewer.
// Driven by tools/build_viewer.py; not part of the printed build.
include <params.scad>
use <mister.scad>
use <assembly.scad>

PART = "body";
$fa = 8; $fs = 1.6;          // ~1/8 the triangles of the print settings

mm_base_h = 25;

if      (PART == "body")   body();
else if (PART == "lid")    translate([0, 0, ch_h]) lid();
else if (PART == "spacer") translate([0, 0, ch_floor]) spacer();
else if (PART == "module")
    translate([0, 0, ch_floor]) rotate([0, 0, 150]) mist_module();
else if (PART == "water")  water();
else if (PART == "cable")  cable();
else if (PART == "bung")
    translate([-cable_hole_r, 0, ch_h + lid_t - 2]) bung();
else if (PART == "cap")    translate([feed_centre, 0, pocket_z]) bottle_cap();
else if (PART == "bottle") translate([feed_centre, 0, pocket_z + 2]) bottle();
else if (PART == "fan")
    translate([-(ch_od/2 + fan_pad_t), 0, duct_z]) rotate([0, -90, 0]) fan40();
else if (PART == "screws")
    for (y = [-1, 1], z = [-1, 1])
        translate([-(ch_od/2 + fan_pad_t) - 10, y*fan_pitch_40/2,
                   duct_z + z*fan_pitch_40/2])
            rotate([0, 90, 0]) m3_screw(14);
else if (PART == "hose")   hose();
