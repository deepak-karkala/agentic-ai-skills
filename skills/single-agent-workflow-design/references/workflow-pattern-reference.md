# Workflow Pattern Reference

Reference for the `single-agent-workflow-design` skill. Contains full descriptions of the six canonical single-agent patterns, decision criteria, failure modes, and upgrade triggers.

---

## The Six Canonical Single-Agent Patterns

Ordered by predictability — highest predictability first, lowest last. The engineering discipline is choosing the simplest pattern that meets the task's requirements.

| Pattern | Type | Predictability | LLM control over execution | Primary cost driver |
|---|---|---|---|---|
| Prompt Chaining | Structured | Highest | None (steps are fixed) | LLM calls × steps |
| Routing | Structured | High | Classification only | Classifier + specialist cost |
| Parallelization | Structured | High | None (parallel execution) | Token cost × parallel branches |
| Evaluator-Optimizer | Dynamic | Medium | Bounded (N critique rounds) | LLM calls per round |
| Orchestrator-Workers | Dynamic | Low | High (planner decides at runtime) | Planner calls |
| Tool-Augmented Agent (ReAct) | Dynamic | None | Continuous | Full loop cost |

---

## Pattern 1: Prompt Chaining

**Structure:**
```
Input → [LLM₁] → Gate → [LLM₂] → Gate → [LLM₃] → Output
```

**When to use:**
- All steps are known before the workflow starts
- Each step produces output consumed by the next step
- Quality at intermediate steps can be validated programmatically
- Order of steps does not depend on runtime observations

**When NOT to use:**
- Steps depend on what earlier steps find — the step sequence changes based on intermediate results
- The task is simple enough to handle in a single call (over-chaining wastes latency and cost)

**Gate design:** Insert gates after every LLM step whose output is consumed by a subsequent step. A gate that always passes is not providing value — tighten the condition.

**Failure mode — Over-chaining:** A 5-step pipeline for a task that 2 steps could handle well. Every additional step adds latency, cost, and compounding error probability (see compounding error math: at 95% per-step accuracy, a 5-step chain succeeds ~77% of the time end-to-end).

**Failure mode — Gate bypassing:** A gate that halts but provides no feedback to the LLM. Retry after a gate failure must inject the failure reason into the prompt.

---

## Pattern 2: Routing

**Structure:**
```
Input → [Classifier] → Route A → [Specialist A] → Output
                     → Route B → [Specialist B] → Output
                     → Route C → [Specialist C] → Output
                     → Fallback → [Default Handler] → Output
```

**When to use:**
- Input space has distinct categories requiring different handling strategies
- A monolithic prompt is performing poorly because it handles too many input types
- Different categories have different cost, quality, or model requirements

**When NOT to use:**
- Categories are fuzzy and the classifier will frequently misroute
- There are fewer than 2–3 meaningful categories (use chaining instead)

**Classifier options (in order of preference):**
1. Rules-based keyword matching: zero cost, brittle for fuzzy cases
2. Embedding-based classifier: low cost, requires labeled examples
3. LLM classification with constrained output: flexible, handles ambiguous cases
4. Hybrid: rules-based for clear signals, LLM fallback for ambiguous

**Always define a fallback handler.** A request that doesn't match any category should route to a default handler — never to silence or an error.

**Failure mode — Silent misrouting:** A request classified to the wrong handler produces a plausible-sounding but wrong response. Unlike a gate failure (which is loud), routing errors are invisible without monitoring. Add confidence thresholds: if the classifier is below threshold, route to a safer handler or HITL.

---

## Pattern 3: Parallelization

**Structure — Sectioning:**
```
Input → [LLM section A] ↘
Input → [LLM section B] → Aggregator → Output
Input → [LLM section C] ↗
```

**Structure — Voting:**
```
Input → [LLM perspective 1] ↘
Input → [LLM perspective 2] → Aggregator (consensus/synthesis) → Output
Input → [LLM perspective 3] ↗
```

**When to use:**
- Sub-tasks are genuinely independent (no output of A is needed by B)
- Task volume exceeds single-context capacity (sectioning for long documents)
- Consistency or reliability improvement through voting justifies the cost

**When NOT to use:**
- Sub-tasks have dependencies — use chaining instead
- Latency budget cannot accommodate parallel fan-out overhead

**Aggregation design:** The aggregator is itself a design decision. Consensus (majority vote), synthesis (LLM merges results), or rule-based selection (pick the highest-confidence output) — each has different cost and quality tradeoffs.

**Failure mode — Independence violation:** Sub-tasks that look independent but actually share state (e.g., two workers writing to the same document) produce race conditions. Verify independence before parallelizing.

---

## Pattern 4: Evaluator-Optimizer

**Structure:**
```
Input → [Generator] → [Evaluator] → Feedback → [Generator (v2)] → ... → Output
```

**When to use:**
- Output quality has a subjective or complex dimension
- Quality criteria can be articulated as a prompt (not a deterministic check)
- Multiple iterations improve quality to a target level

