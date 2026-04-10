---
name: experiment-designer
description: |
  Design a concrete experiment protocol for any research hypothesis. Reads dataset paths,
  metric definitions, and run command template from project/experiment-config.md.
  Trigger when the user says things like:
  "design experiments", "plan experiments for [hypothesis]", "what should I test",
  "help me design an experiment", "experimental setup", "which baselines should I include",
  "design ablation study", "what models to compare", "how do I test this idea",
  "I want to study [variable] effect", "what conditions should I run",
  "structure my research around [hypothesis]", "help me think through the experimental design",
  "I have a hypothesis, what do I run", "what datasets and models should I use",
  "give me a research plan", "what's the right experimental protocol".
version: 2.0.0
tools: Read, Glob, Grep, Bash, Write, Edit
---

# Skill: Experiment Designer

Design a complete, concrete experiment protocol for a research hypothesis. Given a hypothesis
(from the user or from an existing hypothesis file), this skill decomposes it into conditions,
baselines, metrics, compute estimates, and an ablation plan, then writes a structured plan file.

Reads all project-specific configuration from `project/experiment-config.md`.

---

## Step 0 — Check Prerequisites

Read project config:

```
Read: project/experiment-config.md
Read: project/research-focus.md
Read: project/system-design.md    (if exists — for ablation design)
```

**If `project/experiment-config.md` does not exist**, stop and tell the user:

> "I need `project/experiment-config.md` to design experiments.
> Please run the `project-init` skill first, or create this file with at minimum:
> ```markdown
> ## Metrics
> ### Primary Metric
> name: [metric_name]
> definition: [what it measures]
>
> ## Datasets
> ### [dataset name]
> path: [path or TODO]
>
> ## Run Command Template
> ```bash
> [your run command]
> ```
> ```"

Extract from config:
- `system_name` → `{{SYSTEM_NAME}}`
- Primary and secondary metric names and definitions
- Dataset names, paths, and sizes
- Run command template
- Key baselines
- Timing estimate per run

---

## Step 1 — Discover or Elicit the Hypothesis

**First, check for an existing hypothesis file:**

```python
Glob("experiments/hypothesis*.md")  # sorted by modification time; show the 5 most recent
```

If hypothesis files exist, list them and ask:
> "I found these hypothesis files. Which would you like to design experiments for?
> Or describe a new hypothesis."

If no file exists, ask:
> "Please state your research hypothesis in 1–2 sentences.
>
> Hypothesis template if you need help:
> 'We hypothesize that [intervention / independent variable] will [increase / decrease / have
> no effect on] [metric from project/experiment-config.md] for [model / dataset subset],
> compared to [baseline condition].'"

Wait for confirmation before proceeding.

---

## Step 2 — Decompose the Hypothesis

Break the confirmed hypothesis into its experimental components:

```
## Experimental Decomposition

**Independent variable(s):**
  - [What you are changing between conditions]

**Dependent variable(s):**
  - Primary: [from project/experiment-config.md primary metric]
  - Secondary: [from project/experiment-config.md secondary metrics]
  - Exploratory: [any other measurable outputs from the run]

**Controls (held constant across all conditions):**
  - Dataset: [which dataset from project/experiment-config.md]
  - Model: [if not the IV]
  - [Other settings from run command template that are held fixed]
```

Present to user and ask for confirmation.

---

## Step 3 — Scan Available Assets

Report what is available from `project/experiment-config.md`:

```
Available datasets:
  [from project/experiment-config.md Datasets section]

Available LLM providers / models:
  [ask user, or list options from the run command template]

Existing run results:
```

```python
Glob("experiments/runs/*/stats.json")  # count the results to see how many runs exist
```

If existing runs are found, summarize to avoid redundant conditions.

---

## Step 4 — Propose Experimental Conditions

Based on the hypothesis, propose 3–5 concrete conditions. Each condition maps to one run.

```
## Proposed Conditions

| Condition | Description | Key Change from Baseline | Dataset | Model |
|---|---|---|---|---|
| C1 (Baseline) | Default settings | none — establishes baseline | [dataset] | [model] |
| C2 (Treatment) | [hypothesis treatment] | [specific change] | [dataset] | [model] |
| C3 | [variant] | [specific change] | [dataset] | [model] |
```

