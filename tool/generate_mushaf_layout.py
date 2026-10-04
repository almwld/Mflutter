#!/usr/bin/env python3
"""Generate the fixed 15-line Madinah/QCF page layout used by experimental modes.

The source repository contains the per-page QCF layout metadata.  We keep only
the stable word locations/types in the app asset; the Quran text itself stays
in qcf_quran_lite.
"""
from __future__ import annotations

import json
import pathlib
import urllib.request

ROOT = pathlib.Path(__file__).resolve().parents[1]
OUT = ROOT / "assets" / "mushaf_layout.json"
BASE = "https://raw.githubusercontent.com/manaf/KFGQPC-Madinah-Mushaf/main/data/pages/page-{page:03d}.json"


def fetch(page: int) -> dict:
    with urllib.request.urlopen(BASE.format(page=page), timeout=30) as response:
        return json.load(response)


def main() -> None:
    pages = {}
    for page in range(1, 605):
        data = fetch(page)
        compact_lines = []
        for line in data.get("lines", []):
            compact_lines.append({
                "type": line.get("type", "text"),
                "centered": bool(line.get("centered", False)),
                "words": [
                    {
                        "location": word["location"],
                        "kind": word.get("kind", "word"),
                    }
                    for word in line.get("words", [])
                    if "location" in word
                ],
                "surah": (line.get("decor") or {}).get("surah"),
            })
        pages[str(page)] = compact_lines

    OUT.parent.mkdir(parents=True, exist_ok=True)
    OUT.write_text(
        json.dumps(
            {"version": 1, "mushaf": "KFGQPC/QCF V2 Hafs", "pages": pages},
            ensure_ascii=False,
            separators=(",", ":"),
        ),
        encoding="utf-8",
    )
    print(f"generated {OUT} ({OUT.stat().st_size} bytes)")


if __name__ == "__main__":
    main()
