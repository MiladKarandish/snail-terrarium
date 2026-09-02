// ─────────────────────────────────────────────────────────────
//  Automated Snail Terrarium — shared parameters
//  Every dimension in the project comes from here. Change a
//  number, re-run ./build.sh, get new STLs.
//
//  CONFIRMED  = verified from a datasheet / vendor spec
//  ASSUMED    = sensible default, safe to print but verify
//  MEASURE    = must be measured before ordering prints
// ─────────────────────────────────────────────────────────────

// ── Mist maker module ────────────────────────────────────────
// CONFIRMED from the vendor spec (eshop.eca.ir, 550 ml/h unit):
//   Operating voltage      24 V DC
//   Atomization rate       >=550 ml/h
//   Effective water level  20-75 mm            <-- 55 mm wide band
//   Operating temperature  5-45 C
//   Head diameter          45 mm
//   Module height          45 mm
//   Cable                  1400 +/-20 mm, 3.8 mm OD, black PVC
//   Connector              DC female 5.5 x 2.1 mm
mm_module_od      = 45;    // CONFIRMED head diameter
mm_module_h       = 45;    // CONFIRMED module height
mm_cable_od       = 3.8;   // CONFIRMED
water_min         = 20;    // CONFIRMED min effective level above the module
water_max         = 75;    // CONFIRMED max effective level above the module

// ── Water column ─────────────────────────────────────────────
// The 55 mm band is wide enough that the level may simply drift
// between refills. No Mariotte reservoir required - see
// ../DESIGN-DECISIONS.md.
//
// Levels are referenced to the module's TOP FACE, not the chamber
// floor: the module sits mm_recess_d down in its locating recess.
mm_recess_d       = 1.5;   // locating recess depth in the floor
module_top        = mm_module_h - mm_recess_d;   // above chamber floor
water_margin_hi   = 2;     // stay below the 75 mm ceiling
water_margin_lo   = 5;     // stay above the 20 mm floor (dry-run guard)
water_fill        = module_top + water_max - water_margin_hi;
water_refill      = module_top + water_min + water_margin_lo;
fog_headspace     = 68;    // air space above fill line (also keeps the fog
                           // port tip clear of the lid rebate)

// ── Chamber ──────────────────────────────────────────────────
ch_inner          = 90;    // internal square footprint
ch_wall           = 3.0;   // wall thickness (PETG, 100 um, watertight)
ch_floor          = 3.0;
ch_inner_h        = water_fill + fog_headspace;
ch_corner_r       = 6;     // external corner radius
ch_outer          = ch_inner + 2*ch_wall;

// ── Fog outlet ───────────────────────────────────────────────
fog_port_d        = 32;    // duct bore
fog_port_z        = water_fill + 30;   // centre height above floor
fog_boss_len      = 12;    // outward spigot for the duct/hose
fog_boss_wall     = 2.5;

// ── Lid ──────────────────────────────────────────────────────
// The lid is a full-footprint plate that SEATS ON THE RIM - a real
// 3 mm annulus - and is located laterally by a spigot dipping into
// the cavity. No rebate: a rebate cut into a 3 mm wall leaves only
// a 0.35 mm ledge, which is not a seat.
//
// Print it PLATE-TOP-DOWN. The spigot and the fill collar then both
// rise from the bed and there is not a single overhang on the part.
// That is why the fill collar points DOWN in use.
lid_t             = 4.0;   // plate thickness
lid_spigot_h      = 5.0;   // how far the spigot dips into the cavity
lid_clear         = 0.35;  // print clearance, service-FDM friendly
lid_fit           = 0.30;  // spigot-to-cavity side clearance
lid_finger_d      = 22;    // lift cutout in the plate edge
lid_rim_seat      = (ch_outer - ch_inner)/2;   // seating annulus width
vent_d            = 5;     // make-up air inlets
vent_n            = 6;
cable_notch_w     = mm_cable_od + 3;
cable_notch_h     = 6;
lid_pos_xy        = 0;     // seated position: flush with the chamber footprint
lid_pos_z         = ch_floor + ch_inner_h;

// ── Terrarium ────────────────────────────────────────────────
tank_w            = 460;   // MEASURE  is 46x28x37 external or internal?
tank_d            = 280;
tank_h            = 370;
glass_t           = 5.0;   // MEASURE  rim thickness for the hang-on bracket


// ── Rendering ────────────────────────────────────────────────
$fa = 2; $fs = 0.4;
eps = 0.01;

// ── Helpers ──────────────────────────────────────────────────
module rbox(w, d, h, r) {          // rounded-corner box, flat top/bottom
    hull() for (x = [r, w-r], y = [r, d-r])
        translate([x, y, 0]) cylinder(r = r, h = h);
}

module teardrop(d, len) {          // support-free horizontal hole
    r = d/2;
    rotate([-90, 0, 0]) linear_extrude(len) union() {
        circle(r = r);
        polygon([[-r*0.707, -r*0.707], [r*0.707, -r*0.707], [0, -r*1.42]]);
    }
}

// ── Capacity report (printed at render time) ──────────────────
usable_ml = ch_inner*ch_inner*(water_fill-water_refill)/1000;
full_ml   = ch_inner*ch_inner*water_fill/1000;
echo(str("chamber ", ch_outer, " x ", ch_outer, " x ", ch_floor+ch_inner_h, " mm"));
echo(str("water fill line ", water_fill, " mm / refill line ", water_refill, " mm"));
echo(str("usable ", usable_ml, " ml -> ", usable_ml/20, " days at 20 ml/day"));
echo(str("full mass ~", full_ml/1000, " kg of water"));
