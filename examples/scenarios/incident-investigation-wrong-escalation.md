# Scenario: Investigating Systematic Wrong Escalation in a Support Triage Agent

## Trigger

> "This agent caused a bad action in prod — investigate"
>
> "Our support triage agent has been misrouting high-severity billing tickets to the General Inquiry queue for the past 48 hours. Customers with urgent billing issues are waiting 6+ hours instead of getting immediate Tier-2 attention. We need to understand what happened, why our evals didn't catch it, and how to fix it."

## Skill: incident-investigation

### Inputs gathered

1. Bad outcome: High-severity billing tickets routed to General Inquiry queue (Tier-1) instead of Billing Specialist queue (Tier-2/urgent)
2. Period: 48 hours; ~120 tickets affected; detected via customer complaints
3. Evidence available: LLM call logs (no spans), ticket routing logs, one engineer's trace export from LangSmith for 3 representative failures
4. Pattern: Systematic — every billing ticket with the phrase "subscription" in the body was misrouted
5. Recent changes: Knowledge base article about subscription plans was updated 50 hours ago — 2 hours before first misrouting
6. Alerts: None fired (no alert on Tier-2 routing rate)

### Step 2 — Failure timeline

```
T-50h    KB update: subscription plan article rewritten with new pricing structure
T-48h    [First failure] ticket #8841 — "my subscription renewal failed" → routed to General Inquiry
T-48h    [LLM call log] orchestrator: "subscription renewal" → category=general_inquiry (confidence: 0.81)
T-47h    ticket #8853 — "cancel my subscription" → routed to General Inquiry
...
T-2h     [Detection] customer escalation — billing team not receiving urgent tickets
T-0      [Alert] manual review confirms pattern: subscription = misrouted to Tier-1
--- gap: no span data for what the worker agents received; only orchestrator logs available ---
--- gap: no log of what KB content was injected into context at T-48h ---
```

**Timeline gaps:**
- Unknown: what KB content was injected into the orchestrator context at the time of misrouting
- Unknown: whether worker agents were affected or just the orchestrator

### Step 3 — Fault layer identification

**Primary fault layer: Context failure (indirect injection / retrieval)** + **Eval gap**

Evidence for Context failure:
- The KB update occurred 2 hours before the first misrouting — temporal correlation is strong
- The routing decision was made with high confidence (0.81) — the model was not uncertain; it was certain of the wrong answer
- The new KB article likely reframed "subscription" terminology in a way that the orchestrator read as indicating non-billing general inquiries
- The KB article content entered the context window as data — but its new framing acted as a soft instruction to re-classify the category

Evidence for Eval gap:
- The eval suite does not include any "subscription" keyword fixtures in the billing category
- The failure would not have been caught by any golden test

Secondary fault layer: Observability gap
- No alert exists for Tier-2 routing rate drop
- The pattern ran for 48 hours undetected because there was no metric monitoring routing distribution

### Step 4 — Immediate containment

1. **[Done]** Revert the KB subscription article to the previous version (stops new misroutings)
2. **[Required now]** Manually re-route the 120 affected tickets to the Billing Specialist queue; notify Tier-2 team of the backlog
3. **[Required now]** Add monitoring alert: if Tier-2 routing rate drops below 15% for 2 consecutive hours, page on-call
4. **[Hold]** Do not re-publish the new KB article until indirect injection protection is in place

**Current exposure:** Contained (KB reverted). 120 historical tickets still require manual re-routing.

### Step 5 — Durable fix mapping

| Fault layer | Fix target | Specific change |
|---|---|---|
| Context failure (indirect injection via KB) | `context-engineering-for-agents` | Add content inspection layer for KB articles before injection: detect and flag content that contains category-like classification language; do not allow retrieved KB content to override routing logic |
| Context failure | `agentic-security` | KB article content is an indirect injection vector — add to threat model; treat KB content as untrusted data, not trusted instructions |
| Eval gap | `agent-eval-design` | Add golden fixtures for all billing subcategories including subscription, cancellation, renewal; require ≥ 6 fixtures per billing subtype |
| Observability gap | `agent-observability` | Add Tier-2 routing rate metric with alert threshold; add KB content injection logging (content hash + article ID at each retrieval) |

### Step 6 — Incident report

**Incident report written to:** `.agentic/artifacts/incident-support-triage-agent-2026-05-16.md`

### Step 7 — Summary

- **Fault layer:** Context failure (KB retrieval injected classification-influencing content into orchestrator context) + Eval gap (no billing subscription fixtures)
- **Containment:** Contained — KB reverted; re-routing backlog in progress
- **Root cause:** KB article update introduced content with implicit category signals; retrieval injected this into orchestrator context without content inspection; model reclassified subscription-related tickets based on the new article framing
- **Eval gap:** Yes — no subscription keyword fixtures in billing eval suite; this failure would not have been caught
- **Observability gap:** Yes — no routing distribution metric or alert; 48-hour detection window is unacceptable
- **Durable fix targets:**
  1. `context-engineering-for-agents` — content inspection layer for retrieved KB articles
  2. `agent-eval-design` — add billing subscription golden fixtures
  3. `agent-observability` — add routing rate metric + alert
