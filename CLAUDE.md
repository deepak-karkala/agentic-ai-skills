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

**Milestone 2 subagents (active):**
- `agent-product-strategist`: delegate opportunity decomposition, wedge scoring, adoption constraint analysis, and governance risk assessment here when non-trivial. Invoke from `agentic-opportunity-framing` or `agentic-product-strategy` skills. Never invoke for greenfield brainstorming, architecture decisions, or eval design.

**Milestone 2 subagents (deferred):**
- `agent-artifact-designer`: **Gate not met — deferred to a later milestone.** Gate requires ≥2 of the 4 Phase 5 artifacts (Tasks 20–23) to need dynamic section selection, multi-table composition, or conditional rendering beyond simple `{{VARIABLE}}` substitution. Phase 5 has not been implemented; gate cannot be evaluated. Do not implement until Phase 5 artifacts are built and the gate is re-evaluated.

### Per-Skill Delegation Rules

Use this table to decide whether to stay inline or delegate to a subagent. Delegation is evidence-based — invoke a subagent only when inline analysis would flood the conversation with detail the user doesn't need to see.

| Skill | When to delegate | Subagent | When to stay inline |
|---|---|---|---|
| `agentic-system-design` | Non-trivial architecture with an existing design to review; decomposition would exceed ~500 tokens | `agent-systems-architect` | Greenfield design; simple single-agent; user provided minimal context |
| `multi-agent-orchestration` | Complex multi-agent topology requiring independent structural read before recommendations | `agent-systems-architect` | Straightforward topology; user asking conceptual question only |
| `agent-eval-design` | Existing eval suite to audit; `eval_assets_path` is configured and contains artifacts | `agent-evals-auditor` | Greenfield eval design; no eval artifacts exist |
| `agentic-opportunity-framing` | Scoring all 7 process-fit traits for a specific non-trivial use case would exceed ~500 tokens inline | `agent-product-strategist` | Simple use case with obvious verdict; user asking one or two dimensions only |
| `agentic-product-strategy` | Wedge scoring across all 7 dimensions with sourced reasoning; adoption constraints require specific org/industry mapping | `agent-product-strategist` | High-level strategic question; user has already scored the wedge and wants synthesis |
| `agentic-economics-and-moats` | — | none — stays inline | All analysis inline |
| `agentic-governance-and-adoption` | — | none — stays inline | All analysis inline |
| `tool-interface-design` | — | none — stays inline | All analysis inline |
| `single-agent-workflow-design` | — | none — stays inline | All analysis inline |
| `agent-observability` | — | none — stays inline | All analysis inline |

**Structured output requirement:** When a subagent is invoked, the parent skill must synthesize its structured output into the parent's own output format. Never surface raw subagent output to the user — synthesize it into the parent skill's artifact.

## Config Field Consumption Map

Skills read from `.agentic/config.yml`. This map reflects the current implemented state of the plugin after Milestone 1 and Milestone 2 Phases 1–3.

### Active consumers (all implemented)

| Field | Required by | Optional improvement for | Notes |
|---|---|---|---|
| `eval_assets_path` | `agent-eval-design` (audit mode) | — | Only hard dependency in the plugin |
| `design_docs_path` | — | `agentic-system-design`, `multi-agent-orchestration`, `agentic-to-issues`, `agentic-handoff`, `single-agent-workflow-design` | Skills read existing docs before generating recommendations |
| `artifact_output_path` | — | `agentic-system-design` (HTML artifact), `agentic-to-issues`, `agentic-prototype`, `agentic-handoff`, `agentic-opportunity-framing`, `agentic-product-strategy`, `agentic-economics-and-moats`, `agentic-governance-and-adoption`, `tool-interface-design`, `single-agent-workflow-design`, `agent-observability` | Falls back to `.agentic/artifacts/` if absent |
| `adr_path` | — | `agentic-system-design` | Provides ADR context for architecture decisions |
| `glossary_path` | — | `agentic-ubiquitous-language` | Reads existing glossary before generating; extends rather than replaces |
| `agent_source_path` | — | `tool-interface-design` | Writes interface spec to `agent_source_path/tools/interface-spec.md`; falls back to `.agentic/artifacts/` |
| `trace_log_path` | — | `agent-observability` | Reads existing traces when available; falls back to greenfield mode |

**No planned-only consumers remain.** All 7 config fields are now read by at least one implemented skill. The schema is `version: "1"` and is complete — no new fields are required for remaining Milestone 2 work. Skills must read fields they use and ignore fields they don't. Do not add new fields without running setup again and bumping the version comment.

## Portability Note

The skill and agent content in this plugin is host-agnostic. The Claude Code-specific behavior (namespaced commands, subagent invocation, artifact file writes, `.agentic/config.yml` reads) is the thin adapter layer. If porting to another host, adapt this file and AGENTS.md; the `skills/` and `agents/` content transfers unchanged.
