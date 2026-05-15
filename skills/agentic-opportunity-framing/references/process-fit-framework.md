# Process-Fit Framework

Reference for the `agentic-opportunity-framing` skill. Contains full trait definitions, scoring guidance, disqualifier details, and cost calibration notes.

---

## 7 Process-Fit Traits

### Trait 1 — Multi-step reasoning (not a lookup)

**Definition:** The workflow requires chaining multiple reasoning steps, not a single retrieval or classification. The agent must think through sub-problems to arrive at an answer.

**Positive examples:**
- Analyzing a customer complaint, identifying the root cause, checking account history, then drafting a resolution
- Reviewing a contract, identifying non-standard clauses, researching precedent, then summarizing risk

**Negative examples (fail this trait):**
- Looking up a customer's current plan tier
- Classifying a support ticket into one of five predefined categories
- Extracting structured fields from a standardized form

**Scoring guidance:** Score 1 if the workflow requires reasoning across more than two sub-problems that cannot be pre-specified as fixed steps.

---

### Trait 2 — Requires tool use or external information

**Definition:** The workflow requires accessing external systems, APIs, databases, or documents at reasoning time. The agent cannot complete the task from context alone.

**Positive examples:**
- Fetching live inventory levels to confirm fulfillment feasibility
- Querying a CRM before drafting a customer response
- Running a code interpreter to verify a calculation

**Negative examples:**
- Generating a summary from content already in the prompt
- Producing a plan based on requirements provided in the conversation

**Scoring guidance:** Score 1 if the workflow requires at least one external data source or action that cannot be provided in the context window upfront.

---

### Trait 3 — Judgment under uncertainty (not deterministic)

**Definition:** The correct output is not uniquely determined by a fixed rule set. The workflow involves ambiguity, tradeoffs, or edge cases where a decision must be made without a canonical answer.

**Positive examples:**
- Deciding whether a customer complaint warrants a refund based on context and history
- Prioritizing a queue of support tickets where urgency is inferred, not labeled
- Selecting the appropriate response tone based on customer sentiment

**Negative examples:**
- Routing a ticket based on keyword matching
- Approving a request that meets all predefined criteria
- Generating a standardized acknowledgment email

**Scoring guidance:** Score 1 if a rules engine with fixed logic would handle fewer than 80% of cases correctly.

---

### Trait 4 — High-value enough to justify inference cost

**Definition:** The value delivered per workflow execution justifies LLM inference cost. Agentic workflows typically cost 5–25x more than a simple API call — the task must be worth it.

**Cost calibration:**
- Simple chat completion (one turn): baseline cost unit
- Agentic workflow (multi-step, tool-calling): 5–25x baseline
- Supervisor-worker multi-agent: 15–50x baseline

**Positive examples:**
- Automating a task currently requiring 30+ minutes of human time
- Improving conversion on high-value sales decisions
- Reducing churn by improving response quality on escalations

**Negative examples:**
- Automating a task currently taking 2 minutes that requires high inference accuracy
- Replacing a free API call with a multi-step LLM workflow
- Adding AI reasoning to a workflow where a deterministic output is both possible and sufficient

**Scoring guidance:** Score 1 if the automation ROI is clear at realistic inference costs. If the unit economics are marginal, note it and recommend a cost analysis before proceeding.

---

### Trait 5 — Volume sufficient to amortize build cost

**Definition:** The workflow runs often enough that the investment in building, testing, and maintaining an agent is recovered quickly.

**Thresholds (rough guidance):**
- High-volume (1000+ runs/day): build cost amortizes quickly; strong signal
- Medium-volume (10–1000 runs/day): viable if value per run is high
- Low-volume (<10 runs/day): build cost rarely amortizes unless value per run is very high (e.g., $10K+ decisions)

**Scoring guidance:** Score 1 if volume × value per run justifies the build and maintenance overhead within 6–12 months.

---

### Trait 6 — Low enough stakes for acceptable error rate

**Definition:** The consequences of an agent error are proportionate to the intervention cost. The system can operate at a realistic error rate without causing disproportionate harm.

**Error-stakes calibration:**
- Low stakes / reversible (sending a draft email, surfacing a recommendation): high autonomy is fine
- Medium stakes / correctable (routing a ticket, generating a report): supervised autonomy is appropriate
- High stakes / irreversible (financial disbursement, medical action, legal filing): HITL gate required; autonomous operation only after extensive eval

