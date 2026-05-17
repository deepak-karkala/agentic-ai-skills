# Scenario: Multi-Layer Incident Investigation with Reliability Subagent

## Trigger

> "We had a production incident yesterday — our support triage agent started misclassifying tickets and sending emails to the wrong customers. It ran for 6 hours before the team noticed. I have logs, a timeline, and the LangSmith session traces."

## Skill: incident-investigation → agent-reliability-engineer (delegated)

### Inputs gathered

1. Agent: Support Triage Agent — classifies tickets, routes to tiers, sends automated customer emails
2. Incident window: 6 hours (08:00–14:00); ~340 tickets affected; ~40 wrong-tier emails sent
3. Evidence: LangSmith session logs (23 sessions), routing logs, KB update deploy at 07:45
4. Reported symptom: billing tickets classified as General Inquiry; emails sent to wrong tier queue
5. Known change: KB article update deployed at 07:45 — 15 minutes before first reported misclassification

### Step 1 — Failure timeline reconstruction

```
07:45  KB update deployed — 4 billing policy articles updated, 1 article deleted
07:48  First ticket classified as General Inquiry (expected: Tier-2 Billing) — first deviation
07:52  Second misclassification confirmed in routing log
09:30  Supervisor notices pattern after reviewing 3 complaints
14:00  KB rollback initiated; incident declared
14:20  Classification accuracy restored (verified via 10-ticket manual check)
```

**Gap noted:** No alert triggered between 07:48 and 09:30. No circuit breaker on classification confidence — low-confidence classifications passed through to routing unchanged.

### Step 2 — Delegate to agent-reliability-engineer

**Delegation trigger:** The failure touches three layers (context, tool, eval gap), active hallucination modes are present in the email generation step, and the full classification requires structured evidence from all layers. Inline analysis would exceed ~500 tokens.

**Findings synthesized from agent-reliability-engineer:**

#### Fault layer classification

| Failure | Layer | Severity | Affected component |
|---|---|---|---|
| KB deletion removed billing classification anchor — retrieval returned empty for "subscription renewal failed" queries | Context failure | High | KB retrieval step |
| Agent generated confident routing decisions despite empty/low-similarity retrieval | Reasoning failure | High | Classification LLM call |
| No confidence threshold check before routing action committed | Policy gap | High | Routing decision gate |
| Email template populated with wrong-tier routing output without re-validation | Tool failure | Medium | Email-send tool |
| No eval coverage for KB deletion scenarios | Eval gap | Medium | Eval suite — adversarial coverage |

**Primary fault layer:** Context failure (KB deletion removed grounding for billing classification) — amplified by policy gap (no confidence gate).

#### Hallucination assessment

| Mode | Evidence | Severity | Containment existed? |
|---|---|---|---|
| Retrieval failure | Retrieval returned similarity 0.31 for billing queries; agent generated "General Inquiry" routing without flagging low confidence | High | No — no confidence threshold gate |
| Unsupported assertion | Email body referenced "your general inquiry" for confirmed billing tickets — assertion not in retrieval context | Medium | No — email body not verified against routing reason |

#### Reliability gaps identified

| Gap | Component | Risk if unaddressed |
|---|---|---|
| Missing circuit breaker on confidence | Classification step — no threshold gate | Any retrieval degradation silently routes to wrong tier |
| No fallback path on empty retrieval | KB search — returns empty without error | Agent proceeds as if retrieval succeeded |
| Email body not cross-validated against routing decision | Email-send tool | Wrong-tier emails sent without consistency check |
| No escalation trigger on sustained low confidence | Routing decision loop | 6-hour window before human noticed |

#### Eval coverage gaps

- KB deletion scenario: no test
- Low-similarity retrieval fallback: no test
- Email-routing consistency: no test
- Confidence-gated routing: not tested adversarially

### Step 3 — Immediate containment

| Action | Urgency | Owner |
|---|---|---|
| Roll back KB to pre-07:45 state | Completed (14:00) | Ops |
| Pause automated email-send; require manual approval for 24h | Done | Eng |
| Add confidence threshold gate (< 0.70 → mandatory human review) | 24h | Eng |
| Add circuit breaker: >5% low-confidence classifications in 10-min window → alert | 24h | Eng |

### Step 4 — Durable fix targets

| Finding | Fix target |
|---|---|
| Context failure (KB deletion drops retrieval anchor) | `agent-observability` — add retrieval similarity alert; `context-engineering-for-agents` — design KB fallback strategy |
| Policy gap (no confidence gate) | `human-in-the-loop-patterns` — design confidence-gated HITL trigger |
| Eval gap (no KB degradation scenarios) | `agent-eval-design` — add adversarial eval for KB deletion, low-similarity retrieval |
| Email-routing consistency | `tool-interface-design` — add cross-validation step before email-send |

### Output

**Post-mortem artifact written to:** `.agentic/artifacts/incident-investigation-support-triage-agent.md`

**Summary:**
- Primary fault layer: context failure (KB deletion) + policy gap (no confidence gate)
- Active hallucination modes: retrieval failure (high), unsupported assertion (medium)
- 4 eval gaps identified — all adversarial or fallback scenarios
- Immediate containment: complete (KB rollback, email pause, confidence gate in progress)
- Durable fix routes: `human-in-the-loop-patterns` (confidence gate design), `agent-eval-design` (adversarial coverage), `agent-observability` (retrieval alert)
- agent-reliability-engineer delegation used: yes — three fault layers and two hallucination modes exceeded inline threshold
