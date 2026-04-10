---
name: result-reproduction-verifier
description: |
  Use this skill whenever the user wants to re-run the benchmark to verify paper results,
  check reproducibility, or perform artifact evaluation reproduction. Trigger on phrases like:
  "reproduce results", "verify results", "re-run subset", "check reproducibility",
  "artifact evaluation reproduction", "verify paper claims", "sanity check our numbers",
  "re-run to confirm results", "does the benchmark reproduce",
  "run a reproducibility check", "can we reproduce the paper numbers",
  "verify the claimed metrics", "spot-check the results",
  "run a subset to check", "validate the results are stable",
  "confirm the benchmark gives the same numbers", "check result stability",
  "test reproducibility with N cases", "run a sanity check on results",
  "artifact evaluation", "AE reproduction", "verify for camera ready".
  Use before submission or when a reviewer asks about reproducibility.
version: 1.1.0
tools: Read, Glob, Grep, Bash, Write, Edit
---

# Result Reproduction Verifier

This skill re-runs a stratified subset of the benchmark, compares the reproduced results
against the claimed paper values, and produces a PASS/FAIL/WITHIN_VARIANCE report.
It accounts for expected non-determinism (±5% tolerance for rates, exact match for counts).

**Note**: This skill reads `project/experiment-config.md` for the run command template,
dataset paths, and metric names. If `project/experiment-config.md` does not exist, it will
ask the user for these parameters before proceeding.

**General prerequisites:**
- API key for the LLM under test set in environment (if applicable)
- Any containerization tool required by the benchmark (Docker, Podman, etc.)
- Python environment with the benchmark package installed

---

## Output Locations

| Output | Path |
|---|---|
| Reproduction run results | `experiments/reproduction/repro_YYYYMMDD/` |
| Reproduction report | `experiments/reproduction/repro_YYYYMMDD/repro_report.md` |
| Raw stats | `experiments/reproduction/repro_YYYYMMDD/stats.json` |

---

## Step 1: Load Claimed Results

Read `project/experiment-config.md` to understand the result schema:
- `result_file_pattern` — where result files live
- `primary_result_field` — the field that holds the primary metric
- `metric_names` — all tracked metrics
- `per_case_result_file` — per-case result file name (if any)

If `project/experiment-config.md` does not exist, ask the user:
> "What is the run command for your benchmark, the path to your results files, and the
> names of the key metrics to verify?"

Then check if `paper/numbers_tracker.json` exists:
```
Glob: paper/numbers_tracker.json
```

If it exists, load it — it contains the verified mapping of paper claims to source values.

If it does not exist, load the stats file from the paper's primary experiment run using
the `result_file_pattern` from config:
```
Glob: [result_file_pattern]
```

Use the most recently modified result file as the "claimed" results. Record:
- Run ID / path (for provenance)
- All key metrics listed in `project/experiment-config.md`'s `metric_names` section

Also record the total case count from the run — check the dataset file used in the original
run's metadata or configuration.

---

## Step 2: Ask User for Reproduction Parameters

Before proceeding, ask the user:

```
I need a few parameters to set up the reproduction run:

1. Reproduction budget: How many cases to re-run? (default: 5)
   Provide rough timing guidance based on the timing estimate in project/experiment-config.md.

2. LLM/model to use for reproduction:
   - Same model as original? (recommended for apples-to-apples comparison)
   - Or a different model?

3. Concurrency (cases to run in parallel)? (default: 4)
   Higher concurrency = faster but higher API cost.

4. Any special flags to add to the run command? (e.g., container registry, dataset subset)
```

Wait for user responses before proceeding.

---

## Step 3: Select Cases for Stratified Sampling

The goal is a stratified sample that covers the diversity of cases in the full dataset,
so that the reproduction reflects the overall benchmark rather than a lucky/unlucky slice.

