// ============================================================
// Agentic AI Coding × Rust  ── 本文 (compphyshack2026 スタイルで全面リスタイル)
// 主装置: 2カラム比較表 + 具体数字 + inline リンク．hl は文中強調．
// 図: figimg = 完成図 / ponchi = ポンチ絵プレースホルダ / codebox = 実物抜粋
// ============================================================

#import "@preview/touying:0.6.1": *
#import themes.metropolis: *
#import "slides_lib.typ": *

#let live = align(center + horizon, text(size: 1.05em, fill: rgb("#2563eb"))[💻 Live-driven: slides are minimal, the hands-on and screen share carry the talk])

#title-slide()

// ============================================================
= Prerequisites
// ============================================================

== Prerequisites (each of you, before the session)
+ #hl[Install one CLI-type agent] beforehand.
  - Free: #lk("https://github.com/google-gemini/gemini-cli", "Gemini CLI") / ChatGPT Plus and up: #lk("https://developers.openai.com/codex/cli", "Codex") / anything else is fine too.
  - Setup guides: #lk("https://atelierarith.github.io/CompPhysHack2026HandsOn/", "Satoshi Terasaki") / #lk("https://github.com/JunyaIto256/VSCode-Gemini-LaTeX", "Junya Ito").
+ #hl[Set up a programming language toolchain].
  - We will use #hl[Rust] today, but anything works. For Rust, #lk("https://www.rust-lang.org/tools/install", "install Cargo") (reference).

== Today's plan
- First half = methodology / second half = 2D Ising hands-on.
- On the day we only do an #hl[environment check]: most of the time goes to methodology and practice.
- #hl[2D Ising is well known], so even a free model should be able to run the whole thing (probably).

// ============================================================
= Introduction
// ============================================================

== About me, and where I stand today
   - PhD at U. Tokyo → postdoc in Switzerland → PI at Saitama U. (2015〜)
   - Broad experience from quantum many-body to first-principles calculations
   - IR basis / sparse modeling / tensor networks
   - Substantial hands-on experience with *C++ / Python / Julia / Fortran*
   - Contributor to OSS and community
  #align(center + horizon, image("figures/fig_career_timeline_v2.png", width: 70%))
Today I don't write a single line, and I don't read code line-by-line either. Even so, I feel that #hl[agentic coding is more trustworthy than coding by hand]. Why?


== A common criticism: "AI slop"
Some call the output of agentic coding #hl["AI slop"]:

#v(0.15em)
#{
  set text(size: 0.84em)
  table(columns: (27%, 1fr), stroke: none, row-gutter: 0.38em, column-gutter: 0.8em, align: (left + top, left + top),
    [*Loss of craft*\ #text(size: 0.72em)[Sinclair Target]],
    [#text(size: 0.82em, style: "italic")[“…would prefer not to use agentic tools #hl[even if they worked as advertised].”]\ #text(size: 0.72em, fill: gray)[Even if they work, you lose care for the work. #lk("https://sinclairtarget.com/blog/2026/06/01/quality-in-the-age-of-slop/", "Quality in the Age of Slop, 2026")]],

    [*Maintenance breaks down*\ #text(size: 0.72em)[D. Stenberg (curl)]],
    [#text(size: 0.82em, style: "italic")[“The current torrent of submissions put a high load on the curl security team…”]\ #text(size: 0.72em, fill: gray)[Buried in AI slop, curl shut down its bug bounty (2026). #lk("https://www.theregister.com/2026/01/21/curl_ends_bug_bounty/", "The Register")]],

    [*Shared resources degrade*\ #text(size: 0.72em)[Baltes et al.]],
    [#text(size: 0.82em, style: "italic")[“…a tragedy of the commons, where individual productivity gains #hl[externalize costs onto reviewers, maintainers, and the broader community].”]\ #text(size: 0.72em, fill: gray)[#lk("https://arxiv.org/abs/2603.27249", [“An Endless Stream of AI Slop”, arXiv:2603.27249])]],

    [*Overhyped showcases*\ #text(size: 0.72em)[Anthropic C compiler]],
    [#text(size: 0.82em)[A C compiler built with 16 parallel Claude instances (100K lines, ~\$20k). An independent benchmark found it #hl[faster than GCC -O0 but still behind GCC -O2]. Such showcases #hl[grow AI skepticism] when the evaluation target is unclear.]\ #text(size: 0.72em, fill: gray)[#lk("https://www.anthropic.com/engineering/building-c-compiler", "Anthropic") · #lk("https://dineshgdk.substack.com/p/benchmarking-claude-c-compiler", "benchmark")]],
  )
}
#ref-text[Weak optimization is #hl[not proof that AI cannot do it]; it points to a missing performance oracle and a loose human-AI loop.]

== The industrial revolution of coding: from craft to factory
#v(0.8em)
#align(center, image("figures/fig_craft_vs_factory_en.svg", width: 78%))
#v(0.6em)
#pad(x: 4%, grid(columns: (1fr, 1fr), column-gutter: 1.5em, align: center,
  [#text(size: 0.9em)[Humans crafting one piece at a time]\ #text(fill: rgb("#1565c0"), weight: "bold")[\= hand coding]],
  [#text(size: 0.9em)[Mass production from a mold (fast, uniform)]\ #text(fill: rgb("#1565c0"), weight: "bold")[\= ideal agentic coding]],
))
#v(0.6em)
#align(center)[The same shift is happening right now with #hl[agentic coding].]
#align(center)[We are at the stage of figuring out how to realize #hl[ideal agentic coding].]

== Today's thesis (overview)
#align(center)[#block(width: 88%)[
  #set align(center)

  //1AI 生成コードを逐行では読まない
  //1#v(0.3em)
  //#sym.arrow.b
  //#v(0.3em)

  I moved where trust is placed, from #hl[visual inspection] to #hl[mechanical, external verification]:

  Compiler · test · oracle · rules now underwrite correctness in place of eyeballing.

  //1#v(0.5em)
//1
  //1人間の仕事は #hl[何を検査し，何を「正本」として残すかを設計すること]．
]]
#v(0.5em)
#text(size: 0.88em)[
  The underlying view: fast AI generation is industrial mass production. Instead of fixing products one at a time, you fix the #hl[mold (= source of truth: rules · oracle)].\
  //体験談 → 判断軸 (検証可能性) → 正本を育てる → ハンズオン の順に詳しく展開する．
]

// ============================================================
= Foundations of coding agents
// ============================================================

== Chat-type vs CLI-type agents
#table(columns: (1fr, 1fr), stroke: 0.4pt + gray, inset: 8pt,
  [*Chat-type (browser conversation)*], [*CLI-type (terminal)*],
  [Ask a question, copy-paste the answer], [Edit and run files directly],
  [No access to the local environment], [Operates the repo and git],
  [A human relays one round trip at a time], [#hl[Runs multi-step autonomously]],
)
#v(0.3em)
CLI-type agents are #hl[designed for long-running autonomous execution]. They are today's protagonist.
#ref-text[In terms of generations: Gen1 (Cursor / Copilot) → Gen2 (Claude Code / Codex / ...). #lk("https://missing.csail.mit.edu/2026/agentic-coding/", "MIT missing-semester: agentic coding")]

== Representative CLI agents (harnesses)
#table(columns: (auto, 1fr), stroke: none, row-gutter: 0.45em,
  [#lk("https://code.claude.com/docs/en/overview", "Claude Code")], [Anthropic. Autonomous coding in the terminal/IDE],
  [#lk("https://developers.openai.com/codex/cli", "Codex CLI")], [OpenAI. Rust OSS, bundled with ChatGPT plans],
  [#lk("https://github.com/google-gemini/gemini-cli", "Gemini CLI")], [Google. OSS, has a free tier],
  [#lk("https://www.kimi.com/code", "Kimi CLI")], [Moonshot (China). Model K2.7 Code],
  [#lk("https://opencode.ai/", "OpenCode")], [OSS, provider-agnostic],
  [#lk("https://github.com/earendil-works/pi/tree/main/packages/coding-agent", "Pi")], [Minimal OSS. Add your own extensions and skills to grow it (for minimalists)],
)

== Harness ≠ model
- #hl[Harness] = the CLI tool (the framework for editing files, running commands, calling tools).
- #hl[Model] = the LLM running underneath. Many harnesses let you #hl[swap the model].
  - Neutral: OpenCode / Gemini CLI ・ first-party-leaning: Claude Code / Codex.
- Performance is set by the #hl[model], usability and autonomy by the #hl[harness]. Choose both.

== Subscription vs API, and budget models
#table(columns: (auto, 1fr), stroke: 0.4pt + gray, inset: 8pt,
  [*Subscription*], [Claude Pro \$20/mo (Claude Code included) / ChatGPT + Codex. Flat monthly fee + usage allowance],
  [*Pay-as-you-go API*], [Billed per token used. Connect any model to a harness],
)
#v(0.3em)
Budget coding-oriented APIs (2026): #lk("https://api-docs.deepseek.com/quick_start/pricing", "DeepSeek V4 Flash") (input ~\$0.14 / output ~\$0.28 per 1M) ・ #lk("https://platform.kimi.ai/docs/pricing/chat-k27-code", "Kimi K2.7 Code").
Example: #hl[OpenCode + a budget API] lets you start cheaply.
#ref-text[Prices and model names are as of June 2026. Generations turn over fast.]

== What is a skill
- #hl[Skill] = a #hl[playbook] for the agent (markdown). It breaks an abstract task into explicit small steps.
- Close to a function in a program, but the target of the operation is #hl[the agent's behavior, not data].
- It #hl[fires automatically] on related work, and skills call other skills to compose complex procedures.
- #hl[CLAUDE.md / AGENTS.md] = memory that persists across sessions (conventions, commands, structure).
#ref-text[#lk("https://www.jinguo-group.science/sustainable-automation/", "Jin-Guo Liu: Sustainable Automation") · #lk("https://github.com/obra/superpowers", "obra/superpowers")]

== What a real workflow looks like
The superpowers skills enforce #hl[brainstorm → plan → execute] (each stage fires automatically):
#v(0.4em)
#align(center, {
  let ph(t, c) = rect(radius: 5pt, inset: (x: 0.8em, y: 0.55em), fill: c.lighten(88%), stroke: c + 1pt)[
    #text(size: 0.95em, weight: "bold", fill: c)[#t]
  ]
  let ar = text(size: 1.1em, fill: luma(120))[#h(0.25em) #sym.arrow.r #h(0.25em)]
  stack(dir: ltr,
    ph("Brainstorm", rgb("#1565c0")), ar,
    ph("Plan", rgb("#1565c0")), ar,
    ph("Execute", rgb("#2e7d32")), ar,
    ph("Review", rgb("#eb811b")), ar,
    ph("Finish", rgb("#c62828")),
  )
})
#v(0.4em)
- The starting point is not a prompt but a #hl[math-backed design doc]. You design the verification (oracle / test) at the same time.
- After implementing, have the AI emit the correspondence #hl[code ↔ algorithm/math] and reconcile it (sometimes you never read the code itself).
- Execute is TDD + splitting across subagents; if Review surfaces a problem, go back to an earlier stage.
#ref-text[#lk("https://github.com/obra/superpowers", "obra/superpowers") · #lk("https://www.jinguo-group.science/sustainable-automation/", "Jin-Guo Liu: Sustainable Automation")]

// ============================================================
= This past year ── pushing agentic coding to its limits
// ============================================================



//#v(0.3em)
//私もこの1年，これらを *実際に* 大量に踏んだ．→ #hl[結論と対処は次スライド以降]．
//#ref-text[AI slop の正確な定義は後半「正本を育てる」で扱う．]

== How I got here
#text(size: 0.95em, style: "italic")[Since October 2025, #hl[I have not written a single line of code]. I don't read generated code line-by-line either.]

#v(0.4em)

#table(columns: (auto, 1fr), stroke: none, row-gutter: 0.4em,
  [*Jan 2025*], [Started with Cursor, still a generation where you look at the source],
  [*Oct 2025*], [Began porting #lk("https://github.com/SpM-lab/SparseIR.jl", "SparseIR.jl") from Julia to Rust],
  [*Dec 2025*], [Switched to Claude Code: #hl[stopped reading generated code line-by-line]],
  [*Jan 2026*], [Started tensor4all-rs: a Rust port of the Julia TN ecosystem],
  [*Feb 2026*], [Started tenferro-rs: a PyTorch-like tensor stack in Rust],
  [*Mar 2026〜*], [Now mostly on Codex],
)

//== この講演自体も同じやり方で書いた
//#grid(columns: (50%, 50%), gutter: 1em,
  //[
    //- Typst + Claude Code の *AI-人間フィードバックループ*
    ////- 過去のブログ記事 + GitHub repo を context に投入
    //- #hl[Typst も一行も手で書いていない]
  //],
  //ponchi(h: 62%)[AI と人間がフィードバックループで講演スライドを共作する様子],
//)
//#ref-text[元ネタ = ブレスト記録 / 生成 = エージェント / 人間の入力は最小化]

== What I built: tensor4all-rs
A port of Julia's tensor learning stack to Rust.

#v(0.3em)

#text(size: 0.85em)[
  #lk("https://github.com/tensor4all/TensorCrossInterpolation.jl", "TensorCrossInterpolation.jl") / #lk("https://github.com/tensor4all/QuanticsTCI.jl", "QuanticsTCI.jl") etc. / #lk("https://scipost.org/SciPostPhys.18.3.104", "SciPost Phys. 18, 104 (2025)") / #lk("https://tensor4all.org", "tensor4all")
]
#v(0.2em)
#text(size: 0.82em)[Rust stack (#lk("https://github.com/tensor4all", "github.com/tensor4all")): #lk("https://github.com/tensor4all/tensor4all-rs", "tensor4all-rs") · #lk("https://github.com/tensor4all/tenferro-rs", "tenferro-rs") · #lk("https://github.com/tensor4all/tidu-rs", "tidu-rs") · #lk("https://github.com/tensor4all/Tensor4all.jl", "Tensor4all.jl")]

- Started Jan 1, 2026 (originally a winter-break side project to test the "limits" of agentic coding)
- A handful of humans + AI (from Claude Code to mostly Codex)
- 353 commits in 2 months · +61,486 lines in the first 2 weeks (151 files)

$arrow.r$ The debate among collaborators (AI slop, pedagogy, is Julia still needed?) is still ongoing.

#v(0.5em)

#text(size: 1.0em)[#hl["After many trials, errors, and failures, the right way to do agentic coding is just starting to come into view."]]

Design, testing and verification, the right language, (pedagogy)...

== A deliberate experiment: pushing agentic coding to the limit

#text(size: 1.0em)[#hl["Observe the failures, and look for ways to control them."]]

//正しい抽象を探すため，新しい tensor stack (tenferro-rs) を一から作り始めた．\
//そこで agentic coding を #hl[限界まで押し], 何が壊れるかを観測する実験にした．\
//「失敗」ではなく，限界を測る実験である．
//
//#ponchi(h: 44%)[agentic coding のダイヤルを限界まで回す様子 (速度↑ → 何が壊れるか)]
//
//== 最初はモノリシック
//#figimg("figures/fig_monolithic.svg", w: 60%)
The original Julia ecosystem was huge, covering Quantics Tensor Train (QTT) / Tensor Cross Interpolation (TCI). Parts of it depend on ITensors.jl.

#v(2em)

I started from a "monolithic structure": porting the needed parts of ITensors.jl (index system, tensor contraction) + QTT/TCI.

//- 抽象化・階層化が壊れる．巨大なコード (数十万行) のデザインをどう統一する？
//- 正しさをどう検証するか？
//- パフォーマンス最適化 (AIが多重ループを書く，無駄なメモリ確保をする...)
//
//思いがけない良い発見: RustはAIと相性がよく大規模開発が楽

== Failure cases

#text(size: 1.0em)[#hl[(As expected) many problems arose]]

- Breaks abstraction: importing and using low-level functionality from a high-level layer (a quick hack)
- Quietly loosens unit-test thresholds (gives up on fixing the bug)
- Writes nested loops instead of using BLAS (the result is correct, but...)
- A single source file exceeding several thousand lines
- ...

//最先端のAIは良くなってきているが，エラーは付きもの (人間も同じ)．
//1個ずつ目で見て修正するのは不可能．
//$arrow.r$
//ルール，設計などでAIの行動を制約し，ソースコードを機械的に監査する仕組みが必要
//$arrow.r$ 目によるレビューから脱却

== Complexity keeps growing
#grid(columns: (30%, 70%), gutter: 1em,
  [
    - Fixing things individually can't keep up.
    - For long-term maintenance, the only option is to *grow one unified set of* philosophy and design rules.
    - #hl[Otherwise complexity keeps growing.]
  ],
  align(center + horizon, image("figures/fig_complexity_growth.svg", width: 100%)),
)


== Fix the "rules," not the "code"

*References*
- Heinrich pyramid: a safety-engineering rule of thumb that many minor incidents and near misses sit behind one major accident.
- Aircraft accident investigation: ICAO Annex 13 defines the objective as prevention, not blame.
#ref-text[#lk("https://skybrary.aero/articles/heinrich-pyramid", "SKYbrary: Heinrich Pyramid") · #lk("https://www.icao.int/sites/default/files/postalhistory/annex_13_aircraft_accident_and_incident_investigation.htm", "ICAO Annex 13") · #lk("https://asrs.arc.nasa.gov/", "NASA ASRS")]

*My approach in agentic coding*
- Correct the AI's behavior by building "rules" and "institutions"
- Build mechanisms to audit mechanically and fix code in bulk

(Such mechanisms were always important even in hand coding.)

$arrow.r$ #hl[Reconcile AI's overwhelmingly fast code generation with quality control]

== Monolithic → split structure (enforcement by structure)

Split the huge tensor4all-rs into independent layers with distinct roles.

#v(0.25em)

#let layer(name, role, color, url) = block(
  width: 100%,
  stroke: color + 1pt,
  fill: color.lighten(88%),
  inset: 0.42em,
  radius: 4pt,
)[
  #grid(columns: (30%, 70%), gutter: 0.9em, align: horizon,
    link(url, text(size: 0.98em, weight: "bold", fill: color)[#name]),
    text(size: 0.82em)[#role],
  )
]

#pad(x: 7%)[
  #layer("Tensor4all.jl", "Human-facing interface (Julia, ITensors-compatible)", rgb("#C73E1D"), "https://github.com/tensor4all/Tensor4all.jl")
  #v(0.28em)
  #layer("tensor4all-rs", "Tensor networks: TreeTN / QTT / TCI", rgb("#1565c0"), "https://github.com/tensor4all/tensor4all-rs")
  #v(0.28em)
  #layer("tenferro-rs", "General tensor computation + autodiff + GPU (PyTorch/JAX-like)", rgb("#1565c0"), "https://github.com/tensor4all/tenferro-rs")
  #v(0.28em)
  #layer("tidu-rs", "General-purpose autodiff engine", rgb("#1565c0"), "https://github.com/tensor4all/tidu-rs")
]

#v(0.3em)
Humans design the split structure while discussing with the AI. #hl[Once split, the AI can only operate within each layer and can't break the hierarchy.]
#ref-text[The layers and API boundaries were decided by analyzing PyTorch / JAX designs (their successes and failures) in detail, together with the AI.\
#text(style: "italic")[Jin-Guo Liu (initial tenferro design), Satoshi Terasaki (dev support), tensor4all collaboration (tensor4all-rs development)]]

== Modularizing each layer

#align(center, image("figures/tenferro-architecture.svg", width: 70%))
#v(0.2em)
#align(center, text(size: 0.85em)[Rust controls #hl[symbol visibility] along the module hierarchy, so an AI agent can't import a private symbol from outside on its own.])

// 規模の壁 + ChatGPT解答 (三層構造) は後半「正本を育てる」の三本柱へ移動した．

// ============================================================
= Verifiability over readability
// ============================================================

#text(size: 0.6em)[
The following discussion assumes development of a "huge codebase."
]


== The reasoning for language choice flips: how my own words changed

=== March 2023 (Naha, eve of the Computational Physics Spring School 2023)
These days I often prototype in a Jupyter Notebook, and Julia is comfortable because the code looks like the math, it's easy to review, and it handles memory management nicely for you. I'm interested in Rust too, but for a typical student it's a high bar to learn, and the numerical libraries aren't there yet, right?

=== 2026
These days I don't use Jupyter Notebook for prototyping, and Rust, with its strict and explicit memory management, is more efficient for agentic coding. Since the agent writes the code, the steep learning curve isn't a problem. With AI's help, keeping the code consistent with the math isn't an issue even if the code gets a bit long.
Missing numerical libraries can easily be ported to Rust.

#align(center, hl[Verifiability over readability])


== The hand-coding era: what each language gave you
#table(columns: (auto, 1fr), stroke: 0.4pt + gray, inset: 8pt,
  [*Fortran*], [Arrays are native to the language · hand-written loops are still fast · LAPACK / BLAS at your fingertips],
  [*Python*], [Try things interactively (REPL / notebook) · numpy / scipy / matplotlib · instant visualization],
  [*Julia*], [Notation close to the math (broadcast / Unicode) · fast via JIT · prototype is close to production],
)
#v(0.3em)
Common thread: all of these lower the cost of #hl[a human writing, reading, and maintaining] the code by hand.

//== エージェントコーディング時代にRustが心地いいと感じる理由
//
//- 優秀なパッケージシステムとビルドシステム (Cargo)
//- 厳格なメモリ・所有権の管理 (aliasing起因の自明なバグ排除)
//- 比較的高速なコンパイル (型の整合性チェックは軽量，並列コンパイル化)
//
//(Juliaで基盤ライブラリを書くと，長大なテスト時間，型不安定性に悩まされる...)

== The criteria for choosing a language change: large-scale development
The metrics that used to matter all assumed *a human writes and maintains* the code:

#table(columns: (1fr, 1fr), stroke: 0.4pt + gray, inset: 8pt,
  [*Traditional metric*], [*Agentic era*],
  [Readability: follow it line by line], [#hl[Verifiability]: check it with an oracle],
  [A gentle learning curve], [Steepness is *taken over by the AI*],
  [Closeness to the math: verify by eye], [Combine with mechanical checks],
  [Writing speed], [No longer the bottleneck],
)
#v(0.3em)
#align(center, text(size: 1.0em)[#hl[How easy to inspect] over #hl[how easy to read].])

== Readable source ≠ Inspectable implementation
*Being readable* and *being inspectable* are different things.

Example: even Julia's broadcast assignment, which *looks* close to the math, doesn't pin down its behavior from how it reads:
#v(0.25em)
#block(fill: luma(244), inset: 9pt, radius: 6pt, width: 100%,
  text(size: 0.85em, raw(
    "b = a          # b and a point to the same array (alias)\na .+= c        # if updated in-place, b changes too ← side effect",
    lang: "julia", block: true)))
#v(0.25em)
#hl[aliasing / mutation / allocation are invisible from how a line looks.]

#align(center, text(size: 1.0em)[So far this is language-independent. #hl[So which language is a good fit for verifiability?]])

== What Rust is (the minimum for this audience)
- A systems language from #hl[Mozilla]. Developed for the Firefox implementation, with a stable release (1.0) in 2015.
- Valued for reliability, it was officially adopted into the #hl[Linux kernel] (since v6.1, the second language after C).
- #hl[Ownership]: memory safety without a GC. Data races and dangling pointers are ruled out *at compile time*.
- #hl[Cargo]: build, dependency resolution, testing, and benchmarking are integrated as standard.
#v(0.3em)
One line for physicists: #hl["a safe C++ + a first-class build/dependency manager"].\
Speed is C / C++ class, safety is GC-language class.

== Accelerating growth of the ecosystem
#v(-0.3em)
#align(center, image("figures/fig_crate_growth.svg", width: 72%))
///#v(-0.2em)
///#align(center, text(size: 0.95em)[crates.io: #hl[602 (2015) → 21 万 (2026)]，新規 #hl[5.4 万/年] (2025)．2023 年の「数値計算ライブラリが揃わない」は覆った．])
///#ref-text[図: #lk("https://github.com/shinaoka/rust_crate_count", "shinaoka/rust_crate_count") (crates.io DB dump)]

== Why Rust? A fast feedback loop with the AI
Python / Julia were designed to *write fast*. In the AI era this advantage *flips*:

#table(columns: (1fr, 1fr), stroke: 0.4pt + gray, inset: 8pt,
  [*Python / Julia*], [*Rust + AI*],
  [Fast to write by hand], [AI writes it: same speed],
  [Errors surface at runtime], [#hl[Caught at compile time]],
  [Verification needs execution], [`cargo check` in seconds],
  [Slow to find the AI's mistakes], [Find the AI's mistakes *instantly*],
)

#text(size: 1em)[#super[\*]This assumes a huge codebase.]

#ref-text[#lk("https://zenn.dev/h_shinaoka/articles/a099b814166ac7", "Zenn: Why I Migrated from C++ to Rust")]

== A personal experience
- #hl[A from-scratch build of tenferro-rs + external dependencies is ~2 min (Macbook Pro)]\ edit→test finishes in tens of seconds, cargo check is instant.
//- 比較: Julia は全テスト >10分，CI の大半が precompile に消える
- The AI handles the *mechanical complexity* of ownership / lifetimes\ → humans can focus on verifying #hl[the algorithm, the design, and correctness].
- Cargo resolves pure-Rust dependencies. No CMake needed. \ No version conflicts at link time.
//- 複素 SVD の AD など繊細な rule を *一度だけ正しく* 実装して共有

Personally, the anxiety I used to feel in Julia/C++/Python, that "once the code grows large, verification gets hard," is gone.

#ref-text[#lk("https://github.com/tensor4all/tensor4all-meta/blob/main/docs/why_rusty_julia.md", "tensor4all-meta/docs/why_rusty_julia.md")]

== The learning curve: the AI takes over the steep early part
#figimg("figures/fig_learning_curve_en.svg", w: 70%)
//#align(center, text[Rustの美味しいところだけが残る．])
#align(center, hl[Only the best parts of Rust are left.])
#align(center, text[Students in my group are migrating from Julia to Rust too.])
//#ref-text[模式図. Rust は序盤が急 = 従来は不利．だがその急勾配を AI が肩代わりするため，評価が反転する．]

== Workflow in the agentic coding era: languages can mix
- Before: tried things interactively in a Jupyter Notebook.
- Now: #hl[instruct the AI in natural language] \
  #hl[generate code → compute → save results to a file → plot]
- For prototyping, a Jupyter Notebook is #hl[not required].
- #hl[You don't need to do all computation in a single language]. While leveraging existing assets, you can #hl[migrate to Rust gradually].

//== ただし Rust も物理バグは止めない
//- 型・compiler は #hl[符号・prefactor・frequency convention・物理モデル] の誤りを止めない．
//- Rust は品質保証の全体ではなく，検証可能性を高める *基盤*．
//- 向き不向きの本質は #hl[oracle があるか] (library vs application)．

== Takeaway
#align(center + horizon)[#text(size: 1.15em)[
  The criterion shifted from #hl[minimizing cognitive cost] to #hl[maximizing verifiability].
]]



//== 現場から出た3つの異論
//#table(columns: (auto, 1fr), stroke: 0.4pt + gray, inset: 8pt,
  //[*立場*], [*主張*],
  //[コアライブラリ開発], [library と application は別物．application は reference answer が無い],
  //[長く教育に携わる], [初学者に熟練者の流儀を押し付けるな],
  //[若手 / Julia 使い], [Julia の方が読める．notebook は compact],
//)
//#v(0.3em)
//いずれも「#hl[人間の理解が重要]」という点で正しい．だが結論は従来回帰ではない．



// ============================================================
= Supported by three pillars
// ============================================================

== Supporting a huge, feature-rich codebase with three pillars
tenferro-rs is #hl[about 130K lines], a feature-rich stack handling einsum · FFT · automatic differentiation (AD) · GPU.\
Line-by-line review is impossible, and the AI's design choices waver every time. #hl[Instead of a human standing guard, three pillars hold it up.]
#v(0.4em)
#align(center, block(width: 90%, {
  rect(width: 100%, radius: 6pt, inset: 11pt,
    fill: rgb("#1565c0").lighten(86%), stroke: rgb("#1565c0") + 1.5pt)[
    #align(center)[
      #text(weight: "bold", size: 1.15em, fill: rgb("#1565c0"))[tenferro-rs (~130K lines)]\
      #text(size: 0.82em, fill: luma(60))[einsum · FFT · automatic differentiation (AD) · GPU ...]
    ]
  ]
  v(0.5em)
  let pillar(t, s, c) = rect(width: 100%, height: 7em, radius: 5pt, inset: 8pt,
    fill: c.lighten(90%), stroke: c + 1.2pt)[
    #align(center + horizon)[
      #text(weight: "bold", size: 0.95em, fill: c)[#t]
      #v(0.25em)
      #text(size: 0.74em, fill: luma(70))[#s]
    ]
  ]
  grid(columns: (1fr, 1fr, 1fr), gutter: 0.8em,
    pillar([Pillar 1\ Unit / Integration test], [Parallel compile + parallel test\ fast feedback], rgb("#2e7d32")),
    pillar([Pillar 2\ Oracle / Benchmark], [External standards for correctness/performance\ the AI can't change them on its own], rgb("#eb811b")),
    pillar([Pillar 3\ Source of truth (Rules / Docs)], [AI and humans both follow it\ source of truth], rgb("#c62828")),
  )
}))

