# Metrics Glossary for Ablation Studies

Condensed reference for choosing and interpreting metrics in AutoPatch ablation tables.
Full definitions: `/workspace/storage/CodeVul/skills/experiment-designer/references/metrics-glossary.md`

---

## Primary Metric

### `shr_correct_patches` — Overall Correct Patch Rate

**Formula:** `num_passed_fuzzing_and_differential_debugging / num_passed_qa_checks`

**Use in ablations:** This is the headline metric for every ablation condition.
Always include this column in the ablation table. All other metrics are secondary.

**Interpretation:** Higher is better. A 5-percentage-point drop in an ablation condition
is typically significant enough to claim the component contributes meaningfully.

**Typical range:** 0.0 – 1.0 (report as percentage: multiply by 100)

---

## Tier Metrics (for multi-tier systems)

### `shr_passing_fuzzing` — Tier 1 Rate (Crash-Silencing)

**Formula:** `num_passed_fuzzing / num_passed_qa_checks`

**Use in ablations:** Include when an ablation specifically tests a verification component.
If ablating Tier 2 (differential testing), this metric shows what Tier 1 alone achieves.

### `shr_passing_differential_debugging` — Tier 2 Rate

**Formula:** `num_passed_fuzzing_and_differential_debugging / num_passed_qa_checks`

**Use in ablations:** Same as `shr_correct_patches` in most configurations. Differs
only if Tier 3 is active and some patches pass Tier 2 but fail Tier 3.

### Tier 3 Rate (Sanitizer Pass)

Available if sanitizer-based post-validation is enabled. Rarely differs from Tier 2 unless
patch introduces new memory safety bugs.

---

## Process Metrics

### `shr_generated_patch` — Patch Generation Rate

**Formula:** `num_generated_patched_function_name / num_passed_qa_checks`

**Use in ablations:** Tests whether a component affects whether the LLM produces any
patch at all (vs. refusing or producing malformed output). Most useful when ablating
prompt structure components.

### `avg_attempts` — Average Attempts per Case

**Formula:** `total_attempts / num_cases_attempted`

**Use in ablations:** Tests the retry mechanism. When ablating `w/o Retry`, this should
be 1.0 by definition. For the full system, higher values indicate harder cases.

### `shr_max_attempts_reached` — Cases Hitting Retry Limit

**Formula:** `num_cases_at_max_attempts / num_passed_qa_checks`

**Use in ablations:** High values indicate the retry limit is a binding constraint.
If ablating retry count, compare this metric across conditions.

---

## Ablation-Specific Metric Guidelines

### When ablating example selection (C2, C7):

Report:
- `shr_correct_patches` (primary)
- `shr_passing_fuzzing` (to separate crash-fix ability from regression safety)
- If using similarity-based selection: add a "example similarity score" column if logged

### When ablating the retry mechanism (C3):

Report:
- `shr_correct_patches` (primary)
- `avg_attempts`
- `shr_max_attempts_reached`

### When ablating verification tiers (C1):

Report a separate row for each tier's metric rather than collapsing to primary metric:
- `shr_passing_fuzzing` (Tier 1 - crash fix)
- `shr_correct_patches` (Tier 2 - regression safe)
- If Tier 3 exists: add sanitizer pass rate

This lets reviewers see the value each tier adds independently.

### When ablating context/prompt content (C4, C8):

Report:
- `shr_correct_patches` (primary)
- `shr_generated_patch` (to check if missing context causes failure to generate vs. wrong patch)

---

## Statistical Reporting in Ablation Tables

For ablations with sufficient N (≥50 cases per condition), add 95% confidence intervals:
```
CI = ±1.96 × sqrt(p × (1-p) / N)
```
where `p` is the proportion (e.g., shr_correct_patches as decimal) and `N` is the number
of QA-passed cases.

Report as: "XX.X ± Y.Y" where Y.Y is the CI half-width in percentage points.

For ablations on subsets (20-30% of data): report CI explicitly; do NOT bold values as
"best" since the confidence intervals are wide.

---

## Minimum Meaningful Delta

For ablation results to be interpretable:
- **< 2 pp difference**: Likely noise — report but do not claim the component contributes
- **2–5 pp difference**: Modest contribution — worth mentioning in the prose
- **5–10 pp difference**: Meaningful contribution — claim the component matters
- **> 10 pp difference**: Strong contribution — this is a primary result

These thresholds assume N ≥ 50. For smaller N, the minimum meaningful delta increases.
