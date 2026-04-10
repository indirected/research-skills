# ACL LaTeX Comparison Table Patterns

This file provides ready-to-use LaTeX templates for creating comparison tables in the ACL
conference format. All tables use the `booktabs` package for professional typesetting and are
designed to fit within ACL's two-column format.

---

## Required LaTeX Packages

Ensure these are in the preamble of `paper/latex/acl_latex.tex`:

```latex
\usepackage{booktabs}      % \toprule, \midrule, \bottomrule
\usepackage{multirow}      % \multirow for merged cells
\usepackage{makecell}      % \makecell for line breaks within cells
\usepackage{xcolor}        % \rowcolor, \cellcolor for shading
\usepackage{array}         % Enhanced column types (p{}, m{})
\usepackage{tabularx}      % Auto-expanding columns (X type)
\usepackage{rotating}      % \rotatebox for sideways headers
\usepackage{amssymb}       % \checkmark for ✓ symbols
```

Check `paper/latex/acl.sty` — ACL already includes several of these. Do not double-load packages.

---

## Table 1: Standard Comparison Table (ACL Two-Column Format)

Use this for a 5-8 paper comparison with 4-6 axes. Fits in a single column (~8.5cm width).

```latex
\begin{table}[t]
\centering
\small
\caption{Comparison of LLM-based vulnerability repair approaches. 
         \textbf{Lang}: programming language scope. 
         \textbf{Oracle}: correctness verification method. 
         \textbf{Bench}: evaluation benchmark.
         \checkmark{} = supported; \textemdash{} = not applicable.}
\label{tab:related_work_comparison}
\begin{tabular}{lcccc}
\toprule
\textbf{System} & \textbf{Lang} & \textbf{LLM} & \textbf{Oracle} & \textbf{Bench} \\
\midrule
\citet{Paper1}   & Java    & GPT-3.5  & Test suite  & Defects4J  \\
\citet{Paper2}   & C/C++   & \textemdash & Test suite & BigVul \\
\citet{Paper3}   & Multi   & GPT-4    & Human       & SWE-Bench  \\
\citet{Paper4}   & Java    & CodeBERT & Test suite  & QuixBugs   \\
\citet{Paper5}   & Python  & GPT-4    & Test suite  & BugsInPy   \\
\midrule
\textbf{Ours}    & \textbf{C/C++}  & \textbf{GPT-4}  & \textbf{Fuzzer} & \textbf{ARVO} \\
\bottomrule
\end{tabular}
\end{table}
```

---

## Table 2: Wide Comparison Table (Full Page Width, use `table*`)

Use this for 8+ papers or 7+ columns. The `table*` environment spans both columns in ACL format.

```latex
\begin{table*}[t]
\centering
\small
\caption{Comprehensive comparison of automated vulnerability and program repair approaches.
         \textbf{Bug Type}: vulnerability type scope (mem. = memory safety, gen. = general bugs).
         \textbf{Localization}: whether fault localization is automated.
         \textbf{Correct\%}: percentage of bugs with a correct patch; \textemdash{} = not reported.
         Best results in \textbf{bold}.}
\label{tab:full_comparison}
\begin{tabular}{llcccccc}
\toprule
\textbf{System} & \textbf{Venue} & \textbf{Language} & \textbf{Bug Type} & \textbf{LLM} & 
\textbf{Oracle} & \textbf{Benchmark} & \textbf{Correct\%} \\
\midrule
% ---- Classical APR ----
\multicolumn{8}{l}{\textit{Classical Automated Program Repair}} \\
\citet{GenProg}      & TSE'12   & C        & gen.  & \textemdash    & Test suite & ManyBugs    & 8.1\%  \\
\citet{Angelix}      & ICSE'16  & C        & gen.  & \textemdash    & Test suite & ManyBugs    & 12.4\% \\
\citet{Prophet}      & POPL'16  & C        & gen.  & \textemdash    & Test suite & ManyBugs    & 15.0\% \\
\midrule
% ---- Neural APR ----
\multicolumn{8}{l}{\textit{Neural Automated Program Repair}} \\
\citet{CoCoNuT}      & ISSTA'20 & Java     & gen.  & CodeBERT & Test suite & Defects4J   & 21.3\% \\
\citet{AlphaRepair}  & ISSTA'22 & Java     & gen.  & Codex    & Test suite & Defects4J   & 27.5\% \\
\midrule
% ---- LLM-based ----
\multicolumn{8}{l}{\textit{LLM-based Repair}} \\
\citet{ChatRepair}   & ISSTA'24 & Java     & gen.  & GPT-4    & Test suite & Defects4J   & 34.5\% \\
\citet{SWEAgent}     & ICML'24  & Python   & gen.  & GPT-4    & Test suite & SWE-Bench   & 18.0\% \\
\citet{VulRepair}    & CCS'23   & C/C++    & mem.  & GPT-4    & Test suite & BigVul      & 19.2\% \\
\midrule
% ---- Ours ----
\textbf{AutoPatch (Ours)} & This paper & \textbf{C/C++} & \textbf{mem.} & \textbf{GPT-4} &
\textbf{Fuzzer} & \textbf{ARVO} & \textbf{43.2\%} \\
\bottomrule
\end{tabular}
\end{table*}
```

