# Research Workflow Skills

Claude Code skills for end-to-end academic research, from literature discovery through paper submission.
**These skills are project-agnostic** — they work for any research paper in any domain by reading
configuration from the `project/` directory (created by `project-init`).

---

## Quick Start

**Step 1**: Run `project-init` once to set up project configuration:
> "initialize project" or "start new project"

This creates the `project/` directory with a few active config files and placeholder files
for the rest. The `project/` directory is a **living config** — it starts sparse and fills
in as you make progress through the research workflow. You do not need to know your system
design, related work, baselines, or results to run this.

**Step 2**: Use any skill. They will read from `project/` and fill in placeholders as you go.

---

## Skill Families

### Family 0 — Project Setup (Run First)

| Skill | Trigger | Purpose |
|---|---|---|
| `project-init` | "initialize project", "start new project", "set up project context" | Asks 3 short groups of questions (project identity, venue, paper paths) and creates the `project/` directory — prerequisite for all other skills |

**Active config files created** (populated from your answers at init time):
`project/research-focus.md`, `project/venue-config.md`, `project/paper-paths.md`

**Placeholder files created** (written at init, populated by other skills as the project evolves):

| File | Populated by |
|---|---|
| `project/background-concepts.md` | `write-background-section` |
| `project/system-design.md` | You, incrementally, as you design the system |
| `project/contributions.md` | You, after experiments are complete |
| `project/related-work-clusters.md` | `write-related-work` (derived from literature pipeline) |
| `project/experiment-config.md` | `experiment-designer` |

---

### Family 1 — Literature Intelligence

| Skill | Trigger | Purpose |
|---|---|---|
| `paper-search-and-triage` | "find new papers", "update literature tracker", "search for related work" | Derives search queries from `project/research-focus.md`, queries Semantic Scholar + arXiv + ACL Anthology, deduplicates against `literature/papers.csv`, generates a domain-specific relevance rubric, produces a dated triage report |
| `deep-paper-synthesis` | "synthesize papers", "compare papers", "deep read these papers" | Extracts methodology/results/limitations per paper, builds a comparison table, writes a narrative synthesis for Related Work |
| `research-gap-mapper` | "map research gaps", "what hasn't been done", "frame our problem" | Derives research axes from `project/research-focus.md`, builds a coverage matrix from synthesized papers, ranks open gaps by importance × feasibility, drafts a 2-paragraph problem motivation |

**Prerequisite:** `project/research-focus.md` (from `project-init`)
**State files:** `literature/papers.csv`, `literature/relevance-rubric.md`, `literature/synthesis/`, `literature/gap_map.md`

---

### Family 2 — Experiment Intelligence

| Skill | Trigger | Purpose |
|---|---|---|
| `experiment-designer` | "design experiments", "plan experiments for [hypothesis]", "which baselines should I include" | Reads dataset paths and metric names from `project/experiment-config.md`, decomposes a hypothesis into conditions/metrics/baselines, estimates compute cost, writes `experiments/plan_YYYYMMDD.md` |
| `experiment-runner-monitor` | "run the benchmark", "launch experiments", "start the experiment" | Reads run command template from `project/experiment-config.md`, validates environment, launches run, monitors for early failures, parses results |
| `error-cluster-and-fix-proposer` | "cluster failures", "analyze errors", "propose improvements" | Reads result schema from `project/experiment-config.md`, clusters failures by error pattern, proposes targeted fixes — **requires your approval before writing any changes** |

**Prerequisite:** `project/research-focus.md` (from `project-init`); `project/experiment-config.md` is populated by `experiment-designer` before running experiments
**State files:** `experiments/plan_*.md`, `experiments/runs/RUN_ID/`, `experiments/error_clusters_*.md`

---

### Family 3 — Paper Writing (LaTeX / Overleaf)

All writing skills read from `project/` config, enforce anonymization per `project/venue-config.md`,
and remind you to `git push` from `paper/` to sync with Overleaf.

