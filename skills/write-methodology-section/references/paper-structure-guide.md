# Paper Structure Guide — 8-Page ACL Systems/Benchmark Paper

This guide describes the recommended section structure, word budgets, and content guidelines
for an 8-page ACL long paper presenting a system or benchmark (like the AutoPatch benchmark).

---

## Overall Section Structure

For an 8-page systems/benchmark paper at ACL, the recommended structure is:

```
1. Introduction          (~0.7 pages)
2. Background            (~1.0 pages)
3. System Design / Methodology   (~2.0–2.5 pages)
4. Experiments           (~2.0 pages)
5. Related Work          (~0.75–1.0 pages)
6. Conclusion            (~0.25–0.3 pages)
   Limitations           (~0.25 pages, required by ACL)
   [Acknowledgments]     (review: omit; final: ~0.1 pages)
   References            (unlimited, not counted)
```

Total: ~7.0–7.75 pages of content, leaving margin for figures and tables within the 8-page limit.

---

## Section-by-Section Guidance

### 1. Introduction (~0.7 pages, ~350–450 words)

**Purpose**: Hook the reader, state the problem, identify the gap, present contributions, and roadmap the paper.

**Required elements**:
- Opening hook (1–2 sentences): a compelling fact, statistic, or framing of the security problem.
- Problem statement (2–3 sentences): what specifically this paper tackles.
- Gap statement (2–3 sentences): what prior work does NOT address.
- Approach overview (2–3 sentences): how this paper addresses the gap (system/benchmark description at high level).
- Contributions (3–4 bullet points, starting with action verbs).
- Roadmap sentence: "The rest of this paper is organized as follows..."

**What does NOT belong here**:
- Detailed method description (that goes in Section 3).
- Literature review (that goes in Section 5).
- Detailed experimental results beyond headline numbers.

---

### 2. Background (~1.0 page, ~500–650 words)

**Purpose**: Give reviewers the foundational concepts needed to evaluate the paper. NOT a literature review.

**Distinction from Related Work**:
- Background: defines and explains concepts that are USED by this paper (reader needs to understand them to follow the paper).
- Related Work: surveys prior art and positions this paper relative to it.
- A concept belongs in Background if a reviewer unfamiliar with the subdomain would be lost without it.
- A paper belongs in Related Work if it is a competing or complementary approach.

**Recommended subsections for AutoPatch**:

#### 2.1 Coverage-Guided Fuzzing
- Define fuzzing: automated test input generation to find bugs.
- Coverage-guided fuzzing (CGF): AFL/libFuzzer use coverage feedback to guide input mutation toward new code paths.
- OSS-Fuzz: Google's continuous fuzzing infrastructure for open-source C/C++ projects. 1000+ projects, millions of bugs found. Provides reproducers (PoC inputs) and sanitizer-instrumented builds.
- Why relevant: ARVO dataset is derived from OSS-Fuzz; our crash inputs are OSS-Fuzz PoCs.

#### 2.2 Memory Safety Sanitizers
- ASAN (AddressSanitizer): detects heap/stack buffer overflows, use-after-free, use-after-return. Compile-time instrumentation; ~2× slowdown. Reports crash type + stack trace.
- MSAN (MemorySanitizer): detects reads of uninitialized memory. Linux only (requires instrumented libc).
- UBSAN (UndefinedBehaviorSanitizer): detects signed integer overflow, null pointer dereference, out-of-bounds array indexing, etc.
- Why relevant: ARVO crash reports are produced by these sanitizers; the stack trace + SUMMARY line we give to the LLM comes directly from sanitizer output.

#### 2.3 The ARVO Dataset
- ARVO = Automated Regression Vulnerability Oracle.
- Derived from OSS-Fuzz: each ARVO case is a (vulnerable commit, fix commit, PoC input, Docker image) tuple.
- Docker image: pre-built sanitizer-instrumented environment containing both the vulnerable and fixed versions of the code. This lets us test patches in isolation.
- Scale of ARVO: ~15,000+ cases covering hundreds of OSS-Fuzz projects.
- Why relevant: ARVO is the evaluation dataset for AutoPatch. We use the PoC input to verify that a generated patch eliminates the crash.

#### 2.4 LLMs for Code Generation and Repair
- Brief: modern LLMs (GPT-4, Claude, etc.) achieve strong performance on code generation benchmarks (HumanEval, SWE-bench).
- Key capability: LLMs can read a crash report + vulnerable function and generate a corrected version.
- In AutoPatch: the LLM receives the sanitizer crash output + the source code of the crashing function and returns a patched version.

#### 2.5 Automated Program Repair (APR)
- APR: the field of automatically generating patches for bugs, without human intervention.
- Traditional APR: search-based (GenProg), template-based, constraint-based. Limited to predefined fix patterns.
- LLM-based APR: LLMs as generative patch proposers — no fix templates, can handle novel bug classes.
- Why relevant: AutoPatch is an LLM-based APR system; positioning it in APR literature.

