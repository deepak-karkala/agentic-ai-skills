# Milestone 3 Capability Sources

Maps each M3 skill and subagent to its source backing. Produced by Phase 0 Task 2.

Every promoted M3 capability has named source chapter support. No M3 capability is built from generic recollection alone.

---

## Source Chapter Index (M3-relevant)

| ID | Path | Key Concepts Used in M3 |
|---|---|---|
| T4.2 | `technical/module-4-quality-safety-oversight/ch2-guardrails` | Seven-layer guardrail stack; hallucination as guardrail failure mode; containment patterns |
| T4.3 | `technical/module-4-quality-safety-oversight/ch3-human-in-the-loop` | Five HITL models; risk-tiered oversight; approval gate design; bounded autonomy contracts |
| T4.5 | `technical/module-4-quality-safety-oversight/ch5-agent-ui-patterns` | Dual-panel architecture; Intent Preview; Autonomy Dial; AG-UI events; calibrated trust; confidence visualization; error recovery UX (new chapter, M3) |
| T5.1 | `technical/module-5-production-engineering/ch1-monitoring-observability` | MELT framework; trace replay for incident diagnosis; anomaly classification |
| T5.2 | `technical/module-5-production-engineering/ch2-security` | Eight-threat taxonomy; prompt injection; zero-trust agent design; capability scoping |
| T5.3 | `technical/module-5-production-engineering/ch3-cost-optimization` | Token budgets; model cascades; caching strategies; cost-per-task breakdown |
| T5.4 | `technical/module-5-production-engineering/ch4-latency-optimization` | Latency critical path; parallelization; streaming; profiling bottleneck identification |
| T6.1 | `technical/module-6-production-mastery/ch1-production-battle-scars` | Failure taxonomy; anti-patterns (context drift, abstraction traps); incident reconstruction |
| T6.3 | `technical/module-6-production-mastery/ch3-trace-error-analysis` | Backward-tracing RCA; TRAIL/MAST/AgentRx/fault taxonomies; span error patterns; replay strategies (new chapter, M3) |

---

## M3 Skill Source Map

### `latency-and-cost-optimization`

Primary sources:
- T5.3 — token budgets, model cascades, caching (semantic, KV, prompt), batching, cost-per-task formula
- T5.4 — latency critical path, parallelization of tool calls, streaming output, profiling breakdown by layer

Supporting sources:
- T5.1 — MELT visibility: cost and latency traces needed to drive optimization decisions
- T6.1 — production failure taxonomy: "cost explosion" and "latency cliff" anti-patterns

Key decision frameworks to extract:
- Cost driver identification (tokens vs tools vs model tier vs API overhead)
- Latency breakdown by layer (model inference / tool execution / serialization / network)
- Optimization action selection: caching → model routing → prompt compression → parallelization
- Tradeoff guidance: cost vs quality vs responsiveness across autonomy tiers
- When NOT to optimize (premature cost reduction that collapses quality)

Routing boundary:
- Not `context-engineering`: context compression is one lever; this skill owns the full optimization stack
- Not `agent-observability`: observability provides the data; this skill decides what to do with it
- Not `agentic-system-design`: architecture is already chosen; this skill tunes the running system

---

### `agentic-security`

Primary sources:
- T5.2 — eight-threat taxonomy (prompt injection, tool abuse, data exfiltration, privilege escalation, model manipulation, indirect injection, supply chain, agent impersonation), zero-trust design, capability scoping patterns

Supporting sources:
- T1.4 — tool permission tiers and ACI discipline (read-only / correctable / irreversible)
- T4.4 — principal hierarchy, transparency requirements, audit trail obligations

Key decision frameworks to extract:
- Eight-threat taxonomy with mitigation per threat
- Tool permission tier assignment (read-only / correctable write / irreversible write / admin)
- Prompt injection and indirect injection detection and containment
- Secret handling boundaries (no secrets in context window; vault-only access)
- Dangerous action gating: what requires human approval before execution
- Audit trail requirements by autonomy tier
- Zero-trust agent design: verify, not trust, on all inbound tool calls and agent handoffs

Routing boundary:
- Not `deployment-readiness`: deployment covers launch gates and guardrails stack; this skill owns agent-specific trust boundaries
- Not `tool-interface-design`: tool design covers schema and ACI ergonomics; this skill covers the security properties of those tools
- Not generic AppSec: agent-specific threats only (prompt injection, indirect injection, agent impersonation)

---

### `incident-investigation`

Primary sources:
- T6.1 — failure taxonomy (prompt failure / context failure / tool failure / orchestration failure / eval gap / policy gap), anti-patterns, incident reconstruction steps
- T5.1 — MELT traces as the primary evidence source for incident reconstruction

Supporting sources:
- T4.1 — eval gaps surfaced by incidents (what the eval suite failed to catch)
- T4.2 — guardrail failures that contributed to the incident

