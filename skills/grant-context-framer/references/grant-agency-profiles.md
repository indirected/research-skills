# Grant Agency Profiles

Funding agency priorities, tone guidance, and proposal structure for cybersecurity and AI research.
Last reviewed: April 2026. Always verify against the current solicitation — priorities shift yearly.

---

## NSF SaTC (Secure and Trustworthy Cyberspace)

**Program name:** Secure and Trustworthy Cyberspace (SaTC)
**Division:** CISE/CNS (Computer and Network Systems)
**Program URL:** https://www.nsf.gov/funding/pgm_summ.jsp?pims_id=504709

### Award Sizes and Durations

| Type | Budget | Duration | Typical team size |
|------|--------|----------|------------------|
| Small | Up to $600K | 3 years | 1-2 PIs |
| Medium | $600K – $1.2M | 3-4 years | 2-4 PIs |
| Large | $1.2M – $3M | 4-5 years | 4+ PIs, interdisciplinary |
| CORE (annual) | Up to $600K | 3 years | 1-3 PIs |
| TTP (Transition to Practice) | Up to $600K | 3 years | Research + industry partner |

For AutoPatch-scale work (1 PI + 2 PhD students + 1 postdoc): target CORE Small or Medium.

### Priority Research Areas (Current as of 2025-2026)

1. **AI/ML Security**: Security of machine learning systems; adversarial robustness;
   privacy in training; LLM security and misuse prevention.

2. **Secure Software Engineering**: Automated vulnerability discovery and repair;
   program analysis; supply chain security; software composition analysis.

3. **Trustworthy Systems**: Formal methods; verification; certified systems.

4. **Privacy**: Differential privacy; privacy-preserving computation; data minimization.

5. **Human Factors in Security**: Usable security; security education; human-AI teaming.

6. **Critical Infrastructure Protection**: ICS/SCADA security; healthcare systems; energy.

**AutoPatch primary alignment:** Area 2 (Secure Software Engineering) + Area 1 (AI/ML Security)

### NSF Vocabulary to Use

