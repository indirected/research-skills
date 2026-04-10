# AutoPatch Benchmark — Error Taxonomy and Triage Guide

This document catalogs every class of error observed in AutoPatch benchmark runs, with diagnostic criteria, root causes, and remediation steps.

---

## Layer 1 — Infrastructure Errors (before LLM is queried)

These errors appear before any patch generation begins. They are detected in the benchmark runner logs and in `responses.json` via `containers_pass_qa_checks: false`.

---

### ERR-INFRA-01: Container Pull Failure

**Symptom:**
```
Error response from daemon: unauthorized: authentication required
Error: unable to pull image: ...
podman pull: exit status 1
```

**Root cause:** ARVO container images must be pulled from a container registry. Either registry credentials are missing, the image tag does not exist, or the local podman daemon cannot reach the registry.

**Triage steps:**
1. Check if `--container-repository` flag was provided and points to a valid registry
2. Run `podman login <registry>` and verify credentials
3. Check if ARVO image tags match case IDs in the dataset (some old cases may not have prebuilt images)
4. Try pulling a single image manually: `podman pull <registry>/arvo-<case_id>-vul:latest`

**Fix:**
- Provide `--container-repository` pointing to the ECR/registry with prebuilt ARVO images
- If building locally: ensure `podman` daemon is running and the user has build permissions
- For CI: pre-authenticate with `aws ecr get-login-password | podman login --username AWS --password-stdin <ecr-url>`

---

### ERR-INFRA-02: Build Failure (Local Image Build)

**Symptom:**
```
STEP X/Y: RUN ...
Error: error building at STEP ...: exit status 1
Build failed for case_id N
```

**Root cause:** The benchmark is building ARVO container images locally rather than pulling them. Build can fail due to: Docker/Podman daemon not running, insufficient disk space, network access needed for package downloads, or broken Dockerfile.

**Triage steps:**
1. Check if Podman daemon is running: `systemctl status podman` or `podman info`
2. Check disk space: `df -h /var/lib/containers`
3. Check if `--container-repository` is set — if not, the benchmark builds locally
4. Look for specific package download failures in build logs

**Fix:**
- Use `--container-repository` to pull prebuilt images instead of building
- Ensure Podman daemon is running: `systemctl start podman`
- Free disk space if needed (ARVO images are large, ~2–10GB each)

---

### ERR-INFRA-03: QA Check Failure

**Symptom in logs:**
```
QA checks failed for case N (vul container)
containers_pass_qa_checks: false
```

**What QA checks verify:**
- Container starts without error
- Container reaches a healthy state
- The target binary exists inside the container
- The fuzzer crash can be reproduced inside the vul container

**Root cause:** Container built or pulled successfully but is in a broken state — missing binary, wrong entrypoint, or the crash does not reproduce in the provided container version.

**Triage steps:**
1. Start the container manually: `podman run -it <image> bash`
2. Check if the binary exists at the expected path
3. Try to reproduce the crash manually inside the container

**Fix:**
- Report as a dataset quality issue (some ARVO cases may have stale containers)
- Exclude the case from the dataset if reproducibility is confirmed broken
- Update `--container-repository` to a newer build of the images

---

## Layer 2 — LLM/API Errors (during LLM querying)

These errors occur after containers start but during LLM interaction.

---

### ERR-LLM-01: API Authentication Failure

**Symptom:**
```
AuthenticationError: No API key provided
anthropic.AuthenticationError: 401
openai.AuthenticationError: Incorrect API key
```

**Root cause:** The API key is not set in the environment or was passed incorrectly in the `--llm-under-test` specification.

**Triage:**
```bash
echo $ANTHROPIC_API_KEY   # Should print a non-empty key
echo $OPENAI_API_KEY
```

**Fix:**
- Set the key: `export ANTHROPIC_API_KEY=sk-ant-...`
- Or pass it directly: `--llm-under-test ANTHROPIC::claude-3-5-sonnet-20241022::sk-ant-...`
- Check that the key has access to the requested model

---

### ERR-LLM-02: Rate Limiting (429 Too Many Requests)

**Symptom:**
```
anthropic.RateLimitError: 429 Too Many Requests
Rate limit exceeded. Retry after N seconds.
Waiting N seconds before retry...
```

