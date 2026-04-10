---
name: ablation-designer
description: |
  Trigger phrases: "design ablation study", "ablation experiments", "what should I ablate",
  "which components should I test removing", "ablation table design", "test each component",
  "isolate contributions", "reviewer will ask about ablations", "ablation section",
  "component analysis", "how do I justify each part of my system", "what contributes most",
  "which parts of the system are necessary", "ablation plan", "design ablations",
  "validate system components", "contribution analysis", "which baseline comparisons",
  "design experiment to justify design choices", "help me design ablations",
  "I need to show each part helps"
version: 1.0.0
tools: Read, Glob, Grep, Bash, Write, Edit
---

# Skill: ablation-designer

Extract system components from the methodology section, propose principled ablation
conditions (remove, degrade, substitute), rank by reviewer importance, estimate compute
costs, and design a complete ablation table. Adds a methodology stub if one is missing.

---

## Step 0: Load Paper Context

Read the methodology to understand the system being evaluated:

```python
# Read paper-paths config to find the correct main .tex path
Read("project/paper-paths.md")

# Try to find a dedicated methodology section file
Glob("{{sections_dir from project/paper-paths.md}}/*.tex")
Glob("{{sections_dir}}}/methodology*.tex")
Glob("{{sections_dir}}/approach*.tex")
Glob("{{sections_dir}}/method*.tex")

# Fall back to main .tex file (use main_tex from project/paper-paths.md)
Read("{{main_tex from project/paper-paths.md}}")
```

If a separate methodology section file exists, read it:
```python
Read("paper/latex/sections/methodology.tex")   # or whatever the section is called
```

Also read the introduction to understand what is being claimed as a contribution:
```python
Glob("paper/latex/sections/intro*.tex")
Read("paper/latex/sections/introduction.tex")
```

If the LaTeX source cannot be found or is not structured into sections, ask the user:
```
I can't find a separate methodology section. Please describe your system's
components so I can design the ablation study. What are the key parts of
your approach that you would claim as contributions?
```

---

## Step 1: Identify System Components

Extract discrete components from two sources (in priority order):

**Source 1: `project/system-design.md`** (if it exists — from `project-init`)
```python
Read("project/system-design.md")
```
The "Key Components" section lists each component with a 1-sentence description.
Use this as the ground truth component list.

**Source 2: Paper methodology section** (if `project/system-design.md` is absent)
```python
# Look for \subsection{} headings in methodology — each is likely a component
Glob("paper/latex/sections/methodology.tex")
Grep(r"\\subsection\{[^}]+\}", "paper/latex/sections/")
Grep(r"we (propose|use|introduce|employ|incorporate|design)", "paper/latex/sections/", ignore_case=True)
```

Look for these types of components (applicable to most research systems):
- **Algorithmic components**: Processing steps, modules in a pipeline, sub-algorithms
- **In-context learning / example inclusion**: Few-shot examples, demonstrations
- **Verification / evaluation steps**: Each correctness check applied to outputs
- **Retry / iteration mechanisms**: How many times the system tries before giving up
- **Context provision**: What information is included as input
- **Data / knowledge sources**: External databases, retrieved examples, embeddings

Present the derived component list to the user and ask for confirmation before proceeding.

---

## Step 2: Map Components to Paper Claims

For each component, determine its stated contribution in the paper:

```python
# Search for sentences claiming each component contributes
for component in components:
    Grep(component.keywords, "paper/latex/")
```

Rank components by contribution strength:
- **Primary contribution**: Explicitly named in the abstract or intro as a novel contribution
- **Secondary contribution**: Described as an improvement over prior work in related work section
- **Design choice**: Implementation detail not claimed as novel but that could be questioned

**Rule**: Ablations must be prioritized for primary contributions. Reviewers will specifically
ask about ablation of anything claimed as novel. Failure to ablate a primary contribution
is a common rejection reason.

---

## Step 3: Propose Ablation Conditions

For each component, propose 3 ablation types:

### Remove Condition (R)
Remove the component entirely. This is the strongest test of whether the component helps.
- Naming convention: `[COMPONENT]-remove` or `w/o [ComponentName]`
- Example: `w/o [Component1]` — run the system without that component active

### Degrade Condition (D)
Use a weaker version of the component. This tests sensitivity to quality.
- Naming convention: `[COMPONENT]-weak` or `[ComponentName]-simple`
- Example: `[Component1]-random` — use a random/unordered version instead of the designed one

