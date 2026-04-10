---
name: error-cluster-and-fix-proposer
description: |
  Analyze benchmark failures, cluster them by error pattern, and propose targeted improvements
  with human approval before writing any changes. Reads result schema from project/experiment-config.md.
  Trigger when the user says things like:
  "cluster failures", "why is the benchmark failing", "analyze errors", "improve benchmark performance",
  "what patterns are in the failures", "propose prompt improvements", "fix systematic errors",
  "error analysis", "what's going wrong with [model] runs", "analyze the failed cases",
  "why are so many cases failing", "categorize the errors", "what should I fix to improve results",
  "look at the failures from [run]", "diagnose the benchmark problems",
  "what failure patterns do you see", "why did [case] fail", "investigate failures from [run_id]",
  "show me the error breakdown", "what improvements would help the most".
version: 1.0.0
tools: Read, Glob, Grep, Bash, Write, Edit
---

# Skill: Error Cluster and Fix Proposer

Load benchmark failure cases from one or more runs, cluster them by error pattern, propose
specific improvements (prompt edits, new few-shot examples, code fixes), and — after
**explicit human approval** — implement only the approved changes.

**CRITICAL:** This skill NEVER writes changes to any file without first presenting proposals
to the user and receiving explicit approval. The human approval gate is mandatory.

**Prerequisite**: `project/experiment-config.md` should exist with the result file schema
so this skill knows which fields to use for success/failure classification.

---

## Step 0 — Read Project Config and Discover Run Directories

Read `project/experiment-config.md` to understand the result schema:
- `result_file_pattern` — which files contain per-case results
- `primary_result_field` — the field that indicates success/failure

If `project/experiment-config.md` is missing or the schema is unknown, ask the user:
> "What is the name of the field in your result files that indicates success or failure?
> (e.g., 'status', 'success', 'patch_success') And what is the success value? (e.g., 'PASS', 'true')"

```python
# Glob all run directories using the result_file_pattern from project/experiment-config.md
# Generic fallback: experiments/runs/*/stats.json or experiments/runs/*/results.json
```

List discovered runs and ask the user which to analyze:
```
Found N run directories:
  1. experiments/runs/20260402_143022_claude35s_C1_baseline/  (2026-04-02, 15 cases)
  2. experiments/runs/20260401_091500_gpt4o_C2_treatment/     (2026-04-01, 15 cases)
  ...

Which run(s) would you like to analyze?
  - Enter a number (e.g., "1") for a single run
  - Enter multiple numbers (e.g., "1 2") to combine runs
  - Enter "all" to analyze all runs
  - Enter "latest" to analyze the most recent run
```

---

## Step 1 — Load Failure Data

Read `project/experiment-config.md` to find:
- `per_case_result_file` — the filename for per-case detailed results (e.g., `patch_gen_reports.json`, `case_results.json`, `detailed_results.json`)
- `result_file_pattern` — for finding the aggregate results file

If `per_case_result_file` is not specified in config, ask the user:
> "What is the name of the per-case detailed result file in your run directories?
> (e.g., `patch_gen_reports.json`, `case_results.json`) This file should have one entry
> per test case with per-case outcome fields."

Load the per-case result file from each selected run directory:

```python
import json
from pathlib import Path

PER_CASE_FILE = "{{per_case_result_file from project/experiment-config.md}}"

all_reports = []
for run_dir in selected_runs:
    reports_path = Path(run_dir) / PER_CASE_FILE
    if reports_path.exists():
        data = json.loads(reports_path.read_text())
        # Normalize: handle both list and dict formats
        if isinstance(data, dict):
            entries = list(data.values())
        else:
            entries = data
        for entry in entries:
            entry["_run_dir"] = str(run_dir)
        all_reports.extend(entries)
    else:
        # Fall back to the aggregate result file
        agg_path = Path(run_dir) / "stats.json"
        if agg_path.exists():
            print(f"Note: {PER_CASE_FILE} not found in {run_dir}; "
                  f"falling back to stats.json (aggregate only — limited clustering)")

print(f"Loaded {len(all_reports)} total case reports")
```

Also load any secondary per-case files listed in `project/experiment-config.md`
(e.g., a separate responses file) that contain fields not in the primary per-case file:

