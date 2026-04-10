# Venue Requirements Reference

Authoritative requirements for security and ML venues targeted by the lab.
Last reviewed: April 2026. Always cross-check against the official CFP for the current cycle.

---

## CCS (ACM Conference on Computer and Communications Security)

**Tier:** Top-4 security venue (with USENIX Security, IEEE S&P, NDSS)
**Frequency:** Annual (October/November)
**Submission system:** HotCRP (ccs[YEAR].hotcrp.com)
**Review model:** Double-blind

### Page Limits
| Version | Content pages | References | Total |
|---------|--------------|------------|-------|
| Submission | 10 | +5 (max) | 15 |
| Camera-ready | 10 | +5 (max) | 15 |
| Short/WiSec | per-workshop CFP | varies | varies |

Notes:
- The "+5 for references" means at most 5 *additional* pages, not 5 pages total for references.
- Appendices: allowed but reviewers are not required to read them; must fit within the 10+5 limit or be submitted as supplementary material.
- Figures and tables count toward the 10-page content limit.

### Formatting
- Template: ACM double-column (`acmart` class, `sigconf` style)
- Font: 10pt Times Roman; do not alter margins or font sizes
- File format: PDF only
- File size: No stated limit; keep under 50 MB (HotCRP default cap)

### Blind Policy
- Double-blind: Remove all author names, affiliations, acknowledgments
- Self-references must be anonymized: cite your prior work in third person
- URLs to personal/lab GitHub repos must be removed or anonymized (use anonymous.4open.science)
- Funding acknowledgments must be removed from submission

### Required Sections / Elements
- Abstract (≤200 words recommended)
- Introduction, Related Work, Methodology, Evaluation, Conclusion, References
- CCS Concepts (mandatory — use ACM CCS taxonomy, insert via `\ccsdesc{}`)
- Keywords (3–6 keywords)
- Ethics consideration paragraph: required if research involves human subjects, real-world systems, or datasets derived from user data. Should appear at the end of the paper or as a standalone section.

### Artifact Evaluation
- Optional but strongly encouraged
- Artifacts evaluated separately after acceptance
- Badges: "Artifacts Available", "Artifacts Functional", "Results Reproduced"
- Artifact appendix (2 pages max, does not count toward page limit) required for AE submission

### Conflicts of Interest
- Declare by institution domain (e.g., `mit.edu`, not individual names)
- Co-authors within 12 months, advisors, PhD students count as conflicts
- Declare via HotCRP conflict form before submission deadline

### Submission Timeline (typical)
- January: Paper deadline (Cycle 1)
- May: Paper deadline (Cycle 2) — check exact year's CFP
- Author response: ~2 weeks after review notification
- Notification: ~6–8 weeks after deadline
- Camera-ready: ~4 weeks after notification

---

## USENIX Security

**Tier:** Top-4 security venue
**Frequency:** Annual (August); three submission deadlines per year
**Submission system:** HotCRP (sec[YY].hotcrp.com)
**Review model:** Double-blind

### Page Limits
| Version | Content pages | References | Notes |
|---------|--------------|------------|-------|
| Submission | 13 | Unlimited | References do not count toward limit |
| Camera-ready | 13 | Unlimited | + optional 2-page artifact appendix |

Notes:
- No separate "supplementary" track — everything must fit in the 13 pages.
- Figures and tables count toward the 13-page limit.
- Very strict: papers over limit are desk-rejected without review.

### Formatting
- Template: USENIX template (LaTeX or Word, available at usenix.org/author-tools)
- Two-column, 10pt Times; do NOT modify the template
- Margins are set by the template — do not shrink them
- File format: PDF

### Blind Policy
- Double-blind (same rules as CCS above)
- USENIX requires that the blinded version be submitted; cannot submit a preprint link instead

### Required Sections / Elements
- Abstract, Introduction, Related Work, Conclusion, References
- Ethics consideration: Strongly recommended; may be required by Program Chair for sensitive research
- No specific CCS Concepts required (unlike ACM venues)

### Rolling Deadlines (three per year)
Each deadline is a full review cycle with its own notification:
- Summer deadline (June) → notification by September → presentation at August conference
- Fall deadline (October) → notification by January
- Winter deadline (February) → notification by May

Authors who receive "Major Revision" may resubmit to the next deadline cycle.

### Conflicts of Interest
- Same rules as CCS (domain-level, HotCRP form)

---

## IEEE S&P (IEEE Symposium on Security and Privacy)

**Tier:** Top-4 security venue
**Frequency:** Annual (May); two submission deadlines per year
**Submission system:** HotCRP
**Review model:** Double-blind

