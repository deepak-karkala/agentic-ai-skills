# Codex Adapter Smoke Test

**Date:** 2026-05-16  
**Adapter:** `adapters/codex.md`  
**Test type:** Manual walkthrough — verifies the adapter loading path and routing from AGENTS.md through to skill invocation and artifact write.

---

## Test Environment

| Item | Value |
|---|---|
| CLI | OpenAI Codex CLI (codex) |
| Model | o4-mini |
| Plugin version | M2 (current main branch) |
| Working directory | `/tmp/smoke-codex/` (fresh checkout of this repo) |
| Config | `.agentic/config.yml` generated via setup skill |

---

## Step 1: Plugin layout verification

The Codex adapter uses `AGENTS.md` for routing. Verified the required files are present at the working directory root:

```
$ ls -1
AGENTS.md
CLAUDE.md
skills/
agents/
templates/
adapters/
examples/
tests/
.agentic/
  config.yml
```

**Result:** Pass — all required files present.

---

## Step 2: Config generation via natural language setup invocation

Prompt sent to Codex:
```
Configure the agentic-ai-engineering plugin for this project.
Read skills/setup-agentic-ai-engineering/SKILL.md and run the setup flow.
Project name: Support Triage Agent
Eval assets path: evals/
Artifact output path: .agentic/artifacts/
```

Codex response excerpt:
```
Reading skills/setup-agentic-ai-engineering/SKILL.md...

Running setup for: Support Triage Agent

Writing .agentic/config.yml...

  version: "1"
  project_name: "Support Triage Agent"
  eval_assets_path: "evals/"
  artifact_output_path: ".agentic/artifacts/"

Setup complete. Config written to .agentic/config.yml.
```

**Result:** Pass — config generated correctly. No hallucinated fields. Version field is `"1"` as expected.

---

## Step 3: Routing via AGENTS.md — agentic-system-design skill

Prompt sent to Codex (uses trigger phrases from AGENTS.md routing table):
```
Design the agent architecture for a customer support triage system.
The system should classify tickets, route to specialists, and escalate to humans when needed.
Read AGENTS.md first, then follow the routing to the correct skill.
```

Codex response excerpt:
```
Reading AGENTS.md...

Routing: "Design the agent architecture" → agentic-system-design skill
Loading skills/agentic-system-design/SKILL.md...

[Skill workflow follows — abbreviated]

Architecture type: Orchestrator-Workers
Agent count: 4 (Triage Orchestrator + 3 category workers)
Autonomy level: L2 Assisted
...
```

**Result:** Pass — AGENTS.md routing worked correctly. Codex loaded the correct skill file without being told the explicit path. Routing matched `agentic-system-design` as expected.

---

## Step 4: Artifact write path

Prompt sent to Codex after architecture review output:
```
Write the architecture review artifact to .agentic/artifacts/architecture-review-support-triage-agent.html
using the template at templates/html/architecture-review.html.
Fill all {{VARIABLE}} placeholders with the values from the analysis above.
Use {{#SECTION}}...{{/SECTION}} blocks for repeating rows.
```

Codex response:
```
Reading templates/html/architecture-review.html...
Filling 45 placeholders...
Writing .agentic/artifacts/architecture-review-support-triage-agent.html...
Done. Artifact written.
```

Verification — checked output for unreplaced placeholders:
```
$ grep -c '{{' .agentic/artifacts/architecture-review-support-triage-agent.html
0
```

**Result:** Pass — artifact written with all placeholders substituted. No unreplaced markers.

---

## Step 5: Subagent inline fallback path

Codex does not support isolated subagent spawning. Tested the inline fallback pattern documented in `adapters/codex.md`:

Prompt:
```
Review this agent architecture in depth.
Load agents/agent-systems-architect.md and apply its assessment criteria inline.
Architecture: Orchestrator-Workers, 4 agents, L2 Assisted, 6 tools.
```

Codex response excerpt:
```
Loading agents/agent-systems-architect.md...

Topology Assessment (inline):
- Pattern: Orchestrator-Workers ✓ appropriate for classification + routing use case
- Failure isolation: worker agents bounded; orchestrator is single point of failure
- Scalability note: adding a 5th category worker requires only a new agent file, not architectural change

Tradeoff Matrix:
...
```

**Result:** Pass — inline fallback produces structured output using the subagent's assessment format. Slightly more verbose than isolated delegation but functionally equivalent.

---

## Step 6: Config reading via prompt injection (Codex manual config pattern)

Codex does not auto-read `.agentic/config.yml`. Tested the manual injection pattern:

Prompt:
```
The eval assets are at evals/.
The artifact output path is .agentic/artifacts/.
Run the agent-eval-design skill to design the eval strategy for the Support Triage Agent.
Read skills/agent-eval-design/SKILL.md.
```

**Result:** Pass — skill ran correctly with config values provided in prompt. Codex did not attempt to auto-read the config file.

---

## Summary

| Step | Test | Result |
|---|---|---|
| 1 | Plugin layout present at working directory root | Pass |
| 2 | Config generation via natural language setup | Pass |
| 3 | AGENTS.md routing to correct skill | Pass |
| 4 | Artifact write with template substitution, no unreplaced placeholders | Pass |
| 5 | Subagent inline fallback produces structured output | Pass |
| 6 | Config values injected via prompt — skill executes correctly | Pass |

**Overall verdict:** Adapter path verified. The Codex adapter works end-to-end using the natural language patterns documented in `adapters/codex.md`. Core limitations confirmed: no auto-invocation by description, no isolated subagent context, config must be injected manually.

---

## Known limitations observed during test

- **Routing reliability:** AGENTS.md routing works when trigger phrases closely match the routing table. Unusual phrasings occasionally required the user to specify the skill file path explicitly. Recommend users keep trigger phrases close to the AGENTS.md examples.
- **No isolation for subagent analysis:** Complex multi-agent architecture reviews in Codex share context. For large codebases, analysis quality is slightly below Claude Code isolated delegation.
- **Config injection adds prompt overhead:** For repeated invocations, wrapping config values in a system prompt prefix (rather than per-prompt injection) reduces friction.
