#!/usr/bin/env python3
"""Mesh QA for printable parts: manifold, watertight, volume, bbox."""
import sys, glob, trimesh

ok = True
for f in sorted(glob.glob(sys.argv[1] if len(sys.argv) > 1 else 'cad/stl/*.stl')):
    m = trimesh.load(f)
    bb = m.bounding_box.extents
    good = m.is_watertight and m.is_winding_consistent and m.volume > 0
    ok &= good
    print(f"{'PASS' if good else 'FAIL'}  {f.split('/')[-1]:<22}"
          f"{bb[0]:6.1f} x {bb[1]:6.1f} x {bb[2]:6.1f} mm   "
          f"{m.volume/1000:7.1f} cm3  ~{m.volume/1000*1.27:6.0f} g PETG   "
          f"watertight={m.is_watertight} bodies={m.body_count}")
sys.exit(0 if ok else 1)
