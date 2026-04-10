# ACL Formatting Style Rules — latex-compile-and-check Reference

This file contains all ACL formatting requirements needed by the latex-compile-and-check skill.
Authoritative source: `paper/formatting.md` and the ACL style guide at
https://acl-org.github.io/ACLPUB/formatting.html

---

## 1. Paper Length Limits

| Paper type   | Mode    | Content pages | Other pages |
|--------------|---------|--------------|-------------|
| Long paper   | Review  | 8            | + unlimited references |
| Long paper   | Final   | 9            | + acknowledgments + unlimited references |
| Short paper  | Review  | 4            | + unlimited references |
| Short paper  | Final   | 5            | + acknowledgments + unlimited references |

Rules:
- All figures and tables in the main text count toward the content page limit.
- Appendices and supplementary material do NOT count toward the page limit.
- The References section does NOT count toward the page limit.
- The Acknowledgments section does NOT count toward the page limit (final version only).
- Papers that exceed the page limit may be rejected without review.

---

## 2. Submission Mode Flags

Controlled by the option in `\usepackage[MODE]{acl}`:

| Flag | Effect |
|------|--------|
| `[review]` | Anonymous; adds line numbers (ruler); adds page numbers; hides \author block |
| `[final]` | Non-anonymous; no line numbers; no page numbers |
| `[preprint]` | Non-anonymous; adds page numbers; intended for arXiv/non-archival posting |
| (no flag) | Equivalent to `[final]` |

**The key file is `paper/latex/acl_latex.tex`.** Search for `\usepackage` on line ~5
to determine the current mode.

---

## 3. Anonymization Requirements (Review Mode)

When `[review]` is active, the following MUST be true:

### What the ACL style file handles automatically:
- Suppresses the `\author{...}` block from the rendered PDF.

### What YOU must verify manually:

**Author identity in body text:**
- Author names must not appear in the paper body.
- Lab/institution names must not appear in the paper body.
- Do not write "our lab [LabName]" or "our system [SystemName] (AuthorName et al., 2024)".
- Instead write "the system [SystemName] (AuthorName et al., 2024)" — third person.

**Acknowledgments:**
- The `\section*{Acknowledgments}` or `\section*{Acknowledgement}` block must be absent.
- The ACL `[review]` option does NOT automatically suppress acknowledgments you write.
- You must manually remove or comment out the acknowledgments section.

**Self-citations:**
- Do NOT use "Anonymous (YEAR)" style — ACL says to write in third person, not Anonymous.
- Correct: "As shown in AuthorName et al. (2024)..." (treating self as third party)
- Wrong: "(Anonymous, 2024) showed..."

**URLs:**
- Personal website URLs must be removed.
- GitHub/GitLab URLs with usernames must be removed or anonymized (use placeholders).
- Institutional URLs that reveal affiliation must be removed.
- It is OK to reference code as "available upon acceptance" rather than a live URL.

**Supplementary material:**
- If submitting supplementary material, it must also follow anonymization rules.
- Supplementary must not include author names, lab names, or identifying URLs.

---

## 4. Paper Size and File Format

- Format: **PDF** only.
- Paper size: **A4** (21 cm × 29.7 cm). NOT US Letter.
  - This is the most common mistake by authors based in North America.
  - In pdflatex, A4 is set by the ACL style file automatically.
  - If using a local TeX installation configured for Letter by default, verify with:
    `pdfinfo acl_latex.pdf | grep 'Page size'` → should show "595.28 x 841.89 pts (A4)"
- All fonts must be embedded in the PDF.
  - Check with: `pdffonts acl_latex.pdf` — all entries should show "yes" in the "emb" column.
  - Font embedding issues often arise with Type 3 fonts from figures.

---

## 5. Layout Dimensions

```
Margins:        Left: 2.5 cm, Right: 2.5 cm, Top: 2.5 cm, Bottom: 2.5 cm
Column width:   7.7 cm
Column height:  24.7 cm
Column gap:     0.6 cm
Layout:         Two-column throughout main body
```

Full-width content (using `figure*`, `table*`) spans both columns.
Title, author block, and abstract span the full width at the top of page 1.

---

## 6. Fonts

| Text element       | Size  | Style  | How to achieve |
|--------------------|-------|--------|----------------|
| Paper title        | 15 pt | Bold   | automatic via `\maketitle` |
| Author names       | 12 pt | Bold   | automatic via `\maketitle` |
| Author affiliation | 12 pt | Normal | automatic via `\maketitle` |
| "Abstract" heading | 12 pt | Bold   | automatic via `abstract` env |
| Section titles     | 12 pt | Bold   | automatic via `\section` |
| Subsection titles  | 11 pt | Bold   | automatic via `\subsection` |
| Body text          | 11 pt | Normal | `\documentclass[11pt]{article}` |
| Captions           | 10 pt | Normal | automatic via `\caption` |
| Abstract text      | 10 pt | Normal | automatic via `abstract` env |
| Bibliography       | 10 pt | Normal | automatic |
| Footnotes          | 9 pt  | Normal | automatic via `\footnote` |

