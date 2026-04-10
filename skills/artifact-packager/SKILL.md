---
name: artifact-packager
description: |
  Use this skill whenever the user wants to package code for release, prepare for
  artifact evaluation, write an artifact appendix, or prepare a reproducibility package.
  Trigger on phrases like:
  "package artifact", "prepare code release", "artifact evaluation",
  "package code for submission", "write artifact appendix", "prepare code for ACM AE",
  "release code", "package for USENIX artifact", "prepare reproducibility package",
  "code release", "write artifact description", "AE submission",
  "prepare for artifact evaluation committee", "artifact badge",
  "package for camera ready", "open source the code", "make code public",
  "prepare supplementary material", "create artifact README",
  "write the artifact appendix section", "get ready for code release".
  Use when the paper is accepted and the authors want to make code publicly available.
version: 1.1.0
tools: Read, Glob, Grep, Bash, Write, Edit
---

# Artifact Packager

This skill privacy-scans the codebase, curates an `artifact/` directory, writes an
artifact README and LaTeX appendix, and generates a venue-specific pre-release checklist
per ACM AE, USENIX AE, and ACL reproducibility standards.

**Project adaptation**: This skill reads `project/research-focus.md`,
`project/system-design.md`, and `project/experiment-config.md` to populate all
artifact descriptions, run instructions, and expected results. No content is hardcoded
to a specific project — everything is derived from your project config.

**Important**: After creating the artifact appendix, remind the user to include it in
the main .tex file and push to Overleaf.

---

## Output Locations

| Output | Path |
|---|---|
| Artifact directory | `artifact/` |
| Artifact README | `artifact/README.md` |
| Code copy (privacy-cleaned) | `artifact/code/` |
| Data subset | `artifact/data/` |
| Artifact appendix (LaTeX) | `paper/latex/sections/artifact_appendix.tex` |
| Privacy scan report | `artifact_privacy_scan_YYYYMMDD.md` |
| AE checklist | `artifact/ae_checklist_YYYYMMDD.md` |

---

## Step 0: Load Project Context

Read the project config before any other step:

```
Read: project/research-focus.md       → system_name, core problem, approach
Read: project/system-design.md        → pipeline steps, key components, datasets
Read: project/experiment-config.md    → run command template, metrics, result file schema
Read: project/paper-paths.md          → LaTeX paths for appendix placement
```

Extract:
- `system_name` → `{{SYSTEM_NAME}}`
- Pipeline description and key components from system-design.md
- Primary metric name and definition from experiment-config.md
- Run command template from experiment-config.md
- Dataset names and paths from experiment-config.md

---

## Step 1: Ask User for Target Venue and Badge Type

Before proceeding, ask:

```
Artifact packaging requires some choices. Please answer:

1. Target venue:
   a) ACM conference (ACM AE badges: Available, Functional, Results Reproduced)
   b) USENIX conference (USENIX AE badges: Artifacts Available, Functional, Results Reproduced)
   c) ACL (reproducibility checklist, no formal badges but reproducibility reviewed)
   d) Other: ___

2. Which badge(s) are you applying for?
   - Available: Code is publicly accessible (e.g., on GitHub/Zenodo)
   - Functional: Code runs and produces output matching the paper's claims
   - Results Reproduced: Independent reproduction confirms key results

3. Is this a full release (full codebase) or a curated artifact (selected scripts + data)?

4. Where will the artifact be hosted?
   a) GitHub repository (public)
   b) Zenodo (DOI, permanent archival)
   c) ACM/USENIX supplemental material system
   d) Other: ___

5. What is the artifact's repository URL (or placeholder if not yet created)?
```

Wait for answers before proceeding. The venue determines which checklist to generate
and which appendix format to use.

---

## Step 2: Privacy Scan — Find Sensitive Content

Before creating any artifact, scan the entire codebase for sensitive content that must
not be released. This is a critical step — do not skip it.

### 2a: Email Addresses

```
Grep: pattern=[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}, path=., glob=**/*.py, output_mode=content
Grep: pattern=[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}, path=., glob=**/*.sh, output_mode=content
Grep: pattern=[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}, path=., glob=**/*.yaml, output_mode=content
Grep: pattern=[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}, path=., glob=**/*.json, output_mode=content
```

