---
name: experiment-runner-monitor
description: |
  Construct, launch, and monitor benchmark runs. Reads run command template and dataset paths
  from project/experiment-config.md. Manages the full lifecycle of a single benchmark run.
  Trigger when the user says things like:
  "run the benchmark", "launch experiments", "run experiments", "monitor the run",
  "check experiment status", "run benchmark for [model]", "start the experiment",
  "execute the experiment plan", "kick off the experiment", "launch the run for [condition]",
  "run condition C2 from the plan", "start running [system] with [model]",
  "how do I run the benchmark", "construct the run command", "let's run the experiment now",
  "execute plan [date]", "fire off the benchmark", "check if the run is still going",
  "how many cases have finished", "did the run finish".
version: 2.0.0
tools: Read, Glob, Grep, Bash, Write, Edit
---

# Skill: Experiment Runner and Monitor

Construct the correct benchmark run command, validate the environment, launch the run,
monitor for early failures, and parse results on completion. Reads all project-specific
parameters from `project/experiment-config.md`.

---

## Step 0 — Check Prerequisites

Read the project config:

```
Read: project/experiment-config.md
Read: project/research-focus.md
```

**If `project/experiment-config.md` does not exist**, stop and tell the user:

> "I need `project/experiment-config.md` to run experiments.
> Please run the `project-init` skill first, or create this file with at minimum:
> ```markdown
> ## Run Command Template
> ```bash
> [your benchmark run command]
> ```
> ## Output File Schema
> primary_result_field: [metric_name]
> result_file_pattern: experiments/runs/*/stats.json
> ```"

Extract from `project/experiment-config.md`:
- `run_command_template` — the base command to run the benchmark
- `result_file_pattern` — where to find result files
- `primary_result_field` — the key metric to check after the run
- Dataset paths and sizes
- Timing estimate per run

---

## Step 1 — Check Environment

Before constructing any command, validate general prerequisites:

```bash
# Check for the run command's required tool (infer from template — python, java, etc.)
which python3 2>/dev/null && python3 --version
which python 2>/dev/null && python --version

# Check API keys (check all common ones)
echo "ANTHROPIC_API_KEY set:  $([ -n "$ANTHROPIC_API_KEY" ] && echo YES || echo NO)"
echo "OPENAI_API_KEY set:     $([ -n "$OPENAI_API_KEY" ] && echo YES || echo NO)"
echo "GOOGLE_API_KEY set:     $([ -n "$GOOGLE_API_KEY" ] && echo YES || echo NO)"
echo "TOGETHER_API_KEY set:   $([ -n "$TOGETHER_API_KEY" ] && echo YES || echo NO)"

# Check if the benchmark entrypoint exists
# (infer from the run command template in project/experiment-config.md)
```

Also run any environment setup checks specified in `project/experiment-config.md` under
a "## Environment Setup" section if it exists.

Report environment status:
```
Environment Check:
  Python: [version or "not found"]
  API keys set: [list keys that are set]
  [Any other checks from project/experiment-config.md]
```

If any critical check fails (API key missing for chosen provider, binary not found),
stop and tell the user what to fix.

---

## Step 2 — Load Experiment Parameters

**First, look for the latest experiment plan:**

```python
Glob("experiments/plan_*.md")  # sorted by modification time; use the most recent
```

If a plan file exists, read it and extract the conditions:
> "I found your experiment plan from [date]. It contains these conditions: [list].
> Which condition would you like to run now?"

If no plan file exists, ask the user for the minimal parameters:
- What condition label is this? (e.g., "C1_baseline", "C2_treatment")
- Which dataset to use? (list options from `project/experiment-config.md`)
- Which model? (e.g., claude-3-5-sonnet, gpt-4o)
- Any additional flags to add to the run command template?

---

## Step 3 — Construct the Run Command

Generate the full run command by substituting into the template from `project/experiment-config.md`.

**RUN_ID format:** `YYYYMMDD_HHMMSS_{model_short}_{condition_label}`

For the RUN_ID's model_short, derive a 4-8 character abbreviation from the model name:
- `claude-3-5-sonnet-20241022` → `c35s`
- `gpt-4o-2024-11-20` → `gpt4o`
- `gemini-1.5-pro` → `gem15`

The output directory should be: `experiments/runs/${RUN_ID}/`

Show the constructed command to the user and ask for confirmation:
> "Here is the command I will run. Please review and confirm (yes/no/edit):
> [full command with substitutions shown]"

Wait for confirmation before launching.

---

## Step 4 — Create the Run Directory and Metadata

```bash
RUN_DIR="experiments/runs/${RUN_ID}"
mkdir -p "${RUN_DIR}"
```

