---
name: paper-search-and-triage
description: |
  Use this skill whenever the user wants to discover, collect, or triage academic papers.
  Trigger on phrases like: "find new papers", "update literature tracker", "search for related work",
  "what papers should I read", "discover papers on [topic]", "check what's new on arxiv",
  "find recent work on LLM vulnerability repair", "search semantic scholar for papers on [topic]",
  "are there any new papers about automated patching", "pull recent papers on LLMs and security",
  "update my reading list", "what's been published recently on [area]".
  This skill is the front door to the literature intelligence workflow. Run it whenever new papers
  may have appeared, before writing related work, or when preparing for a literature review meeting.
version: 1.0.0
tools: Read, Glob, Grep, Bash, WebSearch, WebFetch, Write, Edit
---

# Paper Search and Triage

This skill discovers relevant papers from Semantic Scholar, arXiv, and ACL Anthology, deduplicates
them against the living tracker at `literature/papers.csv`, scores them for relevance, and produces
a triage report. It is the entry point for the literature intelligence workflow.

## Output Locations

| Output | Path |
|---|---|
| Living paper tracker | `literature/papers.csv` |
| Research focus definition | `literature/research_focus.md` |
| Triage report (dated) | `literature/triage_report_YYYYMMDD.md` |
| BibTeX additions (optional) | bibliography path from `project/paper-paths.md` |

---

## Step-by-Step Workflow

### Step 1 — Load Research Focus

**Check for project config first:**

```
Read: project/research-focus.md
```

If `project/research-focus.md` exists, use its Core Problem, Approach, and Evaluation Context
as the research focus. Extract `system_name` → `{{SYSTEM_NAME}}`.

If `project/research-focus.md` does NOT exist, check `literature/research_focus.md` as a fallback.
If neither exists, stop and tell the user:

> "I need a research focus to search for papers. Please run `project-init` first to create
> `project/research-focus.md`, or describe the research focus here in 2-3 sentences:
> - What core problem does the paper address?
> - What is the approach or method?
> - What benchmarks or datasets does it use?"

If the user provides the focus inline, save it to `literature/research_focus.md` but also
recommend running `project-init` to set up the full project config.

### Step 2 — Extract Search Keywords

From the research focus, ask Claude to derive 5-8 search keyword queries that maximize coverage
of the relevant literature. Do NOT use hardcoded domain-specific queries.

**Derivation prompt** (run internally):
> "Given this research focus: [Core Problem + Approach + Evaluation Context], generate 5-8
> search queries for academic paper search. Each query should be 3-6 words. Cover:
> (1) the core task/problem, (2) the method/approach, (3) the evaluation context,
> (4) adjacent methods the paper builds on or competes with."

Present the derived queries to the user and confirm before searching:
> "I will search for papers using these queries. Add or remove any before I proceed:
> 1. [query 1]
> 2. [query 2]
> ...
> (Type 'ok' to proceed)"

### Step 3 — Query Semantic Scholar API

Use WebFetch to call the Semantic Scholar Graph API. Full API reference is in
`skills/paper-search-and-triage/references/semantic-scholar-api.md`.

Base endpoint:
```
https://api.semanticscholar.org/graph/v1/paper/search
```

Construct a URL for each keyword query derived in Step 2. Request these fields:
`paperId,title,authors,year,venue,citationCount,openAccessPdf,abstract,externalIds`

URL pattern (substitute your derived query for `QUERY_TERMS`):

```
https://api.semanticscholar.org/graph/v1/paper/search?query=QUERY_TERMS&fields=paperId,title,authors,year,venue,citationCount,openAccessPdf,abstract,externalIds&limit=20&publicationDateOrYear=START_DATE:
```

