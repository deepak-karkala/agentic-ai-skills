---
name: context-engineering-for-agents
description: >
  Designs the context and memory strategy for an agentic AI system.
  Covers the Write/Select/Compress/Isolate pillars, memory tier assignment,
  context failure mode detection, and subagent isolation heuristics.
  Use when designing context architecture for a new agent, diagnosing
  context rot or token budget issues in a running agent, designing memory
  for long-running tasks, deciding what belongs in-context vs. external
  storage, or fixing state drift across turns.
  Trigger phrases: "how should I manage context for this agent",
  "the agent keeps losing track of state", "context window is filling up",
  "how do I design memory for a long-running agent", "when should I use
  external memory vs in-context state", "the agent references outdated
  information", "compress or summarize context". Do not use for high-level
  architecture decisions (use agentic-system-design) or multi-agent
  topology design (use multi-agent-orchestration).
allowed-tools:
  - Read
  - Write
metadata:
  category: architecture
  version: "0.1.0"
---

# Context Engineering for Agents

Context and memory design skill for agentic AI systems. Diagnoses context problems, assigns data to the right memory tier, and applies the four engineering pillars to keep agents accurate and cost-efficient across long tasks.

## When to Use

**Use when:**
- Designing context architecture for a new agent
- The agent is losing track of state or referencing outdated information
- The context window is filling up and degrading quality
- Deciding what belongs in-context vs. external storage
- Designing memory for long-running or multi-session agents
- An agent working correctly in testing degrades over longer sessions
- Building subagent context isolation strategy

**Do not use when:**
- Top-level agent architecture decisions (tier, pattern, autonomy) → use `agentic-system-design`
- Multi-agent handoff contracts or topology → use `multi-agent-orchestration`
- Eval strategy → use `agent-eval-design`

## Workflow

### Step 1 — Gather inputs

Ask:
1. What is the agent doing, and how long does a typical task run (turns, duration)?
2. What types of data flow through the agent's context (tool outputs, retrieved docs, user history, policies)?
3. Are there observed quality problems? When do they occur in the task timeline?
4. What is the approximate context window size being used?
5. Is this a single-session agent or a multi-session agent that must remember across runs?

---

### Step 2 — Diagnose context failure mode

Check the task description and any observed symptoms against the **Context Failure Mode Taxonomy**:

| Failure mode | Diagnostic signal | Root cause |
|---|---|---|
| **Context Rot** | Quality degrades monotonically as task length increases | Window fills with stale, accumulated content |
| **Context Poisoning** | Agent makes confident false claims citing its own prior output | Hallucination entered context and was treated as fact |
| **Context Distraction** | Model references irrelevant earlier history; task drifts | Excessive irrelevant content overwhelms attention |
| **Context Confusion** | Wrong tool selected; schema violations; contradictory actions | Overlapping or ambiguous instructions/tool definitions |
| **Context Clash** | Inconsistent output; hedging where certainty expected | Contradictory instructions or facts in context |
| **Telephone Effect** | Sub-agent outputs drift; lead agent contradicts sub-agents | No structured handoff contracts; raw transcripts passed between agents |

**Production rule:** The longer the session, the more suspicious you should be of the context.

---

### Step 3 — Assign data to memory tiers

Map each data type in the agent's domain to the appropriate memory tier:

| Tier | What belongs here | Infrastructure | Key controls |
|---|---|---|---|
| **Working** | Active task state, current turn, plan, immediate tool outputs | Context window | Rolling buffer (12 turns max); compact at 70–80%; keep error evidence in |
| **Episodic** | Prior interactions, user/session history, past decisions and outcomes | Vector database with temporal metadata | TTLs required (90-day detailed, 12-month aggregated); scope per user/tenant; GDPR-compliant deletion |
| **Semantic** | Domain facts, policies, documentation, procedures | RAG / vector index | Freshness contract; citations required on retrieval; access-boundary enforcement |
| **Procedural** | Workflows, checklists, tool heuristics, stable plans | Prompt libraries / durable markdown files (SPEC.md, PLAN.md) | Version-control; stale procedures are worse than none |

**Memory governance — four required properties for any stored tier:**
- **Scoped:** Every record has an explicit access boundary (per-user, per-tenant, per-workflow)
- **Inspectable:** Stored content is readable and auditable by the team
- **Redactable:** Records can be deleted (required for GDPR Article 17 compliance)
- **Revisable:** Contradictions can be resolved; background consolidation for conflicts

---

### Step 4 — Apply the Four Pillars

For each data type identified in Step 3, apply the appropriate pillar:

**Write — Offload outside the window**

Move content out of the context window into external storage when:
- Tool output exceeds 2K tokens → write to filesystem, keep path reference in context
- Intermediate artifacts (drafts, plans, summaries) exist → store as files
- Content will be needed again but not in this turn → episodic or semantic store

**Select — Pull only what's needed**

Retrieve selectively:
- Use semantic retrieval (not bulk loading) for policies and domain knowledge
- Filter episodic memory by recency + relevance — do not dump all history
- Apply binary relevance pruning at context assembly: drop sentences where >50% of tokens are irrelevant to current task
- Apply AGENTS.md pattern for project-level context: include build steps, constraints, non-standard tooling; exclude architectural descriptions that don't change agent behavior

**Compress — Reduce token load proactively**

- Trigger compaction at **70–80% of the context window** — not at 95% (performance degrades at ~30K tokens in a 128K window before it fills)
- Compaction cascade decision order:
  1. Is the content stored externally? → replace with path reference
  2. Can it be stored externally now? → store to filesystem, keep reference
  3. Must remain in context? → summarize with explicit loss budget (state what was dropped)
- Use rolling history windows (max 12 turns by default)
- Restate the current goal and plan at the end of context every 10 turns in long-running tasks (attention management)

**Isolate — Split context to prevent explosion**

Use subagents or separate context windows when:
- A sub-task produces large intermediate outputs not needed by the main agent
- Different domains require incompatible tool sets (>10–15 tools causes attention dilution)
- Context from one sub-task should not pollute reasoning about another
- **Subagent isolation test:** "If I delegated this to a specialist and got back only the result, would the main agent still function correctly?" If yes, isolate.

When isolating into subagents, always define **handoff contracts** — structured output formats (not raw transcripts) that the parent agent can reliably parse.

---

### Step 5 — Define the Working Context Contract

Produce a token budget allocation for the agent's context window:

```
System prompt (stable, cache-pinned):  ~20% of window
Semantic retrieval (policies, docs):   ~15% of window
Conversation history (rolling):        ~25% of window
Working state (current task, plan):    Remaining
Soft trigger (compact):                70–80% full
Hard limit:                            90% full — force compaction or subagent delegation
```

**KV-cache rules** (10× cost difference if ignored):
- Do not put timestamps or session IDs in system prompts — breaks cache on every call
- Use deterministic JSON serialization (stable key ordering)
- Append to traces — never edit prior turns
- Mask tools rather than removing them to preserve cache coherence

---

### Step 6 — Address multi-session memory (if applicable)

If the agent must persist state across sessions, define:

1. What gets written to episodic memory: user preferences, explicit task outcomes, behavior-changing facts only — not every turn
2. TTL policy: 90-day for detailed history; 12-month for aggregated preferences; indefinite only for non-PII, explicitly flagged
3. Contradiction resolution policy: most-recent-wins, explicit-update-wins, or human review for high-stakes conflicts
4. Scope enforcement: every retrieval query filters by user/tenant/workflow scope — no exceptions

**Memory attack surface:** Treat all retrieved content as potentially adversarial. Retrieved instructions should not trigger memory writes. Validate write candidates against schema before storing.

---

### Step 7 — Produce the context design output

Produce a structured context plan:

1. **Failure mode diagnosis** (if symptoms were reported)
2. **Memory tier assignments** — each data type mapped to its tier with rationale
3. **Four-pillar application** — specific Write/Select/Compress/Isolate decisions
4. **Working Context Contract** — token budget table
5. **Multi-session design** (if applicable) — write policy, TTLs, scope rules
6. **Key risks** — top 2–3 risks with mitigations
7. **Verification** — how to detect if the design is working (context hit rate, session quality trend, cost/token trend)

## Output Format

Structured Markdown covering the seven sections above.

If the agent design is part of an architecture review (called from `agentic-system-design`), return the context design as the memory/context section of the architecture output.

## Scope Boundaries

This skill does not:
- Choose agent tiers, patterns, or reasoning paradigms → `agentic-system-design`
- Design multi-agent topologies or handoff contracts → `multi-agent-orchestration`
- Design full RAG infrastructure or vector database schemas — it defines what belongs in semantic memory; RAG implementation is the engineer's responsibility
- Design eval metrics for memory quality — it names what to verify; eval design is `agent-eval-design`
