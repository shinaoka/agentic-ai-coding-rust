// Limits of manual coding (Jin-Guo-style comic, 2 panels) — English-only figure
//  Left : scientific computing held up by a few artisans (bus factor)
//  Right: large project where issues / PRs pile up on a buried maintainer
// Standalone (vector SVG, page auto-trims margins):
//   typst compile fig_manual_limits.typ fig_manual_limits.svg
#set page(width: auto, height: auto, margin: 0.5em, fill: white)
#set text(font: ("Hiragino Sans", "New Computer Modern"), size: 10pt)

#import "@preview/cetz:0.3.4"

#let dark = rgb("#23373b")
#let blue = rgb("#1565c0")
#let orange = rgb("#eb811b")
#let red = rgb("#c62828")

#cetz.canvas(length: 1em, {
  import cetz.draw: *

  // sweat drops (upper-right of the head)
  let sweat(x, y) = {
    circle((x, y), radius: 0.14, fill: blue.lighten(15%), stroke: none)
    circle((x + 0.33, y + 0.2), radius: 0.1, fill: blue.lighten(15%), stroke: none)
  }
  // paper (issue/PR): placed at center (cx,cy) rotated by ang for a messy stack
  let rpaper(cx, cy, ang, label, col) = group({
    translate((cx, cy))
    rotate(ang)
    rect((-1.0, -0.52), (1.0, 0.52), fill: white, stroke: dark + 0.9pt)
    content((0, 0), text(size: 0.6em, fill: col, weight: "bold")[#label])
  })

  // ================= Left panel: scientific computing =================
  rect((0, 0), (15, 13.2), radius: 0.2, stroke: luma(150) + 1pt)
  content((7.5, 12.4), text(size: 1.0em, weight: "bold", fill: dark)[Scientific computing])

  // "Large codebase" slab held overhead (wider) + wobbling boxes
  rect((3.4, 7.0), (11.6, 8.75), radius: 0.15, fill: blue.lighten(80%), stroke: blue + 1.4pt)
  content((7.5, 7.87), text(size: 0.74em, weight: "bold", fill: blue)[Large codebase])
  rect((4.4, 8.75), (7.4, 9.85), fill: luma(240), stroke: dark + 0.8pt)      // wobbly
  rect((7.6, 8.75), (10.0, 9.7), fill: luma(240), stroke: dark + 0.8pt)
  rect((5.6, 9.85), (8.3, 10.65), fill: luma(243), stroke: dark + 0.8pt)

  // lone artisan holding it up (Atlas pose, wide arms, bent knees)
  circle((7.5, 6.0), radius: 0.42, fill: luma(248), stroke: dark + 1.2pt)    // head
  line((7.5, 5.58), (7.5, 4.0), stroke: dark + 2.6pt)                        // torso
  line((7.5, 5.15), (5.25, 6.95), stroke: dark + 2.4pt)                      // arm -> slab (wide)
  line((7.5, 5.15), (9.75, 6.95), stroke: dark + 2.4pt)
  line((7.5, 4.0), (6.5, 3.15), (6.45, 2.3), stroke: dark + 2.4pt)           // left leg (connected)
  line((7.5, 4.0), (8.5, 3.15), (8.55, 2.3), stroke: dark + 2.4pt)           // right leg (connected)
  sweat(8.45, 6.25)                                                          // clear of arms

  content((7.5, 1.25), text(size: 0.8em, fill: red, weight: "bold")[Held up by a few artisans])
  content((7.5, 0.45), text(size: 0.7em, fill: dark)[(PD / staff leave → unmaintainable)])

  // ================= Right panel: large project =================
  rect((16, 0), (31, 13.2), radius: 0.2, stroke: luma(150) + 1pt)
  content((23.5, 12.4), text(size: 1.0em, weight: "bold", fill: dark)[Large project])

  // buried maintainer lying on their back (head out left, feet out right; no face)
  circle((21.0, 2.6), radius: 0.4, fill: luma(248), stroke: dark + 1.2pt)    // head (left)
  line((21.4, 2.55), (24.2, 2.35), stroke: dark + 2.5pt)                     // torso (under pile)
  line((24.2, 2.35), (25.2, 2.95), stroke: dark + 2.3pt)                     // legs (out to the right)
  line((24.2, 2.35), (25.3, 1.95), stroke: dark + 2.3pt)

  // tall messy heap of issue / PR papers resting on the TORSO
  rpaper(22.6, 3.15, 10deg, "Issue", red)
  rpaper(23.6, 3.5, -12deg, "PR", orange)
  rpaper(22.5, 4.2, 19deg, "PR", orange)
  rpaper(23.8, 4.5, -8deg, "Issue", red)
  rpaper(22.7, 5.2, 14deg, "Issue", red)
  rpaper(23.9, 5.5, -16deg, "PR", orange)
  rpaper(22.6, 6.1, 8deg, "PR", orange)
  rpaper(23.7, 6.5, -10deg, "Issue", red)
  rpaper(22.9, 7.3, 16deg, "Issue", red)
  rpaper(23.5, 8.2, -7deg, "PR", orange)
  rpaper(22.9, 9.0, 12deg, "PR", orange)
  rpaper(23.4, 9.8, -9deg, "Issue", red)

  // arm flung out flat under the pile (limp, knocked flat by the weight)
  line((21.9, 2.5), (21.2, 1.8), (20.4, 1.95), stroke: dark + 2.3pt)   // arm out to the lower-left
  line((20.4, 1.95), (20.1, 2.22), stroke: dark + 1.8pt)              // splayed fingers (open hand)
  line((20.4, 1.95), (20.02, 1.96), stroke: dark + 1.8pt)
  line((20.4, 1.95), (20.18, 1.68), stroke: dark + 1.8pt)

  content((23.5, 1.25), text(size: 0.8em, fill: red, weight: "bold")[Issues & PRs keep piling up])
  content((23.5, 0.45), text(size: 0.7em, fill: dark)[(manual review can't keep up)])
})
