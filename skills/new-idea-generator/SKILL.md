---
name: new-idea-generator
description: |
  Trigger phrases: "generate new ideas", "what should we work on next", "brainstorm research directions",
  "find new research questions", "propose paper ideas", "what's novel we could do",
  "new research directions", "idea generation", "what can we improve", "next paper idea",
  "what should our next paper be", "help me brainstorm", "research brainstorm",
  "what gaps exist in the literature", "future work ideas", "follow-up research",
  "spin-off paper ideas", "what would make a good paper", "novel research angle",
  "research direction suggestions", "ideation session", "what hasn't been done",
  "low-hanging fruit in the field", "what could we publish next"
version: 1.0.0
tools: Read, Glob, Grep, Bash, Write, WebSearch
---

# Skill: new-idea-generator

Combine gap map + surprising experimental results + live arxiv digest to generate ranked
research idea candidates. Ideas are scored on novelty, feasibility, and venue fit.

**HUMAN APPROVAL GATE**: Ideas are presented as a ranked numbered menu. The skill waits
for explicit user selection before creating any hypothesis files.

---

## Step 1: Load Prerequisite Context

### 1.1 Gap Map

```python
# Check if gap map exists
Glob("literature/gap_map.md")
```

If `literature/gap_map.md` does not exist:
```
I need to run the research-gap-mapper skill first to build the gap map.
The gap map identifies open problems in the literature that the lab could address.

Would you like me to run research-gap-mapper now before generating ideas?
(Type 'yes' to run it, or 'skip' to generate ideas from the current paper alone.)
```

If it exists:
```python
Read("literature/gap_map.md")
```

Extract the top 5-8 open gaps listed in the gap map. Note which are labeled "high priority"
or have the most citations pointing to them as future work.

### 1.2 Experimental Results

```python
# Find latest results analysis
Glob("experiments/results_analysis_*.md")
# Sort by date suffix; read the most recent
```

Load the latest results analysis and extract:
- Primary metric values across conditions (use `primary_result_field` from `project/experiment-config.md`)
- Any result that was surprising (significantly above or below expectation)
- Conditions where performance was notably high or low relative to other conditions
- Any "failure modes" documented in the analysis

Also scan raw experiment stats for anomalies. First read `project/experiment-config.md` to
get the `primary_result_field` value, then use it:

```python
Read("project/experiment-config.md")
# Extract primary_result_field (e.g., "correct_rate") from the config
```

```bash
# Quick scan for highest and lowest performing conditions
# Substitute PRIMARY_FIELD with the value of primary_result_field from experiment-config.md
python3 -c "
import json, glob
PRIMARY_FIELD = 'PRIMARY_FIELD'  # substituted from experiment-config.md
runs = []
for path in glob.glob('experiments/runs/*/stats.json'):
    try:
        with open(path) as f:
            d = json.load(f)
        runs.append((path, d))
    except:
        pass
runs.sort(key=lambda x: float(x[1].get(PRIMARY_FIELD, 0)), reverse=True)
for path, d in runs[:5]:
    print(f'{path}: {d.get(PRIMARY_FIELD)}')
print('---')
for path, d in runs[-5:]:
    print(f'{path}: {d.get(PRIMARY_FIELD)}')
" 2>/dev/null
```

### 1.3 Current Paper Context

```python
Read("project/research-focus.md")
Read("project/contributions.md")
Read("project/system-design.md")   # if exists
Glob("paper/latex/sections/*.tex") # if exists
```

Extract:
- `system_name` from `project/research-focus.md` → `{{SYSTEM_NAME}}`
- The paper's main claim (from Core Problem and Approach)
- The specific components that make up the system (from system-design.md)
- The datasets and evaluation context

### 1.4 Literature Context

```python
Read("literature/papers.csv")
```
```bash
# Discover synthesis content — check both nested and flat layouts
ls literature/synthesis/*/manifest.md 2>/dev/null  # topic manifests (preferred)
ls literature/synthesis/*.md 2>/dev/null            # flat files (legacy)
```

Read whichever synthesis files are found. Extract the most recent papers (sorted by year DESC),
the main themes in the literature, and the methods being applied.

---

## Step 2: Fetch Live arxiv Digest

Read `project/research-focus.md` and derive 4-5 search queries from the Core Problem,
Approach, and Evaluation Context fields. The queries should target arxiv papers from
the last 2-4 weeks on topics adjacent to {{SYSTEM_NAME}}.

Derive queries directly from the Core Problem, Approach, and Evaluation Context in
`project/research-focus.md`. Cover: the core task, the method/approach, the evaluation
context, and adjacent topics. Format them as short keyword strings, e.g.:
- "arxiv 2025 2026 [core task keyword] [method keyword]"
- "arxiv 2025 2026 [approach keyword] language model"
- "arxiv 2025 2026 [evaluation context keyword] benchmark"