Read `project/experiment-config.md` to find:
- The `per_case_result_file` (per-case results from the original run)
- Any field that categorizes cases (e.g., type, category, class, language, difficulty)

Load the per-case result file from the most recent run:
```
Glob: [result_file_pattern — replace stats.json with per_case_result_file]
```

Identify the stratification dimension — the field that distinguishes case types. If the config
specifies a `stratification_field`, use it. Otherwise, look for fields like `type`, `category`,
`bug_class`, `language`, or ask the user:
> "What field in your per-case results distinguishes case categories? (e.g., 'bug_type',
> 'language', 'difficulty') I'll use this to select a representative sample."

Select N cases using stratified sampling:
1. Group cases by their category value
2. Compute how many cases to take from each group proportional to group size
3. Within each group, select cases randomly (or prefer cases where the original run succeeded,
   to maximize the chance of observing a reproducible result)

Report the selected cases:
```
Selected N cases for reproduction:
  [category 1]: [case IDs] (K cases)
  [category 2]: [case IDs] (K cases)
  ...
```

---

## Step 4: Check Environment

Before running, verify the environment is ready.

```bash
# Check Python package / binary is available:
# (use the interpreter inferred from the run command template)
which python3 || which python || echo "MISSING: Python"

# Check any required container runtime:
which docker || which podman || echo "No container runtime found"

# Check API keys (check common ones):
echo "ANTHROPIC_API_KEY: $([ -n "$ANTHROPIC_API_KEY" ] && echo SET || echo MISSING)"
echo "OPENAI_API_KEY:    $([ -n "$OPENAI_API_KEY" ] && echo SET || echo MISSING)"
echo "GOOGLE_API_KEY:    $([ -n "$GOOGLE_API_KEY" ] && echo SET || echo MISSING)"

# Check disk space:
df -h . | tail -1
```

Report any missing prerequisites and stop if critical ones are absent.
Required: the runtime inferred from the run command, API key for the LLM under test.

---

## Step 5: Create Output Directory and Run Benchmark

Create the output directory:
```bash
REPRO_DATE=$(date +%Y%m%d)
mkdir -p experiments/reproduction/repro_${REPRO_DATE}
```

Write the selected case IDs to a temporary input file (format depends on your benchmark's
expected input — check `project/experiment-config.md` for the prompt-path format):
```bash
# Example: JSON array of case IDs
echo "[case_id_1, case_id_2, ...]" > /tmp/repro_cases.json
```

Construct the run command by substituting into the template from `project/experiment-config.md`:
- Replace the dataset/prompt path with the temporary case file
- Replace the output paths with `experiments/reproduction/repro_${REPRO_DATE}/`
- Substitute the model, concurrency, and any flags the user specified in Step 2

Show the full substituted command to the user and ask for confirmation before running.

**Expected runtime:** Based on the `timing_estimate` field in `project/experiment-config.md`.
Roughly: `(N cases × per-case time) / concurrency`

While the run is in progress, monitor for errors:
- Check if result files are being written (non-empty, growing)
- Alert user if no progress after a reasonable interval (e.g., 2× expected per-case time)

---

## Step 6: Compare Reproduced vs. Claimed Results

Once the run completes, load the reproduction result file and compare it to the claimed values
from Step 1.

For each metric, compute the comparison:

```python
def classify_metric(paper_value, repro_value, metric_type="rate"):
    diff = abs(paper_value - repro_value)
    if metric_type == "rate":
        if diff <= 0.05:   # within 5 percentage points
            return "PASS"
        elif diff <= 0.10: # within 10 percentage points
            return "WITHIN_VARIANCE"
        else:
            return "FAIL"
    elif metric_type == "count":
        return "PASS" if diff == 0 else "FAIL"
```

**Tolerance rationale:**
- LLM outputs are non-deterministic: the same prompt can produce different results.
- Temperature, API version updates, and model fine-tuning all introduce variance.
- For a 5-case sample, each case = 20 percentage points — variance is expected.
- We use ±5pp as the "PASS" threshold and ±10pp as "WITHIN_VARIANCE" for rates.
- Integer counts must match exactly — if a count diverges, flag for investigation.

