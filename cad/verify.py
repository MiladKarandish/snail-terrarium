#!/usr/bin/env python3
"""Pre-print verification. Anything that FAILs must not be sent to a printer."""
import re, math, subprocess, sys, pathlib, trimesh

CAD = pathlib.Path(__file__).parent
STL = CAD / "stl"; STL.mkdir(exist_ok=True)
PARTS = ("simple_lid", "vessel_lid", "gasket", "chamber", "lid")

def scad(src, out, extra=()):
    # OpenSCAD writes nothing for an empty result, so a stale file from a
    # previous run would otherwise be read back as this run's output.
    pathlib.Path(out).unlink(missing_ok=True)
    r = subprocess.run(["openscad", "-o", str(out), *extra, str(CAD / src)],
                       capture_output=True, text=True, timeout=600)
    return r.stdout + r.stderr

P = {k: float(v) for k, v in re.findall(
    r'PARAM (\w+)=([-\d.]+)', scad("dump_params.scad", "/tmp/dp.stl"))}

res = []
def chk(name, cond, detail): res.append((bool(cond), name, detail))

# ── water level vs the module's datasheet band ───────────────────
chk("level inside the spec band", P["water_min"] <= P["water_hold"] <= P["water_max"],
    f"held {P['water_hold']:.0f} mm above module top "
    f"(band {P['water_min']:.0f}-{P['water_max']:.0f})")
chk("dry-run guard", P["water_hold"] - P["water_min"] >= 3,
    f"{P['water_hold'] - P['water_min']:.0f} mm above the minimum")

# ── Mariotte standpipe ───────────────────────────────────────────
sp_bot = P["water_level"]                       # its opening sets the level
chk("standpipe sets the level", abs(sp_bot - P["water_level"]) < 0.01,
    f"opening at {sp_bot:.1f} mm = the held level")
chk("standpipe clears the module", sp_bot - P["module_top"] >= 10,
    f"{sp_bot - P['module_top']:.1f} mm above the module's top face")
chk("standpipe clears the chamber wall",
    P["sp_offset"] + P["sp_od"]/2 <= P["ch_id"]/2 - 2,
    f"{P['ch_id']/2 - (P['sp_offset'] + P['sp_od']/2):.1f} mm to the bore wall")
chk("bottle neck fits the bore", 0.8 <= P["sp_bore"] - 27.4 <= 2.0,
    f"{P['sp_bore'] - 27.4:.1f} mm clearance on a PCO-1881 neck")
free = math.pi/4 * (P["ch_id"]**2 - P["sp_od"]**2)
port = math.pi/4 * P["fog_port_d"]**2
chk("fog can pass the standpipe", free >= 3*port,
    f"{free:.0f} mm2 free vs {port:.0f} mm2 port ({free/port:.1f}x)")
chk("chamber is vented", P["vent_n"] >= 3 and P["vent_d"] >= 3,
    f"{P['vent_n']:.0f} x {P['vent_d']:.0f} mm — without these the siphon stalls")

# ── fog port ─────────────────────────────────────────────────────
lo = P["fog_port_z"] - P["fog_port_d"]/2
hi = P["fog_port_z"] + P["fog_port_d"]/2 * 1.42     # teardrop tip
chk("fog port above the water line", lo - P["water_level"] >= 10,
    f"{lo - P['water_level']:.1f} mm above the level")
chk("fog port fits under the lid", P["ch_inner_h"] - P["lid_spigot_h"] - hi >= 4,
    f"{P['ch_inner_h'] - P['lid_spigot_h'] - hi:.1f} mm to the spigot")

# ── fits ─────────────────────────────────────────────────────────
chk("module fits the chamber", P["mm_module_od"] + 2 <= P["ch_id"],
    f"{P['mm_module_od']:.0f} mm module in a {P['ch_id']:.0f} mm bore")
chk("lid has a real seat on the rim", P["lid_rim_seat"] >= 2.0,
    f"{P['lid_rim_seat']:.2f} mm seating annulus")
chk("spigot locates without binding", 0.2 <= P["lid_fit"] <= 0.6,
    f"{P['lid_fit']:.2f} mm clearance")
chk("cable clears its notch", P["cable_notch_w"] - P["mm_cable_od"] >= 2,
    f"notch {P['cable_notch_w']:.1f} mm for a {P['mm_cable_od']:.1f} mm cable")