---

## Table 3: Grouped with \multicolumn Headers

Use this when columns fall into logical groups (e.g., "Problem Setting" vs. "Method" vs. "Results").

```latex
\begin{table*}[t]
\centering
\small
\caption{Comparison of vulnerability repair systems across problem setting, methodology,
         and evaluation dimensions. P = plausibility rate; C = correctness rate.}
\label{tab:grouped_comparison}
\setlength{\tabcolsep}{4pt}
\begin{tabular}{l l @{\hskip 8pt} c c c @{\hskip 8pt} c c c @{\hskip 8pt} c c}
\toprule
& & \multicolumn{3}{c}{\textbf{Problem Setting}} & 
  \multicolumn{3}{c}{\textbf{Method}} & 
  \multicolumn{2}{c}{\textbf{Evaluation}} \\
\cmidrule(lr){3-5} \cmidrule(lr){6-8} \cmidrule(lr){9-10}
\textbf{System} & \textbf{Venue} & \textbf{Lang} & \textbf{Bug Type} & \textbf{Benchmark} 
                                 & \textbf{LLM} & \textbf{Oracle} & \textbf{Localization} 
                                 & \textbf{P\%} & \textbf{C\%} \\
\midrule
\citet{Paper1}  & CCS'23  & C/C++ & mem.  & BigVul      & GPT-4 & Test suite & Manual    & 65.2 & 19.2 \\
\citet{Paper2}  & ICSE'24 & Java  & gen.  & Defects4J   & GPT-4 & Test suite & Automated & 71.4 & 34.5 \\
\citet{Paper3}  & arXiv'24 & Multi & gen. & SWE-Bench   & GPT-4 & Human      & Auto.     & 42.0 & 18.0 \\
\citet{Paper4}  & ASE'23  & Java  & gen.  & QuixBugs    & Codex & Test suite & Manual    & 58.3 & 27.5 \\
\midrule
\textbf{AutoPatch} & \textbf{Ours} & \textbf{C/C++} & \textbf{mem.} & \textbf{ARVO} 
                   & \textbf{GPT-4} & \textbf{Fuzzer} & \textbf{Auto.}
                   & \textbf{68.4} & \textbf{43.2} \\
\bottomrule
\end{tabular}
\end{table*}
```

Key `\multicolumn` and `\cmidrule` rules:
- `\multicolumn{N}{c}{text}` spans N columns, centered.
- `\cmidrule(lr){A-B}` draws a partial horizontal rule from column A to B, with left/right trimming.
- The number after `\multicolumn` must exactly match the number of columns it spans.
- Use `@{\hskip 8pt}` between column groups to add horizontal whitespace without a visible rule.

---

## Table 4: Checkmark Matrix (Feature Coverage Table)

Use when comparing binary features (supported / not supported).

```latex
\begin{table}[t]
\centering
\small
\caption{Feature coverage across related approaches. 
         \cmark{} = fully supported; 
         $\circ$ = partially supported; 
         \xmark{} = not supported.}
\label{tab:feature_coverage}
\newcommand{\cmark}{\textcolor{teal}{\checkmark}}
\newcommand{\xmark}{\textcolor{red}{$\times$}}
\begin{tabular}{lcccc}
\toprule
\textbf{Feature} & \textbf{Paper1} & \textbf{Paper2} & \textbf{Paper3} & \textbf{Ours} \\
\midrule
C/C++ support          & \cmark & \xmark & \xmark & \cmark \\
Memory safety focus    & \cmark & \xmark & \xmark & \cmark \\
CVE-confirmed bugs     & \xmark & \xmark & \xmark & \cmark \\
Fuzzer-based oracle    & \xmark & \xmark & \xmark & \cmark \\
Automated localization & \xmark & \cmark & $\circ$ & \cmark \\
Open-source code       & \cmark & \xmark & \cmark & \cmark \\
\bottomrule
\end{tabular}
\end{table}
```

---

## Formatting Rules for ACL Tables

### Column Widths
- Single-column tables: maximum total width ~8.5cm. Use `\small` font inside.
- Double-column (`table*`): maximum total width ~17cm. Use `\small` or `\footnotesize`.
- For very wide tables, use `\resizebox{\textwidth}{!}{...}` around the `tabular` environment.

```latex
\resizebox{\textwidth}{!}{%
\begin{tabular}{...}
...
\end{tabular}%
}
```

