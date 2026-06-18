// ============================================================
// Agentic AI Coding × Rust  ── 本文 (compphyshack2026 スタイルで全面リスタイル)
// 主装置: 2カラム比較表 + 具体数字 + inline リンク．hl は文中強調．
// 図: figimg = 完成図 / ponchi = ポンチ絵プレースホルダ / codebox = 実物抜粋
// ============================================================

#import "@preview/touying:0.6.1": *
#import themes.metropolis: *
#import "slides_lib.typ": *

#let live = align(center + horizon, text(size: 1.05em, fill: rgb("#2563eb"))[💻 ライブ中心: スライドは最小限，手と画面共有が主])

#title-slide()

// ============================================================
= 事前準備
// ============================================================

== 事前準備 (各自, 当日までに)
+ #hl[CLI 型エージェントを1つ導入] してくる．
  - 無料: #lk("https://github.com/google-gemini/gemini-cli", "Gemini CLI") / ChatGPT Plus 以上: #lk("https://developers.openai.com/codex/cli", "Codex") / その他はご自由に．
  - 導入手順: #lk("https://atelierarith.github.io/CompPhysHack2026HandsOn/", "Satoshi Terasaki") / #lk("https://github.com/JunyaIto256/VSCode-Gemini-LaTeX", "Junya Ito")．
+ #hl[プログラミング言語の開発環境]を用意する．
  - 今回は #hl[Rust] を使うが何でもよい．Rust なら #lk("https://www.rust-lang.org/tools/install", "Cargo を install") (参考)．

== 今日の流れ
- 前半 = 方法論 / 後半 = 2D Ising ハンズオン．
- 当日は #hl[環境チェックのみ]: 方法論と実習に時間を使う．
- #hl[2D Ising は よく知られている] ので, 無料モデルでも完走できる (多分)．

// ============================================================
= 導入
// ============================================================

== 自己紹介と今日の立ち位置
   - 東大 PhD → スイス Postdoc → 埼玉大 PI (2015〜)
   - 量子多体計算 〜 第一原理計算まで幅広い経験
   - IR basis / sparse modeling / tensor networks
   - *C++ / Python / Julia / Fortran* の本格的な実経験
   - OSS と Community へ貢献
  #align(center + horizon, image("figures/fig_career_timeline_v2.png", width: 70%))
今は1行も書かないし，逐行も読まない．それでも #hl[手動コーディングより agentic coding の方が信頼できる] と感じる. なぜか？


== よく言われる批判: "AI slop"
巷では agentic coding の成果物を #hl["AI slop"] と呼ぶ声がある:

