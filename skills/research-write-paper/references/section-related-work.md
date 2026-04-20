# Writing the Related Work

Related work is the section most often reduced to a laundry list. Good related work does something harder: it **positions the paper** by showing the reader where it sits in the field, what it borrows, what it contests, and what it adds.

## What related work is actually for

- **Establish that the authors know the literature.** A reviewer who sees their own paper cited (or sees the obvious precedent cited) starts trusting the paper. A reviewer who sees an obvious omission assumes carelessness.
- **Differentiate the contribution.** For each close neighbor, say specifically how the current paper is different — one concrete sentence, not vague hedging.
- **Frame the problem.** The prior work you cite tells the reader what kind of paper this is (a theoretical contribution to area X, an empirical advance in area Y, a bridge between X and Y…).

Not what it's for:
- Listing every paper you can find in the space. (That's a survey, not related work.)
- Demonstrating reading breadth. (Depth beats breadth — engage with a few close papers, gesture at the rest.)
- Dismissing prior work to make yourself look better. (This backfires — see "fairness" below.)

## Organization: by theme, not by chronology

Weak: "Smith (2020) proposed X. Jones (2021) extended it. Lee (2022) added…" — reads as a timeline.

Strong: organize around themes / research questions / method families, each as a paragraph. For each theme:
- Describe what the theme is about.
- Cite the important papers in it (the ones that actually made progress, not every paper).
- State how your work relates — builds on the theme / departs from it / combines it with another theme.

Use `research-synthesize-literature` output if the user has it — the themes in the synthesis are often the right backbone for related work.

## Per-paragraph pattern

A useful pattern for each themed paragraph:

1. **Name the theme** (one sentence, sometimes with a topical header).
2. **Cite the key papers** with specific one-line characterizations — not just names.
3. **Explain the limitation or gap** this theme has, in relation to what your paper does.
4. **Differentiate** your work with one concrete sentence.

Example structure (hypothetical):

> **Long-context retrieval** has been studied extensively in the post-4k-context era. X et al. (2024) propose a hierarchical retrieval scheme for contexts up to 128k, while Y et al. (2024) show that a simpler sliding-window approach is competitive under specific assumptions on document structure. These methods share the assumption that the retrieval query is provided explicitly at inference time; in contrast, our approach infers the retrieval target from the generation state, which removes the need for query annotation and allows retrieval to adapt mid-generation.

That's one paragraph. Four sentences, three papers cited with real content, one clean differentiation. Compare to a laundry-list version:

> Many papers have explored long-context retrieval [a, b, c, d, e, f, g]. Our work differs in that we handle query-free retrieval.

The first carries weight; the second doesn't.

## Fairness to prior work

Reviewers take fairness seriously. Specific principles:

- **Cite correctly.** Read the papers you cite. Laundry-list citations (where the author clearly hasn't read them) are transparent and embarrassing. Keogh's anecdote of his co-author's name being misspelled "Refiei" propagating through a dozen papers is a real risk.
- **Characterize honestly.** If Smith 2020 proposed a method that's close to yours, say so clearly. Don't stretch to find a difference; a genuine close neighbor is worth acknowledging.
- **Don't diminish rivals.** "Smith's idea is slow and clumsy; we fixed it" vs. "In her useful paper, Smith shows…; we extend this line by mitigating…" — the first is an unforced error. Even if Smith's paper is flawed, the gracious framing is stronger.
- **Include concurrent work.** If a paper came out near-simultaneously with yours (within a few months), cite it and briefly position against it. Not doing so looks like you're hiding it.
- **If your work overlaps heavily with your own prior paper**, cite the prior paper and explicitly explain what's new. "Double-dipping" is a reject reason.

## Differentiation — the concrete-sentence test

For each close neighbor, you should be able to write one concrete sentence of differentiation. Test yourself: can you finish this sentence?

> Our work differs from {paper} in that we ___.

The blank must be **falsifiable and specific**:
- ✓ "…allow {condition X} which {paper} requires to be bounded".
- ✓ "…evaluate on multilingual data while {paper} evaluates only on English".
- ✓ "…prove tight bounds where {paper} proves only an upper bound".
- ✗ "…take a different approach". (What approach? In what sense different?)
- ✗ "…achieve better performance". (On what? By how much? Under what conditions?)

If you can't fill the blank concretely, you haven't understood the neighbor paper well enough — or your contribution isn't differentiated from it. Either case requires work before writing.

## Breadth vs. depth

A related work section typically has a depth-breadth tradeoff:
- **Depth papers**: 3–6 close neighbors you engage with substantively.
- **Breadth papers**: 10–30 related-but-less-close papers cited in bundles with brief characterization.

The right split depends on the paper. A theoretical paper in a small area might have 10 depth and 0 breadth. An applied ML paper often has 4–6 depth and a broader sweep of breadth citations organized by theme.

If a theme is vast, you can gesture: "The literature on X is extensive; we refer the reader to [survey] and focus here on the subset directly relevant to…". This is respectful — you're acknowledging the breadth without pretending to cover it all.

## Placement: where does related work go?

Two common placements:

1. **Section 2 (right after intro).** Traditional placement. Gets the related work out of the way; lets the rest of the paper proceed without interruption.
2. **Near the end (after method or experiments).** Increasingly common in ML venues. Arguments: (a) reviewers can understand the contribution before seeing how it compares to prior work; (b) the comparison is more meaningful when the reader already understands what you did.

Both are defensible. Follow the venue's convention and the paper's flow. One tip: if related work is section 2 (before method), keep it tighter — don't force the reader to hold a lot of prior-art detail in mind before they know what you're doing.

## Length and weight

Related work is typically 0.5–1.5 pages in a 9-page ML paper. Too short (a paragraph) suggests you haven't engaged with the field; too long (2+ pages) eats space better used on method or experiments.

If you have more to say about prior work than space allows, push the extended discussion to a "Further Discussion of Related Work" appendix. The main paper's related work section should focus on the closest neighbors.

## Anti-patterns

- **The citation bundle.** "This has been extensively studied [a, b, c, d, e]." — nothing of substance.
- **The shallow "unlike X" claim.** "Unlike X, we handle general settings." — what settings specifically? X handles some generality too. Be concrete.
- **The taxonomy that doesn't connect.** Three paragraphs categorizing prior work, then no sentence saying how your work relates.
- **The name-drop.** Citing a famous paper that's only tangentially relevant to show you know the field. Reviewers see through it.
- **The "many papers have explored X" hedge.** If many papers have explored X, name them and engage; if few have, say that.
- **The adversarial related work.** Paragraphs whose main function is to make prior work look bad. Reviewers notice, and even reviewers who aren't the authors of those papers will react negatively.

## Cross-references

- Use `research-synthesize-literature` output if the user has it — themes there often map directly to related-work paragraphs.
- Use `research-read-paper` notes for the close neighbors — the "position vs. our work" section of each reading note is a starter for the differentiation sentence.
- If the user hasn't read the close neighbors deeply, send them back to `research-read-paper` first. Don't bluff-paraphrase papers based on training data.
