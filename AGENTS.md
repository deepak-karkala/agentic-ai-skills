# AGENTS.md

This file provides routing guidance to AI coding agents (Claude Code, Codex, OpenCode, Cursor, and others) when the `agentic-ai-engineering` plugin is active.

## Plugin Overview

Plugin namespace: `agentic-ai-engineering`

This plugin provides decision-compression workflows for building production-grade agentic AI products. It covers 24 skills across six lanes:

- **Architecture and design:** system design, multi-agent orchestration, single-agent workflow design, ubiquitous language, agent UI patterns
- **Context engineering:** context engineering for agents
- **Evaluation and reliability:** eval design and scorecard strategy, incident investigation, hallucination containment, trace error analysis
- **Deployment and operations:** deployment readiness, observability, tool interface design, latency and cost optimization, agentic security, human-in-the-loop patterns, agent prototype, handoff, GitHub issues
- **Product strategy:** opportunity framing, product strategy, economics and moats, governance and adoption
- **Setup:** one-time repo initialization

Each lane has dedicated skills with explicit routing rules. Use the tables below to match user intent to the correct skill.

Skills activate automatically when user intent matches the trigger conditions below. Users can also invoke any skill directly with `/agentic-ai-engineering:<skill-name>`.

---

## Intent-to-Skill Routing

Map user intent to the correct skill. If a request matches multiple skills, use the most specific one.

### Architecture and design

| User intent | Primary skill | Entry command |
|---|---|---|
| Design an agent system from scratch | `agentic-system-design` | `/agentic-ai-engineering:agentic-plan` |
| Review an existing agent architecture | `agentic-system-design` | `/agentic-ai-engineering:agentic-arch-review` |
| Decide between single-agent and multi-agent | `agentic-system-design` | `/agentic-ai-engineering:agentic-plan` |
| Choose an agent orchestration pattern | `agentic-system-design` | `/agentic-ai-engineering:agentic-arch-review` |
| Design multi-agent topology or handoff contracts | `multi-agent-orchestration` | `/agentic-ai-engineering:agentic-plan` |
| Design agent-to-agent communication, A2A protocols, or inter-agent contracts | `multi-agent-orchestration` | auto |
| Design the control loop and step sequence for a single-agent workflow | `single-agent-workflow-design` | auto |
| Select the right single-agent pattern (chaining vs. routing vs. ReAct) | `single-agent-workflow-design` | auto |
| Design retry, fallback, and recovery logic for an agent workflow | `single-agent-workflow-design` | auto |
| Design tool contracts, schemas, and action granularity | `tool-interface-design` | auto |
| Fix tool selection errors (agent calling the wrong tool) | `tool-interface-design` | auto |
| Design MCP tool manifests and capability scoping | `tool-interface-design` | auto |

### Context and memory

| User intent | Primary skill | Entry command |
|---|---|---|
| Design context strategy or memory architecture | `context-engineering-for-agents` | auto |
| Diagnose context overflow, context drift, or token budget issues | `context-engineering-for-agents` | auto |
| Apply write/select/compress/isolate decisions | `context-engineering-for-agents` | auto |
| Design RAG or retrieval integration for an agent | `context-engineering-for-agents` | auto |

### Evaluation and quality

| User intent | Primary skill | Entry command |
|---|---|---|
| Design an eval strategy for a new agent | `agent-eval-design` | `/agentic-ai-engineering:agentic-evals` |
| Audit an existing eval suite | `agent-eval-design` | `/agentic-ai-engineering:agentic-evals` |
| Choose grader types or scorecard dimensions | `agent-eval-design` | `/agentic-ai-engineering:agentic-evals` |
| Set up regression tests from production failures | `agent-eval-design` | `/agentic-ai-engineering:agentic-evals` |

### Observability and monitoring

| User intent | Primary skill | Entry command |
|---|---|---|
| Design observability strategy (MELT, tracing, session replay) | `agent-observability` | auto |
| Debug production agent failures using traces | `agent-observability` | auto |
| Configure circuit breakers (cost, loop, tool failure) | `agent-observability` | auto |
| Connect production monitoring to the eval improvement flywheel | `agent-observability` | auto |
| Select an observability platform (LangSmith, Langfuse, Datadog) | `agent-observability` | auto |

### Reliability and incident response

| User intent | Primary skill | Entry command |
|---|---|---|
| Investigate a production agent incident or run a post-mortem | `incident-investigation` | auto |
| Identify which fault layer caused a production failure | `incident-investigation` | auto |
| Reconstruct a failure timeline from logs and spans | `incident-investigation` | auto |
| Contain or prevent agent hallucinations | `hallucination-containment` | auto |
| Design a grounding check or citation requirement | `hallucination-containment` | auto |
| Enforce "I don't know" behavior when confidence is insufficient | `hallucination-containment` | auto |
| Read a trace to find the root cause span for a bad output | `trace-error-analysis` | auto |
| Classify a trace failure using TRAIL / MAST / six-bucket taxonomy | `trace-error-analysis` | auto |
| Replay a trace to confirm a fix hypothesis | `trace-error-analysis` | auto |

