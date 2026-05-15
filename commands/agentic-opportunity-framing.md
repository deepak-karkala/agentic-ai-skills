---
name: agentic-opportunity-framing
description: >
  Evaluates a workflow or use case for agentic AI fit. Scores against the
  7-trait process-fit framework, checks disqualifiers, classifies the agent
  type, and produces a structured framing document with a Go / No-Go /
  Conditional Go recommendation.
---

# /agentic-opportunity-framing

Routes to the `agentic-opportunity-framing` skill.

## What this command does

Runs the full opportunity framing workflow:
1. Scores the workflow against 7 process-fit traits (5+/7 = strong candidate)
2. Checks for disqualifiers that override the score
3. Classifies the appropriate agent type
4. Estimates compounding error risk for multi-step workflows
5. Applies the build/don't-build filter (4 properties)
6. Produces a structured framing document with a recommendation

## When to use

- "Should we build an agent for this workflow?"
- "Is this use case agent-shaped?"
- "Score this opportunity for agentic AI fit"
- Triaging a backlog of automation ideas

## Output

Framing document at `artifact_output_path/opportunity-framing-<name>.md` (or `.agentic/artifacts/` if not configured).

## Next steps after this command

- **Go**: run `/agentic-plan` to design the architecture
- **Conditional Go**: address the stated conditions, then re-evaluate or proceed with constraints
- **No-Go**: the command will recommend an alternative approach (rules-based, pipeline, simpler ML)
