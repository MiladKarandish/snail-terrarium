#!/usr/bin/env python3
"""Pre-print verification. Anything that FAILs must not be sent to a printer.

Three kinds of check, in increasing order of how much they are worth:

  parametric  arithmetic on the numbers in params.scad
  geometric   booleans on the REAL rendered solids, several of them run a
              second time with a defect injected, which must fail
  printability overhang analysis on the actual triangles, in the actual
              print orientation

The middle group is the one that matters. Every defect this harness now
catches was present in a revision that the previous harness passed.
"""
import json, re, subprocess, sys, pathlib, math, numpy as np, trimesh

CAD = pathlib.Path(__file__).resolve().parent
STL = CAD / "stl"; STL.mkdir(exist_ok=True)
TMP = CAD / ".build"; TMP.mkdir(exist_ok=True)

# (define, flip for the overhang check). Nothing is flipped: mister.scad
# exports every part already lying in its print orientation.
PARTS = {"mister_body":   ('PART="body"',   False),
         "mister_lid":    ('PART="lid"',    False),
         "mister_spacer": ('PART="spacer"', False)}


def scad(src, out, defines=()):
    """Render src to out. Deleting first matters: OpenSCAD writes NO file for
    an empty result, so a stale file would be read back as this run's output.
    That bug once made the harness report a clean part as colliding."""
    out = pathlib.Path(out); out.unlink(missing_ok=True)
    # Binary STL, not OpenSCAD's default ASCII: 3.5x smaller for identical
    # geometry, and these are rewritten on every run, so ASCII would put a
    # fresh 3 MB of text into the history each time a dimension changed.
    args = ["--export-format", "binstl"] if out.suffix == ".stl" else []
    for d in defines:
        args += ["-D", d]
    r = subprocess.run(["openscad", "-o", str(out), *args, str(CAD / src)],
                       capture_output=True, text=True, timeout=900)
    return out, r.stdout + r.stderr


def load(path):
    """A rendered solid, or None if OpenSCAD produced nothing (empty result)."""
    path = pathlib.Path(path)
    if not path.exists() or path.stat().st_size == 0:
        return None
    m = trimesh.load(path)          # process=True merges vertices;
                                    # without it every triangle is a 'body'
    if not isinstance(m, trimesh.Trimesh) or len(m.faces) == 0:
        return None          # OpenSCAD wrote an empty result
    return m


# ── parameters, harvested rather than hand-listed ────────────────
# The old dump listed names by hand and silently dropped any that had been
# deleted from params.scad, because "undef" did not match its number regex.
names = sorted(set(re.findall(r'^([a-z]\w*)\s*=', (CAD / "params.scad").read_text(),
                              re.M)))
(TMP / "dump.scad").write_text(
    "include <../params.scad>\n" +
    "".join(f'echo(str("PARAM {n}=", {n}));\n' for n in names))
_, out = scad(".build/dump.scad", TMP / "dump.stl")
P = {k: float(v) for k, v in re.findall(r'PARAM (\w+)=([-\d.e+]+)"', out)}
missing = [n for n in names if n not in P]

res = []
def chk(name, cond, detail):
    res.append((bool(cond), name, detail))

chk("every parameter resolves to a number", not missing,
    "unresolved: " + ", ".join(missing) if missing else f"{len(P)} parameters")

# ── water level against the datasheet band ───────────────────────
chk("level is inside the optimal band",
    P["water_lo"] <= P["water_hold"] <= P["water_hi"],
    f"{P['water_hold']:.1f} mm held, datasheet optimum "
    f"{P['water_lo']:.0f}-{P['water_hi']:.0f}")
lo_m = P["water_hold"] - P["water_probe"]
hi_m = P["water_choke"] - P["water_hold"]
chk("level has margin on BOTH sides", lo_m >= 3 and hi_m >= 3,
    f"{lo_m:.1f} mm over the probe, {hi_m:.1f} mm under splashing")
