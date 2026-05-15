---
name: agentic-governance-and-adoption
description: >
  Designs the governance posture and adoption strategy for an agentic AI
  product or deployment. Assesses governance maturity, defines minimum
  controls, maps regulatory requirements, designs human-agent collaboration
  UX, and plans the adoption sequence.
---

# /agentic-governance-and-adoption

Routes to the `agentic-governance-and-adoption` skill.

## What this command does

Runs the full governance and adoption workflow:
1. Assesses governance maturity (Ad Hoc → Optimized, 4 levels)
2. Defines minimum governance controls for the deployment context
3. Maps applicable regulatory requirements (EU AI Act, HIPAA, SOC 2, NIST, etc.)
4. Designs human-agent collaboration UX (transparency, control, trust calibration layers)
5. Plans the adoption sequence (Land → Expand → Scale)
6. Produces a structured governance and adoption document

## When to use

- "What governance do we need for this agent?"
- "Design the UX for our agent"
- "How do we roll this out to the organization?"
- "What regulatory requirements apply?"
- "Assess our governance maturity"

## Output

Governance and adoption document at `artifact_output_path/governance-<name>.md` (or `.agentic/artifacts/` if not configured).

## Next steps after this command

- **Technical guardrails**: run `/agentic-ops` to implement deployment readiness controls
- **Eval suite**: run `/agentic-evals` to build the eval infrastructure that supports governance
- **Architecture changes**: run `/agentic-plan` if regulatory requirements reveal architectural changes needed
