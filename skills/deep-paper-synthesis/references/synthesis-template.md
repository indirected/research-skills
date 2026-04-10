# Paper Synthesis Template

This file contains the per-paper extraction card template and instructions for completing each
section. Use this template for every paper in the deep-paper-synthesis workflow.

---

## Full Paper Extraction Card Template

Copy this block for each paper and fill in all sections.

```markdown
---

### [{Full Paper Title}]({url})

**Authors**: {First3 ; et al.}
**Venue**: {venue abbreviation + year, e.g., "CCS 2024"}
**arXiv ID**: {arxiv_id or "N/A"}
**DOI**: {doi or "N/A"}
**Citation Count**: {N} (as of {date})
**Relevance Score**: {1-5}
**Access**: {FULL PDF | ABSTRACT ONLY | SEMANTIC SCHOLAR TLDR}

---

#### Problem Statement

{2-4 sentences. Answer: What specific problem does this paper address? Why does it matter?
What would break or remain unsolved without this work? What is the precise research question?}

#### Key Methodology / Approach

- **System/Algorithm**: {One sentence naming the system or algorithm and its overall structure}
- **Core Innovation**: {What is technically novel — the key idea that makes this different}
- **LLM / Model Used**: {Model name, version, prompting strategy; or "N/A — non-LLM approach"}
- **Oracle / Verifier**: {How correctness is verified: test suite, fuzzer, formal method, human}
- **Input/Output**: {What the system takes as input; what it produces as output}
- **Datasets / Benchmarks**: {Name the datasets used for training and/or evaluation}
- **Implementation Notes**: {Key tools, languages, frameworks; any fine-tuning performed}

#### Main Results and Metrics

| Metric | This Paper | Best Baseline | Notes |
|---|---|---|---|
| {primary metric, e.g., Correct Patch Rate} | {X%} | {Y% (Baseline Name)} | {brief note} |
| {secondary metric} | {X} | {Y} | |
| {additional metric} | {X} | {Y} | |

**Dataset breakdown** (if applicable):
- Evaluated on: {N} {programs/bugs/CVEs} from {source}
- Distribution: {e.g., "42% memory safety, 31% logic errors, 27% other"}

**Key finding** (1 sentence): {The most important quantitative or qualitative claim}

#### Limitations

- {Limitation 1: scope — e.g., "Evaluates on Java only; no C/C++ vulnerability benchmarks"}
- {Limitation 2: oracle — e.g., "Uses test suite oracle; may over-fit to existing tests"}
- {Limitation 3: scale — e.g., "Experiments limited to N programs; may not generalize"}
- {Limitation 4: threats — e.g., "Authors note risk of data contamination in LLM pretraining"}

#### Relation to This Work (AutoPatch)

{1-3 sentences. Is this paper a baseline? Competing approach? Supporting method? Does it
validate our approach or challenge it? Where does it appear in the AutoPatch paper:
Related Work, Experimental Comparison, or Methodology?}

**Gap phrase** (for papers.csv): "{This paper} [does / does not] address {X}; AutoPatch
[extends / differs by / improves on] this by {Y}."

**Cite in**: {Related Work | Results | Methods | All sections | Not cited}

---
```

---

## Section-by-Section Guidance

### Problem Statement

**Do:**
- State the precise problem (not just the topic area)
- Include a motivating consequence ("without this, practitioners must X manually")
- Match the framing to what the authors themselves emphasize in the abstract/intro

**Do not:**
- Paraphrase the abstract verbatim
- Be vague ("this paper addresses security")
- Add your own opinion about whether the problem matters

**Example (good):**
> This paper addresses the challenge of automatically repairing C/C++ memory safety
> vulnerabilities confirmed by OSS-Fuzz, without requiring developer intervention. Existing
> automated repair systems either rely on test suites that may not cover the vulnerability
> trigger, or require manual fault localization. The research question is whether an LLM pipeline
> guided by a fuzzer-based oracle can achieve comparable patch correctness to developer-written
> fixes.

**Example (bad):**
> The paper is about fixing vulnerabilities using AI. This is important because security is hard.

---

### Key Methodology — Notes by Paper Type

#### LLM-based Repair Papers
Required information:
- Which LLM(s) (GPT-4, GPT-3.5, Claude 3, CodeLlama, etc.)
- Prompting strategy: zero-shot / few-shot / chain-of-thought / iterative refinement
- Context provided to LLM: crash stack trace / vulnerable code / fix hint / all three
- Number of patch candidates generated per bug
- How candidates are ranked and selected

#### Classical APR Papers (non-LLM)
Required information:
- Repair operator type: template-based / search-based (genetic, random) / semantic / symbolic
- Search space: how large, how navigated
- Correctness oracle: test suite / specification / verification condition
- Any neural component (even if small)

#### Detection-focused Papers
Note explicitly: "This paper focuses on DETECTION, not repair. Relevant for comparison of
vulnerability localization step only."