trimmed = P["water_hold"] - P["trim_spacer_t"]
chk("trim spacer keeps it in band",
    P["water_lo"] <= trimmed <= P["water_hi"],
    f"{trimmed:.1f} mm effective with the {P['trim_spacer_t']:.0f} mm spacer")
chk("spacer stays inside the module footprint",
    P["trim_spacer_d"] <= P["mm_module_od"] - 1,
    f"Ø{P['trim_spacer_d']:.0f} under a Ø{P['mm_module_od']:.0f} module")

# ── fits and clearances ──────────────────────────────────────────
chk("module clears the locating lugs",
    P["lug_id"] - P["mm_module_od"] >= 2,
    f"Ø{P['lug_id']:.1f} lug circle around a Ø{P['mm_module_od']:.0f} module")
chk("lugs leave an annulus for fog and feed",
    (P["ch_id"] - P["lug_id"])/2 >= 4,
    f"{(P['ch_id'] - P['lug_id'])/2:.2f} mm from lug to wall")
chk("floor is thick enough to hold water", P["ch_floor"] >= 3.0,
    f"{P['ch_floor']:.1f} mm, {P['ch_floor']/0.2:.0f} layers at 0.2 mm")
chk("wall is a whole number of perimeters",
    abs(P["ch_wall"]/0.4 - round(P["ch_wall"]/0.4)) < 1e-6,
    f"{P['ch_wall']:.1f} mm = {P['ch_wall']/0.4:.0f} extrusions at 0.4 mm")

# ── the two ducts ────────────────────────────────────────────────
chk("fan bore clears the water",
    P["duct_z"] - P["fan_bore"]/2 - P["water_z"] >= 5,
    f"{P['duct_z'] - P['fan_bore']/2 - P['water_z']:.1f} mm of air under it")
chk("nozzle bore clears the water",
    P["nozzle_exit_z"] - (P["nozzle_d"]/2)/math.cos(math.radians(P["nozzle_tilt"]))
    - P["water_z"] >= 5,
    f"{P['nozzle_exit_z'] - (P['nozzle_d']/2)/math.cos(math.radians(P['nozzle_tilt'])) - P['water_z']:.1f} mm above the surface")
inlet, outlet = math.pi/4*P["fan_bore"]**2, math.pi/4*P["nozzle_d"]**2
chk("inlet does not throttle the outlet", inlet >= outlet,
    f"fan {inlet:.0f} mm2 vs nozzle {outlet:.0f} mm2 - they are in series, "
    "so the smaller one sets throughput")
chk("nozzle is long enough to clear the barrel AND take the hose",
    P["nozzle_len"] >= P["hose_engage"] + (P["nozzle_od"]/2 + P["hose_wall"])
                       * math.tan(math.radians(P["nozzle_tilt"])) - .01,
    f"{P['nozzle_len']:.1f} mm spigot = {P['hose_engage']:.0f} mm of hose + "
    f"{(P['nozzle_od']/2 + P['hose_wall'])*math.tan(math.radians(P['nozzle_tilt'])):.1f} mm "
    "spent clearing the barrel")
chk("nozzle clears the flange",
    P["ch_h"] - P["ch_flange_h"] - P["nozzle_top"] >= 2,
    f"{P['ch_h'] - P['ch_flange_h'] - P['nozzle_top']:.1f} mm to the flange")
chk("fan pad clears the flange",
    P["ch_h"] - P["ch_flange_h"] - P["fan_pad_top"] >= 2,
    f"{P['ch_h'] - P['ch_flange_h'] - P['fan_pad_top']:.1f} mm to the flange")
# a screw hole that reaches the bore is a hole in a water tank
# Every pattern the pad is drilled for, worst case first: the barrel
# curves CLOSEST to the pad at the narrowest pitch, so that is the one
# that can come out inside the water.
FAN_PITCHES = [(P["fan_pitch_30"], "30 mm"), (P["fan_pitch_40"], "40 mm"),
               (P["fan_pitch_50"], "50 mm")]
