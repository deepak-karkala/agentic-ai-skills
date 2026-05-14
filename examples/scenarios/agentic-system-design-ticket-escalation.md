# Scenario: Support Ticket Escalation Agent

## Trigger

> "We want to build an agent that monitors our customer support inbox, categorizes incoming tickets, and automatically escalates urgent ones to the right team. Can you help me design this?"

## Skill: agentic-system-design

## Step 2 — Use-case qualification (Process-Fit Framework)

| Trait | Assessment |
|---|---|
| High frequency | ✓ Tickets arrive continuously, 200–500/day |
| Multi-system | ✓ Reads email, CRM, ticketing system; writes Slack/PagerDuty |
| SOPs or policies exist | ✓ Escalation runbook exists; urgency tiers are defined |
| Measurable success | ✓ Escalation accuracy measurable vs. human triage baseline |
| Mixed task type | ✓ Combines classification (structured) with urgency judgment (LLM) |
| Recoverable errors | ✓ Missed escalation is a delay, not data loss; over-escalation is noise |
| Clean accessible data | ✓ Email and CRM APIs are accessible |

**Score: 7/7 — Strong agent candidate. No hard disqualifiers.**

## Step 3 — Agent tier

3-Condition Test:
1. Cannot write a complete decision tree — urgency signals are implicit in tone and context, not rule-based ✓
2. Conditional logic would require ongoing maintenance as ticket patterns evolve ✓
3. Ticket text cannot reliably be parsed to a schema before reasoning ✓

**Verdict: Tier 3 (True Agent).** Tier 2 was considered but cannot handle open-ended urgency signals without an LLM orchestrator.

## Step 4 — Pattern selection

Pattern composition: **Routing → Prompt Chaining**
- Routing: classify ticket into category (billing, technical, feedback, urgent)
- Chaining: for urgent tickets → gather context from CRM → draft escalation → route to team

**Guard:** Fallback handler for unclassified tickets; confidence threshold < 0.7 routes to human review.

## Step 5 — Reasoning paradigm

**ReAct** — ticket urgency may require mid-task adaptation (e.g., looking up customer tier before deciding escalation path). MAX_STEPS = 8.

## Step 6 — Autonomy level

| Factor | Assessment |
|---|---|
| Error cost | Medium — missed escalation delays support, not irreversible |
| Domain boundedness | Well-defined (escalation tiers, teams) |
| Reliability | Unproven — new system |
| Regulatory | Internal only |
| Action type | Write to Slack/PagerDuty (bounded, reversible) |

**Starting autonomy: Phase 1 — recommend-and-confirm.** Agent drafts escalation; human confirms before send. Advance to Phase 2 after 90%+ accuracy demonstrated over 30 days.

## Output

**Architecture recommendation:**
- Tier 3 True Agent, Routing → Chaining composition, ReAct paradigm
- Phase 1 supervised autonomy: human confirms all escalations
- Working memory: current ticket + customer context; semantic memory: escalation runbook (RAG)
- Upgrade trigger to Phase 2: 90%+ accuracy on 200 tickets, < 2% false-positive escalation rate

**Key risks:**
1. Over-escalation causing alert fatigue — mitigate with confidence threshold gate
2. Stale runbook in semantic memory — freshness contract required; cite runbook version in every escalation
3. No measurable baseline — instrument human triage baseline before agent launch

**Open question:** Is the escalation action (Slack/PagerDuty write) reversible? If not, Phase 2 advancement gate must require tested rollback.
