---
name: human-in-the-loop-patterns
description: >
  Designs the human-in-the-loop architecture for an agentic AI system.
  Covers the five HITL model selection (fully automated, human-on-standby,
  human-in-the-loop, human-over-the-loop, human-as-teacher) by risk tier
  and action reversibility; approval gate design including trigger
  conditions, validation criteria, and what constitutes approval; bounded
  autonomy contract definition; HITL escalation ladder design; feedback
  loop design for how human approvals feed back into eval and trust
  calibration; and HITL at scale including approval bottleneck patterns
  and batch-approval strategies.
  Goes deeper than the HITL posture section in deployment-readiness,
  which provides a checklist item. This skill designs the full HITL
  mechanism.
  Use when designing the oversight architecture for a new agent, when an
  existing agent has too many or too few approval gates and throughput or
  safety is suffering, when designing the escalation ladder for a
  multi-agent system, when building a bounded autonomy contract for a
  high-stakes agent deployment, or when HITL gates are creating
  bottlenecks at scale.
  Trigger phrases: "design the HITL layer for this agent", "what approval
  gates do we need", "how do we keep humans in the loop", "the agent
  needs human oversight for high-risk actions", "escalation path design",
  "bounded autonomy contract", "human approval workflow", "HITL model
  selection", "oversight without creating a bottleneck",
  "when should the agent ask for human approval".
  Do not use for governance policy and org-level trust frameworks (use
  agentic-governance-and-adoption), for how HITL gates are presented in
  the user interface (use agent-ui-patterns), or for the overall deployment
  gate checklist that includes HITL as one item (use deployment-readiness).
allowed-tools:
  - Read
  - Write
metadata:
  category: technical
  version: "0.1.0"
---

# Human-in-the-Loop Patterns

HITL architecture skill. Selects the appropriate oversight model, designs approval gates, defines bounded autonomy contracts, and builds the feedback loop connecting human decisions back to agent improvement. Produces a concrete HITL design.

## When to Use

**Use when:**
- Designing the oversight architecture for a new agent system
- An existing agent has too many approval gates (throughput bottleneck) or too few (safety risk)
- Designing the escalation ladder for a multi-agent or tiered-autonomy system
- Building a bounded autonomy contract for a regulated or high-stakes deployment
- HITL approval gates are creating throughput problems at scale

**Do not use when:**
- The question is about org-level trust, policy, and stakeholder governance → use `agentic-governance-and-adoption`
- The question is about how approval gates are presented to users in the UI → use `agent-ui-patterns`
- The question is about the overall deployment launch gate that includes HITL as one checklist item → use `deployment-readiness`

## Workflow

### Step 1 — Gather context

Ask the user:
1. What is the agent's task domain? (Customer service, code execution, content generation, financial operations, healthcare, etc.)
2. What are the actions the agent can take? List them, with any existing sense of which are high-risk.
3. What are the consequences of a wrong action? (Reversible vs. irreversible; customer-facing vs. internal; financial, reputational, or safety impact)
4. What is the expected throughput? (How many tasks per hour? Per day?)
5. How many human reviewers are available and what is their bandwidth?
6. Is this a regulatory or compliance context? Any specific oversight requirements?

---

### Step 2 — Select the HITL model

Match the agent's risk profile and deployment context to the appropriate HITL model.

**Five HITL models:**

**Model 1 — Fully Automated**
The agent operates autonomously with no human in the approval path. Humans review aggregate metrics and logs asynchronously.
- When to use: low-risk, fully reversible actions; high throughput requirements; well-tested system with strong eval coverage; consequences of error are minor and quickly correctable
- Examples: internal content tagging, document classification, low-stakes recommendation filtering
- Risk: appropriate only when the action blast radius is bounded and monitored

**Model 2 — Human-on-Standby**
The agent operates autonomously but can escalate to a human reviewer on trigger conditions. Human reviewer is alerted and must respond within a defined SLA.
- When to use: medium-risk with well-defined edge cases; most actions are safe but a small class of inputs requires oversight; throughput would be destroyed by per-action review
- Examples: support triage (autonomous for Tier-1, standby for Tier-3), content moderation (autonomous for clear categories, standby for borderline)
- Design requirement: clear escalation trigger definition; SLA for human response; fallback if no human response within SLA

