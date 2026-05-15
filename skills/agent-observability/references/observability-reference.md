# Observability Reference

Reference for the `agent-observability` skill. Contains the full OpenTelemetry span hierarchy, event catalog, metric reference with alert thresholds, circuit breaker configurations, platform comparison, and the continuous improvement flywheel details.

---

## Full OpenTelemetry Span Hierarchy

```
Session Span (root)                      [span kind: SERVER or CONSUMER]
│  Attributes:
│    gen_ai.session.id       — unique session identifier
│    user_id                 — anonymized or hashed user identifier
│    agent_type              — "single-agent" | "supervisor-worker" | "pipeline"
│    total_duration_ms       — end-to-end wall clock
│    final_status            — "success" | "failure" | "escalated" | "timeout"
│
├── Agent Span                           [span kind: AGENT]
│     gen_ai.system          — "anthropic" | "openai" | "google" | "custom"
│     gen_ai.agent.id        — unique agent identifier
│     autonomy_level         — "L1" | "L2" | "L3" | "L4"
│     goal_description       — brief task description (no PII)
│     total_steps            — number of reasoning steps taken
│     total_tool_calls       — number of tool calls made
│     total_input_tokens     — sum across all LLM calls
│     total_output_tokens    — sum across all LLM calls
│     final_status           — success | failure | escalated
│
│     ├── LLM Call Span                  [span kind: LLM]
│     │     gen_ai.request.model         — model identifier
│     │     gen_ai.request.type          — "chat" | "completion"
│     │     prompt_token_count           — tokens in
│     │     completion_token_count       — tokens out
│     │     finish_reason                — "stop" | "max_tokens" | "tool_use" | "error"
│     │     latency_ms                   — LLM inference time only (exclude tool wait)
│     │     step_number                  — position in the reasoning loop
│     │     [events: prompt_sent, completion_received]
│     │
│     ├── Tool Execution Span            [span kind: TOOL]
│     │     gen_ai.tool.name             — tool identifier
│     │     gen_ai.tool.call_id          — unique call ID (for correlating with logs)
│     │     gen_ai.tool.description      — tool description (for replay)
│     │     tool_status                  — "success" | "error" | "timeout"
│     │     input_args_hash              — SHA256 of arguments (NOT the arguments themselves)
│     │     result_size_bytes            — size of the tool's return value
│     │     latency_ms                   — tool execution time (including network)
│     │     error_type                   — if status=error: error code
│     │
│     ├── RAG Retrieval Span             [span kind: RETRIEVER]
│     │     retrieval_query              — the query sent to retrieval (no PII)
│     │     doc_count_returned           — number of documents retrieved
│     │     vector_similarity_scores     — top-k scores as array
│     │     retrieval_latency_ms         — retrieval time
│     │     index_name                   — which index was queried
│     │     top_k_requested              — k value
│     │
│     ├── Memory Operation Span          [span kind: CHAIN]
│     │     operation                    — "write" | "retrieve" | "evict" | "compress"
│     │     memory_tier                  — "in-context" | "external" | "episodic"
│     │     key_id                       — anonymized key identifier
│     │     hit_or_miss                  — "hit" | "miss" (for retrieve operations)
│     │     memory_size_bytes            — size of the memory object
│     │
│     └── Sub-Agent Delegation Span      [span kind: AGENT]
│           to_agent_id                  — receiving agent's identifier
│           delegated_task               — task description (no PII)
│           handoff_latency_ms           — time to receive the delegated result
│           returned_result_status       — "success" | "failure" | "partial"
│
└── Output Guardrail Span                [span kind: GUARDRAIL]
      guardrail_type          — "input" | "output" | "tool-call" | "safety"
      triggered               — boolean
      action_taken            — "allow" | "block" | "sanitize" | "escalate"
      latency_ms              — guardrail evaluation time
```

---

## Event Catalog

Standard events to emit (structured, timestamped, keyed to the parent span):

| Event | Attributes | When to emit |
|---|---|---|
| `tool.invocation.started` | agent_id, tool_name, call_id | Before every tool call |
| `tool.invocation.completed` | tool_name, call_id, result_status, duration_ms | After every tool call |
| `tool.invocation.failed` | tool_name, call_id, error_type, retry_count | On tool failure |
| `guardrail.triggered` | layer, reason, action_blocked | When any guardrail fires |
| `hitl.escalation` | agent_id, task_id, risk_tier, reason | When agent routes to human |
| `circuit_breaker.tripped` | type (cost\|loop\|tool_failure), threshold, current_value | On circuit break |
| `memory.operation` | operation, memory_tier, key_id, hit_or_miss | On memory read/write |
| `agent.handoff.initiated` | from_agent_id, to_agent_id, context_size_tokens | On agent delegation |
| `session.goal.completed` | goal_description, outcome_verified | When goal is achieved |
| `session.goal.failed` | goal_description, failure_reason | When goal is not achieved |

---

## Metric Reference with Alert Thresholds

### Performance Metrics

| Metric | Description | Target | Warning | Alert |
|---|---|---|---|---|
| Task Completion Rate (TCR) | % tasks completed without error | ≥ 90% | < 85% | < 75% |
| Goal Completion Rate (GCR) | % tasks where business objective achieved | ≥ 80% | < 75% | < 65% |
| Total trajectory latency p95 | End-to-end wall clock | < 30s (typical) | > 45s | > 60s |
| LLM inference latency p95 | Inference time per call | < 5s | > 8s | > 15s |
| Tool call latency p95 | Tool execution time per call | < 3s | > 5s | > 10s |

**The TCR/GCR distinction is critical.** A 100% TCR with 60% GCR means the agent is completing its assigned steps but not achieving the underlying business goal. This indicates a task decomposition problem — the tasks don't map to the goal — not an execution problem. Review the step design before looking at the prompt.