```python
all_responses = {}
for run_dir in selected_runs:
    # Check for a secondary per-case file (e.g., responses.json)
    # Read field name from project/experiment-config.md if specified
    for candidate in ["responses.json", "outputs.json", "results.json"]:
        resp_path = Path(run_dir) / candidate
        if resp_path.exists() and candidate != PER_CASE_FILE:
            for r in json.loads(resp_path.read_text()):
                case_id = r.get("case_id") or r.get("id") or r.get("challenge_number")
                model = r.get("model", "unknown")
                all_responses[(case_id, model)] = r
            break
```

---

## Step 2 — Filter to Failed Cases

Use the `primary_result_field` and success value from `project/experiment-config.md`
(or the user's answer from Step 0) to identify failures.

```python
# Use field name and success value from config
SUCCESS_FIELD = "{{primary_result_field from config}}"  # e.g., "status", "patch_success"
SUCCESS_VALUE = "{{success value from config}}"          # e.g., "PASS", "true", "PATCH_PASSES_CHECKS"

failed = [
    r for r in all_reports
    if str(r.get(SUCCESS_FIELD, "")).lower() != str(SUCCESS_VALUE).lower()
]

print(f"Total cases: {len(all_reports)}")
print(f"Succeeded: {len(all_reports) - len(failed)}")
print(f"Failed: {len(failed)}")

# If there is a separate "infrastructure failure" field noted in project/experiment-config.md,
# split infra failures from logic/prompt failures. Otherwise treat all failures as one group.
```

---

## Step 3 — Group Failures into Clusters

Read `project/experiment-config.md` to understand which fields distinguish failure modes.
Group by the dimensions available in the per-case result files. Generic dimensions that
work for most systems:

### Dimension 1: Pipeline Stage / Status Field

If there is a field indicating *how far* a case got before failing (e.g., a stage name,
status enum, or last completed step), group by it:

```python
from collections import defaultdict, Counter

# Use the stage/status field from project/experiment-config.md
# (or infer from field names present in the result files)
stage_field = "{{pipeline_stage_field}}"  # e.g., "status", "stage", "last_step"

by_stage = defaultdict(list)
for r in failed:
    by_stage[r.get(stage_field, "unknown")].append(r)

print("\n=== Cluster by Pipeline Stage ===")
for stage, cases in sorted(by_stage.items(), key=lambda x: len(x[1]), reverse=True):
    print(f"  {stage}: {len(cases)} cases")
    print(f"    Examples: {[c.get('case_id', c.get('id', i)) for i, c in enumerate(cases[:3])]}")
```

### Dimension 2: Error Category Field

If there is a field categorizing the type of error (e.g., error class, bug type,
exception type), group by it:

```python
# Use an error category field from the result files (project-specific)
category_field = "{{error_category_field}}"  # e.g., "error_type", "bug_class"

by_category = defaultdict(list)
for r in failed:
    by_category[r.get(category_field, "unknown")].append(r)

print("\n=== Cluster by Error Category ===")
for cat, cases in sorted(by_category.items(), key=lambda x: len(x[1]), reverse=True):
    print(f"  {cat}: {len(cases)} cases")
```

### Dimension 3: Exception / Stack Trace Field

If cases have an exception or traceback field, cluster by error pattern:

```python
exception_cases = [r for r in failed if r.get("exception", "").strip()]
print(f"\n=== Cases with Exceptions: {len(exception_cases)} ===")
exception_patterns = Counter()
for r in exception_cases:
    exc = r["exception"]
    first_line = exc.split("\n")[0][:80]
    exception_patterns[first_line] += 1

for pattern, count in exception_patterns.most_common(10):
    print(f"  ({count}x) {pattern}")
```

**Present the cluster overview to the user** — adapt the presentation to whichever
dimensions are available in the result files:

```
=== FAILURE CLUSTER OVERVIEW ===

Total failed cases analyzed: [N]

By pipeline stage:
  [stage name] → [N cases, X%]  ← [brief description of what this stage means]
  ...

By error category (if field exists):
  [category] → [N cases, X%]
  ...

Cases with exceptions: [N]
  Most common: [top exception pattern]
```

---

## Step 4 — Show Representative Examples

For the top 2–3 clusters, load and display representative examples:

```python
# For each major cluster, show 2 representative cases
for cluster_name, cases in top_clusters:
    print(f"\n=== Cluster: {cluster_name} ({len(cases)} cases) ===")
    for case in cases[:2]:
        case_id = case.get('case_id') or case.get('id') or '(unknown)'
        print(f"  Case ID: {case_id}")
        print(f"  Model: {case.get('model', 'unknown')}")
        # Print any available category/error-type fields from the result
        for field in ['error_type', 'error_category', 'bug_class', 'stage', 'status']:
            if case.get(field):
                print(f"  {field}: {case[field]}")
        print(f"  Exception: {case.get('exception', '')[:200]}")
        
        # Offer to read chat.md for detailed analysis
        chat_path = Path(case["_run_dir"]) / "files" / f"case_{case['case_id']}" / case["model"] / "chat.md"
        if chat_path.exists():
            print(f"  Chat history: {chat_path}")
```

For the most common cluster, look for detailed run logs to identify the specific failure pattern.
The log location depends on your benchmark — check `project/experiment-config.md` for any
`log_directory` or `run_log_pattern` field. If not specified, ask the user:
> "Where are the detailed per-case run logs? (e.g., a `chat.md` conversation transcript,
> a `run.log`, or an `output.txt` per case directory)"