| Skill | Trigger | Purpose |
|---|---|---|
| `write-background-section` | "write background section", "write preliminaries", "add technical background" | Reads concepts from `project/background-concepts.md`; drafts one subsection per concept with definition, mechanism, and connection to the paper |
| `write-methodology-section` | "write methodology", "describe our approach", "write the design section" | Reads pipeline and components from `project/system-design.md`; translates into system design prose with algorithm blocks and figure stubs |
| `write-intro-and-abstract` | "write introduction", "draft abstract", "write contributions section" | Reads contributions from `project/contributions.md`; drafts Introduction (hook → problem → gap → contributions → roadmap) + Abstract within venue word limit |
| `write-related-work` | "write related work", "position our work relative to prior art" | Derives thematic clusters from the literature pipeline (`literature/synthesis/`, `literature/gap_map.md`, `literature/papers.csv`) if `project/related-work-clusters.md` is still a placeholder; confirms clusters with user; writes 1–2 paragraphs per cluster with explicit differentiation from {{SYSTEM_NAME}} |
| `paper-experiments` | "write experiments section", "write evaluation section", "draft results section" | Reads metrics from `project/experiment-config.md`; drafts Setup, Baselines, Main Results, Ablation, and Error Analysis subsections |
| `latex-compile-and-check` | "compile the paper", "check paper formatting", "pre-submission check" | Runs full pdflatex build, parses log, checks page count, verifies citations/refs, anonymization scan, outputs dated checklist |

**Prerequisite:** `project/research-focus.md`, `project/paper-paths.md`, `project/venue-config.md` (all from `project-init`). The remaining config files (`background-concepts.md`, `system-design.md`, `contributions.md`, `related-work-clusters.md`) are populated by other skills or by you before running the corresponding writing skill.
**State files:** `paper/latex/sections/`, `paper/tables/`, `paper/figures/`, `paper/submission_checklist_*.md`

---

### Family 4 — Reproduction & Validation

| Skill | Trigger | Purpose |
|---|---|---|
| `paper-reproduce-prior` | "reproduce this paper", "implement this paper", "extract tables from paper" | Reads a prior paper (arXiv URL or PDF), extracts all tables and quantitative claims, scaffolds one Python script per table — **requires your approval before writing code** |
| `result-analyzer-and-table-gen` | "analyze results", "generate results table", "write results section" | Reads metric names from `project/experiment-config.md`; generates ACL booktabs LaTeX tables + matplotlib figures, drafts results section |
| `table-extractor-and-tracker` | "are the numbers in the paper up to date", "numbers tracker", "stale numbers" | Maps every numeric claim in the paper to its source result file; flags any stale values when results change |
| `result-reproduction-verifier` | "reproduce results", "verify paper claims", "sanity check our numbers" | Re-runs a stratified subset of cases, compares reproduced vs. claimed results, outputs PASS/WITHIN\_VARIANCE/FAIL report |
| `artifact-packager` | "package artifact", "prepare code release", "artifact evaluation" | Privacy-scans codebase, curates `artifact/` directory, writes artifact README + LaTeX appendix per ACM AE / USENIX AE / ACL checklists |

**State files:** `paper/numbers_tracker.json`, `paper/stale_numbers_*.md`, `experiments/reproduction/`, `artifact/`, `reproduction/PAPER_SLUG/`

---

### Family 5 — Submission & Author Iteration

| Skill | Trigger | Purpose |
|---|---|---|
| `submission-manager` | "submission checklist", "prepare for [venue] submission", "am I ready to submit" | Reads venue from `project/venue-config.md`; runs venue-specific compliance check, generates backwards timeline from deadline |
| `reviewer-response-drafter` | "respond to reviewers", "draft rebuttal", "write reviewer response" | Parses reviewer comments, classifies concern type, drafts per-comment responses with evidence, produces a prioritized change list |
| `camera-ready-finalizer` | "camera ready", "finalize paper", "de-anonymize paper" | Reads LaTeX paths from `project/paper-paths.md`; switches review → final mode, adds author block + acknowledgments, applies reviewer changes, verifies final page count |

**State files:** `paper/submission/VENUE_YYYY/`, `paper/reviews/`

---

### Family 6 — Ideas & Research Strategy

| Skill | Trigger | Purpose |
|---|---|---|
| `new-idea-generator` | "generate new ideas", "what should we work on next", "brainstorm research directions" | Reads research focus from `project/research-focus.md`, derives arxiv search queries dynamically, combines gap map + results + live arxiv → ranked idea candidates — **requires your approval before creating hypothesis files** |
| `ablation-designer` | "design ablation study", "what should I ablate", "isolate contributions" | Reads components from `project/system-design.md`, proposes principled remove/degrade/substitute conditions, estimates compute cost, designs ablation table |
| `grant-context-framer` | "write grant proposal", "NSF proposal", "DARPA proposal", "grant context" | Reads research context from `project/research-focus.md`, maps to agency priorities, drafts research context + broader impact + specific aims — **requires your approval before saving files** |

