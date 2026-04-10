---
name: write-methodology-section
description: |
  Draft the Methodology / System Design section of any research paper in LaTeX.
  Reads system architecture from project/system-design.md and translates it into
  accurate paper prose with algorithm blocks and figure stubs.
  Trigger when the user says any of the following:
  - "write methodology"
  - "write system design section"
  - "describe our approach"
  - "draft the design section"
  - "write about the system architecture"
  - "write the method section"
  - "explain our system"
  - "draft the methodology"
  - "write about the pipeline"
  - "write the system section"
  - "describe how [system] works"
  - "explain the [component] pipeline"
  - "write about the [approach] approach"
  - "describe the [approach] approach"
  - "help me write the design section"
version: 2.0.0
tools: Read, Glob, Grep, Bash, Write, Edit
---

# Skill: write-methodology-section

You are helping write the **Methodology / System Design** section of a research paper.
This section describes what the system does and how it works — grounded in the actual design,
not aspirational descriptions. It should be precise enough for an expert reviewer to evaluate
and for a reader to re-implement the core ideas.

---

## Step 0 — Check Prerequisites

Read the project config files:

```
Read: project/research-focus.md
Read: project/system-design.md
Read: project/paper-paths.md
Read: project/venue-config.md
```

**If `project/system-design.md` does not exist**, stop and tell the user:

> "I need `project/system-design.md` to write the methodology section.
> Please run the `project-init` skill first, or create this file manually.
>
> The file format is:
> ```markdown
> # System Design
>
> system_name: YourSystem
>
> ## Pipeline
> - Input: [description]
> - Step 1: [description]
> - Step 2: [description]
> - Output: [description]
>
> ## Key Components
> ### [component name]
> [1-sentence description]
>
> ## Datasets
> ### [dataset name]
> [why appropriate]
>
> ## Iterative / Agentic Loop
> [description or N/A]
> ```"

Extract from `project/research-focus.md`:
- `system_name` → use as `{{SYSTEM_NAME}}` throughout

Extract from `project/venue-config.md`:
- `review_mode` → if "yes", apply anonymization
- Word budget for Methodology section

---

## Step 1 — Check Review Mode

If `review_mode: yes` in `project/venue-config.md`:
- Do NOT mention author names, lab names, or institution names.
- Write "the {{SYSTEM_NAME}} system" not "our system" or "our lab's system".
- Treat all prior work as third-party.

Inform the user of current mode.

---

## Step 2 — Read Existing Paper Sections

```
Read: {{main_tex from project/paper-paths.md}}
Glob: {{sections_dir from project/paper-paths.md}}/*.tex
```

Read each existing .tex section to understand what has already been written.
Identify: what the intro/contributions say about the system (the methodology must be consistent),
and what the background section covers (methodology should not re-explain background concepts).

---

## Step 3 — Propose Subsection Structure

Based on the pipeline and components in `project/system-design.md`, derive a subsection structure.

**Rules for structure derivation**:
- The first subsection is always **Overview** — a 1-2 paragraph bird's eye view with a figure stub.
- Each major pipeline stage or component listed in `project/system-design.md` becomes a subsection.
- If the system uses a dataset in a non-obvious way (beyond what background covers), add a **Dataset** subsection.
- If the system has an iterative/agentic loop described in `project/system-design.md`, add a dedicated subsection for it with an algorithm block.
- Merge minor steps that are implementation details rather than conceptual contributions.

Present the proposed structure to the user and ask for approval:

> "Based on `project/system-design.md`, I propose this subsection structure for Section 3:
>
> ```
> 3. System Design
>    3.1 Overview
>    3.2 [Component/Stage from config]
>    3.3 [Component/Stage from config]
>    ...
>    3.N [Iterative Loop — if present]
> ```
>
> Does this structure work, or would you like to add, remove, or reorder subsections?"

---

## Step 4 — Draft Each Subsection

### 3.1 Overview (~100–150 words)

Draft one paragraph describing the full pipeline at high level using the Pipeline bullets
from `project/system-design.md`. Reference a figure:

```latex
\begin{figure}[t]
  \centering
  % TODO: Insert pipeline diagram here
  % Diagram should show: [pipeline steps from config, left-to-right or top-to-bottom]
  \includegraphics[width=\columnwidth]{figures/architecture}
  \caption{The {{SYSTEM_NAME}} pipeline. [1-sentence description derived from pipeline steps.]}
  \label{fig:architecture}
\end{figure}
```

Tell the user: "You will need to create a pipeline diagram at `figures/architecture.pdf`."

---

### 3.2–3.N Component Subsections (~100–250 words each)

For each component or pipeline stage from `project/system-design.md`:

1. **What it does** (2–3 sentences): describe the component's role in the system.
2. **How it works** (3–5 sentences): describe the mechanism. Use concrete language — reference inputs, outputs, parameters, and decisions. If there is a specific algorithm or formula, include it or stub it.
3. **Design choices** (1–2 sentences, if notable): explain why this design was chosen over alternatives (if the user's system-design.md notes mention this).

**For a dataset subsection**:
- Describe how the system uses the dataset (not what the dataset is — that goes in Background).
- Note what properties of the dataset enable the system's evaluation approach.

**For an iterative/agentic loop subsection**:
- Include an algorithm block (see template below).
- Describe the loop termination condition and what is fed back into each iteration.

---

### Algorithm Block Template (use only if system-design.md describes an iterative loop)

```latex
\begin{algorithm}[t]
\caption{{{SYSTEM_NAME}} Main Loop}
\label{alg:main-loop}
\SetAlgoLined
\KwIn{[input description from project/system-design.md]}
\KwOut{[output description]}

[Step 1 from pipeline]\;
[Step 2 from pipeline]\;

\For{$i \gets 1$ \KwTo MAX\_ITERS}{
  [iteration body from loop description in project/system-design.md]\;
  \If{[termination condition]}{
    \textbf{break}\;
  }
}

\Return{[output]}\;
\end{algorithm}
```

Tell the user: "Add `\usepackage[ruled,vlined]{algorithm2e}` to the preamble of your main .tex file if not already present."

---

## Step 5 — Check Citations Against Bibliography

For every `\cite{}` key introduced in the methodology, check if it exists in the bibliography:
```python
Grep(pattern=r"{{cite_key}}", path="{{bibliography from project/paper-paths.md}}")
```

Citations needed in methodology sections typically include:
- The dataset(s) used
- The LLM or model used (if applicable)
- Any tool or infrastructure the system is built on
- The algorithm the system is based on (if applicable)

For missing keys, note as TODO. Never invent DOIs or page numbers.

---

## Step 6 — Apply Anonymization Check

If review mode is active:
```python
Grep(pattern=r"our lab|our prior work|we previously|our previous|our earlier|our group",
     path="{{sections_dir}}/methodology.tex", output_mode="content")
```

Also check for any system/tool names that would reveal the research group.
Flag and suggest neutral rewrites.

---

## Step 7 — Page Budget Check

```bash
wc -w {{sections_dir}}/methodology.tex
```

Compare against the budget in `project/venue-config.md`. Defaults if not specified:
- ACL 8-page: 1000–1300 words (2.0–2.5 pages)
- NeurIPS 9-page: 1200–1500 words
- USENIX 13-page: 1800–2200 words

Note: Figures and algorithm blocks consume significant space. A full-width figure ~= 200 words of space. An algorithm block ~= 100–150 words.

**If over budget**:
- Trim the Overview paragraph (1 paragraph only).
- Move implementation details to an appendix.
- Shorten the dataset subsection if background already covers it.

**If under budget**:
- Add a subsection on a component that was described briefly.
- Add a concrete example (input/output pair showing the system in action).
- Add a complexity analysis or limitations discussion.

---

## Step 8 — Check `\input` in Main .tex

```bash
grep "input{sections/methodology" {{main_tex}} 2>/dev/null || \
grep "input{sections/design" {{main_tex}} 2>/dev/null
```

If not present, tell the user:
> "Add `\input{sections/methodology}` to your main .tex file after the background section input."

Also check that algorithm2e is in the preamble if an algorithm was used:
```bash
grep "algorithm2e" {{main_tex}} 2>/dev/null
```

---

## Step 9 — Final Checklist

- [ ] `\section{System Design}` (or `\section{Methodology}`) with `\label{sec:methodology}` present.
- [ ] All subsections have `\label{sec:method-*}` labels.
- [ ] Figure stub `fig:architecture` present with TODO comment for actual figure.
- [ ] Algorithm block (if iterative system): algorithm2e package noted.
- [ ] All `\cite{}` keys verified in bibliography.
- [ ] No author/lab names in review mode.
- [ ] Word count is within venue budget.
- [ ] `\input{sections/methodology}` placement checked in main .tex.
- [ ] List of needed figures given to user.

---

## Step 10 — List Needed Figures

Present to the user:

```
FIGURES NEEDED FOR METHODOLOGY SECTION:
1. fig:architecture — Full pipeline diagram
   Content: [derived from pipeline steps in project/system-design.md]
   Format: flowchart, left-to-right or top-to-bottom
   File: {{figures_dir}}/architecture.pdf

[Additional figures if any components benefit from a diagram]
```

---

## Step 11 — Remind User to Sync with Overleaf

```
SYNC REMINDER:
If your paper/ directory is a git submodule linked to Overleaf:

  cd {{paper_root_dir}}
  git add latex/sections/methodology.tex latex/custom.bib latex/main.tex
  git commit -m "Add methodology section"
  git push

Verify the PDF compiles on Overleaf. Check especially:
- algorithm2e package availability (if algorithm was added)
- figures/architecture.pdf existence (will cause compile error if missing)
- Any \cite{} keys not yet in bibliography
```