**Model 3 — Human-in-the-Loop**
The agent pauses at a defined gate and waits for explicit human approval before proceeding. The gate is a hard stop.
- When to use: high-risk or irreversible actions; regulated workflows; low-trust new deployment; customer-facing outputs in sensitive domains
- Examples: financial approvals, external communications, medical record updates, code deployment
- Design requirement: the gate must define what the human is approving and what constitutes approval. A gate without a clear approval criteria is theater.

**Model 4 — Human-over-the-Loop**
Humans review batches of completed agent actions after the fact, not before. Patterns of errors are caught via review; individual errors are accepted as a cost of speed.
- When to use: audit compliance requirements without throughput constraints; high-volume, medium-risk workflows; error consequences are manageable but records must exist
- Examples: expense report processing, routine data entry, content translation
- Design requirement: structured audit trail for all agent actions; review cadence defined; escalation path for patterns detected in review

**Model 5 — Human-as-Teacher**
The human's role is to improve the agent over time — reviewing flagged outputs, providing corrections that feed back into the eval dataset, and calibrating the agent's confidence thresholds. The human is not in the per-action path.
- When to use: mature deployment with strong baseline performance; improvement velocity matters more than per-action oversight; team capacity is better spent on systematic improvement than per-action review
- Examples: production agent after 3+ months of operation; deployed system with strong eval coverage being continuously improved

**Selection matrix:**

| If action is... | And throughput is... | Recommended model |
|---|---|---|
| Irreversible, customer-facing | Any | Model 3 (HITL) for that action |
| Reversible, well-tested | High | Model 1 (Fully Automated) |
| Reversible, some edge cases | Medium | Model 2 (Standby) |
| Any, audit required | Any | Model 4 (Over-the-Loop) for compliance |
| Mature system, improvement focus | Any | Model 5 (Teacher) |

A single agent can use different models for different action types — not every action must be governed by the same model.

---

### Step 3 — Design approval gates

For each gate in Model 3 (HITL), design the following:

**Gate components:**

1. **Trigger condition:** What causes the gate to fire? Be specific.
   - Bad: "when the action is risky"
   - Good: "when ticket_severity = High AND routing_tier = Tier-3 AND confidence < 0.85"

2. **Gate content:** What does the human reviewer see? They must have enough information to make an informed decision — not just the raw output.
   - Required: agent's proposed action, the reasoning behind it, the context used, and the alternatives considered
   - Bad: "Do you approve this routing?" with no context
   - Good: "Agent proposes: route ticket #8841 (billing, high severity) to Tier-3 Engineering. Reason: 'subscription API error' matches known engineering issue pattern (confidence: 0.79). Alternative: Tier-2 Billing (confidence: 0.64). Approve?"

3. **Approval definition:** What constitutes approval?
   - One-click approve/reject with mandatory rejection reason
   - Structured override: "approve as-is" vs "approve with modification" vs "reject with reason"
   - Timeout behavior: if no response in [N] hours, what happens? (Do not default to auto-approve for high-risk actions — default to escalate or hold)

4. **Audit record:** What is logged at gate completion?
   - Reviewer identity, timestamp, decision (approve/reject/modify), modification if any, time-to-decision

---

### Step 4 — Define the bounded autonomy contract

A bounded autonomy contract is an explicit statement of what the agent is and is not authorized to do without human approval. It removes ambiguity about where oversight is required.

**Bounded autonomy contract format:**

```markdown
## Bounded Autonomy Contract: <Agent Name>

### Autonomy level: <L1 / L2 / L3>

### Actions the agent may take autonomously
[Explicit list — anything not on this list requires approval]

### Actions that require human approval before execution
[Explicit list with gate trigger conditions]

### Actions the agent is never permitted to take
[Hard prohibitions — not gated, not allowed under any condition]

### Confidence threshold for autonomous action
[Below this threshold, the agent must escalate regardless of action type]

### Session budget
[Maximum irreversible actions per session without human review]
```

---

### Step 5 — Design the escalation ladder

For multi-tier or multi-agent systems, define the escalation path:

1. **Escalation tiers:** List the tiers in order (e.g., Tier-1 autonomous → Tier-2 human agent → Tier-3 specialist → Manager)
2. **Escalation triggers per tier:** What causes escalation from each tier to the next? (Confidence threshold, action category, SLA breach, explicit user request)
3. **Context transfer:** When escalating, what context is passed? (The full agent session? A summary? The specific decision point that triggered escalation?)
4. **SLA at each tier:** How long does each tier have to respond before auto-escalating to the next tier?
5. **Fallback at the top of the ladder:** If no tier can handle the request within SLA, what happens? (Hold, decline, route to emergency contact)

---

### Step 6 — Design the feedback loop

Human approval decisions are valuable training signal. Design how they feed back into agent improvement:

1. **Capture every override:** When a human modifies or rejects an agent decision, record: the original decision, the human's correction, the context at decision time
2. **Route to eval dataset:** Overridden decisions are candidates for the eval golden dataset. A human correction is a labeled example of what the right decision was.
3. **Trust calibration:** Track approval rate by action category and confidence band. If the human approves 95% of decisions in category X at confidence > 0.8, consider raising the autonomous threshold for that category.
4. **Cadence:** Define how often the feedback loop is reviewed (weekly trust calibration review, monthly eval dataset refresh from overrides)

---

### Step 7 — Address HITL at scale

When throughput requirements exceed reviewer bandwidth:

**Anti-patterns to avoid:**
- Auto-approve after timeout (risk: high-volume attack surface; reviewers rubber-stamp)
- Gate every action regardless of risk (bottleneck: reviewers become fatigued; quality degrades)

**Recommended patterns:**
- **Risk-tiered routing:** Route only the highest-risk actions to human review; use Model 2 (Standby) for medium-risk; Model 1 for low-risk
- **Batch approval for identical actions:** If 50 tickets all match the same routing decision with >0.9 confidence, batch them for a single reviewer decision ("approve all matching this pattern?")
- **Async review for non-blocking actions:** Post-execution review (Model 4) for reversible actions; reserve pre-execution review for irreversible
- **Reviewer bandwidth monitoring:** Track review queue depth and time-to-decision. If queue depth grows, the autonomy threshold needs to be raised or more reviewers added — do not let the queue grow unchecked.

---

### Step 8 — Write the HITL design

Write a structured HITL design to:
- `artifact_output_path/hitl-<agent-name>.md` if `artifact_output_path` is configured in `.agentic/config.yml`
- Otherwise: `.agentic/artifacts/hitl-<agent-name>.md`

Format:

```markdown
# HITL Design: <Agent Name>

## Selected HITL Models
[Table: action type | HITL model | rationale]

## Approval Gates
[Per gate: trigger | content shown to reviewer | approval definition | timeout | audit record]

## Bounded Autonomy Contract
[What the agent may/must/never do without approval]

## Escalation Ladder
[Tiers, triggers, context transfer, SLA]

## Feedback Loop
[Override capture, eval routing, trust calibration cadence]

## Scale Considerations
[Anti-patterns avoided; patterns applied; reviewer bandwidth estimate]
```

---

### Step 9 — Report

After writing the design:
1. State the file path.
2. State the selected HITL model(s) and the rationale.
3. Flag any action that currently lacks a gate but requires one given the risk tier.
4. Flag any throughput bottleneck risk in the current design.
5. Suggest next steps: `agent-ui-patterns` to design how approval gates are presented in the user interface, `deployment-readiness` to incorporate the HITL design into the launch gate checklist.

## Output Contract

- **Primary output:** HITL design at `artifact_output_path/hitl-<agent-name>.md` or `.agentic/artifacts/hitl-<agent-name>.md`
- **In-conversation summary:** selected HITL models, approval gate design, bounded autonomy contract, escalation ladder, scale considerations
- **Does not produce:** governance policy, UI design for approval gates, deployment gate checklists

## Scope Boundaries

This skill designs the HITL mechanism — the technical and design architecture of oversight. It does not design the governance policy that determines what risk level requires what oversight (use `agentic-governance-and-adoption`), the user interface that presents approval gates to reviewers (use `agent-ui-patterns`), or the deployment checklist that includes HITL posture as one item (use `deployment-readiness`). The HITL posture section in `deployment-readiness` is a checklist confirmation; this skill is where the posture itself is designed.
