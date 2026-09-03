#!/usr/bin/env python3
"""Pre-print verification. Anything that FAILs must not be sent to a printer."""
import re, math, subprocess, sys, pathlib, trimesh

CAD = pathlib.Path(__file__).parent
STL = CAD / "stl"; STL.mkdir(exist_ok=True)
PARTS = ("gasket",)

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
chk("level inside the MEASURED band",
    P["water_best_lo"] <= P["water_hold"] <= P["water_best_hi"],
    f"held at {P['water_hold']:.0f} mm (best {P['water_best_lo']:.0f}-{P['water_best_hi']:.0f})")
chk("clear of the probe cutoff", P["water_hold"] - P["water_start"] >= 2,
    f"{P['water_hold'] - P['water_start']:.0f} mm above the {P['water_start']:.0f} mm cutoff")
chk("clear of the splashing point", P["water_struggle"] - P["water_hold"] >= 4,
    f"{P['water_struggle'] - P['water_hold']:.0f} mm below where it labours")

# ── fits ─────────────────────────────────────────────────────────
chk("module fits the bore", P["mm_module_od"] + 10 <= P["ch_id"],
    f"Ø{P['mm_module_od']:.0f} module in a Ø{P['ch_id']:.0f} bore")
chk("feed must run outside the wall",
    P["mm_module_od"]/2 + 16.3 + 2 + 16.3 > P["ch_id"]/2,
    "an internal standpipe would need a Ø80 bore - feed goes outside")
chk("water clears the module's disc", P["water_hold"] < P["mm_module_h"] + 6,
    f"held {P['water_hold']:.0f} mm on a {P['mm_module_h']:.0f} mm module")
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


bad = sum(not ok for ok, _, _ in res)
for ok, name, detail in res:
    print(f"{'PASS' if ok else 'FAIL'}  {name:<34} {detail}")
print(f"\n{len(res)-bad}/{len(res)} checks passed")
print(f"PRINTED SO FAR: {total/1000:.1f} cm3  ~{total/1000*1.27:.0f} g PETG")
print("  main body not yet drawn - feed moves outside the wall (see")
print("  cad/superseded/README.md for why the earlier parts were binned)")
sys.exit(1 if bad else 0)
