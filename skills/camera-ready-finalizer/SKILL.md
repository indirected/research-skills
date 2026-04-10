---
name: camera-ready-finalizer
description: |
  Trigger phrases: "camera ready", "finalize paper", "de-anonymize paper", "add author names",
  "prepare camera-ready version", "final paper version", "accepted paper cleanup",
  "paper was accepted what do I do", "camera-ready submission", "prepare final version",
  "remove anonymization", "add acknowledgments", "paper got accepted", "we got accepted",
  "acceptance congratulations now what", "final paper prep", "switch to final mode",
  "remove review mode", "ACL final submission", "USENIX camera ready", "CCS camera ready",
  "post-acceptance cleanup", "finalize my LaTeX", "fix paper after acceptance"
version: 1.0.0
tools: Read, Glob, Grep, Bash, Write, Edit
---

# Skill: camera-ready-finalizer

After acceptance, transition the paper from anonymous review mode to final published mode.
De-anonymize, add authors and acknowledgments, apply reviewer-mandated changes, clean up
draft artifacts, verify figures, and produce a camera-ready checklist.

**Project adaptation**: Read `project/paper-paths.md` for the main `.tex` path and
`project/venue-config.md` for page limits, submission deadlines, and venue-specific
formatting requirements. No values are hardcoded — all paths and limits come from config.

---

## Step 0: Confirm Acceptance and Gather Inputs

Before making any changes to the LaTeX source, gather all necessary information:

```
Congratulations on your acceptance!

To prepare the camera-ready version, I need:

1. **Venue and paper type**: (e.g., "ACL 2026, long paper")
2. **Final page limit**: Content pages for camera-ready version
   (ACL long: 9, ACL short: 5, CCS: 10, USENIX: 13 — or tell me if different)
3. **Author block**: For each author, provide:
   - Full name (as it should appear on the paper)
   - Affiliation (department, institution, city, country)
   - Email address (optional but common)
   - Author ordering (list in order they should appear)
4. **Acknowledgments text**: Funding agencies + grant numbers, collaborator thanks,
   compute resource acknowledgments. I will add this as \section*{Acknowledgments}.
5. **Change list**: Path to paper/reviews/[VENUE]_[YEAR]_changes.md (if it exists),
   or paste the list of changes reviewers required.
6. **arXiv posting**: Do you want to post to arXiv simultaneously? (affects some steps)
```

Store the provided information in memory for use in subsequent steps.

---

## Step 1: Locate and Read the Main LaTeX File

Read `project/paper-paths.md` to find the main .tex file path:
```python
Read("project/paper-paths.md")
```

Use `main_tex` from the config. If `project/paper-paths.md` does not exist, search:
```python
Glob("paper/latex/*.tex")
```
and ask the user which is the main file.

```python
Read("{{main_tex from project/paper-paths.md}}")
```

Identify:
- Current package option: `\usepackage[review]{...}` or `\usepackage[final]{...}`
- Location of `\title{...}` — check for placeholder text
- Location of `\author{...}` block — likely empty or placeholder in review mode
- Whether `\section*{Acknowledgments}` exists and where

Also locate all section files:
```python
Glob("{{sections_dir from project/paper-paths.md}}/*.tex")
```

---

## Step 2: Switch from Review Mode to Final Mode

Search the main .tex file for the review-mode package option:

```python
Grep(r"\\usepackage\[.*review.*\]", "{{main_tex}}")
Grep(r"\\usepackage\[.*anonymous.*\]", "{{main_tex}}")
Grep(r"\\usepackage\[.*blind.*\]", "{{main_tex}}")
```

Common patterns by venue:
- ACL/EMNLP: `\usepackage[review]{acl}` → `\usepackage[final]{acl}`
- NeurIPS: `\usepackage{neurips_2024}` (no option change, but enable author block)
- USENIX: no package option — find and remove `\begin{anon}...\end{anon}` blocks
- IEEE: `\IEEEoverridecommandlockouts` controls some review options

