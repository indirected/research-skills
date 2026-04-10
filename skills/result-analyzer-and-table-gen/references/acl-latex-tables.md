# ACL LaTeX Table Formatting Rules

This reference covers everything needed to produce publication-quality tables for ACL/EMNLP/NAACL
papers using the `acl` style package.

---

## Required Packages

Add these to the preamble if not already present:

```latex
\usepackage{booktabs}    % \toprule, \midrule, \bottomrule — mandatory for ACL
\usepackage{multirow}    % \multirow for spanning rows
\usepackage{makecell}    % \makecell for line breaks in cells
\usepackage{xcolor}      % \cellcolor if needed
```

---

## The Golden Rule: Use booktabs, Never hline

```latex
% CORRECT:
\toprule   % top border
\midrule   % separator between header and body
\bottomrule % bottom border

% NEVER USE:
\hline     % too heavy, not ACL style
```

---

## Standard Table Template (single-column width, 7.7 cm)

```latex
\begin{table}[t]
\centering
\small
\caption{Caption goes here. Keep it informative: define abbreviations used in column headers.}
\label{tab:your-label}
\begin{tabular}{lcccc}
\toprule
\textbf{Method} & \textbf{QA} & \textbf{T1} & \textbf{Correct} & \textbf{Patches} \\
\midrule
GPT-4o        & 80.0 & 53.3 & \textbf{46.7} & 11/15 \\
Claude Sonnet & \textbf{86.7} & \textbf{60.0} & 40.0 & 12/15 \\
Gemini 1.5    & 73.3 & 46.7 & 33.3 & 10/15 \\
\bottomrule
\end{tabular}
\end{table}
```

---

## Wide Table Template (spans both columns, max 16.0 cm)

```latex
\begin{table*}[t]
\centering
\small
\caption{Wide table spanning both columns.}
\label{tab:wide-table}
\begin{tabular}{lcccccccc}
\toprule
\textbf{Model} & \textbf{QA} & \textbf{Patch Gen} & \textbf{T1} & \textbf{T2} & 
\textbf{T2 Iters} & \textbf{T3 Cov.} & \textbf{T4} & \textbf{Correct} \\
\midrule
...
\bottomrule
\end{tabular}
\end{table*}
```

---

## Column Alignment

| Symbol | Use for |
|---|---|
| `l` | Left-aligned — use for method/model names (first column) |
| `c` | Centered — use for numeric values |
| `r` | Right-aligned — use for counts/integers if needed |
| `p{2cm}` | Fixed-width paragraph — use for text that might wrap |

Avoid vertical lines (`|`) between columns — they are heavy and not ACL style.

---

## Bolding the Best Result

Bold the best value in each metric column manually:

```latex
\textbf{60.0}   % best Tier 1 value
```

If there are ties, bold all tied values.

Do **not** use `\mathbf{}` for non-math content — use `\textbf{}`.

---

## Statistical Significance Markers

Use `\dag` (†) or `\ddag` (‡) as superscripts to mark statistical significance:

```latex
60.0\dag   % this model is significantly better than baseline
```

Add a footnote below the table explaining the marker:

```latex
\begin{table}[t]
...
\end{tabular}
\vspace{-0.5em}
{\footnotesize \dag Significantly better than GPT-4o baseline ($p < 0.05$, bootstrap).}
\end{table}
```

---

## Partial Results / Missing Values

Use `--` for not-applicable or not-yet-computed values:

```latex
Claude Sonnet & 86.7 & 60.0 & -- & -- & 40.0 \\
```

---

## Grouping Rows with \midrule

Use `\midrule` to separate logical groups of rows:

```latex
\midrule
% separator between main results and ablation rows
\midrule[0.5pt]  % thinner midrule variant (requires booktabs)
```

---

## Multirow and Multicolumn

```latex
% Span 2 rows
\multirow{2}{*}{Claude Sonnet}

% Span 3 columns, centered
\multicolumn{3}{c}{\textit{Verification Tiers}}
```

Common use: add a grouped header row above columns:

```latex
\toprule
& & \multicolumn{2}{c}{\textbf{Tier 1}} & \multicolumn{3}{c}{\textbf{Tier 2+}} \\
\cmidrule(lr){3-4} \cmidrule(lr){5-7}
\textbf{Model} & \textbf{QA} & \textbf{Fix} & \textbf{Rate} & \textbf{Pass} & \textbf{Iters} & \textbf{Cov.} \\
\midrule
```

