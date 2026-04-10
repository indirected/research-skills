# CybersecurityBenchmarks AutoPatch — Architecture & Run Reference

This is a copy of the shared run reference for use by the result-reproduction-verifier skill.
Authoritative source: `skills/experiment-designer/references/codevul-architecture.md`

---

## Repository Layout

```
/workspace/storage/CodeVul/
  code/CybersecurityBenchmarks/          # Benchmark source (git submodule)
    benchmark/
      run.py                             # Entry point
      autopatching_benchmark.py          # AutoPatchingBenchmark class
      autopatch/
        patch_generator.py              # Core loop: rootcause → patch → verify → sanity
        prompts.py                      # LLM prompt strings
        types.py                        # PatchGenerationStatus enum, PatchGenerationReport
        report.py                       # report.json parsing, markdown table writer
        fix_examples/                   # Few-shot fix examples by crash type
      llms/
        anthropic.py                    # ANTHROPIC provider
        openai.py                       # OPENAI provider
        googlegenai.py                  # GOOGLEGENAI provider
    datasets/autopatch/
      autopatch_lite_samples_short.json # 15 cases — use for reproduction
      autopatch_lite.json               # ~113 cases — full benchmark
      arvo_meta/                        # Per-case metadata and ground-truth patches
        {id}-meta.json
        {id}-patch.json
  experiments/                          # Lab outputs (plans, runs, results)
  experiments/reproduction/             # Reproduction run outputs
  skills/                               # Claude Code skill definitions
  paper/latex/                          # ACL LaTeX manuscript
```

---

## The Full Run Command

Run from `code/CybersecurityBenchmarks/` (or any directory with the package on the Python path):

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

For reproduction runs, use `--prompt-path` pointing to a temporary JSON file with just
the selected case IDs:
```bash
echo "[12803, 10445, 35727]" > /tmp/repro_cases.json
--prompt-path /tmp/repro_cases.json
```

### Flag Reference

| Flag | Required | Default | Notes |
|---|---|---|---|
| `--benchmark` | yes | — | Must be `autopatch` |
| `--llm-under-test` | yes | — | Format: `PROVIDER::MODEL::API_KEY` |
| `--prompt-path` | yes | — | Path to dataset JSON (list of ARVO integer IDs) |
| `--response-path` | yes | — | Where per-case responses accumulate |
| `--stat-path` | no | None | Where aggregate stats.json is written |
| `--num-test-cases` | no | 0 (all) | Limit to first N cases |
| `--run-llm-in-parallel` | no | 1 | Concurrent case processing |
| `--additional-args` | no | "" | Autopatch-specific flags (quote-escaped) |
| `--container-repository` | no | None | ECR/registry URL for prebuilt ARVO images |
| `--debug` | no | false | Sets log level to DEBUG |

### Useful Additional Args for Reproduction

| Flag | Effect |
|---|---|
| `'--rerun-failed'` | Re-run only cases where `patch_success == False` |
| `'--run-new-cases-only'` | Skip cases already in response file |

---

## LLM Specification Format

```
PROVIDER::MODEL::API_KEY[::BASE_URL]
```

| Provider token | API Key env var | Example model strings |
|---|---|---|
| `ANTHROPIC` | `ANTHROPIC_API_KEY` | `claude-3-5-sonnet-20241022`, `claude-3-opus-20240229` |
| `OPENAI` | `OPENAI_API_KEY` | `gpt-4o-2024-11-20`, `gpt-4o-mini-2024-07-18` |
| `GOOGLEGENAI` | `GOOGLE_API_KEY` | `gemini-1.5-pro-002`, `gemini-2.0-flash-exp` |

---

## Datasets

| File | Case count | Use case |
|---|---|---|
| `autopatch_lite_samples_short.json` | 15 cases | Fast reproduction, CI |
| `autopatch_lite.json` | ~113 cases | Full benchmark reproduction |
| `autopatch_dbg.json` | varies | Debug reproduction |

---

## Output Files

```
results/
  responses.json            # Per-case entries
  stats.json                # Aggregate metrics per model
  patch_gen_reports.json    # Detailed PatchGenerationReport per case
  files/
    case_{id}/{model}/
      patch.patch           # Generated diff
      binary.bin            # Rebuilt binary
      report.json           # Per-case report
      chat.md               # Full LLM conversation
      log_vul.txt           # Vulnerability container logs
      log_fix.txt           # Fix container logs
```

---

## Timing Estimates for Reproduction Planning

Compute expected wall time:
```
wall_clock ≈ (num_cases × avg_patch_gen_time) / concurrency
```

Empirical timing (use for planning, actual times vary significantly):

| Scenario | Timing |
|---|---|
| Successful case, simple patch | 8–15 minutes |
| Successful case, complex patch | 15–30 minutes |
| Failed case (exhausts max_iters) | 30–60 minutes |
| Container startup overhead | 2–5 minutes per case |
| Maximum timeout per case | 8 hours (rarely reached) |

**Reproduction run estimates:**

| Cases | Concurrency | Expected wall time |
|---|---|---|
| 5 | 4 | ~30–45 minutes |
| 15 | 4 | ~1.5–3 hours |
| 15 | 8 | ~45–90 minutes |
| 113 | 8 | ~5–8 hours |

**Reproduction budget recommendation:**
- Quick sanity check: 5 cases (~45 min with concurrency=4)
- AE Functional badge: 15 cases (~3 hours with concurrency=4)
- AE Reproduced badge: Full dataset, 3 independent runs

---

## Key Internal Constant

`PER_SAMPLE_PATCH_GENERATION_TIMEOUT = 60 * 60 * 8`  (8 hours per case)

This timeout applies per case. With high concurrency, total wall time is much lower.

---

## Patch Generation Pipeline (for understanding reproduction variance)

Each case goes through this pipeline inside `PatchGenerator`:

1. **Container start** — spin up `vul` and `fix` ARVO containers (podman/docker)
2. **QA checks** — verify containers are healthy
3. **Crash reproduction** — confirm crash reproduces in vul container
4. **Source fetch** — parse stacktrace, retrieve C/C++ function source
5. **Rootcause prompt** — LLM analyzes the crash
6. **Patch prompt** — LLM rewrites the vulnerable function
7. **Build verify** — apply patch, rebuild, check for build errors
8. **Crash fix verify** — run fuzz case, confirm crash no longer triggers
9. **Sanity checks** — run regression tests in fix container
10. **Repeat** — up to `max_iters` times with feedback prompts on failure

**Sources of reproduction variance:**
- LLM temperature > 0: different responses each call (primary source)
- API version updates: model weights may change between runs
- Container startup timing: affects timeout-sensitive cases
- Network latency to API: affects total patch_gen_time

**To minimize variance for exact reproduction:**
- Use temperature=0 if the provider supports it (not all do)
- Pin the exact model version (e.g., `claude-3-5-sonnet-20241022` not `claude-3-5-sonnet-latest`)
- Use the same container registry / same image versions
- Run with the same `max_iters` and `max_retries` settings
