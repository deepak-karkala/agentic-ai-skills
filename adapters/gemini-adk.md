# Gemini / ADK Adapter

Adapter guide for using the `agentic-ai-engineering` plugin with Google Gemini models via the Agent Development Kit (ADK).

**Core `skills/` and `agents/` content is unchanged.** Only the loading and invocation layer differs from Claude Code.

---

## What Gemini / ADK supports natively

| Capability | Gemini + ADK | Notes |
|---|---|---|
| Plugin manifest (plugin.json) | No | ADK uses Python agent definitions |
| AGENTS.md routing | Partial | Must be injected into agent instructions |
| Slash commands | No | Use Python entrypoints or natural language |
| Subagent spawning | Yes (AgentTool) | ADK supports multi-agent; see below |
| File writes (artifacts) | Yes | Same `.agentic/artifacts/` path |
| Config reads (.agentic/config.yml) | Manual | Load and inject config values in agent setup |

---

## Setup

**Step 1 — Install ADK.**

```bash
pip install google-adk
```

**Step 2 — Create an agent that loads skill content.**

The adapter pattern wraps the plugin's skill content as ADK agent instructions. Create a minimal agent file:

```python
# agentic_ai_agent.py
from google.adk.agents import Agent
from pathlib import Path

def load_skill(skill_name: str) -> str:
    skill_path = Path(f"skills/{skill_name}/SKILL.md")
    return skill_path.read_text() if skill_path.exists() else ""

def load_routing() -> str:
    return Path("AGENTS.md").read_text()

# Load the routing table and a target skill into the agent instructions
routing = load_routing()
skill_content = load_skill("agentic-system-design")  # swap per use case

root_agent = Agent(
    name="agentic_ai_engineer",
    model="gemini-2.0-flash",
    instruction=f"""
You are an agentic AI engineering assistant.
Use the routing table below to identify the correct skill for any request.
Follow the skill workflow exactly.

--- ROUTING TABLE ---
{routing}

--- SKILL ---
{skill_content}
""",
)
```

**Step 3 — Run the agent.**

```bash
adk run agentic_ai_agent.py
```

Or invoke via the ADK web UI:
```bash
adk web
```

---

## Manifest mapping

ADK does not use `plugin.json`. The equivalent configuration is the agent's `name` and `model` fields. There is no global plugin registry — each agent file is a standalone entrypoint.

If you want multiple skills accessible in one session, load all skill content into the instruction and rely on the routing table to direct the model to the right workflow.

---

## Entrypoint mapping

Each Claude Code command maps to a Python function or a separate agent configuration:

| Claude Code command | ADK equivalent |
|---|---|
| `/agentic-ai-engineering:agentic-plan` | `Agent(instruction=load_skill("agentic-system-design"), ...)` |
| `/agentic-ai-engineering:agentic-arch-review` | Same skill, triggered with "review this architecture" prompt |
| `/agentic-ai-engineering:agentic-evals` | `Agent(instruction=load_skill("agent-eval-design"), ...)` |
| `/agentic-ai-engineering:agentic-ops` | `Agent(instruction=load_skill("deployment-readiness"), ...)` |
| `/agentic-ai-engineering:agentic-opportunity-framing` | `Agent(instruction=load_skill("agentic-opportunity-framing"), ...)` |
| `/agentic-ai-engineering:agentic-product-strategy` | `Agent(instruction=load_skill("agentic-product-strategy"), ...)` |

For a multi-skill setup, build a router agent that reads `AGENTS.md` and delegates to per-skill sub-agents using `AgentTool`.

---

## Subagent pattern with ADK

ADK supports multi-agent workflows via `AgentTool`. This maps directly to the plugin's subagent pattern:

```python
from google.adk.agents import Agent
from google.adk.tools import AgentTool

# Specialist subagent — equivalent to agents/agent-systems-architect.md
architect_agent = Agent(
    name="agent_systems_architect",
    model="gemini-2.0-flash",
    instruction=Path("agents/agent-systems-architect.md").read_text(),
)

# Parent skill agent — equivalent to agentic-system-design skill
system_design_agent = Agent(
    name="agentic_system_design",
    model="gemini-2.0-flash",
    instruction=Path("skills/agentic-system-design/SKILL.md").read_text(),
    tools=[AgentTool(agent=architect_agent)],
)
```

**Delegation rule:** Apply the same threshold as Claude Code — delegate to the specialist agent only when inline analysis would exceed ~500 tokens of detail. The delegation table in `CLAUDE.md` (Per-Skill Delegation Rules) applies unchanged.

**Output format:** The specialist subagent returns structured findings using the output format defined in the `agents/*.md` file. The parent skill synthesizes these findings — never surfaces raw subagent output to the user.

---

## Artifact output guidance

ADK agents can write files using Python's standard `open()` or the ADK file tool. When a skill produces an artifact:

1. Read the artifact output path from `.agentic/config.yml`, or default to `.agentic/artifacts/`
2. Load the template from `templates/html/` or `templates/markdown/`
3. Perform `{{VARIABLE}}` substitution and `{{#SECTION}}...{{/SECTION}}` block rendering
4. Write the filled artifact to the output path

```python
import re
from pathlib import Path

def fill_template(template_path: str, variables: dict, sections: dict) -> str:
    content = Path(template_path).read_text()
    # Scalar substitution
    for key, value in variables.items():
        content = content.replace(f"{{{{{key}}}}}", str(value))
    # Block repetition
    for section_name, rows in sections.items():
        pattern = rf"\{{\{{#{section_name}\}}\}}(.*?)\{{\{{/{section_name}\}}\}}"
        block = re.search(pattern, content, re.DOTALL)
        if block:
            inner = block.group(1)
            rendered = "".join(
                re.sub(r"\{\{(\w+)\}\}", lambda m: row.get(m.group(1), ""), inner)
                for row in rows
            )
            content = content[:block.start()] + rendered + content[block.end():]
    return content
```

---

## Config reading

Load `.agentic/config.yml` in the agent setup script and inject the relevant values into the agent instruction:

```python
import yaml
from pathlib import Path

config = {}
config_path = Path(".agentic/config.yml")
if config_path.exists():
    config = yaml.safe_load(config_path.read_text())

eval_assets_path = config.get("eval_assets_path", "evals/")
artifact_output_path = config.get("artifact_output_path", ".agentic/artifacts/")
```

Pass these values to the agent instruction or as tool parameters so the skill can use them without prompting the user.

---

## Limitations vs. Claude Code

| Feature | Claude Code | Gemini + ADK |
|---|---|---|
| Auto-invocation by intent | Yes (description field) | No — explicit agent per skill or router agent |
| Isolated subagent context | Yes | Yes (AgentTool) — closest match |
| Namespaced commands | Yes | No — Python entrypoints |
| Plugin manifest auto-loading | Yes | No — manual agent setup |
| Config auto-read | Yes | No — manual load in setup script |
| Streaming output | Yes | Yes |

Subagent isolation is the strongest match to Claude Code behavior. All other invocation mechanisms require an explicit adapter layer.