Where `QUERY_TERMS` is one of the keyword queries derived in Step 2 (URL-encoded, spaces → `+`),
and `START_DATE` is (today's year − 2)-01-01 to cover the last 24 months.

Set `publicationDateOrYear` to cover the last 24 months from today's date. Compute the start date
as (current year - 2)-MM-DD.

Rate limit: 100 requests per 5 minutes without an API key. If you exceed this, pause 60 seconds.
See the API reference for authenticated usage.

For each paper returned, extract:
- `paperId` → use as `arxiv_id` if `externalIds.ArXiv` exists, else use `paperId`
- `title`
- `authors[].name` → join first 3 authors with "; " then append "et al." if more than 3
- `year`
- `venue`
- `abstract` → truncate to 300 characters for the `abstract_snippet` field
- `openAccessPdf.url` → use as `url`
- `externalIds.DOI` → use as `doi`

### Step 4 — Query arXiv API

Use WebFetch to search arXiv directly. Choose the most relevant arXiv categories based on
the research domain from `project/research-focus.md` (e.g., cs.CR for security, cs.SE for
software engineering, cs.CL for NLP, cs.LG for machine learning).

The arXiv Atom feed endpoint pattern:

```
http://export.arxiv.org/api/query?search_query=SEARCH_TERMS&start=0&max_results=30&sortBy=submittedDate&sortOrder=descending
```

Where `SEARCH_TERMS` is constructed from your Step 2 queries using arXiv syntax, e.g.:
`cat:cs.CR+AND+ti:KEYWORD1+AND+KEYWORD2`

Derive the category and keyword terms from `project/research-focus.md` — do not hardcode
domain-specific keywords. Run one arXiv query per Step 2 keyword query.

Parse the Atom XML response:
- `<entry><id>` → extract the arXiv ID (e.g., `2401.12345`)
- `<entry><title>` → paper title
- `<entry><author><name>` → authors
- `<entry><published>` → year
- `<entry><summary>` → abstract
- Set `venue` = "arXiv" for all arXiv-sourced papers

arXiv URL format: `https://arxiv.org/abs/{arxiv_id}`
PDF URL format: `https://arxiv.org/pdf/{arxiv_id}`

### Step 5 — Query ACL Anthology

Use WebFetch to search ACL Anthology when the research domain has NLP/language model components.
Derive search terms from the Step 2 keyword queries:

```
https://aclanthology.org/search/?q=KEYWORD_QUERY_1
https://aclanthology.org/search/?q=KEYWORD_QUERY_2
```

Use 2–3 of your derived keyword queries (URL-encoded). Focus on queries that capture
the NLP/code/LLM aspect of the work, since ACL Anthology covers NLP, code, and
language model papers that security-focused search engines may miss.

ACL Anthology papers use ACL IDs (e.g., `2024.acl-long.123`). Extract:
- ACL ID from the URL slug
- Title, authors, year, venue (e.g., ACL, EMNLP, NAACL, EACL)
- Abstract if shown on the page
- PDF link (usually `https://aclanthology.org/{acl-id}.pdf`)

### Step 6 — Deduplicate Against Existing Tracker

Load `literature/papers.csv` if it exists. Build a deduplication set:

```python
# Pseudocode for deduplication logic
seen = set()
for row in existing_csv:
    key1 = normalize_title(row['title'])   # lowercase, strip punctuation
    key2 = row['arxiv_id'].strip().lower()
    key3 = row['doi'].strip().lower() if row['doi'] else ''
    seen.add(key1)
    if key2: seen.add(key2)
    if key3: seen.add(key3)

# For each candidate
def is_duplicate(candidate):
    t = normalize_title(candidate['title'])
    a = candidate.get('arxiv_id', '').lower()
    d = candidate.get('doi', '').lower()
    return t in seen or (a and a in seen) or (d and d in seen)
```

Title normalization: lowercase, remove punctuation, collapse whitespace, remove stop words
("the", "a", "an", "of", "for", "in", "on", "with", "and", "or").

Only proceed with candidates that are NOT in the deduplication set.

### Step 7 — Score Relevance (1-5)

Before scoring, check if `literature/relevance-rubric.md` exists:
```bash
ls literature/relevance-rubric.md 2>/dev/null
```

If it exists, read it and use the rubric defined there.

If it does NOT exist, **generate a domain-specific rubric** from `project/research-focus.md`:

Derive a 1-5 rubric by asking:
- Score 5: Paper directly addresses the **same task** with a **similar method** on a **related benchmark**
- Score 4: Paper addresses the same task with different method, OR same method on different task
- Score 3: Paper is adjacent — different task but shares key techniques, datasets, or evaluation design
- Score 2: Broadly related — same general area but different focus
- Score 1: Tangentially related — cited by related papers but not directly relevant

Write the derived rubric to `literature/relevance-rubric.md` with examples drawn from the
research focus (not hardcoded examples from another project). The rubric will be reused on
subsequent runs.

For each candidate paper, assign a `relevance_score` using the rubric and write a 1-sentence
`gap_notes` entry describing what the paper contributes relative to this work's gaps.
Example: "Addresses the same task but uses Java, not the target language; no matching oracle type."

Set `status` = "new" for all newly added papers.

### Step 8 — Append to papers.csv

If `literature/papers.csv` does not exist, create it with the header row:

```
arxiv_id,title,authors,year,venue,abstract_snippet,relevance_score,gap_notes,status,url,doi
```

Append each new paper as a properly escaped CSV row. Sort all rows by `relevance_score` descending,
then by `year` descending. Do not modify existing rows except to re-sort. Overwrite the file with
the sorted result.

CSV schema details are in `skills/paper-search-and-triage/references/csv-schema.md`.
Venue tier reference is in `skills/paper-search-and-triage/references/venue-tiers.md`.

### Step 9 — Generate Triage Report

Write `literature/triage_report_YYYYMMDD.md` (use today's actual date):

```markdown
# Literature Triage Report — YYYY-MM-DD

## Summary
- Queries run: N
- New papers found: N
- Duplicates filtered: N
- Total in tracker: N

## Top 5 Recommended Reads

### 1. [Title] (Score: 5)
- **Authors**: ...
- **Venue**: ... (YEAR)
- **arXiv/DOI**: ...
- **Why read**: <1 sentence from gap_notes>
- **Abstract**: <abstract_snippet>

### 2. [Title] (Score: 4)
...

## Venue Distribution

| Venue | Count | Tier |
|---|---|---|
| arXiv | N | 3 |
| ACL 2024 | N | 1 |
| CCS 2023 | N | 1 |
| ... | | |

## Gap Themes Observed

1. **[Theme Name]**: <2-3 sentences describing a cluster of gaps seen across multiple papers>
2. **[Theme Name]**: ...
3. **[Theme Name]**: ...

## New Papers by Relevance Score

| Score | Title | Authors | Venue | Year | Status |
|---|---|---|---|---|---|
| 5 | ... | ... | ... | ... | new |
| 4 | ... | ... | ... | ... | new |
...

## Action Items
- [ ] Promote papers with score 5 to "to-read" status
- [ ] Check PDF availability for top papers before synthesis session
- [ ] Run deep-paper-synthesis on promoted papers
```

### Step 10 — Promote Papers to "to-read"

Ask the user:

> "These are the top recommended papers. Which would you like to promote to 'to-read' status?
> You can say 'all score-5', 'papers 1, 3, and 4', or list arxiv IDs."

Update `status` field in `papers.csv` for the selected papers from "new" to "to-read".

### Step 11 — Optional BibTeX Export

If the user says yes to adding BibTeX entries, or if any promoted papers lack BibTeX in
the bibliography file (path from `project/paper-paths.md`, fallback to `paper/latex/custom.bib`),
offer to add entries.

For each paper to add, construct a BibTeX entry:

```bibtex
@article{AuthorYEARkeyword,
  title     = {Full Paper Title},
  author    = {Last, First and Last2, First2 and Last3, First3},
  year      = {2024},
  journal   = {arXiv preprint arXiv:2401.12345},
  url       = {https://arxiv.org/abs/2401.12345},
  eprint    = {2401.12345},
  archivePrefix = {arXiv},
  primaryClass  = {cs.CR}
}
```

For conference papers use `@inproceedings` with `booktitle`. Check `paper/latex/custom.bib` first
to avoid duplicate citation keys. Append new entries at the end of the file.

---

## Error Handling

| Situation | Action |
|---|---|
| Semantic Scholar returns 429 (rate limit) | Wait 60 seconds, then retry |
| API returns empty results for a query | Log query in triage report, try a rephrased variant |
| PDF URL not available | Set `url` to the abstract page URL instead |
| `literature/papers.csv` is malformed | Report the error with the problematic row; do not overwrite |
| User has no `research_focus.md` | Prompt user to describe focus before proceeding |
| arXiv API timeout | Skip arXiv for that query, note in report |

---

## Quick Reference: CSV Row Construction

Given a Semantic Scholar result object, construct the CSV row as follows:

```
arxiv_id  = externalIds.ArXiv if present, else paperId
title     = title (escape commas with quotes)
authors   = first 3 author names joined by "; ", append "et al." if > 3
year      = year (integer)
venue     = venue or publicationVenue.name, fallback "Unknown"
abstract_snippet = abstract[:300] + "..." if len > 300 (escape commas/newlines)
relevance_score  = 1-5 per rubric above
gap_notes = 1-sentence assessment (escape commas)
status    = "new"
url       = openAccessPdf.url if present, else https://www.semanticscholar.org/paper/{paperId}
doi       = externalIds.DOI if present, else ""
```

---

## Notes on Search Coverage

- Run this skill at least once per week during active writing periods.
- The 24-month window catches both recent arXiv preprints and conference proceedings with typical
  6-12 month publication lag.
- ACL Anthology is particularly important for papers on LLM+code benchmarks published at
  ACL/EMNLP/NAACL — venues that security researchers may miss.
- After running, immediately check if any score-5 papers are not yet cited in the paper; flag these
  as potential missing citations.
- If a paper appears in multiple sources (arXiv + conference proceedings), prefer the proceedings
  version; merge the two records manually in `papers.csv`, keeping the conference venue.
