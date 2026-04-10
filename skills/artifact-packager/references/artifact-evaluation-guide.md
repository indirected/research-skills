# Artifact Evaluation Guide

This guide covers badge criteria, reviewer expectations, and README templates for ACM AE,
USENIX AE, and ACL reproducibility submissions.

---

## 1. ACM Artifact Evaluation (AE)

### Badge Definitions

ACM offers three artifact evaluation badges, awarded independently:

#### Artifacts Available
**Criterion:** The artifact is publicly available and accessible at a stable URL.

Requirements:
- Code/data hosted at a publicly accessible location
- Stable URL (prefer DOI via Zenodo or ACM DL over raw GitHub — GitHub links can rot)
- No login required to access
- A license must be specified (MIT, Apache 2.0, or CC BY are common choices)

How to achieve:
1. Upload to Zenodo (get a DOI): https://zenodo.org
2. Or push to a public GitHub repo AND archive it on Zenodo
3. Include the DOI in the paper

**Common reason for rejection:** GitHub repo is private at time of AE review.

#### Artifacts Functional
**Criterion:** The artifact works and produces outputs matching its documented claims.

Requirements:
- Documentation: README with installation, usage, expected outputs
- Completeness: code and data sufficient to run the main experiments
- Exercisability: AE reviewer can run at least one experiment and get sensible output
- Consistency: outputs match what the paper describes (qualitatively or quantitatively)

How to achieve:
- Write a clear README with tested, copy-pasteable commands
- Include a "Quick Start" that runs in <30 minutes on typical hardware
- Provide expected output for each command
- Test the README on a clean machine (not just your own)

**Common reasons for rejection:**
- Environment setup fails (missing dependencies, wrong versions)
- Run command fails on a clean system
- Expected outputs are not documented
- Hardware requirements not met by typical reviewer machine

#### Results Reproduced
**Criterion:** The main results claimed in the paper can be reproduced using the artifact.

Requirements:
- The artifact can reproduce the key quantitative claims in the paper
- Results are within an acceptable tolerance (for non-deterministic methods, this is
  typically ±5-10% of the reported value)
- The paper must clearly state which results are expected to reproduce and with what tolerance

How to achieve:
- Provide pre-computed reference results for comparison
- Document expected variance due to non-determinism
- Include a comparison script that loads both reference and reproduced results
- Be explicit: "We claim Tier 1 rate of 60% ± 10pp due to LLM non-determinism"

**Common reasons for rejection:**
- Results differ by >10pp without explanation
- Hardware requirements (GPU, memory) not achievable by reviewer
- API keys required but not available (for LLM-based systems, note this and provide a
  demo mode or cached responses if possible)

---

## 2. ACM AE Checklist (per ACM SIGPLAN/SIGARCH template)

Use this checklist in the artifact submission form and in the artifact README:

```
Algorithm                    : [describe the algorithm]
Program                      : [language, version, OS]
Compilation                  : [how to compile, or "interpreted"]
Transformations              : [data preprocessing steps]
Binary                       : [yes/no — do you provide prebuilt binaries?]
Data set                     : [dataset name, size, source, license]
Run-time environment         : [OS, runtime dependencies]
Hardware                     : [CPU, GPU, RAM, disk requirements]
Run-time state               : [seeds, environment variables that affect results]
Execution                    : [how to run; expected duration]
Metrics                      : [which metrics, how computed]
Output                       : [what files are produced, what they contain]
Experiments                  : [which paper experiments can be reproduced, which cannot]
How much disk space?         : [in GB]
How much time to prepare?    : [setup time]
How much time to run?        : [per experiment; total]
Publicly available?          : [yes/no; URL; DOI]
Code licenses                : [license name]
Data licenses                : [license name]
Archived (DOI)?              : [yes/no; DOI]
```

---

## 3. USENIX Artifact Evaluation

USENIX AE uses similar badges with slightly different names:

| USENIX Badge | Equivalent to |
|---|---|
| Artifacts Available | ACM Artifacts Available |
| Artifacts Functional | ACM Artifacts Functional |
| Results Reproduced | ACM Results Reproduced |

