# AGENTS.md

This file provides routing guidance to AI coding agents (Claude Code, Codex, OpenCode, Cursor, and others) when the `agentic-ai-engineering` plugin is active.

## Plugin Overview

Plugin namespace: `agentic-ai-engineering`

This plugin provides decision-compression workflows for building agentic AI products. It covers architecture design, context engineering, multi-agent orchestration, evaluation strategy, and deployment readiness.

Skills activate automatically when user intent matches the trigger conditions below. Users can also invoke any skill directly with `/agentic-ai-engineering:<skill-name>`.

---

## Intent-to-Skill Routing

Map user intent to the correct skill. If a request matches multiple skills, use the most specific one.

### Architecture and design

| User intent | Primary skill | Entry command |
|---|---|---|
| Design an agent system from scratch | `agentic-system-design` | `/agentic-ai-engineering:agentic-plan` |
| Review an existing agent architecture | `agentic-system-design` | `/agentic-ai-engineering:agentic-arch-review` |
| Decide between single-agent and multi-agent | `agentic-system-design` | `/agentic-ai-engineering:agentic-plan` |
| Choose an agent orchestration pattern | `agentic-system-design` | `/agentic-ai-engineering:agentic-arch-review` |
| Design multi-agent topology or handoff contracts | `multi-agent-orchestration` | `/agentic-ai-engineering:agentic-plan` |
| Design tool interfaces, MCP wiring, or agent communication | `multi-agent-orchestration` | auto |

### Context and memory

| User intent | Primary skill | Entry command |
|---|---|---|
| Design context strategy or memory architecture | `context-engineering-for-agents` | auto |
| Diagnose context overflow, context drift, or token budget issues | `context-engineering-for-agents` | auto |
| Apply write/select/compress/isolate decisions | `context-engineering-for-agents` | auto |
| Design RAG or retrieval integration for an agent | `context-engineering-for-agents` | auto |

### Evaluation and quality

| User intent | Primary skill | Entry command |
|---|---|---|
| Design an eval strategy for a new agent | `agent-eval-design` | `/agentic-ai-engineering:agentic-evals` |
| Audit an existing eval suite | `agent-eval-design` | `/agentic-ai-engineering:agentic-evals` |
| Choose grader types or scorecard dimensions | `agent-eval-design` | `/agentic-ai-engineering:agentic-evals` |
| Set up regression tests from production failures | `agent-eval-design` | `/agentic-ai-engineering:agentic-evals` |

### Production and deployment

| User intent | Primary skill | Entry command |
|---|---|---|
| Assess production readiness | `deployment-readiness` | `/agentic-ai-engineering:agentic-ops` |
| Design guardrails or fallback strategies | `deployment-readiness` | `/agentic-ai-engineering:agentic-ops` |
| Define human-in-the-loop approval gates | `deployment-readiness` | `/agentic-ai-engineering:agentic-ops` |
| Plan rollout posture or bounded autonomy | `deployment-readiness` | `/agentic-ai-engineering:agentic-ops` |
| Define observability and incident posture | `deployment-readiness` | `/agentic-ai-engineering:agentic-ops` |

### Setup

| User intent | Primary skill | Entry command |
|---|---|---|
| Configure this repo for the plugin skill suite | `setup-agentic-ai-engineering` | `/agentic-ai-engineering:setup-agentic-ai-engineering` |
| Record where design docs, eval assets, or artifacts live | `setup-agentic-ai-engineering` | `/agentic-ai-engineering:setup-agentic-ai-engineering` |

---

## Skill Trigger Examples and Boundaries

### `agentic-system-design`

**Trigger on:**
- "How should I architect this agent?"
- "Should I use a single agent or multiple agents for this?"
- "What's the right autonomy level for this workflow?"
- "Help me design the control loop for this task"
- "Which orchestration pattern fits this use case?"
- "Review my agent architecture"

**Do not trigger on:**
- Specific eval questions → use `agent-eval-design`
- Multi-agent topology and handoff specifics (after initial design) → use `multi-agent-orchestration`
- Deployment gates and production readiness → use `deployment-readiness`
- Context window budgets or memory tier design → use `context-engineering-for-agents`

---

### `context-engineering-for-agents`