**Root cause:** Too many concurrent LLM calls exceed the API rate limit. Common when `--run-llm-in-parallel` is set high.

**Triage:**
- Check current `--run-llm-in-parallel` value
- Check Anthropic/OpenAI console for rate limit tier

**Fix:**
- Reduce `--run-llm-in-parallel` (try 2–4 for Anthropic, 8–16 for OpenAI depending on tier)
- The benchmark has built-in retry logic (`NUM_LLM_RETRIES`, `MAX_RETRY_TIMEOUT`) — wait and monitor
- Request higher rate limits from the API provider

---

### ERR-LLM-03: JSON / Format Parse Error (LLM Output)

**Symptom in logs:**
```
LLMOutputFormatError: Unexpected number of ``` in the answer
Failed to extract code from response: ...
WARNING: Failed to parse the LLM answer.
```

**Root cause:** The LLM did not wrap its patch in triple backticks as instructed, or produced an odd number of backtick markers. This increases `build_iters` without progress and eventually exhausts `max_iters`.

**Triage:**
- Check `chat.md` in `files/case_N/{model}/chat.md` for the raw LLM response
- Check `max_patch_generation_status == PATCH_FORMAT_CORRECT` — if this is the highest level reached, format errors are the bottleneck

**Fix (prompt engineering):**
- Strengthen the format instruction in `FOLLOWUP_PATCH_PROMPT` (see references in error-cluster-and-fix-proposer skill)
- Add explicit negative examples: "Do NOT write ```cpp or ```c, only use plain ``` markers"
- Consider adding a format validation step before attempting build

---

### ERR-LLM-04: Context Length Exceeded

**Symptom:**
```
anthropic.BadRequestError: prompt is too long
openai.BadRequestError: This model's maximum context length is X tokens
```

**Root cause:** The accumulated chat history (rootcause analysis + patch prompt + retry feedback) exceeds the model's context window. More likely with `minimize_context=False` and many retry rounds.

**Fix:**
- Enable `minimize_context` option (remove middle-of-conversation turns)
- Reduce `stack_ctx_depth` to provide less source code context
- Use `shorten_crash_output=True` (default) to truncate crash stacktraces
- Switch to a model with larger context window

---

## Layer 3 — Patch Generation Failures (LLM produces output but patch is wrong)

---

### ERR-PATCH-01: Build Failure After Patch

**Symptom:**
```
max_patch_generation_status: PATCH_FORMAT_CORRECT  (or lower)
build_iters: 4 (exhausted)
RETRY_BUILD_ERROR_PROMPT was sent N times
```

**Root cause patterns:**
1. LLM omitted headers needed for new types/functions it introduced
2. LLM changed the function signature (different return type or parameter names)
3. LLM introduced syntax errors (especially with complex template code)
4. LLM used C++17/C++20 features not available in the project's build configuration
5. LLM patched the wrong function (function not found at expected location)

**Triage:**
- Check `report.json` → `build_iters` count and `max_patch_generation_status`
- Read `chat.md` to see the build error feedback that was sent to the LLM
- Check the actual build error text in `RETRY_BUILD_ERROR_PROMPT` responses

**Prompt engineering fixes:**
- Add to `FOLLOWUP_PATCH_PROMPT`: "Include all necessary `#include` directives at the top of your rewritten function. Do not change the function signature."
- Emphasize: "DO NOT OMIT ANY CODE from the function body — partial functions cause build failures."
- Add: "Use only C++14 features unless the original code uses newer features."

---

### ERR-PATCH-02: Build Succeeds But Crash Not Fixed

**Symptom:**
```
max_patch_generation_status: PATCH_BUILD_SUCCESSFUL
fix_crash_iters: 4 (exhausted)
RETRY_NOT_FIXED_PROMPT was sent N times
```

