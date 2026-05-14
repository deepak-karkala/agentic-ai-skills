# Scenario: Long-Running Agent Losing Context

## Trigger

> "My research agent works great in short sessions, but after about 30 minutes or 20+ turns it starts referencing old search results that it already discarded, contradicting itself, and occasionally citing sources it made up. What's happening and how do I fix it?"

## Skill: context-engineering-for-agents

## Step 2 — Failure mode diagnosis

Symptom: quality degrades monotonically as session length increases; agent references old discarded content; contradictions appear mid-session; hallucinated citations.

**Diagnosis: Context Rot (primary) + Context Poisoning (secondary)**
- Context Rot: window is filling with accumulated stale search results; older results are never evicted
- Context Poisoning: hallucinated citations entered context early and were treated as fact by later turns

**Production rule applies:** Session > 30 min with monotonically degrading quality = suspect the context first.

## Step 3 — Memory tier assignments

| Data type | Current tier (broken) | Correct tier | Fix |
|---|---|---|---|
| Search results (all turns) | Working (never evicted) | Write → filesystem; keep path reference | Move >2K tool outputs out of context |
| Current research focus | Working | Working (keep) | Compact summaries only |
| Cited sources (accumulated) | Working (all inline) | Episodic (vector DB) | Store + retrieve by relevance, not accumulate |
| Research plan | Working | Procedural (restate every 10 turns) | Explicit plan restatement |

## Step 4 — Four pillars applied

**Write:**
- Any search result > 2K tokens → write to filesystem immediately; replace with file path + one-line summary in context
- Intermediate research notes → store as versioned files; keep only current draft in context

**Select:**
- Retrieve previously stored search results by semantic relevance to current question, not by recency
- Apply binary relevance pruning at each turn: drop sentences where > 50% of tokens are irrelevant to current research focus

**Compress:**
- Trigger compaction at 70% of context window (not 95%)
- Compaction cascade: (1) already stored? → replace with path; (2) can store now? → write to filesystem; (3) must stay? → summarize with explicit loss budget
- Rolling history: keep last 12 turns; compress older turns to summary blocks

**Isolate:**
- Split into subagent: deep search subagent returns compact structured findings (source, key claim, confidence, date) — parent agent never sees raw search transcripts

## Step 5 — Working Context Contract

```
System prompt (stable):              ~20% of window
Research plan (restated every 10t):  ~10% of window
Current draft / working notes:       ~20% of window
Retrieved prior findings (selective): ~15% of window
Conversation (rolling 12 turns):     ~25% of window
Buffer:                              ~10%
Compact trigger:                     70% full
Force compaction:                    90% full
```

## Output

**Root cause:** Search results were never evicted from context. At 20+ turns, the window contained all results from all prior searches, creating attention dilution and confusing old discarded paths with current active ones. Hallucinated citations entered early and went uncontested.

**Fix summary:**
1. Immediately evict tool outputs > 2K tokens to filesystem
2. Set rolling history to 12 turns with explicit compaction at 70%
3. Restate research plan every 10 turns
4. Isolate deep search into subagent with structured output contract (not raw transcript)

**Verification:** Monitor context hit rate (retrieved finding used in output), session quality trend, and cost/token per session. A falling cost/token with stable quality means compaction is working.