inner_y = P["fan_pitch_min"]/2                   # worst case: the tightest pattern
wall_x  = math.sqrt((P["ch_id"]/2)**2 - inner_y**2)
hole_x  = P["ch_od"]/2 + P["fan_pad_t"] - P["fan_screw_depth"]
chk("fan screws stay out of the chamber", hole_x - wall_x >= 1.6,
    f"{hole_x - wall_x:.2f} mm of wall past the deepest screw, at the "
    f"{P['fan_pitch_min']:.0f} mm pitch where the barrel is closest")
chk("pad is drilled for the fans it claims",
    P["fan_pitch_min"] >= 24 and P["fan_pitch_max"] <= 40,
    f"{', '.join(f for _, f in FAN_PITCHES)} fans "
    f"({', '.join(f'{p:.0f}' for p, _ in FAN_PITCHES)} mm pitch); 25 mm fans "
    f"leave only 1.3 mm of screw wall and 60 mm wraps past the barrel")

# ── the Mariotte feed ────────────────────────────────────────────
chk("conduit bore stays outside the barrel",
    P["feed_centre"] - P["feed_id"]/2 - P["ch_od"]/2 >= 1.6,
    f"{P['feed_centre'] - P['feed_id']/2 - P['ch_od']/2:.1f} mm of wall between "
    "bore and chamber")
chk("web is wider than the port",
    (P["feed_web_w"] - P["feed_port_d"])/2 >= 1.6,
    f"{(P['feed_web_w'] - P['feed_port_d'])/2:.1f} mm each side - if the port "
    "broke out of the web, air would reach the conduit and it would drain")
chk("port stops inside the conduit bore",
    P["feed_port_x0"] + P["feed_port_len"] < P["feed_centre"] + P["feed_id"]/2,
    f"port ends at x={P['feed_port_x0'] + P['feed_port_len']:.1f}, "
    f"bore runs to {P['feed_centre'] + P['feed_id']/2:.1f}")
# Air has to break INTO the port as a bubble, and that costs 4*sigma/d of
# head. The level therefore settles a little BELOW the apex, by more the
# narrower the port. It is a level error, not a saving.
bubble = 4*0.0728/(9810*P["feed_port_d"]/1000)*1000
chk("port is wide enough that surface tension barely moves the level",
    bubble <= 3.0 and P["water_hold"] - bubble >= P["water_probe"] + 2,
    f"Ø{P['feed_port_d']:.0f} port: bubble-through head {bubble:.1f} mm, so the "
    f"level settles near {P['water_hold'] - bubble:.1f}-{P['water_hold']:.1f} mm")
chk("conduit passes air up while water runs down", P["feed_id"] >= 8,
    f"Ø{P['feed_id']:.0f} bore; counter-flow stalls below ~6 mm")
chk("cap pocket has a real wall",
    (P["socket_od"] - P["neck_bore_id"])/2 >= 2.4,
    f"{(P['socket_od'] - P['neck_bore_id'])/2:.2f} mm around the widest bore")
# The socket is cut for the standards rather than for one measured cap.
chk("pocket takes every standard cap",
    P["cap_pocket_id"] - P["cap_rib_d"] <= P["cap_od_max"] + 0.3
    and P["cap_pocket_id"] >= P["cap_od_max"] + 0.6,
    f"Ø{P['cap_pocket_id']:.1f} bore, Ø{P['cap_pocket_id'] - P['cap_rib_d']:.1f} "
    f"across the ribs, for caps Ø{P['cap_od_min']:.1f}-{P['cap_od_max']:.1f}")
# The ring is WIDER than the cap, so it can never enter the grip. It
# has to pass in the counterbore, and that is the whole reason for it.
chk("counterbore clears the neck support ring",
    (P["neck_bore_id"] - P["neck_ring_d"])/2 >= 0.4,
    f"{(P['neck_bore_id'] - P['neck_ring_d'])/2:.2f} mm around a "
    f"Ø{P['neck_ring_d']:.1f} ring")
