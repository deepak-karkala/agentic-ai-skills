# Routing Dry-Run: Milestone 2 Skills

Manual routing test table for Milestone 2 skills. For each skill, documents obvious-trigger, paraphrase-trigger, and non-trigger cases. Boundary collisions are noted where they exist.

For Milestone 1 routing tests, see the equivalent M1 dry-run in the same directory.

---

## How to use this table

For each test case, identify which skill should handle the request. Then verify:
1. The AGENTS.md routing table routes to the same skill.
2. The skill's `description` field contains trigger phrases that would match.
3. Non-trigger cases do NOT match the listed skill.

A **boundary collision** means two skills claim the same trigger. These cases are resolved by the tie-breaking rules in AGENTS.md.

---

## agentic-opportunity-framing

| Case type | Input | Expected skill | Notes |
|---|---|---|---|
| Obvious trigger | "Should we build an agent for this?" | `agentic-opportunity-framing` | Classic pre-build fit question |
| Obvious trigger | "Is this use case a good fit for an agent?" | `agentic-opportunity-framing` | — |
| Obvious trigger | "Evaluate this process for agent automation" | `agentic-opportunity-framing` | — |
| Paraphrase trigger | "Does this make sense to automate with AI?" | `agentic-opportunity-framing` | Paraphrase of fit evaluation |
| Paraphrase trigger | "Would an agent help here or is this too risky?" | `agentic-opportunity-framing` | Risk framing of fit question |
| Non-trigger | "We've decided to build — design the architecture" | `agentic-system-design` | Decision is made; architecture begins |
| Non-trigger | "Is this a good product opportunity?" | `agentic-product-strategy` | Product viability, not workflow fit |
| Boundary | "Should we build this as a product?" | `agentic-opportunity-framing` first, then `agentic-product-strategy` | Fit check precedes strategy |

---

## agentic-product-strategy

| Case type | Input | Expected skill | Notes |
|---|---|---|---|
| Obvious trigger | "Develop a product strategy for this agent" | `agentic-product-strategy` | Direct product strategy request |
| Obvious trigger | "What's our ICP for this agentic product?" | `agentic-product-strategy` | ICP definition is product strategy |
| Obvious trigger | "Score our wedge position for this market" | `agentic-product-strategy` | Wedge scoring is product strategy |
| Paraphrase trigger | "How do we build a defensible business around this agent?" | `agentic-product-strategy` | Defensibility = moat strategy |
| Paraphrase trigger | "Who should we sell this to first?" | `agentic-product-strategy` | ICP and GTM landing question |
| Non-trigger | "How deep is our data moat vs competitors?" | `agentic-economics-and-moats` | Quantified depth scoring, not strategic prioritization |
| Non-trigger | "Which moat layers should we invest in this quarter?" | `agentic-product-strategy` | Strategic prioritization → product-strategy (not economics) |
| Boundary | "Should we prioritize context advantage or workflow position?" | `agentic-product-strategy` | High-level prioritization; depth scoring goes to economics |

---

## agentic-economics-and-moats

| Case type | Input | Expected skill | Notes |
|---|---|---|---|
| Obvious trigger | "Analyze the unit economics for this agent" | `agentic-economics-and-moats` | Unit economics = this skill |
| Obvious trigger | "Our margins are bad — is it inference cost or pricing?" | `agentic-economics-and-moats` | Cost vs. pricing analysis |
| Obvious trigger | "Design a data flywheel for our agent" | `agentic-economics-and-moats` | MAPE loop is an economics concept |
| Paraphrase trigger | "How much does it cost per task at P99?" | `agentic-economics-and-moats` | Cost per task = inference cost analysis |
| Paraphrase trigger | "What moat does our eval dataset give us?" | `agentic-economics-and-moats` | Moat depth scoring |
| Non-trigger | "Which moat layers should we invest in?" | `agentic-product-strategy` | Strategic prioritization, not depth scoring |
| Non-trigger | "We need to reduce token count" | `context-engineering-for-agents` | Token optimization is context engineering |
| Boundary | "Are our costs sustainable as we scale?" | `agentic-economics-and-moats` | Unit economics → this skill; architecture cost → route to system-design after |

---

## agentic-governance-and-adoption

| Case type | Input | Expected skill | Notes |
|---|---|---|---|
| Obvious trigger | "What regulatory requirements apply before we go live?" | `agentic-governance-and-adoption` | Regulatory mapping is governance |
| Obvious trigger | "Design our governance controls for this agent" | `agentic-governance-and-adoption` | Controls = governance |
| Obvious trigger | "How do we grow from pilot to full org rollout?" | `agentic-governance-and-adoption` | Adoption sequence is this skill |
| Paraphrase trigger | "Our compliance team is asking what controls we have" | `agentic-governance-and-adoption` | Compliance posture question |
| Paraphrase trigger | "How do we get the team to actually use this?" | `agentic-governance-and-adoption` | Adoption/change management |
| Non-trigger | "How do we add HITL to our agent?" | `deployment-readiness` | HITL gate is a deployment design question |
| Non-trigger | "How do we deploy to production safely?" | `deployment-readiness` | Technical deployment, not governance maturity |
| Boundary | "What approvals do we need before going live?" | `agentic-governance-and-adoption` | Governance sign-off → this skill; technical gate → deployment-readiness |

---

## tool-interface-design

