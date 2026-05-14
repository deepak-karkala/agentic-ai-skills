---
description: >
  Review an existing agent architecture. Assesses topology, tool boundaries,
  autonomy tier, design decisions, and risk register. Routes to the
  agentic-system-design skill with the agent-systems-architect subagent for
  isolated analysis. Produces the architecture-review HTML artifact.
---

Invoke the agentic-ai-engineering:agentic-system-design skill in review mode.

The user has an existing agent design to review. Begin by asking for:
1. A description of the current architecture (or a design doc path if configured)
2. The primary concern driving the review (safety, scalability, correctness, cost)
3. Any known failure modes or incidents that should inform the review

Run the agentic-system-design skill review workflow. Delegate architecture decomposition to the agent-systems-architect subagent.

Always produce the architecture-review HTML artifact for this command — the user explicitly asked for a review, so a structured inspectable output is always appropriate.