# A cap has to clear the support ring to screw on at all, so the ring
# is ALWAYS at or above the cap's rim. Keeping the ribbed grip no
# taller than the shortest cap therefore puts it below every ring
# there can be - an argument from the finish, not a measured gap.
chk("ribbed grip stops clear below the lowest possible ring",
    P["cap_h_min"] - P["cap_grip_h"] >= 0.5,
    f"{P['cap_grip_h']:.1f} mm of ribs, {P['cap_h_min'] - P['cap_grip_h']:.1f} mm "
    f"below a ring that cannot sit under {P['cap_h_min']:.1f} mm")
chk("socket bore is deep enough for the tallest cap's ring",
    P["pocket_depth"] >= P["cap_floor_t"] + P["neck_ring_h"] - 1,
    f"bore {P['pocket_depth']:.1f} mm deep, PCO-1881 ring lands at "
    f"{P['cap_floor_t'] + P['neck_ring_h']:.2f} mm")
chk("socket flare is self-supporting",
    P["socket_cone_ang"] <= 45,
    f"{P['socket_cone_ang']:.0f}° from vertical over "
    f"{P['socket_cone_h']:.1f} mm, Ø{P['feed_od']:.1f} to Ø{P['socket_od']:.1f}")
chk("socket sits above the seated lid",
    P["socket_cone_z"] >= P["ch_h"] + P["lid_t"],
    f"flare starts {P['socket_cone_z'] - P['ch_h'] - P['lid_t']:.1f} mm above the lid")

# ── lid ──────────────────────────────────────────────────────────
relief_in = P["feed_centre"] - P["feed_od"]/2 - P["lid_feed_clear"]
chk("lid still covers the bore past its relief", relief_in - P["ch_id"]/2 >= 1.0,
    f"{relief_in - P['ch_id']/2:.1f} mm of lid past the bore edge")
chk("lid relief misses the locating spigot",
    relief_in - (P["ch_id"]/2 - P["lid_fit"]) >= 1.0,
    f"{relief_in - (P['ch_id']/2 - P['lid_fit']):.1f} mm clear of the spigot")
chk("cable hole takes the bung the module ships with",
    P["bung_d_min"] <= P["cable_hole_d"] <= P["bung_d_max"],
    f"Ø{P['cable_hole_d']:.1f} hole, bung tapers "
    f"Ø{P['bung_d_max']:.0f}-Ø{P['bung_d_min']:.0f}")
chk("cable hole is inside the bore, not over the rim",
    P["cable_hole_r"] + P["cable_cs_d"]/2 <= P["ch_id"]/2 - 1,
    f"countersink reaches r={P['cable_hole_r'] + P['cable_cs_d']/2:.1f} "
    f"in a Ø{P['ch_id']:.0f} bore")

# ── geometric checks on the real solids ──────────────────────────
_geom = {}
def geom(test, ctl=0):
    if (test, ctl) not in _geom:
        f, _ = scad("checks.scad", TMP / f"{test}{ctl}.stl",
                    (f'TEST="{test}"', f"CTL={ctl}"))
        _geom[(test, ctl)] = load(f)
    return _geom[(test, ctl)]

def bodies(m):  return 0 if m is None else m.body_count
def vol(m):     return 0.0 if m is None else m.volume

leak, leak_ctl = geom("leak"), geom("leak", 1)
chk("wall is unbreached below the water line", bodies(leak) == 2,
    f"{bodies(leak)} voids under the water line "
    "(2 = wetted cavity joined to the conduit through the port, plus outside; "
    "1 = the wall leaks; 3 = the port never connected)")
chk("  ...and that test can fail", bodies(leak_ctl) == 1,
    f"control: a 3 mm hole through the wall gives {bodies(leak_ctl)} void")

feed, feed_ctl = geom("feed"), geom("feed", 1)
fz = (0, 0) if feed is None else (feed.bounds[0][2], feed.bounds[1][2])
chk("feed is open from the floor into the cap pocket",
    bodies(feed) == 1 and fz[0] <= P["ch_floor"] + .1 and fz[1] >= P["pocket_z"] - .1,
    f"{bodies(feed)} continuous bore, z {fz[0]:.1f}..{fz[1]:.1f} mm")
chk("  ...and that test can fail", bodies(feed_ctl) != 1,
    f"control: a 3 mm slug under the pocket splits it into {bodies(feed_ctl)}")