#v(0.3em)
#table(columns: (auto, 1fr), stroke: none, row-gutter: 0.7em, column-gutter: 0.9em, align: (left + top, left + top),
  [*職人性の喪失*\ #text(size: 0.78em)[Sinclair Target]],
  [#text(size: 0.85em, style: "italic")[“…would prefer not to use agentic tools #hl[even if they worked as advertised].”]\ #text(size: 0.78em, fill: gray)[宣伝通り動いても, 仕事への care を失う. #lk("https://sinclairtarget.com/blog/2026/06/01/quality-in-the-age-of-slop/", "Quality in the Age of Slop, 2026")]],

  [*保守の崩壊*\ #text(size: 0.78em)[D. Stenberg (curl)]],
  [#text(size: 0.85em, style: "italic")[“The current torrent of submissions put a high load on the curl security team…”]\ #text(size: 0.78em, fill: gray)[AI slop に埋もれ curl は bug bounty を終了 (2026). #lk("https://www.theregister.com/2026/01/21/curl_ends_bug_bounty/", "The Register")]],

  [*共有資源の劣化*\ #text(size: 0.78em)[Baltes et al.]],
  [#text(size: 0.85em, style: "italic")[“…a tragedy of the commons, where individual productivity gains #hl[externalize costs onto reviewers, maintainers, and the broader community].”]\ #text(size: 0.78em, fill: gray)[#lk("https://arxiv.org/abs/2603.27249", [“An Endless Stream of AI Slop”, arXiv:2603.27249])]],

  [*過大広告への反動*\ #text(size: 0.78em)[Anthropic C compiler]],
  [#text(size: 0.85em)[16 並列 Claude で C コンパイラ (100K 行, ~\$20k) を構築．別 benchmark では #hl[GCC -O0 より速いが GCC -O2 には届かない]．こうした showcase は評価軸がずれると #hl[AI 反対派を増やす]．]\ #text(size: 0.78em, fill: gray)[#lk("https://www.anthropic.com/engineering/building-c-compiler", "Anthropic") · #lk("https://dineshgdk.substack.com/p/benchmarking-claude-c-compiler", "benchmark")]],
)
#ref-text[ただし最適化不足は #hl[AI 不能の証拠ではなく], 性能 oracle と緊密な human-AI loop の不足として読むのが妥当である (後述)．]

== コーディングの産業革命: 手工業から工業へ
#v(0.8em)
#align(center, image("figures/fig_craft_vs_factory.svg", width: 78%))
#v(0.6em)
#pad(x: 4%, grid(columns: (1fr, 1fr), column-gutter: 1.5em, align: center,
  [#text(size: 0.9em)[人間が1点ずつ丁寧に]\ #text(fill: rgb("#1565c0"), weight: "bold")[\= 手作業コーディング]],
  [#text(size: 0.9em)[金型で大量生産 (高速・均質)]\ #text(fill: rgb("#1565c0"), weight: "bold")[\= 理想的な agentic coding]],
))
#v(0.6em)
#align(center)[同じ転換が，いま #hl[agentic coding] で起きている．]
#align(center)[#hl[理想的な agentic coding] をどう実現するか考える段階．]

== 今日の主張 (概要)
#align(center)[#block(width: 88%)[
  #set align(center)

  //1AI 生成コードを逐行では読まない
  //1#v(0.3em)
  //#sym.arrow.b
  //#v(0.3em)

  信頼の置き場所を #hl[目視] から #hl[機械的・外部検証] へ移した:

  Compiler · test · oracle · rules が，目視に代わって正しさを支える．

  //1#v(0.5em)
//1
  //1人間の仕事は #hl[何を検査し，何を「正本」として残すかを設計すること]．
]]
#v(0.5em)
#text(size: 0.88em)[
  通底する見方: AI の高速生成は工業的な大量生産．製品を1個ずつ直すのではなく，#hl[金型 (= 正本: rules · oracle)] を直す.\
  //体験談 → 判断軸 (検証可能性) → 正本を育てる → ハンズオン の順に詳しく展開する．
]

// ============================================================
= コーディングエージェントの基礎
// ============================================================

== Chat 型 vs CLI 型エージェント
#table(columns: (1fr, 1fr), stroke: 0.4pt + gray, inset: 8pt,
  [*Chat 型 (ブラウザ対話)*], [*CLI 型 (ターミナル)*],
  [質問して答えをコピペ], [ファイルを直接編集・実行],
  [ローカル環境に触れない], [リポジトリ・git を操作],
  [1往復ずつ人が運ぶ], [#hl[マルチステップを自律実行]],
)
#v(0.3em)
CLI 型は #hl[長時間の自律実行を狙う設計]．今日の主役はこちら．
#ref-text[世代で言えば Gen1 (Cursor / Copilot) → Gen2 (Claude Code / Codex / ...)．#lk("https://missing.csail.mit.edu/2026/agentic-coding/", "MIT missing-semester: agentic coding")]

== 代表的な CLI エージェント (ハーネス)
#table(columns: (auto, 1fr), stroke: none, row-gutter: 0.45em,
  [#lk("https://code.claude.com/docs/en/overview", "Claude Code")], [Anthropic. ターミナル/IDE で自律コーディング],
  [#lk("https://developers.openai.com/codex/cli", "Codex CLI")], [OpenAI. Rust 製 OSS, ChatGPT プランに同梱],
  [#lk("https://github.com/google-gemini/gemini-cli", "Gemini CLI")], [Google. OSS, 無料枠あり],
  [#lk("https://www.kimi.com/code", "Kimi CLI")], [Moonshot (中国系). モデル K2.7 Code],
  [#lk("https://opencode.ai/", "OpenCode")], [OSS, プロバイダ非依存],
  [#lk("https://github.com/earendil-works/pi/tree/main/packages/coding-agent", "Pi")], [最小構成の OSS. 拡張・skill を自分で足して育てる (最小主義者向け)],
)

== ハーネス ≠ モデル
- #hl[ハーネス] = CLI ツール (ファイル編集・コマンド実行・ツール呼び出しの枠組み)．
- #hl[モデル] = 裏で動く LLM．多くのハーネスは #hl[モデルを差し替え可能]．
  - 中立: OpenCode / Gemini CLI ・ 自社統合寄り: Claude Code / Codex．
- 性能は #hl[モデル], 操作性・自律度は #hl[ハーネス] で決まる．両方を選ぶ．

== サブスク vs API, 廉価モデル
#table(columns: (auto, 1fr), stroke: 0.4pt + gray, inset: 8pt,
  [*サブスク*], [Claude Pro \$20/月 (Claude Code 込) / ChatGPT + Codex．月額固定 + 利用枠],
  [*API 従量*], [使ったトークン分課金．ハーネスに任意モデルを接続],
)
#v(0.3em)
廉価なコーディング向け API (2026): #lk("https://api-docs.deepseek.com/quick_start/pricing", "DeepSeek V4 Flash") (入力 ~\$0.14 / 出力 ~\$0.28 per 1M) ・ #lk("https://platform.kimi.ai/docs/pricing/chat-k27-code", "Kimi K2.7 Code")．
例: #hl[OpenCode + 廉価 API] で低コストに始められる．
#ref-text[料金・モデル名は 2026年6月時点．世代更新が速い．]

== スキルとは
- #hl[Skill] = エージェントの #hl[手順書] (markdown)．抽象的な作業を明示的な小ステップに分解する．
- プログラムの関数に近いが, 操作対象は #hl[データでなくエージェントの振る舞い]．
- 関連する作業で #hl[自動的に発火] し, skill が skill を呼んで複雑な手順を構成する．
- #hl[CLAUDE.md / AGENTS.md] = セッションを越える記憶 (規範・コマンド・構成)．
#ref-text[#lk("https://www.jinguo-group.science/sustainable-automation/", "Jin-Guo Liu: Sustainable Automation") · #lk("https://github.com/obra/superpowers", "obra/superpowers")]

== 実際のワークフローはこんな感じ
superpowers の Skill が #hl[brainstorm → plan → execute] を強制する (各段階は自動発火):
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
- 出発点は prompt でなく #hl[数式つき設計書]．検証 (oracle / test) も同時に設計する．
- 実装後は #hl[コード ↔ アルゴリズム・数式] の対応を AI に出させて照合 (コードそのものは読まないこともある)．
- Execute は TDD + サブエージェント分割, Review で問題が出れば前段階へ戻る．
#ref-text[#lk("https://github.com/obra/superpowers", "obra/superpowers") · #lk("https://www.jinguo-group.science/sustainable-automation/", "Jin-Guo Liu: Sustainable Automation")]

// ============================================================
= この1年 ── agentic coding の限界を試す
// ============================================================



//#v(0.3em)
//私もこの1年，これらを *実際に* 大量に踏んだ．→ #hl[結論と対処は次スライド以降]．
//#ref-text[AI slop の正確な定義は後半「正本を育てる」で扱う．]

== これまでの経緯
#text(size: 0.95em, style: "italic")[2025年10月以降，#hl[私はコードを一行も書いていない]．生成コードも逐行では読まない．]

#v(0.4em)

#table(columns: (auto, 1fr), stroke: none, row-gutter: 0.4em,
  [*2025年1月*], [Cursor を開始，依然としてソースコードを見る世代],
  [*2025年10月*], [#lk("https://github.com/SpM-lab/SparseIR.jl", "SparseIR.jl") を Julia → Rust へ移植開始],
  [*2025年12月*], [Claude Code へ移行: #hl[生成コードを逐行で読むのをやめた]],
  [*2026年1月*], [tensor4all-rs開発開始: Julia TN eco の Rust port],
  [*2026年2月*], [tenferro-rs開発開始: Rust 製の PyTorch 的 tensor stack],
  [*2026年3月〜*], [現在は Codexメイン],
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

== 作ったもの: tensor4all-rs
Julia の tensor learning stack を Rust に移植．

#v(0.3em)

#text(size: 0.85em)[
  #lk("https://github.com/tensor4all/TensorCrossInterpolation.jl", "TensorCrossInterpolation.jl") / #lk("https://github.com/tensor4all/QuanticsTCI.jl", "QuanticsTCI.jl")など / #lk("https://scipost.org/SciPostPhys.18.3.104", "SciPost Phys. 18, 104 (2025)") / #lk("https://tensor4all.org", "tensor4all")
]

- 2026年1月1日開始 (元々はagentic codingの「限界」を試す冬休みの自由研究)
- 人間数名 + AI (Claude CodeからCodexメインへ)
- 2ヶ月で 353 commits · 最初の2週間で +61,486 行 (151  files)

$arrow.r$ 共同研究者間の議論 (AI slop, 教育法，Juliaは不要か？)は，まだ続いている．

#v(0.5em)

#text(size: 1.0em)[#hl["多数の試行錯誤と失敗から，正しいagentic coding 法が見え始めたところ"]]

設計，テスト・検証，適した言語，(教育法)...

== 意図的実験: agentic coding を限界まで押す

#text(size: 1.0em)[#hl["失敗を観測し，制御する方法を模索する．"]]

//正しい抽象を探すため，新しい tensor stack (tenferro-rs) を一から作り始めた．\
//そこで agentic coding を #hl[限界まで押し], 何が壊れるかを観測する実験にした．\
//「失敗」ではなく，限界を測る実験である．
//
//#ponchi(h: 44%)[agentic coding のダイヤルを限界まで回す様子 (速度↑ → 何が壊れるか)]
//
//== 最初はモノリシック
//#figimg("figures/fig_monolithic.svg", w: 60%)
元々のJuliaエコシステムは，Quantics Tensor Train (QTT)/Tensor Cross Interpolation (TCI)をカバーする巨大なもの．一部は，ITensors.jlに依存．

#v(2em)

最初は「モノシリック構造」から始めた: ITensors.jlの必要部分 (Index system, tensor contraction)の移植 + QTT/TCI

//- 抽象化・階層化が壊れる．巨大なコード (数十万行) のデザインをどう統一する？
//- 正しさをどう検証するか？
//- パフォーマンス最適化 (AIが多重ループを書く，無駄なメモリ確保をする...)
//
//思いがけない良い発見: RustはAIと相性がよく大規模開発が楽

== 失敗例

#text(size: 1.0em)[#hl[(予想通り) 多数の問題が発生]]

- 抽象化を壊す: 低階層の機能を高階層でimportして使ってしまう (その場しのぎ)
- ユニットテストのしきい値を勝手に緩める (バグを直すのを諦める)
- BLASを使わずにnested loopsを書く (結果は正しいが...)
- 1つのソースファイルの行数が数千行超え
- ...

//最先端のAIは良くなってきているが，エラーは付きもの (人間も同じ)．
//1個ずつ目で見て修正するのは不可能．
//$arrow.r$
//ルール，設計などでAIの行動を制約し，ソースコードを機械的に監査する仕組みが必要
//$arrow.r$ 目によるレビューから脱却

== 複雑さが増え続ける
#grid(columns: (30%, 70%), gutter: 1em,
  [
    - 個別修正では追いつかない．
    - 長期保守には，思想とデザインルールを *統一的に育てる* しかない．
    - #hl[さもないと複雑さが増え続ける．]
  ],
  align(center + horizon, image("figures/fig_complexity_growth.svg", width: 100%)),
)


== 修正するのは「コード」ではなく「ルール」

*参考*
- Heinrich pyramid: 1件の重大事故の背後に多数の軽微事故・near miss がある, という安全工学の経験則．
- 航空事故調査: ICAO Annex 13 は, 調査目的を blame ではなく再発防止と定める．
#ref-text[#lk("https://skybrary.aero/articles/heinrich-pyramid", "SKYbrary: Heinrich Pyramid") · #lk("https://www.icao.int/sites/default/files/postalhistory/annex_13_aircraft_accident_and_incident_investigation.htm", "ICAO Annex 13") · #lk("https://asrs.arc.nasa.gov/", "NASA ASRS")]

*Agentic codingにおける(私の)対処法*
- 「ルール」や「制度」を作ることで，AIの行動を矯正
- 機械的に監査し，コードを一括修正する仕組みを構築

(このような仕組みは手動コーディングでも元々重要)

$arrow.r$ #hl[AIの圧倒的に高速なコード生成と品質管理を両立]

== モノリシック → 分離構造 (構造による強制)

巨大な tensor4all-rs を，役割の異なる独立した層に分割する．

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
  #layer("Tensor4all.jl", "人間向けインターフェース (Julia, ITensors 互換)", rgb("#C73E1D"), "https://github.com/tensor4all/Tensor4all.jl")
  #v(0.28em)
  #layer("tensor4all-rs", "テンソルネットワーク: TreeTN / QTT / TCI", rgb("#1565c0"), "https://github.com/tensor4all/tensor4all-rs")
  #v(0.28em)
  #layer("tenferro-rs", "汎用テンソル計算 + 自動微分 + GPU (PyTorch/JAX 的)", rgb("#1565c0"), "https://github.com/tensor4all/tenferro-rs")
  #v(0.28em)
  #layer("tidu-rs", "汎用自動微分エンジン", rgb("#1565c0"), "https://github.com/tensor4all/tidu-rs")
]

#v(0.3em)
人間が AI と議論しながら分割構造を設計する．#hl[一旦分割すれば，AI は各層の中でしか動けず，階層構造を壊せない．]
#ref-text[層と API 境界は，AI とともに PyTorch / JAX のデザイン (成功・失敗例) を詳しく分析して決めた．]

== 各階層のモジュール化

tenferroの内部もモジュール化されている．
#figimg("figures/fig_crate_split.svg", w: 60%)
//#ref-text[0e3ffa76 (2026-05-26) Refactor crate boundaries without root facade (\#900)]
Rust では シンボルの公開性をモジュール階層に沿って細かく制御可能．
AIエージェントが勝手にprivateなシンボルを外からimportできない．

// 規模の壁 + ChatGPT解答 (三層構造) は後半「正本を育てる」の三本柱へ移動した．

// ============================================================
= 可読性より，検証可能性
// ============================================================

#text(size: 0.6em)[
以下の議論は「巨大なコード」の開発を前提とする．
]


== 言語選択の理由が逆転: 私の発言の変遷

=== 2023年3月 (那覇， 計算物理春の学校2023前夜祭)
最近は Jupyter Notebook でプロトタイプを作ることが多く, 数式とコードが似ていてレビューしやすく, メモリ管理を良きようにやってくれる Julia が楽である．Rust も興味はあるが, 一般の学生が覚えるには敷居が高く, 数値計算ライブラリもまだ揃っていない．

=== 2026年
最近はプロトタイピングに Jupyter Notebook は使わず, メモリ管理が厳格で明示的な Rust の方が agentic coding には効率的である．エージェントがコードを書くので, 学習曲線の急峻さも問題ない．数式との整合も AI の助けがあればコードが少々長くても問題ない．
足りない数値ライブラリは Rust に移植できる．

#align(center, hl[可読性よりは検証性])


== 手動コーディング時代: 各言語の "嬉しさ"
#table(columns: (auto, 1fr), stroke: 0.4pt + gray, inset: 8pt,
  [*Fortran*], [配列が言語ネイティブ · 手書きループでも速い · LAPACK / BLAS が目の前],
  [*Python*], [対話的に試せる (REPL / notebook) · numpy / scipy / matplotlib · 可視化が即座],
  [*Julia*], [数式に近い記法 (broadcast / Unicode) · JIT で速い · prototype が production に近い],
)
#v(0.3em)
共通点: すべて #hl[人間が手で書いて・読んで・保守する] コストを下げる工夫．

//== エージェントコーディング時代にRustが心地いいと感じる理由
//
//- 優秀なパッケージシステムとビルドシステム (Cargo)
//- 厳格なメモリ・所有権の管理 (aliasing起因の自明なバグ排除)
//- 比較的高速なコンパイル (型の整合性チェックは軽量，並列コンパイル化)
//
//(Juliaで基盤ライブラリを書くと，長大なテスト時間，型不安定性に悩まされる...)

== 言語を選ぶ基準が変わる: 大規模開発
これまで重要だった指標は，すべて *人間が書いて保守する* 前提だった:

#table(columns: (1fr, 1fr), stroke: 0.4pt + gray, inset: 8pt,
  [*従来の指標*], [*Agentic 時代*],
  [可読性: 一行ずつ追える], [#hl[検証可能性]: oracle で検査],
  [学習曲線の緩やかさ], [急峻さは *AI が肩代わり*],
  [数式への近さ: 目で確認], [機械チェックを併用],
  [書く速度], [もはや bottleneck ではない],
)
#v(0.3em)
#align(center, text(size: 1.0em)[#hl[読みやすさ] より #hl[検査しやすさ]．])

== Readable source ≠ Inspectable implementation
*読みやすい* ことと *検査しやすい* ことは別物である．

例: 数式に近く *見える* Julia の broadcast 代入も，挙動は見た目で確定しない:
#v(0.25em)
#block(fill: luma(244), inset: 9pt, radius: 6pt, width: 100%,
  text(size: 0.85em, raw(
    "b = a          # b と a は同じ配列を指す (別名)\na .+= c        # in-place 更新なら b も変わる ← 副作用",
    lang: "julia", block: true)))
#v(0.25em)
#hl[aliasing / mutation / allocation は行単位の見た目からは見えない．]

#align(center, text(size: 1.0em)[ここまでは言語に依らない一般論．#hl[ではどの言語が検証可能性に向くか]．])

== Rust とは (この聴衆向けに最小限)
- #hl[Mozilla] 発のシステム言語．Firefox の実装のために開発され，2015 に安定版 (1.0)．
- 信頼性が評価され #hl[Linux カーネル] に正式採用 (v6.1〜, C に次ぐ第2言語)．
- #hl[所有権 (ownership)]: GC 無しでメモリ安全．データ競合・dangling を *コンパイル時に* 排除．
- #hl[Cargo]: ビルド・依存解決・テスト・ベンチが標準で一体．
#v(0.3em)
物理屋向けの一言: #hl[「C++ の安全版 + 一流のビルド/依存管理」]．\
速度は C / C++ 級，安全性は GC 言語級．

== エコシステムの加速的成長
#v(-0.3em)
#align(center, image("figures/fig_crate_growth.svg", width: 72%))
///#v(-0.2em)
///#align(center, text(size: 0.95em)[crates.io: #hl[602 (2015) → 21 万 (2026)]，新規 #hl[5.4 万/年] (2025)．2023 年の「数値計算ライブラリが揃わない」は覆った．])
///#ref-text[図: #lk("https://github.com/shinaoka/rust_crate_count", "shinaoka/rust_crate_count") (crates.io DB dump)]

== Why Rust? AI との fast feedback loop
Python / Julia は *速く書く* ために設計された．AI 時代にこの利点は *反転* する:

#table(columns: (1fr, 1fr), stroke: 0.4pt + gray, inset: 8pt,
  [*Python / Julia*], [*Rust + AI*],
  [手で書くのが速い], [AI が書く: 速度は同じ],
  [エラーは実行時に判明], [#hl[コンパイル時に捕捉]],
  [検証には実行が必要], [`cargo check` 数秒],
  [AI のミス発見が遅い], [AI のミスを *即座に* 発見],
)

#text(size: 1em)[#super[\*]巨大なコードが前提である.]

#ref-text[#lk("https://zenn.dev/h_shinaoka/articles/a099b814166ac7", "Zenn: Why I Migrated from C++ to Rust")]

== 個人的な体験
- #hl[tenferro-rs + 外部依存ライブラリのスクラッチビルド ~2分 (Macbook Pro)]\ edit→test は数十秒で完了, cargo check は瞬時．
//- 比較: Julia は全テスト >10分，CI の大半が precompile に消える
- AI が ownership / lifetime の *機械的複雑さ* を処理\ → 人間は #hl[アルゴリズム・設計・正しさ] の検証に集中できる．
- cargo が pure Rust 依存を解決．CMake 不要. \ link 時のバージョン衝突なし
//- 複素 SVD の AD など繊細な rule を *一度だけ正しく* 実装して共有

個人的には，Julia/C++/Pythonで感じていた「コードが大規模化してきたら，検証が難しくなる」という不安がなくなった．

#ref-text[#lk("https://github.com/tensor4all/tensor4all-meta/blob/main/docs/why_rusty_julia.md", "tensor4all-meta/docs/why_rusty_julia.md")]

== 学習曲線: 急な序盤を AI が肩代わりする
#figimg("figures/fig_learning_curve.svg", w: 70%)
//#align(center, text[Rustの美味しいところだけが残る．])
#align(center, hl[Rustの美味しいところだけが残る．])
#align(center, text[研究室の学生も Julia から Rust へ移行中．])
//#ref-text[模式図. Rust は序盤が急 = 従来は不利．だがその急勾配を AI が肩代わりするため，評価が反転する．]

== Workflow in agentic coding era: 言語は混在してよい
- 以前: Jupyter Notebook で対話的に試した．
- 今: #hl[AIに自然言語で指令] \
  #hl[コード生成 → 計算 → 結果をファイルに保存 → プロット]
- Prototyping のために Jupyter Notebook は #hl[必須ではない]．
- #hl[全計算を単一の言語でやる必要はない]．既存資産を活かしつつ，#hl[段階的に Rust へ移行] できる．

//== ただし Rust も物理バグは止めない
//- 型・compiler は #hl[符号・prefactor・frequency convention・物理モデル] の誤りを止めない．
//- Rust は品質保証の全体ではなく，検証可能性を高める *基盤*．
//- 向き不向きの本質は #hl[oracle があるか] (library vs application)．

== 小結
#align(center + horizon)[#text(size: 1.15em)[
  選ぶ基準は #hl[認知コスト最小化] から #hl[検証可能性最大化] へ移った．
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
= 3本柱で支える
// ============================================================

== 巨大・高機能なコードを3本柱で支える
tenferro-rs は #hl[約13万行]，einsum · FFT · 自動微分 (AD) · GPU まで担う高機能スタック．\
逐行レビューは不可能で，AI の設計選択も毎回ぶれる．#hl[人間が見張る代わりに，3本柱で支える．]
#v(0.4em)
#align(center, block(width: 90%, {
  rect(width: 100%, radius: 6pt, inset: 11pt,
    fill: rgb("#1565c0").lighten(86%), stroke: rgb("#1565c0") + 1.5pt)[
    #align(center)[
      #text(weight: "bold", size: 1.15em, fill: rgb("#1565c0"))[tenferro-rs (約13万行)]\
      #text(size: 0.82em, fill: luma(60))[einsum · FFT · 自動微分 (AD) · GPU ...]
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
    pillar([柱1\ Unit / Integration test], [並列コンパイル + 並列テスト\ 高速な fast feedback], rgb("#2e7d32")),
    pillar([柱2\ Oracle / Benchmark], [正しさ・性能の外部基準\ AI が勝手に変えられない], rgb("#eb811b")),
    pillar([柱3\ 正本 (Rules / Docs)], [AI と人間が従う\ source of truth], rgb("#c62828")),
  )
}))

== 柱1: Unit / Integration test
入出力を期待値と突き合わせる自動テスト群．粒度で2階層に分ける:
#table(columns: (auto, 1fr), stroke: none, row-gutter: 0.45em, column-gutter: 0.9em,
  [#hl[Unit test]], [関数・モジュール単体を細かく検証 (Rust では同ファイル内の `#[test]`)],
  [#hl[Integration test]], [複数モジュール・crate を結合した挙動を検証 (Rust では `tests/` 配下)],
)
#v(0.3em)
- コードを変えるたびに全テストを回し，壊れた箇所を即座に検出する．
- #hl[Rust が効く点]: 依存 crate を *並列コンパイル*，テストも *デフォルトで並列実行*．数分で全テストが回る．
- → AI が実装を書き換えても，緑/赤が即座に返る fast feedback loop．

== 柱2: Oracle と Benchmark (外部基準)
- #hl[oracle] = 正しさの外部基準: 解析解・reference 実装・不変量 (invariants)．
- #hl[benchmark] = 性能の外部基準: 再現可能に測る．
- #hl[別リポジトリ (外部) に置く] → AI が勝手に変えられない．
#v(0.2em)
例: #lk("https://github.com/tensor4all/tenferro-benchmark", "tenferro-benchmark") (性能) / #lk("https://github.com/tensor4all/tensor-ad-oracles", "tensor-ad-oracles") (AD の数値的正しさ)．

== 柱3: 正本 (source of truth) はなぜ要るか
#grid(columns: (54%, 46%), gutter: 1em, align: (left + horizon, center + horizon),
  [
    - #hl[正本] = rules・design・worklog の総体．AI と人間が共に従う source of truth．
    - 育たないと #hl[AI slop]: 失敗が個別修正に留まり，同型の問題が別の場所で再発する．
    - #hl[モグラ叩き (個別修正) では追いつかず，複雑さが増え続ける．]
    - 3本柱で最も過小評価 → どう育てるかを見る．
  ],
  image("figures/fig_complexity_growth.svg", width: 100%),
)

== AI の記憶は正本ではない
#figimg("figures/no-memory-comic.svg", w: 62%)
#ref-text[プロジェクトの判断は AI の会話履歴や memory ではなく, repo 内の正本に残す．漫画: #lk("https://www.jinguo-group.science/sustainable-automation/", "Jin-Guo Liu: Sustainable Automation")]

== 正本は失敗から育てる
2025年10月以降，逐一の介入をやめ，判断を #hl[正本] として蓄積する方へ移した．#hl[失敗を一般化して育てる]．
#v(0.3em)
#grid(columns: (44%, 56%), gutter: 1.1em, align: (center + horizon, left + horizon),
  image("figures/fig_basic_loop.svg", width: 100%),
  [
    実装 → 失敗 → 一般化 → rule/oracle → 次の制約．
    #v(0.4em)
    #codebox(size: 0.72em)[
    tenferro-rs / REPOSITORY_RULES.md (抜粋) \
    - ... are first-class crates, not a broad "tenferro" facade. \
    - No naive CPU loop fallbacks. Use strided-kernel / faer / BLAS.
    ]
    #v(0.2em)
    #text(size: 0.85em)[これは私が経験した #hl[失敗から生まれたルール] (内蔵→分離，naive loop の痛み)．]
  ],
)

