---
name: agentic-product-strategy
description: >
  Defines the product strategy for an agentic AI product or feature. Scores
  the market entry wedge against seven dimensions, defines the ICP (Ideal
  Customer Profile) as role + workflow + system, classifies the product
  architecture tier, selects the GTM motion (PLG → enterprise → regulated),
  and identifies which moat layers to prioritize at a strategic level (not
  quantified depth scoring — use agentic-economics-and-moats for that). Use when deciding where and how
  to enter the market with an agent product, when positioning an agent system
  for a specific customer segment, when assessing whether the product
  architecture is defensible, or when planning the go-to-market sequence.
  Trigger phrases: "where should we enter the market with this agent",
  "define our ICP for this agent product", "is our product architecture
  defensible", "what's our wedge for this agentic AI product", "how should
  we position this agent for enterprise vs SMB", "what GTM motion fits this
  agent product", "are we building a thin wrapper or a defensible product",
  "help us define product strategy for our agent".
  Do not use for evaluating whether a specific workflow is agent-shaped (use
  agentic-opportunity-framing), for architecture design of the agent system
  (use agentic-system-design), or for economics and moat depth analysis in
  detail (use agentic-economics-and-moats).
allowed-tools:
  - Read
  - Write
metadata:
  category: product-strategy
  version: "0.1.0"
---

# Agentic Product Strategy

Product positioning skill. Defines market entry wedge, ICP, architecture tier, and GTM motion for an agentic AI product. Produces a structured strategy document that positions the product defensibly and sequences the go-to-market approach.

## When to Use

**Use when:**
- Deciding where and how to enter the market with an agent product
- Positioning an agent capability for a specific customer segment
- Assessing whether a product architecture will be defensible over time
- Planning the go-to-market sequence (PLG first? Direct enterprise? Regulated market?)
- Deciding between horizontal (many verticals) and vertical (one industry deeply) strategies

**Do not use when:**
- The question is whether to build an agent at all → use `agentic-opportunity-framing`
- The question is about the agent's technical architecture → use `agentic-system-design`
- The question is specifically about unit economics or moat depth → use `agentic-economics-and-moats`
- The request is for a general business plan or market analysis outside agentic AI

## Workflow

### Step 1 — Gather context

Ask the user:
1. What does this agent product do, and who is the primary user?
2. What problem does it solve, and what is the current alternative (manual, rules-based, competitor)?
3. What customer segment are you targeting first — SMB, mid-market, enterprise, regulated industry?
4. Do you have an existing user base or are you entering a new market?
5. What is the business model — usage-based, seat-based, outcome-based?

If the user has already provided context, use it. Do not re-ask for information already in the conversation.

---

### Step 2 — Define the ICP

Define the Ideal Customer Profile at three levels of specificity:

1. **Role**: Who is the primary user? Not just "a company" — the specific job function that gains the most from this agent. (e.g., "Account Executive", "AP Clerk", "Clinical Pharmacist", "Legal Ops Manager")
2. **Workflow**: What specific workflow does this agent change? Not "their job" — the bounded sequence of tasks where the agent delivers value. (e.g., "invoice matching and approval routing", "drafting first-response emails to inbound tickets")
3. **System**: What systems does this ICP already use for this workflow? The agent must integrate into their existing stack. (e.g., "Salesforce + email + internal CRM", "SAP + Outlook + vendor portal")

**ICP validation questions:**
- Does this ICP experience the problem frequently enough to justify the change management cost of adopting an AI agent?
- Does this ICP have the budget authority for the price point you need?
- Can this ICP evaluate success in a 30–90 day pilot?
- Does this ICP operate in a regulatory environment that requires specific compliance considerations?

For detailed ICP positioning patterns, see [Wedge and ICP Frameworks](references/wedge-and-icp-frameworks.md).

---

### Step 3 — Score the market entry wedge

Score the proposed wedge against 7 dimensions. Each dimension is scored 1–3. Total possible: 21 points.

See [Wedge and ICP Frameworks](references/wedge-and-icp-frameworks.md) for full scoring criteria.

| # | Dimension | Score (1–3) | Notes |
|---|---|---|---|
| 1 | Verifiability: Is success measurable by the buyer? | | |
| 2 | Reversibility: Can the buyer roll back if unhappy? | | |
| 3 | Workflow criticality: How central is this workflow to the buyer's operations? | | |
| 4 | Data advantage: Does the agent get access to proprietary data that improves with use? | | |
| 5 | Switching cost: How costly is it for the buyer to switch away after adoption? | | |
| 6 | Competitive differentiation: Is this wedge defensible vs. alternatives? | | |
| 7 | Expansion path: Does winning this wedge open additional workflows? | | |

**Interpretation:**
- 17–21: Strong wedge. Proceed with confidence.
- 12–16: Viable wedge. Identify the lowest-scoring dimensions — they are the risks to mitigate.
- 7–11: Weak wedge. Re-examine ICP or workflow choice before committing.

**Critical dimensions:** Verifiability and reversibility are the two most important. A score of 1 on either is a significant risk regardless of total score. Flag explicitly if either scores 1.

---

### Step 4 — Classify the product architecture tier

Assess where this product sits in the agentic AI architecture spectrum:

| Tier | Description | Risk |
|---|---|---|
| **Thin wrapper** | Prompt + model + basic UI, no proprietary workflow logic or data integration | High: easily replicated; commoditized by model provider |
| **Workflow-integrated** | Agent embedded in existing workflows, tools wired to real systems, context from real data | Medium: integration moat begins here |
| **Domain-specialized** | Agent fine-tuned or prompt-engineered on domain-specific SOPs, captures expert judgment | Low: harder to replicate |
| **Outcome-contracted** | Product priced on outcomes delivered; agent owns an end-to-end workflow | Low: deep lock-in; requires mature eval |

