// True vertical section through the assembly at y = 0.
// projection(cut=true) slices at z=0, so the model is rotated to put
// the XZ plane there. Every outline is the real printed geometry -
// nothing here is drawn by hand.
include <params.scad>
use <mister.scad>

projection(cut = true)
    rotate([-90, 0, 0])
        union() {
            body();
            translate([0, 0, ch_h]) lid();
            // module and water line, for reading the levels off the drawing
            translate([0, 0, ch_floor]) cylinder(d = mm_module_od, h = mm_module_h);
            translate([0, 0, ch_floor]) cylinder(d = ch_id - 0.6, h = water_hold);
        }
