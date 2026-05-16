# Handoff: Support Triage Agent

> Generated 2026-05-16 · Skill: agentic-handoff · Plugin: agentic-ai-engineering  
> Prepared by: Build Team (Jane D., Mark L.) · Receiving team: Platform Operations (Sarah K., Tom W.)

This document transfers ownership of Support Triage Agent from the outgoing team to the receiving team. Read the linked artifacts for full detail; this document summarizes what you need to know to continue the work safely.

---

## Project Summary

The Support Triage Agent is an Orchestrator-Workers system that automatically classifies, prioritizes, and routes inbound customer support tickets to the appropriate handling tier. The Triage Orchestrator agent receives raw tickets, invokes four specialist worker agents (Billing, Technical, Account, General Inquiry), and produces a structured routing decision with a handoff message for Tier-2 escalations. Human-in-the-loop gates are active for Tier-3 escalations and refund approvals over $500.

**Current status:** Pre-production — canary deployment authorized at 5% traffic (read-only mode, CRM write tool disabled) pending resolution of two open blockers.

**Active work:** Adversarial eval suite implementation (Jane D., target 2026-05-23) and CRM circuit breaker implementation (Mark L., target 2026-05-20).

---

## Architecture

**Architecture type:** Orchestrator-Workers, L2 Assisted Autonomy

**Key design decisions:**

- **Worker-per-category over shared worker:** Four separate worker agents (Billing, Technical, Account, General Inquiry) instead of a single polymorphic worker. Enables category-specific prompt tuning and independent failure isolation.
- **Orchestrator owns routing, workers enrich context:** Workers do not re-classify or re-route. They receive a pre-classified ticket and add category-specific context to the handoff message only.
- **HITL at tier boundary, not ticket boundary:** Human confirmation required only for Tier-3 escalation and refunds over $500. Tier-1 and Tier-2 routing is fully autonomous to maintain throughput targets.
- **Confidence-gated escalation:** Confidence below 0.7 automatically routes to human review, regardless of tier. This is the primary safety valve against uncertain classifications.

**Reference artifact:** [architecture-review-support-triage-agent.html](architecture-review-support-triage-agent.html)

---

## Evaluation State

**Eval coverage verdict:** Partial (3/6 dimensions)

**Eval suite location:** `tests/evals/support-triage/`

**Known eval gaps:**

- Trajectory Quality: not tested — no golden trajectories, no step-count grader
- Adversarial Safety: not tested — no prompt injection or adversarial ticket fixtures (open blocker B1)
- Collaboration / Handoff Quality: not tested — handoff message content not graded
- Efficiency / Token Budget: not tested — no latency or cost budget gates in eval suite

**Reference artifact:** [eval-scorecard-support-triage-agent.html](eval-scorecard-support-triage-agent.html)

---

## Deployment State

**Readiness verdict:** Caution

**Deployed environments:**

| Environment | Status | URL / endpoint | Notes |
|---|---|---|---|
| Development | Active | https://support-triage.internal.dev/api | Full feature set; resets nightly |
| Staging | Active | https://support-triage.internal.staging/api | Production-equivalent config; load test in progress |
| Production (canary) | Active (5%) | https://support-triage.prod/api | Read-only mode; CRM write tool disabled; 5% traffic only |
| Production (full) | Blocked | — | Blocked by B1 and B2; do not expand until blockers cleared |

**Circuit breakers configured:**

- **Ticket lookup tool:** Pause after 5 consecutive timeouts; auto-resume after 60-second backoff.
- **Knowledge base search tool:** Pause after 10 consecutive empty results; alert on-call if triggered.
- **CRM write tool:** Circuit breaker NOT yet implemented — this is Blocker B2. CRM write is disabled in canary config. Do not enable CRM write in production until B2 is resolved.

**Reference artifact:** [rollout-readiness-support-triage-agent.html](rollout-readiness-support-triage-agent.html)

---

## Open Risks