### Page Limits
| Version | Content pages | References |
|---------|--------------|------------|
| Submission | 13 | Unlimited |
| Camera-ready | 13 | Unlimited |

Notes:
- IEEE S&P is strict about the 13-page limit. Any page over the limit triggers desk rejection.
- Appendices may be included but reviewers are not required to read them and they must fit within 13 pages (no separate supplementary upload for main paper track).

### Formatting
- Template: IEEE Symposium on Security and Privacy LaTeX template (available from ieee-security.org)
- Two-column, 10pt; default margins
- File format: PDF, IEEE-Xplore compatible (embed all fonts)

### Blind Policy
- Double-blind
- IEEE S&P specifically flags: do not include the paper number in the submission; do not cite unpublished technical reports that identify the authors

### Required Sections / Elements
- Abstract, Introduction, Conclusion, References
- Ethics: Ethics review statement required if paper involves human subjects or IRB-exempt but sensitive data (added since 2022); describe IRB status
- No required keywords section (but recommended)

### Submission Deadlines (typical)
- Deadline 1: April (for papers appearing the following May)
- Deadline 2: November (same conference year)

---

## NeurIPS (Conference on Neural Information Processing Systems)

**Tier:** Top ML/AI venue
**Frequency:** Annual (December)
**Submission system:** OpenReview (openreview.net)
**Review model:** Single-blind since 2022 (authors visible; reviewers anonymous)

### Page Limits
| Version | Content pages | References | Notes |
|---------|--------------|------------|-------|
| Submission | 9 | Unlimited | Checklist required on p9+ |
| Camera-ready | 9 | Unlimited | + acknowledgments + checklist |

Notes:
- NeurIPS checklist is mandatory: a multi-page questionnaire about reproducibility, ethics, limitations. It goes after references and does NOT count toward the page limit.
- Appendix is allowed and unlimited, but reviewers are not required to read it.

### Formatting
- Template: NeurIPS LaTeX template (download from neurips.cc each year — it changes)
- Single-column, 11pt; custom margins set by template
- Do not modify the template style file
- File format: PDF

### Blind Policy (since 2022)
- Authors are NOT anonymous on OpenReview
- Reviewers remain anonymous
- A preprint on arXiv before the submission deadline is allowed (but communicating publicly during review period violates policy)

### Required Sections / Elements
- Abstract, Introduction, Related Work, Conclusion, References
- NeurIPS Paper Checklist (mandatory; see template for current version)
- Limitations section: strongly recommended (since 2021); some ACs treat omission as a weakness
- Broader Impacts: required for papers with potential societal impact

### Author Response
- 1-week author response period (OpenReview discussion phase)
- Responses are short (typically ≤500 words in the rebuttal form)

### Conflicts
- Managed via OpenReview profile; include all institutional affiliations and co-authors from the past 3 years

---

## ACL (Annual Meeting of the Association for Computational Linguistics)

**Tier:** Top NLP venue (along with EMNLP and NAACL)
**Frequency:** Annual (summer/fall)
**Submission system:** OpenReview (since ACL 2023)
**Review model:** Double-blind

### Page Limits
| Paper type | Submission | Camera-ready | Notes |
|-----------|-----------|-------------|-------|
| Long paper | 8 pages content | 9 pages content | + unlimited references |
| Short paper | 4 pages content | 5 pages content | + unlimited references |
| Findings paper | same as long | same as long | lower bar for impact |

Notes:
- References do NOT count toward page limit.
- Acknowledgments (camera-ready only) do NOT count toward page limit.
- Ethical Considerations section does NOT count toward page limit.
- Limitations section does NOT count toward page limit.
- Appendices do NOT count toward page limit (since ACL 2022).

### Formatting
- Template: ACL LaTeX template (`acl` package, available via acl-org GitHub)
- Single-column, 11pt, specific margins defined in the .sty file
- `\usepackage[review]{acl}` for submission; `\usepackage[final]{acl}` for camera-ready
- File format: PDF

### Blind Policy
- Double-blind: author block must be blank or placeholder in review mode
- The `review` option in `acl.sty` automatically hides the author block and adds line numbers
- arXiv preprints: policy allows posting a preprint before the submission deadline but authors should not publicize it during the review period. The paper must not be directly linked in the submission.

### Required Sections / Elements
- Abstract, Introduction, Conclusion, References
- **Limitations**: Required since ACL 2023. Must explicitly state limitations of the work. Does not count toward page limit. Place before references.
- **Ethical Considerations**: Required (must complete ethics checklist during submission). The section itself is optional in the PDF but if included does not count toward page limit.
- The ACL Ethics Committee may flag papers with ethical issues; add a statement if your research involves any of: human subjects, crowdsourcing, personally identifiable information, model outputs that could harm people, dual-use concerns.