### USENIX-Specific Requirements

1. **Kick-the-tires phase (3 days):** Reviewers do a quick check that the artifact
   can be set up. Your README must enable this in <30 minutes.

2. **Full evaluation phase (2 weeks):** Reviewers run the full experiments.
   Document how long each experiment takes.

3. **Appendix in paper:** USENIX requires an "Artifact Description" appendix with
   a standard format (hardware, software, workflow, expected results).

4. **Container encouraged:** Docker/VM image simplifies setup dramatically.
   Provide a Dockerfile and pre-built image on Docker Hub if possible.

### USENIX-Specific Checklist

```
[ ] README describes all experiments from the paper
[ ] Each experiment's expected output is documented
[ ] Expected run time documented for each experiment
[ ] Hardware requirements stated explicitly
[ ] Software requirements include exact version numbers
[ ] Data is included or instructions for downloading it are clear
[ ] Artifact passes kick-the-tires: setup works in <30 minutes
[ ] Results match paper within stated tolerance
```

---

## 4. ACL Reproducibility Checklist

ACL uses a reproducibility checklist embedded in the paper submission form (not separate
AE, but reviewers consider it). Key questions:

### For All Papers

```
[ ] All code is included in the supplementary material or publicly accessible
[ ] An environment specification (requirements.txt, conda env) is provided
[ ] The paper specifies all hyperparameters and their values
[ ] The paper includes the mean and variance of results across multiple runs
[ ] Error bars or confidence intervals are reported
[ ] Compute resources used (GPU type, hours) are stated
[ ] The paper explains which results are expected to vary and by how much
```

### For Papers with Experiments Involving Randomness

```
[ ] Random seeds are fixed and documented
[ ] If non-determinism is inherent (e.g., LLM temperature > 0), this is acknowledged
[ ] The number of independent runs used to compute means is stated
```

### For Papers Using Existing Datasets

```
[ ] The dataset is publicly available with a stable URL or DOI
[ ] The dataset license is compatible with the paper's use
[ ] Dataset statistics (size, splits, demographics if applicable) are in the paper
[ ] The preprocessing pipeline is fully described and reproducible
```

### For Papers Claiming SOTA

```
[ ] All baselines are reimplemented correctly or taken from their official repos
[ ] Hyperparameter tuning budget is equal across compared systems
[ ] Significance tests are reported
```

---

## 5. AE Reviewer Pain Points (and how to avoid them)

Based on common AE reviewer feedback, the following issues most often prevent badge award:

### Pain Point 1: Environment Setup Fails

**Problem:** `conda env create -f environment.yml` fails with version conflicts.

**Prevention:**
- Test on a clean VM/container before submission
- Pin ALL dependency versions: `numpy=1.21.5` not `numpy>=1.20`
- Include `conda env export --no-builds > environment.yml` in your build process
- Test on Linux even if you develop on macOS

### Pain Point 2: Missing Data

**Problem:** The code is there but the data is not, or the download instructions fail.

**Prevention:**
- Include small test datasets directly in the artifact (e.g., 5-case subset)
- Provide a download script with checksums: `sha256sum datasets/*.json`
- Test the download script on a fresh machine
- For large datasets, provide a smaller validated subset for quick testing

### Pain Point 3: Hardware Requirements Exceed Reviewer Capacity

**Problem:** Experiment requires 8 A100 GPUs and takes 2 weeks.

**Prevention:**
- Provide a "fast mode" that runs on CPU or fewer cases (<1 hour)
- Document clearly which claims can be reproduced in "fast mode" vs. full mode
- For LLM API-based systems: state clearly that an API key is required and estimate the cost

### Pain Point 4: Expected Outputs Not Documented

**Problem:** The code runs but the reviewer doesn't know if the output is correct.

**Prevention:**
- Include expected output files in `artifact/results/` (pre-computed reference)
- Write a comparison script: `python compare_results.py results/reference/stats.json results/reproduced/stats.json`
- Document tolerances explicitly: "Due to LLM non-determinism, expect ±10pp variance"