### Substitute Condition (S)
Replace the component with a simple baseline alternative. Tests if the specific design choice matters.
- Naming convention: `[COMPONENT]-baseline` or `[ComponentName]-naive`
- Example: `[Component1]-naive` — replace with the simplest possible implementation of the same idea

### Full Ablation Plan (Template)

Derive condition names from the components identified in Step 1 using this structure:

| Condition ID | Condition Name | Description | Component Tested | Priority |
|---|---|---|---|---|
| A0 | Full System | All components active (baseline) | — | Required |
| A1 | w/o [Component 1] | Remove [component 1 from project/system-design.md] | C1 | High |
| A2 | [Component 1]-naive | Replace with simpler baseline | C1 | High |
| A3 | w/o [Component 2] | Remove [component 2] | C2 | [High/Med] |
| ... | ... | ... | ... | ... |

Populate this table using the confirmed component list from Step 1.
For each component marked as a key contribution in `project/contributions.md`,
the corresponding ablation is High priority.

---

## Step 4: Check Existing Experimental Data

Before finalizing the plan, check if any ablation conditions have already been run:

```python
Glob("experiments/runs/*/stats.json")
```

For each ablation condition, search for matching run directories using the condition names
derived in Step 3:
```python
# For each condition ID/name derived in Step 3, search for matching directories
Glob("experiments/runs/*[condition_keyword]*")
# e.g., Glob("experiments/runs/*no_retry*"), Glob("experiments/runs/*wo_component1*")
```

Mark each ablation condition:
- **Already run**: Data available at `experiments/runs/[PATH]` — fill in numbers now
- **Needs to run**: Estimate compute cost (see Step 5)

---

## Step 5: Estimate Compute Cost

For each ablation condition that has not yet been run:

```python
# Find the full system run to use as compute reference
Read("experiments/runs/[latest_full_run]/stats.json")
```

Extract:
- Total number of cases evaluated
- Average time per case (or total time / N cases)
- GPU/API cost per case if tracked

Compute estimate for each new condition:
```
cost_estimate = num_cases × avg_time_per_case × overhead_factor
overhead_factor = 1.2  # 20% overhead for setup, logging, errors
```

### Subset Recommendations

Some ablations can be run on a subset to save compute:

| When to use subset | Subset size | Rationale |
|---|---|---|
| Ablation is low priority | 10-20% of dataset | Good enough for directional signal |
| Hypothesis: "this doesn't matter" | 20-30% of dataset | If null result, full run is unnecessary |
| Core contribution ablation | 100% of dataset | Reviewers require full-scale evidence |
| Novel method component | 100% of dataset | Must not be perceived as cherry-picked |

In general, if the full dataset has N cases, suggest:
- High-priority ablations (A1, A3, A5, A6): full N cases
- Medium-priority (A2, A4, A7): N/3 cases minimum
- Low-priority (A8, A9): N/5 cases if suggestive signal expected

---

## Step 6: Design Ablation Table Structure

Design the LaTeX table that will appear in the paper:

```
Ablation table layout options:
  Option 1: Rows = conditions, Columns = metrics (most common)
  Option 2: Rows = components, Columns = [with/without, delta] (compact)
  Option 3: Separate tables per research question

For systems with 4+ components and 3+ metrics: use Option 1.
For systems with 2-3 components: Option 2 is more compact and readable.
```

### Ablation Table Template (LaTeX)

Generate the LaTeX table with column headers matching the actual metric names from
`project/experiment-config.md`'s `metric_names` list, and row labels derived from the
component names identified in Step 1. Use this structure:

```latex
\begin{table}[t]
\centering
\small
\caption{Ablation study. We evaluate each system component by removing or degrading it
  while keeping all other components active. All conditions use the same [N] test cases.
  Bold indicates the best result per column.}
\label{tab:ablation}
\begin{tabular}{lcc...}  % one c per metric column
\toprule
\textbf{Condition} & \textbf{[Metric 1]} & \textbf{[Metric 2]} & ... \\
\midrule
\multicolumn{N}{l}{\textit{Full system}} \\
Full System (A0)          & \textbf{XX.X} & ... \\
\midrule
\multicolumn{N}{l}{\textit{[Component 1] ablations}} \\
w/o [Component 1] (A1)    & XX.X & ... \\
[Component 1]-naive (A2)  & XX.X & ... \\
\midrule
\multicolumn{N}{l}{\textit{[Component 2] ablations}} \\
w/o [Component 2] (A3)    & XX.X & ... \\
...
\bottomrule
\end{tabular}
\end{table}
```