Ask the user if the venue template isn't recognized. Once identified, apply the switch using
Edit, then verify the change with Grep.

The effect of switching to final mode:
- Removes the line ruler (numbering in the margin)
- Enables the author block to appear
- Removes the "Anonymous" placeholder header

---

## Step 3: Add Author Block

Locate the `\author{...}` block in the main .tex file (from `project/paper-paths.md`).
It will be empty, commented out, or contain a placeholder like `\author{Anonymous submission}`.

Replace with the real author block. For ACL format:

**Single author from one institution:**
```latex
\author{First Last \\
  Department of Computer Science \\
  University Name \\
  City, Country \\
  \texttt{email@institution.edu}}
```

**Multiple authors, different institutions (use \And):**
```latex
\author{Author One \\
  Affiliation One \\
  City, Country \\
  \texttt{email1@inst1.edu} \And
  Author Two \\
  Affiliation Two \\
  City, Country \\
  \texttt{email2@inst2.edu} \And
  Author Three \\
  Affiliation Three \\
  City, Country \\
  \texttt{email3@inst3.edu}}
```

**Multiple authors, some sharing affiliation (use \And and footnote marks):**
```latex
\author{Author One$^\dagger$ \And Author Two$^\dagger$ \And Author Three$^\ddagger$ \\
  $^\dagger$Institution One, City, Country \\
  $^\ddagger$Institution Two, City, Country}
```

Use Edit to replace the old author block. Confirm the replacement is correct.

### Author Order Note
The corresponding author (usually the PhD student doing the work, or the PI) is typically
listed first. ACL has no explicit "corresponding author" markup — the first author is
conventionally the point of contact. Add `*` notation and a footnote if needed:
```latex
\author{First Author$^*$ \And Second Author ...}
...
\footnotetext{$^*$ Corresponding author.}
```

---

## Step 4: Add Acknowledgments Section

The Acknowledgments section must appear:
- **After** the Conclusion section
- **Before** the References / Bibliography
- Does NOT count toward the page limit in ACL/EMNLP (it goes in the "free" overflow area)

Find the location in the .tex file just before `\bibliography{...}` or `\section{Conclusion}`:

```latex
\section*{Acknowledgments}

[ACKNOWLEDGMENTS TEXT]

```

Insert the user-provided acknowledgments text. Common elements to include:
- Funding: "This work was supported by [Agency] under grant [number]."
- Compute: "Experiments were conducted on [cluster name] provided by [institution]."
- Collaborators: "We thank [Name] for [contribution]."
- Anonymous reviewers: "We thank the anonymous reviewers for their helpful feedback."

Do NOT include acknowledgments in review-mode papers. The `final` option in `acl.sty` is
what makes the section appear in the output; adding it in `review` mode would be a
deanonymization error.

---

## Step 5: Apply Reviewer-Required Changes

Load the change list:
```python
Read("paper/reviews/[VENUE]_[YEAR]_changes.md")
```

Work through all items marked "MUST-FIX" and "SHOULD-FIX":

For each change:
1. Identify the target section file or location in `acl_latex.tex`
2. Read the current text
3. Apply the change using Edit
4. Mark the item as complete in the change list (update the `- [ ]` to `- [x]`)

### Common Camera-Ready Changes

**Factual corrections:** Edit the exact line indicated. Verify the correction is consistent
with all tables and figures that reference the same claim.

**Adding citations:** 
- Add the new citation to `paper/latex/custom.bib`
- Insert `\citep{key}` or `\citet{key}` at the appropriate location in the text
- BibTeX format to add:
  ```bibtex
  @inproceedings{Author2024,
    author    = {First Author and Second Author},
    title     = {Paper Title},
    booktitle = {Proceedings of the Conference},
    year      = {2024},
  }
  ```

**Adding experiment results:** Insert results into existing tables. Verify LaTeX table
alignment is preserved (use spaces to align columns in the source).

**Expanding sections:** Add text using Edit. After adding, check that page count is still
within the final limit (see Step 8).

