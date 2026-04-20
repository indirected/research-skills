---
name: write-paper
description: |
  Use this skill whenever the user is writing (or rewriting, or improving) prose for
  an academic paper — any section, any length, any draft stage — or when they need
  to design or fix a figure or table. Triggers on phrases like "write the
  introduction", "draft the methodology", "improve this paragraph", "rewrite the
  related work", "make this figure clearer", "fix this table", "tighten the
  abstract", "add a results section", "this paragraph isn't working". Make sure to
  use this whenever the user is actively writing paper content — not for framing
  (use frame-research) and not for reviewing an already-complete draft (use
  review-paper). This skill bundles universal paper-writing principles with
  section-specific guidance loaded only when relevant.
---

# Write Paper

Apply academic-paper writing principles to whatever the user is working on — a section, a paragraph, a figure, a table. Universal principles live in this file; section-specific guidance lives in `references/` and is loaded only when you know which section is in play.

## Why this is a hard skill

Most first drafts fail in predictable ways:
- **The reviewer loses interest on page one** because the opening doesn't anchor — abstract generic, first paragraph hedges, contribution unclear.
- **Every sentence requires thought.** Passive voice, implicit pointers ("this", "it"), undefined acronyms, overloaded terms — each makes the reviewer pause.
- **Weak language underclaims or overclaims.** "We attempt to…", "appears to show…" — if you did it, say you did it; if you didn't, don't imply you did.
- **Figures don't carry their own weight.** Reviewers skim figures first; a figure that needs the text to be understandable is wasted.
- **Related work is a laundry list.** Papers cited in bundles with no real differentiation.
- **The experiments section is a data dump.** Tables and numbers, no narrative about what they show.

Good writing is invisible — the reviewer feels like they understood the paper. Bad writing is visible — they feel like they had to work. Keogh's maxim applies: **if you can save the reviewer one minute by spending an hour, you have an obligation to do so.**

## Universal principles (apply to every section)

### 1. First-page anchor

The abstract, the first paragraph of the intro, and the first figure set the reviewer's expectation for the whole paper. "Reviewers make an initial impression on the first page and don't change 80% of the time" (Pazzani). Spend a disproportionate amount of effort on the first page — it has the highest leverage per hour invested.

By the end of the first page, the reviewer should know:
- What is the problem?
- Why does it matter?
- Why is it hard, and why haven't existing approaches solved it?
- What did this paper do, at a high level?

### 2. Don't make the reviewer think

For every sentence, ask: can a tired reviewer, on their tenth paper of the night, understand this on a single pass? If not, rewrite.

Specific tests:
- **Implicit pointers**: every "this", "it", "these", "they" should have a referent that is unambiguous from the immediately preceding text. If the referent could be two things, rewrite.
- **Acronyms**: define on first use (DABTAU — Define Acronyms Before They Are Used). Don't assume the reviewer knows your subfield's jargon — a reviewer could be a first-year grad student on the margins of your area.
- **Overloaded terms**: words like "complexity", "significant", "optimal", "correlated", "proved" have both informal and technical meanings. When using the technical meaning, make sure context forces that reading.
- **Forward references**: don't require the reader to jump ahead to understand the current sentence.

### 3. Active voice

- "We conducted experiments…" not "Experiments were conducted…".
- "We use Euclidean distance…" not "Euclidean distance is used…".
- Active voice is shorter, takes responsibility, and is less weaselly. (Some genres — theorem statements, formal descriptions — use passive appropriately. Fine. But prose defaults to active.)

### 4. Avoid weak language

Weak: "We attempt to…", "our method aims to…", "this appears to…", "might fail to…".
Strong: "We…", "our method does…", "this is…", "fails to…".

If you did the thing, say you did it. If you didn't, don't imply you did. "Attempt" / "aim" in descriptions of *your own work* suggests you're hedging — either you delivered or you didn't.

Separate case: hedging is appropriate for claims about *future work* or *uncertainty in results*. "These results suggest…" is fine when the results genuinely only suggest. But "we attempt to propose…" is never fine — you either proposed it or didn't.

### 5. Avoid overstating

Opposite error of the previous rule. Don't claim more than you showed.

Bad: "We have shown our algorithm is better than a decision tree."
Better: "We have shown our algorithm is more accurate than decision trees on {specific conditions}."

Reviewers at top venues read very carefully for overstatement — a single overstated claim undermines trust in the rest of the paper.

### 6. Name every choice; justify every parameter

If the paper uses single linkage, say why it's single and not group / complete / Ward. If you used N=100, say why 100 and not 50 or 200. "We used single linkage (we also tried group and Ward; results were similar, reported in appendix)" builds trust. Unjustified choices make reviewers wonder what else is hand-picked.

### 7. Sell simplicity, don't hide it

If your idea is simple, that is a feature. Claim it explicitly: "Our method is a one-line modification of X…" or "Surprisingly, a straightforward application of Y works…". Hiding simplicity behind complex notation or padding makes reviewers suspicious that you're dressing up something trivial.

Keogh's framing: "this is the simplest way to get results this good" — your paper is implicitly claiming this. Make it explicit.

### 8. Acknowledge weaknesses

Every paper has weaknesses. Unacknowledged weaknesses signal either that you don't see them (bad) or that you're hiding them (worse). An explicit limitation section, plus honest caveats throughout the paper, buys a lot of trust.

