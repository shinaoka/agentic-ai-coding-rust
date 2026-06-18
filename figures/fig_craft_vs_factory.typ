// 産業革命メタファーのポンチ絵: 職人が壺を1点ずつ手作り → 金型で同じ壺を大量生産
// Standalone (vector SVG 出力, 余白は auto ページで自動トリミング):
//   typst compile fig_craft_vs_factory.typ fig_craft_vs_factory.svg
#set page(width: auto, height: auto, margin: 0.5em, fill: white)
#set text(font: ("Hiragino Sans", "New Computer Modern"), size: 10pt)

#import "@preview/cetz:0.3.4"

#let dark = rgb("#23373b")
#let blue = rgb("#1565c0")
#let orange = rgb("#eb811b")

#cetz.canvas(length: 1em, {
  import cetz.draw: *

  // 壺 (base 中心 (cx, cy), 高さ ~2s): ベジェで滑らかな輪郭 (手作りの工芸品)
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

  // ボトル (base 中心 (cx, cy), 高さ ~2s): 金型 (ブロー成形) で量産される工業製品
  let bottle(cx, cy, s) = {
    merge-path(close: true, fill: blue.lighten(75%), stroke: blue + 1.1pt, {
      line((cx + 0.42*s, cy), (cx + 0.42*s, cy + 1.2*s))           // 胴右
      line((cx + 0.42*s, cy + 1.2*s), (cx + 0.14*s, cy + 1.55*s))  // 肩右
      line((cx + 0.14*s, cy + 1.55*s), (cx + 0.14*s, cy + 1.85*s)) // 首右
      line((cx + 0.14*s, cy + 1.85*s), (cx - 0.14*s, cy + 1.85*s)) // 口
      line((cx - 0.14*s, cy + 1.85*s), (cx - 0.14*s, cy + 1.55*s)) // 首左
      line((cx - 0.14*s, cy + 1.55*s), (cx - 0.42*s, cy + 1.2*s))  // 肩左
      line((cx - 0.42*s, cy + 1.2*s), (cx - 0.42*s, cy))           // 胴左
      line((cx - 0.42*s, cy), (cx + 0.42*s, cy))                   // 底
    })
    rect((cx - 0.17*s, cy + 1.85*s), (cx + 0.17*s, cy + 2.02*s), fill: blue, stroke: blue + 1.1pt) // キャップ
  }

  // ---- 左: 職人が1点ずつ手作り ----
  // 人 (職人)
  circle((2.5, 5.3), radius: 0.42, fill: luma(246), stroke: dark + 1.2pt)
  line((2.5, 4.88), (2.5, 3.2), stroke: dark + 3pt)            // 胴
  line((2.5, 3.2), (2.05, 2.05), stroke: dark + 2.5pt)         // 脚
  line((2.5, 3.2), (2.95, 2.05), stroke: dark + 2.5pt)
  line((2.5, 4.55), (4.1, 4.0), stroke: dark + 2.5pt)          // 腕 (壺へ)
  line((2.5, 4.3), (4.0, 3.4), stroke: dark + 2.5pt)
  // 作業台 + 壺
  rect((4.5, 2.3), (6.5, 2.75), fill: luma(230), stroke: dark + 1pt)
  vase(5.5, 2.75, 1.0)

  // ---- 中央: 転換の矢印 ----
  line((8.8, 3.6), (15.2, 3.6), stroke: dark + 3pt, mark: (end: "stealth", fill: dark))

  // ---- 右: 金型で大量生産 ----
  // 金型 (プレス)
  rect((23.8, 5.5), (29.2, 6.4), radius: 0.12, fill: orange.lighten(55%), stroke: orange + 1.5pt)
  content((26.5, 5.95), text(weight: "bold")[金型])
  line((26.5, 5.4), (26.5, 4.2), stroke: orange + 2pt, mark: (end: "stealth", fill: orange, scale: 0.7))
  // コンベア
  rect((17.3, 2.35), (34.7, 3.1), radius: 0.4, fill: luma(235), stroke: dark + 1pt)
  circle((18.1, 2.72), radius: 0.52, fill: luma(210), stroke: dark + 1pt)
  circle((33.9, 2.72), radius: 0.52, fill: luma(210), stroke: dark + 1pt)
  // 同一のボトルが並ぶ (大量・均質)
  for i in range(5) {
    bottle(19.6 + i * 3.2, 3.1, 0.62)
  }
})
