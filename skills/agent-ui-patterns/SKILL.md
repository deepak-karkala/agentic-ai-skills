---
name: agent-ui-patterns
description: >
  Designs the user interface architecture for an agentic AI system.
  Covers the full agent UI lifecycle: pre-execution transparency
  (Intent Preview for irreversible actions), in-execution feedback
  (Dual-Panel Architecture, Streaming Step Cards, AG-UI event model),
  and post-execution review (Audit Trail, decision log). Covers the
  Autonomy Dial pattern for user control at different trust levels,
  Calibrated Trust design (preventing both over-trust and active distrust),
  Confidence Visualization for communicating uncertainty, Transparency
  and Explainability components (inline rationale, cited sources, decision
  summary), Error and Recovery UX (graceful degradation hierarchy, three-
  part error message), and the eight agent UI anti-patterns to audit
  against. Includes a component vocabulary reference.
  Use when designing the UI for a new agent product, when an existing
  agent interface needs to surface agent actions more clearly, when users
  are confused about what the agent is doing or why, when designing the
  approval gate interface for a supervised agent, or when an agent is
  causing over-trust (users not reviewing outputs) or active distrust
  (users not adopting the agent).
  Trigger phrases: "design the UI for this agent", "how should users
  interact with this agent", "what should the interface show while the
  agent is running", "how do we communicate uncertainty to users",
  "design the approval interface", "streaming agent output design",
  "show agent reasoning to users", "agent activity feed design",
  "why users are not trusting the agent", "over-trust in agent output".
  Do not use for designing the technical approval gate mechanism (use
  human-in-the-loop-patterns), for governance policy and org trust
  frameworks (use agentic-governance-and-adoption), or for deployment
  launch gate checklists (use deployment-readiness).
allowed-tools:
  - Read
  - Write
metadata:
  category: technical
  version: "0.1.0"
---

# Agent UI Patterns

UI architecture skill. Designs the user interface layer for agentic AI systems — from pre-execution transparency through in-execution feedback to post-execution review. Produces actionable component and pattern recommendations.

## When to Use

**Use when:**
- Designing the UI for a new agent product from scratch
- Users are confused about what the agent is doing, have stopped trusting it, or are trusting it too uncritically
- Designing the interface for a supervised agent with human approval gates
- Streaming agent output needs to be structured and surfaced progressively
- An existing agent UI needs to surface agent actions, reasoning, or confidence more clearly

**Do not use when:**
- The question is about the technical mechanism of approval gates (trigger, validation, audit) → use `human-in-the-loop-patterns`
- The question is about governance policy and org-level trust → use `agentic-governance-and-adoption`
- The question is about deployment gate checklists → use `deployment-readiness`

## Workflow

### Step 1 — Gather context

