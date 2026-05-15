# Standard Agentic Vocabulary

Canonical definitions for common agentic AI terms. Used by `agentic-ubiquitous-language` to normalize team vocabulary against standard usage.

Each entry includes the canonical definition, common overloads (divergent uses found in practice), and a disambiguation note.

---

## Core Concepts

### Agent
**Canonical:** An LLM-driven system that perceives inputs, reasons over them, and takes actions that affect an environment — potentially across multiple steps, with tool use and memory.
**Common overloads:**
- "Agent" used as synonym for "chatbot" (no tool use, no multi-step reasoning) — not an agent by this definition
- "Agent" used for any automated background process — too broad
**Disambiguation:** An agent acts on an environment. A chatbot responds. A pipeline processes.

### Tool
**Canonical:** A discrete, typed function an agent can call to interact with external systems — files, APIs, databases, code execution.
**Common overloads:**
- "Tool" used for internal helper functions that don't cross a system boundary — those are functions, not tools
- "Tool" used interchangeably with "skill" or "capability"
**Disambiguation:** A tool has a name, description, parameter schema, and an external effect or read. It is the agent's interface to the world.

### Memory
**Canonical:** Persistent information available to an agent across steps or sessions. Four tiers: in-context (working memory), external (retrieval store), episodic (past session traces), semantic (world knowledge / embeddings).
**Common overloads:**
- "Memory" used only for in-context state (misses external/episodic/semantic tiers)
- "Memory" confused with "context window" (context window is the container; memory is what lives in it or alongside it)
**Disambiguation:** Memory is where information is stored between reasoning steps or sessions. Context is what's assembled and passed to the model for a single inference call.

### Context
**Canonical:** The assembled input to a single model inference call — system prompt, conversation history, tool results, retrieved content. Managed through the write/select/compress/isolate disciplines.
**Common overloads:**
- "Context" used as synonym for "memory" (conflates assembly with storage)
- "Context" used loosely as "background information"
**Disambiguation:** Context is perishable (lost when the inference call ends). Memory is persistent.

### Orchestrator
**Canonical:** The component that directs the agent's control loop — deciding which tool to call next, whether to continue or stop, and how to handle failures.
**Common overloads:**
- "Orchestrator" used for multi-agent coordinator (valid extension, but clarify scope)
- "Orchestrator" used for any LLM that has tools (not all tool-using LLMs are orchestrators)
**Disambiguation:** An orchestrator controls flow. A worker executes a bounded task. An agent can be both.

### Planner
**Canonical:** A component or reasoning mode that produces a multi-step plan before execution — usually separate from the executor that carries out each step.
**Common overloads:**
- "Planner" used interchangeably with "orchestrator" (planners generate plans; orchestrators direct execution)
- "Planner" used for any agent that uses chain-of-thought
**Disambiguation:** Planning is a reasoning mode. Orchestration is an execution mode. An agent may do both in the same loop.

### Worker
**Canonical:** A specialized sub-process or subagent that executes a bounded, well-defined task assigned by an orchestrator.
**Common overloads:**
- "Worker" used for any background process
- "Worker" conflated with "tool" (workers reason and have context; tools are stateless function calls)
**Disambiguation:** A tool is a function call. A worker is a reasoning entity with its own context.

---

## Multi-Agent Terms

### Handoff
**Canonical:** A structured transfer of state, task, and context from one agent to another — including the information the receiving agent needs to continue without re-doing the sender's work.
**Common overloads:**
- "Handoff" used loosely for any message between agents (not all messages are handoffs — a handoff transfers ownership)
- "Handoff" conflated with "tool call" between agents
**Disambiguation:** A handoff transfers task ownership. A message shares information. A tool call requests a capability.

### Session
**Canonical:** A bounded unit of agent interaction — beginning when a user task is accepted, ending when a result is returned or the task is abandoned. Sessions define the scope of in-context memory.
**Common overloads:**
- "Session" used interchangeably with "conversation" (sessions can span multiple conversation turns)
- "Session" used for background job runs (valid extension if scope is bounded)

### Trace
**Canonical:** A structured record of an agent's execution — the sequence of reasoning steps, tool calls, inputs, outputs, and latencies for a single session or task.
**Common overloads:**
- "Trace" used for any log line
- "Trace" conflated with "log" (logs record events; traces record causal chains of agent execution)
**Disambiguation:** A trace reconstructs what the agent did and why, step by step. A log records that something happened.

---

## Evaluation Terms

### Trajectory
**Canonical:** The sequence of steps an agent took to reach an outcome — tool calls, reasoning steps, intermediate states — as distinct from the outcome itself.
**Common overloads:**
- "Trajectory" used only for the final output (that is the outcome, not the trajectory)
- "Trajectory" conflated with "trace" (traces are raw records; trajectories are the meaningful path through them)

### Grader
**Canonical:** The component that assigns a score or verdict to an agent output — may be an LLM (LLM-as-judge), a deterministic function, or a human reviewer.
**Common overloads:**
- "Grader" used interchangeably with "evaluator" (the evaluator is the full eval pipeline; the grader is a single scoring component within it)

---

## Confusion Pairs

| Pair | How to distinguish |
|---|---|
| Agent vs pipeline | Agents discover steps at runtime. Pipelines execute pre-specified steps. |
| Memory vs context | Memory persists. Context is assembled per inference call. |
| Orchestrator vs planner | Orchestrators direct execution. Planners generate plans before execution. |
| Worker vs tool | Workers reason and have context. Tools are stateless function calls. |
| Handoff vs message | Handoffs transfer task ownership. Messages share information. |
| Trace vs log | Traces reconstruct causal agent paths. Logs record discrete events. |
| Trajectory vs outcome | Trajectory is the path. Outcome is the result. |
