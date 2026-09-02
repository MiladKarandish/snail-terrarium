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
// between refills. No Mariotte reservoir is required - see
// ../DESIGN-DECISIONS.md.
water_fill        = mm_module_h + water_max;   // fill line, above floor
water_refill      = mm_module_h + water_min;   // refill line, above floor
fog_headspace     = 60;    // air space above the fill line

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
lid_t             = 4.0;
lid_lip_h         = 4.0;   // spigot that locates the lid in the chamber
lid_clear         = 0.35;  // print clearance, service-FDM friendly
vent_d            = 5;     // make-up air inlets
vent_n            = 6;
cable_notch_w     = mm_cable_od + 3;     // cable exits over the rim: no wall penetration
cable_notch_h     = 6;

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
        polygon([[-r*0.707, r*0.707], [r*0.707, r*0.707], [0, r*1.42]]);
    }
}

// ── Capacity report (printed at render time) ──────────────────
usable_ml = ch_inner*ch_inner*(water_fill-water_refill)/1000;
full_ml   = ch_inner*ch_inner*water_fill/1000;
echo(str("chamber ", ch_outer, " x ", ch_outer, " x ", ch_floor+ch_inner_h, " mm"));
echo(str("water fill line ", water_fill, " mm / refill line ", water_refill, " mm"));
echo(str("usable ", usable_ml, " ml -> ", usable_ml/20, " days at 20 ml/day"));
echo(str("full mass ~", full_ml/1000, " kg of water"));
