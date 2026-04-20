---
name: paper-draft
description: |
  Assemble or update a complete, compilable LaTeX paper draft at any stage of the project.
  Reads project state via project-status, then for each section either invokes the
  corresponding writing skill (if prerequisites are met) or writes a TODO stub (if not).
  The result is always a paper that compiles — with real content where possible and
  explicit TODO markers where data is still missing.
  Trigger whenever the user asks any of the following:
  - "give me a full draft"
  - "draft the paper"
  - "assemble the paper"
  - "update the paper draft"
  - "where is the paper at"
  - "create a paper draft"
  - "make a draft"
  - "write the paper"
  - "get me a draft"
  - "put the paper together"
  - "assemble what we have"
  - "paper draft"
  - "full draft"
  - "generate a draft"
  - "update the draft"
version: 1.0.0
tools: Read, Glob, Grep, Bash, Write, Edit
---

# Skill: paper-draft

You assemble a complete, compilable LaTeX paper draft from whatever the project has at
this moment. The paper always compiles. For sections where the data exists, you invoke
the appropriate writing skill to produce real content. For sections where prerequisites
are missing, you write a structured TODO stub that compiles cleanly.

This skill is designed to be re-run at any project stage. Each time you run it, the
paper improves as more config files and results become available.

**Do not write section prose yourself.** Section content comes from the individual writing
skills. Your job is orchestration, staleness analysis, stub generation, and assembly.

---

## Step 1 — Get Project State

Invoke the `project-status` skill. It will scan the project config and artifacts and print
the status dashboard. Read that output carefully — you will use it to decide what to do
for each section.

Specifically note, for each section:
- Status symbol: ✓ (done), ~ (partial/stub), ○ (ready to write), · (blocked)
- Which config files are populated vs placeholder
- Which section `.tex` files exist and their approximate size

If `project-status` is not available, perform the checks manually:
```bash
ls -la project/*.md 2>/dev/null
grep -l "status: placeholder" project/*.md 2>/dev/null
```

---

## Step 2 — Read Paper Paths

Read `project/paper-paths.md` to get:
- `sections_dir` — where section .tex files live
- `main_tex` — path to the main .tex file
- `figures_dir` — figures directory (for stubs that reference figures)

If the file doesn't exist or has TODO paths, use these defaults:
- `sections_dir` = `paper/sections`
- `main_tex` = `paper/main.tex`
- `figures_dir` = `paper/figures`

Create the sections directory if it doesn't exist:
```bash
mkdir -p {sections_dir}
```

---

## Step 3 — Assess Each Section

For each section below, determine the **action** to take. Use this decision logic:

**INVOKE** the writing skill when:
- The section file is missing or is a stub (contains `% TODO:` in the first 5 lines, or size < 300 bytes)
- AND all prerequisites for that skill are met (config files are populated)

**STUB** when:
- The section file is missing or is a stub
- AND one or more prerequisites are NOT met (config files are placeholder or missing)

**SKIP** when:
- The section file exists, is substantial (> 300 bytes), and contains no `% TODO:` stub marker
- AND the prerequisite config files have NOT been modified more recently than the section file

**OFFER TO REGENERATE** (ask the user before acting) when:
- The section file exists and is substantial
- BUT its prerequisite config file is newer than the section file
- This means: the section was written before the config was updated — it may be stale

Check timestamps with:
```bash
# Returns nothing if config is older than section (section is fresh)
# Returns the config path if config is newer (section may be stale)
find project/contributions.md -newer {sections_dir}/intro.tex 2>/dev/null
```

---

## Step 4 — Section Map

Process sections in this order. The order matters for \input assembly in main.tex.

### Section 1: Introduction (`intro.tex`)
- **Prerequisite**: `project/contributions.md` is populated
- **Writing skill**: `write-intro-and-abstract`
- **Stub file**: `{sections_dir}/intro.tex`

### Section 2: Background (`background.tex`)
- **Prerequisite**: `project/background-concepts.md` is populated (or project-init done — background can be drafted early)
- **Writing skill**: `write-background-section`
- **Stub file**: `{sections_dir}/background.tex`

### Section 3: Methodology (`methodology.tex`)
- **Prerequisite**: `project/system-design.md` is populated
- **Writing skill**: `write-methodology-section`
- **Stub file**: `{sections_dir}/methodology.tex`

### Section 4: Related Work (`related_work.tex`)
- **Prerequisite**: any literature exists — `literature/papers.csv` has entries, OR any files
  exist under `literature/synthesis/`, OR `literature/gap_map.md` exists.
  `write-related-work` will derive and populate `project/related-work-clusters.md` itself
  (Step 0b) if that file is missing or a placeholder — do NOT treat a missing clusters file
  as a blocker.
- **Writing skill**: `write-related-work`
- **Stub file**: `{sections_dir}/related_work.tex`

