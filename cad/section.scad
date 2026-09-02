// Cut-away assembly: chamber + lid + module stand-in + water.
include <params.scad>
use <chamber.scad>
use <lid.scad>

show_water = true;

difference() {
    union() {
        color("SteelBlue")   chamber();
        color("SlateGray")   translate([lid_pos_xy, lid_pos_xy, lid_pos_z]) lid();
        // mist maker stand-in: 45 dia x 45 tall, sunk in its recess
        color("DimGray")
            translate([ch_outer/2, ch_outer/2, ch_floor - mm_recess_d])
                cylinder(d = mm_module_od, h = mm_module_h);
        if (show_water)
            color("DeepSkyBlue", 0.35)
                translate([ch_wall, ch_wall, ch_floor])
                    rbox(ch_inner, ch_inner, water_fill, 3);
    }
    // cut the front half away
    translate([-1, -1, -1]) cube([ch_outer+2, ch_outer/2+1, ch_floor+ch_inner_h+40]);
}
