# Top 10 Rejection Reasons

Drawn from Keogh's SIGKDD-09 reviewing tutorial and expanded for the ML/AI/NLP top-venue era. These are the most common reasons reviewers reject papers — both at the level of "this paper is wrong" and "this paper isn't ready". Each entry has: what the failure looks like, the diagnostic question, and the typical fix.

Read this list during the structured review pass. For each entry, ask whether the paper under review is at risk.

---

## 1. The problem doesn't really exist

**The failure:** the paper solves a problem that no one in the field cares about, or that exists only because the authors framed it that way. Reviewers read the introduction and think: "even if this works perfectly, who would use it?"

**Why it happens:** authors backfill a problem statement around a method they wanted to build. The method is interesting; the problem is invented to justify it.

**Diagnostic questions:**
- Is the problem grounded in either (a) a citation showing prior work on it, (b) a concrete application that needs it, or (c) an observed empirical phenomenon?
- Does the paper have any external validation that this problem matters (someone else's paper, a real system that needs it, a benchmark that captures it)?
- If you removed the contribution claim, is the problem still recognizable as a problem?

**Fix patterns:**
- Anchor the problem in external prior work, application need, or observed phenomenon.
- If the problem is genuinely new (which is rare and risky), spend the first two paragraphs making the case for it carefully.
- If the problem is too narrow to defend on its own, broaden the framing to a recognizable parent problem and position your work as a contribution to that parent.

---

## 2. The problem has been solved (or substantially addressed)

**The failure:** the paper claims to solve X, but a 2-year-old paper Y already solved X (or solved a near-superset of it).

**Why it happens:** literature search wasn't deep enough; concurrent work missed; the relevant prior work is in an adjacent subfield using different terminology.

**Diagnostic questions:**
- Search the contribution claim in literature using non-author terminology (other communities may have a different name for the same idea).
- Check the past 6–12 months for concurrent work — has anyone published a similar idea?
- Is the closest prior work cited and explicitly differentiated, or is it missing / hand-waved?

**Fix patterns:**
- If genuinely scooped: refocus on the *delta* between your work and the closest prior work, even if the delta is smaller than originally claimed.
- If partially scooped: cite prior work explicitly, articulate the differentiation in one concrete sentence (`section-related-work.md` differentiation test).
- If the work was concurrent: cite it; briefly compare; both papers can coexist if the contribution is genuine.

---

## 3. Unfair / strawman comparison to prior work

**The failure:** the baselines aren't strong, aren't tuned, are old, or are run with different protocols than the proposed method.

**Why it happens:** running the strongest baselines is expensive; the easy thing is to run weaker ones. Reviewers in the field will know which baselines you should have included.

**Diagnostic questions:**
- Are the cited baselines the *strongest* in the family, or the most-cited / oldest?
- Were baselines run with the same tuning budget as your method? Same prompts? Same compute envelope?
- Is the trivial / non-learned baseline included?
- For closed-model APIs: were baselines run with the same model snapshot / sampling / prompt template?

**Fix patterns:**
- Add the strongest current baseline; if cost is prohibitive, run on a subset and report.
- Equalize tuning budgets; if asymmetric, name the asymmetry.
- Include the trivial baseline — it's cheap and protects against the "you didn't try the obvious thing" critique.
- See `research-design-experiments/SKILL.md` "Choose baselines — the fair way" for the full protocol.

---

## 4. Unjustified parameters or arbitrary choices

**The failure:** the paper has hyperparameters, threshold values, K-values, or design choices that are stated without justification. Reviewers wonder which were cherry-picked and what would happen if they were different.

**Why it happens:** experiments converged on a set of values; authors used those values without checking sensitivity or articulating why.

**Diagnostic questions:**
- Every numeric choice (N=100, K=8, threshold=0.5, learning rate=3e-4, etc.) — is there either (a) a principled justification or (b) a sensitivity analysis showing the result is stable?
- Every architectural choice (single linkage vs Ward, ReLU vs SiLU, layer norm placement, etc.) — same question.
- Every prompt choice (chain-of-thought yes/no, few-shot K, system prompt content) — same question.

**Fix patterns:**
- Add a sensitivity analysis (often a small appendix table) for the load-bearing parameters.
- Justify each choice in one sentence — "we use K=8 because preliminary experiments showed plateau by K=8 (Appendix B)" or "we use the standard PyTorch default for AdamW".
- Where the choice is empirical and you genuinely don't know why it works best, say that and report the sensitivity range.
- Keogh's "elephant fitting" caution applies: many free parameters allow you to fit any result.

---

## 5. The first-page anchor fails

**The failure:** the abstract is generic, the intro hedges, the first figure is unclear or absent. By the bottom of page 1, the reviewer has decided the paper is weak — and Pazzani's data says they don't change their mind 80% of the time.

**Why it happens:** authors spend most of their writing time on method and experiments; the intro and abstract are written last, in a hurry, and don't get the iteration they deserve.

**Diagnostic questions:**
- Read only page 1. Can you state what the paper claims, why it matters, and one piece of evidence?
- Does the abstract have a concrete number or structural claim?
- Does the first paragraph hook the reader, or open with "in recent years..."?
- If there's a page-1 figure, does it convey the contribution or just the problem?

**Fix patterns:**
- Iterate the abstract 5+ times — see `research-write-paper/references/section-abstract.md`.
- Replace generic intro openers with something concrete, surprising, or pointed — see `section-intro.md`.
- Either fix the page-1 figure or remove it; a bad figure on page 1 hurts more than no figure.

---

## 6. Hidden assumptions or constraints that limit applicability

**The failure:** the paper makes claims that are valid only under unstated assumptions. Reviewers (or worse, post-publication readers) discover the assumption later and the claim falls apart.

**Why it happens:** assumptions are obvious to the authors and so they're left implicit. Reviewers don't share the same context.

**Diagnostic questions:**
- What assumptions does the method *actually* require? (Stationary data? Bounded inputs? Specific tokenizer? English only? GPU access?)
- Are these assumptions stated up-front in the problem statement, or only emergent from the experiments?
- What happens if the assumptions are violated? Does the paper say?
- Is the claim narrowly scoped to match the assumptions, or does it overreach?

**Fix patterns:**
- Add a "Scope" or "Assumptions" paragraph in the problem statement section.
- In the experiments, include a robustness check that violates the assumption and shows the failure mode.
- Tighten the claim to match what was actually evaluated. "Our method works on natural images" is overreach if you only tested CIFAR-10; the honest claim is "...on CIFAR-10 and CIFAR-100".

---

## 7. Overclaimed / underqualified results

**The failure:** the paper claims more than the evidence supports. "We solve task X" when the method gets 65% on X. "Our method generalizes" when only in-distribution evaluation was done.

**Why it happens:** authors are excited about their method; the language drifts toward what they hope is true rather than what they showed.

**Diagnostic questions:**
- For each claim in the abstract / intro / contribution list, find the specific evidence.
- Does the claim language match the evidence's strength? "X solves Y" requires near-perfect performance; "X improves on Y" requires a real gap; "X is competitive on Y" requires being within noise of SOTA.
- Are generalization claims supported by out-of-distribution evaluation?
- Are "first to do X" claims defensible against a thorough literature check?

**Fix patterns:**
- Tighten language to match evidence. "We achieve 65% on X, a 5-point improvement over the previous best of 60%."
- Where you want to claim more, run more experiments to support it.
- Acknowledge limitations explicitly — see `research-write-paper/SKILL.md` "Acknowledge weaknesses" principle.

---

## 8. Reproducibility gaps

**The failure:** a reader who wants to reproduce the work cannot, because key information is missing — exact prompts, exact model versions, exact seeds, exact hyperparameter sweeps.

**Why it happens:** authors know their setup so well that they don't notice what's missing from the paper. Or they have it in code but not in the paper.

**Diagnostic questions:**
- Could you reproduce the headline result from the paper alone?
- For closed models: are exact API versions and call timestamps present?
- For training runs: are seeds, hyperparameters, optimizers, schedulers, and compute documented?
- For LLM-based evaluation: are prompts released verbatim?
- Is there a URL for code and data (or a placeholder if blind review)?

**Fix patterns:**
- Add a reproducibility appendix or checklist (see venue-specific reproducibility checklists).
- Include exact API versions / timestamps for closed models.
- Release prompts verbatim; paraphrasing isn't enough.
- Commit to a code release URL even if the link is anonymous for now.

---

## 9. Carelessness signals

**The failure:** typos, broken figures, empty cells in tables, malformed citations, inconsistent notation, missing labels. None of these are research errors, but they signal that the authors didn't take the manuscript seriously.

**Why it happens:** submission deadline pressure. Last-minute changes break things. Co-author handoffs introduce inconsistency.

**Diagnostic questions:**
- Are any figures missing labels, broken, or have unreadable axes?
- Are any cross-references showing as "??" or pointing to wrong sections?
- Are any cells in tables empty or showing default values?
- Is notation consistent across sections (same symbol = same meaning everywhere)?
- Are acronyms defined on first use (DABTAU)?
- Are bib entries clean (no "TO APPEAR" placeholders, no malformed names)?

**Fix patterns:**
- A dedicated polish pass focused only on these signals, ideally by someone who hasn't been deep in the writing.
- Spell-check, link-check, figure-check, cross-reference check.
- Compile against the venue's official template, not a slightly-different copy.

Keogh's framing: "Take pride in the manuscript." Reviewers transfer carelessness in writing to suspicion of carelessness in research.

---

## 10. Adversarial or dismissive tone toward prior work

**The failure:** the related-work or method sections actively criticize prior work as if needing to tear it down to make space for the proposed method. Reviewers (some of whom may be the authors of those works) react badly.

**Why it happens:** authors feel they need to make space for their contribution; the framing comes out adversarial rather than additive.

**Diagnostic questions:**
- Does the related work section read as gracious or dismissive? Read for words like "fail", "limited", "unable", "naive" — used about prior work, these signal adversarial tone.
- Is concurrent work cited and treated fairly, or implicitly hidden?
- Does the introduction's "why-prior-work-fails" paragraph attribute failure to specific, technical causes (good) or vague inadequacy (bad)?

**Fix patterns:**
- Reframe critique as additive: "Smith et al. introduced X for setting Y; we extend this line to Z." beats "Smith et al. cannot handle Z, which we fix."
- Be specific about prior work's actual contributions before stating limitations.
- For genuinely flawed prior work, focus on the technical gap rather than the flaw.
- See `research-write-paper/references/section-related-work.md` "Fairness to prior work" for examples.

---

## ML-era additions

The above 10 are universal across CS publishing. The modern ML era adds specific failure modes (covered fully in `research-design-experiments/references/ml-evaluation-pitfalls.md`):

- **Data contamination** — pretraining overlap with the eval benchmark.
- **LLM-as-judge bias** — judge prefers length / style / its own outputs.
- **Prompt overfitting** — prompt tuned on test set, or asymmetrically tuned for method vs. baselines.
- **Single-seed reporting** — variance hidden, effect within noise.
- **Closed-model reproducibility** — API drift makes results irreproducible months later.
- **Compute / parameter mismatch** — efficiency claims without matched comparisons.
- **Test-set HP selection** — the cleanest form of overfitting; reviewers catch it.

When reviewing modern ML papers, sweep these in addition to the universal 10.

---

## How to use this list during review

1. Read the paper once for understanding.
2. For each of the 10 (and the ML-era additions), ask the diagnostic questions.
3. Mark each as "low risk", "medium risk", or "high risk".
4. For high-risk items, write a specific issue in the review report (cite location, describe problem, suggest fix).
5. Use the severity-calibration rules (`SKILL.md`) to assign critical / major / minor.

A paper rarely fails on just one of these; usually two or three compound. Catching them now, before submission, is the value of self-review.
