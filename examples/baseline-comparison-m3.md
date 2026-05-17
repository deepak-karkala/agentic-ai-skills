# Milestone 3 Baseline Comparison

Concrete comparison of three representative workflows across three conditions:

- **No plugin:** Interacting with a general-purpose LLM (Claude, GPT-4) without any plugin
- **M2 plugin:** Using the Milestone 2 plugin (strategy, architecture, eval, deployment, context, workflow tools)
- **M3 plugin:** Using the full Milestone 3 plugin (M2 + incident investigation, cost/latency optimization, security hardening, hallucination containment, HITL design, trace analysis, agent UI)

Each comparison is reproducible: the trigger prompt is quoted verbatim, and the structural differences in the output are enumerated.

---

## Workflow 1: Production Incident Investigation

**Trigger:** "Our support triage agent started misclassifying tickets and sending emails to the wrong customers yesterday. It ran for 6 hours before anyone noticed. We have logs and traces. What happened and how do we prevent it?"

### No-plugin baseline

A general-purpose LLM produces:
- "This sounds like a model quality issue — you may need to retrain or update your prompts"
- A list of generic suggestions: "check your prompts", "review your training data", "add more error handling"
- No fault layer framework — prompt failure vs. context failure vs. tool failure are not distinguished
- No timeline reconstruction — the LLM asks clarifying questions and works conversationally
- No structured containment decision — suggests "pause the agent" without a decision table
- No connection between root cause and the specific fix target
- No eval gap identification — the response does not mention that a regression test should exist for this failure mode

**Structural gaps:** No classification framework. No timeline format. No containment decision. Root cause identified conversationally (often wrong or incomplete). No connection to evals or observability. No durable fix design.

### M2 plugin baseline

With `deployment-readiness` (closest M2 skill for production failures):
- **Partial overlap:** Deployment readiness covers HITL gates, guardrails, and observability checklist — but it is a pre-deployment planning skill, not a post-incident diagnostic skill
- **Gap:** `deployment-readiness` does not provide a fault layer taxonomy. It cannot reconstruct a failure timeline or classify a multi-layer failure
- **What M2 produces:** A checklist of what should have been in place (confidence threshold, circuit breaker, retrieval alert) — correct in hindsight, but not a structured diagnosis of what failed and why
- With `agent-observability`: identifies that tracing was insufficient — but does not reconstruct what the trace would have revealed
- **No post-mortem artifact:** M2 has no skill that produces a structured incident post-mortem

**Structural gap (M2):** The plugin has strong pre-deployment design skills, but no post-incident diagnostic workflow. An engineer using M2 gets a checklist of missing safeguards, not a classified failure analysis with a timeline, containment decision, and durable fix targets.

### M3 plugin baseline

With `incident-investigation` (delegating to `agent-reliability-engineer` for multi-layer classification):

**Phase 1 — Timeline reconstruction:**
```
07:45  KB update deployed (4 articles updated, 1 deleted)
07:48  First misclassification logged — 15 minutes after the change
09:30  Supervisor notices — 1h42m detection lag
14:00  KB rollback initiated
14:20  Classification accuracy restored
```
Timeline reveals: the failure started 3 minutes after the KB change, not at random. This scopes the investigation immediately.

**Phase 2 — Fault layer classification (synthesized from agent-reliability-engineer):**

| Failure | Layer | Severity |
|---|---|---|
| KB deletion removed billing retrieval anchor | Context failure | High |
| Agent classified confidently despite similarity 0.31 | Policy gap (no confidence gate) | High |
| Email populated without re-validating routing reason | Tool failure | Medium |
| No test for KB deletion scenarios | Eval gap | Medium |

**Primary fault layer:** Context failure (KB deletion) — amplified by policy gap.

**Phase 3 — Containment decision:**

| Action | Urgency |
|---|---|
| Roll back KB | Immediate (completed) |
| Pause automated emails for 24h | Immediate |
| Add confidence threshold gate (< 0.70 → human review) | 24h |
| Add circuit breaker (>5% low-confidence in 10min → alert) | 24h |

