---
name: research-gap-mapper
description: |
  Use this skill whenever the user wants to understand what hasn't been done in the literature,
  frame a research problem, identify open problems, or draft problem motivation text. Trigger on
  phrases like: "map research gaps", "what hasn't been done", "frame our problem", "find open
  problems in the literature", "write problem motivation", "grant proposal context", "what should
  we work on next", "coverage matrix", "what does the literature miss", "identify gaps",
  "where is the whitespace in the field", "help me position our paper", "what are the open
  challenges in LLM vulnerability repair", "draft the motivation for our approach", "why does
  our work matter relative to the literature", "what do I argue in the introduction".
  Run this skill after deep-paper-synthesis has produced synthesized papers. The richer the
  synthesis, the more accurate the gap map. Can also run in "quick mode" using only papers.csv
  data and abstracts if synthesis files are not yet available.
version: 1.0.0
tools: Read, Glob, Grep, Bash, WebSearch, WebFetch, Write, Edit
---

# Research Gap Mapper

This skill synthesizes the full literature tracker and all available synthesis files into a
structured gap landscape: a coverage matrix showing which problem-dimension combinations have
and have not been explored, ranked open problems with feasibility assessments, and a 2-paragraph
problem motivation text ready to paste into the paper's Introduction.

**Prerequisite**: `project/research-focus.md` must exist (created by `project-init`).

## Output Locations

| Output | Path |
|---|---|
| Gap map (full) | `literature/gap_map.md` |
| Problem motivation text | `literature/problem_motivation.md` |
| Coverage matrix (standalone) | `literature/coverage_matrix.md` |

---

## Step-by-Step Workflow

### Step 1 — Load Literature State

Read all relevant data sources:

**Required:**
- `literature/papers.csv` — full tracker; filter for `status = 'synthesized'` or `status = 'cited'`
- `project/research-focus.md` — defines the research domain and system name (created by `project-init`)

Read `project/research-focus.md` and extract `system_name` → use as `{{SYSTEM_NAME}}` throughout.

**Optional (enrich analysis if present):**
- All files in `literature/synthesis/` matching `*_synthesis.md`
- `literature/triage_report_*.md` — gap themes noted during triage

If `papers.csv` contains fewer than 5 synthesized/cited papers, warn the user:
> "Only N synthesized papers found. Gap map will be based primarily on abstracts. Consider
> running deep-paper-synthesis on more papers first for higher-quality gap analysis.
> Continue anyway? (yes/no)"

Report the loaded state:
- N synthesized papers
- N cited papers
- N synthesis files found in `literature/synthesis/`
- Date range of papers loaded (min year to max year)

### Step 2 — Define Research Axes

Derive 4-6 axes from `project/research-focus.md` that characterize the research space.
These axes become the dimensions of the coverage matrix.

**How to derive axes:**
1. Read the "Core Problem", "Approach", and "Evaluation Context" from `project/research-focus.md`.
2. Ask: "What are the 4-6 most important dimensions along which approaches in this field differ?"
3. For each axis, propose 3-5 discrete values that capture meaningful variation in the field.

Present the proposed axes to the user and ask for confirmation:
> "Based on your research focus, I propose these axes for the coverage matrix:
> 1. [Axis]: [values]
> 2. [Axis]: [values]
> ...
> Do these axes capture the key dimensions of variation? Adjust as needed."

**Example axes for different domains** (use as inspiration, not templates):
- NLP/code: Language × Task × Model family × Dataset
- Security/systems: Language × Attack/Defense class × Oracle type × Benchmark
- ML systems: Architecture × Training objective × Scale × Evaluation domain
- Data management: Data type × System model × Query type × Scale regime

### Step 3 — Populate the Coverage Matrix

For each paper in the synthesized/cited set, determine its axis values. Source data:
1. **Preferred**: synthesis files in `literature/synthesis/` (most accurate)
2. **Fallback**: `abstract_snippet` and `venue` from `papers.csv`
3. **Last resort**: WebFetch the paper's abstract page for clarification

Build a 2D coverage matrix for the two most important axes (typically Language × Bug Type and
LLM × Oracle). For a 5-axis space, produce multiple 2D slices:

**Slice 1: Language × Bug Type**
```
                | Mem. Safety | Logic/Semantic | Test Failures | Concurrency |
|----------------|-------------|----------------|---------------|-------------|
| C/C++          |    PAPERS   |       -        |      -        |      -      |
| Java           |      -      |    PAPERS      |   PAPERS      |      -      |
| Python         |      -      |      -         |   PAPERS      |      -      |
| Multi-language |      -      |      -         |   PAPERS      |      -      |
```

**Slice 2: LLM Type × Oracle Type**
```
                | Fuzzer | Test Suite | Formal | Human | Hybrid |
|----------------|--------|------------|--------|-------|--------|
| GPT-4          | OURS   |   PAPERS   |   -    |   -   |   -    |
| Claude         |   -    |     -      |   -    |   -   |   -    |
| Open-source    |   -    |   PAPERS   |   -    |   -   |   -    |
| Non-LLM Neural |   -    |   PAPERS   |   -    |   -   |   -    |
| Classical APR  |   -    |   PAPERS   | PAPERS |   -   |   -    |
```

For each cell, list the short cite keys of papers occupying that cell. An empty cell (—) is
a **candidate gap**. Mark "OURS" where `{{SYSTEM_NAME}}` uniquely occupies a cell.

### Step 4 — Identify and Rank Gaps

A gap is a coverage matrix cell (or combination of cells) that is empty or has only 1-2 papers.

For each identified gap, produce a gap record:

```markdown
### Gap {N}: {Short gap label}

**Axis combination**: {Axis1=Value1, Axis2=Value2, ...}
**Current coverage**: {N papers; list cite keys or "None"}

**Evidence it matters**:
{1-3 sentences citing literature that motivates why this gap is important.
  E.g., "Paper X shows that memory safety bugs in C/C++ are the dominant CVE type (CWE-119
  accounts for 24% of all CVEs per NVD). However, no existing repair system addresses this
  class with a CVE-faithful fuzzer oracle."}

**Lab assets that enable it**:
{What the lab already has that makes this gap addressable — read from `project/system-design.md`
  and `project/experiment-config.md`:
  - Existing dataset or benchmark (from experiment-config.md)
  - System codebase (from system-design.md)
  - Compute budget, infrastructure, or tooling already in place}

**Estimated effort**:
{Low / Medium / High, with 1-sentence justification.
  E.g., "Medium — extending to Python would require a new fuzzer integration but the
  LLM pipeline is language-agnostic."}

**Importance × Feasibility rank**: {1-N, where 1 = highest priority}
```

Rank gaps by the product of:
- **Importance** (1-5): How significant is this gap given the field's direction?
- **Feasibility** (1-5): How achievable is addressing this gap with current lab resources?

Importance scoring:
- 5 = Gap is the primary motivation for this paper (core claim)
- 4 = Gap is a significant contribution but not the only one
- 3 = Gap is addressed partially; future work
- 2 = Gap is acknowledged but out of scope
- 1 = Gap is minor or speculative

Feasibility scoring:
- 5 = Addressable with current code + data + compute
- 4 = Requires minor extension (1-2 weeks)
- 3 = Requires moderate effort (1-2 months)
- 2 = Requires new resources or collaborations
- 1 = Out of reach for this paper

### Step 5 — Assess {{SYSTEM_NAME}}'s Unique Position

Identify which gap(s) {{SYSTEM_NAME}} uniquely addresses. This is the paper's primary
contribution claim. Summarize:

1. **Primary gap addressed**: The highest-ranked gap that {{SYSTEM_NAME}} fills.
2. **Secondary gaps**: 1-2 additional gaps partially addressed.
3. **Remaining gaps**: Gaps not addressed — appropriate for future work section.
4. **Competitive threats**: Papers that are close to {{SYSTEM_NAME}}'s contribution (score 5 in
   `papers.csv`); articulate how {{SYSTEM_NAME}} is still distinct.

### Step 6 — Draft Problem Motivation Text

Write exactly 2 paragraphs of problem motivation. This text is designed to appear in the
Introduction section, immediately after the problem description and before the contributions list.

**Paragraph 1 — The Problem Exists and Matters:**

Structure:
1. Opening with the scale of the problem (cite a statistic or datum from the literature)
2. Why automated solutions are needed (cost/time/expertise argument)
3. Why existing approaches are insufficient (high level; 2-3 papers cited)
4. What specific aspect remains unsolved (bridge to paragraph 2)

Derive the content from:
- The "Core Problem" in `project/research-focus.md`
- Statistics found in highly-cited papers from `literature/papers.csv`
- The top-ranked gap from Step 4

**Paragraph 2 — Existing Work Doesn't Address the Gap:**

Structure:
1. Acknowledge what existing work has achieved (1-2 sentences, citing best prior work)
2. State the structural gap precisely using the axis combination from Step 4
3. Explain why this gap is not a minor oversight but a fundamental limitation
4. Introduce {{SYSTEM_NAME}} as the solution (1 sentence; do not over-claim)

Pattern:
> "Several recent systems have [approach], achieving [best prior result] on [benchmark].
> However, [limitation]. Crucially, no existing work [specific gap from coverage matrix].
> We present {{SYSTEM_NAME}}, [one-sentence description from project/research-focus.md],
> specifically designed to fill this gap."

Use actual citation keys from `papers.csv` and actual numbers from synthesis files.
The final motivation text should be 150-250 words.

### Step 7 — Save Outputs

**literature/gap_map.md** — complete gap analysis:

```markdown
# Research Gap Map
**Generated**: {YYYY-MM-DD}
**Based on**: {N} synthesized/cited papers; {M} synthesis files

## Research Axes
{Table of axes and values}

## Coverage Matrix

### Slice 1: Language × Bug Type
{matrix}

### Slice 2: LLM Type × Oracle Type
{matrix}

## Identified Gaps (Ranked by Importance × Feasibility)

### Gap 1: ... [score: N/25]
...

### Gap 2: ... [score: N/25]
...

## {{SYSTEM_NAME}}'s Unique Position

**Primary gap addressed**: ...
**Secondary gaps**: ...
**Remaining gaps (future work)**: ...
**Differentiation from closest prior work**: ...

## Problem Motivation Text
(see literature/problem_motivation.md)
```

**literature/problem_motivation.md** — just the two paragraphs, ready to paste:

```markdown
# Problem Motivation

Generated by research-gap-mapper on {date}.
To use: paste both paragraphs into the Introduction section of `paper/latex/main.tex`,
after the problem description paragraph and before \paragraph{Contributions}.

---

{Paragraph 1}

{Paragraph 2}

---

## Citation Keys Used
{List of \citep{} and \citet{} keys used; verify all exist in custom.bib}
```

**literature/coverage_matrix.md** — standalone matrix for quick reference:
Just the matrix tables from gap_map.md, no surrounding text. Useful for sharing in group meetings.

---

## Quick Mode (No Synthesis Files)

If no synthesis files exist but `papers.csv` has synthesized/cited entries, run in quick mode:

1. Use `abstract_snippet` and `gap_notes` from `papers.csv` as the information source.
2. Build the coverage matrix from the `venue`, `year`, and `gap_notes` fields alone.
3. Label all cells with "ABSTRACT-ONLY" superscript to indicate lower confidence.
4. Produce the gap map and motivation text, but add a disclaimer:

> "NOTE: This gap map is based on abstract-level information only. Confidence is lower than a
> synthesis-based map. Run deep-paper-synthesis on the top relevant papers to improve accuracy."

---

## Iterative Refinement

The gap map should be updated whenever:
- New papers are synthesized (run research-gap-mapper again)
- The research focus shifts
- Reviewer feedback suggests the positioning needs adjustment
- A new competing paper appears (check if it occupies a previously empty cell)

When re-running, compare the new gap map to the previous version and report:
- New gaps discovered (cells newly empty after adding more papers)
- Gaps now partially filled (new papers occupy previously empty cells)
- Changes to the importance × feasibility ranking

---

## Integration with Other Skills

- **paper-search-and-triage** provides the initial set of papers and a preliminary gap themes
  section in the triage report. The gap mapper formalizes those themes into a structured matrix.
- **deep-paper-synthesis** produces the `synthesized` status entries and detailed synthesis files
  that make the gap map more accurate. Always prefer running synthesis first.
- The **Problem Motivation text** from this skill feeds directly into the Introduction of
  `paper/latex/main.tex`. The **narrative synthesis paragraphs** from deep-paper-synthesis
  feed into the Related Work section.
- The coverage matrix can be included in grant proposals, conference talks, or group meeting
  presentations directly from `literature/coverage_matrix.md`.

---

## Example Coverage Matrix (Illustrative)

This is an example of what the output looks like for a well-populated literature set.
The axes shown here are illustrative — your axes will be derived from `project/research-focus.md`.

### Slice: Language × Oracle Type (example axes for a code repair domain)

```
                     | Test Suite | Fuzzer | Formal | Human | Hybrid |
|---------------------|------------|--------|--------|-------|--------|
| C/C++               | [Wang'23]  | [OURS] |   —    |   —   |   —    |
| Java                | [Chen'24]  |   —    |[Ke'21] |   —   |   —    |
|                     | [Liu'23]   |        |        |       |        |
| Python              | [SWE'24]   |   —    |   —    |   —   |   —    |
| Multi-language      | [Code'24]  |   —    |   —    |   —   |   —    |
```

In the matrix, mark "OURS" where {{SYSTEM_NAME}} uniquely occupies a cell.
Gaps (—) are candidate open problems. Gaps in cells adjacent to "OURS" are future work directions.

---

## Venue Tiers Reference

This skill uses the same venue tier definitions as paper-search-and-triage. See:
`skills/paper-search-and-triage/references/venue-tiers.md`

When assessing gap importance, papers at Tier 1 venues that address an adjacent combination
provide stronger evidence that the specific combination matters. A gap supported by Tier 1
adjacent work is more likely to be an important open problem than one only noted in Tier 3
preprints.

When citing evidence for why a gap matters (Step 4, "Evidence it matters"), prefer:
1. Statistics from authoritative sources (NVD, OSS-Fuzz reports, CWE Top 25)
2. Claims from Tier 1 papers stating that this direction is "future work" or "open"
3. Survey papers explicitly listing open problems
4. Your own lab's preliminary results (if any)

---

## Checklist Before Finalizing

- [ ] Coverage matrix accounts for all synthesized/cited papers (none omitted)
- [ ] `{{SYSTEM_NAME}}`'s unique cell(s) are clearly marked in the matrix
- [ ] Each gap record has all 5 fields: axis combination, current coverage, evidence, lab assets, effort
- [ ] Importance × Feasibility scores are calibrated (not all 5×5)
- [ ] Problem motivation text uses real citation keys that exist in `paper/latex/custom.bib`
- [ ] Word count of motivation text is 150-250 words (two paragraphs)
- [ ] Remaining gaps section is non-empty (every paper has future work)
- [ ] `literature/problem_motivation.md` is saved and path communicated to user
