---
name: trace-error-analysis
description: >
  Reads agent execution traces to diagnose a known failure. Uses the
  backward-tracing diagnostic pattern — starting from a bad output span
  and working backward through the span tree to find the root cause span.
  Covers five canonical error patterns with their trace signatures (tool
  call failures, reasoning loops, context overflow, hallucinations,
  cascading multi-agent errors); span-level error classification using
  the TRAIL taxonomy, MAST multi-agent failure modes, and the Agentic Fault
  Taxonomy; root cause analysis frameworks (AgentRx, AgentTrace causal
  graph, AgenTracer counterfactual replay); and replay strategies by
  failure type. Produces a root cause span, failure class, and fix target.
  A supporting diagnostic technique — used within incident-investigation
  and standalone when a trace is available and the failure span is unclear.
  Use when you have a trace from a failing agent session and need to identify
  which span caused the bad output, when a stack of LLM calls produced the
  wrong answer and the failure point is not obvious, when a multi-agent
  workflow produced a cascading error and you need to find the origin span,
  or when replaying a trace to test a hypothesis about the root cause.
  Trigger phrases: "help me read this trace", "why did this agent fail",
  "which span caused this", "I have a trace and a bad output",
  "walk me through this trace", "find the root cause span",
  "diagnose this agent failure from the trace", "trace replay",
  "which tool call went wrong", "analyze this LangSmith trace".
  Do not use for designing observability instrumentation (use
  agent-observability), for running a full incident post-mortem that
  includes fault layer identification and durable fix design (use
  incident-investigation — this skill is a technique used within that
  skill), or for debugging code-level bugs not related to agent behavior.
allowed-tools:
  - Read
  - Write
metadata:
  category: technical
  version: "0.1.0"
---

# Trace Error Analysis

Trace diagnostic skill. Reads agent execution traces backward from a bad output to identify the root cause span, classify the failure type, and recommend the target for the durable fix. Used standalone when a trace is available, or as a supporting technique within `incident-investigation`.

## When to Use

**Use when:**
- A trace from a failing agent session is available and the failure span is unclear
- A multi-agent workflow produced a wrong output and you need to find where in the span tree it went wrong
- A loop, hallucination, or tool failure is visible in the trace but the root cause span has not been identified
- Replaying a trace to test a hypothesis about what would have happened with a different input

**Do not use when:**
- The goal is to design the observability infrastructure that produced the trace → use `agent-observability`
- The goal is to run a full incident post-mortem including fault layer and durable fix → use `incident-investigation`
- There is no trace data available — this skill requires trace evidence

## Workflow

### Step 1 — Gather the trace

Ask the user to provide:
1. The trace export (from LangSmith, Langfuse, Arize Phoenix, W&B Weave, or other OTel-compatible backend)
2. The bad output: what was produced vs. what was expected
3. Any hypothesis the user already has about where the failure occurred

If the trace is in a file, read it. If the user pastes relevant span excerpts, work from those. If the trace is described verbally, work from the description but note the analysis is constrained by incomplete evidence.

---

### Step 2 — Apply the backward-tracing diagnostic pattern

**Reading pattern: start at the bad output, move backward.**

1. **Identify the output span:** Find the final span that produced the bad output. This is the observation point — not necessarily the cause.

2. **Read the span tree from the output span backward:**
   - What was the input to the LLM at the output span? Was the context correct at that point?
   - What retrieval or tool results fed into that context?
   - What was the parent span? Was the parent's output the correct input to this span?

3. **Find the first divergence from expected trajectory:**
   - At each span going backward, ask: was the behavior at this span correct given its inputs?
   - The first span where behavior was incorrect given correct inputs is the root cause span.
   - If a span's inputs were already wrong, keep going backward.

4. **Identify the root cause span:**
   - The span where the behavior was wrong AND the inputs to that span were correct
   - This span is where the fix must be applied

**Backward-tracing visualization:**

```
Output span (bad output observed here)
  ↑ was the context correct at input?
LLM reasoning span
  ↑ was the retrieval result correct?
Retrieval span (potential root cause)
  ↑ was the query correct?
Query generation span
```

Work backward until you find the first span where the input was correct but the output was wrong.

---

### Step 3 — Classify the failure using the span-level error matrix

Match the root cause span type to its common failure modes:

| Span type | Common failure modes | Trace signatures |
|---|---|---|
| LLM call span | Reasoning error, hallucination, prompt injection, context truncation | Finish reason = length; confidence discrepancy between consecutive calls; output contradicts context |
| Tool call span | Wrong arguments, schema mismatch, permission denied, timeout, silent error | Error status in result; result_size = 0 unexpectedly; latency spike; argument values not present in prior context |
| Retrieval span | Empty result, low similarity, wrong corpus, stale index | similarity_score < 0.5; doc_count = 0; retrieved docs don't match query semantics |
| Agent handoff span | Context loss, truncated handoff, trust violation | Receiving agent has smaller context than sender; critical fields missing in delegated task |
| Memory operation span | Stale recall, eviction of critical context, wrong tier retrieval | Memory hit but timestamp suggests stale content; incorrect memory tier used |
| Guardrail span | False positive block, missed violation, policy gap | Triggered on benign content; failed to trigger on violating content; latency spike from guardrail |

---

### Step 4 — Apply the error taxonomy

Classify the failure type using the appropriate taxonomy:

**TRAIL Taxonomy (20+ error types — select applicable):**
Key categories: Grounding failures (fabricated facts, ungrounded citations), Reasoning failures (flawed inference, incorrect calculation), Action failures (wrong tool, wrong arguments, unintended side effects), Context failures (overflow, drift, injection), Planning failures (wrong decomposition, infinite loop, premature termination)

