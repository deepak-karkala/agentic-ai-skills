---
name: agentic-prototype
description: >
  Generates a minimal, runnable scaffold for an agentic AI system based on
  an architecture decision. Supports ReAct loops, tool gateway patterns,
  human-in-the-loop approval flows, and LangGraph skeleton graphs. The
  prototype is intentionally narrow and disposable — its purpose is to
  answer a design question or validate a pattern choice, not to be a
  production implementation. Use after agentic-system-design has selected
  a pattern, when a design question can only be answered by seeing code,
  when the team needs a starting point rather than a blank file, or when
  validating whether a chosen framework fits the pattern before committing.
  Trigger phrases: "show me a minimal scaffold for this", "generate a
  prototype for this agent", "give me a starting point for this ReAct loop",
  "prototype the approval gate flow", "sketch the LangGraph skeleton for
  this", "what does this pattern look like in code". Do not use for
  production implementation (this generates stubs and scaffolds only), for
  architecture decisions (use agentic-system-design first), or for full
  feature development.
allowed-tools:
  - Read
  - Write
metadata:
  category: workflow-support
  version: "0.1.0"
---

# Agentic Prototype

Prototype generation skill. Produces a minimal, runnable scaffold aligned with an architecture pattern — enough to validate the design, answer a specific question, or give a team a concrete starting point.

## When to Use

**Use when:**
- `agentic-system-design` has selected a pattern and the team wants to see it in code
- A design question (e.g., "does a supervisor work better than a pipeline here?") can only be answered by running something
- The team needs a starting point rather than a blank file
- Validating whether a framework (LangGraph, CrewAI, raw function-calling) fits the selected pattern

**Do not use when:**
- Architecture hasn't been chosen yet → use `agentic-system-design` first
- The user wants a complete, production-ready implementation — explicitly out of scope
- The user wants infrastructure or CI/CD setup
- The request is to review an existing implementation → use `agentic-system-design` or `multi-agent-orchestration`

## Prototype Contract

Every prototype produced by this skill must be:
- **Minimal:** only the structural skeleton — no business logic beyond stubs
- **Runnable:** imports resolve, no syntax errors, can be executed to demonstrate the pattern
- **Labeled:** a comment at the top of every file: `# PROTOTYPE — not production code`
- **Bounded:** covers exactly the pattern chosen; does not expand into adjacent concerns
- **Disposable:** written with the expectation that it will be rewritten, not extended

## Workflow

### Step 1 — Confirm the pattern and question

Ask the user:
1. What pattern was selected (ReAct, plan-and-execute, supervisor-worker, tool gateway, HITL flow, LangGraph graph)?
2. What specific question does this prototype need to answer?
3. Which language? (Python is the default for agentic AI prototypes.)
4. Which framework, if any? (LangGraph, CrewAI, raw Anthropic SDK, raw OpenAI SDK, framework-agnostic.)
5. What tools should the agent have? Name them — stubs are acceptable.

If `design_docs_path` is configured in `.agentic/config.yml`, check for an existing architecture plan to extract the pattern and tool list.

---

### Step 2 — Select the scaffold type

Match the chosen pattern to a scaffold:

| Pattern | Scaffold |
|---|---|
| ReAct (reason-act) loop | Single-agent ReAct scaffold |
| Plan-and-execute | Planner + executor scaffold |
| Supervisor-worker | Supervisor + 2 worker scaffold |
| Tool gateway | Gateway with tool registry scaffold |
| Human-in-the-loop | Approval gate scaffold |
| LangGraph graph | StateGraph with nodes + edges scaffold |
| Pipeline / chaining | Sequential step scaffold |

See [Scaffold Patterns](references/scaffold-patterns.md) for the template for each scaffold type.

---

### Step 3 — Generate the scaffold

Generate the scaffold using the appropriate template from the reference. Customize:
- Tool stubs: one function per tool named in Step 1, with a `# STUB` comment
- System prompt placeholder: `SYSTEM_PROMPT = "..."` with a note to fill in
- State schema: typed fields matching the described workflow (not generic)
- Entry point: a `main()` or equivalent that can be run directly with a sample input

Do not add:
- Error handling beyond bare try/except stubs
- Authentication or secrets management
- Logging infrastructure
- Database connections or persistence layers

---

### Step 4 — Label and annotate

Add to every generated file:
1. `# PROTOTYPE — not production code` as the first line
2. A `DESIGN QUESTION:` comment at the top stating what this prototype is meant to answer
3. `# STUB` comments on every unimplemented function body
4. A `# NEXT STEPS:` block at the bottom listing what must be built or replaced before this is production-ready

---

### Step 5 — Write the files

Write prototype files to `artifact_output_path/prototypes/<pattern-name>/` if `artifact_output_path` is configured in `.agentic/config.yml`. Otherwise write to `.agentic/artifacts/prototypes/<pattern-name>/` and note the path.

Typical file structure:

```
<pattern-name>/
├── agent.py          # Core agent scaffold
├── tools.py          # Tool stubs
└── README.md         # Pattern, design question, next steps
```

---

### Step 6 — Report and recommend

After writing the prototype:
1. State what pattern is demonstrated and where the files were written.
2. Restate the design question this prototype is meant to answer.
3. List the stubs that must be implemented before the prototype is meaningful.
4. Suggest the next step: run the prototype to answer the design question, then route to `agentic-to-issues` to slice the full implementation.

## Output Contract

- **Primary output:** Prototype files at `artifact_output_path/prototypes/<name>/` or `.agentic/artifacts/prototypes/<name>/`
- **In-conversation summary:** pattern used, design question, stub list, next steps
- **Does not produce:** production code, architecture decisions, eval plans

## Scope Boundaries

This skill generates scaffolds. If during generation a design decision needs to be made that was not resolved by the architecture phase (e.g., "should the approval gate be synchronous or async?"), pause and flag it rather than deciding unilaterally. Route back to `agentic-system-design` if needed.
