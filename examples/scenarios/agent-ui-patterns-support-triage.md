# Scenario: Designing the UI for a Support Triage Agent

## Trigger

> "Design the UI for this agent"
>
> "We're building the frontend for our support triage agent. The agent classifies tickets, routes them, and can send automated emails to customers. The support team will use this in a web app. We want them to trust the agent but also be able to review and override its decisions. How should we design this?"

## Skill: agent-ui-patterns

### Inputs gathered

1. Agent: Support Triage Agent — classifies, routes, can send customer emails
2. Actions: ticket classification (reversible), routing decision (reversible), email-send (irreversible)
3. Users: Support team members (not technical; use the tool 6+ hours/day; 200 tickets/day)
4. Autonomy level: L2 Assisted — most routing is autonomous; human approves Tier-3 escalations and outbound emails
5. UI surface: Web app (React); dual-panel layout is feasible
6. Trust problem: Team lead concerned about over-trust — agents are letting agent decisions through without reviewing confidence scores

### Step 2 — Inversion analysis

| Inversion | Design implication for this agent |
|---|---|
| Temporal | Triage takes 3–8 seconds per ticket; UI must show progress, not just a result |
| Transparency | Support agents need to see routing rationale to audit and override intelligently — not just the routing decision |
| Control | Agents should see clearly what the triage agent will do vs. what it has already done |
| Error recovery | When the agent can't classify a ticket, it should offer a specific handoff path to the human agent — not an error message |

### Step 3 — Layout: Dual-Panel Architecture

```
┌────────────────────────────┬──────────────────────────────┐
│                            │                              │
│  Ticket Queue              │  Agent Activity              │
│  (left panel)              │  (right panel)               │
│                            │                              │
│  Ticket #8901  ⟳           │  Analyzing ticket...   ⟳    │
│  [Customer message]        │  ─────────────────────────── │
│                            │  ✓ Classified: Billing       │
│                            │    Confidence: 0.91          │
│                            │  ✓ Matched routing rule      │
│                            │  ⟳ Generating routing...    │
│                            │                              │
│  Routing decision:         │  Tools used: [ticket-lookup] │
│  Tier-2 Billing  ↓        │  Reason: "subscription"      │
│  [Override] [Approve]      │  keyword matches billing     │
│                            │  policy (article #B-142)     │
└────────────────────────────┴──────────────────────────────┘
```

**Rationale:** Dual-panel selected because triage takes 3–8 seconds (temporal inversion), the team needs to see routing rationale to override intelligently (transparency), and email-send requires explicit Intent Preview (control).

### Step 4 — Streaming step cards

AG-UI events mapped to step cards for the triage workflow:

| Event | Step card update |
|---|---|
| `RUN_STARTED` | "Analyzing ticket..." with spinner |
| `TOOL_CALL_START` (ticket-lookup) | "Looking up ticket history..." with spinner |
| `TOOL_CALL_END` (ticket-lookup) | "Ticket history found (3 prior tickets)" with checkmark |
| `TEXT_MESSAGE_CONTENT` | Classification streaming in activity panel |
| `TOOL_CALL_START` (kb-search) | "Searching knowledge base..." with spinner |
| `TOOL_CALL_END` (kb-search) | "Found: Article #B-142 (Billing policies)" with checkmark |
| `AGENT_STATE_CHANGED` to "routing" | "Generating routing decision..." |
| `RUN_FINISHED` (normal routing) | Routing decision card with confidence badge + Approve/Override buttons |
| `RUN_FINISHED` (requires approval) | Routing decision card with lock icon + mandatory approval gate |

### Step 5 — Intent Preview for email-send

**Email-send is irreversible.** Intent Preview required.

```
┌─────────────────────────────────────────────────────────┐
│  ⚠ The agent is about to send a customer email           │
│                                                         │
│  To: customer@example.com                               │
│  Subject: Your support ticket #8901 has been routed     │
│  Body:                                                  │
│  "Thank you for contacting us. Your billing inquiry     │
│  has been assigned to our billing specialists..."       │
│                                                         │
│  ⚠ Once sent, this email cannot be recalled             │
│                                                         │
│  [Edit email]  [Don't send]  [Send email →]             │
└─────────────────────────────────────────────────────────┘
```

