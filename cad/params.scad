// ─────────────────────────────────────────────────────────────
//  Automated Snail Terrarium — shared parameters
//  Change a number, run ../.venv/bin/python verify.py, get STLs.
//
//  CONFIRMED = from a datasheet / vendor spec
//  ASSUMED   = safe default, verify before ordering prints
//  MEASURE   = must be measured first
// ─────────────────────────────────────────────────────────────

// ── Mist maker module ────────────────────────────────────────
// CONFIRMED (eshop.eca.ir, 550 ml/h unit):
//   24 V DC · >=550 ml/h · effective water level 20-75 mm
//   head dia 45 mm · module height 45 mm · 5-45 C
//   cable 1400 +/-20 mm, 3.8 mm OD · DC female 5.5 x 2.1 mm
mm_module_od      = 45;
mm_module_h       = 45;
mm_cable_od       = 3.8;
water_min         = 20;
water_max         = 75;

// ── Water column ─────────────────────────────────────────────
// A Mariotte (inverted-bottle) reservoir holds the level CONSTANT,
// so it is parked near the BOTTOM of the band rather than filled to
// the top. That is what makes this build cheap: the water column
// drops from 118 mm to 68.5 mm, and the chamber shrinks with it.
mm_recess_d       = 1.5;
module_top        = mm_module_h - mm_recess_d;
water_hold        = 23;    // 3 mm above the 20 mm minimum
water_level       = module_top + water_hold;
fog_headspace     = 50;

// ── Chamber (cylindrical: least wall for a given volume) ──────
ch_id             = 72;    // 45 mm module + standpipe clearance
ch_wall           = 1.6;   // EXACTLY 4 perimeters at a 0.4 mm nozzle, so the
                           // wall is 100% shell with no infill inside it.
                           // A thicker wall is WORSE: at 2 perimeters a 2.0 mm
                           // wall is 0.8 mm shell + 1.2 mm of 20% infill, which
                           // weeps. Keep this a multiple of 0.4.
ch_floor          = 3.0;
ch_od             = ch_id + 2*ch_wall;
// A 1.6 mm wall leaves too narrow a ledge for the lid, so thicken just
// the top few mm. Costs ~3 cm3 and stiffens the rim of a thin tube.
ch_flange_w       = 3.0;
ch_flange_h       = 4.0;
ch_flange_od      = ch_od + 2*ch_flange_w;
ch_inner_h        = water_level + fog_headspace;

// ── Fog outlet ───────────────────────────────────────────────
fog_port_d        = 25;    // smaller port = lower chamber = fewer layers
fog_port_z        = water_level + 23;
fog_boss_len      = 10;
fog_boss_wall     = 2.0;

// ── Mariotte standpipe ───────────────────────────────────────
// Its BOTTOM OPENING sets the water level. Water leaves the bottle
// until it seals this opening; air can then no longer enter, so
// flow stops. The level is independent of how full the bottle is.
// The bore is uniform so the lid prints without a single overhang.
sp_bore           = 28.6;  // PCO-1881 neck (27.4 mm) + clearance
sp_wall           = 1.6;  // 4 perimeters, same reason
sp_od             = sp_bore + 2*sp_wall;
sp_offset         = 16;    // off-centre, clear of the disc's plume
sp_socket_depth   = 18;    // how far the bottle neck inserts
gasket_od         = 36;    // TPU washer under the bottle's support ring
gasket_id         = 29;
gasket_t          = 2.0;

// ── Lid ──────────────────────────────────────────────────────
// Seats on the chamber rim; a spigot locates it in the bore.
// PRINT PLATE-TOP-DOWN: spigot and standpipe both rise from the
// bed, so there are no overhangs and the seat is a bed-flat face.
// No fill port: you refill by lifting out the bottle.
lid_t             = 4.0;
lid_spigot_h      = 5.0;
lid_fit           = 0.30;
lid_finger_d      = 20;
lid_rim_seat      = (ch_flange_od - ch_id)/2;
vent_d            = 5;
vent_n            = 5;
cable_notch_w     = mm_cable_od + 3;
cable_notch_h     = 6;
lid_pos_z         = ch_floor + ch_inner_h;

// ── Cut-bottle vessel (replaces the printed chamber) ─────────
// The chamber is a PET bottle cut into a cup. Free, watertight, and
// transparent so the level is visible. Use a STILL water / juice
// bottle: carbonated bases are petaloid (5 domed feet) and the
// atomiser would sit tilted.
// The lid does not need to seal here - water sits at 66.5 mm and the
// lid at the cut, so the joint is never wet. Only the bottle-neck
// socket seals.
vessel_od         = 90;    // MEASURE bottle OD at the cut (1.5 L ~ 88-92)
vessel_cut_h      = 120;   // cut this high above the inside floor
skirt_h           = 14;
skirt_wall        = 2.0;
skirt_slop        = 5;     // cone self-centres over od-0 .. od+slop
plate_t           = 3.0;

// ── Reservoir bottle ─────────────────────────────────────────
bottle_ml         = 500;   // ~25 days at 20 ml/day
bottle_body_d     = 66;    // ASSUMED 0.5 L PET body diameter - MEASURE

// ── Terrarium ────────────────────────────────────────────────
tank_w = 460; tank_d = 280; tank_h = 370;
glass_t = 5.0;             // MEASURE - only needed for the bracket

// ── Rendering ────────────────────────────────────────────────
$fa = 2; $fs = 0.4;
eps = 0.01;

module teardrop(d, len) {          // support-free horizontal hole, tip UP
    r = d/2;
    rotate([-90, 0, 0]) linear_extrude(len) union() {
        circle(r = r);
        polygon([[-r*0.707, -r*0.707], [r*0.707, -r*0.707], [0, -r*1.42]]);
    }
}

// ── Capacity report ──────────────────────────────────────────
echo(str("chamber OD ", ch_od, " x ", ch_floor+ch_inner_h, " mm tall"));
echo(str("water held at ", water_level, " mm = ", water_hold,
         " mm above the module top (band ", water_min, "-", water_max, ")"));
echo(str("bottle ", bottle_ml, " ml -> ", bottle_ml/20, " days at 20 ml/day"));
