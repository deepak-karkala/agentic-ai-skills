# Scenario: Strategy-to-Architecture Transition

## Trigger

> "We think there's a real opportunity to automate invoice processing with an agent. We want to go from 'should we build this?' all the way to a concrete architecture plan in one session."

## Skills: agentic-opportunity-framing → agentic-product-strategy → agentic-system-design

Multi-skill scenario. Strategy lane runs first (opportunity framing then product strategy), then the technical lane picks up with system design.

---

### Phase 1: agentic-opportunity-framing

#### Inputs gathered

1. Use case: Automate invoice processing — extract fields, match to POs, flag exceptions, route to approvers
2. Current state: Finance team processes 800 invoices/week manually; each takes 8–12 minutes; 15% exception rate
3. Data available: Structured invoice PDFs, ERP purchase order records, historical approval decisions
4. Failure impact: Delayed invoice = vendor penalty; mismatched amount = compliance risk (correctable, not catastrophic)

#### Process-fit scoring

| Trait | Rating | Evidence |
|---|---|---|
| High repetition | Present | 800/week, predictable volume |
| Defined success criteria | Present | Invoice matched to PO, exceptions flagged correctly |
| Stable inputs | Present | PDF invoices + structured ERP data |
| Low irreversibility | Present | Matching is a read + flag operation; payment is downstream and human-gated |
| Moderate complexity | Present | Field extraction + PO matching + exception logic — not trivial, not open-ended |
| Clear process boundary | Present | Invoice arrives → matched or escalated → done |
| Ground truth available | Present | Historical approvals + ERP records provide labeled examples |

**Verdict:** 7/7 traits present — strong candidate. No disqualifiers. Build/don't-build filter: all four properties hold.

---

### Phase 2: agentic-product-strategy

#### Wedge scoring

| Dimension | Score | Evidence |
|---|---|---|
| Verifiability | 3 | ERP match rate and exception flag accuracy are objective metrics |
| Reversibility | 3 | Matching is read-only; payment approval is human-gated |
| Data advantage | 2 | Historical approvals provide training signal; not yet a deep moat |
| Workflow position | 3 | Agent owns the AP processing step — not peripheral |
| SOP capture | 2 | Finance team SOPs can be encoded; not fully captured yet |
| Switching cost | 2 | Integrates into ERP; moderate switching cost |
| Regulatory alignment | 2 | SOC 2 required; manageable with audit logging |

**Total: 17/21 — Strong wedge.** No thin wrapper risk (Workflow Position = 3, Data Advantage growing).

**ICP:** AP team leads at mid-market companies (50–500 person finance teams) running NetSuite, SAP, or Oracle — frustrated with high exception volume and month-end bottlenecks.

**GTM:** Land with a 4-week pilot on one AP team's highest-volume vendor relationship → expand to full AP team → scale to multi-entity.

**Strategic moat priority:** Workflow position (owns the AP step) is the immediate moat. Data advantage builds as approval decisions accumulate.

---

### Phase 3: agentic-system-design

**Trigger:** "Good — we're building it. Now design the architecture."

The decision is made in the strategy lane. System design picks up from here.

#### Architecture designed

**Pattern selected:** Evaluator-Optimizer  
Rationale: Invoice matching produces a structured output (match/exception/partial) that can be evaluated against objective criteria before routing. The evaluator checks match quality; the optimizer resolves partial matches.

**Agent topology:**

```
Orchestrator
│
├── Extractor Agent
│     tools: extract_invoice_fields (PDF parser)
│     output: structured invoice record
│
├── Matcher Agent
│     tools: lookup_purchase_order, lookup_vendor_history
│     output: match_result (matched / partial / no_match)
│
└── Evaluator Agent
      tools: apply_exception_rules, flag_for_review
      output: route_decision (approved / escalated / flagged)
      HITL gate: > $10,000 or partial match → human approval required
```

**Autonomy tier:** L2 — agent executes matching and routing autonomously; payment approval always requires human sign-off.

**Context boundary:** Each agent receives only the data it needs. Extractor outputs go to Matcher via structured schema, not raw PDF. Matcher outputs go to Evaluator via a match result object, not the full invoice record.

#### Strategy-to-architecture decisions preserved

| Strategy decision | Architecture consequence |
|---|---|
| Verifiability = 3 | Evaluator Agent has explicit match criteria — not LLM judgment |
| Reversibility = 3 | No agent has direct write access to payment system |
| Workflow position = 3 | Orchestrator is the AP processing step; no bypass path |
| HITL gate required | `> $10,000 or partial match` triggers human approval before routing |

**Next steps:** `/agentic-ai-engineering:agentic-evals` to design the eval scorecard before writing any code.