fit, fit_ctl = geom("fit"), geom("fit", 1)
chk("lid seats on the rim", vol(fit) < 1.0,
    f"{vol(fit):.2f} mm3 of interference")
chk("  ...and that test can fail", vol(fit_ctl) > 100,
    f"control: the lid 1 mm low collides by {vol(fit_ctl):.0f} mm3")

chk("lid lifts off past the feed column", vol(geom("lift")) < 1.0,
    f"{vol(geom('lift')):.2f} mm3 in the way when slid sideways")
chk("bottle neck, ring and body clear the socket, lid and rim",
    vol(geom("bottle")) < 1.0,
    f"Ø{P['bottle_body_d']:.0f} bottle with a Ø{P['neck_ring_d']:.1f} support "
    f"ring, {vol(geom('bottle')):.2f} mm3 of fouling")
# A PCO-1881 ring lands above the socket in free air, so the test above
# never touches the counterbore. This seats the same neck at the lowest
# ring the socket claims to take - level with the top of the ribbed grip -
# which is the worst point of the design envelope, and the case the
# counterbore exists for.
chk("counterbore takes a ring as low as the socket claims",
    vol(geom("ring")) < 1.0,
    f"ring seated at the top of the grip, {vol(geom('ring')):.2f} mm3 of fouling")
chk("  ...and that test can fail", vol(geom("ring", 1)) > 20,
    f"control: filling the counterbore back to a plain pocket traps that "
    f"ring by {vol(geom('ring', 1)):.0f} mm3")
chk("module drops in without fouling anything", vol(geom("module")) < 1.0,
    f"Ø{P['mm_module_od']:.0f} x {P['mm_module_h']:.0f} module, "
    f"{vol(geom('module')):.2f} mm3 of fouling")

hose, hose_ctl = geom("hosefit"), geom("hosefit", 1)
chk("hose seats on the nozzle", vol(hose) < 1.0,
    f"{P['hose_engage']:.0f} mm of clear spigot for a Ø{P['nozzle_hose_id']:.0f} "
    f"hose, {vol(hose):.2f} mm3 of fouling")
chk("  ...and that test can fail", vol(hose_ctl) > 20,
    f"control: {P['hose_engage']+8:.0f} mm of hose fouls the barrel by "
    f"{vol(hose_ctl):.0f} mm3")

held = vol(geom("water"))/1000
burst = held/9.2                                   # 550 mL/h = 9.2 mL/min
chk("chamber holds enough for a sensible burst", burst >= 3,
    f"{held:.0f} mL wetted -> {burst:.1f} min at full output before the "
    "feed has to keep up")

# ── the printed parts themselves ─────────────────────────────────
def overhangs(m, flip):
    """Downward-facing area that overhangs by more than 45°, in the print
    orientation. Tilt is measured the way a slicer measures it: 0° is a
    vertical wall, 90° is a flat ceiling over air. Faces lying on the bed
    are not overhangs."""
    n = m.face_normals.copy()
    v = m.triangles.copy()
    if flip:                                   # lid prints plate-top-down
        n[:, 2] *= -1; v[:, :, 2] *= -1
    zmin = v[:, :, 2].min()
    on_bed = (v[:, :, 2].max(axis=1) - zmin) < 0.05
    tilt = np.degrees(np.arcsin(np.clip(-n[:, 2], 0, 1)))
    bad = (tilt > 48) & ~on_bed                # 45° design limit + 3° tolerance
    if not bad.any():
        return 0.0, 0.0, ""
    zs = v[bad][:, :, 2]
    return (m.area_faces[bad].sum(), tilt[bad].max(),
            f", worst at z {zs.min():.0f}-{zs.max():.0f}")

