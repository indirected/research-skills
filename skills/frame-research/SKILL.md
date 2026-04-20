---
name: frame-research
description: |
  Use this skill to sharpen a fuzzy research idea into a crisp, falsifiable problem
  frame — a single-sentence problem statement, a why-important/why-hard/why-unsolved
  argument, and a clean contribution list. This is the conceptual move that shows up
  in many places: motivating a paper introduction, articulating a grant's specific
  aims, naming a concrete gap from a synthesis, or converting a brainstormed idea
  into something you can actually work on. Triggers on phrases like "frame this
  problem", "sharpen the contribution", "draft a problem statement", "intro
  motivation", "grant context", "what's our thesis", "make this precise". Make sure
  to use this whenever the user has an idea or direction in hand and is trying to
  articulate its sharpest form.
---

# Frame Research

Turn a rough idea into a crisp frame: one falsifiable problem statement, a three-part argument for why it matters, and a concrete list of contributions you're prepared to defend.

## Why this is a hard skill

A fuzzy frame creates specific downstream failures:

- **The introduction loses the reviewer on page one.** Reviewers anchor on the first page (Keogh); a vague problem statement tells them the paper won't be worth careful reading.
- **Experiments don't know what they're proving.** If you can't say "method X improves Y in context Z", you can't design an experiment that would falsify it, and your results will feel disconnected from your claims.
- **The related-work section has no shape.** Without a sharp frame, prior work becomes a laundry list because you can't say how any paper does or doesn't answer your question.
- **The idea mutates mid-project.** If the frame isn't on paper, every collaborator has a slightly different one, and the scope drifts.

Framing isn't about sounding impressive — it's about making the work falsifiable early enough that you can notice when you're wrong.

## When this skill applies

Same conceptual move, many triggers:
- **New idea → working problem statement** (before starting work)
- **Introduction of a paper** (hook → problem → gap → contributions)
- **Grant application** (specific aims section, broader impacts hook)
- **Reframe when results surprise you** (the claim you set out to make isn't the one the results support — rewrite the frame to match the evidence)
- **Abstract tightening** (the abstract is a frame in 150–200 words)

If the user is trying to *generate* ideas, use `brainstorm-ideas` first. If they're trying to *review* a framing (theirs or someone else's), use `review-paper`. This skill is for sharpening a frame the user has already chosen to pursue.

## Framing protocol

### 1. Extract the one-sentence problem statement

Write the research question in exactly one sentence, following one of these Keogh patterns:

- **"X is good for Y (in the context of Z)."**
- **"X can be extended to achieve Y (in the context of Z)."**
- **"An X approach to Y mitigates the need for Z."**
- **"X enables Y by addressing Z."**

The sentence must be **falsifiable** — it must be possible in principle to design an experiment or observation that would show it's wrong. Vague verbs ("enhance", "improve", "explore") are unfalsifiable; concrete verbs tied to a measurable outcome are. If you find yourself writing "we investigate…" or "we explore…", you don't have a problem statement yet — you have a direction. Push further until the sentence names something that could be shown to be false.

Test the sentence: hand it to someone who hasn't read the paper. Can they tell you what the paper is claiming, on what, and in what setting? If not, rewrite.

### 2. Write the why-important / why-hard / why-unsolved triad

These are three short paragraphs (or three clean bullet groups) that together motivate the work. Each is a different question — don't conflate them:

**Why important?**
- Who cares if this works? Name a concrete constituency (users, researchers, an industry, a scientific program).
- What does it unlock that's not currently possible? Be specific: name the downstream use, not just "future research".
- If possible, estimate value — Keogh's test is dollars / time / lives / scientific progress. An estimate doesn't need to be a number; "this would let clinical decision support tools handle a class of input they currently refuse" is an estimate.
- Avoid the "we need to process large datasets because data is important" circular reasoning. Real importance comes from downstream, not from size.

**Why hard?**
- Why doesn't the obvious approach work? Name the obvious approach and explain what breaks.
- What makes the problem structurally difficult — not just "the search space is large", but something specific (an identifiability issue, a labeling burden, a distributional constraint, a conflicting objective).
- If there isn't a clear hardness argument, you might have a tractable problem masquerading as a research problem. That's fine — pivot the frame to "we show a simple method works surprisingly well here", which is its own valid frame, as long as you own it.

