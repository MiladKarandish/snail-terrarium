#!/usr/bin/env python3
"""Pack the exported assembly parts into one JSON blob for the web viewer.

Positions are quantised to uint16 against a single shared bounding box, so
every part stays in register with every other one and the whole assembly
costs a few hundred KB instead of a few megabytes of STL.

    openscad -o .build/parts/<part>.stl -D 'PART="<part>"' export_parts.scad
    python3 tools/pack_viewer.py > .build/parts.json
"""
import base64, json, pathlib, sys, numpy as np, trimesh

CAD = pathlib.Path(__file__).resolve().parent.parent
SRC = CAD / ".build" / "parts"

# name, label, colour, opacity, explode vector, group
PARTS = [
    ("body",   "Chamber",        "#4a7ebb", 1.00, (0, 0, 0),      "printed"),
    ("lid",    "Lid",            "#7ba4d9", 1.00, (0, 0, 115),    "printed"),
    ("spacer", "Trim spacer",    "#9dbde2", 1.00, (0, 0, 105),    "printed"),
    ("module", "Mist module",    "#31333a", 1.00, (0, 0, 150),    "bought"),
    ("cap",    "Bottle cap",     "#2f6f3f", 1.00, (0, 0, 55),     "bought"),
    ("bottle", "0.5 L bottle",   "#cfe0e8", 0.30, (0, 0, 120),    "bought"),
    ("fan",    "40 mm fan",      "#3a3d44", 1.00, (-70, 0, 0),    "bought"),
    ("screws", "M3 screws",      "#b8bcc4", 1.00, (-95, 0, 0),    "bought"),
    ("hose",   "25 mm hose",     "#26262b", 0.92, (0, 49.5, 49.5), "bought"),
    ("bung",   "Cable bung",     "#3a3a3a", 1.00, (0, 0, 135),    "bought"),
    ("cable",  "Cable",          "#4a4a4a", 1.00, (0, 0, 0),      "bought"),
    ("water",  "Water",          "#3f9ed8", 0.45, (0, 0, 0),      "media"),
]

def pack(src: pathlib.Path = SRC) -> str:
    """Return the packed assembly as one JSON string."""
    meshes = {}
    for name, *_ in PARTS:
        f = src / f"{name}.stl"
        if not f.exists():
            raise SystemExit(f"missing {f} - run viewer.py to export the meshes")
        m = trimesh.load(f)
        m.merge_vertices()
        meshes[name] = m

    lo = np.min([m.bounds[0] for m in meshes.values()], axis=0)
    hi = np.max([m.bounds[1] for m in meshes.values()], axis=0)
    span = float((hi - lo).max())
    scale = span / 65535.0

    out = {"origin": lo.tolist(), "scale": scale,
           "bbox": [lo.tolist(), hi.tolist()], "parts": []}

    for name, label, color, opacity, explode, group in PARTS:
        m = meshes[name]
        q = np.rint((m.vertices - lo) / scale).astype(np.uint16)
        wide = len(m.vertices) > 65535
        idx = m.faces.astype(np.uint32 if wide else np.uint16)
        out["parts"].append({
            "name": name, "label": label, "color": color, "opacity": opacity,
            "explode": list(explode), "group": group, "tris": int(len(m.faces)),
            "wide": bool(wide),
            "pos": base64.b64encode(q.tobytes()).decode(),
            "idx": base64.b64encode(idx.tobytes()).decode(),
        })
    return json.dumps(out, separators=(",", ":"))


if __name__ == "__main__":
    blob = pack()
    print(blob)
    print(f"{len(blob)/1024:.0f} KB", file=sys.stderr)
