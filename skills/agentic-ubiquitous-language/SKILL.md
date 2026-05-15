---
name: agentic-ubiquitous-language
description: >
  Establishes shared vocabulary for an agentic AI system. Normalizes
  overloaded terms, defines project-specific meanings, detects ambiguity,
  and produces a committed glossary artifact that downstream skills can
  reference. Use before designing or reviewing an agent system when more
  than one person or team is involved, when terms like "agent", "tool",
  "memory", "planner", or "handoff" are being used loosely, when domain
  terms conflict with common agentic AI terminology, or when a new engineer
  joins and needs the vocabulary of the system.
  Trigger phrases: "define our agent vocabulary", "what do we mean by X in
  this system", "normalize our terminology before we start", "we keep
  arguing about what a planner is", "write a glossary for this agent
  project", "what is a handoff in our context". Do not use for architecture
  decisions (use agentic-system-design), for general "what is an agent"
  questions with no project-specific context, or for eval design.
allowed-tools:
  - Read
  - Write
metadata:
  category: workflow-support
  version: "0.1.0"
---

# Agentic Ubiquitous Language

Terminology hardening skill. Produces a shared glossary for an agentic AI system before specification drift causes misalignment across the team or between phases of development.

## When to Use

**Use when:**
- Starting design work with multiple engineers or stakeholders
- Terms like "agent", "tool", "memory", "planner", "worker", or "handoff" are used inconsistently across the team
- Domain-specific terms conflict with standard agentic AI vocabulary
- A new engineer or team is taking over an existing agent system
- An architecture review found ambiguous terms in the design docs

**Do not use when:**
- The user wants architecture recommendations → use `agentic-system-design`
- The question is general ("what is an agent?") with no project context — answer directly
- The user wants eval strategy → use `agent-eval-design`

## Workflow

### Step 1 — Gather context

Ask the user:
1. What is the agent system called and what does it do in one sentence?
2. Which terms feel most contested or ambiguous on your team right now?
3. Do you have an existing glossary or terminology doc? (If yes, read `glossary_path` from `.agentic/config.yml` if configured.)
4. Are there domain terms from your industry (e.g., "ticket", "case", "claim", "order") that overlap with agentic AI vocabulary?

If `glossary_path` is configured and the file exists, read it. Use existing definitions as the baseline and extend rather than replace.

---

### Step 2 — Extract candidate terms

From the system description and any existing docs, identify:
- **Standard agentic terms** in use: agent, tool, memory, context, planner, orchestrator, worker, handoff, trace, session, task, goal
- **System-specific terms**: names of components, workflows, states, or roles unique to this project
- **Domain terms** that overlap with agentic vocabulary: any word that means something different in the domain vs. in agentic AI

For each candidate term, note whether it is: unambiguous, contested, or overloaded (has multiple meanings in different contexts).

---

### Step 3 — Normalize standard vocabulary

For each standard agentic term in use, confirm the canonical definition against the standard vocabulary reference, then check whether the team's usage matches, extends, or conflicts.

See [Standard Agentic Vocabulary](references/standard-agentic-vocabulary.md) for canonical definitions and common overloads.

Resolution rules:
- If team usage matches canonical: accept as-is and document it.
- If team usage extends canonical (narrower, project-specific): document both the canonical base and the project-specific extension.
- If team usage conflicts with canonical: flag it. Propose either adopting the canonical term or creating a project-specific alias with a clear non-example.

---

### Step 4 — Define project-specific terms

For each domain or system-specific term:
1. Write a one-sentence definition scoped to this project.
2. Write a non-example: what this term is NOT in this system.
3. Note any related terms or known confusion pairs.

---

### Step 5 — Flag ambiguities and overloads

Identify terms that:
- Mean different things in different parts of the codebase or team
- Are used interchangeably with another term but shouldn't be
- Have a technical meaning that conflicts with the team's intuitive meaning

For each ambiguity, propose a resolution: adopt one meaning, split into two distinct terms, or create an explicit alias.

---

### Step 6 — Produce the glossary artifact

Write the glossary to the path from `glossary_path` in `.agentic/config.yml`. If absent, write to `.agentic/artifacts/agentic-glossary.md` and note the path to the user.

Use the artifact format:

```markdown
# Agentic AI Glossary — [System Name]

## [Term]
**Definition:** One sentence, scoped to this project.
**Canonical base:** [Standard agentic meaning, if this term extends a canonical one]
**Non-example:** What this term is NOT in this system.
**Related terms:** [comma-separated list of related or easily confused terms]
**Flags:** [overloaded | contested | domain-conflict] — omit if unambiguous
```

---

### Step 7 — Report and recommend

After writing the glossary:
1. List the terms defined (count).
2. Call out any unresolved ambiguities that the team should decide before design work proceeds.
3. Suggest which downstream skill to run next (`agentic-system-design`, `agentic-to-issues`, or `agentic-handoff`).

## Output Contract

- **Primary output:** Committed glossary Markdown file at `glossary_path` or `.agentic/artifacts/agentic-glossary.md`
- **In-conversation summary:** term count, unresolved flags, recommended next step
- **Does not produce:** architecture recommendations, eval plans, code

## Scope Boundaries

This skill defines vocabulary. It does not make architecture or design decisions. If a terminology discussion reveals a genuine architecture question (e.g., "we can't agree because our planner is doing two different jobs"), note it and suggest routing to `agentic-system-design`.