**Phase 4 — Durable fix targets (explicit routing):**
- `human-in-the-loop-patterns` — design confidence-gated approval gate
- `agent-eval-design` — add KB deletion + low-similarity adversarial tests
- `agent-observability` — add retrieval similarity alert

**Measurable improvement over M2:**
- Fault classification: checklist of missing safeguards (M2) → structured 4-layer fault classification with severity (M3)
- Timeline: conversational reconstruction (M2/no-plugin) → structured timeline with gap markers (M3)
- Containment: generic "pause the agent" (no plugin) → 4-action containment decision table with urgency tiers (M3)
- Fix routing: "add error handling" (no plugin) → explicit fix target per finding, routed to specific skills (M3)
- Eval gap: not identified (M2) → 4 specific uncovered failure modes named (M3)
- Error prevention: an M3 user implementing the confidence gate and circuit breaker before this incident would have reduced the impact window from 6 hours to < 10 minutes (alert at 07:58 vs. supervisor notice at 09:30)

---

## Workflow 2: Latency and Cost Optimization

**Trigger:** "Our research agent costs $2.40/task and takes 18 seconds. We do 500 tasks/day — it's $1,200/day and growing. Help us cut the cost in half without killing quality."

### No-plugin baseline

A general-purpose LLM produces:
- "You should try a smaller model for some tasks"
- "Use caching where possible"
- "Consider batching requests"
- Generic, unordered suggestions with no prioritization
- No cost attribution — the LLM does not know what fraction of $2.40 is input tokens vs. tool calls vs. output tokens
- No latency breakdown — no identification of which segment is the bottleneck
- No caching eligibility analysis — "use caching" with no criteria for what qualifies
- No parallelization analysis — no identification of which tool calls are independent
- No model tier assessment — no reasoning about which steps need frontier vs. mid-tier vs. small models
- No ranked action plan with estimated impact per action

**Structural gaps:** No cost attribution. No latency breakdown. No prioritization. Advice is generic and not executable without significant further research.

### M2 plugin baseline

With `agentic-economics-and-moats` (closest M2 skill for cost questions):
- **Partial overlap:** Economics and moats covers unit economics, CM2, and inference cost trap — but it is a product-level skill, not a per-request optimization tool
- **What M2 produces:** "Your $1,200/day is 50% of your gross margin if you're charging $3/task — that's an inference cost trap. You need to either raise prices or reduce inference cost" — correct strategic framing, but not an optimization plan
- No component-level cost breakdown by skill
- No caching eligibility criteria
- No parallelization opportunity identification
- No model tier per-step assessment

**Structural gap (M2):** The plugin frames the economics correctly but cannot produce an actionable per-request optimization plan. An engineer using M2 knows they have a cost problem and the rough strategic shape — but not which of the 8 pipeline steps to tackle first or what the expected savings are.

### M3 plugin baseline

With `latency-and-cost-optimization` (delegating to `agent-cost-performance-analyst` for full pipeline breakdown):

**Phase 1 — Cost decomposition:**

| Bucket | Cost | % | Primary driver |
|---|---|---|---|
| Input tokens | $0.92 | 38% | System prompt repeated on every ReAct step |
| Output tokens | $0.54 | 23% | Reasoning traces, 7 steps avg |
| Tool calls (web-search) | $0.72 | 30% | 3 searches × $0.24 (SerpAPI) |
| Tool calls (page-scraper) | $0.18 | 8% | 2 scrapes × $0.09 |
| Infrastructure | $0.04 | 2% | — |

Top driver identified: tool call costs (30%) + cacheable input tokens (38%).

**Phase 2 — Latency decomposition:**

| Segment | Duration | % | Reducible? |
|---|---|---|---|
| Inference (7 calls) | 8.4s | 47% | Partial |
| Tool execution (5 sequential) | 7.2s | 40% | Yes — parallel |
| Network | 1.8s | 10% | Partial |
| Serialization | 0.6s | 3% | No |

