# Bottle-fed mist chamber

The printed part of the terrarium: a chamber the ultrasonic module sits in, held
at a constant water level by an inverted bottle, with a fan blowing across the
fog and a nozzle carrying it to the tank.

Why it is shaped this way: **[../DESIGN-DECISIONS.md](../DESIGN-DECISIONS.md)**.
What the module needs: **[../MIST-MAKER.md](../MIST-MAKER.md)**.

```
                              ┌──────────┐
                              │  0.5 L   │   inverted, screws into a
                              │  bottle  │   captured PET cap
                              └────┬─────┘
      ┌────────────┐               │ Ø12 conduit, up the OUTSIDE
      │    lid     │◄─ cable out   │ of the wall
    ══╪════════════╪══             │
      │  ░░░ fog ░░│               │      fog out, 45° up, Ø25 hose
   ───┤            ├───────────────┤   ◄─ fan in, Ø26
      │▓▓▓▓▓▓▓▓▓▓▓▓│◄──────────────┘   ── water line, 46 mm ────────
      │▓▓ module ▓▓│  feed port, apex ON the water line: air can
      │▓▓▓▓▓▓▓▓▓▓▓▓│  only get in when the level drops past it
      └────────────┘
     ══════ foot ══════
```

## Parts

| File | Part | Qty | Size | PETG |
|---|---|---|---|---|
| `stl/mister_body.stl` | Chamber, feed column, bottle socket | 1 | 98 × 91 × 136 mm | 84 cm³, ~106 g |
| `stl/mister_lid.stl` | Lid with cable gland | 1 | 67 × 68 × 9 mm | 16 cm³, ~20 g |
| `stl/mister_spacer.stl` | Trim spacer — only if the level lands high, see *Commissioning* | 0–1 | 43 × 43 × 2 mm | 2 cm³, ~3 g |

Total for the build: **~102 cm³, ~129 g of PETG.**

Also needed, not printed:

- A **0.5 L still-water PET bottle** and its cap. Not carbonated — petaloid
  bases sit crooked, and here it is the **cap** that matters anyway.
- A **30 mm or 40 mm fan**, 5 V or 12 V. The pad is drilled for both (24 mm and
  32 mm bolt pitch). 4 × M3 screws.
- **25 mm ID hose** for the fog line, and a clamp or zip tie.
- **Epoxy** for the cap.
- **RO or distilled water.** Not optional — see [MIST-MAKER.md §5](../MIST-MAKER.md).

## Build

```bash
../.venv/bin/python verify.py
```

Renders the STLs into `stl/` and runs 45 checks. **It must print `45/45` before
anything goes to a printer.** It checks levels against the datasheet band, fits
and clearances, that the wall is unbreached below the water line, that the lid
seats *and* comes off, that the feed is actually open end to end, and that
nothing on either part overhangs past 45° in its print orientation. Several
checks run twice, once with a defect injected that must fail — a test that
cannot fail is not a test.

Change a number in `params.scad`, run it again.

## Seeing it assembled

```bash
../.venv/bin/python viewer.py
```

Builds and serves an interactive 3D assembly at `http://127.0.0.1:8017/` — orbit
it, pull it apart with the explode slider, switch parts off, and drag the section
slider for a live cutting plane through the bore, the water and the feed port.
`--build` writes a single self-contained `viewer/index.html` you can open
straight off the disk, with no server and no network.

Full reference, controls and troubleshooting: **[VIEWER.md](VIEWER.md)**.

`assembly.scad` also renders stills directly:

```bash
openscad -o out.png --viewall --autocenter --camera=0,0,0,68,0,205,0 \
         -D "EXPLODE=1" assembly.scad          # EXPLODE / SECTION / BOTTLE
```

## Print settings

| | Body | Lid | Spacer |
|---|---|---|---|
| Orientation | Upright, open end up, on the foot | **Plate-top-down** — spigot up | Flat |
| Support | **None** | **None** | None |
| Material | PETG | PETG | PETG |
| Layer | 0.2 mm | 0.2 mm | 0.2 mm |
| Perimeters | **≥ 4** | ≥ 3 | ≥ 3 |
| Infill | ≥ 30 % | ≥ 30 % | ≥ 20 % |