The trick: *acknowledge* the weakness, then *frame* why the work is still useful. "Our method only works for discrete data, as we noted in §4; however, discrete-data problems represent a commercially important class, and we believe our approach can be extended to continuous data via [sketch of extension]."

### 9. Quote and cite well

- Quote specific claims from specific papers when you're contesting, extending, or relying on them. Vague paraphrase invites "that's not what X said".
- Avoid laundry-list citations ("prior work has explored this [a, b, c, d, e, f, g]"). A citation bundle tells the reviewer you didn't read the papers; a differentiated discussion tells them you did.
- If a named field or adjacent body of work exists, gesture at it ("The related work in this area is vast; we refer the reader to [survey] for a broader discussion, and focus here on the subset most directly relevant: ..."). Then do the direct relevance discussion properly.

### 10. Be precise about numbers

- No spurious significant digits. "95.237%" on 300 examples is a lie about precision. Report digits commensurate with your sample size.
- Report variance / confidence intervals, not just means.
- State what units / scales are used and keep them consistent.

### 11. Take pride in the manuscript

Careless writing (typos, inconsistent formatting, broken figures, empty cells in tables) signals carelessness in the research. Do the cleanup pass before showing it to anyone.

## Section-specific guidance

Once you know which section the user is working on, read the matching reference:

| If the user is working on… | Read |
|---|---|
| **Introduction** (hook, motivation, gap, contributions, roadmap) | `references/section-intro.md` |
| **Related work** (differentiation from prior art, thematic organization) | `references/section-related-work.md` |
| **Method** (system design, algorithm description, formal definitions) | `references/section-method.md` |
| **Experiments / Evaluation / Results** | `references/section-experiments.md` |
| **Abstract** (and to some extent title) | `references/section-abstract.md` |
| **Figures or tables** (either designing from scratch or fixing a broken one) | `references/figures-and-tables.md` |

If the user is working on **background / preliminaries / problem statement / conclusion / discussion / limitations**, there is no dedicated reference; apply the universal principles above, plus the closest-adjacent reference (e.g., background borrows from method; conclusion borrows from intro).

If the user is working on a **rebuttal**, that's a different genre — invoke `respond-to-reviews` instead.

## Process: how to approach a writing task

### When drafting new prose

1. **Get the user's inputs.** What section? What's the claim / contribution in scope? What raw material is available (notes, results, figures, related work)? If missing, ask — don't invent content.
2. **Read the matching section reference.** It tells you the genre conventions and the common failure modes for this section type.
3. **Outline before drafting.** Even 3–5 bullets of "paragraph 1 establishes X, paragraph 2 handles Y" prevents meandering.
4. **Draft, applying universal principles and section-specific conventions.**
5. **Self-edit pass** focused on: implicit pointers, weak language, overstatement, unjustified choices, laundry-list citations, acronym definitions, spurious digits.
6. **Reread with the reviewer in mind.** Is it anchor-strong on the first page? Does each paragraph do distinct work? Are figures self-contained?

### When improving existing prose

1. **Read what's there carefully.** Don't rewrite based on vibes — diagnose specific problems.
2. **Name the diagnosis before fixing.** "This paragraph has three implicit pointers and overstates the second claim" is actionable; "this paragraph doesn't flow" is not.
3. **Make the minimum fix.** Don't rewrite whole paragraphs when the issue is three sentences. The user has reasons for their structure.
4. **Preserve the user's voice.** You're editing their paper; they are the author. Match tone, register, and preferred terminology (if the user uses "model" throughout, don't switch to "system").

### When designing a figure or table

Read `references/figures-and-tables.md` first. Figures are a separate craft from prose and have their own failure modes. Do not generate figure code without thinking about the point the figure needs to make.

## Output

Write prose directly into the target file (usually a `.tex` file in the paper's LaTeX repo). Honor the user's path. If they don't specify, suggest a path based on what you see (e.g., `paper/sections/intro.tex`) and confirm.

For LaTeX specifically:
- Use the project's existing commands / environments — don't introduce new ones without a reason.
- Use `\cite{}` for citations; check that the bib file has the entries you're citing (or ask the user to add them).
- Respect the venue's style (anonymous vs. not — if in doubt, check the main `.tex` for `\usepackage{...review...}` or similar flags).
- Use booktabs-style tables; avoid vertical rules.

## Important discipline

- **Don't fabricate citations.** If you cite "Smith 2024", Smith 2024 must be a real paper you (or the user) actually read. Hallucinated citations are the single fastest way to destroy reviewer trust.
- **Don't fabricate numbers.** Every number in the paper must be traceable to a result. If the user hasn't given you a number, ask — don't make one up to keep the prose flowing.
- **Don't claim results the user hasn't run.** "Our method achieves X" needs X to exist in actual experiment output. If experiments are TBD, write the prose around placeholders the user can fill in later, and mark placeholders obviously (e.g., `\todo{fill in accuracy from table 2}`).
- **Don't drift from the frame.** If the paper's framing (from `frame-research`) says the contribution is X, all sections should serve X. A beautiful paragraph that's off-frame weakens the paper.
- **Write for the most cynical reviewer.** A sentence that only works for a sympathetic reader doesn't earn its place.