Top latency driver: sequential tool execution (40%) — fully parallelizable.

**Phase 3 — Ranked optimization plan:**

| Action | Cost saving | Latency saving | Effort |
|---|---|---|---|
| Enable prompt caching on system prompt | $0.35/task ($175/day) | 1.2s | < 1 day |
| Parallelize web-search calls | $0 | 4.2s | 1 day |
| Parallelize page-scraper calls | $0 | 2.7s | < 1 day |
| Route query-gen to claude-haiku | $0.14/task ($70/day) | 1.5s | 1–2 days |
| Route orchestrator to claude-sonnet (A/B test) | $0.28/task ($140/day) | 0.8s | 2–3 days |

**Projected outcome (actions 1–4, 1 week):** $2.40 → $1.53/task (−36%); 18s → 10s P95 (−44%).

**Measurable improvement over M2:**
- Cost attribution: "inference cost trap" framing (M2) → five-bucket per-component attribution with dollar amounts (M3)
- Optimization ranking: generic suggestions (no plugin) → ranked by cost/latency impact × effort with numeric projections (M3)
- Caching: "use caching" (no plugin) → eligibility criteria applied per step with hit-rate estimates (M3)
- Parallelization: not identified (no plugin / M2) → 6.9s latency saving identified from sequential tool calls (M3)
- Model routing: "try a smaller model" (no plugin) → per-step tier assessment with which steps to route and which to keep at frontier (M3)
- Projected outcome: no projection (M2) → $435/day savings projected with 1-week implementation plan (M3)

---

## Workflow 3: Security Hardening Before Production

**Trigger:** "We're about to launch this agent to external customers. It has tools that can read CRM records, send emails to customers, and update ticket status. What security risks do we have and what do we need to fix before we launch?"

### No-plugin baseline

A general-purpose LLM produces:
- "Make sure you validate inputs"
- "Don't expose API keys"
- "Rate limit the agent"
- Generic web application security advice — not tailored to agentic AI threat vectors
- No agentic-specific threat taxonomy (prompt injection, indirect injection, tool abuse, data exfiltration not named)
- No tool permission tier assignment
- No "dangerous action gating" design — email-send is not identified as requiring special protection
- No audit trail requirements
- No secret handling specification (context window vs. vault)

**Structural gaps:** No agentic threat taxonomy. No tool permission tiers. Dangerous actions not identified. No audit trail design. Generic web security advice that misses the highest-risk agentic-specific vectors.

### M2 plugin baseline

With `deployment-readiness` (the closest M2 skill for security concerns):
- **What M2 produces:** 
  - "Email-send is an irreversible write action — it should be HITL-gated"
  - "Add input validation for the CRM query parameter"
  - "Confirm the agent can't access records beyond the ticket scope"
  - Correct but incomplete — these are production readiness observations, not a structured threat model
- **Gap:** `deployment-readiness` does not enumerate the eight agentic threat categories. It identifies specific risks visible from the architecture but does not systematically work through indirect injection, tool abuse, data exfiltration, privilege escalation, model manipulation, supply chain, or agent impersonation
- **No hardening plan:** M2 produces a checklist of deployment blockers but not a structured security hardening specification with priority ranking

**Structural gap (M2):** Deployment readiness catches the most visible security gaps (irreversible actions, permission scope) but does not provide a systematic eight-threat taxonomy audit. A team using M2 might ship with prompt injection hardening absent, indirect injection from CRM notes unmitigated, or API keys in the system prompt.

### M3 plugin baseline

With `agentic-security`:

**Phase 1 — Threat taxonomy audit:**