Filter out false positives (package names, test fixtures, citation emails).

### 2b: API Keys and Secrets

```
Grep: pattern=(?:api_key|api-key|apikey|secret|token|password|passwd|credential)\s*[=:]\s*["\'][^"\']{8,}, path=., glob=**/*.py, output_mode=content, -i=true
Grep: pattern=sk-[a-zA-Z0-9]{20,}, path=., output_mode=content
Grep: pattern=[A-Z_]*API_KEY\s*=\s*[^$\n], path=., output_mode=content
```

Also scan for credential files:
```
Glob: **/.env
Glob: **/*.key
Glob: **/credentials.json
Glob: **/service_account*.json
```

### 2c: Absolute Paths with Usernames

```
Grep: pattern=/home/[a-zA-Z0-9_-]+/, path=., glob=**/*.py, output_mode=content
Grep: pattern=/Users/[a-zA-Z0-9_-]+/, path=., glob=**/*.py, output_mode=content
Grep: pattern=/workspace/[^/\s]+/[^/\s]+, path=., glob=**/*.py, output_mode=content
Grep: pattern=/workspace/[^/\s]+/[^/\s]+, path=., glob=**/*.sh, output_mode=content
```

Absolute paths with usernames or workspace-specific paths must be replaced with relative
paths or configurable environment variables.

### 2d: Author Names in Comments

Extract the author names from the main LaTeX file (`\author{...}` block).
Read `project/paper-paths.md` to find `main_tex`, then search code comments for
any author names or lab/institution names found there.

```
Grep: pattern=(?:TODO|FIXME|NOTE).*[Aa]uthor, path=., glob=**/*.py, output_mode=content
```

### 2e: Git Configuration with Embedded Usernames

```
Grep: pattern=url\s*=\s*https://[^@]+@, path=., glob=**/.git/config, output_mode=content
```

Check if `.git/config` contains `https://username@github.com/...` style URLs.
Prefer `git@github.com:org/repo.git` (SSH) or plain `https://github.com/org/repo.git`.

### 2f: Report Privacy Scan Results

Write `artifact_privacy_scan_YYYYMMDD.md`:

```markdown
# Privacy Scan Report — YYYY-MM-DD

## Summary: N issues found (K critical, M informational)

## Critical Issues (must fix before release)

### 1. [Issue type]
- File: [path], line [N]
- Content: `[excerpt]`
- Action required: [specific fix]

## Informational Issues (review and decide)

### N. [Issue type]
- File: [path]
- Action: [suggestion]

## Items Reviewed and Safe
- [list]

## Next Step
Please review all critical issues. Once you confirm each is resolved, type YES to proceed
with packaging.
```

Show this report to the user and wait for confirmation before proceeding.

---

## Step 3: Create Artifact Directory Structure

After the user confirms the privacy scan issues are resolved, create the artifact directory.
Use `project/system-design.md` to understand what code directories and data directories
are relevant to the paper's evaluation.

```bash
mkdir -p artifact/code
mkdir -p artifact/data
mkdir -p artifact/results
```

The structure should mirror what is needed to reproduce the paper's experiments:

```
artifact/
  README.md                   # Main artifact README (written in Step 6)
  LICENSE                     # Copy of the project license
  INSTALL.md                  # Installation instructions (detailed)
  code/                       # Privacy-cleaned copy of the benchmark/system code
    [code directories from project/system-design.md]
  data/                       # Dataset and evaluation data
    [dataset directories from project/experiment-config.md]
  results/                    # Pre-computed results for comparison
    [result files matching result_file_pattern from experiment-config.md]
  environment.yml             # Conda environment spec (pinned versions)
  requirements.txt            # pip requirements (as fallback)
  ae_checklist_YYYYMMDD.md   # Venue-specific AE checklist
```

When copying `code/`, apply the privacy fixes identified in Step 2:
- Replace hardcoded paths with environment variables or relative paths
- Remove credential values; replace with environment variable references
- Remove personal email addresses from comments
- Replace author-identifying comments with generic ones

---

