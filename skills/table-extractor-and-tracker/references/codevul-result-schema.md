# CybersecurityBenchmarks AutoPatch — Result Schema for Numbers Tracking

This reference covers the result file schemas needed by the table-extractor-and-tracker skill
to map paper numeric claims to their source values.

For the full schema documentation, see also:
`skills/result-analyzer-and-table-gen/references/codevul-result-schema.md`

---

## Primary Source: stats.json

**Location:** `experiments/runs/{run_id}/stats.json` (or wherever `--stat-path` points)

**Structure:**
```json
{
  "claude-3-5-sonnet-20241022": {
    "num_passed_qa_checks": 13,
    "num_generated_patched_function_name": 12,
    "num_passed_fuzzing": 9,
    "num_fuzzing_decode_errors": 0,
    "num_differential_debugging_errors": 0,
    "num_passed_fuzzing_and_differential_debugging": 8,
    "shr_patches_generated": "0.923",
    "shr_passing_fuzzing": "0.600",
    "shr_correct_patches": "0.533"
  }
}
```

**Note:** `shr_*` values are strings, not floats. Convert with `float(s["shr_correct_patches"])`.
If a rate cannot be computed (zero QA passes), the field is `"n/a"` instead of a float string.

---

## Mapping: Paper Claims → Source Fields

This table maps every numeric claim that appears in the AutoPatch paper to its source in
the result files. Use this mapping in the numbers tracker.

### From stats.json

| Paper claim | Source field | Computation |
|-------------|-------------|-------------|
| "N of 15 cases pass QA" | `num_passed_qa_checks` | direct count |
| "QA pass rate X%" | `num_passed_qa_checks` | `/ total_cases * 100` |
| "patch generation rate X%" | `shr_patches_generated` | `float * 100` |
| "Tier 1 pass rate X%" | `shr_passing_fuzzing` | `float * 100` |
| "N of 15 cases fix the crash" | `num_passed_fuzzing` | direct count |
| "correct patch rate X%" | `shr_correct_patches` | `float * 100` |
| "N cases pass differential debugging" | `num_passed_fuzzing_and_differential_debugging` | direct count |
| "N fuzzing decode errors" | `num_fuzzing_decode_errors` | direct count |

### From patch_gen_reports.json

| Paper claim | Source field | Computation |
|-------------|-------------|-------------|
| "average build-fix cycles N" | `build_iters` | `mean(all cases)` |
| "average crash-fix iterations N" | `fix_crash_iters` | `mean(all cases)` |
| "average patch gen time N minutes" | `patch_gen_time` | `mean(all cases) / 60` |
| "average LLM queries N" | `llm_query_cnt` | `mean(all cases)` |
| "N cases reach PATCH_PASSES_CHECKS" | `max_patch_generation_status` | count status == 6 |
| "N cases FAILED" | `max_patch_generation_status` | count status == 1 |

### From responses.json

| Paper claim | Source field | Computation |
|-------------|-------------|-------------|
| "N cases QA passed" | `containers_pass_qa_checks` | count True |
| "N cases patch_success" | `patch_success` | count True |

---

## Total Cases Reference

| Dataset file | Case count |
|---|---|
| `autopatch_lite_samples_short.json` | 15 cases |
| `autopatch_lite.json` | ~113 cases |

The denominator for QA-pass-based rates (`shr_*`) is `num_passed_qa_checks`, NOT the total
case count. When computing QA pass rate for the paper, use total dataset size as denominator.

Example for the 15-case dataset:
```
QA pass rate = num_passed_qa_checks / 15
             = 13 / 15
             = 0.867 = 86.7%
```

---

## PatchGenerationStatus Enum Values

Used for counting how many cases reached each pipeline stage:

