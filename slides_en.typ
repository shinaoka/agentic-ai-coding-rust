#import "@preview/touying:0.6.1": *
#import themes.metropolis: *
#import "slides_lib.typ": *

#show: metropolis-theme.with(
  aspect-ratio: "16-9",
  config-info(
    title: [Agentic AI Coding × Rust],
    subtitle: [Growing computational-physics code you can verify],
    author: [Hiroshi Shinaoka],
    institution: [Saitama University],
  ),
  config-colors(
    primary: rgb("#eb811b"),
    primary-light: rgb("#d6c6b7"),
    secondary: rgb("#23373b"),
    neutral-lightest: white,
    neutral-darkest: rgb("#23373b"),
  ),
  config-page(fill: white),
  // 強調 *...* (touying では alert 扱い) を primary(オレンジ)ではなく深い青にする
  config-methods(alert: (self: none, body) => text(fill: rgb("#1565c0"), body)),
  footer: context {
    let slides = query(heading.where(level: 2))
    let cur = here().page()
    let next = slides.filter(h => h.location().page() > cur)
    if next.len() > 0 [
      #text(size: 0.7em, fill: muted)[Next: #next.first().body]
    ]
  },
)

#set text(font: ("New Computer Modern", "Hiragino Mincho ProN"), size: 20pt, lang: "en")

#include "slides_content_en.typ"
