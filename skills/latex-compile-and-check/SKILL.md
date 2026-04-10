---
name: latex-compile-and-check
description: |
  Use this skill whenever the user wants to compile the paper, check for LaTeX errors,
  verify the PDF builds correctly, or run a pre-submission check. Trigger on phrases like:
  "compile the paper", "check paper formatting", "verify latex", "pre-submission check",
  "check for latex errors", "does the paper compile", "check anonymization",
  "check page count", "build the pdf", "run pdflatex", "latex errors",
  "is the paper ready to submit", "check the pdf", "run a build check",
  "make sure the paper compiles", "verify all citations resolve",
  "check for undefined references", "check for overfull hboxes",
  "is the anonymization correct", "verify the paper is under the page limit",
  "run latex on the paper", "check for missing figures".
  Use proactively before any paper submission deadline or when results/sections are updated.
version: 1.0.0
tools: Read, Glob, Grep, Bash, Write, Edit
---

# LaTeX Compile and Check

This skill compiles the paper from source, parses the build log for errors and warnings,
verifies page count against the venue limit, checks anonymization, validates all citations
and cross-references, and produces a dated pre-submission checklist.

**Project adaptation**: Reads `project/paper-paths.md` for the main `.tex` path and
`project/venue-config.md` for page limits. All derived shell variables (`LATEX_DIR`,
`MAIN_BASE`) come from `main_tex` in the config — no values are hardcoded.

**Important**: The paper lives in `paper/` which is a git submodule pointing to Overleaf.
After any changes, remind the user to run `git push` from within the `paper/` directory
to sync with Overleaf.

---

## Output Locations

| Output | Path |
|---|---|
| Compiled PDF | `${LATEX_DIR}/${MAIN_BASE}.pdf` (derived from `project/paper-paths.md`) |
| Build log | `${LATEX_DIR}/${MAIN_BASE}.log` |
| Pre-submission checklist | `paper/submission_checklist_YYYYMMDD.md` |

---

## Step 1: Check LaTeX Engine Availability

Before compiling, verify that a LaTeX engine is available:

```bash
which pdflatex || which latexmk || which xelatex
```

If `pdflatex` is available, use it (most venues recommend pdflatex).
If only `latexmk` is available, use: `latexmk -pdf -interaction=nonstopmode ${MAIN_BASE}.tex`
(substitute MAIN_BASE from `project/paper-paths.md` — see Step 3)
If only `xelatex` is available, use it but note xelatex output may differ slightly.

If no LaTeX engine is found, report:
> "No LaTeX engine found. Please install TeX Live: `sudo apt-get install texlive-full`
> or on macOS: install MacTeX from https://www.tug.org/mactex/"

Also check for required helper tools:
```bash
which bibtex && which pdfinfo || which pdftotext
```

Note missing tools but proceed with what is available.

---

## Step 2: Locate the Paper Files

Read `project/paper-paths.md` to find the LaTeX file paths:
```python
Read("project/paper-paths.md")
```

Use `main_tex`, `bibliography`, `sections_dir`, and `figures_dir` from the config.
If `project/paper-paths.md` does not exist, search:
```
Glob: paper/latex/*.tex
```
and ask the user which is the main file.

Verify the main file and related files exist:
```
Glob: {{main_tex}}
Glob: {{bibliography}}
Glob: {{sections_dir}}/*.tex
Glob: paper/tables/*.tex
Glob: {{figures_dir}}/*.pdf
Glob: {{figures_dir}}/*.png
```

Note all `.tex` input files — these will be scanned for anonymization and cross-reference checks.

Check which bibliography files are referenced:
```
Grep: pattern=\\bibliography{, path={{main_tex}}
```

---

## Step 3: Compile the Paper

Navigate to the LaTeX directory (parent of `main_tex`) and run the full compile sequence.
Derive `LATEX_DIR` and `MAIN_BASE` from `main_tex` in `project/paper-paths.md`.

```bash
LATEX_DIR="$(dirname {{main_tex}})"
MAIN_BASE="$(basename {{main_tex}} .tex)"

cd "${LATEX_DIR}" && \
  pdflatex -interaction=nonstopmode "${MAIN_BASE}.tex" 2>&1 | tail -20
```

Then run BibTeX to resolve citations:

```bash
cd "${LATEX_DIR}" && bibtex "${MAIN_BASE}" 2>&1
```

Then run pdflatex twice more to resolve cross-references:

```bash
cd "${LATEX_DIR}" && \
  pdflatex -interaction=nonstopmode "${MAIN_BASE}.tex" 2>&1 | tail -5 && \
  pdflatex -interaction=nonstopmode "${MAIN_BASE}.tex" 2>&1 | tail -5
```

**Why four passes?**
1. First pdflatex: generates `.aux` with citation keys and labels
2. bibtex: processes `.aux` → `.bbl` (resolved bibliography)
3. Second pdflatex: incorporates `.bbl`, generates forward references
4. Third pdflatex: resolves any remaining forward references and page numbers

