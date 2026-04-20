---
name: read-paper
description: |
  Use this skill whenever the user wants to deeply read, understand, or extract the
  real contributions from an academic paper — whether to inform their own work, write
  related-work prose, or prepare for literature synthesis. Triggers on phrases like
  "read this paper", "what's this paper actually saying", "extract the claims from
  this paper", "deep-read", "summarize this paper", "what are the real contributions
  of...", or when a PDF / arXiv URL / paper title is handed over with any critical-
  reading intent. Make sure to use this whenever the user points at a paper and wants
  more than a skim — even if they don't say the words "read" or "synthesize".
---

# Read Paper

Deep reading of a single academic paper — the kind of reading that lets you later write a sharp sentence about the paper's real contribution, know what it actually proves versus gestures at, and position your own work against it honestly.

## Why this is a hard skill

Most skimming produces a plausible-sounding summary that quietly distorts the paper. The distortions come from specific, fixable errors:

- **Taking the abstract at face value.** Abstracts sell; they overstate, omit caveats, and sometimes describe a method that isn't quite what the paper delivers.
- **Confusing what's new with what's loaded in.** Papers layer several ideas — a new architecture, a new dataset, a new evaluation protocol. Some are genuinely novel; others are borrowed. Without care you'll credit the paper for things other people did.
- **Treating results as a single number.** "96.4 on MMLU" hides: which split, which prompt, which baseline comparison, which seeds, what variance, whether the authors used the test set during development.
- **Missing the hidden assumptions.** Nearly every paper depends on assumptions the authors don't flag — a particular data distribution, a bounded sequence length, closed-world classes, English only, single-turn interaction. Finding these matters because they predict when the method breaks.
- **Stopping at the paper's own framing of its limitations.** Authors write limitation sections to pre-empt reviewer complaints — not to surface the deeper weaknesses. Your job is to name what they didn't.

Deep reading is the discipline of doing the work the authors didn't do for you.

## When to invoke vs. skim

A skim is fine when you only need to know *what the paper is about* — "does this paper exist in my space?". Invoke this skill when any of these are true:

- You might cite it in your own paper and want to get the characterization right.
- You're synthesizing across several papers and need consistent structured notes.
- The paper is directly adjacent to your contribution and you need to differentiate cleanly.
- You suspect the paper overclaims and you want to know exactly where.
- You're trying to reproduce or extend the method and need the real recipe, not the advertised one.

## Reading protocol

Work through the paper in this order. You do not need to read linearly — authors don't write linearly — but you do need to produce each piece of the output.

### 1. The single-sentence problem statement

Before extracting anything else, write in one sentence what problem the paper solves and in what context. Follow the Keogh pattern: **X is good for Y (in the context of Z)**, or **An X approach to Y mitigates the need for Z**.

If you cannot write this sentence from the abstract and introduction, the paper itself may be at fault — note that as a reading finding (a paper without a clear problem statement is usually a weak paper).

### 2. The real contribution, decomposed

Papers typically claim a bundle. Unbundle it. For each claimed contribution, answer:

- Is this **genuinely new**, or is it **reused from prior work** (with or without attribution)? Name the precedent if you know it.
- Is it **conceptual** (a new idea, framing, or theorem), **methodological** (a new technique), **empirical** (new results on existing methods), or **artifact** (a new dataset, benchmark, or tool)?
- What specifically is different from the closest prior work? A single concrete difference is more useful than a paragraph of hedging.

Be honest: if the paper's "contribution" is three prior ideas in a new combination, say so. That's still a contribution, but it's a different one than "novel technique".

### 3. The method, in plain words

Describe the method so that someone who didn't read the paper could implement the scaffolding (not every hyperparameter). Flag:

- Any step the paper glosses over. Name the paragraph or section where it's under-specified.
- Any step that depends on a trained component or external resource (a specific model, a proprietary dataset, a hand-labeled anchor set).
- Any step that looks simple but hides a critical choice (e.g., "we use cosine similarity" — on what embeddings? projected how?).

### 4. Assumptions the paper relies on but doesn't flag