### Performance, cost, and security

| User intent | Primary skill | Entry command |
|---|---|---|
| Reduce token cost or inference latency for an agent workflow | `latency-and-cost-optimization` | auto |
| Decide whether prompt caching or model routing is the right lever | `latency-and-cost-optimization` | auto |
| Break down cost by component (input tokens, tools, output tokens) | `latency-and-cost-optimization` | auto |
| Design threat mitigations for prompt injection, tool abuse, or data exfiltration | `agentic-security` | auto |
| Assign tool permission tiers and configure dangerous action gating | `agentic-security` | auto |
| Design an audit trail for agent actions by autonomy tier | `agentic-security` | auto |

### Human-in-the-loop design

| User intent | Primary skill | Entry command |
|---|---|---|
| Design an approval gate for a specific agent action | `human-in-the-loop-patterns` | auto |
| Select the right HITL model (fully automated to human-as-teacher) | `human-in-the-loop-patterns` | auto |
| Define the bounded autonomy contract for an agent | `human-in-the-loop-patterns` | auto |
| Design an escalation ladder for a supervised workflow | `human-in-the-loop-patterns` | auto |
| Capture human overrides and feed them back into the eval pipeline | `human-in-the-loop-patterns` | auto |

### Agent UI design

| User intent | Primary skill | Entry command |
|---|---|---|
| Design the user interface for an agent product | `agent-ui-patterns` | auto |
| Design streaming step cards or activity feed for an agent | `agent-ui-patterns` | auto |
| Design Intent Preview for irreversible agent actions | `agent-ui-patterns` | auto |
| Address over-trust (users rubber-stamping) or active distrust in agent UI | `agent-ui-patterns` | auto |
| Design confidence visualization or explainability components | `agent-ui-patterns` | auto |

### Production and deployment

| User intent | Primary skill | Entry command |
|---|---|---|
| Assess production readiness | `deployment-readiness` | `/agentic-ai-engineering:agentic-ops` |
| Design guardrails or fallback strategies | `deployment-readiness` | `/agentic-ai-engineering:agentic-ops` |
| Define human-in-the-loop approval gates | `deployment-readiness` | `/agentic-ai-engineering:agentic-ops` |
| Plan rollout posture or bounded autonomy | `deployment-readiness` | `/agentic-ai-engineering:agentic-ops` |
| Define observability and incident posture | `deployment-readiness` | `/agentic-ai-engineering:agentic-ops` |

### Terminology and vocabulary

| User intent | Primary skill | Entry command |
|---|---|---|
| Define or normalize agent system vocabulary | `agentic-ubiquitous-language` | auto |
| Detect overloaded or ambiguous terms | `agentic-ubiquitous-language` | auto |
| Produce a project glossary before design begins | `agentic-ubiquitous-language` | auto |

### Implementation planning

| User intent | Primary skill | Entry command |
|---|---|---|
| Break an architecture plan into engineering tickets | `agentic-to-issues` | `/agentic-ai-engineering:agentic-to-issues` |
| Convert a design doc into an implementation issue list | `agentic-to-issues` | `/agentic-ai-engineering:agentic-to-issues` |
| Sequence and slice work into foundation, implementation, eval, and rollout tasks | `agentic-to-issues` | `/agentic-ai-engineering:agentic-to-issues` |

### Prototyping

| User intent | Primary skill | Entry command |
|---|---|---|
| Generate a minimal scaffold for an agent pattern | `agentic-prototype` | `/agentic-ai-engineering:agentic-prototype` |
| Validate a pattern choice with runnable code | `agentic-prototype` | `/agentic-ai-engineering:agentic-prototype` |
| Show what a ReAct loop / HITL gate / LangGraph graph looks like in code | `agentic-prototype` | `/agentic-ai-engineering:agentic-prototype` |

### Handoff and continuity

| User intent | Primary skill | Entry command |
|---|---|---|
| Write a handoff doc for a project | `agentic-handoff` | `/agentic-ai-engineering:agentic-handoff` |
| Capture architecture, eval, and deployment state before team transition | `agentic-handoff` | `/agentic-ai-engineering:agentic-handoff` |
| Document open risks and next actions for an incoming engineer | `agentic-handoff` | `/agentic-ai-engineering:agentic-handoff` |

### Opportunity evaluation

