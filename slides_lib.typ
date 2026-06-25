// Helpers matching the compphyshack2026 / lab_introduction style.

// Inline red highlight (used within sentences, not as big blocks).
#let hl(body) = text(fill: rgb("#cc0000"), body)

// Blue inline link.
#let lk(url, label) = link(url)[#text(fill: rgb("#2563eb"))[#label]]

// Subdued text color (references, captions, source notes). One knob: darken here to taste.
#let muted = luma(95)

// Small gray reference line, pinned near the bottom.
#let ref-text(body) = {
  v(1fr)
  text(size: 0.8em, fill: muted, body)
}

// Same gray reference style but inline (no bottom-pinning). Use mid-slide.
#let ref-text-inline(body) = text(size: 0.8em, fill: muted, body)

// Ponchi-e placeholder: a labeled dashed box describing the sketch to draw later.
#let ponchi(desc, h: 58%) = align(center + horizon, box(
  width: 90%,
  height: h,
  fill: luma(249),
  radius: 6pt,
  stroke: (dash: "dashed", paint: rgb("#b9b9b9"), thickness: 1pt),
)[#align(center + horizon, text(size: 0.85em, fill: rgb("#8a8a8a"))[
  ［ポンチ絵］ #parbreak() #desc
])])

// Embedded finished figure (SVG / PNG).
#let figimg(path, w: 98%) = align(center + horizon, image(path, width: w))

// Monospace transcript box (for git log / rule excerpts).
#let codebox(body, size: 0.7em) = block(
  width: 100%,
  fill: luma(244),
  inset: 10pt,
  radius: 6pt,
  stroke: 0.5pt + luma(210),
)[#text(size: size, font: ("Menlo", "Hiragino Mincho ProN"))[#body]]
