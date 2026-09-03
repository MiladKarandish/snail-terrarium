// ─────────────────────────────────────────────────────────────
//  Automated Snail Terrarium — shared parameters
//  Change a number, run ../.venv/bin/python verify.py, get STLs.
//
//  CONFIRMED = from a datasheet / vendor spec
//  ASSUMED   = safe default, verify before ordering prints
//  MEASURE   = must be measured first
// ─────────────────────────────────────────────────────────────

// ── Mist maker module ────────────────────────────────────────
// MEASURED on the actual unit, 2026-09-03, in a bowl of water.
// The vendor spec misled on both numbers that mattered:
//   Module height IS 45 mm (measured) - the spec was right.
//   "water level 20-75 mm" is measured from the ceramic disc down in
//   the well, NOT from the base, which is why it reads so oddly.
//
// All depths below are TOTAL DEPTH FROM THE VESSEL FLOOR, with the
// module standing on that floor:
//   41 mm   safety probe closes, unit starts
//   42-50   works; no meaningful output difference across it
//   >50     labours and throws droplets instead of fog
// Note the module is 45 mm tall, so at the working level its top rim
// stands slightly PROUD of the water - only the recessed disc is
// covered. That is normal for this unit.
//
// The unit carries its own level probe, so it CANNOT run dry. That
// removes the failure mode the earlier designs guarded against.
mm_module_od      = 45;
mm_module_h       = 45;    // MEASURED total height
mm_cable_od       = 3.8;
water_start       = 41;    // probe closes here
water_best_lo     = 42;
water_best_hi     = 45;
water_struggle    = 50;
// ONE feed port, positioned by its TOP EDGE. The siphon stabilises where
// air can just get in, which is the top of the opening - not its centre.
// A Ø14 port centred at the level would hold the water 7 mm too high.
//
// The level is then fixed, and the module is what moves: a printed spacer
// under it raises the disc and probe, which is the same thing as lowering
// the water. 3 mm of level separation is far smaller than any usable port
// bore, so two ports would simply merge into one slot.
//   44 mm  cap OFF   - exactly the range measured (best 42-45), 3 mm over
//                      the probe and 6 mm under the splashing point
//   47 mm  cap ON    - submerges the 45 mm module, 3 mm under splashing
// The cap is removable, and the water test was run without it, so the
// 47 mm figure is inferred rather than measured. This way that question
// does not have to be settled before committing 78 g of PETG.
water_hold        = 47;    // port TOP edge; cap ON, module sitting flat
spacer_t          = 3.0;   // cap OFF: spacer raises the module -> 44 effective
spacer_d          = 44;
water_band        = water_struggle - water_start;   // only 10 mm

// ── Water column ─────────────────────────────────────────────
// A 10 mm usable band means an UNREGULATED vessel needs refilling
// every ~3 days. That is why the bottle feed is required here, and
// why dropping it earlier was wrong: it was dropped on the strength
// of a 55 mm band that the real part does not have.
mm_recess_d       = 1.5;
water_level       = water_hold;
fog_headspace     = 42;   // also lifts the rim flange clear of the fan pad

// ── Chamber (cylindrical: least wall for a given volume) ──────
// The module is Ø45 AND 45 mm tall, and the water sits at 44 mm - so a
// standpipe hanging INSIDE beside the module would need a Ø118 bore to
// clear it. The feed therefore has to run OUTSIDE the chamber wall and
// enter through a port at the water line. That keeps the bore at 60.
ch_id             = 60;
ch_wall           = 1.6;   // EXACTLY 4 perimeters at a 0.4 mm nozzle, so the
                           // wall is 100% shell with no infill inside it.
                           // A thicker wall is WORSE: at 2 perimeters a 2.0 mm
                           // wall is 0.8 mm shell + 1.2 mm of 20% infill, which
                           // weeps. Keep this a multiple of 0.4.
ch_floor          = 2.4;
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
// The bottle SCREWS in, using its own cap. A standard PET cap is
// captured in a pocket in the printed boss and drilled through: the
// thread is then a real injection-moulded one, and the seal is the
// cap's own liner against the bottle rim - exactly what it is for.
// Printing a PCO-1881 thread instead is a 3-start profile and a
// coin toss on FDM tolerances for something that must not leak.
cap_od            = 31.0;  // MEASURE your bottle cap across the knurl
cap_h             = 14.0;  // MEASURE cap height
cap_fit           = 0.35;  // press fit; a smear of glue makes it permanent
sp_bore           = 28.6;  // legacy, retained for the superseded parts
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
// Air in and fog out are in SERIES, so vent area must be >= port area
// or the vents throttle the outlet. Sized to ~1.15x the port.
vent_d            = 12;
vent_n            = 5;
vl_vent_d         = 13;    // vessel_lid: fewer, larger, dodging the standpipe
vl_vent_n         = 4;
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
// A bottle has no locating recess, so the module's top face is simply
// its own height above the floor.
// A cut bottle still works IF the level is regulated (vessel_lid).
// Without regulation it is not viable: a 10 mm band on a Ø88 bottle is
// ~3 days. simple_lid has been retired for that reason.
vessel_cut_h      = 80;    // water held at 43 + ~35 mm headspace
skirt_h           = 14;
skirt_wall        = 2.0;
skirt_slop        = 5;     // cone self-centres over od-0 .. od+slop
plate_t           = 3.0;
lip_h             = 6.0;   // short locating lip; a 14 mm skirt is wasted height
fog_collar_h      = 6.0;
// Endurance with NO reservoir: the level simply drifts down the band.

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
echo(str("water held at ", water_hold, " mm from the floor (band ", water_start, "-", water_struggle, ")"));
echo(str("bottle ", bottle_ml, " ml -> ", bottle_ml/20, " days at 20 ml/day"));

// ── External feed (Mariotte) ─────────────────────────────────
// A conduit up the OUTSIDE of the wall, entering through a port at
// the water line. The port height sets the level: water leaves the
// bottle until it seals the port, then no air can enter and it stops.
// The bottle can therefore sit at any convenient height above.
feed_id           = 12;   // carries ~20 ml/DAY; 20 mm was absurd
feed_wall         = 2.4;  // 6 perimeters
feed_od           = feed_id + 2*feed_wall;
// Must satisfy BOTH:
//   feed_centre - feed_id/2 > ch_od/2  so the conduit bore does not open
//                                      into the chamber except at the port
//   feed_centre - feed_od/2 < ch_od/2  so the two outer walls fuse
feed_centre       = 38.8;
feed_port_d       = 14;
feed_top          = 86;    // where the bottle socket sits

// ── Fan mount — deliberately generic ─────────────────────────
// Fan sizes vary by what is actually in stock, so the body carries one
// pad drilled for a 40 mm fan (32 mm pitch). Smaller fans mount via a
// small adapter plate rather than a reprint of the whole body.
fan_pad           = 42;   // just clears the 32 mm screw pitch
fan_bore          = 30;
fan_pitch         = 32;
fan_screw_d       = 3.2;
fan_z             = 64;

// ── Nozzle ───────────────────────────────────────────────────
nozzle_d          = 25;
nozzle_wall       = 2.0;
nozzle_len        = 14;
nozzle_z          = 64;

fan_pad_t         = 3.0;
socket_od         = cap_od + 2*cap_fit + 5;   // 2.5 mm wall around the pocket
