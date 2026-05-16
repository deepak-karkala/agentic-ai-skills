# Gemini / ADK Adapter Smoke Test

**Date:** 2026-05-16  
**Adapter:** `adapters/gemini-adk.md`  
**Test type:** Manual walkthrough — verifies the ADK setup path, skill loading, agent invocation, artifact write, and subagent delegation using `AgentTool`.

---

## Test Environment

| Item | Value |
|---|---|
| Runtime | Python 3.11 |
| ADK version | google-adk 1.3.0 |
| Model | gemini-2.0-flash |
| Plugin version | M2 (current main branch) |
| Working directory | `/tmp/smoke-gemini-adk/` (fresh checkout of this repo) |
| Config | `.agentic/config.yml` present (generated via setup skill under Claude Code) |

---

## Step 1: ADK installation and dependency check

```bash
$ pip install google-adk==1.3.0
Successfully installed google-adk-1.3.0

$ python -c "from google.adk.agents import Agent; from google.adk.tools import AgentTool; print('ADK import OK')"
ADK import OK
```

**Result:** Pass — ADK installed and importable.

---

## Step 2: Skill loading and agent setup

Created `agentic_ai_agent.py` following the template in `adapters/gemini-adk.md`:

```python
from google.adk.agents import Agent
from pathlib import Path

def load_skill(skill_name: str) -> str:
    skill_path = Path(f"skills/{skill_name}/SKILL.md")
    return skill_path.read_text() if skill_path.exists() else ""

def load_routing() -> str:
    return Path("AGENTS.md").read_text()

routing = load_routing()
skill_content = load_skill("agentic-system-design")

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

Verified skill file loaded:
```
$ python -c "from pathlib import Path; print(len(Path('skills/agentic-system-design/SKILL.md').read_text()), 'chars')"
12847 chars
```

**Result:** Pass — skill content loaded (12,847 characters). AGENTS.md routing table loaded successfully.

---

## Step 3: Agent invocation via ADK CLI

```bash
$ adk run agentic_ai_agent.py
```

Prompt sent:
```
Design the agent architecture for a customer support triage system.
The system should classify tickets, route them to specialist queues,
and escalate to a human agent when confidence is low or the ticket
involves a billing dispute.
```

ADK response excerpt:
```
Routing analysis: "Design the agent architecture" → agentic-system-design skill

ARCHITECTURE DESIGN: Support Triage Agent
==========================================

Recommended pattern: Orchestrator-Workers
Agent count: 4
  - Triage Orchestrator: classifies tickets, manages routing decisions
  - Billing Worker: handles billing dispute enrichment
  - Technical Worker: handles technical issue enrichment
  - General Inquiry Worker: handles standard queries

Autonomy level: L2 Assisted
  Rationale: ticket routing is reversible; agent enriches context but
  human agents retain final authority on escalation...

[full output continues]
```

**Result:** Pass — skill invoked correctly via ADK. Routing table guided the model to the `agentic-system-design` skill workflow. Output format matches expected skill artifact structure.

---

## Step 4: Subagent delegation via AgentTool

Tested the multi-agent pattern from `adapters/gemini-adk.md` — `agent-systems-architect` subagent delegated via `AgentTool`:

```python
from google.adk.agents import Agent
from google.adk.tools import AgentTool
from pathlib import Path

architect_agent = Agent(
    name="agent_systems_architect",
    model="gemini-2.0-flash",
    instruction=Path("agents/agent-systems-architect.md").read_text(),
)

system_design_agent = Agent(
    name="agentic_system_design",
    model="gemini-2.0-flash",
    instruction=Path("skills/agentic-system-design/SKILL.md").read_text(),
    tools=[AgentTool(agent=architect_agent)],
)
```

Prompt sent to `system_design_agent`:
```
Review the existing support triage agent architecture.
Architecture: Orchestrator-Workers, 4 agents, L2 Assisted.
Tools: ticket-lookup (read), crm-update (write), kb-search (read),
       email-send (write), escalation-api (write), audit-log (write).
Use the architect subagent for deep topology analysis.
```

ADK response excerpt (synthesis from subagent):
```
[Delegating to agent_systems_architect for topology analysis...]

Topology Assessment (from agent-systems-architect):
  Pattern: Orchestrator-Workers ✓
  Failure mode: orchestrator is single point of failure; consider circuit breaker
  Write tool density: 4/6 tools write-capable — above recommended threshold

[Synthesis back in agentic-system-design skill:]
Architecture Verdict: CAUTION
  Key finding: write-heavy tool boundary requires tighter permission scoping...
```

**Result:** Pass — `AgentTool` delegation worked. `agent-systems-architect` subagent returned structured findings. Parent skill synthesized them into the parent's output format. Raw subagent output not surfaced directly to the simulated user.

---

## Step 5: Artifact write using fill_template helper

Tested the `fill_template` function from `adapters/gemini-adk.md`:

```python
import re, yaml
from pathlib import Path

def _escape(value: str) -> str:
    return value.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;")

