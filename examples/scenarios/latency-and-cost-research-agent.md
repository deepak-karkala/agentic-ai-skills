# Scenario: Latency and Cost Optimization with Cost-Performance Subagent

## Trigger

> "Our research agent costs $2.40 per research task and takes 18 seconds P95. We process 500 tasks/day. That's $1,200/day — it's becoming a serious cost problem. Help us break down where the money is going and what to do about it."

## Skill: latency-and-cost-optimization → agent-cost-performance-analyst (delegated)

### Inputs gathered

1. Agent: Research Agent — ReAct loop; tools: web-search (×3 avg), page-scraper (×2 avg), summarizer (×1), citation-checker (×1)
2. Current cost: $2.40/task; 500 tasks/day → $1,200/day ($36,000/month)
3. Current latency: 18s P95
4. Model: claude-opus-4-7 for all LLM calls (orchestrator + summarizer)
5. No caching in place
6. Steps run sequentially

### Step 2 — Delegate to agent-cost-performance-analyst

**Delegation trigger:** Full pipeline decomposition across input tokens, output tokens, tool calls, caching eligibility, and parallelization opportunities for an 8-step pipeline will exceed ~500 tokens inline. Delegate.

**Findings synthesized from agent-cost-performance-analyst:**

#### Cost decomposition (per task)

| Bucket | Cost | % of total | Primary driver |
|---|---|---|---|
| Input tokens | $0.92 | 38% | System prompt repeated in full on every ReAct step (avg 7 steps × 2,100 tokens) |
| Output tokens | $0.54 | 23% | Orchestrator reasoning traces (avg 420 tokens/step × 7 steps) |
| Tool calls (web-search API) | $0.72 | 30% | 3 searches/task × $0.24/search (SerpAPI pricing) |
| Tool calls (page-scraper) | $0.18 | 8% | 2 scrapes/task at $0.09/scrape |
| Infrastructure | $0.04 | 2% | Orchestration overhead |

**Top cost driver:** Tool calls (web-search) — 30% of total cost. Input token inflation from repeated system prompt is second (38%, but partially cacheable).

#### Latency decomposition (P95)

| Segment | Duration | % of total | Reducible? |
|---|---|---|---|
| Inference (7 LLM calls) | 8.4s | 47% | Partial — model tier |
| Tool execution (5 tool calls sequential) | 7.2s | 40% | Yes — parallelizable |
| Network roundtrips | 1.8s | 10% | Partial — caching |
| Serialization | 0.6s | 3% | No |

**Top latency driver:** Sequential tool execution — 40% of total latency, fully parallelizable.

#### Caching opportunities

| Step | Eligible? | Estimated hit rate | Expected cost reduction |
|---|---|---|---|
| System prompt prefix (2,100 tokens) | Yes — prefix ≥ 1024 tokens; reused on every step | 85% across steps | ~$0.35/task saved (input token reduction) |
| Web-search results (recent queries) | Partial — 15-min TTL viable for research queries | 25% | ~$0.18/task saved |
| Page scraper (same URL ≤ 24h) | Yes | 40% | ~$0.07/task saved |

#### Parallelization opportunities

| Steps | Currently sequential | Independent? | Estimated latency saving |
|---|---|---|---|
| web-search calls (3 per task) | Yes | Yes — queries are independent | 4.2s (run 3 in parallel; max replaces sum) |
| page-scraper calls (2 per task) | Yes | Yes | 2.7s |
| Total | — | — | ~6.9s latency reduction |

#### Model tier overuse

| Step | Current model | Recommended | Estimated saving |
|---|---|---|---|
| Web-search query generation | claude-opus-4-7 | claude-haiku-4-5 | ~70% cost reduction on this step (~$0.08/task) |
| Citation checker | claude-opus-4-7 | claude-haiku-4-5 | ~70% cost reduction (~$0.06/task) |
| Summarizer (final synthesis) | claude-opus-4-7 | Keep — complex reasoning required | — |
| Orchestrator (ReAct loop) | claude-opus-4-7 | claude-sonnet-4-6 | ~60% cost reduction (~$0.28/task); validate quality |

### Step 3 — Ranked optimization plan

| Action | Cost saving | Latency saving | Effort |
|---|---|---|---|
| 1. Enable prompt caching on system prompt prefix | ~$0.35/task ($175/day) | 1.2s | < 1 day |
| 2. Parallelize web-search calls | $0 | 4.2s | 1 day |
| 3. Parallelize page-scraper calls | $0 | 2.7s | < 1 day |
| 4. Route query-gen + citation-checker to claude-haiku-4-5 | ~$0.14/task ($70/day) | 1.5s | 1–2 days |
| 5. Route orchestrator to claude-sonnet-4-6 (A/B test first) | ~$0.28/task ($140/day) | 0.8s | 2–3 days |
| 6. Add 15-min web-search result cache | ~$0.18/task ($90/day) | 1.8s | 2–3 days |

**Effort-to-impact classification:**
- Quick wins (< 1 day): prompt caching, parallelize scraper calls
- Medium investment (1–3 days): parallelize search calls, model routing for sub-tasks
- High investment (> 3 days): orchestrator model change (requires A/B validation)

### Step 4 — Projected outcome

If actions 1–4 are implemented (1 week of engineering):
- Cost: $2.40 → ~$1.53/task (−36%); $1,200/day → $765/day (−$435/day savings)
- Latency: 18s → ~10s P95 (−44%)
- If action 5 validates (2 weeks): cost → ~$1.25/task (−48%); latency → ~9.2s P95

**Tradeoff note:** Actions 4–5 require quality validation. Recommend A/B testing orchestrator model change against a 50-task golden set before full rollout.

### Output

**Optimization plan written to:** `.agentic/artifacts/latency-and-cost-research-agent.md`

**Summary:**
- Top cost driver: tool calls (web-search, 30%) + input token inflation (38%)
- Top latency driver: sequential tool execution (40%, fully parallelizable)
- Highest-leverage quick wins: prompt caching ($175/day saving) + parallelization (6.9s latency reduction)
- agent-cost-performance-analyst delegation used: yes — 8-step pipeline with four optimization dimensions exceeded inline threshold
- Next step: implement prompt caching (day 1), then parallelize tool calls (day 2), then A/B test model routing (week 2)
