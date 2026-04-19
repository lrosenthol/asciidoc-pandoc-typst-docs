#set page(
  paper: "us-letter",
    margin: (left: 25mm, right: 25mm, top: 25mm, bottom: 30mm),
    numbering: "1",
    number-align: right,
)

#show raw: set text(font: "Source Code Pro")
#show raw.where(block: true): set text(size: 0.92em)

#set heading(numbering: "1.1")
#show heading.where(level: 1): set text(fill: rgb("#0f2d52"))
#show heading.where(level: 1): set block(above: 2em, below: 1em)
#show heading.where(level: 2): set text(fill: rgb("#163d6b"))
#show heading.where(level: 2): set block(above: 1.5em, below: 1em)

#show figure.where(kind: table): set figure.caption(position: bottom)
#show figure.where(kind: table): set block(below: 1.5em)
#show figure.where(kind: image): set block(below: 1.5em)
#show figure.where(kind: "example"): set figure.caption(position: bottom)
#show figure.where(kind: "example"): set block(below: 1.5em)

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

// Macro definitions (imagefigure, exampleblock, codeexample, admonition)
// are injected separately via macros.typ so they can be shared with other templates.
