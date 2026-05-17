#!/usr/bin/env bash
# validate-plugin.sh — structural validation for the agentic-ai-engineering plugin
# Non-mutating: reads files only, exits 0 on pass, 1 on any failure.
# Run from the repo root: bash scripts/validate-plugin.sh

set -euo pipefail
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PASS=0
FAIL=0

pass() { echo "  ✓ $1"; ((PASS++)) || true; }
fail() { echo "  ✗ $1"; ((FAIL++)) || true; }
header() { echo; echo "── $1 ──"; }

# ── 1. Plugin manifest ────────────────────────────────────────────────────────
header "Manifest"

MANIFEST="$REPO_ROOT/.claude-plugin/plugin.json"
if [[ -f "$MANIFEST" ]]; then
  pass "plugin.json exists"
  for field in name version description; do
    if grep -q "\"$field\"" "$MANIFEST"; then
      pass "plugin.json has field: $field"
    else
      fail "plugin.json missing field: $field"
    fi
  done
else
  fail "plugin.json not found at .claude-plugin/plugin.json"
fi

# ── 2. Skill frontmatter ──────────────────────────────────────────────────────
header "Skill frontmatter"

for skill_dir in "$REPO_ROOT/skills"/*/; do
  skill_name="$(basename "$skill_dir")"
  skill_file="$skill_dir/SKILL.md"

  if [[ ! -f "$skill_file" ]]; then
    fail "$skill_name: SKILL.md not found"
    continue
  fi

  # Extract frontmatter (between first two --- lines)
  frontmatter=$(awk '/^---/{c++; if(c==2) exit} c==1' "$skill_file")

  # Check name field matches folder
  fm_name=$(echo "$frontmatter" | grep '^name:' | sed 's/name: *//' | tr -d '"')
  if [[ -z "$fm_name" ]]; then
    fail "$skill_name: frontmatter missing 'name' field"
  elif [[ "$fm_name" != "$skill_name" ]]; then
    fail "$skill_name: frontmatter name '$fm_name' does not match folder name '$skill_name'"
  else
    pass "$skill_name: name matches folder"
  fi

  # Check description field exists
  if echo "$frontmatter" | grep -q '^description:'; then
    pass "$skill_name: has description field"
  else
    fail "$skill_name: frontmatter missing 'description' field"
  fi

  # Check description is substantive (proxy for trigger phrase coverage)
  # Count words in indented lines of the YAML multiline description block
  desc_word_count=$(awk '
    /^description:/{in_desc=1; next}
    in_desc && /^  /{words += NF}
    in_desc && /^[^ ]/{exit}
    END{print words+0}
  ' "$skill_file")
  if [[ "$desc_word_count" -gt 40 ]]; then
    pass "$skill_name: description is substantive (>40 words)"
  else
    fail "$skill_name: description may be too short (<40 words, got $desc_word_count) — check trigger phrase coverage"
  fi

  # Check disable-model-invocation for setup skill
  if [[ "$skill_name" == "setup-agentic-ai-engineering" ]]; then
    if grep -q 'disable-model-invocation: true' "$skill_file"; then
      pass "$skill_name: disable-model-invocation: true present"
    else
      fail "$skill_name: setup skill must have disable-model-invocation: true"
    fi
  fi

  # Check referenced references/ files exist
  # Extract paths from markdown links like [references/foo.md](references/foo.md)
  ref_paths=$(grep -oE '\(references/[^)]+\)' "$skill_file" | tr -d '()' || true)
  for ref in $ref_paths; do
    ref_full="$skill_dir/$ref"
    if [[ -f "$ref_full" ]]; then
      pass "$skill_name: referenced file exists: $ref"
    else
      fail "$skill_name: referenced file missing: $ref (expected at $ref_full)"
    fi
  done
done

# ── 3. Agent frontmatter ──────────────────────────────────────────────────────
header "Agent frontmatter"

for agent_file in "$REPO_ROOT/agents"/*.md; do
  [[ -f "$agent_file" ]] || continue
  agent_name="$(basename "$agent_file" .md)"
  frontmatter=$(awk '/^---/{c++; if(c==2) exit} c==1' "$agent_file")

  if echo "$frontmatter" | grep -q '^name:'; then
    pass "$agent_name: has name field"
  else
    fail "$agent_name: frontmatter missing 'name' field"
  fi

  if echo "$frontmatter" | grep -q '^description:'; then
    pass "$agent_name: has description field"
  else
    fail "$agent_name: frontmatter missing 'description' field"
  fi
done

# ── 4. Command frontmatter ────────────────────────────────────────────────────
header "Command frontmatter"

for cmd_file in "$REPO_ROOT/commands"/*.md; do
  [[ -f "$cmd_file" ]] || continue
  cmd_name="$(basename "$cmd_file" .md)"
  if awk '/^---/{c++; if(c==2) exit} c==1' "$cmd_file" | grep -q '^description:'; then
    pass "$cmd_name: has description field"
  else
    fail "$cmd_name: frontmatter missing 'description' field"
  fi
done

# ── 5. Scenario coverage ──────────────────────────────────────────────────────
header "Scenario coverage"

for skill_dir in "$REPO_ROOT/skills"/*/; do
  skill_name="$(basename "$skill_dir")"
  # Use first two dash-separated components as the search key (e.g., "context-engineering" from
  # "context-engineering-for-agents", "agent-eval" from "agent-eval-design")
  short_key=$(echo "$skill_name" | cut -d'-' -f1-2)
  scenario_count=$(ls "$REPO_ROOT/examples/scenarios/" 2>/dev/null | grep -c "$short_key" || true)
  if [[ "$scenario_count" -gt 0 ]]; then
    pass "$skill_name: has scenario coverage (matched '$short_key')"
  else
    fail "$skill_name: no scenario found in examples/scenarios/ matching '$short_key'"
  fi
done

# ── 6. Templates ─────────────────────────────────────────────────────────────
header "Templates"

# HTML templates
for html_template in architecture-review eval-scorecard rollout-readiness; do
  TEMPLATE="$REPO_ROOT/templates/html/${html_template}.html"
  if [[ -f "$TEMPLATE" ]]; then
    pass "${html_template}.html template exists"
    placeholder_count=$(grep -c '{{[A-Z_#/][A-Z_]*}}' "$TEMPLATE" 2>/dev/null || true)
    if [[ "$placeholder_count" -gt 0 ]]; then
      pass "${html_template}.html contains $placeholder_count placeholder(s) (expected)"
    else
      fail "${html_template}.html has no placeholders — template may be overwritten with rendered output"
    fi
  else
    fail "${html_template}.html template not found at templates/html/"
  fi
done

# Markdown templates
for md_template in glossary handoff; do
  TEMPLATE="$REPO_ROOT/templates/markdown/${md_template}.md"
  if [[ -f "$TEMPLATE" ]]; then
    pass "${md_template}.md template exists"
    placeholder_count=$(grep -c '{{[A-Z_#/][A-Z_]*}}' "$TEMPLATE" 2>/dev/null || true)
    if [[ "$placeholder_count" -gt 0 ]]; then
      pass "${md_template}.md contains $placeholder_count placeholder(s) (expected)"
    else
      fail "${md_template}.md has no placeholders — template may be overwritten with rendered output"
    fi
  else
    fail "${md_template}.md template not found at templates/markdown/"
  fi
done

# ── 7. Adapter files ──────────────────────────────────────────────────────────
header "Adapter files"

for adapter in codex gemini-adk opencode; do
  ADAPTER_FILE="$REPO_ROOT/adapters/${adapter}.md"
  if [[ -f "$ADAPTER_FILE" ]]; then
    pass "${adapter}.md adapter exists"
    # Adapter must have a host capability table (## What ... supports)
    if grep -q "^## What" "$ADAPTER_FILE"; then
      pass "${adapter}.md has capability section"
    else
      fail "${adapter}.md missing capability section (## What ... supports)"
    fi
    # Adapter must not reference local absolute paths
    if grep -qE '/Users/|/home/' "$ADAPTER_FILE"; then
      fail "${adapter}.md contains absolute local path"
    else
      pass "${adapter}.md: no absolute local paths"
    fi
  else
    fail "${adapter}.md adapter not found at adapters/"
  fi
done

# ── 8. No absolute local paths in committed plugin files ─────────────────────
header "No absolute local paths"

# Check committed plugin content files only (skills, agents, commands, root docs)
# Exclude: .claude/ settings, scripts themselves, and backtick-quoted documentation examples
violation_count=0
while IFS= read -r line; do
  file="${line%%:*}"
  content="${line#*:}"
  # Skip if the /Users/ reference is inside backticks (documentation example, not real path)
  if echo "$content" | grep -qE '`/Users/'; then
    continue
  fi
  # Skip .claude/ settings files
  if echo "$file" | grep -q '\.claude/'; then
    continue
  fi
  fail "absolute local path in committed file: $line"
  ((violation_count++)) || true
done < <(grep -rn '/Users/' \
  --include="*.md" --include="*.json" --include="*.html" \
  --exclude-dir=".git" --exclude-dir=".claude" \
  "$REPO_ROOT/skills" "$REPO_ROOT/agents" "$REPO_ROOT/commands" \
  "$REPO_ROOT/CLAUDE.md" "$REPO_ROOT/AGENTS.md" "$REPO_ROOT/CONTRIBUTING.md" \
  "$REPO_ROOT/README.md" 2>/dev/null || true)

if [[ "$violation_count" -eq 0 ]]; then
  pass "no absolute local paths in committed plugin files"
fi

# ── 9. Rendered example outputs ──────────────────────────────────────────────
header "Rendered example outputs"

OUTPUTS_DIR="$REPO_ROOT/examples/outputs"

# Check each of the 5 expected artifact types has at least one rendered file
for artifact_spec in \
  "architecture-review:architecture-review-*.html" \
  "eval-scorecard:eval-scorecard-*.html" \
  "rollout-readiness:rollout-readiness-*.html" \
  "glossary:glossary-*.md" \
  "handoff:handoff-*.md"
do
  artifact_type="${artifact_spec%%:*}"
  pattern="${artifact_spec#*:}"
  matches=( "$OUTPUTS_DIR"/$pattern )
  if [[ -f "${matches[0]}" ]]; then
    pass "examples/outputs/ has rendered $artifact_type (${matches[0]##*/})"
  else
    fail "examples/outputs/ missing rendered $artifact_type — expected file matching $pattern"
  fi
done

# Check no rendered output contains unreplaced placeholders
placeholder_violations=0
while IFS= read -r -d '' f; do
  filename="${f##*/}"
  if grep -q '{{' "$f" 2>/dev/null; then
    fail "rendered output has unreplaced placeholder(s): $filename"
    ((placeholder_violations++)) || true
  fi
done < <(find "$OUTPUTS_DIR" -type f \( -name "*.html" -o -name "*.md" \) ! -name ".gitkeep" -print0 2>/dev/null)

if [[ "$placeholder_violations" -eq 0 ]]; then
  pass "all rendered outputs are placeholder-clean (no unreplaced {{}})"
fi

# Check rendering-variables fixture exists
FIXTURE="$REPO_ROOT/tests/fixtures/rendering-variables.json"
if [[ -f "$FIXTURE" ]]; then
  pass "tests/fixtures/rendering-variables.json exists"
else
  fail "tests/fixtures/rendering-variables.json missing — rendering variable registry required"
fi

# ── 10. Smoke-test evidence ───────────────────────────────────────────────────
header "Smoke-test evidence"

for smoke_file in codex-smoke-test gemini-adk-smoke-test; do
  SMOKE="$REPO_ROOT/tests/smoke/${smoke_file}.md"
  if [[ -f "$SMOKE" ]]; then
    pass "tests/smoke/${smoke_file}.md exists"
    # Check file is non-trivial (more than 5 lines)
    line_count=$(wc -l < "$SMOKE" 2>/dev/null || echo 0)
    if [[ "$line_count" -gt 5 ]]; then
      pass "tests/smoke/${smoke_file}.md is non-trivial (${line_count} lines)"
    else
      fail "tests/smoke/${smoke_file}.md appears empty or trivial (${line_count} lines)"
    fi
  else
    fail "tests/smoke/${smoke_file}.md missing — smoke-test evidence required for public release"
  fi
done

# ── 11. Routing dry-run evidence ──────────────────────────────────────────────
header "Routing dry-run evidence"

for dry_run_file in routing-dry-run-m2 routing-dry-run-m3; do
  DRY_RUN="$REPO_ROOT/tests/${dry_run_file}.md"
  if [[ -f "$DRY_RUN" ]]; then
    pass "tests/${dry_run_file}.md exists"
  else
    fail "tests/${dry_run_file}.md missing — routing dry-run evidence required for public release"
  fi
done

# ── 12. Baseline comparison evidence ─────────────────────────────────────────
header "Baseline comparison evidence"

for baseline_file in baseline-comparison baseline-comparison-m3; do
  BASELINE="$REPO_ROOT/examples/${baseline_file}.md"
  if [[ -f "$BASELINE" ]]; then
    pass "examples/${baseline_file}.md exists"
    # Check file is non-trivial (more than 20 lines)
    line_count=$(wc -l < "$BASELINE" 2>/dev/null || echo 0)
    if [[ "$line_count" -gt 20 ]]; then
      pass "examples/${baseline_file}.md is non-trivial (${line_count} lines)"
    else
      fail "examples/${baseline_file}.md appears too short (${line_count} lines) — comparison may be incomplete"
    fi
  else
    fail "examples/${baseline_file}.md missing — baseline comparison required for public release"
  fi
done

echo
echo "══════════════════════════════════"
echo "  Results: $PASS passed, $FAIL failed"
echo "══════════════════════════════════"

if [[ "$FAIL" -gt 0 ]]; then
  exit 1
fi
