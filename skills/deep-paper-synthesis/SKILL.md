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
version: 4.0.0
tools: Read, Glob, Grep, Bash, Write, Edit, Agent
---

# Deep Paper Synthesis

## What the main agent does in this skill

The main agent is an **orchestrator**, not a reader. Its only jobs are:

1. Read `papers.csv` to get the paper list
2. Ask the user two questions (paper selection + subagent model)
3. Run permission checks
4. Dispatch subagents — one per paper
5. Collect mini-summaries returned by subagents
6. Assign clusters and move files
7. Write `manifest.md`, the LaTeX table, and update `papers.csv`

**The main agent never fetches a URL and never reads a paper.** All paper fetching and
reading happens exclusively inside subagents. This is not a preference — `WebFetch` is not
in the main agent's tool list for this skill (see frontmatter: tools does not include WebFetch).
If you feel the need to fetch a paper to proceed, that is a signal to dispatch a subagent instead.

---

## Output Structure

```
literature/synthesis/{TOPIC}/
  manifest.md                    ← index, cluster map, narrative synthesis, open problems
  {TOPIC}_table.tex              ← ACL LaTeX comparison table
  {cluster_slug}/
    {paper_slug}.md              ← one extraction card per paper
  _pending/                      ← temporary staging dir; deleted after clustering
```

**Naming conventions:**
- `{TOPIC}` — short label for the synthesis batch (e.g., `llm_vuln_repair`). Derived in Step 1.
- `{cluster_slug}` — lowercased underscored cluster name (e.g., `llm_based_repair`).
  Assigned in Step 4 from mini-summaries — subagents write to `_pending/` first.
- `{paper_slug}` — `{firstauthor}_{year}` (e.g., `xia_2023`). Append `a/b` on collision.

---

## Step-by-Step Workflow

### Step 1 — Gather the Paper List

Read `literature/papers.csv`. Filter rows where `status = 'to-read'` and present the list:

> "Found N papers with status 'to-read'. Synthesizing all of them, or a subset?"

If the user provides arXiv IDs or titles directly instead, look them up in `papers.csv` first;
add any missing ones with status `to-read`.

Assign a short `{TOPIC}` label from the paper cluster (e.g., `llm_vuln_repair`).

Get the absolute project root once:
```bash
pwd
```
All paths used in this session are absolute from here.

### Step 2 — Ask the User Two Questions

Ask both in one message:

> "1. Which model should I use for the per-paper reading subagents — haiku (fastest),
>    sonnet (recommended), or opus (best for dense papers)?
>
> 2. Any papers you want to skip or prioritize?"

Record `{subagent_model}` from the answer. This is the only time you ask the user before
dispatching subagents.

### Step 3 — Permission Pre-flight

Subagents inherit the main agent's tool permissions. Verify Write works before dispatching:

```bash
# Write a sentinel file and delete it
echo "ok" > {absolute_synthesis_root}/.write_test && rm {absolute_synthesis_root}/.write_test
```

If this fails, stop and tell the user Write is not permitted. Do not proceed.

You do not need to verify WebFetch here — that is the subagent's concern, not yours.

### Step 4 — Dispatch Per-Paper Subagents

Dispatch one subagent per paper. Each subagent writes its card to:
```
{absolute_synthesis_root}/{TOPIC}/_pending/{paper_slug}.md
```

Clustering happens in Step 5 after all mini-summaries arrive — subagents do not need to know
their final cluster directory. Using `_pending/` as a staging area lets subagents write
immediately without waiting for cluster assignment.

**Subagent configuration:**
- `subagent_type`: `general-purpose`
- `model`: `{subagent_model}`
- Do not use worktree isolation — files must persist in the shared workspace
- Run in **parallel batches of 4–5**; use background execution within each batch

**After each batch**, verify its files arrived before dispatching the next batch:
```bash
ls {absolute_synthesis_root}/{TOPIC}/_pending/
```

Re-dispatch any missing paper before continuing.

#### Subagent Prompt Template

Fill in the bracketed values for each paper:

---
```
You are reading and synthesizing one academic paper.

## Paper details

- Title: {title}
- Authors: {authors}
- Venue: {venue} {year}
- arXiv ID: {arxiv_id}
- PDF URL: {pdf_url}  (fallback: https://arxiv.org/pdf/{arxiv_id})
- Output file (absolute path): {absolute_pending_path}
- Paper slug: {paper_slug}

## Hard rules

1. Write the output file before returning anything. Use the absolute path above exactly.
2. Your response must contain ONLY the mini-summary block below — nothing else.
   Do not include the paper text, card content, or any other material.
3. If the write fails, return only: FAILED: {paper_slug} — {reason}
   Do not paste the card content as a fallback.

## Your task

Step A — Fetch the paper.
  Try the PDF URL first. If unavailable (paywall, 404), fall back to:
  https://arxiv.org/abs/{arxiv_id} or the Semantic Scholar page.
  Mark the card `access: abstract_only` if you could not get the full PDF.

  If the paper is very long (>30 pages), focus on:
  Abstract, Introduction, Related Work, core Methodology sections, Results tables, Conclusion.

Step B — Write the extraction card to the output file using this format:

---
title: "{title}"
authors: "{authors}"
venue: "{venue} {year}"
arxiv_id: "{arxiv_id or N/A}"
url: "{canonical_url}"
paper_slug: "{paper_slug}"
suggested_cluster: "{your suggested cluster slug, e.g. llm_based_repair}"
relevance_score: {1-5}
access: {full_pdf | abstract_only}
status: synthesized
---

# [{title}]({canonical_url})
**Authors**: {authors} | **Venue**: {venue} {year}

## Problem Statement
{2-4 sentences: precise problem, why it matters, research question}

## Methodology / Approach
- **System/approach**: {one sentence}
- **Core innovation**: {what makes this different}
- **Model/technique**: {LLM name + prompting style, or classical method type}
- **Oracle/verifier**: {how correctness is verified}
- **Datasets/benchmarks**: {names}

## Main Results
| Metric | This Paper | Best Baseline |
|---|---|---|
| {primary metric} | {X} | {Y — Baseline Name} |

**Key finding**: {1 sentence with the headline number}

## Limitations
- {scope limitation}
- {oracle/methodology limitation}
- {scale or generalization limitation}

## Relation to Prior Work
{1-3 sentences: gap this paper fills; what it does not address}
**Gap phrase**: "{This paper}'s key limitation: {X}; future work should address {Y}."
**Cite in**: {Related Work | Results | Methods | All | Not cited}

---

Step C — Verify: read back the first 3 lines of the file you wrote.
  If the read fails, report FAILED — do not paste the content.

Step D — Return only this mini-summary. Nothing else.

## Mini-Summary

paper_slug: {paper_slug}
title: {title}
authors: {first author et al.}
venue: {venue} {year}
suggested_cluster: {your suggested cluster slug}
relevance: {1-5}
core_approach: {1 sentence}
key_result: {1 sentence with number and benchmark}
main_limitation: {1 sentence}
gap_phrase: "{gap phrase}"
cite_in: {sections}
access: {full_pdf | abstract_only}
written_to: {absolute_pending_path}
```
---

### Step 5 — Cluster Assignment and File Placement

All subagents have returned. Now assign clusters using the mini-summaries — no file reading needed.

1. Look at each `suggested_cluster` field across all mini-summaries.
2. Identify 3–5 coherent cluster names. You may rename suggested clusters to better names,
   merge similar ones, or split one if papers divide cleanly. Typical cluster types:
   - Core method papers (the primary technique family)
   - Classical / baseline approaches
   - Benchmarks and datasets
   - Survey / empirical studies
   - Adjacent methods from neighboring sub-fields
3. Assign each paper to its final `{cluster_slug}`.
4. Move files from `_pending/` to their cluster directories:

```bash
mkdir -p {absolute_synthesis_root}/{TOPIC}/{cluster_slug}
mv {absolute_synthesis_root}/{TOPIC}/_pending/{paper_slug}.md \
   {absolute_synthesis_root}/{TOPIC}/{cluster_slug}/{paper_slug}.md
```

5. After all files are moved, remove the staging directory:
```bash
rmdir {absolute_synthesis_root}/{TOPIC}/_pending
```

6. Update the YAML front matter `cluster` field in each file with its final cluster assignment:
   read the file, replace `suggested_cluster` with `cluster: {final_cluster_slug}`, rewrite.

### Step 6 — Cross-Paper Analysis (from mini-summaries only)

Work only from the mini-summaries in your context. Do not read the card files.

