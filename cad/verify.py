#!/usr/bin/env python3
"""Pre-print verification. Anything that FAILs must not be sent to a printer."""
import re, subprocess, sys, pathlib, trimesh

CAD = pathlib.Path(__file__).parent
STL = CAD / "stl"; STL.mkdir(exist_ok=True)

def scad(src, out, extra=()):
    # OpenSCAD writes nothing when a result is empty, so a stale file from a
    # previous run would be read back as if it were this run's output.
    pathlib.Path(out).unlink(missing_ok=True)
    r = subprocess.run(["openscad", "-o", str(out), *extra, str(CAD / src)],
                       capture_output=True, text=True, timeout=600)
    return r.stdout + r.stderr

P = {k: float(v) for k, v in re.findall(
    r'PARAM (\w+)=([-\d.]+)', scad("dump_params.scad", "/tmp/dp.stl"))}

results = []
def chk(name, cond, detail):
    results.append((bool(cond), name, detail))

# ── geometry vs the module's datasheet ───────────────────────────
fill_above  = P["water_fill"]   - P["module_top"]
refill_above= P["water_refill"] - P["module_top"]
chk("fill level within spec band", P["water_min"] <= fill_above <= P["water_max"],
    f"{fill_above:.1f} mm above module top (spec {P['water_min']:.0f}-{P['water_max']:.0f})")
chk("refill level within spec band", P["water_min"] <= refill_above <= P["water_max"],
    f"{refill_above:.1f} mm above module top")
chk("dry-run guard", refill_above - P["water_min"] >= 3,
    f"{refill_above - P['water_min']:.1f} mm of margin above the 20 mm minimum")

# ── fog port placement ───────────────────────────────────────────
port_lo = P["fog_port_z"] - P["fog_port_d"]/2
port_hi = P["fog_port_z"] + P["fog_port_d"]/2 * 1.42      # teardrop tip
spig_lo = P["ch_inner_h"] - P["lid_spigot_h"]
chk("fog port above the water line", port_lo - P["water_fill"] >= 10,
    f"{port_lo - P['water_fill']:.1f} mm above fill line")
chk("fog port not blocked by the spigot", spig_lo - port_hi >= 5,
    f"{spig_lo - port_hi:.1f} mm between the port tip and the spigot")

# ── fits and clearances ──────────────────────────────────────────
chk("module fits the chamber", P["mm_module_od"] + 1 < P["ch_inner"] - 4,
    f"module {P['mm_module_od']:.0f} mm in a {P['ch_inner']:.0f} mm cavity")
chk("cable clears its notch", P["cable_notch_w"] - P["mm_cable_od"] >= 2,
    f"notch {P['cable_notch_w']:.1f} mm for a {P['mm_cable_od']:.1f} mm cable")
chk("lid has a real seat on the rim", P["lid_rim_seat"] >= 2.0,
    f"{P['lid_rim_seat']:.2f} mm wide seating annulus")
chk("spigot locates without binding", 0.2 <= P["lid_fit"] <= 0.6,
    f"{P['lid_fit']:.2f} mm spigot-to-cavity clearance")

# vent ring vs cable notch: true minimum distance, circle to rectangle
import math
plate = P["ch_outer"]
fill_cx, fill_cy = plate/2, plate*0.34
ring_r = 38/2 + 2.5 + 5
nx0, nx1 = plate/2 - P["cable_notch_w"]/2, plate/2 + P["cable_notch_w"]/2
ny0, ny1 = 0.0, P["ch_wall"]
def d_rect(cx, cy):
    dx = max(nx0 - cx, 0, cx - nx1)
    dy = max(ny0 - cy, 0, cy - ny1)
    return math.hypot(dx, dy)
gap = min(d_rect(fill_cx + ring_r*math.cos(math.radians(i*360/P["vent_n"])),
                 fill_cy + ring_r*math.sin(math.radians(i*360/P["vent_n"])))
          - P["vent_d"]/2 for i in range(int(P["vent_n"])))
chk("vents clear of the cable notch", gap >= 2, f"{gap:.2f} mm gap")

# ── meshes ───────────────────────────────────────────────────────
for part in ("chamber", "lid"):
    scad(f"{part}.scad", STL / f"{part}.stl")
    m = trimesh.load(STL / f"{part}.stl")
    e = m.bounding_box.extents
    chk(f"{part}: manifold + watertight",
        m.is_watertight and m.is_winding_consistent and m.body_count == 1,
        f"watertight={m.is_watertight} bodies={m.body_count}")
    chk(f"{part}: fits a 250 mm bed", max(e) <= 250,
        f"{e[0]:.1f} x {e[1]:.1f} x {e[2]:.1f} mm, {m.volume/1000:.0f} cm3 "
        f"(~{m.volume/1000*1.27:.0f} g PETG)")

# ── boolean interference: lid seated on chamber must intersect in nothing ──
def interference(drop):
    (CAD / "_interf.scad").write_text(
        "include <params.scad>\nuse <chamber.scad>\nuse <lid.scad>\n"
        "intersection() { chamber(); translate([lid_pos_xy,lid_pos_xy,lid_pos_z-%g]) lid(); }\n" % drop)
    scad("_interf.scad", "/tmp/interf.stl")
    if not pathlib.Path("/tmp/interf.stl").exists():
        return 0.0                      # empty intersection: nothing written
    im = trimesh.load("/tmp/interf.stl")
    return abs(im.volume) if len(im.faces) else 0.0

vol = interference(0)
ctrl = interference(1.0)          # positive control: 1 mm too low MUST collide
chk("lid/chamber interference", vol < 1.0, f"intersection volume {vol:.3f} mm3")
chk("interference check is not vacuous", ctrl > 100,
    f"control (lid dropped 1 mm) collides by {ctrl:.0f} mm3")
(CAD / "_interf.scad").unlink(missing_ok=True)

# ── report ───────────────────────────────────────────────────────
bad = 0
for ok, name, detail in results:
    print(f"{'PASS' if ok else 'FAIL'}  {name:<38} {detail}")
    bad += not ok
print(f"\n{len(results)-bad}/{len(results)} checks passed")
sys.exit(1 if bad else 0)