---

## Step 6: Remove Draft Artifacts

Search for and remove all draft-mode markers:

```python
Grep(r"\\?%\s*TODO", "paper/latex/", ignore_case=True)
Grep(r"\\textit\{\[Placeholder", "paper/latex/")
Grep(r"\\textbf\{TODO\}", "paper/latex/")
Grep(r"FIXME|HACK|XXX", "paper/latex/")
Grep(r"\?\?\?", "paper/latex/")      # common placeholder for unknown citations
Grep(r"\[REF\]|\[CITE\]", "paper/latex/")
Grep(r"\\todo\{", "paper/latex/")    # if \usepackage{todonotes} was used
```

For each hit:
- If it's a resolved TODO (work was done): delete the comment
- If it's an unresolved TODO: flag it for the user to address
- If it's a placeholder citation (\cite{???}): ask the user for the correct reference

Also remove:
```python
Grep(r"\\usepackage\{todonotes\}", "paper/latex/")   # remove the todonotes package itself
Grep(r"\\usepackage\{soul\}", "paper/latex/")        # sometimes used for draft comments
```

---

## Step 7: Verify Figure Quality

```python
Glob("paper/figures/**/*.png")
Glob("paper/figures/**/*.jpg")
Glob("paper/figures/**/*.jpeg")
Glob("paper/figures/**/*.pdf")
Glob("paper/figures/**/*.eps")
```

For each PNG file, check resolution:
```bash
identify -verbose paper/figures/FILENAME.png 2>/dev/null | grep -E "Resolution|Geometry|Print size"
# Alternative if ImageMagick not available:
file paper/figures/*.png
python3 -c "from PIL import Image; img = Image.open('paper/figures/FILENAME.png'); print(img.size, img.info.get('dpi', 'no dpi info'))"
```

Flag any PNG with:
- DPI < 300: WARNING — likely to appear blurry in print
- DPI < 150: FAIL — will definitely appear low quality

For any flagged PNGs:
```
FIGURE WARNING: paper/figures/[filename].png
  Resolution: [N] DPI (below 300 DPI threshold for print quality)
  Recommendation: Re-export this figure as PDF or increase rasterization DPI.
  Command to convert: convert -density 300 figure.png figure_300dpi.png
  Better: export directly to PDF from your plotting library (matplotlib: plt.savefig('fig.pdf'))
```

Also verify every figure referenced in the LaTeX is present on disk:
```python
Grep(r"\\includegraphics(\[.*?\])?\{([^}]+)\}", "paper/latex/")
# For each path found, check if the file exists
```

---

## Step 8: Compile and Verify Page Count

Read `project/paper-paths.md` to get `main_tex` (e.g., `paper/latex/acl_latex.tex`).
Derive `LATEX_DIR` (the directory containing `main_tex`) and `MAIN_BASE` (the filename
without extension). Then run a full LaTeX build:

```bash
# Substitute LATEX_DIR and MAIN_BASE from project/paper-paths.md
cd LATEX_DIR && \
pdflatex MAIN_BASE.tex && \
bibtex MAIN_BASE && \
pdflatex MAIN_BASE.tex && \
pdflatex MAIN_BASE.tex 2>&1 | tail -20
```

Check for:
1. Build errors (LaTeX errors in stdout) — fix before proceeding
2. Undefined citation warnings — fix by adding bibtex entries
3. Overfull hbox warnings — note for optional manual fixing
4. Final page count:
   ```bash
   pdfinfo LATEX_DIR/MAIN_BASE.pdf | grep Pages
   ```

