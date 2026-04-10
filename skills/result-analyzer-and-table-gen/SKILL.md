---
name: result-analyzer-and-table-gen
description: |
  Use this skill whenever the user wants to analyze benchmark results, generate LaTeX tables
  for a paper, create figures from experiment outputs, or write a results section draft.
  Reads metric definitions from project/experiment-config.md.
  Trigger on phrases like:
  "analyze results", "generate results table", "create latex table from results", "plot figures",
  "write results section", "what did the benchmark show", "compare models on benchmark",
  "generate paper tables from [run]", "turn these results into a table", "visualize benchmark output",
  "make a bar chart of results", "format results for the paper", "summarize experiment results".
version: 2.0.0
tools: Read, Glob, Grep, Bash, Write, Edit
---

# Result Analyzer and Table Generator

Takes benchmark result files and produces publication-quality LaTeX tables, matplotlib figures,
and a results section draft. Reads metric definitions and result file schema from
`project/experiment-config.md`.

## Output Locations

| Output | Path |
|---|---|
| Main results table | `paper/tables/results_main.tex` |
| Comparison table (multi-condition) | `paper/tables/results_comparison.tex` |
| Figures | `paper/figures/results_*.pdf` |
| Results section draft | `paper/sections/results_draft.tex` |
| Statistical analysis notes | `experiments/results_analysis_YYYYMMDD.md` |

Create these directories if they don't exist:
```bash
mkdir -p paper/tables paper/figures paper/sections
```

---

## Step 0 — Check Prerequisites

Read:
```
Read: project/experiment-config.md
Read: project/research-focus.md
Read: project/venue-config.md   (for LaTeX format rules)
```

Extract from `project/experiment-config.md`:
- Primary metric name and definition
- Secondary metric names and definitions
- Result file pattern (where stats/results files are located)
- Dataset name(s)

If `project/experiment-config.md` does not exist, ask the user:
> "What is your primary metric name? What fields are in your result files?
> (Or run `project-init` to set these up.)"

Extract `system_name` from `project/research-focus.md`.

---

## Step 1 — Discover Result Files

First, check the `result_file_pattern` from `project/experiment-config.md`.
Then search:

```python
# Use the result_file_pattern from project/experiment-config.md
# Generic fallback patterns:
Glob("experiments/runs/*/stats.json")
Glob("experiments/runs/*/results.json")
Glob("experiments/runs/*/responses.json")
```

If no `experiments/` directory exists, ask:
> "Where are your result files? (provide a directory path or specific file paths)"

List the found files and their dates. If multiple runs exist for different conditions,
map them to their condition labels from `run_metadata.json` if available.

---

## Step 2 — Load and Understand the Schema

Read the result files. Since schemas vary by project, apply this approach:

1. **Load the primary result file** (usually `stats.json` or equivalent)
2. **Print the top-level keys** to understand the structure
3. **Map keys to metrics** from `project/experiment-config.md`

```python
# Pseudocode — adapt to actual file format
import json

stats = json.load(open("experiments/runs/RUN_ID/stats.json"))
# Print structure:
for key, val in stats.items():
    print(f"{key}: {type(val).__name__} = {repr(val)[:80]}")
```

If the stats file has a nested structure (e.g., keyed by model name), flatten it.
Use the `primary_result_field` from `project/experiment-config.md` to find the headline number.

---

## Step 3 — Compute Statistics

For each condition/run in the results, compute:

**From `project/experiment-config.md` metrics section:**
- Primary metric value (find this field in the result file)
- Each secondary metric value

**General metrics to compute if not already in result files:**
- Total cases attempted
- Success rate on primary metric (as a fraction with denominator)
- Comparison across conditions if multiple runs exist

**If multiple runs exist for the same condition** (replications):
- Compute mean ± std
- Flag if std > 5% of mean

Write `experiments/results_analysis_YYYYMMDD.md` with:
- Raw numbers for every condition
- Condition-to-condition comparisons
- Any surprising results (outliers, conditions where primary metric is 0% or 100%)
- Brief interpretation

---

## Step 4 — Generate LaTeX Tables

Key formatting rules (apply regardless of venue):
- Use `booktabs` (`\toprule`, `\midrule`, `\bottomrule` — never `\hline`)
- Bold the best result in each column with `\textbf{}`
- Use `\small` for table font to save space
- Include `\centering` inside the table float
- Always add `\label{tab:results-main}` and `\caption{}`

**Main results table** (one row per condition, columns = metrics from `project/experiment-config.md`):

