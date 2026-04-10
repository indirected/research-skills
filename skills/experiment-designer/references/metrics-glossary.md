# AutoPatch Metrics Glossary

Definitions of every metric produced by the AutoPatch benchmark pipeline. Use this document to choose the right metric for your research question and to interpret results correctly.

---

## Primary Metric

### `shr_correct_patches`

**Formula:** `num_passed_fuzzing_and_differential_debugging / num_passed_qa_checks`

**What it means:** The fraction of QA-valid cases where the LLM generated a patch that both (a) fixes the original fuzzer crash and (b) passes differential debugging / regression testing. This is the headline correctness metric reported in the paper.

**Why it is primary:** It is the most conservative measure of patch quality — not only must the crash be silenced, but existing program behavior must be preserved.

**Typical range:** 0.0 – 1.0 (reported as a decimal string, e.g. `"0.583"`)

**Failure modes that suppress this metric:**
- LLM cannot identify a function to patch (`num_generated_patched_function_name` = 0)
- Patch builds but does not fix the crash
- Patch fixes crash but breaks regression tests (sanity check failure)
- Infrastructure errors during evaluation

---

## Secondary Metrics

### `shr_passing_fuzzing` — Tier 1 Success Rate

**Formula:** `num_passed_fuzzing / num_passed_qa_checks`

**What it means:** The fraction of QA-valid cases where the patch silences the fuzzer crash, regardless of whether regression tests pass.

**Use case:** Measures raw crash-fixing ability. If `shr_passing_fuzzing` >> `shr_correct_patches`, the model is generating patches that break existing tests — a prompt engineering or scope problem.

**Tier:** Corresponds to Tier 1 (PoC fix) in the multi-tier evaluation framework.

---

### `shr_patches_generated`

**Formula:** `num_generated_patched_function_name / num_passed_qa_checks`

**What it means:** The fraction of QA-valid cases where the LLM produced a parseable patch and identified the target function. Does not indicate correctness, only that the output format was valid.

**Use case:** Diagnosing format-level failures. Low `shr_patches_generated` → prompt format issues. Normal `shr_patches_generated` with low `shr_passing_fuzzing` → LLM understands the task but patches are wrong.

---

## Raw Counts (in stats.json)

| Key | Description |
|---|---|
| `num_passed_qa_checks` | Cases where both `vul` and `fix` containers start and pass health checks. The denominator for all `shr_*` metrics. |
| `num_generated_patched_function_name` | Cases where a patched function name was extracted from LLM output. |
| `num_passed_fuzzing` | Cases where the patch fixes the crash (Tier 1). |
| `num_fuzzing_decode_errors` | Cases where fuzzing output could not be decoded — infrastructure/encoding issue, not a model failure. Subtract from `num_passed_qa_checks` when computing corrected rates. |
| `num_differential_debugging_errors` | Cases where the differential debugging step failed to run — infra error. |
| `num_passed_fuzzing_and_differential_debugging` | Cases where the patch passes both fuzzing (Tier 1) and differential debugging. Numerator for `shr_correct_patches`. |

---

## Per-Case Fields in `patch_gen_reports.json`

These fields are available per case in `patch_gen_reports.json` and in the individual `report.json` files:

### Iteration Counters

| Field | Description |
|---|---|
| `build_iters` | Number of times the patch was compiled. Each failed build that triggered a retry increments this. |
| `fix_crash_iters` | Number of times crash reproduction was attempted with a patched build. |
| `sanity_check_iters` | Number of times sanity/regression checks were run. |
| `retry_round` | Which retry round (0-indexed) produced this report. |

### Timing Fields (seconds)

| Field | Description |
|---|---|
| `patch_gen_time` | Total wall-clock time for patch generation (all rounds). Primary time metric. |
| `crash_repro_time` | Time spent on crash reproduction checks. |
| `llms_query_time` | Cumulative time waiting for LLM responses. |
| `sanity_check_time` | Time spent on regression tests. |
| `llm_query_cnt` | Total number of LLM queries made. |

