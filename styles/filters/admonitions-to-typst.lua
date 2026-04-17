local labels = {
  note = "Note",
  tip = "Tip",
  important = "Important",
  caution = "Caution",
  warning = "Warning",
}

local function has_class(classes, wanted)
  for _, class in ipairs(classes) do
    if class == wanted then
      return true
    end
  end
  return false
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
