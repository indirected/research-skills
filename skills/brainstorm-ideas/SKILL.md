---
name: brainstorm-ideas
description: |
  Use this skill when the user wants to generate research ideas — next-paper
  candidates, directions out of a stuck experiment, hypotheses off a literature
  synthesis, or a response to an unexpected result. Triggers on phrases like
  "brainstorm research ideas", "what should we work on next", "generate
  hypotheses", "next-paper ideas", "I'm stuck, what could we try", "given these
  gaps what should we do". Make sure to use this whenever the user shifts into
  generative mode about a direction — not when they are sharpening a single idea
  (that's frame-research) and not when they are reasoning about existing work
  (that's synthesize-literature).
---

# Brainstorm Ideas

Generate candidate research ideas that are **novel, important, and tractable** — and surface them in a form the user can evaluate quickly.

## Why this is a hard skill

Ideation fails in two predictable ways:

1. **Incremental noise.** A list of ten ideas that are all "X but with a different dataset" or "X but slightly bigger". Each one might be publishable, none are interesting. The author has to choose and usually picks the wrong one because they all look similar.
2. **Grandiose vaporware.** A list of ten ideas that would each be a five-year program, nobody can tell which is tractable, and none get started.

The discipline is to generate ideas along **principled axes** (so you cover the actual space, not just the ones that come to mind), then **audit each for falsifiability, importance, and tractability** before handing them to the user. A shortlist of 3–5 grounded ideas is more useful than 20 unaudited ones.

## Inputs

The user may give you one or more of:

- A **literature synthesis** (preferred — has gaps already typed and reasoned about)
- A set of **reading notes** on individual papers
- An **unexpected experimental result** ("we ran X and got Y — what does that open up?")
- A **stuck situation** ("we can't get Z to work — what's the alternative framing?")
- A **domain observation** ("a collaborator just told us Q — does that suggest anything?")
- Nothing specific — just "help me think about next papers in area W"

If the user has none of the above and just wants pure ideation in an area, that's fine — but the quality of ideas you'll generate is capped by how much grounding you have. Say so and offer to read/synthesize first if the timeline allows.

## Generation protocol

### 1. Orient — what's the situation?

One short paragraph: what's the user's project, what do they already have, what's the near-term goal (next paper? next experiment? a pivot?). If the user hasn't said, ask them; do not fabricate context.

### 2. Generate along principled axes

Use Keogh's extension axes, plus a few ML-era additions, as prompts — not as categories the user needs to fill. Each axis is a different *lens* on an existing idea or an existing gap:

**Capability axes (take an existing method X and extend it):**
- Make X more **accurate** — and meaningful improvement usually means statistically significant on a held-out benchmark the field trusts.
- Make X **faster** — usually an order of magnitude or no one cares.
- Make X **cheaper** — in API calls, tokens, parameters, training compute, human labels.
- Make X an **anytime** or **interruptible** algorithm.
- Make X **online / streaming** — process data as it arrives, not in batch.
- Make X **distributed** — across devices, nodes, agents.
- Make X work on **low-powered** or **edge** devices.
- Make X **simpler** — remove a parameter, remove a training phase, remove a dependency.
- Make X **explain why it works** — mechanistic understanding of a black-box success.

**Domain / scope axes (take an existing method X and redirect it):**
- Apply X to a **different data type** (text → code; English → other languages; text → multimodal).
- Apply X to a **different task** (classification → generation; single-turn → multi-turn; single-agent → multi-agent).
- Apply X in a **novel setting** (industrial, low-resource, safety-critical, high-stakes).
- **Remove a parameter / assumption** X relies on.
- **Disk-aware** / memory-bounded version of an in-memory method (still relevant for very large models).

**Foundational axes:**
- **Problem relaxation** — if X is too hard, solve an easier version and publish that; revisit the hard one once you understand the easier.
- **Looking to other fields** — data mining from signal processing, interpretability from neuroscience, agents from economics, evaluation from psychometrics. The solution to an AI problem often lives in a field no AI researcher is watching.
- **Eliminate simple ideas first** — before proposing anything complex, ask "what's the one-line baseline everyone forgot to try?" If it works, that's a paper ("the simplest way to get results this good"). If it doesn't, that's evidence the problem is real.

**ML-era specific axes:**
- **Robustness** — how does X behave under distribution shift, adversarial inputs, noisy labels, contamination?
- **Evaluation** — if everyone uses benchmark B, is B measuring what we think? Can we build a harder B'? A diagnostic suite?
- **Contamination** — is the "SOTA" on benchmark B actually SOTA, or is B in pretraining data?
- **LLM-as-judge reliability** — if the field uses LLM-as-judge for a metric, is it calibrated? Is it sensitive to the target's style rather than quality?
- **Inference-time vs. training-time** — can X move from fine-tuning to prompting (or vice versa)?
- **Scale** — does X's behavior change across model sizes / context lengths / data scales in a way that reveals something?

You do not need to hit every axis. You need to hit enough axes that you're not just generating variations on one theme. Aim for ideas spread across at least 3–4 axes.

### 3. For each candidate idea, audit it

Before handing to the user, check each idea against three filters:

**Falsifiability:**
- Can you state the contribution as "X is good for Y in context Z", or "X achieves Y on Z"?
- What experiment would *disprove* the idea? If you can't name one, the idea isn't a research idea yet — it's a direction.

**Importance:**
- Who cares if the idea works? Name the constituency. "Researchers in area W" is OK; "everyone who uses LLMs" is usually hand-waving.
- Keogh's test: can you imagine a one-sentence dollar, time, or scientific-progress estimate of the value?
- Does it answer a real question (ideally one named in the synthesis or in the user's frustration), or is it a problem you invented so you could solve it?

**Tractability:**
- Can you imagine the minimum-viable experiment that would give evidence for / against? Can that experiment be run in the user's time and compute budget?
- What's the hardest sub-problem? Is there a known technique that makes it tractable, or is it speculative?
- What could kill the idea mid-flight (a dataset that doesn't exist, a dependency on a model that's gated, a labeling burden that's too large)?

If an idea fails any filter, either **reshape it** (more specific claim, narrower scope, different evaluation) or **drop it**. Present only ideas that pass.

### 4. Build the shortlist

Aim for **3–5 audited ideas**. More than that and the user can't pick. Fewer and you might be biased toward a pet direction.

Rank them. Not by "which do I like most" — by a joint sense of **novelty × importance × tractability**. Label each idea with a crude tag: `high-upside / high-risk`, `safe / incremental`, `stretch`, `opportunistic` (leverages a specific thing the user already has). The user picks; you're surfacing, not deciding.

## Output

Present the shortlist in-conversation first — do not write to a file until the user has seen the list and reacted. For each idea, include:

- **One-sentence pitch** (falsifiable form)
- **Why it matters** (who cares, what's the payoff)
- **The minimum-viable experiment** (what to run to get evidence)
- **Closest prior work** (so the user can see differentiation)
- **Risk / effort tag**

Once the user selects ideas they want to keep, offer to save them — but let the user name the file and location. A natural next step is `frame-research` to sharpen whichever idea the user picks.

## Important discipline

- **Don't fabricate prior work.** If you claim "nobody has done this", you need to have read or seen notes on the adjacent literature. Otherwise say "I haven't seen this done in the notes I have — worth a literature check" — which is a different, honest claim.
- **Don't punt by listing twenty variations.** The user needs to pick; your job is to narrow, not to dump possibility space. If you find yourself generating the fifteenth variant of "X + retrieval", stop and look at other axes.
- **Don't mistake novelty for importance.** Something novel nobody needs is not a good research idea. Importance beats novelty.
- **Flag ideas that overlap with the user's stated work.** If the user said in `project.md` or in the conversation "we're working on Y", and a brainstormed idea looks like Y+ε, note that — the user may want genuine alternatives, not extensions.
- **Do not use training data as an authoritative source for what's "been done".** Training data is months to years out of date and does not reflect arxiv in the last N months. Offer to check arxiv / Semantic Scholar for specific ideas the user is serious about.

## When to stop brainstorming

Stop when you have 3–5 audited ideas *and* the user has seen them. Do not keep generating once the shortlist is in the user's hands — they'll extend or ask for more if needed. Over-generating creates choice paralysis.
