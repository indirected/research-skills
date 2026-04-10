# Idea Generation Heuristics for Research

Structured creativity techniques for generating novel research directions.
Calibrated to the AutoPatch domain (LLM-based vulnerability repair) but applicable broadly
to security + ML / NLP research.

---

## The Five Core Heuristics

### 1. Axis Extension

**Pattern:** Take an existing method or finding that works on axis X and extend it to a new axis Y.

**Template:** "[Existing approach] works for [X]. Does it work for [Y]?"

**Examples in the AutoPatch domain:**

- AutoPatch repairs C/C++ vulnerabilities. Does it generalize to **Rust**, **Go**, or **Python**?
  The hypothesis: LLM-based repair is more/less effective in memory-safe languages because
  the class of bugs is different (logic errors vs. memory corruption).

- AutoPatch is evaluated on **OSS-Fuzz bugs**. Does it generalize to **CVEs from the NVD**
  (manually discovered bugs) or **static analysis findings** (potential bugs, not confirmed crashes)?

- AutoPatch patches **one function at a time**. Does multi-function (cross-file) vulnerability
  repair require different prompting? The axis extended: patch scope (function → module → repo).

- AutoPatch is evaluated on **correctness** (does it compile + fix the crash). Extension to
  **security completeness** (does the patch prevent all exploit vectors, not just the PoC?).

**When to apply:** When a paper's core result is strong but the evaluation is narrow.
The extension to Y is novel if no paper has tested Y with the same method.

---

### 2. Combination

**Pattern:** Apply technique A (from domain/paper X) to problem B (from domain/paper Y).
Neither A nor B is new, but their combination is.

**Template:** "[Technique from field X] + [problem from field Y] = [new approach]"

**Examples in the AutoPatch domain:**

- **Program synthesis + LLM repair**: Use symbolic execution (e.g., KLEE) to generate
  constraints on the correct patch, then use the LLM to synthesize patch candidates that
  satisfy those constraints. Neither symbolic execution nor LLM patching is new; their
  tight integration in a feedback loop is.

- **Automated test generation + LLM repair**: Use a fuzzer (e.g., AFL++) to generate a
  regression test suite, then use this suite to evaluate LLM-generated patches. AutoPatch
  does differential testing, but dynamically generating the test suite (not relying on
  existing tests) is different.

- **Code summarization + vulnerability repair**: Use LLM code summarization to produce
  a natural-language explanation of the buggy function, then use that explanation as part
  of the repair prompt. Tests whether "explain then fix" outperforms "fix directly."

- **Retrieval-augmented generation + patch generation**: Use a vector database of prior
  CVE patches as a retrieval corpus. For each new bug, retrieve the most similar historical
  patches and provide them as in-context examples. Extension of RAG to the vulnerability
  repair domain.

**When to apply:** When you read a paper from an adjacent field (e.g., code generation,
formal methods, test generation) and think "that technique would help with our problem."

---

### 3. Inversion

**Pattern:** Take an assumption that everyone accepts and ask "what if the opposite is true?"
Or take a system and ask "what if we use it backwards?"

**Template:** "What if [accepted assumption] is wrong?" or "What if we use [system] to do [opposite]?"

**Examples in the AutoPatch domain:**

- **Assumption:** LLMs generate correct patches. **Inversion:** LLMs generate *intentionally
  incorrect* patches (patch obfuscation). What if we study the space of patches that pass
  syntactic checks and crash-silencing but introduce new vulnerabilities? This generates
  a dataset of "evil patches" useful for training patch verifiers.

- **Assumption:** We evaluate patches by whether they fix the crash. **Inversion:** Evaluate
  patches by whether they *minimize* the code change (minimal patch hypothesis). Smaller patches
  are more likely to be correct and to preserve behavior. Does restricting the LLM to minimal
  diffs improve correctness?