| Case type | Input | Expected skill | Notes |
|---|---|---|---|
| Obvious trigger | "Design the tool interfaces for this agent" | `tool-interface-design` | Direct tool contract design request |
| Obvious trigger | "Write the tool schema for this API" | `tool-interface-design` | Schema = contract design |
| Obvious trigger | "The agent keeps selecting the wrong tool — fix the descriptions" | `tool-interface-design` | ACI disambiguation = this skill |
| Paraphrase trigger | "How granular should our tools be?" | `tool-interface-design` | Granularity decision = this skill |
| Paraphrase trigger | "Should we expose one 'search' tool or separate read/write tools?" | `tool-interface-design` | Tool boundary design |
| Non-trigger | "Which agent gets which tools in my supervisor system?" | `multi-agent-orchestration` | Tool assignment is topology, not contract design |
| Non-trigger | "How do we sandbox tool calls at runtime?" | `deployment-readiness` | Runtime security enforcement |
| Boundary | "Design the MCP server for my agent" | `tool-interface-design` | MCP wiring = contract design; A2A protocols → multi-agent-orchestration |

---

## single-agent-workflow-design

| Case type | Input | Expected skill | Notes |
|---|---|---|---|
| Obvious trigger | "Design the step sequence for this agent workflow" | `single-agent-workflow-design` | Control flow design |
| Obvious trigger | "What's the right pattern — chaining or ReAct?" | `single-agent-workflow-design` | Pattern selection for single agent |
| Obvious trigger | "Design the retry and recovery strategy for this agent" | `single-agent-workflow-design` | Retry/recovery is workflow design |
| Paraphrase trigger | "Map out how this agent should handle failures at each step" | `single-agent-workflow-design` | Gate and fallback design |
| Paraphrase trigger | "When should this agent stop vs keep trying?" | `single-agent-workflow-design` | Termination condition design |
| Non-trigger | "Should I use a single agent or multiple?" | `agentic-system-design` | Architecture decision precedes workflow design |
| Non-trigger | "How do I structure state across my agents?" | `multi-agent-orchestration` | Multi-agent state = orchestration |
| Boundary | "Design the workflow for my orchestrator" | `single-agent-workflow-design` if one agent; `multi-agent-orchestration` if orchestrator+workers | Depends on topology |

---

## agent-observability

| Case type | Input | Expected skill | Notes |
|---|---|---|---|
| Obvious trigger | "What should I trace for this agent?" | `agent-observability` | Core trigger phrase |
| Obvious trigger | "Design the observability strategy for this agent" | `agent-observability` | Direct request |
| Obvious trigger | "Configure circuit breakers for this agent" | `agent-observability` | Circuit breakers = this skill |
| Obvious trigger | "Set up session replay for this agent" | `agent-observability` | Session replay = this skill |
| Paraphrase trigger | "How do I debug production agent failures?" | `agent-observability` | Debug strategy = tracing/replay |
| Paraphrase trigger | "What metrics matter for this agent in production?" | `agent-observability` | KPI selection = this skill |
| Non-trigger | "Is my agent production-ready?" | `deployment-readiness` | Production gate, not observability design |
| Non-trigger | "Design the eval graders for this agent" | `agent-eval-design` | Grader design is eval work |
| Boundary | "How do I connect production traces to my evals?" | `agent-observability` | Improvement flywheel design = this skill |

---

## agentic-ubiquitous-language

| Case type | Input | Expected skill | Notes |
|---|---|---|---|
| Obvious trigger | "We keep using 'agent' and 'workflow' interchangeably" | `agentic-ubiquitous-language` | Classic terminology alignment trigger |
| Obvious trigger | "Build a glossary for this project" | `agentic-ubiquitous-language` | Glossary generation = this skill |
| Obvious trigger | "Define the key terms before we start designing" | `agentic-ubiquitous-language` | Pre-design vocabulary alignment |
| Paraphrase trigger | "Our team has different definitions for 'task' — align us" | `agentic-ubiquitous-language` | Term disambiguation |
| Non-trigger | "Design the architecture for this agent" | `agentic-system-design` | Architecture design, even if terminology is involved |
| Non-trigger | "Write the API documentation for this tool" | Not in plugin scope | Documentation writing is not a plugin skill |

---

## Boundary Collision Summary

| Collision | Resolution |
|---|---|
| "Should we build this as a product?" — opportunity-framing vs product-strategy | opportunity-framing first (fit check); product-strategy if fit is confirmed |
| "Which moat layers to invest in?" — product-strategy vs economics-and-moats | product-strategy for strategic prioritization; economics-and-moats for quantified depth scoring |
| "What approvals before going live?" — governance vs deployment-readiness | governance for organizational sign-off; deployment-readiness for technical production gates |
| "Design MCP wiring for my agent" — tool-interface-design vs multi-agent-orchestration | tool-interface-design for tool contracts and schemas; multi-agent-orchestration for A2A protocols |
| "Design workflow for my orchestrator" — single-agent vs multi-agent | single-agent-workflow-design if one agent's control flow; multi-agent-orchestration if it involves multiple agents |
| Moat questions mentioning "eval dataset" | Always route to economics-and-moats (moat depth scoring), even when "eval" is mentioned |
| "How do I improve from production failures?" — observability vs eval-design | agent-observability owns the improvement flywheel; agent-eval-design owns scorecard/grader design |

---

## Tie-breaking rule

When a request touches both strategy lane (opportunity-framing, product-strategy, economics, governance) and technical lane (system-design, eval-design, deployment-readiness):
- Pre-build (decision not yet made) → prefer strategy lane skill
- Post-decision (system is being built or deployed) → prefer technical lane skill
