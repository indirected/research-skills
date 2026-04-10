---
name: paper-reproduce-prior
description: |
  Given a paper to implement, extract all reported tables and quantitative results, and scaffold
  the reproduction code needed for each. This is how the lab verifies it truly understands
  a paper before building on it.
  Trigger when the user says any of the following:
  - "reproduce this paper"
  - "implement this paper"
  - "extract tables from paper"
  - "reproduce results from [paper]"
  - "scaffold reproduction code"
  - "what tables does this paper have"
  - "create reproduction checklist"
  - "I need to implement [paper]"
  - "help me reproduce [paper]"
  - "read and reproduce [paper]"
  - "build reproduction pipeline for [paper]"
  - "what results does [paper] report"
  - "what claims does [paper] make"
version: 1.0.0
tools: Read, Glob, Grep, Bash, WebFetch, WebSearch, Write
---

# Skill: paper-reproduce-prior

You are helping reproduce the results of a prior paper that the lab is implementing.
The goal is to extract every table and quantitative claim from the paper, understand what
code is needed to reproduce each one, and scaffold that code so the researcher can fill it in.

This is the lab's method for verifying deep understanding before building on a paper.
A paper is truly understood when you can reproduce all its tables.

---

## Step 0 — Get the Paper

Ask the user:

> "Which paper would you like to reproduce? Please provide one of:
> 1. An arXiv URL (e.g., `https://arxiv.org/abs/2310.06770`)
> 2. A local PDF path (e.g., `/path/to/paper.pdf`)
> 3. A paper title and authors (I will search for it)
>
> Also: what short slug should I use for the output directory?
> (e.g., `swebench`, `chatrepair`, `vulrepair` — lowercase, no spaces)"

Wait for the user's answer before proceeding.

---

## Step 1 — Fetch the Paper

### If arXiv URL provided:
```python
# Fetch the abstract page first to confirm it's the right paper
WebFetch("https://arxiv.org/abs/{{arxiv_id}}")

# Fetch the PDF
WebFetch("https://arxiv.org/pdf/{{arxiv_id}}")
```

### If local PDF path provided:
```python
Read("{{pdf_path}}")
```

### If title/authors provided:
```python
# Search for the paper
WebSearch("{{title}} {{authors}} arxiv paper")
# Then fetch from the URL found
```