- **Assumption:** The fuzzer provides the ground truth (crash = bad, no-crash = fixed).
  **Inversion:** What if the fuzzer is wrong? Study cases where the LLM patch "fixes" the
  crash but the patch is semantically incorrect (passes Tier 1 but fails Tier 2). Can we
  detect these false fixes without running differential tests?

- **Assumption:** More information in the prompt (stack traces, function context) helps.
  **Inversion:** Does *less* information (strip context, only show the function signature and crash
  type) produce better patches through forced generalization? Counterintuitive ablation study.

**When to apply:** When a field has a strong consensus about what "always" works. Inversions
often make great short papers because the result is surprising regardless of direction.

---

### 4. Analogical Transfer

**Pattern:** Find a solved problem in field X that is structurally similar to an unsolved
problem in field Y. Transfer the solution.

**Template:** "In field X, [problem] is solved by [approach]. Our problem Y has the same
structure because [structural analogy]. Therefore, try [adapted approach]."

**Examples in the AutoPatch domain:**

- **From medicine:** Drug interaction checking (multiple drugs, complex interactions) is
  structurally similar to patch interaction checking (multiple concurrent patches in a
  large codebase). Medical AI uses graph neural networks on drug-protein interaction graphs.
  Transfer: build a patch interaction graph and use GNNs to predict which patch sequences
  are safe to apply together.

- **From compiler optimization:** Compiler autovectorization selects which code patterns
  to transform based on profitability heuristics. Transfer: build a "repair profitability"
  heuristic that predicts, before running the LLM, whether this type of bug is likely to
  be successfully repaired. Skip unpromising bugs and spend compute on tractable ones.

- **From machine translation:** MT uses confidence estimation to flag low-confidence
  translations for human review. Transfer: use LLM confidence (e.g., token-level logprobs,
  or a separate verifier model) to flag low-confidence patches for human review, enabling
  a human-in-the-loop repair workflow with better resource allocation.

- **From theorem proving:** Interactive theorem provers use search (e.g., Monte Carlo Tree
  Search) over proof steps. Transfer: use MCTS over patch attempts — each node in the tree
  is a patch variant, and the evaluation (crash-silencing + regression) is the reward signal.

**When to apply:** When reading papers from adjacent fields (compilers, biology, theorem
proving, recommendation systems) and noticing a structural similarity to your problem.
Keep a running "analogies" list as you do literature reviews.

---

### 5. Surprising Finding Exploitation

**Pattern:** When an experimental result is unexpected (much better or worse than predicted),
dig into *why* — the "why" often becomes a new paper.

**Template:** "Result X was unexpected because we predicted Y. The cause of X is Z.
Paper idea: study Z systematically."

**Examples in the AutoPatch domain:**

- **If one LLM model dramatically outperforms others**: Don't just report it. Ask: *why*?
  Is it the training data? The context length? The instruction-following quality?
  Design experiments that isolate the factor (same prompt, different models; same model,
  different prompt structures; same model, different context lengths).

- **If shorter functions are repaired much more accurately than longer ones**: This is
  expected, but the *shape* of the degradation curve is a finding. Is it linear? Exponential?
  Does it have a cliff at a specific token length? The paper: "Context length as a predictor
  of LLM repair success: a study of [N] vulnerabilities."

- **If a specific class of bugs (e.g., integer overflow vs. heap overflow) is dramatically
  easier or harder to repair**: Why? Is it the complexity of the fix? The amount of context
  needed? The training data distribution? Paper: a vulnerability-class taxonomy of LLM
  repairability with mechanistic explanations.

- **If the fix-example prompt significantly outperforms the no-example prompt**: How many
  examples are needed? What makes a good example? Is similarity to the target bug the key
  factor? Paper: "Few-shot example selection for LLM vulnerability repair."

- **If retry mechanism (repeated attempts) helps for certain bug classes but not others**:
  Paper: a meta-analysis of when self-correction and retry mechanisms help in code generation.

