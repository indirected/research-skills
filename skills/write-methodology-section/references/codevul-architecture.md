# AutoPatch Codebase Architecture Reference

This file describes the key files, data flow, and architecture of the AutoPatch benchmark system.
Use this as ground truth when writing the Methodology/System Design section of the paper.

---

## Repository Layout

```
/workspace/storage/CodeVul/
├── code/
│   └── CybersecurityBenchmarks/
│       └── benchmark/
│           └── autopatch/
│               ├── types.py              # Core data structures
│               ├── patch_generator.py    # Base patch generator interface
│               ├── my_patch_generator.py # DiagPatchGenerator implementation
│               ├── prompts.py            # LLM prompt templates
│               ├── tools.py              # Container interaction utilities
│               ├── autopatch_tools.py    # Higher-level pipeline tools
│               ├── report.py             # Benchmark reporting
│               ├── source_utils.py       # Source code retrieval
│               ├── llm_interface.py      # LLM API wrapper
│               ├── codex_interface.py    # Codex-specific interface
│               ├── crash_native.py       # Crash/stack trace parsing
│               ├── ROADMAP.md            # Architecture narrative (milestone-by-milestone)
│               └── build/               # LLDB deb packages, arvo_clean script
├── paper/
│   └── latex/
│       ├── acl_latex.tex                # Main LaTeX file
│       ├── custom.bib                   # Bibliography
│       └── sections/                   # Section .tex files
├── experiments/
│   └── results_analysis_20260402.md     # Latest results analysis
└── literature/
    └── synthesis/                       # Synthesized paper cards
```

---

## Core Data Structures (from types.py)

### PatchGenerationStatus (Enum)
Ordered stages in the patch generation pipeline:
```
INIT_STATUS (0)         — initial state
FAILED (1)              — unhandled exception; pipeline aborted
FETCH_SOURCE_SUCCESSFUL (2) — source code for crashing function retrieved
PATCH_FORMAT_CORRECT (3)    — LLM output parses as valid function patch
PATCH_BUILD_SUCCESSFUL (4)  — patched code compiles successfully
PATCH_FIXES_CRASH (5)       — PoC input no longer triggers crash (Tier 1 pass)
PATCH_PASSES_CHECKS (6)     — differential debugging sanity check passes (success)
NOT_SUPPORTED (7)       — crash type not handled by current system
```
`is_success()` returns True only for `PATCH_PASSES_CHECKS`.

### PatchGenerationReport (Dataclass)
The central result object for a single ARVO case. Key fields:
- `crash_id`: ARVO case identifier
- `crash_type`: Lionhead crash classification
- `sanitizer_crash_type`: extracted from ASAN/MSAN/UBSAN SUMMARY line
- `patch_generation_status`: current pipeline stage
- `max_patch_generation_status`: highest stage reached (logged even if later stages fail)
- `retry_round`: how many times the full Tier 1 loop was restarted
- `build_iters`: number of build-fix cycles (LLM requeried after build failure)
- `fix_crash_iters`: number of crash-fix cycles (LLM requeried after PoC still crashes)
- `sanity_check_iters`: number of sanity check cycles
- `patch_gen_time`: wall-clock time in seconds
- `llm_query_cnt`: total number of LLM API calls
- `patched_function_name`: name of the function that was patched
- `patched_file_path`: source file containing the patched function

### PatchGenCrashInfo (Dataclass, frozen)
Input to the patch generator. Contains:
- `crash_id`, `output` (full sanitizer output), `crash_commit`
- `crash_type` (Lionhead), `sanitizer_crash_type` (extracted from SUMMARY)
- `get_output(shorten_depth=N)`: returns stack trace truncated to N frames, followed by SUMMARY line — this is what is fed to the LLM.

### CrashReproduceResult / PatchVerificationResult
- `CrashReproduceResult.is_reproduced()`: True if build succeeded AND crash was NOT eliminated — i.e., the bug still exists (used before patching to confirm the bug is reproducible).
- `PatchVerificationResult`: wraps `CrashReproduceResult` + `SanityCheckResult` (differential debugging result).

---

## Pipeline: How a Single ARVO Case is Processed

