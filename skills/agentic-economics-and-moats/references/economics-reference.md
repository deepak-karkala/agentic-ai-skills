# Economics Reference

Reference for the `agentic-economics-and-moats` skill. Contains inference cost calibration tables, pricing model patterns, cost optimization implementation details, and contribution margin LTV worked examples.

---

## Inference Cost Calibration

### Cost Multiplier by Agent Type

| Agent type | Input tokens (est.) | Output tokens (est.) | Cost multiplier vs. single chat |
|---|---|---|---|
| Single-turn chat (baseline) | ~1K | ~0.5K | 1x |
| ReAct agent, 3–5 tool calls | 5–10K | 2–4K | 5–10x |
| ReAct agent, 10+ tool calls | 15–30K | 5–10K | 15–25x |
| Supervisor + 2 workers | 20–50K | 8–15K | 20–40x |
| Supervisor + 5 workers | 40–100K | 15–30K | 40–80x |
| Multi-pass reasoning (CoT) | 2–3x above baseline | 3–5x above baseline | Additional multiplier on top |

**Notes:**
- Input token counts include system prompt, tool definitions, conversation history, and tool call responses
- Output token counts include reasoning traces (if CoT is used), tool call arguments, and final output
- Frontier model pricing as of 2025: approximately $3–15 per million input tokens, $15–60 per million output tokens
- Cached input tokens are typically 80–90% cheaper — semantic caching materially reduces costs

---

## Pricing Model Patterns

### Per-Seat (Subscription)

**Structure:** Fixed monthly fee per user, regardless of usage.

**When it works:** Low-variance usage across users; agent is a daily productivity tool with relatively consistent usage patterns.

**Inference cost risk:** HIGH — if users vary widely in usage intensity, heavy users create margin pressure while light users subsidize them. In agentic products, power users typically consume 5–10x more inference than light users.

**Mitigation:** Fair-use limits, overage charges above a monthly cap, or tiered seat pricing with usage bands.

---

### Per-Execution (Usage-Based)

**Structure:** Price per workflow execution (per document processed, per ticket handled, per report generated).

**When it works:** Clear, bounded unit of value; buyer can map price to outcome directly.

**Inference cost risk:** MEDIUM — cost is directly tied to revenue, but if the execution cost grows (context accumulation, more complex reasoning), margin erodes unless pricing adjusts.

**Mitigation:** Model pricing on P90 execution cost, not average, to preserve margin on long-tail heavy executions. Review execution cost vs. price quarterly.

---

### Outcome-Based

**Structure:** Price tied to a business outcome (cost saved, revenue generated, time reduced).

**When it works:** The outcome is measurable, attributable to the agent, and large relative to inference cost. Typically viable at Tier 3+ product architecture.

**Inference cost risk:** LOW correlation between cost and price — margin is high if outcome value >> inference cost.

**Risk:** Requires mature eval to prove outcome attribution. Buyers will demand proof before accepting outcome-based contracts.

---

### Tiered (Freemium → Team → Enterprise)

**Structure:** Free tier with usage caps, paid tiers with expanded limits and features.

**Inference cost design:**
- Free tier: must be designed so inference cost per free user is sustainable as a CAC investment, not an ongoing liability
- Rule of thumb: free tier cost per user should be <$1/month at scale
- Gate expensive features (long-context agents, multi-agent workflows) behind paid tiers

---

## Cost Optimization: Implementation Details

### Prompt Compression

**Goal:** Reduce input tokens without losing reasoning quality.

**Techniques:**
- Remove redundant instructions from system prompts (restructure as concise rules, not paragraphs)
- Use structured formats (JSON, YAML) for tool definitions and context injection — more token-efficient than prose
- Truncate conversation history to the most recent N turns plus a compressed summary
- Remove example turns once the model is production-proven — examples consume tokens at inference time

**Measurement:** Track average input tokens per execution before and after. Target 20–40% reduction.

---

### Semantic Caching

**Goal:** Serve identical or near-identical queries from cache rather than re-running inference.

**When to apply:**
- High query similarity: FAQ-style agent, structured data extraction with similar inputs
- Idempotent workflows: same input → same output (no real-time data dependency)

**Implementation:** Cache at the prompt-hash level for exact matches; use embedding similarity for semantic matches. Cache invalidation: time-based TTL or on underlying data change.

**Not applicable when:** Each query is unique (personalized reasoning, real-time data), or output freshness is critical.

---

### Tiered Model Routing

**Goal:** Route simpler subtasks to cheaper models while reserving frontier models for complex reasoning.

**Common routing pattern:**
- Classification / intent detection: small/fast model (Haiku-class)
- Structured extraction: small/fast model or fine-tuned
- Multi-step reasoning, complex judgment: frontier model (Sonnet/Opus-class)
- Tool call parsing: structured output from any tier

**Implementation:** Route at the task level within a supervisor-worker architecture. The supervisor uses the frontier model for orchestration decisions; workers use tiered models for their specific tasks.

**Cost impact:** 50–90% reduction on routed tasks. For a supervisor + 3 workers architecture where 2 workers are routing-eligible, total cost reduction can be 30–50%.

