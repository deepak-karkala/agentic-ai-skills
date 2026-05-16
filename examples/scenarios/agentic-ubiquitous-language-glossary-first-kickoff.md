# Scenario: Glossary-First Architecture Kickoff

## Trigger

> "Before we start designing the architecture, I want to get everyone on the same page about terminology. We keep saying 'agent', 'tool', 'workflow', and 'task' interchangeably and it's causing confusion in our design reviews."

## Skill: agentic-ubiquitous-language → agentic-system-design

Multi-skill scenario. Ubiquitous language runs first to align vocabulary, then system design uses the glossary as a foundation.

---

### Phase 1: agentic-ubiquitous-language

#### Inputs gathered

1. Team: 6 engineers building a claims processing agent
2. Current terminology conflicts:
   - "agent" used for both the full system and individual LLM calls
   - "workflow" used for both the user's business process and the agent's internal control flow
   - "task" used for both a single tool call and an end-to-end job
   - "tool" used for both an LLM tool definition and an external API call
3. Existing glossary: None
4. Downstream consumers: Architecture docs, code comments, sprint tickets, user-facing UI

#### Terms defined

**Agent:**
- Definition: An autonomous software component that perceives its environment, reasons about a goal, and takes actions via tools to achieve it — operating over one or more reasoning steps.
- Non-example: A deterministic function that calls an LLM API once and returns the response. That is an LLM call, not an agent.
- Project-specific usage: "Claims Agent" refers to the full system including all tools and memory. Never use "agent" for an individual reasoning step.

**Workflow:**
- Definition: The user's business process that the agent is embedded in — the sequence of human and system steps that constitute claims handling end to end.
- Non-example: The agent's internal control loop (reasoning → tool call → observe). That is the agent's trajectory, not the workflow.
- Project-specific usage: "Claims workflow" = the full business process. "Agent trajectory" = the agent's internal reasoning path.

**Task:**
- Definition: A discrete, bounded unit of work the agent is asked to complete within one session. A task has a defined start state, success criterion, and termination condition.
- Non-example: A single tool call. That is a step, not a task.
- Project-specific usage: "Process claim #1234" is a task. "Call the fraud check API" is a step within a task.

**Tool:**
- Definition: A capability exposed to the agent via a structured schema that the agent can invoke to take an action or retrieve information.
- Non-example: An internal Python function the agent calls directly. That is implementation, not a tool unless wrapped in the tool schema.
- Project-specific usage: All external integrations (claims database, fraud API, payment system) are tools. Internal helpers are not.

#### Ambiguous terms resolved

| Term | Previous conflicting meanings | Canonical choice | Reason |
|---|---|---|---|
| "agent" | Full system OR individual LLM call | Full system only | Clarity in architecture docs; "LLM call" for individual calls |
| "workflow" | Business process OR agent control loop | Business process only | "trajectory" for internal control flow |
| "task" | Single tool call OR end-to-end job | End-to-end job only | "step" for individual tool calls |

#### Output: `.agentic/artifacts/glossary-claims-processing.md`

Glossary written. 4 terms defined, 3 disambiguation decisions recorded.

---

### Phase 2: agentic-system-design (glossary-aware)

The system design skill reads the glossary from `glossary_path` before generating recommendations. Terms from Phase 1 are used consistently throughout.

#### Architecture decision (using canonical vocabulary)

**Trigger:** "Now design the claims processing agent architecture."

The design uses the glossary vocabulary throughout:

- The **agent** is a ReAct loop that receives **tasks** (one claim per session) and executes **steps** (tool calls) until the task is complete or escalated.
- The **workflow** (business process) routes claims to the agent, receives results, and triggers downstream actions (payment, notification).
- **Tools** exposed to the agent: `retrieve_claim_details`, `run_fraud_check`, `calculate_settlement`, `approve_payment` (destructive — HITL gated), `flag_for_review`.

**Design review outcome:** No terminology conflicts in the architecture doc — all reviewers use the same definitions from the glossary.

**Artifact cross-link:** Architecture review references `glossary-claims-processing.md` for term definitions.

#### Value of glossary-first ordering

| Without glossary-first | With glossary-first |
|---|---|
| Architecture doc uses "agent" for both system and LLM calls | "Agent" means the full system; "LLM call" is distinct |
| "Workflow" diagrams mix business flow and agent trajectory | Two separate diagrams with distinct labels |
| Sprint tickets mix "task" and "step" causing rework | Tickets use "task" (end-to-end) and "step" (individual call) correctly |
| Code review catches terminology drift late | Glossary is the checklist during architecture review |
