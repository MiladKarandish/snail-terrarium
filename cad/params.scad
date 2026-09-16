// ─────────────────────────────────────────────────────────────
//  Automated Snail Terrarium — shared parameters
//  Change a number, run ../.venv/bin/python verify.py, get STLs.
//
//  Every dimension here is either MEASURED, taken from
//  MIST-MAKER.md, or DERIVED from those. Nothing is guessed.
//  Anything still to be confirmed says MEASURE.
// ─────────────────────────────────────────────────────────────

// ── Mist maker module ────────────────────────────────────────
// Source: MIST-MAKER.md (ECA 3791 / CL-24 class, 550 mL/h).
// The module is ONE potted assembly, Ø45 x 45 mm, with a fixed
// splash collar. It has no removable cap: the earlier "cap ON /
// cap OFF" pair of water levels described a part that does not
// exist, and both are gone.
//
// Depths are TOTAL WATER DEPTH measured from the surface the
// module stands on, which is the chamber floor:
//   41      probe closes, unit starts
//   42-47   optimal - 20-25 mm of water over the recessed disc
//   >50     hydrostatic head damps cavitation; throws droplets
// The module carries its own conductivity probe, so it CANNOT
// run dry. Every dry-run guard in the earlier designs was
// solving a problem the hardware had already solved.
mm_module_od      = 45;
mm_module_h       = 45;
mm_cable_od       = 3.8;
// The cable ships with a sliding conical rubber bung, meant to
// seal against a chamfered hole. The lid uses it - see LID.
bung_d_max        = 14.0;
bung_d_min        = 11.0;

water_probe       = 41;    // below this the unit shuts off
water_lo          = 42;    // optimal band, lower
water_hi          = 47;    // optimal band, upper
water_choke       = 50;    // above this it splatters instead of fogging

// ── Water level ──────────────────────────────────────────────
// The level is set by ONE feed port, positioned by its APEX: the
// siphon stabilises where air can just get in, which is the top
// of the opening, not its centre.
//
// Park it in the MIDDLE of the optimal band, not at an edge. The
// port is a printed feature and the Mariotte meniscus adds a
// millimetre or two of its own, so the target needs margin on
// both sides:
//   46.0 mm  ->  5.0 mm over the probe, 4.0 mm under splashing
// and air has to bubble INTO the port to let water out, which costs
// ~2.5 mm of head on a Ø12 port, so the level actually settles
// somewhere around 43.5-46.0. That whole range is inside the band,
// and the low end still clears the probe by 2.5 mm. Targeting the
// arithmetic centre of the band instead put the low end at 42.0,
// which is 1.0 mm off shutting the unit down.
// Earlier revisions held 47 mm, which is the top of the band and
// 3 mm from choking - no margin at all in the direction that
// actually stops the fog.
water_hold        = 46.0;
// Optional trim: a printed disc under the module raises it,
// which is the same as lowering the water. Fit it only if the
// real level lands high (visible splashing, coarse droplets).
trim_spacer_t     = 2.0;
trim_spacer_d     = 43;    // inside the module footprint

// ── Chamber ──────────────────────────────────────────────────
// Cylindrical: least wall for a given volume, and the fog plume
// is round anyway.
ch_id             = 60;    // Ø45 module + 7.5 mm annulus for fog and feed
ch_wall           = 1.6;   // EXACTLY 4 perimeters at a 0.4 mm nozzle, so the
                           // wall is 100% shell with no infill inside it.
                           // A thicker wall is WORSE unless it is also a
                           // multiple of 0.4: at 2 perimeters a 2.0 mm wall
                           // is 0.8 mm shell + 1.2 mm of 20% infill, which
                           // weeps. Keep this a multiple of 0.4.
ch_od             = ch_id + 2*ch_wall;
ch_floor          = 3.2;   // 8 perimeters' worth. This is the largest flat
                           // face under water; it is not the place to save
                           // 0.8 mm.

