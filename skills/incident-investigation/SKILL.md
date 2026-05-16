---
name: incident-investigation
description: >
  Investigates a known failure in a production or staging agentic AI
  system. Reconstructs the failure timeline from available evidence,
  identifies the contributing fault layer (eval gap, observability gap,
  architecture flaw, prompt failure, context failure, tool failure, or
  policy gap), determines immediate containment steps, and maps the
  incident to a durable fix. Backward-looking only — begins from a
  known bad outcome and works toward root cause. Not a debugging or
  monitoring design skill.
  Use when an agent has caused a bad action in production, when a staging
  test has surfaced unexpected behavior that must be understood before
  launch, when a user report describes consistent agent misbehavior,
  when a circuit breaker or cost alert has triggered and the root cause
  is unknown, or when an incident needs a structured post-mortem.
  Trigger phrases: "this agent failed in production", "investigate this
  incident", "what went wrong with this agent", "how did this slip through",
  "the agent took a bad action", "staging looked fine but prod failed",
  "write a post-mortem for this agent failure", "root cause analysis for
  this agent misbehavior", "what layer caused this failure",
  "help me reconstruct what happened".
  Do not use for forward-looking observability design (use agent-observability),
  for reading a specific trace to diagnose a failure (use trace-error-analysis
  as a supporting tool), for eval suite design to prevent future failures
  (use agent-eval-design), or for general debugging of code or infrastructure
  issues that are not agent-behavior failures.
allowed-tools:
  - Read
  - Write
metadata:
  category: technical
  version: "0.1.0"
---

# Incident Investigation

Post-failure investigation skill. Reconstructs failure timelines from available evidence, identifies the contributing fault layer, and maps incidents to durable fixes. Produces a structured incident report.

## When to Use

**Use when:**
- An agent caused an incorrect or harmful action in production
- A known bad output or failure needs to be reconstructed and explained
- A circuit breaker, cost alert, or SLA breach triggered and the root cause is unclear
- An incident needs a structured post-mortem with durable fix recommendations
- Staging/production divergence needs to be explained

**Do not use when:**
- The goal is to design observability infrastructure for future monitoring → use `agent-observability`
- The goal is to read a specific trace to identify the failure span → use `trace-error-analysis` (which this skill invokes as a supporting technique)
- The goal is to design eval tests to prevent this failure recurring → use `agent-eval-design` (this skill recommends it as the durable fix target)
- The issue is a code bug, infrastructure failure, or network problem — not agent behavior

## Workflow

### Step 1 — Gather incident evidence

Ask the user for everything available about the failure:
1. What was the bad outcome? (Wrong action taken, harmful output produced, silent failure, incorrect routing, cost explosion, etc.)
2. When did it occur? Timestamp range.
3. What evidence is available? (Trace logs, LLM call logs, tool call logs, monitoring alerts, user reports, cost billing data)
4. Was this a one-time event or a pattern? If a pattern, how many occurrences and over what period?
5. What changed before the first occurrence? (Model update, prompt change, tool change, traffic increase, new user inputs?)
6. Did any alerts fire? If so, which ones? If not, why not?

If trace evidence is available, use `trace-error-analysis` techniques to read the trace from root span to the failure span. If no trace data exists, the investigation must proceed from whatever evidence is available — and the absence of traces is itself a finding.

---

### Step 2 — Reconstruct the failure timeline

Build a timeline of what happened, in order. Even partial timelines are useful — gaps in the timeline are findings.

**Timeline format:**

```
T+0:00  [Input received] — user submitted ticket with content: [summary]
T+0:02  [LLM call] — orchestrator called model; routing decision: [category, confidence]
T+0:04  [Tool call] — [tool name] called with [args summary]
T+0:05  [Tool result] — [result summary]
T+0:06  [LLM call] — [action taken]
T+0:07  [Bad action] — [what went wrong]
--- gap: what happened between T+0:06 and T+0:07 is unclear ---
```

Note every gap in the timeline. Gaps point to missing instrumentation — a secondary finding.

---

### Step 3 — Identify the fault layer

Agent failures cluster into six fault layers. Identify the primary contributing layer — and note if multiple layers contributed.

**Six fault layers:**

**Layer 1 — Prompt failure:**
The system prompt, task instruction, or few-shot examples led the model to the wrong behavior. The model executed correctly given what it was told — the problem was what it was told.
- Evidence: the model's output was consistent with its instructions; the instructions were wrong
- Durable fix target: update the prompt; add the failure case as a golden test

**Layer 2 — Context failure:**
The agent had incorrect, incomplete, or corrupt context at decision time. The model reasoned correctly over the wrong inputs.
- Evidence: retrieved document was wrong or irrelevant; context was truncated; memory tier returned stale data; injected content came from an untrusted source (indirect injection)
- Durable fix target: fix the retrieval layer; add context validation; update eval fixtures for this retrieval pattern

**Layer 3 — Tool failure:**
A tool returned incorrect results, failed silently, or was called with wrong arguments due to a schema mismatch.
- Evidence: tool call spans show error or unexpected result; downstream behavior changed after a tool schema update; tool result does not match expected format
- Durable fix target: fix the tool implementation or schema; add tool-level integration tests

