# Codex Adapter

Adapter guide for using the `agentic-ai-engineering` plugin with the OpenAI Codex CLI.

**Core `skills/` and `agents/` content is unchanged.** Only the loading and invocation layer differs from Claude Code.

---

## What Codex supports natively

| Capability | Codex CLI | Notes |
|---|---|---|
| Plugin manifest (plugin.json) | No | Not applicable |
| AGENTS.md routing | Yes | Codex reads AGENTS.md in the working directory |
| Slash commands | No | Use natural language equivalents |
| Subagent spawning | No | Inline fallback — see below |
| File writes (artifacts) | Yes | Same `.agentic/artifacts/` path |
| Config reads (.agentic/config.yml) | Manual | Codex does not auto-read config; surface values in the prompt |

---

## Setup

**Step 1 — Clone or copy the plugin into your project directory.**

The Codex CLI picks up `AGENTS.md` from the working directory. Place the plugin repo at your project root or use a symlink:

```
your-project/
├── AGENTS.md              ← routing guidance (from this repo)
├── skills/                ← skill content (from this repo)
├── agents/                ← subagent content (from this repo)
├── .agentic/
│   └── config.yml         ← run setup skill first to generate
└── <your project files>
```

If you don't want to merge the plugin into your project, clone it as a sibling directory and reference `AGENTS.md` explicitly in your Codex system prompt.

**Step 2 — Run setup to generate `.agentic/config.yml`.**

Invoke the setup skill in natural language:

```
Configure the agentic-ai-engineering plugin for this project.
Read skills/setup-agentic-ai-engineering/SKILL.md and run the setup flow.
```

**Step 3 — Invoke skills by description.**

Codex reads `AGENTS.md` for routing. Use natural language that matches the skill's trigger phrases. The routing table in `AGENTS.md` will guide Codex to the right `skills/<skill-name>/SKILL.md`.

---

## Command equivalents

Claude Code slash commands map to natural language prompts for Codex:

| Claude Code command | Codex natural language equivalent |
|---|---|
| `/agentic-ai-engineering:agentic-plan` | "Design the agent system for [description]. Read skills/agentic-system-design/SKILL.md." |
| `/agentic-ai-engineering:agentic-arch-review` | "Review the existing agent architecture. Read skills/agentic-system-design/SKILL.md." |
| `/agentic-ai-engineering:agentic-evals` | "Design the eval strategy. Read skills/agent-eval-design/SKILL.md." |
| `/agentic-ai-engineering:agentic-ops` | "Assess production readiness. Read skills/deployment-readiness/SKILL.md." |
| `/agentic-ai-engineering:agentic-opportunity-framing` | "Evaluate this use case for agent fit. Read skills/agentic-opportunity-framing/SKILL.md." |
| `/agentic-ai-engineering:agentic-product-strategy` | "Develop the product strategy. Read skills/agentic-product-strategy/SKILL.md." |

For any skill, the pattern is: describe the intent using the trigger phrases in `AGENTS.md`, then explicitly reference the skill file if Codex does not load it automatically.

---

## Subagent fallback pattern

Codex does not support spawning subagents in isolated contexts. When a Claude Code workflow would delegate to `agent-systems-architect`, `agent-evals-auditor`, or `agent-product-strategist`, use the inline fallback:

1. Load the subagent file directly: `agents/agent-systems-architect.md`
2. Apply its assessment criteria and output format inline in the same session
3. The parent skill's synthesis step proceeds as normal

**What this means in practice:** The structured output format (Topology Assessment, Tradeoff Matrix, etc.) defined in the subagent file still applies — it just runs in the same context rather than an isolated one. Quality is slightly reduced for complex analyses because the context is shared, not isolated.

---

## Artifact write path

Codex can write files. When a skill produces an artifact:

1. Use the output path from `.agentic/config.yml` (`artifact_output_path`), or default to `.agentic/artifacts/`
2. Filename follows the convention: `<artifact-type>-<agent-name>.<ext>` (see `CONTRIBUTING.md`)
3. HTML templates are in `templates/html/`; markdown templates in `templates/markdown/`

```
Write the architecture review artifact to .agentic/artifacts/architecture-review-<agent-name>.html
using the template at templates/html/architecture-review.html.
Fill all {{VARIABLE}} placeholders. Use {{#SECTION}}...{{/SECTION}} blocks for repeating rows.
```

---

## Config reading

Codex does not auto-read `.agentic/config.yml`. Surface the relevant fields in your prompt:

```
The eval assets are at evals/.
The artifact output path is .agentic/artifacts/.
Run the agent-eval-design skill using these paths.
```

Alternatively, include the config values in a system prompt prefix so Codex has them in context before skill invocation.

---

## Limitations vs. Claude Code

| Feature | Claude Code | Codex |
|---|---|---|
| Auto-invocation by intent | Yes (description field) | Manual — user must reference skill |
| Isolated subagent context | Yes | No — inline fallback only |
| Namespaced commands | Yes | No — natural language only |
| Plugin manifest auto-loading | Yes | No — AGENTS.md routing only |
| Config auto-read | Yes | No — surface values in prompt |

The skill and agent content is identical. Only the invocation and isolation mechanisms differ.
