# Writing the Experiments / Evaluation / Results Section

The experiments section is where the paper's claim either holds or doesn't. The job is **not** to dump tables and numbers — it's to lead the reader through a sequence of "here's what we asked, here's what we found, here's what it means".

Numbers without narrative are noise; narrative without numbers is hand-waving. The section needs both.

## What the experiments section must do

By the end of this section, the reader should be able to say:

1. **What was tested?** Datasets, baselines, metrics, ablations.
2. **Did the method work?** Headline result, with appropriate variance.
3. **Where did it work and where didn't it?** Generalization, robustness, failure modes.
4. **What's the evidence for each claim in the contributions list?** Each contribution should map to specific experiments.
5. **Was the comparison fair?** Tuning budget, compute budget, prompt budget across methods.

If a reviewer can't answer all five from the experiments section, the section needs more work.

## Structure: claim-driven, not table-driven

Weak: "Table 1 shows main results. Table 2 shows ablations. Table 3 shows transfer." (Tables drive the structure, no narrative.)

Strong: organize by **what you're trying to show**, with subsections like:

- **Setup** (datasets, baselines, metrics, protocol — typically 1 page max).
- **Main results** (does the method work? — answers the headline claim).
- **Ablations** (which components matter? — answers "why does it work?").
- **Analysis / case studies** (where does it succeed/fail? — answers "when does it work?").
- **Sensitivity** (robustness to choices — answers "is this brittle?").

Each subsection has a one-sentence question it answers, and the tables/figures in that subsection serve that question. No table without a sentence saying what we're supposed to learn from it.

## The setup paragraph

Tightly structured. Cover:

- **Datasets** — name, brief characterization (size, domain), why chosen.
- **Baselines** — list, with one-line characterization. Crucially, include the trivial / non-learned baseline.
- **Metrics** — name, what they reward. If non-standard, say what it is and why.
- **Protocol** — number of seeds, prompt setup, hardware, key hyperparameters. Forward-reference the appendix for details.

Aim for half a page or less. The reader needs grounding; they don't need a manual.

## Reporting numbers

Universal principles for results presentation:

- **Variance is non-negotiable.** Single-number results are not credible at top venues. Report mean ± stddev, mean ± 95% CI, or full distribution. Pick one and stick to it.
- **Significant digits commensurate with sample size.** "57.235% on 100 examples" is a lie. With N=100, two digits are honest; three is overreach.
- **Effect size in context.** A 0.3-point improvement on a benchmark with 1.0-point label error is noise. Always report (or at least know) the noise floor for your benchmark.
- **Bold the winner per row** (in tables) — but only when the winner is statistically separated. If two methods tie within noise, bold both or neither.
- **Cite where each baseline number comes from.** Re-ran from official code? Took from the original paper? Reused a number from a more recent paper that also re-ran it? Make it traceable.

## The headline result

The first table (or figure) of the experiments section is high-leverage. It anchors the reader's belief about the method. Make it carry weight:

- **Comprehensive enough** to substantiate the headline claim — your method, the strongest baseline(s), one trivial baseline, on the main benchmark(s).
- **Self-explanatory caption** — a reader skimming the paper should understand what the table shows from the caption alone.
- **Direct labeling** — use real method names, not "Method A" / "Method B".
- **Variance shown** — ± stddev or CI per cell.
- **Honest** — don't omit a baseline because it does well.

## Narrating tables

For each non-trivial table or figure, the prose should:

1. **Frame the question.** "Table 2 reports accuracy on the held-out set across model scales."
2. **Point to the most important pattern.** "Our method outperforms the strongest baseline by X points on average, with the largest gap (Y points) at the 70B scale."
3. **Acknowledge counter-patterns.** "The improvement is smaller (Z points) at the 7B scale, which we attribute to [hypothesis]."
4. **Connect to the claim.** "This supports our claim that [contribution] scales with model size."

A reviewer who reads only the prose around each table should still understand what the experiments showed.

## Negative results and ablations

A truthful ablation can show that a component **doesn't** matter — that's information. Report it. Two reasons:

- **Reviewers reward honesty.** A paper that says "we tried adding component C; it didn't help, see Table 4" is more credible than one that hides ablations that weakened the story.
- **The negative result is itself useful** to readers planning their own work.

If your method has 5 components and only 3 matter, the contribution might just be those 3 — clarify that the other 2 are inherited / standard / a separate question. Don't pretend everything matters when it doesn't.

