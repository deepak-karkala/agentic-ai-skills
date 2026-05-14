# Scenario: Evals for Support Ticket Triage Agent

## Trigger

> "We're launching a support ticket triage agent in 3 weeks. It classifies tickets by category and urgency, then routes them to the right team. How should I set up evals?"

## Skill: agent-eval-design

## Step 2 — EDDOps status check

Three weeks before launch with no evals yet written. **Flag: EDDOps violation — evals must be defined before building, not before launching.**

Immediate action: stop agent development and define the eval criteria now. Agent should be re-tested against these criteria before the launch window.

## Step 3 — Six-Dimension Scorecard

| Dimension | Weight | Target | How to measure |
|---|---|---|---|
| Task Success | 30% | ≥ 85% correct routing decision | Compare agent route vs. expert-labeled golden set |
| Trajectory Quality | 20% | F1 ≥ 0.80 on required classification steps | Any-Order Match: agent must check category + urgency + customer tier before routing |
| Robustness | 15% | < 15% accuracy drop on adversarial inputs | Test on misspelled tickets, mixed languages, incomplete descriptions |
| Safety & Policy | 20% | 0 unauthorized escalations; 0 PII leaked in routing metadata | Rule: agent must not include ticket body content in Slack escalation message |
| Efficiency & Cost | 15% | ≤ 6 steps per ticket; ≤ $0.02 per routing decision | Measure step count and token spend per golden set run |
| Collaboration | 0% | N/A — fully automated triage, no HITL | Skip this dimension |

## Step 4 — Trajectory metrics

Ticket triage requires: (1) retrieve customer tier, (2) classify category, (3) assess urgency, (4) look up team routing table, (5) route. Order is flexible.

**Selected metric: Any-Order Match (Recall ≥ 0.85)**
- All five steps must happen; order is flexible
- Recall is the primary concern — missing a step is worse than an extra step
- Secondary: Precision ≥ 0.80 to catch agents that do excessive unnecessary lookups

## Step 5 — Grader selection

| Dimension | Grader | Rationale |
|---|---|---|
| Task Success (routing) | Deterministic | Routing destination is a discrete value — exact match vs. expected team |
| Trajectory | Deterministic | Tool call sequence is verifiable from trace |
| Safety (PII check) | Deterministic | Rule-based: scan Slack message for presence of ticket body content |
| Safety (authorization) | Deterministic | Check if escalation went to authorized team for this ticket category |
| Robustness | LLM-as-Judge | Assess whether agent behavior on adversarial inputs is reasonable, not just correct |

LLM judge deployment checklist for robustness dimension:
- [ ] Rubric written: "did the agent gracefully handle ambiguous/malformed input?"
- [ ] Calibrate on 50 labeled examples before launch
- [ ] Verify ≥ 80% agreement with human ratings
- [ ] Separate judge model from triage agent model
- [ ] Structured verdict: PASS / PARTIAL (minor issue) / FAIL (routed wrong or hallucinated) with failing criterion

## Step 6 — Three-tier pipeline

| Tier | What runs | Gate |
|---|---|---|
| CI/CD | Golden set (30 tickets, representative distribution); routing accuracy; step count | Block merge if accuracy drops > 5% vs. baseline |
| Staging (pre-launch) | Full scorecard; adversarial set; safety checks | Block launch if any safety dimension < 100%, any dimension < target |
| Production | Sample 5% of live tickets daily; compare to golden distribution; alert on drift | Page on-call if TCR drops below 80% for 2 consecutive days |

**Golden set:** Start with 30 tickets, covering happy path (20), edge cases (5), adversarial (5). Grow to 100 within 60 days of launch using production traffic samples.

## Step 7 — Non-determinism

Classification tasks: run k=3, use majority vote on routing destination. If 3 runs disagree on destination, the ticket is borderline — route to human review and add to golden set.

## Output

**Key finding:** Evals should have been defined before development. Three weeks out, the priority is: (1) define golden set of 30 tickets today, (2) run against current agent to establish baseline before any further changes, (3) set up CI/CD gate, (4) run full staging suite 5 days before launch.

**Highest risk:** No adversarial coverage yet. Adversarial set (misspelled input, mixed languages, attempt to route high-priority ticket as low-priority) must be ready before staging eval.
