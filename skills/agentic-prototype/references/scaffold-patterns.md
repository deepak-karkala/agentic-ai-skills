# Scaffold Patterns

Minimal scaffold templates for `agentic-prototype`. Each template is the smallest runnable structure for a given pattern — tool stubs, state schema, and control loop only.

All generated files must start with `# PROTOTYPE — not production code`.

---

## ReAct (Reason-Act) Loop

Single-agent loop: the model reasons about what to do, calls a tool, observes the result, and repeats until it reaches an answer or a stop condition.

**When to use:** The agent needs to use tools dynamically based on what it discovers at runtime. Steps are not pre-specified.

```python
# PROTOTYPE — not production code
# DESIGN QUESTION: <fill in>

import anthropic

# STUB: Replace with real system prompt
SYSTEM_PROMPT = """
You are an agent that completes tasks by using tools.
Think step by step. Use tools when needed. Stop when done.
"""

TOOLS = [
    {
        "name": "search",
        "description": "Search for information. STUB.",
        "input_schema": {
            "type": "object",
            "properties": {"query": {"type": "string"}},
            "required": ["query"],
        },
    },
    # STUB: Add more tools here
]


def call_tool(name: str, inputs: dict) -> str:
    # STUB: Implement actual tool logic
    return f"[STUB] Tool {name} called with {inputs}"


def run_agent(task: str) -> str:
    client = anthropic.Anthropic()
    messages = [{"role": "user", "content": task}]

    while True:
        response = client.messages.create(
            model="claude-sonnet-4-6",
            max_tokens=4096,
            system=SYSTEM_PROMPT,
            tools=TOOLS,
            messages=messages,
        )

        messages.append({"role": "assistant", "content": response.content})

        if response.stop_reason == "end_turn":
            return next(b.text for b in response.content if hasattr(b, "text"))

        tool_results = []
        for block in response.content:
            if block.type == "tool_use":
                result = call_tool(block.name, block.input)
                tool_results.append({
                    "type": "tool_result",
                    "tool_use_id": block.id,
                    "content": result,
                })

        messages.append({"role": "user", "content": tool_results})


def main():
    result = run_agent("Sample task — replace with real input")
    print(result)


if __name__ == "__main__":
    main()

# NEXT STEPS:
# - Replace SYSTEM_PROMPT with real instructions
# - Implement call_tool() with actual integrations
# - Add error handling for tool failures
# - Add session/trace logging
# - Add stop condition beyond end_turn (e.g., max steps)
```

---

## Plan-and-Execute

Two-phase: a planner LLM produces a step-by-step plan; an executor LLM carries out each step using tools.

**When to use:** Tasks are complex enough that upfront planning reduces error. The plan is stable once generated; steps don't require re-planning.

```python
# PROTOTYPE — not production code
# DESIGN QUESTION: <fill in>

import anthropic
import json

client = anthropic.Anthropic()

PLANNER_PROMPT = "Break the task into numbered steps. Output JSON: {\"steps\": [\"step1\", ...]}"
EXECUTOR_PROMPT = "Execute the step precisely. Use tools if needed."

TOOLS = [
    # STUB: Add tools here
]


def plan(task: str) -> list[str]:
    response = client.messages.create(
        model="claude-sonnet-4-6",
        max_tokens=1024,
        system=PLANNER_PROMPT,
        messages=[{"role": "user", "content": task}],
    )
    # STUB: Add error handling for malformed JSON
    return json.loads(response.content[0].text)["steps"]


def execute_step(step: str, context: str) -> str:
    # STUB: Add tool-use loop (same as ReAct scaffold)
    response = client.messages.create(
        model="claude-sonnet-4-6",
        max_tokens=2048,
        system=EXECUTOR_PROMPT,
        messages=[{"role": "user", "content": f"Context: {context}\n\nStep: {step}"}],
    )
    return response.content[0].text


def main():
    task = "Sample task — replace with real input"
    steps = plan(task)
    context = ""
    for i, step in enumerate(steps):
        print(f"Step {i+1}: {step}")
        result = execute_step(step, context)
        context += f"\nStep {i+1} result: {result}"
    print("Done:", context)


if __name__ == "__main__":
    main()

# NEXT STEPS:
# - Add tool-use loop in execute_step()
# - Handle planner JSON parse errors
# - Add re-planning if a step fails
# - Add context compression between steps
```

---

## Supervisor-Worker

A supervisor agent delegates tasks to worker agents. Workers are specialized; the supervisor coordinates and synthesizes.

**When to use:** Tasks require genuinely different expertise or isolated execution contexts. Not every multi-step task needs this — start single-agent.

```python
# PROTOTYPE — not production code
# DESIGN QUESTION: <fill in>

import anthropic

client = anthropic.Anthropic()

SUPERVISOR_PROMPT = "You coordinate workers. Delegate tasks. Synthesize results."
WORKER_A_PROMPT = "You are Worker A. You handle: STUB. Complete the task you receive."
WORKER_B_PROMPT = "You are Worker B. You handle: STUB. Complete the task you receive."


def run_worker(prompt: str, task: str) -> str:
    # STUB: Add tool support if this worker needs tools
    response = client.messages.create(
        model="claude-sonnet-4-6",
        max_tokens=2048,
        system=prompt,
        messages=[{"role": "user", "content": task}],
    )
    return response.content[0].text


def run_supervisor(task: str) -> str:
    # STUB: Replace with real delegation logic
    # In production: supervisor uses tools that invoke workers
    worker_a_result = run_worker(WORKER_A_PROMPT, f"Your part of: {task}")
    worker_b_result = run_worker(WORKER_B_PROMPT, f"Your part of: {task}")

    response = client.messages.create(
        model="claude-sonnet-4-6",
        max_tokens=2048,
        system=SUPERVISOR_PROMPT,
        messages=[{
            "role": "user",
            "content": f"Task: {task}\nWorker A: {worker_a_result}\nWorker B: {worker_b_result}\nSynthesize."
        }],
    )
    return response.content[0].text


def main():
    result = run_supervisor("Sample task — replace with real input")
    print(result)


if __name__ == "__main__":
    main()

# NEXT STEPS:
# - Replace sequential calls with tool-based worker invocation from supervisor
# - Implement worker-specific tool sets
# - Add context isolation between workers
# - Add handoff contract validation
```

---

## Human-in-the-Loop Approval Gate

The agent pauses before irreversible actions and waits for human approval before continuing.

**When to use:** Actions are irreversible (send email, write to database, execute code) or carry significant risk. Required for high and critical risk tiers per the deployment-readiness guardrail stack.

```python
# PROTOTYPE — not production code
# DESIGN QUESTION: <fill in>

import anthropic

client = anthropic.Anthropic()

AGENT_PROMPT = "Complete tasks. For irreversible actions, use the request_approval tool first."

TOOLS = [
    {
        "name": "request_approval",
        "description": "Request human approval before executing an irreversible action.",
        "input_schema": {
            "type": "object",
            "properties": {
                "action": {"type": "string", "description": "The action to be approved"},
                "reason": {"type": "string", "description": "Why this action is needed"},
                "reversible": {"type": "boolean"},
            },
            "required": ["action", "reason", "reversible"],
        },
    },
    {
        "name": "execute_action",
        "description": "Execute an approved action. STUB.",
        "input_schema": {
            "type": "object",
            "properties": {"action": {"type": "string"}},
            "required": ["action"],
        },
    },
]


def handle_approval_request(action: str, reason: str) -> str:
    # STUB: Replace with real approval mechanism (UI, Slack, email, etc.)
    print(f"\n[APPROVAL REQUIRED]\nAction: {action}\nReason: {reason}")
    decision = input("Approve? (y/n): ").strip().lower()
    return "approved" if decision == "y" else "denied"


def call_tool(name: str, inputs: dict) -> str:
    if name == "request_approval":
        return handle_approval_request(inputs["action"], inputs["reason"])
    if name == "execute_action":
        return f"[STUB] Executed: {inputs['action']}"
    return f"[STUB] Unknown tool: {name}"


def run_agent(task: str) -> str:
    messages = [{"role": "user", "content": task}]
    while True:
        response = client.messages.create(
            model="claude-sonnet-4-6",
            max_tokens=2048,
            system=AGENT_PROMPT,
            tools=TOOLS,
            messages=messages,
        )
        messages.append({"role": "assistant", "content": response.content})
        if response.stop_reason == "end_turn":
            return next(b.text for b in response.content if hasattr(b, "text"))
        tool_results = []
        for block in response.content:
            if block.type == "tool_use":
                result = call_tool(block.name, block.input)
                tool_results.append({"type": "tool_result", "tool_use_id": block.id, "content": result})
        messages.append({"role": "user", "content": tool_results})


def main():
    result = run_agent("Sample task requiring approval — replace with real input")
    print(result)


if __name__ == "__main__":
    main()

# NEXT STEPS:
# - Replace input() with real async approval mechanism
# - Add approval timeout and default-deny behavior
# - Add audit log for all approval requests and decisions
# - Add idempotency key for actions that could be double-submitted
```

---

## LangGraph StateGraph Skeleton

A typed state graph with named nodes and edges. Use when the workflow has explicit state transitions that benefit from a visual graph structure.

**When to use:** Complex multi-step flows with conditional branching, error recovery paths, or parallel branches that benefit from explicit state management.

```python
# PROTOTYPE — not production code
# DESIGN QUESTION: <fill in>

from typing import TypedDict, Annotated
import operator
from langgraph.graph import StateGraph, END


class AgentState(TypedDict):
    task: str
    plan: list[str]
    results: Annotated[list[str], operator.add]
    final_answer: str


def plan_node(state: AgentState) -> AgentState:
    # STUB: Call planner LLM
    return {"plan": ["step_1", "step_2"]}


def execute_node(state: AgentState) -> AgentState:
    # STUB: Execute next step from plan, append result
    return {"results": ["stub result"]}


def should_continue(state: AgentState) -> str:
    # STUB: Return "execute" if more steps remain, "end" if done
    if len(state["results"]) < len(state["plan"]):
        return "execute"
    return "end"


def synthesize_node(state: AgentState) -> AgentState:
    # STUB: Synthesize results into final answer
    return {"final_answer": "stub final answer"}


def build_graph() -> StateGraph:
    graph = StateGraph(AgentState)
    graph.add_node("plan", plan_node)
    graph.add_node("execute", execute_node)
    graph.add_node("synthesize", synthesize_node)

    graph.set_entry_point("plan")
    graph.add_edge("plan", "execute")
    graph.add_conditional_edges("execute", should_continue, {"execute": "execute", "end": "synthesize"})
    graph.add_edge("synthesize", END)
    return graph


def main():
    app = build_graph().compile()
    result = app.invoke({"task": "Sample task — replace", "plan": [], "results": [], "final_answer": ""})
    print(result["final_answer"])


if __name__ == "__main__":
    main()

# NEXT STEPS:
# - Implement plan_node() with real LLM call
# - Implement execute_node() with tool calls
# - Add checkpointer for state persistence (langgraph.checkpoint)
# - Add error recovery node and edge
# - Consider human-in-the-loop node for approval gates
```