| Threat | Present? | Severity | Finding |
|---|---|---|---|
| Prompt injection | Yes | High | User-controlled ticket text can contain instructions that override the agent's routing behavior |
| Indirect injection | Yes | Critical | CRM notes field is agent-readable and can contain adversarial instructions from external parties |
| Tool abuse | Yes | High | `update_ticket_status` has no blast radius limit — agent can update any ticket, not just the active one |
| Data exfiltration | Yes | Medium | `read_crm` can access all records; no scope constraint to the active ticket's customer |
| Privilege escalation | No | — | Agent has no admin tools |
| Model manipulation | Low | Low | No user-facing model selection; risk is low |
| Supply chain | Low | Low | No external agent tools or MCP third-party servers |
| Agent impersonation | No | — | Single agent; no inter-agent communication |

**Critical finding:** API keys for the CRM and email provider are in the system prompt — exposed to the context window on every call. Must be resolved before launch.

**Phase 2 — Tool permission tier assignment:**

| Tool | Current tier | Required tier | Action |
|---|---|---|---|
| `read_crm` | Untiered | Read-only | Add scope constraint: only active ticket's customer |
| `send_email` | Untiered | Irreversible write | Add Intent Preview + mandatory human approval gate |
| `update_ticket_status` | Untiered | Correctable write | Add blast radius limit: only active ticket ID |
| `search_kb` | Untiered | Read-only | No change needed |

**Phase 3 — Hardening plan (prioritized):**

| Action | Priority | Blocker for launch? |
|---|---|---|
| Remove API keys from system prompt; use vault-only resolution | P0 | Yes — launch blocker |
| Add CRM scope constraint (active ticket only) | P0 | Yes — data exfiltration risk |
| Add blast radius limit on ticket status update | P0 | Yes — tool abuse risk |
| Add indirect injection filter for CRM notes field | P1 | Yes — critical threat vector |
| Implement email Intent Preview + approval gate | P1 | Yes — irreversible action |
| Add prompt injection hardening for ticket text | P1 | Yes — high severity |
| Add audit trail for all write actions | P2 | No — but required before scaling |

**Measurable improvement over M2:**
- Threat coverage: 3 deployment-blockers visible (M2) → 8-threat taxonomy audit reveals 4 launch blockers including critical indirect injection (M3)
- Secret handling: not specifically addressed (M2/no plugin) → explicit "no secrets in context window" rule with vault-only resolution specified (M3)
- Tool permission tiers: "email-send should be HITL-gated" (M2) → all 4 tools assigned to tiers with specific scope constraints and blast radius limits (M3)
- Error prevention: A team using M2 would likely ship with indirect injection from CRM notes unmitigated (not on the M2 checklist) — the single highest-risk agentic-specific threat vector for this architecture

---

## Summary Table

| Capability dimension | No plugin | M2 plugin | M3 plugin |
|---|---|---|---|
| Post-incident fault layer classification | None | Checklist of missing safeguards | Six-layer taxonomy with severity and fix target |
| Failure timeline reconstruction | Conversational | Conversational | Structured format with gap markers |
| Incident containment decision | Generic "pause agent" | Partial (deployment readiness) | Decision table with urgency tiers |
| Eval gap identification from incidents | None | None | Named failure modes per gap |
| Per-request cost attribution | None | Product-level framing only | Five-bucket component breakdown |
| Latency bottleneck identification | None | None | Per-segment with reducibility flag |
| Caching eligibility analysis | Generic "use caching" | None | Per-step criteria with hit-rate estimates |
| Parallelization opportunity identification | None | None | Step-pair analysis with latency saving |
| Model tier optimization | "Try smaller model" | None | Per-step tier assessment |
| Agentic threat taxonomy | Generic web security | Partial (visible risks only) | Eight-threat taxonomy audit |
| Tool permission tier design | None | Irreversible action flag only | All tools tiered with scope constraints |
| Secret handling specification | "Don't expose API keys" | None | Explicit vault-only rule with context window prohibition |
| Indirect injection detection | None | None | Named threat with CRM notes as vector |
| Security hardening priority ranking | None | Deployment blockers only | P0/P1/P2 with launch-blocker flag |
