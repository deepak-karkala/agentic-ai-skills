# Scenario: Debugging a Runaway Cost Incident via Session Replay

## Trigger

> "What should I trace for this agent?"
>
> "We had a runaway loop incident last week — our procurement agent kept retrying a failed API call in a loop and racked up $1,200 in API costs before we noticed. We're now redesigning observability. What do we need to trace?"

## Skill: agent-observability

### Inputs gathered

1. Agent: Procurement agent (ReAct loop); fetches vendor data, compares quotes, creates POs
2. Incident: API call failure → agent entered retry loop; 400+ tool calls; $1,200 API cost over 2 hours
3. Current observability: Basic error logging; no structured traces; no circuit breakers
4. Infrastructure: Self-hosted (prefer open-source); using LangChain
5. Improvement loop: None — failures identified from billing alerts, not from trace analysis

### Step 2 — Telemetry spine gaps (what was missing)

Current state vs. minimum viable:

| Instrument | Present? | Impact of absence |
|---|---|---|
| Per-request trace with trace_id | No | Could not reconstruct the session replay; had to infer the loop from billing logs |
| LLM call spans with token counts | No | Cost attribution unavailable during incident; discovered only from invoice |
| Tool call spans with status + latency | Partial (errors logged, not spans) | Could not see the retry pattern; 400+ calls looked like one event in logs |
| Session end event | No | No session-level cost summary; no aggregate health metrics |
| Business outcome event | No | Unknown whether any POs were created during the incident |

**Verdict:** 0/5 minimum viable instruments in place. This is why the incident was invisible until the billing alert.

### Step 3 — MELT strategy designed

**Metrics (with alert thresholds):**

| Metric | Target | Alert |
|---|---|---|
| Task Completion Rate | ≥ 85% | < 70% |
| Token cost per task | < $0.30 | > $1.00 per task |
| Cost per hour | < $25 | > $100/hr → immediate page |
| Budget circuit breaker trips | 0 normal | Any trip |
| Tool call latency p95 | < 2s | > 10s → external API issue |

**Events to add:**
- `tool.invocation.started` / `completed` / `failed` — all three, on every call
- `circuit_breaker.tripped` — type=cost, type=loop — both required
- `session.goal.completed` / `session.goal.failed` — needed to distinguish TCR from GCR

**Logs:** Add structured logging for every tool call: tool name, arguments hash (NOT arguments), result status, error type.

**Traces:** Full span hierarchy — session → agent → LLM call + tool execution spans.

### Step 4 — Span hierarchy for procurement agent

```
Session Span
│  gen_ai.session.id, user_id, agent_type="single-agent"
│
└── Agent Span
      gen_ai.agent.id="procurement-agent"
      autonomy_level="L3"
      goal_description="compare quotes, select vendor, create PO"
      
      ├── LLM Call Spans (one per reasoning step)
      │     model="claude-sonnet-4-6"
      │     prompt_token_count, completion_token_count
      │     finish_reason
      │
      ├── Tool Execution Spans (one per tool invocation)
      │     tool_name (e.g., "fetch_vendor_quote")
      │     tool_status: "success" | "error"
      │     input_args_hash, latency_ms
      │     error_type (when status=error)
      │
      └── Output Guardrail Span
            guardrail_type="cost-budget"
            triggered=false (normally) | true (on trip)
```

**During the incident, this span tree would have shown:**
- Tool Execution Span: `fetch_vendor_quote` with status=error, error_type=EXTERNAL_UNAVAILABLE
- Repeated 80+ times in the trace — immediately visible as a pattern
- LLM Call Spans showing the agent reasoning "I should try again" each time
- No circuit breaker span (it didn't exist) → root cause of the incident

### Step 5 — Session replay design

Platform selected: **Langfuse** (self-hostable, MIT license, OTel-native, ~15% overhead acceptable at current volume)

Session linkage: `sessionId` = procurement task ID, propagated via HTTP header across all calls within one task

Debugging workflow for the previous incident (hypothetically):
1. Alert: cost circuit breaker trips at $0.50 session budget
2. Open Langfuse session replay; navigate to trace by session_id
3. Step through spans: LLM call → tool call (fail) → LLM call → tool call (fail) → ...
4. Identify: agent received EXTERNAL_UNAVAILABLE on step 3; did not have retry budget; continued loop
5. Root cause: no tool failure circuit breaker; no structured error with retry_guidance
6. Fix: add tool failure circuit breaker (threshold=3, reset_after=60s); add retry_guidance to tool error response

### Step 6 — Circuit breakers configured

**Cost budget circuit breaker:**
- Session limit: $0.50 (P99 expected cost × 3 = ~$0.15 × 3 = $0.45 → round to $0.50)
- Hour limit: $100 (maximum acceptable per-hour API spend)
- Placed: in the LangChain tool wrapper layer (outside agent code)

**Runaway loop circuit breaker:**
- MAX_STEPS: 25 (procurement tasks rarely exceed 12 steps in production)
- Pattern detection: 6-action lookback window

**Tool failure circuit breaker:**
- Threshold: 3 consecutive failures
- Reset after: 60 seconds
- Per-tool: `fetch_vendor_quote` (external API, slower recovery) → reset_after=120s

### Step 7 — Continuous improvement flywheel

The incident was not in the eval dataset — it was discovered from a billing alert. After observability is in place:

- **Monitor:** Cost circuit breaker trips → immediate alert → session flagged for review
- **Evaluate:** Session replay shows failure pattern → annotate root cause (EXTERNAL_UNAVAILABLE loop)
- **Improve:** Add tool failure circuit breaker + structured error with retry guidance → regression test
- **Deploy:** Canary 10% → compare tool failure rate → roll out
- **Cycle time target:** Incident → eval annotation within 24h → fix deployed within 1 sprint

### Output

`.agentic/artifacts/observability-procurement-agent.md`

```
Observability Plan: Procurement Agent

Telemetry spine: 0/5 instruments in place → all 5 to be added in Phase 1

Critical gaps (caused last week's incident):
1. No tool call spans → loop was invisible until billing alert
2. No cost circuit breaker → $1,200 damage before detection
3. No loop circuit breaker → 400+ redundant tool calls

Platform: Langfuse (self-hosted, OTel-native)

Circuit breakers to add:
- Cost: $0.50/session, $100/hour (outside agent code)
- Loop: MAX_STEPS=25, pattern detection enabled
- Tool failure: threshold=3, reset=60s (vendor API: 120s)

Implementation phases:
- Phase 1 (this sprint): telemetry spine + circuit breakers
- Phase 2 (next sprint): full MELT + session replay
- Phase 3 (month 2): improvement flywheel + anomaly detection

Next step: /agentic-evals to design the eval harness that the 
improvement flywheel feeds into.
```
