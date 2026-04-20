# Writing the Introduction

The introduction is the single most important section of the paper — it anchors the reviewer's first impression, which is hard to change later (Pazzani: "reviewers make an initial impression on the first page and don't change 80% of the time").

By the **end of the introduction**, the reviewer must know all of the following:

1. **What is the problem?**
2. **Why is it interesting and important?**
3. **Why is it hard? Why do naive approaches fail?**
4. **Why hasn't it been solved before?** (What's wrong with previous solutions?)
5. **What are the key components of the approach and results?** Including any specific limitations.
6. **A "Summary of Contributions"** — bullets, usually 3–5, with pointers to sections.

This list (from Jennifer Widom, via Keogh) is battle-tested. If your intro doesn't hit all six, it's missing structural load.

## The five-paragraph arc (common variant)

Most ML-venue intros use some version of:

- **Paragraph 1 — Hook.** Draw the reviewer in. Concrete example, striking fact, pointed question. Not a textbook definition ("Deep learning has recently..."). Anchor on something specific — a real application, a surprising empirical observation, a motivating scenario. The first sentence should make the reviewer want to read the second.

- **Paragraph 2 — Problem.** Define the problem sharply (one or two sentences). Then expand: what does solving this enable, who needs it, what's the scope. This is where the "X is good for Y in context Z" framing (from `frame-research`) goes.

- **Paragraph 3 — Why it's hard / why prior work doesn't solve it.** Name the obvious approaches. Explain, concretely, where they break. A reviewer reading this paragraph should be nodding: "yes, those approaches wouldn't work, and now I'm curious what this paper does differently." Avoid dismissiveness — "prior work is slow and clumsy" is worse than "prior work X assumes Y, which does not hold in regime Z".

- **Paragraph 4 — Our approach (high level) + key result.** Introduce your method at a conceptual level (not implementation detail) and the headline result. This is where you sell simplicity if you have it: "Surprisingly, a direct application of Y is sufficient to…". Include the one or two most important numbers if they're striking.

- **Paragraph 5 — Contributions + roadmap.** A bullet list of 3–5 contributions, each starting with "We…". Each bullet ideally names the section where the contribution is delivered ("§3 introduces…"; "§5 evaluates…"). This doubles as an outline and saves space.

Not every intro uses exactly this arc — long papers sometimes expand to 6–7 paragraphs, short workshop papers compress to 3. But the six questions above must all be answered somewhere in the intro.

## A figure on the first page

Many top-venue papers include a "concept figure" on page 1 — a single visual that conveys the key idea or the key result. This is high-leverage because reviewers often skim figures first. Considerations:

- It must be **self-explanatory** in a few seconds of looking.
- It must convey the paper's **contribution**, not just the problem.
- Direct labeling (not "Method A" / "Method B" — use real names).
- Simple enough that it reads clearly when shrunk to page-1 size.

If you can't make a great figure in the space you have, skip it — a bad figure on page 1 hurts more than it helps.

## The opening sentence

The opening sentence of the intro deserves real attention. Bad opens:

- "In recent years, {topic} has received increasing attention." (Generic, says nothing.)
- "{Topic} is the task of…" (Textbook definition, no momentum.)
- "{Acronym}, first introduced by {X}, is widely used…" (Historical, not engaged with what's new.)

Good opens:

- A surprising empirical fact the paper explains.
- A concrete scenario that motivates the problem.
- A pointed question the paper answers.
- A claim — with teeth — that the paper defends.

Spend a few iterations on the opening. It's 20–50 words that shape everything after.

## The "contribution" bullets

Common failure: contribution bullets that are vague, overlapping, or mix contributions with methodology.

Good contribution bullet formula: **"We [verb] [specific thing] [that shows / enables / improves / introduces] [concrete outcome]. (§ref)"**

Examples (hypothetical):
- "We propose X, a method that Y; X is the first to handle Z without {assumption} (§3)."
- "We prove that X has optimal communication complexity under {conditions} (§4)."
- "We construct a benchmark of N tasks that expose {limitation} of existing methods (§5.2)."
- "We release code and data at [URL] for reproducibility."

Anti-patterns to avoid:
- "We explore…" (not a contribution — what did you find?).
- "We conduct extensive experiments" (not a contribution — what did experiments show?).
- "We survey the literature" (belongs in related work, not contributions — unless the survey itself is the paper).
- Two bullets that say essentially the same thing in different words.

## Anti-patterns in the intro

- **The "we invented a problem and solved it" intro.** The problem description feels bespoke, the evaluation is on data the authors made, the metric is one they chose. Keogh's warning: if the author invented the problem, the data, and the metric, can we be surprised they have 95% accuracy? Ground the problem in something external (prior literature, application need, observed phenomenon) before claiming results on it.

- **The "prior work is inadequate" dismissive intro.** "Existing methods fail to handle X." The reviewer thinks: which existing methods? In what sense fail? Under what conditions? Replace with specific, fair discussion.

- **The "delayed thesis" intro.** Three pages of setup before the paper says what it's doing. Get to the contribution fast — reviewers scan for it.

- **The "hedging intro."** "We hope our work contributes toward…" / "We believe this may help…". If you believe it, say it plainly. If you don't, strengthen the claim before writing.

## Cross-references

When drafting an intro, you're often working with:
- **Framing output** (from `frame-research`): use the one-sentence problem statement and why-triad; the intro unpacks them into prose.
- **Contribution list** (from `frame-research`): the contribution bullets at the end of the intro are usually this list, formatted.
- **Related work** (in a separate section): you'll cite 3–6 papers in the intro for context, but the real differentiation happens in related work — don't over-cite in the intro.
- **Experiments preview**: the intro should name 1–2 headline results to anchor the reader, pointing to the experiments section for detail.

## A quick self-check before moving on

Read your intro as if you were a tired reviewer. Ask:

- Can I write a one-sentence description of this paper after reading only this intro?
- Do I know what kind of evidence the paper will offer?
- Do I feel like the authors know the related work, or are they hand-waving?
- Am I anchored positively (this looks like a good paper) or negatively (this looks unclear, dismissive, or unrigorous)?

If any answer is bad, the intro needs another pass.
