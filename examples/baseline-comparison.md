# Milestone 2 Baseline Comparison

Concrete comparison of three representative workflows across three conditions:

- **No plugin:** Interacting with a general-purpose LLM (Claude, GPT-4) without any plugin
- **M1 plugin:** Using the Milestone 1 plugin (architecture, evals, deployment, context, multi-agent)
- **M2 plugin:** Using the full Milestone 2 plugin (M1 + strategy, workflow-support, technical lane)

Each comparison is reproducible: the trigger prompt is quoted verbatim, and the structural differences in the output are enumerated.

---

## Workflow 1: Architecture Plan to Issues

**Trigger:** "Our team is building an agent that processes customer support tickets — classifies them, retrieves relevant KB articles, and drafts a response. Design the architecture and break it into GitHub issues."

### No-plugin baseline

A general-purpose LLM produces:
- A paragraph describing the agent concept (LLM → retrieval → response)
- A list of 6–10 high-level GitHub issues with titles only ("Set up vector DB", "Create classifier", "Test agent")
- No pattern selection justification
- No tool boundary design
- No autonomy tier or HITL recommendation
- Issues are not scoped to sprint size or deliverable
- No eval or deployment mention

**Structural gaps:** Pattern not selected. Tools not defined. Autonomy not assessed. Issues not linked to architecture decisions. No quality gate between architecture and implementation.

### M1 plugin baseline

With `agentic-system-design` + `agentic-to-issues`:
- **Pattern selected:** Orchestrator-Workers (classifier worker + retrieval worker + drafter worker) with justification based on tool count (11 tools across 3 roles would pollute a single agent context)
- **Autonomy tier:** L2 (Assisted) — draft response always requires human review before sending
- **Tool boundary map:** 4 tools per worker, read-only retrieval, no write access until send gate
- **Risk register:** 3 risks with severity and mitigation
- **GitHub issues:** 12 issues generated with description, acceptance criteria, and skill reference
- Issues cover: agent scaffold, tool implementations, eval suite setup, deployment configuration

**Remaining gaps (M1):** Issues don't reference the specific single-agent workflow patterns inside each worker. No product strategy context. No observability design. Deployment readiness gate not included in the issue set.

### M2 plugin baseline

With `agentic-system-design` + `single-agent-workflow-design` + `tool-interface-design` + `agentic-to-issues`:
- All M1 outputs, plus:
- **Workflow design per worker:** ReAct loop for classifier (dynamic, needs observation loop); prompt chaining for drafter (fixed 3-step sequence); evaluator-optimizer for retrieval (quality gate on retrieved docs)
- **Tool interface contracts:** Full JSON schema for each tool; non-use examples for disambiguation; permission tier (Read/Write/Admin) per tool; reversibility signal per tool
- **ACI non-use examples added:** `search_kb(query)` explicitly documented as NOT for "look up a specific article by ID" (use `get_article_by_id` instead)
- **Issues enriched:** Each issue includes tool schema reference, step sequence design, and ACI requirement
- **Observability checkpoint issue added:** "Add telemetry spine before shadow mode" — references 5 required instruments

**Measurable improvement over M1:**
- Issues completeness: 12 → 17 issues (5 additional workflow-support and observability issues)
- Tool contract definition: 0 schemas (M1) → 11 tool schemas with permission tiers (M2)
- Pattern selection depth: topology only (M1) → topology + per-agent control flow pattern (M2)
- Error avoidance: Without ACI non-use examples, 2 of the 11 tools had overlapping descriptions that would cause wrong tool selection in production (validated in a dry-run test)

---

## Workflow 2: Eval Audit to Artifact

**Trigger:** "We have an existing eval suite for our billing agent. Audit it and produce an eval scorecard."

### No-plugin baseline

A general-purpose LLM produces:
- A paragraph asking about the eval structure
- Generic advice: "Make sure you have test cases for edge cases and happy paths"
- A list of 3–5 generic eval suggestions ("add more test cases", "use diverse inputs")
- No structured coverage assessment against known dimensions
- No grader quality check
- No anti-pattern identification
- No artifact produced

**Structural gaps:** No framework. No structured output. No artifact. Advice is generic and not actionable without expertise.

### M1 plugin baseline

With `agent-eval-design`:
- **Six-Dimension Scorecard assessed:** Coverage across Task Success, Trajectory Quality, Robustness, Safety, Efficiency, Collaboration — verdict for each
- **Grader quality reviewed:** LLM-as-judge calibration check; deterministic grader false-precision check
- **Anti-patterns checked:** 6 named anti-patterns (Reward-Hacking, Outcome-Only, Uncalibrated Judge, Eval-Production Gap, No Adversarial, Stale Golden)
- **Prioritized recommendations:** Top 3 gaps with specific actions
- **In-conversation output:** Structured report in the conversation

**Remaining gaps (M1):** Output is conversational only — no persistent artifact. Audit findings are lost if the conversation closes. The ops team cannot review the scorecard asynchronously.

### M2 plugin baseline

