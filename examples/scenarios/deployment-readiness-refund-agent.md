# Scenario: Refund Agent Production Launch

## Trigger

> "Our customer-facing refund agent is ready for production. It can look up order history, check return policy eligibility, and issue refunds up to $500. What do we need to check before we launch?"

## Skill: deployment-readiness

## Step 1 — Inputs gathered

- Task: look up order, verify policy eligibility, issue refund
- Target autonomy: ambient (no human in the loop for < $500 refunds)
- Irreversible action: **yes — issuing a refund modifies financial records and triggers payment processor**
- Regulatory: processes payment data (PCI-adjacent); handles customer personal data (GDPR)
- Supervised mode testing: "done in staging" — no Phase 1 supervised production run

## Step 2 — Pre-launch gate assessment

**BLOCKED on 3 items:**

1. **Circuit breaker** — no cost/session limit configured. A retry loop could issue thousands of refunds. This is a launch blocker. (Reference: pre-launch-checklist.md, Guardrails section)
2. **Phase 1 supervised mode not completed** — agent has not run in production with human confirmation before going autonomous. Launch must start in Phase 1 (recommend-and-confirm), not Phase 3 (autonomous).
3. **Rollback mechanism untested** — no test of what happens when a refund is issued incorrectly; compensation action (refund reversal) not confirmed available via payment processor API.

## Step 3 — Guardrail stack gaps

| Layer | Status | Gap |
|---|---|---|
| Input validation | Present | Add intent check: does this request actually match a refund workflow? |
| LLM reasoning | Present | Add authorization check: does agent have permission to issue this amount? |
| Tool input | **Missing** | No schema validation on refund API call; no reversibility classification |
| Tool output | **Missing** | No injection defense on order API response |
| Final response | Present | — |
| Rules-based | **Missing** | No per-session refund cap; no per-customer refund frequency limit |
| Guardian agent | Not planned | Recommend for launch; monitors for anomalous refund patterns |

**Tool gateway must be added** before launch. No tool call should reach the payment processor API without: schema validation, authorization check (amount ≤ policy limit), idempotency key.

## Step 4 — HITL design

Refund action = **High risk** (irreversible financial transaction, amount > $0).

| Action | Risk tier | HITL mode | SLA |
|---|---|---|---|
| Look up order history | Low | Automated | N/A |
| Check policy eligibility | Low | Automated | N/A |
| Issue refund ≤ $100 | Medium | Review before execution | < 1 hour |
| Issue refund $100–$500 | High | Explicit approval gate | < 4 hours |

**Glass-box preamble required for > $100 refunds:**
```yaml
proposed_action: issue_refund
customer_id: cus_abc123
order_id: ord_xyz789
amount_usd: 247.50
policy_basis:
  - return_window: 4 days remaining
  - customer_tier: standard
  - reason_code: damage-reported
evidence:
  - orders_api: [order status: eligible, age: 26 days]
  - policy_db: [30-day window for standard tier]
risk_tier: high (amount > $100)
```

## Step 5 — Progressive autonomy plan

**Current state: Not ready for autonomous launch.**

Required path:
1. **Phase 1 (days 1–30):** All refunds require human confirmation. Agent drafts; human executes. Target: 90%+ approval rate with < 5% overrides.
2. **Phase 2 (days 31–90):** Refunds ≤ $100 automated; $100–$500 with approval gate. Target: same metrics sustained.
3. **Phase 3:** Full autonomy within policy bounds only after Phase 2 gate criteria met.

## Step 7 — Regulatory

Payment data + personal data: GDPR applies. Refund records must be erasable on request. Pseudonymization architecture required for audit trail vs. erasure conflict.

## Output

**Verdict: Not Ready. 3 launch blockers.**

Blockers:
1. Cost/session circuit breaker not configured
2. Phase 1 supervised run not completed
3. Rollback mechanism untested

**Recommended path:** Configure circuit breakers and tool gateway this week. Launch in Phase 1 (human-confirms-all) with a 30-day supervised window. Advance to Phase 2 only after meeting the gate criteria.
