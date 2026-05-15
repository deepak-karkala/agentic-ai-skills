# Governance and Regulatory Reference

Reference for the `agentic-governance-and-adoption` skill. Contains the full governance maturity model controls checklist, framework-specific regulatory requirements, production failure modes, and adoption anti-patterns.

---

## Governance Maturity Model: Controls by Level

### Level 1 — Ad Hoc

Characteristics: Agent deployed without formal review. No documented policy. No designated owner. No monitoring. Accountability is unclear.

Typical situation: Internal productivity tool, shadow IT deployment, proof-of-concept that never got formalized.

Risk: Any incident (wrong output, data leak, user harm) has no response playbook. Remediation is ad hoc.

---

### Level 2 — Defined

**Controls required for Level 2:**

| Control | Description |
|---|---|
| AI use case register | Written inventory of all deployed AI/agent systems, what they do, who owns them |
| AI owner designation | Named person accountable for each agent deployment |
| Pre-deployment review checklist | Formal sign-off before any agent reaches production users |
| Scope documentation | Written list of what the agent can and cannot do |
| Basic logging | All agent inputs and outputs logged with 90-day retention minimum |
| Escalation path | Documented process for users to escalate to a human |
| Incident response | Written process for responding to agent errors or harmful outputs |
| User disclosure | Users informed they are interacting with an AI agent |

**Minimum for most commercial deployments and internal enterprise tools.**

---

### Level 3 — Managed

**Controls required for Level 3 (all Level 2 controls plus):**

| Control | Description |
|---|---|
| Structured risk assessment | Per-deployment risk register: likelihood × impact for key failure modes |
| Monitoring with alerts | Automated alerts for error rate, escalation rate, anomalous outputs above defined thresholds |
| Bias and fairness check | Pre-deployment check for systematic errors affecting specific groups |
| Regular audit | Quarterly or annual review of agent behavior against policy |
| Third-party data processing agreements | DPAs with all vendors processing user data through the agent |
| Rollback capability | Documented procedure for disabling or rolling back the agent |
| HITL gate for high-stakes actions | Human approval required for actions above defined risk threshold |

**Required for regulated industries (finance, healthcare, legal, government) and customer-facing agents with material consequences.**

---

### Level 4 — Optimized

**Controls required for Level 4 (all Level 3 controls plus):**

| Control | Description |
|---|---|
| AI governance metrics dashboard | KPIs for governance health tracked and reviewed quarterly |
| Continuous improvement loop | Governance findings systematically fed back into agent improvement |
| External audit or certification | ISO 42001, SOC 2, or sector-specific certification |
| Regulatory engagement | Proactive engagement with relevant regulators; not just reactive compliance |
| Red team / adversarial testing | Scheduled adversarial testing of agent behavior |
| Supplier AI governance review | Assessment of AI governance practices of key vendors (model providers, data suppliers) |

**Required for high-stakes regulated market deployments (financial services AI advice, clinical AI tools, government AI systems).**

---

## Regulatory Framework Details

### EU AI Act — Key Requirements by Risk Tier

**Unacceptable risk (prohibited):** Social scoring, real-time biometric surveillance in public spaces, manipulation of vulnerable populations. No agentic AI product should be built in these categories.

**High-risk systems** (requires full compliance before deployment):
- Employment and HR: CV screening, performance monitoring, task allocation
- Credit and financial services: creditworthiness assessment
- Education: student assessment, admission decisions
- Access to essential services: benefits eligibility

**High-risk requirements:**
1. Conformity assessment (pre-deployment)
2. Technical documentation
3. Automatic logging of all decisions
4. Transparency to affected individuals
5. Human oversight mechanism
6. Registration in EU AI Act database
7. Post-market monitoring

**Limited risk systems** (transparency obligations only):
- Chatbots and conversational agents: must disclose AI identity to users
- Emotion recognition: must disclose to subjects
- AI-generated content: must label as AI-generated

**Minimal risk:** Most productivity agents, recommendation systems with no material consequences. No mandatory requirements, but voluntary codes of conduct are emerging.

---

### NIST AI Risk Management Framework

**Four functions:**

1. **Govern**: Establish policies, roles, and accountability for AI risk management
2. **Map**: Identify and categorize AI risks for each deployment context
3. **Measure**: Define metrics and methods to assess AI risks
4. **Manage**: Implement controls, monitor, and improve continuously

**Practical minimum for US federal procurement context:**
- Documented AI risk management policy (Govern)
- Risk assessment per deployment (Map)
- Defined metrics and evaluation methodology (Measure)
- Incident response and monitoring (Manage)

---

### HIPAA — Agent-Specific Requirements

When an agent accesses, processes, or generates Protected Health Information (PHI):

