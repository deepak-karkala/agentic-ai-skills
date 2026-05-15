---
name: agentic-product-strategy
description: >
  Defines product strategy for an agentic AI product. Scores the market entry
  wedge, defines the ICP, classifies the product architecture tier, selects
  the GTM motion, and identifies moat-building opportunities.
---

# /agentic-product-strategy

Routes to the `agentic-product-strategy` skill.

## What this command does

Runs the full product strategy workflow:
1. Defines the ICP (role + workflow + system)
2. Scores the market entry wedge across 7 dimensions
3. Classifies product architecture tier (thin wrapper → outcome-contracted)
4. Selects the GTM motion (Land → Expand → Scale)
5. Identifies moat-building opportunities
6. Produces a structured product strategy document

## When to use

- "Where should we enter the market with this agent product?"
- "Define our ICP for this agent"
- "Is our product architecture defensible?"
- "What's the right GTM motion for this?"
- "Are we building a thin wrapper?"

## Output

Product strategy document at `artifact_output_path/product-strategy-<name>.md` (or `.agentic/artifacts/` if not configured).

## Next steps after this command

- **Architecture**: run `/agentic-plan` to design the technical architecture
- **Economics**: run `/agentic-economics-and-moats` for unit economics and moat depth
- **Use case validation**: run `/agentic-opportunity-framing` if the ICP workflow hasn't been scored yet