**Why unsolved?**
- If this is important and hard, why hasn't someone done it already? You need an answer, because a reviewer will ask.
- Plausible answers: the ingredients just became available (a new model capability, a new dataset); prior approaches had an assumption that no longer holds; the problem was considered adjacent to another field; the evaluation was blocked by a missing benchmark.
- Implausible answers to avoid: "no one has thought of it" (usually wrong, and even if right, is suspicious); "we're uniquely positioned" (sometimes true, but make the case concrete).

If a reviewer could read your "why unsolved" paragraph and respond "but Smith 2024 did this", your frame is fragile. Go find and read Smith 2024 before proceeding.

### 3. Build the contribution list

Decompose what you are claiming into a numbered list, typically 2–5 items. Each contribution should be:

- **Concrete** — specific enough to know whether the paper delivers it. "We show that…" / "We introduce…" / "We demonstrate…" — followed by a noun.
- **Distinct** — not overlapping with another contribution. If two contributions look like paraphrases, merge or drop.
- **Honest** — you can back it up with evidence in the paper, not gesture.
- **Positioned** — implicitly or explicitly differentiated from the closest prior work.

Common contribution types (useful for self-checking you've named what you actually have):
- A new **method** / technique / algorithm.
- A new **theoretical result** — a bound, a reduction, an equivalence, an impossibility.
- A new **empirical finding** — a phenomenon, a benchmark result, a scaling relationship, a failure mode characterization.
- A new **dataset** / benchmark / evaluation protocol / tool.
- A new **framing** — a way of thinking about a problem that turns out to be productive.

If your "contributions" include "we do a thorough empirical study" without any novel finding, that's not a contribution, it's a methodology. Find the actual finding.

### 4. Stress-test the frame

Run the frame against three adversarial readings:

- **The "simple-idea" test.** Is there a one-line method that would solve this problem? If yes, either your frame is wrong or the one-line method is your paper. Either way, address it.
- **The "does-the-problem-exist" test.** Is there a paper or technique already solving this, perhaps under a different name or in another field? Keogh's examples: comparing sequences of different lengths (solved by resampling); clustering streaming subsequences (meaningless under the framing people used). Can you name a reason to believe your problem isn't already trivially handled somewhere?
- **The "so what if you succeed" test.** Assume your contribution list is 100% delivered. Does the field move? Does the downstream application improve? If the honest answer is "a little", consider whether the frame is too narrow, or whether the contribution list undersells what you'll actually do.

### 5. (Optional) Package for the target audience

The same frame reads differently for different audiences. If the user tells you the target is a paper intro, a grant proposal, or a colleague email, adjust:

- **Paper intro:** 3–5 paragraphs, ending with a "our contributions" bullet list. First page has to anchor — opening sentence should draw the reviewer in, not define the problem abstractly.
- **Grant aims:** problem statement → specific aims (usually 2–3, each an achievable milestone, each with expected outcomes and a contingency if the obvious approach fails) → broader impact tied to the funder's priorities.
- **Elevator pitch / colleague email:** one-sentence statement, one-sentence importance, one-sentence differentiation from the closest prior work. Stop.
- **Abstract:** problem → gap / insight → approach → key result → implication, in 150–250 words.

Don't write the full section — that's `write-paper`'s job. Just shape the frame so it fits the genre.

## Output

Deliver the frame in conversation, structured as:

1. **One-sentence problem statement** (falsifiable form)
2. **Why important / why hard / why unsolved** (three short paragraphs)
3. **Contributions** (numbered list, 2–5 items)
4. **Stress-test notes** (what you checked and where the frame is vulnerable)

If the user wants it saved to a file, let them decide where. Reasonable defaults: a `framing.md` at the project root, or a section within `project.md`. Do not create a rigid directory structure.

## Important discipline

- **If the user gives you conflicting signals about the frame, surface that.** E.g., the stated contribution is "a new method", but the evidence the user describes is really "a new benchmark". Let them choose which frame to run with.
- **Write for the most cynical reviewer, not the most sympathetic one.** A frame that only works if the reader is already convinced is useless.
- **Avoid overstating.** "We prove…" is a high bar; use "we show", "we provide evidence", "our results suggest" when that's the truth.
- **Avoid weak language.** "We attempt to…" / "our method aims to…" — if you did it, say you did it. If you didn't, don't put it in the frame.
- **One frame per project.** If you find yourself writing two overlapping frames, one is wrong or the project is two papers. Force a choice early.
