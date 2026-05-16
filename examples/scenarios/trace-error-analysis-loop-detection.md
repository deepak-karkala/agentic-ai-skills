# Scenario: Diagnosing a Reasoning Loop via Trace Analysis

## Trigger

> "Help me read this trace — the agent returned the wrong answer"
>
> "Our research agent was supposed to find the cheapest flight from NYC to London for next week and book it. Instead it made 23 tool calls over 4 minutes and then gave up with an error. I have the LangSmith trace. Which span caused this?"

## Skill: trace-error-analysis

### Inputs gathered

1. Agent: Travel Research Agent — ReAct loop; tools: flight-search, price-compare, calendar-check, booking-initiate
2. Bad output: "I was unable to complete the booking due to an error" — after 23 tool calls
3. Expected: return 3 flight options with prices, then book the cheapest with user confirmation
4. Trace source: LangSmith session export, 23 spans, ~4 minutes

### Step 2 — Backward-tracing diagnostic

Starting from the output span (span 23 — "unable to complete"):

```
Span 23: LLM output — "I was unable to complete the booking due to an error"
  ↑ what was in context? Review span 22 tool result
Span 22: flight-search — empty result [] (for query: "NYC to London 2026-05-23")
  ↑ why empty? Review span 21
Span 21: LLM call — generated flight-search query: "NYC to London 2026-05-23" [identical to span 19]
  ↑ first loop detected — span 21 and span 19 are identical
Span 19: flight-search — empty result []
  ↑ span 19 is a repeat of span 17...
```

**Loop identified at span 15–22:** The agent entered a loop calling flight-search with the same query 4 consecutive times. Each call returned an empty result. The agent did not recognize the empty result as a terminal condition — it retried the same query.

**Root cause span: Span 15 — first empty flight-search result**

The input to span 15 was correct (valid date, valid airports). The flight-search tool returned empty. The agent's response to an empty search result was to retry the identical query — it had no instruction for what to do when a search returns no results.

### Step 3 — Span-level error classification

Root cause span type: **Tool call span** (flight-search)

| Span characteristic | Value |
|---|---|
| Tool called | flight-search |
| Arguments | `{origin: "NYC", destination: "London", date: "2026-05-23"}` |
| Result | `[]` (empty array) |
| Error status | No error flag — returns empty array, not an error code |
| Subsequent behavior | LLM retried the identical call 4 times |

**Key finding:** The empty array is a silent failure — the tool did not return an error, so the agent did not trigger its error handling path. The agent was never told that "empty results = try a different strategy."

### Step 4 — Error taxonomy

**TRAIL taxonomy:** Planning failure → infinite loop (the agent looped without a termination signal)

**Six-bucket taxonomy:** Tool fault (secondary) + Reasoning fault (primary)
- Tool fault: empty result is a "soft failure" not communicated as an error to the agent
- Reasoning fault: the agent's retry logic was "call the same tool with the same arguments" — there was no broadening strategy in the prompt

**Canonical pattern:** Pattern 2 — Reasoning Loop

Trace signature matches exactly:
- Identical tool calls repeating (4× flight-search with same args)
- No progress between iterations
- Step-count circuit breaker not configured

### Step 5 — Replay hypothesis

**Replay strategy:** Prompt replay — modify the system prompt at the root cause span

Hypothesis: "If the agent had been instructed to: (1) try alternative date ranges when results are empty, (2) stop after 2 consecutive empty results and ask the user for flexibility, — the loop would not have occurred and the agent would have returned alternative options."

**Replay result (hypothetical):**
- Span 15: flight-search empty → agent tries ±2 days (2026-05-21 to 2026-05-25)
- Span 17: flight-search returns 8 results → agent proceeds with price comparison
- Final output: 3 flight options presented, cheapest selected for booking

### Step 6 — Secondary findings

**Span 7 — calendar-check:** Calendar check was called before any flight results were available. The agent was checking the user's calendar against a date before confirming flights exist for that date. This is a suboptimal ordering — not a root cause, but a trajectory quality issue.

**No step-count circuit breaker:** The agent ran 23 steps without hitting a safety limit. With no circuit breaker, a runaway loop could have run much longer (and cost much more). Recommend setting max_steps = 12 for this agent.

### Step 7 — Report

**Root cause span:** Span 15 — flight-search returning empty array with no error signal
**Failure class:** TRAIL Planning Failure (loop); six-bucket Reasoning Fault (no empty-result strategy); Pattern 2 (Reasoning Loop)
**Replay hypothesis:** Adding empty-result handling + a 2-failure escalation → ask user for flexibility would have resolved the loop and produced a valid output
**Fix target:** Update system prompt with: empty result handling strategy, alternative date range broadening, explicit termination after 2 consecutive failures; route to `tool-interface-design` to add a proper error return for empty search results (rather than silent empty array)

**Secondary findings:**
1. No step-count circuit breaker — add max_steps = 12; route to `agent-observability` to configure loop detection
2. Suboptimal ordering (calendar-check before flight availability) — minor trajectory quality issue; low priority