Run each derived query with WebSearch. For each search result:
- Note the paper title, authors, venue/arxiv ID, and date
- Extract 1-sentence summary of the main contribution
- Flag any that directly overlap with {{SYSTEM_NAME}} (cite risk)
- Flag any that suggest an unexplored direction

Build a "recent work" list:
```
recent_papers = [
  {"title": "...", "date": "2026-MM", "main_contribution": "...", "relation_to_lab": "overlap|adjacent|orthogonal"},
  ...
]
```

---

## Step 3: Generate Idea Candidates

Apply the heuristics from `references/idea-generation-heuristics.md` to generate 8-12 raw idea candidates. For each gap, surprising result, or paper, apply one or more heuristics.

Use this idea generation template:

```
For each (gap OR surprising_result OR recent_paper):
  Apply heuristics: axis_extension, combination, inversion, analogical_transfer, surprising_finding_exploitation
  Generate candidate idea if the combination is:
    - Not already done by a paper in the literature
    - Requires < 6 months of PhD student work
    - Producible as a paper at a tier-1 venue
```

### Idea Candidate Template

For each idea:
```
idea = {
  id: "IDEA-01",
  title: "Short memorable name (5-8 words)",
  hypothesis: "One sentence: [System/Method] can [capability] for [domain] because [mechanism].",
  heuristic_applied: "axis_extension | combination | inversion | ...",
  source: "gap: [gap title] | surprising result: [description] | paper: [title]",
  novelty_rationale: "Why this has not been done: [2-3 sentences]",
  lab_assets: "What the lab already has that enables this: [data, code, expertise]",
  feasibility: {
    data_available: true|false,
    compute_available: true|false,
    months_to_result: N,
    score: 1-5  # 5 = most feasible
  },
  venue_fit: ["ACL", "EMNLP", "CCS", "USENIX Security", "NeurIPS"],  # best matches
  risk: "low|medium|high",  # chance the idea doesn't pan out
  expected_contribution: "empirical|theoretical|system|benchmark|survey"
}
```

### Feasibility Scoring Rules

| Score | Meaning |
|-------|---------|
| 5 | Data available, compute available, < 2 months to a result, low risk |
| 4 | Data partially available OR compute needs 1 more run, 2–4 months |
| 3 | Data collection needed OR significant compute, 3–5 months |
| 2 | Novel dataset required OR new model training needed, 5–8 months |
| 1 | Requires new collaborations, IRB approval, or hardware acquisition |

### Venue Fit Rules

Read `project/venue-config.md` (if it exists) to get the project's target venues and their
upcoming deadlines. Use those deadlines to boost the ranking of ideas whose timeline fits
the next submission window.

If `project/venue-config.md` does not exist, use the general heuristics below:

| Idea type | Best venues |
|-----------|-------------|
| Empirical system paper | The primary venue from project/research-focus.md |
| New method or architecture | NeurIPS, ICML, ACL, EMNLP |
| Benchmark / evaluation paper | NeurIPS datasets track, ACL, or domain-specific top venue |
| Systems + ML hybrid | OSDI, ATC, MLSys, or domain conference |
| Survey / meta-analysis | CSUR, TMLR, or a workshop |

Derive the specific best-fit venues from the research domain in `project/research-focus.md`
rather than hardcoding — the config knows the field better than these defaults.

---

## Step 4: Rank and Filter Ideas

Filter out:
- Ideas that directly replicate a paper published in the last 6 months
- Ideas with feasibility score = 1 unless marked as "long-term vision"
- Ideas that are purely incremental (same system, +1 model tested)

Rank remaining ideas by:
1. **Impact score** = novelty + feasibility + venue tier (weighted equally)
2. **Time to submission** = if `project/venue-config.md` exists, read the next upcoming deadlines
   and boost ideas whose estimated timeline (months_to_result) fits within a submission window;
   ideas that align with the nearest deadline rank higher
3. **Lab synergy** = ideas that reuse existing data, code, or infrastructure rank higher

Produce final ranked list of 6-10 ideas.

---

## Step 5: HUMAN APPROVAL GATE — Present and Wait

**DO NOT create any files yet.** Present the ranked ideas as a numbered menu:

```
Research Idea Candidates — [DATE]
===================================
Context: {{SYSTEM_NAME}} paper, [VENUE] submission, [N] gaps in literature

I found [N] idea candidates. Here is the ranked list:

---

#1. [TITLE] (Feasibility: [N]/5 | Venues: [VENUE1, VENUE2])
   Hypothesis: [ONE SENTENCE]
   Why novel: [1-2 sentences]
   Lab assets: [What you already have]
   Estimated time to result: [N months]
   Risk: [low/medium/high]

#2. [TITLE] (Feasibility: [N]/5 | Venues: ...)
   ...

#3. [TITLE] ...
   ...

[... up to #10]

---

Which ideas would you like to pursue?
Enter idea numbers (e.g., "1, 3"), "all", or "none" to exit without saving.

If you'd like more detail on any idea before deciding, say "expand #N".
```

**WAIT for user response before proceeding.**