== 正本を溜めて, 保つ
#table(columns: (auto, 1fr), stroke: none, row-gutter: 0.4em,
  [`AGENTS.md`], [AI と人間が従う作業規範],
  [`REPOSITORY_RULES.md`], [禁止事項 · source of truth · 性能契約],
  [`docs/design/`, `worklogs/`], [守る設計思想 · なぜその判断をしたか],
  [oracle / benchmark], [正しさ · 性能の外部基準],
)
#v(0.3em)
- 正本↔コードの整合性検査は #hl[エージェント自身に継続的に] やらせる (drift = correctness concern)．
- 信頼の対象を「AI の説明」から #hl[rule / oracle / CI / provenance] へ移す．
#v(0.2em)
$arrow.r$ では，育てた正本が本当に効いているかを #hl[外から確かめる]．

== 外から確かめる: 第三者 AI に監査させる
#codebox(size: 0.78em)[
*Ask AI*: 次の3つの repo を読み，巨大コードベースの一貫性・品質管理の工夫を調べて． \
#h(1em)· https://github.com/tensor4all/tenferro-rs \
#h(1em)· https://github.com/tensor4all/tenferro-benchmark \
#h(1em)· https://github.com/tensor4all/tensor-ad-oracles
]
#v(0.3em)
私の試行では, ChatGPT Pro は repo を読むだけで品質管理を再構成した:
- #hl[性能] = tenferro-benchmark / #hl[AD の正しさ] = tensor-ad-oracles → #hl[柱2 (外部基準)] を抽出した．
- #hl[構造の一貫性] = CI + repository rules + first-class crate 分割 → #hl[柱3 (正本)] を抽出した．
#v(0.2em)
#align(center, hl[正本が揃っていれば，第三者 AI でも設計意図を読み取れる．])
#ref-text[再現用 prompt は上の code block．対象 repo は public GitHub repo として外部から読める．]

