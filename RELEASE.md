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
- [ ] `agent-artifact-designer` is confirmed deferred — no file exists at `agents/agent-artifact-designer.md`; gate re-evaluated at M3 Phase 3 (Task 14) and still not met; all five artifact types (architecture-review, eval-scorecard, rollout-readiness, glossary, handoff) remain expressible with scalar substitution and block repetition only — no dynamic section selection, multi-table composition, or conditional rendering beyond `{{#SECTION}}...{{/SECTION}}` has been introduced

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

## Milestone 3 Release Gate

The following criteria must all pass before a Milestone 3 GitHub release tag is cut. All Milestone 1 and Milestone 2 gates continue to apply.

### Structural gate (automated)

- [ ] `bash scripts/validate-plugin.sh` exits 0 with 0 failures (182 checks as of M3 Phase 5)
- [ ] All 24 skill folders follow the naming contract: kebab-case, `SKILL.md` present, `name` matches folder
- [ ] All `references/` files linked from SKILL.md exist
- [ ] All 5 agent files (`agents/*.md`) have frontmatter with `name` and `description`
- [ ] All 11 command files (`commands/*.md`) have frontmatter with `description`
- [ ] All 5 templates (3 HTML + 2 markdown) exist and contain at least one `{{...}}` placeholder
- [ ] All 3 adapter files (`adapters/*.md`) exist and contain a capability section
- [ ] No adapter file or committed skill file contains absolute local paths
- [ ] Smoke-test evidence: `tests/smoke/codex-smoke-test.md` and `tests/smoke/gemini-adk-smoke-test.md` exist and are non-trivial (machine-checked in Section 10)
- [ ] Routing dry-run evidence: `tests/routing-dry-run-m2.md` and `tests/routing-dry-run-m3.md` exist (machine-checked in Section 11)
- [ ] Baseline comparison evidence: `examples/baseline-comparison.md` and `examples/baseline-comparison-m3.md` exist and are non-trivial (machine-checked in Section 12)

### Skill content gate (manual)

- [ ] All 24 skills have: explicit triggers, explicit non-trigger exclusions, step-by-step workflow, output format, scope boundaries
- [ ] All 24 skills have at least one worked scenario in `examples/scenarios/`
- [ ] All 7 M3 Phase 2 skills respect the output path convention: `artifact_output_path` or `.agentic/artifacts/` fallback
- [ ] All 7 M3 Phase 2 skills have explicit routing boundaries against adjacent M1/M2 skills (no collision)
- [ ] `setup-agentic-ai-engineering` post-setup report lists all 24 skills and all 7 config fields

### Routing gate (manual dry-run)

- [ ] `tests/routing-dry-run-m3.md` dry-run passes: all 7 M3 Phase 2 skill rows have correct obvious-trigger, paraphrase-trigger, and non-trigger routing
- [ ] All 13 auto-routed skills (no command wrapper) activate via AGENTS.md intent matching
- [ ] M3 Phase 2 overlap-zone disambiguation table in AGENTS.md correctly resolves all boundary collision cases (14 rows documented in `tests/routing-dry-run-m3.md`)
- [ ] `incident-investigation` delegates to `agent-reliability-engineer` when multi-layer failure classification exceeds ~500 tokens inline; does not delegate for single fault-layer inputs
- [ ] `latency-and-cost-optimization` delegates to `agent-cost-performance-analyst` for detailed full-pipeline breakdowns; does not delegate for single-lever questions
- [ ] No skill delegates to a subagent for greenfield or minimal input

### Subagent gate (manual)

- [ ] `agent-product-strategist` output format matches the structured sections defined in `agents/agent-product-strategist.md`
- [ ] `agent-reliability-engineer` output format matches the structured sections in `agents/agent-reliability-engineer.md`; invoked from `incident-investigation` and `hallucination-containment`; does not overlap `agent-evals-auditor` (grader quality) or `agent-systems-architect` (topology)
- [ ] `agent-cost-performance-analyst` output format matches the structured sections in `agents/agent-cost-performance-analyst.md`; invoked from `latency-and-cost-optimization`; does not overlap `agentic-economics-and-moats` (product-level unit economics)
- [ ] Parent skills synthesize subagent output — raw subagent dumps do not surface to user
- [ ] `agent-artifact-designer` confirmed deferred — no file at `agents/agent-artifact-designer.md`; gate re-evaluated M3 Phase 3 (Task 14), still not met; all 5 artifact types expressible with scalar substitution and block repetition only

### Artifact gate (manual)

- [ ] All 5 artifact types have rendered example outputs in `examples/outputs/` with no unreplaced `{{...}}` literals (machine-checked in Section 9)
- [ ] `tests/fixtures/rendering-variables.json` exists and is consistent with the variable/block names used in `templates/` (machine-checked in Section 9)

### Adapter gate (manual)

- [ ] Codex adapter (`adapters/codex.md`) covers: AGENTS.md routing, command equivalents, inline subagent fallback, artifact write path; smoke-test evidence present at `tests/smoke/codex-smoke-test.md`
- [ ] Gemini/ADK adapter (`adapters/gemini-adk.md`) covers: `fill_template()` implementation with HTML escaping and unreplaced-placeholder check, `AgentTool` subagent pattern; smoke-test evidence present at `tests/smoke/gemini-adk-smoke-test.md`
- [ ] OpenCode adapter (`adapters/opencode.md`) spec-complete status documented accurately; `.opencode/instructions.md` is not created; do not advertise as shipped
- [ ] Host support matrix in AGENTS.md matches the adapter files

### Baseline comparison gate (manual)

- [ ] `examples/baseline-comparison.md` covers 3 workflows across no-plugin / M1 / M2 (machine-checked for presence in Section 12)
- [ ] `examples/baseline-comparison-m3.md` covers 3 workflows across no-plugin / M2 / M3, including incident investigation, cost/latency optimization, and security hardening (machine-checked for presence in Section 12)
- [ ] M3 comparison includes at least one error-prevention example (i.e., what M3 would have prevented vs. M2)
- [ ] 14-dimension summary table covers all major M3 capability additions

### Integrity gate

- [ ] No committed file contains absolute local paths (`/Users/...`) (machine-checked in Section 8)
- [ ] `.gitignore` anchors `/references/` and `/docs/` to root only
- [ ] `plugin.json` version is `"0.3.0"` for Milestone 3
- [ ] `CONTRIBUTING.md` artifact naming table matches the templates present in `templates/`
- [ ] AGENTS.md and CLAUDE.md are consistent: every skill and subagent listed in one is listed in the other

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

### OpenCode adapter — Spec-complete, not yet implemented (Milestone 2)

See `adapters/opencode.md`. Spec documents `.opencode/instructions.md` content, command-to-natural-language mapping, and 6-item acceptance criteria checklist. The `.opencode/instructions.md` file has not been created. Full implementation is gated on OpenCode plugin API stabilization. Do not advertise as shipped.

### Portability principle

Any portability effort starts by adapting the host-specific adapter layer, not the skill content. The adapter boundary is: if the change affects `skills/`, `agents/`, `templates/`, or `examples/`, it is a content change — not a portability adapter. Reject it or upstream it to core.
