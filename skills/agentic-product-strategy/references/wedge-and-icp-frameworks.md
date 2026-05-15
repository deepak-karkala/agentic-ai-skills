# Wedge and ICP Frameworks

Reference for the `agentic-product-strategy` skill. Contains full wedge scoring criteria, ICP definition patterns, architecture tier progression, and positioning anti-patterns.

---

## Wedge Scoring Rubric

Seven dimensions, each scored 1–3. Total: 21 points.

### Dimension 1 — Verifiability

Can the buyer measure whether the agent is working? Is success observable within a reasonable time horizon?

| Score | Meaning |
|---|---|
| 3 | Success is immediately measurable with metrics the buyer already tracks (time saved, error rate, throughput) |
| 2 | Success is measurable but requires new instrumentation or a 30–90 day observation period |
| 1 | Success is subjective or unmeasurable within a normal sales cycle |

**Why this matters:** Buyers who cannot verify success cannot justify renewal. Unverifiable value is invisible during procurement cycles. Verifiability also enables the seller to detect and fix failures before churn.

---

### Dimension 2 — Reversibility

If the buyer tries the agent and is unhappy, how easy is it to revert to the prior state?

| Score | Meaning |
|---|---|
| 3 | Fully reversible: existing systems unchanged, agent can be turned off with no workflow disruption |
| 2 | Partially reversible: some workflow adjustment needed to revert, but prior state is mostly recoverable |
| 1 | Difficult to reverse: the agent is embedded in critical workflows in a way that makes removal costly or disruptive |

**Why this matters:** Reversibility lowers adoption risk for the buyer, which reduces sales friction. Paradoxically, high reversibility at entry (score 3) often leads to high switching costs after adoption as context and workflow integration accumulate — this is the design intent.

---

### Dimension 3 — Workflow Criticality

How central is this workflow to the buyer's daily operations?

| Score | Meaning |
|---|---|
| 3 | Core workflow: blocking this workflow stops revenue or causes immediate operational pain |
| 2 | Important but not critical: delays cause friction but the business can absorb them |
| 1 | Peripheral: the workflow is nice-to-have or low-frequency |

**Guidance:** Critical workflows drive urgency and justify premium pricing. Peripheral workflows are hard to monetize and easy to displace. Avoid peripheral wedges for initial market entry — they will not generate the champion ROI needed for expansion.

---

### Dimension 4 — Data Advantage

Does the agent accumulate proprietary data that makes it more valuable over time?

| Score | Meaning |
|---|---|
| 3 | Agent ingests org-specific data (SOPs, communications, transaction history) that creates a unique context advantage — competitors would need to replicate months of data ingestion to match |
| 2 | Agent learns from some org-specific feedback signals, but the advantage is modest and replicable within weeks |
| 1 | Agent uses only public or generic data — no proprietary context accumulates |

---

### Dimension 5 — Switching Cost

How costly is it for the buyer to switch to a competitor after adoption?

| Score | Meaning |
|---|---|
| 3 | High switching cost: the agent is embedded in multiple workflows, context is stored in the product, and switching requires retraining users and rebuilding integrations |
| 2 | Moderate switching cost: replacing the agent requires effort but is feasible within a sprint cycle |
| 1 | Low switching cost: the agent is a thin layer and another product could be dropped in with minimal migration |

---

### Dimension 6 — Competitive Differentiation

How defensible is this wedge against current and future competitors (including the model provider)?

| Score | Meaning |
|---|---|
| 3 | Strong differentiation: unique domain knowledge, proprietary integrations, or expert SOPs that are not reproducible without significant investment |
| 2 | Moderate differentiation: the product has a head start or specific integrations, but competitors could catch up in 6–12 months |
| 1 | Weak differentiation: the wedge could be replicated by a well-funded competitor (or the model provider) in a short sprint |

---

### Dimension 7 — Expansion Path

Does winning this wedge open additional workflows or customer segments?

| Score | Meaning |
|---|---|
| 3 | Strong expansion: the wedge creates a natural pathway to adjacent workflows, departments, or use cases within the same buyer |
| 2 | Limited expansion: some adjacent workflows exist but require significant new development or a different buyer |
| 1 | Dead end: winning the wedge does not open further expansion; the product remains a point solution |

---

## ICP Definition Patterns

### Level 1: Role

Name the job function, not the company size. The most actionable ICPs are:
- Specific enough to identify a LinkedIn search profile
- Experiencing the target workflow daily or weekly (not occasionally)
- With authority to evaluate or advocate for the tool, even if not the budget holder

**Strong ICP role examples:**
- "Revenue Operations Analyst at a B2B SaaS company (50–500 employees)"
- "AP Supervisor at a manufacturing company with >100 vendors"
- "Clinical Documentation Specialist at a community hospital"

