# Scenario: Security Hardening Review for a Support Triage Agent

## Trigger

> "How do I secure this tool-using agent?"
>
> "We're about to launch our support triage agent into production. It reads from our CRM, our knowledge base, and can update ticket statuses and send automated emails to customers. We haven't done a security review yet — what do we need to check?"

## Skill: agentic-security

### Inputs gathered

1. Agent: Support Triage Agent — Orchestrator-Workers, 4 agents
2. Tools: ticket-lookup (read), kb-search (read), crm-update (write), email-send (write), escalation-api (write)
3. Input surfaces: Customer-written ticket text (free text); retrieved KB articles; CRM record responses
4. Secrets: CRM API key; email service API key — currently embedded in system prompt for convenience
5. Autonomy level: L2 Assisted — high-severity escalations require human approval; Tier-1 routing is autonomous
6. Multi-agent: Orchestrator ↔ 4 worker agents; workers receive routing instructions from orchestrator

### Step 2 — Threat assessment

| Threat | Applicable? | Current exposure | Priority |
|---|---|---|---|
| Prompt injection | Yes | Customer ticket text is injected directly into the system prompt template without sanitization | Critical |
| Indirect injection | Yes | KB articles retrieved from the knowledge base are injected into context without content inspection | High |
| Tool abuse | Yes | email-send and crm-update have no confirmation gate; can be called autonomously | High |
| Data exfiltration | Yes | Agent can call email-send with arbitrary recipient and body — no output filter or recipient allowlist | High |
| Privilege escalation | Low | No self-modification tools; agent cannot spawn new agents | Low |
| Model manipulation | Medium | System prompt contains routing logic; customer-facing agent could be probed | Medium |
| Supply chain injection | Low | Tools are internal; no dynamic plugin loading | Low |
| Agent impersonation | Medium | Worker agents accept routing instructions from orchestrator with no cryptographic verification | Medium |

### Step 3 — Tool permission audit

| Tool | Current tier | Required tier | Change needed |
|---|---|---|---|
| ticket-lookup | Read-only | Read-only | None |
| kb-search | Read-only | Read-only | None |
| crm-update | Correctable write | Correctable write | Add confidence threshold gate (>0.85 before auto-update) |
| email-send | Correctable write | **Irreversible write** | Gate required — email cannot be unsent; add human approval for all outbound emails in L2 mode |
| escalation-api | Correctable write | Correctable write | Add dry-run before execute for Tier-3 escalations |

**Finding:** email-send is classified at the wrong tier. Sending an email to a customer is irreversible — a wrong email cannot be recalled. This tool must be promoted to irreversible-write tier with an approval gate.

### Step 4 — Secret handling

**Critical finding: CRM API key and email service API key are currently embedded in the system prompt.**

Required changes:
1. Remove both API keys from the system prompt immediately
2. Store in secrets manager (AWS Secrets Manager recommended — team already uses AWS)
3. Tools (crm-update, email-send) retrieve the key at call time from the vault — the key value is never passed to the LLM
4. Add log sanitization: scan all agent logs for the API key pattern before writing to log storage

**Interim measure (before vault integration):** At minimum, move the keys to environment variables resolved at container start — not in the prompt. Keys in the prompt appear in LangSmith/Langfuse trace logs in plaintext.

### Step 5 — Dangerous action gates

| Action | Reversibility | Blast radius | Required gate | Current state |
|---|---|---|---|---|
| email-send | Irreversible | Customer-facing — high reputational impact | Human approval (L2) | No gate |
| crm-update | Correctable | Single ticket record | Confidence threshold | No gate |
| escalation-api (Tier-3) | Correctable | Routing to engineering team | Dry-run + confirmation | HITL gate exists for Tier-3 |

### Step 6 — Audit trail for L2 Assisted

Required (currently missing):
- All tool calls must log: tool name, arguments hash, result status, agent_id, session_id, timestamp
- All human approval/rejection decisions must be logged with the reviewer's identity
- All routing decisions must be logged with the confidence score at decision time
- **Currently:** only errors are logged; success paths have no structured audit trail

### Priority hardening actions

1. **[Critical]** Remove API keys from system prompt; integrate with AWS Secrets Manager
2. **[Critical]** Add input sanitization layer for customer ticket text before context assembly; use role-labeling to separate data from instructions
3. **[High]** Promote email-send to irreversible-write tier; add human approval gate for all autonomous emails in L2 mode
4. **[High]** Add indirect injection detection for KB article content; inspect retrieved content for instruction-like patterns before injecting into context
5. **[High]** Implement structured audit trail for all tool calls on success path (not just errors)
6. **[Medium]** Add recipient allowlist to email-send tool; restrict outbound email to domains matching ticket submitter
7. **[Medium]** Add inter-agent message signing between orchestrator and workers; verify message origin before executing routing instructions

### Output

**Security hardening plan written to:** `.agentic/artifacts/security-support-triage-agent.md`

Summary:
- 2 Critical findings: API keys in system prompt; no input sanitization on ticket text
- 1 High permission finding: email-send running at wrong tier (must be irreversible-write)
- 4 High priority actions before production launch
- Blocking launch: API key removal + injection protection + email-send gate
- Suggested next step: incorporate these findings into `deployment-readiness` gate checklist
