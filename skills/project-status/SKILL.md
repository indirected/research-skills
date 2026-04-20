---
name: project-status
description: |
  Analyze the current state of a research project and recommend the next skills to invoke.
  Scans project config files and artifact directories (section .tex files, result tables,
  literature summaries) to determine what has been done and what is ready to run next.
  Produces a prioritized status dashboard — no files are written or modified.
  Trigger whenever the user asks any of the following:
  - "what should I do next"
  - "project status"
  - "where am I in the process"
  - "what's left to do"
  - "what skills should I run"
  - "what's next"
  - "show me project status"
  - "what have I done so far"
  - "what's missing"
  - "am I on track"
  - "what can I run now"
  - "what stage am I in"
  - "project overview"
  - "research progress"
  - "status check"
  - "what needs to happen next"
  Also call this skill at the end of paper-draft to show next actions.
version: 1.0.0
tools: Read, Glob, Grep, Bash
---

# Skill: project-status

You produce a **read-only status dashboard** for the current research project. You detect
what has been done by examining which files and artifacts exist on disk — not by asking the
user. This is fast, quiet, and non-destructive. Do not write or modify any files.

The output is a structured report: what stage the project is at, which skills have run
(inferred from artifacts), what is ready to run now, and what is blocked and why.

---

## Step 1 — Discover Available Skills

Glob the skill suite to know what's available. Read only frontmatter (first 15 lines) of
each SKILL.md — do NOT read the full bodies. You need only the `name` field.

```
Glob("skills/*/SKILL.md")
```

If that path yields nothing, try:
```
Glob("../*/SKILL.md")
Glob("~/.claude/plugins/*/skills/*/SKILL.md")
```

Collect the list of skill names. You'll use this in the dashboard to show which skills
exist vs. which have run. If you cannot find any skills, note "skill path unknown" and
proceed — the artifact analysis still works.

---

## Step 2 — Read Project Config (Shallow Only)

For each config file, you need three facts: **exists**, **placeholder/empty**, **populated**.
Do NOT read the full content — use lightweight checks.

Run these shell commands (batch them where possible):

```bash
# Existence + size (bytes) for all project config files
ls -la project/*.md 2>/dev/null || echo "NO_PROJECT_DIR"

# Check for placeholder markers in each file (just a count, not content)
grep -lc "status: placeholder\|TBD\|TODO" project/*.md 2>/dev/null
```

For a file to count as **populated**: exists AND size > 400 bytes AND does NOT contain
`status: placeholder` on any line.

Files to assess:

| File | Populated → means |
|------|-------------------|
| `project/research-focus.md` | Project identity is defined |
| `project/contributions.md` | Contributions and headline result are written |
| `project/system-design.md` | System architecture is described |
| `project/background-concepts.md` | Background concepts are listed |
| `project/related-work-clusters.md` | Related work is clustered |
| `project/experiment-config.md` | Experiment setup is defined |
| `project/venue-config.md` | Venue and deadline are set |
| `project/paper-paths.md` | LaTeX paths are configured |

Also extract these values for the header (read only lines containing these keys):

```bash
grep -h "^project_name:\|^venue:\|^deadline:" project/research-focus.md project/venue-config.md 2>/dev/null | head -6
```

---

## Step 3 — Read Paper Paths

Read `project/paper-paths.md` (first 20 lines only) to get `sections_dir`, `figures_dir`,
and `main_tex`. These tell you where to scan for written sections and compiled PDFs.

If `paper-paths.md` doesn't exist or has `TODO` paths, use these fallbacks:
- sections: `paper/sections/`
- tables: `paper/tables/`
- figures: `paper/figures/`
- main tex: `paper/main.tex`

---

## Step 4 — Scan Artifact Directories

Use shell commands to check what exists without reading file contents.

```bash
# Literature tracker and synthesis state
ls literature/papers.csv 2>/dev/null                                   # tracker exists?
grep -c ",synthesized," literature/papers.csv 2>/dev/null || echo 0    # synthesized paper count
ls -d literature/synthesis/*/ 2>/dev/null | wc -l                      # synthesis topic dirs

# Result tables
ls paper/tables/*.tex 2>/dev/null | wc -l

# Written sections — check existence and size
ls -la paper/sections/*.tex 2>/dev/null || echo "NO_SECTIONS"

# Experiment results
ls results/ runs/ output/ 2>/dev/null | head -5

# Compiled PDF (proxy for latex-compile-and-check having run)
ls paper/*.pdf paper/main.pdf 2>/dev/null | wc -l
```

Adjust paths based on what you read from `paper-paths.md`.

---

## Step 5 — Evaluate Completion Status

