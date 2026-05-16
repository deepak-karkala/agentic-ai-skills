---
name: hallucination-containment
description: >
  Designs containment strategies for hallucination failure modes in agentic
  AI systems. Identifies the hallucination mode (retrieval failure, reasoning
  failure, tool misuse, unsupported assertion) and selects the appropriate
  containment pattern from the seven-layer guardrail stack. Covers grounding
  and citation requirements, confidence thresholds and human review gates,
  action dry-run for tool misuse, refusal and fallback patterns, and
  verification layer design. Distinct from eval-design (which detects
  hallucination in a test suite) — this skill designs the runtime
  mitigation mechanisms that fire when hallucination occurs in production.
  Use when an agent is producing invented facts, fabricated tool calls,
  unsupported assertions, or actions without grounding; when designing
  the runtime containment layer before launch; when an agent workflow
  involves high-stakes outputs that cannot tolerate unsupported claims;
  or when a hallucination incident has been diagnosed and a containment
  fix is needed.
  Trigger phrases: "stop the agent from inventing facts", "agent is making
  up tool calls", "how do I contain hallucination in this workflow",
  "the agent asserts things it cannot verify", "design the verification
  layer for this agent", "hallucination in production", "agent confabulates
  results", "citation and grounding requirements", "how do I enforce
  I-don't-know behavior", "confidence threshold for agent actions".
  Do not use for hallucination detection in an eval suite (use
  agent-eval-design), for reducing hallucination risk via better context
  design (use context-engineering-for-agents — context design is upstream
  prevention; this skill owns runtime containment), or for general output
  quality improvement that is not specifically a hallucination issue.
allowed-tools:
  - Read
  - Write
metadata:
  category: technical
  version: "0.1.0"
---

# Hallucination Containment

Runtime reliability skill. Classifies the hallucination failure mode and designs containment patterns that fire in production when the agent produces unsupported outputs or actions. Produces a concrete containment design.

## When to Use

**Use when:**
- An agent is producing unsupported factual claims, invented tool calls, or actions without grounding
- Designing the runtime containment layer for a high-stakes agent workflow before launch
- A hallucination incident has been diagnosed and a containment fix is needed
- An agent workflow requires citation or grounding requirements enforced at runtime

**Do not use when:**
- The goal is to detect hallucination in an offline eval suite → use `agent-eval-design`
- The goal is to reduce hallucination risk by improving context quality, retrieval, or prompt design → use `context-engineering-for-agents` (upstream prevention)
- The issue is general output quality (wrong tone, incomplete answers) rather than specifically unsupported or fabricated content
- The agent system is being designed from scratch before any hallucination evidence exists (start with `agentic-system-design` + `agent-eval-design`)

## Workflow

### Step 1 — Gather context

Ask the user:
1. What is the specific hallucination behavior? (Invented facts, fabricated tool calls, unsupported recommendations, citation of non-existent sources, invented API responses, etc.)
2. What is the agent's architecture? (RAG pipeline, tool-using agent, reasoning agent, multi-agent?)
3. What is the output's downstream effect? (Shown to a user, triggers a tool call, written to a database, sent externally?)
4. What evidence exists? (Specific failed examples, frequency estimate, conditions under which it occurs?)
5. Is there already a retrieval layer? If so, what does it return when relevant documents are not found?

---

### Step 2 — Classify the hallucination mode

Four hallucination modes require different containment strategies. Classify which mode(s) apply.

**Mode 1 — Retrieval Failure:**
The agent asserts facts that should have come from retrieved documents, but the retrieval returned nothing relevant (empty result, low-similarity documents, or the agent ignored the retrieved content).
- Evidence: agent asserts specific facts; retrieved documents did not contain those facts; agent either fabricated them or confabulated from training data
- Trigger: "The knowledge base said X" when the KB returned no relevant result; confident assertions about domain-specific facts that vary across contexts

