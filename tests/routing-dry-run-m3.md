# Routing Dry-Run: Milestone 3 Phase 2 Skills and Phase 3 Subagents

Manual routing test table for all seven M3 Phase 2 skills and the two M3 Phase 3 subagents. For each skill, documents obvious-trigger, paraphrase-trigger, and non-trigger cases. Boundary collisions against M1/M2 skills are noted where they exist.

For Milestone 1 and Milestone 2 routing tests, see the equivalent dry-runs in the same directory.

---

## How to use this table

For each test case, identify which skill should handle the request. Then verify:
1. The AGENTS.md routing table routes to the same skill.
2. The skill's `description` field contains trigger phrases that would match.
3. Non-trigger cases do NOT match the listed skill.

A **boundary collision** means two skills claim the same trigger. These cases are resolved by the tie-breaking rules in AGENTS.md and the M3 Phase 2 overlap-zone disambiguation table.

A **subagent delegation** case verifies that the parent skill delegates to the correct subagent under the stated condition.

---

## latency-and-cost-optimization

| Case type | Input | Expected skill | Notes |
|---|---|---|---|
| Obvious trigger | "How do I reduce the cost of this agent?" | `latency-and-cost-optimization` | Direct cost reduction question |
| Obvious trigger | "My agent is too slow — how do I optimize latency?" | `latency-and-cost-optimization` | Direct latency question |
| Obvious trigger | "Break down where my agent is spending tokens" | `latency-and-cost-optimization` | Token cost attribution |
| Paraphrase trigger | "We're spending $1.20 per task — is that normal and how do we get it down?" | `latency-and-cost-optimization` | Cost benchmarking framing |
| Paraphrase trigger | "The agent takes 12 seconds — users are complaining about latency" | `latency-and-cost-optimization` | User-facing latency problem |
| Paraphrase trigger | "Should we cache these prompts?" | `latency-and-cost-optimization` | Caching is a cost optimization lever |
| Non-trigger | "Will our pricing survive at scale?" | `agentic-economics-and-moats` | Product-level unit economics, not per-request optimization |
| Non-trigger | "What moat does our inference cost advantage give us?" | `agentic-economics-and-moats` | Moat depth scoring, not optimization |
| Non-trigger | "Design the architecture for a low-cost agent" | `agentic-system-design` | Architecture decision, not runtime optimization |
| Boundary | "Our margins are bad — is it inference cost or pricing?" | `agentic-economics-and-moats` first | Economics diagnosis precedes optimization; if it reveals a per-request problem, route to `latency-and-cost-optimization` after |
| Subagent delegation | "Break down the cost of every step in this pipeline with caching and parallelization recommendations" | `latency-and-cost-optimization` → `agent-cost-performance-analyst` | Detailed multi-component breakdown exceeds ~500 tokens inline; delegate |
| Subagent delegation (NOT) | "Should I cache this one prompt?" | `latency-and-cost-optimization` inline | Single-lever question; stay inline |

---

## agentic-security

| Case type | Input | Expected skill | Notes |
|---|---|---|---|
| Obvious trigger | "What security threats should I design against for this agent?" | `agentic-security` | Threat taxonomy question |
| Obvious trigger | "How do I prevent prompt injection in this agent?" | `agentic-security` | Specific threat mitigation |
| Obvious trigger | "How do I handle secrets in my agent's context?" | `agentic-security` | Secret handling — a security-first question |
| Paraphrase trigger | "What could go wrong from a security perspective?" | `agentic-security` | Security threat enumeration |
| Paraphrase trigger | "Can a user manipulate this agent into doing things it shouldn't?" | `agentic-security` | Adversarial input / prompt injection framing |
| Paraphrase trigger | "What permission level should this tool have?" | `agentic-security` | Tool permission tier question |
| Non-trigger | "Is this agent safe to deploy to production?" | `deployment-readiness` | Production gate — security is one input among many |
| Non-trigger | "What compliance requirements apply to this deployment?" | `agentic-governance-and-adoption` | Regulatory compliance is governance, not threat taxonomy |
| Non-trigger | "Design sandbox containment for this tool" | `deployment-readiness` | Runtime sandboxing is a production gate concern |
| Boundary | "What do we need before we can give this agent admin access?" | `agentic-security` first | Threat taxonomy and permission design precedes deployment gate assessment |

---

## incident-investigation

