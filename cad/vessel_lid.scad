// ─────────────────────────────────────────────────────────────
//  Vessel lid — sits on a cut PET bottle and carries the Mariotte
//  standpipe, the fog port and the vents. With a cut bottle as the
//  chamber, this plus the gasket is the ENTIRE print.
//
//  The skirt is a shallow CONE, so it self-centres on any bottle
//  between vessel_od and vessel_od + skirt_slop. You do not have to
//  hit the diameter exactly, which matters because bottle diameters
//  vary by brand.
//
//  PRINT PLATE-TOP-DOWN: skirt, standpipe and fog collar all rise
//  from the bed. No overhangs.
//
//  NOTE the build order below. The skirt's bore is a full cone, so
//  subtracting it from everything at once slices the standpipe in
//  half and leaves its lower 53 mm floating. The standpipe is
//  therefore unioned AFTER the skirt is hollowed.
// ─────────────────────────────────────────────────────────────
include <params.scad>

sp_len     = vessel_cut_h - water_level;   // reaches down to the held level
plate_od   = vessel_od + skirt_slop + 2*skirt_wall + 4;
fog_off    = -(vessel_od/2 - fog_port_d/2 - 6);   // opposite the standpipe
fog_collar = 10;
vent_r     = vessel_od/2 - 7;

module vessel_lid() {
    difference() {
        union() {
            difference() {
                union() {
                    cylinder(d = plate_od, h = plate_t);
                    translate([0, 0, -skirt_h])
                        cylinder(d1 = vessel_od + skirt_slop + 2*skirt_wall,
                                 d2 = vessel_od + 2*skirt_wall, h = skirt_h + eps);
                    translate([fog_off, 0, plate_t - eps])
                        cylinder(d = fog_port_d + 2*fog_boss_wall, h = fog_collar);
                }
                // skirt bore — the bottle rim seats here
                translate([0, 0, -skirt_h - eps])
                    cylinder(d1 = vessel_od + skirt_slop, d2 = vessel_od,
                             h = skirt_h + eps);
            }
            // standpipe, added after the skirt bore so it survives
            translate([sp_offset, 0, -sp_len])
                cylinder(d = sp_od, h = sp_len + plate_t);
        }
        // standpipe bore: neck socket above, air/water path below
        translate([sp_offset, 0, -sp_len - eps])
            cylinder(d = sp_bore, h = sp_len + plate_t + 2*eps);
        // fog port
        translate([fog_off, 0, -eps])
            cylinder(d = fog_port_d, h = plate_t + fog_collar + 2*eps);
        // vents — without these the siphon stalls
        for (i = [0 : vent_n - 1])
            rotate([0, 0, i*360/vent_n])
                translate([vent_r, 0, -eps])
                    cylinder(d = vent_d, h = plate_t + 2*eps);
        // cable notch through the skirt
        translate([-cable_notch_w/2, -plate_od/2 - eps, -skirt_h - eps])
            cube([cable_notch_w, plate_od/2 - vessel_od/2 + skirt_wall + 4,
                  skirt_h + plate_t + 2*eps]);
    }
}
vessel_lid();
