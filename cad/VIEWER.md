# The 3D assembly viewer

An interactive model of the whole mister — printed parts, mist module, bottle,
fan, hose, cable and water — that you can orbit, pull apart and cut through in a
browser. It exists because the fits that matter here are between parts, and
those are the ones a still render hides.

Everything in it is generated from `params.scad`, so it cannot drift away from
what `verify.py` checks and what the printer gets.

---

## Quick start

```bash
cd cad
../.venv/bin/python viewer.py
```

That renders any out-of-date meshes, builds the page and serves it at
**http://127.0.0.1:8017/**. First run takes a couple of minutes because
OpenSCAD has twelve components to tessellate; after that it is instant.

Needs `openscad` on the PATH and the project's venv (`trimesh`, `numpy`).

### Options

| Flag | What it does |
|---|---|
| *(none)* | Build, then serve on `127.0.0.1:8017` |
| `--build` | Build `viewer/index.html` and stop |
| `--port N` | Serve on a different port |
| `--cdn` | Load three.js from a CDN instead of inlining it — 227 KB instead of 816 KB, but the page then needs a network |
| `--force` | Re-render every mesh, even ones that look current |

## Three ways to open it

1. **`viewer.py`** — builds and serves. The normal way.
2. **Straight off the disk.** `viewer.py --build`, then open
   `cad/viewer/index.html`. The page is one self-contained file — geometry,
   styles, script and three.js are all inlined — so it needs no server and
   no network. Nothing about it depends on being served over HTTP.
3. **The published artifact**, if you want it on a phone or to send to
   someone: <https://claude.ai/code/artifact/39a16ace-5516-4eab-a32e-9712b58abccf>.
   Same template, built with `--cdn`.

`viewer/index.html` is generated and **gitignored**. `viewer/template.html` is
the source and is tracked. If you only want a picture, four stills rendered from
the same model are committed in `stl/views/`.

---

## Controls

| | |
|---|---|
| **Orbit** | Drag |
| **Zoom** | Scroll |
| **Pan** | Right-drag, or shift-drag |
| **Explode** | Slider — 0 % assembled to 100 % fully apart |
| **Section** | Slider — sweeps a cutting plane through the model from "off" to just past the centre. Interior walls are drawn, so you see the bore, the water and the feed port in one view |
| **Show / hide a part** | Click it in the legend |
| **Spin** | Slow turntable. Honours `prefers-reduced-motion` |
| **Reset view** | Back to the default three-quarter |

Three parts appear and disappear on their own, because showing them otherwise
would be a lie:

- **Water** and the **cable route** only exist assembled, so they hide as soon
  as you start exploding.
- The **trim spacer** is an optional part you fit only if the level lands high,
  so it only appears once the model is pulled apart.

## The water-level gauge

The panel on the right is the one piece of the page that is not geometry. It
plots the module's own limits from [MIST-MAKER.md](../MIST-MAKER.md) against
where this design actually sits:

```
  50.0   chokes, spits drops instead of fogging
  47.0 ┐
       │ optimal band
  46.0 │ ← the feed port's apex: the level the design aims at
  43.6 │ ← where it really settles, 2.4 mm lower, because air has to
  42.0 ┘   bubble into the port before water can leave
  41.0   probe cuts the unit out
```

The whole settling range sits inside the optimal band with 2.6 mm of margin over
the probe. That is the reason the target is 46 and not the arithmetic middle of
the band — see **D21** in [DESIGN-DECISIONS.md](../DESIGN-DECISIONS.md).

The gauge is hidden below 1080 px wide, where there is no room for it.

---

## How it is built

```
  params.scad ──┬── mister.scad ────┐            the printed parts
                └── assembly.scad ──┤            the bought parts
                                    ▼
                          export_parts.scad      one component at a time
                                    │  openscad, per-part tessellation
                                    ▼
                        .build/parts/*.stl       12 meshes
                                    │  tools/pack_viewer.py
                                    ▼
                        one JSON blob, 207 KB    uint16 positions +
                                    │            index buffers, base64
                                    ▼
        viewer/template.html ──► viewer/index.html
                                    ▲
                    .build/three.min.js (cached, inlined)
```

`viewer.py` re-renders a mesh only when its `.stl` is older than `params.scad`,
`mister.scad`, `assembly.scad` or `export_parts.scad`. Change a dimension and
the next run rebuilds against it.

The figures in the title block — chamber size, mass, water level, wetted volume,
checks passed — are **not written into the template**. `verify.py` publishes them
to `.build/facts.json` on every run and `viewer.py` substitutes them, so the page
can only ever quote numbers that were actually verified. Build the viewer without
having run `verify.py` and they show as `?` rather than as something stale.

Positions are quantised to `uint16` against **one bounding box shared by every
part**, which is what keeps them in register with each other and turns 3 MB of
STL into a 207 KB blob. Geometry is de-indexed before normals are computed, so
the parts render flat-shaded: these are machined faces, not organic surfaces,
and smooth normals would round off every edge the design depends on.

---

## Changing it

**Add a part.** Give it a `PART ==` branch in `export_parts.scad`, then a row in
`PARTS` in `tools/pack_viewer.py` (name, label, colour, opacity, explode vector,
group) and in `COMPONENTS` in `viewer.py` (name, `$fa`, `$fs`). The legend
builds itself from that list.

**Move something in the explode.** Edit its explode vector in
`tools/pack_viewer.py`. The vector is in **OpenSCAD coordinates** — the page
rotates the whole model Z-up-to-Y-up once, so you never think in three.js axes.

**Smoother or lighter meshes.** `COMPONENTS` in `viewer.py` carries `$fa` and
`$fs` per part. Most run at `$fa=5, $fs=1.0`; the hose is a chain of hulled
spheres and gets expensive fast, so it runs at `$fa=12, $fs=3.0`. Then
`--force`.

**Colours and layout** live in `viewer/template.html` as CSS custom properties,
with light and dark palettes defined token-by-token. Part colours come from
`pack_viewer.py` so the 3D and the legend swatches cannot disagree.

---

## Troubleshooting

| | |
|---|---|
| **Blank stage, page otherwise fine** | WebGL is off or blocked. Check `chrome://gpu`, or try another browser |
| **`missing .../parts/x.stl`** | Run `viewer.py` rather than `pack_viewer.py` directly — `viewer.py` is what exports the meshes |
| **`openscad failed on <part>`** | The CAD does not compile. Run `verify.py`, which reports properly |
| **Geometry looks stale after an edit** | `viewer.py --force` |
| **`could not fetch three.js`** | No network on first build. It is cached at `.build/three.min.js` afterwards; copy one in by hand if you need to |
| **Page is 816 KB** | That is three.js inlined, and it is why the file works offline. Use `--cdn` for 227 KB |
| **Port already in use** | `--port 8018` |

## Why these choices

**three.js r128, pinned and inlined.** Pinned because an unpinned CDN version
silently changes API under a page nobody is watching. Inlined because a viewer
that needs a network to open is not much use next to a printer.

**A clipping plane instead of an OpenSCAD section.** OpenSCAD paints every cut
face in the colour scheme's cutout colour no matter what `color()` says, and a
full `--render` discards per-part colours altogether. Capping the cut with a real
`projection()` cross-section fixes both but costs a CGAL render per part, which
runs into minutes. WebGL clips per fragment, in colour, live.

**One template for both the local page and the artifact**, so the two cannot
drift apart. The only difference is whether three.js is inlined or linked.
