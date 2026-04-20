# ML / AI / NLP evaluation pitfalls

The failure modes that most commonly sink ML papers at top venues right now. Loaded by `research-design-experiments/SKILL.md` and referenced by `research-review-paper/SKILL.md`.

Each section covers: what the pitfall is, why it matters, how to check for it, how to mitigate.

---

## 1. Data contamination

**The pitfall:** your benchmark (or part of it) was in the pretraining data of the model you're evaluating. "SOTA on MMLU" can mean "the model memorized MMLU". This is now the single most common reason an apparent result is not real.

**Why it matters:** your claim that the model "solves" the task might actually be "the model has seen the answers". A contaminated result doesn't generalize, doesn't scale to new tasks, and can embarrass you post-publication.

**How to check:**
- For closed models (GPT, Claude, Gemini) — you can't directly check pretraining, but you can:
  - Use datasets released *after* the model's training cutoff.
  - Hold out a private test set and compare results.
  - Run paraphrase / perturbation versions of the benchmark and check for degradation (contaminated examples degrade more than genuine generalization).
  - Check canary strings (benchmarks with embedded canary sequences will sometimes make models produce the canary).
- For open models — search the training data directly (many open models publish their datasets).
- For fine-tuned models — confirm your test set is disjoint from the fine-tuning data (and from the pretraining data).
- Benchmark-level: check known contamination registries (e.g., papers that audit MMLU / GSM8K / HumanEval for pretraining overlap).

**Mitigation in the paper:**
- Include a contamination analysis section.
- Report on a dataset released after the model's training cutoff.
- Where possible, include a perturbed / paraphrased version of the benchmark as a secondary measure.
- Do not silently report only contaminated benchmarks; name the risk even if you can't fully eliminate it.

---

## 2. Benchmark saturation

**The pitfall:** the benchmark has been beaten so hard that the top-of-leaderboard differences are within noise, label-error floor, or eval artifacts. You claim SOTA; reviewers see "0.3 points above the previous SOTA" and shrug.

**Why it matters:** a saturation-ceiling result is not a general capability claim.

**How to check:**
- What's the label-error rate of the benchmark? (MNIST, IMDB, some common NLP benchmarks have non-trivial label error — you can't generalize past that ceiling.)
- What's the gap between top-tier methods? If it's small, is your improvement statistically significant over multiple seeds?
- Is there a newer benchmark the community uses for exactly this reason (e.g., MMLU-Pro, BBH, not MMLU)?

**Mitigation:**
- Move to a harder / newer benchmark, or a suite.
- Report on multiple benchmarks.
- When reporting small improvements, put them in context (significance test, comparison to label-noise floor).

---

## 3. LLM-as-judge calibration and biases

**The pitfall:** you use an LLM to grade outputs. The LLM has systematic biases — it prefers longer responses, its own writing style, responses with specific formatting, responses that agree with its own prior outputs. Your metric measures "what this judge likes", which is not what you claimed.

**Why it matters:** an LLM-judged improvement can be real quality, or it can be style / length / sycophancy. If reviewers ask you which, you need an answer.

**How to check:**
- Run a human eval on a subset and compute agreement between judge and humans. Low agreement = judge is not reliable for this task.
- Check for length bias: does the judge prefer longer outputs even when shorter would be correct? Compute correlation between length and judge score.
- Check for positional bias (in pairwise judging): does the judge prefer whichever response is shown first / second? Randomize presentation.
- Check for self-preference: does the judge prefer outputs from its own family? Use a different judge and see if results flip.
- Check for format bias: do outputs with markdown / bullets score higher than equivalent plain text?

**Mitigation:**
- Use multiple judges from different families and report average; report disagreement.
- Pair with human eval on a subset (even 50 examples helps).
- Ensure pairwise comparisons are randomized.
- Control for length / format when the metric allows.
- Don't use LLM-as-judge as the sole metric for subjective tasks; pair with automatic metrics where possible.
- Release the judging prompt — judges are highly prompt-sensitive.

