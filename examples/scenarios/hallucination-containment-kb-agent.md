# Scenario: Containing Hallucination in a Knowledge-Base-Backed Support Agent

## Trigger

> "How do I stop this agent from inventing actions or facts?"
>
> "Our support KB agent is confidently telling customers incorrect information when the knowledge base doesn't have the answer. Instead of saying it doesn't know, it synthesizes a plausible-sounding policy response. We've also had two cases where it cited a knowledge base article that doesn't exist."

## Skill: hallucination-containment

### Inputs gathered

1. Agent: KB-backed support agent — reads from internal knowledge base, answers customer policy questions
2. Hallucination behaviors: (1) asserts specific policies not in KB; (2) cites non-existent article IDs
3. Architecture: RAG pipeline — query → kb-search → LLM response generation
4. Output effect: directly delivered to customer in live chat
5. Evidence: 4 confirmed incidents over past 2 weeks; estimated frequency: ~3–5% of queries where KB returns empty or low-similarity
6. Retrieval behavior: kb-search returns top-3 results by cosine similarity; returns empty array when no results exceed 0.5 threshold

### Step 2 — Hallucination mode classification

**Mode 1 — Retrieval Failure:** The primary mode.
- When kb-search returns empty or low-similarity results, the agent falls back to generating a response from training data
- Evidence: all confirmed hallucination incidents occurred on queries where the KB returned empty (retrieval score < 0.5)
- The agent was not instructed to refuse when retrieval fails — it was instructed to be helpful

**Mode 4 — Unsupported Assertion (secondary):**
- The fabricated article citations are a variant of unsupported assertion — the agent cites a source that does not exist
- This is the model pattern-matching on citation format rather than generating citations from actual retrieved content

### Step 3 — Containment patterns selected

**For Mode 1 (Retrieval Failure):**

1. **"I don't know" enforcement (P1 — required now)**
   Add to system prompt: "If the knowledge base search returns no results or results with similarity below 0.6, you MUST respond: 'I don't have information on that in our knowledge base. Let me connect you with a support agent who can help.' Do not synthesize an answer from general knowledge."
   Add 3 few-shot examples demonstrating the refusal pattern on empty retrieval.

2. **Retrieval result injection into prompt (P1 — required now)**
   The current implementation does not inject retrieval similarity scores into the prompt. The agent cannot distinguish between "KB returned a highly relevant document" and "KB returned a low-similarity fallback." Pass the similarity score alongside the retrieved content:
   ```
   [Retrieved: article #A-1042, similarity: 0.71] <content>
   [Retrieved: article #A-2018, similarity: 0.43] <content>
   [Note: similarity below 0.5 indicates the query may not be covered by the knowledge base]
   ```

3. **Grounding check before response (P2 — next sprint)**
   Add a verification step: before delivering the response, check that each specific claim in the response is grounded in one of the top-3 retrieved articles. Claims not traceable to a specific article are removed.

**For Mode 4 (Citation fabrication):**

4. **Citation format constraint (P1 — required now)**
   Restrict citation format: the agent may only cite articles using the exact article IDs from the retrieved results. Add to system prompt: "You may only cite articles that appear in the retrieved context above. Use the exact article ID as it appears. Never generate article IDs that are not in the retrieved context."

5. **Citation validation (P2 — next sprint)**
   After response generation, validate that every cited article ID in the response matches an article ID from the retrieved set. If a citation does not match, strip it from the response.

### Step 4 — Verification layer

**Recommended for this workflow (customer-facing, policy information):**

Input: generated response + retrieval context (top-3 articles + similarity scores)

Check:
1. Does the response contain any article citations? If yes, validate each citation against the retrieved set.
2. Does the response make any policy-specific claims (dates, amounts, terms)? If yes, verify each claim is present in a retrieved article.
3. Was retrieval empty (similarity < 0.5 for all results)? If yes, verify that the response uses the "I don't know" pattern.

Implementation approach: A second LLM call (cheaper model — claude-3-haiku is sufficient for this check) that receives (response, retrieved articles) and returns a structured validation result:
```json
{
  "unsupported_claims": ["claim text"],
  "fabricated_citations": ["article-id"],
  "retrieval_empty_but_answered": true/false
}
```
If any field is non-empty/non-false, replace the response with the refusal pattern.

### Step 5 — Guardrail stack integration

| Layer | Containment applied |
|---|---|
| Layer 5 — Verification and grounding | Grounding check (P2); citation validation (P2); retrieval score injection (P1) |
| Layer 6 — Human review gate | Route to human agent on empty retrieval + sensitive topic (billing, legal, cancellation) |
| Layer 7 — Fallback and refusal | "I don't know" enforcement (P1); citation format constraint (P1) |

### Eval gap

The four confirmed hallucination incidents must become golden test cases:
- 2 fixtures: query with empty retrieval → expected response uses "I don't know" pattern
- 2 fixtures: query with fabricated citation → expected response contains only valid article IDs
- Add eval dimension: Safety (hallucination sub-dimension) currently has 0 fixtures for empty-retrieval behavior

**Route to `agent-eval-design` to add these fixtures and define the grader for citation validity.**

### Output

**Containment design written to:** `.agentic/artifacts/hallucination-containment-kb-support-agent.md`

Summary:
- Primary mode: Retrieval Failure — agent synthesizes responses when KB returns empty
- Secondary mode: Unsupported Assertion — agent fabricates article citation IDs
- P1 actions: "I don't know" enforcement + retrieval score injection + citation format constraint
- P2 actions: verification layer (second LLM call checking groundedness and citation validity)
- Eval gap: 4 failing cases must be added as golden fixtures; route to `agent-eval-design`
