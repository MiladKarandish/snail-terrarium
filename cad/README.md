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
| `stl/mister_body.stl` | Chamber, feed column, bottle socket | 1 | 99 × 100 × 147 mm | 113 cm³, ~144 g |
| `stl/mister_lid.stl` | Lid with cable gland | 1 | 67 × 68 × 9 mm | 16 cm³, ~20 g |
| `stl/mister_spacer.stl` | Trim spacer — only if the level lands high, see *Commissioning* | 0–1 | 43 × 43 × 2 mm | 2 cm³, ~3 g |

Total for the build: **~132 cm³, ~167 g of PETG.**

Also needed, not printed:

- A **0.5 L still-water PET bottle** and its cap. Not carbonated — petaloid
  bases sit crooked. Any standard closure fits: 28 mm PCO-1881 or PCO-1810
  (soda) and 29/25 or 30/25 (water) are all within the socket's range.
- A **30, 40 or 50 mm fan**, 5 V or 12 V. The pad is drilled for all three
  (24, 32 and 40 mm bolt pitch) and is tall enough that **all four screws of any
  pattern land on flat pad**, not on the chamfer under it — see **D25**.
  4 × M3 screws. Pick on **static pressure, not airflow**: everything goes
  through the same Ø26 bore and Ø20 nozzle, so the duct sets the restriction and
  a small fast fan often beats a big slow one. 25 mm fans are not drilled (only
  1.3 mm of screw wall) and 60 mm will not fit the barrel.
- **25 mm ID hose** for the fog line, and a clamp or zip tie. The spigot
  gives it **15 mm** of clear seat, with room to clamp behind the end.
- **Epoxy** for the cap.
- **RO or distilled water.** Not optional — see [MIST-MAKER.md §5](../MIST-MAKER.md).

## Build

```bash
../.venv/bin/python verify.py
```

Renders the STLs into `stl/` and runs 57 checks. **It must print `57/57` before
anything goes to a printer.** It checks levels against the datasheet band, fits
and clearances, that the wall is unbreached below the water line, that the lid
seats *and* comes off, that the feed is actually open end to end, that a hose
will go far enough onto the nozzle, and that nothing on either part overhangs
past 45° in its print orientation. Five checks run twice, once with a defect
injected that must fail — a test that cannot fail is not a test.

It also writes `.build/facts.json`, which is where the viewer's title block gets
its figures, so nothing downstream quotes a number that was not verified.

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

It is also live at **<https://snail-terrarium-mister.vercel.app>**; `viewer.py --deploy`
rebuilds and pushes it.

Full reference, controls and troubleshooting: **[VIEWER.md](VIEWER.md)**.

If you just want pictures rather than something to spin:

```bash
../.venv/bin/python viewer.py --stills
```

re-renders the five images in `render/` from the same model. `assembly.scad`
takes `EXPLODE` (0–1), `SECTION` and `BOTTLE` if you want a view of your own.

## How the level holds itself

Water only leaves the bottle if air can get in to replace it. That is not a
detail — it is the whole mechanism, and the port does both jobs:

```
   bottle                    air goes UP the same tube the water comes DOWN
     │  water down
     ▼  ▲ air up             1. level sits at the port's apex
   ┌────┴───┐                2. it drops slightly - evaporation, or a burst
   │        │  Ø12 conduit   3. the apex is now above water, exposed to the
   │        │                   chamber's air
   │   ┌────┴──┐             4. air bubbles in, rises the conduit, reaches
   │   │ apex  │ ◄─ port        the bottle
 ══╪═══╪══════════ water     5. an equal volume of water runs out, the level
   │   │       │                rises and re-seals the apex
```

Nothing measures anything and nothing switches. The level is set by where the
air can get in, which is a printed edge, and it is stable because sealing that
edge stops the flow.

Three things have to be true, and all three are checked or specified:

- **The conduit must be wide enough for air and water to pass each other.**
  Ø12; counter-flow stalls below about 6 mm. The whole air path — port, conduit,
  the hole you drill in the cap — is Ø10 or wider.
- **The chamber must be vented.** It is, through the fan bore and the nozzle,
  both well above the water. A sealed chamber cannot let air into the port and
  the feed stalls.
- **The bottle must be sealed except through the conduit.** That is the epoxied
  cap. If air leaks in past it, the bottle drains instead of regulating — which
  is the failure listed in *Commissioning*.

The fan blowing into the chamber does not shift the level: the same pressurised
air presses on the water surface *and* is what enters the port, so it cancels.

## Print settings

| | Body | Lid | Spacer |
|---|---|---|---|
| Orientation | Upright, open end up, on the foot | **Plate-top-down** — spigot up | Flat |
| Support | **None** | **None** | None |
| Material | PETG | PETG | PETG |
| Layer | 0.2 mm | 0.2 mm | 0.2 mm |
| Perimeters | **≥ 4** | ≥ 3 | ≥ 3 |
| Infill | ≥ 30 % | ≥ 30 % | ≥ 20 % |

The STLs are exported **already lying in these orientations** — a print service
slices a file as it is uploaded, so upload them as they are and do not rotate them.

**Perimeters are the setting that matters.** The wall is 1.6 mm, which is
*exactly* four extrusions at a 0.4 mm nozzle, so at ≥ 4 perimeters it is 100 %
shell with no infill inside it to weep through. At 2 perimeters the same wall is
0.8 mm of shell wrapped around 0.8 mm of infill, and it will seep no matter what
infill percentage is set. Ask for 0.2 mm layers rather than 0.1: half the layer
count, half as many interfaces, each one a potential leak path.

PETG, not PLA — PLA embrittles and creeps in constant water contact.

## Assembly

1. **No measuring needed.** The socket is cut for the finish standards, not
   for one cap: a ribbed Ø32.4 grip takes any closure from Ø29.5 to Ø31.4, and
   a Ø34.5 counterbore above it clears the bottle's Ø33 neck support ring
   whatever the cap height is. 28 mm PCO-1881, PCO-1810 and 29/25 or 30/25
   water caps all fit the same part — see **D24**.
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
7. **Thread the cable** up through the lid's hole from underneath. The
   countersink is on the lid's **underside**, so the module's own conical rubber
   bung seals from *below*: slide it down the cable towards the module first —
   at Ø14 it will not pass the Ø11.5 hole — then thread the plug up through the
   lid, and push the bung **up** into the countersink, narrow end first. The fan
   pressurises the chamber, which presses the bung tighter rather than out. The
   bung only slides, and the plug stops it coming off the cable, so check which
   way its narrow end points before you start.
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
| `section2d.scad` | True vertical section, rendered from the real solids |
| `assembly.scad` | The whole thing together, printed and bought parts. Not printable |
| `export_parts.scad` | Splits the assembly into meshes for the viewer |
| `viewer.py` + `viewer/` | Builds and serves the interactive 3D assembly — see [VIEWER.md](VIEWER.md) |
| `tools/pack_viewer.py` | Packs those meshes into the viewer's geometry blob |
| `stl/` | The printable meshes, binary STL. Written by `verify.py` |
| `render/` | Pictures of the assembly — assembled, detail, exploded, section, and a true vertical section as SVG. Written by `viewer.py --stills` |
| `superseded/` | Earlier designs. Kept for reference — **do not print** |