---

## 4. Prompt sensitivity and prompt overfit

**The pitfall:** your results depend heavily on the exact prompt, and you tuned the prompt for your method (possibly on the test set) but used a default prompt for baselines.

**Why it matters:** the "improvement" may be a prompt engineering gap rather than a method gap. This is a reviewer-magnet in LLM papers.

**How to check:**
- Did you tune prompts for your method? For baselines? With what budget?
- Did you use the test set (or test-adjacent data) for prompt selection? (Even "looking at a few test examples to pick a prompt" counts.)
- How does performance change across 3–5 paraphrased prompts?
- If you use chain-of-thought / instruction prefixes / few-shot examples, did the baseline get the same affordance?

**Mitigation:**
- Fix prompts upfront using a development set (not the test set).
- Use the same prompt for your method and baseline wherever possible; when not possible, state the asymmetry and why.
- Report results across multiple prompt variants (mean + variance).
- Release all prompts verbatim in the paper or appendix.

---

## 5. Seed sensitivity with and without access

**The pitfall:** small-sample evaluations with single seeds. Effect sizes within the noise floor.

**Why it matters:** results that don't replicate across seeds aren't real.

**How to check:**
- For open models / trainable systems: run 3+ seeds, report mean ± stddev.
- For closed models (no seeds): use `temperature=0` when possible for determinism; otherwise run N samples per query and use mean or majority vote; report the sampling setup.
- For tasks where seeds affect training: separate "data split seed" (which shouldn't affect method comparison) from "training seed" (which should be varied).

**Mitigation:**
- Report variance everywhere.
- When variance is high relative to effect size, either run more seeds or reframe the claim ("X is competitive with Y" not "X beats Y").
- For closed models, sample multiple times; use pass@k / majority@k where appropriate; report the sampling budget.

---

## 6. Closed-model reproducibility

**The pitfall:** closed models (GPT-4, Claude, Gemini) get updated behind the same API name. Your results aren't reproducible even if someone has API access, because the model has changed.

**Why it matters:** reviewers and future readers can't verify your numbers. Months later, you can't verify your own numbers.

**How to check / mitigate:**
- Record the exact API version / model snapshot string (e.g., `gpt-4-0613`, `claude-sonnet-4-6`) — not just the family.
- Record the timestamp of when you ran the evals.
- For production API calls, log raw responses so you can verify offline.
- Report cost per evaluation (so future readers can gauge feasibility).
- Where possible, include an open-model baseline too — it's the only reproducible data point.
- Release the full set of prompts + responses as an artifact when allowed.

---

## 7. Fair compute / parameter / token comparisons

**The pitfall:** you claim efficiency (faster, smaller, cheaper) but compare a 7B model to a 70B model, or a short-context method to a long-context one, with no matching on compute.

**Why it matters:** any efficiency claim needs to hold the other axis constant.

**How to check:**
- Matched-compute comparison: equal FLOPs / tokens / wall-clock.
- Matched-parameter comparison: equal parameter counts.
- Matched-API-cost comparison: equal dollar cost per query.
- Pareto frontier: plot accuracy vs. compute and show your method moves the frontier, rather than picking one operating point.

**Mitigation:**
- Always report the denominator. "Our method is 3x faster (matched for same accuracy)" or "our method achieves same accuracy at 1/3 the compute".
- Include a Pareto frontier plot.
- Compare to baselines *at the same operating point*, not at the baselines' default.

---

## 8. Training-data leakage in fine-tuning setups

**The pitfall:** your fine-tuning data overlaps with your eval data. Standard-benchmark names / answers / exact strings appear in the training corpus.

**Why it matters:** you're measuring memorization, not generalization.

**How to check:**
- Substring match your eval set against your fine-tuning corpus.
- Fuzzy / n-gram match (13-gram overlap is a common benchmark).
- For LLM-generated fine-tuning data, check that the LLM didn't produce exact test strings.

**Mitigation:**
- Decontaminate the fine-tuning set by removing any document with substantial overlap with any test item.
- Report a post-decontamination evaluation.
- If decontamination isn't feasible, use a fresh held-out set not involved in any training.

---

## 9. Agentic / tool-use evaluation specifics

**The pitfall:** evaluations for agents (tool-calling, multi-step, environment-interacting) have specific failure modes: trajectory length effects, tool-call noise, partial-success ambiguity, environment variation.

**Why it matters:** agent benchmarks are newer, less battle-tested, and more sensitive to protocol details than standard benchmarks.

**How to check / design:**
- **Trajectory length:** does your method look better because it takes more steps (and so has more chances to hit the answer)? Cap trajectory length or budget-match across methods.
- **Tool-call cost:** is the "better" method using 10x more tool calls than the baseline? Report tool-call count and dollar cost.
- **Partial success:** how do you score a task where the agent accomplished 4/5 subgoals? Be explicit about grading; different grading schemes can flip the ranking.
- **Environment stochasticity:** is the environment itself noisy (e.g., a live website, an API that returns different results)? Pin environments when possible; otherwise average over runs and report variance.
- **Success definition:** "the agent said the right thing" is not success if the user's goal was an action. Align the metric to the actual task.

**Mitigation:**
- Report multiple metrics per task (binary success, partial credit, tool-call count, latency, cost).
- Use environments with deterministic or reproducible state.
- Release trajectories (with user permission) so graders can audit.

---

## 10. Multi-task / benchmark-suite reporting

**The pitfall:** you report "average across 15 tasks" and your method wins overall but loses on 6 tasks. The average hides systematic losses.

**Why it matters:** reviewers notice, and the hidden losses often point to real limitations of the method.

**Mitigation:**
- Report per-task results in the main paper or appendix (a table or small-multiple plot).
- Report win-rate (fraction of tasks won) alongside average.
- If your method has a systematic weakness (loses on a category of tasks), name it and discuss — this builds credibility rather than undermining it.

---

## 11. Selecting the best hyperparameter on the test set

**The pitfall:** you ran 64 configs, picked the best on the test set, and reported that number. Your method is "tuned on the test set", inflating results.

**Why it matters:** this is one of the cleanest forms of overfitting and reviewers at top venues will catch it.

**How to check / avoid:**
- Always use a validation set or cross-validation for hyperparameter selection.
- For closed-model evaluations without natural HP sweeps, the equivalent trap is prompt selection on test examples — also out of bounds.
- If the benchmark doesn't provide a validation set, split the training set yourself (and report that split).
- Report the *average* across reasonable hyperparameters if you're unsure, not the best.

Keogh's "fastest 100m runner" example applies: running 1.4 billion Chinese runners and one Indian runner and reporting only the winners is not a comparison.

---

## 12. Metric drift between papers

**The pitfall:** different papers in your space compute the "same" metric differently. Your numbers aren't comparable to the prior work you cite.

**Why it matters:** you claim to beat paper X by 2 points, but you're computing the metric differently than X did.

**How to check:**
- Read how each prior-work baseline computed its metric. Don't assume.
- For LLM-era metrics (pass@1, exact-match, BLEU variants) — there are multiple definitions.
- Check whether baselines used chain-of-thought, self-consistency, majority voting, or not.

**Mitigation:**
- Standardize on one metric definition. State it precisely.
- Re-run baselines under your setup when prior numbers aren't comparable. Explain any differences from published numbers.
- Do not compare numbers across papers that use different metrics, even if the metric has the same name.

---

## Cross-cutting rule

When in doubt, **name the concern in the paper**. A paper that says "we note that benchmark X may have contamination concerns; we report on a held-out split Y and cross-check on perturbations" is more credible than a paper that says "SOTA on X" and hopes reviewers don't notice. Self-aware evaluation builds trust; silent evaluation invites doubt.
