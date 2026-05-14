---
name: agentic-system-design
description: >
  Designs the architecture of an agentic AI system from first principles.
  Covers use-case qualification, agent tier selection, single-agent pattern
  selection, reasoning paradigm, autonomy boundaries, and memory design.
  Use when starting a new agentic AI project, choosing between agent
  architectures, deciding on autonomy level, selecting an orchestration
  pattern, or reviewing whether an existing design fits the problem.
  Trigger phrases: "how should I architect this agent", "should I use an
  agent or a simpler pipeline", "which orchestration pattern should I use",
  "what autonomy level is right for this", "design an agent system for X",
  "review my agent architecture". Do not use for multi-agent topology
  decisions (use multi-agent-orchestration) or production readiness gates
  (use deployment-readiness).
allowed-tools:
  - Read
  - Write
metadata:
  category: architecture
  version: "0.1.0"
---

# Agentic System Design

Architecture decision skill for agentic AI systems. Starts from use-case qualification and ends with a concrete architecture recommendation covering tier, pattern, reasoning paradigm, autonomy level, and memory design.

## When to Use

**Use when:**
- Starting a new agentic system and need to choose architecture
- Deciding whether a workflow needs an agent or a simpler pipeline
- Choosing between single-agent patterns (chaining, routing, orchestrator-workers, ReAct)
- Defining the autonomy level and human approval boundaries
- Reviewing whether an existing agent architecture fits the problem

**Do not use when:**
- Multi-agent topology, handoff contracts, or coordination patterns → use `multi-agent-orchestration`
- Production guardrails, rollout posture, or deployment gates → use `deployment-readiness`
- Context window budgets or memory tier design for an existing agent → use `context-engineering-for-agents`
- Eval strategy → use `agent-eval-design`

## Workflow

### Step 1 — Gather inputs

Ask the user:
1. What task or workflow does the agent need to handle?
2. How variable is the input? Can steps be pre-specified, or are they discovered at runtime?
3. What actions can the agent take, and are they reversible?
4. Is there a success criterion that can be measured programmatically?
5. What are the latency and cost constraints?
6. What existing infrastructure, APIs, or tools are available?

If design docs or ADRs are configured in `.agentic/config.yml`, read them before proceeding.

---

### Step 2 — Use-case qualification

Run the **Process-Fit Framework** (7 traits). Score 1 point for each:

| Trait | Question |
|---|---|
| High frequency | Does this workflow occur daily or weekly (not quarterly)? |
| Multi-system | Does it require jumping between multiple tools or data sources? |
| SOPs or policies exist | Are there clear rules or policies that constrain agent decisions? |
| Measurable success | Can task completion be verified programmatically or by clear criteria? |
| Mixed task type | Does it combine structured lookup with judgment calls? |
| Recoverable errors | Are most mistakes correctable without serious consequences? |
| Clean accessible data | Is relevant data connected, accessible, and reasonably fresh? |

**Scoring:**
- 5–7: Strong agent candidate
- 3–4: Possible with preparation (fix data access or add guardrails)
- 0–2: Start elsewhere — use RPA, a simpler pipeline, or fix the underlying process first

**Hard disqualifiers (stop regardless of score):**
- No measurable success criterion exists → cannot evaluate or improve
- Actions are irreversible AND high-stakes → human accountability required
- Workflow is broken → agentic AI will magnify the dysfunction
- Data is siloed or unreliable → fix data architecture first

---

### Step 3 — Choose the agent tier

Apply the **Agent Spectrum**:

| Tier | Who controls flow | Right for | Wrong for |
|---|---|---|---|
| **Tier 1: Augmented LLM** | Code | Single-call tasks (Q&A, summarization, classification, RAG) | Multi-step execution, edge-case handling |
| **Tier 2: Deterministic Workflow** | Code with LLM as component | Known decision branches, compliance pipelines, predictable step sequences | Adaptive replanning, open-ended input |
| **Tier 3: True Agent** | LLM orchestrator | Open-ended goals, unstructured input, adaptive workflows | Deterministic ETL, schema-validated input |

**Apply the 3-Condition Test** — recommend Tier 3 only if at least 2 of 3 conditions hold:
1. Cannot write a decision tree covering 95% of cases without ongoing maintenance
2. Conditional logic takes more than a few days per quarter to maintain
3. Input cannot reliably be parsed to a schema before reasoning

**Start at the lowest viable tier.** Prove the simpler tier is insufficient (with test cases) before advancing.

---

### Step 4 — Select the single-agent pattern

If Tier 2 or 3 is warranted, select the pattern from the **six canonical single-agent patterns** (ordered by complexity):

| Pattern | When to use | Key guard |
|---|---|---|
| **Prompt Chaining** | Steps are fixed and known before runtime; intermediate quality can be validated | Do not over-chain simple tasks |
| **Routing** | Input space has distinct categories that different prompts/models serve better | Add fallback handler; use confidence threshold |
| **Parallelization** | Sub-tasks are genuinely independent (no data dependency between them) | Verify independence — hidden dependencies produce inconsistent outputs |
| **Evaluator-Optimizer** | Output quality is hard to encode deterministically; iterative refinement demonstrably helps | Always set MAX_ROUNDS (3–5); use PASS/REVISE signal |
| **Orchestrator-Workers** | Specific steps are unknowable before seeing input; open-ended scope | Detect plan drift; re-validate plan if context changes significantly |
| **Tool-Augmented Agent (ReAct)** | Task is genuinely open-ended; mid-task adaptation is required | Always enforce MAX_STEPS (10–20) and COST_BUDGET |

