// ─────────────────────────────────────────────────────────────
//  Simple lid — for a cut PET bottle used with NO reservoir.
//
//  The module's 20-75 mm band is 55 mm wide, so the level may just
//  drift down it between refills: a Ø88 bottle holds ~17 days, a
//  2 L (Ø105) ~23. That makes the Mariotte reservoir unnecessary,
//  and with it the standpipe, the neck seal, the second bottle and
//  50 mm of part height.
//
//  Fog port is CENTRAL - with no standpipe to dodge, there is no
//  reason to offset it - so the vents ring it symmetrically.
//
//  PRINT PLATE-TOP-DOWN. Lip and collar rise from the bed.
// ─────────────────────────────────────────────────────────────
include <params.scad>

plate_od  = vessel_od + skirt_slop + 2*skirt_wall + 4;
vent_r    = fog_port_d/2 + fog_boss_wall + vent_d/2 + 4;

module simple_lid() {
    difference() {
        union() {
            cylinder(d = plate_od, h = plate_t);
            // short conical locating lip, self-centring like the skirt
            translate([0, 0, -lip_h])
                cylinder(d1 = vessel_od + skirt_slop + 2*skirt_wall,
                         d2 = vessel_od + 2*skirt_wall, h = lip_h + eps);
            translate([0, 0, plate_t - eps])
                cylinder(d = fog_port_d + 2*fog_boss_wall, h = fog_collar_h);
        }
        translate([0, 0, -lip_h - eps])
            cylinder(d1 = vessel_od + skirt_slop, d2 = vessel_od, h = lip_h + eps);
        // fog port, central
        translate([0, 0, -lip_h - eps])
            cylinder(d = fog_port_d, h = lip_h + plate_t + fog_collar_h + 2*eps);
        // make-up air vents, sized to match the port
        for (i = [0 : vent_n - 1])
            rotate([0, 0, i*360/vent_n])
                translate([vent_r, 0, -eps])
                    cylinder(d = vent_d, h = plate_t + 2*eps);
        // cable notch through the lip
        translate([-cable_notch_w/2, -plate_od/2 - eps, -lip_h - eps])
            cube([cable_notch_w, plate_od/2 - vessel_od/2 + skirt_wall + 4,
                  lip_h + plate_t + 2*eps]);
    }
}
simple_lid();