If bibtex fails entirely (exit code non-zero), note it but continue — the PDF can still
compile with unresolved citations shown as [?].

---

## Step 4: Parse the Build Log for Errors and Warnings

Read `${LATEX_DIR}/${MAIN_BASE}.log` (paths derived from Step 3). Search for the following patterns:

### Errors (FAIL)

```
Grep: pattern=^! , path=${LATEX_DIR}/${MAIN_BASE}.log
```

Common errors and their meanings (see `references/latex-error-guide.md` for fixes):

| Log pattern | Issue |
|---|---|
| `! Undefined control sequence.` | Used a command that doesn't exist or package not loaded |
| `! Missing $ inserted.` | Math mode used outside `$...$` or vice versa |
| `! File 'foo.sty' not found.` | Required package not installed |
| `! Emergency stop.` | Fatal error — compilation aborted |
| `! LaTeX Error: File 'foo' not found.` | Missing figure or included file |

### Undefined References (WARN)

```
Grep: pattern=LaTeX Warning: Reference .* undefined, path=${LATEX_DIR}/${MAIN_BASE}.log
Grep: pattern=LaTeX Warning: Citation .* undefined, path=${LATEX_DIR}/${MAIN_BASE}.log
```

Extract the undefined reference/citation keys from these warnings. List each one.

### Overfull Hboxes (WARN — flag if > 10pt)

```
Grep: pattern=Overfull \\\\hbox \(([0-9]+), path=${LATEX_DIR}/${MAIN_BASE}.log
```

Filter for cases where the overfull amount exceeds 10pt. An overfull hbox of 0.1pt is
normal due to hyphenation; anything above 10pt is visible on the page and should be fixed.

### Missing figure files

```
Grep: pattern=File .* not found, path=${LATEX_DIR}/${MAIN_BASE}.log
```

List any figure or input files that could not be found.

### Multiply defined labels

```
Grep: pattern=multiply defined, path=${LATEX_DIR}/${MAIN_BASE}.log
```

These cause non-deterministic page numbers on different compiler runs and must be fixed.

### Font warnings

```
Grep: pattern=Font Warning, path=${LATEX_DIR}/${MAIN_BASE}.log
```

Font substitutions can cause text to render incorrectly in the final PDF.

---

## Step 5: Count Pages in the Output PDF

If pdfinfo is available:

```bash
pdfinfo "${LATEX_DIR}/${MAIN_BASE}.pdf" | grep Pages
```

If pdfinfo is not available, use pdftotext:

```bash
pdftotext "${LATEX_DIR}/${MAIN_BASE}.pdf" - | grep -c '^\f'
```

Or check the log for the page count line:

```
Grep: pattern=Output written on .*\.pdf, path=${LATEX_DIR}/${MAIN_BASE}.log
```

This line reads: `Output written on MAIN_BASE.pdf (N pages, XXXXX bytes).`

**Page limits**: Read `project/venue-config.md` (if it exists) for the submission page limit.
If not available, check `references/acl-style-rules.md` for ACL-family venues, or ask the user.
Common defaults (use only if neither file exists):
- Review mode long paper: 8 content pages + unlimited references
- Final mode long paper: 9 content pages + unlimited references
- Short paper review: 4 pages; short paper final: 5 pages

To distinguish content pages from reference pages: count pages before `\bibliography{}`
appears. As a heuristic, the last content page is typically the one before "References"
appears in the PDF text.

**Verdict:**
- Page count within limit → PASS
- Page count over limit → FAIL with count of pages to cut

---

## Step 6: Check Submission Mode (Review vs. Final)

Use `{{main_tex from project/paper-paths.md}}`:

```
Grep: pattern=\\usepackage\[review\], path={{main_tex}}
Grep: pattern=\\usepackage\[final\], path={{main_tex}}
Grep: pattern=\\usepackage\[preprint\], path={{main_tex}}
```

Report the current mode:
- `[review]`: Review submission mode — anonymization required
- `[final]` or no option: Camera-ready / final mode — author info required
- `[preprint]`: Non-anonymous preprint mode with page numbers

---

## Step 7: Anonymization Check (if in review mode)

If the paper is in `[review]` mode, scan ALL `.tex` files for identity-revealing content.

**Collect all tex files:**
```
Glob: paper/latex/*.tex
Glob: paper/sections/*.tex
Glob: paper/tables/*.tex
```

**Check for author names in body text:**

The `[review]` ACL option automatically removes the `\author{...}` block from the PDF,
but the user may accidentally include their name in the body. Check for the names that
appear in the `\author{...}` block of `acl_latex.tex` and search for them in body tex files.