```latex
\begin{table}[t]
\centering
\small
\caption{[SYSTEM_NAME] results on [dataset]. [Brief description of what the columns mean.]}
\label{tab:results-main}
\begin{tabular}{l[c for each metric]}
\toprule
\textbf{Condition} & \textbf{[Metric 1]} & \textbf{[Metric 2]} & ... \\
\midrule
[Condition 1] & [val] & [val] & ... \\
[Condition 2] & [val] & [val] & ... \\
\bottomrule
\end{tabular}
\end{table}
```

Substitute:
- Column headers from metric names in `project/experiment-config.md`
- Caption from dataset name and system name
- Row labels from condition labels in run metadata

For multi-model comparison tables, add a `Model` column as the first column.

Save to `paper/tables/results_main.tex`.

---

## Step 5 — Generate Figures

Write and execute a Python script to generate figures. The script should:
1. Load the result data parsed in Step 3
2. Apply publication-quality style settings
3. Save as PDF

```python
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np

# Style settings for publication figures
plt.rcParams.update({
    'font.size': 9,
    'font.family': 'serif',
    'axes.labelsize': 9,
    'xtick.labelsize': 8,
    'ytick.labelsize': 8,
    'figure.dpi': 300,
    'pdf.fonttype': 42,  # embed fonts
    'ps.fonttype': 42,
})

# Wong color-blind-safe palette
COLORS = ['#0072B2', '#E69F00', '#009E73', '#CC79A7', '#D55E00', '#56B4E9', '#F0E442']

# TODO: populate data from result files
conditions = [...]  # condition labels
primary_metric = [...]  # primary metric values

fig, ax = plt.subplots(figsize=(3.5, 2.5))  # single-column width for ACL/IEEE
ax.bar(range(len(conditions)), primary_metric, color=COLORS[:len(conditions)])
ax.set_xticks(range(len(conditions)))
ax.set_xticklabels(conditions, rotation=15, ha='right')
ax.set_ylabel('[Primary Metric Name]')
ax.set_title('[SYSTEM_NAME] Results')
plt.tight_layout()
plt.savefig('paper/figures/results_bar.pdf', bbox_inches='tight')
print("Saved: paper/figures/results_bar.pdf")
```

**Common figure types:**
1. **Bar chart** — condition comparison on primary metric
2. **Grouped bar chart** — multiple metrics side by side per condition
3. **Breakdown pie/stacked bar** — distribution of outcomes (e.g., success/failure categories)

Save figures to `paper/figures/results_{type}.pdf`.

---

## Step 6 — Write the Results Section Draft

Structure:

```latex
% Results section draft — [SYSTEM_NAME] paper
% Generated by result-analyzer-and-table-gen skill

\section{Results}
\label{sec:results}

\subsection{Main Results}
% Lead with the headline number from project/contributions.md Headline Result
% Reference: \autoref{tab:results-main}
% Walk through conditions: what the numbers show, not just "we are best"

\subsection{Ablation Study}
% TODO: add once ablation runs are complete

\subsection{Error Analysis}
% Distribution of failure modes across conditions
% TODO: expand with error-cluster-and-fix-proposer output
```

For each subsection:
- Lead with the most important number
- Reference the relevant table/figure: `Table~\ref{tab:results-main}`, `Figure~\ref{fig:results-bar}`
- Interpret in terms of the paper's claims (what does this number mean for the contribution?)
- Use present tense ("Table~\ref{tab:results-main} shows...", "The system achieves...")

Ensure all `\label{}` names used in the draft match exactly what is in the table/figure files.

Save to `paper/sections/results_draft.tex`.

---

## Step 7 — Final Reminders

After generating all files, print:

```
Files generated:
  paper/tables/results_main.tex
  paper/figures/results_bar.pdf
  paper/sections/results_draft.tex
  experiments/results_analysis_YYYYMMDD.md

Key results:
  Primary metric ([name]): [value] ([condition])
  [Secondary metric]: [value]

Anything to double-check:
  [flag any results that look unusual — 0%, 100%, N/A]

SYNC REMINDER: If paper/ is a git submodule linked to Overleaf:
  cd paper/
  git add .
  git commit -m "Add results tables and figures"
  git push
```

Flag any `\ref{}` in the draft that point to sections not yet written.

---

## Error Handling

| Situation | Action |
|---|---|
| Result file is empty or zero bytes | Report: "File is empty — run may not have completed." Check log. |
| primary_result_field not found in result file | Print available fields; ask user which to use as primary |
| Multiple result files with same condition label | Warn user; use most recent; note potential duplication |
| Python not available for figure generation | Write the figure script but don't execute; tell user to run it manually |
| LaTeX table exceeds column width | Use `\resizebox{\columnwidth}{!}{...}` or split into two tables |