Key decision frameworks to extract:
- Failure timeline reconstruction from available trace + log evidence
- Contributing layer identification: is the fault in eval, observability, architecture, prompt, context, tool, or policy?
- Containment priority: what to do immediately vs after the incident
- Durable fix classification: does the fix go into eval, observability, architecture, or policy?
- Post-incident artifact: structured incident report linking fault layer to recommended fix

Routing boundary:
- Not `agent-observability`: observability is forward-looking instrumentation; this skill is backward-looking reconstruction from an existing failure
- Not `agent-eval-design`: eval design is pre-launch quality gates; this skill is post-failure analysis
- Not `deployment-readiness`: deployment is pre-launch posture; this skill handles post-launch failures
- Trigger: "this agent failed in production" or "investigate this incident" — not "help me debug my code"

---

### `hallucination-containment`

Primary sources:
- T4.2 — seven-layer guardrail stack: hallucination containment lives in layers 3 (output filtering), 5 (verification and grounding), and 7 (fallback and refusal)
- T6.1 — hallucination as a named failure mode in the production failure taxonomy; anti-patterns (unsupported assertions, invented tool calls)

Supporting sources:
- T4.1 — safety dimension of the six-dimension scorecard (detection, not containment; this skill owns the containment response)
- T2.2 — context design errors that cause hallucination (context rot, missing grounding, retrieval gap)

Key decision frameworks to extract:
- Hallucination mode classification: retrieval failure vs reasoning failure vs tool misuse vs unsupported assertion
- Containment pattern selection per mode:
  - Retrieval failure → grounding check, retrieval retry, citation requirement
  - Reasoning failure → chain-of-thought forcing, confidence threshold, human review gate
  - Tool misuse → non-use examples, permission scoping, action dry-run
  - Unsupported assertion → refusal pattern, "I don't know" enforcement, verification layer
- Confirmation, verification, fallback, and refusal pattern design
- Distinguishing hallucination containment from eval safety dimension (detection is eval; mitigation is this skill)

Routing boundary:
- Not `agent-eval-design`: eval covers detecting hallucination; this skill covers containing it once detected
- Not `context-engineering-for-agents`: context design can reduce hallucination risk; this skill owns the mitigation response when it occurs anyway
- Not `deployment-readiness`: deployment guardrails stack is a checklist; this skill designs the specific containment strategies

---

### `human-in-the-loop-patterns`

Primary sources:
- T4.3 — five HITL models (fully automated / human-on-standby / human-in-the-loop / human-over-the-loop / human-as-teacher), risk-tiered oversight, approval gate design, bounded autonomy contracts

Supporting sources:
- T4.4 — principal hierarchy and audit trail obligations (who approved what and when)
- T4.2 — guardrail stack layer 6 (human review gate as a guardrail layer)
- T5.5 — stateless/stateful deployment topology as context for HITL gate placement

Key decision frameworks to extract:
- Five HITL model selection by risk tier and action reversibility
- Approval gate design: what triggers a gate, what the gate must validate, what constitutes approval
- Bounded autonomy contract: explicit statement of what the agent can do without human approval
- HITL escalation ladder: when to escalate from lower to higher oversight
- Feedback loop design: how human approvals feed back into eval and trust calibration
- HITL at scale: approval bottleneck patterns and batch-approval strategies

Routing boundary:
- Not `deployment-readiness`: deployment covers HITL as one element of a launch gate checklist; this skill owns the full HITL design space and approval gate architecture
- Not `agentic-governance-and-adoption`: governance covers stakeholder policy and org adoption; this skill covers the technical and design patterns of the HITL layer
- Not `agent-eval-design`: eval tracks HITL outcomes as a metric; this skill designs the HITL mechanism itself
- Trigger: "design the HITL layer for this agent", "what approval gates do we need", "how should humans stay in the loop for this workflow"

---

### `trace-error-analysis`

Primary sources:
- T6.3 — backward-tracing RCA methodology, span error pattern reference, AgentRx framework, AgenTracer counterfactual replay, TRAIL/MAST/Agentic Fault Taxonomy reference, practitioner six-bucket taxonomy

Supporting sources:
- T5.1 — MELT traces as the evidence substrate for error analysis; session replay infrastructure
- T6.1 — production failure taxonomy (what classes of failure trace-error-analysis investigates)
- T4.1 — eval gaps surfaced by trace investigation (the durable fix target)

Key decision frameworks to extract:
- The diagnostic reading pattern (backward-tracing: root span → span tree → first divergence → root cause span)
- Span-level error classification matrix (which span types fail in which ways)
- Five canonical error patterns with trace signatures (tool failures, loops, context overflow, hallucination, cascading multi-agent)
- Root cause → durable fix mapping (which failure class maps to which skill for the fix)
- Replay strategies by failure type (prompt replay, retrieval replay, model replay)

