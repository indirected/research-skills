# AutoPatch Metrics Glossary — result-reproduction-verifier Reference

This is a copy of the shared metrics reference for use by the result-reproduction-verifier skill.
Authoritative source: `skills/experiment-designer/references/metrics-glossary.md`

---

## Primary Metric for Reproduction

### `shr_correct_patches` — Correct Patch Rate

**Formula:** `num_passed_fuzzing_and_differential_debugging / num_passed_qa_checks`

**What it measures:** The fraction of QA-valid cases where the LLM generated a patch
that both (a) fixes the original fuzzer crash and (b) passes differential debugging /
regression testing.

**Why it is the headline metric:** It is the most conservative measure of patch quality —
not only must the crash be silenced, but existing program behavior must be preserved.

**Typical range:** 0.0 – 1.0 (stored as string `"0.583"` in stats.json, convert with `float()`)

**In reproduction context:** Compare this value between original and reproduced runs.
Tolerance: ±5 percentage points → PASS; ±5–10pp → WITHIN_VARIANCE; >10pp → FAIL.

---

## Secondary Metrics

### `shr_passing_fuzzing` — Tier 1 Success Rate

**Formula:** `num_passed_fuzzing / num_passed_qa_checks`

**What it measures:** The fraction of QA-valid cases where the patch silences the
fuzzer crash, regardless of whether regression tests pass.

**In reproduction context:** If `shr_passing_fuzzing` reproduces but `shr_correct_patches`
does not, the model is generating patches that fix the crash but break regression tests —
check whether the regression test suite or fix container changed between runs.

### `shr_patches_generated` — Patch Generation Rate

**Formula:** `num_generated_patched_function_name / num_passed_qa_checks`

**What it measures:** Whether the LLM produced a parseable patch (correct output format).

**In reproduction context:** This metric is typically very stable (high and consistent).
If it changes significantly, the prompt format or LLM output parsing may have regressed.

---

## Raw Counts (in stats.json)

| Field | Description | Stable? |
|-------|-------------|---------|
| `num_passed_qa_checks` | Cases where containers pass health checks | Very stable (infra) |
| `num_generated_patched_function_name` | Cases with parseable patches | Stable |
| `num_passed_fuzzing` | Tier 1: crash fixed | Variable (LLM-dependent) |
| `num_fuzzing_decode_errors` | Infra: fuzzing output decode failures | Very stable |
| `num_differential_debugging_errors` | Infra: diff debug runner failures | Very stable |
| `num_passed_fuzzing_and_differential_debugging` | Correct patches | Variable (LLM-dependent) |

**For reproduction:** Infrastructure metrics (`num_passed_qa_checks`,
`num_fuzzing_decode_errors`) should be identical between runs unless the container
images or test harness changed. If these differ, investigate infrastructure changes
before attributing variance to the LLM.

---

## PatchGenerationStatus Enum

Used to interpret `max_patch_generation_status` in `patch_gen_reports.json`.

| Value | Name | Meaning | Stable? |
|-------|------|---------|---------|
| 0 | INIT_STATUS | No progress at all | — |
| 1 | FAILED | Unhandled exception | Should be stable |
| 2 | FETCH_SOURCE_SUCCESSFUL | Source code retrieved | Should be stable |
| 3 | PATCH_FORMAT_CORRECT | Parseable patch produced | Usually stable |
| 4 | PATCH_BUILD_SUCCESSFUL | Patch compiled | Usually stable |
| 5 | PATCH_FIXES_CRASH | Crash fixed | Variable |
| 6 | PATCH_PASSES_CHECKS | **SUCCESS** | Variable |
| 7 | NOT_SUPPORTED | Unsupported crash type | Stable |

For reproduction, compare the distribution of `max_patch_generation_status` values
across cases. Cases that transition between status 4 and 5 (built but crash not fixed)
are most susceptible to LLM variance.

---

## Reproduction Tolerance Reference

| Metric type | PASS threshold | WITHIN_VARIANCE | FAIL |
|-------------|---------------|-----------------|------|
| Rate (shr_*) | diff ≤ 0.05 (5pp) | diff ≤ 0.10 (10pp) | diff > 0.10 |
| Integer count (num_*) | diff = 0 | — | diff ≠ 0 |
| QA infrastructure counts | diff = 0 | — | diff ≠ 0 |
| Average timing (minutes) | diff ≤ 2 min | diff ≤ 5 min | diff > 5 min |

**Rationale for 5pp tolerance on small-N samples:**
- N=5 cases: one case flip = 20pp change — use 10pp (WITHIN_VARIANCE) threshold
- N=15 cases: one case flip = 6.7pp change — 5pp threshold is appropriate
- N=113 cases: one case flip = 0.88pp — 5pp threshold allows ~6 cases to change

**Scale the tolerance by sample size.** When reproducing on a subset, the per-flip
percentage is larger. For N=5, WITHIN_VARIANCE should be interpreted as "correct
within ±1 case" rather than a strict threshold.

---

## Pass@k Interpretation

When a full reproduction uses `k` independent runs per case:

```
pass@1 = standard reproduction (one attempt per case)
pass@k = upper bound (at least one of k attempts succeeds)
```

**Formula for unbiased pass@k estimate:**
```
pass@k = 1 - C(n-c, k) / C(n, k)
```
where `n` = total attempts, `c` = successful attempts, `k` = target.

For artifact evaluation, `pass@1` is the standard. Use `pass@3` to demonstrate that
the model reliably succeeds on representative cases.

---

## Efficiency Metrics (for AE reports)

Per-case efficiency metrics from `patch_gen_reports.json`:

| Metric | Description | Unit |
|--------|-------------|------|
| `patch_gen_time` | Total wall clock per case | seconds |
| `build_iters` | Build attempts needed | count |
| `fix_crash_iters` | Crash-fix attempts | count |
| `llm_query_cnt` | Total LLM API calls | count |
| `llms_query_time` | Time waiting for LLM | seconds |

**Expected ranges (from paper results):**
- `patch_gen_time`: 4–8 minutes median for successful cases
- `build_iters`: typically 1–3
- `fix_crash_iters`: typically 1–4
- `llm_query_cnt`: typically 3–8

High `build_iters` (>5) suggests the LLM is struggling with the build environment.
High `fix_crash_iters` (>5) suggests the patch direction is wrong and the LLM is
iterating without convergence.
