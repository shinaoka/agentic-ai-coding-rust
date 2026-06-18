// Career timeline v2: clean Gantt chart of research themes
// Standalone: typst compile fig_career_timeline_v2.typ fig_career_timeline_v2.png --format png --ppi 200
#set page(width: 46em, height: 20em, margin: 1em)
#set text(font: "New Computer Modern", size: 9pt)

#import "@preview/cetz:0.3.4"

#cetz.canvas(length: 1em, {
  import cetz.draw: *

  let start_year = 2007
  let end_year = 2027
  let scale = 1.6
  let year_to_x(year) = (year - start_year) * scale

  let bar_h = 0.85
  let gap = 0.35

  // Helper: theme bar with label to the left
  let theme_bar(y, x_start, x_end, label, color) = {
    rect(
      (year_to_x(x_start), y), (year_to_x(x_end), y + bar_h),
      fill: color.lighten(75%), stroke: color + 1pt, radius: 0.12,
    )
    content((year_to_x(x_start) - 0.3, y + bar_h / 2),
      anchor: "east",
      text(size: 7pt, fill: color.darken(20%), weight: "bold")[#label])
  }

  // === Year axis ===
  let axis_y = 0.3
  line(
    (year_to_x(start_year), axis_y),
    (year_to_x(end_year), axis_y),
    stroke: luma(80) + 1.5pt,
  )
  for year in range(2008, 2028, step: 2) {
    let x = year_to_x(year)
    line((x, axis_y - 0.2), (x, axis_y + 0.2), stroke: luma(80) + 0.8pt)
    content((x, axis_y - 0.6), text(size: 7pt, fill: luma(100))[#year])
  }

  // === Career phase bar ===
  let phase_y = 1.2
  let phase_h = 0.75

  rect(
    (year_to_x(2007), phase_y), (year_to_x(2009), phase_y + phase_h),
    fill: luma(235), stroke: luma(180) + 0.8pt, radius: 0.12,
  )
  content((year_to_x(2008), phase_y + phase_h / 2),
    text(size: 7pt, weight: "bold", fill: luma(80))[PhD])

  rect(
    (year_to_x(2009), phase_y), (year_to_x(2015), phase_y + phase_h),
    fill: luma(235), stroke: luma(180) + 0.8pt, radius: 0.12,
  )
  content((year_to_x(2012), phase_y + phase_h / 2),
    text(size: 7pt, weight: "bold", fill: luma(80))[Postdoc])

  rect(
    (year_to_x(2015), phase_y), (year_to_x(2026.5), phase_y + phase_h),
    fill: luma(235), stroke: luma(180) + 0.8pt, radius: 0.12,
  )
  content((year_to_x(2020.7), phase_y + phase_h / 2),
    text(size: 7pt, weight: "bold", fill: luma(80))[PI at Saitama University])

  // Colors
  let c1 = rgb("#2E86AB")   // blue
  let c2 = rgb("#A23B72")   // purple
  let c3 = rgb("#F18F01")   // orange
  let c4 = rgb("#C73E1D")   // red
  let c5 = rgb("#5B5EA6")   // indigo
  let c6 = rgb("#3A7D44")   // green

  // === Research themes ===
  let base = phase_y + phase_h + 0.8

  let y0 = base
  theme_bar(y0, 2007, 2016, [Frustrated magnetism], c1)

  let y1 = y0 + bar_h + gap
  theme_bar(y1, 2013, 2026.5, [DFT+DMFT], c2)

  let y2 = y1 + bar_h + gap
  theme_bar(y2, 2016, 2026.5, [IR basis / sparse modeling], c3)

  let y3 = y2 + bar_h + gap
  theme_bar(y3, 2022, 2026.5, [QTT / TCI], c4)

  // === Software ===
  let y4 = y3 + bar_h + gap + 0.3
  theme_bar(y4, 2014, 2026.5, [Software], c5)

  // === Community ===
  let y5 = y4 + bar_h + gap + 0.3
  theme_bar(y5, 2019, 2026.5, [Community], c6)

  // Vertical gridlines (light, behind everything)
  for year in range(2008, 2028, step: 2) {
    let x = year_to_x(year)
    line((x, phase_y), (x, y5 + bar_h),
      stroke: luma(230) + 0.5pt)
  }
})
