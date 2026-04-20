---
name: research-respond-to-reviews
description: |
  Use this skill when the user has received reviews on a paper submission and is
  drafting the rebuttal / author response, or when they need to plan the revision +
  response strategy across multiple reviewers. Triggers on phrases like "respond to
  reviewers", "draft rebuttal", "author response", "reviewer comments", "handle these
  reviews", "rebuttal strategy", "what should I do about reviewer 2". Make sure to use
  this skill whenever the user is processing external reviews — it's a different genre
  from writing the paper or doing self-review. Use review-paper for pre-submission
  self-review (a different task); use this skill only after external reviews have come
  back.
---

# Respond to Reviews

Drafting a rebuttal is a distinct skill from writing the paper. The genre has its own conventions, its own audience (often the area chair more than the original reviewer), its own length budget, and its own failure modes. The goal is **not** to argue every point — it's to make the area chair confident that the paper, as it will be revised, deserves acceptance.

## Why this is a hard skill

Authors get rebuttals wrong in predictable ways:

- **Defensiveness.** The response reads as if the author is angry. Reviewers and ACs notice; it costs the paper.
- **Litigating every point.** The author defends every comment, including misunderstandings the reviewer would have dropped. Word budget evaporates on minor things; the load-bearing critiques get a sentence each.
- **Promises without commitment.** "We will add this in the camera-ready" without a concrete plan. ACs read this as deflection.
- **Tone drift across reviewers.** Different sections of the response have different registers — gracious to R1, terse to R3 — and it shows.
- **Missing the actual concern.** The reviewer's surface comment ("missing baseline X") often masks a deeper concern ("you cherry-picked the comparison"). Responding only to the surface misses the chance to address what's actually in the AC's head.

A good rebuttal is concise, prioritized, evidence-anchored, and respectful — even (especially) when the reviews are unfair.

## The audience: the area chair, not just the reviewer

A common framing mistake: writing the rebuttal as if the reviewer will read it carefully and update their score. They might. They often won't.

The real audience is the **area chair** (or program chair / meta-reviewer) who will read all the reviews, the rebuttal, and decide. They want to see:

- That the authors took the reviews seriously.
- That the most substantive critiques are addressed (or honestly conceded).
- That misunderstandings are clearly clarified.
- That the authors are gracious — a paper with a hostile rebuttal is worse to defend.

Write for the AC. The reviewers may be persuaded as a bonus.

## Step 1 — Triage every comment

Before drafting, classify every comment from every reviewer. Use a small spreadsheet or table. Categories:

1. **Factual misunderstanding.** The reviewer is wrong about what the paper says. Easy to handle: clarify and quote the passage they missed.
2. **Substantive methodological critique.** The reviewer challenges your method, evaluation, or claim. Hardest to handle: requires either an experiment, a careful argument, or a concession.
3. **Reasonable extension request.** The reviewer asks for an additional experiment / analysis / discussion. Tractable if budget allows.
4. **Unreasonable extension request.** The reviewer wants something that's a follow-up paper, not this one. Politely decline with reasoning.
5. **Style / clarity feedback.** "This section is hard to read." Cheap to fix in revision; acknowledge briefly.
6. **Praise.** Thank briefly; doesn't need much.
7. **Question.** The reviewer asks for information not in the paper. Answer concisely.

