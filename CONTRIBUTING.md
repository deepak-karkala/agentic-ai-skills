# Contributing

This document is the authoritative skill authoring contract for `agentic-ai-engineering`. Read it before writing or reviewing any skill, agent, or command in this repo.

---

## Skill Folder Anatomy

Each skill lives in its own directory under `skills/`:

```
skills/<skill-name>/
├── SKILL.md           # required — core skill content and frontmatter
├── references/        # optional — long supporting material, decision tables, source excerpts
├── assets/            # optional — HTML templates, Markdown templates, artifact scaffolds
└── scripts/           # optional — deterministic validators, linting helpers, non-LLM checks
```

Rules:
- Folder name must be `kebab-case`
- `SKILL.md` must be named exactly `SKILL.md` — no other casing, no `README.md` inside skill folders
- Supporting material that exceeds ~100 lines belongs in `references/`, not inlined in `SKILL.md`
- Templates and artifact scaffolds belong in `assets/`, not in `references/`
- Scripts are for deterministic work (path checks, frontmatter lint, format validation) — not for LLM-driven logic

---

## Frontmatter Contract

Every `SKILL.md` must have YAML frontmatter between `---` markers at the top.

### Required fields

```yaml
---
name: <kebab-case-skill-name>   # must match folder name exactly
description: >
  <What the skill does and when to use it.
   Include concrete trigger phrases.>
---
```

### Preferred optional fields

```yaml
disable-model-invocation: true   # set on skills that must be user-invoked only (e.g. setup, destructive actions)
allowed-tools:
  - Read
  - Write
  - Bash
  - WebSearch
compatibility:
  claude-code: ">=1.0"
metadata:
  category: <architecture|reliability|production|setup>
  version: "0.1.0"
```

**`disable-model-invocation: true` is required** for any skill that:
- Writes files or modifies repo state (setup skills, initializers)
- Has side effects that should only happen when the user explicitly requests them
- Could create confusing premature initialization if auto-invoked

---

## Description Quality Rules

The `description` field is a first-class design artifact. It controls auto-invocation. Treat it with the same care as the skill content.

**A good description:**
- States what the skill does (third person, active verb)
- Lists concrete trigger phrases the user might actually say
- States explicitly what NOT to trigger on, if the boundary is subtle

**Examples:**

Good:
```yaml
description: >
  Designs evaluation strategy for agentic workflows. Covers scorecard
  dimensions, grader selection, trajectory metrics, and regression testing.
  Use when setting up evals for a new agent, auditing an existing eval suite,
  choosing between LLM-as-judge and deterministic evaluators, or setting up
  regression tests from production failures.
```

Bad:
```yaml
description: Helps with evaluation.
```

Bad:
```yaml
description: >
  This skill is about evaluation and it helps you evaluate your agents
  and understand what metrics to use for LLM-based systems.
```

Rules:
- No marketing language or abstract adjectives ("powerful", "comprehensive")
- No reference to internal implementation details
- Trigger phrases should match how users actually phrase requests
- Include both obvious triggers and non-obvious ones that the skill genuinely handles

---

## Progressive Disclosure Rules

| Content type | Where it lives |
|---|---|
| Core workflow instructions | `SKILL.md` body |
| Trigger examples and non-trigger boundaries | `SKILL.md` body |
| Decision trees with 3+ branches | `SKILL.md` body (keep inline if under 50 lines) |
| Long decision tables, reference matrices | `references/` |
| Source-backed frameworks or playbooks | `references/` |
| HTML artifact templates | `assets/` |
| Markdown checklist or report templates | `assets/` |
| Deterministic validation scripts | `scripts/` |

The `SKILL.md` should be readable in one pass. If a reader needs to scroll past 200 lines of reference material to get to the next instruction, move that material to `references/`.

---

## Instruction Design Rules

From the `evals-skills` meta-skill — apply to all skills in this plugin:

- Write directives, not wisdom. Tell the agent what to do, not why it matters.
- Cut general knowledge. Only include what the agent wouldn't already know.
- Be concrete. Show what good looks like.
- Scope to the task. Every sentence should help the agent do its job.
- Start with the simplest correct approach. State prerequisites explicitly if advanced techniques need them.

---

## Skill Content Structure

Each skill body should include:

1. **Overview** — one paragraph, what this skill does and when to run it
2. **When to use / When NOT to use** — explicit trigger and non-trigger conditions (matches description)
3. **Core workflow** — the step-by-step process the agent follows
4. **Output format** — what the skill produces (conversation output, artifact, checklist, structured report)
5. **Scope boundaries** — explicit list of what this skill does not do

---

## Subagent Files

Subagents live in `agents/<agent-name>.md`.

Required frontmatter:

```yaml
---
name: <kebab-case-agent-name>
description: >
  <What specialist task this subagent handles.
   When the parent skill should delegate to it.>
---
```

Rules:
- Each subagent has a bounded, non-overlapping responsibility
- Subagents do not spawn other subagents
- Output must be structured (JSON, table, or named sections) so the parent skill can synthesize it

---

## Command Files

Commands live in `commands/<command-name>.md`.

Commands are thin entrypoint wrappers. They route to a primary skill. They do not duplicate skill logic.

Required frontmatter:

```yaml
---
description: >
  <One-sentence description of what this entry point does.
   Mirrors the primary skill it invokes.>
---
```

---

## HTML Artifact Rendering Contract

HTML templates live in `templates/html/`. Skills that generate artifacts load the template, fill all placeholders, and write the result to the configured artifact output path.

### Placeholder syntax

Templates use two placeholder forms:

**Scalar substitution** — replace `{{VARIABLE}}` with a single string value:
```
{{AGENT_NAME}}  →  "Support Resolution Agent"
{{VERDICT}}     →  "Caution"
```

**Block repetition** — replace `{{#SECTION}}...{{/SECTION}}` with zero or more rendered copies of the inner block, one per data item:
```
{{#RISK_ROWS}}
<tr><td>{{RISK_TITLE}}</td>...</tr>
{{/RISK_ROWS}}
```
If the data list is empty, output nothing (no empty rows, no placeholder markers).

### Rendering approach

Skills must use **plain string replacement** — no external template engine required.

Steps:
1. Read the template file as a string.
2. Replace each `{{VARIABLE}}` marker with its value. Escape any `<`, `>`, or `&` characters in user-provided values with HTML entities.
3. For each `{{#SECTION}}...{{/SECTION}}` block: locate the block, render one copy per item in the data list (replacing inner `{{VARIABLE}}` markers for each item), then replace the original block with the concatenated result.
4. Write the resulting string to the artifact output path.

Do not introduce Mustache, Handlebars, Jinja, or any other template library. The plain string replacement contract keeps skills dependency-free and portable across hosts.

### CSS badge classes

Templates use named CSS classes for colored badges. Use the correct class for the value:

| Semantic meaning | Class |
|---|---|
| Good / low risk / reversible | `green` |
| Caution / medium risk / correctable | `yellow` |
| Bad / high risk / irreversible | `red` |
| Informational / neutral | `blue` |
| Plugin-branded / default accent | `purple` |

### Unreplaced placeholders

Before writing the artifact, scan for any remaining `{{` markers. If any are found, either substitute a safe default or remove the surrounding element. Never write `{{VARIABLE}}` literally to the output file.

---

## Artifact Naming, Storage, and Retention Conventions

These conventions apply to all artifacts produced by plugin skills. Follow them exactly — consistency enables cross-linking, avoids output clutter, and ensures the Milestone 1 architecture-review path remains stable.

### Filename patterns

Every artifact filename follows one of two patterns:

```
<artifact-type>-<agent-or-project-name>.<ext>
```

| Artifact type | Template file | Output filename pattern | Extension |
|---|---|---|---|
| Architecture review | `templates/html/architecture-review.html` | `architecture-review-<agent-name>.html` | `.html` |
| Eval scorecard | `templates/html/eval-scorecard.html` | `eval-scorecard-<agent-name>.html` | `.html` |
| Rollout readiness | `templates/html/rollout-readiness.html` | `rollout-readiness-<agent-name>.html` | `.html` |
| Glossary | `templates/markdown/glossary.md` | `glossary-<project-name>.md` | `.md` |
| Handoff | `templates/markdown/handoff.md` | `handoff-<project-name>.md` | `.md` |
| Observability plan | (inline markdown) | `observability-<agent-name>.md` | `.md` |
| Tool interface spec | (inline markdown) | `tool-interface-<agent-name>.md` | `.md` |
| Single-agent workflow | (inline markdown) | `workflow-<agent-name>.md` | `.md` |
| Opportunity framing | (inline markdown) | `opportunity-framing-<name>.md` | `.md` |
| Product strategy | (inline markdown) | `product-strategy-<name>.md` | `.md` |
| Economics and moats | (inline markdown) | `economics-<name>.md` | `.md` |
| Governance and adoption | (inline markdown) | `governance-<name>.md` | `.md` |

