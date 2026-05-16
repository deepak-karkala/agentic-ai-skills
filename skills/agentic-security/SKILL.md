---
name: agentic-security
description: >
  Hardens the trust boundaries of an agentic AI system against agent-specific
  threats. Covers the eight-threat taxonomy for agents (prompt injection,
  tool abuse, data exfiltration, privilege escalation, model manipulation,
  indirect injection, supply chain, agent impersonation); tool permission
  tier assignment (read-only, correctable write, irreversible write, admin);
  prompt injection and indirect injection detection and containment;
  secret handling boundaries; dangerous action gating; audit trail
  requirements by autonomy tier; and zero-trust agent design.
  Focuses exclusively on agent-specific trust model threats — not general
  application security.
  Use when designing the security posture of a new agent system before
  production, when an existing agent has untrusted inputs entering the
  context window, when tool permissions are broader than the minimum
  required, when an agent handles secrets or credentials, when a
  multi-agent system has unclear trust boundaries between agents, or
  when a security review has flagged an agent system for audit.
  Trigger phrases: "how do I secure this agent", "what are the trust
  boundaries", "prompt injection risk", "can the agent be manipulated",
  "what permissions should this tool have", "how do I prevent tool abuse",
  "secrets in context window", "harden this agent against injection",
  "security review for this agent", "zero-trust agent design",
  "how do I gate dangerous actions", "audit trail for agent actions".
  Do not use for general application security that is not agent-specific
  (use standard AppSec practices), for deployment guardrail stack design
  (use deployment-readiness), or for tool schema and ACI ergonomics
  (use tool-interface-design — this skill covers the security properties
  of tools, not their schema design).
allowed-tools:
  - Read
  - Write
metadata:
  category: technical
  version: "0.1.0"
---

# Agentic Security

Security hardening skill. Designs the trust model and security posture for an agentic AI system using an agent-specific threat taxonomy. Produces actionable hardening guidance covering tool permissions, injection containment, secret handling, dangerous action gating, and audit trail design.

## When to Use

**Use when:**
- Designing the security posture of a new agent before production deployment
- An existing agent has untrusted inputs (user-provided content, retrieved documents, external tool results) entering the context window
- Tool permissions are broader than the minimum required
- The agent handles secrets, credentials, or tokens
- A multi-agent system has unclear trust boundaries between agents
- A security review or compliance requirement has flagged the agent system

**Do not use when:**
- The question is about general application security (authentication, TLS, SQL injection) — use standard AppSec practices
- The question is about the deployment guardrail stack, launch gates, or HITL posture → use `deployment-readiness`
- The question is about tool schema ergonomics, naming conventions, or ACI design → use `tool-interface-design`
- The question is about audit trail as a business compliance requirement → use `agentic-governance-and-adoption`

## Workflow

### Step 1 — Gather context

Ask the user:
1. What is the agent's architecture? (Single agent, orchestrator-workers, pipeline, multi-agent?)
2. What tools does the agent have access to? List them with their current permission level.
3. What are the input surfaces? (User-provided free text, retrieved documents, external API responses, agent-to-agent messages?)
4. Does the agent handle secrets, credentials, API keys, or tokens? Where are they stored?
5. What is the autonomy level? (Fully supervised, HITL for high-risk actions, fully autonomous?)
6. Are there other agents in the system that this agent communicates with? Who trusts whom?

---

### Step 2 — Identify applicable threats from the eight-threat taxonomy

Assess which threats are applicable to this system. For each applicable threat, identify the current exposure and the required mitigation.

**Threat 1 — Prompt Injection**
- **Definition:** Malicious instructions embedded in user input that override the agent's intended behavior.
- **Exposure indicators:** Agent accepts free-text user input; user input is directly interpolated into the system prompt or few-shot examples.
- **Mitigation:** Input sanitization layer before context assembly; role-labeling to separate user content from instructions; output behavior monitoring for anomalous instruction-following patterns.