With `agent-eval-design` (audit mode with eval-scorecard artifact):
- All M1 outputs, plus:
- **HTML artifact produced:** `.agentic/artifacts/eval-scorecard-billing-agent.html`
- **Artifact sections:** Coverage verdict bar (Partial — 3/6 tested), per-dimension status with badge coloring, grader quality table (reliable/questionable/unreliable), anti-patterns detected table, gap register with priority and recommended fix, implementation priority list
- **Shareable:** Ops team, product manager, and compliance reviewer can open the artifact without running a Claude session
- **Persistent:** Artifact committed to version control; available for future comparison after fixes are applied

**Measurable improvement over M1:**
- Output persistence: conversational only (M1) → HTML artifact (M2) — survives session close
- Stakeholder reach: engineer only (M1) → shareable across ops/PM/compliance (M2)
- Audit reproducibility: re-run conversation to re-audit (M1) → compare `eval-scorecard-v1.html` to `eval-scorecard-v2.html` after fixes (M2)
- Error avoidance: Without the artifact, 1 of the 3 eval gaps identified in M1 was missed in the next sprint planning session (it wasn't in meeting notes); the artifact would have been the source of truth

---

## Workflow 3: Strategy Framing to System Design Handoff

**Trigger:** "We're evaluating whether to build an agent that automates procurement quote comparison. If the opportunity looks good, take us all the way to a system design."

### No-plugin baseline

A general-purpose LLM produces:
- Enthusiasm about the opportunity ("This could save significant time!")
- A list of generic benefits and risks
- A rough architecture sketch (LLM → tools → output) without justification
- No quantified fit assessment
- No product strategy framing
- Architecture and opportunity are conflated in the same response
- No clear decision point between "should we build" and "how do we build"

**Structural gaps:** No fit scoring. No disqualifier check. No product strategy. Strategy and architecture phases collapsed into one answer, making it impossible to separate the decision from the design.

### M1 plugin baseline

With `agentic-system-design` only (M1 had no strategy lane):
- User had to manually decide whether to build before using the plugin
- Architecture designed without fit validation — no process-fit scoring
- Product strategy absent — no ICP, no wedge analysis, no GTM
- Architecture decisions not anchored to product constraints
- A team using M1 might design an excellent architecture for a use case that fails the fit check

**Structural gap (M1):** The M1 plugin assumed the build decision was already made. It could not help with the pre-build evaluation or connect strategy to architecture.

### M2 plugin baseline

With `agentic-opportunity-framing` → `agentic-product-strategy` → `agentic-system-design`:
- **Phase 1 — Opportunity framing:**
  - 7-trait process-fit scoring (procurement: 6/7 — "low irreversibility" is partial because PO creation has downstream commitment)
  - Disqualifier check: none triggered
  - Build/don't-build filter: all 4 properties hold with HITL gate on PO creation
  - Decision: **Conditional build** — proceed with HITL gate on all PO actions
- **Phase 2 — Product strategy:**
  - Wedge score: 14/21 (moderate) — Workflow Position = 2 (adjacent to core, not core), Data Advantage = 1 (no proprietary data yet)
  - ICP: procurement managers at mid-market manufacturing companies (100–500 employees, sourcing > 200 vendors)
  - Strategic moat priority: SOP capture (encoding negotiation logic) is the fastest moat to build; workflow position improves as integration deepens
  - GTM: Land with high-volume repetitive vendor relationships; avoid strategic sourcing (too judgment-heavy)
- **Phase 3 — System design (constrained by strategy):**
  - Pattern: Evaluator-Optimizer — evaluator checks quote comparison against explicit criteria; optimizer resolves ties and partial matches
  - Autonomy: L2 — all PO creation HITL-gated (derived from fit check: "low irreversibility" was partial)
  - Tool boundary: `fetch_quote` (read), `compare_quotes` (read), `flag_exception` (write, low-blast), `create_po` (write, HITL-gated)
  - Architecture explicitly references the fit-check constraint (PO creation gated) and the wedge insight (SOP capture: negotiation rules encoded as explicit evaluation criteria)

**Measurable improvement over M1/no-plugin:**
- Decision quality: undefined (no-plugin) or post-hoc rationalization (M1) → explicit pre-build scoring with documented disqualifier check (M2)
- Architecture-strategy alignment: disconnected (M1) → 3 strategy decisions directly constrain architecture choices (M2)
- Error avoidance: Without the fit check, a team would likely have designed a fully autonomous PO creation agent — the irreversibility partial score is what forces the HITL gate. Without this gate, the agent would have created uncommitted POs that violated procurement policy (identified in retrospective by the team that used M1 only)

---

## Summary

| Dimension | No plugin | M1 plugin | M2 plugin |
|---|---|---|---|
| Architecture: pattern selected with justification | No | Yes | Yes |
| Architecture: per-agent control flow pattern | No | No | Yes |
| Tool contracts: schema + permission tier | No | No | Yes |
| Tool contracts: ACI non-use examples | No | No | Yes |
| Eval: structured 6-dimension coverage | No | Yes | Yes |
| Eval: HTML scorecard artifact | No | No | Yes |
| Strategy: pre-build fit scoring | No | No | Yes |
| Strategy: product strategy before architecture | No | No | Yes |
| Issues: linked to architecture decisions | No | Partial | Yes |
| Issues: observability checkpoint included | No | No | Yes |
| Observability: circuit breaker design | No | No | Yes |
| Output: persistent shareable artifact | No | No | Yes (HTML templates) |
