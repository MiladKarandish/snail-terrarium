// Interference solid: lid seated on the chamber. Must be empty.
include <params.scad>
use <chamber.scad>
use <lid.scad>
intersection() {
    chamber();
    translate([lid_pos_xy, lid_pos_xy, lid_pos_z]) lid();
}
