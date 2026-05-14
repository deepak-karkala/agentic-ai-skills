---
name: deployment-readiness
description: >
  Assesses production readiness for agentic AI systems. Covers guardrail
  stack design, observability and monitoring, progressive autonomy gates,
  human-in-the-loop patterns, reversibility, incident posture, and
  compliance baselines.
  Use when deciding if an agent is ready to launch, designing production
  guardrails, choosing the right HITL mode, diagnosing approval fatigue,
  defining rollout gates, or preparing for regulatory review.
  Trigger phrases: "is this agent ready to launch", "what guardrails do I
  need", "how do I roll out safely", "what must be true before I expand
  autonomy", "design HITL for my agent", "production checklist for my agent",
  "what monitoring do I need for this agent", "how do I handle failures in
  production", "is this compliant to deploy".
  Do not use for eval strategy (use agent-eval-design), agent architecture
  (use agentic-system-design), or multi-agent topology (use
  multi-agent-orchestration).
allowed-tools:
  - Read
  - Write
metadata:
  category: production
  version: "0.1.0"
---

# Deployment Readiness

Production readiness skill for agentic AI systems. Assesses guardrails, autonomy gates, HITL design, observability, reversibility, and compliance prerequisites before launch.

## When to Use

**Use when:**
- Deciding whether an agent is ready for production launch
- Designing the guardrail stack for a new agent
- Choosing the right human-in-the-loop (HITL) approval mode
- Diagnosing approval fatigue or unsafe automation in an existing system
- Defining rollout gates and progressive autonomy advancement criteria
- Preparing for regulatory or enterprise compliance review
- Designing observability and monitoring for an agentic workflow

**Do not use when:**
- Eval strategy or scorecard design → use `agent-eval-design`
- Agent architecture, tier selection, or pattern choice → use `agentic-system-design`
- Multi-agent topology, handoff contracts → use `multi-agent-orchestration`
- Context window or memory infrastructure → use `context-engineering-for-agents`

## Workflow

### Step 1 — Gather inputs

Ask:
1. What task does the agent perform, and what are the most dangerous actions it can take?
2. What is the target autonomy level: copilot, human-initiated, or ambient?
3. Are any actions irreversible? (send email, submit payment, provision access, delete records)
4. What regulatory environment applies? (healthcare, finance, employment, law enforcement, internal-only)
5. Has the agent been tested in supervised mode first?

---

### Step 2 — Run the Pre-Launch Gate Checklist

Complete this checklist before any production launch decision. A "no" on any shaded item is a launch blocker.

**Architecture (blockers marked with *)**

- [ ] * Workers are stateless and disposable; all state is externalized
- [ ] * Long-running workflows checkpoint and can resume after crash
- [ ] * Circuit breakers are enforced outside agent code (not by the agent itself)
- [ ] * High-risk mutations are idempotent with explicit compensation actions
- [ ] Agent roles are separated by permission scope — write-capable agents do not share processes with read-only agents
- [ ] Interactive and async work use separate queues

**Guardrails (*)**

- [ ] * Seven-layer guardrail stack is present (see Step 3)
- [ ] * Tool gateway intercepts every tool call before execution
- [ ] * Cost budget circuit breaker is set and enforced at the orchestration layer
- [ ] * Loop detection (max steps 20–50) is enforced, not advisory
- [ ] Input validation covers intent, jailbreak, and PII before any LLM call
- [ ] Tool output validation catches prompt injection before observation returns to agent

**HITL and Autonomy (*)**

- [ ] * Risk tier classification is assigned to every action type (Low / Medium / High / Critical)
- [ ] * HITL mode is defined for each risk tier (see Step 4)
- [ ] * Glass-box preamble is shown to reviewers (not prose summary — see Step 4)
- [ ] Approval SLAs are defined and enforced; timeouts escalate, not block
- [ ] Rollback mechanism has been tested

**Observability (*)**

- [ ] * MELT instrumentation is in place (Metrics, Events, Logs, Traces)
- [ ] * Full trace includes session, agent, LLM call, tool execution, guardrail spans
- [ ] * Session replay is available for debugging (reconstruct full execution)
- [ ] Production sampling and drift detection are configured

**Compliance (context-dependent)*

- [ ] Regulatory classification is confirmed (see Step 7)
- [ ] Audit trail meets retention requirement for applicable regulation
- [ ] If handling PII: pseudonymization architecture prevents GDPR/retention conflict

---

### Step 3 — Design the guardrail stack

Apply the **Seven-Layer Guardrail Stack** in this order. Every layer is required; none can be skipped.

