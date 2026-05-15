# Scenario: Breaking an Architecture Plan into Implementation Issues

## Trigger

> `/agentic-to-issues`
>
> "We just finished the architecture review for our document processing agent. It uses a supervisor-worker topology with three specialist workers. Can you break this into implementation tickets?"

## Command: /agentic-ai-engineering:agentic-to-issues

## Skill: agentic-to-issues

### Inputs gathered

1. Source: Architecture plan for a document processing agent (supervisor-worker pattern, 3 workers: extraction, classification, output-formatting)
2. Target context: Small team of 4 engineers
3. Scope: Include eval and rollout tasks

### Step 2 — Work categories identified

**Foundation:** Agent scaffold, shared tool interface contracts, message schema between supervisor and workers  
**Implementation:** Supervisor orchestration logic, Worker A (extraction), Worker B (classification), Worker C (output formatting), tool integrations (document store, output API)  
**Eval:** Eval harness per worker, scorecard graders for extraction accuracy and classification correctness, golden fixtures  
**Rollout:** Shadow mode, observability wiring, gated rollout, approval gate for high-priority documents

### Step 3 — Thin vertical slice decomposition

Each worker is one slice: scaffold → implement → eval → rollout, not all scaffolding first.

Sequencing: supervisor scaffold blocks all workers; workers can be implemented in parallel once scaffold is ready; eval harness per worker can be written alongside implementation.

### Issue list produced (abbreviated)

```markdown
## Foundation
- [ ] [foundation] Set up supervisor-worker agent scaffold (size: M)
- [ ] [foundation] Define supervisor↔worker message schema (size: S, blocked-by: scaffold)
- [ ] [foundation] Implement shared document store tool stub (size: S)

## Implementation
- [ ] [implementation] Implement supervisor: task delegation and result synthesis (size: M, blocked-by: schema)
- [ ] [implementation] Implement Worker A: document extraction (size: M, blocked-by: scaffold)
- [ ] [implementation] Implement Worker B: classification (size: M, blocked-by: scaffold)
- [ ] [implementation] Implement Worker C: output formatting (size: S, blocked-by: schema)
- [ ] [implementation] Wire document store tool (real integration) (size: M)
- [ ] [implementation] Wire output API tool (size: M)

## Eval
- [ ] [eval] Eval harness for Worker A extraction (size: M, blocked-by: Worker A)
- [ ] [eval] Eval harness for Worker B classification (size: M, blocked-by: Worker B)
- [ ] [eval] Deterministic graders: extraction field coverage (size: S)
- [ ] [eval] LLM-as-judge grader: classification correctness (size: M)
- [ ] [eval] Golden fixtures: 50 document samples (size: M)
- [ ] [eval] Supervisor integration test: end-to-end scenario (size: M, blocked-by: all workers)

## Rollout
- [ ] [rollout] Shadow mode deployment (blocked-by: eval harness)
- [ ] [rollout] Wire MELT observability (metrics, spans, alerts) (size: M)
- [ ] [rollout] Implement approval gate for high-priority documents (size: M)
- [ ] [rollout] Gated rollout: 10% → 50% → 100% with review gate (size: S, blocked-by: shadow)
```

### Step 6 — Report

```
Issue list written to .agentic/artifacts/implementation-issues.md.

Counts: foundation: 3, implementation: 6, eval: 6, rollout: 4 — total: 19

Flags:
- Supervisor task delegation logic (size M) has the most downstream blockers. 
  Prioritize after scaffold is ready.
- LLM-as-judge grader for classification needs calibration — budget time for 
  prompt iteration on 10+ examples before treating verdicts as reliable.
- Golden fixtures (50 documents) may require data annotation work if samples 
  don't exist yet — confirm with the team before scheduling.

Recommended next step: Start with the scaffold, then run 
/agentic-prototype to generate the supervisor-worker skeleton 
before writing implementation logic.
```
