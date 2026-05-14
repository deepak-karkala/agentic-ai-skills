---
description: >
  Assess production readiness and deployment posture for an agentic system.
  Covers guardrails, human-in-the-loop gates, observability requirements,
  rollout strategy, and reversibility classification. Routes to the
  deployment-readiness skill.
---

Invoke the agentic-ai-engineering:deployment-readiness skill.

The user wants to assess whether their agent is ready for production. Begin by asking:
1. What actions can the agent take, and are they reversible?
2. What guardrails are currently in place (if any)?
3. What is the intended rollout scope — shadow mode, limited users, or full production?
4. Are there existing observability or alerting setups to reference?

Run the deployment-readiness skill workflow. Produce a structured production-readiness checklist and, if the assessment warrants it, a rollout recommendation.