// Locating lugs for the module, INSIDE the chamber and standing
// UP from the floor. The previous revision cut a Ø46.5 pocket
// into the UNDERSIDE of the floor instead, which located nothing
// and left a 0.9 mm membrane holding the water.
// Gaps between the lugs let the module's cable exit at any angle.
lug_id            = 47.5;  // 1.25 mm clearance per side on a Ø45 module
lug_w             = 2.0;
lug_h             = 2.5;
lug_n             = 4;
lug_arc           = 42;    // degrees of each lug; the rest is gap

// Rim flange. A 1.6 mm wall is too narrow a ledge for the lid, so
// thicken the top few mm. The step out to the flange is a 45°
// CONE, not a square ledge: a 2.5 mm horizontal overhang running
// right round the part droops on every printer.
ch_flange_w       = 2.5;
ch_flange_od      = ch_od + 2*ch_flange_w;
ch_flange_cham    = ch_flange_w;          // 45°
ch_flange_h       = ch_flange_cham + 2.5;

// ── Fog outlet and fan ───────────────────────────────────────
// Air in through the fan, fog out through the nozzle, in series.
// The INLET must be the larger of the two or it throttles the
// outlet, so the fan bore is sized above the nozzle bore.
duct_clear        = 6.0;   // clear air under the lowest duct opening
// Sized around a hose you can actually buy: the spigot OD is the
// hose's ID, so nozzle_d is what is left after the wall.
nozzle_hose_id    = 25;    // standard 25 mm ID pond/aquarium hose
hose_engage       = 15;    // clear spigot the hose must be able to sit on:
                           // 0.6x the bore, enough to clamp behind
hose_wall         = 3.0;   // a 25 mm ID hose is about this thick, and it is
                           // the hose's OUTER BACK CORNER that fouls the
                           // barrel first - not its bore
nozzle_wall       = 2.5;
nozzle_d          = nozzle_hose_id - 2*nozzle_wall;   // Ø20 fog bore
// TILTED 45° UP, and that is not styling. A teardrop fixes a
// horizontal HOLE, because the material above it can be shaped.
// It cannot fix a horizontal PROTRUSION: the underside of a round
// spigot sticking out of a wall is a 90° overhang whatever its
// cross-section, and cutting it back to 45° leaves a V that no
// hose will seal on. An inclined cylinder has no such problem -
// every normal on its underside sits at exactly the tilt angle -
// so at 45° the whole spigot, bore included, is self-supporting
// and still perfectly round for the hose.
// Fog rises into it, and condensate runs back down into the
// chamber instead of dripping out of the hose.
nozzle_tilt       = 45;
fan_bore          = 26;    // > nozzle_d: inlet must not throttle the outlet
// One pad, drilled for BOTH 30 mm (24 mm pitch) and 40 mm (32 mm
// pitch) fans, because what is in stock varies. The screw holes
// are BLIND in the pad and must never reach the chamber: the
// previous revision ran them 12 mm deep, straight through the
// wall and into the water.
fan_pad_t         = 3.0;
// Three bolt patterns, because which fan actually does the job through
// a Ø26 bore is a question you answer by trying them. Diameter is not
// what decides it - everything goes through the same bore and out the
// same Ø20 nozzle, so the fan's STATIC PRESSURE matters and its airflow
// rating does not. A 30 mm at 12 V can beat a 50 mm at 5 V here.
//
// 25 mm fans (20 mm pitch) are deliberately NOT drilled: the barrel
// curves closest to the pad at narrow pitches, and a 5 mm screw there
// leaves 1.3 mm of wall against the 1.6 mm limit. 60 mm and up cannot
// work at all - the pad would wrap past the barrel and push ch_h up.
fan_pitch_30      = 24;
fan_pitch_40      = 32;
fan_pitch_50      = 40;
fan_pitch_max     = max(fan_pitch_30, fan_pitch_40, fan_pitch_50);
fan_pitch_min     = min(fan_pitch_30, fan_pitch_40, fan_pitch_50);
fan_screw_d       = 3.2;
// The pad's flat face does NOT begin at its bottom edge. The 45°
// chamfer under it - which is there so the underside is not the one
// horizontal ceiling on the part - eats into that face from below,
// and by more the further out you go in y: the face only exists once
// the cone has grown past sqrt((ch_od/2 + fan_pad_t)^2 + y^2).
//
// At 42 mm the pad lost 3.0 mm of face at the centreline and 6.5 mm
// at the 40 mm fan's bolt circle, which put its lower two screws
// 1.75 mm ONTO the chamfer. They had no flat seat: a gap under the
// fan and two screws loaded in bending. So the height is derived
// from the widest pattern the pad claims to take, not picked.
fan_seat          = 1.6;   // flat all round a screw before the chamfer
fan_face_r        = sqrt(pow(ch_od/2 + fan_pad_t, 2) + pow(fan_pitch_max/2, 2));
fan_pad           = fan_pitch_max + 2*fan_seat + 2*(fan_face_r - ch_od/2);
// 5 mm, not 8: at the 24 mm bolt pitch the barrel wall is closest to
// the pad, and a deeper hole comes out inside the water.
fan_screw_depth   = 5.0;

