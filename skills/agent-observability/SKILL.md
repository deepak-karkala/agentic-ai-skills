---
name: agent-observability
description: >
  Designs the observability strategy for an agentic AI system. Covers the
  MELT telemetry framework (Metrics, Events, Logs, Traces) adapted for
  agents, the OpenTelemetry hierarchical span model, session replay design,
  circuit breaker configuration, KPI selection, cost and latency visibility,
  tooling platform selection, and the continuous improvement flywheel that
  connects production traces to eval and improvement. Goes deeper than the
  observability section embedded in deployment-readiness. Use when designing
  observability from scratch for a new agent system, when debugging production
  agent failures with insufficient trace information, when tracing strategy
  for a multi-step or multi-agent workflow needs to be structured, or when
  connecting production monitoring to the evaluation and improvement process.
  Trigger phrases: "what should I trace for this agent", "how do I debug
  agent failures in production", "design observability for this agent system",
  "what metrics matter for this agentic workflow", "set up session replay
  for this agent", "design the telemetry strategy for this agent",
  "how do I connect production traces to our evals", "configure circuit
  breakers for this agent", "what's the minimum observability I need before
  going to production".
  Do not use for designing deployment guardrails and the MELT overview at
  the deployment-readiness level (use deployment-readiness for the guardrail
  and rollout posture), for eval scorecard and grader design (use
  agent-eval-design), or for agent architecture (use agentic-system-design).
allowed-tools:
  - Read
  - Write
metadata:
  category: technical
  version: "0.1.0"
---

# Agent Observability

Observability design skill. Designs the full telemetry strategy for an agentic AI system — MELT framework, OpenTelemetry span hierarchy, session replay, circuit breakers, KPI selection, tooling platform, and the continuous improvement flywheel. Produces a concrete observability plan.

## When to Use

**Use when:**
- Designing observability infrastructure for a new agent before production deployment
- Current traces are insufficient to debug production failures
- Need to structure the tracing strategy for a multi-step or multi-agent workflow
- Connecting production monitoring to the evaluation and improvement process
- Selecting and configuring an observability platform (LangSmith, Langfuse, Datadog, etc.)

**Do not use when:**
- The question is about deployment guardrails, rollout posture, or the high-level MELT checklist → use `deployment-readiness`
- The question is about eval scorecard design, grader selection, or golden fixtures → use `agent-eval-design`
- The question is about agent architecture → use `agentic-system-design`

## Workflow

### Step 1 — Gather context

Ask the user:
1. What is the agent's architecture? (Single agent, supervisor-worker, pipeline?)
2. What is the deployment context? (Internal tool, customer-facing, regulated industry?)
3. What observability infrastructure exists today? (OpenTelemetry, APM platform, logging stack?)
4. What are the primary failure modes you're concerned about? (Cost runaway, wrong tool selection, silent failures, latency?)
5. Is there a current improvement loop from production failures back to prompts or evals?

If the user has an existing trace setup, read what's captured and what's missing. Design to extend, not replace.

---

### Step 2 — Select the telemetry spine

The minimum instrumentation every production agent must have. Do not wait for a production incident to add this — the cost of retrofitting is 10× the cost of building it in.

**Five required instruments:**

1. **Per-request trace (OpenTelemetry):** Every request gets a `trace_id`. Every span is tagged with `trace_id` and `parent_span_id`. No request should be untraced.

2. **LLM call spans:** Every call to an LLM must emit a span with: model name, input token count, output token count, latency, finish reason. This is the cost attribution spine.

3. **Tool call spans:** Every tool invocation must emit a span with: tool name, input argument hash (not the arguments — for privacy), result status, latency. If the tool fails, the span must capture the error type.

4. **Session boundary events:** Session start and session end events with total duration, total tokens, total tool calls, final status (success / failure / escalated). These are the aggregate health metrics.

5. **Business outcome event:** Whether the agent achieved its goal — not just whether it completed without error. A 100% completion rate with 60% goal achievement means the task decomposition is wrong.

See [Observability Reference](references/observability-reference.md) for the full OpenTelemetry span hierarchy and event catalog.

---

### Step 3 — Design the MELT strategy

Specify what to instrument in each MELT tier:

**Metrics (quantitative, sampled at intervals):**

Core performance:
- Task Completion Rate (TCR): % of tasks completed without error
- Goal Completion Rate (GCR): % of tasks where the business objective was achieved
- Total trajectory latency (p50/p95/p99)
- LLM inference latency per call
- Tool call latency by tool name (p50/p95/p99)

Core cost:
- Token cost per task (input + output × model price)
- Cost per successful completion (TCR-normalized)
- Budget circuit breaker trip rate