Build a comparison table using the metric names from `project/experiment-config.md`:

| Metric | Paper value | Reproduced value | Verdict |
|--------|------------|-----------------|---------|
| [primary_metric] | N% | N% | PASS/FAIL/WITHIN_VARIANCE |
| [secondary metrics] | ... | ... | ... |

**Subset correction:** When comparing on a subset, look up the original outcome for the
specific reproduced cases from the per-case result file, not the aggregate stats file.
Compare subset-vs-subset (same cases), not subset-vs-full-dataset.

---

## Step 7: Detect Systematic Biases vs. Random Variance

After computing per-metric verdicts, assess whether failures look systematic or random:

**Random variance indicators:**
- Roughly half of the changed cases improved, half regressed
- The overall rate difference is within ±10 pp
- No consistent pattern by case category

**Systematic bias indicators:**
- All changed cases changed in the same direction (all better or all worse)
- Changes cluster on a specific category (e.g., one bug type or one language now always fails)
- Infrastructure metrics changed significantly (environment issue, not model behavior)

Report findings in the reproduction report.

---

## Step 8: Write the Reproduction Report

Write `experiments/reproduction/repro_YYYYMMDD/repro_report.md`:

```markdown
# Reproduction Report — YYYY-MM-DD

## Setup

- Model: [model used for reproduction]
- Cases reproduced: N (stratified sample)
- Dataset: [dataset name from project/experiment-config.md]
- Concurrency: [value]
- Original run: [path to original result file]
- Reproduction run: experiments/reproduction/repro_YYYYMMDD/stats.json

## Case Selection

| Case ID | Category | Original outcome |
|---------|----------|-----------------|
| [id]    | [cat]    | PASS/FAIL        |
| ...     |          |                  |

## Metric Comparison

| Metric | Paper (N=[full]) | Original (N=[subset]) | Reproduced (N=[subset]) | Verdict |
|--------|-----------------|----------------------|------------------------|---------|
| [primary_metric]    | X% | X% | X% | **PASS/WITHIN_VARIANCE/FAIL** |
| [secondary_metric]  | X% | X% | X% | ... |

## Verdict

**Overall: [PASS / PASS WITH VARIANCE / FAIL]**

[2-3 sentences interpreting the result — is it reproducible? Any systematic patterns?]

## Variance Analysis

- Changed cases: N of M
- Direction of change: [positive / negative / mixed]
- [Any case-specific notes]

## Recommendations

- [Whether results are reproducible within expected variance]
- [For AE: whether this reproduction supports a Functional/Reproduced badge]
- [Suggested next steps: run on full dataset, investigate specific failures, etc.]

## Notes

- LLM non-determinism: temperature > 0 means results vary by run.
- Infrastructure variance: environment differences can affect timing and edge cases.
```

---

## Step 9: Summary to User

Print a concise summary:

```
Reproduction complete: N cases run

Metric Results:
  [primary_metric]:    Paper X% | Reproduced Y% | [PASS/WITHIN_VARIANCE/FAIL]
  [secondary_metric]:  Paper X% | Reproduced Y% | [PASS/WITHIN_VARIANCE/FAIL]

Overall verdict: [PASS / PASS WITH VARIANCE / FAIL]
Report saved to: experiments/reproduction/repro_YYYYMMDD/repro_report.md

Note: [brief interpretation — e.g., "Results match within expected LLM non-determinism."]
For full reproducibility evidence, consider running on the complete dataset.
```

---

## Reference Files

- `project/experiment-config.md` — run command template, result file schema, metric names,
  timing estimates, and dataset paths — primary source of truth for this skill
- `paper/numbers_tracker.json` — if created by table-extractor-and-tracker, provides
  verified mapping of paper claims to source values
