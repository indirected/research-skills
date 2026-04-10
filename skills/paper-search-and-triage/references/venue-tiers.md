# Venue Tiers Reference

This file classifies academic venues by prestige tier for the relevance scoring rubric in the
paper-search-and-triage skill. Tier is one factor in calculating a paper's relevance score;
topic relevance remains the primary criterion.

This file is shared between paper-search-and-triage and research-gap-mapper skills.

---

## Tier 1 — Top-Tier Venues

Papers from Tier 1 venues receive a +0 score bonus but are weighted more heavily when assessing
whether a finding is "established" vs "preliminary." A relevant paper at a Tier 1 venue earns a
minimum score of 4 (assuming at least moderate topic relevance).

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

Tier 2 papers are reputable but less selective. A directly relevant paper at Tier 2 earns
a maximum score of 4; adjacent papers cap at 3.

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

Tier 3 sources are valuable for discovering emerging work but should not be the primary evidence
base for claims in the paper. A directly relevant Tier 3 paper earns a maximum score of 3 unless
it is a widely cited arXiv paper (>50 citations) that is clearly the primary reference for a method.

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

Workshop papers at Tier 1 conferences are considered Tier 3 unless they are exceptional outliers
(e.g., the paper that first proposed a widely adopted method, later published at Tier 1).

---

## Upgrade Rules

A paper's effective tier can be **upgraded** if:
1. An arXiv preprint has a published conference version at Tier 1 or 2 — use the proceedings tier.
2. The paper has >200 citations on Semantic Scholar and is the canonical reference for a method.

A paper's effective tier is **never downgraded** by citation count.

---

## AutoPatch Domain: Most Relevant Venue Combinations

For the LLM-based vulnerability repair domain, the highest-priority venues to monitor are:

1. **CCS, USENIX Security, IEEE S&P, NDSS** — for security-focused vulnerability repair papers
2. **ICSE, FSE, ASE, ISSTA** — for automated program repair (APR) and LLM+SE papers
3. **ACL, EMNLP, NeurIPS, ICML** — for LLM code generation, benchmarks, and evaluation methodology
4. **arXiv cs.CR + cs.SE** — for the latest preprints before conference versions appear

When assessing a paper's relevance score, a paper at CCS on vulnerability repair scores 5.
A paper at arXiv on general program repair scores 3 at most (unless it directly evaluates on CVEs).

---

## BibTeX Venue Strings

Use these standard strings in `custom.bib` to ensure consistent formatting:

```
CCS         → booktitle = {Proceedings of the 2024 ACM SIGSAC Conference on Computer and Communications Security}
USENIX Sec  → booktitle = {33rd USENIX Security Symposium (USENIX Security 24)}
IEEE S&P    → booktitle = {2024 IEEE Symposium on Security and Privacy (SP)}
NDSS        → booktitle = {Proceedings of the Network and Distributed System Security Symposium}
ACL         → booktitle = {Proceedings of the 62nd Annual Meeting of the Association for Computational Linguistics (Volume 1: Long Papers)}
EMNLP       → booktitle = {Proceedings of the 2024 Conference on Empirical Methods in Natural Language Processing}
NeurIPS     → booktitle = {Advances in Neural Information Processing Systems 37}
ICML        → booktitle = {Proceedings of the 41st International Conference on Machine Learning}
ICSE        → booktitle = {Proceedings of the 2024 IEEE/ACM International Conference on Software Engineering}
FSE         → booktitle = {Proceedings of the ACM International Conference on the Foundations of Software Engineering}
```
