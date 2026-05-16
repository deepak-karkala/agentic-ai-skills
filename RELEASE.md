# Release

## Milestone 1 Release Gate

The following criteria must all pass before a Milestone 1 GitHub release tag is cut.

### Structural gate (automated)

- [ ] `bash scripts/validate-plugin.sh` exits 0 with 0 failures
- [ ] All skill folders follow the naming contract: kebab-case, `SKILL.md` present, `name` matches folder
- [ ] All `references/` files linked from SKILL.md exist
- [ ] All `agents/*.md` have frontmatter with `name` and `description`
- [ ] All `commands/*.md` have frontmatter with `description` (name not required for commands)

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

## Milestone 2 Release Gate

The following criteria must all pass before a Milestone 2 GitHub release tag is cut. All Milestone 1 gates continue to apply.

### Structural gate (automated)

- [ ] `bash scripts/validate-plugin.sh` exits 0 with 0 failures (currently 133 checks)
- [ ] All 17 skill folders follow the naming contract: kebab-case, `SKILL.md` present, `name` matches folder
- [ ] All `references/` files linked from SKILL.md exist
- [ ] All 3 agent files (`agents/*.md`) have frontmatter with `name` and `description`
- [ ] All 11 command files (`commands/*.md`) have frontmatter with `description`
- [ ] All 5 templates (3 HTML + 2 markdown) exist and contain at least one `{{...}}` placeholder
- [ ] All 3 adapter files (`adapters/*.md`) exist and contain a capability section (`## What ... supports`)
- [ ] No adapter file contains absolute local paths

### Skill content gate (manual)

- [ ] All 17 flagship skills have: explicit triggers, explicit non-trigger exclusions, step-by-step workflow, output format, scope boundaries
- [ ] All 17 flagship skills have at least one worked scenario in `examples/scenarios/`
- [ ] All 11 Milestone 2 skills respect the output path convention: `artifact_output_path` or `.agentic/artifacts/` fallback
- [ ] Strategy lane skills (`agentic-opportunity-framing`, `agentic-product-strategy`, `agentic-economics-and-moats`, `agentic-governance-and-adoption`) have explicit routing boundaries that do not overlap with M1 technical skills
- [ ] `setup-agentic-ai-engineering` post-setup report lists all 17 skills and all 7 config fields with accurate improvement descriptions

### Routing gate (manual dry-run)

- [ ] `tests/routing-dry-run-m2.md` dry-run passes: all 8 new M2 skill rows have correct obvious-trigger, paraphrase-trigger, and non-trigger routing
- [ ] 8 boundary collision cases are resolved by the tie-breaking rule (pre-build → strategy lane; post-decision → technical lane)
- [ ] `/agentic-evals` with existing eval suite delegates to `agent-evals-auditor`
- [ ] `/agentic-opportunity-framing` or `/agentic-product-strategy` with non-trivial input delegates to `agent-product-strategist`
- [ ] No skill delegates to a subagent for greenfield input
- [ ] All 6 auto-routed skills (no command wrapper) still activate via AGENTS.md intent matching

### Artifact gate (manual)

- [ ] `eval-scorecard.html` renders correctly from `templates/html/eval-scorecard.html` with no unreplaced `{{...}}` literals
- [ ] `rollout-readiness.html` renders correctly from `templates/html/rollout-readiness.html` with no unreplaced `{{...}}` literals
- [ ] `glossary.md` renders correctly from `templates/markdown/glossary.md` with correct table structure (headers outside row blocks)
- [ ] `handoff.md` renders correctly from `templates/markdown/handoff.md` with cross-links referencing artifact filenames (not embedded content)
- [ ] All artifact filenames follow the convention: `<artifact-type>-<agent-name>.<ext>`
- [ ] Artifact overwrite-by-default behavior confirmed — no auto-versioned filenames

### Subagent gate (manual)

- [ ] `agent-product-strategist` output format matches the structured sections defined in `agents/agent-product-strategist.md`
- [ ] Parent skills synthesize subagent output — raw subagent dumps do not surface to user
- [ ] `agent-artifact-designer` is confirmed deferred — no file exists at `agents/agent-artifact-designer.md`

### Adapter gate (manual)

- [ ] Codex adapter (`adapters/codex.md`) has been smoke-tested: setup path is followable, command equivalents are accurate, inline subagent fallback is complete
- [ ] Gemini/ADK adapter (`adapters/gemini-adk.md`) `fill_template()` example includes HTML escaping and unreplaced-placeholder check
- [ ] OpenCode adapter (`adapters/opencode.md`) acceptance criteria checklist is present and gated on plugin API stabilization
- [ ] Host support matrix in AGENTS.md matches the adapter files — no "Planned" entries remain for hosts with shipped adapters

### Baseline comparison gate (manual)

- [ ] `examples/baseline-comparison.md` covers 3 workflows across no-plugin / M1 / M2
- [ ] M1 baseline uses only M1 skills (no M2 skills in M1 column)
- [ ] Artifact comparison references git history, not version-suffixed filenames
- [ ] Summary table covers ≥ 10 capability dimensions

### Integrity gate

- [ ] No committed file contains absolute local paths (`/Users/...`)
- [ ] `.gitignore` anchors `/references/` and `/docs/` to root only
- [ ] `plugin.json` namespace is `agentic-ai-engineering` and version is `"0.2.0"` for Milestone 2
- [ ] `CONTRIBUTING.md` artifact naming table matches the templates present in `templates/`

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

## Portability Status

The `skills/`, `agents/`, `templates/`, and `examples/` content is host-agnostic and transfers unchanged to any host. Only `CLAUDE.md`, `AGENTS.md`, `.claude-plugin/plugin.json`, and the adapter files are host-specific.

### Codex adapter — Shipped (Milestone 2)

See `adapters/codex.md`. Covers: AGENTS.md routing, natural language command equivalents, inline subagent fallback, artifact write path, config surfacing.

### Gemini / ADK adapter — Shipped (Milestone 2)

See `adapters/gemini-adk.md`. Covers: Python `load_skill()` setup, `AgentTool` subagent pattern, `fill_template()` rendering implementation (with HTML escaping and unreplaced-placeholder check), yaml config loading.

### OpenCode adapter — Spec complete (Milestone 2)

See `adapters/opencode.md`. Implementation-ready spec with `.opencode/instructions.md` content, command-to-natural-language mapping, and 6-item acceptance criteria checklist. Full implementation gated on OpenCode plugin API stabilization.

### Portability principle

Any portability effort starts by adapting the host-specific adapter layer, not the skill content. The adapter boundary is: if the change affects `skills/`, `agents/`, `templates/`, or `examples/`, it is a content change — not a portability adapter. Reject it or upstream it to core.
