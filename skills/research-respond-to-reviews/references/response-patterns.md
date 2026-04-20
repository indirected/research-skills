# Response Patterns

The taxonomy of moves available in a rebuttal, with examples and guidance for when to use each. Pick the strategy that fits the comment; don't reflexively defend everything or concede everything.

## Pattern 1 — Concede

When the critique lands and the reviewer is right, conceding is the strongest move. A graceful concession buys credibility for the rest of the rebuttal.

### When to use
- The critique identifies a real flaw (unfair comparison, overclaimed result, missing baseline).
- The flaw is fixable in revision.
- Defending would require contortion the AC will see through.

### Pattern
1. Acknowledge the specific point clearly.
2. State what you've done about it (or will do).
3. Frame the revised contribution honestly.

### Example

> **R2 raised concerns that our efficiency comparison does not match parameter counts across methods.**
>
> The reviewer is correct. In the original submission, we compared our 3B-parameter method against the published numbers for X (7B parameters), which is not a matched comparison. We have re-run X at 3B parameters using the publicly released training recipe. At matched parameters, X achieves 64.2 ± 0.7 (vs. our 67.1 ± 0.8); the gap is 2.9 points rather than the 6.4 points reported in our Table 2. The relative ordering is unchanged but the magnitude is smaller. We will update Table 2, Figure 3 (Pareto frontier), and the abstract to reflect the matched-parameter comparison.

### Anti-pattern
"We acknowledge the reviewer's concern and will address it in the camera-ready" — vague concession that doesn't commit. The AC reads this as deflection.

---

## Pattern 2 — Defend with new evidence

When you disagree with the critique and have (or can run) experiments to refute it.

### When to use
- The critique is empirical ("you didn't show this works under condition X").
- You can run an experiment in the rebuttal window that addresses it.
- The new experiment is small enough that you can present the headline result inline.

### Pattern
1. State the disagreement (graciously).
2. Present the new evidence with concrete numbers.
3. Reference where the new material will appear in the revision.

### Example

> **R1 questioned whether our method generalizes beyond English.**
>
> We agree this is an important concern. We have evaluated our method on the multilingual subset of XNLI (15 languages); results are below.
>
> | Language | Baseline | Ours |
> |---|---|---|
> | English | 78.2 | 81.4 |
> | Average non-English | 71.5 | 74.8 |
> | Worst (Swahili) | 64.1 | 66.9 |
>
> The improvement holds across languages, with an average gap of +3.3 points on non-English vs. +3.2 on English. We will add this evaluation as §5.4 in the revision.

### Anti-pattern
Promising new experiments without running them. "We will run multilingual experiments in the camera-ready and expect similar results" reads as deflection. Run them in the rebuttal window or defer the claim.

---

## Pattern 3 — Defend with existing evidence

When the reviewer missed a result that's already in the paper.

### When to use
- The reviewer's concern is addressed in the submission, but they didn't notice.
- The relevant material exists; the issue is that it was not obvious enough.

### Pattern
1. Acknowledge the concern.
2. Point to the specific section / table / passage that addresses it (with quote if helpful).
3. Acknowledge that the paper's clarity is part of the problem; commit to a revision that surfaces this material more visibly.

### Example

> **R3 noted that the paper does not analyze the effect of context length on performance.**
>
> We may not have made this analysis prominent enough. Figure 5 (page 7) presents performance vs. context length across 4 settings, with results showing graceful degradation past 32k tokens. We will move this analysis earlier in the experiments section (currently §5.3, will become §5.1) and reference it explicitly in the introduction.

### Anti-pattern
"As we already showed in Figure 5, the reviewer's concern is addressed." This is correct but reads as a rebuke. The reviewer missed it; the paper failed to make it visible. Take the writing-clarity hit as part of the response.

---

## Pattern 4 — Clarify a misunderstanding

When the reviewer misread what the paper says.

### When to use
- The reviewer's critique would be valid if their interpretation were correct, but the paper actually says / does something different.
- This is one of the highest-leverage response types: clarifying a misunderstanding can flip a "weak reject" to "weak accept" because the underlying objection dissolves.

### Pattern
1. State what the reviewer understood (so the AC can verify).
2. State what the paper actually does.
3. Quote or cite the relevant passage.
4. Commit to clarifying the writing in the revision.

