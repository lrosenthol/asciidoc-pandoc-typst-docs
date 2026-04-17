local labels = {
  note = "Note",
  tip = "Tip",
  important = "Important",
  caution = "Caution",
  warning = "Warning",
}

local section_numbering_block = nil
local document_dir = nil
local images_dir = nil
local resolved_images_dir = nil

local function has_class(classes, wanted)
  for _, class in ipairs(classes) do
    if class == wanted then
      return true
    end
  end
  return false
end

local function meta_enabled(value)
  if not value then
    return false
  end

  if type(value) == "boolean" then
    return value
  end

  if value.t == "MetaBool" then
    return value[1]
  end

  local text = pandoc.utils.stringify(value):lower()
  return text ~= "" and text ~= "false" and text ~= "0" and text ~= "no"
end

local function section_pattern(level)
  local parts = {}
  for _ = 1, level do
    table.insert(parts, "1")
  end
  return table.concat(parts, ".") .. "."
end

local function render_blocks(blocks)
  if not blocks or #blocks == 0 then
    return ""
  end

  return pandoc.write(pandoc.Pandoc(blocks), "typst"):gsub("%s+$", "")
end

local function caption_blocks(caption)
  if not caption then
    return {}
  end

  if caption.long then
    return caption.long
  end

  return caption
end

local function block_identifier(el)
  if el.identifier and el.identifier ~= "" then
    return el.identifier
  end

  if el.attr and el.attr.identifier and el.attr.identifier ~= "" then
    return el.attr.identifier
  end

  return nil
end

local function title_case(value)
  if not value or value == "" then
    return nil
  end

  local parts = {}
  for part in string.gmatch(value, "[^%-%_]+") do
    local lower = string.lower(part)
    table.insert(parts, string.upper(string.sub(lower, 1, 1)) .. string.sub(lower, 2))
  end

  return table.concat(parts, " ")
end

local function codeexample_block(caption, el, identifier)
  local caption_markup = caption and string.format("[%s]", caption) or "none"
  local rendered = render_blocks({ el })
  local blocks = pandoc.List({
    pandoc.RawBlock("typst", string.format("#codeexample(%s)[", caption_markup)),
    pandoc.RawBlock("typst", rendered),
  })

  local closing = "]"
  if identifier then
    closing = closing .. string.format(" <%s>", identifier)
  end
  blocks:insert(pandoc.RawBlock("typst", closing))

  return blocks
end

local function configure_from_meta(meta)
  document_dir = meta.docdir and pandoc.utils.stringify(meta.docdir) or ""
  images_dir = meta.imagesdir and pandoc.utils.stringify(meta.imagesdir) or ""
  resolved_images_dir = meta.resolvedimagesdir and pandoc.utils.stringify(meta.resolvedimagesdir) or ""

  if not meta_enabled(meta.sectnums) then
    section_numbering_block = nil
    return
  end

  local depth = tonumber(pandoc.utils.stringify(meta.sectnumlevels or "3")) or 3
  local lines = {}

  for level = 1, depth do
    table.insert(
      lines,
      string.format('#show heading.where(level: %d): set heading(numbering: "%s")', level, section_pattern(level))
    )
  end

  section_numbering_block = pandoc.RawBlock("typst", table.concat(lines, "\n"))
end

local function transform_figure(el)
  if #el.content ~= 1 then
    return nil
  end

  local first = el.content[1]
  if first.t ~= "Plain" and first.t ~= "Para" then
    return nil
  end

  if #first.content ~= 1 or first.content[1].t ~= "Image" then
    return nil
  end

  local image = first.content[1]
  local src = image.src
  local current_images_dir = images_dir or ""
  local current_document_dir = document_dir or ""
  local current_resolved_images_dir = resolved_images_dir or ""
  local used_resolved_images_dir = false
  if current_resolved_images_dir ~= "" and not string.match(src, "^/") and not string.match(src, "^[A-Za-z]+://") and not string.find(src, "/") then
    src = current_resolved_images_dir .. "/" .. src
    used_resolved_images_dir = true
  elseif current_images_dir ~= "" and not string.match(src, "^/") and not string.match(src, "^[A-Za-z]+://") and not string.find(src, "/") then
    src = current_images_dir .. "/" .. src
  end
  if not used_resolved_images_dir and current_document_dir ~= "" and not string.match(src, "^/") and not string.match(src, "^[A-Za-z]+://") then
    src = current_document_dir .. "/" .. src
  end
  local alt = pandoc.utils.stringify(image.caption or {})
  local caption = render_blocks(caption_blocks(el.caption))
  local raw = string.format('#imagefigure(%q, %q', src, alt)

  if caption ~= "" then
    raw = raw .. string.format(', [%s]', caption)
  else
    raw = raw .. ", none"
  end

  raw = raw .. ")"

  local identifier = block_identifier(el)
  if identifier then
    raw = raw .. string.format(" <%s>", identifier)
  end

  return pandoc.RawBlock("typst", raw)
end

local function transform_div(el)
  if #el.content == 2 then
    local first = el.content[1]
    local second = el.content[2]

    if first.t == "Div" and has_class(first.classes, "title") and second.t == "CodeBlock" then
      return codeexample_block(pandoc.utils.stringify(first), second, block_identifier(el))
    end
  end

  local kind = nil

  for _, class in ipairs(el.classes) do
    local normalized = string.lower(class)
    if labels[normalized] then
      kind = normalized
      break
    end
  end

  if not kind then
    if has_class(el.classes, "example") then
      local title = nil
      local content = el.content

      if #content > 0 then
        local first = content[1]
        if first.t == "Div" and has_class(first.classes, "title") then
          title = pandoc.utils.stringify(first)
          table.remove(content, 1)
        end
      end

      local blocks = pandoc.List({
        pandoc.RawBlock(
          "typst",
          string.format("#exampleblock(%s)[", title and string.format("[%s]", title) or "none")
        ),
      })

      for _, block in ipairs(content) do
        blocks:insert(block)
      end

      local closing = "]"
      local identifier = block_identifier(el)
      if identifier then
        closing = closing .. string.format(" <%s>", identifier)
      end
      blocks:insert(pandoc.RawBlock("typst", closing))

      return blocks
    end

    return nil
  end

  local title = labels[kind]
  local content = el.content

  if #content > 0 then
    local first = content[1]
    if first.t == "Div" and has_class(first.classes, "title") then
      title = pandoc.utils.stringify(first)
      table.remove(content, 1)
    end
  end

  return pandoc.List({
    pandoc.RawBlock("typst", string.format("#admonition(%q, %q)[", kind, title)),
    table.unpack(content),
    pandoc.RawBlock("typst", "]"),
  })
end

local function transform_codeblock(el)
  local language = el.classes and el.classes[1] or nil
  local caption = title_case(language)

  if caption then
    caption = caption .. " Example"
  else
    caption = "Code Example"
  end

  return codeexample_block(caption, el, block_identifier(el))
end

function Pandoc(doc)
  configure_from_meta(doc.meta)

  if section_numbering_block then
    doc.blocks:insert(1, section_numbering_block)
  end

  doc = doc:walk({
    Figure = transform_figure,
    Div = transform_div,
  })

  return doc:walk({
    CodeBlock = transform_codeblock,
  })
end