**When NOT to use:**
- The quality criterion can be expressed as a deterministic check (schema validator, regex) — use a gate instead; it's cheaper and faster
- The improvement plateau is reached after 1–2 iterations (marginal benefit of extra rounds is low)

**Iteration budget:** Define MAX_ROUNDS before implementation. After the budget is exhausted, return the best output so far — do not run indefinitely.

**Evaluator design:** The evaluator LLM prompt should specify: what to evaluate, what "acceptable" looks like, and what structured feedback format to return. Unstructured evaluator feedback degrades generator improvement.

**Failure mode — Circular critique:** The evaluator and generator disagree perpetually — evaluator flags X, generator fixes X but breaks Y, evaluator flags Y, repeat. Add a convergence check: if the evaluator's critique is the same as the previous round's, increment a stall counter and break.

---

## Pattern 5: Orchestrator-Workers

**Structure:**
```
Input → [Orchestrator/Planner] → Sub-task 1 → [Worker 1] ↘
                               → Sub-task 2 → [Worker 2] → Synthesizer → Output
                               → Sub-task 3 → [Worker 3] ↗
```

**When to use:**
- The task is too complex for one LLM call but the sub-task decomposition is not known in advance
- Different sub-tasks benefit from specialized workers (different prompts, models, toolsets)
- Workers can run in parallel after the planner generates the decomposition

**When NOT to use:**
- The sub-task decomposition is known in advance — use chaining or parallelization (cheaper, more predictable)
- Workers are not meaningfully different — over-engineering

**Planner design:** The planner output must be structured enough for the orchestration layer to parse: a list of tasks with assigned workers, required inputs, and expected output formats. Free-form planner text creates parsing failures.

**Re-planning gate:** Add a re-planning gate between phases for long tasks. If major tool outputs change the picture significantly, re-run the planner on the updated state rather than continuing the original plan.

**Failure mode — Plan drift:** The planner generates steps that make sense at generation time but become contextually inappropriate as tool outputs evolve. Early steps inform later steps; later steps may need to be replanned based on what the earlier steps discovered.

---

## Pattern 6: Tool-Augmented Agent (ReAct Loop)

**Structure:**
```
Input → Thought → Action (tool call) → Observation → Thought → ... → Final Answer
```

**When to use:**
- The task is genuinely open-ended: the steps cannot be enumerated in advance
- Mid-task adaptation to tool results is required
- Recovery from unexpected tool outputs is needed
- Trust in the model's tool selection has been validated through testing

**When NOT to use:**
- Any of patterns 1–5 can handle the task — the ReAct loop is the most expensive and least predictable pattern
- Latency constraints cannot accommodate multi-step round-trips
- Tool selection accuracy has not been validated (test with the actual tool set before committing)

**Required safeguards (non-negotiable):**
- `MAX_STEPS`: Hard step limit. Recommended: 10–25 depending on task complexity. Log terminal state on every exit.
- `COST_BUDGET`: Hard per-session cost cap. Must live outside the agent code (in the tool gateway or orchestration layer — never evaluated by the agent itself).
- Loop detection: If the agent takes the same action on the same input 3 consecutive times, trigger termination.

**Upgrade trigger from simpler patterns:** Use the ReAct loop only when:
- [ ] All simpler patterns have been ruled out with a documented reason
- [ ] Tool selection accuracy has been validated with > 85% correct tool choice on a representative sample
- [ ] MAX_STEPS and COST_BUDGET are defined and enforced

---

## Upgrade Triggers: When to Escalate to Multi-Agent

A single-agent workflow should be upgraded to a multi-agent architecture when:

1. **Prompt complexity is unmanageable:** The system prompt contains deeply nested conditionals for different task categories. Different categories require contradictory personas or tool configurations.

2. **Tool overload with overlap:** More than 10–15 tools; multiple tools are similar; the model consistently selects the wrong tool despite disambiguation. Partition tools across specialist agents.

3. **Context overflow on multi-phase tasks:** A single agent's context cannot hold the accumulation of tool outputs, history, and knowledge required for the full task. Use hierarchical orchestration.

4. **Independent parallelizable sub-tasks:** Tasks that are both independent and would benefit from concurrent execution beyond what simple parallelization can handle.

**At the upgrade decision point:** Route to `multi-agent-orchestration` rather than continuing in `single-agent-workflow-design`.

---

## Retry Budget Reference

| Failure type | Max retries | Recovery strategy | On exhaustion |
|---|---|---|---|
| LLM output malformed | 2 | Inject schema + error message into retry prompt | Escalate to human |
| Tool call: bad parameters | 2 | Inject tool error + correction hint | Escalate to human |
| Tool call: rate limited | 3 | Exponential backoff (1s, 2s, 4s) | Escalate or suspend |
| Tool call: external unavailable | 1 | Wait 30s, retry once | Suspend with state snapshot |
| Gate failure: schema | 2 | Inject schema + error into prompt | Escalate to human |
| Gate failure: quality | 2 | Inject critique feedback | Escalate to human |
| Destructive tool failure | 0 | No retry — escalate immediately | Human review only |
| Loop detected | 0 | No retry — terminate with diagnostic | Human review only |
