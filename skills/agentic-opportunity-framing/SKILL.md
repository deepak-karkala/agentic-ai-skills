---
name: agentic-opportunity-framing
description: >
  Evaluates whether a proposed workflow or use case is a strong candidate
  for an agentic AI solution. Scores the opportunity against a process-fit
  framework (7 traits), applies a build/don't-build filter, classifies the
  agent type, flags compounding error risk, and produces a structured framing
  document. Use when deciding whether to build an agent for a workflow, when
  assessing if a proposed use case is agent-shaped, when a team wants to
  audit their backlog for high-fit agentic opportunities, or when a stakeholder
  asks whether agentic AI is the right tool for a problem.
  Trigger phrases: "should we build an agent for this", "is this use case
  agent-shaped", "does this workflow need an agent", "score this workflow for
  agentic fit", "evaluate this opportunity for agentic AI", "is this a good
  candidate for an agent", "help us decide if we should automate this with an
  agent", "which of our workflows should we agentify first".
  Do not use for architecture design after a decision is made (use
  agentic-system-design), for product wedge and ICP strategy (use
  agentic-product-strategy), or for reviewing an existing agent system
  (use agentic-arch-review).
allowed-tools:
  - Read
  - Write
metadata:
  category: product-strategy
  version: "0.1.0"
---

# Agentic Opportunity Framing

Opportunity evaluation skill. Assesses whether a workflow is genuinely agent-shaped before a team commits to building. Applies a structured process-fit scoring rubric, a build/don't-build filter, and compounding error analysis to produce a defensible go/no-go framing document.

## When to Use

**Use when:**
- A team is deciding whether to build an agent for a workflow
- A stakeholder wants to know if a proposed use case is "agent-shaped"
- A backlog of automation ideas needs to be triaged for agentic fit
- An existing rule-based automation is being considered for upgrade to an agent

**Do not use when:**
- The decision to build is already made → use `agentic-system-design`
- The question is about product wedge, ICP, or market strategy → use `agentic-product-strategy`
- The question is about an existing deployed agent system → use `agentic-arch-review`
- The workflow is simple and deterministic (a script or pipeline will do) → answer directly

## Workflow

### Step 1 — Gather context

Ask the user:
1. Describe the workflow in one or two sentences: what triggers it, what decisions are made, what outputs are produced?
2. Who currently does this work, and how often?
3. What are the failure modes if the output is wrong?
4. Is there an existing automation or rule-based system handling any of this?

If the user has already described a workflow in the conversation, use that description. Do not re-ask for information already provided.

---

### Step 2 — Score process fit (7 traits)

Score the workflow against the 7 process-fit traits. Each trait is either present (1 point) or absent (0 points). See [Process-Fit Framework](references/process-fit-framework.md) for full definitions and examples.

| # | Trait | Score |
|---|---|---|
| 1 | Multi-step reasoning (not a lookup) | 0 or 1 |
| 2 | Requires tool use or external information | 0 or 1 |
| 3 | Judgment under uncertainty (not deterministic) | 0 or 1 |
| 4 | High-value enough to justify inference cost | 0 or 1 |
| 5 | Volume sufficient to amortize build cost | 0 or 1 |
| 6 | Low enough stakes for acceptable error rate | 0 or 1 |
| 7 | Human verification feasible at proposed autonomy tier | 0 or 1 |

**Interpretation:**
- 6–7 / 7: Strong candidate. Recommend proceeding to architecture design.
- 4–5 / 7: Conditional candidate. Identify which traits are absent and whether they can be mitigated.
- 0–3 / 7: Poor fit. A deterministic pipeline, rules engine, or simple automation is likely better.

Disqualifiers override the score — see Step 3.

---

### Step 3 — Check disqualifiers

Even with a high score, the following conditions disqualify the workflow from an agentic approach:

1. **Zero-tolerance error domain**: The workflow cannot tolerate any errors without human review (financial transactions with no correction window, safety-critical medical actions). An agent with supervised autonomy may still be viable if HITL is built in — flag this explicitly.
2. **No verifiable ground truth**: There is no way to evaluate whether the agent's output is correct. Without evaluation, there is no path to safe autonomy expansion.
3. **Latency incompatible**: The workflow requires sub-second response times and multi-step reasoning cannot fit within that budget.
4. **Data not available at inference time**: The workflow depends on proprietary or real-time data the agent cannot access via tools.
5. **Regulatory prohibition**: The workflow operates in a regulated domain that prohibits automated decision-making without explicit human sign-off in a way that negates the automation benefit.

For each disqualifier that applies: state it, state whether it blocks completely or whether a mitigation exists (e.g., supervised mode, HITL gate), and adjust the recommendation accordingly.

---

### Step 4 — Classify agent type