### Example

> **R2 understood our method to require a separate training run per task, raising scalability concerns.**
>
> Our method does not require per-task training. The base model is trained once; per-task adaptation happens at inference time via the prompting protocol described in §3.4. The "training" mentioned in §3.2 refers to the one-time base-model training. We will rewrite §3.4's opening sentences to make this distinction explicit, and add a sentence in the abstract clarifying the inference-time-only adaptation.

### Anti-pattern
"The reviewer misunderstood the paper" — accusatory. Use "we may not have been clear" instead. The phrasing matters.

---

## Pattern 5 — Politely decline

When the reviewer requests something that would constitute a separate paper, or that you genuinely can't do.

### When to use
- The request is for a major extension that's outside the paper's scope.
- The request is for something cost-prohibitive (re-running the entire experiment suite on a new model family, etc.).
- The request is for something that doesn't make sense given the paper's framing.

### Pattern
1. Acknowledge the request as valuable.
2. Explain why it's outside this paper's scope.
3. Commit to discussing the open question in the revision (often a sentence or two in limitations / future work).

### Example

> **R3 suggested we extend the method to image generation tasks.**
>
> We agree this would be a valuable direction. Extending to image generation involves several non-trivial design choices (handling spatial structure, image-specific conditioning, large-scale image evaluation) that we believe constitute a separate study rather than an extension of the present paper. We will add a paragraph in §6 (Limitations and Future Work) discussing the open question of cross-modal extension and pointing to specific challenges.

### Anti-pattern
"This is beyond the scope of the paper" — terse and dismissive. Always pair with acknowledgment of value and a commitment to discuss the question briefly.

---

## Pattern 6 — Commit to a revision

When the comment is about clarity, structure, or completeness, and the fix is in the writing rather than the experiments.

### When to use
- "Section X is hard to follow."
- "The notation in §3 is inconsistent."
- "The related work could be more thorough on topic Y."
- "Figure 4 is unclear."

### Pattern
1. Acknowledge the issue.
2. State the specific change you'll make.
3. Note where it will appear in the revision.

### Example

> **R1 noted that §4 (Method) is hard to follow due to dense notation.**
>
> We agree §4 introduces too much notation too quickly. In the revision, we will: (a) add a notation table at the start of §4; (b) split the current §4.2 into two subsections separating the encoder and decoder formulations; (c) move the formal complexity analysis to Appendix C, leaving an intuitive summary in the main text. These changes are scoped to fit the existing page budget.

### Anti-pattern
"We will improve the writing" — vague. Specify the changes.

---

## Choosing among patterns

Decision rules:

- **Reviewer is right + flaw is fixable → Concede + state revision.**
- **Reviewer is right + flaw requires new experiments → Run experiments + Defend with new evidence.**
- **Reviewer missed something in the paper → Defend with existing evidence + commit to making it more visible.**
- **Reviewer misread the paper → Clarify + commit to clarifying writing.**
- **Reviewer asks for too much → Politely decline + brief discussion in revision.**
- **Reviewer asks for clarity / polish → Commit to revision.**
- **Reviewer asks something you can't fully resolve → Honest partial response. "We address aspects A and B; aspect C is beyond what we can do in this rebuttal but we discuss it in [section]."**

## Honest partial responses

Some critiques can't be fully resolved in the rebuttal window. Be honest:

> **R2 questioned whether our results extend to non-Latin scripts.**
>
> We have run a partial evaluation on Arabic and Korean (Table A1, attached); both show consistent improvement (+2.1 and +2.4 points respectively). Full multilingual evaluation including 15+ languages and CJK scripts is in progress; we will include partial results in the revision and the full evaluation in a follow-up. The headline claim of the paper (improvement on English) is unaffected; the broader generalization claim will be appropriately qualified in the revision.

This is more credible than either over-promising ("results will hold") or under-responding ("this is future work").

## Cross-references

- For the overall rebuttal structure, see `SKILL.md` (Step 6).
- For the revision change list that emerges from concessions and commitments, see `assets/rebuttal-template.md`.
- For new experiments needed to support a response, hand off to `research-design-experiments` (then run, then write up).