| Layer | What it guards | What to check |
|---|---|---|
| **Input validation** | Incoming user/API input | Relevance, intent, jailbreak detection, PII scan |
| **LLM reasoning** | Agent plan before execution | Plan validation, authorization check (does agent have permission for proposed steps?) |
| **Tool input** | Arguments before tool is called | Schema validation, policy check, reversibility classification |
| **Tool output** | Tool result before agent observes it | Prompt injection defense, data leakage prevention, sanitization |
| **Final response** | Output before delivery | Moderation, PII leakage check, hallucination signal |
| **Rules-based** | Deterministic policy enforcement | Allowlists, rate quotas, cost circuit breakers — these are code, not model decisions |
| **Guardian agent** | Semantic policy compliance | Independent observer; veto authority; fires on anomalies the rules layer cannot classify |

**"Let the model propose, let policy decide."** The LLM suggests actions. A deterministic policy layer enforces the decision. The LLM is never the access-control boundary.

**Tool Gateway Architecture** — all tool calls must route through:
```
Agent → tool request → tool gateway
  ├─ schema validation
  ├─ authorization check (policy-as-code, e.g. Rego)
  ├─ approval routing (if risk tier requires it)
  ├─ execution
  ├─ output validation
  ├─ trace logging
  └─ sanitized observation → Agent
```

**Cost budget circuit breaker** — enforce these at the orchestration layer, not inside agent code:
- `session_limit_usd`: maximum spend per task session
- `hour_limit_usd`: maximum spend per hour across all sessions
- Trip action: suspend agent, alert on-call, log full session trace

---

### Step 4 — Define HITL mode by risk tier

Classify every action type the agent can take:

| Risk tier | Example actions | HITL mode | SLA |
|---|---|---|---|
| **Low** | Read-only lookups, FAQ, summarization | Fully automated; periodic audit | N/A |
| **Medium** | Draft email, update internal record | Review before execution | < 1 hour |
| **High** | Send email to customer, issue refund | Explicit approval gate | < 4 hours |
| **Critical** | Financial decision, medical decision, access provisioning | Synchronous human control | Real-time |

**Four-pattern oversight model** (choose the minimum sufficient set):

1. **Plan review upfront** — agent generates structured plan; human approves once before execution (replaces N approval gates)
2. **Selective approval for irreversible actions** — agent autonomous except at designated high-risk nodes
3. **Visible intervention controls** — human can pause, inspect reasoning, and redirect at any point
4. **Action ledger** — immutable log reviewed periodically for audit and compliance (not real-time)

**Glass-box preamble** (required for any High or Critical approval gate):

```yaml
proposed_action: <action_name>
evidence:
  - source: <api/policy/doc> — key facts used
  - source: <api/policy/doc> — key facts used
policy_basis:
  - rule: <policy that permits or triggers this action>
risk_tier: high | critical
agent_reasoning: <one-paragraph justification>
alternatives_considered: <what else the agent could have done>
```

A reviewer who sees this can make a real decision in < 60 seconds. A reviewer who sees prose summary is rubber-stamping.

**Approval fatigue is a production failure mode.** When approval volume exceeds reviewer capacity, approvals become reflexive. This inverts the safety guarantee. Structural fixes:
- Reduce volume: only genuinely irreversible actions require approval
- Signal stakes: risk tier + plain language, not technical payload
- Enforce SLAs: escalate on timeout; do not auto-approve
- Track quality: override rate < 1% signals rubber-stamping, not high quality

**Asynchronous HITL** (for High risk tier, non-real-time):
1. Agent pauses and serializes full state to persistent storage (current node, working memory, proposed action)
2. Notification dispatched to reviewer with SLA
3. Agent thread suspended (no compute cost during wait)
4. Reviewer opens approval interface with full glass-box preamble
5. Reviewer submits decision; agent resumes from exact checkpoint

---

### Step 5 — Define progressive autonomy gates

**Never start at full autonomy.** Direction is always: supervised → partial → autonomous.

| Phase | Behavior | Gate criteria to advance |
|---|---|---|
| **Phase 1 — Supervised** | Agent suggests; human executes every action | Task completion ≥ 90%, error rate < 5%, stable 90+ consecutive days |
| **Phase 2 — Assisted** | Agent executes; human spot-checks via dashboard | Same metrics maintained through Phase 2; exception routing catches edge cases; rollback tested |
| **Phase 3 — Autonomous** | Agent executes and self-corrects; humans handle exceptions only | Phase 2 criteria met; KPI trend is stable; incident response tested |

**Warn explicitly** if the design proposes Phase 3 launch without Phase 1 or Phase 2 data. Organizations that skip Phase 2 consistently produce production failures.

**Canary rollout** before broad release:
- Start at 5–10% of traffic
- Measure: task completion rate, tool error rate, escalation rate, override rate, latency (p95/p99), cost per task, policy violation rate
- Automatic rollback trigger: any metric regresses > 15% vs. baseline

---

### Step 6 — Design MELT observability

Instrument the full MELT stack:

**Metrics (KPIs)**
- Task Completion Rate (TCR): primary health metric; target ≥ 90%
- Goal Completion Rate (GCR): task finished AND goal achieved; distinct from TCR
- Revert-to-human rate: how often agent hands off; declining = good
- Hallucination rate: citations to nonexistent sources or tool calls to nonexistent endpoints
- Cost per task: token spend + tool API cost; track per workflow type
- Guardrail trigger rate: how often each guardrail layer fires

