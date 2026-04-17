DOC ?=
MANUSCRIPT_DIR := manuscript
BUILD_DIR := build
DOCKER_IMAGE ?= pandoc/typst:3.9-ubuntu
CONTAINER_WORKDIR := /work
UID := $(shell id -u)
GID := $(shell id -g)
HOST_WORKDIR ?= $(subst /Library/CloudStorage/OneDrive-Adobe/Documents,/Documents,$(CURDIR))
FONT_DIR := assets/fonts
SOURCE_SANS_DIR := $(FONT_DIR)/source-sans-3
SOURCE_CODE_DIR := $(FONT_DIR)/source-code-pro
PANDOC_METADATA := styles/pandoc/document.yaml

DOCKER_RUN = docker run --rm \
	-u $(UID):$(GID) \
	-v "$(HOST_WORKDIR):$(CONTAINER_WORKDIR)" \
	-w $(CONTAINER_WORKDIR) \
	$(DOCKER_IMAGE)
TYPST_RUN = docker run --rm \
	--entrypoint typst \
	-u $(UID):$(GID) \
	-v "$(HOST_WORKDIR):$(CONTAINER_WORKDIR)" \
	-w $(CONTAINER_WORKDIR) \
	$(DOCKER_IMAGE)

PANDOC = $(DOCKER_RUN)
ALL_DOCS := $(patsubst $(MANUSCRIPT_DIR)/%.adoc,%,$(wildcard $(MANUSCRIPT_DIR)/*.adoc))
TARGET_DOCS := $(if $(strip $(DOC)),$(DOC),$(ALL_DOCS))
TYPST_TARGETS := $(addprefix $(BUILD_DIR)/,$(addsuffix .typ,$(TARGET_DOCS)))
PDF_TARGETS := $(addprefix $(BUILD_DIR)/,$(addsuffix .pdf,$(TARGET_DOCS)))
NATIVE_TARGETS := $(addprefix $(BUILD_DIR)/,$(addsuffix .native,$(TARGET_DOCS)))
PDF_STANDARD ?=
PDF_TAGS ?= on
COMMON_PANDOC_FLAGS = \
	--from=asciidoc \
	--standalone \
	--metadata-file=$(PANDOC_METADATA) \
	--resource-path=.:$(MANUSCRIPT_DIR):$(MANUSCRIPT_DIR)/sections:assets \
	--lua-filter=styles/filters/asciidoc-to-typst.lua \
	--include-in-header=styles/typst/document.typ \
	--pdf-engine-opt=--font-path=$(SOURCE_SANS_DIR) \
	--pdf-engine-opt=--font-path=$(SOURCE_CODE_DIR) \
	--pdf-engine-opt=--ignore-system-fonts

ifneq ($(strip $(PDF_STANDARD)),)
COMMON_PANDOC_FLAGS += --pdf-engine-opt=--pdf-standard=$(PDF_STANDARD)
endif

ifeq ($(PDF_TAGS),off)
COMMON_PANDOC_FLAGS += --pdf-engine-opt=--no-pdf-tags
endif

.PHONY: all help pdf typst native fonts clean FORCE

all: pdf

help:
	@printf '%s\n' \
		'make typst                    Build Typst source for all manuscript entrypoints' \
		'make pdf                      Build PDFs for all manuscript entrypoints' \
		'make native                   Inspect Pandoc AST for all manuscript entrypoints' \
		'make fonts              Show fonts discovered by Typst in the container' \
		'make DOC=white-paper pdf      Build a single manuscript entrypoint' \
		'make DOC=numbered-report pdf  Build a single manuscript entrypoint' \
		'make PDF_STANDARD=ua-1 pdf    Build a PDF/UA-1 file' \
		'make PDF_STANDARD=a-2u pdf    Build a PDF/A-2u file' \
		'make PDF_TAGS=off pdf         Disable Tagged PDF output' \
		'make clean              Remove generated files'

$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

typst: $(TYPST_TARGETS)

$(BUILD_DIR)/%.typ: FORCE $(MANUSCRIPT_DIR)/%.adoc $(PANDOC_METADATA) styles/filters/asciidoc-to-typst.lua styles/typst/document.typ | $(BUILD_DIR)
	$(PANDOC) $(COMMON_PANDOC_FLAGS) --to=typst $(MANUSCRIPT_DIR)/$*.adoc -o $@

pdf: $(PDF_TARGETS)

$(BUILD_DIR)/%.pdf: FORCE $(MANUSCRIPT_DIR)/%.adoc $(PANDOC_METADATA) styles/filters/asciidoc-to-typst.lua styles/typst/document.typ | $(BUILD_DIR)
	$(PANDOC) $(COMMON_PANDOC_FLAGS) --pdf-engine=typst $(MANUSCRIPT_DIR)/$*.adoc -o $@

native: $(NATIVE_TARGETS)

$(BUILD_DIR)/%.native: FORCE $(MANUSCRIPT_DIR)/%.adoc | $(BUILD_DIR)
	$(PANDOC) --from=asciidoc --to=native $(MANUSCRIPT_DIR)/$*.adoc -o $@

fonts:
	$(TYPST_RUN) fonts --font-path $(SOURCE_SANS_DIR) --font-path $(SOURCE_CODE_DIR) --ignore-system-fonts

clean:
	rm -f $(BUILD_DIR)/*.typ $(BUILD_DIR)/*.pdf $(BUILD_DIR)/*.native

FORCE:
