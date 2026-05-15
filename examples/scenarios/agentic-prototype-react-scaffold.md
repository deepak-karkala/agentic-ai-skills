# Scenario: Generating a ReAct Scaffold to Validate a Pattern Choice

## Trigger

> `/agentic-prototype`
>
> "We chose a ReAct loop for our research assistant agent. It needs to search the web, read documents, and summarize findings. Can you generate the scaffold so I can validate the pattern works before we start building for real?"

## Command: /agentic-ai-engineering:agentic-prototype

## Skill: agentic-prototype

### Inputs gathered

1. Pattern: ReAct (reason-act) loop
2. Design question: Does a single ReAct loop handle multi-source research (web + documents) without losing track of findings across tool calls?
3. Language: Python, raw Anthropic SDK (no framework)
4. Tools: `search_web`, `read_document`, `summarize` (stubs acceptable)

### Step 2 — Scaffold type selected

ReAct scaffold — single-agent loop with tool-use.

### Step 3 — Generated scaffold

**Files written to:** `.agentic/artifacts/prototypes/react-research-agent/`

`agent.py` (abbreviated):
```python
# PROTOTYPE — not production code
# DESIGN QUESTION: Does a single ReAct loop maintain research coherence
# across multiple tool calls to web search and document reading?

import anthropic

SYSTEM_PROMPT = """
You are a research assistant. Complete research tasks by searching and
reading sources. Think step by step. Cite sources as you go.
Stop when you have enough to write a complete summary.
"""

TOOLS = [
    {
        "name": "search_web",
        "description": "Search the web for information on a topic. Returns snippets.",
        "input_schema": {
            "type": "object",
            "properties": {"query": {"type": "string"}},
            "required": ["query"],
        },
    },
    {
        "name": "read_document",
        "description": "Read the full content of a document by URL or path.",
        "input_schema": {
            "type": "object",
            "properties": {"source": {"type": "string"}},
            "required": ["source"],
        },
    },
    {
        "name": "summarize",
        "description": "Write the final research summary. Call when research is complete.",
        "input_schema": {
            "type": "object",
            "properties": {
                "findings": {"type": "string"},
                "sources": {"type": "array", "items": {"type": "string"}},
            },
            "required": ["findings", "sources"],
        },
    },
]


def call_tool(name: str, inputs: dict) -> str:
    # STUB: Implement actual search, document reading, and summarization
    return f"[STUB] {name} called with {inputs}"


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
                tool_results.append(
                    {"type": "tool_result", "tool_use_id": block.id, "content": result}
                )
        messages.append({"role": "user", "content": tool_results})


# NEXT STEPS:
# - Implement call_tool() with real web search (Brave/Serper) and document reader
# - Add max_steps guard to prevent runaway loops
# - Add context compression if research sessions grow long (>30k tokens)
# - Add trace logging for each tool call and reasoning step
# - Validate: does the agent cite sources correctly across multi-turn sessions?
```

### Step 6 — Report

```
Scaffold written to .agentic/artifacts/prototypes/react-research-agent/

Pattern: ReAct loop (single agent, tool-use)
Design question: Does the loop maintain research coherence across 
multi-source tool calls?

Stubs to implement before the prototype is meaningful:
1. call_tool() → real web search integration
2. call_tool() → real document reader
3. (Optional) real summarize() or let the model handle it in end_turn

To answer your design question: run the prototype with stub results
that simulate multi-source findings (search returns 3 snippets, 
document read returns full text). Check whether the model correctly
synthesizes across both sources in the final summary.

If the loop drifts or loses track of earlier findings, that signals
a context engineering problem — route to context-engineering-for-agents
before building the real implementation.

Recommended next step: implement the stubs and run the prototype,
then /agentic-to-issues to slice the full implementation.
```