| Case type | Input | Expected skill | Notes |
|---|---|---|---|
| Obvious trigger | "An agent incident just happened — help me investigate" | `incident-investigation` | Post-incident investigation framing |
| Obvious trigger | "Run a post-mortem on this agent failure" | `incident-investigation` | Post-mortem is an incident skill |
| Obvious trigger | "We had a mass failure — which layer caused it?" | `incident-investigation` | Fault layer identification |
| Paraphrase trigger | "The agent went wrong in production yesterday — walk me through how to figure out what happened" | `incident-investigation` | Timeline reconstruction framing |
| Paraphrase trigger | "120 tickets were misrouted — what should I investigate first?" | `incident-investigation` | Scoped incident with impact |
| Non-trigger | "Help me read this trace — the agent returned the wrong answer" | `trace-error-analysis` | Trace diagnostic technique — not a post-mortem |
| Non-trigger | "Design the monitoring setup for this agent" | `agent-observability` | Proactive instrumentation design |
| Boundary | "The agent failed and I have a LangSmith trace — what went wrong?" | `trace-error-analysis` | Trace is available; diagnostic technique is trace-first; route to `incident-investigation` only if a broader post-mortem is needed |
| Subagent delegation | "We had a production failure — it touched the prompt, context, and tool layers; classify each failure mode and give me priorities" | `incident-investigation` → `agent-reliability-engineer` | Multi-layer failure classification exceeds ~500 tokens inline; delegate |
| Subagent delegation (NOT) | "The agent failed because the wrong routing rule triggered — what's the fix?" | `incident-investigation` inline | Single fault layer identified; stay inline |

---

## hallucination-containment

| Case type | Input | Expected skill | Notes |
|---|---|---|---|
| Obvious trigger | "My agent is making things up — how do I stop it?" | `hallucination-containment` | Core hallucination containment question |
| Obvious trigger | "Design a grounding check for this agent" | `hallucination-containment` | Containment pattern design |
| Obvious trigger | "How do I enforce 'I don't know' behavior?" | `hallucination-containment` | Refusal pattern |
| Paraphrase trigger | "The agent cites sources that don't exist" | `hallucination-containment` | Unsupported assertion mode |
| Paraphrase trigger | "The agent answers confidently when it shouldn't" | `hallucination-containment` | Over-confidence pattern |
| Paraphrase trigger | "Add citation requirements to this agent" | `hallucination-containment` | Citation requirement is a containment pattern |
| Non-trigger | "How often is the agent hallucinating?" | `agent-eval-design` | Measuring frequency — not designing containment |
| Non-trigger | "The agent's context window is overflowing and it's losing facts" | `context-engineering-for-agents` | Context management issue, not hallucination containment |
| Boundary | "Evaluate whether our grounding check is working" | `agent-eval-design` | Evaluating the containment mechanism — not designing it |
| Subagent delegation | "The agent is hallucinating in multiple ways — it fabricates citations, makes unsupported assertions, and misreads tool results; assess all active modes" | `hallucination-containment` → `agent-reliability-engineer` | Multiple active modes; classification would exceed ~500 tokens inline |
| Subagent delegation (NOT) | "The agent is making up citation IDs — how do I stop that?" | `hallucination-containment` inline | Single mode (unsupported assertion); stay inline |

---

## human-in-the-loop-patterns

| Case type | Input | Expected skill | Notes |
|---|---|---|---|
| Obvious trigger | "Design the approval gate for this agent action" | `human-in-the-loop-patterns` | Approval gate mechanism design |
| Obvious trigger | "What HITL model fits this use case?" | `human-in-the-loop-patterns` | HITL model selection |
| Obvious trigger | "Define the bounded autonomy contract for this agent" | `human-in-the-loop-patterns` | Autonomy contract |
| Paraphrase trigger | "When should the agent ask for human approval vs. proceed on its own?" | `human-in-the-loop-patterns` | Autonomy boundary question |
| Paraphrase trigger | "Design the escalation ladder for this workflow" | `human-in-the-loop-patterns` | Escalation ladder is a HITL pattern |
| Paraphrase trigger | "How do we route overrides back into our eval pipeline?" | `human-in-the-loop-patterns` | Human override feedback loop |
| Non-trigger | "Design the UI for the approval step — what does the reviewer see?" | `agent-ui-patterns` | UI layer, not gate mechanism |
| Non-trigger | "What governance policy should we require for AI decision-making?" | `agentic-governance-and-adoption` | Policy and org-level trust, not gate design |
| Non-trigger | "Is this agent ready to deploy with human-in-the-loop?" | `deployment-readiness` | Production gate — HITL design is an input, not the same skill |
| Boundary | "We want to add HITL to our agent — how?" | `human-in-the-loop-patterns` | Gate mechanism design; if the user then asks how it should look to reviewers, route to `agent-ui-patterns` |

---

## trace-error-analysis

| Case type | Input | Expected skill | Notes |
|---|---|---|---|
| Obvious trigger | "Help me read this trace — the agent returned the wrong answer" | `trace-error-analysis` | Classic trace diagnostic |
| Obvious trigger | "Which span caused this failure?" | `trace-error-analysis` | Span-level root cause |
| Obvious trigger | "I have a LangSmith trace and a bad output — walk me through it" | `trace-error-analysis` | Trace tool + bad output = this skill |
| Paraphrase trigger | "The agent looped 23 times — where in the trace did it go wrong?" | `trace-error-analysis` | Loop detection in a trace |
| Paraphrase trigger | "Which tool call went wrong?" | `trace-error-analysis` | Tool call span identification |
| Non-trigger | "Design the tracing strategy for this agent" | `agent-observability` | Forward instrumentation design, not backward reading |
| Non-trigger | "An incident just happened in production" | `incident-investigation` | Full post-mortem — use trace-error-analysis as a supporting technique within it |
| Non-trigger | "I don't have a trace — the agent just gave a bad answer" | `hallucination-containment` or `incident-investigation` | No trace available; this skill requires trace evidence |
| Boundary | "The agent failed and I have a trace and 200 affected tickets" | `incident-investigation` | Scale and impact framing suggests post-mortem; use trace-error-analysis within it |

