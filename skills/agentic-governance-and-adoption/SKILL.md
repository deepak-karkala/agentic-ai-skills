---
name: agentic-governance-and-adoption
description: >
  Designs the governance posture and adoption strategy for an agentic AI
  product or internal deployment. Assesses governance maturity level, defines
  minimum governance controls, maps regulatory baseline requirements, designs
  the UX for human-agent collaboration, and plans the Land/Expand/Scale
  adoption sequence. Use when deploying an agent internally or externally in
  an organization, when a compliance or legal team is asking what governance
  is in place, when designing the UX for an agent that users will collaborate
  with daily, or when planning how to grow adoption from a pilot to
  organization-wide deployment.
  Trigger phrases: "what governance do we need for this agent", "design the
  UX for our agent", "how do we roll out this agent to the organization",
  "what compliance requirements apply to this agent", "assess our governance
  maturity for agentic AI", "design our human-agent collaboration UX",
  "how do we get from pilot to production adoption", "what regulatory
  requirements do we need to meet for this agent".
  Do not use for technical agent architecture (use agentic-system-design),
  for deployment readiness and guardrail design (use deployment-readiness),
  for product strategy and wedge (use agentic-product-strategy), or for
  eval strategy (use agent-eval-design).
allowed-tools:
  - Read
  - Write
metadata:
  category: product-strategy
  version: "0.1.0"
---

# Agentic Governance and Adoption

Governance design and adoption planning skill. Assesses governance maturity, defines minimum controls, maps regulatory requirements, designs human-agent collaboration UX, and plans the adoption sequence. Produces a structured governance and adoption document.

## When to Use

**Use when:**
- Deploying an agent internally or externally in an organization with governance requirements
- A compliance or legal team is asking what governance controls are in place
- Designing the UX for an agent that users will collaborate with daily
- Planning how to grow adoption from a pilot to org-wide or customer-wide deployment
- Entering a regulated market (finance, healthcare, legal, government)

**Do not use when:**
- The question is about technical guardrail implementation → use `deployment-readiness`
- The question is about eval strategy → use `agent-eval-design`
- The question is about technical agent architecture → use `agentic-system-design`
- The question is about product wedge or market strategy → use `agentic-product-strategy`

## Workflow

### Step 1 — Gather context

Ask the user:
1. What does the agent do, and who uses it? (Internal employees, customers, external partners?)
2. What industry does the deploying organization operate in? (Regulated: finance, healthcare, legal, government? Or general enterprise?)
3. What is the current governance posture? (No governance, informal review, structured process, certified program?)
4. What is the desired deployment scope? (Pilot team, department, company-wide, customer-facing?)
5. What is the autonomy level of the agent? (Supervised, gated, or fully autonomous actions?)

---

### Step 2 — Assess governance maturity

Place the organization on the governance maturity model:

| Level | Name | Characteristics |
|---|---|---|
| **Level 1** | Ad Hoc | No AI governance policy; agents deployed without review; no accountability structure |
| **Level 2** | Defined | AI policy exists; pre-deployment review required; roles assigned (AI owner, risk owner); basic logging |
| **Level 3** | Managed | Structured risk assessment per deployment; monitoring in place; incident response defined; regular audits |
| **Level 4** | Optimized | Continuous improvement loop; governance metrics tracked; external audit or certification; regulatory engagement |

**Assessment questions:**
- Does a written AI policy exist and is it enforced?
- Is there a designated AI risk or governance function?
- Is there a formal pre-deployment review process?
- Is there monitoring with defined incident response?
- Is there any external audit or certification of AI governance?

For most organizations deploying their first or second agent system, Level 2 is the minimum viable governance posture. Level 3 is required for regulated industries. Level 4 is needed for high-stakes external deployments in regulated markets.

See [Governance and Regulatory Reference](references/governance-regulatory-reference.md) for full maturity model details and controls checklist.

---

### Step 3 — Define minimum governance controls

Based on the autonomy level and deployment context, define the minimum set of governance controls:

#### For all deployments (universal baseline)

1. **AI owner designated**: One named person accountable for this agent deployment's outcomes.
2. **Use case documentation**: Written description of what the agent does, what data it accesses, and what actions it can take.
3. **Logging and audit trail**: All agent decisions, inputs, and outputs logged with retention appropriate to the context.
4. **Human escalation path**: A defined path for users to escalate agent outputs to a human reviewer.
5. **Incident response**: A written process for what happens when the agent produces a harmful or incorrect output.

#### For supervised/gated deployments (Level 2+)

6. **Pre-deployment review**: Formal sign-off from risk, legal, or compliance before deployment.
7. **Scope limitation**: The agent is constrained to defined workflows; explicit list of what it cannot do.
8. **Monitoring alerts**: Defined metrics and thresholds that trigger a review (error rate, escalation rate, anomalous outputs).

#### For autonomous deployments or regulated contexts (Level 3+)

9. **Bias and fairness assessment**: Pre-deployment check for systematic errors affecting specific user groups.
10. **External audit**: Third-party review of governance controls.
11. **Regulatory disclosure**: Notification to relevant regulators if required (EU AI Act high-risk systems, HIPAA covered entity requirements, etc.)

---

### Step 4 — Map regulatory baseline

Identify which regulatory frameworks apply based on industry and deployment context:

| Framework | Applies when | Key requirements |
|---|---|---|
| **EU AI Act** | Deploying in or to EU customers; high-risk system categories (employment, credit, healthcare, law enforcement) | Risk assessment, transparency, human oversight, logging, registration for high-risk |
| **NIST AI RMF** | US federal context; voluntary framework but expected by federal procurement | Map, Measure, Manage, Govern functions |
| **ISO 42001** | Seeking AI management system certification; global enterprise deployment | AI management system requirements, continual improvement |
| **HIPAA** | Healthcare context; agent accesses or generates PHI | Business Associate Agreement, PHI access logging, minimum necessary access |
| **SOC 2 Type II** | Enterprise SaaS; customers require security/availability audit | Security controls, availability, confidentiality, privacy |
| **FINRA / SEC** | Financial services; agent provides advice or executes financial actions | Supervisory controls, suitability requirements, audit trail |
| **GDPR** | EU data subjects; agent processes personal data | Lawful basis, data minimization, subject rights, breach notification |

For each applicable framework:
1. State the specific requirements that apply to this deployment.
2. Identify any requirements that are currently unmet.
3. Flag any hard blockers that must be resolved before deployment.

See [Governance and Regulatory Reference](references/governance-regulatory-reference.md) for framework-specific controls mapping.

---

### Step 5 — Design human-agent collaboration UX

Agent UX is different from chatbot UX. Design the collaboration model explicitly:

#### Transparency layer

Users must know:
1. **When they are talking to an agent** (not a human). Disclose agent identity clearly.
2. **What the agent can and cannot do**. Set expectations at the start of every interaction.
3. **How confident the agent is**. Surface uncertainty, not false confidence. "I'm not certain about X — would you like me to flag this for review?"
4. **What the agent did and why** (audit trail for the user, not just for compliance). "I routed this to the billing team because [reason]."

#### Control layer

Users must be able to:
1. **Override the agent's recommendation** at any point without friction.
2. **Escalate to a human** with a single action.
3. **Review what the agent is about to do** before it acts on irreversible actions.
4. **Undo or correct agent actions** where technically possible.

#### Trust calibration layer

Design UX to support accurate trust calibration — users should trust the agent as much as it deserves, not more and not less:
- Show error rates and confidence levels when available.
- Surface recent failures or known limitations in the agent's domain.
- Avoid language that implies human-level judgment ("I believe", "I'm sure") unless the agent has been validated at that level.
- Design onboarding to build correct mental models — "The agent is good at X, tends to struggle with Y."

#### Collaboration pattern by autonomy tier

