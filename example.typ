// A paper formatted using SAGE's defaults.
#import "template.typ": (
  acknowledgements, affiliation-note, conflicting-interests, endnote, funding, paper, print-endnotes, proof,
  theorem-env,
)

#show: paper.with(
  title: [Title of the Paper],
  short-title: [Short title for the running head],
  authors: ((name: "First Author", affiliation: "Department, University, City, Country"),),
  abstract: [An abstract of about 150 words goes here.],
  keywords: ("keyword one", "keyword two"),
)

#affiliation-note(
  [Department, University, City, Country],
  [First Author, Department, University, Address. \ Email: author\@example.edu],
)

// The class defines no theorem environments; each paper makes its own.
// The lemma shares the theorem's counter.
#let theorem = theorem-env("Theorem")
#let lemma = theorem-env("Lemma", kind: "theorem")

= Introduction
Body text citing prior work @example2020.

== A subsection
More text, with an equation
$ a^2 + b^2 = c^2 . $

=== A paragraph heading
Text with an endnote.#endnote[The text of the endnote, which appears under the heading Notes.]

#theorem(note: [Pythagoras])[Right triangles satisfy $a^2 + b^2 = c^2$.] <thm:pythagoras>
#proof[Obvious.]
#lemma[This lemma is numbered after @thm:pythagoras.]

#print-endnotes()

#acknowledgements[Thanks to the reviewers.]
#funding[This work was supported by grant number 0000.]
#conflicting-interests[The authors declare no conflicts of interest.]

#bibliography("refs.bib", style: "sage-harvard.csl")
