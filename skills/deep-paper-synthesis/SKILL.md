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
version: 3.0.0
tools: Read, Glob, Grep, Bash, WebSearch, WebFetch, Write, Edit, Agent
---

# Deep Paper Synthesis

This skill performs deep reading and synthesis of academic papers, producing:
- **One `.md` file per paper** containing the extraction card
- **One directory per thematic cluster** grouping the paper files
- **One `manifest.md`** at the topic root — the lightweight index with narrative synthesis and
  cross-paper analysis (the only file an AI needs to load for orientation)
- **One `_table.tex`** containing the ACL-format LaTeX comparison table

## Context Management Architecture

Reading many papers in one context fills up quickly. This skill avoids that with a
**two-phase approach**:

**Phase A — Clustering (main agent, abstracts only)**
Fetch only the abstract for each paper. Assign clusters and slugs. The main agent never reads
full PDFs.

**Phase B — Full synthesis (one subagent per paper, run in parallel batches)**
Each subagent receives one paper assignment. It fetches the full PDF, writes the extraction card
file directly to disk, and returns only a compact **mini-summary** (~300 tokens) to the main
agent. The main agent's context never holds raw paper content.

After all subagents return, the main agent holds N × ~300 tokens of mini-summaries — regardless
of how many papers there are — and uses these to write the manifest, table, and narrative.

## Output Structure

```
literature/synthesis/{TOPIC}/
  manifest.md                    ← index, cluster map, narrative synthesis, open problems
  {TOPIC}_table.tex              ← ACL LaTeX comparison table
  {cluster_slug}/
    {paper_slug}.md              ← one extraction card per paper
    {paper_slug}.md
  {cluster_slug}/
    {paper_slug}.md
  ...
```

**Naming conventions:**
- `{TOPIC}` — short label for the synthesis batch (e.g., `llm_vuln_repair`, `apr_baselines`).
  Derived in Step 1. Becomes the directory name under `literature/synthesis/`.
- `{cluster_slug}` — lowercased, underscored cluster name derived from the papers themselves
  (e.g., `llm_based_repair`, `classical_apr`, `benchmarks`). Derived in Step 4a.
- `{paper_slug}` — `{firstauthor}_{year}` form, lowercased (e.g., `xia_2023`,
  `sobania_2023`). If two papers share the same slug, append a letter: `xia_2023a`, `xia_2023b`.

**Updated tracker:** `literature/papers.csv` (status → `synthesized`)

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
**directory name** for all synthesis outputs under `literature/synthesis/{TOPIC}/`.

### Step 2 — Abstract Pass: Cluster Assignment (main agent)

The main agent fetches only the **abstract** for each paper — not the full PDF. This is fast
and keeps the main context small.

For each paper:
1. If `papers.csv` has an `abstract` column already populated, use it directly.
2. Otherwise fetch the arXiv abstract page: `https://arxiv.org/abs/{arxiv_id}` — parse just
   the abstract paragraph. For non-arXiv papers, fetch the landing page at `url`.
3. If the abstract is already in `papers.csv`, skip the fetch.

After collecting all abstracts, perform **thematic clustering** (see Step 4a below for the
clustering logic). Derive `{cluster_slug}` and `{paper_slug}` for every paper before
dispatching any subagents, since subagents need to know their output path.

**Output of this step:** a table mapping each paper to its cluster_slug, paper_slug, and
**absolute** output path. Determine the absolute path with:
```bash
pwd  # run once to get the project root
```

Example (if project root is `/workspace/myproject`):

| paper | cluster_slug | paper_slug | absolute_output_path |
|---|---|---|---|
| Xia et al. 2023 | llm_based_repair | xia_2023 | /workspace/myproject/literature/synthesis/llm_vuln_repair/llm_based_repair/xia_2023.md |
| ... | | | |

Always pass **absolute paths** to subagents. Relative paths are the most common cause of
silent write failures when a subagent's working directory differs from the main agent's.

### Step 3 — Dispatch Per-Paper Subagents (parallel batches)

#### 3a. Pre-flight: ask the user for subagent model

Before dispatching any subagents, ask the user:

> "Which model should I use for the per-paper subagents — haiku (fastest, cheapest),
> sonnet (recommended default), or opus (best for dense or complex papers)?"

Record the answer as `{subagent_model}` and use it for every subagent in this session.

#### 3b. Pre-flight: verify permissions

Subagents inherit the same tool permissions as the main agent. Before dispatching, confirm the
main agent itself can exercise the two critical operations:

1. **WebFetch** — attempt a lightweight fetch (e.g., the arXiv abstract page for the first
   paper). If it is blocked, stop and tell the user:
   > "WebFetch is not permitted in this session. Paper subagents will not be able to fetch
   > PDFs. Please allow WebFetch and restart, or provide pre-downloaded PDF paths."