Write `${RUN_DIR}/run_metadata.json`:
```json
{
  "run_id": "${RUN_ID}",
  "started_at": "[current UTC timestamp]",
  "model": "[model]",
  "dataset": "[dataset]",
  "condition": "[condition_label]",
  "command": "[full command string]",
  "project_system_name": "[system_name from project/research-focus.md]"
}
```

---

## Step 5 — Launch the Run

**Option A: Foreground** (for short runs, ≤ 30 min estimate, or test/validation mode):
Run the command directly with output streaming to terminal and teed to log.

**Option B: Background** (recommended for full runs):
Use the Bash tool with `run_in_background: true`.

After launching:
> "Run launched. RUN_ID: [RUN_ID]
> Monitoring log at: ${RUN_DIR}/run.log
> I will check for early failure patterns."

---

## Step 6 — Monitor for Early Failure Patterns

After launch, check the first ~100 lines of the log for common failure patterns:

```bash
sleep 30
head -100 "${RUN_DIR}/run.log"
```

**Universal early failure patterns** (apply to any benchmark):

| Pattern | Diagnosis | Action |
|---|---|---|
| `AuthenticationError` / `401` / `unauthorized` | API key rejected | Check the API key env var |
| `No API key` / `APIKeyNotFound` | Missing API key | Set the env var and relaunch |
| `ModuleNotFoundError` / `ImportError` | Package not on PYTHONPATH | Fix PYTHONPATH or cd to correct dir |
| `FileNotFoundError` for dataset | Dataset path wrong | Check path in project/experiment-config.md |
| `RateLimitError` / `429` repeated | Rate limit | Reduce parallelism and relaunch |
| `ConnectionError` / `Timeout` | Network issue | Check connectivity; retry |

**Project-specific early failure patterns**: if `project/experiment-config.md` has a
"## Common Errors" section, check the log against those patterns too.

Alert the user immediately if any critical failure is found in the first 30 log lines.

---

## Step 7 — Periodic Status Check

For long-running experiments, provide status using files in `${RUN_DIR}/`:

Look for the result file pattern from `project/experiment-config.md`:
```bash
# Check if results files exist and have content
wc -l ${RUN_DIR}/stats.json 2>/dev/null || echo "stats.json: not yet written"
wc -c ${RUN_DIR}/responses.json 2>/dev/null || echo "responses.json: not yet written"
```

If results files are JSON arrays/objects, try to count completed entries:
```bash
python3 -c "
import json, sys
try:
    data = json.load(open('${RUN_DIR}/responses.json'))
    if isinstance(data, list):
        print(f'Responses written: {len(data)}')
    elif isinstance(data, dict):
        print(f'Stats keys: {list(data.keys())}')
except Exception as e:
    print(f'Not ready yet: {e}')
" 2>/dev/null
```

---

## Step 8 — Parse Results on Completion

When the run finishes, parse the primary result from the result file pattern
specified in `project/experiment-config.md`.

The `primary_result_field` from the config tells you which field to report.

```bash
python3 -c "
import json, sys
try:
    # Try stats.json first
    stats = json.load(open('${RUN_DIR}/stats.json'))
    print('=== RUN RESULTS ===')
    print(json.dumps(stats, indent=2))
except FileNotFoundError:
    print('stats.json not found — run may not have completed')
except json.JSONDecodeError:
    print('stats.json exists but is not valid JSON yet')
"
```

Report the primary metric and key secondary metrics.
Flag any unusual values (e.g., 0% success rate may indicate infrastructure failure).

---

## Step 9 — Print Run Summary

```
=== RUN COMPLETE ===
Run ID:      [RUN_ID]
Condition:   [condition_label]
Dataset:     [dataset] ([N] cases if known)
Duration:    [start → end]

Primary metric ([metric_name]): [value]
[Secondary metric 1]:           [value]
[Secondary metric 2]:           [value]

Output files:
  [result_file_pattern with RUN_ID substituted]
  ${RUN_DIR}/run.log
  ${RUN_DIR}/run_metadata.json

Next steps:
  - Analyze results: use result-analyzer-and-table-gen skill
  - Compare conditions: run next condition from experiment plan
  - Check failures: use error-cluster-and-fix-proposer skill
```

---

## Error Handling

If the run command template has "TODO" placeholders, stop and tell the user:
> "The run command template in `project/experiment-config.md` has unfilled TODOs.
> Please update the template before running."

If the result file is empty after the run completes, check the log for errors and report
the last 20 lines of the log to help diagnose.

If results look anomalous (e.g., 0% success rate, all errors), do not silently pass.
Report the anomaly and suggest checking the log or running a smaller test first.