The `\cmidrule(lr){3-4}` draws a partial rule under columns 3-4 with small left and right trim.

---

## Number Formatting Conventions

| Value type | Format | Example |
|---|---|---|
| Rates / percentages | 1 decimal place, no % symbol (define in caption) | `60.0` |
| Absolute counts | `X/N` format | `9/15` |
| Mean ± std | Compact notation | `60.0±5.2` |
| Large integers | Plain | `15` |
| Float with significance | `60.0\dag` | |

---

## Font Size

Use `\small` for most tables (reduces to ~10pt, still readable in print).
Use `\footnotesize` only if the table is very wide.
Avoid `\tiny` — hard to read in print.

---

## Placement

- `[t]` — top of page (preferred for ACL: keeps text flow)
- `[h]` — here (use sparingly; ACL prefers `[t]`)
- `[!t]` — force top (when `[t]` gets pushed to next page)

Tables should appear near the text that first references them. In a 2-column layout,
single-column tables float within their column; `table*` floats across both columns.

---

## Complete Example: Main AutoPatch Results Table

```latex
\begin{table}[t]
\centering
\small
\caption{AutoPatch benchmark results on ARVO-Lite (15 cases).
QA: containers pass quality checks; Patch: patch generated (/ QA-passed);
T1: crash fixed; Correct: crash fixed and functionality preserved.
All rates are \% of QA-passed cases.}
\label{tab:results-main}
\begin{tabular}{lcccc}
\toprule
\textbf{Model} & \textbf{QA} & \textbf{Patch} & \textbf{T1} & \textbf{Correct} \\
\midrule
GPT-4o           & 80.0 & 91.7 & 53.3 & 46.7 \\
Claude 3.5 Sonnet & \textbf{86.7} & \textbf{100.0} & \textbf{66.7} & \textbf{58.3} \\
Gemini 1.5 Pro   & 73.3 & 90.9 & 45.5 & 36.4 \\
\bottomrule
\end{tabular}
\end{table}
```

---

## Complete Example: Multi-Tier Results Table (Milestone 6)

```latex
\begin{table*}[t]
\centering
\small
\caption{Multi-tier verification results. T1: PoC crash fix; T2: developer test suite;
T3: line coverage (\%); T4: differential testing. Correct (M6) = T1 + T2.
Tier 2 Iters: mean LLM repair iterations.}
\label{tab:results-multitier}
\begin{tabular}{lcccccccc}
\toprule
& & \multicolumn{2}{c}{\textbf{Tier 1}} & 
  \multicolumn{3}{c}{\textbf{Tier 2}} & 
  \textbf{T4} & \textbf{Correct} \\
\cmidrule(lr){3-4}\cmidrule(lr){5-7}
\textbf{Model} & \textbf{QA} & \textbf{Pass} & \textbf{Rate} & \textbf{Pass} & \textbf{Iters} & \textbf{T3 Cov.} & \textbf{Pass} & \textbf{(T1+T2)} \\
\midrule
GPT-4o           & 12/15 & 8/12 & 66.7 & 6/12 & 2.1 & 54.3 & 7/12 & 50.0 \\
Claude 3.5 Sonnet & \textbf{13/15} & \textbf{9/13} & \textbf{69.2} & \textbf{8/13} & \textbf{1.7} & \textbf{58.9} & \textbf{8/13} & \textbf{61.5} \\
\bottomrule
\end{tabular}
\end{table*}
```

---

## Including Tables in the Main Document

In `acl_latex.tex`, include section files:

```latex
\input{tables/results_main}
```

Or reference from within a section file:

```latex
% In paper/sections/results_draft.tex:
Table~\ref{tab:results-main} shows the main benchmark results.
% Or with hyperref:
\autoref{tab:results-main} shows...
```

---

## Common Mistakes to Avoid

1. Using `\hline` — always use `\toprule`/`\midrule`/`\bottomrule`
2. Column headers not bolded — use `\textbf{}`
3. Inconsistent decimal places across rows (e.g., `60.0` vs `60`)
4. Missing `\label{}` — makes cross-referencing impossible
5. Caption below instead of above for tables — ACL style puts captions **above** tables
6. Missing definition of abbreviations in the caption
