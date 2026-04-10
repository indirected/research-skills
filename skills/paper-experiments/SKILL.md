---
name: paper-experiments
description: |
  Draft the Experiments / Evaluation section of any research paper in LaTeX.
  Reads result tables from paper/tables/ and contributions from project/contributions.md,
  then generates the section prose with setup, baselines, results, ablation, and error analysis.
  Trigger when the user says any of the following:
  - "write experiments section"
  - "write evaluation section"
  - "draft results section"
  - "write the experiments"
  - "help me write about my results"
  - "write the experimental evaluation"
  - "draft the evaluation"
  - "write about the experimental setup"
  - "write the results section"
  - "write experiments and results"
  - "generate experiments section"
version: 1.0.0
tools: Read, Glob, Grep, Bash, Write, Edit
---

# Skill: paper-experiments

You are helping write the **Experiments / Evaluation** section of a research paper.
This section describes what experiments were run, what the results are, and what they mean
relative to the paper's contributions. Every claim must be traceable to a result file or table.

---

## Step 0 — Check Prerequisites

Read the project config files:

```
Read: project/research-focus.md
Read: project/contributions.md
Read: project/experiment-config.md
Read: project/paper-paths.md
Read: project/venue-config.md
```

**If `project/experiment-config.md` does not exist**, stop and tell the user:

> "I need `project/experiment-config.md` to write the experiments section.
> Please run the `project-init` skill first, or create this file manually.
>
> The file must contain at minimum:
> ```markdown
> ## Metrics
> ### Primary Metric
> name: [metric_name]
> definition: [what it measures]
>
> ## Datasets
> ### [dataset name]
> description: [1-sentence]
> ```"

Extract from config:
- `system_name` from `project/research-focus.md` → `{{SYSTEM_NAME}}`
- Primary metric name and definition from `project/experiment-config.md`
- Dataset names and descriptions
- Key baselines
- `review_mode` from `project/venue-config.md`
- Word budget for Experiments section

---

## Step 1 — Check Review Mode

If `review_mode: yes`:
- No author names, lab names, institution names.
- Use "{{SYSTEM_NAME}}" not "our system".

Inform the user of current mode.

---

## Step 2 — Discover Result Artifacts

Find what result tables and analysis files already exist:

```python
# Find result tables (try paths from project/paper-paths.md first)
Glob("{{tables_dir from project/paper-paths.md}}/*.tex")
Glob("paper/tables/*.tex")          # fallback
Glob("paper/latex/tables/*.tex")    # fallback

# Find latest results analysis
Glob("experiments/results_analysis_*.md")

# Find ablation plan and results
Glob("experiments/ablation_plan_*.md")

# Find error cluster report
Glob("experiments/error_clusters_*.md")

# Find raw stats
Glob("experiments/runs/*/stats.json")
```

Read all files found. If no result artifacts exist yet:

> "I don't see any result files yet. I can draft a skeleton experiments section with placeholder
> tables and [TODO: fill in results] markers, or we can wait until results are available.
> Which would you prefer?"

---

## Step 3 — Propose Section Structure

Present the following default structure and ask for approval:

```
4. Experiments
   4.1 Experimental Setup
       - Dataset(s)
       - Metrics
       - Implementation Details
       - Baselines
   4.2 Main Results
       - Primary results table + interpretation
   4.3 Ablation Study    (include only if ablation results exist)
   4.4 Error Analysis    (include only if error cluster report exists)
   4.5 Discussion        (optional: include for longer papers)
```

Ask:
> "I propose this structure for the experiments section. Does this work, or would you like
> to add/remove subsections? For example, should I include a case study, a runtime analysis,
> or a per-category breakdown?"

---

## Step 4 — Draft Experimental Setup (~200–350 words)

### 4.1.1 Dataset(s)

For each dataset in `project/experiment-config.md`:
- Name and source citation
- Size (number of instances, splits)
- What makes it appropriate for evaluating {{SYSTEM_NAME}}
- How cases were selected if a subset was used

Do NOT re-explain the dataset from scratch if it was covered in Background — instead write:
"We evaluate on [Dataset], described in Section~\ref{sec:background}."
Then add the evaluation-specific details (subset, how the split was constructed, etc.).

### 4.1.2 Metrics

For each metric in `project/experiment-config.md`:
- Give the formal definition (fraction, count, ratio — be precise about numerator and denominator)
- Explain why this metric reflects the paper's claims
- Note statistical treatment: confidence intervals, significance tests

Lead with the primary metric. For secondary metrics, one sentence each is sufficient.

### 4.1.3 Implementation Details

Ask the user for any implementation details not in the config:
> "Do you have implementation details to add? (e.g., hardware, model version, hyperparameters,
> number of seeds, runtime)"

Include: model/tool version, hardware used (GPU type + count if relevant), wall-clock runtime,
number of random seeds or runs, and any other reproducibility-relevant details.

### 4.1.4 Baselines

For each baseline in `project/experiment-config.md`:
- Name and citation
- 1 sentence: what the baseline does
- Note any implementation choices (e.g., "we use the authors' released code")

---

## Step 5 — Draft Main Results (~300–500 words)

### Structure

