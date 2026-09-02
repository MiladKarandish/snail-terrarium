# Design Decisions

Why the printed parts are shaped the way they are. Each entry records what was
considered and what settled it, so a future change starts from the reasoning
rather than re-deriving it.

---

## D1 — No reservoir. The chamber *is* the reservoir.

**Settled by:** the module's own spec — **effective water level 20–75 mm**.

The original plan was an inverted-barometric (Mariotte / chicken-waterer)
reservoir to hold a constant level. That solves *"maintain a precise depth while
consuming water quickly."* Neither half of that premise survived checking:

**Consumption is tiny.** A 47 L tank at 22 °C / 80 %RH holds ~15.5 g/m³ of
vapour; room air at 50 %RH holds ~9.7. At ~2.7 m³/day of air exchange the tank
loses `2.7 × 5.8 ≈ 16 mL/day`, plus ~1 mL/day passive. Fog that condenses on
glass and duct runs back into the substrate — it stays in the system. So the
module consumes roughly **20 mL/day**, and at 550 mL/h that is **~2 minutes of
runtime per day**.

**The tolerance band is wide.** 20–75 mm is a **55 mm** window. A 90 × 90 mm
chamber releases 445 mL across that band:

```
81 cm² × 5.5 cm = 445 mL  ÷  20 mL/day  ≈  22 days between refills
```

So the level may simply drift down the band between fortnightly refills. That
deletes the bottle, the shroud, the standpipe, the level shims, every seal, and
the tower height needed to stack a bottle above the chamber.

> Interim resellers of a *different* OEM module quoted "4 to 5 cm, do not exceed
> 5 cm" — a 10 mm band, which **would** have required regulation. The reservoir
> was correct right up until the real datasheet arrived. If the module is ever
> swapped, re-check this number first: it is the hinge the whole design turns on.

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

## D5 — Open questions

- **Water level datum.** The spec says "effective water level 20–75 mm" without
  stating the datum. Read here as *above the module's top face* (consistent with
  how this class of module is always specified, and with the 45 mm module height
  making a 20 mm total depth impossible). Worth confirming on first fill: if
  fogging is weak at the refill line, the datum is the vessel floor and both
  lines move up by 45 mm.
- **Mounting.** Hang-on-back bracket vs. table stand — deferred deliberately.
  The chamber is mounting-agnostic; the bracket is a separate part, so this
  choice does not block anything.
