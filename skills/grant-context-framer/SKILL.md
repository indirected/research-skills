---
name: grant-context-framer
description: |
  Trigger phrases: "write grant proposal", "grant context", "broader impact section",
  "frame research for grant", "NSF proposal", "DARPA proposal", "research statement",
  "specific aims", "funding proposal", "grant writing", "frame the work for funding",
  "help me write a grant", "draft research proposal", "grant abstract", "project description",
  "write specific aims page", "broader impacts", "intellectual merit", "research program statement",
  "fund this research", "ARPA-H proposal", "SaTC proposal", "NSF SaTC",
  "write a one-pager for funding", "PI statement", "lab research statement",
  "prepare for grant submission", "help me apply for funding", "funding agency framing",
  "DARPA pitch", "proposal narrative"
version: 1.0.0
tools: Read, Glob, Grep, Bash, Write, WebSearch
---

# Skill: grant-context-framer

Map lab research to NSF SaTC, DARPA, and ARPA-H priorities. Draft problem statement,
broader impact, specific aims, and 3-year roadmap at accessible (non-expert) level.

**HUMAN APPROVAL GATE**: All drafted content is presented for review before any files
are saved. No grant files are written without explicit user approval.

---

## Step 0: Gather Inputs

Ask before doing any analysis:

```
To frame your research for a grant proposal, I need:

1. **Target agency and program**: (e.g., "NSF SaTC Core: Medium", "DARPA AMP", "ARPA-H")
2. **Estimated deadline**: When is this due? (even an approximate quarter helps)
3. **PI name and affiliation**: For the research statement framing
4. **Team composition**: Other PIs, postdocs, PhD students involved?
5. **Budget range**: (e.g., $500K over 3 years, $1.5M over 4 years)
   This affects how ambitious the research plan should be.
6. **Prior funding**: Any existing grants that this would build on or complement?
   (This affects how you frame "preliminary results")

I'll load the current research context from your paper and literature files.
```

---

## Step 1: Load Research Context

Load all available context about the current research program:

### Paper Context
```python
Read("project/research-focus.md")
Read("project/contributions.md")
Read("project/system-design.md")   # if exists
Glob("paper/latex/sections/*.tex") # if exists
```

Extract:
- System name (`system_name` from `project/research-focus.md`) → `{{SYSTEM_NAME}}`
- Paper title and main claim (from research-focus.md Core Problem + Approach)
- Key results (from `project/contributions.md` Headline Result)
- Stated limitations and future work (from gap map or paper sections)

### Literature Gap Map
```python
Glob("literature/gap_map.md")
Read("literature/gap_map.md")
```

Extract: The 3-5 most significant open problems the lab is positioned to address.

### Published Track Record
```python
Read("literature/papers.csv")
```

If `literature/papers.csv` exists, filter rows where the lab's papers appear (look for
the system name or authors from `project/research-focus.md`) to build the publication
list for "preliminary results" and "track record" sections.

### Idea Candidates
```python
Glob("ideas/candidates_*.md")
Glob("experiments/hypothesis_*.md")
```

Load the latest idea candidate list or hypothesis files for "future directions" content.

### Experimental Results
```python
Glob("experiments/results_analysis_*.md")
Read("experiments/results_analysis_[LATEST].md")
```

Extract headline results (quantitative) to use as "preliminary results."

---

## Step 2: Load Agency Profile

Read `references/grant-agency-profiles.md` to get the funding priorities, tone guidance,
and structural requirements for the target agency.

Map the research to agency priorities. For each priority area listed in the agency profile,
assess whether the lab's research addresses it:
- **Strong match**: Research directly addresses this priority; use this in the narrative
- **Indirect match**: Research contributes to this area; frame carefully
- **No match**: Do not stretch; focus on strong and indirect matches

---

## Step 3: Search for Current Program Priorities

Derive search terms from `project/research-focus.md` (Core Problem, Approach, Evaluation Context)
and from the user's target agency/program provided in Step 0:

```python
WebSearch(f"[AGENCY] [PROGRAM] solicitation 2025 2026 priorities")
WebSearch(f"[AGENCY] [PROGRAM] funded projects similar to [core task from research-focus.md]")
WebSearch(f"[AGENCY] recent awards [approach keyword from research-focus.md] [evaluation keyword]")
```

Do not hardcode domain keywords — derive them from `project/research-focus.md`.