Core quality:
- Revert-to-human rate (HITL escalation rate)
- Override rate (for supervised deployments — how often the human changes the agent's output)
- Hallucination rate (if a validator exists)

Alert thresholds: Define specific numeric targets for each metric. A metric without a target is data, not monitoring.

**Events (discrete, timestamped):**
- Tool invocation started / completed / failed
- Guardrail triggered (layer, reason, action blocked)
- HITL escalation (agent_id, reason, risk tier)
- Circuit breaker tripped (type: cost | loop | tool failure)
- Memory operation (write / retrieve / evict)
- Agent handoff (in multi-agent systems: from_agent, to_agent, context_size)

**Logs (structured, immutable):**
Must capture (for debugging and compliance):
- The exact prompt sent to the LLM (not paraphrased)
- Context state at each LLM call (memory retrieved, documents injected)
- Tool call intent as structured parameters
- Tool result (raw output)
- Confidence signal if available
- Human decision at HITL gates (the reviewer's response and any modifications)

Immutability requirement: For regulated deployments (EU AI Act high-risk systems), audit logs must be tamper-proof and retained per regulatory schedule (up to 10 years). Design WORM storage into the logging architecture from day one.

**Traces (full trajectory per request):**
The debugging locus for agents. When a failure occurs, the trace is what you open — not the log tail, not the stack trace. The trace shows the sequence: what the agent planned, what it retrieved, what tool it called, what came back, how that changed the next decision.

---

### Step 4 — Design the OpenTelemetry span hierarchy

Map the span tree for this specific agent. Use this structure as the template:

```
Session Span (root)
│  gen_ai.session.id, user_id, agent_type, total_duration_ms
│
├── Agent Span
│     gen_ai.agent.id, autonomy_level
│     goal_description, total_steps, final_status
│
│     ├── LLM Call Span
│     │     model, prompt_token_count, completion_token_count
│     │     finish_reason, latency_ms
│     │
│     ├── Tool Execution Span
│     │     tool_name, tool_call_id, input_args_hash
│     │     tool_status, result_size_bytes, latency_ms
│     │
│     ├── RAG Retrieval Span (if applicable)
│     │     retrieval_query, doc_count, similarity_scores
│     │     retrieval_latency_ms
│     │
│     ├── Memory Operation Span (if applicable)
│     │     operation, memory_tier, hit_or_miss
│     │
│     └── Sub-Agent Delegation Span (multi-agent only)
│           to_agent_id, delegated_task, handoff_latency_ms
│
└── Output Guardrail Span
      guardrail_type, triggered, action_taken, latency_ms
```

For each span type in the actual agent, specify:
- Required attributes
- Optional attributes worth capturing for debugging
- Privacy requirements (what must NOT be logged — PII, secrets, PHI)

---

### Step 5 — Design session replay

Session replay reconstructs the agent's full execution sequence after the fact — navigable step by step.

**What replay must reconstruct:**
- The exact context window content at each LLM call (not a summary — the actual tokens, subject to privacy constraints)
- The gap between the agent's stated reasoning and its actual tool call
- The retrieval that the agent received — and whether it was the retrieval that caused the wrong answer
- The step where a prompt injection from a retrieved document entered the context

**Replay implementation:**

1. **Trace storage:** All spans exported to a backend that supports trace visualization (LangSmith, Langfuse, Datadog LLM Obs., Arize Phoenix)
2. **Session linkage:** All spans for a session share a `session_id` — not just a `trace_id`. Multi-turn sessions require session-level grouping.
3. **Replay navigation:** The trace backend must support stepping through spans chronologically and viewing the context window at each LLM call span

**Practical debugging workflow:**
1. Alert or user report flags session as anomalous
2. Open session replay
3. Step through spans chronologically
4. Identify the first divergence from expected trajectory
5. Examine the context window at that span — what did the agent see?
6. Examine the tool call — correct tool? Correct arguments?
7. Examine the tool output — did the tool return what was expected?
8. Form hypothesis: the divergence originated at [span N]; root cause: [retrieved document / malformed tool output / context overflow]
9. Fix; add failing case to golden dataset for regression testing

---

### Step 6 — Configure circuit breakers

Circuit breakers interrupt runaway agent behavior before it propagates to cost, user impact, or data loss.

**Three circuit breaker types to configure:**

**1. Cost budget circuit breaker:**
- Session budget: max spend per workflow execution (define based on P99 expected cost × 3)
- Hourly budget: max spend per hour across all sessions (protection against volume spikes)
- Must live outside the agent code — in the tool gateway or orchestration layer

**2. Runaway loop circuit breaker:**
- Step limit: define MAX_STEPS before implementation (recommended: 10–25 for most tasks, up to 50 for research agents)
- Pattern detection: if the last 6 actions contain a 3-action repeating sub-pattern, trip the breaker
- Consecutive identical tool calls: if the agent calls the same tool with the same arguments 3 consecutive times, trip the breaker

**3. Tool failure circuit breaker:**
- Consecutive failure threshold: after N consecutive failures on the same tool (recommended: 3), open the circuit
- Reset after: 60 seconds (attempt one retry to check if the tool has recovered)
- Behavior when open: return a structured error to the agent — do not attempt the call

**Alert on every circuit breaker trip:** A trip is a signal that something is wrong, not just a normal edge case. Circuit breaker trips should flow to the monitoring alert queue, not disappear silently.

---

### Step 7 — Select the tooling platform

Recommend a platform based on the agent's architecture and the team's existing infrastructure:

| If the team uses... | Recommended platform |
|---|---|
| LangGraph / LangChain | LangSmith — native integration, session replay, multi-turn eval |
| Framework-agnostic or custom | Langfuse — open-source, self-hostable, OTel-native |
| Existing Datadog infrastructure | Datadog LLM Observability — add-on to existing APM |
| MLOps-mature team (Arize for ML) | Arize Phoenix — extends existing ML observability to agents |
| Dynatrace infrastructure (enterprise) | Dynatrace — full-stack from UI to GPU, multi-agent support |

**OTel export:** All platforms accept OpenTelemetry spans as of 2025. Instrument to OTel standards and you are not locked to one backend. Design the instrumentation once; fan out to multiple backends if needed.

---

### Step 8 — Design the continuous improvement flywheel

Connect observability to evaluation and improvement — the full AgentOps loop.

**Monitor → Evaluate → Improve → Deploy:**

1. **Monitor:** Production traces surface failure signals (low TCR sessions, guardrail trips, escalations, user overrides)
2. **Route flagged sessions to review queue:** Aggregate metrics mask patterns. A 93% success rate hides a systematic failure on a 7% query class. Route flagged sessions to a human review or automated grader queue.
3. **Evaluate:** Flagged sessions become the raw material for the eval dataset. Label: was this a failure? What was the root cause? Add to golden fixtures.
4. **Improve:** Findings feed into prompt updates, tool schema changes, guardrail adjustments. Each change is regression-tested against the golden dataset before deployment.
5. **Deploy safely:** Canary deploy (5–10% traffic); compare metrics against baseline; gradual rollout if metrics hold; automatic rollback if metrics regress.

**Flywheel cadence target:** 
- Flagged session → eval dataset within 2 days
- Eval findings → prompt update within 1 sprint
- Production deployment → monitoring for regression within 24 hours

---

### Step 9 — Write the observability plan

Write a structured observability plan to:
- `artifact_output_path/observability-<agent-name>.md` if `artifact_output_path` is configured in `.agentic/config.yml`
- Otherwise: `.agentic/artifacts/observability-<agent-name>.md`

Use the format:

```markdown
# Observability Plan: <Agent Name>

## Telemetry Spine
[5 required instruments — implemented or not]

## MELT Strategy
[Metrics table with targets and alert thresholds]
[Events catalog]
[Log requirements and retention policy]
[Trace strategy]

## Span Hierarchy
[Customized span tree for this agent]
[Privacy requirements per span]

## Session Replay Design
[Backend selected, session linkage, debugging workflow]

## Circuit Breaker Configuration
[Cost budget, loop limit, tool failure settings]

## Tooling Platform
[Selected platform with rationale]

## Continuous Improvement Flywheel
[Monitor → Evaluate → Improve → Deploy cadence]

## Implementation Priority
[Phase 1: minimum viable (telemetry spine + circuit breakers)]
[Phase 2: full MELT + replay]
[Phase 3: flywheel + anomaly detection]
```

---

### Step 10 — Report

After writing the plan:
1. State the file path.
2. List which telemetry spine instruments are currently in place vs. missing.
3. Flag any metrics with no alert threshold defined.
4. Flag any circuit breaker type not yet configured.
5. Suggest next steps: `agent-eval-design` to design the eval harness that the improvement flywheel depends on, or `deployment-readiness` if the deployment guardrails (HITL gates, rollout posture) need to be designed.

## Output Contract

- **Primary output:** Observability plan at `artifact_output_path/observability-<agent-name>.md` or `.agentic/artifacts/observability-<agent-name>.md`
- **In-conversation summary:** telemetry gaps, metric targets, circuit breaker config, platform recommendation, next steps
- **Does not produce:** deployment guardrails, eval scorecards, agent architecture decisions

## Scope Boundaries

This skill designs the observability and monitoring strategy in depth. It does not design deployment guardrails (route to `deployment-readiness`), eval scorecards (route to `agent-eval-design`), or agent architecture (route to `agentic-system-design`). The observability section in `deployment-readiness` provides a high-level MELT checklist as part of the production readiness gate — this skill goes deeper when a team needs to design or fix their observability infrastructure specifically.
