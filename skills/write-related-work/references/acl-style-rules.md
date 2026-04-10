# ACL Style Rules — Quick Reference for Paper Writing

This file summarizes the official ACL formatting instructions for use by paper-writing skills.
Source: `/workspace/storage/CodeVul/paper/formatting.md` (the authoritative document).

---

## 1. Paper Length

| Paper type    | Review version | Final version |
|---------------|---------------|--------------|
| Long paper    | 8 pages content + unlimited references | 9 pages + acknowledgments + references |
| Short paper   | 4 pages content + unlimited references | 5 pages + acknowledgments + references |

- Figures and tables in the main text count toward the page limit.
- Appendices and supplementary material do NOT count toward the page limit.
- Review versions must be self-contained; reviewers are not required to read appendices.

---

## 2. Anonymization (Review Mode)

**Check**: Look for `\usepackage[review]{acl}` in `acl_latex.tex`. If present, the paper is in review mode and ALL of the following apply.

### What must be removed or hidden in review mode:
- All author names and affiliations (the `\author{...}` block should be omitted or contain placeholders).
- All lab/institution names in the body text.
- Acknowledgments section must be completely omitted.
- Self-references that reveal identity. Do NOT write "In our previous work (AuthorName, 2024)..." or "We built on our prior system [LabName]...". Instead write "In prior work (AuthorName, 2024)..." treating yourself as third party.
- URLs pointing to personal/lab repositories or websites.
- Preliminary versions of the same work listed in submission form are NOT cited in the review paper.

### Correct citation style in review mode (and final mode):
- Inline: `\citet{key}` → "AuthorName (2024) showed that..."
- Parenthetical: `\citep{key}` → "...as shown in prior work (AuthorName, 2024)."
- Do NOT write: "(AuthorName, 2024) showed that..." (citation as sentence subject — wrong)
- Do NOT write: "In (AuthorName, 2024), ..." (citation as prepositional object — wrong)
- Multi-author: two authors → "Aho and Ullman (1972)"; three or more → "Chandra et al. (1981)"
- Multiple citations collapsed: `\citep{key1,key2}` → "(AuthorName, 2024; OtherName, 2023)"

---

## 3. File Format and Paper Size

- Submission format: **PDF** with all fonts embedded.
- Paper size: **A4** (21 cm × 29.7 cm). NOT letter. This is a hard requirement.
- Compiler: pdfLaTeX strongly recommended. LuaLaTeX and XeLaTeX are acceptable.

---

## 4. Layout

- **Two-column** layout throughout the main body.
- Exceptions to two-column: title, author names/affiliations (centered at top of page 1), and full-width figures/tables using the `figure*`/`table*` environments.
- Margins: Left 2.5 cm, Right 2.5 cm, Top 2.5 cm, Bottom 2.5 cm.
- Column width: 7.7 cm; Column height: 24.7 cm; Column gap: 0.6 cm.
- Page numbers: centered in bottom margin for review versions. **No page numbers in final version**.
- Line numbers (ruler): printed in review version for reviewer comments. Absent in final version.

---

## 5. Fonts

| Text element         | Size  | Style  |
|----------------------|-------|--------|
| Paper title          | 15 pt | Bold   |
| Author names         | 12 pt | Bold   |
| Author affiliation   | 12 pt | Normal |
| "Abstract" heading   | 12 pt | Bold   |
| Section titles       | 12 pt | Bold   |
| Subsection titles    | 11 pt | Bold   |
| Body text            | 11 pt | Normal |
| Captions             | 10 pt | Normal |
| Abstract text        | 10 pt | Normal |
| Bibliography         | 10 pt | Normal |
| Footnotes            | 9 pt  | Normal |

- Font family: **Times Roman** (or Times New Roman / Computer Modern Roman if unavailable).
- Load with `\usepackage{times}` in the preamble.

---

## 6. Title and Authors

- Title: centered, 15 pt bold, title case (capitalize major words; acronyms like "BLEU" stay uppercase).
- Long titles: split across two lines with no blank line between.
- Author block: full names (not initials unless normally written as initials), affiliations, and email.
- In review version: author block is suppressed by the ACL style file automatically when `[review]` is active. You should still leave space (do not set `\setlength\titlebox` too small).