```
INPUT: ARVO case (crash_id, PoC input, Docker image, sanitizer crash output, source file + function)

1. CONTAINER SETUP
   - Pull/start the ARVO Docker image (vul container = vulnerable version of the code)
   - Copy source code into container

2. QA CHECK (pre-patch)
   - Verify the PoC input triggers the crash in the vul container (ASAN/MSAN output with expected SUMMARY)
   - If fails: mark FAILED, skip to output

3. SOURCE FETCH
   - Retrieve the crashing function's source code (file path + function name from stack trace)
   - Status → FETCH_SOURCE_SUCCESSFUL

4. TIER 1 LOOP (DiagPatchGenerator / repair loop)
   a. Build prompt: crash output (truncated stack trace + SUMMARY) + vulnerable function source
   b. Query LLM → receive patched function text
   c. Parse LLM output: check format (function signature preserved, valid C/C++)
      → Status → PATCH_FORMAT_CORRECT (or back to 4a if format wrong)
   d. Apply patch to source in container, rebuild
      → Status → PATCH_BUILD_SUCCESSFUL (or back to 4a with build error feedback)
   e. Run PoC input against patched binary
      → Status → PATCH_FIXES_CRASH (or back to 4a with crash output feedback)
   f. If PoC still crashes after MAX_ITERATIONS: retry_round++ and restart from 4a
      (up to MAX_RETRY_ROUNDS)

5. SANITY CHECK (differential debugging, Tier 4)
   - Run LLDB-based differential testing comparing vulnerable vs. patched binary
   - Status → PATCH_PASSES_CHECKS (success) or FAILED (regression detected)

6. OUTPUT: PatchGenerationReport with all metrics
```

---

## Multi-Tier Verification Architecture (per ROADMAP.md)

The full multi-tier system extends the basic pipeline with three additional verification tiers:

```
Tier 1: PoC Crash Fix          (existing — FUZZING mode, vul container)
         Verdict: PATCH_FIXES_CRASH
Tier 2: Developer Test Suite   (M3 — TEST mode, vul container)
         Verdict: all tests pass with total_tests > 0
Tier 3: Code Coverage          (M3 — COVERAGE mode, informational)
         Metric: line coverage percentage
Tier 4: Differential Testing   (M1 — LLDB microsnapshots, fix container)
         Verdict: no behavioral regression vs. fixed commit
```

**Success definition**: A patch is **correct** if Tier 1 AND Tier 2 both pass. Tiers 3 and 4 are informational quality signals.

### Container Build Modes

| Mode       | Build script            | Run input            | Purpose                         |
|------------|------------------------|---------------------|---------------------------------|
| FUZZING    | OSS-Fuzz compile       | PoC input bytes     | Crash reproduction, Tier 1 check |
| TEST       | test_build.sh (Codex)  | test_run.sh         | Developer test suite, Tier 2     |
| COVERAGE   | coverage_build.sh      | coverage_run.sh     | Code coverage, Tier 3            |

Mode switches always clean first (`arvo_clean` → `git clean`), then rebuild. Incremental builds within a mode (for the agentic repair loop) do NOT clean.

### ArvoContainer Methods (M3)
Key methods added to `ArvoContainer` in `arvo_utils.py`:
- `switch_to_test_mode()`: arvo_clean + test_build.sh
- `switch_to_coverage_mode()`: arvo_clean + coverage_build.sh
- `switch_to_fuzzing_mode()`: arvo_clean + compile (existing)
- `run_tests() -> TestResult`: execute test_run.sh, parse pass/fail counts
- `run_coverage() -> CoverageResult`: execute coverage_run.sh, parse coverage %
- `incremental_test_build(changed_file)`: recompile only one file (no clean), for agentic loop
- `inject_decoupled_scripts()`: copy Codex-generated scripts into container at /usr/local/bin/

### Codex-Generated Per-Project Scripts (M2)
Because OSS-Fuzz's `compile` script only builds fuzzer binaries (incompatible with developer test suites), Codex generates four per-project scripts for each ARVO case:
- `test_build.sh`: build project using native build system (cmake/make/meson), not OSS-Fuzz compile
- `test_run.sh`: run developer test suite, output structured pass/fail counts
- `coverage_build.sh`: same as test_build.sh with gcov instrumentation flags
- `coverage_run.sh`: run tests with lcov coverage reporting

