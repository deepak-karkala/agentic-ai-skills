---
description: >
  Generate a minimal, runnable scaffold for an agentic AI pattern. Supports
  ReAct loops, plan-and-execute, supervisor-worker, human-in-the-loop approval
  gates, and LangGraph skeletons. The scaffold is intentionally narrow and
  disposable — its purpose is to answer a design question or validate a
  pattern, not to be production code. Routes to the agentic-prototype skill.
---

Invoke the agentic-ai-engineering:agentic-prototype skill.

The user wants a minimal working scaffold to validate a pattern or answer a design question. Begin by asking:
1. What pattern was chosen? (ReAct, plan-and-execute, supervisor-worker, HITL approval gate, LangGraph graph)
2. What specific design question does this prototype need to answer?
3. Which language and framework? (Python default; LangGraph, CrewAI, raw SDK, or framework-agnostic)
4. What tools should the agent have? Stubs are acceptable.

Run the agentic-prototype skill workflow. Produce a scaffold with STUB comments on every unimplemented body, a DESIGN QUESTION comment at the top, and a NEXT STEPS block at the bottom. If no pattern has been chosen yet, direct the user to run /agentic-ai-engineering:agentic-plan first.

Remind the user: this is a prototype, not production code. The first line of every generated file must be: # PROTOTYPE — not production code
