---
name: reviewer-response-drafter
description: |
  Trigger phrases: "respond to reviewers", "draft rebuttal", "write reviewer response",
  "respond to review comments", "handle reviewer concerns", "write rebuttal for [venue]",
  "rebuttal period", "address reviewer concerns", "response to reviews", "help me reply to reviewers",
  "review came back", "I got my reviews", "reviewers said", "what should I say to reviewer",
  "reviewer is wrong", "how do I respond to this review", "draft author response",
  "rebuttal draft", "compose rebuttal", "reply to referee", "reviewer feedback response"
version: 1.0.0
tools: Read, Glob, Grep, Bash, Write, Edit
---

# Skill: reviewer-response-drafter

Parse reviewer comments, classify each concern by type, draft professional per-comment
responses with evidence, and produce a prioritized change list. Covers security (CCS,
USENIX, S&P, NDSS) and NLP (ACL, EMNLP, NeurIPS) venues with tone calibrated to each.

---

## Step 0: Load Reviews

Ask the user to provide reviews in one of two ways:

```
To draft your rebuttal, I need the reviewer comments. Please either:

1. **Paste them here** — copy/paste the full review text from the submission system
2. **Provide the file path** — if you've already saved the reviews, tell me where
   (e.g., paper/reviews/ACL_2026_reviews.md)

Also tell me:
- Which venue is this for? (affects tone, word limit, response format)
- Are there any reviews you consider hostile or unfair? I'll flag those for special handling.
- Have you already run any new experiments since the submission? If so, what?
```

If reviews are provided inline, save them first:
```bash
mkdir -p paper/reviews/
# Write the pasted content to:
# paper/reviews/[VENUE]_[YEAR]_reviews.md
```

If reviews are already saved, load them:
```python
Read("paper/reviews/[VENUE]_[YEAR]_reviews.md")
```

---

## Step 1: Parse Reviews into Structured List

Parse the review text into a structured list. Reviews typically have the format:

```
Review #1 / Reviewer A
Summary: ...
Strengths: ...
Weaknesses: ...
Questions: ...
Score: ...
```

For each reviewer, extract individual concerns. Each concern becomes one entry:

```
concern = {
  reviewer_id: "R1",          # "R1", "R2", "R3", "Meta", "AC"
  concern_id: "R1-1",         # reviewer ID + sequential number
  concern_text: "...",        # exact quote from the review
  urgency: "critical|high|medium|low",  # see rules below
  type: "...",                # see Step 2
  action_required: "...",     # what must change in paper or response
}
```

### Urgency Rules
- **critical**: Directly threatens acceptance; addresses core validity, soundness, or ethics
- **high**: Significant weakness likely to lower score; must be addressed in full
- **medium**: Legitimate concern that a good response can resolve
- **low**: Minor nitpick, typo, or question that a one-sentence clarification resolves

### Parsing Tips
- Questions that end with "?" are usually medium urgency unless the reviewer signals they are blocking
- "This is a major weakness" → critical or high
- "It would be nice to see..." → medium or low
- "I strongly disagree..." or "I am not convinced..." → critical
- "Minor: ..." → low
- Score < 3 (out of 5) or below "Weak Accept" → escalate all concerns from this reviewer by one urgency level

---

## Step 2: Classify Each Concern

Assign one primary type to each concern:

| Type | Description | Examples |
|------|-------------|----------|
| `methodological` | Questions about experimental design, baselines, statistical validity, scope | "Why not compare to X?", "Is the dataset representative?", "Threat model is unclear" |
| `presentation` | Clarity, writing quality, structure, missing explanation | "Section 3 is hard to follow", "Figure 2 is not explained in the text" |
| `missing_experiment` | Requests for additional experiments, ablations, or results | "Test on more models", "Include an ablation of component Y" |
| `missing_citation` | Missing related work or unfair credit | "You missed [Paper X]", "This is similar to prior work [Y]" |
| `factual_error` | Incorrect claim, wrong number, misquoted result | "Line 247 says X but the table shows Y" |
| `scope_concern` | Paper claims more than it demonstrates | "The title claims general applicability but experiments are narrow" |
| `reproducibility` | Missing code/data/hyperparameters | "No implementation details", "Cannot reproduce Table 3" |
| `novelty_concern` | Reviewer questions the contribution | "This seems similar to [X]", "Is the delta over baseline significant?" |
| `ethical_concern` | Concerns about dual use, bias, harm | rare but critical to address |

---

## Step 3: Check Existing Experimental Data

Before drafting responses that promise new data, check what already exists:

```python
Glob("experiments/runs/*/stats.json")   # all experiment run statistics
Glob("experiments/runs/*/")            # list all runs
```

For each `missing_experiment` concern, search if the data might already exist by using
keywords from the concern to glob for matching run directories:

```python
# Derive keywords from the concern text and search for matching run directories
Glob("experiments/runs/*[keyword_from_concern]*")
Glob("experiments/runs/*[alternative_keyword]*")
```

If data already exists:
- Mark the concern as resolvable with existing data (EASY WIN)
- Quote specific numbers in the response
- Do NOT promise to run new experiments if existing ones already answer the question

