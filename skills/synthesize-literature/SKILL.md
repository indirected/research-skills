---
name: synthesize-literature
description: |
  Use this skill when the user has accumulated reading notes on multiple papers and
  wants to step back and look at the literature as a whole — build themes, see what
  the field agrees and disagrees on, surface real gaps, spot methodological
  monocultures, and form a grounded opinion about where the work is missing. Triggers
  on phrases like "synthesize the literature", "what does the literature say",
  "find themes across these notes", "map out the gaps", "where is the field stuck",
  "build a related-work map", or any request that moves from one paper to many.
  Make sure to use this whenever the user shifts from reading individual papers to
  reasoning about the field — even if they don't explicitly say "synthesize".
---

# Synthesize Literature

Cross-paper synthesis — turning a pile of reading notes into a structured view of the field that can then inform related-work prose, problem framing, or idea generation.

## Why this is a hard skill

Synthesizing papers is not summarizing them consecutively. The specific work that makes synthesis useful:

- **Building themes that cut across papers, not topic tags.** A good theme is a claim or a research question ("does scale alone solve X?"), not a noun ("retrieval"). Noun-tagged groups produce flat related-work sections; claim-tagged groups produce arguments.
- **Noticing what the field agrees on and what it quietly disagrees on.** Disagreements are usually buried in benchmark choices, metric definitions, and unstated assumptions — not in explicit debate. Surfacing them is where the real gaps live.
- **Distinguishing "not done" from "not done because not worth doing".** Every obvious axis is unexplored for some reason. Real gaps are ones where the reason doesn't hold any more (new capability, new data, new application) or never held (everyone assumed someone else had done it).
- **Spotting methodological monocultures.** Fields converge on a benchmark, a metric, a model size, a prompting strategy. That convergence creates blind spots. Papers inside the monoculture look thorough but share the same failure mode.
- **Mapping empirical coverage.** Which datasets? which domains? which languages? which model sizes? Most fields have a very uneven empirical footprint that's easy to see once plotted and easy to miss from individual papers.

## Inputs

The user supplies a set of reading notes — typically markdown files (e.g., from `read-paper`), but any structured text works. If they don't hand you paths, ask where their notes live. If notes are inconsistent in structure, work with what's there; do not require conformance to the `read-paper` template.

If the user wants synthesis across papers they haven't read yet (or haven't taken notes on), stop and tell them — synthesis is only trustworthy when it's grounded in notes the user has made. Offer to read the papers first via `read-paper`.

## Synthesis protocol

### 1. Read the notes carefully, don't just skim

For each note, extract:
- The paper's **real** contribution (not the claimed one — use the decomposition already in the notes).
- Its **main empirical claim** and how strong the evidence is.
- Its **assumptions and hidden assumptions**.
- Its **benchmark / dataset / model-size** footprint.

Build a small internal table in your head or on paper. If there are more than ~20 notes, build it explicitly.

### 2. Build themes bottom-up

Do NOT start with themes you expect to find. Start from the contributions and claims in the notes, and cluster them by the *question they're answering*, not by the *topic they're in*.

Good themes:
- "Can we get long-context quality without more parameters?"
- "Is retrieval augmentation a training-time fix or an inference-time fix?"
- "Do reasoning traces help or just add tokens?"

Bad themes (too coarse, become tag buckets):
- "Retrieval"
- "Long context"
- "Reasoning"

A useful cross-check: for each theme, ask "could I argue this theme is the wrong question to ask?" If yes, the theme is substantive. If no, it's probably just a topic tag.

### 3. For each theme, identify the shape of the work

- **Papers in this theme** — list them, grouped by the position they take.
- **Consensus** — what do most papers in this theme agree on? State it as a claim, with citations.
- **Disagreement** — where do papers diverge? On **benchmarks** (measuring different things)? On **methods** (same end, different means)? On **definitions** (same word, different meaning)? Disagreements are often implicit — watch for them.
- **Empirical footprint** — what datasets / model sizes / domains have papers actually covered? Where is it thin?
- **Methodological monoculture** — has the community converged on one eval protocol, one benchmark, one model family? What could hide in that convergence?

### 4. Identify gaps — carefully

Gaps come in three flavors. Label each gap with its type:

- **Unexplored** — a plausible axis that no paper has touched. These are often suspicious — ask why, because a reason usually exists.
- **Under-evaluated** — an axis that's been explored but only on one dataset, one model size, one domain. Broader evaluation would actually move the field.
- **Reopenable** — a question that was "settled" but under conditions that no longer hold (new model capability, new data, new application). These are the richest gaps because the settled conclusion can be genuinely wrong now.

For each gap, write:
- **What's missing** (one sentence).
- **Why it's missing** (best guess — hard / expensive / unfashionable / assumed-solved).
- **Whether the reason still holds** (and if not, why not).
- **What would count as filling the gap** (what kind of paper would close it — be concrete).

A gap without a "why it's missing" is a shopping list, not a synthesis.

### 5. Form grounded opinions

Synthesis without opinion is just a structured bibliography. Commit to positions:

- **What's the center of gravity** in this field right now? (What does most of the community assume is true?)
- **What does the center of gravity get wrong or miss?** Where is the consensus thinner than it looks?
- **Where is the next interesting paper likely to come from?** (Not a prediction — a claim about where the unclaimed ground is.)

Be willing to be wrong in writing. A grounded opinion the user can push back on is more valuable than a hedged summary.

## Output

Produce a synthesis document following `assets/synthesis-template.md`. The template has four sections: **themes** (with papers, consensus, disagreement), **empirical coverage table**, **gap map** (with types), and **grounded opinions**.

Default location suggestion: `synthesis-{date}.md` at the project root or wherever the user has been keeping literature notes. Honor any path the user specifies.

## Important discipline

- **Ground every claim in a citation to a specific paper's notes.** "Most papers do X" is a synthesis claim; it needs to be backed by specific notes you read. If you catch yourself generalizing without a citation, stop and check.
- **Don't invent consensus or disagreement that isn't in the notes.** If the notes don't say how a paper handled contamination, don't claim "all papers ignore contamination". Say "contamination is not addressed in any of the notes I have" — which is a different (and weaker, and honest) claim.
- **Do not pull from training data.** Use only the papers in the user's notes. If the user asks "is there prior work on X?" and X isn't in the notes, say so rather than guessing from memory. Offer to go read relevant papers.
- **Name the papers you didn't include.** If the user's note set is missing obvious adjacent work, flag it as "this synthesis may be undersampled in area Y". Don't silently paper over gaps in the user's reading.

## When the note set is small

With fewer than ~5 papers, don't force themes — it will read as overfitted. Instead, write a simpler output: a short paragraph per paper with one-line position, one cross-cutting observation, and an explicit flag that this is too small a sample to draw structural conclusions. Recommend reading more before calling it a synthesis.
