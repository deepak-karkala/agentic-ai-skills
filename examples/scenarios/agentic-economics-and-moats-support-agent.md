# Scenario: Unit Economics Review for a Customer Support Agent

## Trigger

> `/agentic-economics-and-moats`
>
> "We launched our customer support agent 3 months ago. We charge $99/seat/month. Each seat handles roughly 500 tickets/month. Our gross margin is looking worse than we expected — we think inference costs are eating into it. Help us model this."

## Command: /agentic-ai-engineering:agentic-economics-and-moats

## Skill: agentic-economics-and-moats

### Inputs gathered

1. Pricing: $99/seat/month
2. Usage: ~500 tickets/month per seat
3. Agent type: ReAct agent, reads customer history + KB, drafts responses, classifies escalations
4. Current cost: ~$0.12/ticket in inference (estimate from the team)
5. Existing optimization: None
6. Other direct costs: ~$5/seat/month (storage + third-party integrations)

### Step 2 — Inference cost trap diagnosis

**Estimates:**
- Revenue per ticket: $99 / 500 = $0.198/ticket
- Inference cost per ticket: $0.12 (given)
- Cost-to-revenue ratio: $0.12 / $0.198 = **60.6%**

**Warning flag:** Cost-to-revenue ratio is 60.6% — far above the 30% threshold. Inference cost alone is consuming more than half of per-ticket revenue.

Agent profile check:
- ReAct agent with 4–6 tool calls per ticket (KB search, CRM lookup, draft response, escalation classifier)
- Estimated input tokens per ticket: ~8K (system prompt + KB context + customer history + 4 tool responses)
- Estimated output tokens per ticket: ~3K (reasoning traces + tool arguments + drafted response)
- At frontier model pricing: ~$0.11–0.13/ticket — consistent with team's $0.12 estimate

**Diagnosis:** This is a classic inference cost trap. The per-seat pricing was set without accounting for per-ticket inference costs at realistic usage volumes.

### Step 3 — Contribution Margin LTV

**Model (per seat/month):**
- Monthly revenue: $99.00
- Inference cost (500 tickets × $0.12): $60.00
- Other direct costs: $5.00
- Total COGS: $65.00
- Monthly gross contribution: $34.00
- Gross contribution margin: **34.4%** — below healthy threshold of 60%

**Retention assumption:** 20 months (typical SaaS at this stage)

**Contribution Margin LTV:** $34/month × 20 months = $680/seat

**CAC (assumed):** $300 (PLG acquisition)

**LTV:CAC:** $680 / $300 = 2.3:1 — below the 3:1 target

**Payback period:** $300 / $34 = 8.8 months — borderline

**Conclusion:** The product is cash-flow positive but not in a healthy unit economics position. At 34% gross contribution margin, there is no room for CAC increase, support costs, or R&D investment.

### Step 4 — Cost optimization opportunities

**Priority 1 — Tiered model routing (estimated 35–40% cost reduction)**
- Classification (is this escalation-worthy?) and structured extraction (customer name, product) → route to Haiku-class model
- Only the drafted response generation requires a frontier model
- Estimated new cost: $0.07/ticket → new margin: $0.198 - $0.07 - $0.01 (other) = $0.118/ticket → **59.6% gross margin**

**Priority 2 — Semantic caching (estimated 15–20% additional reduction)**
- Many support tickets ask the same questions; KB search results can be cached
- Estimated new cost after caching: $0.055/ticket → **72.2% gross margin** if caching captures ~20% of queries

**Priority 3 — Prompt compression (estimated 10–15% reduction)**
- System prompt review: likely contains verbose instructions that can be tightened
- Lower priority — address after routing and caching are implemented

**Combined impact:**
| Optimization | Cost/ticket | Gross margin |
|---|---|---|
| Baseline (current) | $0.12 | 34.4% |
| After model routing | $0.07 | 59.6% |
| After + caching | $0.055 | 72.2% |
| After + compression | $0.048 | 75.8% |

### Step 5 — Moat stack assessment

| Layer | Depth | Evidence |
|---|---|---|
| Workflow position | 2 | Agent handles daily ticket queue; removing it would slow response times |
| Context advantage | 1 | Some customer history stored, but context advantage is modest after 3 months |
| Domain SOP capture | 1 | Generic support prompts; little domain-specific expertise encoded |
| Evaluation advantage | 0 | No structured eval suite yet |
| Habit and spread | 1 | Daily use by agents; team-level adoption growing but not viral |

**Total: 5/15 — Shallow moat**

**Priority moat investments:**
1. Evaluation advantage: build labeled dataset from 3 months of production corrections (CSAT overrides, manual re-drafts) — this data exists; it just needs to be captured
2. Domain SOP capture: encode support playbook and escalation heuristics into system prompt and guardrails
3. Context advantage: store per-customer communication history and preferences across sessions

### Step 6 — Data flywheel design

**Current state:** Minimal. Tickets are processed but feedback loops are not closed.

**MAPE design:**

- **Monitor**: Log all ticket outcomes (resolved, escalated, re-opened), agent drafts vs. final sent response (capture edits), customer satisfaction signals (CSAT, re-contact within 24h)
- **Analyze**: Weekly automated grader run on sampled tickets (LLM-as-judge on response quality); human review of escalated tickets; cluster analysis on re-opened tickets (likely agent failure pattern)
- **Plan**: Backlog of prompt updates and guardrail changes driven by analysis findings; new golden fixtures from high-quality examples
- **Execute**: Prompt changes tested on 10% of traffic before full rollout; regression test on golden fixture set

**Flywheel quality:**
- Signal richness: Medium (edits are rich; CSAT is coarse)
- Feedback loop speed: Currently none → target: 2-week loop
- Proprietary data: Support transcript corpus is proprietary; growing with each ticket

### Document written

`.agentic/artifacts/economics-support-agent.md`

```
Economics and Moats: Customer Support Agent

Inference cost risk: HIGH — 60% cost-to-revenue ratio (threshold: 30%)
Gross contribution margin: 34.4% (target: >60%)
LTV:CAC: 2.3:1 (target: >3:1)

Top recommendation: Implement tiered model routing immediately.
Expected impact: raise gross margin from 34% to ~60% without price change.
ROI: ~3 weeks engineering effort → recovers ~$26/seat/month in margin.

Moat depth: 5/15 — Shallow. Highest priority: build eval advantage from
existing production corrections data.

Next step: implement cost optimization (engineering), then run
/agentic-evals to design the eval suite that powers the data flywheel.
```