== では人間の役割は何か
#table(columns: (1fr, 1fr), stroke: 0.4pt + gray, inset: 8pt,
  [*人間*], [*AI エージェント*],
  [追う価値のある目標を持つ], [速くコードを書く],
  [ドメイン知識を持つ], [実装の詳細を処理],
  [新しいアルゴリズムを設計], [設計をコードに翻訳],
  [#hl[何を検証するか決める]], [テストを自律的に実行・修正],
)
#v(0.3em)
- 人間は #hl[プロジェクトの提案・設計・検証] が主になる．
- AI との結合は #hl[documents · tests] を介して．
#ref-text[物理屋は保存則・対称性・極限・解析解を「定義できる」側．]

// ============================================================
= 教育
// ============================================================

== 共同研究者からの懸念
新しい workflow には反論もある (tensor4all 共同研究者):
#table(columns: (auto, 1fr), stroke: 0.4pt + gray, inset: 8pt,
  [*① library ≠ application*], [application は reference answer が無い],
  [*② 学習段階への配慮*], [junior に senior の workflow をそのまま求めるのは早い],
  [*③ Julia の読みやすさ*], [小さな notebook は #hl[数式との整合性を目で確認しやすい]],
)

== 個人的な回答
#table(columns: (auto, 1fr), stroke: 0.4pt + gray, inset: 8pt,
  [*①*], [application でも #hl[対称性・極限・保存則] などチェックできる対象はある．#hl[それを探すことが重要]．],
  [*②*], [#hl[学習段階で分ける]: 基礎は手書きで学び, 研究レベルで agentic engineering を学ぶ．一律に求めない．],
  [*③*], [目視チェックが信頼できるとは限らない．#hl[AI に擬似コードを生成させて照合] を併用すれば, Rust / C++ でも分かりやすい．],
)

もう既に「産業革命」は起きている．実践から教育のパイプラインを構築する必要がある．過去のスタイルにこだわる必要はない．

// ============================================================
= まとめ
// ============================================================

== まとめ
+ #hl[ワークフロー]: brainstorm → plan → execute．prompt でなく #hl[数式つき設計書] から始め, 検証を先に設計する．
+ #hl[3本柱で支える]: unit / integration test ・ oracle / benchmark ・ 正本 (rules) で巨大コードを維持する．
+ #hl[教育]: 基礎は手書き, 研究レベルで agentic engineering．学習段階で分ける．
#v(0.6em)
#align(center, text(size: 1.1em)[→ 人間の仕事は #hl[プロジェクトの提案・設計・検証] が主になる．])

// ============================================================
= ハンズオン: 2D Ising を検証駆動で
// ============================================================

== セットアップ: 最初に AI に指示すること
- #hl[git] は必須: 履歴・差分・レビュー・CI の前提．`git init` + `.gitignore` から始める．
- 言語は今日は #hl[Rust]．Python / Julia でもよい (oracle が組めれば言語は本質でない)．
- Rust なら #hl[標準ディレクトリ構成 + テスト階層] を作らせる:
  - `src/` 内の `#[cfg(test)]` に #hl[unit test] ・ `tests/` に #hl[integration test]．
- 併せて最初から: `AGENTS.md` / `CLAUDE.md` (規範・コマンド・構成) ・ `README` ・ `cargo fmt` + `clippy` ・ #hl[seeded RNG (再現性)] ・ 結果はファイル保存しプロットは分離．

== 今日のサイクルと2つのタスク
前半の #hl[superpowers ワークフロー] を 2D Ising に適用する．各タスクで回す #hl[1周のサイクル]:
#table(columns: (auto, 1fr), stroke: none, row-gutter: 0.35em, column-gutter: 0.7em,
  [Step 1], [AI に下調べさせ, 数式つき設計書 (markdown/LaTeX) にまとめさせる],
  [Step 2], [何を unit test するか議論し, oracle と検証計画を決める],
  [Step 3], [実装 → 数式・擬似コード・invariant を出させて照合],
  [Step 4], [oracle で検証 (Onsager と比較, $chevron.l M chevron.r$ の有限時間挙動)],
  [Step 5], [得た知見を正本 (rules) に書き残す],
)
#v(0.3em)
- #hl[Task 1]: 基本の 2D Ising (Metropolis)．
- #hl[Task 2]: アルゴリズム拡張 (レプリカ交換) = 別タスク．#hl[また Step 1 から] 同じサイクルを1周．

== 題材と仕様: 2D Ising
- 統計力学の定番: 厳密解 (Onsager) があり #hl[oracle が揃う]．well-known で無料モデルでも実装できる．
- $H = - J sum_(chevron.l i j chevron.r) s_i s_j$ (周期境界), Metropolis 更新．観測量 = energy / magnetization / 比熱 / 帯磁率．
#ref-text[既存教材 #lk("https://github.com/saitama-cond-mat/rust-computational-physics-tutorial", "rust-computational-physics-tutorial") の Ising 章が下敷き．厳密解は Onsager (1944)．]

== Step 1: AI に下調べさせ, 設計書に
prompt から書き始めず, まず AI に #hl[文献調査] させてノート (markdown/LaTeX) にまとめさせる:
- #hl[Onsager 厳密解]: $T_c = 2 \/ ln(1 + sqrt(2)) approx 2.269$ ($J = k_B = 1$), 厳密磁化曲線・比熱．
- #hl[Binder cumulant]: $U_L = 1 - chevron.l M^4 chevron.r \/ (3 chevron.l M^2 chevron.r^2)$．異なる $L$ の曲線が $T_c$ で交差する．
#v(0.2em)
この数式ノートが #hl[inspectable な設計書] の核になる．
#ref-text[Onsager, Phys. Rev. 65, 117 (1944) · Binder, Z. Phys. B 43, 119 (1981)．テンプレ: 問題 / 定式化 / 仮定 / algorithm / 擬似コード / invariants / reference / error metrics / test plan]

== Step 2: 何を unit test し, 何を oracle で見るか
MC は乱数を含むので「出力一致」テストは難しい．#hl[何が決定的に検査できるか] を AI と議論して切り分ける:
#table(columns: (1fr, 1fr), stroke: 0.4pt + gray, inset: 8pt,
  [*unit-test できる (決定的)*], [*oracle で見る (統計的)*],
  [周期境界の index 計算], [$chevron.l E chevron.r$, $chevron.l M chevron.r$ の期待値],
  [1スピン反転の $Delta E$], [比熱・帯磁率のピーク],
  [受容確率 $min(1, e^(-beta Delta E))$], [Onsager との一致],
  [detailed balance / 可逆性], [Binder の交差],
)
#v(0.3em)
- #hl[小さな系 (例: 2スピン)] は全状態を厳密に数え上げられ, 超長時間もサンプルできる．\
  → 統計量でも #hl[失敗確率 $approx 0$ の準決定的テスト] になる．

