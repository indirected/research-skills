---
name: submission-manager
description: |
  Trigger phrases: "submission checklist", "prepare for submission", "prepare for [venue] submission",
  "what do I need to submit", "deadline checklist", "formatting check", "formatting check for [venue]",
  "submission timeline", "how do I submit to CCS", "what does USENIX require", "what does ACL require",
  "paper submission requirements", "am I ready to submit", "check my paper for submission",
  "help me submit", "submission requirements", "what are the page limits", "is my paper ready",
  "submission prep", "get ready for the deadline", "checklist for [venue]", "venue requirements"
version: 1.0.0
tools: Read, Glob, Grep, Bash, Write, Edit
---

# Skill: submission-manager

Generate venue-specific submission checklists, formatting compliance reports, and backwards
timelines from a given deadline. Covers CCS, USENIX Security, IEEE S&P, NeurIPS, ACL, EMNLP,
and NDSS. Reads the actual paper to verify compliance rather than relying solely on user claims.

---

## Step 0: Gather Inputs

Ask the user for three pieces of information before doing any analysis:

```
I'll generate a complete submission checklist and timeline for you.

Please tell me:
1. **Venue**: Which venue are you submitting to? (e.g., CCS 2026, ACL 2026, USENIX Security 2026)
2. **Deadline**: What is the exact submission deadline, including time zone? (e.g., "May 15, 2026, 23:59 AoE")
3. **Paper type**: What type of submission? (e.g., long paper, short paper, SoK, workshop paper, findings paper)

If you have already submitted to a system (HotCRP, OpenReview, START), let me know the
submission ID or system URL so I can reference it in the checklist.
```

Parse the venue name and look it up in `references/venue-requirements.md`. If the venue is not
listed, ask the user to provide page limits and blind policy before proceeding.

---

## Step 1: Load Venue Requirements

Read `skills/submission-manager/references/venue-requirements.md` to get authoritative
requirements for the specified venue. Extract:

- Content page limit (review version)
- Content page limit (final / camera-ready version)
- Reference page limit (unlimited or capped)
- Blind policy (single-blind vs. double-blind)
- Submission system (HotCRP, OpenReview, START, EDAS, etc.)
- Ethics statement required (yes / no / recommended)
- Artifact evaluation available (yes / no / required)
- File size limit (if any)
- Font and margin requirements
- Any venue-specific quirks (rolling deadlines, author response period, etc.)

---

## Step 2: Locate the Paper

```python
# Locate main LaTeX source
Glob("paper/latex/*.tex")           # expect acl_latex.tex or similar
Glob("paper/latex/**/*.tex")        # catch split-file papers

# Locate compiled PDF
Glob("paper/**/*.pdf")

# Locate any existing submission output
Glob("paper/submission/**/*")
```

Read `project/paper-paths.md` to find the main .tex path (`main_tex` field). If
`project/paper-paths.md` does not exist, use the first .tex file found above. Identify:
- The review/final mode package option — determines anonymization mode
- `\title{...}` — check for placeholder text
- `\author{...}` block — should be absent or placeholder in double-blind review mode
- `\section{...}` commands to inventory all sections present

Derive `LATEX_DIR` and `MAIN_BASE` from `main_tex` for use in all subsequent bash commands.

---

## Step 3: Run Compliance Checks

Run each check and record PASS / FAIL / WARNING with a note explaining the finding.

### 3.1 Page Count Check

```bash
# Count pages in compiled PDF (substitute LATEX_DIR and MAIN_BASE from project/paper-paths.md)
pdfinfo ${LATEX_DIR}/${MAIN_BASE}.pdf 2>/dev/null | grep "Pages:"

# If PDF not available, estimate from LaTeX source
texcount -sum ${LATEX_DIR}/${MAIN_BASE}.tex 2>/dev/null | tail -5
```

Compare page count against venue limit from `references/venue-requirements.md`.
- PASS: page count ≤ venue content limit
- WARNING: page count = venue content limit exactly (tight; any revision risks overflow)
- FAIL: page count > venue content limit

### 3.2 Anonymization Check (double-blind venues only)

Search the main .tex and all section files for anonymization violations:

```python
Grep(r"\\usepackage\[review\]\{acl\}", "paper/latex/")   # must be present for review mode
Grep(r"our (previous|prior|earlier) work", "paper/latex/", ignore_case=True)
Grep(r"our lab|our group|our system", "paper/latex/", ignore_case=True)
Grep(r"github\.com/", "paper/latex/")                     # self-deanonymizing URLs
Grep(r"\\acknowledgments|\\section\*\{Acknowledgments\}", "paper/latex/")  # must be absent
```

Report each hit with file name and line number. Flag as FAIL if any anonymization violations found.

### 3.3 Required Sections Check

Grep the .tex source for these section names:

| Section | Required at |
|---|---|
| Abstract | All venues |
| Introduction | All venues |
| Related Work | All venues (may be merged into intro at short-paper venues) |
| Methodology / Approach | All venues |
| Evaluation / Experiments | All venues |
| Conclusion | All venues |
| References / Bibliography | All venues |
| Ethics Statement | ACL, EMNLP (required); CCS (recommended); USENIX (recommended) |
| Limitations | ACL, EMNLP (required since ACL 2023) |

Flag each missing section as FAIL (if required) or WARNING (if recommended).

### 3.4 Bibliography / Citation Check

```python
# Check for undefined citation warnings in last build
Grep(pattern=r"(?i)citation.*undefined|undefined.*citation",
     path="${LATEX_DIR}/${MAIN_BASE}.log", output_mode="content")
```

```bash
# Identify unused bibtex entries
bibtex ${LATEX_DIR}/${MAIN_BASE} 2>/dev/null | grep "Warning"
```

Flag undefined citations as FAIL (they appear as [?] in the PDF).

### 3.5 Figure Quality Check

```python
Glob("paper/figures/**/*.png")    # PNGs should be ≥300 DPI; flag any present
Glob("paper/figures/**/*.jpg")    # JPGs are lossy; flag for replacement with PDF/EPS
Glob("paper/figures/**/*.pdf")    # preferred format
```

For each PNG file, attempt a DPI check:
```bash
identify -verbose paper/figures/FILENAME.png 2>/dev/null | grep "Resolution"
```

Flag any PNG with resolution < 300 DPI as WARNING. Flag JPGs as WARNING (recommend PDF/EPS).

### 3.6 File Size Check

```bash
ls -lh ${LATEX_DIR}/${MAIN_BASE}.pdf 2>/dev/null
du -sh ${LATEX_DIR}/ 2>/dev/null
```

Compare against venue file size limit (see `references/venue-requirements.md`). Most venues
have a 50 MB limit; USENIX Security has no stated limit but HotCRP defaults to 50 MB.
Flag as WARNING if PDF > 20 MB (large PDFs often have uncompressed figures).

### 3.7 Spell Check

```bash
# Run aspell on LaTeX source (ignore LaTeX commands)
aspell --mode=tex --lang=en check ${LATEX_DIR}/${MAIN_BASE}.tex --list 2>/dev/null | sort | uniq | head -50
```

Report the top misspelled words as WARNING items for manual review.

### 3.8 Submission System Fields Inventory

Based on venue, list every field the author must fill in on the submission system:

**HotCRP (CCS, IEEE S&P, USENIX):**
- Title, abstract (paste plain text — no LaTeX), author names + emails + affiliations
- Topic/area tags, conflicts of interest (list domain names of institutions, not individuals)
- Artifact evaluation checkbox (optional at most venues)
- Submission PDF upload

**OpenReview (NeurIPS):**
- Title, abstract, author names + affiliations (or anonymized for blind), keywords
- Primary area, secondary area, paper type, TL;DR (≤100 chars)
- Supplementary material (optional), code/data link (optional)

**START/SoftConf (ACL, EMNLP):**
- Title, abstract, author names + affiliations, paper type (long/short/findings)
- Subject area (pick 1 primary + up to 3 secondary from the ACL taxonomy)
- Ethics checklist (must check all applicable boxes before submission)
- Limitations section (must be present in PDF)
- Anonymized PDF upload; optional supplementary material

---

## Step 4: Generate Backwards Timeline

Parse the deadline string to compute exact dates. Today's date is available from the system.
Calculate T-N from the submission deadline working backwards.