**Weak ICP role examples:**
- "Business user" (too broad)
- "Enterprise buyer" (a title, not a role)
- "Any knowledge worker" (not an ICP — it's a market)

---

### Level 2: Workflow

Name the bounded sequence of tasks, not the department or outcome. The workflow is the unit of value delivery.

**Strong ICP workflow examples:**
- "Receiving a vendor invoice, extracting fields, matching to a PO, flagging discrepancies, and routing for approval"
- "Reviewing a support ticket, checking account history, drafting a resolution, and escalating if needed"
- "Reading a clinical note, extracting diagnoses and medications, and populating the structured EHR fields"

**Weak ICP workflow examples:**
- "Automate their job" (not a workflow — a goal)
- "Improve productivity" (an outcome, not a workflow)
- "Handle customer communications" (too broad)

---

### Level 3: System

Name the specific tools already in use. The agent must integrate into this stack, not replace it.

**Example:**
- Role: AP Supervisor
- Workflow: Invoice matching and approval routing
- System: SAP S/4HANA + Outlook + proprietary vendor portal

**Integration insight:** Buyers with established enterprise systems (SAP, Salesforce, Workday) have higher switching costs for those systems, which means an agent that integrates deeply has higher retention than one that requires workflow migration.

---

## Product Architecture Tier Progression

### Tier 1 → Tier 2 Upgrade

Moving from thin wrapper to workflow-integrated requires:
1. Real tool integrations — the agent calls APIs and reads/writes real data
2. Workflow-specific prompting — system prompt encodes the specific workflow, not just generic instructions
3. Persistent context — agent remembers org-specific preferences, past decisions, user patterns

**Minimum viable Tier 2:** Agent + 2 real system integrations + workflow-specific system prompt.

---

### Tier 2 → Tier 3 Upgrade

Moving from workflow-integrated to domain-specialized requires:
1. Expert knowledge capture — SOPs, heuristics, and edge-case handling from domain experts encoded in prompts and guardrails
2. Domain-specific eval — golden fixtures, labeled examples, and graders that reflect expert judgment (not just generic accuracy)
3. Proprietary fine-tuning or RAG — domain documents indexed and retrievable; possibly fine-tuned on domain-specific decision patterns

**Timeline:** Tier 3 typically requires 6–18 months of production data and expert collaboration.

---

### Tier 3 → Tier 4 Upgrade

Moving to outcome-contracted requires:
1. Mature eval — end-to-end success rate measurable and demonstrably above human baseline
2. Business model alignment — pricing model must shift from per-seat or per-usage to per-outcome
3. Trust infrastructure — buyers need audit logs, approval gates, and rollback capability before accepting outcome-based contracts

---

## Positioning Anti-Patterns

### The Thin-Wrapper Trap

Building a product that is only a prompt + model + UI with no proprietary logic, integration, or data advantage. Signs:
- Any engineer could build a comparable prototype in a weekend
- The product provides no value beyond what the user gets from direct model access
- There is no differentiation from a model provider's first-party product

**Escape:** Add one real integration and one domain-specific capability within the first quarter.

---

### The Horizontal Overhang

Targeting "all knowledge workers" or "all companies" without a specific wedge. Signs:
- The product has no named ICP
- Marketing describes the product as generally useful, not specifically valuable
- The team cannot name a specific workflow that the product owns

**Escape:** Pick the workflow where the product is most differentiated and own it completely before expanding.

---

### The Autonomy Oversell

Positioning the product as "fully autonomous" before eval data supports it. Signs:
- Product marketing claims 90%+ automation rate without published evals
- No HITL mechanism exists for errors
- The customer success team is absorbing errors manually without reporting them

**Escape:** Position as "supervised autonomous" or "AI-assisted" until eval confirms the autonomy claim.

---

## GTM Motion Details

### Land (PLG) — Design Principles

1. **Time to value under 30 minutes**: The user gets a meaningful result without a sales call, onboarding, or training.
2. **Self-service trial**: Free tier or freemium that demonstrates core value on real user data.
3. **Viral signal**: The agent's output is visible to others (shared reports, team notifications, approval workflows), creating organic spread.
4. **Usage-based pricing**: Pay-as-you-go pricing that aligns cost to value realized, removing the "we're paying even when we don't use it" objection.

### Expand (Enterprise) — Design Principles

1. **Champion + budget authority**: The PLG user becomes a champion who can escalate to a decision-maker.
2. **Team features**: Multi-user support, admin controls, shared context, audit logs — features that make the product more valuable as more team members use it.
3. **Integration depth**: Enterprise buyers require SSO, SCIM provisioning, SLA guarantees, and compliance docs.
4. **ROI reporting**: Quantified business impact (hours saved, errors reduced, throughput increased) that justifies the enterprise contract.

### Scale (Regulated) — Design Principles

1. **Compliance posture**: EU AI Act, HIPAA, SOC 2, ISO 42001 — specific to the industry. Budget 3–6 months for certification.
2. **HITL by default**: Regulated buyers require human approval for decisions above a risk threshold.
3. **Audit trail**: Full logging of agent decisions, inputs, and outputs with retention policies.
4. **Reference customer**: A named, referenceable regulated customer reduces procurement risk for subsequent buyers.
