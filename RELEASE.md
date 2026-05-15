# Release

## Milestone 1 Release Gate

The following criteria must all pass before a Milestone 1 GitHub release tag is cut.

### Structural gate (automated)

- [ ] `bash scripts/validate-plugin.sh` exits 0 with 0 failures
- [ ] All skill folders follow the naming contract: kebab-case, `SKILL.md` present, `name` matches folder
- [ ] All `references/` files linked from SKILL.md exist
- [ ] All `agents/*.md` and `commands/*.md` have frontmatter with `name` and `description`

### Skill content gate (manual)

- [ ] All 5 flagship skills have: explicit triggers, explicit non-trigger exclusions, step-by-step workflow, output format, scope boundaries
- [ ] All 5 flagship skills have at least one worked scenario in `examples/scenarios/`
- [ ] `setup-agentic-ai-engineering` has `disable-model-invocation: true`
- [ ] No SKILL.md contains TODO placeholder comments

### Routing gate (manual dry-run)

- [ ] 10-request dry-run passes (documented in milestone plan Task 13 notes)
- [ ] `/agentic-arch-review` command always produces HTML artifact
- [ ] `/agentic-evals` with existing eval suite delegates to `agent-evals-auditor`
- [ ] `/agentic-plan` does not delegate to `agent-systems-architect` for greenfield design

### HTML artifact gate (manual)

- [ ] `templates/html/architecture-review.html` contains no unreplaced `{{VARIABLE}}` literals in a rendered output
- [ ] The HTML artifact scenario (`examples/scenarios/agentic-arch-review-html-artifact.md`) walks through a complete artifact generation path

### Integrity gate

- [ ] No committed file contains absolute local paths (`/Users/...`)
- [ ] `.gitignore` anchors `/references/` and `/docs/` to root only
- [ ] `plugin.json` namespace is `agentic-ai-engineering`

---

## What is committed vs local-only

| Committed to repo | Local-only (gitignored) |
|---|---|
| `skills/` — skill implementations | `docs/` — implementation plan, contracts, mapping notes |
| `agents/` — subagent definitions | `ideation/` — exploration drafts |
| `commands/` — command wrappers | `/references/` — source research notes |
| `templates/` — HTML artifact templates | `.agentic/` — per-repo config (may commit if shared config) |
| `examples/` — scenarios and outputs | `.DS_Store` — OS artifacts |
| `scripts/` — validation tools | |
| `AGENTS.md`, `CLAUDE.md`, `CONTRIBUTING.md`, `README.md`, `RELEASE.md` | |
| `.claude-plugin/plugin.json` | |

---

## Portability Roadmap

Milestone 1 targets Claude Code as the primary host. The skill and agent content is host-agnostic. The following adapter work is deferred:

### Codex adapter (post-Milestone 1)

- [ ] Map `agents/` to Codex equivalent (no native subagent concept — implement as inline instructions or tool calls)
- [ ] Map plugin namespace to Codex skill directory convention
- [ ] Verify `disable-model-invocation: true` equivalent enforcement
- [ ] Validate HTML artifact write path on Codex file system model

### Gemini / Google ADK adapter (post-Milestone 1)

- [ ] Map `.claude-plugin/plugin.json` to ADK manifest equivalent
- [ ] Map namespaced commands to ADK entry point format
- [ ] Validate subagent invocation pattern on ADK

### OpenCode adapter (post-Milestone 1)

- [ ] Assess OpenCode skill loading mechanism (TBD — depends on OpenCode plugin spec)
- [ ] Content transfer requires no changes; adapter layer only

### Portability principle

The `skills/`, `agents/`, and `examples/` content transfers unchanged to any host. Only `CLAUDE.md`, `AGENTS.md`, and `.claude-plugin/plugin.json` are host-specific. Any portability effort starts by adapting those three files, not the skill content.