| User intent | Primary skill | Entry command |
|---|---|---|
| Decide whether to build an agent for a workflow | `agentic-opportunity-framing` | `/agentic-ai-engineering:agentic-opportunity-framing` |
| Score a use case for agentic AI fit | `agentic-opportunity-framing` | `/agentic-ai-engineering:agentic-opportunity-framing` |
| Triage a backlog of automation ideas for agent-shaped workflows | `agentic-opportunity-framing` | `/agentic-ai-engineering:agentic-opportunity-framing` |
| Assess build/don't-build for a proposed agent | `agentic-opportunity-framing` | `/agentic-ai-engineering:agentic-opportunity-framing` |

### Product strategy

| User intent | Primary skill | Entry command |
|---|---|---|
| Define ICP and market entry wedge for an agent product | `agentic-product-strategy` | `/agentic-ai-engineering:agentic-product-strategy` |
| Score the wedge dimensions for an agent product | `agentic-product-strategy` | `/agentic-ai-engineering:agentic-product-strategy` |
| Assess whether the product architecture is defensible | `agentic-product-strategy` | `/agentic-ai-engineering:agentic-product-strategy` |
| Select the GTM motion (PLG vs. enterprise vs. regulated) | `agentic-product-strategy` | `/agentic-ai-engineering:agentic-product-strategy` |
| Identify which moat layers to prioritize (strategic, high-level) | `agentic-product-strategy` | `/agentic-ai-engineering:agentic-product-strategy` |

### Economics and moats

| User intent | Primary skill | Entry command |
|---|---|---|
| Model unit economics for an agent product | `agentic-economics-and-moats` | `/agentic-ai-engineering:agentic-economics-and-moats` |
| Diagnose inference cost trap or margin deterioration | `agentic-economics-and-moats` | `/agentic-ai-engineering:agentic-economics-and-moats` |
| Design the data flywheel for an agent product | `agentic-economics-and-moats` | `/agentic-ai-engineering:agentic-economics-and-moats` |
| Score moat depth across all 5 layers and identify shallowest | `agentic-economics-and-moats` | `/agentic-ai-engineering:agentic-economics-and-moats` |
| Quantify how defensible the product is and for how long | `agentic-economics-and-moats` | `/agentic-ai-engineering:agentic-economics-and-moats` |
| Identify cost optimization levers (caching, routing, compression) | `agentic-economics-and-moats` | `/agentic-ai-engineering:agentic-economics-and-moats` |

### Governance and adoption

| User intent | Primary skill | Entry command |
|---|---|---|
| Assess AI governance maturity for an agent deployment | `agentic-governance-and-adoption` | `/agentic-ai-engineering:agentic-governance-and-adoption` |
| Define minimum governance controls for an agent | `agentic-governance-and-adoption` | `/agentic-ai-engineering:agentic-governance-and-adoption` |
| Map regulatory requirements (EU AI Act, HIPAA, SOC 2) | `agentic-governance-and-adoption` | `/agentic-ai-engineering:agentic-governance-and-adoption` |
| Design human-agent collaboration UX | `agentic-governance-and-adoption` | `/agentic-ai-engineering:agentic-governance-and-adoption` |
| Plan the adoption sequence (pilot to org-wide) | `agentic-governance-and-adoption` | `/agentic-ai-engineering:agentic-governance-and-adoption` |

### Setup

| User intent | Primary skill | Entry command |
|---|---|---|
| Configure this repo for the plugin skill suite | `setup-agentic-ai-engineering` | `/agentic-ai-engineering:setup-agentic-ai-engineering` |
| Record where design docs, eval assets, or artifacts live | `setup-agentic-ai-engineering` | `/agentic-ai-engineering:setup-agentic-ai-engineering` |

---

## Skill Trigger Examples and Boundaries

### `agentic-system-design`

**Trigger on:**
- "How should I architect this agent?"
- "Should I use a single agent or multiple agents for this?"
- "What's the right autonomy level for this workflow?"
- "Help me design the control loop for this task"
- "Which orchestration pattern fits this use case?"
- "Review my agent architecture"

**Do not trigger on:**
- Specific eval questions → use `agent-eval-design`
- Multi-agent topology and handoff specifics (after initial design) → use `multi-agent-orchestration`
- Deployment gates and production readiness → use `deployment-readiness`
- Context window budgets or memory tier design → use `context-engineering-for-agents`

---

### `context-engineering-for-agents`

**Trigger on:**
- "How should I manage context for this agent?"
- "The agent keeps losing track of state — how do I fix this?"
- "How do I design memory for a long-running agent?"
- "When should I use external memory vs in-context state?"
- "How do I compress context without losing important information?"
- "How should I isolate context across subagents?"

**Do not trigger on:**
- High-level architecture questions → use `agentic-system-design`
- Tool design or MCP wiring → use `multi-agent-orchestration`

---

### `multi-agent-orchestration`

**Trigger on:**
- "When should I split this into multiple agents?"
- "How should I structure the handoff between agents?"
- "Which multi-agent topology fits this use case — sequential, fan-out, supervisor?"
- "How do I prevent coordination failures in a multi-agent system?"
- "How do MCP and A2A work together in this design?"
- "What are the risks of this multi-agent design?"

**Do not trigger on:**
- Initial "should I use agents at all?" questions → use `agentic-system-design`
- Eval strategy → use `agent-eval-design`
- Deployment readiness → use `deployment-readiness`

---

### `agent-eval-design`

**Trigger on:**
- "How do I evaluate this agent?"
- "What metrics matter for this agentic workflow?"
- "My agent looks good in demos but I'm not confident — how do I test it properly?"
- "How do I choose between LLM-as-judge and deterministic evaluators?"
- "How do I set up regression tests for this agent?"
- "Audit my current eval setup"

**Do not trigger on:**
- Architecture decisions → use `agentic-system-design`
- Production readiness gates → use `deployment-readiness` (eval is a readiness input, not the same skill)

---

### `deployment-readiness`

**Trigger on:**
- "Is this agent safe to deploy to production?"
- "What guardrails do I need before going live?"
- "How do I design human approval gates for this agent?"
- "What should I monitor once this is running?"
- "What's the rollout posture — shadow mode, gated, full?"
- "What's the reversibility classification for this agent's actions?"

**Do not trigger on:**
- Eval design → use `agent-eval-design`
- Architecture decisions → use `agentic-system-design`

---

### `agentic-ubiquitous-language`

**Trigger on:**
- "Define our agent system vocabulary before we start"
- "What do we mean by planner / worker / handoff in this system?"
- "We keep arguing about what a tool is vs a skill"
- "Write a glossary for this agent project"
- "Normalize our terminology"
- "What's the difference between memory and context in our system?"

**Do not trigger on:**
- General "what is an agent?" with no project context — answer directly without invoking this skill
- Architecture design questions → use `agentic-system-design`
- Eval strategy → use `agent-eval-design`

---

### `agentic-to-issues`

**Trigger on:**
- "Break this architecture plan into tickets"
- "Convert this design into implementation tasks"
- "Turn this review artifact into GitHub issues"
- "Slice this plan into work items"
- "What are the engineering tasks for this architecture?"
- "Generate an issue list from this design doc"

**Do not trigger on:**
- Architecture not yet decided → use `agentic-system-design` first
- Eval plan creation → use `agent-eval-design`
- Project state capture for handoff → use `agentic-handoff`

---

### `agentic-prototype`

**Trigger on:**
- "Show me a minimal scaffold for this agent"
- "Give me a starting point for this ReAct loop"
- "Prototype the approval gate flow"
- "What does this pattern look like in code?"
- "Generate a LangGraph skeleton for this design"
- "I want to validate this pattern before committing"

**Do not trigger on:**
- Architecture not yet chosen → use `agentic-system-design` first
- Request for full production implementation — explicitly out of scope; note this and offer a prototype instead
- Code review of existing implementation → use `agentic-system-design` or `multi-agent-orchestration`

---

### `agentic-handoff`

**Trigger on:**
- "Write a handoff doc for this project"
- "Capture what the next engineer needs to know"
- "I'm handing this off to another team"
- "Document current state before I leave"
- "Create a project summary for the incoming team"
- "What should I document before wrapping up?"

**Do not trigger on:**
- Architecture decisions still open → use `agentic-system-design` first
- Generating implementation tasks → use `agentic-to-issues`
- Eval plan creation → use `agent-eval-design`

---

### `agentic-opportunity-framing`

**Trigger on:**
- "Should we build an agent for this workflow?"
- "Is this use case agent-shaped?"
- "Score this opportunity for agentic AI fit"
- "Help us decide which workflows to automate with agents"
- "Does this workflow need an agent or would a pipeline do?"
- "Evaluate our use case backlog for agentic fit"

**Do not trigger on:**
- Architecture design (decision already made) → use `agentic-system-design`
- Product wedge, ICP, or market strategy questions → use `agentic-product-strategy`
- Reviewing an existing deployed agent → use `agentic-arch-review`
- General "what is an agent?" with no specific use case — answer directly

---

### `agentic-product-strategy`

**Trigger on:**
- "Where should we enter the market with this agent?"
- "Define our ICP for this agent product"
- "What's our wedge for this agentic AI product?"
- "Are we building a thin wrapper?"
- "What GTM motion should we use?"
- "How do we make this agent product defensible?"

