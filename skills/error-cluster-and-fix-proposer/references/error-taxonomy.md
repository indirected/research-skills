# AutoPatch Benchmark — Error Taxonomy and Prompt Engineering Guide

This document covers all failure modes observed in AutoPatch runs, with additional prompt engineering patterns for each failure type. For the infrastructure-level triage guide (container pull failures, API key errors, rate limits), see the same-named file in the experiment-runner-monitor skill.

---

## Failure Mode Classification

### Cluster A — Infrastructure Failures (pre-LLM)

**Indicators:**
- `containers_pass_qa_checks: false` in responses.json
- `max_patch_generation_status: "INIT_STATUS"` or `"FAILED"`
- `exception` field non-empty with container or Python error

**Sub-types:**

| Sub-type | `exception` pattern | Fix |
|---|---|---|
| Container pull failure | `unauthorized`, `unable to pull image` | Registry auth, `--container-repository` |
| Build failure | `Build failed for case_id`, `exit status 1` | Podman daemon, disk space |
| API auth failure | `AuthenticationError`, `401` | Check API key env var |
| Rate limit | `RateLimitError`, `429` | Reduce `--run-llm-in-parallel` |
| Timeout | `Patch generation timed out` | Investigate specific case container |

**Analysis note:** Infrastructure failures are not model failures. Exclude them from model performance analysis. Report `num_passed_qa_checks` separately.

---

### Cluster B — Source Retrieval Failures

**Indicators:**
- `max_patch_generation_status: "FETCH_SOURCE_SUCCESSFUL"` (or stays at INIT)
- `patched_function_name: null`
- `llm_query_cnt: 0` (LLM was never queried)
- Log message: "The stack trace is empty or no function is found in the first stack trace."

**Root causes:**
1. Stack trace does not contain file:line references (stripped binary, JIT-compiled code)
2. Source file referenced in stack trace is not present in the container's working directory
3. Stack trace format is non-standard (platform-specific or third-party library)

**Analysis:** These cases become `NOT_SUPPORTED`. They are a known limitation of the source-retrieval approach. They should be excluded from the model performance denominator.

**Potential improvement direction:** Add a fallback source retrieval strategy for cases without clean file:line references (e.g., symbol-based lookup).

---

### Cluster C — Build Failures (patch produced but won't compile)

**Indicators:**
- `max_patch_generation_status: "PATCH_FORMAT_CORRECT"` (highest level reached)
- `build_iters` = max_iters (all iterations exhausted on build failures)
- `fix_crash_iters: 0` (never got to crash testing)

**Sub-patterns (from `chat.md` analysis):**

#### C1 — Missing Header Includes
**Symptom in log_vul.txt:** `error: use of undeclared identifier 'X'`, `error: no type named 'Y'`
**LLM behavior:** Introduces new types or functions (e.g., `safe_malloc`, `strnlen`) without including the required headers.

**Prompt engineering fix:**
In `FOLLOWUP_PATCH_PROMPT`, add:
```
If your fix introduces any new types, functions, or macros not already present in the 
original function, you MUST add the required #include directive at the top of your 
rewritten function, before the function definition.
```

**Example addition to prompt:**
```
Common headers you may need:
  #include <string.h>    // strnlen, memcpy, strchr
  #include <stdlib.h>    // malloc, free, realloc
  #include <stdint.h>    // uint32_t, size_t
```

#### C2 — Changed Function Signature
**Symptom in log_vul.txt:** `error: no matching function for call to 'X'`, `conflicting types for 'X'`
**LLM behavior:** Changes return type, parameter types, or parameter names, breaking all call sites.

**Prompt engineering fix:**
```
CRITICAL: Do NOT change the function signature (return type, parameter types, or parameter 
names). The output will replace the function body in-place; if you change the signature, 
all call sites will break.
```

#### C3 — Omitted Code (partial function)
**Symptom in log_vul.txt:** Syntax errors, `expected '}'`, `undeclared variable`
**LLM behavior:** Writes `// ... rest of function ...` or omits sections of the original function body.

**Prompt engineering fix:**
```
CRITICAL: Provide the COMPLETE rewritten function. Do NOT use comments like 
"// ... existing code ..." or "// rest of function unchanged". Every line of the 
original function must be present in your output, either verbatim or modified.
```

#### C4 — Language Standard Mismatch
**Symptom in log_vul.txt:** `error: 'auto' type specifier is a C++11 extension`, `error: use of undeclared identifier 'nullptr'`
**LLM behavior:** Uses C++11/14/17 features in a C89/C99/C++03 codebase.

**Prompt engineering fix:**
```
Match the language standard of the original code. If the original function uses C-style 
syntax (no auto, no nullptr, no range-based for loops), your patch must do the same.
```

---

### Cluster D — Logic Failures (builds but crash persists)

**Indicators:**
- `max_patch_generation_status: "PATCH_BUILD_SUCCESSFUL"` (highest level)
- `fix_crash_iters` = max_iters (all attempts exhausted)
- `sanity_check_iters: 0`

**Sub-patterns:**

#### D1 — Symptom Fix, Not Root Cause Fix
**LLM behavior:** Adds a null pointer check or bounds check that hides the crash but doesn't address why the out-of-bounds access occurs.
**Example:** For a heap-buffer-overflow, LLM adds `if (ptr != NULL)` but the real issue is an incorrect size calculation.

**Prompt engineering fix:**
```
Find and fix the ROOT CAUSE of the crash, not just the immediate symptom. For example:
- If the crash is a heap-buffer-overflow, the root cause is likely an incorrect size 
  calculation or an off-by-one in loop bounds. Fix the calculation, not just add a bounds check.
- If the crash is a null-dereference, the root cause may be that a pointer is not initialized 
  under certain conditions. Fix the initialization, not just add a null check that silently 
  returns early.
```

