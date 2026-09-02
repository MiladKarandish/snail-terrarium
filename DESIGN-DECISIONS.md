# Design Decisions

Why the printed parts are shaped the way they are. Each entry records what was
considered and what settled it, so a future change starts from the reasoning
rather than re-deriving it.

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

## D13 — Open questions

- **Water level datum.** The spec says "effective water level 20–75 mm" without
  stating the datum. Read here as *above the module's top face* (consistent with
  how this class of module is always specified, and with the 45 mm module height
  making a 20 mm total depth impossible). Worth confirming on first fill: if
  fogging is weak at the refill line, the datum is the vessel floor and both
  lines move up by 45 mm.
- **Mounting.** Hang-on-back bracket vs. table stand — deferred deliberately.
  The chamber is mounting-agnostic; the bracket is a separate part, so this
  choice does not block anything.