**Do not trigger on:**
- Workflow fit evaluation (is this use case agent-shaped?) → use `agentic-opportunity-framing`
- Technical agent architecture design → use `agentic-system-design`
- Detailed unit economics and moat depth → use `agentic-economics-and-moats`
- General business strategy with no agentic AI context — answer directly

---

### `agentic-economics-and-moats`

**Trigger on:**
- "Will our pricing survive at scale?"
- "We're losing margin — I think inference costs are the problem"
- "Model the unit economics for this agent product"
- "How do we build a data flywheel?"
- "Assess our moat depth"
- "What cost optimizations should we prioritize?"

**Do not trigger on:**
- Product wedge and ICP strategy → use `agentic-product-strategy`
- Technical architecture of the agent → use `agentic-system-design`
- Workflow fit evaluation → use `agentic-opportunity-framing`
- General financial modeling outside agentic AI context — answer directly

---

### `agentic-governance-and-adoption`

**Trigger on:**
- "What governance do we need for this agent?"
- "What compliance requirements apply to this deployment?"
- "Design the UX for our agent — we want doctors/users to trust it but not over-trust it"
- "How do we roll this agent out to the organization?"
- "Assess our governance maturity"
- "What do we need before we can deploy to a regulated customer?"

**Do not trigger on:**
- Technical guardrail implementation → use `deployment-readiness`
- Eval strategy → use `agent-eval-design`
- Technical architecture → use `agentic-system-design`
- Product strategy and wedge → use `agentic-product-strategy`

---

### `tool-interface-design`

**Trigger on:**
- "How should I design the tools for this agent?"
- "Should this be one tool or three smaller tools?"
- "The agent keeps calling the wrong tool — how do I fix this?"
- "Write tool schemas for this agent"
- "Design MCP tool contracts"
- "How do I expose this API as an agent tool?"
- "What should the tool descriptions say?"

**Do not trigger on:**
- Which agent receives which tools in a multi-agent system → use `multi-agent-orchestration`
- Runtime security enforcement for tool calls (sandbox, gateway) → use `deployment-readiness`
- High-level architecture decisions → use `agentic-system-design`
- Generating runnable tool stubs → use `agentic-prototype`

---

### `single-agent-workflow-design`

**Trigger on:**
- "Design the control loop for this single-agent workflow"
- "Should I use prompt chaining or a ReAct loop for this?"
- "How should retries and fallback steps be structured?"
- "Design the step sequence for this agent"
- "Which single-agent pattern fits this workflow?"
- "Map the state transitions for this workflow"

**Do not trigger on:**
- Whether to use a single agent vs. multiple agents → use `agentic-system-design` first
- Multi-agent topology and handoff contracts → use `multi-agent-orchestration`
- Tool contract design → use `tool-interface-design`
- Generating runnable scaffold → use `agentic-prototype`

---

### `agent-observability`

**Trigger on:**
- "What should I trace for this agent?"
- "How do I debug agent failures in production?"
- "Design the telemetry strategy for this agent"
- "Set up session replay for this agent"
- "Configure circuit breakers for this agent"
- "How do I connect production traces to our evals?"
- "What's the minimum observability I need before going to production?"

**Do not trigger on:**
- High-level MELT checklist as part of deployment readiness gate → use `deployment-readiness`
- Eval scorecard and grader design → use `agent-eval-design`
- Agent architecture → use `agentic-system-design`

---

### `latency-and-cost-optimization`

**Trigger on:**
- "How do I reduce the cost of this agent?"
- "My agent is too slow — how do I optimize latency?"
- "Which parts of this agent pipeline are most expensive?"
- "Should I cache this prompt response?"
- "How do I route between models to reduce cost?"
- "Break down where my agent is spending tokens"
- "Is prompt caching worth it for this workflow?"

**Do not trigger on:**
- Unit economics and product-level margin → use `agentic-economics-and-moats`
- General model cost comparison with no specific agent context — answer directly
- Architecture decisions about which agent to build → use `agentic-system-design`

---

### `agentic-security`

**Trigger on:**
- "What security threats should I design against for this agent?"
- "How do I prevent prompt injection in this agent?"
- "How do I handle secrets in my agent's context?"
- "What permission tier should this tool have?"
- "Design the audit trail for this agent's actions"
- "How do I prevent data exfiltration through tool calls?"
- "What should I do before giving this agent admin access?"

**Do not trigger on:**
- Production readiness gates (security as one input among many) → use `deployment-readiness`
- Governance and compliance framing → use `agentic-governance-and-adoption`
- General API security with no agentic AI context — answer directly

---

### `incident-investigation`