**Root cause patterns:**
1. LLM addressed a symptom rather than the root cause (e.g., added a null check but didn't fix the underlying out-of-bounds access)
2. LLM patched the wrong function (root cause is in a different stack frame)
3. The crash has a complex trigger condition that the simple patch does not fully address
4. The LLM's root cause analysis was correct but the fix logic was wrong

**Triage:**
- Compare `sanitizer_crash_type` to the kind of patch attempted (read `chat.md`)
- Check `stack_ctx_depth` — if 1, the LLM may not see enough context to identify the right function

**Prompt engineering fixes:**
- Increase `stack_ctx_depth` to 2 or 3 to show more of the call chain
- Add crash type-specific guidance in few-shot examples (`show_fix_example=True`)
- Add to rootcause prompt: "The bug is most likely in the function that directly performs the unsafe operation, not in a helper that checks for it."

---

### ERR-PATCH-03: Sanity Check Failure (Regression)

**Symptom:**
```
max_patch_generation_status: PATCH_FIXES_CRASH
sanity_check_iters: 2+
RETRY_TEST_FAILURE_PROMPT was sent N times
The patch fixes the crash but does not pass regression tests.
```

**Root cause patterns:**
1. LLM added overly conservative null checks that change behavior for valid inputs
2. LLM removed a code path that handles legitimate cases
3. LLM changed memory allocation behavior in a way that breaks correct usage
4. The patch fixes the crash at the cost of incorrect semantics

**Triage:**
- Read `chat.md` to see which test failures were reported
- Check `sanity_check_time` — if very short, the tests may be trivially failing (test infrastructure issue)

**Prompt engineering fixes:**
- Add to the patch prompt: "Your fix must preserve all existing functionality — do not add early returns or null checks that would change behavior for valid inputs."
- Add: "Focus on fixing the specific unsafe operation, not adding defensive checks that change the function's contract."
- Provide better context about what the function is supposed to do

---

### ERR-PATCH-04: NOT_SUPPORTED

**Symptom:**
```
max_patch_generation_status: NOT_SUPPORTED
exception: "NOT_SUPPORTED: Unable to fetch the function source info..."
```

**Root cause:** The stack trace does not contain parseable file:line references, so no source code can be retrieved. Common for crashes where the stack trace format is non-standard (e.g., JIT-compiled code, stripped binaries, or crashes in third-party libraries not in the source tree).

**Fix:** These cases are excluded from the benchmark denominator — they represent a known limitation of the tool.

---

## Layer 4 — Timeout

**Symptom:**
```
Patch generation timed out after 28800 seconds
exception: "Patch generation timed out after 28800 seconds"
```

**Root cause:** A single case exceeded `PER_SAMPLE_PATCH_GENERATION_TIMEOUT` (8 hours). This is extremely rare but can happen if a container operation hangs.

**Fix:**
- These cases are rare in practice; investigate the specific case's container behavior
- If a case consistently times out, exclude it from the dataset

---

## Triage Checklist for a Failed Run

When a run completes with > 30% failed cases (`shr_patches_generated` < 0.7):

```
[ ] 1. Check num_passed_qa_checks — if low, it's an infrastructure problem (ERR-INFRA-*)
[ ] 2. Check exception field in patch_gen_reports.json — API errors appear here
[ ] 3. Check build_iters distribution — high mean (> 3) → format/build errors (ERR-PATCH-01)
[ ] 4. Check max_patch_generation_status distribution:
        - Clustered at FETCH_SOURCE_SUCCESSFUL → source retrieval failing
        - Clustered at PATCH_FORMAT_CORRECT → build errors
        - Clustered at PATCH_BUILD_SUCCESSFUL → logic errors
        - Clustered at PATCH_FIXES_CRASH → regression failures
[ ] 5. Check sanitizer_crash_type — are failures concentrated in one crash type?
[ ] 6. Read 2–3 chat.md files from failed cases to see actual LLM outputs
```

---

## Quick Reference: Error → Layer → Fix Priority

| Error | Layer | Priority | Fix |
|---|---|---|---|
| containers_pass_qa_checks=false | Infra | Critical — fix before anything else | Registry auth / podman daemon |
| AuthenticationError | API | Critical | Set correct API key |
| RateLimitError (429) | API | High | Reduce --run-llm-in-parallel |
| LLMOutputFormatError | Prompt | Medium | Strengthen format instructions |
| max_status = PATCH_FORMAT_CORRECT | Prompt | Medium | Fix build-error prompt |
| max_status = PATCH_BUILD_SUCCESSFUL | Prompt | Medium | Add crash-specific guidance |
| max_status = PATCH_FIXES_CRASH | Prompt | Low-Medium | Tighten scope instructions |
| TimeoutError | Infra/Case | Low | Investigate specific case |
| NOT_SUPPORTED | Dataset limit | Informational | Expected; exclude from analysis |
