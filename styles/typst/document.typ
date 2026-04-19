#set page(
  paper: "us-letter",
    margin: (left: 25mm, right: 25mm, top: 25mm, bottom: 30mm),
    numbering: "1",
    number-align: right,
)

// Paragraph
#set par(
  leading: 0.75em,
  justify: true,
)

#set text(font: "Source Serif 4", size: 11pt)
#show heading: set text(font: "Source Sans 3")
#show raw: set text(font: "Source Code Pro", size: 10pt)
#show raw.where(block: true): set text(size: 0.92em)

#set heading(numbering: "1.1")
#show heading.where(level: 1): it => {
  v(2em, weak: false)
  block(above: 0pt, below: 0.5em, breakable: false)[
    #set text(size: 22pt, weight: "black", fill: rgb("#0f2d52"))
    #it
  ]
}
#show heading.where(level: 2): it => {
  v(1.5em, weak: false)
  block(above: 0pt, below: 0.5em, breakable: false)[
    #set text(size: 15pt, weight: "bold", fill: rgb("#163d6b"))
    #it
  ]
}
#show heading.where(level: 3): it => {
  v(1.5em, weak: false)
  block(above: 0pt, below: 0.5em, breakable: false)[
    #set text(size: 13pt, weight: "bold", fill: rgb("#163d6b"))
    #it
  ]
}

#show figure.where(kind: table): it => {
  set figure.caption(position: bottom)
  block(above: 2em, below: 1.5em)[#it]
}
#show figure.where(kind: image): it => {
  block(above: 2em, below: 1.5em)[#it]
}
#show figure.where(kind: "example"): it => {
  set figure.caption(position: bottom)
  block(above: 2em, below: 1.5em)[#it]
}

#let frame(stroke) = (x, y) => (
  left: if x > 0 { 0pt } else { stroke },
  right: stroke,
  top: stroke,
  bottom: stroke,
)
#set table(
  fill: (none),
  stroke: frame(1pt + rgb("21222C")),
)

#show table.cell: set align(start)
#show table.cell.where(y: 0): set align(center)
#show table.cell.where(y: 0): set text(weight: "semibold")

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
