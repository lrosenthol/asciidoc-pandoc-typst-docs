# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Project Does

A document generation pipeline that converts AsciiDoc source files to polished PDFs via Pandoc → Typst. Designed for long-form technical documents (white papers, validation reports). All processing runs inside Docker for reproducibility.

## Build Commands

```bash
make pdf                     # Build PDFs for all documents
make typst                   # Build Typst source (intermediate) for all documents
make native                  # Dump Pandoc AST (useful for filter debugging)
make fonts                   # Verify Typst can find bundled fonts
make clean                   # Remove build/ directory

# Single document:
make DOC=white-paper pdf
make DOC=numbered-report pdf

# PDF conformance variants:
make PDF_STANDARD=ua-1 pdf   # PDF/UA-1 accessibility
make PDF_STANDARD=a-2u pdf   # PDF/A-2u archival
make PDF_TAGS=off pdf        # Disable Tagged PDF
```

**Prerequisite:** Docker must be running. The Makefile uses `pandoc/typst:3.9-ubuntu`.

## Pipeline Architecture

```
AsciiDoc source (.adoc)
    → Pandoc (parses AsciiDoc, applies Lua filter)
        → styles/filters/asciidoc-to-typst.lua  (structural normalization)
    → Typst source (.typ)
        → styles/typst/document.typ             (default styling + macros)
        → styles/typst/adobe-whitepaper.typ     (Adobe-branded template, optional)
    → PDF
```

Pandoc metadata (fonts, margins, language) comes from `styles/pandoc/document.yaml`.

## Lua Filter (`styles/filters/asciidoc-to-typst.lua`)

This is the core transformation layer. It converts Pandoc AST elements into Typst macro calls:

| AsciiDoc construct | Emitted Typst macro |
|---|---|
| Admonition divs (NOTE, TIP, etc.) | `#admonition(kind, title, body)` |
| Figures with captions | `#imagefigure(path, alt, caption)` |
| Code blocks | `#codeexample(caption, body)` — caption derived from language tag |
| Example blocks | `#exampleblock(caption, body)` |
| `:sectnums:` / `:sectnumlevels:` | Heading numbering rules injected into preamble |

When debugging unexpected PDF output, use `make native` to inspect the Pandoc AST before the filter runs, then `make typst` to see the Typst source after the filter.

## Document Structure

Each document lives under `docs/<name>/`:
- `<name>.adoc` — entry point, sets document attributes (`:sectionsdir:`, `:imagesdir:`, `:assetdir:`)
- `sections/*.adoc` — included content fragments
- `assets/images/` — document-local figures (SVG preferred)

Shared assets (fonts, logos) are in `assets/` at the repo root.

## Typst Templates

- `styles/typst/document.typ` — active default: page setup, heading colors, table styling, macro definitions
- `styles/typst/adobe-whitepaper.typ` — Adobe-branded variant with title page, header/footer, Adobe Clean font; not wired into the Makefile by default

To switch templates, edit the `--template` argument in the Makefile's PDF/Typst targets.

## Adding a New Document

1. Create `docs/<name>/<name>.adoc` and `docs/<name>/sections/`
2. The Makefile auto-discovers documents via `$(wildcard docs/*/*.adoc)` — no Makefile edits needed
3. Build with `make DOC=<name> pdf`