---

**Word budget per subsection**: ~80–130 words each (2–4 paragraphs total across all subsections).

---

### 3. System Design / Methodology (~2.0–2.5 pages, ~1000–1300 words)

**Purpose**: Describe the system architecture accurately and accessibly. Must be reproducible from this section alone (given the ARVO dataset).

**Recommended subsections for AutoPatch**:
- 3.1 Overview (pipeline diagram stub)
- 3.2 Dataset: ARVO (brief re-statement from benchmark perspective, not background)
- 3.3 Patch Generation (how the LLM is queried, what it receives, what it returns)
- 3.4 Verification Pipeline (multi-tier: crash fix → test suite → coverage → differential)
- 3.5 Agentic Repair Loop (how feedback from failed tiers drives re-generation)

**Figures to include**:
- `fig:architecture`: full pipeline flowchart (input → patch gen → tier 1 → tier 2 → output).
- `fig:prompt`: example prompt structure (crash report + function code → LLM → patch).

**Algorithms to include**:
- Algorithm 1: Main repair loop (pseudocode for `DiagPatchGenerator` + `MultiTierRepairAgent`).

---

### 4. Experiments (~2.0 pages, ~1000–1200 words)

**Purpose**: Evaluate the system empirically and answer the research questions.

**Recommended subsections**:
- 4.1 Experimental Setup (dataset split, models evaluated, hardware, timeout budgets)
- 4.2 Main Results (primary table: model × metric)
- 4.3 Analysis (iteration counts, failure mode breakdown, per-tier analysis)
- 4.4 Ablation (effect of removing verification tiers, effect of retry budget)

**Required tables**:
- `tab:results-main`: main results table with models as rows, metrics as columns (QA pass rate, patch gen rate, Tier 1 rate, correct patch rate). Use booktabs.
- `tab:ablation`: ablation results.

**Key metrics to report** (from results_analysis_20260402.md):
- QA pass rate: 86.7% (13/15)
- Patch generation rate: 92.3% (of QA-passed)
- Tier 1 (crash fixed): 60.0% (9/15)
- Correct patch rate: 53.3% (8/15)
- Avg build iterations: 2.1
- Avg crash-fix iterations: 1.8
- Avg patch gen time: 4.7 min

---

### 5. Related Work (~0.75–1.0 page, ~400–550 words)

**Purpose**: Survey prior art and clearly differentiate this work. NOT a background section.

**Recommended clusters**:
- 5.1 Automated Program Repair (APR)
- 5.2 LLMs for Security / Vulnerability Repair
- 5.3 Vulnerability Benchmarks and Datasets
- 5.4 Fuzzing and Sanitizer-Based Testing

**Key distinction from Background**: Related Work cites competing or complementary *papers*; Background explains *concepts*.

---

### 6. Conclusion (~0.25–0.3 pages, ~120–180 words)

**Purpose**: Summarize contributions and gesture toward future work.

**Required elements**:
- 1 paragraph: what we built and the key results (do not just repeat the abstract).
- 1 paragraph: limitations and future directions (or merge with the Limitations section).

---

### Limitations Section (REQUIRED by ACL)

- Unnumbered section: `\section*{Limitations}`
- Required at ACL venues. Must appear in both review and final versions.
- Discuss: dataset size (15 cases is small), single-language focus (C/C++), LLM API costs, patch correctness definition (crash fix ≠ semantic correctness), multi-file patch limitation.
- Target length: ~100–200 words.

---

## What Belongs in Background vs. Related Work — Decision Table

| Concept/Paper | Background | Related Work |
|---|---|---|
| What is ASAN? | Yes | No |
| MSAN/UBSAN definitions | Yes | No |
| What is OSS-Fuzz? | Yes | Brief mention only |
| ARVO dataset design | Yes | No |
| VulnFix (prior APR tool) | No | Yes |
| SWE-bench (code repair benchmark) | No | Yes |
| InstructionEval, CyberSecEval | No | Yes |
| How AFL works (high level) | Yes | No |
| Coverage-guided fuzzing survey paper | No | Yes (brief) |
| GPT-4 code generation capability | Yes (1 sentence) | No |

---

## Page Budget Tracking Template

Use this mental model when drafting:

```
Page 1:   Title + Abstract + Intro start
Page 2:   Intro end + Background start
Page 3:   Background end + Methodology start
Page 4-5: Methodology (architecture, algorithm)
Page 6-7: Experiments (setup, results, analysis)
Page 8:   Related Work + Conclusion + Limitations
```

If a section is running long, cut from Related Work or Analysis first, never from Methodology or Experiments.
