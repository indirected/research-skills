---
name: write-related-work
description: |
  Draft the Related Work section of any research paper by clustering synthesized papers
  thematically and clearly differentiating this work from prior art.
  Reads clusters from project/related-work-clusters.md and paper summaries from literature/.
  Trigger when the user says any of the following:
  - "write related work"
  - "draft related work section"
  - "position our work relative to prior art"
  - "write literature review section"
  - "write the related work"
  - "compare to prior work"
  - "help me write related work"
  - "related work section needs drafting"
  - "how does our work differ from [paper]"
  - "add [paper] to related work"
  - "write the prior work section"
  - "survey related papers in the paper"
  - "differentiate from prior work"
  - "position [system] against prior work"
version: 2.0.0
tools: Read, Glob, Grep, Bash, Write, Edit
---

# Skill: write-related-work

You are helping write the **Related Work** section of a research paper.

Related work is distinct from background: background explains *concepts* (what a technique is),
related work surveys *competing and complementary papers* and explicitly differentiates this work
from each cluster. Every cluster must end with a sentence making the relationship explicit.

---

## Step 0 — Check Prerequisites

Read the project config files:

```
Read: project/research-focus.md
Read: project/related-work-clusters.md   (may be a placeholder — handled below)
Read: project/contributions.md
Read: project/paper-paths.md
Read: project/venue-config.md
```

Extract from `project/research-focus.md`:
- `system_name` → use as `{{SYSTEM_NAME}}` throughout

Extract from `project/venue-config.md`:
- `review_mode`
- Word budget for Related Work section

**Check the state of `project/related-work-clusters.md`:**

A file is considered a **placeholder** if it contains `status: placeholder` or if it has no
`## Cluster:` entries. A file is **populated** if it has at least one `## Cluster:` entry with
a non-empty `**What this cluster does**` field.

- If the file is **populated**: proceed directly to Step 1.
- If the file is **a placeholder or missing**: go to Step 0b to derive clusters from the
  literature pipeline before continuing.

---

## Step 0b — Derive Clusters from Literature Pipeline

The clusters have not been defined yet. Derive them from the existing literature outputs
rather than stopping or asking the user to run `project-init`.

**Load available literature sources (in order of richness):**

```bash
# Discover synthesis content — structure varies; check both nested and flat layouts
ls -d literature/synthesis/*/ 2>/dev/null          # topic subdirectories (nested layout)
ls literature/synthesis/*/manifest.md 2>/dev/null  # manifest files within topic dirs
ls literature/synthesis/*.md 2>/dev/null            # flat synthesis files (legacy layout)
```
```
Read: literature/gap_map.md              → coverage matrix from research-gap-mapper
Read: literature/papers.csv              → full paper list with relevance scores and gap_notes
Glob: literature/triage_report_*.md      → gap themes from paper-search-and-triage
```

**Derive clusters using the best available source:**

1. **If synthesis content exists** (any `.md` files found anywhere under `literature/synthesis/`):
   Synthesis outputs contain thematic clusters and paper summaries. Look for a `manifest.md`
   in each topic subdirectory first (richest source); fall back to any `.md` file present.
   Collect every named cluster across all synthesis files found. Merge clusters with the same
   theme (e.g., "LLM-based APR" and "LLM for code repair" are the same cluster). Aim for 3–5
   distinct clusters that cover the synthesized papers without overlap.

2. **If `literature/gap_map.md` exists** (but no synthesis files):
   The gap map's coverage matrix axes define the research dimensions. Use the axis values and
   their associated papers to construct clusters. Each axis value with 2+ papers becomes a cluster.

3. **If only `literature/papers.csv` exists**:
   Group papers by their `gap_notes` themes. Papers with similar gap notes belong to the same
   cluster. Use relevance scores to prioritize — score-4 and score-5 papers define the clusters;
   lower-scored papers fill in secondarily.

4. **If no literature files exist at all**:
   Tell the user:
   > "I don't have enough literature context to derive clusters automatically. Please either:
   > 1. Run `paper-search-and-triage` to find relevant papers, then come back
   > 2. Tell me 3–5 thematic areas of related work and I'll build the clusters from your description"
   
   If the user provides descriptions inline, use those to construct clusters. Do not stop —
   proceed with whatever the user provides.

**For each derived cluster, fill in:**

```markdown
## Cluster: {{cluster name}}
**What this cluster does**: {{1-sentence description derived from paper summaries}}
**How {{SYSTEM_NAME}} differs**: {{1-sentence differentiation — use gap_notes or synthesis
  "Relation to this work" fields; write "TBD" if not determinable yet}}
**Key papers to cite**: {{cite keys or titles from papers in this cluster}}
```

