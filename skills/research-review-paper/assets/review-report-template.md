# Self-Review Report

**Paper:** {paper title}
**Reviewed:** {date}
**Reviewer:** {your name / "self-review via review-paper skill"}
**Target venue:** {venue}

---

## Headline assessment

{One paragraph. State your overall take: would this be accepted, rejected, or major-revisioned at the target venue if submitted as-is? What are the 1–2 highest-risk issues?}

**Recommendation:** {Accept / Major Revision / Reject if as-is}

---

## Strengths

{2–5 bullet points naming what the paper does well. These are the parts you should NOT change in the fix pass — preserving them is as important as fixing the weaknesses.}

- {Strength 1 — e.g., "Strong empirical contribution: matched-compute comparison across 5 baselines on 3 datasets is rigorous."}
- {Strength 2 — e.g., "Clear motivation: the problem statement in §1 is sharp and well-anchored in prior work."}
- {Strength 3}

---

## Critical issues

{Issues that would lead to rejection if not addressed. Each issue includes: location, what's wrong, suggested fix, effort estimate.}

### C1: {short title}
- **Location:** §X.Y / Figure N / Table M
- **Issue:** {what's wrong, in concrete terms}
- **Why critical:** {what reject reason this maps to — e.g., "unfair baseline comparison (top-10 #3)" or "data contamination not addressed (ML pitfall)"}
- **Suggested fix:** {specific action — "add baseline X with same tuning budget" / "report on a held-out post-cutoff dataset"}
- **Effort:** {low / medium / high — e.g., "low: rewrite 1 paragraph" or "high: requires re-running experiments"}

### C2: {short title}
- **Location:**
- **Issue:**
- **Why critical:**
- **Suggested fix:**
- **Effort:**

{... repeat for each critical issue. Aim for 3–8 total; if you have more than 10 critical issues, the paper isn't ready and the recommendation should reflect that.}

---

## Major issues

{Issues that would substantially weaken reviewer enthusiasm but might not single-handedly cause rejection.}

### M1: {short title}
- **Location:**
- **Issue:**
- **Suggested fix:**
- **Effort:**

### M2: {short title}
- **Location:**
- **Issue:**
- **Suggested fix:**
- **Effort:**

{... 5–15 typical}

---

## Minor issues

{Polish, ambiguity, style. Each can be a one-liner.}

- §1, line 3: typo "approch" → "approach".
- §3.2: K=8 used without justification — add a sentence or appendix sensitivity check.
- Table 2: bolding the winner where not statistically separated; either compute significance or unbold ties.
- Figure 4 caption: doesn't state the takeaway — add "Our method (red) dominates the Pareto frontier."
- §5: acronym RAG used before being defined; define on first use (intro or setup).
- Bibliography: 3 entries marked "TO APPEAR" — update before submission.

---

## ML-era pitfalls audit

{For each pitfall, mark status: addressed / partially addressed / not addressed / not applicable.}

| Pitfall | Status | Notes |
|---|---|---|
| Data contamination | {status} | {one-line note} |
| LLM-as-judge bias | {status} | |
| Prompt sensitivity / overfit | {status} | |
| Seed sensitivity / variance reporting | {status} | |
| Closed-model reproducibility | {status} | |
| Compute / parameter fairness | {status} | |
| Test-set hyperparameter selection | {status} | |
| Multi-task hidden losses | {status} | |
| Training-data leakage (fine-tuning) | {status} | |
| Metric drift across papers | {status} | |

Any "not addressed" rows that apply to this paper should appear in the critical or major issues list.

---

## Reproducibility audit

{Quick checklist — present / missing / partial.}

- [ ] Exact prompts (verbatim)
- [ ] Exact API model versions and timestamps (for closed models)
- [ ] Exact training hyperparameters (full sweep, not just winning config)
- [ ] Exact data splits (with seed)
- [ ] Random seeds used
- [ ] Hardware and software versions
- [ ] Code release plan / URL
- [ ] Compute cost (GPU hours / API dollars)

---

## Anticipated reviewer attacks

{Imagine the most cynical reviewer. What are the 3–5 strongest attacks they might mount? Listing these now lets you preempt them in the paper or prepare for the rebuttal.}

1. **Attack:** {what the reviewer might say}
   - **Best defense:** {how the paper either preempts this or how the rebuttal would handle it}
   - **Action:** {what to do now — strengthen the relevant section, add an experiment, etc.}

2. **Attack:**
   - **Best defense:**
   - **Action:**

3. **Attack:**
   - **Best defense:**
   - **Action:**

---

## Fix prioritization

A suggested order for the fix pass:

1. **Highest-impact, lowest-effort** — typically prose fixes that address critical issues.
2. **Highest-impact, highest-effort** — typically new experiments or major restructuring; start early if needed.
3. **Major issues** — work through systematically.
4. **Minor issues** — polish pass at the end.

Estimated total fix time: {hours/days based on the effort estimates above}.

---

## Cross-references

- For prose fixes: hand off issues to `research-write-paper`, citing the section reference (intro / related-work / method / experiments / abstract).
- For experiment fixes: hand off to `research-design-experiments` for the experimental design, then run.
- For figure / table fixes: see `research-write-paper/references/figures-and-tables.md`.
- For ML-era pitfall remediation: `research-design-experiments/references/ml-evaluation-pitfalls.md` is the canonical reference.

---

## Notes for next review pass

{Anything to remember for the next time you self-review (e.g., "the CIFAR-only evaluation is still a generalization concern even with the additional baseline" — issues that were partially addressed and need re-checking).}
