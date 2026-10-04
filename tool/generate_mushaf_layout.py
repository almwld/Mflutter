#!/usr/bin/env python3
"""Generate the fixed 15-line Madinah/QCF page layout used by experimental modes."""

from __future__ import annotations

import json
import pathlib
import tempfile
import urllib.request
import zipfile

ROOT = pathlib.Path(__file__).resolve().parents[1]
OUT = ROOT / "assets" / "mushaf_layout.json"
ARCHIVE = "https://github.com/manaf/KFGQPC-Madinah-Mushaf/archive/refs/heads/main.zip"


def main() -> None:
    pages = {}

    with tempfile.TemporaryDirectory() as tmp:
        archive = pathlib.Path(tmp) / "mushaf.zip"
        urllib.request.urlretrieve(ARCHIVE, archive)

        with zipfile.ZipFile(archive) as zf:
            prefix = "KFGQPC-Madinah-Mushaf-main/data/pages"
            for page in range(1, 605):
                member = f"{prefix}/page-{page:03d}.json"
                with zf.open(member) as stream:
                    data = json.load(stream)

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
