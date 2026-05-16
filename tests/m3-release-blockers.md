# Milestone 3 Public-Release Blocker Register

Maps each public-release blocker to an explicit M3 task. Produced by Phase 0 Task 3.

Blocker categories: Evidence (E), Structural (S), Documentation (D), Routing (R).

---

## Blocker Register

### E1 — `examples/outputs/` is empty

**Category:** Evidence  
**Current state:** `examples/outputs/` contains only `.gitkeep`. No committed rendered artifact output exists.  
**Impact:** Any new user inspecting the repo cannot verify that the templates produce correct output without running the plugin. Reduces trust in artifact quality claims.  
**M3 task:** Task 4 — Add rendered example outputs for all artifact types  
**Acceptance:** `examples/outputs/` contains at least one committed rendered output per artifact type (3 HTML + 2 Markdown).

---

### E2 — No artifact rendering verification beyond template presence

**Category:** Evidence / Structural  
**Current state:** `scripts/validate-plugin.sh` checks that template files exist and contain at least one `{{...}}` placeholder. It does not verify scalar substitution, repeated section expansion, zero-row sections, placeholder exhaustion, or Markdown table structure.  
**Impact:** A template could contain malformed substitution blocks or broken table structure and pass validation. Public users have no machine-checked proof that templates render correctly.  
**M3 task:** Task 5 — Add artifact rendering verification scripts or fixtures  
**Acceptance:** Rendering fixtures exist; seeded rendering error causes a predictable validation failure.

---

### E3 — No committed smoke-test evidence for Codex adapter

**Category:** Evidence  
**Current state:** `adapters/codex.md` is a prose adapter guide. No committed test transcript, session note, or fixture demonstrates that the setup path was followed and a skill was actually invoked end-to-end.  
**Impact:** A public user following the Codex adapter guide cannot tell whether it was validated. The adapter may overstate what works.  
**M3 task:** Task 6 — Add committed smoke-test evidence for Codex  
**Acceptance:** `tests/smoke/` contains Codex smoke-test notes covering setup, one core workflow, one artifact-producing path.

---

### E4 — No committed smoke-test evidence for Gemini/ADK adapter

**Category:** Evidence  
**Current state:** `adapters/gemini-adk.md` includes a `fill_template()` Python example and usage notes but no committed end-to-end test evidence.  
**Impact:** The adapter is documented but not demonstrated. HTML escaping and unreplaced-placeholder check are described but not shown as working.  
**M3 task:** Task 6 — Add committed smoke-test evidence for Gemini/ADK  
**Acceptance:** `tests/smoke/` contains Gemini/ADK smoke-test notes covering setup, one workflow, one artifact path.

---

### D1 — OpenCode status is ambiguous across files

**Category:** Documentation  
**Current state:**
  - `README.md:138` — "Spec complete" in host support table
  - `RELEASE.md:93` — M2 gate item says "acceptance criteria checklist is present and gated on plugin API stabilization"
  - `RELEASE.md:139` — Portability section says "Spec complete (Milestone 2)"
  - `adapters/opencode.md` — Status header says "Spec-complete. Ready to implement when OpenCode's plugin API stabilizes."
  - `AGENTS.md:490` — host support table lists OpenCode without a status label
**Impact:** Public users get inconsistent signals. The status claim in README, RELEASE, AGENTS, and the adapter itself must agree on exactly one status.  
**M3 task:** Task 7 — Decide OpenCode status honestly  
**Acceptance:** README, RELEASE, AGENTS.md, and `adapters/opencode.md` all state the same OpenCode status with no ambiguity.

---

### D2 — README does not reflect M3 skills (pre-M3 implementation)

**Category:** Documentation  
**Current state:** README skills table lists 17 skills (M1 + M2). After M3 implements 4 new skills, README will be stale.  
**Impact:** Post-M3, README underreports the plugin surface and new users cannot discover the new capabilities.  
**M3 task:** Task 20 — Refresh public-facing documentation  
**Acceptance:** After M3 implementation, README reflects all 21 skills, updated subagent count, and M3 evidence.  
**Note:** This blocker resolves only after Phase 2 (M3 skills implemented) is complete.