== Step 3: 実装させ, 逆変換して照合
- 設計書をプロンプトに Rust 実装させる．
- 実装後, AI に #hl[数式・擬似コード・invariant] を逆に出力させ, 設計書と突き合わせる．
- 人間が読むのは #hl[コードそのものではなく, この「コード ↔ アルゴリズム・数式」の対応]．
- ただし #hl[最初はコードも目で見て] 確認する．わからない部分は #hl[AI に質問する]．
#ref-text[💻 ここはライブで実演する．]

== Step 4: $chevron.l M chevron.r$ は有限時間で 0 に戻らない
- まず Onsager 厳密解 ($T_c$・磁化曲線・比熱ピーク) と突き合わせる．
- Z2 対称性 ($s_i arrow.r -s_i$) は厳密には #hl[$chevron.l M chevron.r = 0$] を要求する．
- だが $T_c$ 以下では single-spin-flip Metropolis は系全体を反転できず, #hl[片方の磁化セクターに捕まる] (ergodicity の実効的破れ)．有限時間平均では $chevron.l M chevron.r eq.not 0$．
#v(0.2em)
$arrow.r$ #hl[これはバグではなく, アルゴリズムの限界]．型も compiler も検出しない．止めるのは oracle．

== Step 5: 得た知見を正本に書き残す (Task 1 の仕上げ)
Task 1 で分かったことを #hl[次のセッションへ引き継ぐ] ため, rules に書き足して育てる:
- $T_c$ 以下の秩序変数は $chevron.l |M| chevron.r$ を使う ($chevron.l M chevron.r$ は有限時間で 0 に戻らない)．
- MC の unit-test 境界: 決定的部分のみ, 小さな系で準決定的に検証する．
#v(0.2em)
$arrow.r$ #hl[AGENTS.md / REPOSITORY_RULES.md] に書き込む = 正本を育てる1サイクル．

