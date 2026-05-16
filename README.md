# agentic-ai-engineering

Decision compression for agentic AI engineering.

A plugin for Claude Code and compatible coding agents that provides senior engineer, staff engineer, tech lead, and CTO-level domain expertise for building production-grade agentic AI products.

---

## What this plugin does

It answers the hard questions quickly — across the full lifecycle of an agentic AI product:

**Before you build:**
- Is this use case a good fit for an agent? (process-fit scoring, disqualifier check)
- What's the product strategy and wedge position? (ICP, GTM, moat layers)
- What are the unit economics and moat depth? (inference cost, CM LTV, data flywheel)
- What governance controls and regulatory requirements apply?

**While you build:**
- Which agent architecture should I use? (single vs multi, pattern selection)
- How should tools, memory, and context be designed?
- What control flow and step sequence should each agent follow?
- How do I design tool interfaces and MCP wiring?
- How do I evaluate agent quality in a defensible way?

**Before and after you ship:**
- What production failure modes should I expect?
- What guardrails and HITL gates are required?
- What should I trace and circuit-break?
- What is the rollout and incident-response posture?

The plugin provides opinionated decision frameworks, playbooks, anti-pattern detectors, checklists, architecture templates, and HTML/Markdown artifacts — not generic AI advice.

---

## Installation

### Claude Code

```bash
claude plugin install https://github.com/deepak-karkala/agentic-ai-engineering
```

For local development and testing:

```bash
claude --plugin-dir /path/to/agentic-ai-engineering
```

### Other hosts

Adapter guides for Codex, Gemini/ADK, and OpenCode are in the `adapters/` directory. The core `skills/` and `agents/` content is host-agnostic — only the invocation layer differs. See the full host support matrix in [AGENTS.md](AGENTS.md).

---

## Entry Points

Run these commands to invoke the plugin's main workflows:

| Command | What it does |
|---|---|
| `/agentic-ai-engineering:setup-agentic-ai-engineering` | One-time repo config — establishes paths that downstream skills read |
| `/agentic-ai-engineering:agentic-plan` | Design an agent system from scratch |
| `/agentic-ai-engineering:agentic-arch-review` | Review an existing agent architecture |
| `/agentic-ai-engineering:agentic-evals` | Design or audit the evaluation strategy |
| `/agentic-ai-engineering:agentic-ops` | Assess production readiness and deployment posture |
| `/agentic-ai-engineering:agentic-opportunity-framing` | Evaluate a use case for agent fit before committing to build |
| `/agentic-ai-engineering:agentic-product-strategy` | Develop product strategy, wedge position, and ICP for an agent product |
| `/agentic-ai-engineering:agentic-economics-and-moats` | Quantify unit economics, moat depth, and data flywheel potential |
| `/agentic-ai-engineering:agentic-governance-and-adoption` | Design governance controls, HITL policy, and adoption plan |
| `/agentic-ai-engineering:agentic-to-issues` | Convert an architecture design into structured GitHub issues |
| `/agentic-ai-engineering:agentic-prototype` | Scope a minimal working prototype from an agent design |
| `/agentic-ai-engineering:agentic-handoff` | Produce a structured handoff artifact from a completed agent project |

Skills without a command wrapper (`single-agent-workflow-design`, `tool-interface-design`, `agent-observability`, `agentic-ubiquitous-language`) are auto-routed by intent — describe what you need and the plugin selects the right skill.

---

## Skills

| Skill | Lane | What it handles |
|---|---|---|
| `setup-agentic-ai-engineering` | Setup | One-time per-repo config for paths and project context |
| `agentic-opportunity-framing` | Strategy | Process-fit scoring, disqualifier check, build/don't-build filter |
| `agentic-product-strategy` | Strategy | Wedge score, ICP definition, GTM framing, moat layer prioritization |
| `agentic-economics-and-moats` | Strategy | Unit economics, inference cost, CM2, LTV, data flywheel, moat depth |
| `agentic-governance-and-adoption` | Strategy | Governance controls, regulatory mapping, HITL policy, adoption plan |
| `agentic-system-design` | Architecture | Architecture decisions, agent vs pipeline, autonomy levels, orchestration |
| `context-engineering-for-agents` | Architecture | Context design, memory tiers, write/select/compress/isolate, context failure modes |
| `multi-agent-orchestration` | Architecture | Topology selection, handoff contracts, coordination anti-patterns |
| `single-agent-workflow-design` | Architecture | Control flow pattern selection, step sequencing, error recovery design |
| `tool-interface-design` | Architecture | Tool schema design, ACI non-use examples, permission tiers, MCP wiring |
| `agentic-ubiquitous-language` | Architecture | Shared vocabulary, glossary artifact, term disambiguation |
| `agent-eval-design` | Reliability | Eval strategy, six-dimension scorecard, grader types, regression testing |
| `agent-observability` | Reliability | Trace design, span taxonomy, circuit breakers, alert thresholds |
| `deployment-readiness` | Production | Production gates, guardrails, HITL design, rollout posture |
| `agentic-to-issues` | Workflow | Architecture-to-GitHub-issues translation with acceptance criteria |
| `agentic-prototype` | Workflow | Minimal prototype scoping from an agent design |
| `agentic-handoff` | Workflow | Structured handoff artifact from a completed agent project |

---

## Subagents

| Agent | What it does |
|---|---|
| `agent-systems-architect` | Isolated architecture decomposition and tradeoff analysis |
| `agent-evals-auditor` | Audit-style eval inspection and evidence gathering |
| `agent-product-strategist` | Opportunity decomposition, wedge scoring, adoption constraint analysis, governance risk |

---

## Repo Structure

```
.
├── .claude-plugin/plugin.json     # Plugin manifest
├── skills/                        # Domain skills (17 skills across 6 lanes)
├── agents/                        # Specialist subagents (3)
├── commands/                      # User-facing entry point wrappers (11)
├── adapters/                      # Host adapter guides (Codex, Gemini/ADK, OpenCode)
├── templates/html/                # HTML artifact templates (3)
├── templates/markdown/            # Markdown artifact templates (2)
├── examples/scenarios/            # Worked example scenarios
├── examples/outputs/              # Example skill outputs
└── tests/                         # Validation harness
```

---

## Host Support

| Host | Status | Adapter |
|---|---|---|
| Claude Code | Primary — full support | Native (plugin.json) |
| Codex | Adapter shipped | [`adapters/codex.md`](adapters/codex.md) |
| Gemini / ADK | Adapter shipped | [`adapters/gemini-adk.md`](adapters/gemini-adk.md) |
| OpenCode | Spec complete | [`adapters/opencode.md`](adapters/opencode.md) |

Core `skills/` and `agents/` content is host-agnostic. Each adapter documents the invocation layer differences without modifying skill content.

---

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for the skill authoring contract, frontmatter standards, and packaging rules.