If data does NOT exist:
- Estimate compute time realistically before promising the experiment
- Flag as "OVER-COMMITMENT RISK" if the experiment would take more than 48 hours on available hardware
- Consider whether the experiment can be done on a subset (3-5 cases instead of full dataset)

Load the current results analysis if available:
```python
Glob("experiments/results_analysis_*.md")
Read("experiments/results_analysis_[LATEST].md")
```

---

## Step 4: Read Relevant Paper Sections

For `factual_error` and `presentation` concerns, read the actual paper section before drafting.
Use `project/paper-paths.md` to find the correct main .tex path:

```python
Read("project/paper-paths.md")
Read("{{main_tex from project/paper-paths.md}}")
Glob("{{sections_dir from project/paper-paths.md}}/*.tex")   # read specific sections if they exist
```

For `missing_citation` concerns, check the bibliography:
```python
Read("paper/latex/custom.bib")
```

Then search the literature directory:
```python
Read("literature/papers.csv")
Glob("literature/synthesis/*.md")
```

---

## Step 5: Draft Per-Concern Responses

For each concern, draft a response using this structure:

### Standard Response Template

```
**[R{N}-{M}: {TYPE} — {URGENCY}]**

> "{exact quote from reviewer}"

We thank Reviewer {N} for this important observation. [One sentence acknowledging
the concern without being defensive.]

[Clarification / evidence / correction — 2-5 sentences. Be specific. Cite line numbers,
table rows, equation numbers, or experiment IDs where possible.]

**Paper change**: [Describe exactly what will change — section name, nature of the change,
approximately how many words/lines will be added or modified. If no change: state why the
current text already addresses this and where the relevant text appears.]
```

### Response Templates by Type

**methodological:**
```
We thank Reviewer {N} for raising this question about [aspect of methodology].
[Explain the design choice and its justification.] This choice was motivated by
[reason], which is standard practice in [related work citations].
We will add a paragraph to Section [X] clarifying this design decision and
its implications for generalizability.
```

**presentation:**
```
We agree that [specific aspect] could be explained more clearly.
[Brief explanation of what the text intends to convey.] In the camera-ready
version, we will revise [Section/Figure X] to [specific change: add a sentence,
include a caption clarification, reorder the steps, etc.].
```

**missing_experiment:**
```
[If data exists:]
We appreciate this suggestion. We have in fact already run this experiment and
the results show [METRIC = VALUE]. This [supports / challenges] our main finding
because [explanation]. We will add these results to [Table/Figure X] in the
revised paper.

[If data does NOT exist, small experiment feasible:]
This is a valuable suggestion. We will run [description of experiment] on
[N cases / subset of the dataset] and report results in the revision.
Preliminary analysis suggests [direction of expected result] because [reasoning].

[If data does NOT exist and experiment is large:]
This experiment would strengthen the paper. We note that a full run on the
complete dataset requires [compute resource / time], which may be beyond the
rebuttal window. We commit to [scaled-down version or timeline] and will
include these results in the camera-ready version if accepted.
```

**missing_citation:**
```
We thank Reviewer {N} for pointing us to [paper/author].
[One sentence describing what the cited paper does.]
[One sentence explaining the relationship to our work: "This work is related
in that X, but differs in Y. Our contribution Z builds on / is orthogonal to
this work because..."]
We will add a citation and discussion of this work in Section [Related Work].
```

**factual_error:**
```
We thank Reviewer {N} for catching this. The reviewer is correct that
[restate error clearly]. The correct statement is [corrected claim],
as shown in [Table/Figure/Equation reference]. We will correct line [N]
of the paper to read: "[corrected text]".
```

**novelty_concern:**
```
We appreciate Reviewer {N}'s question about novelty. While [prior work X]
addresses [related problem], our work differs in [specific dimension 1],
[specific dimension 2], and [specific dimension 3].
Specifically, [prior work X] assumes [assumption] and evaluates on [setting],
whereas we [key distinction]. This distinction matters because [impact on results].
We will strengthen the Related Work section (Section [X]) to more clearly
articulate this differentiation.
```

**scope_concern:**
```
Reviewer {N} raises a fair point about the scope of our claims.
We agree that our experiments demonstrate [narrower claim] rather than
[broad claim as written]. We will revise [title / abstract / Section X]
to more precisely reflect the scope: [proposed revised claim].
```

**reproducibility:**
```
We agree that reproducibility is important. [Description of what is already
provided: hyperparameters, random seeds, dataset splits, model checkpoints.]
We will [add implementation details to Section X / release code on GitHub /
include a reproducibility appendix] with all information needed to replicate
our results.
```

---

## Step 6: Handle Hostile or Contradictory Reviews

### Hostile Review Indicators
- Score much lower than other reviewers without proportional criticism
- Criticism that is vague ("the paper is not good") with no specific concern
- Reviewer ignores the response to a prior round of reviews
- Reviewer criticizes something the paper explicitly addresses