Extract:
- Paper title
- Authors
- Venue and year
- Abstract (to understand the paper's main claims)

---

## Step 2 — Extract All Tables

Read through the paper carefully and identify every table. For each table:

1. **Table number** (e.g., "Table 1", "Table 2")
2. **Caption** (exact text)
3. **Row headers** (what the rows represent — e.g., system names, ablation conditions)
4. **Column headers** (what the columns represent — e.g., metric names, dataset names)
5. **All numeric values** (copy exactly as written in the paper)
6. **Table type**: classify as one of:
   - `main_results` — primary performance comparison against baselines
   - `ablation` — removing or varying a component of the system
   - `dataset_stats` — statistics about the dataset(s) used
   - `case_study` — qualitative or selected examples
   - `hyperparameter` — sensitivity to hyperparameters
   - `comparison_prior_work` — comparing to other papers' numbers
   - `other` — anything that doesn't fit above

Output format for each table:

```
TABLE {{N}}: {{caption}}
Type: {{type}}
Rows: {{row headers}}
Columns: {{column headers}}
Values:
  {{row 1}}: {{val1}}, {{val2}}, ...
  {{row 2}}: {{val1}}, {{val2}}, ...
Reproduction complexity: {{1-5}}  (1=trivial, 5=requires new data/training)
What you need to reproduce it: {{2-3 sentences}}
```

---

## Step 3 — Extract Quantitative Claims from Prose

Scan the paper for numeric claims in the text (not in tables). Look for:
- Percentages: "X% accuracy", "improved by Y%"
- Counts: "N out of M cases", "K papers"
- Comparisons: "2× faster", "3pp improvement"
- Absolute values: "achieves 47.3 F1"

For each claim:
1. Quote the sentence exactly
2. Identify the metric and value
3. Note which table or experiment it refers to (if identifiable)
4. Mark as `in_table` (already captured) or `prose_only` (not in any table)

---

## Step 4 — Identify What is Needed to Reproduce

For each table and each `prose_only` claim, determine what is needed:

| Requirement | Description |
|---|---|
| **Dataset** | What data is needed? Is it publicly available? Link if known. |
| **Model/System** | What model or system produces the results? Is code released? |
| **Baseline** | What are the comparison systems? Are they available? |
| **Compute** | GPU? Hours? Roughly how expensive? |
| **Special tools** | Any proprietary tools, APIs, or infrastructure? |

Rate **reproduction difficulty** on a 1–5 scale:
| Score | Meaning |
|---|---|
| 1 | Dataset and code both public; runs in < 1 hour |
| 2 | Dataset public, code partially available or easy to implement |
| 3 | Dataset public, code not released — must implement from paper |
| 4 | Dataset requires access (email authors, data agreement) |
| 5 | Requires proprietary infrastructure, closed dataset, or model weights not released |

---

## Step 5 — HUMAN APPROVAL GATE

**DO NOT write any files yet.** Present the full extraction to the user:

```
Paper: {{title}} ({{authors}}, {{venue}} {{year}})
Slug: {{PAPER_SLUG}}
=============================================================

TABLES FOUND: {{N}}

{{For each table:}}
Table {{N}} [{{type}}] — {{caption}}
  Complexity: {{1-5}} | Dataset needed: {{yes/no/partial}}
  Model/code available: {{yes/no/partial}}
  Key values: {{2-3 representative values from the table}}

PROSE-ONLY CLAIMS: {{N}}
{{list key prose claims}}

REPRODUCTION ASSESSMENT:
- Tables reproducible without new data: {{N}} of {{total}}
- Tables requiring data access: {{N}}
- Tables requiring model training: {{N}}
- Estimated total effort: {{low/medium/high}} (~{{N}} weeks for a PhD student)

RECOMMENDED STARTING POINT:
Table {{N}} — [type: main_results, complexity: {{1-2}}]
Reason: {{why this is the easiest entry point}}

---
Shall I create the reproduction directory and code scaffolding?
(Type 'yes' to proceed, 'no' to exit, or 'only tables N,M' to scaffold specific tables.)
```

**WAIT for user response before proceeding.**

---

## Step 6 — Create Reproduction Directory

```bash
mkdir -p reproduction/{{PAPER_SLUG}}
```

---

## Step 7 — Write Checklist

Write `reproduction/{{PAPER_SLUG}}/checklist.md`:

```markdown
# Reproduction Checklist: {{title}}

**Paper**: {{title}}
**Authors**: {{authors}}
**Venue**: {{venue}} {{year}}
**arXiv/URL**: {{url}}
**Initialized**: {{TODAY}}
**Status**: In Progress

---

## Summary

- Total tables: {{N}}
- Prose-only claims: {{N}}
- Tables started: 0 / {{N}}
- Tables completed: 0 / {{N}}

---

## Table Checklist

{{For each table (ordered by complexity ASC):}}

### Table {{N}}: {{caption}}
- **Type**: {{type}}
- **Complexity**: {{1-5}}
- **Status**: [ ] Not started / [ ] In progress / [ ] Reproduced / [ ] Blocked
- **Script**: `reproduce_table{{N}}.py`
- **Dataset needed**: {{dataset name, link if available}}
- **Model/code**: {{available at URL or "not released — implement from paper"}}
- **Key values to match**:
  {{list 3-5 specific numbers from the table that the script must reproduce}}
- **Notes**: {{any caveats, e.g., "paper uses v1 of dataset, check version"}}

---

## Prose Claims

{{For each prose_only claim:}}
- [ ] "{{exact quote}}" — {{metric}}: {{value}}

---

## Blockers

{{list any tables that cannot be reproduced due to data/code access issues}}

---

## Reproduction Log

| Date | Table | Status | Notes |
|------|-------|--------|-------|
| {{TODAY}} | — | Initialized | — |
```

---

## Step 8 — Scaffold Reproduction Scripts

For each approved table, write `reproduction/{{PAPER_SLUG}}/reproduce_table{{N}}.py`:

```python
"""
Reproduction script for Table {{N}} from:
  {{title}} ({{authors}}, {{venue}} {{year}})

Table caption: {{caption}}
Table type: {{type}}

Expected output matches:
{{list all numeric values from the table, formatted as expected}}

Reproduction complexity: {{1-5}}
Dataset: {{dataset name and access instructions}}
"""

import json
import csv
# Add other imports as needed

# =============================================================================
# STEP 1: Load Data
# =============================================================================
# TODO: Load the dataset
# Dataset: {{dataset name}}
# Access: {{how to get it}}
# Expected location: data/{{PAPER_SLUG}}/{{dataset_name}}/

data = None  # TODO: replace with actual data loading


# =============================================================================
# STEP 2: Run Model / System
# =============================================================================
# TODO: Run {{SYSTEM_NAME or baseline}} on the loaded data
# Reference: Section {{N}} of the paper describes this process

results = None  # TODO: replace with actual model output


# =============================================================================
# STEP 3: Compute Metrics
# =============================================================================
# TODO: Compute the metrics reported in Table {{N}}
# Primary metric: {{metric name from table column headers}}

def compute_{{primary_metric}}(results, data):
    """
    {{definition of metric from paper}}
    Denominator: {{what the denominator is}}
    """
    # TODO: implement
    raise NotImplementedError


# =============================================================================
# STEP 4: Format as LaTeX Table
# =============================================================================
def format_latex_table(metrics):
    """
    Format results as a LaTeX table matching Table {{N}} in the paper.
    Expected structure:
    {{row headers}} x {{column headers}}
    """
    rows = []
    # TODO: fill in rows from metrics dict
    
    latex = "\\begin{tabular}{" + "l" * (1 + len(metrics)) + "}\n"
    latex += "\\toprule\n"
    latex += " & ".join(["Method"] + list(metrics.keys())) + " \\\\\n"
    latex += "\\midrule\n"
    for row in rows:
        latex += " & ".join(str(v) for v in row) + " \\\\\n"
    latex += "\\bottomrule\n"
    latex += "\\end{tabular}"
    return latex


# =============================================================================
# STEP 5: Compare Against Paper Values
# =============================================================================
PAPER_VALUES = {
    # Table {{N}} values from the paper
    # {{row_name}}: {{metric_name}}: {{value}}
    {{paste all numeric values from the table here}}
}

def compare_to_paper(computed, paper_values, tolerance=0.005):
    """Check if computed values match paper values within tolerance."""
    for key, expected in paper_values.items():
        actual = computed.get(key)
        if actual is None:
            print(f"MISSING: {key}")
        elif abs(actual - expected) > tolerance:
            print(f"MISMATCH: {key} — expected {expected}, got {actual:.4f}")
        else:
            print(f"OK: {key} = {actual:.4f}")


# =============================================================================
# MAIN
# =============================================================================
if __name__ == "__main__":
    # TODO: uncomment and complete each step
    # data = load_data()
    # results = run_model(data)
    # metrics = compute_metrics(results, data)
    # compare_to_paper(metrics, PAPER_VALUES)
    # print(format_latex_table(metrics))
    print("Reproduction script for Table {{N}} — fill in TODOs to run.")
```

---

## Step 9 — Write `run_all.sh`

Write `reproduction/{{PAPER_SLUG}}/run_all.sh`:

```bash
#!/bin/bash
# Run all reproduction scripts for: {{title}}
# Usage: bash run_all.sh
# Each script prints PASS/FAIL for its table.

set -e
PAPER_SLUG="{{PAPER_SLUG}}"
RESULTS_DIR="reproduction/${PAPER_SLUG}/results"
mkdir -p "$RESULTS_DIR"

echo "=== Reproducing: {{title}} ==="
echo "Date: $(date)"
echo ""

{{for each table:}}
echo "--- Table {{N}}: {{caption[:50]}} ---"
python3 reproduction/${PAPER_SLUG}/reproduce_table{{N}}.py 2>&1 | tee "$RESULTS_DIR/table{{N}}.log"
echo ""

echo "=== Done. Check $RESULTS_DIR/ for logs. ==="
```

```bash
chmod +x reproduction/{{PAPER_SLUG}}/run_all.sh
```

---

## Step 10 — Write README

Write `reproduction/{{PAPER_SLUG}}/README.md`:

```markdown
# Reproduction: {{title}}

**Paper**: {{title}}
**Authors**: {{authors}}
**Venue**: {{venue}} {{year}}
**URL**: {{url}}
**Initiated by**: {{TODAY}}

---

## Paper Summary

{{2-3 sentence summary of the paper's main claims, derived from the abstract}}

## Main Claims

{{list 3-5 specific, falsifiable claims the paper makes — use exact numbers from the paper}}

1. [Claim 1 — e.g., "The system achieves X% on benchmark Y, outperforming baseline Z by N points"]
2. [Claim 2]
...

## Reproduction Status

See `checklist.md` for per-table status.

| Table | Type | Complexity | Status |
|-------|------|------------|--------|
{{one row per table}}

## How to Run

```bash
# Install requirements
pip install -r requirements.txt  # TODO: create this

# Run all reproduction scripts
bash run_all.sh

# Run a single table
python3 reproduce_table1.py
```

## Data Access

{{For each dataset required, list name + how to access}}

## Notes

{{Any gotchas, version issues, or deviations from the paper discovered during reproduction}}
```

---

## Step 11 — Summary to User

```
Reproduction directory created: reproduction/{{PAPER_SLUG}}/
=============================================================

Files written:
  checklist.md            — full table checklist with expected values
  README.md               — paper summary and reproduction status
  run_all.sh              — runs all scripts in sequence
  reproduce_table1.py     — [type: main_results, complexity: N]
  reproduce_table2.py     — [type: ablation, complexity: N]
  ...

Tables to reproduce: {{N}} total
  Easy (complexity 1-2): {{N}} tables — start here
  Medium (complexity 3): {{N}} tables
  Hard (complexity 4-5): {{N}} tables — check data access first

Next steps:
  1. Read checklist.md and confirm the expected values
  2. Get the dataset(s) listed in README.md
  3. Fill in the TODOs in reproduce_table1.py (start with complexity 1-2)
  4. Run: python3 reproduce_table1.py
  5. Update checklist.md as you complete each table

When all tables are reproduced, you truly understand the paper.
Then use the experiment-designer skill to design your own experiments building on it.
```

---

## Error Handling

| Situation | Action |
|---|---|
| PDF cannot be fetched (paywalled) | Ask user to provide the PDF locally; proceed with local file |
| Paper has no tables (theory paper) | Extract equations and proofs as "claims" instead; scaffold verification scripts |
| Very large paper (> 30 pages) | Ask user which sections to focus on; prioritize main results and ablation tables |
| arXiv page 404 | Try alternate URL formats; ask user to confirm arXiv ID |
| User says "only table 2" | Scaffold only that table; still write the full checklist for reference |
