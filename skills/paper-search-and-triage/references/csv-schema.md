# Literature Tracker CSV Schema

File location: `literature/papers.csv`

This file is the single source of truth for the literature intelligence workflow. All three skills
(paper-search-and-triage, deep-paper-synthesis, research-gap-mapper) read and write this file.
Never edit it by hand without running the search skill afterward to re-sort.

---

## Column Definitions

### `arxiv_id`
- Type: string
- Description: The arXiv identifier (e.g., `2401.12345`) if the paper has one. For papers without
  an arXiv preprint, use the Semantic Scholar paper ID (a 40-character hex string) prefixed with
  `s2:` (e.g., `s2:abc123...`). For ACL Anthology papers without arXiv IDs, use the ACL anthology
  ID prefixed with `acl:` (e.g., `acl:2024.acl-long.123`).
- Uniqueness: Must be unique within the file. Used as a primary deduplication key.
- Example: `2403.18471`
- Required: Yes (use `s2:{id}` fallback if no arXiv ID)

### `title`
- Type: string (CSV-quoted if contains commas)
- Description: Full paper title as it appears in the publication. Do not truncate.
- Case: Preserve original casing (title case per the paper's own rendering).
- Example: `"VulMaster: A Comprehensive Framework for Automated Vulnerability Repair with LLMs"`
- Required: Yes

### `authors`
- Type: string
- Description: First 3 authors' full names joined by ` ; ` (space-semicolon-space). If more than
  3 authors, append ` et al.` after the third name.
- Format: `Last, First` style preferred but `First Last` accepted if that is how the source lists them.
- Example: `Wang, Peng ; Chen, Yifei ; Liu, Junfeng et al.`
- Required: Yes

### `year`
- Type: integer (4-digit)
- Description: Year the paper was published or first publicly released. For arXiv preprints, use
  the year of initial submission. For conference papers, use the proceedings year (not the
  submission year).
- Example: `2024`
- Required: Yes

### `venue`
- Type: string
- Description: Abbreviated publication venue name. Use standard abbreviations (see venue-tiers.md).
  For arXiv preprints with no conference version, use `arXiv`. For workshop papers, use
  `{Workshop Name} @ {Conference}` format.
- Examples: `CCS 2024`, `arXiv`, `ACL 2024`, `USENIX Security 2023`, `SecCodePLUG @ NeurIPS 2024`
- Required: Yes

### `abstract_snippet`
- Type: string (CSV-quoted)
- Description: First 300 characters of the abstract, terminated with `...` if truncated. Remove
  line breaks; collapse whitespace. Used for quick triage without fetching the full paper.
- Example: `"We present AutoPatch, a system that uses LLMs to automatically repair C/C++ vulnerabilities confirmed by OSS-Fuzz. Given a crashing input and the vulnerable..."`
- Required: Yes (use paper title paraphrase if abstract unavailable)

### `relevance_score`
- Type: integer, range 1-5
- Description: Relevance to the AutoPatch/LLM-vulnerability-repair research topic.
  - **5** — Core topic: directly addresses LLM-based vulnerability repair or automated patch
    generation for C/C++ CVEs. Must read before submitting.
  - **4** — High relevance: LLM-based code repair (not vulnerability-specific), or
    vulnerability repair without LLMs (APR baselines), or LLM security benchmarks. Should read.
  - **3** — Adjacent: automated program repair (non-LLM), fuzzing + ML, LLM code generation
    (not repair), general LLM benchmarks for code quality.
  - **2** — Broad context: general software security, general code LLMs, general APR surveys.
  - **1** — Background/cited by: only tangentially relevant; cited by relevant papers.
- Required: Yes

### `gap_notes`
- Type: string (CSV-quoted)
- Description: A single sentence identifying the key gap or limitation of this paper relative to
  the AutoPatch work. Written from the perspective of "what this paper does NOT do that we do" or
  "what it contributes that we build on." Updated during synthesis.
- Example: `"Addresses LLM-based repair but evaluates on Java bugs only; no memory-safety focus."`
- Required: Yes (use "TBD" before synthesis, update after)

### `status`
- Type: enum string
- Valid values:
  - `new` — Found by search skill, not yet triaged by human
  - `to-read` — Human confirmed as worth reading; not yet synthesized
  - `synthesized` — Deep synthesis completed; summary in `literature/synthesis/`
  - `cited` — Paper is cited in `paper/latex/custom.bib` and used in the paper draft
  - `rejected` — Reviewed and decided not relevant enough to synthesize or cite
- Transitions: `new` → `to-read` → `synthesized` → `cited`
                `new` → `rejected` or `to-read` → `rejected`
- Required: Yes

### `url`
- Type: string (URL)
- Description: Best available URL to access the paper. Priority order:
  1. Open-access PDF URL (from Semantic Scholar `openAccessPdf.url`)
  2. arXiv abstract page (`https://arxiv.org/abs/{arxiv_id}`)
  3. ACL Anthology page (`https://aclanthology.org/{acl_id}`)
  4. Semantic Scholar page (`https://www.semanticscholar.org/paper/{paperId}`)
  5. DOI URL (`https://doi.org/{doi}`)
- Required: Yes

### `doi`
- Type: string
- Description: DOI without the `https://doi.org/` prefix (e.g., `10.1145/3576915.3623208`).
  Leave empty string `""` if no DOI is available (e.g., arXiv-only preprints without a conference
  proceedings version).
- Required: No (empty string acceptable)

---

## File Conventions

### Header Row
The CSV file MUST begin with this exact header row (no BOM, UTF-8 encoding):
```
arxiv_id,title,authors,year,venue,abstract_snippet,relevance_score,gap_notes,status,url,doi
```

### Quoting
- Fields containing commas, double quotes, or newlines MUST be enclosed in double quotes.
- Literal double quotes within a field must be escaped as `""` (two double-quote characters).
- Newlines within a field should be replaced with a space before writing to CSV.

### Sorting
After any write operation, sort all data rows by:
1. `relevance_score` descending (5 first)
2. `year` descending (most recent first)
3. `title` ascending (alphabetical, as tiebreaker)

### Encoding
UTF-8, no BOM. Line endings: LF (`\n`), not CRLF.

---

## Example Rows

```csv
arxiv_id,title,authors,year,venue,abstract_snippet,relevance_score,gap_notes,status,url,doi
2403.17927,"VulRepair: LLM-Driven Automated Repair of C Vulnerabilities","Kim, Jaeseung ; Park, Minsu ; Lee, Younghee et al.",2024,arXiv,"We propose VulRepair, a pipeline leveraging GPT-4 for automated repair of memory safety vulnerabilities in C programs. Given a CVE...",5,"Closely related but evaluates on synthetic benchmarks rather than OSS-Fuzz confirmed CVEs.",to-read,https://arxiv.org/abs/2403.17927,""
2311.04169,"An Empirical Study of Deep Learning Models for Vulnerability Detection","Chakraborty, Saikat ; Krishna, Rahul ; Ding, Yangruibo",2023,IEEE S&P 2023,"We perform a large-scale empirical study of deep learning-based vulnerability detection models across 5 architectures and 3 datasets...",3,"Focuses on detection not repair; no LLM-based patching component.",synthesized,https://arxiv.org/abs/2311.04169,10.1109/SP46215.2023.00020
2406.00500,"AutoCodeRover: Autonomous Program Improvement","Zhang, Yuntong ; Ruan, Haifeng ; Fang, Zhiyu et al.",2024,ICSE 2024,"AutoCodeRover is an autonomous software engineering agent that resolves GitHub issues by combining LLM reasoning with program analysis...",4,"Addresses autonomous code repair for general bugs; not vulnerability/CVE-specific; Java/Python focus.",to-read,https://arxiv.org/abs/2406.00500,10.1145/3597503.3639179
```

---

## Status Lifecycle Diagram

```
[API/Arxiv Discovery]
        |
        v
      "new"          ← paper-search-and-triage writes this status
        |
   [Human triage]
        |
   +---------+
   |         |
"to-read"  "rejected"
   |
   v
[deep-paper-synthesis runs]
   |
   v
"synthesized"       ← synthesis skill updates this
   |
[Added to paper.tex / custom.bib]
   |
   v
"cited"             ← researcher updates manually or via BibTeX export step
```

---

## Maintenance Notes

- Do not have more than ~500 rows before archiving old rejected/low-relevance entries to
  `literature/papers_archive.csv`.
- After each synthesis session, verify `gap_notes` fields are populated (not "TBD") for all
  `synthesized` and `cited` papers.
- The `doi` field is required before a paper can be promoted to `cited` status — DOIs are needed
  for proper ACL bibliography rendering.
