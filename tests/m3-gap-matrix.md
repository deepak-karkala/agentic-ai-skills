# Milestone 3 Gap Matrix

Classifies all remaining product goals from the long-range plugin vision into M3, later, or out-of-scope. Produced by Phase 0 Task 1.

No vague buckets — every item maps to a concrete M3 task or an explicit deferral reason.

---

## M3: Implement (public-release blockers or high-value deferred capabilities)

### Skills

| Skill | Primary Source | M3 Task | Why M3 |
|---|---|---|---|
| `latency-and-cost-optimization` | T5.3, T5.4 | Task 8 | Dense production value; no equivalent in M2; top public-release gap |
| `agentic-security` | T5.2 | Task 9 | Agent-specific trust boundaries; eight-threat taxonomy; high public value |
| `incident-investigation` | T6.1, T5.1 | Task 10 | Post-launch failure reconstruction; no M2 skill covers this path |
| `hallucination-containment` | T4.2, T6.1 | Task 11 | Containment strategies; eval-design covers detection only, not mitigation |
| `human-in-the-loop-patterns` | T4.3 | Task 11b | T4.3 covers 5 distinct HITL models and risk-tiered approval gates beyond what deployment-readiness surfaces; promoted from Later |

### Subagents

| Subagent | Sponsoring Skill | M3 Task | Why M3 |
|---|---|---|---|
| `agent-reliability-engineer` | `hallucination-containment`, `incident-investigation` | Task 12 | Deep isolated reliability analysis; distinct from architecture and eval audit |
| `agent-cost-performance-analyst` | `latency-and-cost-optimization` | Task 13 | Cost/latency decomposition; distinct from observability or architecture review |
| `agent-artifact-designer` (re-evaluate) | multiple | Task 14 | Gate re-evaluation after M3 rendering evidence work; keep deferred unless gate is met |

### Evidence and Packaging

| Item | M3 Task | Why M3 (public-release blocker) |
|---|---|---|
| Rendered example outputs for all 5 artifact types | Task 4 | `examples/outputs/` is empty; no committed proof any template renders correctly |
| Artifact rendering verification scripts/fixtures | Task 5 | Validation checks template presence only; does not verify substitution or structure |
| Smoke-test evidence for Codex adapter | Task 6 | `adapters/codex.md` is prose only; no usage evidence committed |
| Smoke-test evidence for Gemini/ADK adapter | Task 6 | `adapters/gemini-adk.md` is prose + sample code; no end-to-end path demonstrated |
| OpenCode honest status decision | Task 7 | README/RELEASE/adapter files must all agree on exactly one status claim |

### Routing, Scenarios, Baselines

| Item | M3 Task | Why M3 |
|---|---|---|
| AGENTS.md + CLAUDE.md routing for 4 new skills and 2 subagents | Task 15 | Required before any M3 skill is usable |
| Worked scenarios for all 4 new M3 skills | Task 16 | Release confidence gate: every skill needs at least one scenario |
| Baseline comparison for M3-relevant workflows | Task 17 | Demonstrates M3 adds measurable value beyond M2 |

### Release Packaging

| Item | M3 Task | Why M3 |
|---|---|---|
| Extend `validate-plugin.sh` for M3 surfaces + output checks | Task 18 | Currently 133 checks; rendered-output evidence is not machine-checked |
| Convert `RELEASE.md` to true public-release gate | Task 19 | Current gate is milestone-only; needs evidence, adapter, and baseline sections |
| Refresh README and public docs | Task 20 | README must reflect M3 skills, adapters, and what works today |
| Cut public release candidate | Task 21 | Final packaging step |

---

## Later: Defer Beyond M3

| Capability | Primary Source | Reason for Deferral |
|---|---|---|
| `guardrails-and-fallbacks` | T4.2 | Seven-layer stack already surfaced via `deployment-readiness`; deeper skill adds breadth without fixing a public-release gap |
| `guardrails-and-fallbacks` | T4.2 | Seven-layer stack already surfaced via `deployment-readiness`; deeper skill adds breadth without fixing a public-release gap |
| `memory-patterns` | T1.3, T2.1 | Four-tier memory architecture substantially covered by `context-engineering-for-agents`; defer until usage evidence shows gap |
| `/agentic-discover` command | workflow | Discovery workflow is nice-to-have; no blocking user scenario identified |
| `/agentic-debug` command | workflow | Debugging support pathway; no evidence of demand at public release; superseded by `incident-investigation` for production failures |
| `/agentic-ship` command | — | Would require CI/CD integration scope beyond plugin thesis; deferred indefinitely |
| `agent-security-reviewer` subagent | T5.2 | `agentic-security` skill stays inline per M3 plan; delegation not needed unless security analysis exceeds ~500 tokens inline |

---

## Out of Scope: Reject

| Capability | Reason |
|---|---|
| `trace-error-analysis` | No source chapter; building from general knowledge only; does not meet source-backing standard |
| `agent-ui-patterns` | No source backing in technical or business strategy lane; outside agentic engineering thesis |
| Hosted SaaS, backend services | Outside plugin scope entirely |
| Cloud provider integrations (beyond adapter docs) | Not plugin content; vendor-specific; out of thesis |

---

## Summary

| Bucket | Count |
|---|---|
| M3: implement | 5 skills, 3 subagents (incl. re-evaluate), 5 evidence items, 3 routing/scenario items, 4 packaging items |
| Later: defer | 6 items |
| Out of scope: reject | 4 items |

No vague "improve quality" items remain. Every M3 item maps to one explicit task in `docs/milestone-3-implementation-plan.md`.