```
Timeline for [VENUE] submission — deadline: [DATE TIME TIMEZONE]

T-14 days ([DATE]):  Paper freeze — no new content after this point.
                     Complete internal lab review. Circulate to all co-authors for sign-off.
                     Identify all experiments that must be run before submission.

T-10 days ([DATE]):  All experiment data must be in. No new runs after this date.
                     Begin revisions incorporating internal feedback.
                     Check bibliography for completeness; run bibtex.

T-7 days ([DATE]):   Incorporate all co-author feedback.
                     Resolve all TODO and placeholder comments.
                     Run a full LaTeX build and review the compiled PDF end to end.
                     Check all figures are publication quality.

T-5 days ([DATE]):   External dry-run read (colleague outside the project).
                     Verify page count with a fresh build.
                     Check for anonymization violations (if double-blind).
                     Finalize abstract text for submission system (strip LaTeX markup).

T-3 days ([DATE]):   Final polish: grammar, flow, transitions.
                     Verify all figures have captions, all tables have headers.
                     Run spell check.
                     Build PDF in clean environment (new directory, fresh bibtex run).

T-1 day ([DATE]):    Create submission directory: paper/submission/[VENUE]_[YEAR]/
                     Upload PDF to submission system. Fill in all metadata fields.
                     Double-check conflict-of-interest declarations.
                     Take a screenshot of the completed submission form.

T-0 ([DEADLINE]):    Submit. Do NOT edit after submitting unless the system allows withdrawal.
                     Send "submitted!" message to co-authors.
                     Calendar reminder for author response period (if venue has one).
```

If deadline is fewer than 7 days away, compress the timeline and flag as URGENT.

---

## Step 5: Generate Output File

Create the output directory and write the checklist:

```bash
mkdir -p paper/submission/[VENUE]_[YEAR]/
```

Write to `paper/submission/[VENUE]_[YEAR]/checklist.md`:

```markdown
# Submission Checklist: [VENUE] [YEAR]

Generated: [DATE]
Deadline: [DEADLINE]
Paper type: [TYPE]
Submission system: [SYSTEM]

---

## Compliance Report

| Check | Result | Notes |
|-------|--------|-------|
| Page count ([N] pages vs. limit [L]) | PASS/FAIL/WARN | ... |
| Anonymization (double-blind) | PASS/FAIL | ... |
| Required sections present | PASS/FAIL | ... |
| Bibliography (no undefined citations) | PASS/FAIL | ... |
| Figure quality | PASS/WARN | ... |
| File size ([X] MB vs. limit [Y] MB) | PASS/WARN | ... |
| Spell check | WARN | Top issues: ... |

---

## Submission System Fields

[ ] Title: [paste here]
[ ] Abstract (plain text): [paste here]
[ ] Author 1: Name, Email, Affiliation
[ ] Author 2: Name, Email, Affiliation
...
[ ] Topics/Areas: [select appropriate]
[ ] Conflicts: [list institution domains]
[ ] Artifact evaluation: [opt in / out]
[ ] PDF uploaded

---

## Timeline

[GENERATED TIMELINE]

---

## Outstanding Issues

[LIST OF FAILS AND WARNINGS WITH ACTION ITEMS]
```

---

## Step 6: Summary to User

Print a summary in the chat:

```
Submission Checklist Generated
===============================
Venue: [VENUE] [YEAR]
Deadline: [DEADLINE] ([N] days away)
Output: paper/submission/[VENUE]_[YEAR]/checklist.md

Compliance: [N_PASS] passed, [N_WARN] warnings, [N_FAIL] failures

FAILURES (must fix before submission):
  - [list]

WARNINGS (should fix):
  - [list]

Next action: [first urgent item or "All checks passed — finalize PDF and upload"]
```

---

## Reference Files

- `references/venue-requirements.md` — Authoritative requirements per venue (CCS, USENIX, S&P, NeurIPS, ACL, EMNLP, NDSS)

---

## Error Handling

- If the PDF does not exist, instruct the user to compile the LaTeX first using paths from `project/paper-paths.md`:
  `cd ${LATEX_DIR} && pdflatex ${MAIN_BASE}.tex && bibtex ${MAIN_BASE} && pdflatex ${MAIN_BASE}.tex && pdflatex ${MAIN_BASE}.tex`
- If `pdfinfo` is not available, use `qpdf --show-npages paper.pdf` or simply report that page count must be checked manually
- If the venue is not in `references/venue-requirements.md`, ask the user to provide the CFP URL and extract requirements via WebFetch if available
- If deadline has already passed, say so clearly and ask if user wants a post-mortem checklist for lessons learned