**State files:** `experiments/hypothesis_*.md`, `experiments/ablation_plan_*.md`, `grants/AGENCY_YYYY/`

---

## Pipeline Overview

```
project-init  ←── Run this FIRST for any new paper
     │
     ▼
[project/ config directory]
     │
     ├──► paper-search-and-triage
     │    deep-paper-synthesis
     │    research-gap-mapper
     │         │
     │         ▼
     ├──► experiment-designer ──► experiment-runner-monitor
     │                            error-cluster-and-fix-proposer
     │                                 │
     │                                 ▼
     │                          result-analyzer-and-table-gen
     │                          table-extractor-and-tracker
     │                                 │
     │         ┌───────────────────────┘
     │         ▼
     └──► write-background-section
          write-methodology-section
          write-related-work
          paper-experiments
          write-intro-and-abstract   ◄── (after results exist)
               │
               ▼
          latex-compile-and-check
          result-reproduction-verifier
          artifact-packager
               │
               ▼
          submission-manager
          reviewer-response-drafter  ◄── (after reviews received)
          camera-ready-finalizer     ◄── (after acceptance)

  Separately:
  paper-reproduce-prior  ◄── (when implementing a prior paper)
  new-idea-generator     ◄── (anytime, for next paper ideas)
  grant-context-framer   ◄── (when writing a grant proposal)
```

---

## State Directory Convention

```
{project_root}/
├── project/                     ← Created by project-init; living config, grows over time
│   ├── research-focus.md        # [active at init] Project name, area, problem statement
│   ├── venue-config.md          # [active at init] Venue, format, page limit, deadline
│   ├── paper-paths.md           # [active at init] main_tex, bibliography, sections_dir, figures_dir
│   ├── background-concepts.md   # [placeholder → filled by write-background-section]
│   ├── system-design.md         # [placeholder → filled by you as system design evolves]
│   ├── contributions.md         # [placeholder → filled by you after experiments]
│   ├── related-work-clusters.md # [placeholder → derived by write-related-work from literature/]
│   └── experiment-config.md     # [placeholder → filled by experiment-designer]
│
├── literature/
│   ├── papers.csv               # Living literature tracker
│   ├── relevance-rubric.md      # Domain-specific relevance scoring guide
│   ├── synthesis/               # Per-topic synthesis files + LaTeX tables
│   └── gap_map.md               # Coverage matrix + ranked gaps
│
├── experiments/
│   ├── plan_YYYYMMDD.md         # Experiment protocol
│   ├── hypothesis_*.md          # Approved research ideas
│   ├── runs/RUN_ID/             # Result files per benchmark run
│   ├── ablation_plan_*.md
│   └── reproduction/
│
├── paper/                       # Overleaf git submodule
│   └── latex/
│       ├── [main].tex           # Main document (path in project/paper-paths.md)
│       ├── custom.bib           # All new citations go here
│       ├── sections/            # One file per section
│       ├── tables/              # Generated LaTeX tables
│       └── figures/             # Generated PDF figures
│
├── reproduction/PAPER_SLUG/     # Prior paper reproduction (paper-reproduce-prior)
├── ideas/                       # Approved hypothesis files
├── grants/AGENCY_YYYY/          # Grant proposal drafts
└── artifact/                    # Camera-ready code release
```

---

## Human Approval Gates

Three skills pause and wait for explicit input before taking action:

- **`error-cluster-and-fix-proposer`** — presents proposed prompt/code changes; only implements what you select
- **`new-idea-generator`** — presents ranked idea candidates; only creates hypothesis files for approved ideas
- **`grant-context-framer`** — presents all drafted sections; only saves to `grants/` after approval
- **`paper-reproduce-prior`** — presents extraction results and checklist; only writes code stubs after approval

---

## Notes

- All writing skills check `review_mode` in `project/venue-config.md` and enforce anonymization automatically
- New BibTeX entries go to the bibliography file specified in `project/paper-paths.md`
- `paper/` is typically a git submodule linked to Overleaf; all writing skills remind you to `git push` from `paper/` to sync
- **To adapt for a new project**: run `project-init` — all skills will automatically use the new project's configuration