2. **Write** — attempt to write a small sentinel file at the synthesis directory root
   (e.g., `{absolute_synthesis_dir}/.write_test`) and then delete it. If Write is blocked,
   stop and tell the user:
   > "Write is not permitted in this session. Paper subagents will not be able to save
   > extraction cards. Please allow Write and restart."

Only proceed to dispatching subagents if both checks pass.

#### 3c. Dispatch

Dispatch one subagent per paper using the Agent tool with:
- `subagent_type`: `general-purpose` (requires Read, Write, WebFetch, Bash)
- `model`: `{subagent_model}` as chosen by the user above
- `isolation`: do **not** use worktree isolation — files must persist in the shared workspace
- Run subagents in **parallel batches of 4–5**. Do not run all subagents simultaneously if
  N > 5. Use background execution where supported so an entire batch runs in parallel.
  After each batch completes, run the main agent gate (verify files on disk) before dispatching
  the next batch.

Each subagent:
1. Fetches the full paper PDF (or falls back to abstract-only if paywalled)
2. Produces the complete extraction card
3. Writes the card file to its assigned `output_path`
4. Returns a **mini-summary** to the main agent (see format below)

**The main agent must never read the full paper content itself.** All raw paper content stays
inside the subagent's context and is discarded after the subagent writes its file.

#### Subagent Prompt Template

Use this exact structure when constructing the prompt for each paper's subagent. Fill in the
bracketed values:

---
```
You are synthesizing one academic paper as part of a larger literature review.

## Your Assignment

- **Title**: {title}
- **Authors**: {authors}
- **Venue**: {venue} {year}
- **arXiv ID**: {arxiv_id}
- **PDF URL**: {pdf_url}  (try https://arxiv.org/pdf/{arxiv_id} if no direct URL)
- **Output file (absolute path)**: {absolute_output_path}
- **Cluster**: {cluster_slug}
- **Paper slug**: {paper_slug}

## Hard constraints — read before doing anything else

- WRITE THE FILE BEFORE RETURNING. Do not return until the Write tool has confirmed success.
- DO NOT include the paper text, PDF content, or full extraction card in your response.
  Your response must contain ONLY the mini-summary block defined below.
- If you cannot write the file for any reason, return ONLY:
  `FAILED: {paper_slug} — {reason}` and nothing else. Do not paste the card content as a fallback.
- Use the absolute path exactly as given above. Do not change it or use a relative path.

## Instructions

1. Fetch the full paper PDF using WebFetch at the PDF URL above. If the PDF is unavailable
   (paywalled), fetch the Semantic Scholar page or arXiv abstract page instead and mark the
   card `**Access**: ABSTRACT ONLY`.

2. Write the extraction card to the absolute path above using this exact format:

---
title: "{title}"
authors: "{authors}"
venue: "{venue} {year}"
arxiv_id: "{arxiv_id}"
url: "{canonical_url}"
cluster: "{cluster_slug}"
secondary_clusters: []
paper_slug: "{paper_slug}"
relevance_score: {1-5}
status: synthesized
---

# [{title}]({canonical_url})
**Authors**: {authors} | **Venue**: {venue} {year} | **arXiv**: {arxiv_id}
**Cluster**: {cluster_slug} | **Relevance**: {score}/5

## Problem Statement
{2-4 sentences: precise problem, why it matters, research question}

## Methodology / Approach
{2-5 bullets: architecture, core innovation, LLM/model used, oracle/verifier, datasets}

## Main Results
| Metric | This Paper | Best Baseline | Notes |
|---|---|---|---|
| {primary metric} | {X} | {Y (Baseline)} | |

**Key finding**: {1 sentence with the headline number}

## Limitations
- {scope limitation}
- {oracle/methodology limitation}
- {scale or generalization limitation}
- {threats to validity}

## Relation to This Work
{1-3 sentences: supports/contradicts/extends our claims; gap our work fills; where to cite}

**Gap phrase**: "{This paper}'s key limitation: {limitation}; our work addresses this by {contribution}."
**Cite in**: {Related Work | Results | Methods | All sections | Not cited}

---

3. After the Write tool confirms the file was written, verify it exists by reading it back
   with the Read tool (first 5 lines only). If Read fails, report FAILED — do not paste content.

4. Return ONLY the mini-summary below. Do not include the card, the paper text, or anything
   else in your response.

## Mini-Summary

- **paper_slug**: {paper_slug}
- **title**: {title}
- **authors**: {first author} et al.
- **venue**: {venue} {year}
- **cluster**: {cluster_slug}
- **relevance**: {1-5}
- **core_approach**: {1 sentence — what the system does}
- **key_result**: {1 sentence — headline number and benchmark}
- **main_limitation**: {1 sentence}
- **gap_phrase**: "{gap phrase from card}"
- **cite_in**: {sections}
- **access**: {FULL PDF | ABSTRACT ONLY}
- **written_to**: {absolute_output_path}
- **verified**: yes
```
---

