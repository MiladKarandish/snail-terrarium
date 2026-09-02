// TPU (XFlex) washer. The bottle's support ring presses onto this,
// sealing the neck so air can only enter via the standpipe bore.
include <params.scad>
difference() {
    cylinder(d = gasket_od, h = gasket_t);
    translate([0,0,-eps]) cylinder(d = gasket_id, h = gasket_t + 2*eps);
}