Font family: **Times Roman** via `\usepackage{times}`.
Alternatives: Times New Roman, Computer Modern Roman.
Non-Latin scripts and math may use appropriate fonts.

**Do NOT** manually override font sizes with `\small`, `\footnotesize`, `\scriptsize` in
the main text or in table cells — this is used to circumvent page limits and reviewers
will notice.

---

## 7. Tables

ACL convention: use the `booktabs` package.

```latex
\usepackage{booktabs}  % in preamble

\begin{table}[t]
\centering
\small
\caption{Caption goes ABOVE the table body (for tables) or BELOW (for figures).
  Actually: ACL says captions below figures/tables. Use below for both.}
\label{tab:results-main}
\begin{tabular}{lcc}
\toprule
\textbf{Column A} & \textbf{Column B} & \textbf{Column C} \\
\midrule
Row 1 data        & 0.85              & 0.72              \\
Row 2 data        & 0.91              & 0.80              \\
\bottomrule
\end{tabular}
\end{table}
```

Rules:
- `\toprule` at the top, `\midrule` between header and data, `\bottomrule` at the bottom.
- NEVER use `\hline` in a booktabs-style table.
- Bold the best result per column: `\textbf{0.91}`.
- Use `\dag` for statistical significance markers.
- Caption placement: ACL places captions **below** both figures and tables.
  (Note: some older ACL guidance said tables above; current style is below for all.)
- Add `\centering` inside the `table` environment.

---

## 8. Figures

```latex
\begin{figure}[t]
  \includegraphics[width=\columnwidth]{figures/my_figure}
  \caption{Caption below the figure. One-line captions are centered;
    multi-line captions are left-aligned.}
  \label{fig:my-figure}
\end{figure}
```

Rules:
- Include via `\usepackage{graphicx}`.
- Width: `\columnwidth` for single-column figures, `\linewidth` for `figure*`.
- Prefer PDF or EPS figures (vector graphics). PNG at 300 dpi is acceptable.
- Grayscale readability: don't rely solely on color for critical distinctions.
- Hyperlinks in the figure: dark blue (#000099), not underlined.

---

## 9. Citation Style

The ACL style uses natbib. Key commands:

| Command | Output | Usage |
|---------|--------|-------|
| `\citet{key}` | AuthorName (2024) | Inline author citation |
| `\citep{key}` | (AuthorName, 2024) | Parenthetical citation |
| `\citealp{key}` | AuthorName, 2024 | Citation without outer parens |
| `\citeposs{key}` | AuthorName's (2024) | Possessive citation |
| `\citeyearpar{key}` | (2024) | Year only |

Multiple citations: `\citep{key1,key2}` → "(AuthorA, 2024; AuthorB, 2023)"

Wrong patterns to flag:
- `(AuthorName, 2024) showed that...` — citation as sentence subject
- `In (AuthorName, 2024), we see...` — citation as prepositional object

Bibliography requirements:
- All references must include DOIs when available.
- ACL Anthology papers: include the ACL Anthology URL or DOI.
- BibTeX entries: use LaTeX escape sequences for special characters (no raw Unicode).
- Bibliography file: `custom.bib` (local), optionally `anthology.bib` (ACL Anthology).

---

## 10. Abstract

- Maximum length: **200 words** (firm limit).
- Width: 0.6 cm narrower than column width on each side (handled by ACL style).
- The word "Abstract" is centered, 12 pt bold, above the abstract text.
- Abstract text: 10 pt, single-spaced.

---

## 11. Structure Requirements

Mandatory sections for ACL papers:
- **Limitations** section (unnumbered, `\section*{Limitations}`) — required since ACL 2022.
- **Ethics Statement** (optional but encouraged) — unnumbered.
- **Acknowledgments** (final version only, before references).
- **References** (before appendices, unnumbered).

Appendices come after references and are lettered (A, B, ...).

---

## 12. Common Pre-Submission Mistakes

1. **Paper size**: A4 required, not US Letter.
2. **Page overflow**: Content exceeds 8-page limit (review) or 9-page limit (final).
3. **Anonymous acknowledgments**: Acknowledgments section left in during review submission.
4. **\hline in tables**: Should use booktabs (`\toprule`, `\midrule`, `\bottomrule`).
5. **Undefined citations**: `\cite{key}` with key missing from all `.bib` files.
6. **Undefined cross-references**: `\ref{label}` with no matching `\label{label}`.
7. **Missing Limitations section**: Required for all ACL submissions since 2022.
8. **Font not embedded**: PDF generated without embedding all fonts.
9. **Manual spacing hacks**: `\vspace{-0.5em}` to squeeze content — disallowed.
10. **Anonymous URL in review mode**: GitHub URL with username or lab domain.