#### Benchmark/Dataset Papers
Required information:
- How many bugs/CVEs in the dataset
- Source of bugs (real CVEs, synthetic, mined from repos)
- What metadata is provided (reproducer, fix, root cause)
- License and availability
- Compare dataset characteristics to ARVO

---

### Main Results — Metric Definitions

Standard metrics in the APR/vulnerability repair domain:

| Metric Name | Definition | Unit |
|---|---|---|
| Correct patch rate | Patch passes all available tests AND fixes the vulnerability oracle | % of bugs |
| Plausibility rate | Patch compiles AND passes some tests (but may over-fit) | % of bugs |
| Pass@k | At least 1 of k generated patches is correct | % of bugs |
| Over-fitting rate | Plausible patches that fail additional validation | % of plausible patches |
| Fault localization accuracy | Correct file/function/line identified | % of bugs |
| Time-to-patch | Wall clock time from bug input to generated patch | seconds/minutes |

For LLM-specific metrics:
| Metric Name | Definition |
|---|---|
| Token efficiency | Prompt + completion tokens per successfully patched bug |
| Retry rate | Average number of LLM calls required per bug |
| Compilation rate | Fraction of LLM outputs that compile without errors |

---

### Handling Papers Without Full PDF Access

When only the abstract is available:

1. Complete the Problem Statement from the abstract.
2. For Methodology: use what is described in the abstract + any figures on the Semantic Scholar
   page. Write "[Inferred from abstract]" for each bullet.
3. For Results: extract only what appears in the abstract (often the headline number only).
4. For Limitations: write "Not determinable from abstract. Common limitations in this class of
   work include: {list 2-3 typical limitations for this paper type}."
5. Mark the card clearly at the top: `**Access**: ABSTRACT ONLY`
6. Add an action item: "Retrieve full PDF before finalizing synthesis."

If the Semantic Scholar TLDR is available, quote it directly in the Problem Statement section
and note `[TLDR source]`.

---

## Cross-Paper Analysis Templates

### Thematic Cluster Summary

```markdown
## Thematic Clusters

### Cluster 1: {Name} ({N} papers)
**Papers**: {cite1}, {cite2}, {cite3}
**Common approach**: {2 sentences describing the shared methodology}
**Shared assumption**: {The key assumption that unifies this cluster}
**Collective limitation**: {What this entire cluster does not address}

### Cluster 2: {Name} ({N} papers)
...
```

### Idea Evolution Timeline

```markdown
## Idea Evolution

{Year range 1}: Early work established {foundation}. \citet{paper1} first showed...
{Year range 2}: The field shifted toward {approach}, exemplified by \citet{paper2} and
  \citet{paper3}, who demonstrated...
{Year range 3}: Most recently, LLM-based approaches have emerged, with \citet{paper4}
  achieving {result}, followed by \citet{paper5} extending to {extension}.
The current state of the art is {description}, but no existing work addresses {gap}.
```

### Open Problems Table

```markdown
## Open Problems (From Limitations Analysis)

| Problem | Papers Noting It | Severity | AutoPatch Addresses? |
|---|---|---|---|
| {problem 1} | cite1, cite2, cite3 | High | Yes — by {method} |
| {problem 2} | cite2, cite4 | Medium | Partially |
| {problem 3} | cite1 | Medium | No — future work |
| {problem 4} | cite3, cite5 | Low | N/A |
```

---

## Narrative Synthesis Paragraph Templates

### Opening Paragraph (Chronological Arc)

```
Automated program repair (APR) has been studied for over a decade, with early work such as
\citet{FirstPaper} demonstrating that {early finding}. Template-based approaches
\citep{template1, template2} improved scalability but remained limited to {scope limitation}.
The shift toward machine learning began with \citet{mlpaper}, who applied {technique} to achieve
{result}. The emergence of large language models has further transformed the landscape:
\citet{llmpaper1} first applied {LLM type} to program repair, showing {finding}, while
\citet{llmpaper2} extended this to {extension}.
```

### Gap Paragraph (Required — Positioning AutoPatch)

```
Despite this progress, existing work leaves critical gaps that {AutoPatch / our system} addresses.
First, {gap 1}: no existing work {specifics}, leaving {consequence}. Second, {gap 2}: while
\citet{paper} addresses {partial}, it {limitation}, which limits applicability to {context}.
Our approach addresses both gaps by {method contribution 1} and {method contribution 2}, evaluated
on {benchmark}, a benchmark specifically designed for {properties}.
```

---

## Synthesis File Header Template

```markdown
# Literature Synthesis: {TOPIC}
**Generated**: {YYYY-MM-DD}
**Skill version**: deep-paper-synthesis 1.0.0
**Papers synthesized**: {N}
**Status in tracker**: synthesized

## Papers in This Synthesis

| # | Title | Authors | Venue | Year | Score | Access |
|---|---|---|---|---|---|---|
| 1 | [{title}]({url}) | {authors} | {venue} | {year} | {score} | Full PDF |
| 2 | ... | | | | | Abstract only |

---
```
