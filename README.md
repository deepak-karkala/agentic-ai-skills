# agentic-ai-engineering

Decision compression for agentic AI engineering.

A plugin for Claude Code and compatible coding agents that provides senior engineer, staff engineer, tech lead, and CTO-level domain expertise for building production-grade agentic AI products.

---

## What this plugin does

It answers the hard questions quickly:

- Which agent architecture should I use?
- When should I use single-agent vs multi-agent?
- How should tools, memory, and context be designed?
- What are the tradeoffs between reliability, latency, and cost?
- How do I evaluate agent quality in a defensible way?
- What production failure modes should I expect?
- What guardrails are required?
- What is the rollout and incident-response posture?

The plugin provides opinionated decision frameworks, playbooks, anti-pattern detectors, checklists, architecture templates, and HTML artifacts — not generic AI advice.

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

Codex, Gemini, and OpenCode support is planned. The core skill content is host-agnostic. See the host support matrix in [AGENTS.md](AGENTS.md).

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

---

## Skills

| Skill | Category | What it handles |
|---|---|---|
| `setup-agentic-ai-engineering` | Setup | One-time per-repo config for paths and project context |
| `agentic-system-design` | Architecture | Architecture decisions, agent vs pipeline, autonomy levels, orchestration |
| `context-engineering-for-agents` | Architecture | Context design, memory tiers, write/select/compress/isolate, context failure modes |
| `multi-agent-orchestration` | Architecture | Topology selection, handoff contracts, coordination anti-patterns |
| `agent-eval-design` | Reliability | Eval strategy, scorecard design, grader types, regression testing |
| `deployment-readiness` | Production | Production gates, guardrails, HITL design, rollout posture |

---

## Subagents

| Agent | What it does |
|---|---|
| `agent-systems-architect` | Isolated architecture decomposition and tradeoff analysis |
| `agent-evals-auditor` | Audit-style eval inspection and evidence gathering |

---

## Repo Structure

```
.
├── .claude-plugin/plugin.json     # Plugin manifest
├── skills/                        # Domain skills
├── agents/                        # Specialist subagents
├── commands/                      # User-facing entry point wrappers
├── templates/html/                # HTML artifact templates
├── templates/markdown/            # Markdown artifact templates
├── examples/scenarios/            # Worked example scenarios
├── examples/outputs/              # Example skill outputs
└── tests/                         # Validation harness
```

---

## Host Support

| Host | Status |
|---|---|
| Claude Code | Milestone 1 — primary target |
| Codex | Planned |
| Gemini | Planned |
| OpenCode | Planned |

Core skill content is host-agnostic. Host-specific routing adapters are thin wrappers generated after the core is stable.

---

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for the skill authoring contract, frontmatter standards, and packaging rules.