Scripts are validated (build, run, check N > 0 results) and stored in `decoupled_scripts/` per case.

---

## Agentic Repair Loop (M5 design)

```
[Tier 1 loop: DiagPatchGenerator]
  → LLM receives: crash output + vulnerable function
  → LLM returns: patched function
  → If PoC fixed: proceed to Tier 2
  → If not: feed build errors or crash output back to LLM, retry (up to MAX_ITERS)

[Tier 2 loop: MultiTierRepairAgent]
  → Switch container to TEST mode
  → Run developer tests
  → If all pass: done (record tier2_tests_passed=True)
  → If failures: feed test failure output (test name, stdout, expected vs actual) to LLM
      with TEST_FAILURE_REPAIR_PROMPT
  → LLM refines patch
  → Incremental rebuild (no clean)
  → Re-verify PoC still fixed (fast, no rebuild)
  → Retry tests
  → Up to TIER2_MAX_ITERS iterations

[Tier 3: Coverage measurement (informational)]
  → Switch to COVERAGE mode
  → Report line coverage %

[Tier 4: Differential testing (informational)]
  → Run LLDB microsnapshots on fix container
  → Report behavioral equivalence verdict
```

---

## Prompt Structure (from prompts.py)

The LLM receives a structured prompt containing:
1. **System message**: role framing ("You are a C/C++ security engineer...")
2. **Crash context**: the sanitizer output, truncated to N stack frames + SUMMARY line
3. **Source code**: the vulnerable function (file path, function name, full source text)
4. **Instruction**: "Return the complete corrected function. Do not change the function signature. Wrap the function in ```c ... ``` code blocks."
5. **Conversation history**: prior attempts and their failure messages (build errors, crash output) — enables multi-turn repair

For Tier 2 failure repair, an additional prompt (`TEST_FAILURE_REPAIR_PROMPT`) provides:
- The current patch
- Specific test failures (test name, stdout, expected vs. actual output)
- Instruction to fix the logic error without breaking the PoC fix

---

## Evaluation Metrics

From `results_analysis_20260402.md` (ARVO-Lite, 15 cases, Claude 3.5 Sonnet):

| Metric                         | Value        |
|-------------------------------|-------------|
| QA pass rate                  | 86.7% (13/15) |
| Patch generation rate         | 92.3% (of QA-passed) |
| Tier 1 pass (crash fixed)     | 60.0% (9/15) |
| Correct patch rate            | 53.3% (8/15) |
| Avg build iterations          | 2.1 |
| Avg crash-fix iterations      | 1.8 |
| Avg patch gen time            | 4.7 min |

PatchGenerationStatus distribution:
- PATCH_PASSES_CHECKS: 8 cases (53.3%)
- PATCH_FIXES_CRASH: 1 case (6.7%)
- PATCH_BUILD_SUCCESSFUL: 2 cases (13.3%)
- PATCH_FORMAT_CORRECT: 1 case (6.7%)
- FAILED: 3 cases (20.0%)

---

## Key Design Decisions (for paper narrative)

1. **Function-level granularity**: Patches replace exactly one function. This keeps the LLM output space bounded and makes patch application deterministic. Multi-file patches are out of scope for v1.

2. **Incremental verification**: The pipeline verifies each step before proceeding to the next. If build fails, the LLM is queried with build errors — not crash output. This prevents the model from confusing error types.

3. **Containerized evaluation**: ARVO Docker images provide exact reproducibility. No host-system dependencies. Each case runs in isolation.

4. **Decoupled script generation**: OSS-Fuzz's compile script cannot produce developer test binaries. Project-specific test scripts generated by Codex solve this elegantly without modifying OSS-Fuzz infrastructure.

5. **Multi-turn repair**: Rather than submitting one query per case, AutoPatch maintains conversation history. Each failed attempt provides feedback that guides the next generation, mimicking a developer debug session.