1. **Business Associate Agreement (BAA)**: Required with any vendor (including model provider) that processes PHI.
2. **Minimum necessary standard**: Agent should only access PHI necessary for the specific task.
3. **Access logging**: All PHI access must be logged with user identity, timestamp, and action.
4. **Breach notification**: If PHI is exposed due to agent error, HIPAA breach notification rules apply (60-day notification to affected individuals and HHS).
5. **De-identification**: If PHI can be de-identified before reaching the agent, this significantly reduces compliance burden.

**Practical implication:** Using any frontier model (Anthropic, OpenAI, Google) with PHI requires a BAA with that provider. Check current BAA availability before architectural decisions are finalized.

---

### SOC 2 Type II — Relevant Trust Service Criteria

For SaaS agentic AI products sold to enterprise customers:

- **Security**: Agent infrastructure must meet SOC 2 security criteria (access controls, encryption, vulnerability management)
- **Availability**: Agent must have defined SLAs and incident response
- **Confidentiality**: Customer data processed by the agent must be protected per confidentiality commitments
- **Privacy**: If processing personal data, privacy controls must be documented and audited

**Practical implication:** Enterprise customers will ask for SOC 2 Type II in procurement. Budget 6–12 months for first certification. Interim: share security questionnaire responses and point to model provider SOC 2.

---

## Production Failure Modes

### Failure Mode 1: Silent Failure

The agent produces incorrect outputs but users do not notice because there is no verification step. The error propagates downstream.

**Mitigation:** 
- Automated output quality monitoring (LLM-as-judge on sampled outputs)
- Business metric monitoring that would be affected by systematic errors (e.g., if the agent is routing tickets, monitor resolution time and escalation rate)
- Periodic human audit of a sampled output set

---

### Failure Mode 2: Prompt Injection

A malicious input causes the agent to take unintended actions, override its instructions, or leak sensitive information.

**Mitigation:**
- Input validation and sanitization before agent processing
- Principle of least privilege for tools (agent can only call tools and access data it needs for the current task)
- Output validation before agent actions are executed
- Never include sensitive credentials or data in the system prompt

---

### Failure Mode 3: Trust Overhang

Users over-trust the agent and stop verifying its outputs. The agent's error rate is acceptable in isolation but becomes unacceptable when applied at scale without oversight.

**Mitigation:**
- UX design that surfaces uncertainty and confidence levels
- Regular "trust calibration" communications to users: share real error rates
- Retain HITL gates for high-stakes actions even as the agent matures
- Avoid language in UI that implies higher reliability than is demonstrated

---

### Failure Mode 4: Scope Creep

The agent is used for tasks outside its designed scope — either by user initiative or by the agent generalizing beyond its intended domain.

**Mitigation:**
- System prompt explicitly scopes the agent's tasks and authorizes specific tools only
- Off-topic requests produce a clear refusal with a redirect ("I'm designed for X — for Y, please use [alternative]")
- Monitoring for out-of-scope tool calls or unexpected output patterns

---

### Failure Mode 5: Data Leakage

The agent exposes data from one user's context to another, or reveals sensitive system information to users.

**Mitigation:**
- Strict context isolation between user sessions
- No sensitive data in system prompts that could be extracted via prompt injection
- Tool call responses sanitized before inclusion in context
- Regular red team testing for data leakage vectors

---

## Adoption Anti-Patterns

### Anti-Pattern 1: Big Bang Launch

Deploying to all users simultaneously without a pilot phase. When failures occur (and they will), the impact is maximum and trust recovery is difficult.

**Alternative:** Land (pilot) → Expand (department) → Scale, with defined gate criteria between phases.

---

### Anti-Pattern 2: Skipping Change Management

Announcing the agent to users as "this will replace your current process" without explanation, training, or feedback channels. Users resist, work around it, or use it incorrectly.

**Alternative:** Frame as augmentation ("the agent handles the routine cases so you can focus on the complex ones"). Provide training, collect feedback, and show users how the agent improves based on their input.

---

### Anti-Pattern 3: Governance Theater

Creating governance documentation that no one reads, audit trails that no one reviews, and incident response plans that have never been tested.

**Alternative:** Start with minimal controls that are actually practiced. A Level 2 posture that is enforced is better than a Level 4 posture on paper. Run a tabletop incident response exercise before deploying to production.

---

### Anti-Pattern 4: Compliance-Driven Architecture

Letting compliance requirements drive the agent architecture to the point where the agent cannot do its job effectively. For example, logging requirements so strict that they add 2 seconds to every response.

**Alternative:** Involve compliance early to find solutions that meet requirements without degrading the user experience. Most compliance requirements can be met asynchronously (log to a queue, process after response).

---

### Anti-Pattern 5: No Human Escalation Path

Deploying an agent without a way for users to escalate to a human. Users who cannot escalate when they need to either lose trust in the system entirely or make poor decisions based on incorrect agent output.

**Alternative:** Every agent interaction that has material consequences must have a single-action escalation path that reaches a human within a defined SLA. Design this as a first-class feature, not an afterthought.
