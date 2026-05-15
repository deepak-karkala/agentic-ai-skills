# Scenario: Evaluating Invoice Processing for Agentic Fit

## Trigger

> `/agentic-opportunity-framing`
>
> "We're thinking about building an agent to handle invoice processing — receiving vendor invoices, validating fields, matching against POs, flagging discrepancies, and routing for approval. Should we build an agent for this?"

## Command: /agentic-ai-engineering:agentic-opportunity-framing

## Skill: agentic-opportunity-framing

### Inputs gathered

1. Workflow: Receive vendor invoices (PDF/email), extract fields, validate against PO database, identify discrepancies, route for approval or auto-approve if within policy
2. Current state: Accounts payable team of 3 processes ~200 invoices/day; ~40% are routine and could be auto-approved
3. Failure modes: Duplicate payments, incorrect PO matching, missed discrepancies causing overpayment
4. Existing automation: Basic OCR for field extraction; no intelligence layer

### Step 2 — Process-fit score

| # | Trait | Score | Rationale |
|---|---|---|---|
| 1 | Multi-step reasoning | 1 | Extract → validate → match → discrepancy check → routing decision requires chained reasoning |
| 2 | Requires tool use | 1 | Must query PO database, vendor records, and approval routing system |
| 3 | Judgment under uncertainty | 1 | Discrepancy resolution and routing require judgment; 30% of cases don't fit clean rules |
| 4 | High-value enough | 1 | Processing 200 invoices/day × 10 min each = 33 person-hours/day; clear ROI |
| 5 | Volume sufficient | 1 | 200/day is well above the amortization threshold |
| 6 | Acceptable error rate | 1 | Supervised mode (HITL for discrepancies and high-value invoices) makes error rate acceptable |
| 7 | Human verification feasible | 1 | AP team reviews flagged invoices; auto-approval only below dollar threshold |

**Score: 7/7 — Strong candidate**

### Step 3 — Disqualifiers checked

- D1 (zero-tolerance): Invoice processing has financial consequences, but supervised mode (HITL for flagged items and high-value invoices) removes this as a blocker.
- D2 (no ground truth): PO matching is verifiable; historical approval decisions provide labeled training data. Eval is feasible.
- D3 (latency): Processing time is minutes-to-hours, not sub-second. Not a constraint.
- D4 (data access): PO database and vendor records can be exposed via tool. Feasible.
- D5 (regulatory): Accounts payable is not regulated in a way that prohibits automation at L2/L3 autonomy.

**No disqualifiers apply.**

### Step 4 — Agent type

**Recommendation: Pipeline agent with HITL gate**

The extraction → validation → matching → routing sequence is largely pre-specified. A pipeline agent handles the structured steps; the HITL gate activates for discrepancies and invoices above the dollar threshold (e.g., >$10K).

Start at L2 (supervised): agent proposes; AP team approves. Expand to L3 (gated) for routine invoices after eval confirms accuracy.

### Step 5 — Compounding error analysis

- Distinct decision points: ~5 (extract, validate, match PO, assess discrepancy, routing decision)
- Conservative per-step accuracy: 93% (OCR + structured validation helps)
- End-to-end estimate: 0.93^5 ≈ 70%

**Flag:** 70% end-to-end accuracy is below the 80% threshold for unassisted operation.

Mitigation already in design: HITL gate for flagged invoices effectively breaks the compounding chain. Routine invoices (no discrepancy) have fewer effective steps and higher accuracy. Target: start with HITL for all, then automate the clean subset (no discrepancy, under threshold) once per-step eval data is in hand.

### Step 6 — Build/don't-build filter

| Filter | Result | Reasoning |
|---|---|---|
| Handles genuine ambiguity | Pass | ~30% of invoices have non-standard discrepancies that rules can't resolve |
| Benefits from tool use | Pass | PO matching and vendor lookup require real-time database access |
| Value exceeds inference cost | Pass | 33 person-hours/day saved; inference cost is marginal by comparison |
| Failure is recoverable | Pass | HITL gate on flagged items; duplicate detection is a validation step |

### Issue list produced (abbreviated)

Document written to `.agentic/artifacts/opportunity-framing-invoice-processing.md`.

```
Opportunity Framing: Invoice Processing Agent

Score: 7/7 — Strong candidate
Recommendation: Conditional Go

Conditions:
1. Start at L2 (supervised) — HITL for all invoices initially. 
   Do not auto-approve until per-step eval confirms >95% accuracy on clean invoices.
2. Define the "clean invoice" subset before build — the initial automation 
   target is invoices with no discrepancy and below $X threshold.
3. Build eval harness before expanding autonomy — ground truth is available 
   (historical approvals); use it.

Compounding error flag:
- End-to-end accuracy estimate: ~70% at 93% per-step.
- Mitigation: HITL gate breaks the chain for flagged invoices. 
  Auto-approval only applies to the clean subset where fewer steps are active.

Next step: /agentic-plan to design the pipeline agent with HITL gate.
Recommended pattern: pipeline agent (pre-specified steps) + approval gate 
for discrepancies and high-value invoices.
```