Also check for common patterns:
```
Grep: pattern=\\section\*\{Acknowledgment, path=paper/, glob=**/*.tex
Grep: pattern=\\section\*\{Acknowledgments, path=paper/, glob=**/*.tex
```
Acknowledgment sections must be completely absent in review mode.

**Check for institutional URLs:**
```
Grep: pattern=\\url\{https?://, path=paper/, glob=**/*.tex
Grep: pattern=href\{https?://, path=paper/, glob=**/*.tex
```

For any URL found, report it and flag if it points to a personal or lab domain
(e.g., `github.com/{username}`, `{labname}.{university}.edu`).

**Check for self-referential citations that reveal identity:**
Look for patterns like `Anonymous` (should not appear — ACL guidance says to write
self-references in third person, not as "Anonymous"):
```
Grep: pattern=Anonymous, path=paper/, glob=**/*.tex
```

**Report:**
- PASS: No identity-revealing content found
- ISSUES FOUND: List each finding with file:line

---

## Step 8: Verify All Citation Keys

Extract all citation keys used in the paper:
```
Grep: pattern=\\cite[tp]?\{([^}]+)\}, path=paper/, glob=**/*.tex, output_mode=content
```

Also check for `\nocite{...}` entries.

Parse out each individual key (split on commas within braces).

Then check all keys exist in the bibliography files:
- `paper/latex/custom.bib`: search for `@{type}{key,`
- `paper/anthology.bib.txt`: search for `@{type}{key,`

Flag any citation key that appears in the `.tex` files but not in either `.bib` file.
These will compile as `[?]` in the PDF.

Also run the BibTeX warnings from the log:
```
Grep: pattern=I didn't find a database entry, path=${LATEX_DIR}/${MAIN_BASE}.blg
```

---

## Step 9: Verify All Cross-References

Extract all `\label{...}` definitions across all tex files:
```
Grep: pattern=\\label\{([^}]+)\}, path=paper/, glob=**/*.tex, output_mode=content
```

Extract all `\ref{...}`, `\autoref{...}`, `\pageref{...}` usages:
```
Grep: pattern=\\(?:auto)?ref\{([^}]+)\}, path=paper/, glob=**/*.tex, output_mode=content
```

Compare the two sets. Flag any `\ref{key}` where `key` does not appear in any `\label{...}`.
These will produce "undefined reference" warnings and appear as `??` in the PDF.

Also check the log for the definitive list of undefined references (Step 4 captures these).

---

## Step 10: Generate the Pre-Submission Checklist

Write `paper/submission_checklist_YYYYMMDD.md` (replace YYYYMMDD with today's date):

```markdown
# Pre-Submission Checklist — YYYY-MM-DD

## Build Status
- [ BUILD: PASS/FAIL ] LaTeX compilation completed without fatal errors
- [ BIBTEX: PASS/FAIL ] BibTeX resolved all citations

## Errors
<list each error from Step 4, or "None found">

## Warnings
### Undefined References
<list each undefined \ref{} key, or "None">

### Undefined Citations  
<list each undefined \cite{} key, or "None">

### Overfull Hboxes (>10pt)
<list each overfull hbox with line number, or "None">

### Missing Files
<list each missing figure/include, or "None">

## Page Count
- [ PAGES: PASS/FAIL ] Content pages: N (limit: [from project/venue-config.md or user input])
- Submission mode: review / final

## Anonymization
- [ ANON: PASS/ISSUES FOUND ] 
<list any identity-revealing content found, or "No issues found">

## Citations
- [ CITE: PASS/FAIL ] All N citation keys resolved

## Cross-References
- [ REFS: PASS/FAIL ] All N cross-references resolved

## Summary
**X errors, Y warnings, Z content pages, anonymization: OK/ISSUES FOUND**
```

---

## Step 11: Print Summary

After writing the checklist, print a concise summary to the user:

```
Build: PASS/FAIL
Errors: N (list briefly)
Warnings: N overfull hboxes, M undefined refs, K undefined citations
Pages: N content pages (limit: [from venue-config.md]) — PASS/FAIL
Mode: review / final
Anonymization: OK / ISSUES FOUND (list briefly)
Checklist saved to: paper/submission_checklist_YYYYMMDD.md
```

---

## Step 12: Overleaf Sync Reminder

After any run that makes changes (fixes applied, checklist written):

> **Overleaf sync required.** The `paper/` directory is a git submodule pointing to
> Overleaf. Run the following to push all changes:
>
> ```bash
> cd paper && git add -A && git commit -m "Pre-submission compile check YYYY-MM-DD" && git push
> ```
>
> Then from the parent repo:
> ```bash
> git add paper && git commit -m "Update paper submodule pointer" && git push
> ```

---

## Reference Files

- `references/acl-style-rules.md` — Full ACL formatting requirements (margins, fonts, page
  limits, anonymization rules, table/figure conventions)
- `references/latex-error-guide.md` — Common LaTeX errors with quick-fix instructions