**Threat 2 — Indirect Injection**
- **Definition:** Malicious instructions embedded in content retrieved from the environment (web pages, documents, tool outputs, database results) that the agent processes as data but which contain instruction-like text.
- **Exposure indicators:** Agent reads and processes external documents, web content, database records, or multi-hop tool call results.
- **Mitigation:** Treat all retrieved content as untrusted data (never as instructions); use a separate retrieval context that is firewalled from the instruction context; add injection detection patterns to retrieved content before it enters the context.
- **Note:** Indirect injection is often more dangerous than direct injection because it is harder to detect and the agent may not be designed to resist it.

**Threat 3 — Tool Abuse**
- **Definition:** The agent is manipulated (via injection or model error) into calling tools it should not call, with arguments it should not use.
- **Exposure indicators:** Write-capable tools accessible to the agent; tools that can affect external systems (email, CRM, databases, infrastructure APIs).
- **Mitigation:** Minimum permission tier assignment (see Step 3); tool call dry-run for irreversible actions; human approval gate for admin-tier tools.

**Threat 4 — Data Exfiltration**
- **Definition:** The agent is manipulated into returning sensitive data to unauthorized parties — either directly in output or via tool calls to external endpoints.
- **Exposure indicators:** Agent has access to databases, user PII, credentials, or internal documents; agent can call outbound HTTP tools or send messages.
- **Mitigation:** Output filtering for PII and secrets; restrict outbound tool calls to an allowlist of verified destinations; log all output operations.

**Threat 5 — Privilege Escalation**
- **Definition:** The agent is manipulated into performing actions outside its intended authority scope — e.g., accessing admin APIs, modifying its own instructions, or creating new agent sessions.
- **Exposure indicators:** Agent has tools that could modify its own configuration; agent has access to administrative APIs; agent can spawn sub-agents or modify other agents' contexts.
- **Mitigation:** Capability scoping — agent can only call tools in its defined capability set; no self-modification tools; capability set is immutable at runtime.

**Threat 6 — Model Manipulation**
- **Definition:** An attacker systematically probes the agent to extract its system prompt, tool schemas, routing logic, or internal decision rules.
- **Exposure indicators:** Agent has a significant system prompt or routing logic that would be valuable to leak; agent is customer-facing.
- **Mitigation:** Instruct the agent to refuse requests to reveal its instructions; monitor for systematic probing patterns; do not embed secrets in the system prompt.

**Threat 7 — Supply Chain Injection**
- **Definition:** A malicious tool, plugin, or model version is introduced into the agent's execution environment.
- **Exposure indicators:** Agent loads tools or plugins dynamically; model version is not pinned; third-party tool integrations exist.
- **Mitigation:** Pin model version; audit all third-party tool integrations; sign and verify tool packages; use a plugin registry with integrity checks.

**Threat 8 — Agent Impersonation**
- **Definition:** In a multi-agent system, a malicious agent or external actor impersonates a trusted agent to send fraudulent messages or trigger unauthorized actions.
- **Exposure indicators:** Multiple agents in the system; agents can receive and act on messages from other agents; no authentication between agents.
- **Mitigation:** Cryptographic signing of inter-agent messages; principal hierarchy that defines which agents can issue which instructions; verify agent identity before acting on delegated tasks.

---

### Step 3 — Assign tool permission tiers

Classify every tool the agent can access into the minimum required permission tier. The principle: an agent should never hold a tool at a higher permission tier than its tasks strictly require.

| Tier | Description | Examples | Gate required |
|---|---|---|---|
| Read-only | Returns data; no side effects; fully reversible | ticket-lookup, kb-search, database-read, user-profile-fetch | None — safe for autonomous use |
| Correctable write | Modifies state that can be corrected without significant cost | Draft save, status update, tag assignment, note creation | Confidence threshold or dry-run before execute |
| Irreversible write | Modifies state that is costly or impossible to reverse | Email send, record delete, financial transaction, external API post | Human approval gate or dry-run with explicit confirmation |
| Admin | Can modify agent configuration, permissions, or other agents | Prompt update, tool registration, agent spawn, infrastructure change | Never autonomous — always human-in-the-loop |

For each write-capable tool: confirm it is at the minimum tier required, not the most convenient tier available.

---

### Step 4 — Design secret handling boundaries

Secrets must never enter the agent's context window.

**Enforcement rules:**

