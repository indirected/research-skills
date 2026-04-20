# {{Short title}} ({{Authors}}, {{Venue Year}})

**Source:** {{arXiv URL / DOI / local path}}
**Read on:** {{absolute date}}
**Read by:** {{reader name, if multi-author project}}

---

## Problem statement (one sentence)

{{Single-sentence statement in the form: "X is good for Y in the context of Z" or
"An X approach to Y mitigates the need for Z." If the paper doesn't make this easy,
note that as a finding.}}

## Real contributions (decomposed)

| Claimed contribution | Type | Genuinely new? | Differentiation from closest prior work |
|---|---|---|---|
| {{e.g., "new architecture"}} | conceptual / methodological / empirical / artifact | yes / partial / no ({{cite precedent}}) | {{one-sentence concrete difference}} |

## Method in plain words

{{2–5 sentences: the scaffolding of the method. Someone reading this should know the
shape of the technique without needing the paper open. Cite §X.Y for detail.}}

**Underspecified / glossed steps:**
- {{step and where in the paper it's handwaved}}

**External dependencies:**
- {{e.g., requires GPT-4 as judge / requires proprietary dataset X / requires pretrained encoder Y}}

**Hidden critical choices:**
- {{e.g., "uses cosine similarity" — on what embeddings, projected how}}

## Hidden assumptions (not flagged by the paper)

- {{e.g., assumes English-only inputs}}
- {{e.g., assumes bounded sequence length ≤ 2k}}
- {{e.g., assumes closed-set labels}}
- {{e.g., assumes the teacher model is GPT-4-tier}}

## Falsifiability audit

| Main claim | Falsifiable? | Evidence in paper | Evidence strength |
|---|---|---|---|
| {{claim 1}} | yes / no / partial | Table X, §Y.Z | statistically significant over N seeds / single run / cherry-picked example / rhetorical |

## Evaluation fairness

- **Baseline configurations:** {{1 vs N variants per method — any cherry-picking?}}
- **Tuning budget parity:** {{same budget across methods? yes / no / unclear}}
- **Baseline relevance:** {{are baselines from the right era / family?}}
- **Simple-baseline inclusion:** {{is there a non-learned or trivial baseline? often missing}}
- **Contamination risk:** {{any train/test overlap, especially for closed LLMs?}}
- **Prompt / seed discipline:** {{same prompts across methods? multiple seeds with variance?}}
- **Other flags:** {{anything that tilts the playing field}}

## Limitations the authors didn't state

- **Generalization:** {{what falls outside the validated domain?}}
- **Cost:** {{compute / API / annotation — reported? fair to baselines?}}
- **Reproducibility:** {{code released? data? seeds? prompts? hyperparameters?}}
- **Method fragility:** {{would it survive a different LLM / dataset?}}

## Position vs. our work

{{How this paper relates to the user's project: enabler / competitor / challenger /
orthogonal. If competitor or challenger, spell out the specific differentiation or
the specific threat. Skip if user's project context isn't provided.}}

## Quotes worth keeping

> {{rare; only include quotes that will be directly relevant for related-work prose
> or for settling a dispute about what the paper claimed}}

## One-line takeaway

{{The single sentence you'd say to a collaborator who asked "what did that paper do?"}}