**When to apply:** Always. After every set of experimental results, write a list of "what
surprised me" and generate one hypothesis per surprise.

---

## AutoPatch-Specific Idea Space

The following axes define the full space of variations on the AutoPatch research program.
Ideas are formed by varying along one or more axes:

### Axis 1: Vulnerability Class
- Currently: OSS-Fuzz memory bugs (heap overflow, use-after-free, null deref, integer overflow)
- Extensions: SQL injection, XSS, race conditions, logic errors, cryptographic misuse,
  configuration errors, dependency vulnerabilities (SCA)

### Axis 2: Programming Language
- Currently: C/C++
- Extensions: Python, JavaScript/TypeScript, Java, Go, Rust, PHP

### Axis 3: LLM Model
- Currently: Claude, GPT-4, Gemini (see paper for exact models)
- Extensions: Code-specialized models (CodeLlama, StarCoder, DeepSeek-Coder), open-source
  models, fine-tuned models, ensemble methods

### Axis 4: Repair Granularity
- Currently: Single function
- Extensions: Single line (surgical), multi-function, multi-file, full repository context

### Axis 5: Verification Method
- Currently: Fuzzer (PoC) + differential testing (regression)
- Extensions: Formal verification (SMT solver), static analysis, human expert validation,
  LLM-as-judge verification, property-based testing

### Axis 6: Prompt Strategy
- Currently: Fix examples + context + crash report
- Extensions: Chain-of-thought, self-consistency sampling, multi-agent debate,
  retrieval-augmented (similar past patches), structured output (JSON patch format)

### Axis 7: Input Information
- Currently: Crash stack trace + vulnerable function source
- Extensions: Full call graph, binary only (no source), static analysis report,
  CWE classification, CVE description

### Axis 8: Evaluation Metric
- Currently: Crash silencing rate + differential testing pass rate
- Extensions: Patch minimality, security completeness, developer acceptance rate,
  code quality metrics (SonarQube), performance impact of patch

### Axis 9: Human-in-the-loop
- Currently: Fully automated
- Extensions: Human review step at varying confidence thresholds, interactive repair
  (LLM suggests, human selects among candidates), expert-guided prompt refinement

---

## Generating Ideas: The Matrix Method

To systematically generate ideas, pick 2 axes from the table above and vary them jointly:

Example: Axis 3 (LLM Model) × Axis 5 (Verification Method)
→ "Does the optimal LLM model change depending on the verification method?
   Is Claude better at satisfying fuzzer oracle but GPT-4 better at satisfying SMT constraints?"

Example: Axis 4 (Repair Granularity) × Axis 8 (Evaluation Metric)
→ "As repair granularity increases (function → file → repo), how does patch minimality change?
   Are larger-scope repairs more minimal or less minimal?"

Example: Axis 1 (Vulnerability Class) × Axis 6 (Prompt Strategy)
→ "Different vulnerability classes may require different prompting strategies.
   Does chain-of-thought improve heap overflow repair more than integer overflow repair?"

---

## Quality Filters

Before presenting an idea to the user, check:

1. **Not already done**: Search literature/papers.csv for the exact combination. If a paper
   within 2 years addresses the same axis-combination, drop the idea or add a "novel angle."

2. **Falsifiable**: The hypothesis must have a clear prediction that experiments can confirm
   or deny. "LLMs are useful for security" is not falsifiable at the granularity needed
   for a research paper. "LLM repair rate on Python bugs is within 10% of C++ repair rate"
   is falsifiable.

3. **Producible as a paper**: The experiment must produce enough results to fill an 8-page
   paper. Rule of thumb: at least 3 research questions, at least 2 tables or figures with
   quantitative results, at least 1 surprising finding.

4. **Lab has competitive advantage**: The lab should have either (a) unique data,
   (b) unique methodology, or (c) unique experimental infrastructure that gives an edge
   over competing groups. Ideas that any group could execute with a weekend of OpenAI API
   calls are less defensible.
