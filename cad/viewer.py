#!/usr/bin/env python3
"""Build and serve the interactive assembly viewer.

    ../.venv/bin/python viewer.py            build, then serve on localhost
    ../.venv/bin/python viewer.py --build    build viewer/index.html and stop
    ../.venv/bin/python viewer.py --cdn      load three.js from a CDN instead
                                             of inlining it (smaller file,
                                             needs a network to open)
    ../.venv/bin/python viewer.py --force    re-export the meshes even if the
                                             cached ones look current
    ../.venv/bin/python viewer.py --deploy   build, then push to git, which
                                             is what Vercel deploys from
    ../.venv/bin/python viewer.py --stills   re-render the still images in
                                             render/ and stop

The page it writes is ONE self-contained file: geometry, styles, script and
(by default) three.js itself are all inlined, so viewer/index.html opens
straight off the disk with no server and no network. The server is only a
convenience, and because everything is inlined it is not required.

Geometry comes from export_parts.scad, which pulls the printed parts from
mister.scad and the bought parts from assembly.scad, so the viewer cannot
drift away from what verify.py checks and the printer gets.
"""
import argparse, http.server, json, os, socketserver, subprocess, sys, pathlib, urllib.request

CAD    = pathlib.Path(__file__).resolve().parent
BUILD  = CAD / ".build"
PARTS  = BUILD / "parts"
OUT    = CAD / "viewer"
TPL    = OUT / "template.html"
THREE  = BUILD / "three.min.js"
THREE_URL = "https://cdnjs.cloudflare.com/ajax/libs/three.js/r128/three.min.js"
THREE_TAG = f'<script src="{THREE_URL}"></script>'

# Every part the viewer shows. Tessellation is per part: the hose is a chain
# of hulled spheres and gets very expensive very fast, and it is a matte black
# tube that nobody inspects closely.
COMPONENTS = [("body", 5, 1.0), ("lid", 5, 1.0), ("spacer", 5, 1.0),
              ("module", 5, 1.0), ("water", 5, 1.0), ("cable", 5, 1.0),
              ("bung", 5, 1.0), ("cap", 5, 1.0), ("bottle", 5, 1.0),
              ("fan", 5, 1.0), ("screws", 5, 1.0), ("hose", 12, 3.0)]

SOURCES = ["params.scad", "mister.scad", "assembly.scad", "export_parts.scad"]


def newest_source() -> float:
    return max((CAD / f).stat().st_mtime for f in SOURCES)


def export(force: bool) -> None:
    PARTS.mkdir(parents=True, exist_ok=True)
    src_time = newest_source()
    todo = [(n, fa, fs) for n, fa, fs in COMPONENTS
            if force or not (PARTS / f"{n}.stl").exists()
            or (PARTS / f"{n}.stl").stat().st_mtime < src_time]
    if not todo:
        print(f"meshes up to date ({len(COMPONENTS)} parts)")
        return
    for i, (name, fa, fs) in enumerate(todo, 1):
        print(f"  [{i}/{len(todo)}] rendering {name} ...", flush=True)
        r = subprocess.run(
            ["openscad", "-o", str(PARTS / f"{name}.stl"),
             "-D", f"$fa={fa}", "-D", f"$fs={fs}", "-D", f'PART="{name}"',
             str(CAD / "export_parts.scad")],
            capture_output=True, text=True)
        if r.returncode != 0:
            sys.exit(f"openscad failed on {name}:\n{r.stderr.strip()[:800]}")


def three_js() -> str:
    """three.js, cached in .build. Inlining it is what lets the page work
    with no network at all."""
    if not THREE.exists():
        print("  fetching three.js r128 ...", flush=True)
        try:
            with urllib.request.urlopen(THREE_URL, timeout=60) as r:
                THREE.write_bytes(r.read())
        except Exception as e:
            print(f"  could not fetch three.js ({e}); falling back to the CDN "
                  "tag - the page will need a network to open", file=sys.stderr)
            return THREE_TAG
    js = THREE.read_text()
    if "</script" in js:            # would close our own tag early
        return THREE_TAG
    return "<script>" + js + "</script>"