List the preconditions for the method to work. Examples:

- Data is in English / Unicode / a specific format.
- Sequences are bounded by some length.
- Classes are closed-set / there are no ambiguous labels.
- A teacher model of a specific capability tier is available.
- The environment is static / the agent is the only actor.
- The distribution at test time matches training.

Ask: if any one of these were violated, what would happen to the claims?

### 5. Falsifiability audit of the main claims

For each major claim, answer:

- **Is it falsifiable in principle?** "We improve performance" is not falsifiable without a metric, direction, and context. "Method X statistically significantly outperforms baseline Y on benchmark Z at p<0.05" is.
- **What evidence does the paper provide?** Tables? Ablations? Proofs? Case studies? Cite the specific figure / table / theorem.
- **How strong is the evidence?** Statistically significant over enough seeds? A single run? A cherry-picked example? An unverified assertion?

Call out any claim that's unfalsifiable, vague, or supported only by rhetoric.

### 6. Evaluation fairness check

Keogh's "be fair to rivals" principle reversed: look at how the *paper* treated its rivals.

- Does the paper test one configuration of the baseline against many configurations of its own method? (Common, and usually silent.)
- Are baselines tuned with the same budget as the proposed method?
- Are baselines from the right families, or strawmen (compare to SOTA, not to the 2018 method)?
- Is a simple non-learned baseline included? (Often missing and often competitive.)
- ML-era specific: any risk of **train/test contamination** (data seen during training, especially for closed LLMs)? Any signs of **prompt overfit** (different prompts per method)? Any **unreported seeds** or **single-seed results**?

### 7. Limitations the authors didn't state

The limitations section is usually defensive. Your job is to name the ones they didn't. Consider:

- **Generalization** — what population of data / tasks / domains was this actually validated on? What falls outside?
- **Cost** — what compute / API / human annotation does the method require? Reported? Fair to the baselines?
- **Reproducibility** — is code released? Data released? Are seed, prompt, and hyperparameter details explicit enough to re-run?
- **Dependence on a specific model / dataset** — would the method survive if the underlying LLM or dataset changed?

### 8. Position vs. the user's own work (if applicable)

If the user has told you about their own project, close with: how does this paper relate?

- Does it **enable** the user's work? (A building block they can cite.)
- Does it **compete** with the user's work? (Overlapping contribution — note the specific differentiation.)
- Does it **challenge** the user's work? (A result or claim that undermines an assumption the user is making — flag urgently.)
- Is it **orthogonal**? (Interesting but irrelevant — say so, don't pad related work with it.)

If the user hasn't given you their own project context, skip this section.

## Output

Produce structured reading notes following `assets/reading-notes-template.md`. The template keeps notes consistent across papers so they flow cleanly into `synthesize-literature` later, but the user decides where to save the file. Suggest a filename like `notes-{author}-{year}-{shortslug}.md` and a default location like `literature/` or wherever the user has been saving notes, but honor any path they give.

## Important constraints

- **Work from the PDF / arXiv / HTML, not from your training data.** Training-data summaries silently hallucinate details that feel right but aren't in the paper. If the user gave you a URL, fetch it; if they gave you a path, read it; if they gave you a title with no source, ask for the PDF or URL rather than guessing.
- **Cite specific locations** (section number, figure/table number, page). "The method description in §3.2" is useful; "the paper says" is not.
- **Quote sparingly** — a few precise quotes for claims that are about to get contested, not long passages. Your reading notes are for the user, not for showing off that you read the paper.
- **Don't hide uncertainty.** If you can't tell whether the paper's main claim holds, say so in the notes. Silent glossing is worse than admitting a gap.

## When the paper is long, dense, or multi-part

For a paper with heavy appendices, you usually need to read the appendices for the real recipe — main body glosses, appendix specifies. Flag any section where the main body's description materially understates what the appendix reveals (this is a reproducibility concern worth naming).

For a paper that bundles multiple contributions (a dataset + a method + a benchmark), write separate entries for each in the contributions section — they often have different novelty and different evidence.