### Section 5: Experiments (`experiments.tex`)
- **Prerequisite**: `paper/tables/` has at least one `.tex` file (result tables exist)
- **Writing skill**: `paper-experiments`
- **Stub file**: `{sections_dir}/experiments.tex`

### Section 6: Conclusion (`conclusion.tex`)
- **Prerequisite**: none — always writable, but quality improves with contributions.md
- **Writing skill**: none — write stub or a minimal conclusion yourself (see below)
- **Stub file**: `{sections_dir}/conclusion.tex`

**Note on venue section order**: Some venues put Related Work before Background, or after
Experiments. The default order above is common for systems/NLP papers. If `project/venue-config.md`
specifies a different convention, adjust the \input order in main.tex accordingly. The section
files themselves don't need to change.

---

## Step 5 — Execute: Invoke Skills for Ready Sections

For each section marked **INVOKE**, use the corresponding writing skill.

Invoke skills one at a time in the order from Step 4. Before invoking each skill, tell the
user clearly what you're doing:

> "Invoking `write-intro-and-abstract` to write the Introduction..."

Each writing skill will read its own prerequisites and write to the section file. After each
invocation, verify the section file was written:

```bash
ls -la {sections_dir}/intro.tex
wc -l {sections_dir}/intro.tex
```

If a writing skill fails or the section file isn't produced, write a stub instead (see Step 6)
and note the failure in the summary.

---

## Step 6 — Execute: Write Stubs for Blocked Sections

For each section marked **STUB**, write a compilable placeholder file. Use this pattern:

The stub must:
1. Start with a `% TODO:` comment identifying what's needed
2. Have a proper `\section{}` and `\label{}`
3. Have a `\textit{[TODO: ...]}` call-to-action that's readable in the PDF
4. Contain structured placeholder subsections with `TODO:` text
5. Compile without errors (no undefined commands, no missing braces)

### Stub: Introduction

```latex
% TODO: intro — populate project/contributions.md then run write-intro-and-abstract
% Prerequisites missing: project/contributions.md is placeholder or absent

\section{Introduction}
\label{sec:intro}

\textit{\textbf{TODO:} Introduction placeholder. Populate \texttt{project/contributions.md}
with your headline result and contribution bullets, then run the
\texttt{write-intro-and-abstract} skill to replace this stub.}

\paragraph{Problem.} TODO: Describe the problem this paper addresses.

\paragraph{Limitations of prior work.} TODO: What existing approaches fail to do.

\paragraph{Our approach.} TODO: High-level description of the solution.

\paragraph{Contributions.} This paper makes the following contributions:
\begin{itemize}
    \item TODO: Contribution 1.
    \item TODO: Contribution 2.
    \item TODO: Contribution 3.
\end{itemize}
```

### Stub: Background

```latex
% TODO: background — populate project/background-concepts.md then run write-background-section
% Prerequisites missing: project/background-concepts.md is placeholder or absent

\section{Background}
\label{sec:background}

\textit{\textbf{TODO:} Background placeholder. Populate \texttt{project/background-concepts.md}
with the technical concepts a non-expert reviewer would need, then run the
\texttt{write-background-section} skill.}

\subsection{TODO: Core Concept 1}
TODO: Define and explain the first key concept.

\subsection{TODO: Core Concept 2}
TODO: Define and explain the second key concept.
```

### Stub: Methodology

```latex
% TODO: methodology — populate project/system-design.md then run write-methodology-section
% Prerequisites missing: project/system-design.md is placeholder or absent

\section{Methodology}
\label{sec:method}

\textit{\textbf{TODO:} Methodology placeholder. Populate \texttt{project/system-design.md}
with your system architecture, pipeline stages, and datasets, then run the
\texttt{write-methodology-section} skill.}

\subsection{System Overview}
TODO: Describe the overall architecture and pipeline.

\subsection{TODO: Component 1}
TODO: Describe the first major system component.

\subsection{TODO: Component 2}
TODO: Describe the second major system component.

\subsection{Implementation Details}
TODO: Datasets, hyperparameters, compute infrastructure.
```

### Stub: Related Work

```latex
% TODO: related_work — no literature found; run paper-search-and-triage then write-related-work
% Prerequisites missing: no papers.csv, no literature/synthesis/ content, no literature/gap_map.md

\section{Related Work}
\label{sec:related}

\textit{\textbf{TODO:} Related work placeholder. Run \texttt{paper-search-and-triage} to collect
papers, then run \texttt{write-related-work} directly — it will derive thematic clusters
automatically from available literature.}

\subsection{TODO: Research Area 1}
TODO: Survey of the first cluster of related work.

\subsection{TODO: Research Area 2}
TODO: Survey of the second cluster of related work.

\subsection{Comparison to This Work}
TODO: Summarize how this work differs from and extends the above.
```

### Stub: Experiments

