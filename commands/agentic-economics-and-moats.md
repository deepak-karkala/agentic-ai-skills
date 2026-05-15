---
name: agentic-economics-and-moats
description: >
  Analyzes unit economics and competitive moat structure for an agentic AI
  product. Models the inference cost trap, builds a contribution margin LTV
  analysis, identifies cost optimization levers, and designs the data flywheel.
---

# /agentic-economics-and-moats

Routes to the `agentic-economics-and-moats` skill.

## What this command does

Runs the full economics and moat analysis:
1. Diagnoses the inference cost trap (5–25x multiplier risk)
2. Builds a contribution margin LTV model (not standard LTV:CAC)
3. Identifies cost optimization levers (caching, tiered routing, compression)
4. Assesses the five-layer moat stack (workflow position through habit/spread)
5. Designs the data flywheel (MAPE: Monitor → Analyze → Plan → Execute)
6. Produces a structured economics and moat document

## When to use

- "Will this pricing model work at scale?"
- "Are we losing money on inference?"
- "Model our unit economics"
- "How do we build a defensible moat?"
- "Design our data flywheel"

## Output

Economics and moat document at `artifact_output_path/economics-<name>.md` (or `.agentic/artifacts/` if not configured).

## Next steps after this command

- **Pricing model problem**: adjust pricing structure and re-run
- **Architecture inefficiency**: run `/agentic-plan` to redesign for cost efficiency
- **Product positioning problem**: run `/agentic-product-strategy` to re-examine wedge and ICP
