---
name: latency-and-cost-optimization
description: >
  Analyzes and optimizes the latency and cost profile of a running or
  planned agentic AI system. Covers cost driver identification across
  token spend, tool overhead, model tier, and API fees; latency breakdown
  by layer (model inference, tool execution, serialization, network);
  optimization action selection including caching strategies (semantic,
  KV, prompt), model routing and cascades, prompt compression, parallelization
  of tool calls, streaming output, and batching; and tradeoff guidance
  between cost, quality, and responsiveness across autonomy tiers.
  Distinguishes architecture-level optimization choices from operational
  tuning of a running system.
  Use when the agent is too slow or too expensive in production or staging,
  when a cost or latency budget is being set before launch, when you need
  to identify which layer is the dominant cost or latency driver, when
  model or caching changes need to be evaluated before making them, or
  when a cost-reduction effort risks degrading output quality.
  Trigger phrases: "why is this agent too slow", "how do I cut inference
  cost", "which tool is most expensive", "optimize latency for this agent",
  "what caching strategy should I use", "reduce token spend without
  hurting quality", "cost per task is too high", "latency is too high at
  P95", "how do I parallelize tool calls", "model cascade for cost routing".
  Do not use for greenfield agent architecture (use agentic-system-design),
  for observability infrastructure design (use agent-observability),
  or for context compression as the only goal without a cost or latency
  problem (use context-engineering-for-agents).
allowed-tools:
  - Read
  - Write
metadata:
  category: technical
  version: "0.1.0"
---

# Latency and Cost Optimization

Production optimization skill. Identifies dominant cost and latency drivers in an agentic system and selects the highest-leverage optimization actions. Produces a ranked optimization plan with tradeoff guidance.

## When to Use

**Use when:**
- Agent is over budget or over latency threshold in production or staging
- Setting cost or latency targets before launch
- Evaluating whether a caching, model routing, or compression change is worth making
- A cost-reduction effort risks quality regression and you need tradeoff guidance
- You have profiling data and need to identify which layer to fix first

**Do not use when:**
- The problem is agent architecture choices → use `agentic-system-design`
- The goal is to design observability infrastructure to get cost/latency data → use `agent-observability`
- Context compression is the only question without a cost or latency budget problem → use `context-engineering-for-agents`
- The system has not yet launched and you're designing from scratch without a measured baseline (optimization without data is premature)

## Workflow

### Step 1 — Gather the cost and latency profile

Ask the user for:
1. Current measured cost per task (or cost per session). If not measured, explain why this is required before optimization.
2. Current measured latency (p50/p95/p99) end-to-end and, if available, per layer.
3. Target budget: what is the acceptable cost per task and latency SLA?
4. Model(s) in use and their pricing tier.
5. Average tool call count per session and breakdown by tool type.
6. Any existing caching layer (semantic cache, KV cache, prompt cache)?
7. Architecture: single agent, orchestrator-workers, pipeline? Sequential or parallelizable tool calls?

If the user cannot provide measured numbers, help them add the minimum instrumentation first (recommend `agent-observability`). Optimization without data produces guesses, not improvements.

---

### Step 2 — Identify the dominant cost driver

Decompose cost using the cost-per-task formula:

```
Cost per task =
  (input_tokens × input_price_per_token)
  + (output_tokens × output_price_per_token)
  + (tool_calls × tool_cost_per_call)
  + (external_api_fees)
  + (infrastructure_overhead)
```

**Cost driver categories:**

| Driver | Typical share | Optimization lever |
|---|---|---|
| Input tokens (large context, retrieved docs) | 40–70% | Context compression, retrieval quality, prompt caching |
| Output tokens (verbose responses) | 10–30% | Output format constraints, structured output schemas |
| Tool calls (API fees, per-call cost) | 5–40% | Tool call deduplication, result caching, batching |
| Model tier (using frontier when not needed) | Variable | Model routing cascade |
| Redundant LLM calls (retry loops, self-checks) | 5–20% | Loop detection, confidence thresholds, single-pass design |

Identify the top-1 or top-2 drivers. Do not optimize across all drivers simultaneously — start with the one that accounts for the most cost.

---

### Step 3 — Identify the dominant latency driver

Decompose latency by layer:

```
End-to-end latency =
  model_inference_latency (per LLM call × call count)
  + tool_execution_latency (per tool × call count)
  + context_serialization_latency (tokenization + context assembly)
  + network_roundtrip_latency (client ↔ API × roundtrips)
  + retrieval_latency (if RAG is in the path)
```

**Latency breakdown guidance:**

- **Inference dominates (>60% of latency):** The bottleneck is model inference. Options: smaller/faster model, streaming to reduce perceived latency, caching repeated prompts.
- **Tool execution dominates (>40% of latency):** The bottleneck is tool calls. Options: parallelize independent tool calls, cache tool results, eliminate redundant calls.
- **Sequential tool chains:** Each tool must wait for the previous. Options: graph the dependency chain and identify which calls can be parallelized.
- **Context serialization:** Unusually large context windows. Options: context compression, selective retrieval, sliding window.

Build a latency critical path diagram — identify the longest sequential chain and the calls that can run in parallel.

---

### Step 4 — Select optimization actions

Match the dominant driver to the highest-leverage optimization. Apply in priority order — do not pre-optimize multiple layers at once.

**Caching strategies (highest leverage for repeated queries):**