Based on the workflow description, classify the primary agent pattern:

| Type | Description | When to use |
|---|---|---|
| **Single-agent** | One LLM with tools, operating in a ReAct loop | Most workflows; start here |
| **Pipeline agent** | Pre-specified multi-step sequence, steps known in advance | Document processing, structured extraction |
| **Supervisor-worker** | Orchestrator delegates to specialist sub-agents | Parallel workstreams, specialized domains |
| **Human-in-the-loop (HITL)** | Agent proposes, human approves before execution | High-stakes actions, compliance requirements |
| **Fully autonomous** | Agent acts without human approval on each action | Only after eval proves reliability |

Apply the autonomy-first rule: start at supervised/HITL and expand only when eval data supports it. Do not recommend fully autonomous unless the use case is explicitly low-stakes and reversible.

---

### Step 5 — Compounding error analysis

Estimate the compounding accuracy risk for multi-step workflows.

Rule of thumb: at 95% per-step accuracy, a 10-step workflow succeeds end-to-end roughly 60% of the time (0.95^10 ≈ 0.60). At 90% per-step accuracy, a 5-step workflow succeeds roughly 59% of the time (0.90^5 ≈ 0.59).

Steps to complete:
1. Estimate the number of distinct decision points in the workflow.
2. Estimate realistic per-step accuracy (use 90–95% as a conservative starting range unless the user has eval data).
3. Calculate approximate end-to-end success rate.
4. If end-to-end success rate falls below 80%, flag this explicitly and recommend either reducing the number of autonomous steps (add HITL gates), increasing per-step accuracy requirements in evals, or treating this as a supervised assistant rather than an autonomous agent.

---

### Step 6 — Apply the build/don't-build filter

Before recommending an agent, verify the workflow passes all four filter properties:

1. **Handles genuine ambiguity**: The workflow requires judgment, not just pattern matching. A deterministic rule set can't capture all cases.
2. **Benefits from tool use**: The workflow gains meaningfully from connecting to external systems, APIs, or data sources at reasoning time.
3. **Value exceeds inference cost**: The value delivered per workflow execution justifiably exceeds the LLM inference cost (typically 5–25x more expensive than simple API calls). See [Process-Fit Framework](references/process-fit-framework.md) for cost calibration.
4. **Failure is recoverable**: Errors can be caught, corrected, and learned from — either via HITL, monitoring, or eval-driven improvement.

If any filter property fails: state which one, explain why, and recommend an alternative (rules-based automation, deterministic pipeline, simpler ML model, or human-only process).

---

### Step 7 — Write the framing document

Write a structured framing document to:
- `artifact_output_path/opportunity-framing-<name>.md` if `artifact_output_path` is configured in `.agentic/config.yml`
- Otherwise: `.agentic/artifacts/opportunity-framing-<name>.md`

Use the format:

```markdown
# Opportunity Framing: <Workflow Name>

## Summary
[2–3 sentences: what the workflow does, the go/no-go recommendation, and the primary rationale]

## Process-Fit Score
[Score table with per-trait justification]
Overall: N/7 — [Strong / Conditional / Poor] candidate

## Disqualifiers
[List any that apply with mitigation notes, or state "None identified"]

## Agent Type Recommendation
[Primary pattern with rationale; note if HITL is required]

## Compounding Error Estimate
[Step count, per-step accuracy assumption, end-to-end estimate, flag if below 80%]

## Build/Don't-Build Assessment
[One line per filter property: pass or fail with reasoning]

## Recommendation
[Go / No-Go / Conditional Go]
If Conditional Go: list the conditions that must be met before proceeding.
If No-Go: recommend the alternative approach.
If Go: suggest next step (agentic-system-design or agentic-product-strategy).

## Open Questions
[Any unresolved factors the team needs to clarify before committing]
```

---

### Step 8 — Report

After writing the document:
1. State the file path.
2. State the overall score (N/7) and recommendation (Go / No-Go / Conditional Go).
3. Call out any disqualifiers or compounding error flags.
4. Suggest next step: `agentic-system-design` if Go, `agentic-product-strategy` if strategic context is needed first, or the specific mitigation to address for a Conditional Go.

## Output Contract

- **Primary output:** Framing Markdown document at `artifact_output_path/opportunity-framing-<name>.md` or `.agentic/artifacts/opportunity-framing-<name>.md`
- **In-conversation summary:** score, recommendation, disqualifiers, next step
- **Does not produce:** architecture decisions, product strategy, eval plans, code

## Scope Boundaries

This skill evaluates fit and makes a recommendation. It does not design the agent. If the recommendation is Go, route to `agentic-system-design` for architecture. If the strategic fit (market, ICP, wedge) needs to be assessed first, route to `agentic-product-strategy`.