#### D2 — Wrong Function Patched
**LLM behavior:** Patches a function in the stack trace that is not the root-cause function (e.g., patches a validation helper instead of the function that produces the invalid value).
**Diagnosis:** `patched_function_name` names a function that is clearly a checker, not a producer.

**Prompt engineering fix (in `ROOTCAUSE_PROMPT`):**
```
When identifying the function to fix, prefer functions that PRODUCE potentially invalid 
values (e.g., compute a size, allocate memory, build a data structure) over functions 
that only CHECK values (e.g., functions named 'check*', 'validate*', 'assert*').
The bug is most likely in the function that creates the condition, not the one that detects it.
```

#### D3 — Incomplete Coverage of Crash Trigger
**LLM behavior:** Fixes the crash for the specific input but there are other code paths that lead to the same crash.
**Diagnosis:** Crash reproduces with a different input vector than the one shown.

**Prompt engineering fix:**
```
Your fix should address ALL code paths that could lead to this class of crash, not just 
the specific path shown in the stack trace. Consider all inputs to this function and 
ensure the fix is general.
```

---

### Cluster E — Regression Failures (crash fixed but tests broken)

**Indicators:**
- `max_patch_generation_status: "PATCH_FIXES_CRASH"` (highest level)
- `sanity_check_iters` > 0
- `sanity_check_time` > 0

**Sub-patterns:**

#### E1 — Overly Conservative Null Check
**LLM behavior:** Adds `if (ptr == NULL) return NULL;` where the function was previously guaranteed to receive a non-null pointer, changing the function's contract.
**Test failure:** Tests that call the function and expect meaningful output now receive NULL.

**Prompt engineering fix:**
```
Do not add early return statements or null checks unless the original function handles 
null inputs. Adding safety checks that change the function's return value for previously 
valid inputs will break existing tests. The fix must be semantics-preserving for all 
valid inputs.
```

#### E2 — Narrowed Functionality
**LLM behavior:** Removes a code path (e.g., simplifies a switch statement) to avoid the crash, but the removed path handles legitimate inputs.

**Prompt engineering fix:**
```
Your fix must preserve ALL existing functionality. Do not remove code paths, simplify 
logic, or restrict the set of inputs the function accepts. The only change should be 
to prevent the specific unsafe operation identified in the crash.
```

#### E3 — Changed Memory Management
**LLM behavior:** Changes allocation strategy (e.g., allocates a fixed buffer instead of dynamic allocation) in a way that leaks memory or changes ownership semantics.

**Prompt engineering fix:**
```
If you change memory allocation (malloc/free/realloc), ensure the ownership semantics 
are preserved — the caller should not be responsible for freeing memory that the callee 
now manages differently, and vice versa.
```

---

## Prompt Engineering Patterns Summary

This table maps failure clusters to specific prompt additions. File paths are relative to the benchmark source.

| Cluster | Affected prompt(s) | Addition type |
|---|---|---|
| C1 (missing headers) | `FOLLOWUP_PATCH_PROMPT` | Instruction + common header list |
| C2 (changed signature) | `FOLLOWUP_PATCH_PROMPT` | Critical constraint instruction |
| C3 (omitted code) | `FOLLOWUP_PATCH_PROMPT`, `RETRY_BUILD_ERROR_PROMPT` | Critical constraint + retry reminder |
| C4 (language standard) | `FOLLOWUP_PATCH_PROMPT` | Context-aware constraint |
| D1 (symptom fix) | `ROOTCAUSE_PROMPT` | Root cause vs. symptom distinction |
| D2 (wrong function) | `ROOTCAUSE_PROMPT` | Producer vs. checker preference |
| D3 (incomplete coverage) | `FOLLOWUP_PATCH_PROMPT` | Generality requirement |
| E1 (overly conservative) | `FOLLOWUP_PATCH_PROMPT`, `RETRY_TEST_FAILURE_PROMPT` | Semantics-preserving constraint |
| E2 (narrowed functionality) | `FOLLOWUP_PATCH_PROMPT` | Functionality preservation |
| E3 (memory management) | `FOLLOWUP_PATCH_PROMPT` | Ownership semantics constraint |

---

## Few-Shot Fix Example Opportunities

When a cluster shows repeated failures for a specific sanitizer type, adding a new entry to `fix_examples_index.json` and a corresponding `.log` file in `fix_examples/` can provide targeted few-shot guidance.

**Current coverage:**
- `direct-leak` → `direct-leak-1.log`
- `write-heap-buffer-overflow` → `write-heap-buffer-overflow-1.log`
- `null-deref` → `null-deref-1.log`
- `allocation-size-too-big` → `allocation-size-too-big-1.log`

**Gaps (no few-shot example):**
- `heap-use-after-free` — common crash type with no example
- `stack-buffer-overflow` — distinct from heap variant
- `double-free`
- Any crash type with `sanitizer_crash_type: "null"` (non-ASAN format)

**To add a new example:**
1. Write a `.log` file in `benchmark/autopatch/fix_examples/` with the format: crash output → root cause analysis → correct fix
2. Add an entry to `fix_examples_index.json`: `"crash-type-key": ["new-example.log"]`
3. Ensure `show_fix_example=True` is set in the run configuration

The `crash_type` key used for lookup in `patch_generator.py:get_fix_example()` comes from `PatchGenerationReport.crash_type`, which is set from the ARVO metadata (not the sanitizer string). Verify the key format before adding examples.