---

### D3 — RELEASE.md has no M3 public-release gate

**Category:** Documentation  
**Current state:** `RELEASE.md` contains M1 and M2 milestone-specific gates. There is no M3 gate section covering evidence requirements, adapter smoke requirements, scenario coverage, or public-release packaging.  
**Impact:** M3 cannot be signed off without a gate. Manual sign-off has no checklist.  
**M3 task:** Task 19 — Update release gate for public release  
**Acceptance:** RELEASE.md contains an M3/public-release gate section covering structure, content, artifact outputs, subagent behavior, adapter evidence, and baseline comparison.

---

### S1 — `tests/fixtures/`, `tests/golden/`, `tests/smoke/` are empty

**Category:** Structural  
**Current state:** Three test subdirectories contain only `.gitkeep`. No fixtures, golden outputs, or smoke-test records exist.  
**Impact:** The validation harness is structurally present but has no test content. New M3 rendering verification (Task 5) and adapter smoke evidence (Task 6) will populate these.  
**M3 task:** Task 5 (fixtures), Task 6 (smoke), Task 18 (extend harness)  
**Acceptance:** Each directory has at least one real file after M3 Phase 1 implementation.

---

### S2 — Validation harness does not check M3 surfaces

**Category:** Structural  
**Current state:** `scripts/validate-plugin.sh` at 133 checks covers M1 + M2 surfaces. It does not check for M3 skills, new subagents, new scenarios, rendered output examples, or smoke-test evidence presence.  
**Impact:** After M3 adds 4 skills, 2 subagents, scenarios, and output examples, the harness will not catch missing or malformed M3 content.  
**M3 task:** Task 18 — Extend validation harness for M3 surfaces  
**Acceptance:** Harness count grows to cover M3 skills, subagents, scenarios, output examples, and (where feasible) smoke-test evidence presence.

---

### R1 — No routing coverage for M3 skills in AGENTS.md or CLAUDE.md

**Category:** Routing  
**Current state:** AGENTS.md and CLAUDE.md routing tables cover M1 + M2 skills only. No trigger phrases, non-trigger exclusions, or delegation rules exist for `latency-and-cost-optimization`, `agentic-security`, `incident-investigation`, or `hallucination-containment`.  
**Impact:** M3 skills are not auto-routable until routing entries are added. Skills without routing entries are effectively invisible to the plugin's intent-matching layer.  
**M3 task:** Task 15 — Extend routing for M3 skills and subagents  
**Acceptance:** Each M3 skill has explicit trigger phrases and non-trigger exclusions in AGENTS.md; delegation rules for new subagents appear in CLAUDE.md.

---

### R2 — No routing dry-run for M3 surfaces

**Category:** Routing  
**Current state:** `tests/routing-dry-run-m2.md` covers M2 skills only. No M3 routing dry-run exists.  
**Impact:** M3 routing has no documented evidence of correct disambiguation against neighboring skills.  
**M3 task:** Task 15 (dry-run added alongside routing extension)  
**Acceptance:** `tests/routing-dry-run-m3.md` covers all 4 M3 skills with obvious-trigger, paraphrase-trigger, and non-trigger rows.

---

## Summary by M3 Task

| Blocker | Resolved by M3 Task |
|---|---|
| E1 — empty examples/outputs/ | Task 4 |
| E2 — no rendering verification | Task 5 |
| E3 — no Codex smoke evidence | Task 6 |
| E4 — no Gemini/ADK smoke evidence | Task 6 |
| D1 — OpenCode status inconsistent | Task 7 |
| D2 — README stale post-M3 | Task 20 |
| D3 — no M3 release gate | Task 19 |
| S1 — test directories empty | Tasks 5, 6, 18 |
| S2 — harness doesn't cover M3 | Task 18 |
| R1 — no M3 routing entries | Task 15 |
| R2 — no M3 routing dry-run | Task 15 |

All 11 blockers have explicit M3 task assignments. No unresolved ambiguity remains.