**Trigger on:**
- "An agent incident just happened — help me investigate"
- "We had a mass failure — which layer caused it?"
- "Run a post-mortem on this agent failure"
- "Walk me through how to diagnose this incident"
- "Help me reconstruct what went wrong in production"
- "The agent behaved badly in production — where do I start?"

**Do not trigger on:**
- Reading a specific trace to identify the root cause span → use `trace-error-analysis`
- Designing observability instrumentation → use `agent-observability`
- One-off debugging with no incident framing → use `trace-error-analysis`

---

### `hallucination-containment`

**Trigger on:**
- "My agent is making things up — how do I stop it?"
- "How do I detect when the agent is hallucinating?"
- "The agent cites sources that don't exist"
- "Design a grounding check for this agent"
- "How do I enforce 'I don't know' behavior?"
- "The agent confidently answers when it shouldn't"
- "Add citation requirements to this agent"

**Do not trigger on:**
- Eval strategy for measuring hallucination frequency → use `agent-eval-design`
- Context design to prevent truncation causing hallucinations → use `context-engineering-for-agents`
- General "what is hallucination?" with no specific agent — answer directly

---

### `human-in-the-loop-patterns`

**Trigger on:**
- "Design the approval gate for this agent action"
- "When should the agent wait for human review vs. proceed autonomously?"
- "How do I define the bounded autonomy contract for this agent?"
- "Design the escalation ladder for this workflow"
- "What HITL model fits this use case?"
- "How do I capture human overrides and feed them back into evals?"
- "Design the timeout and audit mechanism for this approval gate"

**Do not trigger on:**
- UI components and layout for approval (how the gate looks to users) → use `agent-ui-patterns`
- Governance policy and org-level trust frameworks → use `agentic-governance-and-adoption`
- High-level HITL posture as part of deployment readiness → use `deployment-readiness`

---

### `trace-error-analysis`

**Trigger on:**
- "Help me read this trace — the agent returned the wrong answer"
- "Which span caused this failure?"
- "I have a LangSmith/Langfuse trace and a bad output — walk me through it"
- "The agent looped — find the root cause span"
- "Diagnose this agent failure from the trace"
- "Walk me through this trace"
- "The agent hallucinated — which tool call went wrong?"

**Do not trigger on:**
- Designing the observability instrumentation that captures traces → use `agent-observability`
- Full incident post-mortem including fault layer and durable fix design → use `incident-investigation`
- No trace available — this skill requires trace evidence

---

### `agent-ui-patterns`

**Trigger on:**
- "Design the UI for this agent"
- "What should the interface show while the agent is running?"
- "How do we communicate uncertainty to users?"
- "Design the approval interface for this agent"
- "Users are rubber-stamping the agent output — how do we fix that?"
- "Design the activity feed for this agent"
- "How should we show agent reasoning to users?"
- "Users have stopped trusting the agent — how do we fix that?"

**Do not trigger on:**
- Technical approval gate mechanism (trigger conditions, validation, audit records) → use `human-in-the-loop-patterns`
- Governance policy and org-level trust frameworks → use `agentic-governance-and-adoption`
- Deployment gate checklists → use `deployment-readiness`

---

## Subagent Routing

Subagents run in isolated context and are invoked by skills when specialist analysis is needed.

| Subagent | Invoked by | Responsibility |
|---|---|---|
| `agent-systems-architect` | `agentic-system-design`, `multi-agent-orchestration` | Architecture decomposition, tradeoff analysis, context-boundary review |
| `agent-evals-auditor` | `agent-eval-design` | Audit-style eval inspection, evidence gathering, gap identification |
| `agent-product-strategist` | `agentic-opportunity-framing`, `agentic-product-strategy` | Opportunity decomposition, wedge scoring, adoption constraint analysis, governance risk assessment |
| `agent-reliability-engineer` | `incident-investigation`, `hallucination-containment`, `agent-eval-design` | Failure mode classification, hallucination pattern assessment, reliability gap identification, eval coverage review for reliability dimensions |
| `agent-cost-performance-analyst` | `latency-and-cost-optimization` | Latency/cost decomposition by component, bottleneck prioritization, optimization tradeoff synthesis |

**Rules:**
- `agent-systems-architect` owns architecture. It does not assess eval quality, production gates, or product strategy.
- `agent-evals-auditor` owns eval audit. It does not make architecture or product recommendations.
- `agent-product-strategist` owns opportunity and product analysis. It does not make architecture decisions or design eval scorecards.
- `agent-reliability-engineer` owns reliability analysis. It does not design architecture, optimize costs, or audit eval suite structure.
- `agent-cost-performance-analyst` owns cost/latency decomposition. It does not make architecture decisions or assess reliability/incident root causes.
- Subagents return structured findings. The parent skill synthesizes and presents to the user.
- No subagent spawns another subagent.
- Delegation is evidence-based, not automatic. Invoke a subagent only when inline analysis would flood the conversation with detail the user does not need to see.

