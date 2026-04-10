# Introduction and Abstract Templates — Security/ML Papers

This file provides worked examples, hook styles, contribution bullet formats, and common pitfalls
for writing strong introductions and abstracts for security/ML papers at venues like ACL, IEEE S&P,
CCS, USENIX Security, EMNLP, and NAACL.

---

## Abstract Templates

### ACL Abstract Template (200-word limit)

The ACL abstract should pack four elements into ~200 words:

```
[Context — 1 sentence]
  What domain and why it matters.

[Problem — 1 sentence]
  The specific gap or challenge this paper addresses.

[Approach — 1–2 sentences]
  What this paper does: the system/benchmark/method.

[Result — 1 sentence]
  The headline number or takeaway.
```

**Worked Example (AutoPatch)**:

> Memory safety vulnerabilities in C/C++ software cause the majority of critical CVEs, yet manual patch development remains slow and expensive.
> We introduce AutoPatch, a benchmark and evaluation framework for automated LLM-based vulnerability repair using real crash reproducers from OSS-Fuzz.
> AutoPatch takes a sanitizer crash report and the vulnerable source function as input and uses an LLM in a multi-turn repair loop, verifying each candidate patch across four tiers: crash fix, developer test suite, code coverage, and differential testing.
> We evaluate [MODEL] on [N] ARVO cases and find that [MODEL] fixes [X]% of crashes (Tier 1), with [Y]% passing the full verification pipeline.
> Our results reveal that crash-fix rates overestimate patch quality by [Z] percentage points relative to test-suite verification, highlighting the importance of multi-tier evaluation.

**Word count target**: 150–190 words. Never go over 200.