Fill in `[Component N]` and `[Metric N]` placeholders from the component list (Step 1)
and metric list (`project/experiment-config.md`) respectively.

---

## Step 7: Add Ablation Subsection to Methodology

Check if an ablation subsection already exists:
```python
Grep(r"\\subsection\{Ablation|\\section\{Ablation", "paper/latex/")
```

If it does NOT exist, add a stub to the methodology section:

Locate the end of the methodology section in the .tex file. Add:

```latex

%--- Ablation subsection stub (populate with experiment-designer + results) ---%
\subsection{Ablation Study}

To validate the contribution of each system component, we conduct a systematic ablation
study. We evaluate the following conditions (derived from project/system-design.md):

\begin{itemize}
  \item \textbf{Full System}: All components active (A0). This is our primary system.
  \item \textbf{w/o [Component 1] (A1)}: [Description of what is removed — from Step 1].
  \item \textbf{w/o [Component 2] (A3)}: [Description of what is removed — from Step 1].
  \item ... (add one \item per component identified in Step 1)
\end{itemize}

Results are shown in Table~\ref{tab:ablation} (Section~\ref{sec:evaluation}).
%--- End stub ---%
```

Populate `[Component N]` and their descriptions from the confirmed component list in Step 1.

Use Edit to insert this block. Confirm with user before editing if they want to review first.

---

## Step 8: Generate Ablation Plan File

Write to `experiments/ablation_plan_[YYYYMMDD].md`:

```markdown
# Ablation Plan: [PAPER TITLE]

Generated: [DATE]
Paper: [VENUE] [YEAR] submission
System: [System name, e.g., AutoPatch]

---

## System Components Identified

[Table of all components with descriptions and whether they are claimed as contributions]

---

## Ablation Conditions

[Full table of all conditions: ID, Name, Description, Component, Priority, Status]

---

## Execution Plan

### Already Available (use immediately)

| Condition | Data location | Primary metric value |
|-----------|--------------|---------------------|
| A0 (Full System) | experiments/runs/[path]/ | [value] |
| [others if already run] | | |

### Needs to Run (prioritized)

| Priority | Condition | Dataset subset | Estimated compute | Target completion |
|----------|-----------|---------------|-------------------|------------------|
| 1 | A1 (w/o [Component 1]) | Full (N=[N]) | [N hours] | [DATE] |
| 2 | A3 (w/o [Component 2]) | Full (N=[N]) | [N hours] | [DATE] |
| ... (continue for each component in priority order) | | | | |
| [low-priority] | A2 ([Component 1]-naive) | 30% (N=[N/3]) | [N hours] | [DATE] |

### Run Order Recommendation

Run high-priority ablations first, as they may reveal bugs in the full system
or suggest prompt changes before low-priority ablations are executed.

---

## Ablation Table Design

[Paste the LaTeX table template from Step 6, with blank cells for as-yet-unrun conditions]

---

## Expected Findings

For each ablation, state the expected direction of effect. Derive these predictions from
the component descriptions in `project/system-design.md` and the paper's stated motivations:

| Condition | Expected direction | Reasoning |
|-----------|------------------|-----------|
| A1 w/o [Component 1] | Decrease | [Why this component helps — from system-design.md] |
| A2 [Component 1]-naive | Decrease vs A0, increase vs A1 | Simplified version better than nothing |
| A3 w/o [Component 2] | Decrease | [Why this component helps] |
| ... | ... | ... |

Unexpected results (an ablation increases performance) are the most interesting findings —
they suggest the component may hurt or that design should be reconsidered.

---

## Integration with Paper

After ablation experiments complete:

1. Fill in the ablation table with real numbers
2. Update the ablation subsection in methodology.tex with narrative interpretation
3. Add 2-3 sentences in the discussion section about the most interesting ablation finding
4. Reference the ablation table from the main results section

Cross-reference: experiment-designer, result-analyzer-and-table-gen skills
```

---

## Reference Files

- `references/metrics-glossary.md` — Metric definitions for ablation table columns

---

## Error Handling

- If methodology section cannot be parsed automatically: ask the user to list components manually, then generate the plan from the list
- If no experiment runs exist at all: generate the full plan but mark all conditions as "needs to run"; do not attempt to fill in any numbers
- If the user's system has fewer than 3 identifiable components: note that ablations will be limited; suggest expanding the methodology description to identify more design choices
- If an ablation condition would require rebuilding the full training pipeline (not just inference): flag as "training-time ablation — significantly higher cost" and suggest deferring to a future workshop paper