---

### Context Window Management

**Goal:** Prevent unbounded context growth in long-running agents.

**Techniques:**
- **Sliding window**: Keep only the last N turns in context; drop oldest
- **Summarization**: Compress early conversation turns into a summary at a token threshold
- **External memory**: Move episodic context to a vector store; retrieve on demand rather than including in every call
- **State compression**: Represent agent state as a structured object rather than raw conversation history

**When critical:** Long-running agents (10+ turns), multi-session agents that carry history across sessions, supervisor-worker architectures where the supervisor accumulates all worker outputs.

---

## Contribution Margin LTV: Worked Example

### Scenario: Invoice Processing Agent

**Inputs:**
- Price: $0.50 per invoice processed
- Average invoices/month per customer: 1,000
- Monthly revenue per customer: $500
- Inference cost per invoice: $0.08 (ReAct agent, ~8K tokens in/out)
- Monthly inference cost per customer: $80
- Other direct costs per customer/month: $10 (storage, third-party OCR API)
- Total COGS per customer/month: $90
- Monthly gross contribution: $500 - $90 = $410
- Gross contribution margin: 82%
- Average retention: 30 months (assumption)

**Contribution Margin LTV:**
$410/month × 30 months = $12,300

**CAC assumption:** $2,000 (PLG + light sales)

**LTV:CAC:** $12,300 / $2,000 = 6.15:1 — healthy

**Payback period:** $2,000 / $410 = 4.9 months — excellent

---

### Scenario with Cost Trap

**Same scenario but agent is a Supervisor + 3 Workers:**
- Inference cost per invoice: $0.40 (40K tokens, frontier model throughout)
- Monthly inference cost per customer: $400
- Total COGS per customer/month: $410
- Monthly gross contribution: $500 - $410 = $90
- Gross contribution margin: 18% — danger zone

**Diagnosis:** Inference cost trap. The product is under-priced for its actual cost structure.

**Options:**
1. Raise price to $2.00+/invoice to restore margin
2. Apply tiered model routing to reduce per-invoice cost to $0.15 or below
3. Combine: cost reduction + modest price increase to $0.80/invoice

---

## Moat Layer Depth: Assessment Questions

### Workflow Position (0–3)

- 0: Agent is used occasionally or as a one-off tool
- 1: Agent is part of a weekly workflow
- 2: Agent is part of a daily workflow but has workarounds
- 3: Agent is in the critical path of a daily workflow; removing it causes immediate operational friction

**Test:** Ask: "If the agent went down for a day, what would the user do?" If the answer is "we'd just do it manually like before," the moat depth is 0–1. If the answer is "we'd have to stop or delay a critical process," it's 2–3.

---

### Context Advantage (0–3)

- 0: Agent has no persistent memory; each session starts fresh
- 1: Agent stores some preferences or history but it has minimal impact on output quality
- 2: Agent has accumulated meaningful org-specific context (past decisions, patterns, preferences) that visibly improves output quality
- 3: Agent context is a major source of competitive advantage; removing it would degrade quality significantly; competitors would need months to replicate

---

### Domain SOP Capture (0–3)

- 0: Generic prompts; no domain-specific expertise encoded
- 1: Some domain vocabulary and basic heuristics in system prompt
- 2: Significant expert knowledge encoded; prompts and guardrails reflect domain-specific judgment
- 3: Deep SOP capture from domain experts; eval golden fixtures encode expert judgment; fine-tuning or RAG on domain-specific materials

---

### Evaluation Advantage (0–3)

- 0: No eval suite
- 1: Basic evals exist but are minimal and not production-grounded
- 2: Production-grounded evals with labeled failures; eval suite runs on deployment
- 3: Large labeled dataset from production; proprietary graders encoding expert judgment; competitors without this data cannot match quality at this cost

---

### Habit and Spread (0–3)

- 0: Used occasionally; no habit formation
- 1: Some users engage daily; limited cross-user visibility
- 2: Daily habit for power users; team-level features create network effects
- 3: Embedded in team workflows; new team members are onboarded onto it; organic spread within orgs documented

---

## MAPE Loop: Design Checklist

For each step, check whether the current product captures this:

**Monitor:**
- [ ] Are all tool calls and outcomes logged?
- [ ] Are user overrides and corrections captured?
- [ ] Are failure modes (timeouts, errors, low-confidence outputs) recorded with context?
- [ ] Is the signal granular enough to attribute quality to specific agent steps?

**Analyze:**
- [ ] Is there an automated pipeline that runs graders on logged outputs?
- [ ] Is there a process for human review of sampled outputs?
- [ ] Are failure patterns clustered and reviewed on a regular cadence?

**Plan:**
- [ ] Do analysis findings have a path to prompt updates, eval additions, or guardrail changes?
- [ ] Is there a backlog of eval-driven improvements?

**Execute:**
- [ ] Are prompt changes A/B tested before full deployment?
- [ ] Is regression testing automated and mandatory before deployment?
- [ ] Are improvements measurably attributed to the flywheel (before/after metrics)?
