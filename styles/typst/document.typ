#show raw: set text(font: "Source Code Pro")
#show raw.where(block: true): set text(size: 0.92em)

#show heading.where(level: 1): set text(fill: rgb("#0f2d52"))
#show heading.where(level: 2): set text(fill: rgb("#163d6b"))

#show figure.where(kind: table): set block(below: 1.1em)
#show figure.where(kind: image): set block(below: 1.1em)

#let admonition(kind, title, body) = {
  let palette = (
    note: (
      accent: rgb("#1d4ed8"),
      border: rgb("#93c5fd"),
      fill: rgb("#eff6ff"),
    ),
    tip: (
      accent: rgb("#047857"),
      border: rgb("#6ee7b7"),
      fill: rgb("#ecfdf5"),
    ),
    important: (
      accent: rgb("#7c3aed"),
      border: rgb("#c4b5fd"),
      fill: rgb("#f5f3ff"),
    ),
    caution: (
      accent: rgb("#b45309"),
      border: rgb("#fcd34d"),
      fill: rgb("#fffbeb"),
    ),
    warning: (
      accent: rgb("#b91c1c"),
      border: rgb("#fca5a5"),
      fill: rgb("#fef2f2"),
    ),
  )

  let style = palette.at(kind)

  block(
    inset: 12pt,
    above: 1em,
    below: 1em,
    fill: style.fill,
    stroke: (
      left: 4pt + style.accent,
      right: 1pt + style.border,
      top: 1pt + style.border,
      bottom: 1pt + style.border,
    ),
    radius: 6pt,
    breakable: true,
  )[
    #text(weight: "bold", fill: style.accent)[#title]
    #v(0.45em)
    #body
  ]
}
