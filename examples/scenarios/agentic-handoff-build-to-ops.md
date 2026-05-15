# Scenario: Build-to-Ops Team Handoff

## Trigger

> `/agentic-handoff`
>
> "We're done with the build phase of our refund processing agent. It's been approved for shadow deployment. The ops team is taking over from here. Can you write the handoff doc?"

## Command: /agentic-ai-engineering:agentic-handoff

## Skill: agentic-handoff

### Inputs gathered

1. Handoff type: Build team → Ops team
2. Current phase: Eval complete, approved for shadow deployment
3. Existing artifacts: Architecture doc at `docs/architecture/refund-agent.md`, eval scorecard at `evals/scorecard-v1.md`, deployment guide at `docs/deployment/refund-agent-ops.md`
4. `.agentic/config.yml`: `design_docs_path: docs/architecture`, `artifact_output_path: .agentic/artifacts`, `eval_assets_path: evals/`

### Architecture state captured

Pattern: ReAct loop with tool gateway  
Autonomy tier: Assisted (Phase 2 — agent executes, human reviews escalations)  
Tools: `lookup_order`, `issue_refund` (irreversible), `flag_for_review`  
External systems: Order management system (read-only), payment processor (write), support ticket system (write)

Key decisions:
- `issue_refund` is gated behind a HITL approval gate for amounts > $500
- ReAct chosen over plan-and-execute because refund decisions depend on dynamic order state
- Architecture doc: `docs/architecture/refund-agent.md`

Architecture debts:
- Partial refunds not yet supported — full refund or escalate only
- No retry logic if payment processor times out (fails hard, creates a ticket)

### Eval status captured

Eval suite: Automated, runs on every commit  
Eval scorecard: `evals/scorecard-v1.md`

| Dimension | Coverage | Baseline |
|---|---|---|
| Task Success | High | 94% correct routing |
| Trajectory Quality | Medium | 78% optimal tool call sequence |
| Robustness | Medium | Tested 3 of 5 adversarial categories |
| Safety | High | HITL gate tested and verified |
| Efficiency | Low | No latency baseline established |
| Collaboration | N/A | No collaboration dimension applicable |

Eval gaps:
- Robustness: edge cases for partial order refunds not tested (deferred — feature not built)
- Efficiency: no latency SLA established; ops team should measure during shadow

### Deployment posture captured

Current mode: Approved for shadow deployment (not yet running)  
Guardrails active: HITL gate for amounts > $500, rate limiter (max 100 refunds/hour)  
Rollback procedure: Disable the agent route in the API gateway; orders fall back to manual queue  
Observability: OTel spans wired for all tool calls; no dashboards set up yet

Monitoring gaps:
- No Grafana dashboard or alert rules — ops team must set these up before gated rollout
- `issue_refund` call success rate has no alert threshold defined

### Open risks

**Blockers:**
- Observability dashboards not set up — must exist before exiting shadow mode

**Important:**
- Payment processor timeout handling — currently hard fails; should be graceful with retry before gated rollout
- Partial refund support — currently escalates all partial refund requests; will generate noise in the escalation queue

**Noted:**
- Latency SLA not established — measure during shadow and define before gated rollout

### Handoff document written

**File:** `.agentic/artifacts/handoff-refund-agent-2026-05-15.md`

**Linked artifacts:**
| Artifact | Path | Status |
|---|---|---|
| Architecture doc | `docs/architecture/refund-agent.md` | Current |
| Eval scorecard | `evals/scorecard-v1.md` | Current |
| Deployment guide | `docs/deployment/refund-agent-ops.md` | Current |
| Architecture HTML | `.agentic/artifacts/architecture-review-refund-agent.html` | Current |

### User message

```
Handoff document written to:
.agentic/artifacts/handoff-refund-agent-2026-05-15.md

Linked 4 existing artifacts. All found and current.

⚠ Blocker before exiting shadow mode:
  Observability dashboards and alert rules are not set up.
  The ops team must create these before approving gated rollout.

First action for the incoming ops team:
  1. Read the architecture doc and deployment guide (15 min)
  2. Run the shadow deployment per the ops guide
  3. Set up Grafana dashboard for issue_refund success rate
  4. Define latency SLA from shadow observations
  5. Open a ticket to address payment processor timeout handling
```