**Write the derived clusters to `project/related-work-clusters.md`**, replacing the placeholder:

```markdown
# Related Work Clusters

project_name: {{project_name from research-focus.md}}
last_updated: {{TODAY}}
derived_from: {{list of source files used, e.g. "literature/synthesis/llm_repair_synthesis.md,
  literature/gap_map.md"}}

{{one ## Cluster: block per cluster}}
```

Then show the user what was derived:

> "I derived [N] clusters from your literature pipeline:
> 1. **[Cluster 1]** — [N] papers: [paper titles or keys]
> 2. **[Cluster 2]** — ...
> ...
>
> Does this look right? You can ask me to merge, split, rename, or reorder clusters before
> I draft the section. Or say 'looks good' to proceed."

Wait for confirmation. If the user requests adjustments, update `project/related-work-clusters.md`
accordingly before continuing. If the user says "looks good" or equivalent, proceed to Step 1.

---

## Step 1 — Check Review Mode

If `review_mode: yes` in `project/venue-config.md`:
- Do NOT mention author names, lab names, or institution names.
- Do NOT write "Unlike our previous system [X]..." — treat self-references as third-party.
- Use "{{SYSTEM_NAME}}" when referring to this paper's system.

Inform the user of current mode.

---

## Step 2 — Load Literature

Read in this order:

```
Read: {{main_tex from project/paper-paths.md}}
Glob: {{sections_dir}}/*.tex
Read: {{bibliography from project/paper-paths.md}}
Read: literature/papers.csv        (if exists)
```
```bash
# Find synthesis outputs — check both nested and flat layouts
ls literature/synthesis/*/manifest.md 2>/dev/null  # preferred: topic manifests
ls literature/synthesis/**/*.md 2>/dev/null         # fallback: all .md files recursively
```

For each synthesis file found, read it — these contain deep paper summaries and are the
primary source of content for related work paragraphs.

If `papers.csv` has entries, parse it for the full paper list with relevance scores.

If no synthesis content is found under `literature/synthesis/`:
> "I don't see any synthesized papers in `literature/synthesis/`. I can still draft related work
> using the cluster descriptions in `project/related-work-clusters.md`, but the paragraphs will
> have placeholder citations. Would you like to proceed, or run synthesis first?"

---

## Step 3 — Confirm Cluster Structure

Present the clusters from `project/related-work-clusters.md` to the user:

> "I found [N] thematic clusters in `project/related-work-clusters.md`:
> 1. [Cluster 1 name]
> 2. [Cluster 2 name]
> ...
>
> For a [N]-page paper with a [budget]-word related work section, [3-4] clusters is optimal.
> Should I use all [N] clusters, merge any, or adjust the order?"

---

## Step 4 — Draft Each Cluster

For each cluster, write **1–2 paragraphs** following this structure:

1. **Cluster description** (2–3 sentences): what does this line of work do? What is the general approach, and what problem does it address?
2. **Key papers with differentiation**: cite 2–5 key papers and distinguish each using the pattern: "Unlike [X] which [what X does], {{SYSTEM_NAME}} [what makes it different]."
3. **Positioning sentence**: 1 sentence making the cluster's relationship to {{SYSTEM_NAME}} explicit — whether competitive (same task), complementary (different task, shared infrastructure), or foundational (prior work this builds on).

### Differentiation Pattern Library

Use these templates when writing differentiation within each cluster:

```
"Unlike [X] which [what X does], {{SYSTEM_NAME}} [how {{SYSTEM_NAME}} differs]."

"In contrast to [X], which [limitation of X], {{SYSTEM_NAME}} [advantage]."

"[X] shares our goal of [shared goal] but differs in [key dimension]:
 [X does Y]; {{SYSTEM_NAME}} [does Z instead]."

"The closest prior work is [X] \citep{key}, which [brief description].
 However, [X] [specific limitation], whereas {{SYSTEM_NAME}} [specific advantage]."

"{{SYSTEM_NAME}} builds on [X]'s [shared idea] but extends it with [new contribution],
 enabling [new capability not in X]."
```

Choose the template based on how competitive vs. complementary the cited work is:
- **Competitive** (same task, different approach): use "Unlike X..." or "In contrast to X..."
- **Complementary** (different task, shared infrastructure): use "{{SYSTEM_NAME}} builds on..." or "This work is orthogonal to X..."
- **Seminal** (foundational paper everyone cites): one citation in the cluster description, no special differentiation needed.

### Using Synthesis Cards

If a synthesis card exists in `literature/synthesis/` for a paper being cited:
- Use the "Limitations" and "Relation to this work" fields from the card to derive the differentiation sentence.
- Use the "Results" field to include a specific number when citing the paper's performance.

