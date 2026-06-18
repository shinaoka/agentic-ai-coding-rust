# Agentic AI Coding × Rust

Lecture slides for **物理屋のための機械学習講義 (Machine Learning Lectures for Physicists) #22**,
2026-06-26, by **Hiroshi Shinaoka** (Saitama University).

Theme: how to use AI coding agents safely and fast for research code, using Rust's
type system, ownership, tests, and package management to grow AI-generated code into
verifiable, robust scientific software.

## Slides

| | PDF | Source |
|---|---|---|
| 日本語 (Japanese) | [`slides.pdf`](slides.pdf) | `slides.typ` + `slides_content.typ` |
| English | [`slides_en.pdf`](slides_en.pdf) | `slides_en.typ` + `slides_content_en.typ` |

Shared helpers: `slides_lib.typ`, `slides_meta.typ`. Figures: `figures/`.

## Reproduce

Requires [Typst](https://typst.app/) (built with 0.14).

```sh
typst compile slides.typ    slides.pdf      # Japanese
typst compile slides_en.typ slides_en.pdf   # English
```

Most figures are committed as `figures/*.svg`. A few are generated from their
sources next to them (e.g. `figures/fig_craft_vs_factory.typ`, the matplotlib chart
in `figures/fig_crate_growth.svg` from [shinaoka/rust_crate_count](https://github.com/shinaoka/rust_crate_count)).

## License

© 2026 Hiroshi Shinaoka. Released for educational use.