Once you know the path pattern, read logs from 1–2 representative failing cases:

```python
# Example: if logs are at run_dir/logs/case_{case_id}.log
# Adapt the path based on what the user tells you or what's in experiment-config.md
for case in representative_failing_cases[:2]:
    case_id = case.get("case_id") or case.get("id") or "(unknown)"
    # Try common log path patterns:
    for log_pattern in [
        Path(case["_run_dir"]) / "logs" / f"case_{case_id}.log",
        Path(case["_run_dir"]) / f"{case_id}" / "run.log",
        Path(case["_run_dir"]) / "files" / f"case_{case_id}" / "chat.md",
    ]:
        if log_pattern.exists():
            content = log_pattern.read_text()
            # Show the final portion which often contains the failure reason
            print(f"=== Case {case_id} log (last 3000 chars) ===")
            print(content[-3000:])
            break
```

Look for:
- Error messages from the system being evaluated
- LLM response patterns that indicate format or reasoning issues
- Whether the system is addressing the right root cause
- Infrastructure errors (timeouts, missing files) vs. logic/reasoning errors

---

## Step 5 — Propose Specific Improvements

Based on the cluster analysis, generate a numbered proposal list. For each cluster,
reason about the root cause and the appropriate fix type. Check `references/error-taxonomy.md`
if it exists; otherwise derive proposals from first principles.

**Proposal template:**

```
=== IMPROVEMENT PROPOSALS ===

Proposal 1: [Short title]
  Target cluster: [cluster name and size]
  Root cause: [1-2 sentences]
  Change type: [Prompt addition | New few-shot example | Code fix | Config change | Dataset exclusion]
  File to edit: [path to the prompt file, config, or code — read from project/experiment-config.md
                 or ask the user if not specified there]
  Proposed addition:
    ---
    [Exact text to add/change]
    ---
  Expected impact: [e.g., "+X% on primary metric for this cluster"]
  Risk: [Low | Medium | High] — [brief explanation]
  Evidence: [N cases in cluster, representative case IDs]

Proposal 2: [Short title]
  Target cluster: [cluster name]
  ...

Proposal 3: Add few-shot example for [error category]
  Target cluster: [error type with N cases, no current example]
  Root cause: No few-shot example exists for this error class
  Change type: New few-shot example
  Files to create: [ask user where examples are stored, or check project/experiment-config.md]
  Proposed content: [sketch of what the example should demonstrate]
  Note: Requires a human to write the actual example content

...
```

**Generic cluster → proposal mapping:**

| Cluster type | Canonical proposals |
|---|---|
| Output format errors (not parseable) | Add format constraint or example to the generation prompt |
| Logic/reasoning failures (output is valid but wrong) | Add chain-of-thought, root cause analysis step, or constraint to the reasoning prompt |
| Regression failures (primary check passes, secondary fails) | Add semantics-preserving constraint to follow-up prompts |
| Infrastructure exceptions | Dataset quality check; may be environment issue (not a prompt issue) |
| Error class with no few-shot example | Add new few-shot example entry for that class |

