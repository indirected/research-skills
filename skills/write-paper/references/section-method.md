# Writing the Method Section

The method section's job: a careful reader can **understand what you did and why**, and a determined reader can **reproduce it**. Anything more is decoration; anything less is failure.

## What the method section must convey

By the end of this section, the reader should know:

1. **The setup.** What's the input? What's the output? What assumptions are in play?
2. **The core idea.** What is the conceptual move that distinguishes your method from the obvious approach?
3. **The mechanics.** Step-by-step (or component-by-component) what the method does.
4. **The justifications.** Why this design choice rather than the obvious alternative?
5. **The non-obvious details.** The implementation details that matter for reproducibility (initialization, hyperparameters, edge cases).

A reader who only reads section 3 (Method) should be able to write a one-paragraph summary of how the method works. If they can't, the section has failed.

## Structure: top-down, not bottom-up

A common failure: starting with low-level details and assembling them into the method, expecting the reader to hold a mental construction kit until the picture finally emerges. Reverse this:

1. **Start with the high-level picture.** "Our method has three components: A, B, and C. A does X, B does Y, C does Z. Together they accomplish W."
2. **Then deep-dive each component.** Subsections or paragraphs per component.
3. **Then put it back together.** A summary paragraph or pseudocode showing the end-to-end flow.

This is the **figure-sentence-paragraph-component** progression: the reader gets coarser-to-finer levels of understanding, each grounded in the one above.

## The motivating example or figure

A good method section often opens with one of:
- **A motivating example** that shows the input, what your method does to it, and the output. Keeps the rest of the section concrete.
- **A system diagram** that shows the components and their data flow. Same purpose: ground the reader in a picture before throwing prose at them.
- **A formal problem statement** (notation, inputs, outputs, objectives) that grounds the reader in what's being computed.

Pick whichever fits the genre. ML systems papers tend to lead with a system diagram; theory papers with formal statements; applied papers often with motivating examples.

## Notation and formalism

Notation done well makes the method easier to read; done badly, it becomes a barrier.

Principles:
- **Define every symbol on first use.** Even the obvious ones — what does "bold lowercase" vs. "italic lowercase" mean in this paper?
- **Use a notation table** for any paper with more than ~10 distinct symbols. Place it early in the section or in the appendix.
- **Keep notation consistent across the paper.** If `θ` is parameters in section 3, don't switch to `φ` in section 5 without flagging.
- **Don't introduce notation you don't need.** Every variable is cognitive overhead; if a quantity appears once and is then unused, name it inline ("a constant `c`") or skip the symbol entirely.
- **Use intuitive names.** `R` for a reward function is faster to parse than `q`. `θ_enc` and `θ_dec` are clearer than `θ_1` and `θ_2`.

For algorithms: pseudocode (in `algorithm` / `algorithmic` LaTeX environments) often communicates more clearly than prose. Use it when the method has a clear procedural structure. Annotate non-obvious lines with comments.

## Per-component pattern

For each component (or step) of the method:

1. **Name and purpose.** "The retriever takes a query and returns the top-k most relevant documents."
2. **The mechanism.** How it works at a level the reader can follow.
3. **The non-obvious choice.** What's surprising or non-default here, and why?
4. **Connection to the next component.** What does this output that the next component consumes?

The "non-obvious choice" point is critical. Reviewers will assume default unless told otherwise — so if you used a non-default optimizer, a custom initialization, a trick to make training stable, **say so**, even if it's a one-liner. Otherwise the reader either assumes default and is confused later, or assumes you're hiding something.

## Justifying every design choice

A method section without justifications reads like a recipe. A method section with justifications reads like research. For each non-trivial design choice, give one sentence of why:

- "We use cosine similarity rather than dot product because [embedding norms vary across documents]."
- "We train for 10k steps because validation loss plateaus by then (Figure 4)."
- "We chose K=8 retrieved documents because preliminary experiments showed diminishing returns past 8 (Appendix B)."

This connects to the universal principle "name every choice; justify every parameter" (`SKILL.md`). Reviewers read for unjustified choices because they're a signal of cherry-picking.

