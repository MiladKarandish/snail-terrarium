# Superseded

All of these were drawn against a module height that turned out to be wrong.

The vendor spec reads "Ø45 x 45 mm", which I first took as a cube, then — from
photographs — as a ~29 mm body plus a removable cap. **Both were wrong. The
module is 45 mm tall.**

That single number invalidates every part in here, because each hangs a Mariotte
standpipe *inside* the chamber beside the module. With a Ø45 module that is also
45 mm tall, and the water held at 44 mm, a standpipe alongside it needs a **Ø80
bore** to clear — nearly double what these were drawn for, and the wall area
scales with the square.

The replacement runs the feed **outside** the chamber wall, entering through a
port at the water line, which keeps the bore at Ø60.

Kept for reference only. Do not print.

---

## Second wave: the first bottle-fed body

`mister_section.scad`, `gasket.scad` and `cap_chamber.scad` joined them later,
for different reasons:

- **`gasket.scad`** — the TPU neck washer. Replaced by the captured PET cap,
  whose own liner does the sealing. That is what a bottle cap liner is *for*.
- **`cap_chamber.scad`** — an alternative two-part cup-and-top arrangement,
  never built. It still hangs a standpipe inside beside the module, so it has
  the same Ø80 problem as everything else here.
- **`mister_section.scad`** — sectioned the *STL files* rather than the model,
  so it showed whatever was last exported instead of what the source says.
  Replaced by `../section2d.scad`, which sections the real solids.

The body those were drawn against was itself replaced after a boolean audit
found eight defects in it, three of them fatal — see **D15** in
[../../DESIGN-DECISIONS.md](../../DESIGN-DECISIONS.md). Retired parameters those
files still need live in `legacy_params.scad`, so they open and render, but
nothing here is current.
