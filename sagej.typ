// A Typst version of SAGE's LaTeX class sagej.cls (v1.01, 2015/06/09), which SAGE journals share.
//
// sagej.cls takes class options that pick the page geometry (Afour, shortAfour, MCfour, PCfour, Royal, Crown), the citation style (sageh, sagev, sageapa), the font (times) and the line spacing (doublespace).
// Each journal fills in its name, volume, issue, year and web address.
// `paper` takes the same choices as arguments.
// See README.md for a table, and ijrr.typ for the settings that IJRR uses.
//
// With `times`, text is Times and the sans-serif elements are Helvetica scaled to 0.95, as in the class's times and helvet packages.
// Nimbus Roman, Nimbus Sans and Nimbus Mono PS are the URW fonts those packages map to.
// Without `times` the class uses Computer Modern.
// Typst bundles New Computer Modern but no sans-serif or typewriter face of it, so those use Nimbus Sans and Nimbus Mono PS unless `fonts` names others.

#let ink = rgb("#000000")

// LaTeX sizes under sagej: \normalsize 10/12, \small 9/10.5, \footnotesize 8/10, \scriptsize 7/8.5, \large 12/14, \titlesize 18/20, and the reference size 9/12.
#let normal = 10pt
#let small = 9pt
#let footnote-size = 8pt
#let script = 7pt
#let large = 12pt
#let title-size = 18pt
#let ref-size = 9pt

// The page geometries of sagej's size options.
// `text` is the text block, centered on the page.
// `sans: false` is PCfour, whose title block and captions use the serif face.
// Royal and Crown are single column and set their title block a little differently.
#let layouts = (
  Afour: (paper: (210mm, 297mm), text: (174mm, 258mm), columns: 2),
  shortAfour: (paper: (210mm, 280mm), text: (170.5mm, 226mm), columns: 2),
  MCfour: (paper: (189mm, 246mm), text: (151.5mm, 196mm), columns: 2),
  PCfour: (paper: (170mm, 242mm), text: (138mm, 198mm), columns: 2, sans: false),
  Royal: (paper: (156mm, 234mm), text: (124mm, 185mm), columns: 1),
  Crown: (paper: (7.25in, 9.5in), text: (146.5mm, 183mm), columns: 1),
)

// The font settings that sans-serif helpers read. `paper` sets them for its body.
#let sage-config = state("sage-config", (sans: "Nimbus Sans", scale: 1))

// Text in the class's sans-serif family at a LaTeX size. Use it inside the body of `paper`.
#let sf(size, body, ..args) = context {
  let c = sage-config.get()
  text(font: c.sans, size: size * c.scale, ..args, body)
}

// The leading that puts baselines `skip` apart for text of a LaTeX size, which the class's sans-serif family sets at `scale` of that size.
// Every line box is one em tall.
#let lead(size, skip, scale: 1) = skip - size * scale

// A run-in paragraph heading, sagej's \paragraph: sans-serif italic at the text size.
#let runin(body) = sf(normal, style: "italic", body) + h(0.5em)

// The version of this template, in the date and number format that SAGE's class uses for its own.
// Change it when the template changes.
#let template-version = "2026/10/15 v0.1"

#let journal-defaults = (
  name: [Journal name],
  volume: "XX",
  issue: "X",
  year: "0000",
  doi: "10.1177/ToBeAssigned",
  permissions: "sagepub.co.uk/journalsPermissions.nav",
  url: "www.sagepub.com/",
  logo: none,
)

