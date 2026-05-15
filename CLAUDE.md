# CLAUDE.md

This file provides Claude Code-specific guidance when the `agentic-ai-engineering` plugin is active.

For general agent routing rules, see [AGENTS.md](AGENTS.md).

## Plugin Namespace

Plugin name: `agentic-ai-engineering`

All skills are accessible as `/agentic-ai-engineering:<skill-name>`.

## Skill Auto-Invocation

Claude Code loads skills automatically when user intent matches a skill's `description` field. The plugin's skills are designed to be auto-invoked by intent, not only on explicit commands.

When a user asks about agent architecture, context engineering, multi-agent design, evaluation strategy, or production deployment, check the AGENTS.md routing table and load the matching skill before responding. Do not answer these questions from general knowledge alone — the skills contain source-backed decision frameworks that are more accurate and defensible.

## When to Use the Setup Skill First

Run `/agentic-ai-engineering:setup-agentic-ai-engineering` before other skills when:

- The user is starting a new agentic AI project in this repo
- The user asks you to run eval-related skills and `.agentic/config.yml` does not exist
- `agent-eval-design` is about to run and `eval_assets_path` is not configured

Skills that are purely conversational (architecture design, context engineering, multi-agent topology) do not require setup. They degrade gracefully without `.agentic/config.yml`.

## HTML Artifact Generation

When a flagship skill produces an HTML artifact (architecture review, eval scorecard), write it to the path specified in `.agentic/config.yml` under `artifact_output_path`. If that field is absent, write to `.agentic/artifacts/` by default and note the location to the user.

After writing an HTML artifact, tell the user the file path and suggest opening it in a browser.

## Subagent Delegation

The plugin includes specialist subagents. Subagents return structured findings — synthesize their output and present it in the parent skill's output format. Do not present raw subagent dumps to the user.

**Milestone 1 subagents (active):**
- `agent-systems-architect`: delegate architecture decomposition tasks here when deeper isolated analysis is needed. Invoke from `agentic-system-design` or `multi-agent-orchestration` skills. Never invoke for greenfield design.
- `agent-evals-auditor`: delegate eval audit tasks here. Invoke from `agent-eval-design` skill. Only when eval artifacts exist.

**Milestone 2 subagents (implemented when skills are built):**
- `agent-product-strategist`: delegate product strategy and opportunity reviews here when non-trivial. Invoke from `agentic-opportunity-framing` or `agentic-product-strategy` skills.
- `agent-artifact-designer`: delegate artifact composition here only when artifact complexity exceeds simple `{{VARIABLE}}` substitution. Gated — see M2 Task 17 in implementation plan.

## Config Field Consumption Map

Skills read from `.agentic/config.yml`. Active consumers are Milestone 1 skills only. Planned M2 consumers are listed separately so this map stays accurate as skills are added.

### Active consumers (Milestone 1)

| Field | Required by | Optional improvement for | Notes |
|---|---|---|---|
| `eval_assets_path` | `agent-eval-design` (audit mode) | — | Only hard dependency in the plugin |
| `design_docs_path` | — | `agentic-system-design`, `multi-agent-orchestration` | Skills read existing docs before generating recommendations |
| `artifact_output_path` | — | `agentic-system-design` (HTML artifact) | Falls back to `.agentic/artifacts/` if absent |
| `adr_path` | — | `agentic-system-design` | Provides ADR context for architecture decisions |
| `agent_source_path` | — | — | No Milestone 1 skill reads this |
| `trace_log_path` | — | — | No Milestone 1 skill reads this |
| `glossary_path` | — | — | No Milestone 1 skill reads this |

### Planned consumers (Milestone 2 — not yet implemented)

| Field | Planned consumer | When |
|---|---|---|
| `design_docs_path` | `single-agent-workflow-design`, `agentic-to-issues`, `agentic-prototype`, `agentic-handoff` | When each M2 skill is implemented |
| `artifact_output_path` | All M2 artifact-generating skills | When each artifact skill is implemented |
| `agent_source_path` | `tool-interface-design` | When M2 Task 14 is implemented |
| `trace_log_path` | `agent-observability` | When M2 Task 16 is implemented |
| `glossary_path` | `agentic-ubiquitous-language` | When M2 Task 4 is implemented |

**Contract stability:** The schema is `version: "1"`. No new fields are required for Milestone 2 — all planned M2 consumers use existing fields. Skills must read fields they use and ignore fields they don't. Do not add new fields to the schema without running setup again and bumping the version comment.

## Portability Note

The skill and agent content in this plugin is host-agnostic. The Claude Code-specific behavior (namespaced commands, subagent invocation, artifact file writes, `.agentic/config.yml` reads) is the thin adapter layer. If porting to another host, adapt this file and AGENTS.md; the `skills/` and `agents/` content transfers unchanged.