**Name normalization:** Convert the agent or project name to kebab-case (lowercase, spaces replaced with `-`, special characters stripped). Example: "Procurement Agent v2" → `procurement-agent-v2`.

### Output directory

- Default output directory: `.agentic/artifacts/`
- Custom output directory: configured via `artifact_output_path` in `.agentic/config.yml`
- All artifacts go directly into the output directory — no subdirectory per artifact type, no subdirectory per skill
- Skills must report the full output path to the user after writing: `Artifact written to .agentic/artifacts/eval-scorecard-billing-agent.html`

### Overwrite vs versioning

- **Overwrite by default.** Running a skill twice for the same agent name overwrites the previous artifact.
- Skills must not create version-suffixed filenames automatically (e.g., `architecture-review-v2.html`).
- Users who need artifact history should commit artifacts to version control.

### Cross-linking between artifacts

- The handoff artifact (`handoff-<name>.md`) references other artifacts by their output filename (relative to the shared output directory). Example: `See architecture-review-billing-agent.html for topology details.`
- Cross-links are references, not embeds — do not copy large sections from one artifact into another.
- Skills may mention related artifacts by name when they are likely to exist. They must not fail if the referenced artifact is absent.

### Template location rules

- HTML templates: `templates/html/<artifact-type>.html`
- Markdown templates: `templates/markdown/<artifact-type>.md`
- Skills that produce inline markdown (no template) write directly; no template file needed.
- New artifact types that require a template must add their template file before the skill that uses it is implemented.

### Registering new artifact types

- New artifact types do not require new `.agentic/config.yml` fields. They write to the shared `artifact_output_path`.
- The naming table above is the registry. Add a row here when a new artifact type is introduced.
- Skills must use the exact `<artifact-type>` prefix from the table — no ad-hoc naming.

### Compatibility note

The Milestone 1 `architecture-review-<agent-name>.html` path is compatible with these conventions without any change. It was the original pattern these conventions formalize.

---

## Testing Requirements

Before a skill can be considered complete:

- [ ] Frontmatter has `name` and `description`; `name` matches folder name
- [ ] Description includes at least 3 concrete trigger phrases
- [ ] Skill has explicit non-trigger boundaries
- [ ] Skill body covers: overview, when to use, core workflow, output format, scope boundaries
- [ ] No references to local absolute paths or `docs/`, `ideation/`, `references/` folders
- [ ] If a supporting file is referenced, it exists in `references/` or `assets/`
- [ ] At least one worked example scenario exists in `examples/scenarios/`

---

## What Not To Include

In committed skill content, never include:

- Local absolute paths (`/Users/...`)
- References to `docs/`, `ideation/`, or `references/` planning folders
- Source corpus citations (these are local-only planning inputs)
- Unfinished placeholder instructions ("TODO: add frameworks here")
- Generic advice that any LLM would produce without this skill

---

## Sample Skill Skeleton

Use this as a starting point for any new flagship skill:

```markdown
---
name: <skill-name>
description: >
  <What it does. When to use it. 3+ concrete trigger phrases.
   Explicit non-trigger statement if needed.>
allowed-tools:
  - Read
  - Write
metadata:
  category: <architecture|reliability|production|setup>
  version: "0.1.0"
---

# <Skill Title>

<One-paragraph overview. What this skill does and when to run it.>

## When to Use

**Use when:**
- <concrete trigger 1>
- <concrete trigger 2>
- <concrete trigger 3>

**Do not use when:**
- <exclusion 1 — redirect to the right skill>
- <exclusion 2>

## Workflow

<Step-by-step process. Use numbered steps. Be directive, not explanatory.>

## Output

<What the skill produces. Format spec if structured output.>

## Scope Boundaries

This skill does not:
- <explicit out-of-scope item 1>
- <explicit out-of-scope item 2>
```
