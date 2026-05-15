---
name: tool-interface-design
description: >
  Designs the tool interface layer for an agent system. Covers tool contract
  design (name, description, parameters, return schema), action granularity
  decisions (one tool vs. several), permission and scope boundaries, MCP
  ergonomics for tool discovery and invocation, structured error feedback,
  and the Agent-Computer Interface (ACI) principles that determine whether
  a tool is actually usable by an LLM. Use when defining the tools an agent
  will use, when an agent is calling the wrong tool or using tools incorrectly,
  when deciding how to split or merge tool responsibilities, or when wiring up
  MCP servers for a new agent system.
  Trigger phrases: "how should I design the tools for this agent",
  "should this be one tool or three smaller tools", "the agent keeps calling
  the wrong tool", "write tool schemas for this agent", "design the tool
  interface for this workflow", "how do I expose this API as an agent tool",
  "what should the tool descriptions say", "design MCP tool contracts for
  this agent", "how granular should my tools be".
  Do not use for multi-agent topology and handoff design (use
  multi-agent-orchestration), for production deployment guardrails and the
  Tool Gateway security layer (use deployment-readiness), for high-level
  agent architecture decisions (use agentic-system-design), or for
  prototyping a scaffold (use agentic-prototype).
allowed-tools:
  - Read
  - Write
metadata:
  category: technical
  version: "0.1.0"
---

# Tool Interface Design

Tool contract skill. Designs the tool interface layer for an agent — covering contract design, action granularity, permission boundaries, MCP ergonomics, and structured error feedback. Produces concrete tool schemas and interface recommendations.

## When to Use

**Use when:**
- Defining what tools an agent will have and how those tools should be designed
- An agent is selecting the wrong tool or using tools incorrectly despite good instructions
- Deciding whether to split a broad capability into smaller tools or merge several narrow tools
- Wiring up MCP servers and designing how the agent discovers and invokes tools
- Improving tool descriptions and parameter schemas to reduce agent tool-use errors

**Do not use when:**
- The question is about multi-agent topology, worker delegation, or handoff contracts → use `multi-agent-orchestration`
- The question is about the Tool Gateway security layer, tool sandboxing, or permission guardrails at runtime → use `deployment-readiness`
- The question is about which agent pattern to use → use `agentic-system-design`
- The question is about generating a scaffold to validate the tool design → use `agentic-prototype`

## Workflow

### Step 1 — Gather context

Ask the user:
1. What does the agent need to do? (Workflow description)
2. What external systems, APIs, or data sources does the agent need to access?
3. Are there existing API definitions (OpenAPI spec, function signatures) the tools should wrap?
4. What is the agent's autonomy level? (Supervised, gated, or autonomous — this affects action scope design)
5. Are there any permission or scope constraints? (Read-only vs. write access, which users can authorize what)

If the user has an existing tool list or partial implementation, read it. Design against what exists, not from scratch.

---

### Step 2 — Apply ACI principles

Before designing individual tools, apply the Agent-Computer Interface (ACI) design principles. Tool quality determines tool-use accuracy — it is as important as prompt quality.

**ACI principle 1 — Poka-yoke design (error-proofing):**
Design tools so the likely misuse is impossible or caught before the agent commits an irreversible action. Examples:
- Require absolute paths instead of relative paths (eliminates navigation errors)
- Require explicit confirmation parameters for destructive operations
- Validate parameters at tool entry, not in the tool body

**ACI principle 2 — Minimal footprint:**
Each tool should do exactly one thing. An agent with 3 small, clear tools makes better decisions than an agent with 1 large, multi-mode tool.
- Split tools by action type: read tools vs. write tools vs. search tools
- Split tools by resource type: customer tools vs. order tools vs. account tools
- Never put optional modes in a single tool if the modes require different parameters

**ACI principle 3 — Structured error feedback:**
When a tool fails, return a structured error — not a raw exception, not a boolean False. The agent's next reasoning step is better when it knows *why* the tool failed.

**ACI principle 4 — Reversibility signal:**
For any tool that writes, updates, or deletes: make reversibility explicit in the tool description. The agent should know whether calling this tool is reversible before it calls it.

**ACI principle 5 — Tool descriptions as the agent's compass:**
Treat tool descriptions as first-class artifacts — iterate on them like system prompts. A good tool description answers: what this tool does, when to use it (not just what it returns), and when NOT to use it (at least one explicit non-use example for each tool that has a plausible look-alike).

See [Tool Design Reference](references/tool-design-reference.md) for full ACI patterns, description templates, and anti-patterns.

---

### Step 3 — Design action granularity

Decide how to scope each tool. Apply the granularity decision rules:

**Too coarse (one tool for everything):**
- Signs: A single tool has more than 3–4 required parameters, or has an `action` enum with 5+ values, or its description requires multiple paragraphs
- Risk: The agent selects the right tool but calls it with wrong mode/parameters
- Fix: Split by action type or resource type

**Too fine (too many tiny tools):**
- Signs: More than 15–20 tools in the total set; multiple tools with nearly identical descriptions; the agent frequently calls tools in sequences that could be one operation
- Risk: The agent fails to discover the right tool; tool selection quality degrades with too many options
- Fix: Merge closely related read operations; use composite tools for common multi-step sequences