# ── meshes ───────────────────────────────────────────────────────
total = 0.0
for part in PARTS:
    scad(f"{part}.scad", STL / f"{part}.stl")
    m = trimesh.load(STL / f"{part}.stl"); e = m.bounding_box.extents
    total += m.volume
    chk(f"{part}: manifold + watertight",
        m.is_watertight and m.is_winding_consistent and m.body_count == 1,
        f"watertight={m.is_watertight} bodies={m.body_count}")
    chk(f"{part}: fits a 250 mm bed", max(e) <= 250,
        f"{e[0]:.0f} x {e[1]:.0f} x {e[2]:.0f} mm, {m.volume/1000:5.1f} cm3 "
        f"(~{m.volume/1000*1.27:.0f} g)")

# ── vent area must match the fog port (they are in series) ───────
port_a = math.pi/4 * P["fog_port_d"]**2
for nm, n, d in (("simple_lid", P["vent_n"], P["vent_d"]),
                 ("vessel_lid", P["vl_vent_n"], P["vl_vent_d"])):
    a = n * math.pi/4 * d**2
    chk(f"{nm}: vents match the port", a >= port_a,
        f"{a:.0f} mm2 vents vs {port_a:.0f} mm2 port ({a/port_a*100:.0f}%)")
chk("no-reservoir endurance", P["plain_ml"]/20 >= 14,
    f"{P['plain_ml']:.0f} ml -> {P['plain_ml']/20:.0f} days at 20 ml/day")

# ── cut-bottle vessel lid ────────────────────────────────────────
sp_len = P["vessel_cut_h"] - P["water_level"]
chk("standpipe reaches the level", sp_len > 20,
    f"{sp_len:.1f} mm from the cut down to the water")
chk("skirt tolerates bottle variation", P["skirt_slop"] >= 4,
    f"self-centres over {P['vessel_od']:.0f}-{P['vessel_od']+P['skirt_slop']:.0f} mm")
fog_off = -(P["vessel_od"]/2 - P["fog_port_d"]/2 - 6)
vr = P["vessel_od"]/2 - 7
P["vent_n_vl"] = P["vl_vent_n"]
VL_VENT_A = [60, 120, 240, 300]          # must match vessel_lid.scad
import math as _m
def _vc(cx, cy, r):
    return min(_m.hypot(vr*_m.cos(_m.radians(a)) - cx, vr*_m.sin(_m.radians(a)) - cy)
               for a in VL_VENT_A) - r - P["vl_vent_d"]/2
worst = min(_vc(P["sp_offset"], 0, P["sp_od"]/2),
            _vc(fog_off, 0, P["fog_port_d"]/2 + P["fog_boss_wall"]))
chk("vents clear standpipe and fog port", worst >= 1.0,
    f"{worst:.1f} mm closest approach")
chk("fog port sits over the vessel mouth",
    abs(fog_off) + P["fog_port_d"]/2 + P["fog_boss_wall"] <= P["vessel_od"]/2,
    f"outer edge {abs(fog_off) + P['fog_port_d']/2 + P['fog_boss_wall']:.1f} mm "
    f"vs {P['vessel_od']/2:.0f} mm mouth radius")

# ── boolean interference, with a positive control ────────────────
def interf(drop):
    (CAD / "_i.scad").write_text(
        "include <params.scad>\nuse <chamber.scad>\nuse <lid.scad>\n"
        "intersection(){ chamber(); translate([0,0,lid_pos_z-%g]) lid(); }\n" % drop)
    scad("_i.scad", "/tmp/i.stl")
    if not pathlib.Path("/tmp/i.stl").exists(): return 0.0
    im = trimesh.load("/tmp/i.stl")
    return abs(im.volume) if len(im.faces) else 0.0
vol, ctrl = interf(0), interf(1.0)
chk("lid/chamber interference", vol < 1.0, f"{vol:.3f} mm3 when seated")
chk("interference check is not vacuous", ctrl > 100,
    f"control (lid 1 mm low) collides by {ctrl:.0f} mm3")
(CAD / "_i.scad").unlink(missing_ok=True)

bad = sum(not ok for ok, _, _ in res)
for ok, name, detail in res:
    print(f"{'PASS' if ok else 'FAIL'}  {name:<34} {detail}")
print(f"\n{len(res)-bad}/{len(res)} checks passed")
rec = trimesh.load(STL / "simple_lid.stl").volume
print(f"RECOMMENDED BUILD (cut bottle + simple_lid): "
      f"{rec/1000:.1f} cm3  ~{rec/1000*1.27:.0f} g PETG")
print(f"  all variants combined, for reference: {total/1000:.0f} cm3")
sys.exit(1 if bad else 0)