### Pain Point 5: Non-Determinism Not Acknowledged

**Problem:** LLM-based system produces different results on every run.

**Prevention:**
- State clearly in the README that results are non-deterministic
- Provide the tolerance: "Results should be within ±5 percentage points of the paper"
- Explain the source of variance: "LLM temperature defaults to 1.0; use temperature=0
  for more deterministic output (but performance may differ)"
- Consider providing pre-generated responses to replay without an API key

### Pain Point 6: Absolute Paths in Code

**Problem:** Code has hardcoded paths like `/home/jane/research/codevul/` that break
on any other machine.

**Prevention:** Use relative paths or configurable variables (`$BENCHMARK_ROOT`).

---

## 6. Artifact README Template Structure

The following structure is expected by most AE committees:

```markdown
# [System Name] Artifact

> Artifact for: [Full Paper Title] ([Venue] [Year])
> DOI: 10.XXXX/...
> Authors: [names — only in camera-ready, not review]

## Overview

[2-3 sentence summary of what the artifact does and what claims it supports]

## Quick Start

[Minimum set of commands to run one experiment in <30 minutes]

## System Requirements

### Hardware
- CPU: x86-64, [N] cores recommended
- RAM: [N] GB minimum, [N] GB recommended
- Disk: [N] GB free
- GPU: [required/optional — specify]
- Internet: [required/optional — for API calls]

### Software
- OS: Ubuntu 20.04+ (tested); macOS 12+ (untested)
- Python: 3.10+
- Container runtime: Docker ≥ 20.10 or Podman ≥ 3.0
- [Other dependencies]

## Installation

[Step-by-step, tested on a clean machine]

## Running Experiments

### Experiment 1: [Name] (reproduces Table N / Figure N)

[Command, expected duration, expected output]

### Experiment 2: [Name]

[...]

## Expected Results

[Table or description of expected values with tolerances]

## Validating Results

[How to compare reproduced results to reference results]

## Troubleshooting

[5-10 most common issues and fixes]

## License

[License name and brief description]

## Citation

[BibTeX entry for the paper]
```

---

## 7. Zenodo Upload Instructions

For archival with a DOI (required for ACM Artifacts Available badge):

1. Create a Zenodo account at https://zenodo.org
2. Click "New Upload"
3. Upload the artifact as a zip file: `zip -r artifact.zip artifact/`
4. Fill in metadata: title, authors (use final version, not anonymous), description,
   license, publication date
5. Set "Resource type" to "Software"
6. Link to the paper's DOI if available
7. Click "Publish" — this assigns a permanent DOI
8. Add the DOI to the paper appendix and to the GitHub repo README

**Important:** Zenodo DOIs are permanent but the content can be updated with new versions.
Publish a new version after any AE fixes, and cite the specific version DOI in the paper.

---

## 8. AutoPatch-Specific Notes

For the CybersecurityBenchmarks AutoPatch artifact:

### What can AE reviewers reproduce:
- Full benchmark on ARVO-Lite (15 cases, ~3 hours with concurrency=4)
- Results for any LLM for which they have an API key
- Qualitative behavior (patch generation, build verification, crash testing)

### What cannot be reproduced exactly:
- Per-case LLM responses (non-deterministic at temperature > 0)
- Wall-clock timing (varies by API latency and machine)
- Container build times (vary by network speed and caching)

### Recommended AE approach:
1. Provide the 15-case dataset in the artifact (it is already in the repo)
2. Include pre-computed responses for replay without an API key (as demo/reference)
3. State clearly: "Results may vary ±10pp due to LLM non-determinism"
4. For Reproduced badge: run on full 15-case dataset and compare to reference stats.json

### API Key Challenge:
LLM API keys cannot be distributed. State clearly:
- "This artifact requires an ANTHROPIC_API_KEY to run patch generation"
- "Cost estimate: ~$[N] per full benchmark run at current Claude pricing"
- "AE reviewers may use their own keys or contact us at [email] for a temporary key"
