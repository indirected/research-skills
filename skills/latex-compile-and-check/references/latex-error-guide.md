# LaTeX Error Guide — Quick Fixes for Common Errors

This guide covers every common LaTeX error and warning encountered when compiling ACL papers.
Each entry includes the exact log pattern, the cause, and the fix.

---

## Fatal Errors (stop compilation)

### 1. Undefined Control Sequence

**Log pattern:**
```
! Undefined control sequence.
l.42 \somemacro
```

**Cause:** You used a command (`\somemacro`) that LaTeX doesn't know. Either:
- The package that defines it is not loaded.
- You misspelled the command.
- The command is defined in a newer package version.

**Fixes:**
```latex
% Check if you need to load the package:
\usepackage{booktabs}    % for \toprule, \midrule, \bottomrule
\usepackage{amsmath}     % for \mathbb, \text, \operatorname
\usepackage{graphicx}    % for \includegraphics
\usepackage{hyperref}    % for \url, \href (already in acl.sty)
\usepackage{microtype}   % for \microtypesetup

% Or check spelling: common misspellings
\textbf vs \textbold  (wrong)
\emph  vs \emp        (wrong)
\citet vs \cite       (cite syntax differs by style)
```

---

### 2. Missing $ Inserted

**Log pattern:**
```
! Missing $ inserted.
l.88 ...the value is α which represents
```

**Cause:** A math symbol (Greek letter, subscript, operator) was used outside math mode,
or math mode was opened/closed in the wrong place.

**Fixes:**
```latex
% Wrap math in $...$
the value is $\alpha$ which represents   % correct
the value is \alpha which represents     % WRONG — triggers this error

% Common symbols that MUST be in math mode:
\alpha \beta \gamma \delta \epsilon \mu \sigma \tau
\leq \geq \neq \approx \times \cdot \rightarrow \leftarrow
x_1 x^2   % subscripts/superscripts

% Subscripts in text (use \textsubscript or \texorpdfstring):
step$_1$    % in math mode
\textsubscript{1}  % in text mode (needs fixltx2e or use math mode)
```

---

### 3. File Not Found

**Log pattern:**
```
! LaTeX Error: File 'figures/pipeline' not found.
```
or
```
! LaTeX Error: File 'sections/method' not found.
```

**Cause:** An `\includegraphics{...}` or `\input{...}` references a file that doesn't exist
at the specified path.

**Fixes:**
```latex
% For figures: verify the file exists and extension is correct
% pdflatex accepts: .pdf, .png, .jpg, .eps
% Don't include the extension in \includegraphics (LaTeX searches for it):
\includegraphics{figures/pipeline}   % correct — LaTeX finds pipeline.pdf/.png/.jpg
\includegraphics{figures/pipeline.pdf}  % also works if exact

% For \input files: path is relative to the main .tex file
\input{sections/method}     % looks for sections/method.tex
\input{tables/results_main} % looks for tables/results_main.tex

% Check case sensitivity on Linux (macOS is case-insensitive):
figures/Pipeline.pdf ≠ figures/pipeline.pdf on Linux
```

Verify with:
```bash
ls paper/figures/
ls paper/sections/
ls paper/tables/
```

---

### 4. Emergency Stop

**Log pattern:**
```
! Emergency stop.
```

**Cause:** LaTeX encountered an error it could not recover from. Look at the lines
immediately before this message in the log for the triggering error.

**Fix:** Scroll up in the log to find the actual error. Emergency stop is always a
consequence of another error, not the root cause.

---

### 5. Package Not Found

**Log pattern:**
```
! LaTeX Error: File 'booktabs.sty' not found.
```

**Cause:** A required LaTeX package is not installed.

**Fix:**
```bash
# Ubuntu/Debian:
sudo apt-get install texlive-full   # installs all packages

# Or install specific package:
sudo apt-get install texlive-science     # for algorithm packages
sudo apt-get install texlive-publishers  # for ACL style files

# macOS with MacTeX: use TeX Live Utility
# Or via tlmgr:
sudo tlmgr install booktabs
sudo tlmgr install microtype
sudo tlmgr install inconsolata
```

---

## Warnings (do not stop compilation)

### 6. Undefined Reference / Citation

**Log pattern:**
```
LaTeX Warning: Reference `fig:pipeline' on page 3 undefined on input line 247.
LaTeX Warning: Citation `smith2024' on page 5 undefined on input line 312.
```

**Cause (references):** A `\ref{fig:pipeline}` or `\autoref{fig:pipeline}` exists but no
`\label{fig:pipeline}` is defined anywhere. Or the label is defined but the aux file is stale.

**Fix (references):**
```bash
# Run pdflatex twice (or three times) to resolve:
pdflatex acl_latex.tex && pdflatex acl_latex.tex

# Or check for the label:
grep -r "label{fig:pipeline}" paper/
# If not found: add \label{fig:pipeline} after \caption{} in the figure
```

**Cause (citations):** A `\cite{smith2024}` key is not in any `.bib` file referenced by
`\bibliography{...}`.

**Fix (citations):**
```bash
# Check which bib files are used:
grep bibliography paper/latex/acl_latex.tex

# Search for the key in your bib files:
grep "smith2024" paper/latex/custom.bib
grep "smith2024" paper/anthology.bib.txt

# If not found: add the entry to custom.bib
# If found but still warning: run bibtex again
cd paper/latex && bibtex acl_latex && pdflatex acl_latex.tex && pdflatex acl_latex.tex
```

---

### 7. Overfull Hbox

