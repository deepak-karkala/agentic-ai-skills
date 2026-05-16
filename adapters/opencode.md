# OpenCode Adapter

Implementation-ready adapter spec for the `agentic-ai-engineering` plugin on OpenCode.

**Status:** Spec-complete. Ready to implement when OpenCode's plugin API stabilizes.

**Core `skills/` and `agents/` content is unchanged.** Only the loading layer differs.

---

## OpenCode architecture relevant to this adapter

OpenCode (opencode.ai) is an open-source AI coding agent that runs in the terminal. As of mid-2025, the key surfaces relevant to this adapter are:

| Surface | OpenCode | Relevant to adapter |
|---|---|---|
| Project instructions | `AGENTS.md` in working directory | Yes — same file, same format |
| Custom instructions file | `.opencode/instructions.md` | Skill content goes here |
| Slash commands | Not implemented as of mid-2025 | Entrypoints use natural language |
| Subagent / multi-context | Not implemented | Inline fallback |
| File writes | Yes | Same `.agentic/artifacts/` path |
| Config reads | Manual | Surface via instructions file |

OpenCode reads `AGENTS.md` from the working directory, which is identical to Codex behavior. This makes the adapter primarily a question of how to load skill content into the instruction surface.

---

## Required adapter files

These are the files that must be created or modified when implementing this adapter. None of them touch `skills/` or `agents/`.

```
.opencode/
└── instructions.md          ← NEW: skill loader instructions for OpenCode

adapters/
└── opencode.md              ← THIS FILE: adapter spec

(no changes to)
skills/                      ← unchanged
agents/                      ← unchanged
AGENTS.md                    ← unchanged (OpenCode reads this natively)
```

---

## Adapter implementation plan

### Step 1 — Create `.opencode/instructions.md`

This file is the adapter shim. It tells OpenCode how to find and use plugin skills.

**Required content:**

```markdown
# agentic-ai-engineering Plugin Instructions

When the user asks about agent architecture, evaluation strategy, deployment,
observability, product strategy, or any topic in the routing table below,
load and follow the matching skill.

## Loading a skill

1. Read the skill file: `skills/<skill-name>/SKILL.md`
2. Follow the workflow defined in the skill exactly
3. If the skill references a supporting file in `references/`, read it
4. Write any artifact output to `.agentic/artifacts/` unless a different
   path is configured in `.agentic/config.yml`

## Skill directory

[Include the intent-to-skill routing table from AGENTS.md here,
or reference: "See AGENTS.md for the full routing table."]

## Config

Read `.agentic/config.yml` if present. Use `eval_assets_path`,
`artifact_output_path`, and other fields per the skill's requirements.
If absent, use defaults documented in each skill's SKILL.md.
```

### Step 2 — Map commands to natural language

OpenCode does not support slash commands. Use the same natural language equivalents as the Codex adapter:

| Claude Code command | OpenCode natural language |
|---|---|
| `/agentic-ai-engineering:agentic-plan` | "Design the agent architecture for [description]" |
| `/agentic-ai-engineering:agentic-arch-review` | "Review this agent architecture" |
| `/agentic-ai-engineering:agentic-evals` | "Design the eval strategy for this agent" |
| `/agentic-ai-engineering:agentic-ops` | "Assess production readiness for this agent" |
| `/agentic-ai-engineering:agentic-opportunity-framing` | "Evaluate this use case for agent fit" |
| `/agentic-ai-engineering:agentic-product-strategy` | "Develop the product strategy for this agent product" |
| `/agentic-ai-engineering:agentic-economics-and-moats` | "Analyze the economics and moat for this agent product" |
| `/agentic-ai-engineering:agentic-governance-and-adoption` | "Design the governance and adoption plan for this agent" |
| `/agentic-ai-engineering:setup-agentic-ai-engineering` | "Configure the plugin for this project" |

Skills without a command wrapper (`agent-observability`, `single-agent-workflow-design`, `tool-interface-design`, `agentic-ubiquitous-language`) are auto-routed on Claude Code. On OpenCode, invoke them by describing the intent: "Design the observability strategy for this agent" — AGENTS.md routing will direct the model to the correct skill.

### Step 3 — Subagent fallback

OpenCode does not support multi-context subagent spawning. Use the same inline fallback as the Codex adapter:

1. Load the subagent file: `agents/agent-systems-architect.md` (or other)
2. Apply the subagent's assessment criteria in the same session
3. Produce output using the subagent's structured output format
4. The parent skill synthesizes and presents

### Step 4 — Config read

OpenCode does not auto-read `.agentic/config.yml`. Include a prompt in the instructions file that instructs OpenCode to read and use the config:

```markdown
## Config
At the start of each session, read .agentic/config.yml if it exists.
Use the values to set artifact output paths and skill behavior.
```

---

## Acceptance criteria for full implementation

When OpenCode's plugin API stabilizes enough to support the following, the adapter moves from spec to full implementation:

- [ ] `.opencode/instructions.md` created and tested with a real OpenCode session
- [ ] AGENTS.md routing confirmed working (OpenCode reads it without modification)
- [ ] At least 3 skills invoked end-to-end via natural language prompts
- [ ] At least 1 artifact written to `.agentic/artifacts/` from an OpenCode session
- [ ] Subagent inline fallback verified to produce correct output format
- [ ] Limitations table updated with any new OpenCode-specific constraints

---

## Adapter boundary

This adapter covers only the OpenCode-specific invocation layer. It does not:

- Modify any file in `skills/`, `agents/`, `templates/`, or `commands/`
- Change the rendering contract (`CONTRIBUTING.md`)
- Change `.agentic/config.yml` schema (version "1")
- Add new plugin capabilities — it only exposes existing capabilities on a new host

---

## Limitations vs. Claude Code

| Feature | Claude Code | OpenCode (current) |
|---|---|---|
| Auto-invocation by intent | Yes (description field) | No — AGENTS.md routing only |
| Isolated subagent context | Yes | No — inline fallback |
| Namespaced commands | Yes | No — natural language |
| Plugin manifest auto-loading | Yes | No — instructions.md shim |
| Config auto-read | Yes | No — manual prompt |
| File writes | Yes | Yes |

When OpenCode implements a plugin API, this adapter should be upgraded from instructions.md shim to a proper manifest-based integration, matching Claude Code's auto-invocation behavior.
