---
description: >
  Convert an agentic AI architecture plan or design doc into a structured
  implementation issue list. Separates work into foundation, implementation,
  eval, and rollout tasks with dependencies and sequencing. Routes to the
  agentic-to-issues skill.
---

Invoke the agentic-ai-engineering:agentic-to-issues skill.

The user wants to break an architecture plan into implementation work. Begin by asking:
1. Is there an existing architecture plan, design doc, or review artifact to work from? (Check .agentic/config.yml for design_docs_path)
2. What is the target team size and context — solo, small team, or larger team with distinct roles?
3. Should eval and rollout tasks be included, or implementation only?

Run the agentic-to-issues skill workflow. Produce a structured Markdown issue list organized by phase (foundation → implementation → eval → rollout) with explicit dependencies. If no architecture plan exists yet, direct the user to run /agentic-ai-engineering:agentic-plan first.