**Thin-wrapper test:** Ask: "If the model provider released a version of this product tomorrow, would our customers switch?" If yes, you are in thin-wrapper territory.

**Recommendation:** Start at Workflow-integrated (Tier 2) at minimum. A product that is solely Tier 1 has no durable differentiation.

For architecture tier patterns and progression paths, see [Wedge and ICP Frameworks](references/wedge-and-icp-frameworks.md).

---

### Step 5 — Select GTM motion

Match the GTM motion to the ICP and product architecture tier:

| Motion | Best for | When to use |
|---|---|---|
| **Land (PLG)** | Individual users or small teams; self-serve onboarding possible; value demonstrable in a free trial or freemium tier | Starting motion for most agent products; optimizes for time-to-value |
| **Expand (enterprise)** | Teams and departments once PLG has proven value; requires champion + budget authority | After Land proves ROI; add enterprise features (SSO, audit logs, admin controls) |
| **Scale (regulated)** | Regulated industries (finance, healthcare, legal); requires compliance posture, HITL guardrails, audit trails | Third motion; enter only after Expand motion validates unit economics |

**Sequencing rule:** Land first, Expand second, Scale third — unless the target buyer cannot self-serve (e.g., enterprise-only regulated market). In that case, start with Expand but budget longer sales cycles.

**PLG fit test:** Can a user get value in under 30 minutes without a sales call? If yes, PLG is viable. If no, direct sales or a product-led sales (PLS) hybrid is needed.

---

### Step 6 — Identify moat layers to prioritize

This step identifies *which* moat layers are accessible and worth investing in given the ICP, wedge, and architecture tier. It does not score moat depth or model the data flywheel — that is the domain of `agentic-economics-and-moats`.

For each of the five moat layers, state whether it is: immediately accessible, requires 6–12 months of investment, or not accessible given the current product and ICP.

| Moat layer | Description | How to access |
|---|---|---|
| **Workflow position** | Agent is embedded in the critical path of a daily workflow | Ensure agent owns a step — not just assists |
| **Context advantage** | Agent accumulates proprietary context that improves with use | Store and reuse user/org-specific context; build memory architecture |
| **Domain SOP capture** | Agent encodes expert SOPs generalist models lack | Interview domain experts; encode judgment in prompts and guardrails |
| **Evaluation advantage** | Team has labeled data and eval infrastructure competitors lack | Invest in eval early; treat labeled failures as proprietary data |
| **Habit and spread** | Agent is a daily habit; spreads within orgs organically | Design for daily engagement; build team-level features |

**Output of this step:** A prioritized list of 2–3 moat layers to target in the first 12 months, with a one-line rationale for each. Not a depth score — that belongs in `agentic-economics-and-moats`.

**Boundary:** If the user asks "how deep is our moat?" or "score our moat across all layers," stop here and route to `agentic-economics-and-moats`. This step answers "which layers should we invest in?" not "how strong are we today?".

---

### Step 7 — Write the strategy document

Write a structured product strategy document to:
- `artifact_output_path/product-strategy-<name>.md` if `artifact_output_path` is configured in `.agentic/config.yml`
- Otherwise: `.agentic/artifacts/product-strategy-<name>.md`

Use the format:

```markdown
# Product Strategy: <Product Name>

## ICP Definition
**Role:** [specific job function]
**Workflow:** [specific workflow]
**System:** [existing systems in use]
**Validation notes:** [ICP strength/risks]

## Wedge Score
[Score table with per-dimension notes]
Overall: N/21 — [Strong / Viable / Weak] wedge
Critical dimension flags: [any dimension scoring 1, especially verifiability/reversibility]

## Product Architecture Tier
[Tier classification with rationale]
[Thin-wrapper risk assessment if applicable]

## GTM Motion
[Primary motion with rationale]
[Sequencing plan: Land → Expand → Scale]
[PLG fit assessment]

## Moat-Building Plan
[2–3 moat layers to prioritize in first 12 months]
[Specific tactics per layer]

## Risks and Open Questions
[Top 2–3 strategy risks]
[Decisions that need to be made before committing]

## Recommended Next Steps
[Ordered list: what to do first]
```

---

### Step 8 — Report

After writing the document:
1. State the file path.
2. State the wedge score (N/21) and the GTM motion selected.
3. Flag any critical dimension risks (verifiability, reversibility scored 1).
4. Flag if the product is in thin-wrapper territory.
5. Suggest next steps: `agentic-system-design` for technical architecture, `agentic-economics-and-moats` for unit economics, or `agentic-opportunity-framing` if the ICP or workflow hasn't been validated yet.

## Output Contract

- **Primary output:** Strategy Markdown document at `artifact_output_path/product-strategy-<name>.md` or `.agentic/artifacts/product-strategy-<name>.md`
- **In-conversation summary:** ICP, wedge score, GTM motion, critical risks, next steps
- **Does not produce:** agent architecture, code, eval plans, financial models

## Scope Boundaries

This skill defines product positioning. It does not design the agent system or model the unit economics in detail. If the strategy reveals a need for deeper economics analysis (pricing model, cost structure, moat depth), route to `agentic-economics-and-moats`. If the technical architecture needs to be defined, route to `agentic-system-design`.
