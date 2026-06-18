// Industrial-revolution metaphor: a craftsman hand-makes vases one by one -> a mold mass-produces identical bottles
// Standalone (vector SVG output, margins auto-trimmed by the auto page):
//   typst compile fig_craft_vs_factory_en.typ fig_craft_vs_factory_en.svg
#set page(width: auto, height: auto, margin: 0.5em, fill: white)
#set text(font: ("Helvetica", "New Computer Modern"), size: 10pt)

#import "@preview/cetz:0.3.4"

#let dark = rgb("#23373b")
#let blue = rgb("#1565c0")
#let orange = rgb("#eb811b")

#cetz.canvas(length: 1em, {
  import cetz.draw: *

  // vase (base center (cx, cy), height ~2s): smooth bezier outline (handmade craft)
  let vase(cx, cy, s) = {
    merge-path(close: true, fill: blue.lighten(75%), stroke: blue + 1.2pt, {
      bezier((cx + 0.4*s, cy), (cx + 0.22*s, cy + 1.5*s), (cx + 0.98*s, cy + 0.5*s), (cx + 0.7*s, cy + 1.32*s))
      line((cx + 0.22*s, cy + 1.5*s), (cx + 0.36*s, cy + 1.95*s))
      line((cx + 0.36*s, cy + 1.95*s), (cx - 0.36*s, cy + 1.95*s))
      line((cx - 0.36*s, cy + 1.95*s), (cx - 0.22*s, cy + 1.5*s))
      bezier((cx - 0.22*s, cy + 1.5*s), (cx - 0.4*s, cy), (cx - 0.7*s, cy + 1.32*s), (cx - 0.98*s, cy + 0.5*s))
      line((cx - 0.4*s, cy), (cx + 0.4*s, cy))
    })
  }

  // bottle (base center (cx, cy), height ~2s): industrial product mass-produced by a mold (blow molding)
  let bottle(cx, cy, s) = {
    merge-path(close: true, fill: blue.lighten(75%), stroke: blue + 1.1pt, {
      line((cx + 0.42*s, cy), (cx + 0.42*s, cy + 1.2*s))
      line((cx + 0.42*s, cy + 1.2*s), (cx + 0.14*s, cy + 1.55*s))
      line((cx + 0.14*s, cy + 1.55*s), (cx + 0.14*s, cy + 1.85*s))
      line((cx + 0.14*s, cy + 1.85*s), (cx - 0.14*s, cy + 1.85*s))
      line((cx - 0.14*s, cy + 1.85*s), (cx - 0.14*s, cy + 1.55*s))
      line((cx - 0.14*s, cy + 1.55*s), (cx - 0.42*s, cy + 1.2*s))
      line((cx - 0.42*s, cy + 1.2*s), (cx - 0.42*s, cy))
      line((cx - 0.42*s, cy), (cx + 0.42*s, cy))
    })
    rect((cx - 0.17*s, cy + 1.85*s), (cx + 0.17*s, cy + 2.02*s), fill: blue, stroke: blue + 1.1pt)
  }

  // ---- left: craftsman makes one by one ----
  circle((2.5, 5.3), radius: 0.42, fill: luma(246), stroke: dark + 1.2pt)
  line((2.5, 4.88), (2.5, 3.2), stroke: dark + 3pt)
  line((2.5, 3.2), (2.05, 2.05), stroke: dark + 2.5pt)
  line((2.5, 3.2), (2.95, 2.05), stroke: dark + 2.5pt)
  line((2.5, 4.55), (4.1, 4.0), stroke: dark + 2.5pt)
  line((2.5, 4.3), (4.0, 3.4), stroke: dark + 2.5pt)
  rect((4.5, 2.3), (6.5, 2.75), fill: luma(230), stroke: dark + 1pt)
  vase(5.5, 2.75, 1.0)

  // ---- center: transition arrow ----
  line((8.8, 3.6), (15.2, 3.6), stroke: dark + 3pt, mark: (end: "stealth", fill: dark))

  // ---- right: mass production by a mold ----
  rect((23.8, 5.5), (29.2, 6.4), radius: 0.12, fill: orange.lighten(55%), stroke: orange + 1.5pt)
  content((26.5, 5.95), text(weight: "bold")[Mold])
  line((26.5, 5.4), (26.5, 4.2), stroke: orange + 2pt, mark: (end: "stealth", fill: orange, scale: 0.7))
  rect((17.3, 2.35), (34.7, 3.1), radius: 0.4, fill: luma(235), stroke: dark + 1pt)
  circle((18.1, 2.72), radius: 0.52, fill: luma(210), stroke: dark + 1pt)
  circle((33.9, 2.72), radius: 0.52, fill: luma(210), stroke: dark + 1pt)
  for i in range(5) {
    bottle(19.6 + i * 3.2, 3.1, 0.62)
  }
})
