---
name: write-intro-and-abstract
description: |
  Draft the Introduction and Abstract of any research paper following a structured
  narrative arc: hook → problem → gap → contribution → roadmap. Also generates a reviewer pitch.
  Reads contributions and research focus from project/ config files.
  Trigger when the user says any of the following:
  - "write introduction"
  - "draft abstract"
  - "write intro section"
  - "improve the abstract"
  - "write paper intro for [venue]"
  - "write contributions section"
  - "draft the intro"
  - "write the opening of the paper"
  - "write abstract and introduction"
  - "help me write the intro"
  - "the introduction needs work"
  - "draft contributions bullets"
  - "write the intro for [venue]"
  - "rewrite the abstract"
  - "write a hook paragraph"
  - "fix the intro"
  - "I need an abstract"
version: 2.0.0
tools: Read, Glob, Grep, Bash, Write, Edit
---

# Skill: write-intro-and-abstract

You are helping write the **Introduction** and **Abstract** of a research paper.
These are the most-read parts of any paper. They must be accurate (grounded in what the paper
actually demonstrates), specific (include concrete numbers), and structured (follow a clear arc).

---

## Step 0 — Check Prerequisites

Read the project config files:

```
Read: project/research-focus.md
Read: project/contributions.md
Read: project/paper-paths.md
Read: project/venue-config.md
```

**If `project/contributions.md` does not exist**, stop and tell the user:

> "I need `project/contributions.md` to write the introduction and abstract.
> Please run the `project-init` skill first, or create this file manually.
>
> The file format is:
> ```markdown
> # Paper Contributions
>
> ## Contributions
> - We introduce [system], which [what it does].
> - We demonstrate [capability] achieving [result].
> - We release [artifact].
>
> ## Headline Result
> [The single most important finding with a specific number]
> ```"

Extract from config:
- `system_name` from `project/research-focus.md` → `{{SYSTEM_NAME}}`
- `review_mode` from `project/venue-config.md`
- Venue name and abstract word limit

---

## Step 1 — Check Review Mode, Venue, and Paper Type

Read `project/venue-config.md` to get:
- `review_mode` (yes/no)
- Venue name
- Page limit (determines intro word budget)

If `review_mode: yes`:
- **Review mode is active.** No author names, lab names, or institution names anywhere.
- Contributions section must not say "our lab" or reference lab-specific prior systems.
- Acknowledgments must be absent.
- Self-citations written as third-party: "Prior work (AuthorName, Year)" not "Our prior work".

Inform the user: "Review mode is **active** — all text will be anonymized." or "Review mode is **inactive**."

Determine **abstract word limit** from venue:
- ACL / EMNLP / NAACL: ≤200 words
- NeurIPS / ICML / ICLR: ≤150 words
- CCS / USENIX Security / IEEE S&P: ≤250 words
- ICSE / FSE / ASE: ≤200 words
- Unknown: use 200 words as default

Determine **intro word budget**:
- 8-page paper (ACL, CCS, etc.): 350–450 words
- 9-page paper (NeurIPS): 450–550 words
- 13-page paper (USENIX, IEEE): 550–700 words

---

## Step 2 — Read the Full Paper for Context

Before drafting, read everything that already exists. The abstract and intro must accurately
reflect the paper's actual content.

```
Read: {{main_tex from project/paper-paths.md}}
Glob: {{sections_dir from project/paper-paths.md}}/*.tex
```

For each section file found, read it. Extract:
- Key claims made in the methodology section.
- The evaluation dataset and setup.
- Any headline numbers from the experiments section.
- What contributions are actually demonstrated vs. merely planned.

---

## Step 3 — Gather Headline Results

Look for the most recent results analysis file:
```python
Glob("experiments/results_analysis_*.md")  # sorted by modification time; use the last one
```

Read the most recent file. Extract the top 3–4 numbers to use in the abstract and contributions.

If no results file exists, read `project/contributions.md` which should have a "Headline Result" entry.
If that is also empty, ask the user:
> "What are your top 3 headline results? I need specific numbers to make the abstract and
> contributions concrete. Example: 'Our system achieves 47% patch correctness, a 2× improvement
> over the best baseline.'"

---

## Step 4 — Ask for User Preferences

Before drafting, ask (or infer from context):
1. **Hook style**: statistic hook (opens with a number), problem hook (describes the manual
   process), or contrast hook (AI can do X but not Y yet)?
2. **Contribution count**: how many bullet points? (3–5 is standard)
3. **Draft both abstract + intro, or just one?**

If the user doesn't express a preference, default to:
- Problem hook (works for most research areas)
- 3–4 contribution bullets matching the entries in `project/contributions.md`
- Draft both abstract and intro

---

## Step 5 — Draft the Abstract

Use the word limit from Step 1.

Structure:
```
[Context — 1 sentence]    Domain and why it matters.
[Problem — 1 sentence]    Specific challenge this paper addresses.
[Approach — 1–2 sentences] What {{SYSTEM_NAME}} is and does.
[Result — 1 sentence]     Headline number or key finding from project/contributions.md.
```

**Template**:
> [Domain context sentence connecting to a real-world need.]
> We introduce {{SYSTEM_NAME}}, [1-sentence approach from project/research-focus.md].
> [1-2 sentences describing the key method or framework.]
> Evaluating on [dataset/benchmark], we find that [headline result with number].

Fill placeholders from `project/contributions.md` (Headline Result) and `project/research-focus.md`.

Count words:
```bash
echo "abstract text" | wc -w
```

If over the limit: cut from the approach sentences first (keep context and result). Never cut the headline number.

---

## Step 6 — Draft the Introduction

Follow the 6-part arc. Target the word budget from Step 1.

### Part 1 — Hook

**Statistic hook**: Opens with a striking number about the domain's scale or cost.
> "[Domain metric] — [what the statistic means]. [Why this matters.]"

**Problem hook**: Describes the painful manual process that exists today.
> "When a [practitioner] encounters [problem], they must [manual steps — time-consuming and error-prone]."

**Contrast hook**: States what AI can do vs. what it still cannot.
> "Large language models can [impressive capability], yet they struggle to [gap this paper addresses]."

Choose based on the user's preference from Step 4. Use the domain described in `project/research-focus.md`.

### Part 2 — Problem Statement

Translate the "Core Problem" from `project/research-focus.md` into 2–3 sentences:
- What specific challenge does the paper address?
- Why is this hard? (What properties make it non-trivial?)
- Why does it matter? (What happens if it is not solved?)

### Part 3 — Gap Statement

Describe what existing work does NOT do that {{SYSTEM_NAME}} does. Ground this in:
- The "What Makes This Novel" field from `project/research-focus.md`
- The cluster differentiation notes from `project/related-work-clusters.md` (if it exists)

Pattern: "Prior work on [area] has [what it does]. However, [limitation that {{SYSTEM_NAME}} addresses]."

### Part 4 — Approach Overview

Translate the "Approach" from `project/research-focus.md` into 2–3 sentences.
Be concrete: what is the input, what is the output, what is the key mechanism?

### Part 5 — Contributions

Format as a LaTeX itemize block:

```latex
\noindent Our main contributions are:
\begin{itemize}[noitemsep,topsep=2pt]
  \item \textbf{[Bold label].} [Description with specific number or capability].
  \item \textbf{[Bold label].} [Description].
  \item \textbf{[Bold label].} [Description].
\end{itemize}
```

Pull directly from `project/contributions.md`. Each bullet should:
- Start with a bold 2–5 word label
- Include a specific claim (number, comparison, or artifact)
- Be verifiable from the paper's actual content

In review mode: remove artifact release URLs; replace with "Code and data will be released upon acceptance."

### Part 6 — Roadmap

```latex
The remainder of this paper is organized as follows:
Section~\ref{sec:background} provides background on [key concepts];
Section~\ref{sec:methodology} describes [the {{SYSTEM_NAME}} design / our approach];
Section~\ref{sec:experiments} presents [experimental results];
Section~\ref{sec:related} surveys related work; and
Section~\ref{sec:conclusion} concludes.
```

Only include `\ref{}` labels for sections that actually exist or will exist in the paper.

---

## Step 7 — Verify Contributions Against Paper Body