// ============================================================
= もう一周: アルゴリズム拡張
// ============================================================

== Task 2: 混合 (mixing) を速くする
- #hl[別タスク] として, 同じサイクルをもう一周 (#hl[また Step 1 から])．
- 問題: single-flip は $T_c$ 近傍で #hl[臨界減速], $T_c$ 以下で #hl[セクター間を遷移できない]．
- 拡張案 (Step 1 で下調べ・設計させる):
  - #hl[レプリカ交換 (parallel tempering)]: 複数温度を並走させ隣接を交換．高温側が障壁を越える．
  - #hl[クラスター法 (Wolff / Swendsen-Wang)]: スピンの塊を一括反転し, 臨界減速を回避．
#ref-text[Replica exchange: Hukushima and Nemoto, J. Phys. Soc. Jpn. 65, 1604 (1996)．Cluster algorithms: Swendsen and Wang, Phys. Rev. Lett. 58, 86 (1987) · Wolff, Phys. Rev. Lett. 62, 361 (1989)．]

== レプリカ交換の設計: 温度分点をどう置くか
- 温度集合 ${T_i}$ の配置 = 設計判断 (Step 1):
  - 隣接 replica の #hl[受容率を一定 (20〜40%)] に → エネルギー分布の重なりを確保．
  - 実務: #hl[幾何級数] 配置から始め, 受容率を見て調整．