== Pillar 1: Unit / Integration test
A suite of automated tests that match inputs and outputs against expected values. Split into two levels by granularity:
#table(columns: (auto, 1fr), stroke: none, row-gutter: 0.45em, column-gutter: 0.9em,
  [#hl[Unit test]], [Verify a single function or module in fine detail (in Rust, `#[test]` within the same file)],
  [#hl[Integration test]], [Verify the behavior of combined modules/crates (in Rust, under `tests/`)],
)
#v(0.3em)
- Every time the code changes, run the full test suite and immediately detect what broke.
- #hl[Where Rust helps]: dependency crates *compile in parallel*, and tests *run in parallel by default*. The whole suite runs in a few minutes.
- → Even when the AI rewrites an implementation, you get green/red back instantly, a fast feedback loop.

== Pillar 2: Oracle and Benchmark (external standards)
- #hl[oracle] = an external standard for correctness: analytic solutions, reference implementations, invariants.
- #hl[benchmark] = an external standard for performance: measured reproducibly.
- #hl[Put them in a separate (external) repository] → the AI can't change them on its own.
#v(0.2em)
Example: #lk("https://github.com/tensor4all/tenferro-benchmark", "tenferro-benchmark") (performance) / #lk("https://github.com/tensor4all/tensor-ad-oracles", "tensor-ad-oracles") (numerical correctness of AD).

== Pillar 3: Why you need a source of truth
#grid(columns: (54%, 46%), gutter: 1em, align: (left + horizon, center + horizon),
  [
    - #hl[Source of truth] = the totality of rules, design, and worklog. AI and humans both follow it.
    - If it doesn't grow, you get #hl[AI slop]: failures stay as one-off fixes, and the same kind of problem recurs elsewhere.
    - #hl[Whack-a-mole (one-off fixes) can't keep up, and complexity keeps growing.]
    - The most underrated of the three pillars → let's see how to grow it.
  ],
  image("figures/fig_complexity_growth.svg", width: 100%),
)

