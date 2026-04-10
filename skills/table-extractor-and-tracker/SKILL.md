---
name: table-extractor-and-tracker
description: |
  Use this skill whenever the user wants to verify that numbers in the paper match the
  experiment results, track numeric claims, check for stale values, or sync paper content
  with the latest benchmark outputs. Trigger on phrases like:
  "track paper numbers", "are the numbers in the paper up to date",
  "extract tables from paper", "check if results match paper",
  "numbers tracker", "stale numbers", "sync paper numbers with results",
  "update the numbers in the paper", "verify paper claims match experiments",
  "check that our tables are accurate", "did the numbers change",
  "is the paper consistent with the latest run", "verify the results section",
  "update results in the paper", "are the percentages correct",
  "find outdated numbers", "check for stale claims", "update table values",
  "do the numbers match the json", "reconcile paper with results".
  Use proactively after any new experiment run completes or before submission.
version: 1.0.0
tools: Read, Glob, Grep, Bash, Write, Edit
---

# Table Extractor and Numbers Tracker

This skill parses all `.tex` files in the paper for numeric claims (table cells, inline
percentages, counts), maps each value to its source in the experiment result files
(`stats.json`, `patch_gen_reports.json`, `responses.json`), flags stale values, and
optionally updates the `.tex` files to match the current results.

**Important**: The paper lives in `paper/` which is a git submodule pointing to Overleaf.
After any changes to `.tex` files, remind the user to `git push` from within `paper/`.

---

## Output Locations

| Output | Path |
|---|---|
| Numbers tracker | `paper/numbers_tracker.json` |
| Stale numbers report | `paper/stale_numbers_YYYYMMDD.md` |

---

## Step 0: Check Prerequisites and Load Config

Read `project/experiment-config.md` to learn the result file schema:
- `result_file_pattern` — where result files live (e.g., `experiments/runs/*/stats.json`)
- `primary_result_field` — the field that holds the primary metric (e.g., `correct_rate`)
- `metric_names` — list of all tracked metrics and their field names in result files
- `per_case_result_file` — per-case result file name (e.g., `patch_gen_reports.json`)

If `project/experiment-config.md` is missing, stop and tell the user:
> "Cannot track numbers without knowing the result schema. Please run `project-init` first,
> or manually create `project/experiment-config.md` with your metric field names."

Read `project/paper-paths.md` to get the LaTeX file locations.

---

## Step 1: Discover All Source Files

### Paper files to scan:

Read paths from `project/paper-paths.md`:
```
Glob: {{sections_dir}}/*.tex
Glob: {{paper_dir}}/tables/*.tex
Glob: {{main_tex}}
```

Key files to prioritize:
- `paper/tables/results_main.tex` — main results table
- `paper/tables/results_comparison.tex` — multi-model comparison (if it exists)
- `paper/sections/results*.tex` — results section prose

### Result files to scan:

Use the `result_file_pattern` from `project/experiment-config.md`:
```
Glob: experiments/runs/*/stats.json     (or whatever the pattern is)
Glob: **/results.json                   (generic fallback)
```

If `experiments/runs/` does not exist, also check:
```
Glob: **/stats.json
```

If multiple stats.json files exist, use the most recently modified one as the "current"
source of truth, but load all of them to check for historical values.

Report which result file is being used as the source of truth, with its modification date.

---

## Step 2: Extract Numeric Claims from .tex Files

### 2a: Table Cell Values

Scan all `.tex` files for LaTeX tabular content. Look for lines containing `&` (column
separators) that also contain numbers.

```
Grep: pattern=(?:\d+\.?\d*\%?|\d+/\d+), path=paper/, glob=**/*.tex, output_mode=content
```

For each match, record:
- `tex_file`: the file path
- `line_number`: the line
- `context`: the surrounding 2 lines (for readability)
- `raw_value`: the extracted number string (e.g., `"0.923"`, `"13/15"`, `"60.0\%"`)