#### Main agent gate after all subagents return

**Before proceeding to Step 4**, the main agent must verify every paper file is on disk:

```bash
ls {absolute_synthesis_dir}/{TOPIC}/*/
```

For each expected paper file, confirm it appears in the output. If any file is missing:
1. Check if the subagent returned `FAILED: ...` — if so, re-dispatch that paper's subagent alone.
2. If the subagent returned a mini-summary but the file is absent, the write silently failed —
   re-dispatch that paper's subagent alone.
3. If a subagent returned the card content in its response body instead of writing to disk,
   write the content to the correct path yourself using the Write tool, then continue.
   Do not let this content remain in the conversation context any longer than necessary.

Do not proceed to Step 4 until all paper files are confirmed on disk.

### Step 4 — Cross-Paper Analysis (from mini-summaries)

By this point all subagents have returned their mini-summaries. The main agent works
**only from mini-summaries** for all cross-paper analysis — never reading the card files.

#### 4a. Thematic Clustering

Clustering was done in Step 2 from abstracts. Verify the assignments are consistent with
what subagents reported in their mini-summaries (subagents may suggest a better cluster after
reading the full paper). Update any cluster assignments if the subagent's suggestion is better.
If a paper moves clusters, rename its file:
```bash
mv literature/synthesis/{TOPIC}/{old_cluster}/{paper_slug}.md \
   literature/synthesis/{TOPIC}/{new_cluster}/{paper_slug}.md
```

Cluster naming guidance — derive names from the papers themselves:

1. **Core Method Papers** — papers proposing the primary technique used in each cluster
2. **Baseline / Classical Approaches** — non-ML or earlier-generation approaches
3. **Benchmarks and Datasets** — papers that primarily contribute evaluation infrastructure
4. **Survey / Empirical Studies** — papers analyzing the state of the field
5. **Adjacent Methods** — related techniques from neighboring sub-fields

#### 4b. Idea Evolution Timeline

From mini-summaries, trace the chronological progression of key ideas:
- When did the dominant technique first appear?
- What preceded it, and what did it supersede?
- What was the state of the art immediately before the paper being written?

Write a 3-4 sentence paragraph. This goes in `manifest.md`.

#### 4c. Open Problems Identification

From the `main_limitation` fields in all mini-summaries, enumerate structural gaps:
- Which limitations appear in 3+ papers? (structural gaps in the field)
- Which are addressed by some papers but not others?
- What does no paper address? (the gap this paper fills)

This goes in `manifest.md`.

### Step 5 — Generate ACL Comparison Table

Build a LaTeX comparison table using the mini-summaries (do not read paper files).
Derive comparison axes from the `core_approach`, `key_result`, and `main_limitation` fields,
and from `project/research-focus.md` (if it exists).

**Always include:**
- Paper (short citation form, e.g., \citet{Author2024})
- Venue + Year
- Our Approach? (checkmark ✓ or dash —)

**Domain-specific axes** — select based on what differentiates papers (typically 4-6 axes):
- Input type / language / modality
- Task type or problem setting
- Core technique / model family (LLM, classical ML, rule-based, etc.)
- Evaluation oracle or verification method
- Benchmark / dataset used
- Primary metric reported

Use the LaTeX table template from `references/latex-table-patterns.md`.

Draft the table now; it will be written to disk in Step 8.

Suggested column grouping:
- Group 1: Approach (paper, venue, year)
- Group 2: Problem Setting (input type, task type)
- Group 3: Method (technique, model)
- Group 4: Evaluation (benchmark, metric)

### Step 6 — Write Narrative Synthesis

Write 3-5 paragraphs of narrative synthesis from the mini-summaries. This content goes in
`manifest.md`. Do not re-read the paper card files — the mini-summaries contain everything
needed for the narrative.

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

### Step 7 — Write manifest.md

Save `literature/synthesis/{TOPIC}/manifest.md` with this structure:

```markdown
# Synthesis Manifest: {TOPIC}
**Date**: {DATE} | **Papers**: {N} | **Clusters**: {K}
**Skill version**: deep-paper-synthesis 3.0.0

## Papers in This Synthesis

### {Cluster Display Name} (`{cluster_slug}/`)
- [{Title}](./{cluster_slug}/{paper_slug}.md) — {Authors}, {Venue} {Year} | Relevance: {score}/5
- ...

### {Cluster Display Name} (`{cluster_slug}/`)
- ...

## Comparison Table
See [{TOPIC}_table.tex](./{TOPIC}_table.tex)

## Cross-Paper Analysis

### Idea Evolution Timeline
{3-4 sentence paragraph from Step 4b}

### Open Problems
{bullet list or table from Step 4c}

### Conflicting Claims
{list contradictions; omit section if none}

## Narrative Synthesis
{3-5 paragraphs from Step 6}

---

## Examined but Excluded
{papers rejected after reading; omit section if none}
- {Title} — {reason}
```

