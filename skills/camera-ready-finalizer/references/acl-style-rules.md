# ACL Style Rules — Camera-Ready Quick Reference

Authoritative source: `/workspace/storage/CodeVul/paper/formatting.md` and the official
ACL style guide at https://acl-org.github.io/ACLPUB/formatting.html

This file focuses specifically on rules that differ between **review mode** and **final mode**,
and the additional requirements that only apply to camera-ready submissions.

---

## 1. Package Option Switch

| Mode | LaTeX command | Effect |
|------|--------------|--------|
| Review (submission) | `\usepackage[review]{acl}` | Adds line numbers, hides author block, shows "Anonymous" |
| Final (camera-ready) | `\usepackage[final]{acl}` | Removes line numbers, shows author block, shows paper title |
| Preprint (arXiv) | `\usepackage[preprint]{acl}` | Shows authors, adds page numbers, no conference header |

Always use `final` for the camera-ready submission to the publisher.
Use `preprint` if uploading to arXiv (it removes the ACL-specific conference header and adds page numbers for standalone reading).

---

## 2. Page Limits (Final / Camera-Ready)

| Paper type | Content pages | Acknowledgments | Limitations | Ethical Considerations | References | Appendix |
|-----------|-------------|----------------|-------------|----------------------|------------|---------|
| Long paper | **9** | Does not count | Does not count | Does not count | Does not count | Does not count |
| Short paper | **5** | Does not count | Does not count | Does not count | Does not count | Does not count |
| Findings paper | Same as long/short parent type | Same | Same | Same | Same | Same |

**Key rule:** In the camera-ready, the content limit is **one page more** than the review limit (8→9 for long, 4→5 for short). This extra page is for incorporating reviewer feedback.

The "does not count" sections must still appear **in the same PDF**, just after the content. They go in this order:
1. Limitations (if present)
2. Ethical Considerations (if present)  
3. Acknowledgments
4. References
5. Appendix / Supplementary Material

---

## 3. Author Block Format

The `\author{...}` command is the only mechanism for specifying authors. ACL does not use separate `\affiliation` or `\institution` commands. Example:

```latex
\author{Alice Smith \\
  Department of Computer Science \\
  MIT \\
  Cambridge, MA, USA \\
  \texttt{asmith@mit.edu} \And
  Bob Jones \\
  Google DeepMind \\
  London, UK \\
  \texttt{bjones@google.com}}
```

Rules:
- Use `\And` (capital A, capital A) between authors from different institutions
- Use `\and` (lowercase) within an institution group (rarely needed)
- Use `\AND` (all caps) to force a line break between author groups
- Email addresses are optional but standard
- Use `\texttt{}` for email addresses (typewriter font)
- Do NOT use `\footnote{}` for additional author notes in the author block — use a `\footnotetext{}` after `\maketitle`

---

## 4. Acknowledgments Section

Must appear as an unnumbered section just before the bibliography:

```latex
\section*{Acknowledgments}

This work was supported by the National Science Foundation under award XXX-XXXXXXX.
We thank the reviewers for their helpful comments.
Experiments were run on the [cluster name] cluster at [institution].

\bibliography{custom}
```

Notes:
- Must be `\section*` (star = unnumbered)
- Does NOT appear in the table of contents
- Does NOT count toward the page limit
- Should NOT appear in review-mode submissions (anonymization violation)
- Must include grant numbers if funding was received — this is a requirement of most funding agencies

---

## 5. Line Numbers

The `review` mode adds line numbers automatically. The `final` mode removes them.
Do NOT add line numbers manually with any package (e.g., `lineno`) in the final version.

---

## 6. Fonts and Typography

| Requirement | Specification |
|-------------|--------------|
| Main body font | Times New Roman (11pt, set by template) |
| Math font | Standard LaTeX math (Computer Modern math is OK) |
| Code/URLs | `\texttt{}` or `\url{}` — Courier/inconsolata |
| Do NOT use | Arial, Helvetica, or other sans-serif for body text |

The ACL template loads `\usepackage{times}` automatically. Do not override the font.

---

## 7. Figures and Tables

- All figures must have captions below the figure.
- All tables must have captions above the table.
- Caption format: "Figure N: Description." — capitalize "Figure" and "Table".
- Use `\caption{...}` inside `figure` and `table` environments.
- Preferred figure formats: **PDF** (vector, scales perfectly), EPS (vector), PNG at ≥300 DPI.
- Do NOT use GIF, BMP, or TIFF formats.
- All text in figures must be readable at the printed paper size (≥7pt equivalent).
- Figures should be described in the text before they appear (forward reference is acceptable).

---

## 8. Citations and Bibliography

ACL uses **natbib** for citations. Do NOT use `\cite{}` — use:
- `\citep{key}` — parenthetical: "(Smith, 2024)"
- `\citet{key}` — textual: "Smith (2024)"
- `\citep[p.~5]{key}` — with page number: "(Smith, 2024, p. 5)"
- `\citep{key1,key2}` — multiple: "(Smith, 2024; Jones, 2023)"

The ACL anthology provides .bib entries at https://aclanthology.org/ — use these
for any paper published at ACL venues; they are authoritative.

Do NOT change the bibliography style file (acl_natbib.bst). Use `custom.bib` for all
references and let the style file format them.

---

## 9. Required Sections in Camera-Ready

| Section | Required? | Notes |
|---------|----------|-------|
| Abstract | Yes | ≤200 words recommended |
| Introduction | Yes | |
| Related Work | Yes (or integrated) | May be merged into intro for short papers |
| Methodology | Yes | |
| Experiments / Evaluation | Yes | |
| Results | Yes (may be merged with Experiments) | |
| Conclusion | Yes | |
| **Limitations** | **Yes** | Required since ACL 2023; does not count toward page limit |
| Ethical Considerations | Strongly recommended | Required checklist was submitted; section optional in PDF |
| Acknowledgments | Yes (if any funding) | Required by funders; does not count toward page limit |
| References | Yes | |

---

## 10. Checklist for Final Submission

- [ ] `\usepackage[final]{acl}` is set
- [ ] Author block is complete and correct
- [ ] Affiliations match what was entered in the submission system
- [ ] Acknowledgments section is present
- [ ] Grant numbers are exact (check with PI)
- [ ] Limitations section is present
- [ ] No TODO comments, placeholders, or draft markers remain
- [ ] `pdflatex` build completes without errors
- [ ] No undefined citations (bibtex ran successfully)
- [ ] Page count ≤ final limit
- [ ] All figures are high-resolution PDF or PNG ≥ 300 DPI
- [ ] PDF file size is reasonable (< 20 MB; check if large PNG figures are embedded)
- [ ] git committed and pushed to Overleaf
- [ ] PDF downloaded from Overleaf or local build and verified visually
- [ ] Uploaded to submission system before camera-ready deadline