**MAST Taxonomy (14 multi-agent failure modes — apply for multi-agent traces):**
Key categories: Communication failures (lost context at handoff, ambiguous delegation), Coordination failures (race condition, conflicting actions from parallel agents), Trust failures (impersonation, unauthorized escalation), Termination failures (loop without exit, deadlock)

**Agentic Fault Taxonomy (practitioner six-bucket):**
1. Input fault — bad input caused the failure (malformed query, adversarial input, unexpected format)
2. Retrieval fault — the retrieval layer returned wrong or missing information
3. Reasoning fault — the LLM made an incorrect inference over correct inputs
4. Tool fault — the tool call failed or returned incorrect results
5. Orchestration fault — the workflow sequencing or handoff was incorrect
6. Output fault — the final output was wrong despite correct intermediate steps

Apply the most specific taxonomy that fits. The taxonomy classification determines the fix target.

---

### Step 5 — Identify the five canonical error patterns

Match the trace to one of the five most common agent error patterns:

**Pattern 1 — Tool Call Failure Chain:**
A tool call fails (timeout, error, wrong result) and the agent continues without correctly handling the failure. The agent's subsequent reasoning is based on an invalid tool result.
- Trace signature: tool span shows error status; subsequent LLM span does not reference the error; output proceeds as if the tool succeeded
- Fix: add explicit error handling after tool calls; add a fallback path for tool failures

**Pattern 2 — Reasoning Loop:**
The agent enters a loop — calling the same tool or generating the same plan step repeatedly. Each iteration produces the same output, which the agent does not recognize as a termination signal.
- Trace signature: identical or near-identical spans repeating 3+ times; increasing step count without progress; loop breaker not firing
- Fix: add loop detection (consecutive identical calls = stop); define explicit termination conditions; add a step-count circuit breaker

**Pattern 3 — Context Overflow / Truncation:**
The context window fills up and critical information is truncated. The agent's output quality degrades silently — it does not signal that context was lost.
- Trace signature: finish_reason = "length" or total tokens near max_context; prompt token count spikes; later LLM calls reference less context detail than earlier ones
- Fix: context summarization for long sessions; sliding window strategy; reduce redundant context injection

**Pattern 4 — Hallucination (Grounding Failure):**
The agent generates output that is not grounded in the retrieved context or tool results. The output is plausible but unsupported.
- Trace signature: output contains specific claims; retrieved documents don't contain those claims; tool results don't contain the asserted values; LLM call span with high output token count relative to low retrieval similarity
- Fix: citation requirement; grounding check layer; "I don't know" enforcement; route to `hallucination-containment`

**Pattern 5 — Cascading Multi-Agent Error:**
In a multi-agent system, an error in one agent propagates to downstream agents that accept the incorrect output as ground truth and amplify the error.
- Trace signature: upstream agent span has suspicious output; downstream agent span uses that output without validation; the error in the final output cannot be explained by the downstream agent's own reasoning alone
- Fix: add validation at agent handoff boundaries; do not pass unverified outputs between agents; add a reconciliation step before critical downstream actions

---

### Step 6 — Apply replay strategy

After identifying the root cause span, verify the hypothesis with a replay:

**Replay type selection:**

| Root cause type | Replay strategy |
|---|---|
| Prompt or instruction error | Prompt replay — modify the prompt at the root cause span and re-run the session from that point |
| Retrieval failure | Retrieval replay — replace the retrieval result with the correct document and re-run from the retrieval span |
| Tool failure | Tool replay — provide the correct tool result manually and re-run from the tool call span |
| Model error on specific input | Model replay — run the same prompt through a different model or model version |
| Orchestration / handoff error | Session replay — re-run the full session with the corrected handoff context |

The goal of replay is to confirm: "if the root cause span had produced the correct output, would the final output have been correct?" If yes, the root cause is confirmed.

---

### Step 7 — Map root cause to fix target

| Root cause taxonomy | Fix target |
|---|---|
| Input fault | Update input validation; add golden test for this input pattern |
| Retrieval fault | Fix retrieval layer; update embedding quality; add retrieval eval fixtures |
| Reasoning fault | Update prompt; add chain-of-thought forcing; route to `hallucination-containment` |
| Tool fault | Fix tool implementation or schema; add tool integration test; route to `tool-interface-design` |
| Orchestration fault | Fix handoff contract; add boundary validation; route to `agentic-system-design` |
| Output fault | Add output verification layer; add golden fixture for this output type |

---

### Step 8 — Report the trace analysis

Report:
1. Root cause span: span type, span ID or position, what it produced vs. what was expected
2. Failure class: taxonomy category (TRAIL/MAST/six-bucket) and canonical error pattern (1–5)
3. Replay hypothesis: "If [root cause span] had returned [correct output], the final output would have been [expected output]"
4. Fix target skill: which skill owns the durable fix
5. Secondary findings: any other suspicious spans that should be investigated (even if not the primary root cause)

## Output Contract

- **Primary output:** In-conversation trace analysis report with root cause span, failure class, replay hypothesis, fix target
- **Secondary output (if requested):** Trace analysis written to `artifact_output_path/trace-analysis-<session-id>.md`
- **Does not produce:** full incident post-mortem, durable fix implementation, observability infrastructure design

## Scope Boundaries

This skill is a diagnostic technique — it reads traces backward to find the failure span. It does not design the observability infrastructure that captures the trace (use `agent-observability`), run the full incident investigation workflow that includes fault layer classification and durable fix design (use `incident-investigation`), or implement the fix (route to the appropriate target skill). When used within `incident-investigation`, this skill provides the trace-reading step — the parent skill owns the full incident lifecycle.
