# Scenario: Architecture Review with HTML Artifact

## Trigger

> `/agentic-arch-review`
>
> "I have an existing support escalation agent using LangGraph. It monitors a support queue, classifies tickets, looks up customer history from our CRM, and routes urgent tickets to on-call engineers via PagerDuty. I want a review before we expand it to more regions."

## Command: /agentic-ai-engineering:agentic-arch-review

This command always produces an HTML artifact — that is its explicit contract.

## Skill: agentic-system-design (review mode)

### Inputs gathered

1. Existing architecture description provided inline
2. Primary concern: correctness and scalability before regional expansion
3. Known failure mode: occasional duplicate PagerDuty alerts when two tickets arrive simultaneously

### agent-systems-architect delegated

The design is non-trivial (multi-system, existing production architecture) — subagent is invoked.

**Subagent returns:**

```
## Topology Assessment
Routing → Tool-Augmented Agent (ReAct) — fit: acceptable
LangGraph provides graph state, which is appropriate. However, the duplicate-alert failure
suggests missing idempotency on the PagerDuty tool call. The ReAct loop can reach the
escalation node via two concurrent ticket-processing paths without a deduplication gate.

## Context Boundary Risks
- Implicit shared state: two concurrent ticket sessions may both read the same CRM customer
  record and both decide to escalate before either write is visible — severity: high
- Missing handoff contract: the tool call to PagerDuty has no idempotency key in the
  current design — severity: high

## Tradeoff Matrix
| Alternative | Pros | Cons | When to choose |
|---|---|---|---|
| Add idempotency key on PagerDuty tool | Fixes duplicates; minimal change | Requires unique key per customer+window | Recommended for current design |
| Move to Hub-and-Spoke with dedup worker | Cleaner long-term; handles volume | More complex; not needed yet | When volume exceeds single-node capacity |
| Optimistic locking on CRM read+escalate | Eliminates race condition | Higher latency; adds complexity | If idempotency key alone is insufficient |

## Anti-patterns Detected
- False Independence: concurrent ticket sessions share the CRM customer record without
  explicit lock/lease. If two tickets arrive for the same customer within the same window,
  both sessions may escalate independently.

## Key Questions for the Design
- Is the PagerDuty tool idempotent by default, or does it create a new alert on every call?
- What is the expected concurrent session count at regional scale?
```

### Full skill analysis (abbreviated)

**Qualification:** 7/7 on Process-Fit. Tier 3 (True Agent). No change from original design.

**Autonomy review:** Currently Phase 2 (agent executes, human spot-checks). Expanding to more regions does not require autonomy change — the same gate criteria apply.

**Key risk from review:** The duplicate-alert failure is a False Independence anti-pattern. Fix before expansion: add idempotency key to PagerDuty tool call (customer_id + time-window hash). Confirm PagerDuty dedup window matches the ticket-processing window.

**Verdict: Caution** — the duplicate-alert issue must be resolved before regional expansion. Architecture is otherwise sound.

## HTML Artifact Generation

The skill reads `.agentic/config.yml` → `artifact_output_path: .agentic/artifacts/`.

Template `templates/html/architecture-review.html` is loaded and all `{{VARIABLE}}` placeholders filled:

```
AGENT_NAME          → "Support Escalation Agent"
VERDICT             → "Caution"
TOPOLOGY            → "Routing → ReAct (LangGraph)"
AUTONOMY_TIER       → "Phase 2 — Assisted"
RISK_ROWS           → [False Independence (high), Missing idempotency key (high)]
RECOMMENDATION      → "Add idempotency key to PagerDuty tool call before regional expansion."
OPEN_QUESTIONS      → [2 questions from subagent]
```

**File written:** `.agentic/artifacts/architecture-review-support-escalation-agent.html`

**User message:**
```
Architecture review complete. Verdict: Caution.

Key finding: False Independence anti-pattern in concurrent ticket sessions.
Fix required before regional expansion: add idempotency key to PagerDuty tool call.

HTML artifact written to: .agentic/artifacts/architecture-review-support-escalation-agent.html
Open in browser to view the full review with risk register and recommendation.
```