---

## Command-to-Skill Mapping

| Command | Primary skill | Subagent invoked |
|---|---|---|
| `/agentic-ai-engineering:setup-agentic-ai-engineering` | `setup-agentic-ai-engineering` | none |
| `/agentic-ai-engineering:agentic-plan` | `agentic-system-design` | `agent-systems-architect` (optional) |
| `/agentic-ai-engineering:agentic-arch-review` | `agentic-system-design` | `agent-systems-architect` |
| `/agentic-ai-engineering:agentic-evals` | `agent-eval-design` | `agent-evals-auditor` |
| `/agentic-ai-engineering:agentic-ops` | `deployment-readiness` | none |
| `/agentic-ai-engineering:agentic-to-issues` | `agentic-to-issues` | none |
| `/agentic-ai-engineering:agentic-prototype` | `agentic-prototype` | none |
| `/agentic-ai-engineering:agentic-handoff` | `agentic-handoff` | none |
| `/agentic-ai-engineering:agentic-opportunity-framing` | `agentic-opportunity-framing` | `agent-product-strategist` (optional — non-trivial use cases) |
| `/agentic-ai-engineering:agentic-product-strategy` | `agentic-product-strategy` | `agent-product-strategist` (optional — multi-dimension wedge scoring) |
| `/agentic-ai-engineering:agentic-economics-and-moats` | `agentic-economics-and-moats` | none |
| `/agentic-ai-engineering:agentic-governance-and-adoption` | `agentic-governance-and-adoption` | none |

---

## Host Support Matrix

| Host | Plugin loading | Skill auto-invoke | Subagents | Commands | Adapter |
|---|---|---|---|---|---|
| Claude Code | plugin.json | Yes | Yes (isolated context) | Yes (namespaced) | Native |
| Codex | AGENTS.md | No — manual skill reference | No — inline fallback | No — natural language | `adapters/codex.md` |
| Gemini / ADK | Python agent setup | No — explicit agent per skill | Yes (AgentTool) | No — Python entrypoints | `adapters/gemini-adk.md` |
| OpenCode | AGENTS.md (spec-complete — not yet implemented; `.opencode/instructions.md` not yet created) | No — AGENTS.md routing only | No — inline fallback | No — natural language | `adapters/opencode.md` |

For non-Claude Code hosts: see the adapter file for setup instructions. Core `skills/` and `agents/` content is unchanged across all hosts — only the invocation layer differs.

---

## Cross-Lane Routing: Ambiguous Requests

Some requests sit at the boundary between the strategy lane (Tasks 9–12) and the technical lane (M1 skills). Use this table to route without ambiguity.

| Request | Correct skill | Routing rationale |
|---|---|---|
| "Should we build an agent for this?" | `agentic-opportunity-framing` | Fit evaluation, not architecture design |
| "We decided to build — how should we architect it?" | `agentic-system-design` | Decision is made; architecture begins here |
| "Is this use case worth building a product around?" | `agentic-product-strategy` | Product viability, not workflow fit |
| "We have a working agent — is it ready to deploy?" | `deployment-readiness` | Production gate, not strategy |
| "Our margins are bad — is it an inference cost problem or a pricing problem?" | `agentic-economics-and-moats` | Economics first; if it reveals an architecture problem, route to `agentic-system-design` after |
| "We want to add HITL to our agent — how?" | `deployment-readiness` | HITL gate is a deployment/guardrail design question, not a governance question |
| "Our compliance team is asking what governance we have" | `agentic-governance-and-adoption` | Governance posture and controls documentation |
| "How do we deploy our agent to production safely?" | `deployment-readiness` | Technical deployment readiness, not governance maturity |
| "How do we grow from 5 pilot users to the whole org?" | `agentic-governance-and-adoption` | Adoption sequence is governance/change management |
| "How do we evaluate our agent's accuracy?" | `agent-eval-design` | Eval design, not economics or governance |
| "What moat does our eval dataset give us?" | `agentic-economics-and-moats` | Moat depth scoring — even when the trigger mentions eval |
| "Which moat layers should we invest in this quarter?" | `agentic-product-strategy` | Strategic prioritization of moat layers — high-level, no scoring |
| "How deep is our context advantage moat vs. competitors?" | `agentic-economics-and-moats` | Quantified moat depth assessment, not strategic prioritization |
| "We keep using 'agent' and 'workflow' interchangeably" | `agentic-ubiquitous-language` | Terminology alignment precedes all other design work |
| "Design a data flywheel for our agent" | `agentic-economics-and-moats` | MAPE loop is an economics/moat concept, not an eval or architecture concept |
| "What regulatory requirements apply before we can go live?" | `agentic-governance-and-adoption` | Regulatory mapping is governance work |
| "We're handing this project to a new team" | `agentic-handoff` | Continuity document, not governance or strategy |