| Cache type | What it covers | Best for |
|---|---|---|
| Prompt cache (Anthropic, OpenAI) | Repeated prefix tokens | System prompts, long instructions, few-shot examples |
| Semantic cache | Near-duplicate user queries | Customer service agents, FAQ agents |
| Tool result cache | Deterministic tool calls | Read-only tools with stable results (knowledge base, catalog lookups) |
| KV cache reuse | Adjacent token batches | High-throughput batch processing |

**Model routing cascade:**

Route queries to the cheapest model that can handle them. Use a cascade:
1. Cheap/fast model for simple classification or structured extraction
2. Mid-tier model for moderate reasoning tasks
3. Frontier model only when the task requires it (complex reasoning, nuanced judgment)

Cascade design rules:
- Define a routing signal: query complexity score, keyword classification, or a fast classifier model
- Define the fallback trigger: when the fast model output fails a quality check, escalate to the next tier
- Never cascade without a quality gate — a fast model giving wrong answers is not a cost savings

**Tool call optimization:**

- **Parallelize independent calls:** If tool A and tool B do not depend on each other's output, call them concurrently. Most orchestration frameworks support this — it is commonly the single highest-impact latency fix.
- **Deduplicate calls:** If the same tool is called with the same arguments in a session, return the cached result.
- **Eliminate unnecessary calls:** Audit the agent's trajectory — are all tool calls strictly necessary? A common failure is calling a confirmation tool after every action rather than only when the action is irreversible.

**Output format constraints:**

Verbose natural-language outputs cost more than structured outputs. If the output is consumed programmatically or rendered in a UI, switch to:
- JSON schema output with a defined structure
- Bulleted lists instead of paragraphs
- Summary + details pattern (output the short summary; generate detail only on request)

**Prompt compression:**

Compress the system prompt and few-shot examples. Techniques:
1. Remove filler language and redundant instructions
2. Replace verbose examples with compact schemas
3. Move static context to a cached prefix
4. Use retrieval for dynamic context rather than injecting all relevant docs

Warning: Prompt compression is high-risk for quality. Always measure output quality before and after. Set a minimum quality threshold before applying compression.

**Streaming output:**

If latency is user-perceived (a human is watching), streaming reduces perceived latency without reducing actual inference time. Implement streaming for any user-facing output. Do not implement streaming for programmatic consumers — they need the complete output.

---

### Step 5 — Evaluate tradeoffs

Before committing to any optimization, evaluate:

**Cost vs. quality tradeoff:**
- Will this reduction in tokens or model tier reduce accuracy or completeness?
- Run the proposed change through the eval suite. Any optimization that degrades eval scores below the production threshold is not a valid optimization.
- Set a minimum acceptable quality floor before starting any cost reduction work.

**Latency vs. cost tradeoff:**
- Caching improves both latency and cost — always prioritize caching opportunities first.
- Smaller models reduce cost but may increase latency if the task requires multiple calls to compensate for lower quality.
- Parallelization reduces latency but may increase cost if it causes more total tool calls.

**When NOT to optimize:**
- When the agent has no production traffic yet (no baseline to optimize against)
- When optimizing would require degrading quality below the minimum acceptable threshold
- When the engineering cost of the optimization exceeds the projected savings over the next quarter
- When the dominant cost driver will change with the next architectural change anyway

---

### Step 6 — Write the optimization plan

Write a ranked optimization plan to:
- `artifact_output_path/optimization-<agent-name>.md` if `artifact_output_path` is configured in `.agentic/config.yml`
- Otherwise: `.agentic/artifacts/optimization-<agent-name>.md`

Format:

```markdown
# Optimization Plan: <Agent Name>

## Current Profile
Cost per task: [measured]
Latency p95: [measured]
Target: [cost target] / [latency target]

## Dominant Drivers
1. [Top cost driver]: [% of total cost]
2. [Top latency driver]: [% of end-to-end latency]

## Optimization Actions (ranked by impact)
1. [Action] — Expected impact: [quantified estimate] — Risk: [Low/Med/High]
2. ...

## Quality Gates
Minimum acceptable: [eval metric threshold]
Test before/after: [eval suite reference]

## Not Recommended
[Actions evaluated and rejected, with reason]
```

---

### Step 7 — Report

After writing the plan:
1. State the file path.
2. Name the top cost driver and the highest-leverage action.
3. Name the top latency driver and the highest-leverage action.
4. Flag any optimization with a quality-regression risk and the required quality gate.
5. Suggest next steps: `agent-observability` if profiling data is insufficient, `agent-eval-design` if there is no eval suite to gate quality against.

## Output Contract

- **Primary output:** Optimization plan at `artifact_output_path/optimization-<agent-name>.md` or `.agentic/artifacts/optimization-<agent-name>.md`
- **In-conversation summary:** dominant cost driver, dominant latency driver, top-ranked actions, quality tradeoff warnings
- **Does not produce:** agent architecture decisions, observability instrumentation plans, eval scorecard design

## Scope Boundaries

This skill tunes a running system. It does not redesign the architecture (use `agentic-system-design`), design observability infrastructure to collect the profiling data (use `agent-observability`), or design the eval suite to gate quality regressions (use `agent-eval-design`). Context compression is one optimization lever within this skill — when context compression is the only question and there is no cost or latency budget pressure, route to `context-engineering-for-agents` instead.