| Value | Name | Meaning |
|-------|------|---------|
| 0 | INIT_STATUS | No progress |
| 1 | FAILED | Unhandled exception |
| 2 | FETCH_SOURCE_SUCCESSFUL | Source code retrieved |
| 3 | PATCH_FORMAT_CORRECT | LLM produced parseable patch |
| 4 | PATCH_BUILD_SUCCESSFUL | Patch compiled |
| 5 | PATCH_FIXES_CRASH | Crash fixed by patch |
| 6 | PATCH_PASSES_CHECKS | Success: crash fixed + sanity checks pass |
| 7 | NOT_SUPPORTED | Crash type unsupported |

In `patch_gen_reports.json`, the status is stored as a string:
`"PatchGenerationStatus.PATCH_PASSES_CHECKS"` — strip the prefix when comparing.

---

## Example Paper-to-Source Mapping (results_draft.tex lines)

From `paper/sections/results_draft.tex`:

| Line | Paper text | Source field | Source value |
|------|-----------|-------------|-------------|
| 14 | "13 of 15 cases (86.7\%)" | `num_passed_qa_checks` = 13 | 13/15 = 0.867 |
| 18 | "12 instances (patch generation rate 92.3\%)" | `shr_patches_generated` = "0.923" | 0.923 |
| 22 | "9 of 15 cases have their crash repaired ... (60.0\%)" | `num_passed_fuzzing` = 9, `shr_passing_fuzzing` = "0.600" | 9/15 = 0.600 |
| 23 | "8 cases additionally pass differential debugging ... (53.3\%)" | `num_passed_fuzzing_and_differential_debugging` = 8, `shr_correct_patches` = "0.533" | 8/15 = 0.533 |
| 68 | "average number of build-fix cycles is 2.1" | mean(`build_iters`) | computed from patch_gen_reports.json |
| 69 | "average number of crash-fix iterations is 1.8" | mean(`fix_crash_iters`) | computed from patch_gen_reports.json |
| 71 | "4.7 minutes per case" | mean(`patch_gen_time`) / 60 | computed from patch_gen_reports.json |

---

## Staleness Thresholds

| Number type | Threshold | Rationale |
|-------------|-----------|-----------|
| Rates/percentages | ±0.1 pp (0.001) | Rounding to 1 decimal place |
| Integer counts | ±0 (exact) | Counts are exact, no rounding |
| Averages | ±0.05 | Float rounding in display |
| Fractions (N/M) | both N and M must match exactly | — |

When a rate is reported as "X.X%" (1 decimal), the paper value and source value must
agree to within ±0.05 pp (half the last displayed digit) to be considered current.

---

## Milestone 6 Additional Fields (multi-tier runs)

When `--multi-tier` was used, additional fields appear in stats.json:

| Paper claim | Source field |
|-------------|-------------|
| "Tier 2 pass rate X%" | `shr_tier2_passed` |
| "N cases pass Tier 2" | `num_tier2_passed` |
| "mean coverage X%" | `mean_tier3_coverage` |
| "Tier 4 pass rate X%" | (compute from per-case `tier4_diff_passed`) |

These fields only exist when `--multi-tier` was in `--additional-args`.
Check for their presence before computing comparisons.

---

## Finding the Latest Run

```python
import os, glob, json
from pathlib import Path

# Find all stats.json files, sort by modification time
stats_files = glob.glob("experiments/runs/*/stats.json")
if stats_files:
    latest = max(stats_files, key=os.path.getmtime)
    print(f"Latest stats: {latest} (modified {os.path.getmtime(latest)})")
    with open(latest) as f:
        stats = json.load(f)
else:
    print("No stats.json found in experiments/runs/")
```

---

## Note on Multiple Models in One Run

If a single stats.json contains results for multiple models (comparison run), all
model keys are present at the top level:

```json
{
  "claude-3-5-sonnet-20241022": { ... },
  "gpt-4o-2024-11-20": { ... },
  "gemini-1.5-pro-002": { ... }
}
```

Map each table row to the corresponding model key. The model name in the stats.json
key exactly matches the `--llm-under-test` model identifier (middle part after `PROVIDER::`).
