# Release Notes — v0.3.0 (Milestone 3)

## Summary

v0.3.0 closes the gap between a broadly-implemented plugin and a confidently-publishable one. The release adds seven new domain skills covering production reliability, security, and cost optimization; two new specialist subagents for deep isolated analysis; a validated routing dry-run for all new surfaces; three workflows of concrete baseline comparison evidence; and public-release infrastructure (validation harness, release gate, and refreshed documentation).

**Automated validation:** `bash scripts/validate-plugin.sh` — 182 checks, 0 failures.

---

## What's New

### Seven new domain skills (M3 Phase 2)

| Skill | Lane | What it handles |
|---|---|---|
| `latency-and-cost-optimization` | Production | Token cost decomposition, model routing, prompt caching, parallelization, latency-cost tradeoffs |
| `agentic-security` | Production | Eight-threat taxonomy, tool permission tiers, secret handling, dangerous action gating, audit trail |
| `human-in-the-loop-patterns` | Production | HITL model selection (5 models), approval gate design, bounded autonomy contract, escalation ladder |
| `incident-investigation` | Reliability | Failure timeline reconstruction, six fault layer taxonomy, immediate containment decisions, durable fix routing |
| `hallucination-containment` | Reliability | Four-mode classification, grounding checks, citation requirements, verification layer design |
| `trace-error-analysis` | Reliability | Backward-tracing diagnostic from bad output to root cause span, TRAIL/MAST/six-bucket taxonomy, replay strategies |
| `agent-ui-patterns` | Architecture | Dual-panel layout, AG-UI streaming step cards, Intent Preview, Autonomy Dial, Calibrated Trust |

All seven skills are auto-routed by intent (no command wrapper needed). Each has explicit trigger and non-trigger boundaries, a step-by-step workflow, output format, scope boundaries, and at least one worked scenario.

### Two new specialist subagents (M3 Phase 3)

**`agent-reliability-engineer`** — invoked from `incident-investigation`, `hallucination-containment`, and `agent-eval-design` for deep reliability analysis. Provides: six fault layer classification (prompt/context/tool/orchestration/eval gap/policy gap), four hallucination mode assessment (retrieval failure, reasoning failure, tool misuse, unsupported assertion), runtime reliability gap identification, and eval coverage review for reliability dimensions.

**`agent-cost-performance-analyst`** — invoked from `latency-and-cost-optimization` for full-pipeline cost and latency decomposition. Provides: five-bucket cost attribution (input tokens, output tokens, tool calls, external API, infrastructure), latency segment breakdown, caching eligibility assessment, parallelization opportunity analysis, model tier overuse detection, and ranked optimization plan with effort-to-impact classification.

Delegation is evidence-based: both subagents are only invoked when multi-dimensional analysis would exceed ~500 tokens inline. Single-bottleneck questions stay inline.

### Routing and validation

- `tests/routing-dry-run-m3.md`: manual routing test table for all 7 M3 skills + 2 new subagents — obvious-trigger, paraphrase-trigger, and non-trigger cases per skill; subagent delegation dry-run with delegate/do-not-delegate cases; 14-row boundary collision summary.
- `scripts/validate-plugin.sh`: extended with Sections 10–12 (smoke-test evidence, routing dry-run evidence, baseline comparison evidence). Seeded regression test confirms failures are correctly reported.

### Baseline comparison evidence

`examples/baseline-comparison-m3.md`: three workflows comparing no-plugin / M2 / M3:

1. **Incident investigation:** structured fault-layer classification vs. generic checklist (M2). A confidence gate + circuit breaker designed from the M3 post-mortem would have reduced a 6-hour production incident to under 10 minutes.
2. **Cost/latency optimization:** per-component cost attribution vs. product-level framing (M2). 40% of latency identified as sequential tool execution (parallelizable, invisible without M3); $435/day saving projected from 1 week of implementation.
3. **Security hardening:** eight-threat taxonomy audit vs. visible-risks checklist (M2). Indirect injection from CRM notes — the highest-risk agentic-specific threat — not present in the M2 surface. API keys in context window caught as P0 launch blocker.

---

## What Has Changed

- **README.md:** M3 capabilities added to "What this plugin does"; artifacts documented with producing skill and output path; "What Works Today" section with host support status; "Best for" narrative for four primary use cases; subagent count corrected (3 → 5).
- **AGENTS.md:** 24-skill overview; four new routing table sections (reliability/incident, performance/cost/security, HITL, agent UI); 14-row M3 overlap-zone disambiguation table; trigger/boundary sections for all 7 new skills; subagent routing table updated with `agent-reliability-engineer` and `agent-cost-performance-analyst`.
- **CLAUDE.md:** All 7 new skills added to per-skill delegation table; all 7 added to `artifact_output_path` consumer list; M3 subagents registered with delegation rules; milestone note updated.
- **RELEASE.md:** Milestone 3 Release Gate added (supersedes M2 gate for new surfaces); all counts updated; machine-checked items cross-referenced to validator sections; `agent-artifact-designer` deferral re-evaluated and documented (gate still not met).
- **`.claude-plugin/plugin.json`:** Version bumped `0.2.0` → `0.3.0`.

---

## What Remains Deferred

**`agent-artifact-designer` subagent:** Gate requires ≥2 of the 5 artifact types to need dynamic section selection, multi-table composition, or conditional rendering beyond `{{VARIABLE}}` / `{{#SECTION}}...{{/SECTION}}` substitution. All 5 artifact types remain expressible with the existing rendering contract. Gate re-evaluated at M3 Phase 3 (Task 14). Not implemented. Do not revisit until a future milestone introduces artifacts requiring genuinely new rendering logic.

**OpenCode adapter:** Spec is complete (`adapters/opencode.md`). `.opencode/instructions.md` has not been created. Full implementation is gated on OpenCode plugin API stabilization. Do not advertise as shipped.

**Command wrappers for M3 skills:** All 7 M3 Phase 2 skills are auto-routed only. No named command wrappers added. This is intentional — the auto-routing surface is sufficient and command wrappers add maintenance overhead without clear user benefit for these skill types.

---

## Release Checklist Status

| Gate | Status |
|---|---|
| Automated validation (182 checks) | ✓ 0 failures |
| All 24 skills: frontmatter, description, scenario | ✓ |
| All 5 subagents: frontmatter | ✓ |
| All 5 artifact types: rendered outputs, placeholder-clean | ✓ |
| Smoke-test evidence (Codex, Gemini/ADK) | ✓ |
| Routing dry-run (M2 + M3) | ✓ |
| Baseline comparison (M2 + M3) | ✓ |
| No absolute local paths in committed files | ✓ |
| `plugin.json` version `0.3.0` | ✓ |
| `agent-artifact-designer` deferral documented | ✓ |
| OpenCode gated | ✓ (documented in README, RELEASE.md, adapters/opencode.md) |