// Both ducts share a centreline, high enough that the lowest
// opening clears the water by duct_clear.
duct_z            = ch_floor + water_hold + duct_clear + fan_bore/2;

// ── Chamber height, DERIVED ──────────────────────────────────
// Tall enough that the nozzle and the fan pad both sit clear of
// the flange, and no taller. Deriving it beats guessing a
// headspace and checking afterwards.
water_z           = ch_floor + water_hold;        // absolute water surface
nozzle_od         = nozzle_hose_id;
// A tilted spigot leaves a round barrel unevenly: its top side is buried
// far deeper than its bottom, and the SHORT side is what the hose end
// stops against. Clearing the barrel costs (hose outer radius)*tan(tilt)
// of spigot before any of it can be used, so the length is derived from
// the engagement wanted rather than picked. At 18 mm it looked generous
// on screen and gave the hose 2.5 mm to sit on.
nozzle_len        = hose_engage + (nozzle_od/2 + hose_wall)*tan(nozzle_tilt);
// Placed by where its bore breaks through the wall, so the bottom
// of the opening clears the water by duct_clear.
nozzle_exit_z     = water_z + duct_clear + (nozzle_d/2)/cos(nozzle_tilt);
nozzle_axis_z     = nozzle_exit_z - (ch_od/2)*tan(nozzle_tilt);
nozzle_top        = nozzle_exit_z + nozzle_len*sin(nozzle_tilt)
                                  + (nozzle_od/2)*cos(nozzle_tilt);
fan_pad_top       = duct_z + fan_pad/2;
feature_clear     = 3.0;
ch_h              = max(nozzle_top, fan_pad_top) + feature_clear + ch_flange_h;
ch_inner_h        = ch_h - ch_floor;
fog_headspace     = ch_h - water_z;

// ── Mariotte feed ────────────────────────────────────────────
// A conduit up the OUTSIDE of the wall, entering through a port
// at the water line. Water leaves the bottle until it seals that
// port; air can then no longer get in, so flow stops. The level
// is independent of how full the bottle is, and nothing measures
// anything.
//
// An internal standpipe is not an option: the module is Ø45 AND
// 45 mm tall and the water sits at 44.5, so a pipe hanging beside
// it needs a Ø80 bore. Wall area goes with the square of that.
feed_id           = 12;   // carries ~9 mL/min at full output, and wide
                          // enough that capillary rise does not move the
                          // level: a narrow bore is a level ERROR, not a
                          // saving. Also wide enough for air to bubble up
                          // while water runs down (counter-flow stalls
                          // below ~6 mm).
feed_wall         = 2.4;  // 6 perimeters
feed_od           = feed_id + 2*feed_wall;
// Far enough out that the lid can be relieved for the conduit and
// still cover the bore; close enough that the web to the barrel
// stays short.
feed_centre       = 41;
// The conduit does NOT rely on two cylinders grazing each other.
// It is joined to the barrel by a solid web, wide enough that the
// port is bored through material rather than through a cusp - if
// the port broke out of the side of the web, air would reach the
// conduit directly and the Mariotte would simply drain.
feed_web_w        = 18;   // > feed_port_d + 2 walls
feed_rib_w        = 8;    // above the port the web is only carrying load
feed_web_x        = 26;   // web root, well inside the bore (trimmed by it)
feed_port_d       = 12;   // teardrop; apex sits ON the water line
feed_web_top      = water_z + feed_port_d + 6;
// The rib stops FLUSH WITH THE RIM. Above that only the round conduit
// carries on, because the lid can only be relieved for a circle - a
// slab beside it would have to be notched out of the seat as well.
feed_rib_top      = ch_h;
// The port is bored from inside the chamber wall to just short of
// the conduit bore's far wall. It must never punch through it.
feed_port_x0      = ch_id/2 - 3;
feed_port_len     = (feed_centre + feed_id/2 - 3) - feed_port_x0;