Ask the user:
1. What is the agent's task domain and the user's goal? (Customer service, coding, research, operations?)
2. What actions can the agent take? Which are reversible, which are irreversible?
3. Who are the users? (Technical operators, business users, end customers, reviewers?)
4. What is the autonomy level? (Fully supervised, HITL for high-risk, mostly autonomous?)
5. What UI surface is available? (Web app, chat interface, embedded panel, CLI, mobile?)
6. What is the current trust problem, if any? (Users don't trust the agent, or they trust it too much?)

---

### Step 2 — Solve the inversion problem

Agentic systems invert traditional UI assumptions in four ways that require explicit design:

1. **Temporal inversion:** Traditional UI responds to user actions instantly. Agents work over time — the interface must represent an ongoing process, not a completed response.
2. **Transparency inversion:** Traditional UI hides complexity. Agent UIs must expose reasoning, evidence, and uncertainty to maintain appropriate trust.
3. **Control inversion:** Traditional UI keeps users in control of every step. Agent UIs must communicate what the agent decided, not just what it did.
4. **Error inversion:** Traditional UI errors are deterministic and fixable. Agent errors are probabilistic, difficult to predict, and may require human judgment to recover from.

These four inversions mean agent UIs cannot be designed as traditional chatbots with longer responses. They require a different component vocabulary.

---

### Step 3 — Select the core layout pattern

**Dual-Panel Architecture:**

The foundational layout for agent UIs. Separates the conversation surface from the activity stream.

```
┌────────────────────┬───────────────────────────────┐
│                    │                               │
│  Conversation      │  Activity Stream              │
│  Panel             │  (What the agent is doing)    │
│                    │                               │
│  User ← → Agent    │  Step 1: Searching...   ✓     │
│  exchange          │  Step 2: Analyzing...   ⟳     │
│                    │  Step 3: Drafting...    –     │
│                    │                               │
│                    │  Tools used: [3]              │
│                    │  Sources: [2]                 │
└────────────────────┴───────────────────────────────┘
```

**When to use Dual-Panel:**
- Agent executes multiple steps that take more than a few seconds
- The user needs visibility into progress and intermediate results
- The agent uses tools that should be visible to maintain trust

**When single-panel is acceptable:**
- Short-running agents (< 2 seconds, single LLM call)
- Internal tools where transparency is not a user requirement
- Simple Q&A agents with no tool use

---

### Step 4 — Design the streaming step cards

Use the AG-UI event model to map backend agent events to frontend component states.

**AG-UI event taxonomy (relevant events to handle):**

| Backend event | Frontend state | Component update |
|---|---|---|
| `RUN_STARTED` | Agent is working | Show activity indicator; start step card |
| `TEXT_MESSAGE_START` | Generating response | Start streaming text in conversation panel |
| `TEXT_MESSAGE_CONTENT` | Response streaming | Append streamed tokens to conversation panel |
| `TEXT_MESSAGE_END` | Response complete | Finalize text; show response |
| `TOOL_CALL_START` | Tool being called | Show tool name in activity stream; animate |
| `TOOL_CALL_END` | Tool result received | Show result summary; mark step complete |
| `AGENT_STATE_CHANGED` | State transition | Update state indicator (planning/executing/waiting) |
| `RUN_FINISHED` | Agent done | Clear activity indicator; show final state |
| `RUN_ERROR` | Error occurred | Show error state; offer recovery path |

**Step card design:**

Each step in the activity stream is a step card:
- Icon: spinner (in progress) / checkmark (done) / warning (failed) / lock (waiting for approval)
- Label: plain-language description of what the step did ("Searched knowledge base", "Drafted response", "Waiting for your approval")
- Detail (expandable): tool name, arguments summary, result summary
- Timing: elapsed time for each step

---

### Step 5 — Design Intent Preview for irreversible actions

Intent Preview is required before any irreversible action. The agent must show what it intends to do and give the user an opportunity to cancel or modify before the action executes.

**Intent Preview components:**

1. **Action description:** Plain language — "I'm about to send this email to [recipient]"
2. **Action details:** Structured preview of exactly what will happen — email body, recipient list, subject line
3. **Consequence statement:** What this action will do that cannot be undone — "Once sent, this email cannot be recalled"
4. **Confirm / Cancel buttons:** Explicit confirmation required; Cancel must be as prominent as Confirm

**When to show Intent Preview:**
- Any irreversible write action (email send, record delete, financial transaction, external API post)
- Any action with external visibility (any communication to external parties)
- Any action affecting more than one record or user

**Intent Preview is not:**
- A generic "are you sure?" dialog — it must show specific action details, not a generic warning
- Required for reversible read-only actions
- An optional nicety — it is required for irreversible actions in any supervised deployment

---

### Step 6 — Design the Autonomy Dial

The Autonomy Dial gives users explicit control over the agent's autonomy level. Three positions:

**Position 1 — Review Everything:**
The agent proposes each action and waits for user confirmation before executing. Every step is visible and confirmable.
- Use for: new users onboarding to the agent; high-stakes workflows; regulated domains; users who want full control
- Cost: slower throughput; higher cognitive load on the user

**Position 2 — Review Significant Actions:**
The agent executes reversible, low-risk actions autonomously. Irreversible or high-risk actions require confirmation (Intent Preview fires automatically).
- Use for: most production deployments; the default position for new users who have completed onboarding
- Recommended default for most agent products

**Position 3 — Let the Agent Run:**
The agent executes all actions autonomously; the user reviews results at the end. The activity stream is still visible but approval gates do not fire.
- Use for: experienced users who have built trust with the agent; low-stakes, well-tested workflows; batch processing

**Autonomy Dial design rules:**
- Default to Position 2 (Review Significant Actions) for new users
- Do not allow users to start at Position 3 without completing an onboarding sequence
- Remember user preference per task type (a user may want Position 1 for financial tasks and Position 3 for content tasks)
- Make the current position visible and changeable at any time

---

### Step 7 — Design Transparency and Explainability components

Three levels of transparency, applied progressively:

**Level 1 — Visible action stream:**
The user can see what the agent is doing (steps, tools used, progress). No explanation of reasoning required. Minimum transparency for any agent UI.

**Level 2 — Inline rationale:**
For significant decisions, the agent explains why it chose this action over alternatives. Shown as a collapsed detail under the action step ("Why did the agent do this?").

**Level 3 — Full explainability:**
For high-stakes or regulated workflows, the agent provides a full audit trail: every decision point, the evidence used, the alternatives considered, and the confidence at each step.

**Component selection by autonomy tier:**

| Autonomy tier | Level 1 | Level 2 | Level 3 |
|---|---|---|---|
| L1 Supervised | Required | Required | Required |
| L2 Assisted | Required | Required | Optional |
| L3 Conditional | Required | Optional | Not required |
| L4 Autonomous | Required | Not required | Not required |

**Calibrated Trust:**
Design explicitly against both failure modes:
- **Over-trust:** Users accept agent output without review. Signs: approval rate > 98%, no override, no questions. Mitigation: make uncertainty visible; surface confidence scores below threshold; show "suggested by agent" framing, not "confirmed by agent"
- **Active distrust:** Users reject agent suggestions routinely even when correct. Signs: override rate > 50%, abandonment after first error. Mitigation: show agent reasoning; start with Position 1 (Review Everything); let users build trust incrementally through correct decisions

---

### Step 8 — Design Confidence Visualization

Do not hide agent uncertainty from users.

**Confidence visualization patterns:**

1. **Confidence bar / badge:** Show a visual confidence indicator alongside recommendations. Color-coded: green (> 0.8), yellow (0.6–0.8), red (< 0.6).

2. **Uncertainty language:** When confidence is below threshold, the agent's language should reflect uncertainty:
   - High confidence (> 0.8): "The answer is X"
   - Medium confidence (0.6–0.8): "Based on available information, X appears likely"
   - Low confidence (< 0.6): "I'm not certain, but X might apply — I recommend verifying this"

3. **"I don't know" surface:** When the agent cannot answer with adequate confidence, surface this clearly rather than hedging. "I don't have enough information to answer this reliably" is better than a low-confidence assertion.

4. **Confidence on actions:** For approval gates, show the agent's confidence in its recommended action alongside the action details. A reviewer seeing "confidence: 0.62" will review more carefully than one seeing no confidence indicator.

---

### Step 9 — Design Error and Recovery UX

**Four-level graceful degradation hierarchy:**

1. **Level 1 — Retry:** The agent attempts the action again. Shown to user as: "Retrying..." with a step card update.
2. **Level 2 — Fallback:** The agent uses an alternative approach or tool. Shown to user as: "Trying an alternative approach..."
3. **Level 3 — Partial completion:** The agent completes what it can and reports what it could not do. Shown to user as: "I completed X and Y, but couldn't complete Z because [reason]."
4. **Level 4 — Escalation:** The agent cannot complete the task and routes to a human. Shown to user as: a full handoff message with context.

**Three-part error message pattern:**
For any agent error shown to the user:
1. **What happened:** Plain language, no jargon ("I couldn't find your account in our records")
2. **Why it happened (if known):** "This sometimes occurs when the account was created in a different system"
3. **What you can do:** Actionable next step ("Please contact support with your account ID: [X]")

**Anti-patterns to audit against (eight key patterns):**

| Anti-pattern | Description | Fix |
|---|---|---|
| Silent failure | Agent fails and shows no indication to user | Always surface errors at Level 1+ |
| Generic spinner | "Loading..." with no step visibility | Replace with step cards |
| Confidence theater | Always shows high confidence | Show actual confidence scores |
| Premature commitment | Agent executes irreversible actions without preview | Add Intent Preview for all irreversible actions |
| Unexplained refusal | Agent refuses without explanation | Use three-part error message |
| Autonomy ambiguity | User cannot tell what the agent will do autonomously | Make bounded autonomy contract visible in UI |
| Irreversible by default | Default autonomy is "let the agent run" | Default to Position 2 (Review Significant Actions) |
| Recovery dead end | Error message with no next step | Always include a recovery path in error messages |

---

### Step 10 — Write the UI design specification

Write a structured UI design specification to:
- `artifact_output_path/ui-patterns-<agent-name>.md` if `artifact_output_path` is configured in `.agentic/config.yml`
- Otherwise: `.agentic/artifacts/ui-patterns-<agent-name>.md`

Format:

```markdown
# Agent UI Design: <Agent Name>

## Layout
[Dual-panel or single-panel — rationale]

## Streaming Step Cards
[AG-UI events handled; step card design]

## Intent Preview
[Which actions trigger preview; preview content format]

## Autonomy Dial
[Three positions; default; per-task configuration]

## Transparency Level
[Which level by autonomy tier; components used]

## Confidence Visualization
[Threshold definitions; visualization patterns]

## Error and Recovery
[Degradation level for each error type; three-part message templates]

## Anti-pattern Audit
[Eight anti-patterns checked; present/absent for this design]

## Component Inventory
[Named components in the design with their role]
```

---

### Step 11 — Report

After writing the design:
1. State the file path.
2. State the layout choice and autonomy dial default.
3. Flag any anti-patterns that are currently present in the existing UI (if reviewing an existing design).
4. Flag any irreversible actions that lack Intent Preview.
5. Flag any trust problem (over-trust or active distrust) and the recommended design response.
6. Suggest next steps: `human-in-the-loop-patterns` to design the underlying approval gate mechanism that the UI exposes.

## Output Contract

- **Primary output:** UI design specification at `artifact_output_path/ui-patterns-<agent-name>.md` or `.agentic/artifacts/ui-patterns-<agent-name>.md`
- **In-conversation summary:** layout choice, key pattern selections, anti-pattern findings, trust calibration assessment
- **Does not produce:** approval gate technical mechanism (use `human-in-the-loop-patterns`), governance policy (use `agentic-governance-and-adoption`)

## Scope Boundaries

This skill designs the user interface layer of an agentic system — the components, patterns, and layout that users interact with. It does not design the technical mechanism of approval gates (trigger conditions, validation, audit records) — that is `human-in-the-loop-patterns`. It does not design governance policy or org-level trust frameworks — that is `agentic-governance-and-adoption`. The UI patterns here implement the HITL design at the visual layer; the underlying approval mechanism must be designed separately.
