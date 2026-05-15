# Scenario: Terminology Alignment Before Architecture Design

## Trigger

> "We're starting a new agent project for automating customer escalation routing. Three engineers are on the team but we keep using 'agent', 'workflow', and 'pipeline' interchangeably. Before we design anything, can we align on vocabulary?"

## Skill: agentic-ubiquitous-language

### Inputs gathered

1. System: Customer escalation routing — classifies incoming support tickets and routes them to appropriate team queues
2. Contested terms identified by the user: "agent", "workflow", "pipeline", "tool"
3. Domain terms that overlap with agentic vocabulary: "ticket", "routing", "queue", "escalation"
4. No existing glossary; `glossary_path` not configured in `.agentic/config.yml`

### Step 2 — Candidate terms extracted

Standard agentic terms in use: agent, tool, pipeline, workflow, memory, session  
Domain terms with overlap: ticket (internal domain), routing (overloaded — both domain action and agent pattern), queue (infrastructure), escalation (domain term, also used loosely for agent retry behavior)

### Step 3 — Normalization against standard vocabulary

| Term | Team usage | Canonical | Resolution |
|---|---|---|---|
| agent | Used for any automated process including simple rules engine | LLM-driven system that perceives, reasons, acts across multiple steps | Conflict: rules engine is NOT an agent by this definition — label it "automation" |
| pipeline | Used interchangeably with workflow and agent | Pre-specified multi-step process (steps known in advance) | Accept canonical; distinguish from agent (dynamic steps) |
| tool | Used for both internal helpers and external API calls | Typed function with external effect, name, description, parameter schema | Extend: narrow to external-boundary calls only |
| workflow | No consistent definition | N/A | Define project-specifically |

### Step 4 — Project-specific terms defined

**Escalation Agent**  
Definition: The LLM-driven system that reads ticket content, classifies urgency, and routes to a team queue using tool calls to the CRM and routing API.  
Non-example: The rules-based pre-filter that rejects spam tickets before the agent sees them — that is the "pre-filter automation", not the escalation agent.

**Routing Tool**  
Definition: The tool the agent calls to assign a ticket to a specific team queue. Has a typed interface: `route_ticket(ticket_id, team_id, priority)`.  
Non-example: The agent's internal decision about which team to route to — that is the agent's reasoning, not the routing tool.

**Ticket Session**  
Definition: One agent execution bounded by a single incoming ticket — begins when the ticket is received, ends when it is routed or escalated to a human.  
Non-example: A multi-ticket batch job — that is a scheduled run, not a session.

### Step 5 — Ambiguity flags

**Overload: "escalation"**  
In this domain: a ticket flagged for human review.  
In agentic vocabulary: the agent invoking a higher-authority agent or human.  
Resolution: Always qualify — use "ticket escalation" for the domain concept and "agent escalation" for the agentic pattern. Do not use "escalation" unqualified.

### Glossary artifact written

`docs/agentic-glossary.md` (default path; `glossary_path` not configured)

**Terms defined:** 8 (4 standard normalized, 3 project-specific, 1 disambiguation rule)  
**Flags:** 1 unresolved overload ("escalation") resolved with qualification rule

### User message

```
Glossary written to docs/agentic-glossary.md.

8 terms defined. One important disambiguation:
- "escalation" means different things in your domain vs. agentic AI. 
  Resolved with a qualification rule: use "ticket escalation" and 
  "agent escalation" rather than "escalation" unqualified.

The rules-based pre-filter is NOT an agent by the canonical definition 
— it should be called "pre-filter automation" to keep the team's usage
consistent.

Recommended next step: /agentic-plan to design the escalation agent
architecture with this shared vocabulary in place.
```
