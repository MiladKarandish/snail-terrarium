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

## D8 — A jar could replace the chamber entirely.

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

## D9 — Open questions

- **Water level datum.** The spec says "effective water level 20–75 mm" without
  stating the datum. Read here as *above the module's top face* (consistent with
  how this class of module is always specified, and with the 45 mm module height
  making a 20 mm total depth impossible). Worth confirming on first fill: if
  fogging is weak at the refill line, the datum is the vessel floor and both
  lines move up by 45 mm.
- **Mounting.** Hang-on-back bracket vs. table stand — deferred deliberately.
  The chamber is mounting-agnostic; the bracket is a separate part, so this
  choice does not block anything.