**Rules for condition design:**
- Always include one "baseline" condition matching the paper's default settings
- Change only one independent variable at a time between conditions
- For model comparisons, hold all other settings constant
- For prompt/config ablations, hold model and dataset constant
- Label conditions C1, C2, ... for cross-referencing in the plan and paper

---

## Step 5 — Suggest Baselines from Literature

Ask the user:
> "Do you have specific baselines from prior work you want to include? Or should I suggest
> baselines based on the research focus?"

If suggestions are requested, propose:
- Random baseline (null expectation — what does random or trivial behavior give?)
- Best prior published result on the same benchmark (for comparison)
- Ablation of the system's key component (to validate contribution)

These baselines come from `project/related-work-clusters.md` if it exists.

---

## Step 6 — Define Success Metrics

Present the metrics plan from `project/experiment-config.md` and ask for modifications:

```
## Metrics Plan

### Primary (report in main table)
- [primary_metric_name]: [definition from config]
  Denominator: [from config]

### Secondary (report in analysis)
- [secondary metric 1]: [definition]
- [secondary metric 2]: [definition]

### Exploratory (report in appendix or supplemental)
- [any timing, iteration count, or quality signals available from the run]

### Statistical Considerations
- With [N] cases: minimum detectable effect ~[X]pp at α=0.05, power=0.80
  (Use Wilson or Clopper-Pearson confidence intervals for proportions)
  (Use Fisher's exact test for pairwise condition comparisons)
```

Compute the minimum detectable effect based on dataset size from config.

---

## Step 7 — Estimate Compute

Calculate and present:

```
## Compute Estimate

Parameters:
  Cases per condition:    [N from dataset in config]
  Timing estimate:        [from project/experiment-config.md Timing Estimate field]
  Conditions:             [K]

Total (all conditions sequential):
  [K × timing_per_condition]

API cost estimate:
  [If LLM API is used, estimate tokens per case × price per token × N × K]
  [Otherwise note compute resource needed]

Recommendation: Run C1 (baseline) on the smallest available dataset first
to validate infrastructure before committing to full runs.
```

---

## Step 8 — Propose Ablation Conditions

Based on `project/system-design.md` (if it exists), propose ablations for each key component:

```
## Ablation Study Design

For each major component in project/system-design.md, propose an ablation:

| Component | Default | Ablation | Expected effect if component matters |
|---|---|---|---|
| [component 1] | [default setting] | [removed/degraded] | [expected metric change] |
| [component 2] | [default setting] | [removed/degraded] | [expected metric change] |
```

If `project/system-design.md` does not exist, ask the user to list the key components
of their system that they want to validate.

---

## Step 9 — Write the Plan File

After user confirms the design, write to `experiments/plan_YYYYMMDD.md`:

```bash
date +%Y%m%d
```

**Output file path:** `experiments/plan_YYYYMMDD.md`

**Template:**

```markdown
# Experiment Plan — YYYYMMDD

## Research Hypothesis
[One-paragraph statement]

## Experimental Decomposition
**Independent Variable(s):** [list]
**Dependent Variables:** [primary metric] (primary), [secondary metrics] (secondary)
**Controls:** [held-constant settings]

## Conditions

### C1 — Baseline
**Description:** Default settings
**Run command:**
```bash
[from project/experiment-config.md run command template, with substitutions]
```
**Output dir:** `experiments/runs/YYYYMMDD_C1_baseline/`

### C2 — [Treatment name]
[repeat pattern]

## Baselines
[List baselines and sources]

## Metrics
- Primary: [from config]
- Secondary: [from config]

## Statistical Analysis Plan
- Confidence intervals: [method]
- Comparison test: [method]
- Significance threshold: α = 0.05

## Compute Estimate
[From Step 7]

## Ablation Conditions
[From Step 8]

## Run Order
1. C1 (baseline) — validate infrastructure
2. C2 (primary treatment) — test hypothesis
3. C3–CN (secondary conditions) — once C1 and C2 are healthy
4. Ablations — after primary results reviewed

## Notes
[Any design decisions, known limitations, etc.]
```

---

## Error Handling

If the run command template in `project/experiment-config.md` has "TODO" placeholders,
note them in the plan but do not block on them — the plan can still be written.

If the user's hypothesis references a metric name not in `project/experiment-config.md`,
ask: "This metric isn't in `project/experiment-config.md` — would you like to add it now?"

If no timing estimate is available in the config, ask the user for a rough estimate
(e.g., "How long does one run of 10 cases take?") before computing the compute estimate.