```latex
% TODO: experiments — generate result tables then run paper-experiments
% Prerequisites missing: paper/tables/ has no .tex files yet

\section{Evaluation}
\label{sec:eval}

\textit{\textbf{TODO:} Experiments placeholder. Run \texttt{experiment-runner-monitor}
to collect results, then \texttt{result-analyzer-and-table-gen} to produce tables,
then \texttt{paper-experiments} to write this section.}

\subsection{Experimental Setup}
TODO: Datasets, baselines, metrics, and compute environment.

\subsection{Main Results}
TODO: Main results table goes here.
% \input{tables/results_main}

\subsection{Ablation Study}
TODO: Ablation results.

\subsection{Analysis}
TODO: Error analysis and qualitative findings.
```

### Stub / Minimal Conclusion

The conclusion can always be drafted as a minimal real section (not just a TODO) because
it derives from the paper's own claims. Write a brief real conclusion if contributions.md
is populated; write a stub if it is not.

**If contributions.md is populated**, write a real 3-paragraph conclusion:
- Para 1: Restate the problem and what this paper did
- Para 2: Summarize the 2–3 key findings
- Para 3: Future work (draw from contributions.md hints, or write "We leave X as future work")

**If contributions.md is not populated**, write:

```latex
% TODO: conclusion — will be written after contributions.md is populated

\section{Conclusion}
\label{sec:conclusion}

\textit{\textbf{TODO:} Conclusion placeholder. Populate \texttt{project/contributions.md}
to enable a real conclusion. In the meantime:}

TODO: Summarize what problem was solved and what was built.

TODO: State the key result or finding.

TODO: Describe limitations and future directions.
```

---

## Step 7 — Assemble main.tex

Check if the main .tex file exists:

```bash
ls {main_tex} 2>/dev/null
```

### If main.tex does NOT exist — create it

Create a full minimal main.tex that compiles. Infer the document class from
`project/venue-config.md`:

- ACL / EMNLP / NAACL → `\documentclass[11pt]{article}` with `\usepackage{acl}`
- NeurIPS → `\documentclass{article}` with `\usepackage{neurips_2024}`
- USENIX / CCS / IEEE S&P → `\documentclass[letterpaper,twocolumn,10pt]{article}` with `\usepackage{usenix-2020-09}`
- Unknown venue → `\documentclass[11pt]{article}` with common packages

Create the file with:
- Preamble: document class + essential packages (`\usepackage{amsmath, amssymb, graphicx, hyperref, booktabs, xcolor}`)
- Title block with TODO placeholders
- Abstract block (inline, with TODO or a brief real abstract if contributions.md is populated)
- `\input` for each section in the order from Step 4
- Bibliography with `\bibliographystyle{plain}` and `\bibliography{references}` (or venue-appropriate style)

**Never hardcode author names** — use `TODO: Author Names` as the placeholder.

### If main.tex EXISTS — ensure all sections are \input'd

Read the main.tex file. For each section file that now exists (whether written by a skill
or as a stub), check that a corresponding `\input` or `\include` line is present. If any
are missing, add them in the correct position using Edit.

The correct positions (look for surrounding context clues):
- `\input{sections/intro}` → after `\end{abstract}`
- `\input{sections/background}` → after intro, before methodology
- `\input{sections/methodology}` → after background
- `\input{sections/related_work}` → position depends on venue (before or after methodology)
- `\input{sections/experiments}` → after methodology
- `\input{sections/conclusion}` → last, before bibliography

When inserting, use the relative path format that matches what's already in the file.

---

## Step 8 — Compile Check

After assembly, invoke the `latex-compile-and-check` skill to verify the paper compiles
and count pages.

If that skill is unavailable, run a quick compile check:
```bash
cd {paper_dir} && pdflatex -interaction=nonstopmode main.tex 2>&1 | tail -20
```

If there are compile errors:
- If the error is in a stub file, fix the LaTeX syntax in the stub
- If the error is in a skill-generated section, note it for the user but do not modify the section
- Never leave the paper in a non-compiling state — fix stubs until the paper builds

---

## Step 9 — Summary Report

Print a concise summary of what was done:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  PAPER DRAFT UPDATED
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Sections written by skill:
  ✓ write-intro-and-abstract   → intro.tex  (643 words)
  ✓ write-background-section   → background.tex  (891 words)

Sections stubbed (prerequisites missing):
  ~ methodology.tex    needs: project/system-design.md
  ~ related_work.tex   needs: project/related-work-clusters.md
  ~ experiments.tex    needs: paper/tables/ (no result tables yet)
  ~ conclusion.tex     needs: project/contributions.md

Assembly:
  main.tex             all 6 sections \input'd
  PDF                  [compiled OK — N pages] OR [compile failed — see errors above]

TO IMPROVE THIS DRAFT:
  Fill in project/system-design.md   → unlocks write-methodology-section
  Run paper-search-and-triage        → unlocks deep-paper-synthesis → research-gap-mapper → write-related-work
  Run experiment-runner-monitor      → unlocks result-analyzer-and-table-gen → paper-experiments

Re-run paper-draft at any time to convert stubs into real sections as prerequisites are met.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

Then invoke `project-status` to show the full updated dashboard.