Routing boundary:
- Not `agent-observability`: observability instruments the system forward-looking; this skill reads existing traces backward from a known failure
- Not `incident-investigation`: incident investigation determines fault layer and converts to fixes; this skill is the trace-reading technique used during that investigation (a supporting skill, invoked inline or as a reference)
- Not `deployment-readiness`: deployment is pre-launch; this skill is post-failure
- Trigger: "help me read this trace", "why did this agent fail", "which span caused this", "I have a trace and a bad output"

---

### `agent-ui-patterns`

Primary sources:
- T4.5 — full UI pattern library: Dual-Panel Architecture, Intent Preview, Autonomy Dial, Streaming Step Cards (AG-UI event model), Explainable Rationale, Audit Trail, Calibrated Trust, Confidence Visualization, Error Recovery UX, Component Vocabulary, Anti-Patterns, design system references

Supporting sources:
- T4.3 — HITL models that the Autonomy Dial and approval gate patterns implement at the UI layer
- T4.4 — trust and transparency principles that the explainability and confidence patterns surface
- T5.1 — trace/session replay as the backend for the Audit Trail and decision log UI components

Key decision frameworks to extract:
- Reversibility classification → pattern selection matrix (Intent Preview vs. Action Audit vs. silent execution)
- Dual-Panel Architecture: when and how to separate conversation from activity stream
- Autonomy Dial: three positions, granularity by task type, onboarding ramp
- AG-UI event taxonomy → UI state mapping (which backend event maps to which frontend component state)
- Calibrated trust: designing against both over-trust and active distrust
- Graceful degradation hierarchy (four levels with explicit user communication)
- Anti-pattern checklist (8 patterns to audit against)

Routing boundary:
- Not `human-in-the-loop-patterns`: HITL patterns cover the technical approval gate architecture; this skill covers how those gates are presented and experienced by users
- Not `agentic-governance-and-adoption`: governance covers org-level policy and trust; this skill covers product-level UI design
- Not `deployment-readiness`: deployment covers launch gates; this skill covers the ongoing user experience
- Trigger: "design the UI for this agent", "how should users interact with this agent", "what should the interface show while the agent is working", "how do we show uncertainty to users"

---

## M3 Subagent Source Map

### `agent-reliability-engineer`

Source coverage:
- T4.2 — guardrail failures and hallucination containment patterns
- T4.1 — safety dimension of the scorecard; reliability gap evidence
- T6.1 — failure taxonomy and incident classification

Bounded responsibility: isolated failure mode classification, hallucination containment recommendations, and reliability-focused review of eval, workflow, and runtime behavior. Returns structured reliability findings to parent skill.

Does not overlap with:
- `agent-evals-auditor` — auditor inspects eval coverage; reliability engineer diagnoses failure modes
- `agent-systems-architect` — architect reviews topology; reliability engineer reviews runtime behavior and containment

Delegation trigger: invoked from `hallucination-containment` or `incident-investigation` when analysis would exceed ~500 tokens inline or requires isolated evidence-gathering.

---

### `agent-cost-performance-analyst`

Source coverage:
- T5.3 — cost-per-task model, token budget analysis, caching effectiveness, model cascade decisions
- T5.4 — latency critical path, bottleneck profiling, parallelization opportunities

Bounded responsibility: latency/cost decomposition, bottleneck prioritization, optimization tradeoff synthesis. Returns structured findings with ranked recommendations to parent skill.

Does not overlap with:
- `agent-observability` — observability instruments the system; this subagent interprets cost/latency data
- `agent-systems-architect` — architecture is already decided; this subagent analyzes the running system

Delegation trigger: invoked from `latency-and-cost-optimization` when decomposition analysis would exceed ~500 tokens inline or cost profile requires isolated multi-layer investigation.

---

## Orphan Check

| M3 Skill / Subagent | Has Source? |
|---|---|
| `latency-and-cost-optimization` | Yes (T5.3, T5.4; supporting T5.1, T6.1) |
| `agentic-security` | Yes (T5.2; supporting T1.4, T4.4) |
| `incident-investigation` | Yes (T6.1, T5.1; supporting T4.1, T4.2) |
| `hallucination-containment` | Yes (T4.2, T6.1; supporting T4.1, T2.2) |
| `human-in-the-loop-patterns` | Yes (T4.3; supporting T4.2, T4.4, T5.5) |
| `trace-error-analysis` | Yes (T6.3; supporting T5.1, T6.1, T4.1) — new chapter written |
| `agent-ui-patterns` | Yes (T4.5; supporting T4.3, T4.4, T5.1) — new chapter written |
| `agent-reliability-engineer` | Yes (T4.2, T4.1, T6.1) |
| `agent-cost-performance-analyst` | Yes (T5.3, T5.4) |

No orphans. All M3 capabilities have named source chapter backing.
