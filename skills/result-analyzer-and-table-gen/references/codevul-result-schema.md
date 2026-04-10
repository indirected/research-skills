# CybersecurityBenchmarks AutoPatch — Result File Schema

This document describes every result file produced by the AutoPatch benchmark pipeline.
Understanding these schemas is essential for correctly loading and computing statistics.

---

## File Overview

| File | Location | Format | Written by |
|---|---|---|---|
| `stats.json` | `stat_path` (passed to `run.py --stat-path`) | JSON object | `evaluate_results()` |
| `responses.json` | `response_path` | JSON array | `_write_to_response_json()` |
| `patch_gen_reports.json` | `response_path.parent/` | JSON array | `_write_to_patch_gen_reports_json()` |
| `report.json` | `files/case_{id}/{model}/report.json` | JSON object | `_gen_patch_and_binary()` |

---

## `stats.json` — Aggregate Statistics per Model

Written to `stat_path` after `evaluate_results()` completes. Top-level keys are model names.

```json
{
  "claude-3-5-sonnet-20241022": {
    "num_passed_qa_checks": 12,
    "num_generated_patched_function_name": 11,
    "num_passed_fuzzing": 8,
    "num_fuzzing_decode_errors": 1,
    "num_differential_debugging_errors": 0,
    "num_passed_fuzzing_and_differential_debugging": 7,
    "shr_patches_generated": "0.917",
    "shr_passing_fuzzing": "0.667",
    "shr_correct_patches": "0.583"
  }
}
```

### Field Definitions

| Field | Type | Description |
|---|---|---|
| `num_passed_qa_checks` | int | Cases where both vul and fix containers pass QA checks (images built, containers start correctly) |
| `num_generated_patched_function_name` | int | Cases where the LLM identified a function name to patch (among QA-passed cases) |
| `num_passed_fuzzing` | int | Cases where the generated patch fixes the crash (Tier 1 PoC fix) |
| `num_fuzzing_decode_errors` | int | Cases where fuzzing output could not be decoded — may indicate infrastructure issues |
| `num_differential_debugging_errors` | int | Cases where differential debugging failed to run (infra error, not a patch failure) |
| `num_passed_fuzzing_and_differential_debugging` | int | Cases where patch fixes crash AND passes differential testing (Tier 1 + Tier 4) — this is the "correct patch" definition |
| `shr_patches_generated` | str (float) | `num_generated_patched_function_name / num_passed_qa_checks` |
| `shr_passing_fuzzing` | str (float) | `num_passed_fuzzing / num_passed_qa_checks` — Tier 1 success rate |
| `shr_correct_patches` | str (float) | `num_passed_fuzzing_and_differential_debugging / num_passed_qa_checks` — primary correctness metric |

**Note**: If `num_passed_qa_checks == 0`, then `shr_*` fields are set to `"n/a"` instead of floats.

---

## `responses.json` — Per-Case Response Entries

A JSON array where each element is one case × one model.

```json
[
  {
    "model": "claude-3-5-sonnet-20241022",
    "arvo_challenge_number": 12803,
    "containers_pass_qa_checks": true,
    "generated_patch": "/path/to/results/files/case_12803/claude.../patch.patch",
    "rebuilt_binary": "/path/to/results/files/case_12803/claude.../binary.bin",
    "patched_function": "mruby_parse",
    "patch_success": true,
    "exception_message": null
  }
]
```

### Field Definitions

| Field | Type | Description |
|---|---|---|
| `model` | str | LLM identifier (e.g., `"claude-3-5-sonnet-20241022"`, `"gpt-4o-2024-11-20"`) |
| `arvo_challenge_number` | int | The ARVO OSS-Fuzz case ID |
| `containers_pass_qa_checks` | bool | Whether vul + fix containers both started and passed checks |
| `generated_patch` | str | Absolute path to the generated `.patch` file (or `"n/a"`) |
| `rebuilt_binary` | str | Absolute path to the rebuilt fuzzer binary (or `"n/a"`) |
| `patched_function` | str \| null | Name of the function the LLM chose to patch |
| `patch_success` | bool | Whether `max_patch_generation_status == PATCH_PASSES_CHECKS` |
| `exception_message` | str \| null | Exception text if the run crashed, else null |

---

## `patch_gen_reports.json` — Per-Case Patch Generation Reports

A JSON array of flattened `PatchGenerationReport` objects. Each entry corresponds to one case.

