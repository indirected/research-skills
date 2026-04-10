---
name: project-init
description: |
  Initialize a new research project by creating the project/ config directory.
  Run this ONCE at the very start of any new paper or research project — even if
  you have only a rough idea of the topic. All other skills read from project/ as
  the project grows; this skill just gets you started.
  Trigger when the user says any of the following:
  - "start new project"
  - "initialize project"
  - "set up project context"
  - "I'm starting a new paper"
  - "create project config"
  - "init project"
  - "new paper setup"
  - "set up my research project"
  - "configure project"
  - "project setup"
  - "beginning a new research project"
version: 2.0.0
tools: Read, Glob, Bash, Write
---

# Skill: project-init

You are setting up the `project/` config directory that all other research skills
depend on. This skill is intentionally lightweight — it only captures what you
actually know at day 1 of a research project.

The `project/` directory is a **living config**. It starts sparse and fills in as
you make progress. Other skills (paper-search-and-triage, experiment-designer,
write-methodology-section, etc.) will add and update files here as your project
evolves. You do not need to know your system design, related work, baselines, or
results to run this skill.

**Run this skill once per project.** If `project/research-focus.md` already exists,
go to the Update flow at the bottom of this file.

---

## Step 0 — Check for Existing Config

```python
Glob("project/*.md")
```

If `project/research-focus.md` exists, read it and say:

> "I found an existing project config for **[project_name]**. Do you want to:
> 1. Update a specific file (tell me which one)
> 2. Start fresh (overwrite everything)
> 3. View current config (I'll display all files)"

If the directory is empty or does not exist, proceed to Step 1.

---

## Step 1 — Interview (3 Groups)

Tell the user upfront:

> "I'll ask you 3 short groups of questions to get your project started. You don't
> need to know everything yet — use 'TBD' or 'not sure yet' freely. These files will
> fill in as your project evolves."

---

### Group 1: Project Identity → `project/research-focus.md`

Ask:

> **Group 1 of 3 — Research Identity**
>
> 1. What do you want to call this project for now? (anything works — "paper1",
>    "my-llm-project", a real system name if you have one)
> 2. What general research area is this in?
>    (e.g., "NLP", "systems security", "computer vision", "HCI")
> 3. In 1–3 sentences: what problem are you trying to solve, or what question
>    are you trying to answer? (rough is fine — even a direction counts)
> 4. Do you have an initial idea for your approach or method, even vaguely?
>    (say "not yet" if you're still exploring)

These four questions are the minimum. Everything else — system name, novelty,
contributions, baselines — comes later through other skills.

---

### Group 2: Venue → `project/venue-config.md`

Ask:

> **Group 2 of 3 — Target Venue (optional)**
>
> 1. Do you have a target venue in mind?
>    (e.g., ACL, NeurIPS, USENIX Security, ICSE — or say "unknown")
> 2. Do you know the submission deadline?
>    (YYYY-MM-DD, or "unknown")
> 3. Is the submission double-blind (anonymous review)? (yes / no / unknown)

All answers can be "unknown". This file is easy to update later by saying
"update venue config".

---

### Group 3: Paper Setup → `project/paper-paths.md`

Ask:

> **Group 3 of 3 — Paper Files (optional)**
>
> Do you already have a LaTeX project set up? If yes, provide:
> - Path to your main .tex file
> - Path to your .bib file
> - Path to your sections/ directory
> - Path to your figures/ directory
>
> If you haven't set up LaTeX yet, just say "not yet" and we'll leave these as TODO.

---

## Step 2 — Write Config Files

After collecting all answers, create the `project/` directory and write 3 active
config files plus 5 placeholder files for configs that other skills will populate.

```bash
mkdir -p project
```

### File 1: `project/research-focus.md`

```markdown
# Research Focus

project_name: {{Q1.1 answer}}
research_area: {{Q1.2 answer}}
last_updated: {{TODAY}}

## Problem Statement

{{Q1.3 answer — the problem or research question, in the student's own words}}

## Initial Approach

{{Q1.4 answer, or "Not yet defined — see paper-search-and-triage to explore the space"}}

## System Name

{{Q1.1 answer if a proper name, otherwise "TBD — will be defined as the project matures"}}

## What Makes This Novel

TBD — run paper-search-and-triage and research-gap-mapper to identify the gap
this work fills.

## Headline Result

TBD — fill in after experiments are complete.
```

### File 2: `project/venue-config.md`

```markdown
# Venue Configuration

venue: {{Q2.1 answer, or "unknown"}}
deadline: {{Q2.2 answer, or "unknown"}}
review_mode: {{Q2.3 answer, or "unknown"}}
format: {{infer from venue if known, else "TBD"}}
page_limit: {{infer from venue if known, else "TBD"}}
last_updated: {{TODAY}}

## Section Word Budgets

{{If venue is known, fill in the appropriate word budgets from the table below.
If unknown, write: "TBD — update when venue is confirmed."}}
```

Word budgets by venue (fill in if venue is known):
- ACL 8-page: Abstract 200, Intro 400, Background 550, Method 1100, Experiments 1400, Related 500, Conclusion 250
- NeurIPS 9-page: Abstract 150, Intro 500, Background 600, Method 1200, Experiments 1600, Related 600, Conclusion 300
- USENIX 13-page: Abstract 200, Intro 500, Background 700, Design 1800, Evaluation 2000, Related 700, Conclusion 300
- IEEE S&P 13-page: same as USENIX roughly
- If venue is unknown, skip word budgets entirely — they'll be added when venue is set.

### File 3: `project/paper-paths.md`

```markdown
# Paper File Paths

last_updated: {{TODAY}}

main_tex: {{path or "TODO — not set up yet"}}
bibliography: {{path or "TODO — not set up yet"}}
sections_dir: {{path or "TODO — not set up yet"}}
figures_dir: {{path or "TODO — not set up yet"}}

## Notes
<!-- Add any notes about the LaTeX setup here -->
```

### Placeholder Files (written once, filled in by other skills)

Write these 5 files with placeholder content. They tell other skills that the
file exists but hasn't been populated yet.

**`project/background-concepts.md`**
```markdown
# Background Concepts

last_updated: {{TODAY}}
status: placeholder — run write-background-section to populate this file

<!-- This file will be filled in as you identify the concepts a non-expert
reviewer would need explained. The write-background-section skill will help
you discover and structure these. -->
```

**`project/system-design.md`**
```markdown
# System Design

project_name: {{project_name}}
last_updated: {{TODAY}}
status: placeholder — fill in as your system design takes shape

<!-- Describe your system's pipeline, components, and datasets here.
The write-methodology-section skill will read this when you're ready to
write the methodology. Add to it incrementally as you design your system. -->
```

**`project/contributions.md`**
```markdown
# Paper Contributions

last_updated: {{TODAY}}
status: placeholder — fill in after experiments are complete

<!-- List your paper's contributions and headline result here.
This should be filled in after you have experimental results.
The write-intro-and-abstract skill will read this to draft your Introduction. -->
```

**`project/related-work-clusters.md`**
```markdown
# Related Work Clusters

project_name: {{project_name}}
last_updated: {{TODAY}}
status: placeholder — run paper-search-and-triage to begin populating

<!-- This file maps the landscape of related work thematically.
Run paper-search-and-triage first, then deep-paper-synthesis and
research-gap-mapper. The write-related-work skill reads this file
when drafting the Related Work section. -->
```

**`project/experiment-config.md`**
```markdown
# Experiment Configuration

project_name: {{project_name}}
last_updated: {{TODAY}}
status: placeholder — run experiment-designer to populate this file

<!-- Defines your datasets, metrics, run commands, and baselines.
The experiment-designer skill will interview you and fill this in
when you're ready to design your evaluation. -->
```

---

## Step 3 — Display Summary and Recommended Next Steps

After writing all files, print:

```
Project initialized: {{project_name}}
Research area: {{research_area}}
======================================

Files created:
  project/research-focus.md        — problem statement and initial direction
  project/venue-config.md          — {{venue or "venue TBD"}}
  project/paper-paths.md           — {{configured or "LaTeX paths TBD"}}

Placeholder files (populated as you make progress):
  project/background-concepts.md   — filled by: write-background-section
  project/system-design.md         — filled by: you, as you design the system
  project/contributions.md         — filled by: you, after experiments
  project/related-work-clusters.md — filled by: paper-search-and-triage pipeline
  project/experiment-config.md     — filled by: experiment-designer

Recommended next steps (in rough research order):
  1. paper-search-and-triage       — find what's out there in your area
  2. research-gap-mapper           — identify where your contribution can live
  3. new-idea-generator            — generate and rank research directions
  4. experiment-designer           — design your evaluation once you have a plan
  5. write-background-section      — draft background when you understand the field

You can run any of these by name, or say "update project/venue-config.md" at
any time to fill in information as it becomes available.
```

---

## Update Flow

If the user wants to update a specific config file:

1. Ask which file (or which group of questions) they want to update.
2. Re-ask only the relevant questions for that file.
3. Overwrite only that file.
4. Print a one-line confirmation: `Updated: project/{{filename}}`

If the user says "update project" without specifying a file, ask:
> "Which part of your project config has changed? You can update any of these:
> research-focus, venue-config, paper-paths, background-concepts, system-design,
> contributions, related-work-clusters, or experiment-config."

---

## Handling Partial or Unknown Answers

If the user says "TODO", "not sure", "not yet", or anything equivalent for any answer:
- Write a `TODO:` placeholder in the appropriate field
- Do not press for an answer — incomplete is fine and expected at day 1
- Do not list TODOs at the end as warnings — they are normal, not errors
```