**Right granularity (heuristics):**
- Each tool covers exactly one action on exactly one resource type
- A senior engineer can read the description and immediately know when to call it
- The total tool set is under 10–12 for a focused agent; under 20 for a broad-capability agent

**Overload test:** If the agent consistently selects the wrong tool despite good descriptions, the tool set is too large. Consider dynamic tool masking: expose only the subset of tools relevant to the current task phase.

---

### Step 4 — Write tool contracts

For each tool, write a complete contract. Use the structured format:

```
Tool name:        [verb_noun format — search_orders, update_customer, delete_draft]
Description:      [What it does. When to use it. One non-use example: "Do NOT use
                  this to X — use Y instead."]
Parameters:
  - name:         [parameter name]
    type:         [string | integer | boolean | object | array]
    required:     [true | false]
    description:  [What this parameter controls. Include valid values or format.]
Returns:          [Structure of the return value. Include error structure.]
Side effects:     [none | creates <X> | modifies <X> | deletes <X>]
Reversible:       [yes | no | with_conditions (explain)]
Permission scope: [read | write | admin — who can authorize this tool call]
```

For the full schema format including JSON Schema, validation rules, and MCP tool manifest format, see [Tool Design Reference](references/tool-design-reference.md).

---

### Step 5 — Design permission and scope boundaries

Map each tool to a permission tier:

| Tier | Description | Authorization required |
|---|---|---|
| **Read** | Tool retrieves information; no state change | None (or user-level auth) |
| **Write** | Tool modifies state; changes are reversible | User confirmation or workflow approval |
| **Destructive** | Tool deletes, overwrites, or sends an irreversible action | Explicit HITL approval gate |
| **Admin** | Tool modifies system configuration, permissions, or user accounts | Admin-level auth; log all uses |

Design rules:
1. The agent should only have access to the permission tier its current task requires. An agent doing read-only analysis should not have destructive tools in scope.
2. Destructive tools must include a confirmation parameter (e.g., `confirm: bool`) that the agent must explicitly set to `True`.
3. Admin-tier tools should be excluded from the agent's default tool set and injected only when an explicitly authorized workflow requires them.

---

### Step 6 — Design MCP ergonomics (if applicable)

If the agent uses MCP servers for tool discovery and invocation:

**Tool manifest design:**
- Tool names must be unique across all MCP servers the agent connects to — namespace collisions cause silent misrouting
- Use a consistent naming convention: `<server>_<resource>_<action>` (e.g., `crm_contact_search`, `crm_contact_update`)
- Tool descriptions in the MCP manifest are what the agent sees at inference time — treat them as system prompt content, not implementation notes

**Resource vs. tool boundary:**
- MCP Resources: static or slowly-changing data the agent reads (documents, schemas, configuration)
- MCP Tools: actions the agent takes (API calls, database writes, external service invocations)
- Do not expose dynamic data as a Resource if it changes within the session — use a Tool with a read-only permission tier instead

**MCP capability negotiation:**
- Scope tool access at the MCP server level by deployer intent: a read-only analysis server should not expose write tools even if the underlying API supports them
- Version the tool manifest: if tool schemas change, the agent's tool-use behavior must be re-validated

---

### Step 7 — Write the interface spec

Write a structured tool interface specification to:
- `agent_source_path/tools/interface-spec.md` if `agent_source_path` is configured in `.agentic/config.yml`
- Otherwise: `.agentic/artifacts/tool-interface-<agent-name>.md`

The spec should include:
1. Tool inventory table (name, tier, reversible, description summary)
2. Full contract for each tool (from Step 4)
3. Permission tier mapping
4. Granularity rationale (why each tool is scoped as it is)
5. MCP manifest notes if applicable
6. Known edge cases and error handling design

---

### Step 8 — Report

After writing the spec:
1. State the file path.
2. List the tool count by permission tier (read: N, write: N, destructive: N, admin: N).
3. Flag any tools with more than 3–4 required parameters — these are candidates for splitting.
4. Flag any tools with similar descriptions — these are candidates for merging or disambiguation.
5. Suggest next steps: `agentic-prototype` to generate a scaffold with these tool stubs, or `deployment-readiness` to design the Tool Gateway that enforces the permission boundaries at runtime.

## Output Contract

- **Primary output:** Tool interface specification at `agent_source_path/tools/interface-spec.md` or `.agentic/artifacts/tool-interface-<agent-name>.md`
- **In-conversation summary:** tool count by tier, granularity flags, next steps
- **Does not produce:** multi-agent topology, runtime guardrails, code implementations, agent architecture decisions

## Scope Boundaries

This skill designs tool contracts and interfaces. It does not design the security layer that enforces those contracts at runtime (route to `deployment-readiness`), the multi-agent topology that determines which agent gets which tools (route to `multi-agent-orchestration`), or the agent architecture (route to `agentic-system-design`). If designing tool interfaces reveals a need for dynamic tool masking or tool overload mitigation, note it and route to the appropriate skill.
