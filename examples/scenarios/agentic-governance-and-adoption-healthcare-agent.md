# Scenario: Governance Design for a Clinical Documentation Agent

## Trigger

> `/agentic-governance-and-adoption`
>
> "We're deploying an agent to help clinical staff at a community hospital auto-populate structured EHR fields from physician notes. Our legal team is asking what governance is in place. We're also not sure how to design the UX — we want doctors to trust it but not over-trust it. Help us."

## Command: /agentic-ai-engineering:agentic-governance-and-adoption

## Skill: agentic-governance-and-adoption

### Inputs gathered

1. Agent: Reads unstructured clinical notes, extracts diagnoses, medications, procedures, and populates structured EHR fields
2. Users: Clinical staff (physicians, nurses, clinical documentation specialists)
3. Industry: Healthcare — US community hospital (HIPAA covered entity)
4. Current governance: Pre-deployment review done informally; no written AI policy; no monitoring in place
5. Deployment scope: Pilot with 5 physicians, target: hospital-wide
6. Autonomy level: L2 (supervised) — agent proposes field values; physician confirms before EHR commit

### Step 2 — Governance maturity assessment

**Current level: Level 1 (Ad Hoc)**

- No written AI policy
- No formal AI use case register
- Informal pre-deployment review only
- No monitoring or alerting
- No structured incident response for AI errors

**Target level: Level 3 (Managed)** — required for a HIPAA-covered healthcare deployment with clinical consequences

**Gap to close:**
1. Level 2: Write AI policy, designate AI owner, formalize pre-deployment review, implement logging, document escalation path
2. Level 3: Structured risk assessment, monitoring with alerts, bias check (does the agent perform equally across patient demographics?), HITL gate formalized (already in design as L2 autonomy)

### Step 3 — Minimum governance controls

**Universal baseline — Status:**
- [ ] AI owner designated: NOT MET — assign CMIO or CIO as AI owner for this deployment
- [ ] Use case documentation: PARTIAL — informal notes exist; formalize into written scope document
- [ ] Logging and audit trail: NOT MET — must implement before go-live; HIPAA requires PHI access logging
- [ ] Human escalation path: MET — L2 design requires physician confirmation; disagreement path is explicit
- [ ] Incident response: NOT MET — no written process; must define before go-live

**Healthcare-specific controls:**
- [ ] BAA with Anthropic (or model provider): NOT MET — CRITICAL BLOCKER before any PHI reaches the model
- [ ] PHI de-identification audit: NOT MET — assess whether note content can be partially de-identified before model processing
- [ ] Minimum necessary access check: NOT MET — confirm agent only accesses fields required for structured extraction task
- [ ] HIPAA breach notification plan: NOT MET — add PHI-specific breach scenario to incident response

### Step 4 — Regulatory baseline

**Applicable frameworks:**

**HIPAA** (CRITICAL — hard blocker):
- Agent processes PHI (clinical notes contain patient identity and health information)
- BAA required with model provider before first PHI call — this is an absolute prerequisite
- All PHI access must be logged with staff identity, timestamp, and note accessed
- Breach response plan required for the scenario where the agent exposes PHI (e.g., outputs one patient's data in another patient's context)
- Status: **NOT MET — blocks deployment**

**EU AI Act** (not applicable — US deployment, US patients)

**NIST AI RMF** (voluntary but advisable):
- Healthcare organizations increasingly referenced in NIST AI RMF guidance
- Map function: identify risks (diagnostic error, demographic bias, PHI leakage)
- Manage function: HITL gate, monitoring — partially addressed by L2 design

**SOC 2**: Not directly applicable for internal hospital deployment, but if the hospital is working with an AI vendor, vendor's SOC 2 status is relevant for procurement.

**Regulatory blockers (must resolve before pilot):**
1. BAA with model provider — cannot deploy on real patient data without this
2. PHI access logging implemented — required by HIPAA Security Rule
3. Incident response plan for PHI breach scenario

### Step 5 — Human-agent collaboration UX

**Transparency layer design:**
- Disclosure: "AI-assisted documentation — all suggestions require physician review before saving"
- Confidence display: Show extraction confidence per field (high/medium/low), not just the extracted value
  - High confidence: green indicator, suggested value pre-populated
  - Medium confidence: yellow indicator, value shown with "Review carefully" label
  - Low confidence: red indicator, field left blank with "Agent could not determine — please enter manually"
- Audit transparency: Each field shows its source (which sentence in the note generated this extraction)

**Control layer design:**
- Physician approval required for every EHR commit — agent cannot write to EHR without explicit confirmation
- Single-click override: Change any field before confirming
- Reject all: One button to dismiss all agent suggestions and enter manually
- Flag for review: One button to escalate a specific extraction to a clinical documentation specialist

**Trust calibration design:**
- Onboarding message: "The agent is most accurate for standard ICD-10 diagnoses and common medications. It has a higher error rate for rare conditions, complex polypharmacy, and unusual procedure coding. Always review carefully for these cases."
- Performance dashboard for physicians: Monthly summary of their acceptance rate, correction rate, and which field types generate the most corrections — personalizes trust to actual performance for each physician
- System-wide transparency: Share aggregate accuracy metrics with clinical staff quarterly

**Collaboration pattern:** L2 (Supervised)
- Agent drafts field values from note content
- Physician reviews each field before confirming
- Physician approval triggers EHR write

### Step 6 — Adoption sequence

**Land phase (Pilot — 5 physicians, 4 weeks):**
- Scope: Cardiology department, 3 common diagnosis categories only (reduces blast radius)
- Goal: Validate accuracy on real notes, identify edge cases, collect physician feedback
- Criteria to advance: >85% field-level acceptance rate, zero PHI incidents, at least 3 physicians willing to continue
- Support: Dedicated clinical informatics support during pilot; weekly feedback sessions

**Expand phase (Department — 50 physicians, 2 months):**
- Scope: Internal medicine + cardiology, full diagnosis list
- Prerequisites: Level 2 governance in place, BAA executed, HIPAA logging implemented
- Goal: Demonstrate repeatability across specialties, build governance muscle
- Criteria to advance: Monitoring in place, incident response tested in tabletop exercise, >80% physician satisfaction

**Scale phase (Hospital-wide — all clinical staff):**
- Prerequisites: Level 3 governance, bias assessment completed, CMIO sign-off, nursing/NP workflow validated separately
- Timeline: 6–9 months post-pilot
- Regular review: Quarterly accuracy report reviewed by CMIO and clinical informatics team

### Document written

`.agentic/artifacts/governance-clinical-documentation-agent.md`

```
Governance and Adoption: Clinical Documentation Agent

Governance maturity: Level 1 (current) → Level 3 (required)

CRITICAL BLOCKERS (must resolve before pilot on real patient data):
1. BAA with model provider — no PHI can be sent to the model without this
2. PHI access logging not implemented — HIPAA Security Rule requirement
3. No written incident response plan for PHI breach scenario

Regulatory: HIPAA governs this deployment. EU AI Act not applicable.

UX: L2 supervised — agent proposes, physician approves before EHR write.
Confidence indicators per field. Source attribution per extraction.
Trust calibration via per-physician performance dashboard.

Adoption: Land (5 physicians, cardiology, 4 weeks) → Expand (50, internal 
medicine + cardiology, 2 months) → Scale (hospital-wide, 6–9 months).

Next steps:
1. /agentic-ops — implement PHI access logging and audit trail (guardrail)
2. Engage model provider legal team for BAA (immediate, blocks everything else)
3. Designate CMIO as AI owner and formalize incident response plan
```