**Log pattern:**
```
Overfull \hbox (15.2pt too wide) in paragraph at lines 182--186.
```

**Cause:** A word, URL, or piece of math is wider than the column and sticks out into the margin.

**Severity:** Anything over 10pt is visible to reviewers and should be fixed.

**Fixes:**
```latex
% Option 1: Allow hyphenation (add soft hyphens):
algo\-rithm   % suggests a hyphenation point

% Option 2: Force line break before a long word:
% Restructure the sentence to avoid the long word at line end.

% Option 3: For URLs, use \url{} (hyperref handles breaking):
\url{https://very-long-url.example.com/path/to/thing}

% Option 4: Reduce size of code snippets:
\small
\texttt{some\_long\_function\_name\_here}

% Option 5: Use \sloppy locally (last resort — may produce ugly spacing):
{\sloppy
Text with problematic URL or term \url{https://...} here.
}

% Option 6: Add the word to the hyphenation exception list:
\hyphenation{auto-patch bench-mark}  % in preamble
```

---

### 8. Multiply Defined Label

**Log pattern:**
```
LaTeX Warning: Label `tab:results-main' multiply defined.
```

**Cause:** Two `\label{tab:results-main}` definitions exist in the document.

**Fix:**
```bash
grep -rn "label{tab:results-main}" paper/
```
Rename one of them. Multiply-defined labels cause the reference to non-deterministically
point to one of the two definitions — a subtle bug that can produce wrong page/section numbers.

---

### 9. Font Warning / Font Substitution

**Log pattern:**
```
LaTeX Font Warning: Font shape `OT1/cmr/m/n' in size <10.95> not available
LaTeX Font Warning: Some font shapes were not available, defaults substituted.
```

**Cause:** The exact font shape/size combination needed is not installed, or a figure
was embedded with a non-standard font.

**Fixes:**
```bash
# Ensure Times Roman is loaded:
\usepackage{times}   % in preamble (already in ACL template)

# For figures with font issues: regenerate the figure with fonts embedded
# In matplotlib:
import matplotlib
matplotlib.rcParams['pdf.fonttype'] = 42   # TrueType fonts
matplotlib.rcParams['ps.fonttype'] = 42

# Verify embedded fonts in the final PDF:
pdffonts paper/latex/acl_latex.pdf
# All rows should show "yes" in the "emb" column
```

---

### 10. Missing \bibitem / BibTeX Errors

**Log pattern (in acl_latex.blg):**
```
I didn't find a database entry for "smith2024"
```

**Cause:** The citation key `smith2024` is not in any `.bib` file.

**Fix:**
```bash
# Check bibtex log:
cat paper/latex/acl_latex.blg | grep "didn't find"

# Find which bib files are included:
grep bibliography paper/latex/acl_latex.tex

# Add the missing entry to custom.bib:
@inproceedings{smith2024,
  author = {Smith, John and Doe, Jane},
  title  = {Paper Title Here},
  booktitle = {Proceedings of ACL 2024},
  year   = {2024},
  doi    = {10.18653/v1/...},
  url    = {https://aclanthology.org/...}
}
```

---

### 11. Package Option Clash

**Log pattern:**
```
! LaTeX Error: Option clash for package hyperref.
```

**Cause:** A package is loaded twice with different options, or two packages both load
`hyperref` with conflicting settings.

**Fix:**
```latex
% Load hyperref LAST (or let acl.sty handle it — it loads hyperref internally)
% Don't manually load \usepackage{hyperref} — acl.sty already includes it

% If you need hyperref options:
\PassOptionsToPackage{hidelinks}{hyperref}  % before \usepackage{acl}
```

---

### 12. Lonely \item / Wrongly Placed List Command

**Log pattern:**
```
! LaTeX Error: \begin{itemize} on input line 14 ended by \end{document}.
```

**Cause:** A list environment (`itemize`, `enumerate`) was opened but never closed.

**Fix:** Match every `\begin{itemize}` with `\end{itemize}`. Use a text editor with
LaTeX environment matching (Overleaf does this automatically).

---

## BibTeX-Specific Issues

### 13. Year Field Not a Number

**Log pattern (blg):**
```
Warning--I'm ignoring jones2024's extra "year" field
```

**Fix:** BibTeX year fields must be plain numbers: `year = {2024}` not `year = {2024a}`.
Use the `year` for the main year and the entry key suffix for disambiguation.

### 14. Special Characters in BibTeX

BibTeX does not accept raw Unicode in `.bib` files on older TeX installations.

**Fix:**
```bibtex
% Wrong:
author = {Müller, Hans}

% Correct:
author = {M{\"u}ller, Hans}

% Common escapes:
\"a → ä    \'e → é    \`e → è    \^o → ô    \~n → ñ    \c{c} → ç
```

---

## Quick Reference: Compile Command Sequence

```bash
cd paper/latex

# Full compile (required for first build or after adding citations):
pdflatex -interaction=nonstopmode acl_latex.tex
bibtex acl_latex
pdflatex -interaction=nonstopmode acl_latex.tex
pdflatex -interaction=nonstopmode acl_latex.tex

# Quick re-compile (no new citations or labels added):
pdflatex -interaction=nonstopmode acl_latex.tex

# Check for errors in log:
grep "^!" acl_latex.log
grep "Warning" acl_latex.log | grep -v "Font"

# Check page count:
pdfinfo acl_latex.pdf | grep Pages

# Check font embedding:
pdffonts acl_latex.pdf | grep -v "yes"
```
