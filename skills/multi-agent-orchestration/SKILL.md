---
name: multi-agent-orchestration
description: >
  Designs multi-agent topologies, handoff contracts, and coordination
  strategies for agentic AI systems. Covers when NOT to use multi-agent,
  topology selection, handoff contract definition, coordination anti-patterns,
  and protocol/framework selection.
  Use when deciding whether to split a single agent into multiple agents,
  selecting a multi-agent topology (sequential, fan-out, supervisor, swarm),
  defining handoff contracts between agents, diagnosing coordination
  failures, or choosing between MCP and A2A.
  Trigger phrases: "should I split this into multiple agents", "how should
  agents hand off work to each other", "design a multi-agent system for X",
  "which multi-agent topology fits this", "how do I prevent coordination
  failures", "when should I use MCP vs A2A", "supervisor pattern vs fan-out".
  Do not use for single-agent pattern selection (use agentic-system-design)
  or production readiness (use deployment-readiness).
allowed-tools:
  - Read
  - Write
metadata:
  category: architecture
  version: "0.1.0"
---

# Multi-Agent Orchestration

Multi-agent topology, coordination, and protocol design skill. Starts with the single-agent default check, selects a topology only when justified, defines handoff contracts, and flags coordination anti-patterns.

## When to Use

**Use when:**
- Deciding whether to split a single agent into multiple agents
- Selecting a multi-agent topology for a design that already cleared the single-agent default
- Defining handoff contracts between agents
- Diagnosing coordination failures (agents duplicating work, wrong topology, state conflicts)
- Choosing MCP vs A2A vs framework-level orchestration
- Designing a supervisor/critic pattern, parallel fan-out, or shared-state swarm

**Do not use when:**
- The agent design hasn't been validated at single-agent level first → use `agentic-system-design`
- Context window or memory design questions → use `context-engineering-for-agents`
- Production gates, guardrails, or deployment posture → use `deployment-readiness`
- Eval strategy → use `agent-eval-design`

## Workflow

### Step 1 — Gather inputs

Ask:
1. What is the overall task or workflow?
2. Is this a new design or a diagnosis of an existing multi-agent system?
3. For new designs: has the single-agent approach already been tried or ruled out?
4. What sub-tasks are involved, and are they independent of each other?
5. What are the latency, cost, and auditability constraints?
6. Are any agents built by different teams or vendors (relevant for A2A)?

---

### Step 2 — Apply the single-agent default

**Multi-agent adds real costs:** 30–50% token premium, 100–500ms per handoff, significantly more complex debugging. Do not add it unless the single-agent approach is genuinely insufficient.

Proceed to topology selection only if at least one of the **four upgrade triggers** is present:

| Upgrade trigger | Description | Fail signal (do NOT split if...) |
|---|---|---|
| **Context Pollution** | A subagent can absorb high-volume irrelevant context and return a compact summary | The lead agent actually needs the full reasoning path, not just the conclusion |
| **Tool Overload** | Single agent has 15–20+ tools; tool selection quality degrades; tools cluster by domain, permission scope, or risk level | Dynamic tool masking (logit masking) can solve the problem more cheaply |
| **Conflicting Specialist Roles** | The task requires behavioral modes that actively conflict (e.g., empathetic support vs. adversarial security review vs. strict compliance auditor) | The roles are sequential phases that all need the same context |
| **Independent Parallel Workstreams** | Sub-tasks are genuinely independent; they only share final outputs | Intermediate findings from one stream need to change another's work in real time |

**If none of the four triggers applies:** Recommend a more powerful single-agent model, better context management, or pattern composition before adding agents.

**Decompose by context, not by job title.** The right split is where one agent can operate from a compact handoff contract — not at org-chart boundaries like "planner → implementer → reviewer."

---

### Step 3 — Select a topology

| Topology | When to use | Primary failure mode | Required safeguard |
|---|---|---|---|
| **Sequential Pipeline** | Fixed auditable workflow; each stage has a defined output contract; control flow is predictable | Downstream laundering — early error gets polished into confident wrong output | Validation gate at every stage boundary |
| **Hub-and-Spoke (Manager-Worker)** | One agent owns UX; subtasks produce clear structured outputs; auditability required | Orchestrator bottleneck — Specialist A's finding for Specialist B must route through manager | Manager issues work orders, not vague intent; structured output contracts per specialist |
| **Parallel Fan-Out (Agent Teams)** | Subtasks are genuinely independent; long-running; coverage matters more than latency | False independence — workers collide through shared resource or hidden dependency | Explicit partition ownership; locking/versioning/merge protocol for any shared resource |
| **Supervisor-with-Critic** | Quality-critical output; evaluation criteria separable from generation; wrong answer cost > additional generation cost | Rubber-stamp verifier — weak criteria cause verifier to approve plausible-but-wrong output | Verifier outputs structured verdicts: `PASS`, `REVISE`, `ESCALATE` with evidence and severity |
| **Message Bus** | Event-driven workflow; agent types grow over time; extensible routing | Silent routing failure — router misclassifies; nothing crashes; system just fails to act | Correlation IDs, causality metadata, producer identity, schema version, retry/dead-letter behavior |
| **Shared-State Swarm** | Collaborative research; evolving knowledge base; no single point of failure | Reactive loops — agents react to each other's outputs indefinitely without convergence | Append-only event log; explicit termination condition (token budget, convergence score, or judge agent) |
| **Peer-to-Peer Handoff** | Conversational triage; responsibility transfers cleanly; specialists know their own boundaries | Accountability loss — no component owns the final answer | Handoff transfers authority, not just context; add handoff ledger and escalation policy |

**Topology composition is common and valid.** State the composition and its rationale explicitly (e.g., Hub-and-Spoke routing to Parallel Fan-Out for independent research subtasks).

---

### Step 4 — Define handoff contracts

Every inter-agent boundary requires a handoff contract. Vague delegation is the most common coordination failure.

Minimum required fields:

```yaml
task_id: string
parent_trace_id: string
requesting_agent: string
receiving_agent: string
objective: string            # specific, not "do the research thing"
scope:
  in_scope: [...]
  out_of_scope: [...]
inputs:
  artifacts: [...]           # pass by reference, not by value
  source_refs: [...]
constraints:
  allowed_tools: [...]
  forbidden_actions: [...]
budget:
  max_steps: int
  max_tokens: int
output_contract:
  schema: {...}
  acceptance_criteria: [...]
  citation_required: boolean
failure_policy:
  on_tool_error: string
  on_low_confidence: string
  on_budget_exceeded: string
```

**Pass artifacts by reference, not by value.** Sending full document contents through every handoff burns tokens and introduces summarization drift. Pass file paths or storage references instead.

**Verifier contracts require structured verdicts.** Verifiers must return `PASS`, `REVISE`, or `ESCALATE` with: failing criteria, evidence, severity, and the count of revisions allowed remaining. "Check if this is good" is not a verifier contract.

---

### Step 5 — Assign agent roles

| Role | Responsibility | Key constraint |
|---|---|---|
| **Orchestrator / Manager** | Decompose goals, delegate via work orders, synthesize outputs | Broad context; strict output contracts; must not pass vague intent to workers |
| **Specialist / Worker** | Execute narrow domain work with focused toolset | Small context; narrow toolset; clear ownership of one domain |
| **Critic / Verifier** | Evaluate outputs against explicit criteria | Independent context; must use criteria not subjective judgment; structured verdicts |
| **Guardian / Monitor** | Enforce safety, policy, cost, permission limits | Veto authority; conservative thresholds; always-on; audit logs |
| **Memory Keeper** | Retrieve, compress, and curate shared state | High-precision retrieval; recency policy; source tracking |

---

### Step 6 — Choose protocols and framework

**MCP vs A2A — boundary decision:**

| Protocol | Use for | Not for |
|---|---|---|
| **MCP** | Agent-to-tool/data boundary — how an agent discovers and invokes tools, reads resources, negotiates capabilities | Agent-to-agent coordination — use A2A instead |
| **A2A** | Agent-to-agent boundary — coordinating with independently deployed agents (different team, vendor, or framework) | Replacing normal API engineering; still need auth, rate limits, logs |

**Common mistake:** Adopting MCP expecting multi-agent governance. MCP is a tool boundary, not an agent boundary.

**Framework selection decision path:**

1. Need graph state + checkpoint/resume/HITL? → **LangGraph**
2. Role-based business automation with crews? → **CrewAI**
3. In Azure/.NET enterprise? → **Microsoft Agent Framework**
4. RAG-heavy with complex orchestration? → **LlamaIndex + LangGraph**
5. Type-safe Python with strong structured outputs? → **PydanticAI**
6. Code-first OpenAI stack with guardrails? → **OpenAI Agents SDK**
7. In Google Cloud? → **Google ADK / Vertex Agent Engine**
8. Framework assumptions don't fit? → **Custom orchestration** (own retries, replay, traces, evals, safety)

**Before committing to a framework:** Pilot with production-shaped constraints — long-running state, HITL gates, tool failures, auth failure, schema evolution, trace inspection. Every framework eventually exposes its abstractions. Choose the framework whose failure modes you can tolerate.

---

### Step 7 — Flag coordination anti-patterns

Check the design against the **coordination anti-pattern table**:

| Anti-pattern | Diagnostic signal | Fix |
|---|---|---|
| **Shared Scratchpad Trap** | Agents write unstructured prose to shared state; contradictions collapse into confident conclusions | Replace with append-only event log; typed findings with evidence, confidence, source, timestamp |
| **Vague Delegation** | Subagent duplicates work or has coverage gaps; unclear authority | Work order must include objective, scope, allowed tools, forbidden actions, output schema, budget, fallback |
| **Orchestrator Bottleneck** | All information routes through manager; Specialist A's finding for Specialist B requires manager recognition | Move event routing to message bus or isolate collaborative subtasks in shared state |
| **Rubber-Stamp Verifier** | Verifier approves plausible-but-wrong output; quality theater | Verifier criteria must be explicit and independently verifiable; structured verdict required |
| **Silent Routing Failure** | Events disappear; no exception, just non-action | Track event lifecycle (not just agent outputs); correlation IDs, dead-letter queues |
| **Reactive Loop** | Agents react to each other's outputs indefinitely; no convergence | Explicit termination condition; token/step budget; convergence threshold |
| **Tool Poisoning** | Agents behave incorrectly while validation passes | Review tool descriptions like code; validate I/O strictly; pin server versions; sandbox execution |
| **False Independence** | Parallel agents collide through shared resource or hidden dependency | Explicit partition ownership; locking or versioning for any shared resource |

---

### Step 8 — Produce the orchestration design output

Produce a structured design with:

1. **Single-agent default check** — upgrade triggers present / not present
2. **Selected topology** — with rationale and failure mode mitigations
3. **Agent role assignments** — role, responsibility, toolset, output contract
4. **Handoff contracts** — one contract per inter-agent boundary (use the schema from Step 4)
5. **Protocol decisions** — MCP and/or A2A with rationale
6. **Framework recommendation** — with selection rationale
7. **Anti-patterns flagged** — any detected in the design with fixes
8. **Open questions** — design decisions that need more information

## Output Format

Structured Markdown covering the eight sections above.

If this output is part of an architecture review (called from `agentic-system-design`), return the topology section as the multi-agent component of the architecture output.

## Scope Boundaries

This skill does not:
- Select agent tiers or single-agent patterns → `agentic-system-design`
- Design context or memory architecture → `context-engineering-for-agents`
- Design production guardrails, HITL gates, or deployment posture → `deployment-readiness`
- Design eval strategy → `agent-eval-design`
- Implement the chosen framework — it selects and specifies; implementation is the engineer's responsibility
