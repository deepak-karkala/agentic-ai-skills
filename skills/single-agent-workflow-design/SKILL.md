---
name: single-agent-workflow-design
description: >
  Designs the control flow and state transitions for a single-agent workflow.
  Selects among the six canonical single-agent patterns (prompt chaining,
  routing, parallelization, evaluator-optimizer, orchestrator-workers,
  ReAct loop), designs the step sequence, gate logic, retry and recovery
  strategy, and termination conditions. Use when a single-agent architecture
  has been chosen and the workflow needs to be composed in detail, when the
  control loop structure is unclear, when a workflow needs retry or fallback
  steps designed, or when upgrading from a simple prompt to a structured
  single-agent workflow.
  Trigger phrases: "design the control loop for this single-agent workflow",
  "how should retries and fallback steps be structured", "which single-agent
  pattern fits this workflow", "design the step sequence for this agent",
  "should I use prompt chaining or a ReAct loop for this", "how do I handle
  partial failures in this agent workflow", "structure the state transitions
  for this workflow", "design the workflow for this single-agent system".
  Do not use for multi-agent topology and handoff design (use
  multi-agent-orchestration), for high-level agent architecture decisions
  like single-agent vs multi-agent (use agentic-system-design), for tool
  contract design (use tool-interface-design), or for generating a runnable
  scaffold (use agentic-prototype).
allowed-tools:
  - Read
  - Write
metadata:
  category: technical
  version: "0.1.0"
---

# Single-Agent Workflow Design

Control flow design skill. Designs the step sequence, pattern selection, gate logic, retry strategy, and termination conditions for a single-agent workflow. Produces a structured workflow diagram or table that bridges the gap between high-level architecture and implementation.

## When to Use

**Use when:**
- A single-agent decision has been made and the workflow control flow needs to be designed in detail
- The right single-agent pattern (chaining vs. routing vs. ReAct loop) is unclear
- A workflow needs explicit retry, fallback, and recovery steps
- State transitions need to be mapped (what happens after each step, including failures)
- Upgrading from a monolithic prompt to a structured workflow

**Do not use when:**
- The question is whether to use a single agent or multiple agents → use `agentic-system-design`
- The question is about multi-agent coordination, handoffs, or topology → use `multi-agent-orchestration`
- The question is about tool contract schemas → use `tool-interface-design`
- The question is about generating runnable scaffold code → use `agentic-prototype`

## Workflow

### Step 1 — Gather context

Ask the user:
1. What does the workflow do? (Input → process → output)
2. Are all the steps known before the workflow starts, or do steps depend on runtime observations?
3. What happens if a step fails? (Retry, fallback to human, abandon, partial result?)
4. What tools does the agent use?
5. Is there a latency or cost constraint?

Use the answers to select the correct single-agent pattern in Step 2.

---

### Step 2 — Select the single-agent pattern

Apply the decision tree to select the appropriate pattern. **Default to the highest-predictability pattern that can meet the task requirements.** Upgrade only when the simpler pattern demonstrably cannot.

```
Are all steps known before the workflow starts?
  Yes → Structured workflow family
    Is the step sequence linear?
      Yes → Are sub-tasks independent and parallelizable?
        Yes → Parallelization
        No → Prompt Chaining
      No → Does input fall into distinct categories?
        Yes → Routing
        No → Prompt Chaining with branching gates
  No → Dynamic pattern family
    Does the task require iterative self-improvement on output quality?
      Yes → Evaluator-Optimizer
    Does the task require dynamic sub-task decomposition?
      Yes → Orchestrator-Workers
    Does the task require open-ended tool use with mid-task adaptation?
      Yes → Tool-Augmented Agent (ReAct Loop)
```

See [Workflow Pattern Reference](references/workflow-pattern-reference.md) for full pattern descriptions, when-to-use criteria, and failure modes.

---

### Step 3 — Design the step sequence

Map every step in the workflow:

| Step | Type | LLM call? | Tool call? | Gate condition | On fail |
|---|---|---|---|---|---|
| Step 1 | [input / processing / output] | yes/no | yes/no | [validation rule] | [retry / escalate / abort] |
| ... | | | | | |

**Step types:**
- **Input**: Receive and validate input; structure context for the first LLM call
- **Processing**: LLM call, tool call, or both
- **Gate**: Validate intermediate output before proceeding; if gate fails, route to recovery
- **Decision**: Branch logic based on a classification or threshold
- **Output**: Format and return the final result

**Design principles:**
- Add a gate after every LLM step whose output is consumed by a subsequent step — fail fast rather than propagating flawed intermediates
- Keep each processing step to one clear task — avoid steps that do "classify AND extract AND format"
- Name each step with an active verb: "Extract entities", "Validate schema", "Generate draft"

---

### Step 4 — Design gates and validation logic

For each gate in the workflow, specify:

| Gate | Validates | Method | On fail |
|---|---|---|---|
| Schema gate | Output is valid JSON / matches expected structure | Schema validator | Retry Step N with correction prompt |
| Content gate | Output meets quality or completeness criteria | LLM-as-judge or regex | Retry with feedback / escalate |
| Safety gate | Output does not violate guardrails | Rules check or guardian model | Escalate to human |
| Confidence gate | Model confidence is above threshold | Logprob or self-assessment prompt | Route to slower/stronger model |

**Gate implementation guidance:**
- Prefer deterministic gates (schema validator, regex, rule check) over LLM-as-judge where possible — they are cheaper, faster, and more reliable
- Use LLM-as-judge gates only for quality dimensions that cannot be expressed as deterministic rules
- A gate that always passes is not a gate — review and tighten the condition

---

### Step 5 — Design retry and recovery strategy

For each failure mode, define the recovery path:

| Failure | First recovery | Second recovery | Escalation |
|---|---|---|---|
| LLM output malformed | Retry with correction prompt (inject error + schema) | Retry with simplified instruction | Human review |
| Tool call failed | Check error type → retry with corrected parameters | Retry with alternative tool | Human review |
| Gate failed (schema) | Retry with schema + error description in prompt | Simplified input or reduced scope | Human review |
| Gate failed (quality) | Retry with critique feedback | Retry with different model/temperature | Human review |
| Step limit exceeded | Return partial result with flag | — | Human review |
| Cost budget exceeded | Suspend workflow, return state snapshot | — | Human review |

**Retry budget guidance:**
- Maximum 2–3 retries per step before escalating to human review
- Use exponential backoff for rate-limited tool errors
- Never retry a destructive tool call on failure — escalate immediately
- After the second consecutive gate failure, escalate; do not retry indefinitely

---

### Step 6 — Design termination conditions

Every agent workflow must have well-defined termination conditions. The ReAct loop pattern is especially prone to missing this.

**Explicit termination conditions:**
1. **Success termination**: The final output has been produced and validated. The workflow exits with the result.
2. **Step limit termination**: MAX_STEPS has been reached. Return the partial result with a flag and log the terminal state.
3. **Cost limit termination**: COST_BUDGET has been exceeded. Suspend the workflow, return a state snapshot for potential resumption.
4. **Failure escalation termination**: The recovery strategy has been exhausted. Escalate to human with a diagnostic payload (last step, last error, current state).
5. **Explicit abort**: The agent determined that the task cannot be completed with the available information or tools. Return with a clear explanation.

**For ReAct loops specifically:**
- Define MAX_STEPS before implementation (recommended: 10–25 depending on task complexity)
- Define COST_BUDGET before implementation
- Add loop detection: if the agent takes the same action on the same input 3 times, trigger termination

---

### Step 7 — Write the workflow design document

Write a workflow design document to:
- `design_docs_path/workflow-<agent-name>.md` if `design_docs_path` is configured in `.agentic/config.yml`
- Otherwise: `.agentic/artifacts/workflow-<agent-name>.md`

Use the format:

```markdown
# Workflow Design: <Agent Name>

## Pattern Selected
[Pattern name and one-sentence rationale]
[Why simpler patterns were ruled out, if applicable]

## Step Sequence
[Step table from Step 3]

## Gate Logic
[Gate table from Step 4]

## Retry and Recovery Strategy
[Failure/recovery table from Step 5]

## Termination Conditions
[Explicit list of all termination conditions with actions]

## State Transitions (optional — for stateful workflows)
[State diagram or table if the workflow is stateful across sessions]

## Open Design Questions
[Any unresolved decisions the implementation team needs to make]
```

---

### Step 8 — Report

After writing the document:
1. State the file path.
2. State the pattern selected and the primary rationale.
3. Flag any steps with no gate after an LLM call — these are unvalidated failure points.
4. Flag any failure modes with no defined recovery path.
5. Suggest next steps: `tool-interface-design` to design the tool contracts this workflow depends on, or `agentic-prototype` to generate a runnable scaffold for the pattern.

## Output Contract

- **Primary output:** Workflow design document at `design_docs_path/workflow-<agent-name>.md` or `.agentic/artifacts/workflow-<agent-name>.md`
- **In-conversation summary:** pattern selected, step count, unvalidated failure points, next steps
- **Does not produce:** multi-agent topology, tool contracts, code implementation, eval plans

## Scope Boundaries

This skill designs single-agent control flow. It does not decide whether to use a single agent (route to `agentic-system-design`), design multi-agent topologies (route to `multi-agent-orchestration`), write tool contracts (route to `tool-interface-design`), or generate runnable code (route to `agentic-prototype`). If the workflow design reveals a case that a single agent cannot handle (too many distinct domains, context overflow across phases), note it and suggest routing to `multi-agent-orchestration`.