---

## Step 6 — HUMAN APPROVAL GATE (MANDATORY)

**Present the complete numbered proposal list to the user:**

```
I have identified [N] improvement proposals based on the cluster analysis.
Please review and tell me which to implement.

[Full proposal list from Step 5]

Which proposals would you like to implement?
Enter numbers (e.g., "1 3" or "1-3"), "all", or "none":
```

**WAIT for the user's response. Do NOT proceed to Step 7 until you have explicit approval.**

If the user says "none" or declines all proposals: summarize the analysis and stop.

If the user asks for clarification on any proposal: provide it, then re-ask for the approval decision.

If the user approves proposals: confirm exactly which ones will be implemented before making any changes:
> "I will implement Proposals [X, Y, Z]. This will modify [list files]. Shall I proceed?"

**Wait for final confirmation before writing any files.**

---

## Step 7 — Implement Approved Proposals (Only After Approval)

For each approved proposal, implement the change:

### Identifying file paths

If the proposal involves editing a prompt file, configuration file, or example index:
1. Check `project/experiment-config.md` for `code_directory` or prompt file paths.
2. If not specified there, ask the user: "Where is the file I should edit for this change?"
3. Always use `Read` to read the file before making any edits.

### Implementing prompt additions

Read the target prompt file first, then apply a minimal targeted edit. After editing,
show the diff to the user:
```
Modified: [path/to/prompts.py or equivalent]
  Added to [PROMPT_NAME]:
  + [the new text]
```

### Implementing new few-shot example entries

If the proposal involves adding a new few-shot example:
1. Ask the user where examples are stored (or find it in `project/experiment-config.md`).
2. Only update the example index if the example file already exists or the user provides content.
3. Show the proposed index update to the user before writing.

### Do NOT implement the following without explicit user content:
- Writing new few-shot example files (requires human expertise to write correct examples)
- Changing iteration limits or hyperparameters without a specific value from the user
- Modifying core pipeline or verification logic

---

## Step 8 — Suggest Verification Runs

After implementing approved changes, suggest a verification strategy using the run command
template from `project/experiment-config.md`:

```
=== VERIFICATION PLAN ===

Changes implemented:
  [list of changes made]

Recommended verification:
  1. Run on a small subset (10-20% of dataset) to check for regressions before full run.
     Use the run command template from project/experiment-config.md:
     [run command template — substitute verification output paths]

  2. Compare target metrics (use metric names from project/experiment-config.md):
     - Primary metric: expect INCREASE if the primary fix was implemented
     - Secondary metrics: watch for unexpected DECREASE (regression check)

  3. Focus re-analysis on the previously failing cluster:
     - [cluster name] should show reduced failure rate
     - Run error-cluster-and-fix-proposer again on the new results to compare

  4. If verification shows improvement, proceed to full dataset run.

Use the experiment-runner-monitor skill to launch the verification run.
```

---

## Example Walkthrough

**User says:** "cluster failures from the run I just did"

**You do:**
1. Read `project/experiment-config.md` — learn result file pattern, success field, metric names
2. Find the latest run directory and its per-case result file
3. Load N cases; identify M succeeded, K failed based on success field from config
4. Cluster by available dimensions: pipeline stage field, error category field, exception field
5. For the top 2-3 clusters, load representative case logs/chat histories to understand failure mode
6. Propose targeted fixes (prompt edits, new examples, config changes) matched to each cluster
7. Present proposals and WAIT for user approval
8. User selects proposals to implement
9. Read target files → apply minimal edits → show diff
10. Suggest verification run using the command template from `project/experiment-config.md`

---

## Reference Files

- `project/experiment-config.md` — result file schema, success field name, metric names,
  run command template — primary source of truth for this skill
- `project/experiment-config.md` — per_case_result_file, result_file_pattern, primary_result_field,
  metric_names — primary source of truth for locating and interpreting failure data
- `references/error-taxonomy.md` — if it exists: error taxonomy with prompt engineering
  fixes for each cluster type; otherwise derive taxonomy from cluster analysis directly
