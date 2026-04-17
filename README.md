# AsciiDoc Document Production

This project is structured for producing white papers, reports, and similar long-form documents from AsciiDoc through Pandoc to Typst PDF output. The entire toolchain runs in Docker via the official `pandoc/typst` image.

It currently includes:

- a white-paper style document entrypoint
- a numbered validation report with mixed heading levels
- bundled Source Sans 3 and Source Code Pro fonts
- custom handling for admonitions, image figures, examples, and section numbering
- optional PDF/UA-1 and PDF/A-2u output controls through `make`

## Layout

- `manuscript/`: document entrypoints and section files
- `manuscript/sections/`: reusable included sections for long-form reports
- `styles/filters/`: Pandoc Lua filters that normalize AsciiDoc structures for Typst
- `styles/typst/`: Typst presentation and document styling
- `assets/fonts/`: bundled Adobe font files used during Docker builds
- `assets/images/`: project-local image assets used by the sample documents
- `build/`: generated Typst and PDF output

## Quick Start

```sh
make pdf
make typst
make fonts
make DOC=numbered-report pdf
```

By default, `make pdf` and `make typst` build every top-level document entrypoint under `manuscript/*.adoc`. Use `DOC=...` to build just one.

Current sample entrypoints:

- `manuscript/white-paper.adoc`
- `manuscript/numbered-report.adoc`

## Targets

- `make pdf`: build PDFs for all manuscript entrypoints
- `make typst`: build Typst source for all manuscript entrypoints
- `make native`: inspect Pandoc's AST for all manuscript entrypoints
- `make fonts`: confirm that Typst sees the bundled project fonts
- `make DOC=numbered-report pdf`: build the numbered validation document
- `make DOC=white-paper pdf`: build only the white paper
- `make DOC=annual-report pdf`: build a different manuscript entrypoint
- `make PDF_STANDARD=ua-1 pdf`: request PDF/UA-1 output
- `make PDF_STANDARD=a-2u pdf`: request PDF/A-2u output
- `make PDF_TAGS=off pdf`: disable Tagged PDF output
- `make clean`: remove generated files

## Typography

The build is configured to use:

- `Source Sans 3` for body content
- `Source Code Pro` for inline code and code blocks

Those font files are vendored into the repository so the Docker build does not rely on host-installed fonts.

## What The Filter Does

The shared Lua filter in `styles/filters/asciidoc-to-typst.lua` is doing more than admonition handling now. It currently:

- rewrites AsciiDoc admonitions into Typst callout macros
- maps `:sectnums:` and `:sectnumlevels:` into Typst heading numbering rules
- rewrites simple image figures into explicit Typst figure calls
- preserves image alt text for accessibility-aware output
- rewrites AsciiDoc example blocks into a separate numbered `Example` figure kind

The matching visual presentation lives in `styles/typst/document.typ`.

## Figures And Examples

The project now includes sample SVG figures in `assets/images/` and exercises them in both documents.

- White paper figures are emitted as numbered image figures with captions and alt text.
- The numbered report includes multiple figures, multiple code blocks, and multiple numbered examples.
- Example blocks are counted separately from image figures.

## Section Numbering

The shared Lua filter also maps AsciiDoc section numbering attributes into Typst heading numbering rules. In practice, that means source attributes such as `:sectnums:` and `:sectnumlevels:` stay authoritative for numbered output documents.

See `manuscript/numbered-report.adoc` for a validation document with mixed heading levels and JSON code blocks.

## PDF Conformance

The build can pass Typst PDF conformance options through Docker by setting `PDF_STANDARD` in `make`.

- `PDF_STANDARD=ua-1` asks Typst to enforce PDF/UA-1 rules
- `PDF_STANDARD=a-2u` asks Typst to enforce PDF/A-2u rules
- `PDF_TAGS=off` disables Tagged PDF output

Typst currently does not let you target PDF/A and PDF/UA at the same time. Sources: [Typst PDF reference](https://typst.app/docs/reference/pdf/), [Typst accessibility guide](https://typst.app/docs/guides/accessibility/).

## Notes

- The project currently pins `pandoc/typst:3.9-ubuntu`.
- If your documents live in a cloud-synced folder on macOS and Docker has trouble with the mounted path, override `HOST_WORKDIR` when running `make`.
- The theme currently uses restrained admonitions, centered column headers, start-aligned body cells, and separate figure/example numbering.
- The next production upgrades would usually be bibliography handling, title-page variants, cover imagery, richer cross-references, and brand-specific theme variables.
