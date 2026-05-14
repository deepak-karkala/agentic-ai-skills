# Pre-Launch Gate Checklist

Use before any production launch decision. A "no" on any item marked with * is a launch blocker.

## Architecture

- [ ] * Workers are stateless and disposable; all state is externalized
- [ ] * Long-running workflows checkpoint and can resume after crash
- [ ] * Circuit breakers are enforced outside agent code (not by the agent itself)
- [ ] * High-risk mutations are idempotent with explicit compensation actions
- [ ] Agent roles are separated by permission scope — write-capable agents do not share processes with read-only agents
- [ ] Interactive and async work use separate queues

## Guardrails

- [ ] * Seven-layer guardrail stack is present
- [ ] * Tool gateway intercepts every tool call before execution
- [ ] * Cost budget circuit breaker is set and enforced at the orchestration layer
- [ ] * Loop detection (max steps 20–50) is enforced, not advisory
- [ ] Input validation covers intent, jailbreak, and PII before any LLM call
- [ ] Tool output validation catches prompt injection before observation returns to agent

## HITL and Autonomy

- [ ] * Risk tier classification is assigned to every action type (Low / Medium / High / Critical)
- [ ] * HITL mode is defined for each risk tier
- [ ] * Glass-box preamble is shown to reviewers (not prose summary)
- [ ] Approval SLAs are defined and enforced; timeouts escalate, not block
- [ ] Rollback mechanism has been tested

## Observability

- [ ] * MELT instrumentation is in place (Metrics, Events, Logs, Traces)
- [ ] * Full trace includes session, agent, LLM call, tool execution, guardrail spans
- [ ] * Session replay is available for debugging (reconstruct full execution)
- [ ] Production sampling and drift detection are configured

## CI/CD

- [ ] Golden evals run on every meaningful agent change
- [ ] Adversarial and security evals run before rollout
- [ ] Cost and latency budgets are regression gates
- [ ] Rollback criteria include quality and safety, not only uptime

## State

- [ ] Operational state has TTLs, leases, and cleanup procedures
- [ ] Durable history stores decisions, tool calls, approvals, and audit records
- [ ] Mutating tools are idempotent
- [ ] Sagas define compensation for multi-step mutations

## Compliance (context-dependent)

- [ ] Regulatory classification is confirmed
- [ ] Audit trail meets retention requirement for applicable regulation
- [ ] If handling PII: pseudonymization architecture prevents GDPR/retention conflict