### Status Fields

| Field | Description |
|---|---|
| `max_patch_generation_status` | The highest `PatchGenerationStatus` level reached (see below). The primary per-case outcome indicator. |
| `sanitizer_crash_type` | Sanitizer-derived crash category string extracted by regex from crash output (e.g., `"AddressSanitizer: heap-buffer-overflow"`, `"AddressSanitizer: memory leak"`). |
| `crash_type` | Lionhead/ARVO internal crash type label. |
| `exception` | Exception message if an unhandled exception occurred during generation. |

---

## `PatchGenerationStatus` Enum — Ordered by Severity

Values are ordered: higher value = further progress. `max_patch_generation_status` records the highest level reached across all iterations.

| Value | Name | Meaning |
|---|---|---|
| 0 | `INIT_STATUS` | No progress at all — generation never started meaningfully. |
| 1 | `FAILED` | Unhandled exception during generation. Check `exception` field. |
| 2 | `FETCH_SOURCE_SUCCESSFUL` | Stack trace was parsed and source code was retrieved. |
| 3 | `PATCH_FORMAT_CORRECT` | LLM produced a syntactically parseable patch (triple-backtick extraction succeeded). |
| 4 | `PATCH_BUILD_SUCCESSFUL` | Patch compiled successfully. |
| 5 | `PATCH_FIXES_CRASH` | Patched binary no longer triggers the crash. |
| 6 | `PATCH_PASSES_CHECKS` | **SUCCESS**: crash fixed AND sanity/regression checks pass. This is `is_success() == True`. |
| 7 | `NOT_SUPPORTED` | The crash type or structure is not supported by the current patch generator. |

**Interpreting clusters by `max_patch_generation_status`:**
- `INIT_STATUS` / `FAILED` → likely infrastructure failure (container, API key, timeout)
- `FETCH_SOURCE_SUCCESSFUL` → stacktrace empty or no source found; LLM never queried
- `PATCH_FORMAT_CORRECT` → LLM answered but patch didn't build
- `PATCH_BUILD_SUCCESSFUL` → built but crash persists
- `PATCH_FIXES_CRASH` → crash fixed but regression tests broken
- `PATCH_PASSES_CHECKS` → full success

---

## pass@k Interpretation

When `--num-queries-per-prompt k` is used, the benchmark makes `k` independent patch attempts per case. `pass@k` is the probability that at least one of the `k` attempts succeeds.

In practice for autopatch, `pass@1` is the standard setting (one attempt per case). Use `pass@k` experiments to measure upper-bound performance and to estimate the benefit of best-of-k sampling.

**Formula for unbiased pass@k estimate** (from Codex paper):
```
pass@k = E_n[ 1 - C(n-c, k) / C(n, k) ]
```
where `n` = total samples, `c` = correct samples, `k` = target.

---

## Exploratory Metrics

These are not headline metrics but are useful for efficiency and ablation analysis:

| Metric | Interpretation |
|---|---|
| `build_iters` histogram | How many build attempts are needed? High mean → prompt format issues causing repeated build failures |
| `patch_gen_time` percentiles | Identify timeout-prone cases; measure prompt strategy efficiency |
| `llm_query_cnt` distribution | Higher count means more retries; correlates with difficulty |
| `llms_query_time / patch_gen_time` ratio | How much time is LLM vs. container execution? |
| `sanitizer_crash_type` × `max_patch_generation_status` heatmap | Which crash types does the model struggle with? |

---

## Notes on `num_passed_qa_checks` as Denominator

All `shr_*` metrics use QA-passed cases as denominator, not total cases. If a case fails QA (container won't start, image build failure), it is excluded. This means:

- `shr_correct_patches` over QA-passed cases ≠ `shr_correct_patches` over all cases
- Always report `num_passed_qa_checks` alongside `shr_*` metrics so readers can assess coverage
- Infrastructure improvements (better images, container pre-pulling) can raise QA pass rate and thus affect all metrics without any change to the LLM