== AI memory is not the source of truth
#figimg("figures/no-memory-comic.svg", w: 62%)
#ref-text[Project decisions should live in the repo's source of truth, not in an AI chat history or memory feature. Comic: #lk("https://www.jinguo-group.science/sustainable-automation/", "Jin-Guo Liu: Sustainable Automation")]

== Grow the source of truth from failures
Since October 2025, I stopped intervening case by case and shifted toward accumulating my judgments as the #hl[source of truth]. #hl[Generalize from failures and let it grow.]
#v(0.3em)
#grid(columns: (44%, 56%), gutter: 1.1em, align: (center + horizon, left + horizon),
  image("figures/fig_basic_loop_en.svg", width: 100%),
  [
    implement → fail → generalize → rule/oracle → the next constraint.
    #v(0.4em)
    #codebox(size: 0.72em)[
    tenferro-rs / REPOSITORY_RULES.md (excerpt) \
    - ... are first-class crates, not a broad "tenferro" facade. \
    - No naive CPU loop fallbacks. Use strided-kernel / faer / BLAS.
    ]
    #v(0.2em)
    #text(size: 0.85em)[These are #hl[rules born from failures] I experienced (built-in→separated, the pain of naive loops).]
  ],
)

== Accumulate the source of truth, and keep it
#table(columns: (auto, 1fr), stroke: none, row-gutter: 0.4em,
  [`AGENTS.md`], [Work conventions that AI and humans follow],
  [`REPOSITORY_RULES.md`], [Prohibitions · source of truth · performance contracts],
  [`docs/design/`, `worklogs/`], [Design philosophy to uphold · why a decision was made],
  [oracle / benchmark], [External standards for correctness · performance],
)
#v(0.3em)
- Have #hl[the agent itself continuously] check the source-of-truth↔code consistency (drift = correctness concern).
- Move the object of trust from "the AI's explanation" to #hl[rule / oracle / CI / provenance].
#v(0.2em)
$arrow.r$ Now, let's #hl[verify from the outside] whether the cultivated source of truth is actually working.

