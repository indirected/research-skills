# CybersecurityBenchmarks AutoPatch — Architecture & Run Reference

This document is the single authoritative reference for running the AutoPatch benchmark and understanding the available assets that an experiment can draw on.

---

## Repository Layout

```
/workspace/storage/CodeVul/
  code/CybersecurityBenchmarks/          # Benchmark source (git submodule)
    benchmark/
      run.py                             # Entry point: python -m CybersecurityBenchmarks.benchmark.run
      autopatching_benchmark.py          # AutoPatchingBenchmark class
      autopatch/
        patch_generator.py              # Core loop: rootcause → patch → verify → sanity
        prompts.py                      # All LLM prompt strings (SYSTEM_PROMPT, ROOTCAUSE_PROMPT, etc.)
        types.py                        # PatchGenerationStatus enum, PatchGenerationReport dataclass
        report.py                       # report.json parsing, markdown table writer
        fix_examples/                   # Few-shot fix examples keyed by sanitizer crash type
          fix_examples_index.json       # Map: crash_type → [filename, ...]
          direct-leak-1.log
          null-deref-1.log
          write-heap-buffer-overflow-1.log
          allocation-size-too-big-1.log
      llms/
        anthropic.py                    # ANTHROPIC provider
        openai.py                       # OPENAI provider
        googlegenai.py                  # GOOGLEGENAI provider
        together.py                     # TOGETHER provider
        meta.py                         # LLAMA provider
    datasets/autopatch/
      autopatch_lite_samples_short.json # 15 cases (fast CI subset)
      autopatch_lite.json               # ~113 cases (lite benchmark)
      autopatch_dbg.json                # Debug subset
      autopatch_dbg_build_mode.json     # Debug build-mode variant
      arvo_meta/                        # Per-case metadata and ground-truth patches
        {id}-meta.json
        {id}-patch.json
  experiments/                          # Lab outputs (plans, runs, results)
  skills/                               # Claude Code skill definitions
  paper/latex/                          # ACL LaTeX manuscript
```

---

## The Full Run Command

Run from the `code/CybersecurityBenchmarks/` directory (or any directory that has `CybersecurityBenchmarks` as a Python package on the path):

```bash
python -m CybersecurityBenchmarks.benchmark.run \
  --benchmark autopatch \
  --llm-under-test ANTHROPIC::claude-3-5-sonnet-20241022::$ANTHROPIC_API_KEY \
  --prompt-path datasets/autopatch/autopatch_lite_samples_short.json \
  --response-path results/responses.json \
  --stat-path results/stats.json \
  [--num-test-cases 5] \
  [--run-llm-in-parallel 4] \
  [--additional-args '--test-mode'] \
  [--container-repository <ecr-or-registry-url>] \
  [--debug]
```

### Flag Reference

| Flag | Required | Default | Notes |
|---|---|---|---|
| `--benchmark` | yes | — | Must be `autopatch` |
| `--llm-under-test` | yes | — | Format: `PROVIDER::MODEL::API_KEY` (see LLM Spec Format) |
| `--prompt-path` | yes | — | Path to dataset JSON (list of ARVO integer IDs) |
| `--response-path` | yes | — | Where per-case responses are accumulated |
| `--stat-path` | no | None | Where aggregate stats.json is written after eval |
| `--num-test-cases` | no | 0 (all) | Positive int limits to first N cases |
| `--run-llm-in-parallel` | no | 1 | Semaphore width for concurrent case processing |
| `--additional-args` | no | "" | Autopatch-specific flags (quote-escaped): `'--test-mode'`, `'--rerun-failed'`, `'--run-new-cases-only'` |
| `--container-repository` | no | None | ECR/registry URL to pull prebuilt ARVO images instead of building locally |
| `--debug` | no | false | Sets log level to DEBUG throughout |
| `--max-tokens` | no | 2048 | Max tokens for LLM queries |

### Autopatch Additional Args (--additional-args)

Pass these by wrapping in `'...'`:

| Additional Flag | Effect |
|---|---|
| `--test-mode` | Skip patch generation entirely; only test QA checks. Used for infra validation. |
| `--rerun-failed` | Re-run only cases where `patch_success == False` in the existing response file |
| `--run-new-cases-only` | Skip cases already present in the response file; add only new ones |

### Key Internal Constant

`PER_SAMPLE_PATCH_GENERATION_TIMEOUT = 60 * 60 * 8`  (8 hours per case)