**Tie-breaking rule:** When a request touches both strategy and technical lanes, prefer the strategy-lane skill if the decision hasn't been made yet (pre-build); prefer the technical-lane skill if the system is already being built or deployed (post-decision).

### M3 Phase 2 Skill Overlap Zones

These requests sit at the boundaries between the seven new M3 skills and existing skills:

| Request | Correct skill | Routing rationale |
|---|---|---|
| "How do I reduce the cost of this agent?" | `latency-and-cost-optimization` | Token-level optimization and model routing — not product economics |
| "Will our margins survive at scale?" | `agentic-economics-and-moats` | Product-level unit economics and pricing, not per-request token tuning |
| "What security threats should I design against?" | `agentic-security` | Threat taxonomy and mitigation — not a deployment readiness gate |
| "Is this agent safe to deploy?" | `deployment-readiness` | Production gate checklist — security is one input; for threat-specific hardening use `agentic-security` |
| "An incident just happened — help me investigate" | `incident-investigation` | Post-mortem workflow: fault layer identification and timeline reconstruction |
| "Help me read this trace — the agent returned the wrong answer" | `trace-error-analysis` | Trace-reading technique: backward trace from bad output to root cause span |
| "Design circuit breakers and alerts" | `agent-observability` | Proactive instrumentation design — not reactive incident analysis |
| "My agent is hallucinating — how do I stop it?" | `hallucination-containment` | Containment patterns: grounding checks, citations, verification layers |
| "Measure hallucination rate in my evals" | `agent-eval-design` | Measuring frequency — not containment design |
| "Design the approval gate for this agent" | `human-in-the-loop-patterns` | Technical gate mechanism: trigger, content, audit, timeout, escalation |
| "Design the UI for the approval step" | `agent-ui-patterns` | UI layer: Intent Preview, Autonomy Dial, confidence visualization |
| "What HITL policy should we require for compliance?" | `agentic-governance-and-adoption` | Governance policy — not gate mechanism design |
| "Design the UI for this agent" | `agent-ui-patterns` | UI architecture: layout, streaming, transparency, Calibrated Trust |
| "Design the UX for our agent — we want users to trust it" | `agent-ui-patterns` | Trust calibration design — not governance or adoption planning |

---

### Phase 3 Technical Skill Overlap Zones

These requests sit at the boundaries between the three new Phase 3 skills and M1 skills:

| Request | Correct skill | Routing rationale |
|---|---|---|
| "How should I design the tools for this agent?" | `tool-interface-design` | Contract design, schema, ACI principles |
| "Which agent gets which tools in my supervisor-worker system?" | `multi-agent-orchestration` | Tool assignment is topology — not contract design |
| "How do I sandbox or gate tool calls at runtime?" | `deployment-readiness` | Runtime security enforcement, not contract design |
| "Design the step sequence for this single-agent workflow" | `single-agent-workflow-design` | Control flow design for a decided architecture |
| "Should I use a single agent or multiple agents?" | `agentic-system-design` | Architecture decision precedes workflow design |
| "How do I structure the state across agents?" | `multi-agent-orchestration` | Multi-agent state is topology/handoff, not single-agent workflow |
| "What should I trace for this agent?" | `agent-observability` | Deep observability design |
| "Is my agent production-ready?" | `deployment-readiness` | Production readiness gate — includes high-level MELT checklist |
| "How do I improve my agent from production failures?" | `agent-observability` | Improvement flywheel design connects traces to evals |
| "How do I design the eval graders?" | `agent-eval-design` | Grader design is eval work; observability provides the raw signal |
| "What's the difference between TCR and GCR?" | `agent-observability` | KPI definitions are in observability context |
| "The agent selects the wrong tool despite good descriptions" | `tool-interface-design` | Tool disambiguation via ACI non-use examples |
| "The agent's prompt is too complex — too many tool categories" | `multi-agent-orchestration` | Prompt overload is a topology trigger (partition into workers) |

---

## Anti-Patterns

Do not:
- Route a general "help me with my agent" request without first reading the specific intent
- Invoke multiple conflicting skills for the same request
- Let `agent-evals-auditor` make architecture recommendations
- Let `agent-systems-architect` assess eval quality
- Bypass `setup-agentic-ai-engineering` when a skill explicitly requires `eval_assets_path`
- Route strategy-lane requests to technical-lane skills (e.g., routing "should we build this?" to `agentic-system-design`)
