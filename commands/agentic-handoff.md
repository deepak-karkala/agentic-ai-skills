---
description: >
  Produce a structured handoff document for an agentic AI project. Captures
  architecture state, eval status, deployment posture, open risks, and next
  actions. Links to existing artifacts rather than duplicating them. Routes
  to the agentic-handoff skill.
---

Invoke the agentic-ai-engineering:agentic-handoff skill.

The user wants to document current project state for handoff to a new engineer or team. Begin by asking:
1. Who is handing off to whom? (Same team, different team, contractor to employee, build to ops?)
2. What is the current project phase? (Design, build, eval, deployed?)
3. Are there existing artifacts to reference — architecture docs, eval scorecards, deployment guides? (Check .agentic/config.yml for design_docs_path and artifact_output_path)

Run the agentic-handoff skill workflow. Produce a structured Markdown handoff document covering architecture state, eval status, deployment posture, open risks (tiered as blocker/important/noted), and recommended first actions for the incoming team. Link to existing artifacts rather than duplicating their content.