== Verify from the outside: have a third-party AI audit it
#codebox(size: 0.78em)[
*Ask AI*: Read the following 3 repos and investigate the techniques used for consistency and quality control in a huge codebase. \
#h(1em)· https://github.com/tensor4all/tenferro-rs \
#h(1em)· https://github.com/tensor4all/tenferro-benchmark \
#h(1em)· https://github.com/tensor4all/tensor-ad-oracles
]
#v(0.3em)
In my trial, ChatGPT Pro reconstructed the quality control just by reading the repos:
- #hl[Performance] = tenferro-benchmark / #hl[correctness of AD] = tensor-ad-oracles → it extracted #hl[Pillar 2 (external standards)].
- #hl[Structural consistency] = CI + repository rules + first-class crate split → it extracted #hl[Pillar 3 (source of truth)].
#v(0.2em)
#align(center, hl[If the source of truth is in place, even a third-party AI can read the design intent.])
#ref-text[The prompt is the code block above. The target repos are public GitHub repos readable from outside.]

== So what is the human's role?
#table(columns: (1fr, 1fr), stroke: 0.4pt + gray, inset: 8pt,
  [*Human*], [*AI agent*],
  [Holds a goal worth pursuing], [Writes code fast],
  [Holds the domain knowledge], [Handles implementation detail],
  [Designs new algorithms], [Translates the design into code],
  [#hl[Decides what to verify]], [Runs and fixes tests autonomously],
)
#v(0.3em)
- The human's job becomes mainly #hl[proposing, designing, and verifying the project].
- The coupling with the AI is through #hl[documents · tests].
#ref-text[Physicists are the side that can "define" conservation laws, symmetries, limiting cases, and analytic solutions.]