## Failure cases and case studies

A short subsection on **where does this fail?** earns enormous credibility. Patterns:

- **Categorical analysis.** Break results down by example category; identify a category where the method underperforms.
- **Qualitative cases.** Show 1–2 specific inputs where the method gets it wrong, alongside what the right output should be. Be honest about why.
- **Error taxonomy.** If you ran error analysis, classify the errors and report counts / fractions.

This connects to the `acknowledge weaknesses` universal principle. A failure case section is also a service to follow-up researchers.

## Comparing apples to apples

This is where reviewers concentrate fire. Specific anti-patterns to avoid:

- **Different prompts for your method and baselines.** If your method got chain-of-thought and the baseline didn't, that's a confound, not a comparison.
- **Different tuning budgets.** If you ran 64 configs for your method and 1 default for the baseline, the result reflects tuning intensity, not method quality.
- **Different model scales.** Comparing your 70B method to a 7B baseline isn't a quality comparison.
- **Different test sets / metric definitions.** "Pass@1" can mean three different things depending on sampling.
- **Cherry-picked subsets.** Reporting only the benchmarks your method wins on; calling them "the relevant ones" without explaining why.

Where an asymmetry exists, name it explicitly: "Note that our method requires N additional context tokens; we discuss the cost in §X." Honesty about asymmetries is far stronger than hoping reviewers don't notice.

## Pareto frontiers and tradeoff plots

When the claim is about a tradeoff (accuracy vs. compute, accuracy vs. latency, etc.), a single operating point is rarely enough. Plot the **frontier**:

- X-axis: the cost dimension (compute, parameters, tokens, dollars).
- Y-axis: the quality dimension (accuracy, F1, win-rate).
- Curves: each method, with multiple operating points (different model sizes, different sampling budgets, different K).

The claim becomes "our method moves the frontier" rather than "our method is better at one operating point" — which is a stronger and more honest claim.

## Statistical claims

When you say "method A is significantly better than method B":

- "Significantly" should mean **statistically significantly at confidence level X**. If you don't have that, don't use the word.
- Pick a test appropriate to the data: paired t-test for matched samples, bootstrap CI for non-Gaussian, Wilcoxon for ranked outcomes.
- Report p-values or CIs in the table or text. Don't hide them.
- Adjust for multiple comparisons if you're testing many hypotheses (Bonferroni or similar).

When the difference is within noise, say "comparable" or "competitive", not "better".

## ML-era specifics

Read `design-experiments/references/ml-evaluation-pitfalls.md` if you haven't — these failure modes are the most common reviewer concerns:

- **Contamination.** If you've been audited for contamination, say so. If not, address the risk.
- **LLM-as-judge.** If you used a judge, justify the choice, report agreement with humans, randomize positions, ideally use multiple judges.
- **Closed-model versions.** State exact API versions and timestamps.
- **Compute fairness.** If claiming efficiency, report the matched comparison.

## Length and budget

Experiments sections are usually 2–4 pages in a 9-page paper. Subsections per claim. Tables and figures take space — choose them wisely.

If you have more results than fit, push to appendix. The main paper should have:
- Headline table.
- Ablation table.
- One or two key analysis figures.
- Anything required to substantiate every contribution.

Everything else (per-task breakdowns, full hyperparameter grids, additional sensitivity studies) goes to appendix, with forward references from main paper.

## Anti-patterns

- **The data dump.** Six tables, no narrative. The reader is left to draw their own conclusions; they will, and not to your benefit.
- **The single-cherry-pick.** "On benchmark X our method achieves Y." But X is the only one your method won, and you don't say so.
- **The variance vacuum.** All single-seed numbers; no error bars. Reviewers will assume your improvements are noise.
- **The undefended sweep.** "We tuned hyperparameters extensively." On what? With what budget? Selected on what?
- **The lopsided baseline.** Baseline run once with defaults; your method tuned to the gills. Match the budgets.
- **The vanishing failure mode.** No discussion of where the method fails. Reviewers wonder what you're hiding.
- **The metric salad.** Five metrics, three favoring your method, two not — and only the three favorable ones make the main table.

## Cross-references

- Use the experiment plan from `design-experiments` as the structural backbone — every experiment in that plan should be reflected in the section.
- For figures (Pareto plots, learning curves, attention heatmaps), use `references/figures-and-tables.md`.
- For the abstract's headline number, ensure consistency: the number you cite in the abstract must come from a specific table in this section.
