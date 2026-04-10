---
name: write-background-section
description: |
  Draft the Background / Preliminaries section of any research paper in LaTeX.
  Reads technical concepts from project/background-concepts.md and produces
  a section explaining each concept at the level appropriate for a non-expert reviewer.
  Trigger when the user says any of the following:
  - "write background section"
  - "write preliminaries"
  - "draft background"
  - "explain [technical concept] in the paper"
  - "add technical background for reviewers"
  - "write the background"
  - "what technical concepts need background"
  - "draft the background and related concepts"
  - "help me write the background"
  - "background section needs work"
  - "add background on [concept]"
version: 2.0.0
tools: Read, Glob, Grep, Bash, Write, Edit
---

# Skill: write-background-section

You are helping write the **Background / Preliminaries** section of a research paper.
This section explains technical concepts that a non-expert reviewer needs to understand
the paper — it does NOT summarize prior work (that belongs in Related Work).

---

## Step 0 — Check Prerequisites

Read the project config files:

```
Read: project/research-focus.md
Read: project/background-concepts.md
Read: project/paper-paths.md
Read: project/venue-config.md
```

**If `project/background-concepts.md` does not exist**, stop and tell the user:

> "I need `project/background-concepts.md` to write the background section.
> Please run the `project-init` skill first, or create this file manually.
>
> The file format is:
> ```markdown
> # Background Concepts
>
> ## Concept: [name]
> **What it is**: [1-sentence definition]
> **Why relevant**: [1-sentence connection to the paper]
> **Suggested citations**: [citation keys or TODO]
>
> ## Concept: [name]
> ...
> ```"

**If `project/paper-paths.md` does not exist**, ask the user:
> "Where is your LaTeX sections directory? (e.g., `/path/to/paper/latex/sections/`)"
> Use the answer as the output directory.

Extract from `project/research-focus.md`:
- `system_name` → use as `{{SYSTEM_NAME}}` throughout

Extract from `project/venue-config.md`:
- `review_mode` → if "yes", apply anonymization rules throughout
- Word budget for Background section

---

## Step 1 — Check Review Mode

If `review_mode: yes` in `project/venue-config.md`:
- Do NOT mention author names, lab names, or institution names anywhere.
- Do NOT write "our prior work [citation]" — treat all prior work as third-party.
- All self-references must use the system name without possessive: "{{SYSTEM_NAME}}" not "our system".
- The Acknowledgments section must NOT appear.

Inform the user: "Review mode is **active** — all text will be anonymized." or "Review mode is **inactive** — author information is allowed."

---

## Step 2 — Read Current Paper State

Read the LaTeX file and existing sections to avoid duplication:

```
Read: {{main_tex from project/paper-paths.md}}
Glob: {{sections_dir from project/paper-paths.md}}/*.tex
```

For each .tex file found, read it briefly and identify:
- What sections already exist and what they cover.
- Whether a `background.tex` already exists (if so, read it and extend rather than overwrite).
- What `\input{sections/...}` lines are already in the main .tex.

Read the bibliography file to know what citations already exist:
```
Read: {{bibliography from project/paper-paths.md}}
```

---

## Step 3 — Load and Confirm Concepts

Read `project/background-concepts.md`. Present the list of concepts to the user:

> "I found the following concepts in `project/background-concepts.md`:
> 1. [concept 1]
> 2. [concept 2]
> ...
>
> Are these all the concepts to cover, or would you like to add/remove any?
> (Type 'ok' to proceed, or list changes.)"

If the user specifies a subset (e.g., "just concepts 1 and 3"), draft only those.

---

## Step 4 — Draft Each Concept Subsection

For each concept, draft **1–3 paragraphs** following this structure:

1. **Definition** (1–2 sentences): What is this concept? Accessible to a reviewer who may not know this specific subfield.
2. **How it works** (2–4 sentences): Key mechanism in plain language. Use analogies if appropriate.
3. **Why relevant to this paper** (1–2 sentences): Explicit connection to {{SYSTEM_NAME}}'s design or evaluation.

### Drafting Guidelines

- Use the "What it is" and "Why relevant" fields from `project/background-concepts.md` as the seed for each subsection — expand them into full paragraphs.
- Write at a level appropriate for a reviewer who is expert in adjacent areas but not this exact subfield.
- Do NOT repeat content that belongs in Related Work (e.g., comparisons to prior systems).
- Do NOT repeat content that belongs in Methodology (e.g., how {{SYSTEM_NAME}} implements this concept).
- If the concept has a widely cited survey or seminal paper, cite it. Look in the bibliography first; if not present, note it as a TODO.

### Citation Handling

For each suggested citation key from `project/background-concepts.md`, check if it exists
in the bibliography file (from `project/paper-paths.md`):

```python
Grep(pattern=r"{{citation_key}}", path="{{bibliography from project/paper-paths.md}}", output_mode="count")
```

If the key is NOT in the bibliography:
1. Note it as a TODO: `% TODO: add \cite{{{citation_key}}} to bibliography`
2. After completing the draft, list all missing citations to the user with guidance on finding them.

---

## Step 5 — Apply Anonymization Check

If review mode is active, run:

```python
Grep(pattern=r"our lab|our prior work|we previously|our previous|our earlier|our group",
     path="{{sections_dir}}/background.tex", output_mode="content")
```

Also grep for any lab name or institution name the user might have mentioned during the session.
Flag every hit and suggest neutral rewrites:
- "our prior work [X]" → "prior work by [AuthorName] [X]"
- "our lab's system" → "the {{SYSTEM_NAME}} system"
- "we previously showed [X]" → "[Authors (Year)] showed [X]"

---

## Step 6 — Write Output File

Write the full section to `{{sections_dir}}/background.tex`.

The file should begin:

```latex
% Background section — {{SYSTEM_NAME}} paper
% Generated by write-background-section skill

\section{Background}
\label{sec:background}
```

Each subsection uses `\subsection{Concept Name}` with labels following the convention `sec:bg-{{concept-slug}}`.

After writing, check if `\input{sections/background}` is already in the main .tex file.
If not, tell the user:
> "Add `\input{sections/background}` to your main .tex file. It should go after the Introduction input and before the Methodology/System Design input."

---

## Step 7 — Page Budget Check

Count the word count of the draft:
```bash
wc -w {{sections_dir}}/background.tex
```

Compare against the budget in `project/venue-config.md`. If no budget is specified, use these defaults:
- ACL 8-page: 500–650 words
- NeurIPS 9-page: 550–700 words
- USENIX 13-page: 700–900 words
- IEEE S&P 13-page: 700–900 words

**If significantly over budget**:
- Trim definition paragraphs to 1–2 sentences for well-known concepts.
- Cut "how it works" detail for concepts the target venue's reviewers will know well.
- Move any comparison to prior implementations to Related Work.

**If under budget (< 80% of target)**:
- Expand the "why relevant" paragraph for 1–2 concepts.
- Add a sentence contextualizing the domain's importance (statistics, adoption, real-world impact).

---

## Step 8 — Final Checklist

Before presenting the draft to the user, verify:

- [ ] `\section{Background}` with `\label{sec:background}` is present.
- [ ] All subsections have consistent `\label{sec:bg-*}` names.
- [ ] Every `\cite{}` key exists in the bibliography (or is marked TODO).
- [ ] No author/lab names if review mode is active.
- [ ] No acknowledgments text.
- [ ] Word count is within the venue budget.
- [ ] `\input{sections/background}` placement advice given for main .tex.

---

## Step 9 — Remind User to Sync with Overleaf

If the paper is linked to Overleaf via a git submodule:

```
SYNC REMINDER:
If your paper/ directory is a git submodule linked to Overleaf:

  cd {{paper_root_dir}}
  git add latex/sections/background.tex latex/custom.bib
  git commit -m "Add background section"
  git push

Verify the build compiles on Overleaf after pushing.
```

---

## Missing Citation Guidance

When a citation is missing from the bibliography, help the user add it by suggesting:
- Search for the paper on Semantic Scholar or Google Scholar
- Construct a BibTeX entry with the correct type (@inproceedings, @article, @misc for arXiv)
- Add it to the bibliography file
- Mark with `% TODO: verify DOI` if the DOI is uncertain

Never fabricate DOIs or page numbers. It is better to leave a TODO than to invent metadata.
