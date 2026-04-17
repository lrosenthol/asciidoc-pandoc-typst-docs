#set page(
  paper: "us-letter"
)

#show raw: set text(font: "Source Code Pro")
#show raw.where(block: true): set text(size: 0.92em)

#show heading.where(level: 1): set text(fill: rgb("#0f2d52"))
#show heading.where(level: 1): set block(above: 1.5em, below: 1em)
#show heading.where(level: 2): set text(fill: rgb("#163d6b"))
#show heading.where(level: 2): set block(above: 1.2em, below: 1em)

#show figure.where(kind: table): set figure.caption(position: bottom)
#show figure.where(kind: table): set block(below: 1.1em)
#show figure.where(kind: image): set block(below: 1.1em)
#show figure.where(kind: "example"): set figure.caption(position: bottom)
#show figure.where(kind: "example"): set block(below: 1.1em)
#show table.header: set align(center)
#show table.header: set text(weight: "semibold")

#set table(align: start)

#let imagefigure(path, alt, caption) = {
  figure(
    image(path, width: 100%, alt: alt),
    caption: caption,
  )
}

#let exampleblock(caption, body) = {
  figure(
    grid(
      columns: (1fr, 92%, 1fr),
      [],
      block(
        width: 100%,
        inset: 10pt,
        stroke: 1pt + luma(195),
        radius: 4pt,
        fill: luma(250),
        breakable: true,
      )[
        #align(start)[#body]
      ],
      [],
    ),
    kind: "example",
    supplement: [Example],
    caption: caption,
  )
}

#let codeexample(caption, body) = {
  figure(
    grid(
      columns: (1fr, 92%, 1fr),
      [],
      block(
        width: 100%,
        inset: 10pt,
        stroke: 1pt + luma(195),
        radius: 4pt,
        fill: luma(250),
        breakable: true,
      )[
        #align(start)[#body]
      ],
      [],
    ),
    kind: "example",
    supplement: [Example],
    caption: caption,
  )
}

#let admonition(kind, title, body) = {
  let palette = (
    note: (
      accent: rgb("#1d4ed8"),
      label: "NOTE",
      default-title: "Note",
    ),
    tip: (
      accent: rgb("#047857"),
      label: "TIP",
      default-title: "Tip",
    ),
    important: (
      accent: rgb("#5b21b6"),
      label: "IMPORTANT",
      default-title: "Important",
    ),
    caution: (
      accent: rgb("#b45309"),
      label: "CAUTION",
      default-title: "Caution",
    ),
    warning: (
      accent: rgb("#b91c1c"),
      label: "WARNING",
      default-title: "Warning",
    ),
  )

  let style = palette.at(kind)

  block(
    inset: (left: 12pt, right: 0pt, top: 3pt, bottom: 3pt),
    above: 1em,
    below: 1em,
    stroke: (
      left: 4pt + style.accent,
    ),
    breakable: true,
  )[
    #text(size: 0.78em, weight: "bold", tracking: 0.08em, fill: style.accent)[#style.label]
    #if title != style.default-title {
      parbreak()
      text(weight: "semibold")[#title]
      v(0.35em)
    } else {
      v(0.3em)
    }
    #block(inset: (left: 0.2em, right: 0pt, top: 0pt, bottom: 0pt))[#body]
  ]
}