#let paper(
  title: none,
  short-title: none,
  authors: (),
  abstract: none,
  keywords: (),
  // One of the keys of `layouts`, or a dictionary with `paper`, `text`, `columns` and optionally `sans`.
  layout: "Afour",
  // The class option `times`.
  times: false,
  // The class option `doublespace`, which sets lines at 1.25 times their usual distance.
  doublespace: false,
  // "harvard" (sageh), "vancouver" (sagev) or "apa" (sageapa), which sets the reference list.
  citations: "harvard",
  // A numbering pattern for headings, such as "1.1.". The class leaves sections unnumbered.
  numbering: none,
  // The journal's details; any key left out takes its value from `journal-defaults`.
  journal: (:),
  // Font families to use in place of the defaults, with any of the keys `serif`, `sans` and `mono`.
  fonts: (:),
  // The version of this template that prepared the paper, shown on the first page's footer.
  // It is this template's own version, not sagej.cls's.
  version: template-version,
  body,
) = {
  let geom = if type(layout) == str { layouts.at(layout) } else { layout }
  let has-sans = geom.at("sans", default: true)
  let serif-face = fonts.at("serif", default: if times { "Nimbus Roman" } else { "New Computer Modern" })
  let sans-face = if has-sans { fonts.at("sans", default: "Nimbus Sans") } else { serif-face }
  let sf-scale = if times and has-sans { 0.95 } else { 1 }
  let mono-face = fonts.at("mono", default: "Nimbus Mono PS")
  let j = journal-defaults + journal
  let one-column = geom.columns == 1
  let (text-w, text-h) = geom.text
  let (page-w, page-h) = geom.paper

  // Text in the class's sans-serif family at a LaTeX size, with this paper's settings.
  let sf(size, body, ..args) = text(font: sans-face, size: size * sf-scale, ..args, body)

  set document(title: title, author: authors.map(a => a.name))

  let head-rule = line(length: 100%, stroke: 0.25pt + ink)
  let volume-issue = [#j.volume\(#j.issue\)]
  set page(
    width: page-w,
    height: page-h,
    margin: (x: (page-w - text-w) / 2, y: (page-h - text-h) / 2),
    columns: geom.columns,
    header-ascent: 14pt,
    footer-descent: 22pt,
    header: context {
      let n = counter(page).get().first()
      if n == 1 {
        line(length: 100%, stroke: 0.5pt + ink)
      } else {
        set par(first-line-indent: 0pt, justify: false)
        if calc.even(n) {
          sf(normal)[#n #h(1fr) #emph[#j.name #volume-issue]]
        } else {
          sf(normal)[#emph(short-title) #h(1fr) #n]
        }
        v(-4pt)
        head-rule
      }
    },
    footer: context {
      set par(first-line-indent: 0pt, justify: false)
      let n = counter(page).get().first()
      text(
        font: serif-face,
        size: script,
        style: "italic",
      )[Prepared using #text(font: sans-face, size: script * sf-scale)[template.typ]#if n == 1 [ \[Version: #version\]]]
    },
  )
  set columns(gutter: 12pt)

  set text(font: serif-face, size: normal, fill: ink, lang: "en", region: "us", top-edge: 0.8em, bottom-edge: -0.2em)
  // sagej discourages hyphenation (\hyphenpenalty=1000) and forbids widows and clubs.
  set text(costs: (hyphenation: 2000%, widow: 10000%, orphan: 10000%))
  // sagej does not load microtype, so punctuation stays inside the measure rather than hanging into the margin.
  set text(overhang: false)
  // \onehalfspacing sets baselines 1.25 times 12 pt apart.
  let body-leading = if doublespace { 2pt + 0.25 * 12pt } else { 2pt }
  set par(justify: true, leading: body-leading, spacing: body-leading, first-line-indent: (amount: 1em, all: false))
  show math.equation: set text(font: "New Computer Modern Math")
  // Typewriter text is Courier, here its URW clone, with the times package, and Computer Modern typewriter without.
  // Inline code keeps the text size.
  // Listings are set at \scriptsize so that their lines fit the column.
  show raw: set text(font: mono-face, size: normal)
  show raw.where(block: true): set text(size: script)
  show raw.where(block: true): set par(leading: lead(script, 8.5pt))

  set heading(numbering: numbering)
  show heading: set par(first-line-indent: 0pt, justify: false)
  show heading.where(level: 1): it => {
    block(above: 14.4pt, below: 5pt + 2pt, sticky: true, sf(large, weight: "bold", {
      if it.numbering != none {
        counter(heading).display(it.numbering)
        h(0.5em)
      }
      it.body
    }))
  }
  show heading.where(level: 2): it => {
    block(above: 10.8pt, below: 4pt + 2pt, sticky: true, sf(large, style: "italic", weight: "regular", {
      if it.numbering != none {
        counter(heading).display(it.numbering)
        h(0.5em)
      }
      it.body
    }))
  }
  show heading.where(level: 3): it => {
    block(above: 6pt, below: 2pt, sticky: true, sf(normal, style: "italic", weight: "regular", it.body))
  }

  // Captions: \small sans serif, a bold label followed by a period and 1ex, set ragged right.
  // Tables carry theirs above with 2 pt of space, figures below with 10 pt.
  set figure(gap: 10pt)
  show figure.where(kind: table): set figure(gap: 2pt)
  show figure.caption: it => {
    set par(justify: false, first-line-indent: 0pt, leading: lead(small, 10.5pt, scale: sf-scale), spacing: lead(
      small,
      10.5pt,
      scale: sf-scale,
    ))
    set align(left)
    // The separator is a period and 1 ex.
    // An unnumbered figure, such as a table's continuation, shows its caption's text alone.
    if it.numbering == none { sf(small, it.body) } else {
      sf(small, [#text(weight: "bold")[#it.supplement #context it.counter.display(it.numbering).]#h(0.52em)#it.body])
    }
  }
  show figure.where(kind: table): set figure.caption(position: top)
  set table(stroke: none, inset: (x: 4pt, y: 2.4pt))

  // Theorems, set by the class's `sage` theorem style: a bold head with the name, the number and a period, then the body in italics.
  // A note follows the head in the text's own weight.
  // Environments made by `theorem-env` are figures of a kind that starts with "sage-theorem:", so that references to their labels work.
  show figure: it => if type(it.kind) == str and it.kind.starts-with("sage-theorem:") {
    block(above: 6pt, below: 6pt, breakable: true, width: 100%, align(left, {
      text(weight: "bold")[#it.supplement#if it.numbering != none [ #context it.counter.display(it.numbering)].]
      if it.caption != none [ #it.caption.body.]
      h(0.75em)
      text(style: "italic", it.body)
    }))
  } else { it }
  show table: set text(size: 8pt)

  set math.equation(numbering: "(1)")
  // Lists: no space between items, labels hung in a 2.5 em margin as in article.
  set enum(indent: 0pt, body-indent: 0.5em, spacing: 2pt, numbering: "1.")
  set list(indent: 0.6em, spacing: 2pt)

  // The reference list is set at the reference size.
  // Harvard and APA entries hang by 16 pt and sit 1 pt apart.
  // Vancouver entries carry their numbers and sit together.
  let hanging = citations != "vancouver"
  set bibliography(title: none)
  show bibliography: it => {
    block(above: 14.4pt, below: 5pt + 2pt, sticky: true, sf(normal, weight: "bold")[References])
    set text(size: ref-size)
    set par(
      first-line-indent: 0pt,
      leading: lead(ref-size, 12pt),
      spacing: lead(ref-size, 12pt) + if hanging { 1pt } else { 0pt },
      hanging-indent: if hanging { 16pt } else { 0pt },
      justify: false,
    )
    it
  }

  // The title block, sagej's \@maketitle: the title beside the journal's details, the authors, the abstract, and the keywords, all in sans serif and across both columns.
  place(
    top,
    scope: "parent",
    float: true,
    clearance: if one-column { 22pt - 4.5mm } else { 22pt },
    {
      set par(first-line-indent: 0pt, justify: false)
      grid(
        columns: (text-w - 57.625mm, 42.625mm),
        column-gutter: 15mm,
        {
          v(12.5pt)
          set par(leading: lead(title-size, 20pt, scale: sf-scale))
          sf(title-size, weight: "bold", title)
          v(1.5em + 12.5mm)
        },
        {
          set par(leading: lead(script, 8.5pt, scale: sf-scale), spacing: lead(script, 8.5pt, scale: sf-scale))
          sf(script)[
            #j.name \
            #j.volume\(#j.issue\):1--#context counter(page).final().first() \
            ©The Author(s) #j.year \
            Reprints and permission: \
            #j.permissions \
            DOI: #j.doi \
            #j.url
          ]
          v(2.3pt)
          if j.logo != none { j.logo } else { sf(12pt, weight: "bold")[SAGE] }
        },
      )
      if one-column { v(6mm) }
      block(below: 40pt, {
        set par(leading: lead(large, 14pt, scale: sf-scale))
        sf(large, weight: "bold", authors.map(a => a.name).join(", "))
      })
      {
        set par(justify: true, leading: lead(normal, 12pt, scale: sf-scale), spacing: lead(
          normal,
          12pt,
          scale: sf-scale,
        ))
        if abstract != none {
          sf(normal, weight: "bold")[Abstract]
          v(5pt - 1.5mm, weak: true)
          parbreak()
          sf(normal, abstract)
        }
        if keywords.len() > 0 {
          v(20pt)
          sf(normal, weight: "bold")[Keywords]
          linebreak()
          sf(normal, keywords.join(", "))
        }
      }
    },
  )

  sage-config.update((sans: sans-face, scale: sf-scale))
  body
}

// The affiliation and corresponding author, which sagej sets as unmarked footnotes and ftnright moves to the foot of the right-hand column of the first page.
// Place this inside that column.
#let affiliation-note(affiliation, corresponding) = context {
  let scale = sage-config.get().scale
  place(bottom, float: true, clearance: 20pt, {
    set par(first-line-indent: 0pt, justify: false, leading: lead(footnote-size, 10pt, scale: scale), spacing: lead(
      footnote-size,
      10pt,
      scale: scale,
    ))
    line(length: 100%, stroke: 0.4pt + ink)
    v(3mm - 3pt)
    sf(footnote-size, affiliation)
    if corresponding != none {
      // Each unmarked footnote is its own paragraph, with \footnotesep of space above it, less 3 pt for the corresponding author.
      v(6.65pt - 3pt)
      sf(footnote-size)[*Corresponding author:* \ #corresponding]
    }
  })
}

// A back-matter section such as the class's acks, funding, sm, dci and biog environments.
// It has an unnumbered sans-serif bold heading at the text size, then the text at the reference size.
#let back-matter(title, body) = {
  block(above: 10.8pt, below: 4pt + 2pt, sticky: true, sf(normal, weight: "bold", title))
  set text(size: ref-size)
  set par(first-line-indent: 0pt, justify: true, leading: lead(ref-size, 12pt), spacing: lead(ref-size, 12pt))
  body
}
#let acknowledgements(body) = back-matter[Acknowledgements][#body]
#let funding(body) = back-matter[Funding][#body]
#let supplemental-material(body) = back-matter[Supplemental material][#body]
#let conflicting-interests(body) = back-matter[Declaration of conflicting interests][#body]
#let author-biography(body) = back-matter[Author biography][#body]
#let author-biographies(body) = back-matter[Author Biographies][#body]

// An environment for theorems, lemmas and the like, in the class's `sage` theorem style.
// Call it as `#let theorem = theorem-env("Theorem")`, then write `#theorem[...]` or `#theorem(note: [Name])[...]`.
// Attach a label for references, as in `#theorem[...] <thm:main>`.
// Environments with the same `kind` share a counter, as `\newtheorem{lemma}[theorem]{Lemma}` does.
// The kind defaults to the lowercased supplement.
// With `numbered: false` the head has no number.
#let theorem-env(supplement, kind: none, numbered: true) = {
  let key = "sage-theorem:" + if kind == none { lower(supplement) } else { kind }
  (body, note: none) => figure(
    body,
    kind: key,
    supplement: supplement,
    numbering: if numbered { "1" } else { none },
    caption: note,
    outlined: false,
  )
}

// A proof, as the class sets it: a bold head with a period, then the body in the text's own style and no end mark.
#let proof(body, name: [Proof]) = block(above: 6pt, below: 6pt, breakable: true, {
  text(weight: "bold")[#name.]
  h(5pt)
  body
})

// Endnotes, as the class's endnotes package sets them.
// `endnote` leaves a superscript number in the text and records its body.
// `print-endnotes` sets the recorded notes under a heading at the reference size, with the numbers hung in a 15 pt margin.
#let endnotes = state("sage-endnotes", ())
#let endnote(body) = {
  endnotes.update(notes => notes + (body,))
  context super(str(endnotes.get().len()))
}
#let print-endnotes(title: [Notes]) = context {
  block(above: 10.8pt, below: 4pt + 2pt, sticky: true, sf(normal, weight: "bold", title))
  set text(size: ref-size)
  set par(first-line-indent: 0pt, hanging-indent: 15pt, justify: true, leading: lead(ref-size, 12pt), spacing: lead(
    ref-size,
    12pt,
  ))
  for (i, note) in endnotes.final().enumerate() {
    box(width: 15pt)[#(i + 1).]
    note
    parbreak()
  }
}
