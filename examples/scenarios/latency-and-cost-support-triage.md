# Scenario: Cutting Inference Cost for a Support Triage Agent at Scale

## Trigger

> "How do I cut inference cost without collapsing quality?"
>
> "Our support triage agent is costing $0.85 per ticket at current volume (500 tickets/day). We need to get below $0.30. The agent uses claude-3-5-sonnet for everything — classification, enrichment, and handoff message generation. P95 latency is also at 9s which feels too slow for live triage."

## Skill: latency-and-cost-optimization

### Inputs gathered

1. Agent: Support Triage Agent — Orchestrator-Workers pattern, 4 agents
2. Current cost: $0.85 per ticket; 500 tickets/day → $425/day
3. Target: $0.30 per ticket or below; latency target: < 4s P95
4. Model: claude-3-5-sonnet for all calls (orchestrator + all workers)
5. Average call count per ticket: 5 LLM calls; 3 tool calls (ticket-lookup, kb-search, crm-update)
6. Caching: none
7. Architecture: sequential — orchestrator calls workers serially; workers call tools serially

### Step 2 — Cost driver decomposition

| Driver | Estimated share | Details |
|---|---|---|
| Input tokens (full ticket + routing history in every call) | 55% | Ticket thread is injected into all 5 LLM calls; 1,800–2,400 input tokens per call |
| Output tokens (verbose handoff messages) | 15% | Handoff message averages 600 tokens; could be 200 with structured output |
| Model tier (frontier for all tasks including classification) | 20% | Classification step doesn't require frontier model quality |
| Redundant LLM calls (confirmation step after every routing decision) | 10% | Agent calls a confirmation LLM step after each worker — unnecessary for low-risk routing |

**Top cost driver: Input tokens** (shared full context injected into every downstream call)

### Step 3 — Latency breakdown

| Layer | Estimated contribution | Notes |
|---|---|---|
| Model inference (5 sequential LLM calls) | 72% (~6.5s) | At ~1.3s/call for sonnet |
| Tool execution (3 sequential tool calls) | 18% (~1.6s) | ticket-lookup + kb-search run sequentially |
| Network overhead | 10% (~0.9s) | |

**Top latency driver: Sequential LLM calls** — 5 calls in series with a frontier model dominates the budget.

### Step 4 — Optimization actions (ranked)

**Action 1 — Model routing cascade (impact: high, risk: medium)**
- Classification step (Tier-1 vs Tier-2/3 routing): replace claude-3-5-sonnet with claude-3-haiku
- Expected: saves ~$0.18/ticket on classification; classification is a structured extraction task well within haiku's capability
- Quality gate: run classification eval suite; require ≥ 97% accuracy (current sonnet baseline: 99.1%)
- Risk: test on full ticket category distribution — edge categories may require sonnet

**Action 2 — Parallelize tool calls (impact: high, risk: low)**
- ticket-lookup and kb-search are independent — run them concurrently
- Expected latency reduction: ~0.7s (one of the two 0.8s tool calls moves off the critical path)
- Risk: minimal — standard async pattern; no quality impact

**Action 3 — Prompt cache the system prompt prefix (impact: medium, risk: low)**
- The orchestrator system prompt (850 tokens) and worker instructions are static per ticket category
- Enable Anthropic prompt caching on the static prefix
- Expected: 30–50% reduction in input token cost on the 850-token prefix
- Risk: none — prompt caching is transparent to output quality

**Action 4 — Structured output for handoff messages (impact: medium, risk: low)**
- Current verbose prose handoff (~600 tokens) → JSON schema with defined fields (~180 tokens)
- Expected: saves ~$0.06/ticket in output tokens
- Risk: requires update to Tier-2 UI to render structured handoff — coordinate with frontend

**Action 5 — Eliminate confirmation LLM call (impact: low-medium, risk: low)**
- The confirmation step adds ~1.3s and ~$0.04/ticket
- For low-severity tickets (Tier-1 routing with confidence > 0.9), skip it
- Apply only to high-severity (Tier-2+) or low-confidence routings
- Expected: skip on ~65% of tickets → saves $0.026/ticket average

### Step 5 — Tradeoff assessment

Expected combined impact (Actions 1–5 together):
- Cost: $0.85 → ~$0.27/ticket (below $0.30 target)
- Latency: 9s P95 → ~4.5s P95 (close to target — may need Action 1 model tier to fully close)
- Quality risk: Action 1 is the only meaningful quality risk; blocked on eval gate (≥97% classification accuracy)

**Recommended sequencing:** Implement in order — Actions 2 and 3 first (zero-risk, measurable impact), then Action 4, then re-measure, then gate Action 1 on eval results.

**Not recommended:** Reducing context window for workers by summarizing the ticket — would save tokens but risks loss of critical ticket detail for specialist workers. Quality risk exceeds cost benefit at current token prices.

### Output

**Optimization plan written to:** `.agentic/artifacts/optimization-support-triage-agent.md`

Summary:
- Top cost driver: Input tokens (55%) — fix with prompt caching + model routing cascade
- Top latency driver: Sequential LLM calls — fix with parallelized tools + model cascade for classification
- Combined expected result: $0.85 → $0.27/ticket; 9s → ~4s P95
- Quality gate required for Action 1 (model cascade): ≥97% classification accuracy on full eval suite
- Recommended sequence: Actions 2, 3, 4 first (zero-risk); Action 1 after eval gate passes