---

## 7. Abstract

- Placed at top of first column, after the title.
- The word "Abstract" is centered, 12 pt bold, above the abstract body.
- Abstract width: 0.6 cm narrower than column width on each side.
- Abstract text: 10 pt, single-spaced.
- **Maximum length: 200 words.** This is a firm limit for ACL.

---

## 8. Sections and Labels

- Use Arabic numerals: `\section`, `\subsection`, `\subsubsection`.
- Cross-references: `\label{...}` + `\ref{...}` or `\autoref{...}` (if hyperref loaded).
- Recommended label naming convention for this paper:
  - Sections: `sec:intro`, `sec:background`, `sec:methodology`, `sec:experiments`, `sec:related`, `sec:conclusion`
  - Tables: `tab:results-main`, `tab:ablation`, `tab:dataset-stats`
  - Figures: `fig:architecture`, `fig:pipeline`, `fig:results`
  - Equations: `eq:loss`, `eq:score`
  - Appendix: `app:prompts`, `app:case-study`

---

## 9. Figures and Tables

- Place near first mention in text; use `[t]` or `[h]` placement hints.
- Wide figures/tables span both columns: use `figure*` / `table*`.
- Grayscale readability strongly encouraged (color-blind accessibility).
- Captions: below the figure/table, 10 pt. One-line captions are centered; multi-line captions are left-aligned.
- Caption format: "Figure 1: Description." and "Table 1: Description."
- **Do not override default caption sizes.**
- For tables: use `booktabs` package (`\toprule`, `\midrule`, `\bottomrule`) — ACL convention.
  - Load with: `\usepackage{booktabs}`
  - Never use `\hline` in booktabs-style tables.

---

## 10. Citations and Bibliography

- Citation style: natbib. Use `\citet{}` for inline, `\citep{}` for parenthetical.
- ACL-specific: `\citeposs{key}` for possessive ("AuthorName's (2024) approach...").
- All references must include DOIs when available; ACL Anthology papers should include ACL Anthology URLs or DOIs.
- Bibliography entry format follows American Psychological Association style.
- References section: unnumbered (`\section*{References}` or auto-generated), placed before appendices.
- References are sorted alphabetically by first author surname.
- Use `\bibliography{custom}` (never `anthology.bib.txt` — the correct file is `custom.bib`).
- To include ACL Anthology: `\bibliography{anthology,custom}`.
- BibTeX entries: use LaTeX escape sequences for special characters (no raw Unicode in .bib files).

---

## 11. Acknowledgments

- Goes immediately before the references section.
- **Do NOT include in review version** (the `[review]` option in `\usepackage[review]{acl}` suppresses it automatically, but you must also not write it manually).
- Not numbered.

---

## 12. Footnotes

- Use `\footnote{...}`. Placed at bottom of page. 9 pt font.
- Separated from text by a horizontal rule (handled automatically by LaTeX).

---

## 13. Hyperlinks

- Color: dark blue, hex `#000099`.
- Not underlined or boxed.
- Handled via `hyperref` package (included by the ACL style file).

---

## 14. Equations

- Use `\begin{equation}...\end{equation}` for numbered equations.
- Label: `\label{eq:name}`, cross-reference: `\autoref{eq:name}` or `Equation~\ref{eq:name}`.

---

## 15. Appendices

- Use `\appendix` before the first appendix section.
- Lettered: "Appendix A. Title", "Appendix B. Title".
- Come **after** the References section.
- In review versions, appendices must follow the same anonymity guidelines as the main paper.

---

## 16. Common LaTeX Pitfalls to Avoid

- Do NOT use `\vspace`, `\vskip`, or manual spacing hacks to squeeze content. Papers that artificially compress spacing may be rejected.
- Do NOT use smaller fonts than specified (e.g., 10 pt body text) to fit more content.
- Do NOT use `\footnotesize` or `\scriptsize` in table cells to bypass page limits.
- Paragraph indentation: 0.4 cm for all paragraphs except the first in a section.
- For algorithm pseudocode, use `algorithm2e` or `algorithmicx`; never use verbatim for pseudocode.
- Check that all `\cite{}` keys exist in `custom.bib` before compiling.