---

## agent-ui-patterns

| Case type | Input | Expected skill | Notes |
|---|---|---|---|
| Obvious trigger | "Design the UI for this agent" | `agent-ui-patterns` | Direct UI design request |
| Obvious trigger | "What should the interface show while the agent is running?" | `agent-ui-patterns` | In-execution transparency |
| Obvious trigger | "Users are rubber-stamping the agent output — how do we fix that?" | `agent-ui-patterns` | Over-trust problem |
| Paraphrase trigger | "How do we make users trust the agent at the right level?" | `agent-ui-patterns` | Calibrated trust design |
| Paraphrase trigger | "Design the activity feed for this agent" | `agent-ui-patterns` | Activity stream / streaming step cards |
| Paraphrase trigger | "Show agent reasoning to users without overwhelming them" | `agent-ui-patterns` | Transparency and explainability design |
| Non-trigger | "Design the approval gate mechanism — what triggers it, what times out?" | `human-in-the-loop-patterns` | Gate mechanism, not UI layer |
| Non-trigger | "What governance policy do we need for human review?" | `agentic-governance-and-adoption` | Policy, not UI |
| Non-trigger | "Is our agent ready to deploy?" | `deployment-readiness` | Production gate |
| Boundary | "Design the UX for our agent — we want doctors to trust it" | `agent-ui-patterns` first | UI trust calibration; if it surfaces org-level trust questions, route to `agentic-governance-and-adoption` for policy framing |

---

## Subagent Delegation Dry-Run

### agent-reliability-engineer

| Case type | Input | Parent skill | Delegate? | Notes |
|---|---|---|---|---|
| Delegate | "The incident touched prompt failure, context drift, and a tool schema mismatch — classify all three layers, assess which hallucination modes are active, and identify eval gaps" | `incident-investigation` | Yes | Multi-layer, multi-mode analysis exceeds ~500 tokens inline |
| Delegate | "Multiple hallucination modes are active — retrieval failure, unsupported assertions, and reasoning errors — assess each and rank containment priorities" | `hallucination-containment` | Yes | Three active modes; classification inline would flood the conversation |
| Do not delegate | "The incident had a single cause: the wrong routing rule triggered" | `incident-investigation` | No | Single fault layer; stay inline |
| Do not delegate | "The agent is making up citation IDs — add a citation requirement" | `hallucination-containment` | No | Single mode identified; containment design is straightforward inline |
| Do not delegate | "Audit our eval suite — is our trajectory coverage adequate?" | `agent-eval-design` | Use `agent-evals-auditor` instead | Eval suite audit is eval auditor scope, not reliability engineer |

### agent-cost-performance-analyst

| Case type | Input | Parent skill | Delegate? | Notes |
|---|---|---|---|---|
| Delegate | "Break down the cost of every step in this 8-step pipeline: input tokens, tool calls, caching opportunities, and parallelization wins" | `latency-and-cost-optimization` | Yes | Full pipeline decomposition with four optimization dimensions; inline would exceed ~500 tokens |
| Delegate | "We're spending $0.85/task — attribute each dollar to a cost bucket and give me a ranked optimization plan" | `latency-and-cost-optimization` | Yes | Multi-bucket attribution with ranked plan |
| Do not delegate | "Should I cache the system prompt?" | `latency-and-cost-optimization` | No | Single-lever question; stay inline |
| Do not delegate | "Switch from Opus to Sonnet for classification steps — good idea?" | `latency-and-cost-optimization` | No | Single model-tier decision; stay inline |
| Do not delegate | "Will our margins survive at scale?" | `agentic-economics-and-moats` | N/A — wrong skill | Product economics, not per-request optimization |

---

## Boundary Collision Summary

| Request | Correct skill | Why not the other |
|---|---|---|
| "How do I reduce cost?" | `latency-and-cost-optimization` | `agentic-economics-and-moats` covers product margins, not per-request tuning |
| "Is this agent safe to deploy?" | `deployment-readiness` | `agentic-security` covers threat taxonomy — the gate is a readiness check |
| "Help me read this trace" | `trace-error-analysis` | `incident-investigation` is a full post-mortem — trace reading is a supporting technique |
| "Design the approval gate" | `human-in-the-loop-patterns` | `agent-ui-patterns` covers the UI layer — the gate mechanism is a separate design |
| "Design the UI for approvals" | `agent-ui-patterns` | `human-in-the-loop-patterns` covers trigger/audit/timeout — the UI is separate |
| "Users aren't trusting the agent" | `agent-ui-patterns` | `agentic-governance-and-adoption` covers org-level trust policy, not UI calibration |
| "Multiple hallucination modes" | `hallucination-containment` → `agent-reliability-engineer` | Multiple active modes trigger subagent delegation |
| "Full pipeline cost breakdown" | `latency-and-cost-optimization` → `agent-cost-performance-analyst` | Multi-bucket attribution triggers subagent delegation |