### Author Response Period
- Typically 3 days (shorter than CCS/USENIX)
- Responses visible to all reviewers and Area Chair
- Word limit: 500 words (strictly enforced by START/OpenReview form)

### Findings of ACL
- Papers not accepted to main venue may be offered "Findings of ACL" (archival but not presented at main conference)
- Authors can decline Findings and resubmit elsewhere

### ARR Integration
- ACL uses ACL Rolling Review (ARR) for some submission cycles
- ARR papers are reviewed centrally; authors "commit" the reviewed paper to a venue
- If using ARR track, submission is to ARR not directly to ACL system

---

## EMNLP (Conference on Empirical Methods in Natural Language Processing)

**Tier:** Top NLP venue (co-equal with ACL)
**Frequency:** Annual (November/December)
**Submission system:** OpenReview (via ARR or direct track)
**Review model:** Double-blind

### Page Limits
Same as ACL (see above):
- Long paper: 8 pages content (submission), 9 pages (camera-ready)
- Short paper: 4 pages content (submission), 5 pages (camera-ready)
- References, Limitations, Ethical Considerations, Acknowledgments: do NOT count

### Formatting
Same ACL template and `acl.sty` package as ACL. EMNLP uses the same style.

### Blind Policy
Same as ACL (double-blind, `\usepackage[review]{acl}` required).

### Required Sections / Elements
Same as ACL: Limitations (required), Ethical Considerations (required checklist).

### Differences from ACL
- EMNLP places higher emphasis on empirical rigor (the "E" in EMNLP means "Empirical")
- Reviewers expect ablations and statistical significance testing
- EMNLP Findings: same concept as ACL Findings

---

## NDSS (Network and Distributed System Security Symposium)

**Tier:** Top-4 security venue (slightly below CCS/USENIX/S&P in some rankings)
**Frequency:** Annual (February)
**Submission system:** HotCRP
**Review model:** Double-blind

### Page Limits
| Version | Content pages | References |
|---------|--------------|------------|
| Submission | 12 | Unlimited |
| Camera-ready | 12 | Unlimited |

### Formatting
- Template: NDSS LaTeX template (available from ndss-symposium.org)
- Two-column, 10pt
- File format: PDF

### Blind Policy
- Double-blind (same anonymization rules as CCS/USENIX)

### Required Sections / Elements
- Abstract, Introduction, Related Work, Conclusion, References
- Ethics: recommended; required if human subjects or real-world system measurements

### Submission Deadlines
NDSS has two deadlines per year (Summer and Spring cycles, each reviewing for the same conference year).

---

## Ethics Statement Requirements by Venue

| Venue | Ethics Statement | Notes |
|-------|----------------|-------|
| CCS | Required (if applicable) | Describe IRB status, data collection ethics, disclosure policy |
| USENIX Security | Strongly recommended | PC may require it for sensitive papers |
| IEEE S&P | Required (if human subjects) | Must state IRB status or exempt justification |
| NeurIPS | Broader Impacts required | + NeurIPS checklist includes ethics questions |
| ACL | Required checklist | PDF section optional but checklist is mandatory on submission |
| EMNLP | Same as ACL | |
| NDSS | Recommended | Required for human subjects research |

---

## Submission System Quick Reference

| Venue | System | URL Pattern |
|-------|--------|-------------|
| CCS | HotCRP | ccs[YEAR].hotcrp.com |
| USENIX Security | HotCRP | sec[YY].hotcrp.com |
| IEEE S&P | HotCRP | sp[YEAR].hotcrp.com |
| NeurIPS | OpenReview | openreview.net |
| ACL | OpenReview | openreview.net (or ARR) |
| EMNLP | OpenReview | openreview.net (or ARR) |
| NDSS | HotCRP | ndss[YEAR].hotcrp.com |

---

## Common Desk-Rejection Causes (by venue)

- **Over page limit**: Any venue — leads to immediate desk rejection without review
- **Anonymization violation**: Double-blind venues — author names visible, self-citations not anonymized
- **Wrong template**: Using ACL template for a CCS submission, etc.
- **Missing required section**: Ethics/Limitations at ACL/EMNLP
- **Missing CCS Concepts**: ACM venues require this metadata block
- **Broken PDF**: Fonts not embedded, figures missing, corrupt file
- **Dual-submission violation**: Submitting a paper currently under review elsewhere (check each venue's policy)
