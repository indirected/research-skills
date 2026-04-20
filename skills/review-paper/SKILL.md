---
name: review-paper
description: |
  Use this skill when the user wants an adversarial self-review of their own paper draft
  before submission, or wants to think like a reviewer about a paper (their own or
  someone else's) to find weaknesses. Triggers on phrases like "review my paper",
  "self-review", "what would a reviewer say", "pre-submission check", "find weaknesses",
  "stress test this paper", "would this get rejected", "do a reviewer pass", "internal
  review". Make sure to use this skill whenever the user wants reviewer-style critique
  on a complete or near-complete draft. Use review-paper for finding problems; use
  write-paper for fixing them; use respond-to-reviews for the rebuttal *after* external
  review.
---

# Review Paper

Read the user's paper as a careful, slightly-cynical reviewer at a top venue would. The goal is to find every reason the paper might be rejected before reviewers do, and to convert each into a concrete fix the user can act on.

## Why this is a hard skill

Self-review is hard for the author because:

- **You know what you meant.** You read your own ambiguity as the intended meaning. Reviewers don't get that.
- **You know the result is real.** You don't notice when the evidence isn't presented in a way that *proves* it.
- **You're invested.** You want the paper to look strong; you skim past the parts that look weak.
- **You're tired.** By submission week, the paper has been read 50 times; the brain has stopped registering the prose.

A skill-driven review forces a structured sweep that a tired co-author would do well, finding things you've stopped seeing.

## The reviewer's mindset

Internalize these before reading the paper:

- **The reviewer has 6 papers tonight, started at 11pm.** They will not work hard to understand you. Anything ambiguous reads as wrong.
- **The reviewer's default is reject.** Top venues accept ~25% of submissions. The null hypothesis is "this paper has a flaw"; it's the author's job to disprove it.
- **The reviewer has seen this kind of paper before.** Generic claims, hand-waved comparisons, single-seed numbers all pattern-match to weak papers they've previously rejected.
- **The reviewer knows the field.** A claim of "first to do X" can be falsified instantly if the reviewer has read paper Y.
- **The reviewer respects honesty.** A clearly stated limitation buys far more trust than a glossed weakness.

Read the paper assuming the reviewer is bright, busy, and skeptical. That's the actual audience.

## The Top-10 rejection-reason sweep

Most rejections at top venues fall into a small number of patterns. Read `references/top-10-rejection-reasons.md` for the canonical list (drawn from Keogh's SIGKDD-09 tutorial, expanded for the modern ML era). The top-10 covers:

1. The problem doesn't really exist (no one needs this).
2. The problem has been solved.
3. Unfair / strawman comparison to prior work.
4. Unjustified parameters or arbitrary choices.
5. The first-page anchor fails (abstract / intro / first figure don't sell the contribution).
6. Hidden assumptions or constraints that limit applicability.
7. Overclaimed / underqualified results.
8. Reproducibility gaps (missing seeds, prompts, versions).
9. Carelessness signals (typos, broken figures, missing references).
10. Adversarial or dismissive tone toward prior work.

Use this list as a structured checklist; for each, ask "is this paper at risk on this dimension?" If yes, drill into the reference for the diagnostic and fix patterns.

## The ML-era pitfalls sweep

In addition to the universal rejection reasons, modern ML papers have specific failure modes that reviewers focus on:

- **Data contamination** — does the benchmark overlap with pretraining data?
- **LLM-as-judge biases** — is the metric calibrated; does it have known biases?
- **Prompt sensitivity** — was the prompt tuned on the test set; how robust is the result to prompt variation?
- **Seed sensitivity** — are results reported with variance across seeds (or sampling for closed models)?
- **Closed-model reproducibility** — exact API versions, timestamps?
- **Compute-fairness** — is the efficiency / quality comparison made at matched compute / parameters / cost?
- **Cherry-picked test-set tuning** — were hyperparameters (or prompts, or chain-of-thought variations) selected on the test set?
- **Multi-task hidden losses** — is "average over 15 tasks" hiding wins on 9 and losses on 6?

For these, read `design-experiments/references/ml-evaluation-pitfalls.md` (the canonical reference, shared with the design skill — see Cross-references at end). Each pitfall has a "how to check" section that translates directly into review questions.

## Review protocol

Work through the paper section by section, with an explicit pass per dimension. Don't try to do everything at once — the brain misses things in unstructured reads. The order below mimics the reviewer's actual reading order.

### Pass 1 — First-page anchor

Read **only**: title, abstract, intro (first paragraph), first figure (if any).

Ask:

- After reading the title alone, do I have a guess at what the paper's about?
- After the abstract, can I say in one sentence what the paper claims?
- After the first paragraph, am I oriented (problem, why-hard) or hedging?
- If there's a page-1 figure, does it convey the contribution or just the problem? Is it self-explanatory?
- What's my impression of the paper's quality? (Be honest — this impression sticks for the rest of the read.)

If the answers are weak, the rest of the paper is starting at a deficit. Note this as the highest-priority issue.

### Pass 2 — Claim ↔ evidence map

Read the contributions list at the end of the intro. For each contribution, find:

- Where in the paper is the evidence for it?
- Is the evidence sufficient to support the claim as stated?
- Is the evidence adversely affected by any of the ML-era pitfalls?
- Does the claim overstate what the evidence shows?

Build a small table mentally: contribution → evidence → status (supported / overclaimed / unsupported).

### Pass 3 — Method clarity

Read the method section. Ask:

- Could I implement this from the paper alone? What would I have to guess?
- Are all design choices justified? Mark every undefended choice as a parameter audit issue.
- Is there a hidden component that's load-bearing but glossed?
- Is the method made to look more novel than it is?
- Is the method made to look less novel than it is (i.e., is the contribution buried in irrelevant complexity)?

### Pass 4 — Experimental rigor

Read the experiments section. Ask:

- Are baselines fair? Same tuning budget? Same prompts? Same compute envelope?
- Is variance reported? Across how many seeds / samples?
- Are spurious significant digits used?
- Where are the failure cases discussed?
- Is the trivial / non-learned baseline included? If not, why not?
- Is there a hidden cherry-pick (subset of benchmarks where method wins)?
- For each ML-era pitfall, has the paper either avoided it or named it?

### Pass 5 — Related work fairness

Read the related work. Ask:

- Are the closest neighbors cited? (List the 5 most-similar papers from your knowledge of the field; check.)
- Is concurrent work (within ~3–6 months) acknowledged?
- Is the differentiation concrete (one falsifiable sentence per close neighbor) or hand-waved ("unlike X, we...")?
- Is the tone gracious or adversarial? Adversarial framings undermine the paper.

### Pass 6 — Reproducibility audit

Across the whole paper plus appendix, check:

- Exact seeds, prompts, versions, hyperparameters present?
- Code release planned? URL placeholder filled in?
- For closed models: exact API versions and call timestamps?
- Hyperparameter sweeps fully reported, not just the winning config?
- Compute reported (GPU hours / API cost)?

If you would struggle to reproduce, the paper has a reproducibility gap.

### Pass 7 — Polish and signaling

Skim for:

- Typos, broken cross-references, missing figures, empty cells in tables.
- Inconsistent notation across sections.
- Acronyms not defined on first use.
- Citations rendered as `[?]` or with malformed bib entries.
- Inconsistent formatting (different fonts, sizes).

These are not the substance of the paper, but they're carelessness signals — and reviewers transfer carelessness in writing to suspicion of carelessness in research.

### Pass 8 — Self-questioning

Pretend you are the most cynical reviewer. Ask:

- "If I wanted to reject this paper, what would I attack?" Find the 3 strongest attacks.
- "What's the one experiment that would settle whether the claim is real?" Did the paper run it?
- "What would I want to see in the rebuttal that the paper hasn't preempted?"
- "Is the contribution larger than the easy sneer? (It's just X with Y added.)" If the sneer is plausible, the paper needs to preempt it.

Write down the attacks as if you were the reviewer. Your future rebuttal will need to address them — better to know them now.

## Output: the prioritized issue list

Use `assets/review-report-template.md` as the format. The output is a single document with:

1. **Headline assessment.** One paragraph: would you accept, reject, or major-revision this? With reasoning.
2. **Critical issues.** Things that would lead to rejection if not fixed. Each with: where it is, what's wrong, suggested fix.
3. **Major issues.** Things that would substantially weaken reviewer enthusiasm. Same format.
4. **Minor issues.** Carelessness, polish, small ambiguities.
5. **Things the paper does well.** Genuinely — every paper has strengths; naming them helps the user prioritize what *not* to change in the fix pass.

Issues should be **specific**: "Section 4.2 reports 67.3% on a 100-example test set; the third digit overstates precision" beats "report fewer significant digits".

## Severity calibration

- **Critical**: a top-venue reviewer would mark this as a reject reason. Examples: unjustified comparison, contamination not addressed, overclaimed result, missing baseline.
- **Major**: would substantially lower the reviewer's score even if not a reject. Examples: weak intro framing, hand-waved related work, weak ablations.
- **Minor**: would not directly affect the score but adds friction. Typos, polish, small ambiguities.

When in doubt about severity, err on the side of higher — better to flag and have the user dismiss than to miss a critical issue.

## Important discipline

- **Read the actual paper, not what you imagine the paper says.** If the paper isn't on disk, ask the user for the file. Don't review from a description.
- **Cite line / section / figure references** for every issue. The user needs to find what you're flagging.
- **Suggest fixes, not just problems.** "This is unfair" without "here's how to make it fair" is half a review.
- **Don't over-correct on tone.** This is the user's paper. Critique their argument, not their style preferences. Style suggestions go in minor issues.
- **Acknowledge what's good.** A bare list of problems is demoralizing and unhelpful for prioritization. Name strengths so the user knows what to preserve.
- **Don't bluff.** If the user's paper is in a subfield you're shaky on, say so and stick to checks you can do reliably (clarity, structure, claim-evidence mapping, ML pitfalls). Don't fabricate references to "prior work that did this".

## Cross-references

- `references/top-10-rejection-reasons.md` — the canonical rejection-reason list, with diagnostics and fix patterns per item.
- `design-experiments/references/ml-evaluation-pitfalls.md` — shared with the design skill; canonical reference for ML-era evaluation pitfalls. Read from this file when doing the ML-pitfalls sweep.
- `assets/review-report-template.md` — output template for the prioritized issue list.
- `Keogh_SIGKDD09_tutorial.md` (in repo root) — the underlying tutorial that several principles are drawn from. Read for deeper context on any principle.
- For fixing the issues, hand off to `write-paper` (or `design-experiments` if the fix requires new experiments).
