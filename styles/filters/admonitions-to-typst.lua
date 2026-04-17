local labels = {
  note = "Note",
  tip = "Tip",
  important = "Important",
  caution = "Caution",
  warning = "Warning",
}

local section_numbering_block = nil

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

function Meta(meta)
  if not meta_enabled(meta.sectnums) then
    section_numbering_block = nil
    return meta
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
  return meta
end

function Pandoc(doc)
  if section_numbering_block then
    doc.blocks:insert(1, section_numbering_block)
  end
  return doc
end

function Div(el)
  local kind = nil

  for _, class in ipairs(el.classes) do
    local normalized = string.lower(class)
    if labels[normalized] then
      kind = normalized
      break
    end
  end

  if not kind then
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