**Idea Evolution Timeline:** Using `venue` years and `core_approach` fields, trace how the
dominant technique emerged. Write 3–4 sentences covering what preceded it, when it shifted,
and what the current state of the art is. Goes in `manifest.md`.

**Open Problems:** Collect all `main_limitation` values. Group limitations that appear in 3+
papers — those are structural field gaps. Note which limitations our work addresses.
Goes in `manifest.md`.

**Conflicting Claims:** If any `key_result` values directly contradict each other, note both
with citations and a one-sentence judgment on credibility. Goes in `manifest.md` (omit section
if none).

### Step 7 — Write Narrative Synthesis (from mini-summaries only)

Write 3–5 paragraphs for `manifest.md`. Use the `core_approach`, `key_result`, and
`main_limitation` fields from mini-summaries. Do not re-read card files.

**Paragraph 1 — Chronological arc:** Trace from earliest to most recent using `venue` years.
Cite inline: `\citet{}` for subject, `\citep{}` for parenthetical.

**Paragraph 2 — Thematic synthesis:** One cluster per 2–3 sentences, citing key papers.

**Paragraph 3 — Zoom in:** Focus on the cluster most relevant to the paper being written.
Identify the shared gap across that cluster.

**Paragraph 4 — Gap and positioning (required):**
> Despite progress in [field], no existing work [gap 1]. Our work addresses this by [method].

**Paragraph 5 (optional):** If evaluation setups differ significantly across papers, compare
benchmark characteristics (size, bug type, oracle strength).

Target 400–600 words. Academic English, past tense for prior work, present for our claims.

### Step 8 — Write manifest.md and LaTeX table

Write `{absolute_synthesis_root}/{TOPIC}/manifest.md`:

```markdown
# Synthesis Manifest: {TOPIC}
**Date**: {DATE} | **Papers**: {N} | **Clusters**: {K}

## Papers in This Synthesis

### {Cluster Display Name} (`{cluster_slug}/`)
- [{Title}](./{cluster_slug}/{paper_slug}.md) — {Authors}, {Venue} {Year} | Relevance: {score}/5

### {Cluster Display Name} (`{cluster_slug}/`)
- ...

## Comparison Table
See [{TOPIC}_table.tex](./{TOPIC}_table.tex)

## Cross-Paper Analysis

### Idea Evolution Timeline
{paragraph from Step 6}

### Open Problems
{bullet list from Step 6}

### Conflicting Claims
{list from Step 6; omit if none}

## Narrative Synthesis
{paragraphs from Step 7}

---

## Examined but Excluded
{papers rejected after reading; omit if none}
- {Title} — {reason}
```

Write the LaTeX comparison table to `{absolute_synthesis_root}/{TOPIC}/{TOPIC}_table.tex`.
Use the template from `references/latex-table-patterns.md`. Derive axes from mini-summary
fields: `core_approach`, `key_result`, `access`. Standard column groups:
- Approach (paper, venue, year) · Problem setting · Method · Evaluation

### Step 9 — Update papers.csv

For each synthesized paper, update `literature/papers.csv`:
- `status`: `to-read` → `synthesized` (or `rejected` if excluded after reading)
- `gap_notes`: the `gap_phrase` from the mini-summary (1 sentence, CSV-escaped)

Read the CSV, update only the relevant rows, preserve row order, overwrite.

---

## Quality Checklist

- [ ] `_pending/` directory is gone (all files moved to cluster dirs)
- [ ] Every expected paper file exists under its cluster dir
- [ ] Each paper file has `cluster:` field set to its final cluster (not `suggested_cluster`)
- [ ] `manifest.md` links resolve to existing files
- [ ] Narrative cites all papers (no orphans)
- [ ] Gap paragraph references this paper's contributions
- [ ] `papers.csv` updated with status and gap_notes
- [ ] LaTeX table column counts consistent

---

## Integration with Other Skills

- **paper-search-and-triage** populates `papers.csv` with `to-read` entries before this runs.
- **research-gap-mapper** reads `manifest.md` for orientation; loads individual card files on
  demand. Run deep-paper-synthesis before research-gap-mapper.
- **write-related-work** reads the narrative from `manifest.md` and navigates cluster dirs.
- Narrative paragraphs paste directly into `paper/latex/acl_latex.tex` Related Work section.