| Autonomy tier | UX pattern | User role |
|---|---|---|
| L1 (assisted) | Agent drafts; user finalizes | User makes all decisions; agent prepares materials |
| L2 (supervised) | Agent recommends; user approves | User reviews each action; one-click approve or reject |
| L3 (gated) | Agent acts; user notified; review on trigger | User monitors; reviews exceptions and flagged cases |
| L4/L5 (autonomous) | Agent acts; user audits | User audits periodically; relies on monitoring infrastructure |

---

### Step 6 — Plan the adoption sequence

Apply the Land → Expand → Scale motion to the internal or customer deployment:

**Land phase (pilot)**
- Scope: 5–20 users, single workflow, high-touch support
- Goal: Prove value and build confidence before scale
- Criteria to advance: measurable ROI, no critical failures, pilot users become advocates
- Duration: 4–8 weeks

**Expand phase (department or segment)**
- Scope: 50–500 users, 2–3 workflows, self-service onboarding
- Goal: Demonstrate repeatability and build governance muscle
- Criteria to advance: governance Level 2 in place, support load manageable, adoption metrics healthy
- Duration: 1–3 months

**Scale phase (org-wide or regulated market)**
- Scope: All eligible users, full workflow coverage, compliance-ready
- Prerequisites: Level 3 governance, regulatory requirements addressed, monitoring and incident response proven
- Duration: ongoing; quarterly review cycles

**Adoption blockers to flag:**
- Change management resistance (users feel threatened by agent)
- Unclear ownership of agent errors (who is responsible?)
- IT security or data governance restrictions on agent data access
- Lack of executive sponsorship for required process changes

---

### Step 7 — Write the governance and adoption document

Write a structured document to:
- `artifact_output_path/governance-<name>.md` if `artifact_output_path` is configured in `.agentic/config.yml`
- Otherwise: `.agentic/artifacts/governance-<name>.md`

Use the format:

```markdown
# Governance and Adoption: <Product/Deployment Name>

## Governance Maturity Assessment
[Current level and gap to target level]
[Priority controls to add]

## Minimum Governance Controls
[Universal baseline checklist — met/not met for each]
[Context-specific controls — met/not met for each]

## Regulatory Baseline
[Applicable frameworks with key requirements and current status]
[Blockers that must be resolved before deployment]

## Human-Agent Collaboration UX
[Transparency layer design]
[Control layer design]
[Trust calibration approach]
[Collaboration pattern by autonomy tier]

## Adoption Sequence
[Land phase: scope, criteria, timeline]
[Expand phase: scope, criteria, timeline]
[Scale phase: prerequisites, timeline]

## Open Risks and Blockers
[Any governance gaps, regulatory blockers, or adoption risks]

## Recommended Next Steps
[Ordered by urgency]
```

---

### Step 8 — Report

After writing the document:
1. State the file path.
2. State the governance maturity level (current vs. target).
3. Flag any regulatory blockers that must be resolved before deployment.
4. Flag any UX design gaps in the transparency or control layers.
5. Suggest next steps: `deployment-readiness` for technical guardrail implementation, `agent-eval-design` for building the eval suite that supports governance, or specific regulatory preparation.

## Output Contract

- **Primary output:** Governance and adoption Markdown document at `artifact_output_path/governance-<name>.md` or `.agentic/artifacts/governance-<name>.md`
- **In-conversation summary:** maturity level, regulatory blockers, UX gaps, adoption sequence, next steps
- **Does not produce:** technical guardrail implementations, eval plans, architecture decisions, legal advice

## Scope Boundaries

This skill designs governance posture and adoption strategy. It does not implement guardrails (route to `deployment-readiness`) or design evals (route to `agent-eval-design`). If regulatory requirements reveal a need for architectural changes (e.g., HIPAA requires data isolation that affects the agent design), flag it and route to `agentic-system-design`.

This skill does not constitute legal or compliance advice. It provides a framework for identifying requirements and gaps. Organizations in regulated industries should engage qualified legal and compliance counsel.