The Intent Preview includes the full email body (not a summary), an explicit consequence statement, and three options including Edit (so the reviewer doesn't have to choose between approve-as-is and reject entirely).

### Step 6 — Autonomy Dial

Default: **Position 2 — Review Significant Actions**

| Position | Support team use |
|---|---|
| Review Everything (P1) | New team members (first 2 weeks); tickets flagged by supervisor for training |
| Review Significant Actions (P2) | Default for all production use — shows email Intent Preview; requires approval for Tier-3 |
| Let Agent Run (P3) | Only for batch re-classification (after hours; supervisor-only unlock) |

**Per-task configuration:** P3 never allowed for email-send action. The email-send action always shows Intent Preview regardless of dial position.

### Step 7 — Transparency and Explainability

**Level 2 — Inline rationale** (appropriate for L2 Assisted):

```
Routing decision: Tier-2 Billing  🟢 0.91

▼ Why Tier-2 Billing? (expand)
  Matched: "subscription renewal failed" → billing pattern
  Evidence: Article #B-142 (Billing policies, similarity: 0.87)
  Alternative considered: General Inquiry (0.64)
  
Override: [ General Inquiry ▾ ]  [ Confirm routing → ]
```

The collapsed rationale panel satisfies the transparency requirement without cluttering the primary workflow. Expanding it gives the reviewer enough detail to make an informed override decision.

**Calibrated trust response to over-trust problem:**
- Show confidence score as a color-coded badge (not just as a number)
- Confidence below 0.80: yellow badge + "Review recommended" prompt → slows rubber-stamping
- Route confidence scores below 0.70 to mandatory review (cannot be auto-approved)
- Weekly team metrics: "Your approval rate this week: 97%. Average review time: 3 seconds." — surface to supervisors

### Step 8 — Confidence visualization

| Confidence range | Badge color | Language used in routing card |
|---|---|---|
| > 0.85 | Green | "High confidence routing" |
| 0.70–0.85 | Yellow | "Review recommended" |
| < 0.70 | Red + lock | "Requires manual review" — auto-approval disabled |

### Step 9 — Error and Recovery UX

**Degradation hierarchy for the triage agent:**

| Error | Level | User-facing message |
|---|---|---|
| ticket-lookup timeout | Level 2 (Fallback) | "Couldn't load ticket history — routing based on message content only" |
| kb-search empty result | Level 3 (Partial) | "I found a routing match but couldn't find supporting KB articles. Routing to [Tier] with low confidence badge." |
| Classification failure | Level 4 (Escalation) | "I wasn't able to classify this ticket reliably. Routing to your review queue for manual triage." |

**Three-part error message for classification failure:**
1. "I wasn't able to classify this ticket reliably" (what happened)
2. "This sometimes happens with very short or ambiguous ticket text" (why)
3. "The ticket has been added to your manual review queue" (what you can do)

### Step 10 — Anti-pattern audit for existing design

| Anti-pattern | Status in proposed design |
|---|---|
| Silent failure | Absent — all errors surface via step cards |
| Generic spinner | Absent — step cards show specific actions |
| Confidence theater | Absent — real confidence scores with color coding |
| Premature commitment | Absent — Intent Preview required for email-send |
| Unexplained refusal | Absent — three-part error messages |
| Autonomy ambiguity | Absent — Bounded Autonomy Contract surfaced in UI settings |
| Irreversible by default | Absent — default is P2; P3 not allowed for email actions |
| Recovery dead end | Absent — all error states have explicit recovery paths |

### Output

**UI design specification written to:** `.agentic/artifacts/ui-patterns-support-triage-agent.md`

Summary:
- Layout: Dual-Panel — ticket queue (left) + activity stream (right)
- Default autonomy: Position 2; email-send always requires Intent Preview regardless of position
- Transparency: Level 2 with inline rationale; confidence badge system
- Trust problem (over-trust): addressed via confidence color-coding + "review recommended" prompts + supervisor metrics
- Anti-patterns: all 8 checked; none present in proposed design
- Next step: `human-in-the-loop-patterns` to design the underlying approval gate mechanism (trigger conditions, audit records, SLAs)