- **[High]** Adversarial ticket injection: A malicious customer could embed instructions in ticket text that override routing behavior. — *Mitigation: Implement prompt injection detection layer; adversarial eval suite (B1, target 2026-05-23)*
- **[High]** CRM write without circuit breaker: Runaway writes possible under error cascade; could corrupt ticket statuses at scale. — *Mitigation: Implement circuit breaker on CRM write tool (B2, target 2026-05-20)*
- **[Medium]** Load capacity gap: Peak production load (80 concurrent) is 8x tested load (10). Performance at scale unknown. — *Mitigation: Complete full load test before expanding beyond canary*
- **[Medium]** Context drift on long ticket threads: Threads with 20+ messages approach context window limits; behavior at boundary not tested. — *Mitigation: Implement context summarization for threads over 15 messages; add long-thread eval fixtures*
- **[Medium]** Model version drift: Agent pinned to claude-3-5-sonnet-20241022; silent regression risk if model is updated or deprecated. — *Mitigation: Pin model in config; re-eval on any model update; 90-day review reminder set*

---

## Open Blockers and Decisions

- **Blocker** — B1: Adversarial eval suite not implemented. Prompt injection detection unvalidated. Blocks full production launch. (Owner: Jane D., Target: 2026-05-23)
- **Blocker** — B2: CRM write tool circuit breaker absent. Runaway writes possible. Blocks enabling CRM write tool in production. (Owner: Mark L., Target: 2026-05-20)
- **Decision** — Canary traffic expansion schedule: currently 5%; plan to go to 25% after B1+B2 clear, then full after load test passes. Receiving team to execute this schedule. (Owner: Platform Ops)
- **Decision** — Handoff message schema finalisation: draft schema at `schemas/handoff-message.json` — review and freeze before full launch. (Owner: Platform Ops + ML Eng)

---

## Glossary

The team glossary is at [glossary-support-triage-agent.md](glossary-support-triage-agent.md). Key terms to know before reviewing the code or design docs:

- **Triage:** Classify and route a ticket (without resolving it). Performed exclusively by the Triage Orchestrator.
- **Routing Decision:** Structured output specifying destination queue, priority, and tier. Logged as JSON in the audit trail.
- **Escalation:** Upward tier move (Tier-N to Tier-N+1). Requires HITL confirmation at Tier-2 → Tier-3.
- **Confidence Score:** 0.0–1.0 value on each routing decision. Below 0.7 triggers HITL escalation path.
- **HITL Gate:** Hard stop requiring human confirmation before agent proceeds. Two active gates: Tier-3 escalation and refunds over $500.
- **Circuit Breaker:** Safety mechanism halting tool calls after error threshold. Required on all write-capable tools.

---

## Next Actions for the Receiving Team

1. Review open blockers B1 and B2 with respective owners; confirm target dates are still achievable. (Priority: High)
2. Complete full load test at 80 concurrent tickets in staging before expanding canary beyond 5%. (Priority: High)
3. Review and freeze handoff message schema (`schemas/handoff-message.json`) — required before full launch. (Priority: High)
4. Set up cost and latency dashboards using the partial observability instrumentation already in place; add per-span breakdown. (Priority: Medium)
5. Schedule 90-day model version review reminder (pinned model: claude-3-5-sonnet-20241022; review date: 2026-08-16). (Priority: Medium)
6. Expand adversarial eval suite beyond B1 scope: add context drift fixtures for long threads, category confusion fixtures. (Priority: Medium)

---

## Contacts

| Role | Name | Contact |
|---|---|---|
| Build team lead (outgoing) | Jane D. | jane.d@company.internal |
| Backend engineer (outgoing) | Mark L. | mark.l@company.internal |
| Platform ops lead (receiving) | Sarah K. | sarah.k@company.internal |
| Platform ops engineer (receiving) | Tom W. | tom.w@company.internal |
| ML Engineer (eval suite) | Jane D. | jane.d@company.internal |
| On-call rotation | Platform Ops | pagerduty: support-triage-oncall |

---

## Related Artifacts

All artifacts are in the shared output directory (.agentic/artifacts/).

- [Architecture Review](architecture-review-support-triage-agent.html)
- [Eval Scorecard](eval-scorecard-support-triage-agent.html)
- [Rollout Readiness](rollout-readiness-support-triage-agent.html)
- [Glossary](glossary-support-triage-agent.md)

---

*Generated by the `agentic-ai-engineering` plugin. To re-generate, run `/agentic-ai-engineering:agentic-handoff`.*
