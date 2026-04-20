# Writing the Abstract (and Title)

The abstract is read 100x more than the paper. Many reviewers' decision to engage seriously with the paper is half-made by the time they finish the abstract. It is the single most cost-effective place to spend writing time per word.

## What an abstract must do

In 150–250 words (or whatever the venue allows), an abstract must answer:

1. **What is the problem?** (One sentence — sharp, not generic.)
2. **Why does it matter / what's the gap?** (One sentence — what's missing in prior work.)
3. **What did you do?** (One or two sentences — the conceptual contribution and approach at a high level.)
4. **What did you find?** (One or two sentences — the headline result with numbers.)
5. **What's the implication or significance?** (Optional but useful — one sentence.)

That's roughly 5–7 sentences. If your abstract is longer, look for sentences that don't pull weight.

## The five-sentence template (a starting point)

A useful skeleton you can adapt and then break:

> [Problem domain] faces [specific problem]. Existing approaches [common limitation]. We propose [method name and one-line characterization]. We show [headline result] on [datasets / benchmarks], [improving over baseline by X / matching state-of-the-art at Y cost]. [Optional: implication — opens new direction / enables new application / clarifies long-standing question.]

This is dense. Each sentence does one job; nothing is redundant.

## Hook the reader in the first sentence

A weak first sentence loses the abstract. Bad opens:

- "In recent years, {topic} has gained increasing attention." (Generic, says nothing.)
- "{Topic} is a fundamental problem in {field}." (Textbook, no momentum.)
- "Many approaches have been proposed for {topic}." (Hedge, says nothing.)

Stronger opens:

- A surprising empirical fact your paper explains.
- A concrete problem with sharp scope.
- A pointed question your paper answers.
- A contested claim your paper defends.

Examples (hypothetical):
- "Long-context language models often retrieve irrelevant content even when the relevant content is in context."
- "We show that a 7B model with retrieval matches a 70B model on 8 of 12 reasoning benchmarks."
- "Despite years of work on calibration, LLM confidence scores remain miscalibrated by more than 20% on factual questions."

The first sentence should make the reader want to read the second.

## Concrete numbers in the abstract

If you have a striking headline number, put it in the abstract. Reviewers anchor on it. Conventions:

- One or two key numbers, not a barrage.
- Prefer relative ("3x faster") or absolute ("5 points higher accuracy") depending on which is more striking.
- Be honest: the number cited in the abstract must come from a specific table; you'll need to defend it.
- If your improvement is small but the *implication* is large (e.g., closing a known gap; first method to handle a regime), say that explicitly rather than hyping the small number.

If you don't have a striking number, don't fake one. Replace with a structural claim: "We provide the first analysis of X under condition Y" or "We introduce a benchmark that distinguishes A from B".

## Avoid weak language

Same rule as the rest of the paper, doubly so in the abstract:

- "We attempt to..." → "We..."
- "Our method aims to..." → "Our method..."
- "Results suggest..." → "Results show..." (only if they actually do)

If the abstract hedges, the reader assumes the paper hedges. Hedging is weakness.

## Avoid jargon

The abstract is read by people outside your subfield. Reviewers may be assigned based on the abstract alone. Test:

- Could a competent ML researcher one subfield over follow the abstract?
- Are all acronyms either defined or unavoidable (e.g., LLM, NLP)?
- Are the technical terms you use the standard ones for the broad field, not your local lab's terminology?

If the abstract requires deep subfield knowledge to parse, you've narrowed your reach unnecessarily.

## Don't reference the paper internally

Bad: "In this paper, we propose..." / "Section 3 describes...". The abstract is the paper's outermost layer; it shouldn't refer inward.

Good: "We propose..." (no "in this paper"). Direct, present tense.

## What goes at the end

The last sentence is the second-most-read sentence of the abstract. Use it for:

- The implication ("...opens a path toward [direction]").
- The reproducibility offer ("...code and data at [URL]").
- The future-work pointer ("...suggests a need to revisit [common assumption]").

Don't waste it on a generic close ("We hope this work..." / "Future work will...").

## Iteration discipline

Abstracts deserve real iteration:

1. Draft based on the introduction (which by now should be solid).
2. Cut every sentence that doesn't serve one of the five questions above.
3. Replace every weak verb / hedge.
4. Sharpen the first and last sentence.
5. Read it aloud — if anything trips, rewrite.
6. Have someone unfamiliar with the work read it; ask them to summarize what the paper does. If they can't, the abstract isn't pulling its weight.

Five iterations on the abstract is normal. It's the highest-return writing time in the paper.

## The title

Titles are abstracts compressed to ~10 words. Conventions:

- **Clarity over cleverness.** Reviewers Googling your work later will search by topic words; a punny title without the topic word loses you readers.
- **Include the key concept.** "Retrieval-Augmented Generation for Long-Form Question Answering" beats "Reading Between the Lines: Better QA via External Memory".
- **A subtitle is acceptable** for a memorable hook + a clarifying technical second line ("Constitutional AI: Harmlessness from AI Feedback").
- **Avoid generic openers.** "On X", "A Study of X", "Towards X" — these are common but do less work per word than naming what you actually did.
- **Avoid overclaiming.** Titles like "Solving X" or "The Final Word on Y" set up reviewers to look for ways the paper doesn't deliver.

For ML venues specifically: most accepted titles are 6–12 words, descriptive, sometimes with a method name (acronym or noun phrase). Reading 20 titles from your target venue is the fastest way to calibrate.

## Anti-patterns

- **The abstract that doesn't say what was done.** "We address an important problem in X." — no method, no result. Many drafts have this; rewrite to name the contribution.
- **The abstract that's all setup.** Three sentences of motivation, one rushed sentence on the method, no results. Cut motivation; expand contribution.
- **The abstract with no number.** If you have a quantitative result, lead with one. If you don't (theory paper, position paper), name the structural contribution clearly.
- **The metaphor abstract.** Abstracts that read like a marketing pitch — "imagine a world where..." — are off-putting at top venues. Save the metaphor for a talk; the paper abstract is direct.
- **The kitchen-sink abstract.** Every contribution, every dataset, every collaborator. Pick the headline; gesture at the rest.
- **The "we present a comprehensive study" abstract.** What did the study find? What's the headline? "Comprehensive" without a result is empty.

## Cross-references

- The abstract distills the introduction; if the intro is solid (`references/section-intro.md`), the abstract often falls out naturally.
- Use `research-frame-research` output for the one-sentence problem statement and the contribution list — they translate directly.
- The headline number in the abstract should map to a specific result in the experiments section (`references/section-experiments.md`); cross-check.
