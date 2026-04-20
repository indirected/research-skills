---
name: design-experiments
description: |
  Use this skill when the user is designing the empirical evaluation of an ML / AI /
  NLP paper — choosing datasets, baselines, metrics, ablations, compute budget, and
  the statistical protocol. Triggers on phrases like "design experiments", "what
  baselines should I use", "design ablations", "evaluation protocol", "how should we
  evaluate X", "plan the experiments section", "what should we measure". Make sure
  to use this whenever the user shifts from framing the problem to planning how to
  show the claim holds — even if they only mention one piece (e.g. "which baselines
  do I need").
---

# Design Experiments

Plan an evaluation that will actually support the paper's claim — fair, reproducible, ablation-rich, variance-aware, and honest about what it does and doesn't measure.

## Why this is a hard skill

Most evaluations fail in ways that are visible in hindsight but invisible while you're designing them:

- **The data doesn't match the claim.** You claim X works "on natural images" but evaluate only on CIFAR. You claim X generalizes but evaluate only in-distribution.
- **The baselines are strawmen.** A newer, stronger method from the same family exists but wasn't run. A trivial non-learned baseline would solve 80% of the problem — and wasn't tried.
- **The comparison is tilted.** Your method is tuned on 64 configurations; the baseline is run once with default hyperparameters.
- **Variance is hidden.** A single seed, a single prompt, a single hyperparameter — and the apparent improvement is within noise.
- **Contamination invalidates the result.** The benchmark was in pretraining data; the LLM "knows" the test set.
- **The ablations test the wrong thing.** You ablate components that you already know matter, and don't ablate the choices that are actually load-bearing.
- **The metric measures something adjacent.** Exact-match on a task where paraphrases are right; LLM-as-judge on a task where the judge has known biases; accuracy on a dataset with label errors.
- **The protocol is not reproducible.** Seeds, prompts, versions, compute, all under-specified.

Designing well means spending time *before* running experiments on the questions that are very expensive to answer *after*.

## When to invoke vs. defer

Use this skill when the user is planning the experiments for a paper (or a significant ablation study / rebuttal experiment). Do not use it for:
- **Running** the experiments (that's execution — handle inline if needed)
- **Analyzing** results after they're in (handle inline or invoke `write-paper` for the experiments section)
- **Reviewing** an existing experimental design (invoke `review-paper`)

## Design protocol

Work through the dimensions below. You don't need to hit every one every time, but you should have an *answer* for every one, even if the answer is "N/A here, and here's why".

### 1. What claim are you evaluating?

Start from the problem statement (use `frame-research` output if available). The evaluation must map onto specific falsifiable claims. For each claim in the contribution list, write down:
- **What result would count as evidence for it?**
- **What result would count as evidence against it?**

If you can't answer both for a claim, the claim isn't falsifiable and the evaluation can't support it. Go back to `frame-research`.

### 2. Choose datasets — real over synthetic, and why

Defaults:
- **Real datasets** beat synthetic. Keogh's argument: you cannot control the dataset and the method both; one of them has to be independent. If you made the data, you can (consciously or not) cherry-pick it to favor your method.
- **Standard benchmarks** in your field are usually worth including — they make comparisons clean and let reviewers anchor. Pick the ones your nearest prior work evaluated on.
- **Multiple datasets** beat one. A single-dataset result can be a quirk of the dataset, not a property of the method.
- **Adversarial / distribution-shift** sets matter when your claim includes generalization. If your claim is in-distribution only, say so and evaluate accordingly — don't claim more.

Watch for:
- **Data contamination** (critical in the LLM era — see `references/ml-evaluation-pitfalls.md`).
- **Unrepresentative size / domain.** If the claim is about real-world scale and your data is 1k examples from one domain, the claim doesn't reach that far.
- **Label error rates** in the benchmark. Widely-used benchmarks have known label errors that cap achievable accuracy — report the ceiling if it matters.

If you genuinely need synthetic data (controlled hardness, causal structure you need to know), say so and justify. Synthetic as a diagnostic complement to real data is fine; synthetic instead of real is a red flag.

### 3. Choose baselines — the fair way

A baseline is fair when it is given the same opportunity your method got. Anchor on these:

- **A trivial / non-learned baseline.** Majority class, random, nearest-neighbor on raw features, a one-line heuristic. If this works, your method needs to work more-better; if you don't report it, reviewers will wonder. Keogh's crop-type example: `sum(x) > 2700` got perfect accuracy — check this for your problem.
- **The strongest method from your family** — not the oldest or most-cited, the strongest. If your field moved past method X five years ago, method X is a strawman.
- **An adjacent method** from a different family that could conceivably solve the same problem.
- **An ablated version of your own method** (belongs partly here, partly in ablations — see below).

Fair-comparison rules:
- **Same tuning budget** across methods. If you ran 64 configs for your method, don't run 1 config for baselines. If baseline configs are expensive, use a smaller budget for your method too, or state the asymmetry.
- **Same evaluation protocol.** Same prompts, same seeds distribution, same metric definitions, same test split.
- **Same compute envelope** when claiming efficiency. Comparing a 7B model to a 70B model on quality isn't a quality comparison.
- **Closest prior work must be cited and compared to.** If you can't reproduce it, say so explicitly and explain why (missing code, missing data, ambiguity).

### 4. Choose metrics — and know what they don't measure

Pick metrics that your *claim* needs, not just the ones your field uses by default. For each metric, ask:
- What does this metric actually reward? What can get a high score while being wrong?
- What noise floor does it have? Is a 0.5-point improvement signal or noise?
- What's the ceiling? (Label error, task ambiguity, judge noise.)
- Is this metric itself contested? If LLM-as-judge, is it calibrated? If pass@k, is k principled?

Report **multiple metrics** when possible; a single number can hide a lot. If metrics conflict (method A wins on metric P, method B wins on metric Q), that's a finding, not a problem — write it up.

See `references/ml-evaluation-pitfalls.md` for specific traps (LLM-as-judge biases, contamination in benchmarks, prompt-sensitivity on evals, etc.).

### 5. Choose ablations — test what's load-bearing

An ablation is useful when it answers: **"if I remove / change component C, does the claim still hold?"**

Principles:
- **Ablate the choices that would be most surprising if they didn't matter.** If your method has 5 components and you can predict in advance which 3 are important, ablating those 3 is less useful than ablating the 2 whose role is unclear.
- **Include "degrade" and "substitute" ablations, not just "remove".** Replace component C with a simpler version. Replace component C with a random version. Sometimes "substitute with random" reveals that C isn't doing what you thought.
- **Ablations must be honest.** If removing component C makes the method run differently in a way that confounds the ablation (e.g., also changes memory usage in a way that affects batch size), state that — don't hide it.
- **Negative ablations are publishable.** If you try an ablation and the component doesn't matter, that's a useful finding that belongs in the paper (or at least the appendix). Don't silently drop ablations that weaken the story.

### 6. Design the statistical protocol — variance and significance

Single-number results are not credible anymore. For each experiment, plan:

- **Number of seeds / runs** — at minimum 3, usually 5, sometimes more if the effect is small.
- **How to report variance** — mean ± stddev, mean ± 95% CI, full distribution. Pick one and stick to it.
- **Statistical test** (when claiming superiority) — paired t-test, bootstrap CI, Wilcoxon, etc. Pick one appropriate to the data; justify briefly. Keogh's note: "significant" in a paper should mean "statistically significant at a confidence level of X", never used as an informal synonym for "better".
- **How you'll handle multi-seed variance in closed models** (where seeds don't apply cleanly) — see `references/ml-evaluation-pitfalls.md`.

Keogh's example: sampling 16 American males and 16 Chinese males, but one of them is Yao Ming. Without variance, the mean is misleading. Report the variance.

### 7. Justify every parameter

For every hyperparameter, tunable choice, or arbitrary number in your pipeline, you need one of:

- **A principled way to set it** — theoretical justification, validation-set tuning, a known rule of thumb with citation.
- **Evidence it doesn't matter** — sensitivity analysis showing the result is stable across a range.

If neither holds, the parameter is magic. Magic numbers make reviewers suspicious and kill reproducibility. Keogh: "With four parameters I can fit an elephant, and with five I can make him wiggle his trunk."

This includes:
- Model size / dataset size / context length choices.
- Prompt choices (LLM-era specific — see pitfalls ref).
- Temperature / sampling settings.
- Hand-picked decision thresholds.
- "We use N=100 because..."

### 8. Budget — compute, time, and annotation

Before committing, estimate:
- **Compute cost** — GPU hours or API cost, across all methods × seeds × datasets × ablations. Multiply by a factor for unexpected reruns.
- **Wall-clock time** — does this finish before the deadline?
- **Annotation budget** — if you need human labels or expert review, what's the cost and who's doing it?

If the plan blows the budget, cut ruthlessly and name what was cut (you'll need to defend the cut in `review-paper` / reviewer response). Common cuts: fewer seeds (risk: noisier results), fewer baselines (risk: gaps in comparison), fewer datasets (risk: narrower generalization claim). Never cut the variance reporting or the trivial baseline.

### 9. Reproducibility checklist

Plan to capture, from the start:
- Exact random seeds used.
- Exact prompts / templates (if LLM-based) with version control.
- Exact model versions / checkpoints / API timestamps (closed models drift — record when you called them).
- Exact data splits (how you split, with what seed).
- Exact hyperparameter sweeps (full grid or sample, not just the winning config).
- Exact compute — hardware, software versions, library versions.
- Code and data release plan (if blind review, how).

Keogh: "Assume you lose all files. Can you recreate all the experiments from the paper? Really really think about this."

### 10. ML / AI / NLP-era specific pitfalls

For anything evaluating an LLM, a fine-tuned model, or an agent-style system, **read `references/ml-evaluation-pitfalls.md`**. It covers:
- Data contamination (most important).
- Benchmark saturation and overfit.
- LLM-as-judge calibration and biases.
- Prompt sensitivity and prompt overfit.
- Seed sensitivity with and without access to seeds.
- Closed-model reproducibility.
- Fair compute / parameter / token comparisons.
- Training-data leakage in fine-tuning setups.
- Agentic eval specifics (trajectory length, tool-call costs, partial success).

These are the failure modes that most commonly sink an ML paper at top venues right now.

## Output

Produce an experiment plan that covers:

1. **Claims → evaluations mapping** — which experiment supports which claim.
2. **Datasets** — list, with justification, with contamination check for each.
3. **Baselines** — list, with fairness notes.
4. **Metrics** — list, with what they measure and don't measure.
5. **Ablations** — list, with what question each ablation answers.
6. **Statistical protocol** — seeds, variance reporting, significance tests.
7. **Parameter table** — every parameter, how it's set, why.
8. **Budget** — compute / time / annotation estimates.
9. **Reproducibility artifacts** — what gets captured.
10. **Known risks / open choices** — honest flags for the user to decide on.

Default file location: `experiments-plan-{date}.md` next to the code repo or at the project root. User decides. Let them edit the plan directly as decisions settle.

## Important discipline

- **Design before running.** An evaluation designed after seeing results is an evaluation that chose its own criteria — reviewers can spot this.
- **Honest over impressive.** A narrower, cleanly-supported claim beats a broader, shaky one every time at top venues.
- **Protect the trivial baseline.** The simple baseline is the single most load-bearing thing in a credible evaluation — it defends you from "you didn't try the obvious thing" and it's the cheapest experiment to run.
- **Pre-register the plan with collaborators / advisor.** Not formal pre-registration — just agreeing on the design before running, so nobody retrospectively moves the goalposts.
- **Leave room for surprises.** Plan what to do if results don't show what you expected — sometimes the surprising result is the paper, but only if you're set up to recognize it.