// Bottle socket. A standard PET cap is captured in a pocket and
// drilled through: the thread is then a real injection-moulded
// one and the seal is the cap's own liner against the bottle rim.
// Printing a PCO-1881 thread instead is a 3-start profile and a
// coin toss on FDM tolerances for something that must not leak.
//
// The socket is cut for the STANDARDS, not for one measured cap.
// Caps vary; the finishes they are moulded to do not. Across the
// closures a 0.5 L bottle actually carries:
//
//   28 mm PCO-1881   soda, 2009-    cap Ø30.4 ±0.3   11-13 mm tall
//   28 mm PCO-1810   soda, older    cap Ø31.0 ±0.4   14-17 mm tall
//   29/25, 30/25     still water    cap Ø29.5-31      8-12 mm tall
//
// The DIAMETER spread is under 2 mm. The HEIGHT spread is 9 mm,
// and height was the one that bit: pocket depth used to be tied
// to cap height, and the top of the pocket is the face the
// bottle's neck support ring lands on. A 16.5 mm cap put that
// ring 0.26 mm INSIDE the socket and the bottle could not seat.
cap_od_min        = 29.5;
cap_od_max        = 31.4;
cap_h_min         = 8.0;
cap_h_max         = 17.0;
cap_floor_t       = 1.5;   // cap's own top wall; the bottle's seal
                           // face lands this far above the pocket floor
// ISBT PCO-1881, drawing 3784253-21: the neck support ring is
// Ø33.00 ±0.15 and sits H = 15.24 ±0.15 below the sealing face.
// The ring is WIDER than the cap, so it can never enter the
// pocket - it has to pass the socket in a counterbore above it.
neck_ring_d       = 33.2;   // worst case across the finishes
neck_ring_h       = 15.24;  // seal face to support ledge
// Straight neck between the support ring and the shoulder - the neck
// grippers on a filling line need it. NOT in the ISBT drawing, which
// stops at the ring; this is the figure the assembly model has always
// used, and it is the only unsourced number in the neck.
neck_straight     = 4.5;

// The pocket grips the bottom of ANY of those caps and then opens
// out. Because a cap must clear the support ring to screw on at
// all, the ring is ALWAYS at or above the cap's rim - so a ribbed
// section no taller than the shortest cap can never be in its
// way. That is a structural argument, not a measured clearance.
cap_pocket_id     = cap_od_max + 1.0;   // Ø32.4, every standard cap drops in
// ...below it, not flush WITH it: at cap_grip_h = cap_h_min the grip's
// top face and the lowest possible ring's underside land on the same
// z, and the Ø33.2 ring rests on the Ø32.4 bore's edge. A bound is
// not a clearance. 1 mm of margin, and 7 mm still grips the shortest
// cap over most of its height.
cap_grip_margin   = 1.0;
cap_grip_h        = cap_h_min - cap_grip_margin;
cap_rib_n         = 6;     // anti-rotation ribs, so the cap cannot spin
cap_rib_d         = 1.2;   // when the bottle is screwed in or out. They
                           // crush 0.2 mm on the widest cap and key the
                           // epoxy on the narrowest - the epoxy is what
                           // retains AND seals, as it always was.
// Counterbore: wide enough that the support ring passes whatever
// the cap height turns out to be. A hole that WIDENS as it rises
// has no overhang, so this costs nothing in printability.
neck_bore_id      = neck_ring_d + 1.3;  // Ø34.5
socket_wall       = 3.2;
socket_od         = neck_bore_id + 2*socket_wall;
pocket_depth      = 16.0;  // pocket floor to socket top
// A representative cap, for the ASSEMBLY DRAWING only. The
// printed part does not depend on either number any more.
cap_od            = 30.4;
cap_h             = 12.0;