Mark each as a **severity** (does this affect the AC's decision?) and a **cost** (low / medium / high to address).

The triage prevents you from spending equal time on every comment. The substantive critiques (category 2) and the genuinely-load-bearing extension requests (category 3) get the bulk of your effort.

## Step 2 — Identify the meta-themes

Before drafting per-comment responses, look across all reviews for **meta-themes**: concerns that appear in multiple reviews. These are what the AC sees as the paper's load-bearing weakness. Address them first and most fully.

Common meta-themes:
- "Comparison to prior work is unfair / incomplete"
- "Method seems incremental over X"
- "Experiments don't support the generalization claim"
- "Reproducibility / details missing"
- "Writing is hard to follow"

A meta-theme that appears in 2 of 3 reviews is more important than a singleton concern in 1 review. Lead the rebuttal with the meta-themes.

## Step 3 — Pick a structure

Two common rebuttal structures:

### Option A — By theme (recommended for most cases)

Group responses around 3–5 themes. Each theme aggregates comments across reviewers.

**Pros:** efficient — one careful response addresses multiple comments. Reads as coherent. Easier for AC to follow the substantive concerns.
**Cons:** individual reviewers may feel un-addressed if their specific comment isn't named.

Mitigation: end the response with a per-reviewer pointer ("R1 W2 → §A; R2 Q3 → §B; …") so each reviewer can find their comments quickly.

### Option B — By reviewer

One section per reviewer; respond to their comments in order.

**Pros:** each reviewer feels addressed. Easier to write.
**Cons:** repetitive when multiple reviewers raise the same concern. Substantive issues get diluted across sections.

Use this if reviews diverge so much that thematic grouping doesn't fit.

Most strong rebuttals use Option A.

## Step 4 — Draft per-response strategy

For each comment (or theme), pick a response strategy. See `references/response-patterns.md` for the full taxonomy with examples; the patterns are:

- **Concede.** "The reviewer is right. We will [specific action]." The strongest move when the critique lands. Concession buys credibility for everything else.
- **Defend with new evidence.** "We have run [new experiment / analysis]; the result is [specific number]. This addresses the reviewer's concern about [thing]."
- **Defend with existing evidence.** "We disagree; the experiment in §X.Y already addresses this — [quote the result]. We will clarify this in the revision."
- **Clarify a misunderstanding.** "We may not have been clear: the method does [X], not [Y as the reviewer understood]. The relevant passage is in §A; we will rewrite for clarity."
- **Politely decline.** "We agree this would be valuable; however, it would constitute a separate study and is beyond the scope of this paper. We will add a discussion in §Z noting the open question."
- **Commit to a revision.** "We will [specific change] in the revised version, including [exact addition]." Be concrete — vague commitments don't earn credit.

Match the strategy to the comment. Conceding everything looks weak; defending everything looks rigid.

## Step 5 — Run the experiments (if any)

If your response promises new experimental evidence, run those experiments **before** finalizing the rebuttal. Don't promise numbers you don't have.

Common new experiments in rebuttals:
- A baseline the reviewer asked for.
- A sensitivity / ablation the reviewer doubted.
- An additional dataset / metric.
- A failure-case analysis.

Time pressure is real (rebuttals are typically 1–2 weeks). Prioritize the experiments that address meta-themes; defer or politely decline the rest.

## Step 6 — Draft, with the conventions

### Length budget

Most venues impose a strict word/character/page limit (often 1 page or ~5000 characters). Treat this as binding. If you can't fit everything, prioritize:

1. Meta-themes (the cross-reviewer concerns).
2. Critical substantive critiques.
3. Specific factual misunderstandings (these have high impact for low cost).
4. Specific extension requests addressed with new experiments.
5. Everything else — bundle, abbreviate, or defer to revision.

### Tone

- **Gracious throughout.** Even when a reviewer is wrong / unfair, respond as if they were a colleague making a good-faith critique. The AC reads tone before content.
- **No defensiveness.** Don't say "the reviewer misunderstands"; say "we may not have been clear". This is a small phrasing shift with large effect.
- **No diminishing.** Don't say "the reviewer's concern is minor"; say "this is a fair point; we address it in [revision]".
- **No sarcasm, no exclamation marks, no rhetorical questions.** All read as defensive.

### Structure within a response

For each themed response, a useful pattern:

1. **Acknowledge the concern in the reviewer's terms.** "Reviewers raised concerns about the fairness of our baselines."
2. **State the response in one sentence.** "We have re-run all baselines under our method's tuning budget; the relative ordering is unchanged."
3. **Provide evidence.** New numbers (with table reference), quoted passages from the paper, citations.
4. **Commit to a revision change.** "We will add Table X in §4.3 with the matched-budget comparison."
5. **Move on.** Don't keep arguing once the case is made.

### Reference your tables and your paper

When citing new experiments, present them in a small table inline (rebuttal tables are typically a few rows). Reference your paper's existing sections by number. Anchoring in concrete numbers is more persuasive than prose.

If the venue allows attachments / appendix changes, include the new tables there and reference from the rebuttal.

## Step 7 — Plan the revision

The rebuttal is half the deliverable; the revised paper is the other half. Maintain a **change list** alongside the rebuttal: every promise you make in the rebuttal becomes a TODO for the revision.

Use `assets/rebuttal-template.md` for the rebuttal itself; the template includes a change-list section so promises don't get forgotten.

For each change in the list:
- Where in the paper.
- What changes.
- Whose comment(s) it addresses.
- Approximate effort.

If the change list is too long for the camera-ready window, cut promises. Don't over-commit.

## Anti-patterns

- **The point-by-point defense of every comment.** Word budget exhausted, meta-themes unaddressed.
- **The "we thank the reviewer for the comment" repetition.** Once is enough; repeating it across 12 paragraphs reads as filler.
- **The "as we already showed in §3.2" rebuke.** If the reviewer missed it, the paper's clarity is part of the problem. Acknowledge that.
- **The vague promise.** "We will improve the experimental section." Vague promises don't move the AC.
- **The over-promise.** Committing to 5 new experiments and a major rewrite — the AC reads this as "the paper isn't ready yet". Promise what you can deliver.
- **The hostile defense.** Aggressive language toward a reviewer who was unfair. The AC sees both sides; the hostile one loses.
- **The "we will explain in the camera-ready" deflection.** If you can clarify it in the rebuttal, do so — don't defer.
- **The mismatched tone across reviewers.** Reads as "we like R1 and resent R3". Even tone throughout.

## When the reviews are bad

Sometimes a review is genuinely unfair: the reviewer didn't read the paper, made a basic error, was hostile, or dismissed the work for non-substantive reasons. Handling:

- **Don't say it.** "The reviewer clearly didn't read the paper" is correct but devastating to your case. The AC will judge for themselves.
- **Respond on the substance** as if the comment were thoughtful. Quote the paper sections the reviewer missed.
- **Note clearly when you've already addressed something.** "Section 4 (lines X–Y) addresses this" — not as a rebuke, as a pointer.
- **Save the meta-objection for the AC.** Most venues have a way to flag confidential concerns to the AC about review quality. Use sparingly and professionally.

When the reviewer is hostile, the rebuttal is your chance to look like the adult in the room. Take it.

## When you have to concede

Sometimes the reviewer is right and the critique lands hard — the comparison was unfair, the claim was overreach, the experiment was thin. The temptation is to defend; the right move is often to concede.

How to concede well:

- **Acknowledge the specific point clearly.** "The reviewer is right that our comparison did not include the strongest current baseline X."
- **State what you've done about it (or will do).** "We have re-run our experiments including X; the result is [number]. The relative ordering [is unchanged / has changed in the following ways]."
- **Frame the revised contribution honestly.** "Our contribution remains [revised, narrower claim]; we will update §1 to reflect this."

A graceful concession on a real critique buys more credibility than a clever defense. ACs see this and trust the rest of the paper more.

## Output

Use `assets/rebuttal-template.md` as the structured template. The output is:

1. **The rebuttal text** (within the venue's word/page budget).
2. **A change list** for the revision (separate document, not submitted with the rebuttal).
3. **A new-experiments log** (what you ran during the rebuttal window, numbers, where they appear).

## Cross-references

- `references/response-patterns.md` — the taxonomy of response strategies (concede / defend / clarify / decline / commit) with examples per type.
- `assets/rebuttal-template.md` — the structural template.
- For new experiments needed in response, hand off to `research-design-experiments` for the design, then run.
- For revision writing, hand off to `research-write-paper` (or specific section references therein).
- For deeper understanding of the original critique categories, `research-review-paper/references/top-10-rejection-reasons.md` maps reviewer concerns onto well-known failure modes.

## Important discipline

- **Don't promise what you can't deliver.** Every promise becomes a deliverable for camera-ready or the next round.
- **Don't fabricate.** New numbers must come from new runs; cited prior work must be real.
- **Run the experiments before drafting the response that depends on them.** Avoid "we expect X" — actually have X in hand.
- **Stay within the word budget.** Going over is sometimes allowed but reads as desperate.
- **Read the reviews twice before drafting.** First time: emotional reaction. Second time: actual content. Draft only after the second read.
