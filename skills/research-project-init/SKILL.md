---
name: research-project-init
description: |
  Use this skill ONCE at the start of a new research project to capture a minimal,
  lightweight project identity note that other research skills can optionally read for
  context. Triggers on phrases like "initialize project", "start a new research
  project", "set up research context", "new paper project", or any fresh-project-setup
  language. Does NOT create a directory zoo of placeholder files — it writes a single
  short markdown note the user can extend as they go.
---

# Project Init

This skill captures the minimum context a research project needs on day one, nothing more. It produces **one short markdown file** that other skills can optionally read for grounding.

## Philosophy

The old way: set up a dozen placeholder files that a rigid pipeline fills in. That creates friction, enforces an order the user doesn't want, and hides the fact that most of the files are empty.

The new way: write down what you actually know *now*, in plain prose, in one file. As the project evolves, the user edits that same file (or creates new files as they please). Other skills that want context can read this note; they do not depend on a specific structure.

## What to capture

Ask the user for each item below *only if they don't already supply it*. Skip anything they indicate is not yet decided — leave a short `# TBD` line for it instead of interrogating.

1. **Project name / short slug** — one or two words the user thinks of this project as (e.g. `flash-eval`, `context-compression`).
2. **One-sentence pitch** — what the project is about, in the user's own words. Don't polish it; this is a scratchpad, not the paper's abstract.
3. **Topic area** — the field / subfield (e.g., "LLM alignment", "retrieval-augmented generation", "mechanistic interpretability"). This helps later skills calibrate jargon and reviewer expectations.
4. **Target venue(s)** — if the user has one in mind (e.g., ACL 2026, NeurIPS 2026, arXiv-only). Can be blank or a list of candidates.
5. **Deadline** — if known. Relative dates from the user ("next March") get converted to absolute dates.
6. **Paper repo / LaTeX path** — if the user has an existing Overleaf or LaTeX repo, capture the local path and the main `.tex` file. Otherwise leave blank.
7. **Code repo path** — if they have a code repo already. Otherwise blank.
8. **Collaborators** — first names or handles, if relevant (useful for authorship, review-rival checks, and division of labor mentions). Can skip.
9. **Anything else the user wants to anchor** — open text. E.g., "we are building on our prior ICLR 2025 paper", or "the key constraint is we only have 8 H100s".

## Output

Write a single file. Default location: `project.md` at the project root. If the user wants it elsewhere, honor that — this skill does not enforce a path.

### Template

```markdown
# {{Project name}}

**Pitch:** {{one-sentence pitch}}

**Area:** {{topic area}}

**Venue:** {{target venue(s), or "TBD"}}
**Deadline:** {{absolute date, or "TBD"}}

**Paper repo:** {{path to LaTeX repo, or "none yet"}}
**Main .tex:** {{path, or "none yet"}}
**Code repo:** {{path, or "none yet"}}

**Collaborators:** {{names/handles, or "solo"}}

## Notes

{{anything else the user anchored — freeform prose, bullet points, whatever}}

## Status

Created {{today's date, absolute}}. Extend this file freely as the project evolves —
other skills will read it for context but do not enforce any structure.
```

## How other skills should use this

Other skills in this suite may check for a `project.md` (or read a path the user hands them). They read it for context — topic area for jargon calibration, venue for page-limit awareness, paper repo path when writing LaTeX sections. They do **not** require it. A user who never runs `research-project-init` can still use every other skill by supplying context in the prompt.

## Things this skill explicitly does NOT do

- Does not create subdirectories like `literature/`, `experiments/`, `paper/`. If the user wants those, they make them.
- Does not create placeholder files for contributions, system design, related-work clusters, etc. Those emerge naturally from the relevant skills' outputs and live wherever the user decides.
- Does not ask questions the user has already answered in conversation. Infer aggressively from what's already been said.
- Does not re-run if `project.md` already exists — instead, ask the user if they want to edit the existing one.

## When to not trigger

- The user is asking about a specific subtask (reading a paper, designing an experiment, writing a section) — run the relevant skill, don't re-init.
- The user is mid-project and just wants to add one piece of info — just edit the file, don't wizard through all 9 questions.