---

## Step 6: Handle User Response

Parse the user's response:

- **"none"** or **"exit"**: Respond "No hypothesis files created. The ranked list above is available for reference." — do not write any files.
- **"all"**: Proceed with all ideas.
- **Numbers** (e.g., "1, 3, 5"): Proceed with only those ideas.
- **"expand #N"**: Print the full detail for idea N (all fields), then re-ask the question.

For each approved idea, proceed to Step 7.

---

## Step 7: Create Hypothesis Files for Approved Ideas

For each approved idea, generate a slug from the title:
```python
slug = idea["title"].lower().replace(" ", "_").replace("-", "_")[:40]
# e.g., "multilang_vuln_repair_with_llm"
```

Create `experiments/hypothesis_{SLUG}.md`:

```markdown
# Research Hypothesis: [TITLE]

Generated: [DATE]
Status: Candidate (not yet started)
Idea source: [gap/surprising result/recent paper citation]
Heuristic applied: [heuristic name]

---

## Hypothesis

[ONE SENTENCE HYPOTHESIS]

### Why This Is Novel

[2-3 paragraphs explaining what exists in the literature and why this specific
combination/direction has not been done. Include citations to papers that are
adjacent but not identical.]

---

## Expected Contribution

Type: [empirical | theoretical | system | benchmark | survey]
Primary venue targets: [list in priority order]
Expected paper length: [long paper | short paper | workshop]

---

## Experimental Plan (Sketch)

### Research Questions

1. RQ1: [Specific question this paper will answer]
2. RQ2: [Second question]
3. RQ3: [Third question — at least 3, no more than 5]

### Methodology Sketch

[3-5 sentences describing how the experiment would be set up.
What is the input, what is the output, what is varied, what is measured?]

### Baseline / Comparison

[What existing system or random baseline would this compare against?]

### Dataset / Evaluation Corpus

[What data would be used? Is it existing (e.g., the {{SYSTEM_NAME}} dataset) or new?
If new: what is the collection strategy and estimated size?]

### Primary Metric

[Which metric would be the headline result? How does it connect to the hypothesis?]

---

## Lab Assets Available

| Asset | Status | Location |
|-------|--------|---------|
| [dataset] | [available/partial/need to collect] | [path or description] |
| [codebase] | [available/partial/need to build] | [path or description] |
| [compute] | [available/need to request] | [cluster name] |

---

## Feasibility Assessment

| Dimension | Score (1-5) | Notes |
|-----------|-------------|-------|
| Data availability | [N] | [detail] |
| Compute availability | [N] | [detail] |
| Time to first result | [N] | [N months estimate] |
| Risk (will it work?) | [N] | [reasoning] |
| **Overall feasibility** | **[avg]** | |

---

## Timeline Sketch

| Milestone | Target date | Notes |
|-----------|-------------|-------|
| Hypothesis confirmed, plan finalized | [DATE+2wks] | |
| Data collected / pipeline built | [DATE+6wks] | |
| Initial results available | [DATE+8wks] | |
| Full results + analysis | [DATE+12wks] | |
| Paper draft ready | [DATE+16wks] | |
| Target submission deadline | [DATE+18-20wks] | [VENUE DEADLINE] |

---

## Known Risks and Mitigations

| Risk | Likelihood | Mitigation |
|------|-----------|------------|
| [e.g., "LLM API costs exceed budget"] | medium | [Run on smaller model first; subset evaluation] |
| [e.g., "Dataset collection takes longer than expected"] | low | [Use existing dataset for initial results] |

---

## Next Actions

1. [ ] Discuss hypothesis with PI/co-authors to get buy-in
2. [ ] Verify data availability (run: [specific command or query])
3. [ ] Create experiment config using experiment-designer skill
4. [ ] Register in lab project tracker
```

---

## Step 8: Summary to User

```
Hypothesis Files Created
========================

[N] ideas approved. Files written:

[for each approved idea:]
  experiments/hypothesis_[SLUG].md
  Hypothesis: [one sentence]
  Next step: Run experiment-designer skill with this hypothesis file

Remaining ideas (not approved today) can be regenerated with this skill at any time.
The gap map and arxiv digest are current as of [DATE].

Tip: To start experiments on an approved idea, say "design experiment for hypothesis_[SLUG]"
```

---

## Reference Files

- `references/idea-generation-heuristics.md` — Structured creativity techniques (axis_extension, combination, inversion, analogical_transfer)

---

## Error Handling

- If `literature/gap_map.md` does not exist and user declines to run research-gap-mapper:
  generate ideas from the current paper's limitations section + arxiv digest only
- If experiment stats cannot be parsed (JSON errors): skip the "surprising results" step and
  generate ideas from gaps and arxiv only; note this in the output
- If WebSearch is unavailable: proceed without the arxiv digest and note it in the output
- If the user approves all ideas (>8): warn that creating >8 hypothesis files may dilute lab
  focus; suggest starting with the top 3 feasibility scores