**Layer 4 — Orchestration failure:**
The workflow sequencing, handoff logic, or multi-agent coordination failed. The right individual steps happened in the wrong order or with the wrong context passed between steps.
- Evidence: worker agent received incomplete or incorrect context from orchestrator; loop detected in tool call sequence; context state was lost at agent boundary; race condition in parallel tool calls
- Durable fix target: redesign the handoff contract; add context validation at agent boundaries

**Layer 5 — Eval gap:**
The failure mode was not covered by the eval suite. The system behaved as designed — the design was wrong and the eval suite did not catch it.
- Evidence: all eval tests pass; the failing input would not be covered by any existing golden case; the failure is in a category with few or no eval fixtures
- Durable fix target: add the failing case to the eval golden dataset; expand eval coverage for the gap category

**Layer 6 — Policy gap:**
The agent behaved correctly within its designed constraints, but the constraints did not address this scenario. The failure is in governance, permission, or deployment policy — not in the agent's execution.
- Evidence: the agent did exactly what its permission tier allows; no guardrail or HITL gate covered the scenario; the policy did not anticipate this input category
- Durable fix target: update HITL gates, tool permission tiers, or guardrail rules; document the policy change

---

### Step 4 — Determine immediate containment steps

Before working on the durable fix, determine what must be done immediately to prevent recurrence or limit current impact:

| Situation | Immediate action |
|---|---|
| Harmful outputs still possible | Disable the agent or restrict to supervised mode immediately |
| A specific tool is causing harm | Disable or scope-restrict the tool at the gateway layer |
| Indirect injection is the vector | Filter the input source; add injection detection before next session |
| Cost runaway in progress | Trip the cost circuit breaker; impose per-session budget limit |
| Pattern of failures over multiple sessions | Roll back to last known good configuration; analyze delta |
| One-time failure, root cause understood | No immediate rollback needed; document and add to eval |

Containment must happen before the durable fix. Do not leave the system in a state where the same failure can recur while the fix is being developed.

---

### Step 5 — Map to durable fix

Each fault layer maps to a specific fix target. The durable fix prevents the same failure class from recurring — it does not just patch the specific instance.

| Fault layer | Primary fix target | Secondary fix target |
|---|---|---|
| Prompt failure | Update prompt; add golden test | `agent-eval-design` to expand coverage of this prompt behavior |
| Context failure | Fix retrieval layer; validate context assembly | `agent-observability` to instrument context state at decision points |
| Tool failure | Fix tool implementation or schema | `tool-interface-design` to review the tool contract |
| Orchestration failure | Redesign handoff contract; add boundary validation | `agentic-system-design` if the topology needs restructuring |
| Eval gap | Add failing case to golden dataset | `agent-eval-design` to expand the dimension with the gap |
| Policy gap | Update HITL gates / permission tiers / guardrails | `deployment-readiness` to incorporate the policy change into the launch gate |

---

### Step 6 — Write the incident report

Write a structured incident report to:
- `artifact_output_path/incident-<agent-name>-<date>.md` if `artifact_output_path` is configured in `.agentic/config.yml`
- Otherwise: `.agentic/artifacts/incident-<agent-name>-<date>.md`

Format:

```markdown
# Incident Report: <Agent Name> — <Date>

## Summary
[One sentence: what failed, when, severity]

## Timeline
[Reconstructed timeline with evidence sources and gaps noted]

## Contributing Fault Layer
[Primary layer(s) identified; evidence for each]

## Immediate Containment
[Actions taken or recommended; current exposure status]

## Root Cause
[Root cause statement: what condition made this failure possible?]

## Durable Fix
[Fix target skill, specific change required, estimated effort]

## Eval Gap
[Was this covered by the eval suite? What case must be added?]

## Observability Gap
[Was this discoverable from current traces? What instrumentation was missing?]

## Next Steps
[Ordered list: containment → fix → eval update → monitoring update]
```

---

### Step 7 — Report

After writing the incident report:
1. State the file path.
2. State the identified fault layer (primary and secondary if applicable).
3. State the containment status (contained / still exposed).
4. State the durable fix target.
5. Explicitly state whether the eval suite would have caught this. If not, name the eval gap.
6. Explicitly state whether the observability was sufficient to diagnose this without extensive investigation. If not, name the instrumentation gap.

## Output Contract

- **Primary output:** Incident report at `artifact_output_path/incident-<agent-name>-<date>.md` or `.agentic/artifacts/incident-<agent-name>-<date>.md`
- **In-conversation summary:** fault layer, containment status, durable fix target, eval gap, observability gap
- **Does not produce:** forward-looking observability plans, eval suite design, deployment gate checklists

## Scope Boundaries

This skill is backward-looking — it starts from a known failure and reconstructs toward root cause. It does not design monitoring systems (use `agent-observability`), design eval suites (use `agent-eval-design`), or implement fixes (use the appropriate target skill). `trace-error-analysis` is the supporting technique used within this skill when trace data is available — this skill owns the full incident investigation workflow, not just trace reading. The durable fix always routes to another skill: the investigation ends at identifying the fix target, not at implementing it.
