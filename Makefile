DOC ?=
DOCS_DIR := docs
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
DOC_ASSET_DIR ?= assets
DOC_IMAGES_DIR ?= $(DOC_ASSET_DIR)/images

TEMPLATE ?=
TYPST_MACROS := styles/typst/macros.typ
ifeq ($(TEMPLATE),adobe)
  TYPST_LAYOUT := styles/typst/adobe-whitepaper.typ
  TEMPLATE_SUFFIX := _adobe
else
  TYPST_LAYOUT := styles/typst/document.typ
  TEMPLATE_SUFFIX :=
endif
TYPST_HEADERS := $(TYPST_MACROS) $(TYPST_LAYOUT)

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
ALL_DOCS := $(sort $(basename $(notdir $(wildcard $(DOCS_DIR)/*/*.adoc))))
TARGET_DOCS := $(if $(strip $(DOC)),$(DOC),$(ALL_DOCS))
TYPST_TARGETS := $(addprefix $(BUILD_DIR)/,$(addsuffix $(TEMPLATE_SUFFIX).typ,$(TARGET_DOCS)))
PDF_TARGETS  := $(addprefix $(BUILD_DIR)/,$(addsuffix $(TEMPLATE_SUFFIX).pdf,$(TARGET_DOCS)))
NATIVE_TARGETS := $(addprefix $(BUILD_DIR)/,$(addsuffix .native,$(TARGET_DOCS)))
PDF_STANDARD ?=
PDF_TAGS ?= on
COMMON_PANDOC_FLAGS = \
	--from=asciidoc \
	--standalone \
	--metadata-file=$(PANDOC_METADATA) \
	--lua-filter=styles/filters/asciidoc-to-typst.lua \
	--include-in-header=$(TYPST_MACROS) \
	--include-in-header=$(TYPST_LAYOUT) \
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
		'make typst                               Build Typst source for all document entrypoints' \
		'make pdf                                 Build PDFs for all document entrypoints' \
		'make native                              Inspect Pandoc AST for all document entrypoints' \
		'make fonts                               Show fonts discovered by Typst in the container' \
		'make DOC=white-paper pdf                 Build a single document entrypoint' \
		'make DOC=numbered-report pdf             Build a single document entrypoint' \
		'make TEMPLATE=adobe pdf                  Build using Adobe-branded template (output gets _adobe suffix)' \
		'make TEMPLATE=adobe DOC=white-paper pdf  Build single doc with Adobe template' \
		'make PDF_STANDARD=ua-1 pdf               Build a PDF/UA-1 file' \
		'make PDF_STANDARD=a-2u pdf               Build a PDF/A-2u file' \
		'make PDF_TAGS=off pdf                    Disable Tagged PDF output' \
		'make clean                               Remove generated files'

$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

# --- Per-document rules generated via foreach so TEMPLATE_SUFFIX can be embedded
#     in the target filename while still resolving the source path from the doc name.

define TYPST_RULE
$(BUILD_DIR)/$(1)$(TEMPLATE_SUFFIX).typ: FORCE $(PANDOC_METADATA) styles/filters/asciidoc-to-typst.lua $(TYPST_HEADERS) | $(BUILD_DIR)
	$(PANDOC) $(COMMON_PANDOC_FLAGS) \
		--resource-path=.:$(DOCS_DIR)/$(1):$(DOCS_DIR)/$(1)/sections:$(DOCS_DIR)/$(1)/assets:$(DOCS_DIR)/$(1)/assets/images \
		--metadata=docdir:$(DOCS_DIR)/$(1) \
		--metadata=imagesdir:$(DOC_IMAGES_DIR) \
		--metadata=resolvedimagesdir:$(DOCS_DIR)/$(1)/$(DOC_IMAGES_DIR) \
		--to=typst $(DOCS_DIR)/$(1)/$(1).adoc -o $$@
endef

define PDF_RULE
$(BUILD_DIR)/$(1)$(TEMPLATE_SUFFIX).pdf: FORCE $(PANDOC_METADATA) styles/filters/asciidoc-to-typst.lua $(TYPST_HEADERS) | $(BUILD_DIR)
	$(PANDOC) $(COMMON_PANDOC_FLAGS) \
		--resource-path=.:$(DOCS_DIR)/$(1):$(DOCS_DIR)/$(1)/sections:$(DOCS_DIR)/$(1)/assets:$(DOCS_DIR)/$(1)/assets/images \
		--metadata=docdir:$(DOCS_DIR)/$(1) \
		--metadata=imagesdir:$(DOC_IMAGES_DIR) \
		--metadata=resolvedimagesdir:$(DOCS_DIR)/$(1)/$(DOC_IMAGES_DIR) \
		--pdf-engine=typst $(DOCS_DIR)/$(1)/$(1).adoc -o $$@
endef

define NATIVE_RULE
$(BUILD_DIR)/$(1).native: FORCE | $(BUILD_DIR)
	$(PANDOC) --from=asciidoc --to=native $(DOCS_DIR)/$(1)/$(1).adoc -o $$@
endef

$(foreach doc,$(TARGET_DOCS),$(eval $(call TYPST_RULE,$(doc))))
$(foreach doc,$(TARGET_DOCS),$(eval $(call PDF_RULE,$(doc))))
$(foreach doc,$(TARGET_DOCS),$(eval $(call NATIVE_RULE,$(doc))))

typst: $(TYPST_TARGETS)
pdf: $(PDF_TARGETS)
native: $(NATIVE_TARGETS)

fonts:
	$(TYPST_RUN) fonts --font-path $(SOURCE_SANS_DIR) --font-path $(SOURCE_CODE_DIR) --ignore-system-fonts

clean:
	rm -f $(BUILD_DIR)/*.typ $(BUILD_DIR)/*.pdf $(BUILD_DIR)/*.native

FORCE:
