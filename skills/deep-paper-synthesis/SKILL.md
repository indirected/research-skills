---
name: deep-paper-synthesis
description: |
  Use this skill whenever the user wants to deeply read, summarize, compare, or synthesize academic
  papers. Trigger on phrases like: "synthesize papers", "compare papers", "read and summarize
  [paper list]", "generate comparison table", "write summary of related work papers", "extract key
  results from papers", "deep read these papers", "summarize what these papers do", "make a table
  comparing approaches", "write the related work section based on these papers", "what do these
  papers say about [topic]", "contrast our approach with [paper]", "help me understand this paper
  in context", "what are the key takeaways from the to-read list", "summarize my reading list".
  Run this skill after paper-search-and-triage has populated the "to-read" list, or when the user
  directly provides paper IDs, PDF links, or titles to analyze.
version: 1.0.0
tools: Read, Glob, Grep, Bash, WebSearch, WebFetch, Write, Edit
---

# Deep Paper Synthesis

This skill performs deep reading and synthesis of academic papers, producing per-paper extraction
cards, cross-paper comparison tables in ACL LaTeX format, and narrative synthesis paragraphs
suitable for the Related Work section of the paper.

## Output Locations

| Output | Path |
|---|---|
| Per-paper cards + narrative | `literature/synthesis/{TOPIC}_synthesis.md` |
| ACL-format LaTeX table | `literature/synthesis/{TOPIC}_table.tex` |
| Updated paper tracker | `literature/papers.csv` (status → `synthesized`) |

---

## Step-by-Step Workflow

### Step 1 — Gather the Paper List

Two modes:

**Mode A — From tracker (default):**
Read `literature/papers.csv`. Filter rows where `status = 'to-read'`. Present the list to the user:

> "Found N papers with status 'to-read'. Synthesizing all of them, or a subset? (Reply with
> 'all' or list arXiv IDs / row numbers to include.)"

**Mode B — User-provided:**
User provides arXiv IDs, PDF URLs, or paper titles directly. Look up each in `papers.csv` first.
For papers not in the tracker, add them with status `to-read` before proceeding.

For papers with no `arxiv_id` (status `s2:...` prefix), use the `url` field to access the paper.

Record the final paper list. Assign a short `TOPIC` label (e.g., `llm_vuln_repair`,
`apr_baselines`, `fuzzing_ml`) based on the cluster of papers selected. This label becomes the
filename stem for synthesis outputs.

### Step 2 — Fetch Each Paper

For each paper in the synthesis list:

1. Check if a PDF URL is available in `papers.csv` (`url` field). If it points to a PDF
   (ends in `.pdf` or contains `arxiv.org/pdf`), use WebFetch to retrieve it.

2. If no direct PDF URL: try constructing the arXiv PDF URL:
   `https://arxiv.org/pdf/{arxiv_id}`

3. If the paper is paywalled with no open-access version:
   - Use WebFetch to retrieve the Semantic Scholar page for the abstract, related work links, and
     TLDR: `https://www.semanticscholar.org/paper/{paperId}`
   - Fall back to the abstract + title for the extraction card. Mark the card with
     `[ABSTRACT ONLY - no PDF access]`.

4. After retrieving the content, extract the text. For PDFs fetched via WebFetch, the content
   will be HTML or text — parse out the paper body text.

See `skills/deep-paper-synthesis/references/synthesis-template.md` for the exact paper card format.

### Step 3 — Extract Per-Paper Information

For each paper, produce a **paper extraction card** using the template in
`references/synthesis-template.md`. The card has these sections:

#### 3a. Problem Statement
One concise paragraph (2-4 sentences):
- What specific problem does this paper address?
- Why does the problem matter (what breaks if it is not solved)?
- What is the core research question or hypothesis?

#### 3b. Key Methodology / Approach
2-5 bullet points or a short paragraph covering:
- Overall system or algorithm architecture
- Key technical innovations (what makes this different from prior work)
- Tools, datasets, or components used
- Any novel training procedure, prompting strategy, or verification step

For LLM-based papers: note which models are used (GPT-4, Claude, open-source), prompting style
(zero-shot, few-shot, chain-of-thought), and any fine-tuning.

For domain-specific papers (e.g., APR): note the repair operator set, search strategy,
oracle type, or other domain-specific design choices relevant to the paper.

#### 3c. Main Results / Metrics

Always capture:
- Primary metric (e.g., patch correctness rate, plausibility rate, precision/recall, pass@k)
- Benchmark / dataset used
- Comparison baselines
- Key quantitative finding (e.g., "achieves 43.2% correct patches vs. 28.1% for GPT-4 baseline")

Format as a small table if multiple metrics are reported:
```
| Metric | This Paper | Best Baseline |
|---|---|---|
| Correct patch rate | 43.2% | 28.1% (GPT-4-base) |
| Plausibility rate | 71.4% | 65.0% |
```

#### 3d. Limitations

2-4 bullet points identifying:
- Scope limitations (language, bug type, dataset size)
- Methodological limitations (oracle assumptions, evaluation validity)
- Known failure modes reported in the paper
- Threats to validity noted by the authors

#### 3e. Relation to This Work

1-3 sentences written from the perspective of the paper being written. Answer:
- Does this paper support, contradict, or extend our claims?
- What gap does our work fill that this paper does not address?
- Should this paper be cited in Related Work, Methodology, or Evaluation sections?

Update `gap_notes` in `papers.csv` with the key phrase from this section.

### Step 4 — Cross-Paper Analysis

After all cards are complete, perform the following analyses:

#### 4a. Thematic Clustering

Identify 3-5 thematic clusters across the papers. Derive cluster names from the papers
themselves — do not assume a fixed set. Common cluster types that apply across domains:

1. **Core Method Papers** — papers proposing the primary technique used in each cluster
2. **Baseline / Classical Approaches** — non-ML or earlier-generation approaches
3. **Benchmarks and Datasets** — papers that primarily contribute evaluation infrastructure
4. **Survey / Empirical Studies** — papers analyzing the state of the field
5. **Adjacent Methods** — related techniques from neighboring sub-fields

For the specific domain, derive more precise cluster names from the paper abstracts.
Assign each paper to its primary cluster. A paper may appear in a secondary cluster too.

#### 4b. Idea Evolution Timeline

Trace the chronological progression of key ideas in the domain:
- When did the dominant technique (e.g., deep learning, LLMs, a specific algorithm) first appear?
- What preceded it, and what did it supersede?
- What was the state of the art immediately before the paper being written?

Write a 3-4 sentence paragraph tracing this arc.

#### 4c. Open Problems Identification

From the limitations sections of all cards, enumerate open problems that multiple papers share:
- Which limitations appear in 3+ papers? (these are structural gaps in the field)
- Which limitations are addressed by some papers but not others?
- What does no paper in the set address? (this is where the paper being written contributes)

### Step 5 — Generate ACL Comparison Table

Build a LaTeX comparison table. Derive the comparison axes from the papers themselves
and from `project/research-focus.md` (if it exists). Standard axes that work across domains:

**Always include:**
- Paper (short citation form, e.g., \citet{Author2024})
- Venue + Year
- Our Approach? (checkmark ✓ or dash —)

**Domain-specific axes** — select from the following based on what differentiates papers
in the set (typically 4-6 axes total):
- Input type / language / modality
- Task type or problem setting
- Core technique / model family (LLM, classical ML, rule-based, etc.)
- Evaluation oracle or verification method
- Benchmark / dataset used
- Primary metric reported

Use the LaTeX table template from `references/latex-table-patterns.md`.

Save to `literature/synthesis/{TOPIC}_table.tex`.

Suggested column grouping:
- Group 1: Approach (paper, venue, year)
- Group 2: Problem Setting (input type, task type)
- Group 3: Method (technique, model)
- Group 4: Evaluation (benchmark, metric)

### Step 6 — Write Narrative Synthesis

Write 3-5 paragraphs of narrative synthesis. Structure:

**Paragraph 1 — Chronological arc:**
Begin with the earliest relevant work and trace the evolution to the most recent. Cite papers
inline using `\citet{}` or `\citep{}` ACL style. Cover how the field progressed from early
approaches to more recent ones. Adapt this arc to the domain; do not assume a fixed narrative.

Example opening structure:
> [Field] has been studied since \citet{...}, who first demonstrated ... Over time, the
> community shifted toward [later paradigm]. Most recently, [dominant current approach]
> has emerged as the leading direction (\citep{...}).

**Paragraph 2 — Thematic synthesis by cluster:**
Group papers by the clusters identified in Step 4a. Describe each cluster in 2-3 sentences,
citing the key papers. Highlight the dominant approach within each cluster and its assumptions.

**Paragraph 3 — Most relevant sub-field (zoom in):**
Zoom into the cluster most directly related to the paper being written. Contrast its
assumptions, oracles, and evaluation setups with those of the other clusters. Identify the
specific gap or limitation shared by most papers in this cluster that the paper addresses.

**Paragraph 4 — Gap and positioning (required):**
Explicitly state what no existing work addresses. Example structure:
> Despite progress in [field], no existing work [gap 1]. Furthermore, [gap 2].
> Our work addresses both gaps by [method contribution].

This paragraph feeds directly into the gap_map.md produced by research-gap-mapper.

**Paragraph 5 (optional) — Evaluation methodology comparison:**
If the papers use very different evaluation setups, add a paragraph comparing benchmark
characteristics (dataset size, bug type distribution, oracle strength).

Write in academic English, past tense for describing prior work, present tense for our claims.
Target 400-600 words for the full narrative. Avoid excessive hedging.

### Step 7 — Save Outputs

Save the complete synthesis (all cards + cross-paper analysis + narrative) to:
```
literature/synthesis/{TOPIC}_synthesis.md
```

Save the LaTeX comparison table to:
```
literature/synthesis/{TOPIC}_table.tex
```

The synthesis markdown file structure:
```markdown
# Synthesis: {TOPIC} — {DATE}

## Papers in This Synthesis
- [{title}]({url}) — {authors}, {venue} {year}
...

## Per-Paper Extraction Cards
### Card 1: {Title}
...

## Cross-Paper Analysis
### Thematic Clusters
...
### Idea Evolution Timeline
...
### Open Problems
...

## Comparison Table (LaTeX source)
See `literature/synthesis/{TOPIC}_table.tex`

## Narrative Synthesis
...
(paste the 3-5 paragraphs here)
```

### Step 8 — Update papers.csv

For each paper that was successfully synthesized (even if abstract-only), update its `status`
from `to-read` to `synthesized` in `literature/papers.csv`. Also update the `gap_notes` field
with the key phrase from the Relation to This Work section (Step 3e).

To update the CSV:
1. Read the full CSV content.
2. For each synthesized paper's row, change `status` from `to-read` to `synthesized`.
3. Update `gap_notes` with the synthesis finding (1 sentence, CSV-escaped).
4. Overwrite the file. Do NOT change the sort order here; preserve the existing row order.

---

## Handling Edge Cases

### Paper Without Open-Access PDF
Use abstract + title only. Mark the extraction card header:
```
[ABSTRACT ONLY — No open-access PDF found. Access via: {url}]
```
Still complete all 5 card sections; use "Not determinable from abstract" for metrics.
Recommend the user manually retrieve the PDF and re-run synthesis for that paper.

### Paper in a Language Other Than English
Note the language in the card header. If abstract is in English, proceed with abstract-only.
Do not attempt machine translation; flag for human review.

### Very Long Paper (>30 pages)
Focus on: Abstract, Introduction (full), Related Work (full), Methodology (sections 3-4 typically),
Results (tables and key findings), Conclusion (full). Skip implementation details in excess.

### Contradictory Claims Between Papers
Note contradictions explicitly in the Cross-Paper Analysis section under a subsection
"Conflicting Claims." Include both citations and a sentence on which finding is more credible
(based on dataset size, venue tier, reproducibility).

### Paper Is Actually Not Relevant After Reading
Change status to `rejected` in papers.csv. Note the reason in `gap_notes`.
Do not include it in the narrative synthesis, but mention it briefly in the triage report as
"Examined but excluded: {reason}."

---

## Quality Checklist

Before saving the synthesis:
- [ ] Every paper has a complete extraction card (all 5 sections filled)
- [ ] No card section says "N/A" without explanation
- [ ] The comparison table has consistent column definitions across all rows
- [ ] The narrative synthesis cites all papers in the synthesis set (no orphaned papers)
- [ ] Gap paragraph explicitly links to this paper's contributions (using `{{SYSTEM_NAME}}` from `project/research-focus.md`)
- [ ] papers.csv has been updated with new statuses
- [ ] LaTeX table compiles without errors (verify \multicolumn counts match column count)

---

## Integration with Other Skills

- **paper-search-and-triage** must run first to populate `papers.csv` with `to-read` entries.
- **research-gap-mapper** reads `synthesized` papers from `papers.csv` and the synthesis files
  in `literature/synthesis/`. Run deep-paper-synthesis before running research-gap-mapper for
  the most accurate gap map.
- Narrative synthesis paragraphs are designed to paste directly into the Related Work section
  of the ACL LaTeX paper at `paper/latex/acl_latex.tex`.

---

## Template Quick Reference

Full templates are in `skills/deep-paper-synthesis/references/synthesis-template.md`.
Full LaTeX table patterns are in `skills/deep-paper-synthesis/references/latex-table-patterns.md`.

### Minimal card header format:
```markdown
### [{Title}]({url})
**Authors**: {authors} | **Venue**: {venue} {year} | **arXiv**: {arxiv_id}
**Status**: synthesized | **Relevance Score**: {1-5}
```

### Gap phrase format (for papers.csv gap_notes):
"{This paper}'s key limitation: {limitation}; our work addresses this by {contribution}."
```