1. **No secrets in system prompts.** API keys, tokens, passwords, and credentials must be resolved at the tool layer — not embedded in the prompt. An agent that has a secret in its context window will eventually leak it via output.
2. **Tool layer resolution only.** Tools retrieve secrets from a vault (AWS Secrets Manager, HashiCorp Vault, GCP Secret Manager) at call time. The secret value is never passed to the LLM — only the tool result (success/failure, response data).
3. **Log sanitization.** All agent logs must be scanned for secret patterns (API key formats, JWT patterns, credential patterns) before storage. Mask or drop any secret that appears in a log.
4. **No user-provided secrets in context.** If a user provides credentials in a message (even benignly), the agent must not echo them back, store them in memory, or pass them to tools beyond the immediate authenticated call.

---

### Step 5 — Design dangerous action gating

Dangerous actions — irreversible writes, admin operations, and high-blast-radius tool calls — require a gate before execution.

**Gate design for dangerous actions:**

1. **Classify actions by reversibility and blast radius at design time.** Maintain a list of dangerous tool calls with their tier, blast radius, and required gate type.
2. **Dry-run before execute pattern:** For irreversible writes, generate a structured dry-run output ("Here is what I would do: [action description]") and require explicit confirmation before the actual call.
3. **Bounded action budget:** Define the maximum number of irreversible actions the agent can take in a single session without human review. Exceeding the budget triggers an escalation.
4. **Post-action audit event:** Every dangerous action must emit an audit event with: action type, arguments, agent_id, session_id, timestamp, outcome. No dangerous action should be undiscoverable from the audit trail.

---

### Step 6 — Assign audit trail requirements by autonomy tier

| Autonomy tier | Required audit trail |
|---|---|
| Fully supervised (L1) | Log all inputs and outputs; no dangerous actions possible |
| Assisted (L2) | Log all tool calls with arguments hash; log all HITL decisions (human approval/rejection); log all routing decisions |
| Conditional automation (L3) | Above, plus: log all context state at decision points; log all confidence scores below threshold; flag for async review |
| Full autonomy (L4) | Above, plus: immutable audit log for all irreversible actions; retention per compliance schedule; alert on anomalous action patterns |

---

### Step 7 — Write the security hardening plan

Write a structured hardening plan to:
- `artifact_output_path/security-<agent-name>.md` if `artifact_output_path` is configured in `.agentic/config.yml`
- Otherwise: `.agentic/artifacts/security-<agent-name>.md`

Format:

```markdown
# Security Hardening Plan: <Agent Name>

## Threat Assessment
[Table: threat | applicable | exposure | mitigation | priority]

## Tool Permission Map
[Table: tool | current tier | required tier | change needed]

## Secret Handling
[Current state vs. required state; vault integration plan]

## Dangerous Action Gates
[List: action | reversibility | blast radius | gate type | current state]

## Audit Trail Requirements
[Autonomy tier → required trail; current gaps]

## Priority Hardening Actions
[Ordered list with effort and impact estimates]
```

---

### Step 8 — Report

After writing the plan:
1. State the file path.
2. List the applicable threats with their current exposure status.
3. Flag any tool running at a higher permission tier than required.
4. Flag any secret currently in the context window.
5. Flag any dangerous action without a gate.
6. Suggest next steps: `deployment-readiness` to incorporate the security posture into the launch gate, `tool-interface-design` to redesign tool schemas that are contributing to security exposure.

## Output Contract

- **Primary output:** Security hardening plan at `artifact_output_path/security-<agent-name>.md` or `.agentic/artifacts/security-<agent-name>.md`
- **In-conversation summary:** applicable threats, tool permission gaps, secret handling gaps, dangerous action gates, priority actions
- **Does not produce:** general AppSec reviews, deployment gate checklists, eval scorecard, tool schema redesign

## Scope Boundaries

This skill covers agent-specific trust model threats — the eight threats that arise from agents operating with tools, context windows, and autonomy that do not exist in conventional software. It does not cover general application security (authentication, authorization, input validation in the conventional sense — those belong in standard AppSec), deployment guardrail design (use `deployment-readiness`), or tool schema ergonomics (use `tool-interface-design`). The security properties of tools — what permissions they need, whether they are safe to call autonomously — are in scope here. The naming and schema structure of those tools is not.
