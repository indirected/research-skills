# Rebuttal — {Paper Title}

**Submission:** {paper ID}
**Venue:** {venue}
**Word / character budget:** {limit}

---

## Triage table (working notes — do NOT submit)

A spreadsheet-style scratch table. Use this to plan the rebuttal; don't include in the final submission.

| ID | Reviewer | Comment (1-line) | Category | Severity | Cost | Strategy | Theme |
|---|---|---|---|---|---|---|---|
| R1.W1 | R1 | Method comparison missing X | Substantive | High | High | Defend w/ new evidence | Fairness |
| R1.W2 | R1 | Notation in §4 unclear | Style/clarity | Low | Low | Commit to revision | Clarity |
| R2.Q1 | R2 | Generalize beyond English? | Extension request | Medium | Medium | Defend w/ new evidence (partial) | Generalization |
| R3.W1 | R3 | Method "incremental" over Y | Substantive | High | Medium | Defend w/ existing evidence + clarify | Novelty |
| R3.Q1 | R3 | What about image gen? | Unreasonable extension | Low | None | Politely decline | — |
| ... | | | | | | | |

**Categories:** factual misunderstanding / substantive critique / reasonable extension / unreasonable extension / style / praise / question.
**Severities:** does this affect AC's decision? (low / medium / high)
**Costs:** to address (low / medium / high).
**Strategies:** concede / defend new / defend existing / clarify / decline / commit revision (see `references/response-patterns.md`).

---

## Meta-themes (working notes)

Cross-reviewer concerns. These get the most response budget.

1. **{Theme 1, e.g., "Fairness of comparison"}** — raised by R1 (W1), R2 (W2). High severity. Plan: run new matched-budget experiments; concede on the original framing.
2. **{Theme 2}** — raised by R1, R3. Medium severity. Plan: clarify writing; cite existing analysis.
3. **{Theme 3}** — raised by R2, R3. High severity. Plan: partial new evidence + qualified discussion.

---

# Rebuttal (the part you submit)

We thank the reviewers for their detailed and constructive feedback. We address the most substantive concerns first, organized by theme; per-reviewer pointers are at the end.

## {Theme 1 title — e.g., "Fairness of comparison to prior work"}

{Acknowledgment of the concern in reviewers' terms.}

{The response: what you've done, what the new evidence shows, what changes in the revision. Use a small inline table when presenting numbers.}

| Setting | Baseline | Ours |
|---|---|---|
| {row} | {value} | {value} |
| {row} | {value} | {value} |

{Commitment to revision changes — specific.}

## {Theme 2 title}

{Same structure: acknowledge → respond → commit.}

## {Theme 3 title}

{Same structure.}

## Per-comment responses

For comments not covered by the themes above:

**R1.W1, R1.W2** — addressed in {Theme 1}. We additionally clarify in §4 that {…}.

**R1.Q3 (notation)** — Yes, the symbol $\theta$ is reused with two meanings; we will introduce $\theta_{enc}$ and $\theta_{dec}$ in the revision.

**R2.Q1** — Our method is compatible with {…} as described in §3.5; we will add an explicit statement.

**R3.W2 (image generation extension)** — We agree this is a valuable direction. It involves several non-trivial design choices (spatial structure, image-specific conditioning, evaluation) that constitute a separate study. We will add a paragraph in §6 (Limitations and Future Work) discussing the open question.

{... continue for each comment that didn't fit a theme.}

## Per-reviewer pointers

For each reviewer, a quick map of where their comments are addressed.

- **R1:** W1 → Theme 1; W2 → Theme 1; Q1 → §4 (notation rewrite, see above); Q3 → per-comment.
- **R2:** W1 → Theme 2; W2 → Theme 1; Q1 → per-comment.
- **R3:** W1 → Theme 3; W2 → per-comment (politely decline); W3 → §6 (limitations expansion).

## Summary of revisions

We will make the following changes in the revised version:

1. **§1 (Introduction):** add a sentence clarifying inference-time-only adaptation.
2. **§3 (Method):** add a notation table; split §3.2 into encoder / decoder subsections.
3. **§4 (Experiments):** add Table 5 with matched-parameter comparison; rewrite §4.3 caption to surface the analysis.
4. **§5 (Analysis):** add §5.4 with multilingual evaluation (15 languages).
5. **§6 (Limitations):** expand to discuss image-modality extension as future work.
6. **Abstract:** revise "X is faster" claim to "X is faster at matched parameters" to reflect the new comparison.

We thank the reviewers and the area chair for their consideration.

---

# Revision change list (working notes — NOT submitted)

For your own tracking after the rebuttal is submitted. Every promise above becomes a TODO here. Ensure the revision actually delivers each.

| # | Section | Change | Addresses | Effort | Done? |
|---|---|---|---|---|---|
| 1 | §1 | Add sentence on inference-time-only adaptation | R2 misunderstanding | Low | [ ] |
| 2 | §3 | Add notation table | R1.W2 | Low | [ ] |
| 3 | §3.2 | Split into 3.2 encoder / 3.3 decoder | R1.W2 | Medium | [ ] |
| 4 | §4 | Add matched-parameter Table 5 | Theme 1 | Medium | [ ] |
| 5 | §4.3 | Rewrite caption to surface analysis | R3 | Low | [ ] |
| 6 | §5 | New §5.4 multilingual eval | R2.Q1, Theme 3 | Medium (data already collected) | [ ] |
| 7 | §6 | Expand limitations re: image modality | R3.W2 | Low | [ ] |
| 8 | Abstract | Revise efficiency claim | Theme 1 | Low | [ ] |
| 9 | Bib | Add Smith et al. 2024 (concurrent) | R1.Q2 | Low | [ ] |

---

# New-experiments log (working notes — NOT submitted)

What you ran during the rebuttal window, where to find the data, and where the numbers appear in the rebuttal.

| Experiment | Run by | Data location | Used in |
|---|---|---|---|
| Matched-parameter X re-run | {name, date} | `runs/rebuttal/matched_param/` | Theme 1 inline table |
| XNLI multilingual eval | {name, date} | `runs/rebuttal/xnli/` | Theme 3 inline table |
| Arabic + Korean partial | {name, date} | `runs/rebuttal/non_latin/` | Theme 3 (partial response) |

---

# Notes for next time

{Things you learned from the review cycle that should feed back into framing / design / writing for future papers — e.g., "always include matched-parameter comparison upfront", "don't bury the analysis in §5.3".}