**Mode 2 — Reasoning Failure:**
The agent follows a plausible but incorrect chain of reasoning that leads to a false conclusion. The reasoning looks coherent but contains a logical error, an unjustified step, or a step that contradicts the context.
- Evidence: the agent's output is internally consistent but factually wrong; the error is in the inference, not the retrieval; the model cannot distinguish its confidence from its accuracy
- Trigger: multi-step reasoning chains with final conclusions that aren't directly supported by retrieved evidence; numeric calculations; date or version arithmetic

**Mode 3 — Tool Misuse:**
The agent invents tool calls, calls tools with fabricated arguments, or calls a tool that does not exist in its tool schema.
- Evidence: tool call arguments contain values not present in the context; the agent calls a tool with a plausible-sounding but nonexistent tool name; tool arguments are internally inconsistent
- Trigger: "used by X" or "call Y tool" when no such tool exists in the schema; arguments that are synthesis of context rather than direct extraction

**Mode 4 — Unsupported Assertion:**
The agent makes a confident claim about something outside its knowledge scope, without indicating uncertainty.
- Evidence: factual claims in domains not covered by the retrieval corpus; specific numbers, dates, or proper nouns that are not in the context; recommendations presented as certain when the basis is unclear
- Trigger: customer-facing agents giving policy information; agents answering regulatory or legal questions; agents recommending specific products or services

---

### Step 3 — Select containment patterns by mode

Apply containment patterns from the seven-layer guardrail stack. Match pattern to mode.

**For Mode 1 — Retrieval Failure:**

1. **Grounding check:** Before generating output, verify that each factual claim can be traced to a specific retrieved document. If not, the claim must not be made.
2. **Citation requirement:** Require the agent to cite the source document for every factual claim. If no source can be cited, the claim is not permitted.
3. **Retrieval retry with broadened query:** If retrieval returns empty or low-similarity results, retry with a broader query before treating the absence as evidence of nonexistence.
4. **"I don't know" enforcement:** Explicitly instruct the agent: "If the knowledge base does not contain information to answer this question, say 'I don't have information on that' rather than inferring from general knowledge."

**For Mode 2 — Reasoning Failure:**

1. **Chain-of-thought forcing:** Require the agent to show its reasoning steps before giving a conclusion. This slows hallucination because the agent must commit to intermediate steps that can be verified.
2. **Confidence threshold with human review gate:** Set a confidence threshold below which the agent's conclusion is routed to human review rather than acted upon. "If confidence < 0.8, flag for human review."
3. **Cross-check with a second model call:** For high-stakes reasoning conclusions, add a verification LLM call that independently evaluates the chain of reasoning. Agreement between the two calls increases confidence; disagreement triggers human review.
4. **Numeric and calculation guardrail:** For any numeric output (calculations, dates, financial figures), require the agent to show the calculation and verify the arithmetic. Do not allow confident numeric assertions without an explicit calculation trace.

**For Mode 3 — Tool Misuse:**

1. **Tool schema enforcement:** The LLM should only see tools in its schema that it is authorized to call. Remove tools not needed for the current task. An agent cannot call a tool that is not in its schema.
2. **Non-use examples in few-shot:** Add explicit few-shot examples showing the agent declining to call tools when the required arguments are not present in the context. Teach the refusal pattern explicitly.
3. **Permission scoping:** Ensure tool arguments are validated before execution. If the agent attempts to call a tool with arguments that cannot be verified against the context, return a validation error rather than executing.
4. **Dry-run before execute:** For irreversible tool calls, require the agent to generate a structured description of what it intends to do ("I would call [tool] with [arguments] — does this look correct?") before executing. This surfaces invented arguments before they cause harm.

**For Mode 4 — Unsupported Assertion:**

