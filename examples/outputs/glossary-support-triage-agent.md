# Glossary: Support Triage Agent

> Generated 2026-05-16 · Skill: agentic-ubiquitous-language · Plugin: agentic-ai-engineering

This glossary establishes the shared vocabulary for Support Triage Agent. Terms are defined once here and should be used consistently across all design documents, code, and team communication.

---

## Terms

### Triage

**Definition:** The act of classifying an inbound support ticket by category, severity, and required expertise level, and routing it to the appropriate handling queue or agent without resolving the ticket itself.

**Non-example:** Resolving a billing dispute is not triage — it is resolution. Asking a customer for more information is not triage — it is clarification.

**Project-specific usage:** In this system, triage is performed exclusively by the Triage Orchestrator agent. No worker agent performs triage. When engineers say "the agent triaged the ticket," they mean the Triage Orchestrator completed classification and routing.

---

### Routing Decision

**Definition:** A structured output produced by the Triage Orchestrator that specifies the destination queue, assigned priority, and recommended handling tier (Tier-1 self-service, Tier-2 specialist, Tier-3 engineering) for a given ticket.

**Non-example:** Forwarding a raw ticket to a queue without a priority or tier recommendation is not a routing decision — it is a queue transfer.

**Project-specific usage:** Routing decisions are logged as structured JSON in the audit trail. A routing decision is only final after HITL confirmation for high-severity tickets. Never refer to this as "sending to the team" — use "routing decision" with explicit tier and priority.

---

### Escalation

**Definition:** The act of upgrading a ticket from a lower handling tier to a higher one (e.g., Tier-1 to Tier-2, or Tier-2 to Tier-3) because the current tier cannot resolve the issue within its authority or competency boundary.

**Non-example:** Routing a new ticket directly to Tier-3 on arrival is not escalation — it is initial routing. Escalation only occurs when a ticket has already been assigned to a tier and cannot be resolved there.

**Project-specific usage:** Escalation always triggers a HITL confirmation gate when moving from Tier-2 to Tier-3. The Triage Orchestrator can recommend escalation but cannot execute it without human approval at this tier boundary.

---

### Confidence Score

**Definition:** A numeric value (0.0–1.0) produced by the Triage Orchestrator alongside each routing decision, representing the agent's assessed reliability of that decision given the available ticket context.

**Non-example:** A confidence score is not a probability that the ticket will be resolved successfully. It is not a customer satisfaction predictor.

**Project-specific usage:** Confidence below 0.7 automatically triggers the HITL escalation path. Confidence is logged with every routing decision and is used in weekly eval reviews to identify categories where the model needs more training data.

---

### Handoff Message

**Definition:** A structured summary produced by the Triage Orchestrator when escalating a ticket to Tier-2 or Tier-3, containing the ticket ID, classification, key extracted facts, recommended priority, and the agent's routing rationale.

**Non-example:** Simply forwarding the original ticket text is not a handoff message. A handoff message must include the agent's interpretation and rationale, not just the raw customer input.

**Project-specific usage:** Handoff messages are rendered in the support agent UI as a collapsible "Agent Summary" panel. The format is validated against the handoff message schema in `schemas/handoff-message.json`. If the handoff message is missing or malformed, the ticket is held in the Triage queue for manual review.

---

### Worker Agent

**Definition:** A specialized subagent within the Support Triage system that handles a specific category of tickets (Billing, Technical, Account, General Inquiry) and is invoked by the Triage Orchestrator after initial classification.

**Non-example:** The Triage Orchestrator is not a worker agent — it is the orchestrator. External CRM tools and ticketing APIs are not worker agents — they are tools.

**Project-specific usage:** Worker agents operate within a bounded context: they receive a pre-classified ticket and routing decision, and their sole responsibility is to enrich the handoff message with category-specific context. Worker agents do not re-classify tickets.

---

### Circuit Breaker

**Definition:** A safety mechanism on a tool integration that halts all further tool calls to a downstream system after a defined error threshold is reached, preventing cascading failures or runaway writes.

**Non-example:** A retry mechanism is not a circuit breaker — it continues attempting the operation. An alert is not a circuit breaker — it notifies but does not halt.

**Project-specific usage:** Circuit breakers are required on all write-capable tools (CRM write, ticket status update). The CRM circuit breaker threshold is: pause after 3 consecutive errors, max 5 writes per agent session. Circuit breaker state is logged and surfaced in the observability dashboard.

---

### HITL Gate

**Definition:** A mandatory pause in the agent's execution at which a human operator must confirm or override the agent's proposed action before the agent proceeds.

**Non-example:** An optional review step that the agent can bypass if no human responds within a timeout is not a HITL gate — it is a soft approval check.

**Project-specific usage:** HITL gates are hard stops — the agent does not proceed until a human acts. Two HITL gates are active: (1) Tier-3 escalation confirmation, (2) refund approval for amounts over $500. Gate timeout behavior: after 2 hours without a response, route to the manager queue (do not auto-proceed).

---

## Ambiguous Terms (Resolved)

The following terms had multiple competing meanings in the team before this glossary was established. The canonical definition above is the one to use going forward.

| Term | Previous conflicting meanings | Canonical choice | Reason |
|---|---|---|---|
| "triage" | (1) Classify only; (2) Classify and route; (3) Classify, route, and first-response | Classify and route (without resolving) | Matches the agent's actual responsibility boundary; avoids implying the agent handles resolution |
| "escalation" | (1) Any upward tier move; (2) Only emergency/P1 tickets; (3) Moving to human from agent | Any upward tier move (Tier-N to Tier-N+1) | Most precise; "moving to human" is a separate concept captured by HITL gate |
| "confidence" | (1) Model temperature; (2) Routing decision reliability score; (3) SLA confidence | Routing decision reliability score (0.0–1.0) | Avoids confusion with model parameters; matches the logged field name in the audit trail |
| "handoff" | (1) Agent-to-agent pass; (2) Agent-to-human transfer; (3) Shift change documentation | Agent-to-human transfer with structured context summary | This system has no agent-to-agent handoffs at the same tier; handoff always crosses the human boundary |

---

## Banned Terms

These terms are prohibited in this project because they are ambiguous, misleading, or overloaded. Use the canonical term instead.

| Banned term | Use instead | Why banned |
|---|---|---|
| "the bot" | Support Triage Agent | Implies a rule-based chatbot; obscures the orchestrator-workers architecture |
| "auto-resolve" | routing decision + worker agent enrichment | Implies the agent resolves tickets; it does not — it routes and enriches |
| "AI decision" | routing decision | "AI decision" is vague and non-auditable; routing decision has a defined schema and audit trail |
| "send to the team" | routing decision (with tier and priority) | Hides the structured nature of the output; prevents traceability |
| "smart routing" | triage | Marketing language; not precise enough for engineering discussions or incident reports |
| "failed" (for escalations) | escalated | Escalation is correct behavior, not failure; using "failed" creates confusion in incident reports |

---

*To extend this glossary, run `/agentic-ai-engineering:agentic-ubiquitous-language` and reference this file via `glossary_path` in `.agentic/config.yml`.*