- 実装 → #hl[$chevron.l M chevron.r$ / Binder の改善] を検証 → 温度配置の知見も #hl[正本に書き残す]．
#ref-text[💻 Task 2 はライブで実演する．]

// ============================================================
= 参考資料
// ============================================================

== 謝辞
本講義の準備にあたり, #hl[有益な議論] をいただいた (敬称略):
#v(0.3em)
#lk("https://giggleliu.github.io/", "Jin-Guo Liu") · #lk("https://wangleiphy.github.io/", "Lei Wang") · #lk("https://terasakisatoshi.github.io/", "Satoshi Terasaki")

== 参考資料
#table(columns: (auto, 1fr), stroke: none, row-gutter: 0.6em, column-gutter: 0.9em,
  [#lk("https://qc-hybrid.github.io/CompPhysHack2026/", "CompPhysHack2026")],
  [本講義の前提となるハッカソン (公式サイト)．#lk("https://atelierarith.github.io/CompPhysHack2026HandsOn/", "寺崎ハンズオン教材") も参照],

  [#lk("https://www.jinguo-group.science/sustainable-automation/", "Sustainable Automation")\ #text(size: 0.8em, fill: gray)[Jin-Guo Liu]],
  [#hl[CLAUDE.md (記憶) + Skills (手順) + サブエージェント] で AI 協働をセッション・週・プロジェクトを越えて持続可能にする方法を, C コンパイラの 10万行天井を例に論じる],

  [#lk("https://github.com/obra/superpowers", "superpowers")],
  [brainstorm → plan → execute を Skills として強制するワークフロー (本日のハンズオンで使用)],

  [#lk("https://missing.csail.mit.edu/2026/agentic-coding/", "MIT missing-semester")],
  [agentic coding 入門 (CLI エージェントの基礎)],
)
