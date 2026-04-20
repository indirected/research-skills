# Research Skills

Claude Code skills for academic research — from reading papers, through framing problems and designing experiments, to writing and rebutting. Built around the **conceptual moves** that make a research project succeed at top ML / AI / NLP venues.

These skills are intentionally **not a pipeline**. There is no required order, no shared state directory, no skill that depends on another's output. Each one captures a hard cognitive task you do during research; you invoke whichever fits the moment.

## The 9 skills

| Skill | Use when you're… |
|---|---|
| `project-init` | Starting a new research project and want to capture identity (name, area, venue, paper paths) in a small notes file you can grep later. Optional. |
| `read-paper` | Doing a deep read of a single paper — extracting claims, separating empirical from theoretical, identifying hidden assumptions, judging fairness, positioning vs. your own work. |
| `synthesize-literature` | Looking across a stack of paper-reading notes — finding themes, surfacing consensus and contradictions, identifying real research gaps, spotting methodological monocultures. |
| `brainstorm-ideas` | Generating new research ideas — from a literature synthesis, from current results, from a stuck experiment, or from scratch. Audits each idea on falsifiability, importance, tractability. |
| `frame-research` | Sharpening a fuzzy idea into a falsifiable problem — single-sentence statement, why-important / why-hard / why-unsolved triad, contribution list. The same move serves intros, gap-framings, and grant context. |
| `design-experiments` | Planning the empirical evaluation — datasets, baselines, metrics, ablations, statistical protocol, reproducibility, ML-era pitfalls (contamination, LLM-as-judge bias, prompt sensitivity, closed-model reproducibility, fair compute comparison). |
| `write-paper` | Writing or improving any section of a paper — intro, related work, method, experiments, abstract, figures, tables. Universal writing principles + section-specific guidance loaded only for the section in play. |
| `review-paper` | Self-reviewing a near-complete draft as an adversarial reviewer would — structured sweep over the top-10 rejection reasons + ML-era pitfalls, prioritized issue list with concrete fixes. |
| `respond-to-reviews` | Drafting the rebuttal after external reviews come back — comment triage, response strategies (concede / defend / clarify / decline / commit), revision change list. |

## Design principles

- **Each skill is independent.** No skill is a prerequisite for another. Invoke whichever fits the cognitive task at hand. The output of one (e.g., a literature synthesis) is often a *useful input* to another (e.g., framing a problem), but you bring the file across yourself — there's no enforced pipeline.
- **The user decides where outputs go.** Skills suggest a default file location and ask; they don't force a directory layout on your project.
- **Conceptual depth over logistics.** The skills embed "how to read a paper deeply" or "how to frame a falsifiable problem" rather than "where to save the third draft of the methodology section".
- **Progressive disclosure.** Each `SKILL.md` is the always-loaded entry point. Larger skills have `references/` (loaded only when needed) and `assets/` (output templates) — the model fetches them when relevant, not all at once.
- **Modern ML/AI/NLP focused.** Evaluation pitfalls (contamination, LLM-as-judge bias, prompt sensitivity, closed-model reproducibility) are first-class concerns, not afterthoughts.

## Installation

Run from this directory:

```bash
bash install-skills.sh           # install for the current user (~/.claude/skills/)
bash install-skills.sh --project # install into ./.claude/skills/ for the current project
bash install-skills.sh --force   # overwrite existing installations
```

Each invocation copies the `skills/<name>/` directory into the destination.

## Repository layout

```
research-skills/
├── README.md                          ← this file
├── install-skills.sh                  ← install to ~/.claude/skills/ (or project-local)
├── Keogh_SIGKDD09_tutorial.md         ← reference: Keogh's reviewing tutorial,
│                                        the source of several principles in
│                                        review-paper and write-paper
└── skills/
    ├── project-init/
    │   └── SKILL.md
    ├── read-paper/
    │   ├── SKILL.md
    │   └── assets/reading-notes-template.md
    ├── synthesize-literature/
    │   ├── SKILL.md
    │   └── assets/synthesis-template.md
    ├── brainstorm-ideas/
    │   └── SKILL.md
    ├── frame-research/
    │   └── SKILL.md
    ├── design-experiments/
    │   ├── SKILL.md
    │   └── references/ml-evaluation-pitfalls.md
    ├── write-paper/
    │   ├── SKILL.md
    │   └── references/
    │       ├── section-intro.md
    │       ├── section-related-work.md
    │       ├── section-method.md
    │       ├── section-experiments.md
    │       ├── section-abstract.md
    │       └── figures-and-tables.md
    ├── review-paper/
    │   ├── SKILL.md
    │   ├── references/top-10-rejection-reasons.md
    │   └── assets/review-report-template.md
    └── respond-to-reviews/
        ├── SKILL.md
        ├── references/response-patterns.md
        └── assets/rebuttal-template.md
```

## A typical research project

You don't have to follow any sequence, but a common path:

1. **`project-init`** — capture project identity in a notes file (optional).
2. **`read-paper`** (× many) — deep-read each closely-related paper into a structured notes file.
3. **`synthesize-literature`** — cluster reading notes into themes; surface gaps.
4. **`brainstorm-ideas`** — generate candidate research ideas from the synthesis.
5. **`frame-research`** — sharpen the chosen idea into a falsifiable problem with a contribution list.
6. **`design-experiments`** — design the evaluation that would substantiate (or refute) the contribution.
7. *(run experiments)*
8. **`write-paper`** — draft and iterate on each section; same skill, different sections.
9. **`review-paper`** — adversarial self-review before submission.
10. **`respond-to-reviews`** — when the reviews come back.

Loop and re-invoke as needed. Most sections of most projects get multiple passes through `write-paper`, multiple new reads via `read-paper`, and multiple ideas through `brainstorm-ideas`.

## Cross-skill references

A few skills point to references in another skill's directory rather than duplicating content:

- `review-paper` reads `design-experiments/references/ml-evaluation-pitfalls.md` (single-source for ML-era pitfall content).
- `review-paper` references `Keogh_SIGKDD09_tutorial.md` (in repo root) for backing principles.

The model has filesystem access, so cross-directory reads are fine; we keep one canonical copy per concept.

## Adapting for your workflow

These skills make few assumptions. To customize:

- Edit any `SKILL.md` to match your venue's conventions, your group's norms, or your personal preferences.
- Add references / assets as you discover patterns specific to your domain.
- Re-run `install-skills.sh --force` to push changes to `~/.claude/skills/`.

## Background

This suite started as a 26-skill project with a hardcoded pipeline and a shared `project/` config directory. After real-world use, the pipeline coupling and the per-artifact granularity became friction. This 9-skill design replaces it: each skill embeds a hard conceptual move; nothing forces an order; the user owns the file layout.

For deep context on the principles, see `Keogh_SIGKDD09_tutorial.md` — the underlying tutorial that several of these skills draw from.
