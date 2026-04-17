# AsciiDoc Document Production

This project is structured for producing white papers, reports, and similar long-form documents from AsciiDoc through Pandoc to Typst PDF output. The entire toolchain runs in Docker via the official `pandoc/typst` image.

## Layout

- `manuscript/`: document entrypoints and section files
- `manuscript/sections/`: reusable included sections for long-form reports
- `styles/filters/`: Pandoc Lua filters
- `styles/typst/`: Typst presentation and document styling
- `assets/fonts/`: bundled Adobe font files used during Docker builds
- `assets/images/`: project-local image assets
- `build/`: generated Typst and PDF output

## Quick Start

```sh
make pdf
make typst
make fonts
```

The default build entrypoint is `manuscript/white-paper.adoc`. Override it with `DOC=...` if you add more documents.

## Targets

- `make pdf`: build `build/white-paper.pdf`
- `make typst`: build the intermediate Typst source
- `make native`: inspect Pandoc's AST for troubleshooting conversion behavior
- `make fonts`: confirm that Typst sees the bundled project fonts
- `make DOC=annual-report pdf`: build a different manuscript entrypoint
- `make clean`: remove generated files

## Typography

The build is configured to use:

- `Source Sans 3` for body content
- `Source Code Pro` for inline code and code blocks

Those font files are vendored into the repository so the Docker build does not rely on host-installed fonts.

## Admonitions

Pandoc preserves AsciiDoc admonitions semantically, but Typst does not style them automatically when emitted by Pandoc. The Lua filter in `styles/filters/admonitions-to-typst.lua` rewrites admonition blocks into Typst macro calls, and `styles/typst/document.typ` renders them as styled callouts.

## Notes

- The project currently pins `pandoc/typst:3.9-ubuntu`.
- If your documents live in a cloud-synced folder on macOS and Docker has trouble with the mounted path, override `HOST_WORKDIR` when running `make`.
- The current starter is a white-paper/report-oriented baseline. The next production upgrades would usually be bibliography handling, title-page variants, cover imagery, and brand-specific theme variables.
