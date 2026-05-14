# Scenario: Research + Report + Fact-Check Pipeline

## Trigger

> "I have an agent that does competitive analysis: it searches for market data across multiple sources, writes a summary report, and then fact-checks the report. It's getting slow and the context window is filling up. Should I split this into multiple agents?"

## Skill: multi-agent-orchestration

## Step 2 — Single-agent default check

Evaluate the four upgrade triggers:

| Trigger | Present? | Evidence |
|---|---|---|
| **Context Pollution** | ✓ | Search results are high-volume, irrelevant to each other; they could be absorbed by specialist subagents and returned as compact findings |
| **Tool Overload** | Borderline | 3 tool clusters: search tools, report tools, fact-check tools — borderline but not clearly degrading |
| **Conflicting Specialist Roles** | ✓ | Researcher role (maximize coverage, cite everything) and Critic role (challenge claims, identify gaps) actively conflict — putting both in one agent produces hedged, low-confidence output |
| **Independent Parallel Workstreams** | Partial | Search sub-tasks across sources are independent of each other, but report writing depends on search completing |

**Verdict: 2+ upgrade triggers present. Multi-agent is justified.**

Note: context window exhaustion is the immediate symptom, but the conflicting roles (researcher vs. critic) are the deeper reason — a single agent cannot be both uncritically comprehensive and adversarially skeptical.

**Decompose by context, not by job title.** The right split is not "researcher → writer → checker" (org-chart) but where each agent can operate from a compact handoff contract.

## Step 3 — Topology selection

**Topology: Hub-and-Spoke routing to Parallel Fan-Out**

- Manager agent owns the overall task and synthesizes final output
- Parallel Fan-Out: 3+ search workers run independently (one per source domain); each returns structured findings
- Sequential stage: report writer receives merged findings from manager; produces structured draft
- Supervisor-with-Critic: fact-checker receives draft + source citations; returns structured verdict

This is a topology composition: Hub-and-Spoke at the outer level, Parallel Fan-Out for independent search, Supervisor-with-Critic for quality gate.

## Step 4 — Handoff contract (Manager → Search Worker, example)

```yaml
task_id: competitive-analysis-2026-05
parent_trace_id: trace-abc123
requesting_agent: manager
receiving_agent: search-worker-industry-news
objective: Find competitor product announcements from the last 90 days
scope:
  in_scope: [product launches, pricing changes, partnership announcements]
  out_of_scope: [opinion pieces, historical background, unverified rumors]
inputs:
  artifacts: []
  source_refs: [industry-news-domain-list.txt]
constraints:
  allowed_tools: [web_search, news_api]
  forbidden_actions: [write_to_report, contact_external_apis]
budget:
  max_steps: 10
  max_tokens: 4000
output_contract:
  schema: {findings: [{claim, source_url, date, confidence}]}
  acceptance_criteria: [at least 3 findings, each with source URL and date]
  citation_required: true
failure_policy:
  on_tool_error: return partial findings with error note
  on_low_confidence: include in findings with confidence < 0.6 flagged
  on_budget_exceeded: return findings collected so far
```

## Step 5 — Anti-patterns flagged

**False Independence (risk):** The parallel search workers must not write to a shared output document directly — they return structured findings to the manager, who merges them. Explicit partition ownership required.

**Rubber-Stamp Verifier (risk):** The fact-checker must have explicit criteria (not "check if this is accurate"). Verifier contract must return `PASS`, `REVISE`, or `ESCALATE` with failing claims and evidence.

## Output

**Topology:** Hub-and-Spoke (manager) → Parallel Fan-Out (search workers) → Sequential (report writer) → Supervisor-with-Critic (fact-checker)

**Framework recommendation:** LangGraph — graph state + checkpoint/resume needed to handle the search fan-out merge; HITL gate possible if fact-checker returns `ESCALATE`.

**Token cost:** This adds ~30–50% token overhead. Justified because: (1) search workers absorb and compress high-volume raw content before it reaches manager context; (2) conflicting roles are now cleanly separated.