## Step 4: Verify Environment Specification

Check that `environment.yml` (or equivalent) is complete and pinned:

```
Glob: environment.yml
Glob: requirements.txt
Glob: setup.py
Glob: pyproject.toml
```

Read the environment file and verify:
1. All direct dependencies are listed with pinned versions
2. The Python version is specified
3. GPU/hardware requirements are noted (if applicable)
4. The operating system requirements are noted

If missing or has unpinned versions (e.g., `numpy>=1.20` instead of `numpy==1.21.5`), flag:

```
Missing or incomplete environment specification:
- No pinned versions for: [list of packages]
- AE reviewers need pinned versions to reproduce the exact environment

Please pin all versions in environment.yml before packaging.
```

The environment spec must also cover:
- Any required runtime (container engine, compiler, etc.)
- API access requirements (LLM provider API key, if applicable)
- Hardware requirements (CPU cores, RAM, disk space)

---

## Step 5: Write the Artifact Appendix (LaTeX)

Write `paper/latex/sections/artifact_appendix.tex`. Use content derived from the project
config files loaded in Step 0 — do not use any hardcoded system names or values.

Structure:

```latex
\section{Artifact Description}
\label{app:artifact}

\subsection{Abstract}

The artifact for this paper consists of the \textsc{{{SYSTEM_NAME}}} implementation
and the evaluation dataset. [1-2 sentences from project/research-focus.md describing
what the system does and how it is evaluated.]

\subsection{Artifact Check-List}

\begin{itemize}
  \item \textbf{Algorithm:} [1-sentence description of the algorithm from system-design.md]
  \item \textbf{Program:} [runtime requirements — e.g., Python version, container engine]
  \item \textbf{Data set:} [dataset name from experiment-config.md] available at \url{[REPO\_URL]/data/}.
  \item \textbf{Run-time environment:} [OS, RAM, disk requirements]
  \item \textbf{Hardware:} [GPU requirements or "No GPU required"]
  \item \textbf{Execution:} [1-sentence description of the main run command from experiment-config.md]
  \item \textbf{Metrics:} [primary metric name and definition from experiment-config.md]
  \item \textbf{Output:} [result file names from experiment-config.md result_file_pattern]
  \item \textbf{How much disk space required?} [estimate from project knowledge]
  \item \textbf{How much time is needed?} [from timing_estimate in experiment-config.md]
  \item \textbf{Publicly available?} Yes. See \S\ref{app:artifact-availability}.
  \item \textbf{Code licenses:} [license type]
  \item \textbf{Archived?} [Zenodo DOI placeholder or "To be archived upon acceptance."]
\end{itemize}

\subsection{Description}
\label{app:artifact-description}

\subsubsection{How to Access}
\label{app:artifact-availability}

The artifact is available at: \url{[REPO\_URL]}.

\subsubsection{Hardware Dependencies}

[Enumerate hardware requirements derived from project/experiment-config.md and
project/system-design.md — e.g., OS, RAM, disk, network access for APIs.]

\subsubsection{Software Dependencies}

[Enumerate software requirements — runtime, package manager, key packages.]

\subsection{Installation}

\begin{verbatim}
[Installation commands — adapt from environment.yml and project/system-design.md pipeline]
\end{verbatim}

\subsection{Experiment Workflow}
\label{app:artifact-usage}

The main entry point is:

\begin{verbatim}
[Run command template from project/experiment-config.md, with placeholders explained]
\end{verbatim}

Expected outputs:
\begin{itemize}
  [List result files from experiment-config.md result_file_pattern with 1-line description each]
\end{itemize}

\subsection{Evaluation and Expected Results}
\label{app:artifact-reproduction}

Expected results on [dataset name] with [model/system used]:

\begin{table}[h]
\centering
\small
\caption{Expected results for artifact reproduction ([dataset]).
  Due to [source of variance — e.g., LLM non-determinism], results may vary by $\pm$[tolerance].}
\label{tab:artifact-expected}
\begin{tabular}{lcc}
\toprule
\textbf{Metric} & \textbf{Expected} & \textbf{Tolerance} \\
\midrule
[primary_metric from experiment-config.md]  & [value from latest run] & $\pm$[tolerance] \\
[secondary metrics]                          & [values]               & $\pm$[tolerance] \\
\bottomrule
\end{tabular}
\end{table}

\subsection{Metrics}
\label{app:artifact-metrics}

The primary metric is \textbf{[primary_metric name]} ([primary_metric definition from
experiment-config.md]). See the metrics glossary in the repository README for full definitions.
```

