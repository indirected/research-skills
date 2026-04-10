# Venue Tiers Reference (Shared)

This file is shared between the `paper-search-and-triage` and `research-gap-mapper` skills.
The canonical copy lives at:
`skills/paper-search-and-triage/references/venue-tiers.md`

This copy is provided for convenience so the research-gap-mapper skill does not need to
navigate to another skill's directory. Both files should remain identical. If you update one,
update the other.

---

## How Venue Tier Affects the Gap Map

In the research-gap-mapper workflow, venue tier is used in two places:

1. **Evidence strength for gap importance (Step 4):**
   A gap is considered more important if it is adjacent to work published at Tier 1 venues.
   - Tier 1 paper explicitly lists a direction as "future work" → strong evidence the gap matters
   - Only Tier 3 preprints note the gap → weaker evidence (may be a niche sub-problem)

2. **Competitive threat assessment (Step 5):**
   A paper at Tier 1 that occupies a similar coverage matrix cell as AutoPatch is a stronger
   competitive threat than an arXiv preprint.

---

## Tier 1 — Top-Tier Venues

### Security

| Abbreviation | Full Name | Typical Acceptance Rate |
|---|---|---|
| CCS | ACM Conference on Computer and Communications Security | ~18% |
| USENIX Security | USENIX Security Symposium | ~16% |
| IEEE S&P | IEEE Symposium on Security and Privacy ("Oakland") | ~13% |
| NDSS | Network and Distributed System Security Symposium | ~17% |

### Machine Learning / AI

| Abbreviation | Full Name | Typical Acceptance Rate |
|---|---|---|
| NeurIPS | Conference on Neural Information Processing Systems | ~26% |
| ICML | International Conference on Machine Learning | ~28% |
| ICLR | International Conference on Learning Representations | ~31% |
| AAAI | AAAI Conference on Artificial Intelligence | ~23% |

### Natural Language Processing

| Abbreviation | Full Name | Typical Acceptance Rate |
|---|---|---|
| ACL | Annual Meeting of the Association for Computational Linguistics | ~25% |
| EMNLP | Conference on Empirical Methods in NLP | ~27% |
| NAACL | North American Chapter of the ACL | ~25% |

### Software Engineering

| Abbreviation | Full Name | Typical Acceptance Rate |
|---|---|---|
| ICSE | International Conference on Software Engineering | ~21% |
| FSE / ESEC | ACM SIGSOFT Symposium / European SE Conference | ~22% |
| ASE | Automated Software Engineering Conference | ~22% |
| ISSTA | International Symposium on Software Testing and Analysis | ~24% |

### Systems

| Abbreviation | Full Name | Typical Acceptance Rate |
|---|---|---|
| SOSP | ACM Symposium on Operating Systems Principles | ~13% |
| OSDI | USENIX Symposium on Operating Systems Design and Implementation | ~16% |

---

## Tier 2 — Strong Second-Tier Venues

### Security (Tier 2)

| Abbreviation | Full Name |
|---|---|
| EuroS&P | IEEE European Symposium on Security and Privacy |
| SecureComm | International Conference on Security and Privacy in Communication Networks |
| RAID | International Symposium on Research in Attacks, Intrusions, and Defenses |
| AsiaCCS | ACM ASIA Conference on Computer and Communications Security |
| DIMVA | Detection of Intrusions and Malware, and Vulnerability Assessment |

### Software Engineering (Tier 2)

| Abbreviation | Full Name |
|---|---|
| ICSME | International Conference on Software Maintenance and Evolution |
| SANER | IEEE International Conference on Software Analysis, Evolution, and Reengineering |
| MSR | Mining Software Repositories |
| ICPC | IEEE International Conference on Program Comprehension |

### AI / NLP (Tier 2)

| Abbreviation | Full Name |
|---|---|
| EACL | European Chapter of the ACL |
| COLING | International Conference on Computational Linguistics |
| AISTATS | International Conference on Artificial Intelligence and Statistics |
| ECAI | European Conference on Artificial Intelligence |

### Transactions / Journals

| Abbreviation | Full Name |
|---|---|
| TDSC | IEEE Transactions on Dependable and Secure Computing |
| TIFS | IEEE Transactions on Information Forensics and Security |
| TSE | IEEE Transactions on Software Engineering |
| TOSEM | ACM Transactions on Software Engineering and Methodology |
| TACL | Transactions of the Association for Computational Linguistics |

---

## Tier 3 — Workshop Papers and Preprints

### Preprint Servers

| Source | Notes |
|---|---|
| arXiv cs.CR | Cryptography and security preprints. Check if conference version exists. |
| arXiv cs.SE | Software engineering preprints. Often appear 6+ months before proceedings. |
| arXiv cs.LG | ML preprints; relevant for LLM evaluation methodology papers. |
| arXiv cs.PL | Programming languages; relevant for program synthesis and repair. |

### Workshop Venues (examples)

| Format | Example |
|---|---|
| `{Workshop} @ {Top Conference}` | `SecCodePLUG @ NeurIPS 2024` |
| `{Workshop} @ {Top Conference}` | `DeepSec @ USENIX Security 2024` |
| `{Workshop} @ {Top Conference}` | `LLM4Code @ ICSE 2024` |

---

## Upgrade Rules

A paper's effective tier can be **upgraded** if:
1. An arXiv preprint has a published conference version at Tier 1 or 2 — use the proceedings tier.
2. The paper has >200 citations on Semantic Scholar and is the canonical reference for a method.

---

## Gap Importance Scoring by Venue Evidence

Use this table when scoring the "Importance" dimension of each gap (Step 4 in research-gap-mapper):

| Evidence type | Importance boost |
|---|---|
| Tier 1 paper explicitly states direction as "future work" | +2 |
| Multiple Tier 1 papers share the same limitation | +2 |
| Single Tier 1 paper adjacent to the gap | +1 |
| Tier 2 papers note the gap | +0 |
| Only Tier 3 preprints note the gap | -1 |
| NVD / OSS-Fuzz statistics directly motivate the gap | +2 |
| Lab has preliminary results supporting the gap | +1 |

Base importance is 3 (medium). Add/subtract boosts. Clamp to range [1, 5].

---

## AutoPatch Domain: Most Relevant Venue Combinations

For the LLM-based vulnerability repair domain, the highest-priority venues to monitor are:

1. **CCS, USENIX Security, IEEE S&P, NDSS** — security-focused vulnerability repair
2. **ICSE, FSE, ASE, ISSTA** — automated program repair and LLM+SE
3. **ACL, EMNLP, NeurIPS, ICML** — LLM code generation, benchmarks, evaluation methodology
4. **arXiv cs.CR + cs.SE** — latest preprints before conference versions appear

For gap mapping purposes: a gap in C/C++ vulnerability repair with fuzzer oracle is adjacent to:
- CCS and USENIX Security (primary security venue for vulnerability work)
- ISSTA and ASE (primary SE venue for APR)
- ICSE (broad SE, where APR surveys and benchmarks often appear)

A gap unsupported by work at any of these venues may indicate the problem is niche; assess carefully.