def fan_seat_margin(m):
    """How much FLAT pad sits below each fan screw, measured on the real
    triangles. The pad's seating face is the one whose normal is -x at
    x = -(ch_od/2 + fan_pad_t); the 45 deg chamfer under the pad eats into
    it from below, and by more the further out in y you go. A screw whose
    hole opens on that chamfer has no seat: a gap under the fan and a bolt
    loaded in bending."""
    face_x = -(P["ch_od"]/2 + P["fan_pad_t"])
    n, v = m.face_normals, m.triangles
    sel = (n[:, 0] < -0.999) & (np.abs(v[:, :, 0].mean(axis=1) - face_x) < 0.05)
    pts = v[sel].reshape(-1, 3)
    if not len(pts):
        return -99.0, "no flat pad face at all"
    worst = None
    for pitch, fan in FAN_PITCHES:
        for zs, end in ((-1, "lower"), (1, "upper")):
            hy, hz = pitch/2, P["duct_z"] + zs*pitch/2
            near = pts[np.abs(np.abs(pts[:, 1]) - hy) < 1.0]
            if not len(near):
                return -99.0, f"{fan} fan bolt circle is off the pad entirely"
            margin = hz - near[:, 2].min()
            if worst is None or margin < worst[0]:
                worst = (margin, f"{fan} fan, {end} screws")
    return worst


total = 0.0
for part, (define, flip) in PARTS.items():
    f, _ = scad("mister.scad", STL / f"{part}.stl", (define,))
    m = load(f)
    if m is None:
        chk(f"{part}: renders", False, "OpenSCAD produced nothing"); continue
    e = m.bounding_box.extents
    total += m.volume
    chk(f"{part}: manifold and watertight",
        m.is_watertight and m.is_winding_consistent and m.body_count == 1,
        f"watertight={m.is_watertight} consistent={m.is_winding_consistent} "
        f"bodies={m.body_count}")
    chk(f"{part}: fits a 250 mm bed", max(e) <= 250,
        f"{e[0]:.0f} x {e[1]:.0f} x {e[2]:.0f} mm, {m.volume/1000:.1f} cm3 "
        f"(~{m.volume/1000*1.27:.0f} g PETG)")
    area, worst, where = overhangs(m, flip)
    chk(f"{part}: prints without support", area < 20,
        f"{area:.1f} mm2 overhanging past 45° (worst {worst:.0f}°{where})")
    if part == "mister_body":
        seat, which = fan_seat_margin(m)
        chk("every fan screw opens on the pad's FLAT face",
            seat >= P["fan_seat"] - 0.05,
            f"worst is the {which}: {seat:.2f} mm of flat below the hole. The "
            f"45° chamfer under the pad eats "
            f"{P['fan_face_r'] - P['ch_od']/2:.2f} mm into the face at the "
            f"{P['fan_pitch_max']:.0f} mm bolt circle, "
            f"{P['fan_face_r'] - P['ch_od']/2 - 3.0:.2f} mm more than at the "
            f"centreline")

# Publish the headline numbers so nothing downstream has to hardcode them.
# The viewer's title block reads this, which is why its figures cannot drift
# away from what was actually verified.
(TMP / "facts.json").write_text(json.dumps({
    "chamber_od": round(P["ch_od"], 1), "chamber_h": round(P["ch_h"], 1),
    "grams": round(total/1000*1.27), "water_hold": round(P["water_hold"], 1),
    "wetted_ml": round(held), "burst_min": round(burst, 1),
    "passed": sum(ok for ok, _, _ in res), "total": len(res),
}, indent=1))

bad = sum(not ok for ok, _, _ in res)
w = max(len(n) for _, n, _ in res)
for ok, name, detail in res:
    print(f"{'PASS' if ok else 'FAIL'}  {name:<{w}}  {detail}")
print(f"\n{len(res)-bad}/{len(res)} checks passed")
print(f"BUILD: {total/1000:.1f} cm3, ~{total/1000*1.27:.0f} g PETG "
      f"(body + lid; the spacer is optional trim)")
print(f"Chamber Ø{P['ch_od']:.1f} x {P['ch_h']:.1f} mm, water held at "
      f"{P['water_hold']:.1f} mm, {held:.0f} mL wetted, "
      f"{P['bottle_ml']/20:.0f} days per 0.5 L at 20 mL/day")
sys.exit(1 if bad else 0)
