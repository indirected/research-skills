# Literature synthesis — {{project / area name}}

**Synthesized on:** {{absolute date}}
**Notes drawn from:** {{N papers, with paths or a short list — cite explicitly}}
**Caveats on coverage:** {{e.g., "missing post-2025 work on X" or "sample may underweight industry papers"}}

---

## Themes

Each theme is a research question or claim that cuts across multiple papers, not a topic tag.

### Theme 1 — {{question-shaped theme name}}

**Papers:** {{paper A (notes path), paper B, ...}}

**Consensus:**
{{What most papers in this theme agree on, stated as a claim, with specific paper citations.}}

**Disagreement:**
{{Where papers diverge — on benchmarks, methods, or definitions. Cite the papers on each side.}}

**Empirical footprint:**
{{What datasets / model sizes / domains are actually covered in this theme. Where is it thin?}}

**Methodological monoculture:**
{{Has the theme converged on one eval protocol / benchmark / model family? What could hide in that convergence?}}

### Theme 2 — ...

{{repeat}}

---

## Empirical coverage

A table summarizing which datasets / model sizes / domains / languages the field has actually evaluated on. Useful for spotting under-tested regions.

| Paper | Datasets | Model size(s) | Domain | Language | Eval metric | Seeds |
|---|---|---|---|---|---|---|
| {{Author 2024}} | MMLU, GSM8K | 7B, 70B | general | en | accuracy | 3 |
| ... | ... | ... | ... | ... | ... | ... |

**Under-covered regions (from this table):**
- {{e.g., no paper evaluates on non-English data}}
- {{e.g., all papers use the same benchmark suite}}

---

## Gap map

Each gap is typed: **unexplored** / **under-evaluated** / **reopenable**.

### Gap 1 — {{short name}}
- **Type:** {{unexplored / under-evaluated / reopenable}}
- **What's missing:** {{one sentence}}
- **Why it's missing:** {{hard / expensive / unfashionable / assumed-solved / etc.}}
- **Does the reason still hold?** {{yes / no — explain}}
- **What would count as filling it:** {{concretely: a paper that does X on Y and shows Z}}

### Gap 2 — ...

---

## Grounded opinions

(Commit to positions. The user can push back — that's the point.)

**Center of gravity:** {{what most of the community currently assumes is true}}

**What the center gets wrong or misses:** {{where the consensus is thinner than it looks, with specific reasoning}}

**Where the next interesting paper is likely to come from:** {{which unclaimed ground looks most promising, and why}}

---

## Open items for further reading

{{If the synthesis revealed obvious missing papers, list them here so the user can prioritize next reads.}}