From search results, identify:
- Current focus areas the program officer has emphasized in recent talks or awards
- Examples of recently funded projects that are adjacent to the lab's work
- Vocabulary the agency uses (copy their terminology — "transition to practice", "fundamental
  science", "adversarial machine learning", etc.)
- Any explicit exclusions or out-of-scope areas to avoid

---

## Step 4: Draft the Research Context Components

Draft each component separately. Present ALL components to the user before saving anything.

### Component A: Problem Statement (Accessible Level)

Write for a program officer or panelist who is intelligent but not an expert in the
lab's specific domain. Avoid jargon in the first paragraph. Derive the specific
framing from `project/research-focus.md` (Core Problem and Approach fields).

```
Target length: 250-400 words
Tone: Alarming but precise (the problem is real and large; your work is tractable)
Structure:
  1. Real-world impact hook (2-3 sentences on software vulnerabilities' societal cost)
  2. The technical problem (why fixing vulnerabilities is hard)
  3. Why LLMs create a new opportunity (not "AI is amazing" — be specific)
  4. What is still missing / what this proposal will do
```

Draft template:
```
Software vulnerabilities represent one of the most persistent threats to digital infrastructure.
[SPECIFIC STATISTIC: e.g., number of CVEs per year, average time to patch, cost of breaches].
Despite decades of research on automated program analysis, the vast majority of security
vulnerabilities still require highly skilled human engineers to fix — a resource that is
chronically scarce.

Recent advances in large language models (LLMs) have demonstrated remarkable ability to
understand and generate code. However, applying LLMs to vulnerability repair raises
fundamental questions that remain unanswered: [LIST 2-3 questions from RQs in the paper].

Our preliminary results suggest that [HEADLINE RESULT from experiments].
This proposal will build on these results to [MAIN GOAL of the grant proposal].
```

Fill in the bracketed sections with real numbers from the experiments and specific claims
from the paper.

### Component B: The Lab's Unique Position

Articulate why THIS lab can do this work better than others.

```
Target length: 150-200 words
Key elements:
  - Unique dataset or infrastructure (describe from project/system-design.md)
  - Methodological expertise (LLM evaluation methodology, security testing)
  - Track record (publications, existing funding)
  - Team composition (security expertise + NLP/ML expertise combined)
  - Existing collaborations that provide access to real-world systems or data
```

### Component C: Three-Year Research Roadmap

Structure the roadmap around 3 phases with concrete deliverables:

```
Year 1 — Foundation: [Current paper + 1-2 follow-up studies]
  Research: Establish baselines, understand failure modes, build infrastructure
  Deliverable: [N] publications, open-source release of [system]

Year 2 — Expansion: [Move from one language/bug class to broader scope]
  Research: Generalize to [new domain], introduce [key technical advance]
  Deliverable: [N] publications, deployed prototype in collaboration with [partner]

Year 3 — Deployment and Transfer: [Demonstrate real-world applicability]
  Research: Human-in-the-loop validation, case studies with industry partners
  Deliverable: [N] publications, [system] in production use at [org], policy recommendations
```

Connect each year to ideas from `experiments/hypothesis_*.md` files if they exist.

### Component D: Broader Impact Statement

```
Target length: 300-500 words (for NSF) or 200-300 words (for DARPA)
Audience: Non-technical reviewers, policy makers
Structure:
  1. Scientific impact: How this advances the field
  2. Societal impact: How this reduces real-world harm
  3. Training impact: How this supports student education (NSF-specific)
  4. Diversity and inclusion (NSF-specific): Plan for broadening participation
  5. Artifacts and dissemination: Open-source, datasets, reproducibility
```

For NSF specifically, the Broader Impacts section is scored separately from Intellectual
Merit and must directly address NSF's stated criteria (see `references/grant-agency-profiles.md`).

### Component E: Agency-Specific Structure

**For NSF (Project Description):**
```
Section 1: Introduction and Motivation (1 page)
Section 2: Background and Related Work (1-2 pages)
Section 3: Research Plan
  3.1 Research Questions (bulleted; 4-6 RQs)
  3.2 Year 1 Research
  3.3 Year 2 Research
  3.4 Year 3 Research
Section 4: Preliminary Results (1-2 pages with real numbers)
Section 5: Broader Impacts (1 page)
Section 6: Evaluation Plan (how will you know if you succeeded?)
Section 7: Timeline (Gantt chart or table)
Bibliography (not counted toward page limit)
```

**For DARPA (Technical Volume):**
```
Section 1: Executive Summary (0.5 page)
Section 2: Technical Approach
  - Phase 1 (18 months): [Technical goal] with metrics [M1, M2, M3]
  - Phase 2 (18 months): [Technical goal] with metrics [M4, M5, M6]
Section 3: Risk Mitigation: [For each phase, what are the risks and fallback plans?]
Section 4: Team and Facilities
Section 5: Related Work and Differentiation
```

**For ARPA-H (Research Plan):**
- Same structure as DARPA but emphasize: healthcare application, patient outcomes,
  clinical deployment pathway. Frame vulnerability repair in the context of medical
  device firmware, healthcare record systems, or supply chain security.

---

## Step 5: HUMAN APPROVAL GATE — Present and Wait

**DO NOT save any files yet.** Present all drafted components in the chat:

```
Grant Context Draft — [AGENCY] [PROGRAM]
==========================================
Estimated deadline: [DATE]
Target length: [N] pages (program: [PROGRAM])

---

COMPONENT A: Problem Statement
[DRAFT TEXT]

---

COMPONENT B: Lab's Unique Position
[DRAFT TEXT]

---

COMPONENT C: Three-Year Roadmap
[DRAFT TEXT]

---

COMPONENT D: Broader Impact Statement
[DRAFT TEXT]

---

COMPONENT E: [AGENCY]-Specific Structure Outline
[SECTION OUTLINE]

---

VOCABULARY ALIGNMENT
The following terms from the agency's recent solicitation are used in the draft:
[List 5-10 terms/phrases adopted from the agency's own language]

POTENTIAL WEAKNESSES
Items to strengthen before submission:
1. [weakness 1]
2. [weakness 2]
3. [weakness 3]

---

Shall I save these drafts to grants/[AGENCY]_[YEAR]/?
Reply:
- "yes" — save all components as separate files
- "save A, C" — save only specific components
- "revise B" — I will redraft Component B with your guidance before saving
- "no" — do not save anything; use the text above for your own editing
```

**WAIT for user response.**

---

## Step 6: Handle User Response and Save Files

Parse the user's response:

- **"yes"** or **"save all"**: Save all components.
- **"save [letters]"**: Save only the specified components (A, B, C, D, E).
- **"revise [letter]"**: Ask "What should be different?" then redraft that component and
  re-present the draft before saving.
- **"no"**: Do not save anything. Confirm: "No files saved. The draft text above is yours
  to copy and edit as needed."

### Saving Files

Create the grants directory:
```bash
mkdir -p grants/[AGENCY]_[YEAR]/
```

Write each approved component:

```
grants/[AGENCY]_[YEAR]/problem_statement.md        # Component A
grants/[AGENCY]_[YEAR]/lab_position.md             # Component B
grants/[AGENCY]_[YEAR]/research_roadmap.md         # Component C
grants/[AGENCY]_[YEAR]/broader_impact.md           # Component D
grants/[AGENCY]_[YEAR]/proposal_outline.md         # Component E
grants/[AGENCY]_[YEAR]/vocabulary_and_alignment.md # Vocabulary list
grants/[AGENCY]_[YEAR]/README.md                   # Overview with deadlines and next steps
```

Write `README.md`:
```markdown
# Grant Package: [AGENCY] [PROGRAM] [YEAR]

Status: Draft
Target deadline: [DATE]
PI: [PI NAME]

---

## Files in This Directory

- problem_statement.md — Problem statement at accessible level (~[N] words)
- lab_position.md — Lab's unique capabilities and track record
- research_roadmap.md — Three-year research plan
- broader_impact.md — Broader impacts statement ([N] words)
- proposal_outline.md — Full [AGENCY]-specific proposal outline
- vocabulary_and_alignment.md — Agency vocabulary and priority mapping

---

## Next Steps

- [ ] Have PI review all components for accuracy
- [ ] Verify all statistics and quantitative claims against source data
- [ ] Check grant limit pages against official solicitation
- [ ] Identify letter of support contacts (industry, other institutions)
- [ ] Check for required registrations: SAM.gov, Research.gov, Grants.gov
- [ ] Identify if institution has required subcontracts or budget approval process
- [ ] Target submission deadline: [DATE]
```

---

## Reference Files

- `references/grant-agency-profiles.md` — Agency priorities, tone, structure for NSF SaTC, DARPA, ARPA-H, NIH R01

---

## Error Handling

- If gap map or ideas files do not exist: proceed with paper abstract as the sole future-directions source; note this limitation
- If WebSearch is unavailable: use `references/grant-agency-profiles.md` only; note that agency priorities should be manually verified against current solicitation
- If no quantitative results are available (experiments not yet complete): draft the Preliminary Results section with placeholders clearly marked `[INSERT RESULT: ...]`; warn user these must be filled in before submission
- If target deadline is < 4 weeks away: warn that grant writing typically requires 4-8 weeks of intensive effort; suggest focusing on the most critical sections first (Problem Statement + Preliminary Results)
- If agency is not in `references/grant-agency-profiles.md`: ask for the solicitation URL and extract priorities via WebFetch before drafting