**Pattern composition is common.** State the composition clearly (e.g., Routing → Chaining, Parallelization → Evaluator-Optimizer).

**Upgrade triggers to multi-agent** (do not add multi-agent before these):
- Prompt complexity is unmanageable (deeply nested conditionals)
- Tool overload: more than 10–15 tools with overlapping names
- Context window exhaustion from accumulated tool outputs
- Workstreams are fully independent and parallel with no runtime dependencies

---

### Step 5 — Select the reasoning paradigm

| Paradigm | When | Cost | Weakness |
|---|---|---|---|
| **Chain-of-Thought (CoT)** | Single-prompt reasoning, all context available | Low (1 call) | Error propagation without observation |
| **ReAct** | Adaptive tasks requiring mid-task tool feedback — **default starting choice** | High (linear in steps) | Runaway loops without MAX_STEPS |
| **ReWOO** | Predictable steps, latency or cost binding, parallel tool calls | Medium (50–70% lower latency vs ReAct on fitting tasks) | Less adaptive to unexpected tool output |
| **Plan-and-Execute** | Auditable workflows, regulated contexts, inspectable plan required | Medium-High | More upfront design |
| **Tree-of-Thoughts** | Strategic exploration with backtracking required | Very High | Use only when backtracking genuinely needed |

**Default decision rule:** Start with ReAct. Upgrade to Plan-and-Execute when transparency or auditability is required. Use ReWOO when task structure is predictable and latency/cost are binding constraints. Add ToT only when strategic backtracking is genuinely needed.

For any ReAct or looping pattern, always set a hard `MAX_STEPS` cap (10–20 steps typical). This is the single most common production fix.

---

### Step 6 — Define autonomy level

Rate the workflow on **five autonomy factors**:

| Factor | Low autonomy → | High autonomy |
|---|---|---|
| Error cost | High or irreversible | Low and recoverable |
| Domain boundedness | Open-ended | Well-defined rules |
| Agent reliability | Unproven | 90%+ completion rate, 90+ days production |
| Regulatory environment | Finance, healthcare, legal | Internal only |
| Action type | Write / commit to external systems | Read / analyze / recommend |

**Progressive autonomy model** — always start lower:
1. Read-only / recommend only (highest success, lowest risk)
2. Recommend + bounded reversible action
3. Write to internal systems with approval gates
4. Broader write access after 90%+ reliability demonstrated

No production case has started at full autonomy and worked backward. Direction is always supervised → partial → autonomous.

**Warn explicitly** if the user proposes write-to-external-system autonomy without demonstrated reliability in supervised mode.

---

### Step 7 — Define memory and context design

Assign each data type to the appropriate memory tier:

| Tier | What belongs here | Infrastructure |
|---|---|---|
| **Working** | Current task, turn, plan, immediate tool outputs | Prompt / agent state (compact aggressively) |
| **Episodic** | Prior interactions, user history, past decisions | Durable database (privacy, retention policies) |
| **Semantic** | Policies, docs, procedures, domain knowledge | RAG / vector index (freshness, citation required) |
| **Procedural** | Workflows, tool usage patterns, escalation logic | Prompt libraries (version-controlled, tested) |

**Context engineering rule:** Use memory to find evidence. Use authoritative systems to decide action.

---

### Step 8 — Produce the architecture output

Produce a structured architecture plan with these sections:

1. **Qualification verdict** — score from Process-Fit Framework; disqualifiers if any
2. **Agent tier** — Tier 1/2/3 with rationale
3. **Pattern** — selected pattern(s) with composition if applicable
4. **Reasoning paradigm** — selected paradigm with rationale
5. **Autonomy level** — tier and progression path
6. **Memory design** — tier assignments for the key data types
7. **Key risks** — top 3 risks with mitigations
8. **Open questions** — design decisions that require more information

If the request came via `/agentic-ai-engineering:agentic-arch-review` or the design has enough structure (topology + tools + decisions + risks), generate the `architecture-review.html` artifact using `templates/html/architecture-review.html`.

## Output Format

For conversational design: structured Markdown sections per Step 8.

For architecture review command: fill and write `templates/html/architecture-review.html` to `artifact_output_path`, then provide a Markdown summary and the file path.

## Scope Boundaries

This skill does not:
- Design multi-agent topologies, handoff contracts, or coordination patterns → `multi-agent-orchestration`
- Design production guardrails, HITL gates, or rollout posture → `deployment-readiness`
- Design context compression strategies or memory infrastructure → `context-engineering-for-agents`
- Design eval scorecards or graders → `agent-eval-design`
- Make final tool implementation choices — it defines tool boundaries; implementation is up to the engineer