1. **Refusal pattern:** Explicitly instruct the agent to refuse questions outside its knowledge scope. "If you cannot answer from the provided documents, say 'I cannot confirm this from the available information.'" The refusal pattern must be in the system prompt and reinforced with few-shot examples.
2. **"I don't know" enforcement:** Same as Mode 1 — the agent must have an active permission to say it doesn't know. By default, language models are trained to generate a response; explicit permission to refuse is required.
3. **Hedging instruction:** Require the agent to use uncertainty qualifiers ("based on the available information," "as of my knowledge date") rather than unqualified assertions. Note: hedging alone is not sufficient containment for high-stakes domains — it must be paired with a refusal pattern.
4. **Verification layer:** Add an output verification step that checks whether each claim in the response can be grounded in the context. Claims that cannot be grounded are removed or replaced with a refusal.

---

### Step 4 — Design the verification layer

For high-stakes workflows (financial advice, medical information, legal guidance, safety-critical systems), add a verification layer that runs after the agent's response is generated and before it is delivered to the user or used to trigger tool calls.

**Verification layer design:**

1. **Input:** The agent's generated response and the context window content at response time
2. **Check:** For each factual claim or tool call argument in the response, is there direct evidence in the context?
3. **Pass:** The claim or argument is directly supported → deliver response
4. **Fail:** The claim or argument cannot be traced to context → replace with refusal or citation request
5. **Output:** Verified response with unsupported claims replaced

The verification step can be implemented as:
- A second LLM call that takes (original context, generated response) and returns a list of unsupported claims
- A deterministic rule check for specific claim types (citation check, tool argument validation)
- A human review gate for the most critical outputs

---

### Step 5 — Integrate with the seven-layer guardrail stack

Map the selected containment patterns to the appropriate guardrail layers:

| Guardrail layer | Containment patterns that live here |
|---|---|
| Layer 3 — Output filtering | Remove unsupported claims from output; citation check before delivery |
| Layer 5 — Verification and grounding | Verification layer (cross-check, grounding check, citation requirement) |
| Layer 6 — Human review gate | Confidence-threshold routing; verification failures → human review |
| Layer 7 — Fallback and refusal | "I don't know" enforcement; refusal pattern; graceful degradation |

---

### Step 6 — Write the containment design

Write a structured containment design to:
- `artifact_output_path/hallucination-containment-<agent-name>.md` if `artifact_output_path` is configured in `.agentic/config.yml`
- Otherwise: `.agentic/artifacts/hallucination-containment-<agent-name>.md`

Format:

```markdown
# Hallucination Containment Design: <Agent Name>

## Observed Hallucination Modes
[Modes identified with evidence]

## Containment Patterns Selected
[Per mode: pattern(s), implementation notes, priority]

## Verification Layer
[If applicable: input, check, pass/fail criteria, implementation approach]

## Guardrail Stack Integration
[Which layer each pattern lives in]

## Implementation Priority
[P1 — must have before production; P2 — add in next sprint; P3 — nice to have]

## Eval Gap
[The hallucination modes identified here must become eval fixtures — route to agent-eval-design]
```

---

### Step 7 — Report

After writing the containment design:
1. State the file path.
2. State the identified hallucination mode(s) with evidence.
3. State the selected containment patterns per mode.
4. Flag any high-stakes workflow that requires the verification layer.
5. State the eval gap: the hallucination patterns identified here should become golden test cases. Recommend `agent-eval-design` to add them to the eval suite.

## Output Contract

- **Primary output:** Containment design at `artifact_output_path/hallucination-containment-<agent-name>.md` or `.agentic/artifacts/hallucination-containment-<agent-name>.md`
- **In-conversation summary:** hallucination modes, selected containment patterns, verification layer design, eval gap
- **Does not produce:** eval golden test cases (route to `agent-eval-design`), context quality improvements (route to `context-engineering-for-agents`), general output quality improvements

## Scope Boundaries

This skill designs runtime containment — the mechanisms that fire in production when hallucination occurs. It does not detect hallucination in an eval suite (use `agent-eval-design`) or reduce hallucination risk via better context design and retrieval (use `context-engineering-for-agents`). The seven-layer guardrail stack is the framework; this skill selects and designs the specific guardrail configurations at layers 3, 5, 6, and 7 that address hallucination. A deployed guardrail stack configuration at the full-system level lives in `deployment-readiness`.