For each contribution bullet, verify it is actually demonstrated in the paper:
- If the contribution mentions a specific number, find that number in the experiments section.
- If the contribution mentions an artifact release, confirm it is real (or soften to "upon acceptance").
- If the contribution mentions a method, confirm the methodology section describes it.

Flag any contribution that cannot be verified from existing sections. Ask the user to confirm or update.

---

## Step 8 — Check Citations Against Bibliography

For every `\cite{}` key used in the intro, check it exists in the bibliography:
```python
Grep(pattern=r"{{cite_key}}", path="{{bibliography from project/paper-paths.md}}")
```

Typical citations needed:
- The dataset(s) evaluated on
- Key baselines from related work
- Any statistics or facts cited in the hook
- The model or tool used (if applicable)

For missing keys, note as TODO. Never invent DOIs or page numbers.

---

## Step 9 — Apply Anonymization Check

If review mode is active:
```python
Grep(pattern=r"our lab|our prior work|we previously|our previous|our earlier|our group",
     path="{{sections_dir}}/intro.tex", output_mode="content")
```

Also check for:
- Lab/institution names embedded in system names
- URLs pointing to lab GitHub orgs (remove in review mode)
- Author-revealing acknowledgment text accidentally added to the intro

Fix all hits before presenting the draft.

---

## Step 10 — Write Output Files

Write the introduction to `{{sections_dir}}/intro.tex`.

The file should begin:
```latex
% Introduction section — {{SYSTEM_NAME}} paper
% Generated by write-intro-and-abstract skill

\section{Introduction}
\label{sec:intro}
```

For the abstract: check if it is inline in the main .tex or in a separate file:
```python
Grep(pattern=r"\\begin\{abstract\}", path="{{main_tex}}", output_mode="content")
Grep(pattern=r"\\input\{.*abstract", path="{{main_tex}}", output_mode="content")
```

If inline: edit the `\begin{abstract}...\end{abstract}` block in the main .tex using Edit.
If separate file: write to `{{sections_dir}}/abstract.tex`.

Check that `\input{sections/intro}` is in the main .tex:
```python
Grep(pattern=r"\\input\{.*intro", path="{{main_tex}}", output_mode="content")
```

If not present, tell the user: "Add `\input{sections/intro}` after the abstract block in your main .tex."

---

## Step 11 — Generate Reviewer Pitch

After the draft, generate a reviewer pitch for internal reference (NOT submitted):

```
REVIEWER PITCH (internal reference — do not include in submission):

1. [Primary empirical claim with number]
   Example: "First to [key novelty]; achieves [X]% [metric] — establishes the baseline."

2. [Key novelty claim]
   Example: "[Finding] reveals [insight] — a systematic effect, not a model-specific failure."

3. [Artifact/community value, if applicable]
   Example: "Full replication package: [artifact description] — enables comparison for future work."
```

Fill with actual numbers from Step 3.

---

## Step 12 — Final Checklist

- [ ] Abstract is within venue word limit.
- [ ] Abstract covers: context, problem, approach, result.
- [ ] Introduction has all 6 parts: hook, problem, gap, approach, contributions, roadmap.
- [ ] Every contribution bullet starts with bold label + action verb.
- [ ] All `\cite{}` keys verified in bibliography.
- [ ] No author/lab names in review mode.
- [ ] All headline numbers in abstract and contributions match the experiments section.
- [ ] Roadmap `\ref{}` labels match actual section labels in the paper.
- [ ] `\input{sections/intro}` placement checked in main .tex.
- [ ] Reviewer pitch generated (internal only).
- [ ] Introduction word count is within venue budget.

---

## Step 13 — Remind User to Sync with Overleaf

```
SYNC REMINDER:
If your paper/ directory is a git submodule linked to Overleaf:

  cd {{paper_root_dir}}
  git add latex/sections/intro.tex latex/main.tex latex/custom.bib
  git commit -m "Add introduction and abstract"
  git push

After pushing, verify on Overleaf:
- Abstract word count in rendered PDF
- All citations resolve (no "?" in the PDF)
- Review mode ruler (line numbers) is present if in review mode
```
