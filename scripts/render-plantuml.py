#!/usr/bin/env python3
"""Pre-render PlantUML diagrams from AsciiDoc files to SVG using Docker."""

import hashlib
import os
import re
import subprocess
import sys

DOCKER_IMAGE = "plantuml/plantuml"

# Matches [plantuml...] blocks delimited by ....
# Captures content including the trailing newline before the closing ....
# This mirrors what pandoc puts in el.text (which includes a trailing \n).
BLOCK_PATTERN = re.compile(
    r'\[plantuml[^\]]*\]\n\.{4}\n(.*?\n)\.{4}',
    re.DOTALL,
)


def find_plantuml_blocks(filepath):
    with open(filepath, encoding="utf-8") as f:
        content = f.read()
    return BLOCK_PATTERN.findall(content)


def content_hash(text):
    """SHA1 hash matching pandoc.utils.sha1 (UTF-8 bytes, hex output)."""
    return hashlib.sha1(text.encode("utf-8")).hexdigest()[:12]


def render_block(content, output_path):
    cmd = ["docker", "run", "--rm", "-i", DOCKER_IMAGE, "-tsvg", "-pipe"]
    result = subprocess.run(cmd, input=content.encode("utf-8"), capture_output=True)
    if result.returncode != 0:
        msg = result.stderr.decode("utf-8", errors="replace")
        print(f"  ERROR: {msg}", file=sys.stderr)
        return False
    with open(output_path, "wb") as f:
        f.write(result.stdout)
    return True


def main():
    if len(sys.argv) < 3:
        print(f"Usage: {sys.argv[0]} <docs_dir> <output_dir>", file=sys.stderr)
        sys.exit(1)

    docs_dir, output_dir = sys.argv[1], sys.argv[2]
    os.makedirs(output_dir, exist_ok=True)

    rendered = skipped = errors = 0
    for root, _, files in os.walk(docs_dir):
        for name in sorted(files):
            if not name.endswith(".adoc"):
                continue
            path = os.path.join(root, name)
            for block in find_plantuml_blocks(path):
                h = content_hash(block)
                out = os.path.join(output_dir, f"plantuml-{h}.svg")
                if os.path.exists(out):
                    skipped += 1
                    continue
                print(f"Rendering: {path} → plantuml-{h}.svg")
                if render_block(block, out):
                    rendered += 1
                else:
                    errors += 1

    print(f"PlantUML: {rendered} rendered, {skipped} cached, {errors} errors")
    if errors:
        sys.exit(1)


if __name__ == "__main__":
    main()