### How to Handle Hostile Reviews
1. **Do not argue emotionally.** Use calm, precise, factual language.
2. **Address every specific concern** even if you believe the reviewer misread the paper.
3. For vague criticism ("the paper is poorly written"), ask the reviewer for specifics: "We would welcome more specific guidance on which sections or passages the reviewer found unclear, so we can target our revisions appropriately."
4. If the reviewer contradicts another reviewer, note the disagreement politely: "We note that Reviewers {X} and {Y} have expressed different perspectives on [topic]. We have [resolution] and hope this addresses both concerns."
5. Do not point out that the reviewer is wrong. Instead, provide the correct evidence and let it speak.
6. If the review is factually incorrect about your paper: "We respectfully note that [claim] is addressed in Section [X], lines [N-M], where we state: '[exact quote]'."

### Contradictory Reviews
If Reviewer A says "too much evaluation" and Reviewer B says "not enough evaluation":
- Address both directly without mentioning the contradiction
- Propose a balanced revision that satisfies both where possible
- If impossible, explain your editorial choice and why you prioritize one concern over the other

---

## Step 7: Check for Over-Committed Responses

Before finalizing, scan all drafted responses for these patterns and flag them:

- "We will run experiments on [X]" where X has not been done and requires > 48 hours of compute
- "We will collect [Y] additional data" — is the data actually available?
- "We will add [Z] to the paper" — does Z fit within the page limit?
- Any promise to run a new baseline model (may require days of GPU time)

For each flagged item, print:
```
OVER-COMMITMENT WARNING: Response to [R{N}-{M}] promises [action].
Estimated effort: [N hours / days of compute].
Recommendation: [scale down / hedge with "if time permits" / note in limitations instead]
```

---

## Step 8: Generate Output Files

### File 1: Full Response — `paper/reviews/[VENUE]_[YEAR]_response.md`

```markdown
# Author Response: [VENUE] [YEAR]

Total word count: [N] words
Venue word limit: [L] words (read from project/venue-config.md or rebuttal-guide.md)

---

## Summary of Changes

We thank all reviewers for their thorough feedback. The main changes we will make:
1. [Change 1]
2. [Change 2]
3. [Change 3]

---

## Response to Reviewer 1 (Score: [N/5])

### R1-1: [Brief description of concern]
[Drafted response]

### R1-2: [Brief description of concern]
[Drafted response]

---

## Response to Reviewer 2 (Score: [N/5])
...

---

## Response to Reviewer 3 (Score: [N/5])
...
```

### File 2: Change List — `paper/reviews/[VENUE]_[YEAR]_changes.md`

```markdown
# Paper Change List: [VENUE] [YEAR]

Generated from reviewer concerns. Priority order for camera-ready (if accepted)
or revision (if major revision requested).

---

## MUST-FIX (Critical / High priority)

- [ ] [R1-2] Revise Section 4.1 to clarify the threat model (addresses R1 major concern)
- [ ] [R2-1] Add ablation of component X to Table 3 (data already available)
- [ ] [R3-1] Correct factual error on line 247: change "X" to "Y"

## SHOULD-FIX (Medium priority)

- [ ] [R1-1] Add clarification paragraph to Section 3 re: baseline selection
- [ ] [R2-3] Add citation to [Paper X] in Related Work
- [ ] [R3-2] Improve Figure 2 caption to explain the x-axis

## NICE-TO-HAVE (Low priority, if space allows)

- [ ] [R1-4] Minor: fix typo "experiements" → "experiments" (line 301)
- [ ] [R2-5] Expand discussion of limitations in Section 6

## NEW EXPERIMENTS NEEDED (Track separately)

- [ ] [R2-2] Run evaluation on [additional dataset] — estimated [N hours]
  Status: [ ] not started [ ] in progress [ ] complete
  Data location: experiments/runs/[slug]/
```

---

## Step 9: Word Count Check

After drafting all responses, count words and compare against venue limits:

```bash
wc -w paper/reviews/[VENUE]_[YEAR]_response.md
```

Read the venue word limit from `project/venue-config.md` if it exists.
Fallback: check `references/rebuttal-guide.md` for the target venue's limit.
Common defaults (only use if neither file exists and user didn't specify):
- **ACL / EMNLP**: 500 words hard limit enforced by OpenReview form
- **NeurIPS**: ~500–700 words (check current year's instructions)
- **CCS / USENIX / S&P / NDSS**: No stated word limit, but 2–4 pages is conventional

If over limit (especially ACL/EMNLP), prioritize cuts:
1. Remove "We thank Reviewer X for..." preambles from low-priority concerns
2. Merge short related concerns into one response
3. Use bullet points instead of paragraphs for low-urgency items
4. Move details to "Paper change" line and cut the explanation

---

## Reference Files

- `references/rebuttal-guide.md` — Tone guide, structure, venue-specific advice, common mistakes

---

## Error Handling

- If reviews cannot be parsed (unusual format), ask the user to paste them in a structured format or paste one reviewer at a time
- If experiment data is ambiguous (multiple matching run directories), list them all and ask the user to confirm which is relevant
- If the paper sections cannot be found (no LaTeX source), ask the user to describe the relevant content directly
- If the venue has a strict word limit and the draft significantly exceeds it, warn before writing the file and offer to cut the lowest-priority responses first