**Common abstract mistakes**:
- Opening with "In this paper, we..." — weak opener, wastes words.
- Spending 3+ sentences on background before stating the problem.
- Burying the result in a vague phrase like "shows promising results" instead of a number.
- Describing methods in too much detail (that's what the paper is for).
- Using undefined acronyms without expansion in the abstract.

---

## Introduction Arc

The standard 5-part introduction arc for a systems/benchmark paper:

### Part 1 — Hook (1–2 paragraphs)

**Goal**: Make the reader care within the first 3 sentences.

**Three hook styles**:

#### Style A: Statistic Hook
Open with a striking number that quantifies the problem.

> "Memory safety bugs account for approximately 70% of all critical CVEs in C/C++ projects (Microsoft Security Response Center, 2019). OSS-Fuzz alone has discovered over 10,000 such vulnerabilities in open-source software since 2017 — yet the median time from bug discovery to patch landing in production exceeds 60 days."

Use this when: your problem has well-established severity statistics. Cite the statistic (don't claim without a citation).

#### Style B: Problem Hook
Open by describing what a practitioner has to do today, which is hard and slow.

> "When a fuzzer discovers a heap-buffer-overflow in a widely-deployed C library, a security engineer must read the sanitizer crash report, trace the root cause through the stack frames, understand the memory layout at fault, and write a correct patch — all before the vulnerability is disclosed and exploited. This process is skilled, time-consuming, and does not scale to the volume of crashes that continuous fuzzing produces."

Use this when: the pain of the manual process is vivid and relatable.

#### Style C: Contrast Hook
Open by establishing what AI can do, then reveal what the gap is.

> "Large language models have demonstrated remarkable ability to generate correct code on benchmarks ranging from competitive programming problems to real-world GitHub issues (Chen et al., 2021; Jimenez et al., 2023). Yet applying LLMs to security vulnerabilities — where correctness is safety-critical and evaluation requires sanitizer-instrumented execution environments — remains largely unexplored."

Use this when: your paper is positioned relative to recent LLM progress and the gap is about domain transfer.

**Recommended for AutoPatch**: Style A or B. Style C works if the venue is NLP-focused (e.g., ACL) where reviewers may be less familiar with the security domain.

---

### Part 2 — Problem Statement (1 paragraph)

Be specific. What exactly does this paper tackle? Do NOT restate the hook.

Pattern:
> "Specifically, we address the problem of [precise problem definition], given [inputs], producing [outputs], with the goal of [success criterion]."

**For AutoPatch**:
> "Specifically, we study LLM-based automated vulnerability repair: given a sanitizer crash report (crash type, stack trace) and the source code of the crashing function extracted from an OSS-Fuzz Docker image, can an LLM generate a patch that (1) eliminates the crash and (2) does not break the existing developer test suite?"

---

### Part 3 — Gap Statement (1 paragraph)

Describe what prior work does NOT address. This justifies why this paper is needed.

**Gap types**:
- **Dataset gap**: prior work uses synthetic/small/unrealistic data.
- **Evaluation gap**: prior work only measures one metric (e.g., crash fix) and misses regressions.
- **Scope gap**: prior work addresses a different task (e.g., code generation) not vulnerability repair.
- **Infrastructure gap**: no prior benchmark for this problem setting.

**For AutoPatch**, the key gaps are:
1. Prior LLM-based APR benchmarks (SWE-bench, HumanEval) use non-security tasks; no benchmark for sanitizer-triggered memory safety bugs.
2. Prior security benchmarks (CyberSecEval) test attack generation, not repair.
3. Existing APR evaluations use crash-fix as the sole metric; multi-tier evaluation (including developer test regression detection) is new.

Pattern:
> "While prior work has [what they did], none has [specific gap 1]. Furthermore, [gap 2]. Our work addresses both gaps by [brief foreshadow of approach]."

---

### Part 4 — Approach Overview (1 paragraph)

2–3 sentences on the method. Do NOT go into subsection-level detail — that's the methodology section.

Pattern:
> "[System name] is a [what it is] that [core mechanism] to [goal]. [One sentence on the key technical insight]. [One sentence on how it is evaluated]."

**For AutoPatch**:
> "AutoPatch is a benchmark and evaluation framework that combines an LLM-based patch generation loop with a four-tier verification pipeline to evaluate patch quality beyond simple crash suppression. The key insight is that crash-fix verification (Tier 1) systematically overestimates patch quality relative to developer test suite verification (Tier 2), motivating richer evaluation. We evaluate AutoPatch on [N] real-world OSS-Fuzz vulnerabilities from the ARVO dataset across [M] LLMs."

---

### Part 5 — Contributions (3–4 bullet points)

Each bullet starts with an action verb. Be specific — include numbers if available. Make sure every claimed contribution is backed by content in the paper.

**Template**:
```
\begin{itemize}[noitemsep]
  \item \textbf{We present [X]}, [what it is and what it enables]. [number if applicable]
  \item \textbf{We introduce [Y]}, [novel contribution]. [what makes it novel]
  \item \textbf{We demonstrate [Z]}, [empirical finding with number].
  \item \textbf{We release [W]}, [artifact and its value to the community].
\end{itemize}
```

**For AutoPatch**:
```
\begin{itemize}[noitemsep]
  \item \textbf{We present AutoPatch}, a benchmark for LLM-based automated vulnerability repair
    on real OSS-Fuzz crashes, covering [N] ARVO cases across [M] open-source C/C++ projects.
  \item \textbf{We introduce a four-tier verification pipeline} that evaluates patch correctness
    beyond crash suppression, including developer test suite regression detection, code coverage
    measurement, and LLDB-based differential testing.
  \item \textbf{We demonstrate that crash-fix rates overestimate patch quality}: [X]% of patches
    pass Tier 1 (crash fixed) but only [Y]% pass Tier 2 (no test regressions), a gap of
    [X-Y] percentage points with [MODEL].
  \item \textbf{We release the AutoPatch benchmark infrastructure} including the ARVO Docker
    evaluation harness, per-project Codex-generated test scripts, and a replication package
    at [URL --- omit in review mode].
\end{itemize}
```

**Contribution bullet common mistakes**:
- "We explore..." — too vague. Replace with "We present...", "We demonstrate...", "We show..."
- Claiming a contribution not backed by the paper body (e.g., claiming multilingual support when you only tested English/C).
- Using lab-identifying language in review mode ("our lab's benchmark").
- Contributions that are really just descriptions of steps taken, not actual claims.

---

### Part 6 — Roadmap (1 sentence)

Required at ACL for longer papers. Mechanical but important.

> "The remainder of this paper is organized as follows: Section~\ref{sec:background} introduces background on fuzzing, sanitizers, and the ARVO dataset; Section~\ref{sec:methodology} describes the AutoPatch system design; Section~\ref{sec:experiments} presents experimental results; Section~\ref{sec:related} surveys related work; and Section~\ref{sec:conclusion} concludes."

---

## Common Introduction Pitfalls

| Pitfall | Example | Fix |
|---|---|---|
| Burying the lede | Background dominates first 2 paragraphs; problem stated on page 2 | Move the gap statement to paragraph 2; keep hook tight (≤2 paragraphs) |
| Over-claiming | "We solve vulnerability repair" | Scope the claim: "We address function-level memory safety vulnerabilities in C/C++ from OSS-Fuzz" |
| Weak hook | "Security is important. Memory safety is also important." | Replace with a statistic or concrete problem framing |
| No gap statement | Contributions appear without justifying why prior work is insufficient | Add a dedicated paragraph on what prior work lacks |
| Vague contributions | "We improve performance" | "We improve crash-fix rate by X% over [baseline]" |
| Missing roadmap | Paper ends introduction at contributions | Add one roadmap sentence |
| Review-mode violation | "Our prior work [OurSystem, 2023]..." | "Prior work [AuthorName, 2023]..." |
| Undefined acronyms | "ASAN detects UAF bugs" | "AddressSanitizer (ASAN) detects use-after-free (UAF) bugs" — define all acronyms on first use |

---

## Reviewer Pitch Format

A reviewer pitch (for internal use, NOT submitted) is a 3-bullet summary of the strongest claims:

```
REVIEWER PITCH (internal — not submitted):
1. [Strongest empirical claim with number]
2. [Key novelty claim — what has not been done before]
3. [Artifact/community value claim]
```

Example for AutoPatch:
```
REVIEWER PITCH:
1. First benchmark for LLM vulnerability repair on real OSS-Fuzz crashes with
   multi-tier verification; [N] cases, [M] models.
2. Four-tier pipeline reveals crash-fix rates overestimate quality by [X] pp —
   a measurement artifact not previously quantified.
3. Full replication package released: ARVO harness + per-project test scripts.
```

---

## Intro Length and Pacing

For an 8-page ACL paper, target **~0.7 pages** for the introduction (~350–450 words).

Pacing:
- Hook: 2–3 sentences
- Problem: 2–3 sentences
- Gap: 3–4 sentences
- Approach: 2–3 sentences
- Contributions: 4 bullet points (2–3 lines each)
- Roadmap: 1 sentence

If the introduction is running long (> 0.8 pages), cut from the hook and gap — reviewers in the area already know the problem is important.