// The socket has to sit ABOVE the lid: it is Ø41 on a 41 mm
// offset, so it overlaps any lid big enough to cover a Ø60 bore.
// The slim conduit below it is relieved in the lid instead.
// Enough that the lid can be lifted clear of its own spigot BEFORE
// the socket flare starts, or it cannot come off at all.
lid_clear         = 4.0;
// The flare is DERIVED from the angle rather than set to a height:
// a wider socket needs a taller cone to stay self-supporting, and
// hardcoding 12 mm quietly took this to 45.1° when socket_od grew.
socket_cone_ang   = 42;    // from vertical; 45 is the printable limit
socket_cone_h     = (socket_od - feed_od)/2 / tan(socket_cone_ang);

// ── Lid ──────────────────────────────────────────────────────
// Seats on the chamber rim; a spigot ring locates it in the bore.
// PRINT PLATE-TOP-DOWN: the spigot rises from the bed, the cable
// countersink widens as it rises, and the seating face is a flat
// top skin. There is not one overhang on the part. mister.scad
// exports the STL already lying that way.
lid_t             = 4.0;
lid_spigot_h      = 5.0;
lid_spigot_w      = 2.0;
lid_fit           = 0.30;
lid_finger_d      = 18;
// Relief so the lid clears the feed conduit. It opens to the
// lid's edge, so the lid lifts a millimetre and slides sideways
// off the column - it does not have to pass the socket above.
lid_feed_clear    = 0.8;
// The module's cable leaves through the LID, not through a notch
// in the rim. A hole in the lid is vertical in the print, so it
// comes out round and takes the bung the module already ships
// with; a rim notch leaks fog down the outside of the chamber.
cable_hole_d      = 11.5;      // bung seats in the countersink above this
cable_cs_d        = bung_d_max + 1.0;
cable_cs_depth    = 2.0;
cable_hole_r      = ch_id/2 - cable_cs_d/2 - 2;   // countersink stays over the bore

// The flare starts above the seated lid, so nothing above the
// conduit blocks the lid coming off.
socket_cone_z     = ch_h + lid_t + lid_clear;
socket_top        = socket_cone_z + socket_cone_h + 2 + pocket_depth;
pocket_z          = socket_top - pocket_depth;

// ── Foot ─────────────────────────────────────────────────────
// The bottle is 520 g on a 41 mm arm, 190 mm up. Without a foot
// the whole assembly stands on the barrel and tips at about 5°.
// The plate also anchors a 130 mm tall print to the bed.
foot_t            = 2.4;
foot_d            = 76;
foot_pad_d        = 26;

// ── Reservoir bottle ─────────────────────────────────────────
// 0.5 L, because 1.5 L is 1.5 kg on the same arm.
bottle_ml         = 500;
bottle_body_d     = 66;    // MEASURE your 0.5 L PET body diameter
bottle_shoulder   = 22;    // neck-ring to full diameter; MEASURE

// ── Terrarium ────────────────────────────────────────────────
tank_w = 460; tank_d = 280; tank_h = 370;

// ── Rendering ────────────────────────────────────────────────
$fa = 2; $fs = 0.4;
eps = 0.01;

// Support-free horizontal hole: a circle with a 45° roof, so no
// layer ever overhangs more than 45°. Extrudes along +Y with the
// apex pointing +Z. d2 tapers the far end (for hose grip).
module teardrop(d, len, d2 = -1) {
    r  = d/2;
    sc = (d2 < 0) ? 1 : d2/d;
    rotate([-90, 0, 0]) linear_extrude(len, scale = sc) union() {
        circle(r = r);
        polygon([[-r*0.707, -r*0.707], [r*0.707, -r*0.707], [0, -r*1.42]]);
    }
}
// Same, extruded along +X.
module teardrop_x(d, len, d2 = -1) { rotate([0, 0, -90]) teardrop(d, len, d2); }