If no synthesis card exists, use the abstract from `literature/papers.csv`, or the cluster differentiation sentence from `project/related-work-clusters.md` as the basis.

---

## Step 5 — Write Closing Positioning Paragraph

After all clusters, add a 2–3 sentence paragraph that summarizes {{SYSTEM_NAME}}'s unique position
across all clusters. Use the "What Makes This Novel" field from `project/research-focus.md` as
the basis. Also reference the headline result from `project/contributions.md` if appropriate.

Pattern:
> "In summary, {{SYSTEM_NAME}} occupies a distinct position at the intersection of [cluster 1] and
> [cluster 2]. Existing systems either [limitation 1] or [limitation 2].
> {{SYSTEM_NAME}} is the first to [unique contribution from research-focus.md]."

---

## Step 6 — Check Against Background Section

Read the background section (if it exists) and ensure related work does NOT repeat background content:

```python
Grep(pattern=r"\\subsection", path="{{sections_dir}}/background.tex", output_mode="count")
```

Read `background.tex` to find which concepts it already explains. Flag any content in the related work draft that duplicates those explanations. Related work should only *cite* concepts with "as described in Section~\ref{sec:background}" rather than re-explaining them.

---

## Step 7 — Check Citations Against Bibliography

For every `\cite{}` key in the draft, check if it exists in the bibliography:
```python
Grep(pattern=r"{{cite_key}}", path="{{bibliography from project/paper-paths.md}}")
```

For each missing key, note as TODO and provide guidance on finding the entry.
Never invent DOIs or page numbers.

If a paper appears in `literature/papers.csv` but has no BibTeX entry yet, offer to construct one from the CSV metadata (arxiv_id, title, authors, year, venue, doi fields).

---

## Step 8 — Apply Anonymization Check

If review mode is active:
```python
Grep(pattern=r"our lab|our prior work|we previously|our previous|our earlier|our group",
     path="{{sections_dir}}/related_work.tex", output_mode="content")
```

Also check for any system names that uniquely identify the research group.
Flag all hits and suggest neutral rewrites.

---

## Step 9 — Page Budget Check

```bash
wc -w {{sections_dir}}/related_work.tex
```

Compare against budget in `project/venue-config.md`. Defaults if not specified:
- ACL 8-page: 400–550 words (0.75–1.0 page)
- NeurIPS 9-page: 500–650 words
- USENIX 13-page: 700–900 words

**If over budget**:
- Reduce complementary/foundational clusters to 2–3 sentences each.
- Keep competitive clusters (same task) at full length — reviewers scrutinize these.
- Cut citations to ≤ 3 per cluster; keep only the most directly related papers.

**If under budget**:
- Expand the most competitive cluster (same task, different approach) — reviewers look for this.
- Add a paragraph on datasets/benchmarks used by prior work if multiple benchmarks exist in the field.

---

## Step 10 — Write Output File

Write to `{{sections_dir}}/related_work.tex`.

The file should begin:
```latex
% Related Work section — {{SYSTEM_NAME}} paper
% Generated by write-related-work skill

\section{Related Work}
\label{sec:related}
```

Each cluster uses `\paragraph{Cluster Name.}` (not `\subsection`) to keep the section compact.
This is standard for related work in most venues.

After writing, check that `\input{sections/related_work}` is in the main .tex:
```bash
grep "input{sections/related_work" {{main_tex}} 2>/dev/null || \
grep "input{sections/related" {{main_tex}} 2>/dev/null
```

If not present, tell the user where to add it (typically after Experiments, before Conclusion).

---

## Step 11 — Final Checklist

- [ ] `\section{Related Work}` with `\label{sec:related}` present.
- [ ] [N] thematic clusters using `\paragraph{}` headers.
- [ ] Each cluster has explicit differentiation using "Unlike X..." or "In contrast...".
- [ ] Closing positioning paragraph summarizing {{SYSTEM_NAME}}'s unique contribution.
- [ ] No repeated content from the background section.
- [ ] All `\cite{}` keys verified in bibliography; missing entries noted as TODO.
- [ ] No author/lab names in review mode.
- [ ] Word count is within venue budget.
- [ ] `\input{sections/related_work}` placement checked in main .tex.

---

## Step 12 — Remind User to Sync with Overleaf

```
SYNC REMINDER:
If your paper/ directory is a git submodule linked to Overleaf:

  cd {{paper_root_dir}}
  git add latex/sections/related_work.tex latex/custom.bib
  git commit -m "Add related work section"
  git push

After pushing, verify on Overleaf:
- All citations resolve (no "?" in the PDF)
- Related work does not duplicate content from the background section
- The section fits within the page budget
```