// ============================================================
= Education
// ============================================================

== Concerns from collaborators
The new workflow has its objections too (from tensor4all collaborators):
#table(columns: (auto, 1fr), stroke: 0.4pt + gray, inset: 8pt,
  [*① library ≠ application*], [Applications have no reference answer],
  [*② Mind the learning stage*], [Asking juniors to adopt a senior's workflow as-is is premature],
  [*③ Julia's readability*], [Small notebooks make it #hl[easy to check consistency with the math by eye]],
)

== My personal answers
#table(columns: (auto, 1fr), stroke: 0.4pt + gray, inset: 8pt,
  [*①*], [Even applications have things you can check: #hl[symmetries, limiting cases, conservation laws]. #hl[Finding them is what matters].],
  [*②*], [#hl[Separate by learning stage]: learn the basics by hand, and learn agentic engineering at the research level. Don't demand it uniformly.],
  [*③*], [Visual checks aren't always trustworthy. If you also #hl[have the AI generate pseudocode and reconcile it], Rust / C++ become clear too.],
)

The "industrial revolution" has already happened. We need to build a pipeline from practice into education. There's no need to cling to past styles.

// ============================================================
= Summary
// ============================================================

== Summary
+ #hl[Workflow]: brainstorm → plan → execute. Start from a #hl[math-backed design doc], not a prompt, and design the verification first.
+ #hl[Supported by three pillars]: unit / integration test ・ oracle / benchmark ・ source of truth (rules) maintain a huge codebase.
+ #hl[Education]: basics by hand, agentic engineering at the research level. Separate by learning stage.
#v(0.6em)
#align(center, text(size: 1.1em)[→ The human's job becomes mainly #hl[proposing, designing, and verifying the project].])

// ============================================================
= Hands-on: 2D Ising, verification-driven
// ============================================================

== Setup: the first things to tell the AI
- #hl[git] is mandatory: the basis for history, diffs, review, and CI. Start with `git init` + `.gitignore`.
- The language today is #hl[Rust]. Python / Julia are fine too (if you can build an oracle, the language isn't essential).
- For Rust, have it create #hl[the standard directory layout + test hierarchy]:
  - #hl[unit tests] in `#[cfg(test)]` within `src/` ・ #hl[integration tests] in `tests/`.
- And from the start: `AGENTS.md` / `CLAUDE.md` (conventions, commands, structure) ・ `README` ・ `cargo fmt` + `clippy` ・ #hl[seeded RNG (reproducibility)] ・ save results to files and keep plotting separate.

== Today's cycle and the two tasks
We apply the first half's #hl[superpowers workflow] to 2D Ising. The #hl[one cycle] we run for each task:
#table(columns: (auto, 1fr), stroke: none, row-gutter: 0.35em, column-gutter: 0.7em,
  [Step 1], [Have the AI do background research and write it up as a math-backed design doc (markdown/LaTeX)],
  [Step 2], [Discuss what to unit-test, and decide the oracle and verification plan],
  [Step 3], [Implement → have it emit the math / pseudocode / invariants and reconcile],
  [Step 4], [Verify with the oracle (compare against Onsager, the finite-time behavior of $chevron.l M chevron.r$)],
  [Step 5], [Write the lessons learned into the source of truth (rules)],
)
#v(0.3em)
- #hl[Task 1]: basic 2D Ising (Metropolis).
- #hl[Task 2]: algorithm extension (replica exchange) = a separate task. #hl[Start again from Step 1] and run the same cycle once.

== Problem and spec: 2D Ising
- A statistical-mechanics classic: it has an exact solution (Onsager), so #hl[the oracles are all there]. Being well-known, even a free model can implement it.
- $H = - J sum_(chevron.l i j chevron.r) s_i s_j$ (periodic boundary), Metropolis updates. Observables = energy / magnetization / specific heat / magnetic susceptibility.
#ref-text[Based on the Ising chapter of the existing material #lk("https://github.com/saitama-cond-mat/rust-computational-physics-tutorial", "rust-computational-physics-tutorial"). Exact solution: Onsager (1944).]

== Step 1: Have the AI research and write a design doc
Don't start writing from a prompt; first have the AI do a #hl[literature review] and write notes (markdown/LaTeX):
- #hl[Onsager exact solution]: $T_c = 2 \/ ln(1 + sqrt(2)) approx 2.269$ ($J = k_B = 1$), the exact magnetization curve and specific heat.
- #hl[Binder cumulant]: $U_L = 1 - chevron.l M^4 chevron.r \/ (3 chevron.l M^2 chevron.r^2)$. Curves for different $L$ cross at $T_c$.
#v(0.2em)
This math note becomes the core of an #hl[inspectable design doc].
#ref-text[Onsager, Phys. Rev. 65, 117 (1944) · Binder, Z. Phys. B 43, 119 (1981). Template: problem / formulation / assumptions / algorithm / pseudocode / invariants / reference / error metrics / test plan]

== Step 2: What to unit-test, and what to check with the oracle
MC involves randomness, so an "exact output match" test is hard. Discuss with the AI to separate out #hl[what can be checked deterministically]:
#table(columns: (1fr, 1fr), stroke: 0.4pt + gray, inset: 8pt,
  [*unit-testable (deterministic)*], [*checked via oracle (statistical)*],
  [periodic-boundary index computation], [expected values of $chevron.l E chevron.r$, $chevron.l M chevron.r$],
  [$Delta E$ of a single spin flip], [peaks of specific heat / susceptibility],
  [acceptance probability $min(1, e^(-beta Delta E))$], [agreement with Onsager],
  [detailed balance / reversibility], [Binder crossing],
)
#v(0.3em)
- For a #hl[small system (e.g. 2 spins)] you can enumerate all states exactly and sample for arbitrarily long times.\
  → even a statistical quantity becomes a #hl[quasi-deterministic test with failure probability $approx 0$].

== Step 3: Have it implement, then read it back and reconcile
- Implement in Rust from the design doc as the prompt.
- After implementing, have the AI emit the #hl[math / pseudocode / invariants] back, and match them against the design doc.
- What the human reads is #hl[not the code itself, but this "code ↔ algorithm/math" correspondence].
- That said, #hl[at first, also look at the code by eye] to check. For parts you don't understand, #hl[ask the AI].
#ref-text[💻 This part is demonstrated live.]

== Step 4: $chevron.l M chevron.r$ doesn't return to 0 in finite time
- First match against the Onsager exact solution ($T_c$, magnetization curve, specific-heat peak).
- Z2 symmetry ($s_i arrow.r -s_i$) strictly requires #hl[$chevron.l M chevron.r = 0$].
- But below $T_c$, single-spin-flip Metropolis can't flip the whole system, so it #hl[gets trapped in one magnetization sector] (an effective breaking of ergodicity). In a finite-time average, $chevron.l M chevron.r eq.not 0$.
#v(0.2em)
$arrow.r$ #hl[This isn't a bug, it's a limitation of the algorithm]. Neither the types nor the compiler detect it. What catches it is the oracle.

== Step 5: Write the lessons into the source of truth (finishing Task 1)
To #hl[hand off to the next session] what Task 1 taught us, add it to the rules and keep growing them:
- Below $T_c$, use $chevron.l |M| chevron.r$ for the order parameter ($chevron.l M chevron.r$ doesn't return to 0 in finite time).
- Boundaries of MC unit testing: only the deterministic parts; verify quasi-deterministically on a small system.
#v(0.2em)
$arrow.r$ Writing it into #hl[AGENTS.md / REPOSITORY_RULES.md] = one cycle of growing the source of truth.

// ============================================================
= Another round: extending the algorithm
// ============================================================

== Task 2: speed up the mixing
- As a #hl[separate task], run the same cycle once more (#hl[again from Step 1]).
- Problem: single-flip suffers #hl[critical slowing down] near $T_c$, and #hl[can't transition between sectors] below $T_c$.
- Extension ideas (have it research and design in Step 1):
  - #hl[replica exchange (parallel tempering)]: run several temperatures in parallel and swap neighbors. The high-temperature side crosses the barrier.
  - #hl[cluster algorithm (Wolff / Swendsen-Wang)]: flip a cluster of spins at once and avoid critical slowing down.
#ref-text[Replica exchange: Hukushima and Nemoto, J. Phys. Soc. Jpn. 65, 1604 (1996). Cluster algorithms: Swendsen and Wang, Phys. Rev. Lett. 58, 86 (1987) · Wolff, Phys. Rev. Lett. 62, 361 (1989).]

== Designing replica exchange: how to place the temperature points
- The set of temperatures ${T_i}$ is a design decision (Step 1):
  - Keep the #hl[acceptance rate between neighboring replicas constant (20〜40%)] → ensure overlap of the energy distributions.
  - In practice: #hl[start from geometric spacing] and adjust based on the acceptance rate.
- Implement → verify the #hl[improvement in $chevron.l M chevron.r$ / Binder] → write the lessons on temperature placement #hl[into the source of truth] too.
#ref-text[💻 Task 2 is demonstrated live.]

// ============================================================
= References
// ============================================================

== Acknowledgments
For #hl[fruitful discussions] while preparing this lecture:
#v(0.3em)
#lk("https://giggleliu.github.io/", "Jin-Guo Liu") · #lk("https://wangleiphy.github.io/", "Lei Wang") · #lk("https://terasakisatoshi.github.io/", "Satoshi Terasaki")

== References
#table(columns: (auto, 1fr), stroke: none, row-gutter: 0.6em, column-gutter: 0.9em,
  [#lk("https://qc-hybrid.github.io/CompPhysHack2026/", "CompPhysHack2026")],
  [The hackathon this lecture is built around (official site). See also the #lk("https://atelierarith.github.io/CompPhysHack2026HandsOn/", "Terasaki hands-on material")],

  [#lk("https://www.jinguo-group.science/sustainable-automation/", "Sustainable Automation")\ #text(size: 0.8em, fill: gray)[Jin-Guo Liu]],
  [Discusses how to make AI collaboration sustainable across sessions, weeks, and projects with #hl[CLAUDE.md (memory) + Skills (procedures) + subagents], using the 100K-line ceiling of a C compiler as an example],

  [#lk("https://github.com/obra/superpowers", "superpowers")],
  [A workflow that enforces brainstorm → plan → execute as Skills (used in today's hands-on)],

  [#lk("https://missing.csail.mit.edu/2026/agentic-coding/", "MIT missing-semester")],
  [Intro to agentic coding (the basics of CLI agents)],
)
