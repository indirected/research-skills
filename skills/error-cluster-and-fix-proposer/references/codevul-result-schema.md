# CybersecurityBenchmarks AutoPatch — Result File Schema (Error Analysis Summary)

This is a targeted summary for error analysis. For the full schema, see:
`/workspace/storage/CodeVul/skills/result-analyzer-and-table-gen/references/codevul-result-schema.md`

---

## Files Used by Error Cluster Analysis

### `patch_gen_reports.json` — Primary Input

Location: `experiments/runs/*/patch_gen_reports.json`
Written by: `AutoPatchingBenchmark._write_to_patch_gen_reports_json()`

**Each element is one case × one model:**

```json
{
  "build_iters": 4,
  "case_id": 12803,
  "chat_history_length": 8,
  "crash_repro_time": 180,
  "crash_type": "heap-buffer-overflow",
  "exception": "",
  "fix_crash_iters": 2,
  "llm_query_cnt": 6,
  "llms_query_time": 45,
  "max_patch_generation_status": "PATCH_BUILD_SUCCESSFUL",
  "model": "claude-3-5-sonnet-20241022",
  "patch_gen_time": 1450,
  "patched_file_path": "src/parse.c",
  "patched_function_name": "mruby_parse",
  "retry_round": 0,
  "sanitizer_crash_type": "AddressSanitizer: heap-buffer-overflow",
  "sanity_check_iters": 0,
  "sanity_check_time": 0
}
```

**Key fields for clustering:**

| Field | Clustering use |
|---|---|
| `max_patch_generation_status` | Primary grouping dimension — indicates where in the pipeline the case stopped |
| `sanitizer_crash_type` | Secondary grouping — identifies the class of memory error |
| `exception` | Non-empty strings indicate unhandled Python exceptions (infra failures) |
| `build_iters` | High values (= max_iters) indicate format/build prompt failures |
| `crash_type` | ARVO/Lionhead internal type label |
| `patched_function_name` | null if LLM never produced a valid patch format |

---

## `PatchGenerationStatus` Values (for filtering failed cases)

Failed cases are those where `max_patch_generation_status != "PATCH_PASSES_CHECKS"`:

| Value (string in JSON) | Success? | Failure category |
|---|---|---|
| `INIT_STATUS` | No | Infrastructure: never started |
| `FAILED` | No | Infrastructure: unhandled exception (check `exception` field) |
| `FETCH_SOURCE_SUCCESSFUL` | No | Source retrieval: stacktrace unparseable or no source found |
| `PATCH_FORMAT_CORRECT` | No | Build failure: patch generated but didn't compile |
| `PATCH_BUILD_SUCCESSFUL` | No | Logic failure: compiled but crash not fixed |
| `PATCH_FIXES_CRASH` | No | Regression: crash fixed but sanity checks failed |
| `PATCH_PASSES_CHECKS` | **YES** | Full success |
| `NOT_SUPPORTED` | No | Known limitation: crash type not supported |

**For analysis, filter to:** `max_patch_generation_status != "PATCH_PASSES_CHECKS"` AND `max_patch_generation_status != "NOT_SUPPORTED"`

---

## `responses.json` — Secondary Input

Location: `experiments/runs/*/responses.json`
Contains per-case infrastructure status.

```json
[
  {
    "model": "claude-3-5-sonnet-20241022",
    "arvo_challenge_number": 12803,
    "containers_pass_qa_checks": true,
    "patch_success": false,
    "generated_patch": "/path/to/patch.patch",
    "rebuilt_binary": "/path/to/binary.bin",
    "patched_function": "mruby_parse",
    "exception_message": null
  }
]
```

Use `containers_pass_qa_checks` to separate infrastructure failures from patch-generation failures.

---

## Per-Case Files (for deep-dive analysis)

For cases of interest, read individual files:

```
experiments/runs/{RUN_ID}/files/case_{id}/{model}/
  chat.md        — Full LLM conversation (most useful for understanding failures)
  report.json    — Single-case PatchGenerationReport (same fields as patch_gen_reports.json entry)
  patch.patch    — Git diff of the attempted patch (if any was generated)
  log_vul.txt    — Vulnerability container logs (build errors, crash reproduction logs)
  log_fix.txt    — Fix container logs (regression test output)
```

**`chat.md` structure:** Sections labeled "Message N" alternate between user prompts and LLM responses.
- Messages 1–2: ROOTCAUSE_PROMPT and LLM root cause analysis
- Messages 3–4: FOLLOWUP_PATCH_PROMPT and LLM patch attempt
- Messages 5+: RETRY_BUILD_ERROR_PROMPT / RETRY_NOT_FIXED_PROMPT / RETRY_TEST_FAILURE_PROMPT and LLM retry attempts

---

## Sanitizer Crash Types (common values)

The `sanitizer_crash_type` field is extracted by regex from the raw crash output. Common values:

| Value | What it means |
|---|---|
| `AddressSanitizer: heap-buffer-overflow` | Write or read past the end of a heap allocation |
| `AddressSanitizer: stack-buffer-overflow` | Write past the end of a stack-allocated buffer |
| `AddressSanitizer: heap-use-after-free` | Accessing freed memory |
| `AddressSanitizer: memory leak` / `AddressSanitizer: direct-leak` | Allocated memory not freed |
| `AddressSanitizer: null-dereference` | Null pointer dereference |
| `AddressSanitizer: allocation-size-too-big` | Requested allocation size exceeds limits |
| `null` | Crash output did not match sanitizer summary pattern (non-ASAN crash or format issue) |

These values correspond to the fix_examples_index.json keys:
- `direct-leak` → `fix_examples/direct-leak-1.log`
- `write-heap-buffer-overflow` → `fix_examples/write-heap-buffer-overflow-1.log`
- `null-deref` → `fix_examples/null-deref-1.log`
- `allocation-size-too-big` → `fix_examples/allocation-size-too-big-1.log`
