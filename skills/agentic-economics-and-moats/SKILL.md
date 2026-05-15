---
name: agentic-economics-and-moats
description: >
  Analyzes the unit economics and competitive moat structure of an agentic AI
  product. Models the inference cost trap (5–25x multiplier), builds a
  contribution margin LTV analysis, identifies cost optimization levers,
  assesses the five-layer moat stack, and designs the data flywheel (MAPE
  loop). Use when evaluating whether the pricing model will survive inference
  costs at scale, when designing the moat-building strategy, when a product
  is growing but margins are deteriorating, or when an investor or stakeholder
  asks about the unit economics of an agentic AI product.
  Trigger phrases: "will this pricing model work at scale", "model the unit
  economics for this agent product", "are we losing money on inference",
  "how do we build a defensible moat for this agent", "design our data
  flywheel", "what's the LTV for this agentic AI product", "how do we
  optimize inference costs", "is our margin structure sustainable".
  Do not use for product strategy and wedge decisions (use
  agentic-product-strategy), for technical architecture (use
  agentic-system-design), or for evaluating whether a workflow is
  agent-shaped (use agentic-opportunity-framing).
allowed-tools:
  - Read
  - Write
metadata:
  category: product-strategy
  version: "0.1.0"
---

# Agentic Economics and Moats

Unit economics and moat design skill. Models inference cost impact on margins, builds a contribution margin LTV framework, identifies cost optimization levers, and designs the data flywheel. Produces a structured economics and moat document.

## When to Use

**Use when:**
- Evaluating whether a pricing model will survive inference costs at scale
- Margins are deteriorating as usage grows — diagnosing the cause
- Designing a data flywheel to create compounding competitive advantage
- An investor or stakeholder asks about the unit economics of an agent product
- Moving from seat-based to usage-based or outcome-based pricing

**Do not use when:**
- The question is about product wedge or market entry → use `agentic-product-strategy`
- The question is about technical agent architecture → use `agentic-system-design`
- The question is about workflow fit → use `agentic-opportunity-framing`
- The request is for a full financial model or business plan outside agentic AI economics

## Workflow

### Step 1 — Gather context

Ask the user:
1. What is the current pricing model? (Per seat, per workflow execution, per outcome, flat monthly?)
2. What is the approximate LLM inference cost per workflow execution today?
3. What is the average revenue per execution (or per customer per month)?
4. What are the main cost drivers: input token volume, output token volume, tool calls, number of model passes?
5. Are there any current cost optimization measures in place (caching, prompt compression, tiered models)?

If the user provides approximate numbers, use them. If not, work with ranges and flag the assumptions.

---

### Step 2 — Diagnose the inference cost trap

Quantify the inference cost multiplier relative to a comparable non-agentic implementation.

**Reference baseline:**
- Simple chat completion (single-turn, ~1K tokens in/out): 1x baseline cost unit
- Agent with 3–5 tool calls, multi-turn: 5–10x baseline
- Agent with 10+ tool calls, multi-pass reasoning: 10–25x baseline
- Supervisor + 2–3 workers: 15–40x baseline
- Supervisor + 5+ workers: 40–80x baseline

**Cost trap diagnosis:**
1. Estimate total input tokens per workflow execution (system prompt + context + tool responses)
2. Estimate total output tokens per workflow execution (reasoning traces + tool calls + final output)
3. Apply current model pricing to get cost-per-execution
4. Compare to current revenue-per-execution

**Warning signs:**
- Cost-per-execution is more than 30% of revenue-per-execution: margin pressure is significant
- Cost-per-execution is growing faster than usage (context accumulation, longer reasoning chains): negative scale economics
- The "per seat" price was set without considering per-execution inference costs: pricing model may be misaligned

See [Economics Reference](references/economics-reference.md) for cost calibration tables and pricing model patterns.

---

### Step 3 — Build contribution margin LTV

Standard LTV:CAC is misleading for agentic AI products because inference cost is a direct cost of revenue that scales with usage. Use **Contribution Margin LTV** instead.

**Formula:**

```
Contribution Margin LTV = Σ (Revenue per period - COGS per period) × Retention period
```

Where **COGS per period** = inference cost + data storage + API costs + human oversight cost (HITL labor, where applicable)

**Build the model:**

1. **Revenue per period**: Monthly recurring revenue per customer (or per-execution revenue × average monthly executions)
2. **Inference cost per period**: Cost-per-execution × average monthly executions
3. **Other direct costs per period**: Data storage, third-party API costs, HITL labor if applicable
4. **Gross contribution margin per period**: Revenue - Total direct costs
5. **Retention estimate**: Average months before churn (or 1/monthly churn rate)
6. **Contribution Margin LTV**: Gross contribution margin per period × retention estimate

**Key ratios to assess:**
- Gross contribution margin %: Target >60% at scale; <40% indicates pricing or cost structure problem
- LTV:CAC (using contribution margin LTV): Target >3:1 for sustainable growth
- Payback period (CAC / monthly gross contribution margin): Target <18 months for most B2B SaaS

---

### Step 4 — Identify cost optimization levers

Assess which cost optimization techniques are applicable:

| Technique | Cost reduction | Implementation effort | When to apply |
|---|---|---|---|
| **Prompt compression** | 20–50% input token reduction | Low | System prompt is long or repetitive |
| **Semantic caching** | Up to 80% cost reduction on repeated queries | Medium | High query similarity expected |
| **Tiered model routing** | 50–90% for routed tasks | Medium | Not all tasks require frontier model |
| **Context window management** | 20–40% per-call reduction | Medium | Long-running agents with context accumulation |
| **Batch processing** | 30–50% for async workloads | Low-Medium | Latency-insensitive workflows |
| **Tool call optimization** | 10–30% reduction | Medium | Agents making redundant or unnecessary tool calls |
| **Fine-tuning for specific tasks** | 60–80% cost reduction for that task | High | High-volume, narrow-scope subtasks |
| **Structured output validation** | Reduces retry cost | Low | Frequent tool call failures or malformed outputs |

**Priority guidance:** Apply prompt compression and tiered model routing first — they have the best effort-to-impact ratio. Cache second if the query pattern supports it. Fine-tuning last — it requires training data and ops investment.

For detailed implementation patterns, see [Economics Reference](references/economics-reference.md).

---

### Step 5 — Assess the five-layer moat stack

Score each moat layer on depth (0 = not present, 1 = early stage, 2 = moderate, 3 = deep/defensible):

| Layer | Description | Depth (0–3) |
|---|---|---|
| **Workflow position** | Agent owns a step in the buyer's critical daily workflow | |
| **Context advantage** | Agent accumulates org-specific context that improves quality over time | |
| **Domain SOP capture** | Agent encodes expert SOPs not available to generalist models | |
| **Evaluation advantage** | Team has labeled data and eval infrastructure competitors lack | |
| **Habit and spread** | Agent is a daily habit; spreads organically within orgs | |

**Interpretation:**
- Total 12–15: Deep moat. Defensible for 2–3 years without significant new investment.
- Total 8–11: Moderate moat. Defensible for 12–18 months; identify the shallowest layers and prioritize.
- Total 4–7: Shallow moat. Replication risk within 6–12 months. Prioritize 1–2 layers immediately.
- Total 0–3: No moat. Product is a thin wrapper; competitors (or the model provider) can replicate quickly.

---

### Step 6 — Design the data flywheel (MAPE loop)

An agentic AI product with a data flywheel improves faster than competitors as usage scales. Design the MAPE loop:

**Monitor → Analyze → Plan → Execute**

1. **Monitor**: What signals does the product collect from each workflow execution?
   - Success / failure outcomes
   - User corrections or overrides
   - Tool call results and errors
   - User engagement (accepted, edited, rejected outputs)

2. **Analyze**: How are signals processed to identify improvement opportunities?
   - Automated graders on logged outputs
   - Human review of sampled cases
   - Error clustering to identify systematic failures

3. **Plan**: How do findings feed back into product improvements?
   - Prompt updates
   - Eval golden fixture additions
   - Fine-tuning data curation
   - Guardrail adjustments

4. **Execute**: How are improvements deployed and validated?
   - A/B testing new prompts
   - Regression testing before deployment
   - Staged rollout with monitoring

**Flywheel quality assessment:** Rate the current data flywheel on three dimensions:
- **Signal richness**: Are the collected signals meaningful? (User overrides are richer than thumbs-up/down)
- **Feedback loop speed**: How quickly do signals become product improvements? (Days vs. months)
- **Proprietary data accumulation**: Is the feedback data specific to this product, or would it benefit competitors too?

---

### Step 7 — Write the economics document

Write a structured economics and moat document to:
- `artifact_output_path/economics-<name>.md` if `artifact_output_path` is configured in `.agentic/config.yml`
- Otherwise: `.agentic/artifacts/economics-<name>.md`

Use the format:

```markdown
# Economics and Moats: <Product Name>

## Inference Cost Analysis
[Cost-per-execution estimate with assumptions]
[Cost-to-revenue ratio]
[Warning flags if applicable]

## Contribution Margin LTV
[Model with assumptions stated]
[Gross contribution margin %]
[LTV:CAC ratio (if CAC is known)]
[Payback period]

## Cost Optimization Opportunities
[Prioritized list of 2–3 techniques with estimated impact]

## Moat Stack Assessment
[Score table with per-layer evidence]
Total: N/15 — [Deep / Moderate / Shallow / No moat]

## Data Flywheel Design
[MAPE loop with specifics for this product]
[Signal richness, feedback loop speed, proprietary data accumulation assessment]

## Recommendations
[Top 2–3 actions with expected impact]
[Pricing model changes if warranted]

## Risks
[Key economic or competitive risks]
```

---

### Step 8 — Report

After writing the document:
1. State the file path.
2. State the gross contribution margin % and whether it is on track for the target.
3. Flag any inference cost trap risk (cost-to-revenue ratio > 30%).
4. State the moat stack total and the shallowest layer.
5. Suggest next steps: pricing model adjustment, cost optimization, or moat-building investment.

## Output Contract

- **Primary output:** Economics and moat Markdown document at `artifact_output_path/economics-<name>.md` or `.agentic/artifacts/economics-<name>.md`
- **In-conversation summary:** margin health, inference cost risk, moat depth, top recommendations
- **Does not produce:** product strategy, architecture decisions, financial projections, investor materials

## Scope Boundaries

This skill models economics and designs the moat strategy. It does not make product strategy or architecture decisions. If the analysis reveals a product positioning problem (wrong ICP, weak wedge), route to `agentic-product-strategy`. If it reveals an architecture inefficiency (too many model passes, wrong orchestration pattern), route to `agentic-system-design`.
