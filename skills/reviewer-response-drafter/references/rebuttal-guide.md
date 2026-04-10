# Academic Rebuttal Best Practices

A practical guide for writing effective author responses in security and NLP venues.
Based on experience with CCS, USENIX Security, IEEE S&P, ACL, EMNLP, and NeurIPS.

---

## Core Principles

### 1. Be a Scientist, Not a Lawyer

Your goal is to clarify, not to win. Reviewers want to be convinced the paper is correct
and important. If you argue too hard, you look defensive. If you provide clean evidence,
the reviewer can update their assessment with dignity.

**Wrong tone:** "The reviewer has fundamentally misunderstood our contribution. We clearly
state on page 3 that..."

**Right tone:** "We may not have explained this clearly enough. To clarify: our approach
differs from [X] in [specific ways]. We will revise Section 3 to make this distinction
explicit at the start of the section."

### 2. Never Promise What You Cannot Deliver

The rebuttal creates obligations that carry through to the camera-ready. If you promise
a new experiment and then don't include it, the Program Chair will notice. Rules:
- If you CAN run the experiment during the rebuttal window (typically 7–14 days), promise it
- If the experiment requires > 2 days of compute and you have only 3 days, hedge: "we will
  include preliminary results from a 5-case subset during the rebuttal period, with full
  results in the camera-ready version"
- Never promise a new dataset collection, a user study, or a new baseline model that requires
  months of work

### 3. Acknowledge What Is Valid

Reviewers are often right, even when they're wrong about the details. Acknowledge valid
concerns even if the fix is small. Saying "this is a fair point" before presenting your
evidence signals confidence, not weakness.

### 4. Be Concrete and Specific

Vague responses are disregarded. Always point to:
- Specific line numbers or section numbers in the paper
- Exact numbers from your results
- Specific sentences you will add or change
- Names of related papers you will cite

### 5. Respond to Every Concern

Even a "minor" concern gets at least one sentence. Leaving a concern unaddressed signals
either that you don't have an answer or that you didn't read the review carefully.

---

## Response Structure

### For a paper with 3 reviewers and a metareviewer:

```
Summary of Main Changes (3-5 bullet points — the most important changes)

Response to Reviewer 1
  [Per-concern responses, most critical first]

Response to Reviewer 2
  [Per-concern responses]

Response to Reviewer 3
  [Per-concern responses]

Response to Metareviewer (if present)
  [Address the meta-review summary and any AC-specific questions]
```

### Single-concern response skeleton:
```
[Acknowledgment, 1 sentence] → [Clarification, 2-3 sentences] → [Evidence, 1-2 sentences] → [Paper change, 1 sentence]
```

Total: 5–7 sentences per concern. Use fewer for low-urgency items.

---

## Tone Guide by Situation

### When the reviewer is factually wrong

Do not say "the reviewer is wrong." Instead:
- "We may not have made this sufficiently clear."
- "To clarify, [correct information], as shown in [reference to exact location in paper]."
- "We will revise [section] to make this point more prominent."

The reviewer saves face, and you still correct the record.

### When the reviewer missed something in the paper

- "This point is addressed in Section [X] (line [N]–[M]), where we [brief summary]."
- "We recognize that this may not have been easy to locate. We will add a forward reference
  from [earlier section] to [the relevant section] to help readers find this discussion."

### When the reviewer wants an experiment that doesn't exist yet

- If you can do it: "We have run this experiment. The result is [N%], which [supports /
  slightly reduces / does not change] our main conclusion. We will add this to Table [X]."
- If you have partial data: "We ran a pilot study of [N] cases. The result is [N%].
  We will complete the full evaluation and include results in the camera-ready version."
- If you cannot do it: "This is a valuable direction. Due to compute constraints during
  the rebuttal window, we are unable to complete a full evaluation. We note that
  [existing evidence that partially addresses the concern], and we will include this
  experiment as future work."

### When the reviewer raises a legitimate limitation

- Concede clearly: "Reviewer [N] is correct that [limitation]. We have added a paragraph
  to the Limitations section that addresses this directly."
- Do not minimize a real limitation with hand-waving. Reviewers value honesty.

### When reviewers contradict each other

- Address each reviewer's concern independently without referencing the contradiction
- If forced to make a choice: "Based on the reviewers' feedback, we have decided to
  [course of action] because [reasoning]. We believe this best balances [concern A]
  and [concern B]."

### When reviewing a hostile review

Signs of hostility: very low score with thin justification, dismissal without engagement,
personal tone, criticism that contradicts the paper's explicit content.

Strategy:
1. Respond with extra care and precision — hostile reviewers look for any slippage
2. Do not mirror the hostile tone
3. Demonstrate that you have read their review carefully by quoting it accurately
4. Provide more evidence than you think you need
5. If the concern is truly unfounded, provide clear counter-evidence and let the AC decide
6. Consider noting (once, briefly) that you would welcome more specific guidance if the
   reviewer's concern is too vague to address: "We would be grateful if the reviewer
   could point to specific passages that need improvement, so we can revise appropriately."