### Cost Metrics

| Metric | Description | Alert |
|---|---|---|
| Token cost per task | input + output tokens × model price | > 2× baseline |
| Cost per successful completion | TCR-normalized cost | > 3× baseline |
| Budget circuit breaker trips | Sessions that exceeded cost budget | Any trip → investigate |
| Tool call cost by tool | API cost attribution per tool | > 50% of session cost on one tool |

### Quality Metrics

| Metric | Description | Alert |
|---|---|---|
| Revert-to-human rate | % sessions escalated to human | > 15% → systematic failure |
| Override rate (HITL) | % approvals where human changes the output | > 30% → agent accuracy issue |
| Hallucination rate | % outputs flagged by validator | > 5% → systematic |
| Guardrail trigger rate by type | % sessions triggering each guardrail | > 10% on any guardrail |

---

## Circuit Breaker Configuration Reference

### Cost Budget Circuit Breaker

```python
# Recommended starting values — calibrate to P99 session cost × 3
CostCircuitBreaker(
    session_limit_usd=0.50,    # Max cost per session
    hour_limit_usd=50.0        # Max cost per hour across all sessions
)
```

**Where to place it:** In the tool gateway or orchestration layer — NOT inside the agent code. An agent that evaluates its own budget constraint can accidentally (or through injection) bypass the check.

**On trip:** Suspend the session, log the terminal state, return a state snapshot for potential resumption.

### Runaway Loop Circuit Breaker

```python
LoopCircuitBreaker(
    max_steps=25,          # Absolute step limit
    lookback_window=6,     # Actions to inspect for repeating patterns
    # Pattern: if last 6 actions = [A,B,C,A,B,C], trip the breaker
)
```

**Calibration:** For focused task agents (invoice processing, ticket resolution): 10–15 steps. For research or multi-phase agents: 25–50 steps. Never "just set it high" — a higher limit means a more expensive runaway.

### Tool Failure Circuit Breaker

```python
ToolFailureCircuitBreaker(
    threshold=3,           # Consecutive failures before opening circuit
    reset_after_s=60       # Retry window after opening
)
```

**Per-tool calibration:** Some tools (rate-limited APIs) benefit from longer reset windows (120s+). External services with known flakiness should have higher thresholds (5+) if partial failures are acceptable.

---

## Observability Platform Comparison (2025)

| Platform | Performance overhead | Multi-agent | Self-hostable | Best for |
|---|---|---|---|---|
| **LangSmith** | ~0% | Full OTel + execution visualization | No (SaaS) | LangGraph/LangChain teams; deepest framework integration; native session replay |
| **Langfuse** | ~15% | `sessionId` propagation, HTTP header trace IDs | Yes (MIT license) | Framework-agnostic teams; cost-sensitive; self-hosted; OTel-native |
| **Arize / Phoenix** | ~12% | Full multi-step trace, 10 span kinds | Phoenix: yes | MLOps-mature teams extending to agents |
| **Datadog LLM Obs.** | <5% (estimated) | Service maps across agent services | No (SaaS) | Enterprise Datadog customers; June 2025: Bedrock, OpenAI SDK, Google ADK |
| **Dynatrace** | <5% (estimated) | Full-stack multi-cloud multi-agent | No (SaaS) | Infrastructure-first enterprise; LangChain, ADK, OpenAI Agents, MCP, Bedrock |

**OTel as the portability layer:** All platforms accept OpenTelemetry spans (2025). Instrument to OTel GenAI Semantic Conventions v1.37 and you are not locked to any single backend. Export to multiple backends simultaneously if needed.

**Privacy-first instrumentation:** Never log raw tool arguments in spans — use the argument hash. Never log the full context window unless GDPR/HIPAA scope has been reviewed. Log the minimum required for debugging.

---

## The AITL Production Data Flywheel

The AITL (Agent-in-the-Loop) framework formalizes the connection between production traces and evaluation improvement. Four annotation types integrated into live operations:

| Annotation type | Production signal | Use in eval |
|---|---|---|
| Pairwise preferences | Human comparison of two agent responses | Train reward model; curate golden fixtures |
| Agent adoption rationale | Which tool/decision was correct and why | Improve task decomposition; tool description quality |
| Knowledge relevance | Was the retrieved document actually useful? | RAG retrieval quality; index optimization |
| Missing knowledge | What did the agent try to find but couldn't? | Knowledge gap identification; corpus expansion |

**Observed impact (AITL production deployment):** +11.7% retrieval recall, +14.8% retrieval precision, +8.4% generation helpfulness, +4.5% recommendation adoption — over 6 weeks of flywheel operation. Retraining cycles compressed from months to weeks.

**Implementation checklist:**
- [ ] Flagged sessions routed to review queue within 24h
- [ ] Human reviewers have access to full session replay
- [ ] Annotation tool captures the four annotation types above
- [ ] Annotations flow into eval dataset within 48h
- [ ] Eval dataset used for regression testing on every prompt/tool change
- [ ] Deployment uses canary (5–10% traffic) before full rollout
- [ ] Rollback is automated within 5 minutes if metrics regress

---

## Minimum Viable Observability Checklist

Before any agent goes to production, verify these 8 items are in place:

- [ ] Every request has a `trace_id`
- [ ] Every LLM call emits a span with token counts and finish reason
- [ ] Every tool call emits a span with status and latency
- [ ] Session start and end events are emitted
- [ ] At least TCR and cost-per-task are being measured
- [ ] Cost budget circuit breaker is configured (outside agent code)
- [ ] Step limit circuit breaker is configured
- [ ] Logs are immutable and retained per compliance requirements

Without these 8 items, a production incident cannot be diagnosed. Do not deploy without them.