**Trigger on:**
- "How should I manage context for this agent?"
- "The agent keeps losing track of state — how do I fix this?"
- "How do I design memory for a long-running agent?"
- "When should I use external memory vs in-context state?"
- "How do I compress context without losing important information?"
- "How should I isolate context across subagents?"

**Do not trigger on:**
- High-level architecture questions → use `agentic-system-design`
- Tool design or MCP wiring → use `multi-agent-orchestration`

---

### `multi-agent-orchestration`

**Trigger on:**
- "When should I split this into multiple agents?"
- "How should I structure the handoff between agents?"
- "Which multi-agent topology fits this use case — sequential, fan-out, supervisor?"
- "How do I prevent coordination failures in a multi-agent system?"
- "How do MCP and A2A work together in this design?"
- "What are the risks of this multi-agent design?"

**Do not trigger on:**
- Initial "should I use agents at all?" questions → use `agentic-system-design`
- Eval strategy → use `agent-eval-design`
- Deployment readiness → use `deployment-readiness`

---

### `agent-eval-design`

**Trigger on:**
- "How do I evaluate this agent?"
- "What metrics matter for this agentic workflow?"
- "My agent looks good in demos but I'm not confident — how do I test it properly?"
- "How do I choose between LLM-as-judge and deterministic evaluators?"
- "How do I set up regression tests for this agent?"
- "Audit my current eval setup"

**Do not trigger on:**
- Architecture decisions → use `agentic-system-design`
- Production readiness gates → use `deployment-readiness` (eval is a readiness input, not the same skill)

---

### `deployment-readiness`

**Trigger on:**
- "Is this agent safe to deploy to production?"
- "What guardrails do I need before going live?"
- "How do I design human approval gates for this agent?"
- "What should I monitor once this is running?"
- "What's the rollout posture — shadow mode, gated, full?"
- "What's the reversibility classification for this agent's actions?"

**Do not trigger on:**
- Eval design → use `agent-eval-design`
- Architecture decisions → use `agentic-system-design`

---

## Subagent Routing

Subagents run in isolated context and are invoked by skills when specialist analysis is needed.

| Subagent | Invoked by | Responsibility |
|---|---|---|
| `agent-systems-architect` | `agentic-system-design`, `multi-agent-orchestration` | Architecture decomposition, tradeoff analysis, context-boundary review |
| `agent-evals-auditor` | `agent-eval-design` | Audit-style eval inspection, evidence gathering, gap identification |

**Rules:**
- `agent-systems-architect` owns architecture. It does not assess eval quality or production gates.
- `agent-evals-auditor` owns eval audit. It does not make architecture recommendations.
- Subagents return structured findings. The parent skill synthesizes and presents to the user.
- Neither subagent spawns other subagents.

---

## Command-to-Skill Mapping

| Command | Primary skill | Subagent invoked |
|---|---|---|
| `/agentic-ai-engineering:setup-agentic-ai-engineering` | `setup-agentic-ai-engineering` | none |
| `/agentic-ai-engineering:agentic-plan` | `agentic-system-design` | `agent-systems-architect` (optional) |
| `/agentic-ai-engineering:agentic-arch-review` | `agentic-system-design` | `agent-systems-architect` |
| `/agentic-ai-engineering:agentic-evals` | `agent-eval-design` | `agent-evals-auditor` |
| `/agentic-ai-engineering:agentic-ops` | `deployment-readiness` | none |

---

## Host Support Matrix

| Host | Plugin loading | Skill auto-invoke | Subagents | Commands |
|---|---|---|---|---|
| Claude Code | plugin.json | Yes | Yes | Yes (namespaced) |
| Codex | — | Planned | Planned | Planned |
| Gemini | — | Planned | Planned | Planned |
| OpenCode | — | Planned | Planned | Planned |

For non-Claude Code hosts without plugin loading: place skills in the host's equivalent skill directory and use the routing intent table above.

---

## Anti-Patterns

Do not:
- Route a general "help me with my agent" request without first reading the specific intent
- Invoke multiple conflicting skills for the same request
- Let `agent-evals-auditor` make architecture recommendations
- Let `agent-systems-architect` assess eval quality
- Bypass `setup-agentic-ai-engineering` when a skill explicitly requires `eval_assets_path`