- "fundamental research" (NSF funds basic science, not just applications)
- "scientific foundations" (emphasize the science, not just the tool)
- "transition to practice" (if there's an industry partner angle)
- "broadening participation in computing" (if diversity angle is strong)
- "reproducible research" (open-source, open data)
- "interdisciplinary" (if team spans security + ML + HCI + formal methods)
- "workforce development" (training PhD students and undergrads)

Avoid: "deploy", "product", "commercialize" — NSF funds research, not products.

### NSF Intellectual Merit Criteria

NSF scores proposals on two criteria with equal weight:

**Intellectual Merit** — Does the research advance knowledge?
- Novelty: Why hasn't this been done before?
- Significance: What will the field know afterward that it doesn't know now?
- Rigor: Is the methodology sound?
- Qualifications: Can this team execute?

**Broader Impacts** — Does the research benefit society?
- Scientific community: Open datasets, tools, methods others will reuse
- Education: Training of PhD students, undergrad research, courses
- Diversity: How will underrepresented groups be included?
- Society: How does this reduce real-world harm?
- Dissemination: Publications, open-source, tech transfer

**Important:** NSF panels often decline proposals that have strong Intellectual Merit
but weak Broader Impacts. Both must be explicitly addressed.

### NSF Proposal Structure

- **Project Description**: 15 pages for CORE (check current solicitation — limits change)
- **References Cited**: Unlimited, not counted toward page limit
- **Facilities**: 2 pages max (cluster access, lab facilities, libraries)
- **Data Management Plan**: 2 pages (required; describe how data will be stored, shared, archived)
- **Budget Justification**: Detail all personnel, compute costs, travel
- **Project Summary**: 1 page (3 paragraphs: overview, Intellectual Merit, Broader Impacts)

### NSF SaTC-Specific Tips

- Name-drop the SaTC program explicitly in the Project Summary
- Reference prior SaTC awards that this builds on (shows awareness of the community)
- Emphasize "fundamental" contributions that go beyond the current paper
- Include a "Convergence" aspect if the team spans security + another discipline
- Program officers rotate; check recent award titles on NSF.gov to understand the
  current PO's interests before submission

---

## DARPA (Defense Advanced Research Projects Agency)

**Relevant programs for AutoPatch research:**

### DARPA AMP (Automated Program Analysis for Cybersecurity)

Past programs that AutoPatch is successor-aligned with:
- **CGC (Cyber Grand Challenge)** — automated cyber reasoning (completed)
- **CHESS** — finding and exploiting software vulnerabilities (completed)
- **ARCOS** — automated rapid certification of software (active ~2024)
- **AIE (AI Exploration)** — short-term high-risk AI research (ongoing mechanism)

For current programs, check: https://www.darpa.mil/work-with-us/opportunities

### DARPA Vocabulary and Tone

DARPA's core ethos: **"high-risk, high-reward" / "moonshot"**

Key phrases DARPA responds to:
- "game-changing capability" — be specific about the change
- "technical barriers currently prevent..." — identify what they are
- "Phase 1 / Phase 2 / Phase 3" — DARPA funds in phases with go/no-go gates
- "transition to [DoD component]" — who in the DoD will use this?
- "quantitative metrics" — every phase must have measurable success criteria
- "performer team" — DARPA uses this term for funded researchers
- "technical risk" — acknowledge it; DARPA expects risk
- "dual-use" — be careful; acknowledge if civilian applications exist

Avoid: "We will study..." or "We will investigate..." — DARPA funds "we will build" proposals.
The proposal must describe a specific system or capability that will exist at the end.

### DARPA Proposal Structure (BAA response format)

**Technical Volume (typically 15-35 pages, varies by BAA):**

1. **Executive Summary** (1-2 pages)
   - The capability gap being addressed
   - The proposed technical approach in 3 sentences
   - Why this team can execute

2. **Technical Approach** (8-15 pages)
   - Phase 1 (~18 months): What will be built? What are the metrics?
   - Phase 2 (~18 months): How is Phase 1 extended? New metrics?
   - Optional Phase 3 (transition): How does this get into a military system?

3. **Risk and Mitigation** (2-3 pages)
   - For each phase: list 3-5 technical risks
   - For each risk: likelihood (H/M/L), impact (H/M/L), mitigation approach
   - DARPA program managers expect risk acknowledgment; hiding risk is a red flag

4. **Related Work** (2-3 pages)
   - What else has been tried? Why does it fall short?
   - Do not just cite papers; explain why they don't solve the problem

5. **Team and Facilities** (1-2 pages)
   - Prior relevant work (especially prior DARPA performance)
   - Key personnel and roles

6. **Metrics and Evaluation Plan** (1 page)
   - Exact quantitative metrics for success at each phase go/no-go point

**Example Metrics for AutoPatch-aligned DARPA proposal:**
```
Phase 1 Go/No-Go Metrics:
- M1: System correctly repairs ≥ 60% of PoC vulnerability cases in the benchmark suite
- M2: Time-to-patch ≤ 30 minutes per vulnerability (fully automated, no human input)
- M3: False-negative rate (missed true bugs) ≤ 5% on held-out evaluation set
- M4: System operates on C/C++ and Python codebases without language-specific tuning

Phase 2 Go/No-Go Metrics:
- M5: ≥ 40% of generated patches pass independent red-team security review
- M6: System generalizes to at least 3 vulnerability classes not seen in Phase 1 training
- M7: End-to-end pipeline runs in cloud environment with no specialized hardware
```

### DARPA Budget Expectations

- DARPA contracts (not grants): managed by the DoD contracting office
- Typical contract: $1M–$5M per performer team per phase; total program budget much larger
- Indirect costs (overhead): universities can charge their negotiated F&A rate
- DARPA does not fund equipment well; compute access must be justified carefully
- Export control: DARPA-funded research may have restrictions on sharing with foreign nationals

---

## ARPA-H (Advanced Research Projects Agency for Health)

**Mission:** DARPA-style high-risk research specifically for healthcare applications.
**Established:** 2022; still defining its portfolio.

### Relevance to AutoPatch Research

The healthcare angle for vulnerability repair:
- **Medical device firmware**: Insulin pumps, pacemakers, imaging devices have known
  security vulnerabilities. AutoPatch could be adapted to medical device codebases.
- **Healthcare records systems**: EHR software (Epic, Cerner) has large C/C++ codebases
  with known vulnerability classes.
- **Supply chain**: Third-party medical software components with unpatched CVEs.
- **Operational technology (OT)**: Hospital building management, ventilators, infusion pumps.

### ARPA-H Tone

- Emphasize **patient safety** and **clinical outcomes**, not cybersecurity per se
- The frame should be: "Cybersecurity failures kill patients. Automated repair prevents this."
- Concrete patient-harm scenarios are valued over abstract security metrics
- ARPA-H prefers "health-first" framing, not "security-first"

### ARPA-H Proposal Structure

Similar to DARPA (phases with go/no-go metrics) but:
- Include a **Clinical Translation Plan**: How will this get deployed in hospitals?
- Include a **Healthcare Partner Letter**: A hospital system, medical device company,
  or healthcare IT vendor expressing interest
- Metrics should include **patient-outcome proxies** (e.g., "reduce mean time to patch
  for medical device CVEs from 18 months to 30 days")

---

## NIH R01 (National Institutes of Health Research Project Grant)

**Relevance to AutoPatch:** Low unless the research has a direct biomedical angle.
A stretch framing is possible via:
- Security of clinical genomics pipelines
- Privacy of health AI models (differential privacy angle)
- Automated repair of bioinformatics software vulnerabilities

### R01 Quick Reference

| Attribute | Value |
|-----------|-------|
| Typical budget | $250K–$500K direct costs per year |
| Duration | 5 years (R01); 2 years for R21 (exploratory) |
| Review | Study section (NIH peer review), two rounds |
| Page limit | 12 pages Research Plan (Specific Aims 1 page + Research Strategy 11 pages) |

### NIH Specific Aims Page (most critical)

The Specific Aims page is the most important page of any NIH proposal. Every reviewer
reads it; some only read this page.

Structure:
```
Paragraph 1: The problem and why it matters (~100 words)
Paragraph 2: The gap in knowledge / critical barrier to progress (~100 words)
Paragraph 3: Your approach and your team's qualifications (~100 words)
Paragraph 4: Central hypothesis (one sentence) and overall objective

Aim 1: [Verb] [specific measurable goal] (Years 1-2)
  Rationale: [why this aim first?]
  Expected Outcome: [what you will have at the end]

Aim 2: [Verb] [specific measurable goal] (Years 2-4)
  Rationale: ...
  Expected Outcome: ...

Aim 3: [Verb] [specific measurable goal] (Years 3-5)
  ...

Innovation statement: [What is novel about this approach?]
Impact statement: [If Aims are achieved, what changes?]
```

---

## Common Mistakes Across All Agencies

| Mistake | How to avoid |
|---------|-------------|
| Citing only your own work | Cite broadly; demonstrate field awareness |
| Too much background, too little research plan | Lead with the gap, not the history |
| No quantitative metrics for success | Every aim/phase must have measurable outcomes |
| Budget not connected to research plan | Each budget item should trace to a specific aim |
| Broader Impacts is an afterthought | Write it first; it affects narrative framing |
| Over-claiming preliminary results | Be accurate; reviewers check your citations |
| Generic statement of impact | Be specific: which agency, which system, which person benefits? |
| Ignoring the review criteria | Read the solicitation's "merit review criteria" section carefully |
| Not reading recently funded awards | Search awards databases to calibrate expectations |

---

## Research Statement (for Faculty Positions, not Grants)

If the goal is a faculty research statement (not a grant proposal), the structure is:
- 1 page: "elevator" version for hiring committee (what you do, in one paragraph each for past/present/future)
- 3-5 pages: Full research statement (background, current work, future work, broader impact)

Differences from grant proposals:
- No budget
- More emphasis on intellectual vision and long-term trajectory
- Less emphasis on phase-by-phase metrics
- Should convey "what will this person's research program look like in 10 years?"

For AutoPatch researchers: frame the arc as:
"automated vulnerability discovery → automated repair → automated secure coding → human-AI
collaborative security engineering" — a 10-year research program.