**Perimeters are the setting that matters.** The wall is 1.6 mm, which is
*exactly* four extrusions at a 0.4 mm nozzle, so at ≥ 4 perimeters it is 100 %
shell with no infill inside it to weep through. At 2 perimeters the same wall is
0.8 mm of shell wrapped around 0.8 mm of infill, and it will seep no matter what
infill percentage is set. Ask for 0.2 mm layers rather than 0.1: half the layer
count, half as many interfaces, each one a potential leak path.

PETG, not PLA — PLA embrittles and creeps in constant water contact.

## Assembly

1. **Measure your cap** across the knurl and its height. If they are not
   Ø31 × 14 mm, set `cap_od` / `cap_h` in `params.scad` and re-run `verify.py`
   before printing. This is the one joint the whole reservoir depends on.
2. **Drill the cap** through its flat top, ~Ø10, centred.
3. **Epoxy the cap into the socket**, drilled face down onto the pocket floor,
   threads up. Six ribs in the pocket stop it turning when the bottle is screwed
   in. The epoxy is doing two jobs: holding it and *sealing* it — any air leak
   around the cap and the bottle drains instead of regulating.
4. **Fit the fan** to the pad, blowing **inward**, with M3 screws in whichever
   bolt circle matches. The holes are blind; do not force a longer screw through.
5. **Push the hose** onto the 45° nozzle and clamp it. Run it **downhill** to the
   tank so condensate drains forward.
6. **Stand the module** on the chamber floor, inside the four locating lugs, with
   its cable out through one of the gaps between them.
7. **Thread the cable** up through the lid's hole from underneath, then slide the
   module's own conical rubber bung down it into the countersink.
8. **Fill the chamber** by hand to roughly 45 mm, screw on the filled bottle, and
   seat the lid.

To take it apart: unscrew the bottle, lift the lid a few mm until its spigot is
clear of the bore, then slide it sideways off the feed column.

## Commissioning

Run it with the lid off and watch the water line.

| What you see | What it means | What to do |
|---|---|---|
| Dense, low-lying fog | Correct | Nothing |
| Nothing, or it cuts in and out | Level is under the 41 mm probe | Check the bottle is sealed and the port is not blocked |
| Spitting, coarse droplets | Level is high, over ~50 mm | Fit the 2 mm trim spacer under the module |
| Bottle empties fast, chamber overflows | Air is leaking in past the cap | Re-seal the cap in the socket |

The level should settle between **43.6 and 46.0 mm** measured from the chamber
floor. It sits a little below the port's apex because air has to bubble in
before water can leave — about 2.4 mm on a Ø12 port. That is designed for; the
whole range is inside the module's 42–47 mm optimum.

The chamber holds **~58 mL** with the module in it — about **6 minutes** of
continuous fogging before the bottle has to keep up, which it does easily. At
20 mL/day a 0.5 L bottle lasts about **25 days**. Check it weekly at first: a
tank that leaks humidity will run the mister far harder than that, and the
bottle is the first place you will see it.

## Maintenance

- **Descale** in 50:50 white vinegar for 20–30 min when output drops. Lift the
  module out; never scrape the disc.
- **Never let it run on tap water.** Scale halves the output within weeks and
  eventually cracks the ceramic.
- The module is a **consumable** — potted, non-serviceable, 3000–5000 h. It
  lifts straight out when it dies.

## Files

| | |
|---|---|
| `params.scad` | Every dimension, with its source and its reason |
| `mister.scad` | The parts |
| `checks.scad` | Geometry that exists only to be measured. Not printed |
| `verify.py` | The gate — run this before printing anything |
| `qa.py` | Standalone watertight/volume check over `stl/`. Superseded by `verify.py`, which does this and much more |
| `section2d.scad` | True vertical section, rendered from the real solids |
| `assembly.scad` | The whole thing together, printed and bought parts. Not printable |
| `export_parts.scad` | Splits the assembly into meshes for the viewer |
| `viewer.py` + `viewer/` | Builds and serves the interactive 3D assembly — see [VIEWER.md](VIEWER.md) |
| `tools/pack_viewer.py` | Packs those meshes into the viewer's geometry blob |
| `stl/` | Rendered STLs, plus `views/` — assembled, exploded, detail and section |
| `superseded/` | Earlier designs. Kept for reference — **do not print** |
