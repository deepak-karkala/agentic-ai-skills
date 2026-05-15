---
name: agentic-to-issues
description: >
  Converts an agentic AI architecture plan, design doc, or review artifact
  into a structured implementation issue list. Separates work into epics,
  implementation tasks, eval work, and rollout tasks. Preserves dependencies
  and sequencing from the source design. Use after producing an architecture
  plan or review with agentic-system-design or agentic-arch-review, when
  the team is ready to break design into engineering work, or when an
  architecture plan needs to be handed to engineers or a planning tool.
  Trigger phrases: "break this into tickets", "convert this plan to issues",
  "turn this architecture into implementation tasks", "generate GitHub issues
  from this design", "slice this plan into work items", "what are the
  engineering tasks for this architecture". Do not use to produce
  architecture decisions (use agentic-system-design), to write eval plans
  (use agent-eval-design), or to summarize a system for handoff (use
  agentic-handoff).
allowed-tools:
  - Read
  - Write
metadata:
  category: workflow-support
  version: "0.1.0"
---

# Agentic To Issues

Plan-to-issues conversion skill. Translates an agentic AI architecture plan or review artifact into a structured, sequenced issue list — separating foundation work, implementation tasks, eval setup, and rollout into clearly bounded work items.

## When to Use

**Use when:**
- An architecture plan or review from `agentic-system-design` or `multi-agent-orchestration` is complete and the team is ready to implement
- A design doc exists and needs to be sliced into engineering tickets
- The user wants a Markdown-first issue checklist before (or instead of) pushing to a tracker
- Breaking down a multi-phase rollout into concrete, assignable tasks

**Do not use when:**
- Architecture decisions haven't been made yet → use `agentic-system-design` first
- The user wants an eval plan → use `agent-eval-design`
- The user wants to capture project state for handoff → use `agentic-handoff`
- The request is to re-explain the architecture, not decompose it into work

## Workflow

### Step 1 — Load the source plan

Check for input in this order:
1. A plan or artifact the user pastes or references in the current conversation.
2. Architecture docs at `design_docs_path` from `.agentic/config.yml`, if configured.
3. A direct description from the user.

Ask the user:
- What is the target implementation context (solo, small team, large team)?
- Are there known constraints — dependencies, deadlines, team boundaries, rollout gates?
- Should eval and rollout work be included, or implementation only?

---

### Step 2 — Identify work categories

Classify all work in the source plan into four categories:

| Category | Contains |
|---|---|
| **Foundation** | Infrastructure, scaffolding, shared interfaces, environment setup |
| **Implementation** | Core agent logic, tool integrations, orchestration, state management |
| **Eval** | Eval harness, graders, scorecard setup, regression fixtures |
| **Rollout** | Shadow mode, gated release, monitoring setup, approval gates, guardrail wiring |

---

### Step 3 — Decompose into thin vertical slices

Apply the thin-vertical-slice rule: each issue should deliver an independently testable increment of value rather than a horizontal layer.

Rules:
- Each implementation issue should include: what to build, done-when criteria, and at most one dependency.
- Foundation issues should be sequenced first; subsequent work must not block on unstarted foundation tasks.
- Eval issues should be paired with the implementation task they test, not batched at the end.
- Rollout issues should sequence shadow → gated → full with explicit gate criteria.

For sizing guidance and acceptance criteria patterns, see [Issue Templates](references/issue-templates.md).

---

### Step 4 — Sequence and label dependencies

For each issue:
1. Assign a phase label: `phase/foundation`, `phase/implementation`, `phase/eval`, `phase/rollout`
2. Note blockers: `blocked-by: <issue-title>` where one issue depends on another completing first
3. Flag cross-team dependencies if the user indicated team boundaries

---

### Step 5 — Produce the issue list

Write the issue list. Format as a Markdown checklist at minimum; see [Issue Templates](references/issue-templates.md) for the full structured format.

If the user wants GitHub-ready output, use the structured format with title, description, acceptance criteria, and labels. Otherwise the Markdown checklist is sufficient.

Default output location: write to `design_docs_path/issues.md` if `design_docs_path` is configured; otherwise present inline and offer to write to `docs/implementation-issues.md`.

---

### Step 6 — Report

After producing the issue list:
1. State the total count by category (foundation: N, implementation: N, eval: N, rollout: N).
2. Flag any issues with no clear done-when criteria — those need the team's input before work starts.
3. Flag cross-phase dependencies that could bottleneck delivery.
4. Suggest next step: start with foundation, or run `agentic-prototype` for a specific issue first.

## Output Contract

- **Primary output:** Structured Markdown issue list (checklist or GitHub-ready format)
- **In-conversation summary:** category counts, unresolved issues, recommended next step
- **Does not produce:** architecture decisions, code, eval plans, deployment guides

## Scope Boundaries

This skill slices work. It does not make architecture decisions. If decomposition reveals a design gap (e.g., an issue that cannot be clearly defined because the architecture is ambiguous), note it and suggest routing to `agentic-system-design` or `multi-agent-orchestration`.