If the choice was made because "it's what we tried first and it worked", say something like "We use X (any reasonable Y also works; see Appendix C for a sensitivity study)." Honesty about empirical choices is fine; pretending every choice was principled when it wasn't gets you in trouble at review.

## Algorithm presentation

If the method is a clear algorithm, present it as one. Common formats:

1. **Inline prose** for short, conceptually simple methods.
2. **Numbered steps** ("(1) compute X; (2) for each i, do Y; (3) aggregate by Z") for medium complexity.
3. **Pseudocode** (LaTeX `algorithm` environment) for full procedural methods. Include line numbers, comments, input/output declarations.
4. **A figure** for non-procedural methods (e.g., a neural net architecture).

Pick the lowest-overhead format that communicates the method clearly. A 5-line algorithm doesn't need a pseudocode block; a 30-line algorithm probably does.

For pseudocode:
- Type-annotate inputs/outputs.
- Use `←` for assignment, not `=`.
- Use `for / while / if` keywords in bold or with appropriate LaTeX styling.
- Include comments explaining non-obvious lines.
- Reference the algorithm by number from the prose ("Algorithm 1 details the procedure…").

## What goes in the main paper vs. the appendix

A frequent question. Rough rule:

**Main paper:**
- The conceptual contribution and core algorithm.
- The choices that *change the outcome* — anything a reader would need to change to get a different result.
- The minimal set of details a reader needs to understand what you did.

**Appendix:**
- Implementation tweaks that don't affect understanding (e.g., specific learning rate schedules, infrastructure details).
- Additional ablations and sensitivity studies.
- Full hyperparameter tables.
- Proofs (if your venue allows it; some require proofs in main paper).
- Edge case handling.

If the appendix would push the main paper to be illegible without it, you've put too much there. The main paper should be self-contained for understanding.

## Reproducibility paragraph

Most ML method sections (or experiments sections — pick one) include a small paragraph or table covering:
- Architecture and parameter count.
- Training objective and loss function.
- Optimizer, learning rate, schedule, batch size, training duration.
- Data preprocessing (tokenization, normalization, splits).
- Hardware and software stack (versions matter for closed APIs).
- Code release intent.

This supports the reproducibility checklist in `design-experiments`. If it's not in the method section, make sure it's somewhere — the appendix is fine.

## Anti-patterns

- **The bottom-up construction.** Three pages of building blocks before saying what the method actually does. Reverse it.
- **The notation cascade.** Introducing 30 symbols in the first column with no payoff until column 4. Reorganize so notation appears with the prose that needs it.
- **The unjustified choice.** "We use a learning rate of 3e-4" with no explanation. Either tune it from a validation set, cite a source, or say "this is the standard PyTorch default for AdamW".
- **The hidden component.** A component that's load-bearing but mentioned in passing. Give every load-bearing component its own subsection.
- **The "we modify standard X by adding Y" without showing X.** If your reader doesn't know X cold, gesture at it (one sentence, one citation) before introducing your modification.
- **The "see code" deflection.** "Implementation details are in our code." No — the paper has to be self-contained. Code is a supplement, not a substitute.
- **The over-claimed novelty.** "We introduce a novel attention mechanism…" when the mechanism is just rescaled dot-product attention. Reviewers know the literature; describe what you did and let novelty be assessed honestly.

## When the method is "just" applying X

A common case in modern ML: the contribution isn't a brand new algorithm but a careful application of existing methods to a new problem. This is *fine* and you should sell it cleanly:

- "We apply [existing technique X] to [new domain Y]. The non-trivial elements are: (a) adapting X's [step] to Y's [constraint]; (b) introducing [auxiliary mechanism] to handle [problem specific to Y]; (c) [empirical recipe that makes it work]."

This is a legitimate contribution. Hiding it behind made-up novelty is worse than naming it. Reviewers respect crisp, honest framing more than they respect inflated novelty claims.

## Cross-references

- Use `frame-research` output for the high-level "what this method computes and why" framing.
- Use `design-experiments` for the reproducibility-detail level: anything in the design plan that affects results should be reflected in the method section.
- For figures (system diagrams, architecture diagrams), use `references/figures-and-tables.md`.
