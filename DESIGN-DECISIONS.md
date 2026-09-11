# Design Decisions

Why the printed parts are shaped the way they are. Each entry records what was
considered and what settled it, so a future change starts from the reasoning
rather than re-deriving it.

**Nothing here is deleted when it turns out to be wrong.** Several of these were
reversed — twice, in one case — and the reversals are the most useful entries in
the file. The index says which still hold, so you do not have to read all of it
to find out.

| | Decision | Status |
|---|---|---|
| **D1** | Mariotte reservoir, chosen on cost | dropped by D11, reinstated by D13 |
| **D2** | Nothing mounts on the terrarium lid | holds |
| **D3** | PETG, and the seal is not a print | holds, but the gasket became a captured bottle cap |
| **D4** | The fog port is a teardrop | superseded by **D18** — teardrops fix holes, not spigots |
| **D5** | The lid seats on the rim and prints upside down | holds |
| **D6** | Levels referenced to the module's top face | superseded by **D14** — datum settled from the datasheet |
| **D7** | Nothing is printed until `verify.py` passes | holds, and **D15**/**D16** say why it was not enough |
| **D8** | The chamber is a cut PET bottle | superseded by **D13** |
| **D9** | Wall thickness is a multiple of the nozzle | holds |
| **D10** | A jar would also work | superseded by **D13** |
| **D11** | The reservoir outlived its justification | **reversed by D13** |
| **D12** | Vents and the fog port are in series | holds, as the fan and the nozzle |
| **D13** | The module was measured, and it invalidated everything | **holds — the pivot** |
| **D14** | Open questions | live |
| **D15** | The design was audited by boolean, and it did not survive | holds |
| **D16** | A leak is a topology question, not a dimension | holds |
| **D17** | Nothing that must not leak is left to two cylinders grazing | holds |
| **D18** | A teardrop fixes a hole, not a protrusion | holds |
| **D19** | The cable leaves through the lid | holds |
| **D20** | The foot exists because the bottle is a lever | holds |
| **D21** | The level is not the port height | holds |
| **D22** | The assembly model is generated, not drawn | holds |
| **D23** | A tilted spigot is shorter than it looks | holds |
| **D24** | The socket is cut for the standard, not for one cap | holds |
| **D25** | A chamfer takes the seat away before it takes the overhang | holds |

If you read only three: **D13** (measuring the real module invalidated the whole
design), **D15** (the rebuilt design still had eight defects, three fatal) and
**D16** (why watertightness is checked by counting voids).

---

## D1 — Mariotte reservoir, chosen on cost.

**Settled by:** a 4 M toman quote for the reservoir-less design.

The wide 20–75 mm band made a plain chamber *possible* — hold ~445 mL across the
band and refill fortnightly. But possible is not cheap. Sizing a vessel by
`footprint x band` meant a 96 x 96 x 187.5 mm box: **293 cm3, ~373 g of PETG.**

An inverted-bottle (Mariotte / chicken-waterer) reservoir holds the level
**constant**, which changes what the chamber is for. Two consequences, both
saving material:

1. **Park the level at the bottom of the band, not the top.** Nothing has to
   drift, so the level sits at 25 mm above the module instead of filling to 73.
   The water column drops from 118 mm to **68.5 mm**.
2. **Capacity moves into the bottle.** The chamber no longer stores anything, so
   its footprint is set only by the 45 mm module — a **74 mm bore**, cylindrical,
   because a cylinder needs the least wall for a given volume.

```
                      volume    PETG     refill
  plain chamber       293 cm3   373 g    22 days
  bottle + siphon     134 cm3   170 g    25 days   (0.5 L bottle)
```

**~55 % less material for a longer refill interval.** The bottle is free,
transparent so the level is visible, and cannot leak the way a printed vessel can.

> How it regulates: the standpipe hangs from the lid, its bottom opening at the
> target level. Water leaves the bottle until it seals that opening; air can then
> no longer enter, so flow stops. As water is consumed the level drops, air
> bubbles up the standpipe, and more water flows out. **The chamber must stay
> vented** — the lid's air holes are not optional, or atmospheric pressure cannot
> act on the water surface and the siphon stalls.

> The standpipe is offset 16 mm from centre so it does not sit directly over the
> atomising disc. Free area past it is 5.5x the fog port's, so the plume is not
> choked.

## D2 — Nothing mounts on the lid.

A lid-mounted reservoir works out at 1.7–2.7 kg on ~130 × 130 mm. Mesh lids bow
under far less, 3 mm acrylic creeps permanently, and glass fails suddenly and
directly above the animals.

The decisive objection is not structural though: **the lid opens every day** for
feeding and checks. No design survives lifting 2 kg of sloshing water off a
hinge twice a day.

## D3 — PETG, and the seal is a gasket, not a print.

The print service is FDM-only. Service-printed parts are not reliably watertight,
because the service prints to its own profile rather than one tuned for water.

- **PETG** for everything touching water — no hydrolysis (PLA embrittles and
  creeps in constant water contact), tolerant of the 5–45 °C the module allows.
- **XFlex (TPU)** is on the service's material list, so gaskets are *printed*
  rather than sourced as O-rings.
- Print settings that matter: **100 µm layers, ≥4 perimeters, ≥40 % infill.**
- The chamber has **no wall penetration below the water line.** The module's
  cable exits over the rim through a notch. The only hole in the vessel is the
  fog port, 150 mm up — 30 mm above the fill line. Nothing below water can leak.

## D4 — The fog port is a teardrop.

A round horizontal hole has a 90° overhang at its crown and needs support. The
teardrop profile self-supports, so the chamber prints upright with **zero
support material** — cheaper from a service and no scarring inside a vessel that
has to stay clean.

## D5 — The lid seats on the rim, and prints upside down.

Two failed attempts are worth recording, because both looked fine on screen.

**A rebate is not a seat.** Cutting a lid rebate into a 3 mm wall leaves a ledge
only `lid_clear` wide — 0.35 mm. A flush drop-in lid resting on that would fall
into the chamber. The seat has to be the **rim** itself: a full 3 mm annulus.

**Do not seat on a printed overhang.** A plate-on-spigot lid printed spigot-down
leaves a 3 mm unsupported ledge around the perimeter — and that ledge is the face
that lands on the rim. It prints droopy and the lid rocks.

The fix is orientation: **print the lid plate-top-down.** The spigot and the fill
collar then both rise from the bed, there is not a single overhang on the part,
and the seating face is bed-flat. That is the only reason the fill collar points
*down* in use.

## D6 — Levels are referenced to the module's top face.

The module sits 1.5 mm down in its locating recess, so levels measured from the
chamber floor overshoot by that much — the fill line worked out at 76.5 mm above
the module against a 75 mm ceiling. `module_top` now carries the recess, and the
lines sit inside the band with margin: **fill at 73 mm** (2 mm below the ceiling)
and **refill at 25 mm** (5 mm above the floor, as a dry-run guard).

## D7 — Nothing gets printed until `verify.py` passes.

Renders hide defects; a 288 g PETG part is expensive to get wrong. `cad/verify.py`
asserts levels against the datasheet band, port placement, fits and clearances,
mesh manifoldness, and does a **boolean interference test** of the lid seated on
the chamber.

Two things make it trustworthy rather than decorative:

- **A positive control.** The same test runs with the lid dropped 1 mm, which
  *must* collide. Without it, an interference check that silently measures
  nothing passes forever.
- **No stale reads.** OpenSCAD writes no file when a result is empty, so the
  harness deleted the target before each render — otherwise the previous run's
  mesh is read back as if it were this one's. That bug made the check report a
  clean part as colliding and a colliding part as clean.

The control is what caught D5: a 17 mm³ collision, where the rim area predicted
~1100 mm³, is what revealed the seat was only 0.05 mm wide.

## D8 — The chamber is a cut PET bottle.

A real quote settled this: **2.44 M toman for the 83.6 g chamber**, ~29,000 per
gram. That is far above material cost, so the price is machine time, and time on
FDM tracks **layer count** — the chamber was 126.5 mm tall at 100 um, i.e. 1,265
layers.

Printing a plain water container at that rate is the worst possible use of the
budget. It holds water and locates the module; **a PET bottle cut into a cup does
both for nothing**, and is more watertight than any FDM part plus transparent, so
the level is visible.

```
                             printed   PETG    height
  original box               293 cm3   373 g   187.5 mm   (quoted 4 M)
  printed cylinder + lid      99 cm3   126 g   120 mm
  cut bottle + vessel_lid     40 cm3    51 g    66 mm
```

Two constraints that are easy to get wrong:

- **Not a saucer.** A bird waterer's dish is ~15 mm deep. This module is 45 mm
  tall and wants 20-75 mm *above* that, so the water is ~66 mm deep and the
  vessel is a bottle cut at ~120 mm.
- **Not a carbonated bottle.** Soda bottle bases are petaloid - five domed feet -
  so the atomiser would sit tilted. Use a still water, juice or milk bottle,
  which have near-flat bases.

The lid's skirt is a shallow **cone**, self-centring over a 5 mm spread of
diameters, because bottle diameters vary by brand and the user should not have
to match a number exactly. It needs no seal: water sits at 66.5 mm and the joint
is at 120 mm, so it is never wet. Only the bottle-neck socket seals, via a
printed TPU washer.

## D9 — Wall thickness is a multiple of the nozzle, not a strength number.

Hydrostatic load here is trivial - 0.02 MPa hoop stress against PETG's ~50 MPa.
Wall thickness is set by **watertightness**, and watertightness is set by
perimeters, which a print service's calculator does not expose.

At 2 perimeters on a 0.4 mm nozzle, a 2.0 mm wall is 0.8 mm of shell wrapped
around 1.2 mm of 20 % infill - a porous sandwich that weeps no matter what infill
is set to. **1.6 mm is exactly 4 extrusions**, so the wall is 100 % shell.
Thinner is both cheaper and more reliable. Keep it a multiple of 0.4.

For the same reason, ask for **200 um layers, not 100**: half the layer count, and
half as many layer interfaces, every one of which is a potential leak path.

## D10 — A jar would also work.

The chamber is still two thirds of the print. It does nothing clever: it holds
water and locates the module. **Any watertight container with a >=70 mm bore and
>=130 mm depth would do the same job for near-nothing**, leaving only the
lid/standpipe assembly to print:

```
  chamber + lid + gasket    134 cm3   170 g
  lid + gasket only          47 cm3    59 g     ~65 % less again
```

Not adopted yet only because it needs a specific container to design the lid
around. If a suitable jar is available, that is the cheapest version of this
build by a wide margin.

## D11 — The reservoir outlived its justification.

Re-derived from scratch after the vessel became free. **The Mariotte reservoir
was correct only while the vessel was printed.**

Its purpose was holding the level constant so an *expensive* vessel could be
small: capacity cost `footprint x band` in PETG. Once the vessel became a cut
bottle, capacity became free — and the reason for the reservoir vanished. It was
carried forward on momentum, not on a reason that still held.

With a 55 mm band and a Ø88 bottle, the level can simply drift down the band:

```
  π/4 × 88² × 55 mm = 334 mL ÷ 20 mL/day  ≈ 17 days   (1.5 L bottle)
  π/4 × 103² × 55   = 458 mL              ≈ 23 days   (2 L bottle)
```

The reservoir bought endurance obtainable for free by cutting a bigger empty
bottle. What it cost: a standpipe, a TPU neck seal, a second bottle to mount and
keep upright, a siphon that can stall if the vents block — and **50 mm of part
height**, which is the cost driver.

```
                          printed   PETG   height   layers @100 um
  bottle + Mariotte lid   37.7 cm3   48 g   66 mm      660
  bottle + simple lid     26.1 cm3   33 g   15 mm      150
```

`vessel_lid` is kept for anyone who wants a genuinely constant level — steadier
fog output across the cycle — but it is not the default.

**The lesson worth keeping:** when a constraint disappears, re-derive the
decisions that were made to satisfy it. Three of them here were downstream of
"the vessel is expensive", and all three fell together.

## D12 — Vents and the fog port are in series.

Air in and fog out are the same flow path. The **smaller** opening sets
throughput, so vent area must be at least the port area. The original 5 x Ø5 mm
vents were 98 mm² against a 491 mm² port — **throttling the outlet to 20 %**.
Vents are now sized to ~1.15x the port, and `verify.py` checks the ratio on both
lids. Enlarging them also removes material.

## D13 — The module was measured, and it invalidated everything.

Handling the real part and running it in a bowl produced two numbers that no
amount of reading had given:

```
  module height        45 mm     (spec was right; my photo estimate of 29 was not)
  starts working       41 mm     water depth from the VESSEL FLOOR
  works                42-50 mm
  labours / splashes   >50 mm
```

The vendor's "effective water level 20-75 mm" is measured **from the ceramic disc
down in the well**, not from the base — which is why it never matched anything.

Three consequences, in order of importance:

**1. The usable band is 9 mm, not 55.** An unregulated vessel drifts from 41 to
50 mm and stops. On a Ø88 bottle that is ~3 days. **This reverses D11.** Dropping
the reservoir was correct arithmetic on a 55 mm band and simply wrong on a 9 mm
one. Level regulation is what makes this practical, not a refinement.

**2. The feed has to run outside the chamber.** The module is Ø45 *and* 45 mm
tall, and water sits at 44 mm. A standpipe hanging inside beside it needs a **Ø80
bore** to clear — and wall area goes with the square, so that is the difference
between a cheap part and an expensive one. Running the feed up the outside and
into a port at the water line keeps the bore at Ø60.

**3. It cannot run dry.** The unit has its own level probe and stops at 41 mm.
Every dry-run guard in the earlier designs was solving a problem the hardware had
already solved.

Everything drawn before this is in `cad/superseded/`.

## D14 — Open questions

- ~~**Water level datum.**~~ **Settled** by [MIST-MAKER.md](MIST-MAKER.md): the
  disc sits ~22 mm above the base in a recessed well, and the vendor's
  "20–75 mm" is the column *above the disc*. Depths here are total depth from
  the surface the module stands on, which is the chamber floor.
- **Mounting.** Hang-on-back bracket vs. table stand — deferred deliberately.
  The chamber is mounting-agnostic; the bracket is a separate part, so this
  choice does not block anything.
- ~~**Cap dimensions.**~~ **Settled by [D24](#d24--a-socket-cut-for-the-standard-fits-every-cap-a-measured-one-fits-one)**:
  the socket is cut for the finish standards instead of for one measured cap,
  so nothing has to be measured before printing.

## D15 — The design was audited by boolean, and it did not survive.

Everything from D13 onwards was drawn, rendered, checked by a harness that
reported 26/26, and looked right. Measuring it with booleans instead of reading
it found **eight defects, three of them fatal**:

```
  feed bore blocked by a 3 mm slug          337.9 mm3 of PETG across the conduit
  lid collided with the bottle socket       375.6 mm3 - it could not be fitted
  2 of 4 fan screw holes opened into the      1.7 mm3 breach at z 46.4-49.4,
    chamber BELOW the water line                     under water
  fan bore dipped 0.4 mm under the water    breach at z 49.0-49.4
  nozzle spigot bonded to the barrel by       0.2 mm3 - a hairline
  module "recess" cut into the UNDERSIDE    0.9 mm membrane holding the water
  fan bore was a plain horizontal hole      needed support the file said it did not
  flange was a 2.5 mm square ledge          a 90° overhang right round the part
```

The first two mean the thing could not be assembled, let alone work. Every one
was invisible in a render and invisible to arithmetic.

**What made the old harness miss them:** it checked *numbers* — is the port at
the water line, does the module fit the bore — and every number was right. The
defects were all in the *relationships between solids*, which only a boolean
sees. `verify.py` now renders the real parts and asks topological questions of
them; `checks.scad` exists only to be measured.

## D16 — A leak is a topology question, not a dimension.

The strongest check in the harness does not measure anything. It takes a box up
to the water line, subtracts the body, and **counts the voids**:

```
  2  correct: the wetted cavity (joined to the conduit through the port,
              which is the entire point of the port) and the outside air
  1  the wall is breached somewhere - it leaks
  3  the port never connected - the bottle feeds nothing
```

One number, and it cannot be satisfied by accident. It caught a defect that
arithmetic could not: the nozzle was tilted with `rotate([-45,0,0])`, which
tips +Y **downward**, so the fog outlet left the wall *below* the water line.
The parametric clearance check passed — it was computing where the nozzle was
*supposed* to be. The void count went to 1.

Every boolean check that can have a control has one: the lid one millimetre low
*must* collide, a 3 mm hole through the wall *must* merge the voids, a slug in
the conduit *must* split it. A test that cannot fail passes forever.

## D17 — Nothing that must not leak is left to two cylinders grazing each other.

The old feed column relied on the conduit and the barrel overlapping by 1.2 mm
where their surfaces crossed. That is a cusp: a zero-angle crevice, the weakest
joint FDM can produce, and the feed port was bored straight through it.

The conduit is now joined to the barrel by a **solid web**, and the web is
deliberately wider than the port (18 mm against 12). That matters for more than
strength: if the port broke out of the web's side, air would reach the conduit
directly and the Mariotte would stop regulating and simply drain.

The same rule killed the old fan pad and nozzle. A flat plate floating off a
Ø63 barrel touches it along a sliver — the nozzle's entire bond to the chamber
was **0.2 mm³**. The fan pad is now a boss filled solid back to the barrel, and
the nozzle starts *inside* the bore so the wall cut trims it, rather than being
butted against the outside.

## D18 — A teardrop fixes a hole. It cannot fix a protrusion.

Teardrops were used everywhere on the old part, including places they do nothing.
The distinction:

- A horizontal **hole** can be given a 45° roof, because the material above it
  is ours to shape. Every hole here is a teardrop — fan bore, feed port, even
  the Ø3.2 screw holes.
- A horizontal **protrusion** cannot. The underside of a round spigot sticking
  out of a wall is a 90° overhang whatever its cross-section, and cutting it
  back to 45° leaves a V that no hose will seal against.

So the nozzle is **tilted 45° up**. An inclined cylinder has every normal on its
underside at exactly the tilt angle, so at 45° the spigot *and its bore* are
self-supporting while staying perfectly round for the hose. Fog rises into it,
and condensate runs back into the chamber instead of dripping out of the hose.

The remaining overhang on the whole body is **9.4 mm²** of tessellation facets
at 48°, around the teardrop screw holes. `verify.py` measures this on the actual
triangles, in the actual print orientation — the lid is evaluated flipped,
because it prints plate-top-down.

## D19 — The cable leaves through the lid.

The old design notched the rim. A notch is free to print but it is a hole in the
side of a fog generator: fog leaves through it and runs down the outside.

MIST-MAKER.md §4 records something the earlier work did not know — the cable
ships with **a sliding conical rubber bung, 14 mm tapering to 11 mm, meant for a
chamfered hole**. A hole in the lid is vertical in the print, so it comes out
round and takes that bung; the countersink narrows as it rises and needs no
support either. The rim notch, and the matching notch in the lid that had to line
up with it, are both gone.

## D20 — The foot exists because the bottle is a lever.

A full 0.5 L bottle is **520 g on a 41 mm arm, 190 mm up**. Standing on the
barrel alone, the centre of mass sits about 30 mm off-axis inside a support edge
at 48 mm: the assembly tips at roughly 5°, next to a glass tank full of animals.

The foot is a 2.4 mm plate hulled from the barrel out under the column. It also
anchors a 145 mm tall print to the bed, which a Ø63 footprint does not.

**A bottle larger than 0.5 L must be supported independently.** 1.5 L is 1.5 kg
on the same arm and no foot fixes that.

## D21 — The level is not the port height.

Air has to break *into* the port as a bubble before water can leave, and that
costs `4σ/d` of head — **2.4 mm of water on a Ø12 port**. The level therefore
settles somewhere between the port's apex and 2.4 mm below it.

That is why the port is Ø12 rather than something tidier: the head goes as `1/d`,
so a narrow port is a level *error*, not a saving. And it is why the target is
**46 mm rather than the arithmetic centre of the 42–47 band**. Centring the port
would have put the low end of the real range at 42.5 mm — 1.5 mm from the probe
cut-off that stops the unit. At 46 the real range is 43.6–46.0, entirely inside
the band, clearing the probe by 2.6 mm and splashing by 4.0.

The 2 mm trim spacer covers the other direction: fit it under the module if the
level lands high and the unit spits droplets instead of fog.

## D22 — The assembly model is generated, not drawn.

Once the parts were rebuilt, the obvious next thing was a picture of them
together. The temptation is to model that separately — quicker to draw, and it
only has to *look* right.

`cad/assembly.scad` instead `include`s `params.scad` and `use`s `mister.scad`,
so the printed parts in it are literally the printed parts. The bought parts are
built from their own documentation rather than from memory: the module from
[MIST-MAKER.md](MIST-MAKER.md) §4 (Ø45 potted base, 20 mm splash collar, Ø20
disc recessed at 22 mm, probe beside it), the reservoir as a standard PET neck
finish. So the fits it shows are the real fits, and a change to `water_hold`
moves the water in the picture.

The same file feeds the interactive viewer through `export_parts.scad`, which
means the browser model, the rendered stills and the STLs the printer gets all
come from one set of numbers. A separately-drawn assembly would have been a
fourth version of the truth, and the whole point of D15 is that this design has
already been bitten by versions of the truth that only looked right.

Two things fell out of building it that are worth keeping:

- **It made D20 obvious.** The chamber is 99 mm; with the reservoir the assembly
  is 322 mm, and nearly all the mass is at the top on a 41 mm arm. The
  arithmetic said the same thing, but nobody feels an arithmetic tipping moment.
- **WebGL sections beat OpenSCAD sections.** OpenSCAD paints cut faces in the
  colour scheme's cutout colour whatever `color()` says, and `--render` discards
  per-part colours entirely; capping the cut with a real `projection()`
  cross-section works but costs a CGAL render per part. A clipping plane in the
  browser does it per fragment, in colour, live, and is draggable.

How to run it: **[cad/VIEWER.md](cad/VIEWER.md)**.

## D23 — A tilted spigot is shorter than it looks.

Spotted in the viewer, not in a check: the fog nozzle looked far too short to
push a hose onto. Measuring it was worse than looking at it. Sliding a modelled
hose down the nozzle axis until it fouled the barrel gave **under 4 mm** of
usable seat on an 18 mm spigot.

The reason is geometry that only applies to an *inclined* protrusion. A spigot
leaving a round barrel at 45° is buried unevenly — its upper side runs much
deeper into the wall than its lower side — and the hose stops against the
**short** side. Worse, it is the hose's outer *back corner* that hits first, not
its bore, so the length lost is set by the hose's OUTER radius:

```
  lost to clearing the barrel = (hose OD/2) x tan(tilt)
                              = (25/2 + 3) x tan(45°)
                              = 15.5 mm
```

Fifteen and a half millimetres of an 18 mm spigot were spent before the hose
could touch any of it. The screen showed a nozzle of respectable length, and
essentially none of it was usable.

**The fix is to derive the length rather than pick it.** `nozzle_len` is now
`hose_engage + (nozzle_od/2 + hose_wall)*tan(nozzle_tilt)` — 30.5 mm, of which
15 mm is clear seat with room to clamp behind the hose end. `verify.py` slides
the real hose down the real axis and checks it fouls nothing, with a control at
+8 mm that must foul.

**What it costs.** The nozzle rises at 45°, so a longer one reaches higher, and
the chamber is derived to keep it clear of the flange. The chamber grew from
98.9 mm to **107.7 mm**, and the build from 129 g to **137 g** — about 8 g, or
6 %, for a hose joint that actually holds. Both numbers fall straight out of
`params.scad`; shortening `hose_engage` shortens the part again if that trade
ever looks wrong.

**Why no check caught it.** Every existing nozzle check asked about the *bore* —
does it clear the water, does it clear the flange, does it throttle the fan. Not
one asked whether the thing a human has to attach could be attached. That is a
recurring shape in this design's history (D15, D16): the checks tested the part
against itself, and the defect was in the part's relationship to something else.
The new check models the hose.

## D24 — A socket cut for the standard fits every cap. A measured one fits one.

`cap_od` and `cap_h` were the last two numbers in `params.scad` marked MEASURE,
and they cut real geometry: the pocket, the anti-rotation ribs, and — through
`pocket_depth = cap_h + 1` — the height of the socket's top face. Getting them
wrong meant reprinting a 115 g part. Looking up what caps actually are showed
the guard was aimed at the wrong number:

```
  28 mm PCO-1881  soda, 2009-    cap Ø30.4 ±0.3   11-13 mm tall
  28 mm PCO-1810  soda, older    cap Ø31.0 ±0.4   14-17 mm tall
  29/25, 30/25    still water    cap Ø29.5-31      8-12 mm tall
```

**Diameter varies by under 2 mm. Height varies by 9 mm** — and height was the
one wired into the geometry. ISBT drawing 3784253-21 says why that matters: the
bottle's **neck support ring is Ø33.00**, sitting **H = 15.24 mm** below the
sealing face. The ring is *wider than the cap*, so it can never enter a Ø31.7
pocket; it has to stop on the socket's top face, and that face was pinned to
cap height:

```
  cap  9   mm tall  ->  +7.24 mm   OK
  cap 14   mm tall  ->  +2.24 mm   OK      <- what was drawn
  cap 16.5 mm tall  ->  -0.26 mm   the bottle cannot seat
```

The fix is not to measure better. It is to stop the part caring: a **ribbed
Ø32.4 grip** for the bottom 8 mm, and a **Ø34.5 counterbore** above it that the
support ring drops into whatever the cap height turns out to be. One body fits
every finish above, and a hole that widens as it rises adds no overhang, so it
costs nothing to print. The socket goes Ø38.1 → Ø40.9 and the part grows 2.3 mm.

The grip height is not a measured clearance but an argument from the finish: a
cap has to clear the support ring to screw on at all, so **the ring is always at
or above the cap's rim**. A ribbed section no taller than the shortest cap is
therefore below every ring there can be.

**And the harness could not see any of this.** `checks.scad` modelled the bottle
as a bare `cylinder(d = bottle_body_d, h = 250)` starting *above* `socket_top` —
no neck, no support ring — while `assembly.scad` drew the ring correctly for the
viewer. The two models disagreed, and the gate was using the blind one. It now
models the real finish. Exactly the lesson of **D15**, found again in the joint
**D14** called the one the Mariotte depends on.

The first control written for it was itself worthless, which is worth recording.
It filled the counterbore back in and expected the ring to collide — and it
reported **0 mm³**, because a PCO-1881 ring lands at 16.74 mm, *above* the 16 mm
socket top, in free air. The counterbore is for **short** necks, and the test was
seating a long one. A control that injects a defect the modelled case never
meets proves nothing at all.

So the envelope is tested instead of a guess: rather than invent a neck height
for a water finish there is no drawing for, the same neck is seated at the
**lowest ring that can physically occur**. A cap has to clear its own support
ring to screw on, so the ring is never below `cap_h_min`. That is the worst
point the design promises to handle, and filling the counterbore under it does
collide — by 217 mm³.

That test then failed twice more, both times in the harness rather than the
part, which is worth recording because both were mine.

**8.24 mm³ at the socket rim, and it was fictitious.** Rewriting `bottle()` had
quietly dropped the Ø25 × 4.5 straight section that `assembly.scad` has always
had between the support ring and the shoulder. Without it the shoulder starts
*at* the ring, so it was Ø35.25 by the time it reached the socket top instead of
Ø26.86, and fouled a Ø34.5 bore by 0.4 mm. No bottle is shaped like that — a
filling line's neck grippers need that straight section. The fix was to the
model, not the socket. `neck_straight` is flagged in `params.scad` as the one
dimension in the neck the ISBT drawing does not cover.

**And 8.24 mm³ before that, which was not fictitious.** The grip had been set to
`cap_h_min` exactly, so its top face and the lowest possible ring's underside
landed on the same z and the Ø33.2 ring came to rest on the Ø32.4 bore's edge —
0.20 mm of overlap across a 41.2 mm² annulus. The structural argument gave a
correct *bound* and was then used as if it were a *clearance*. The grip now
stops 1 mm below it (`cap_grip_margin`), and 7 mm still grips the shortest cap
over most of its height.

## D25 — A chamfer takes the seat away before it takes the overhang.

The fan pad carries two bolt patterns, 24 mm and 32 mm, so whichever fan is in
stock will fit. **D15** put a 45° chamfer under the pad, correctly: its flat
underside would otherwise have been the one horizontal ceiling on the part. What
nobody followed through was what the chamfer does to the *face above it*.

The seating face only exists where the chamfer cone has grown past the corner it
has to reach. That distance is not constant — it goes with `y`:

```
  ch_od/2 = 31.6                 the barrel
  face at sqrt(34.6² + y²)       how far out the flat face really is

  y =  0    face at 34.60    chamfer eats 3.00 mm of the pad
  y = 12    face at 36.62    eats 5.02 mm   <- 30 mm fan bolt circle
  y = 16    face at 38.12    eats 6.52 mm   <- 40 mm fan bolt circle
```

On a 42 mm pad that put the 40 mm fan's **lower two screws 1.75 mm below where
the flat face starts** — their holes opened onto the chamfer. A 30 mm fan was
fine, with 4.29 mm to spare. So "drilled for both" was half true, and the half
that failed was the more common fan.

The consequence is not cosmetic: the fan frame would bridge a gap at its lower
edge and those two screws would be tightened into a slope, loading them in
bending and levering at the chamfer's edge.

The pad height is now **derived from the widest pattern it claims to take**
rather than picked:

```
  fan_pad = fan_pitch_max + 2*fan_seat + 2*(fan_face_r - ch_od/2)
```

which leaves exactly `fan_seat` of flat under the lowest screw by construction,
whatever patterns the pad carries. `fan_pad_top` stays below `nozzle_top`, so
`ch_h` does not move.

**And since the pad now sizes itself, it may as well carry a third pattern.**
Which fan actually does the job through a Ø26 bore is a question you answer by
trying them, so 24, 32 and 40 mm pitches are all drilled: 30, 40 and 50 mm fans
bolt straight on, and `fan_pad` follows the widest at 59.93 mm. Twelve blind
holes, 2.46 mm of material between the closest pair.

The range is bounded at both ends by the barrel, not by choice:

```
  25 mm fan  20 mm pitch   1.3 mm of screw wall   under the 1.6 limit
  30 mm fan  24 mm pitch   2.1 mm                 the tightest one drilled
  50 mm fan  40 mm pitch   7.2 mm                 pad_top 98.2 < 99.7
  60 mm fan  50 mm pitch   pad wraps past the barrel AND pushes ch_h up
```

The narrow end is the dangerous one and it is not obvious: the barrel curves
*closest to the pad* at small pitches, so it is the 30 mm fan's screws, not the
50 mm fan's, that come nearest to opening into the water. `verify.py` takes
`fan_pitch_min` for that check and `fan_pitch_max` for the seat, which are
different patterns.

Worth saying plainly, since it decides what to buy: **fan diameter is not what
sets performance here.** Every fan blows through the same Ø26 bore and out the
same Ø20 nozzle, so the duct is the restriction and what matters is static
pressure, not the airflow figure on the box. A 30 mm at 12 V can beat a 50 mm
at 5 V.

**The check is geometric, and its control is history.** `verify.py` now finds
the pad's seating face on the real triangles — normals at −x, at the pad plane —
and measures how far the flat reaches down at each bolt circle. Run it against
the body committed before this change and it reports −1.75 mm and fails. A test
whose control is the part you shipped yesterday is the cheapest one to trust.

The pattern is the same as **D24**: a feature added for a good reason (there, a
counterbore; here, a chamfer) quietly consumed something else the design needed,
and no check was watching the thing it consumed.