The manifest is the entry point for any AI working with this literature set. Individual paper
files are loaded on demand when detail about a specific paper is needed.

### Step 8 — Write the LaTeX Table

Paper files were already written by subagents in Step 3. This step only writes the table.

**LaTeX table path:** `literature/synthesis/{TOPIC}/{TOPIC}_table.tex`

Verify all paper files exist before writing the table:
```bash
ls literature/synthesis/{TOPIC}/*/  # confirm cluster dirs and paper files are present
```

If any paper file is missing, re-dispatch its subagent before writing the manifest.

### Step 9 — Update papers.csv

For each paper that was successfully synthesized (even if abstract-only), update its `status`
from `to-read` to `synthesized` in `literature/papers.csv`. Take the `gap_notes` value from
the `gap_phrase` field in each paper's mini-summary.

To update the CSV:
1. Read the full CSV content.
2. For each synthesized paper's row, change `status` from `to-read` to `synthesized`.
3. Update `gap_notes` with the synthesis finding (1 sentence, CSV-escaped).
4. Overwrite the file. Do NOT change the sort order; preserve the existing row order.

---

## Handling Edge Cases

### Paper Without Open-Access PDF
Use abstract + title only. Mark the extraction card:
```
**Access**: ABSTRACT ONLY — No open-access PDF found. Retrieve via: {url}
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
Note contradictions in `manifest.md` under the "Conflicting Claims" subsection.
Include both citations and a sentence on which finding is more credible
(based on dataset size, venue tier, reproducibility).

### Paper Is Actually Not Relevant After Reading
Change status to `rejected` in papers.csv. Note the reason in `gap_notes`.
Do not create a paper file for it. Add a brief note in the "Examined but Excluded" section of
`manifest.md` with the reason.

### Re-synthesizing a Single Paper
Overwrite only that paper's `.md` file. Update the paper's entry in `manifest.md` (relevance
score, cluster assignment if changed). Do not regenerate the full table or narrative unless
requested.

---

## Quality Checklist

Before finalizing:
- [ ] All subagents have returned mini-summaries (no paper is missing)
- [ ] Every paper file exists on disk at its assigned path (`ls literature/synthesis/{TOPIC}/*/`)
- [ ] Each paper file has complete YAML front matter
- [ ] No card section says "N/A" without explanation
- [ ] All paper files are placed under the correct `{cluster_slug}/` directory
- [ ] `manifest.md` lists every paper with a working relative link to its file
- [ ] The comparison table has consistent column definitions across all rows
- [ ] The narrative synthesis cites all papers in the synthesis set (no orphaned papers)
- [ ] Gap paragraph explicitly links to this paper's contributions (using `{{SYSTEM_NAME}}` from `project/research-focus.md`)
- [ ] papers.csv has been updated with new statuses and gap_notes
- [ ] LaTeX table compiles without errors (verify \multicolumn counts match column count)

---

## Integration with Other Skills

- **paper-search-and-triage** must run first to populate `papers.csv` with `to-read` entries.
- **research-gap-mapper** reads `synthesized` papers from `papers.csv` and the synthesis
  directory. Point it at `literature/synthesis/{TOPIC}/manifest.md` for orientation, and at
  individual paper files for detail. Run deep-paper-synthesis before research-gap-mapper.
- **write-related-work** reads the narrative synthesis from `manifest.md` and uses the cluster
  directory structure to navigate individual papers.
- Narrative synthesis paragraphs in `manifest.md` are designed to paste directly into the
  Related Work section of the ACL LaTeX paper at `paper/latex/acl_latex.tex`.

---

## Template Quick Reference

Full templates are in `skills/deep-paper-synthesis/references/synthesis-template.md`.
Full LaTeX table patterns are in `skills/deep-paper-synthesis/references/latex-table-patterns.md`.

### Minimal paper file header:
```markdown
---
title: "{Full Paper Title}"
authors: "{authors}"
venue: "{Venue} {Year}"
arxiv_id: "{arxiv_id or N/A}"
url: "{url}"
cluster: "{cluster_slug}"
paper_slug: "{paper_slug}"
relevance_score: {1-5}
status: synthesized
---
```

### Manifest paper list entry:
```markdown
- [{Title}](./{cluster_slug}/{paper_slug}.md) — {Authors}, {Venue} {Year} | Relevance: {score}/5
```

### Gap phrase format (for papers.csv gap_notes):
```
"{This paper}'s key limitation: {limitation}; our work addresses this by {contribution}."
```
