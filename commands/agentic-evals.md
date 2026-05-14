---
description: >
  Design or audit the evaluation strategy for an agentic workflow. Covers
  scorecard dimensions, grader selection, trajectory metrics, and regression
  testing. Routes to the agent-eval-design skill with the agent-evals-auditor
  subagent for audit-style inspection.
---

Invoke the agentic-ai-engineering:agent-eval-design skill.

The user wants to design evals for a new agent or audit an existing eval suite. Begin by asking:
1. Is this a new eval design or an audit of an existing setup?
2. What does the agent do, and what would a correct execution look like?
3. For audits: where are existing eval configs, traces, and scorecards? (Check .agentic/config.yml for eval_assets_path)

For audits: delegate evidence gathering to the agent-evals-auditor subagent before synthesizing recommendations.

Produce a structured eval plan or audit report. If eval_assets_path is not configured and the user needs audit mode, prompt them to run /agentic-ai-engineering:setup-agentic-ai-engineering first.