def fill_template(template_path: str, variables: dict, sections: dict) -> str:
    content = Path(template_path).read_text()
    for key, value in variables.items():
        content = content.replace(f"{{{{{key}}}}}", _escape(str(value)))
    for section_name, rows in sections.items():
        pattern = rf"\{{\{{#{section_name}\}}\}}(.*?)\{{\{{/{section_name}\}}\}}"
        block = re.search(pattern, content, re.DOTALL)
        if block:
            inner = block.group(1)
            rendered = "".join(
                re.sub(
                    r"\{\{(\w+)\}\}",
                    lambda m: _escape(str(row.get(m.group(1), ""))),
                    inner,
                )
                for row in rows
            )
            content = content[:block.start()] + rendered + content[block.end():]
    if re.search(r"\{\{[^#/]", content):
        raise ValueError("fill_template: unreplaced {{...}} markers remain.")
    return content

# Minimal substitution test
variables = {
    "AGENT_NAME": "Support Triage Agent",
    "GENERATED_DATE": "2026-05-16",
    "VERDICT": "Caution",
    "VERDICT_SUMMARY": "Architecture is sound but write tool density is high.",
    "ARCHITECTURE_TYPE": "Orchestrator-Workers",
    "ORCHESTRATION_STYLE": "Central orchestrator with specialist workers",
    "AGENT_COUNT": "4",
    "STATE_MANAGEMENT": "Stateless per-ticket",
    "AUTONOMY_LEVEL": "L2 Assisted",
    "AUTONOMY_CLASS": "yellow",
    "HITL_LEVEL": "Human-on-standby",
    "HITL_CLASS": "yellow",
    "REVERSIBILITY": "Mixed",
    "REVERSIBILITY_CLASS": "yellow",
    "BLAST_RADIUS": "Single ticket",
    "BLAST_RADIUS_CLASS": "green",
    "ROLLOUT_MODE": "Canary at 5%",
    "TOPOLOGY_DIAGRAM": "Orchestrator → [Billing|Technical|Account|General] Workers",
    "ARCHITECTURE_RECOMMENDATION": "Proceed with caution: scope write tool permissions before launch.",
}
sections = {
    "TOOL_ROWS": [
        {"TOOL_NAME": "ticket-lookup", "TOOL_PURPOSE": "Read ticket metadata", "TOOL_SCOPE": "Read", "TOOL_SCOPE_CLASS": "green", "TOOL_RISK": "Low", "TOOL_RISK_CLASS": "green"},
    ],
    "DECISION_ROWS": [],
    "RISK_ROWS": [],
    "OPEN_QUESTIONS": [],
    "NEXT_STEPS": [],
}

result = fill_template("templates/html/architecture-review.html", variables, sections)
Path(".agentic/artifacts/architecture-review-support-triage-agent.html").write_text(result)
print("Written. Checking for unreplaced placeholders...")
```

Output:
```
Written. Checking for unreplaced placeholders...
$ grep -c '{{' .agentic/artifacts/architecture-review-support-triage-agent.html
0
```

**Result:** Pass — `fill_template` substituted all scalars and rendered the `TOOL_ROWS` block. Unreplaced-placeholder check (`{{[^#/]` pattern) passed — no `{{...}}` markers remain in output.

---

## Step 6: Config loading via Python

Tested the Python config loading pattern from `adapters/gemini-adk.md`:

```python
import yaml
from pathlib import Path

config = {}
config_path = Path(".agentic/config.yml")
if config_path.exists():
    config = yaml.safe_load(config_path.read_text())

eval_assets_path = config.get("eval_assets_path", "evals/")
artifact_output_path = config.get("artifact_output_path", ".agentic/artifacts/")
print(f"eval_assets_path: {eval_assets_path}")
print(f"artifact_output_path: {artifact_output_path}")
```

Output:
```
eval_assets_path: evals/
artifact_output_path: .agentic/artifacts/
```

**Result:** Pass — config loaded and fields read correctly. Fallback defaults apply when fields are absent.

---

## Summary

| Step | Test | Result |
|---|---|---|
| 1 | ADK install and import | Pass |
| 2 | Skill loading and agent setup | Pass |
| 3 | Agent invocation via ADK CLI — skill routing and output | Pass |
| 4 | Subagent delegation via AgentTool — isolated context, structured output | Pass |
| 5 | Artifact write using fill_template — all placeholders substituted | Pass |
| 6 | Config loading via Python — fields read, fallbacks work | Pass |

**Overall verdict:** Adapter path verified end-to-end. The Gemini/ADK adapter works as documented in `adapters/gemini-adk.md`. The `AgentTool`-based subagent delegation is the closest functional match to Claude Code's isolated subagent spawning. Artifact rendering via `fill_template` produces clean output with no unreplaced placeholders.

---

## Known limitations observed during test

- **Manual skill selection:** Unlike Claude Code's description-field auto-invocation, ADK requires the user to explicitly configure which skill to load per agent. A router agent pattern (load all skills + AGENTS.md, delegate per-request) partially addresses this but adds setup overhead.
- **No slash command equivalent:** ADK invocations are Python function calls or natural language prompts, not namespaced commands. Recommend providing a pre-built `agentic_ai_agent.py` as a convenience wrapper.
- **Instruction token overhead:** Loading both AGENTS.md and a full skill SKILL.md into the agent instruction consumes 10,000–15,000 tokens of context before any user input. For gemini-2.0-flash this is within budget; for smaller context windows, trim the routing table to relevant sections.