Fill all bracketed placeholders from the project config files. Tell the user which values
you could not derive automatically and need their input.

---

## Step 6: Write artifact/README.md

Write a comprehensive README following the structure AE reviewers expect. Use content from
the project config files (Step 0) — no hardcoded system-specific content.

```markdown
# {{SYSTEM_NAME}} Artifact

> Artifact for: [paper title from project/research-focus.md] ([VENUE YEAR])

## Overview

[2-3 sentences from project/research-focus.md: what the system does, what problem it solves,
what benchmark it evaluates on.]

## Quick Start (~5 minutes)

```bash
[Condensed setup and minimal run command — e.g., run on 1 case to verify environment]
```

Check `[result file]` for the output.

## System Requirements

[Enumerate from project/experiment-config.md and project/system-design.md:
OS, Python version, RAM, disk, network, API keys, etc.]

## Installation

[Full installation steps from environment.yml and system-design.md pipeline]

## Running the Full Benchmark

[Full run command from experiment-config.md run_command_template with all flags explained]

## Expected Results

[Table of expected metrics with tolerances — from latest experiment run results]

## Validating Results

```python
import json
# Compare your result file against the reference:
with open("artifact/results/[result file]") as f:
    reference = json.load(f)
with open("[your result file]") as f:
    yours = json.load(f)
# Compare primary metric:
primary = "[primary_result_field from experiment-config.md]"
print(f"Reference: {reference.get(primary)}")
print(f"Yours:     {yours.get(primary)}")
```

## Troubleshooting

[Common issues — API key not set, missing dependencies, insufficient disk space]
```

---

## Step 7: Generate Venue-Specific AE Checklist

Write `artifact/ae_checklist_YYYYMMDD.md` with the appropriate venue checklist.
See `references/artifact-evaluation-guide.md` for full badge criteria.

### For ACM:
Include the full ACM AE checklist with PASS/FAIL/N-A for each criterion.

### For USENIX:
Include USENIX AE criteria (similar to ACM but with some differences in badge names).

### For ACL:
Include the ACL reproducibility checklist questions from the paper submission form.

---

## Step 8: Overleaf Sync Reminder

After writing the artifact appendix:

> **Overleaf sync required.** The artifact appendix is in `paper/latex/sections/artifact_appendix.tex`.
> You must include it in the main .tex file with `\input{sections/artifact_appendix}` before
> the `\end{document}`.
>
> Then push to Overleaf:
> ```bash
> cd paper && git add -A && git commit -m "Add artifact appendix" && git push
> ```

---

## Step 9: Final Summary

Print a summary of everything created:

```
Artifact packaging complete.

Files created:
  artifact/README.md              — Main artifact README
  artifact/code/                  — Privacy-cleaned code
  artifact/data/                  — Evaluation datasets
  artifact/results/               — Pre-computed reference results
  artifact/environment.yml        — Pinned environment spec
  artifact/ae_checklist_YYYYMMDD.md — Venue-specific AE checklist
  paper/latex/sections/artifact_appendix.tex — LaTeX appendix for the paper

Privacy scan: K issues found and resolved (see artifact_privacy_scan_YYYYMMDD.md)

Values you need to fill in manually:
  [List any placeholders you could not auto-populate from config files]

Next steps:
  1. Add \input{sections/artifact_appendix} to the main .tex before \end{document}
  2. Push to Overleaf: cd paper && git push
  3. Upload artifact/ to [Zenodo / GitHub / submission system]
  4. Run result-reproduction-verifier to confirm artifact produces claimed results
```

---

## Reference Files

- `references/artifact-evaluation-guide.md` — ACM AE badge criteria, USENIX AE requirements,
  ACL reproducibility checklist, AE reviewer pain points, and README template structure