Using the data collected above, assign each skill a status:

| Symbol | Meaning |
|--------|---------|
| ✓ | Done — artifact exists and looks substantive |
| ~ | Partial — artifact exists but is thin or placeholder |
| ○ | Ready — prerequisites are met, can run now |
| · | Not ready — prerequisites missing (show what's blocking) |
| — | Not applicable — skill not relevant to this project yet |

### Detection Rules (Artifact → Skill Status)

**project-init**
- ✓ if `project/research-focus.md` is populated
- ~ if it exists but is small or placeholder
- · otherwise

**paper-search-and-triage**
- ✓ if `literature/` has ≥ 3 .md files
- ~ if 1–2 files exist
- ○ if project-init is done
- · if project-init not done

**deep-paper-synthesis**
- ✓ if `literature/papers.csv` has ≥ 1 row with status `synthesized`
- ~ if `literature/synthesis/` has subdirectories but papers.csv synthesized count is 0
  (synthesis started but tracker not yet updated, or only partially complete)
- ○ if paper-search-and-triage is done (papers.csv exists with ≥ 1 `to-read` entry)
- · otherwise

**research-gap-mapper**
- ✓ if `literature/gap_map.md` exists and is populated (> 400 bytes)
- ○ if deep-paper-synthesis is ✓ or ~
- · otherwise

**new-idea-generator**
- ✓ if `project/contributions.md` is populated (ideas converted to contributions)
- ○ if research-gap-mapper is ✓
- · otherwise

**experiment-designer**
- ✓ if `project/experiment-config.md` is populated
- ~ if it exists but is placeholder
- ○ if `project/system-design.md` is populated
- · otherwise

**experiment-runner-monitor**
- ✓ if `results/`, `runs/`, or `output/` directory has files
- ~ if directory exists but is empty
- ○ if experiment-designer is ✓
- · otherwise

**result-analyzer-and-table-gen**
- ✓ if sections_dir/../tables/ (or `paper/tables/`) has ≥ 1 .tex file
- ○ if experiment-runner-monitor is ✓
- · otherwise

**error-cluster-and-fix-proposer**
- ○ if results exist (check same dirs as experiment-runner-monitor)
- · otherwise

**ablation-designer**
- ○ if result-analyzer-and-table-gen is ✓
- · otherwise

**write-background-section**
- ✓ if a section file matching `background*.tex` or `prelim*.tex` exists and size > 500B
- ~ if file exists but is small (likely stub)
- ○ if `project/background-concepts.md` is populated, OR if project-init is done (can draft from scratch)
- · otherwise

**write-methodology-section**
- ✓ if a section file matching `method*.tex`, `approach*.tex`, or `design*.tex` exists and size > 500B
- ~ if file exists but small
- ○ if `project/system-design.md` is populated
- · if system-design.md is placeholder or missing

**write-related-work**
- ✓ if a section file matching `related*.tex` exists and size > 500B
- ~ if file exists but small
- ○ if any literature exists: `literature/papers.csv` has entries, OR files exist under
  `literature/synthesis/`, OR `literature/gap_map.md` exists
  (write-related-work self-derives clusters from whatever is available)
- · otherwise (no literature at all)

**write-intro-and-abstract**
- ✓ if `intro*.tex` or `abstract*.tex` exists and size > 500B
- ~ if exists but small
- ○ if `project/contributions.md` is populated
- · if contributions.md is placeholder

**paper-experiments**
- ✓ if a section file matching `experiment*.tex`, `eval*.tex`, or `results*.tex` exists and size > 500B
- ~ if exists but small
- ○ if result-analyzer-and-table-gen is ✓
- · otherwise

**paper-draft**
- ✓ if main.tex exists and has ≥ 4 `\input` or `\include` statements
- ~ if main.tex exists but only 1–3 includes (partial assembly)
- ○ always (can run at any stage, produces stubs for missing content)

**latex-compile-and-check**
- ✓ if a .pdf file exists in the paper directory
- ○ if paper-draft is ✓ or ~
- · otherwise

**result-reproduction-verifier**
- ○ if result-analyzer-and-table-gen is ✓
- · otherwise

**submission-manager**
- ○ if latex-compile-and-check is ✓ and venue-config is populated
- · otherwise

**camera-ready-finalizer**
- — unless user has mentioned acceptance

**reviewer-response-drafter**
- — unless user has mentioned reviews received

**grant-context-framer**, **artifact-packager**
- — unless specifically requested

---

## Step 6 — Infer Project Stage

Based on the pattern of ✓ and ○ statuses, determine the current stage:

| Stage | Indicators |
|-------|-----------|
| **Problem Formulation** | project-init done, little else |
| **Literature Review** | paper-search-and-triage in progress |
| **Gap & Idea Synthesis** | deep-paper-synthesis, research-gap-mapper running |
| **System Design** | system-design.md being populated |
| **Experimentation** | experiment-designer done, running experiments |
| **Analysis & Tables** | results exist, generating tables |
| **Writing** | ≥ 2 section files exist |
| **Polishing** | All sections exist, working on quality |
| **Submission Ready** | Paper compiles, within page limit |

---

## Step 7 — Compute Recommended Next Steps

From all skills marked ○ (ready), select the top 3–5 recommendations in priority order:

**Priority ordering heuristic:**
1. Skills that unblock the most other skills come first
2. Within the same "dependency depth", prefer skills whose outputs feed the paper draft
3. Writing skills take lower priority than data/analysis skills (you need results before prose)
4. `paper-draft` is always in the list if any writing skill is ✓ or ~ (useful to assemble what exists)

For each recommended skill, write one sentence on **why now** and **what it produces**.

---

## Step 8 — Render the Dashboard

Output the status using this format. Use plain text — no HTML, no markdown tables for the
main status (use symbols and spacing instead — it renders better in terminal):

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  PROJECT STATUS: [project_name or "unnamed project"]
  Venue: [venue or "TBD"]  |  Deadline: [deadline or "not set"]
  Stage: [inferred stage]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

RESEARCH SETUP
  [✓/~/○/·] project-init               [one-line artifact summary]
  [✓/~/○/·] paper-search-and-triage    [e.g. "12 papers in literature/"]
  [✓/~/○/·] deep-paper-synthesis       [e.g. "4/12 synthesized (avg 2.1KB)"]
  [✓/~/○/·] research-gap-mapper        [e.g. "related-work-clusters.md populated"]
  [✓/~/○/·] new-idea-generator         [e.g. "contributions.md is placeholder"]

SYSTEM & EXPERIMENTS
  [✓/~/○/·] experiment-designer        [e.g. "experiment-config.md populated"]
  [✓/~/○/·] experiment-runner-monitor  [e.g. "no results found"]
  [✓/~/○/·] result-analyzer-and-table-gen  [e.g. "3 tables in paper/tables/"]
  [✓/~/○/·] error-cluster-and-fix-proposer
  [✓/~/○/·] ablation-designer

PAPER WRITING
  [✓/~/○/·] write-background-section   [e.g. "background.tex (1.2KB)"]
  [✓/~/○/·] write-methodology-section  [e.g. "methodology.tex exists but thin (180B)"]
  [✓/~/○/·] write-intro-and-abstract   [e.g. "no section file found"]
  [✓/~/○/·] write-related-work         [e.g. "needs related-work-clusters.md"]
  [✓/~/○/·] paper-experiments          [e.g. "needs result tables first"]
  [✓/~/○/·] paper-draft                [e.g. "○ can run now — assembles stubs"]

FINISHING
  [✓/~/○/·] latex-compile-and-check    [e.g. "no PDF found yet"]
  [✓/~/○/·] submission-manager
  [    —   ] camera-ready-finalizer     not applicable yet

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
RECOMMENDED NEXT STEPS

  1. deep-paper-synthesis       8 papers in literature/ not yet synthesized
  2. research-gap-mapper        ready once synthesis is done
  3. paper-draft                assemble readable draft from what exists now

WHAT'S BLOCKING
  write-intro-and-abstract  →  project/contributions.md is placeholder
  write-related-work        →  project/related-work-clusters.md not populated
  paper-experiments         →  no result tables yet (run experiment-runner-monitor first)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

**Formatting notes:**
- Omit skills marked `—` from the dashboard unless there are ≥ 2 of them (collapse to a single line)
- If a skill is ✓, the artifact summary should state concretely what was found
- If a skill is ○ or ·, the artifact summary states what's needed
- Keep each line under 72 characters total
- The WHAT'S BLOCKING section only shows skills that are · (not ready), not all skills

---

## Handling Edge Cases

**No `project/` directory at all**: Print a minimal dashboard showing only project-init as ○,
and recommend running it first. Skip all other steps.

**Skills directory not found**: Note it at the top of the output ("skill discovery unavailable —
showing known skills only"), then proceed with the hardcoded skill list above.

**Paper directory not found**: Show all writing skills as ○ if their config prerequisites are met,
note "paper LaTeX not set up — run project-init to configure paths."

**Single-section project** (e.g., workshop paper, extended abstract): If venue-config shows a
short venue format, simplify the PAPER WRITING section accordingly.