Normalize the value to a float for comparison:
- `"0.923"` → 0.923
- `"13/15"` → 0.867 (also keep the raw fraction separately)
- `"60.0\%"` → 0.600
- `"60.0"` (in a % context) → 0.600

### 2b: Inline Prose Claims

Scan the results section and main text for inline numeric claims:

```
Grep: pattern=\d+\.?\d*\\%, path=paper/sections/, glob=**/*.tex, output_mode=content
```

Also catch common patterns from typical results sections:
```
Grep: pattern=(?:achieves|obtains|produces|reaches|shows)\s+\d, path=paper/, glob=**/*.tex, output_mode=content
Grep: pattern=\d+\s+of\s+\d+\s+(?:cases|samples|instances|examples), path=paper/, glob=**/*.tex, output_mode=content
Grep: pattern=\d+/\d+\s+(?:cases|samples|instances|examples), path=paper/, glob=**/*.tex, output_mode=content
Grep: pattern=average\s+\w+\s+(?:is|was|of)\s+\d+\.?\d*, path=paper/, glob=**/*.tex, output_mode=content
```

Use the metric names from `project/experiment-config.md` to refine which numbers matter most.
For each metric in the `metric_names` list, run an additional targeted grep:
```
# For each metric display name in project/experiment-config.md:
Grep: pattern=[metric display name], path=paper/, glob=**/*.tex, output_mode=content
```

Common patterns to normalize when you find them:
- `"X of N cases (Y%)"` → fraction X/N and percentage Y%
- `"Y%"` → rate 0.Y
- `"average X is N.N"` → float N.N
- `"N× improvement"` → ratio N

### 2c: Table Row/Column Mapping

For the main results table (`paper/tables/results_main.tex`), map each cell to a
result file field based on the column header.

Read the metric field mappings from `project/experiment-config.md`. The config lists
each metric name (as it appears in the table column header) and its corresponding field
name in the result files:

```
metric_names:
  - display: "[metric display name as in table header]"
    field:   "[field name in the result file JSON]"
  - display: "[another metric]"
    field:   "[another field]"
```

Build the column→field mapping from this list. For any column header in the table that
does not match a metric in the config, flag it as `"source_field": "UNMAPPED"` and ask
the user to clarify which result file field it corresponds to.

For the multi-model/multi-condition comparison table (when it exists):
- Each row corresponds to a model or condition key in the result file
- Match row labels between the table and the result file keys
- If run directories are named by condition (see experiment-runner-monitor RUN_ID format),
  use the condition label to match rows

---

## Step 3: Load Result Files and Extract Source Values

Read the latest result file (use `result_file_pattern` from `project/experiment-config.md`
to find it; sort by modification date and use the most recent):

```python
import json
from pathlib import Path

# Load the primary result file (stats.json or equivalent)
result_file = most_recent_matching(result_file_pattern)
with open(result_file) as f:
    results = json.load(f)

# Structure depends on the project — could be flat dict, list, or nested by model key.
# Read the schema description in project/experiment-config.md to understand it.
```

For each metric in `project/experiment-config.md`'s `metric_names` list, extract the
corresponding field value from the result file. Handle common cases:
- Direct float/int field → use directly
- "n/a" string → treat as None (report as unmappable)
- Count field requiring division by total → compute rate

If `per_case_result_file` is specified in config (e.g., per-case JSON), also load it and
compute any averages that are tracked in the paper (e.g., timing, iteration counts).

---

## Step 4: Build the Numbers Tracker

Create `paper/numbers_tracker.json` as a JSON array. Each entry represents one tracked
number in the paper. Use metric names and field names from `project/experiment-config.md`:

```json
[
  {
    "id": "[metric id — short key from experiment-config.md metric_names]",
    "tex_file": "paper/sections/results_draft.tex",
    "line_number": 14,
    "context": "[quote the surrounding sentence from the .tex file]",
    "paper_value_raw": "[exact string from .tex, e.g. '13/15' or '86.7\\%']",
    "paper_value_float": 0.867,
    "source_file": "experiments/runs/YYYYMMDD_HHMMSS/[result file from experiment-config.md]",
    "source_field": "[field name from experiment-config.md metric_names[i].field]",
    "source_value_float": 0.867,
    "is_stale": false,
    "last_verified": "YYYY-MM-DD"
  }
]
```

For each tracked number:
- `id`: a short descriptive key derived from the metric name in `project/experiment-config.md`
  (use the `display` name, lowercased and underscored — e.g., if display is "Correct Rate", use `correct_rate`)
- `paper_value_raw`: the string exactly as it appears in the .tex file
- `paper_value_float`: normalized float (convert percentages, fractions)
- `source_value_float`: the value from the result file
- `is_stale`: `true` if `|paper_value_float - source_value_float| > tolerance`

---

## Step 5: Compare Paper Values vs. Source Values

For each tracked number, compute the difference:

```python
diff = abs(paper_value - source_value)
```

**Staleness thresholds:**
- For rates/percentages: stale if `diff > 0.001` (0.1 percentage point)
- For integer counts: stale if `diff > 0` (any difference)
- For averages (timing, iters): stale if `diff > 0.05` (rounding tolerance)

Mark `is_stale: true` for any that exceed their threshold.

**Special cases:**
- If `source_value_float` is `None` (e.g., `"n/a"` in stats.json due to zero QA passes),
  mark as stale with a note: "Source value unavailable — QA pass count may be 0"
- If the number in the paper cannot be mapped to any field in the result files, mark as
  `"source_field": "UNMAPPED"` and flag for manual review

---

## Step 6: Generate the Stale Numbers Report

Write `paper/stale_numbers_YYYYMMDD.md`:

```markdown
# Stale Numbers Report — YYYY-MM-DD

Source: experiments/runs/LATEST/stats.json (modified: YYYY-MM-DD HH:MM)

## Summary

- Total tracked numbers: N
- Up to date: M
- Stale: K

## Stale Numbers

### 1. `[metric_id]` — [Metric Display Name]

- File: `paper/sections/results_draft.tex`, line [N]
- Context: `"[surrounding sentence from the .tex file]"`
- Paper value: [paper_value_float] ([paper_value_raw])
- Current source value: [source_value_float]  ← [from source_field]
- Difference: [diff] ([diff in display units])
- Suggested fix: Change "[old value]" → "[new value]"

[Repeat for each stale number]

## Up-to-Date Numbers

[List each up-to-date metric id: value ✓]

## Unmapped Numbers

<any numbers found in the paper with no matching source field>
```

If no stale numbers are found:
```markdown
## Result: All N tracked numbers are up to date as of YYYY-MM-DD.
Source: experiments/runs/LATEST/stats.json
```

---

## Step 7: Offer to Update Stale Numbers

After generating the stale numbers report, ask the user:

> "Found K stale numbers. Would you like me to automatically update them in the .tex files?
> I will:
> - Change each stale value to match the source
> - Leave a `% updated YYYY-MM-DD from stats.json` comment on the changed line
>
> Please review the stale_numbers report first, then type YES to proceed."

If the user says yes:

For each stale number, use `Edit` to apply the fix in the `.tex` file.
Be precise — only change the specific value token, not the surrounding context.

After updating, remind the user:
> "Numbers updated. Remember to run latex-compile-and-check to verify the paper still
> compiles, and then push to Overleaf:
> ```bash
> cd paper && git add -A && git commit -m 'Update numbers from latest run' && git push
> ```"

---

## Step 8: Update the Tracker

After any updates (or after verifying numbers are current), update `paper/numbers_tracker.json`:
- Set `is_stale: false` for all verified numbers
- Update `last_verified` to today's date
- Update `source_value_float` to match the current source

---

## Reference Files

- `project/experiment-config.md` — metric field names, result file pattern, per-case
  result file name — the primary source of truth for mapping paper numbers to source fields