def build(cdn: bool) -> pathlib.Path:
    sys.path.insert(0, str(CAD / "tools"))
    import pack_viewer
    blob = pack_viewer.pack(PARTS)
    if "</" in blob:                 # same hazard, for the geometry blob
        sys.exit("packed geometry contains '</' and would break the script tag")

    html = TPL.read_text()
    html = html.replace("__PARTS_JSON__", blob)

    # The title block quotes what verify.py actually measured, so it cannot
    # drift from the checked design. verify.py writes these on every run.
    facts = BUILD / "facts.json"
    if facts.exists():
        f = json.loads(facts.read_text())
        for k, v in {"__F_OD__": f["chamber_od"], "__F_H__": f["chamber_h"],
                     "__F_G__": f["grams"], "__F_WL__": f["water_hold"],
                     "__F_ML__": f["wetted_ml"], "__F_MIN__": f["burst_min"],
                     "__F_PASS__": f["passed"], "__F_TOT__": f["total"]}.items():
            html = html.replace(k, str(v))
    elif "__F_" in html:
        print("  no .build/facts.json - run verify.py so the title block can "
              "quote real numbers", file=sys.stderr)
        html = html.replace("__F_OD__", "?").replace("__F_H__", "?") \
                   .replace("__F_G__", "?").replace("__F_WL__", "?") \
                   .replace("__F_ML__", "?").replace("__F_MIN__", "?") \
                   .replace("__F_PASS__", "?").replace("__F_TOT__", "?")
    html = html.replace("__THREE__", THREE_TAG if cdn else three_js())
    OUT.mkdir(exist_ok=True)
    dst = OUT / "index.html"
    dst.write_text(html)
    print(f"wrote {dst.relative_to(CAD.parent)}  ({dst.stat().st_size/1024:.0f} KB"
          f"{', three.js from CDN' if cdn else ', fully self-contained'})")
    return dst


# The four views in render/, and the true vertical section. Rendered from the
# same assembly.scad the viewer uses, so they cannot show a different part.
STILLS = [
    ("assembly.png",        "1000,1500", "66", "205", "EXPLODE=0"),
    ("assembly_detail.png", "1200,1000", "62", "205", "EXPLODE=0;BOTTLE=0"),
    ("exploded.png",        "1000,1600", "68", "205", "EXPLODE=1"),
    ("section.png",         "1100,1100", "80", "16",  "SECTION=1;BOTTLE=0"),
]


def stills() -> None:
    out = CAD / "render"; out.mkdir(exist_ok=True)
    for name, size, elev, azim, defs in STILLS:
        print(f"  rendering {name} ...", flush=True)
        subprocess.run(["openscad", "-o", str(out / name), "--imgsize", size,
                        "--viewall", "--autocenter",
                        "--camera", f"0,0,0,{elev},0,{azim},0",
                        "--colorscheme", "Tomorrow", "-D", defs,
                        str(CAD / "assembly.scad")], capture_output=True)
    print("  rendering section.svg ...", flush=True)
    subprocess.run(["openscad", "-o", str(out / "section.svg"),
                    str(CAD / "section2d.scad")], capture_output=True)
    print(f"wrote {len(STILLS) + 1} images to {out.relative_to(CAD.parent)}")


def deploy() -> None:
    """Ship the page. Vercel builds cad/viewer/ straight from GitHub on every
    push to main, so shipping is committing the freshly built index.html and
    pushing it. Building first is the point: deploying a stale index.html is
    the easy mistake, and this makes it impossible."""
    root = CAD.parent
    rel  = OUT.relative_to(root)
    git  = lambda *a, **k: subprocess.run(["git", *a], cwd=root, **k)

    dirty = git("status", "--porcelain", "--", str(OUT),
                capture_output=True, text=True).stdout.strip()
    if dirty:
        sys.exit(f"{rel}/index.html was just rebuilt and does not match HEAD.\n"
                 f"The deployment is whatever is committed, so commit it first:\n"
                 f"    git add {rel}/index.html\n"
                 f"    git commit -m 'Rebuild the viewer'\n"
                 f"then re-run --deploy.")

    if git("push").returncode != 0:
        sys.exit("git push failed - Vercel deploys what is on the remote, "
                 "so nothing shipped.")
    print(f"\n  pushed. Vercel is building {rel}/ - watch it with:\n"
          f"    vercel inspect --wait snail-terrarium-mister.vercel.app\n"
          f"  https://snail-terrarium-mister.vercel.app\n")


def serve(port: int) -> None:
    os.chdir(OUT)
    socketserver.TCPServer.allow_reuse_address = True
    with socketserver.TCPServer(("127.0.0.1", port),
                                http.server.SimpleHTTPRequestHandler) as srv:
        print(f"\n  http://127.0.0.1:{port}/    (Ctrl-C to stop)\n")
        try:
            srv.serve_forever()
        except KeyboardInterrupt:
            print("stopped")


if __name__ == "__main__":
    ap = argparse.ArgumentParser(description=__doc__.split("\n")[0])
    ap.add_argument("--build", action="store_true", help="build and stop")
    ap.add_argument("--cdn", action="store_true", help="do not inline three.js")
    ap.add_argument("--force", action="store_true", help="re-export all meshes")
    ap.add_argument("--deploy", action="store_true",
                    help="build, then push; Vercel deploys the push")
    ap.add_argument("--stills", action="store_true",
                    help="re-render the still images in render/ and stop")
    ap.add_argument("--port", type=int, default=8017)
    a = ap.parse_args()

    if a.stills:
        stills()
        raise SystemExit(0)

    export(a.force)
    dst = build(a.cdn)
    if a.deploy:
        deploy()
    elif a.build:
        print(f"open it directly: file://{dst}")
    else:
        serve(a.port)