**Scoring guidance:** Score 1 if the workflow can operate at a realistic LLM accuracy rate (90–95%) without catastrophic outcomes, OR if HITL is built in for the high-stakes actions.

---

### Trait 7 — Human verification feasible at proposed autonomy tier

**Definition:** At the autonomy level being considered, a human can meaningfully verify or correct the agent's outputs without the verification being prohibitively expensive.

**Autonomy tier reference:**
- L1 (assisted): Human makes all decisions; agent prepares materials. Verification is the human's normal workflow.
- L2 (supervised): Agent proposes; human approves. Verification cost = approval time per action.
- L3 (gated): Agent executes autonomously; human reviews on trigger (error, flag, sample). Verification = review cadence.
- L4/L5 (autonomous): Agent executes without per-action review. Verification = monitoring + periodic audit.

**Negative examples (fail this trait):**
- The proposed autonomy tier is L3/L4 but there is no monitoring infrastructure
- The verification task requires domain expertise that isn't available on the reviewing team
- The volume of outputs makes meaningful human review impossible

**Scoring guidance:** Score 1 if human oversight is operationally feasible at the proposed autonomy tier.

---

## Disqualifiers

These conditions override the score. If any apply, flag them before stating the recommendation.

| # | Disqualifier | Complete Block? | Possible Mitigation |
|---|---|---|---|
| D1 | Zero-tolerance error domain with no HITL path | Block unless HITL is added | Add approval gate; reframe as supervised assistant |
| D2 | No verifiable ground truth (cannot eval) | Block | Define evaluation criteria first; without eval, no safe autonomy expansion |
| D3 | Latency incompatible with multi-step reasoning | Block | Use simpler model or redesign workflow for offline/async execution |
| D4 | Required data not accessible at inference time | Block unless tool integration is added | Build tool integration; if not feasible, block |
| D5 | Regulatory prohibition on automated decision-making | Block or constrain | Reframe as decision support (L1/L2) rather than automation |

---

## Build/Don't-Build Filter Details

### Filter 1 — Handles genuine ambiguity

A workflow passes this filter if a rules engine with 100 rules would still miss more than 20% of real cases. If the team can enumerate all decision paths, it's not an agent — it's a pipeline.

**Test:** Ask: "Could this workflow be fully automated with if/then rules and no LLM?" If yes, an agent adds cost without proportional benefit.

---

### Filter 2 — Benefits from tool use

A workflow passes this filter if the agent needs to fetch, write, or act on external information that cannot be batched into the context window at invocation time.

**Test:** Ask: "If we gave the agent everything it needs in the prompt upfront, would the output quality be equivalent?" If yes, the workflow is a simple text transformation — a prompt, not an agent.

---

### Filter 3 — Value exceeds inference cost

**Cost calibration table:**

| Workflow type | Approximate cost per run (relative) | Minimum value needed |
|---|---|---|
| Single-agent, 3–5 tool calls | 5–10x baseline | Clear time/quality savings |
| Single-agent, 10+ tool calls | 10–20x baseline | Significant automation benefit |
| Supervisor + 2–3 workers | 20–40x baseline | High-value, high-frequency use case |
| Supervisor + 5+ workers | 40–80x baseline | Enterprise-tier value only |

If the workflow is high-volume but low-value per run, model fine-tuning or a simpler classifier may deliver better unit economics.

---

### Filter 4 — Failure is recoverable

A workflow passes this filter if at least one of the following is true:
- Errors can be caught before they propagate (HITL gate, validation step)
- Errors can be corrected after the fact without material harm
- The system can improve through eval-driven iteration (ground truth is capturable)

If none of these are true, the workflow is either not ready for automation or requires a different approach (human-in-the-loop decision support rather than autonomous execution).

---

## Compounding Error Math

| Steps | Per-step accuracy 99% | Per-step accuracy 95% | Per-step accuracy 90% |
|---|---|---|---|
| 3 | 97% | 86% | 73% |
| 5 | 95% | 77% | 59% |
| 7 | 93% | 70% | 48% |
| 10 | 90% | 60% | 35% |
| 15 | 86% | 46% | 21% |

**Key implication:** At 95% per-step accuracy — which is optimistic for most production LLM workflows — a 10-step agent succeeds end-to-end only 60% of the time.

**Mitigations:**
- Add HITL gates at high-risk steps to reset the compounding chain
- Reduce the number of autonomous steps (pipeline more; agent less)
- Invest in per-step evals to raise accuracy before expanding autonomy
- Use structured outputs and tool-call validation to catch errors early