```json
[
  {
    "crash_id": 12803,
    "crash_type": "heap-buffer-overflow",
    "sanitizer_crash_type": "AddressSanitizer: heap-buffer-overflow",
    "patch_generation_status": "PatchGenerationStatus.PATCH_PASSES_CHECKS",
    "max_patch_generation_status": "PatchGenerationStatus.PATCH_PASSES_CHECKS",
    "exception": "",
    "retry_round": 0,
    "build_iters": 2,
    "fix_crash_iters": 3,
    "sanity_check_iters": 1,
    "crash_repro_time": 45,
    "llm_query_cnt": 6,
    "llms_query_time": 120,
    "sanity_check_time": 30,
    "patch_gen_time": 210,
    "patched_function_name": "mruby_parse",
    "patched_file_path": "src/parse.c"
  }
]
```

### Field Definitions

| Field | Type | Description |
|---|---|---|
| `crash_id` | int | ARVO case ID |
| `crash_type` | str | Crash type from ARVO metadata |
| `sanitizer_crash_type` | str | Crash type extracted from sanitizer output (e.g., `"AddressSanitizer: heap-buffer-overflow"`) |
| `max_patch_generation_status` | str | Highest status reached — primary success indicator |
| `retry_round` | int | How many full retry rounds were used |
| `build_iters` | int | Total build attempts (incremental within rounds) |
| `fix_crash_iters` | int | Total fix-crash attempts |
| `sanity_check_iters` | int | Total sanity check iterations |
| `crash_repro_time` | int | Seconds spent on crash reproduction |
| `llm_query_cnt` | int | Number of LLM API calls made |
| `llms_query_time` | int | Total seconds spent waiting for LLM responses |
| `patch_gen_time` | int | Total seconds for the whole patch generation process |
| `patched_function_name` | str \| null | Function name the LLM patched |
| `patched_file_path` | str \| null | File path of the patched function |

### `PatchGenerationStatus` Values (ordered by severity/progress)

```
INIT_STATUS          (0) — initial state
FAILED               (1) — unhandled exception
FETCH_SOURCE_SUCCESSFUL (2) — successfully fetched source code
PATCH_FORMAT_CORRECT (3) — LLM produced correctly formatted patch
PATCH_BUILD_SUCCESSFUL (4) — patch compiles without errors
PATCH_FIXES_CRASH    (5) — patch fixes the PoC crash
PATCH_PASSES_CHECKS  (6) — patch passes sanity checks (final success)
NOT_SUPPORTED        (7) — crash type not yet supported
```

For computing success: `is_success()` returns `True` only for `PATCH_PASSES_CHECKS`.

For a status distribution breakdown, group cases by `max_patch_generation_status` — this shows where failures occur in the pipeline.

---

## `report.json` — Individual Case Report

Per-case file at `files/case_{id}/{model}/report.json`. Same fields as `patch_gen_reports.json` entries.

Other files in `files/case_{id}/{model}/`:
- `patch.patch` — the generated diff
- `binary.bin` — rebuilt fuzzer binary
- `chat.md` — full LLM conversation history (markdown)
- `log_vul.txt`, `log_fix.txt` — container logs

---

## Milestone 6 Additional Fields

When the benchmark runs with `--multi-tier` (Milestone 6), these keys are added to the per-case entries and aggregate stats:

| Field | Type | Location | Description |
|---|---|---|---|
| `tier2_tests_passed` | bool | responses.json + stats | Developer test suite passed (Tier 2) |
| `tier2_test_stats` | object | responses.json | `{total, passed, failed, skipped}` |
| `tier2_repair_iters` | int | responses.json | LLM repair iterations needed for Tier 2 |
| `tier3_coverage_pct` | float | responses.json | Line coverage percentage (0–100) |
| `tier4_diff_passed` | bool | responses.json | Differential testing passed (Tier 4) |
| `num_tier2_passed` | int | stats | Count of cases passing Tier 2 |
| `shr_tier2_passed` | str | stats | Rate of Tier 2 pass among QA-passed cases |
| `mean_tier3_coverage` | str | stats | Mean coverage % across cases |

**Correct patch definition with Milestone 6**: Tier 1 (crash fixed) + Tier 2 (tests pass).
Tiers 3 and 4 remain informational quality signals.

---

## Computing Key Paper Metrics

```python
import json

with open("stats.json") as f:
    stats = json.load(f)

for model, s in stats.items():
    total_cases = 15  # from dataset length
    qa_pass = s["num_passed_qa_checks"]
    tier1_rate = float(s["shr_passing_fuzzing"]) if s["shr_passing_fuzzing"] != "n/a" else 0
    correct_rate = float(s["shr_correct_patches"]) if s["shr_correct_patches"] != "n/a" else 0
    
    print(f"{model}")
    print(f"  QA pass:       {qa_pass}/{total_cases} ({qa_pass/total_cases:.1%})")
    print(f"  Tier 1 (crash fix): {tier1_rate:.1%} of QA-passed")
    print(f"  Correct patch: {correct_rate:.1%} of QA-passed")
```
