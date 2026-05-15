---
name: agentic-handoff
description: >
  Produces a structured handoff document for an agentic AI project —
  capturing architecture state, eval status, deployment posture, open
  risks, and next actions so a new engineer or team can continue without
  losing context. Links to existing artifacts rather than duplicating them.
  Use when transitioning a project to a new engineer or team, when pausing
  work on an agent system for an extended period, when completing a phase
  and handing to a different team (build to ops, research to production),
  or when creating a record before a major refactor.
  Trigger phrases: "write a handoff doc for this project", "capture what the
  next engineer needs to know", "I'm handing this off", "create a project
  summary for the new team", "document current state before I leave",
  "what should I document before wrapping up". Do not use for architecture
  design (use agentic-system-design), for generating implementation tasks
  (use agentic-to-issues), or for eval design (use agent-eval-design).
allowed-tools:
  - Read
  - Write
metadata:
  category: workflow-support
  version: "0.1.0"
---

# Agentic Handoff

Cross-session and cross-team continuity skill. Produces a structured handoff document that captures current project state, key decisions, open risks, and next actions — linking to existing artifacts rather than duplicating content.

## When to Use

**Use when:**
- Transitioning a project to a new engineer or team
- Pausing work on an agent system for an extended period
- Completing a build phase and handing to an ops or reliability team
- Creating a record before a major architecture change or refactor
- Concluding a consulting or contract engagement

**Do not use when:**
- Architecture decisions still need to be made → use `agentic-system-design`
- The team needs implementation tasks → use `agentic-to-issues`
- The request is to generate an eval plan → use `agent-eval-design`
- The work is ongoing and the team isn't changing — a handoff doc is premature

## Workflow

### Step 1 — Establish scope

Ask the user:
1. Who is handing off to whom? (Same team, different team, contractor to employee, build to ops?)
2. What is the current phase? (Design, build, eval, deployed, incident recovery?)
3. What is the time horizon? (Immediate handoff, returning in weeks, permanent transfer?)
4. Are there existing artifacts to reference? (Architecture docs, eval scorecards, deployment guides, ADRs?)

Check `.agentic/config.yml` for `design_docs_path` and `artifact_output_path`. If configured, scan those paths for existing artifacts to link rather than re-summarize.

---

### Step 2 — Capture architecture state

Summarize the current architecture in 3–5 sentences:
- What does this agent system do?
- What pattern was chosen (ReAct, plan-and-execute, supervisor-worker, pipeline)?
- What tools does it use, and what external systems does it connect to?
- What autonomy tier is it operating at (supervised, assisted, autonomous)?

Link to the full architecture doc or HTML artifact if it exists. Do not duplicate the full design here.

Key decisions to surface:
- Why this pattern was chosen over the alternatives considered
- Any architecture constraints that must be preserved (compliance, performance, cost)
- Any architecture debts or deferred decisions that the incoming team will need to address

---

### Step 3 — Capture eval status

Summarize the eval posture in 3–5 sentences:
- Does an eval suite exist? Is it automated?
- Which scorecard dimensions are covered and at what confidence?
- What is the current pass rate or baseline on key metrics?
- What failure modes remain unaddressed in evals?

Link to eval artifacts, scorecard files, or eval harness location if configured at `eval_assets_path`.

Flag explicitly:
- Any dimension with no eval coverage (especially safety and robustness)
- Known eval gaps that must be addressed before expanding autonomy
- Regression tests that are currently failing or skipped

---

### Step 4 — Capture deployment posture

Summarize the production state:
- Is the system deployed? In what mode (shadow, gated, full)?
- What guardrails are active?
- What is the HITL approval gate configuration?
- What observability is in place (tracing, metrics, alerts)?
- What is the rollback procedure?

Link to the deployment artifact or runbook if it exists.

Flag explicitly:
- Any guardrails that are disabled or in soft-fail mode
- Any monitoring gaps (metrics with no alerts, traces not reviewed)
- Any open incidents or post-mortems not yet resolved

---

### Step 5 — Capture open risks and decisions

List all known open items in three tiers:

| Tier | Meaning |
|---|---|
| **Blocker** | Must be resolved before the incoming team can proceed safely |
| **Important** | Should be resolved in the next milestone; does not block day-to-day work |
| **Noted** | Known issue or debt; low urgency but should not be forgotten |

For each item: what is the risk, what is the current mitigation (if any), and what decision or action is needed.

---

### Step 6 — Write recommended next actions

Provide a concrete, ordered list of what the incoming engineer or team should do first:
1. What to read before touching anything (architecture doc, key ADRs, recent incidents)
2. What to run to verify the system is in the expected state
3. What the first meaningful task is (usually the top blocker from Step 5)
4. Who to contact for questions on specific subsystems

---

### Step 7 — Write the handoff document

Write the document to `artifact_output_path/handoff-<system-name>-<date>.md` if `artifact_output_path` is configured. Otherwise write to `.agentic/artifacts/handoff-<system-name>-<date>.md` and note the path.

Use the handoff document format from [Handoff Document Template](references/handoff-template.md).

Keep the document concise: the reader should be able to get oriented in 15 minutes or less. Long content belongs in linked artifacts, not in this document.

---

### Step 8 — Report

After writing the document:
1. State the file path.
2. List the artifacts linked (and flag any that were referenced but not found).
3. Call out any blocker-tier risks that must be resolved immediately.
4. Suggest next step: the first action from Step 6.

## Output Contract

- **Primary output:** Handoff Markdown document at `artifact_output_path/handoff-<name>-<date>.md` or `.agentic/artifacts/handoff-<name>-<date>.md`
- **In-conversation summary:** file path, linked artifacts, blockers, first next action
- **Does not produce:** architecture decisions, code, eval plans, new design documents

## Scope Boundaries

This skill captures state. It does not make new architecture or design decisions. If preparing the handoff reveals an unresolved design question, note it in the open risks section and suggest routing to `agentic-system-design` before handoff is complete.