This timeout applies per case. With high concurrency and many cases, total wall time can be much lower.

---

## LLM Specification Format

```
PROVIDER::MODEL::API_KEY[::BASE_URL]
```

Supported providers and example model strings:

| Provider token | API Key env var | Example model strings |
|---|---|---|
| `ANTHROPIC` | `ANTHROPIC_API_KEY` | `claude-3-5-sonnet-20241022`, `claude-3-opus-20240229`, `claude-3-haiku-20240307` |
| `OPENAI` | `OPENAI_API_KEY` | `gpt-4o-2024-11-20`, `gpt-4o-mini-2024-07-18`, `o1-2024-12-17` |
| `GOOGLEGENAI` | `GOOGLE_API_KEY` | `gemini-1.5-pro-002`, `gemini-2.0-flash-exp` |
| `TOGETHER` | `TOGETHER_API_KEY` | `meta-llama/Meta-Llama-3.1-70B-Instruct-Turbo` |
| `LLAMA` | `LLAMA_API_KEY` | Meta-hosted Llama endpoints |

Example:
```bash
--llm-under-test ANTHROPIC::claude-3-5-sonnet-20241022::$ANTHROPIC_API_KEY
```

---

## Dataset Files

| File | Case Count | Purpose |
|---|---|---|
| `autopatch_lite_samples_short.json` | 15 cases | Fast iteration / CI; recommended for pilot experiments |
| `autopatch_lite.json` | 113 cases | Standard lite benchmark; used in paper results |
| `autopatch_dbg.json` | varies | Debug-specific subset |
| `autopatch_dbg_build_mode.json` | varies | Debug with build-mode testing |

The files contain JSON arrays of integer ARVO challenge IDs, e.g. `[10445, 11429, 1273, ...]`.

---

## Output Files Produced by a Run

After a run completes, the following files exist relative to `--response-path`:

```
results/
  responses.json            # Array of per-case entries (model, arvo_challenge_number, patch_success, ...)
  stats.json                # Aggregate metrics per model (shr_correct_patches, shr_passing_fuzzing, ...)
  patch_gen_reports.json    # Array of detailed PatchGenerationReport entries per case
  files/
    case_{id}/
      {model}/
        patch.patch         # Git diff of the generated patch
        binary.bin          # Rebuilt binary after patching
        report.json         # PatchGenerationReport as flat JSON (single case)
        chat.md             # Full LLM conversation in markdown
        log_vul.txt         # Vulnerability container logs
        log_fix.txt         # Fix container logs
```

---

## Patch Generation Loop (for experiment design)

Each case goes through this pipeline inside `PatchGenerator`:

1. **Container start** — spin up `vul` and `fix` ARVO containers (podman)
2. **QA checks** — verify containers are healthy
3. **Crash reproduction** — confirm the crash reproduces in the vul container
4. **Source fetch** — parse stacktrace, retrieve C/C++ function source
5. **Rootcause prompt** (`ROOTCAUSE_PROMPT`) — LLM analyzes the crash
6. **Patch prompt** (`FOLLOWUP_PATCH_PROMPT`) — LLM rewrites the function
7. **Build verify** — apply patch, rebuild, check for build errors
8. **Crash fix verify** — run fuzz case, confirm crash no longer triggers
9. **Sanity checks** — run regression tests in fix container
10. **Repeat** — up to `max_iters` times with feedback prompts on failure

**Key configurable parameters** (exposed via `PatchGenConfig`):
- `max_iters` (default 4): iterations per retry round
- `max_retries` (default 1): full retry rounds
- `stack_ctx_depth` (default 1): number of stack frames shown to LLM
- `shorten_crash_output` (default True): truncate crash stacktrace at 10 frames
- `show_fix_example` (default False): include few-shot fix example in prompt
- `increasing_temperature` (default False): raise temperature each iteration

---

## Compute Estimation Formula

For planning:

```
wall_clock ≈ (num_cases × avg_patch_gen_time_seconds) / concurrency
```

Empirical timing observations (highly case-dependent):
- Median patch gen time (successful): ~8–20 minutes per case
- Median patch gen time (failed after max_iters): ~30–60 minutes per case
- Container startup: ~2–5 minutes per case
- Timeout per case: 8 hours (rarely hit)

Example: 15 cases, concurrency=4, avg 20 min/case → ~75 min wall clock
Example: 113 cases, concurrency=8, avg 25 min/case → ~5.9 hours wall clock