1. **Point to the table**: "Table~\ref{tab:results-main} shows the main results."
2. **Headline result**: State the headline result from `project/contributions.md` explicitly.
3. **Walk through the table**: Describe results row by row or column by column, highlighting
   the most important comparisons. Do NOT just say "{{SYSTEM_NAME}} performs best" — give
   the specific numbers and what they mean.
4. **Interpret**: Connect results back to the contributions. For each contribution bullet in
   `project/contributions.md`, find the result that supports it and reference it.
5. **Negative or surprising results**: If any condition performed unexpectedly, acknowledge it.
   Reviewers notice when authors cherry-pick only positive results.

### Table Reference

Find the main results table (check `paper/tables/results_main.tex` or equivalent via
`project/paper-paths.md`) and read it. Check that all `\label{}` keys referenced in the
prose (`\ref{tab:results-main}` etc.) exist:

```python
Grep(pattern=r"\\label\{", path="{{tables_dir}}/results_main.tex")
```

---

## Step 6 — Draft Ablation Study (~200–350 words, if applicable)

If ablation results exist:

1. **Motivation**: 1 sentence explaining what the ablation is testing ("To understand the
   contribution of each component...").
2. **Table reference**: "Table~\ref{tab:ablation} presents the ablation results."
3. **Walk through**: For each ablated component, state the performance drop and interpret
   what this shows about the component's contribution.
4. **Summary**: 1–2 sentences summarizing which components matter most.

If no ablation results exist yet, insert a placeholder:
```latex
% TODO: Add ablation study once ablation runs complete.
% Use ablation-designer skill to plan ablation conditions.
```

---

## Step 7 — Draft Error Analysis (~150–250 words, if applicable)

If an error cluster report exists in `experiments/error_clusters_*.md`:

1. **What we analyzed**: which cases or failure modes were examined.
2. **Error categories**: describe the top 2–3 error types with frequency and an example.
3. **Implications**: what do the failure modes suggest about future work or system limitations.

If no error analysis exists, optionally suggest:
> "Would you like me to add an error analysis placeholder? Running the `error-cluster-and-fix-proposer`
> skill will populate this section."

---

## Step 8 — Verify Table References

Check that every `\ref{}` in the experiments section points to a label that actually exists:

```python
# Extract all \ref{} calls from the draft
Grep(pattern=r"\\ref\{[^}]*\}", path="{{sections_dir}}/experiments.tex", output_mode="content")

# Check each against the tables and figures directories
Grep(pattern=r"\\label\{", path="paper/tables/", glob="**/*.tex", output_mode="content")
Grep(pattern=r"\\label\{", path="paper/figures/", glob="**/*.tex", output_mode="content")
```

Report any unresolved references to the user.

---

## Step 9 — Apply Anonymization Check

If review mode is active:
```python
Grep(pattern=r"our lab|our prior work|we previously|our previous|our earlier|our group",
     path="{{sections_dir}}/experiments.tex", output_mode="content")
```

Flag all hits and suggest neutral rewrites.

---

## Step 10 — Write Output File

Write to `{{sections_dir}}/experiments.tex`.

The file should begin:
```latex
% Experiments section — {{SYSTEM_NAME}} paper
% Generated by paper-experiments skill

\section{Experiments}
\label{sec:experiments}
```

After writing, check that `\input{sections/experiments}` is in the main .tex:
```python
Grep(pattern=r"\\input\{.*experiments", path="{{main_tex from project/paper-paths.md}}", output_mode="content")
```

If not present, tell the user where to add it (after Methodology, before Related Work or Conclusion).

---

## Step 11 — Page Budget Check

```bash
wc -w {{sections_dir}}/experiments.tex
```

Compare against budget in `project/venue-config.md`. Defaults if not specified:
- ACL 8-page: 1200–1600 words (2.5–3.0 pages with tables)
- NeurIPS 9-page: 1400–1800 words
- USENIX 13-page: 1800–2200 words

Note: Tables and figures consume significant space. Each full-width table ≈ 150–250 words of space.

**If over budget**:
- Move error analysis to appendix.
- Compress ablation to a single short paragraph without its own subsection.
- Remove per-category breakdowns and put them in supplemental.

**If under budget**:
- Add a per-condition breakdown table.
- Add runtime or efficiency analysis.
- Expand the interpretation of surprising results.

---

## Step 12 — Final Checklist

- [ ] `\section{Experiments}` with `\label{sec:experiments}` present.
- [ ] Experimental setup covers: dataset, metrics, implementation, baselines.
- [ ] Every metric mentioned in setup is reported in a table.
- [ ] Headline result from `project/contributions.md` is explicitly stated in prose.
- [ ] All `\ref{tab:*}` and `\ref{fig:*}` labels exist in the tables/figures files.
- [ ] No author/lab names in review mode.
- [ ] Word count is within venue budget.
- [ ] `\input{sections/experiments}` placement checked in main .tex.

---

## Step 13 — Remind User to Sync with Overleaf

```
SYNC REMINDER:
If your paper/ directory is a git submodule linked to Overleaf:

  cd {{paper_root_dir}}
  git add latex/sections/experiments.tex
  git commit -m "Add experiments section"
  git push

After pushing, verify on Overleaf:
- All table \ref{} labels resolve correctly
- Tables render with booktabs formatting
- Page budget is within limits
```