### Number Formatting
- Percentages: `43.2\%` (never `43.2%` without backslash in LaTeX math-adjacent contexts)
- Bold best result: `\textbf{43.2}` — bold the number AND the unit separately if needed
- "Not reported": use `\textemdash{}` (renders as —)
- Approximate values: `$\approx$43.2`

### Row Shading (highlight key row)
```latex
\usepackage[table]{xcolor}
% In the table body, before the row to highlight:
\rowcolor{gray!15}
\textbf{AutoPatch (Ours)} & ... \\
```

### Long Cell Content
For cells with multiple items or line breaks:
```latex
\makecell[l]{Memory safety \\ CVE-confirmed}   % left-aligned two-line cell
\makecell[c]{GPT-4 \\ (zero-shot)}              % centered two-line cell
```

### Sideways Column Headers (for very wide tables)
```latex
\rotatebox{60}{\textbf{LLM Used}}
\rotatebox{60}{\textbf{Oracle Type}}
```

---

## Complete Working Example: AutoPatch Related Work Table

This is the full LaTeX source for a production-ready comparison table for the AutoPatch paper.
Copy, fill in the real citation keys and numbers, and paste into the paper.

```latex
\begin{table*}[t]
\centering
\small
\setlength{\tabcolsep}{5pt}
\caption{Comparison of automated vulnerability and program repair systems most related to
         AutoPatch. \textbf{C\%}: percentage of bugs with correct patches (as defined by 
         each paper's oracle). \textemdash{} = not reported or not applicable. 
         Results for our system averaged across all LLM configurations.}
\label{tab:main_comparison}
\begin{tabular}{l l c c c c c r}
\toprule
\textbf{System} & \textbf{Venue} & \textbf{Lang.} & \textbf{Bug Type} & 
\textbf{LLM} & \textbf{Oracle} & \textbf{Dataset} & \textbf{C\%} \\
\midrule
\multicolumn{8}{l}{\textit{\small Classical Automated Program Repair}} \\[2pt]
\citet{genprog}     & TSE 2012   & C      & General  & \textemdash & Tests    & ManyBugs     & 8.1  \\
\citet{prophet}     & POPL 2016  & C      & General  & \textemdash & Tests    & ManyBugs     & 15.0 \\
\citet{vulfix}      & CCS 2021   & C/C++  & Mem.     & \textemdash & Tests    & CVEFixes     & 12.3 \\
\addlinespace[4pt]
\multicolumn{8}{l}{\textit{\small LLM-Assisted Program Repair}} \\[2pt]
\citet{codex_apr}   & arXiv 2022 & Multi  & General  & Codex       & Tests    & QuixBugs     & 27.5 \\
\citet{chatrepair}  & ISSTA 2024 & Java   & General  & GPT-4       & Tests    & Defects4J    & 34.5 \\
\citet{sweagent}    & ICML 2024  & Python & General  & GPT-4       & Tests    & SWE-Bench    & 18.0 \\
\addlinespace[4pt]
\multicolumn{8}{l}{\textit{\small LLM-based Vulnerability Repair}} \\[2pt]
\citet{vulrepair}   & CCS 2023   & C/C++  & Mem.     & GPT-4       & Tests    & BigVul       & 19.2 \\
\citet{seccodeplt}  & NeurIPS 2024 & C/C++ & Mem.   & GPT-4       & Tests    & CVE-Bench    & 22.8 \\
\midrule
\rowcolor{gray!12}
\textbf{AutoPatch}  & \textbf{This paper} & \textbf{C/C++} & \textbf{Mem.} &
\textbf{GPT-4}      & \textbf{Fuzzer}  & \textbf{ARVO} & \textbf{43.2} \\
\bottomrule
\end{tabular}
\end{table*}
```

---

## Generating the Table from Synthesis Data

When the deep-paper-synthesis skill builds a comparison table programmatically, follow this order:

1. Collect one row per paper from the extraction cards.
2. Sort rows: Classical APR (by year) → Neural APR (by year) → LLM-based repair (by year) → Ours (always last).
3. Insert `\multicolumn` group headers between sections.
4. Bold the best result in each numeric column (check all rows first, then bold).
5. If a value is missing from a paper's card, use `\textemdash{}`.
6. Validate column count: count `&` characters in each row; must equal (number of columns - 1).
   Mismatched counts cause LaTeX compilation errors.

---

## Saving and Including the Table in the Paper

Save to: `literature/synthesis/{TOPIC}_table.tex`

To include in the paper:
```latex
\input{literature/synthesis/llm_vuln_repair_table.tex}
```

Or copy the content directly into `paper/latex/acl_latex.tex` at the appropriate location
(typically just after the start of the Related Work or Experiments section, wherever the
comparison table is referenced).

Reference with:
```latex
Table~\ref{tab:main_comparison} compares AutoPatch against related approaches.
```
