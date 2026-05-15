# Scenario: Designing the Control Loop for a Document Processing Agent

## Trigger

> "Design the control loop for this single-agent workflow."
>
> "We have a single-agent system that processes vendor contracts. It needs to: extract key fields, classify contract type, flag non-standard clauses, and summarize risk. The steps are fixed but we're not sure how to structure the gates and retry logic."

## Skill: single-agent-workflow-design

### Inputs gathered

1. Workflow: Receive contract PDF → extract fields → classify type → flag non-standard clauses → summarize risk → output structured report
2. Steps: Fixed and known in advance (all steps enumerable before start)
3. Failure handling: If extraction fails, flag for human review; partial results are acceptable
4. Tools: `extract_pdf_text`, `classify_contract_type`, `search_clause_library`
5. Constraints: Target < 30 seconds end-to-end; cost < $0.10/document

### Step 2 — Pattern selected

**Prompt Chaining** — all steps are known before the workflow starts; each step's output feeds the next; quality at each step can be validated programmatically.

**Rejected alternatives:**
- Routing: Input is always a vendor contract — no meaningful routing needed
- ReAct loop: Steps are fixed; open-ended adaptation is not required and would add unnecessary cost

### Step 3 — Step sequence

| Step | Type | LLM? | Tool? | Gate condition | On fail |
|---|---|---|---|---|---|
| 1. Receive and validate | Input | No | No | PDF is parseable, text is non-empty | Abort with "invalid document" error |
| 2. Extract text | Processing | No | `extract_pdf_text` | Text length > 100 chars | Abort — cannot proceed without text |
| 3. Extract key fields | Processing | Yes | No | Output is valid JSON with required fields: parties, dates, value | Retry with schema + error (max 2) → escalate |
| 4. Schema gate | Gate | No | No | JSON schema validation | Retry Step 3 with correction prompt |
| 5. Classify contract type | Processing | Yes | `search_clause_library` | Classification is in known_types enum | Default to "UNKNOWN" — do not retry |
| 6. Flag non-standard clauses | Processing | Yes | `search_clause_library` | Flags are array of {clause, reason, severity} | Retry with schema (max 1) → return empty array |
| 7. Content gate | Gate | No | No | Severity enum values are valid | Normalize to "MEDIUM" if invalid |
| 8. Summarize risk | Processing | Yes | No | Summary is non-empty string, ≤ 500 words | Retry (max 1) → return truncated partial |
| 9. Format output | Output | No | No | Required fields present | Escalate — final step should not fail |

### Step 4 — Gate logic

| Gate | Validates | Method | On fail |
|---|---|---|---|
| Schema gate (Step 4) | Output is valid JSON with parties, dates, value | JSON schema validator | Retry Step 3: inject schema + error description + "do not include prose outside the JSON" |
| Content gate (Step 7) | Severity values are in [LOW, MEDIUM, HIGH, CRITICAL] | Enum membership check | Normalize to MEDIUM; log for review |

**Deterministic gates only** — no LLM-as-judge needed here; schema and enum validation are sufficient.

### Step 5 — Retry and recovery

| Failure | Recovery | Max retries | Escalation |
|---|---|---|---|
| Step 3 (extract fields) — malformed JSON | Inject schema + error message | 2 | Human review with raw PDF |
| Step 5 (classify) — unknown type | Default to UNKNOWN, continue | 0 | — (graceful degradation) |
| Step 6 (flag clauses) — malformed output | Retry with simplified prompt | 1 | Return empty flags array |
| Step 8 (summarize) — empty output | Retry once | 1 | Return "Summary unavailable — manual review required" |
| `extract_pdf_text` fails | Abort immediately | 0 | Human review |
| `search_clause_library` unavailable | Return UNKNOWN for classification, empty for flags | 0 | — (graceful degradation) |

**Design principle applied:** Tool failures degrade gracefully (unknown type, empty flags) rather than blocking the pipeline. Only field extraction failure aborts — the output is meaningless without it.

### Step 6 — Termination conditions

1. **Success:** Output report is formatted and validated at Step 9
2. **Abort:** PDF is unparseable (Step 1) or text extraction fails (Step 2)
3. **Partial success:** Any processing step exhausts retries → return partial report with flags indicating which sections require human review
4. **Cost limit:** If cost exceeds $0.10/document (approximately 12K tokens total), suspend and return state snapshot

### Workflow design document

`.agentic/artifacts/workflow-contract-processor.md`

```
Pattern: Prompt Chaining
Steps: 9 (4 processing, 2 gates, 2 input/output, 1 tool-only)

Unvalidated failure points: None — gates after every LLM call.

Graceful degradation design:
- Classification failure → UNKNOWN (not abort)
- Clause flagging failure → empty array (not abort)
- Summary failure → human-review flag (not abort)
- Only field extraction failure → abort (output meaningless without it)

Termination: Success, Abort (Step 1–2), Partial (Step 3–8), Cost limit

Next steps:
- /tool-interface-design to write contracts for extract_pdf_text 
  and search_clause_library
- /agentic-prototype to generate a prompt-chaining scaffold for this pattern
```
