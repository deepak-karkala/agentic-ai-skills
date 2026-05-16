# Scenario: Rollout Readiness Artifact Generation

## Trigger

> `/agentic-ops`
>
> "Our billing reconciliation agent passed all evals. We're ready to start the rollout conversation with the ops team. Can you produce a rollout readiness document?"

## Command: /agentic-ai-engineering:agentic-ops

## Skill: deployment-readiness → rollout-readiness HTML artifact

### Inputs gathered

1. Agent: Billing reconciliation agent — matches payments to invoices, flags discrepancies, generates reconciliation reports
2. Autonomy level: L2 — autonomous matching and flagging; discrepancies over $5,000 require human review
3. Eval status: 91% TCR, 83% GCR, 6-dimension scorecard at Partial coverage (Trajectory Quality gap resolved last sprint)
4. Observability: LLM call spans in place; tool call spans missing; no cost circuit breaker; session replay not configured
5. Rollout plan: Shadow mode week 1 → 10% live traffic week 2 → full rollout week 4

### Production gate checklist

| Gate | Status | Notes |
|---|---|---|
| Eval suite at minimum viable coverage | Passed | 6-dimension scorecard, Partial→Strong after last sprint |
| TCR ≥ 85% | Passed | 91% on staging traffic |
| GCR ≥ 75% | Passed | 83% goal completion rate |
| HITL gate defined | Passed | > $5,000 discrepancy → human review |
| Cost circuit breaker configured | **Not met** | No session budget limit set |
| Tool call spans instrumented | **Not met** | LLM call spans only; tool calls not traced |
| Session replay backend configured | **Not met** | No observability platform selected |
| Rollback plan documented | Passed | Shadow mode → progressive → auto-rollback on TCR < 80% |

**Gates passed: 5 / 8. Readiness: Caution.**

### HITL posture

- Autonomy level: L2 (Assisted)
- Approval gates: Discrepancy > $5,000; end-of-month reconciliation report always requires sign-off
- Override path: Any reconciliation decision can be overridden by billing team lead
- Escalation trigger: 3 consecutive failures on same invoice → pause and escalate
- Fallback: If agent is unavailable, route to manual processing queue (SLA: 48h)

### Observability readiness

| Instrument | Status | Notes |
|---|---|---|
| Per-request trace ID | In place | All requests have trace_id |
| LLM call spans (tokens, finish reason) | In place | Configured in production |
| Tool call spans (status, latency) | **Missing** | Only error logs; no structured spans |
| Session boundary events | In place | Start/end events emitted |
| Business outcome event (GCR signal) | In place | Reconciliation success/failure event |

**Missing instrument:** Tool call spans. Without them, a retry loop on a failing external API (similar to the procurement agent incident) would be invisible until the cost circuit breaker tripped — except the cost circuit breaker isn't configured either.

### Open blockers

1. **No cost circuit breaker** — session budget and hourly budget not set. Billing reconciliation at volume could generate runaway costs if the matching loop fails. Required before any live traffic.
   Owner: Infrastructure team

2. **Tool call spans missing** — the most common class of production incidents (retry loops, latency spikes on external APIs) would be invisible. Required before full rollout; acceptable to ship to shadow mode without this if blocker 1 is resolved.
   Owner: Observability team

### Rollout recommendation

Shadow mode is acceptable now if blocker 1 (cost circuit breaker) is resolved this week. Do not advance to live traffic until both blockers are resolved. The TCR/GCR numbers are strong — the risk is operational, not model quality.

Recommended rollout sequence:
1. **This week:** Add cost circuit breaker ($2.00/session, $200/hour). Add tool call spans.
2. **Shadow mode (week 1):** Compare agent decisions to human decisions on real traffic. Target: < 5% divergence.
3. **10% live traffic (week 2):** Monitor TCR, GCR, cost/session. Auto-rollback if TCR < 80%.
4. **Full rollout (week 4):** If metrics hold across 5,000 transactions.

### Output

**Artifact written:** `.agentic/artifacts/rollout-readiness-billing-reconciliation-agent.html`

The HTML artifact is generated from `templates/html/rollout-readiness.html`:

```
Template variables filled:
  AGENT_NAME: Billing Reconciliation Agent
  GENERATED_DATE: [date]
  READINESS_VERDICT: Caution
  READINESS_VERDICT_CLASS: caution
  GATES_PASSED: 5
  GATES_TOTAL: 8
  BLOCKER_COUNT: 2
  READINESS_SUMMARY: Strong model quality (91% TCR, 83% GCR) but two operational
                     blockers must be resolved before live traffic

Block sections rendered:
  GATE_ROWS: 8 rows with passed/not-met badges
  OBS_ROWS: 5 rows (minimum viable observability instruments)
  RISK_ROWS: 3 risk entries with severity badges
  BLOCKER_ROWS: 2 open blockers with owners
```

**Open in browser:** `open .agentic/artifacts/rollout-readiness-billing-reconciliation-agent.html`

**Next step:** `/agentic-ai-engineering:agentic-handoff` once blockers are resolved and shadow mode is complete — the artifact provides the foundation for the ops team handoff document.
