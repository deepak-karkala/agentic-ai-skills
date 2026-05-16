# Scenario: Designing HITL Architecture for a Financial Operations Agent

## Trigger

> "Design the HITL layer for this agent"
>
> "We're building an accounts payable automation agent that processes vendor invoices, matches them to POs, and can approve payments up to $10,000 automatically. Payments over $10,000 need human approval. We have 3 AP reviewers handling ~200 invoices/day currently. What HITL model should we use, and how do we design the approval gates?"

## Skill: human-in-the-loop-patterns

### Inputs gathered

1. Agent: Accounts Payable Automation Agent — RAG + tool-using; processes invoices, matches POs, initiates payments
2. Action types: invoice-match (read), po-lookup (read), payment-initiate (irreversible write), vendor-create (correctable write), flag-for-review (correctable write)
3. Risk profile: payment-initiate is irreversible (cannot be recalled once sent); payments up to $10,000 can be autonomous; over $10,000 requires approval
4. Throughput: ~200 invoices/day; 3 AP reviewers; current manual process takes 15 minutes/invoice
5. Consequences: wrong payment = financial loss, vendor relationship damage, potential fraud
6. Regulatory: SOX compliance requires audit trail for all payment approvals

### Step 2 — HITL model selection

| Action | Risk tier | HITL model | Rationale |
|---|---|---|---|
| invoice-match, po-lookup | Low — read-only | Model 1 (Fully Automated) | No side effects; reversible |
| vendor-create | Medium — new vendor requires validation | Model 2 (Human-on-Standby) | Most vendors are standard; flag unusual patterns for human review |
| payment-initiate (≤ $10,000) | Medium — irreversible but bounded loss | Model 2 (Human-on-Standby) | Autonomous with defined escalation triggers |
| payment-initiate (> $10,000) | High — irreversible, significant loss potential | Model 3 (Human-in-the-Loop) | Hard stop; explicit approval required; SOX requirement |
| All completed actions | Audit requirement | Model 4 (Human-over-the-Loop) | SOX requires post-hoc review of all payment actions |

**Decision:** Mixed-model design. Not all actions need the same gate.

### Step 3 — Approval gate design

**Gate 1: Large payment approval (payment-initiate > $10,000)**

| Component | Design |
|---|---|
| Trigger | payment_amount > $10,000 AND payment_status = pending_approval |
| Content shown to reviewer | Invoice #, vendor name, PO # matched, match confidence score, amount, payment date, agent's match reasoning, PO line item details, link to original invoice scan |
| Approval definition | Reviewer clicks Approve (with digital signature) or Reject (with mandatory rejection category + free text note) or Route-to-Manager (for amounts > $50,000 or anomalous patterns) |
| Timeout | No auto-approve. After 4 hours: send reminder. After 8 hours: escalate to AP Manager. After 24 hours: reject and hold. |
| Audit record | Reviewer ID, timestamp, decision, digital signature, time-to-decision, any modification |

**Gate 2: New vendor creation (vendor-create)**

| Component | Design |
|---|---|
| Trigger | Vendor not in approved vendor master; agent attempts vendor-create |
| Content shown | Vendor details extracted from invoice, tax ID, payment terms, bank routing (masked), agent's confidence in vendor legitimacy |
| Approval definition | One of: approve-and-add (add to vendor master), reject (do not pay), request-more-info (agent follows up with vendor) |
| Timeout | 48 hours; if no response: hold invoice for manual review |

**Escalation trigger for payment-initiate ≤ $10,000 (Standby model):**
Escalate to human review when ANY of:
- PO match confidence < 0.85
- Invoice amount differs from PO amount by > 2%
- Vendor is flagged as new (< 3 prior payments)
- Duplicate invoice number detected
- Payment recipient differs from vendor master

### Step 4 — Bounded autonomy contract

```markdown
## Bounded Autonomy Contract: AP Automation Agent

### Autonomy level: L2 Assisted

### Actions the agent may take autonomously
- invoice-match: any invoice with PO match confidence ≥ 0.85
- payment-initiate: amount ≤ $10,000 AND match confidence ≥ 0.85 AND vendor in master AND no anomaly flags

### Actions that require human approval before execution
- payment-initiate: amount > $10,000 (hard threshold, no exceptions)
- payment-initiate: any amount when match confidence < 0.85, amount delta > 2%, new vendor, duplicate invoice, or recipient mismatch
- vendor-create: always — new vendors must be human-approved before entry into vendor master

### Actions the agent is never permitted to take
- Modify vendor banking details
- Initiate payments to vendors not in the approved vendor master
- Create or modify its own tool permissions or configuration

### Confidence threshold for autonomous payment
Payment-initiate requires PO match confidence ≥ 0.85. Below this threshold, ALWAYS escalate.

### Session budget
Maximum 10 autonomous payments per hour. If the agent attempts more than 10 per hour, pause and alert AP Manager (anomaly: unusual volume may indicate fraud or malfunction).
```

### Step 5 — Escalation ladder

| Tier | Handler | Trigger | SLA | Context passed |
|---|---|---|---|---|
| Tier 1 | Agent (autonomous) | Low-risk, high-confidence | Real-time | N/A |
| Tier 2 | AP Reviewer | Amount > $10k, anomaly flags, new vendor | 4 hours | Full invoice + PO + agent reasoning |
| Tier 3 | AP Manager | Amount > $50k, reviewer escalation, anomaly pattern across multiple invoices | 2 hours | Tier-2 reviewer's notes + original context |
| Tier 4 | CFO / Finance Director | Amount > $100k, suspected fraud | 1 hour | Full audit trail + fraud indicators |

Fallback: If no tier responds within SLA, the payment is held (not processed) and an alert fires to all tiers simultaneously.

### Step 6 — Feedback loop

1. Every AP reviewer approval/rejection creates a labeled training example
2. Weekly: review rejection reasons and confidence score distributions
   - If rejection rate for confidence 0.85–0.90 is > 20%, lower the autonomous threshold to 0.90
   - If rejection rate for confidence > 0.90 is < 5% over 30 days, consider raising automatic limit to $15,000 (after risk review)
3. Monthly: review override categories — the top 3 rejection reasons become new eval fixtures
4. Trust calibration: after 90 days of operation, update the confidence thresholds using empirical reviewer agreement data

### Scale consideration

With 200 invoices/day and 3 reviewers:
- ~60% expected to route autonomously (≤ $10k, high confidence, known vendor) → 80 invoices
- ~40% requiring review → 80 invoices/day / 3 reviewers = ~27/reviewer/day
- At 5 min/review (vs. 15 min manual): reviewers handle 2.5× more volume with agent support
- Batch approval: Enable for batches of invoices from the same vendor/PO with identical match conditions — single approval for up to 5 matched invoices

### Output

**HITL design written to:** `.agentic/artifacts/hitl-ap-automation-agent.md`

Summary:
- Mixed HITL model: Fully Automated (read-only) + Human-on-Standby (payments ≤ $10k with anomaly triggers) + HITL (payments > $10k) + Over-the-Loop (SOX audit)
- Hard gate: all payments > $10,000; no auto-approve on timeout
- Bounded autonomy contract: explicit list of autonomous vs. gated vs. prohibited actions
- Scale: 40% review rate; reviewers handle 27 reviews/day at 5 min each
- Next step: `agent-ui-patterns` to design the reviewer approval interface