---

## Venue-Specific Notes

### ACL / EMNLP
- **Word limit**: 500 words, enforced by the submission system. This is very tight.
- **Format**: OpenReview comment box. Use Markdown lightly — it renders on OpenReview.
- **Priority**: Address scores < 4 (on a 5-point scale) with at least 3 substantive points.
  Low-scoring reviewers are more likely to be the deciding factor.
- **AC role**: Area Chair reads the reviews and the response. Write for the AC as the
  secondary audience: they have more context but less time than reviewers.
- **Author discussion**: Authors can comment during the review period on OpenReview;
  this is separate from the formal rebuttal. Use discussion comments sparingly to
  clarify critical misunderstandings.
- **Tip**: Lead with a 3-sentence summary of changes — the AC reads this first.

### NeurIPS
- **Format**: OpenReview; responses appear as public comments under each review.
- **Limit**: No official word count but ≤500–700 words per reviewer is conventional.
- **Single-blind**: Reviewers know who you are (since 2022). Maintain professionalism —
  your response is visible to the community (public papers) or to ACs (non-public papers).
- **Discuss period**: NeurIPS has a formal author-reviewer discussion period where you
  can interact with reviewers. Use it; reviewers sometimes update their scores after discussion.
- **Emergency AC**: If a review is clearly outside expertise or inappropriate, you can
  flag it for the AC using the "flag" mechanism on OpenReview.

### CCS / USENIX Security / IEEE S&P
- **No strict word limit**: Typical length is 2–4 pages. Longer is acceptable if well-organized.
- **HotCRP format**: Plain text (no Markdown rendering, though you can use simple formatting
  with asterisks and dashes). Structure with headers like "===Response to Reviewer 1===".
- **Author response period**: Typically 7–14 days. Use the full time — submissions in the
  last 24 hours tend to be better polished.
- **Metareviewer**: CCS and USENIX use a Paper Chair or Meta-reviewer who synthesizes
  reviews. Their summary often reveals which concerns are "load-bearing." Address those first.
- **Major revisions**: USENIX frequently gives "Major Revision" decisions. These papers go
  through a second review round. Commit clearly to what you will do — vague commitments are
  rejected at round 2.
- **NDSS**: Similar to CCS; reviewers sometimes make themselves available for live Q&A in
  the HotCRP forum during the response period. Monitor and respond promptly if they do.

---

## Common Reviewer Concerns in Security / ML Venues

### Security Venues

| Concern | What reviewers actually care about |
|---|---|
| Threat model | Is the attacker model realistic? Does the system defend against the stated threat? |
| Dataset representativeness | Is the evaluation cherry-picked or does it generalize? |
| Ethical disclosure | Did authors follow responsible disclosure for CVEs? |
| Comparison to state-of-art | Is the baseline fair? Did authors tune the baseline as carefully as their method? |
| Artifact availability | Can someone reproduce this? |
| Statistical significance | Is N large enough? Are confidence intervals reported? |

### ML / NLP Venues

| Concern | What reviewers actually care about |
|---|---|
| Ablation completeness | Does each claimed component contribute? |
| Baseline selection | Is the comparison fair? Hyperparameters tuned equally? |
| Significance testing | Is the improvement beyond noise (statistical tests)? |
| Human evaluation | For NLP: is automatic metric correlated with human judgment? |
| Failure analysis | What does the system get wrong and why? |
| Compute requirements | Is this reproducible by researchers without huge GPU clusters? |

---

## What Reviewers Actually Care About (Meta-level)

Reviewers want to accept good papers and reject bad ones, but they have limited time.
A rebuttal that makes their job easier — by organizing the response clearly, providing
exact evidence, and making explicit what will change — is more effective than one that
provides more text but is harder to navigate.

The three things that most change reviewer scores:
1. **Concrete new evidence**: A number you didn't have before, or an experiment result
2. **Correction of a significant misunderstanding**: "We do X, not Y, as shown in line N"
3. **A credible commitment to a specific change**: "We will add paragraph X to Section Y"

The one thing that most annoys reviewers:
- Attacking the review rather than addressing the concern

---

## Rebuttal Checklist

Before submitting:
- [ ] Every concern from every reviewer has a response (even if one sentence)
- [ ] Word count is within venue limits
- [ ] No promises of experiments that cannot realistically be completed
- [ ] No defensive or argumentative language
- [ ] All paper references include section/line numbers
- [ ] New experiment results (if any) are included as numbers, not "we will run this"
- [ ] The most critical concerns (lowest-score reviewers) are addressed first and most thoroughly
- [ ] The response has been read by at least one co-author who is NOT the primary author
- [ ] Tone has been reviewed: calm, professional, evidence-based throughout