Read `project/venue-config.md` (if it exists) to get the camera-ready page limit for the
target venue. If the file doesn't exist, use the limit provided by the user in Step 0.
Common defaults (only use if no config and user didn't specify):
- ACL long: 9 content pages + unlimited references + acknowledgments overflow
- ACL short: 5 content pages
- CCS: 10 content + 5 references
- USENIX Security: 13 pages total

If over the final limit, list the MUST-FIX overage before proceeding to checklist generation.

### Checking Which Pages Are "Content"

For ACL: content pages end before `\bibliography{...}`. Pages containing only references
do not count toward the limit. Acknowledgments do not count. Ethical Considerations and
Limitations do not count. Appendices do not count.

To verify what page the references start on, look at the compiled PDF visually or search
the .aux file for the bibliography page number.

---

## Step 9: Generate Camera-Ready Checklist

Write to `paper/submission/[VENUE]_[YEAR]/camera_ready_checklist.md`:

```markdown
# Camera-Ready Checklist: [VENUE] [YEAR]

Date generated: [DATE]
Paper title: [TITLE]
Authors: [AUTHOR LIST]

---

## Mode Switch
- [x] Changed \usepackage[review]{acl} → \usepackage[final]{acl}

## Author Information
- [x] Author block added: [N] authors from [M] institutions
- [ ] Verify author names exactly match accepted submission metadata in submission system

## Acknowledgments
- [x] Acknowledgments section added (before references)
- [ ] Verify all funding sources and grant numbers are correct

## Reviewer Changes Applied
- [x] MUST-FIX items from paper/reviews/[VENUE]_[YEAR]_changes.md:
  - [list each item]
- [x] SHOULD-FIX items applied:
  - [list each item]

## Draft Artifact Removal
- [x] No TODO comments remaining
- [x] No placeholder text remaining
- [x] todonotes package removed (if applicable)

## Figure Quality
- [x] All figures are PDF or high-resolution PNG (≥300 DPI)
- [ ] Items needing attention: [list any warnings]

## Build Verification
- [x] LaTeX compiles without errors
- [x] No undefined citations
- [x] Final page count: [N] pages (limit: [L] pages) — PASS/FAIL

---

## Submission Steps

1. [ ] git add -p && git commit -m "camera-ready: [VENUE] [YEAR]"
2. [ ] git push origin main  (syncs with Overleaf if configured as remote)
3. [ ] On Overleaf: verify the push was received, compile once, download PDF
4. [ ] Upload camera-ready PDF to [submission system] (e.g., START, OpenReview, HotCRP)
5. [ ] Fill in any updated metadata fields (title, abstract, author order, keywords)
6. [ ] Submit by camera-ready deadline: [DEADLINE]

---

## Post-Submission

- [ ] Post to arXiv (if desired): update arXiv version with final text (must match published version)
- [ ] Post to lab website / Twitter / Bluesky with paper link
- [ ] Add to lab publication list
- [ ] Check with publisher re: open access options
```

---

## Step 10: Final Reminder to User

```
Camera-Ready Preparation Complete
===================================
Output: paper/submission/[VENUE]_[YEAR]/camera_ready_checklist.md

Changes made to [main_tex from project/paper-paths.md]:
  - Switched package option from review/anonymous to final mode
  - Added author block ([N] authors)
  - Added Acknowledgments section
  - Applied [N] reviewer-required changes
  - Removed [N] draft markers

Final page count: [N] / [L] allowed — [PASS/FAIL]

Next steps:
  1. git push to Overleaf (or compile locally and upload PDF)
  2. Upload PDF to [SYSTEM] before camera-ready deadline
  3. Double-check author list matches what was registered in the submission system

If page count fails: [specific recommendation for cuts]
```

---

## Reference Files

- `references/acl-style-rules.md` — ACL formatting rules; key final-mode requirements

---

## Error Handling

- If `\usepackage[review]{acl}` is not found: check if paper uses a different package or
  template; ask user to identify the correct line
- If LaTeX build fails after changes: show the error message and revert the last Edit if
  necessary
- If page count exceeds limit after applying reviewer changes: list the largest contributors
  to page bloat (long tables, wide figures) and suggest options (move to appendix, reduce
  whitespace, trim prose)
- If an author's affiliation is unclear: ask before writing it — incorrect affiliations
  are printed in the proceedings and cannot be changed after submission