**Events** (emit for every):
- Tool invocation started / completed / failed
- Agent handoff (to human or sub-agent)
- Guardrail triggered (which layer, action taken)
- Circuit breaker tripped
- Human approval requested / approved / rejected / timed out

**Logs** (immutable, WORM storage for compliance):
- Decision inputs, context state, reasoning output
- Tool call intent and tool result
- Human decisions (with reviewer ID, timestamp, SLA)
- Guardrail verdicts with evidence

**Traces** (OpenTelemetry span hierarchy):
```
Session (root)
  └─ Agent span (goal, autonomy level, steps, outcome)
       ├─ LLM call (model, tokens, latency, finish reason)
       ├─ Tool execution (tool name, input args hash, result size, status)
       ├─ RAG retrieval (query, doc count, vector scores, latency)
       ├─ Memory operation (read/write/evict, hit/miss)
       ├─ Guardrail span (layer, triggered, action taken)
       └─ Sub-agent delegation (to_agent_id, handoff_latency)
```

**Session replay** is the primary debugging tool. Replay must reconstruct the exact context window at each LLM call, the exact tool calls generated, and the exact outputs returned. Without replay, debugging is inference from metrics alone.

---

### Step 7 — Apply regulatory baseline

Determine which regulations apply and their minimum requirements:

| Regulation | Applies when | Minimum requirement |
|---|---|---|
| **EU AI Act (Art. 6, Aug 2026)** | Healthcare decisions, credit scoring, employment screening, law enforcement | Human oversight capability (understand, monitor, halt, override); 10-year audit trail |
| **GDPR / CCPA** | Agent stores or processes personal data | Memory is personal data; Article 17 erasure right applies; pseudonymization required if retention > erasure window |
| **HIPAA** | Agent touches Protected Health Information | Business Associate status; 6-year audit retention; PHI access logging mandatory |
| **NIST AI RMF** | US federal or enterprise context | Govern (accountability chain), Map (delegation chains), Measure (continuous eval), Manage (circuit breakers, rollback) |

**GDPR / EU AI Act conflict resolution**: EU AI Act requires 10-year retention; GDPR Article 17 requires erasure on request. Pseudonymization architecture: store events with pseudonymous IDs; separate key store maps pseudonym → real user; erasure deletes the key, preserving audit structure.

---

### Step 8 — Address failure modes with the MAST taxonomy

Check the design against the **MAST failure taxonomy**:

| Failure mode | Diagnostic signal | Mitigation |
|---|---|---|
| **M — Misalignment** | Agent deviates from intended task; conflicting criteria cause loops | Explicit shared success criteria; timeout with human escalation |
| **A — Ambiguity** | Agent hallucinates missing parameters instead of asking | Confidence threshold triggers escalation; constrain-to-JSON failing loudly |
| **S — Specification Errors** | Hallucinated tool names; malformed API calls; wrong arg types | Strict tool output tracing; predefined action menus; schema validation at every tool boundary |
| **T — Termination Gaps** | Premature success claims or infinite loops | Explicit termination conditions before deploy; step counter with hard limit; escalation on threshold |

**Graceful degradation ladder** (must be product-approved before launch):
```
full autonomy
  → smaller action set
  → read-only mode
  → cached / stale-safe answers
  → async continuation (queue for human)
  → human handoff
  → unavailable with clear status
```

---

### Step 9 — Produce the deployment readiness output

Produce a structured readiness assessment:

1. **Launch gate verdict** — Ready / Conditional / Not Ready, with which checklist items are blocking
2. **Guardrail stack** — all seven layers with implementation notes; tool gateway design
3. **HITL design** — risk tier classification for each action type; HITL mode per tier; glass-box preamble template
4. **Progressive autonomy plan** — current phase, gate criteria to advance, canary rollout parameters
5. **MELT instrumentation plan** — metric targets, event list, trace span hierarchy
6. **MAST failure mitigations** — any gaps in termination conditions, ambiguity handling, or spec enforcement
7. **Regulatory checklist** — applicable regulations, current gaps, remediation required
8. **Open questions** — design decisions that need more information before launch

## Output Format

Structured Markdown covering the eight sections above.

If this assessment is part of an architecture review (called from `agentic-system-design`), return the deployment section as the production readiness component of the architecture output.

## Scope Boundaries

This skill does not:
- Design agent architecture, tiers, or orchestration patterns → `agentic-system-design`
- Design eval scorecards, trajectory metrics, or grader selection → `agent-eval-design`
- Design multi-agent topologies or handoff contracts → `multi-agent-orchestration`
- Design context window or memory infrastructure → `context-engineering-for-agents`
- Implement guardrails, monitoring infrastructure, or CI/CD pipelines — it specifies what to build; implementation is the engineer's responsibility
- Provide legal counsel — regulatory baselines here are engineering-facing summaries, not legal advice
