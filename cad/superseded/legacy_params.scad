// Parameters that only the superseded parts still use.
//
// They were removed from ../params.scad when the designs that needed
// them were retired, so that the live file describes exactly one
// build and nothing else. Kept here so these files still open and
// render for reference. DO NOT PRINT ANYTHING FROM THIS DIRECTORY -
// see README.md.
include <../params.scad>

// The module was thought to sit 1.5 mm down in a locating recess.
mm_recess_d       = 1.5;
// The water band as it was believed to be before the module was
// measured and MIST-MAKER.md was written: 41-50 mm, not 20-75.
water_start       = 41;
water_best_lo     = 42;
water_best_hi     = 45;
water_struggle    = 50;
plain_ml          = 445;

// Internal Mariotte standpipe, hung from the lid beside the module.
// Impossible once the module turned out to be 45 mm TALL as well as
// Ø45: a pipe alongside it needs a Ø80 bore.
sp_bore           = 28.6;
sp_wall           = 1.6;
sp_od             = sp_bore + 2*sp_wall;
sp_offset         = 16;
sp_socket_depth   = 18;

// TPU neck washer, replaced by the captured bottle cap's own liner.
gasket_od         = 36;
gasket_id         = 29;
gasket_t          = 2.0;

// Fog port as a hole in a lid, before the fan and nozzle existed.
fog_port_d        = 25;
fog_port_z        = 70;
fog_boss_len      = 10;
fog_boss_wall     = 2.0;
fog_collar_h      = 6.0;

// Cut-PET-bottle vessel and its lid.
vessel_od         = 90;
vessel_cut_h      = 80;
vessel_lid        = 1;
skirt_h           = 14;
skirt_wall        = 2.0;
skirt_slop        = 5;
plate_t           = 3.0;
lip_h             = 6.0;
vl_vent_d         = 13;
vl_vent_n         = 4;

// Cable notch in the rim, replaced by a bung hole in the lid: a
// notch leaks fog down the outside of the chamber.
cable_notch_w     = mm_cable_od + 3;
cable_notch_h     = 6;

// Printed cap-chamber alternative.
cc_id    = 58;
cc_wall  = 1.6;
cc_od    = cc_id + 2*cc_wall;
cc_water = mm_module_h + 25;
cc_head  = 40;
cc_h     = cc_water + cc_head;
cc_flange = 3;

// Lid vents and placement, from before the fan/nozzle pair existed.
vent_d            = 12;
vent_n            = 5;
water_level       = water_hold;
lid_pos_z         = ch_floor + ch_inner_h;
lid_pos_xy        = 0;
fog_headspace_old = 42;

// cap_chamber.scad selects its part with this.
PART              = "cup";
