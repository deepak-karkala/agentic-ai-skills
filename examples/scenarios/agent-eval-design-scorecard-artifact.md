# Scenario: Eval Scorecard Artifact Generation

## Trigger

> `/agentic-evals`
>
> "We have a document classification agent that's been running in staging for two weeks. We want to audit our eval suite before moving to production. Can you generate an eval scorecard?"

## Command: /agentic-ai-engineering:agentic-evals

## Skill: agent-eval-design (audit mode → eval-scorecard HTML artifact)

### Inputs gathered

1. Agent: Document classification agent — routes legal documents to the correct workflow (contract review, NDA processing, litigation support, general filing)
2. Eval suite location: `evals/` (configured in `.agentic/config.yml` as `eval_assets_path`)
3. Artifact output path: `.agentic/artifacts/` (configured as `artifact_output_path`)
4. Current state: 2 weeks staging data, 1,200 documents processed, 3 known misclassification types

### Agent-evals-auditor findings (audit mode)

The `agent-evals-auditor` subagent is invoked because `eval_assets_path` is configured and eval artifacts exist.

#### Coverage assessment

| Dimension | Status | Evidence |
|---|---|---|
| Task Success | Tested | 180 golden documents; covers 4 routing categories |
| Trajectory Quality | **Absent** | Only final classification checked; no trajectory metrics |
| Robustness | Partial | 15 adversarial examples (mislabeled, ambiguous); missing malformed input |
| Safety & Policy | Tested | PII handling verified; no cross-workflow data leakage |
| Efficiency & Cost | Partial | Token count tracked; no latency baseline |
| Collaboration | N/A | Single-agent, no HITL in staging configuration |

**Coverage verdict: Partial** — 3/6 dimensions fully tested, 2 partial, 1 absent.

#### Grader quality

| Grader | Type | Quality | Reason |
|---|---|---|---|
| `exact_match_router` | Deterministic | Reliable | Matches classification label exactly; no false precision risk |
| `llm_classification_judge` | LLM-as-judge | **Questionable** | No calibration record; judge uses same model as agent |
| `pii_leak_check` | Deterministic | Reliable | Pattern-based PII detection; well-scoped |

#### Anti-patterns detected

| Anti-pattern | Present | Evidence |
|---|---|---|
| Reward-Hacking Evals | Present | All 180 golden docs from dev; no production-traffic sampling |
| Outcome-Only Scoring | Present | No trajectory metrics; only final label checked |
| Uncalibrated LLM Judge | Present | `llm_classification_judge` has no calibration record |
| Eval-Production Gap | Present | 3 production misclassification types not in golden set |
| No Adversarial Coverage | Absent | 15 adversarial examples exist (partial coverage) |
| Stale Golden Set | Absent | Golden set updated 3 days ago |

#### Coverage gaps

1. **Critical:** Trajectory Quality has zero tests — the agent's routing path is invisible to evals. A correct final label with a bad routing path will pass evals and fail in production on edge cases.
2. **High:** `llm_classification_judge` is uncalibrated and uses the same model as the agent. Replace judge model or calibrate against human labels before production.
3. **High:** 3 production misclassification types (contract renewals, NDA amendments, litigation holds) are not in the golden set.
4. **Medium:** No production-traffic sampling — golden set is all from development, creating reward-hacking risk.

### Output

**Eval recommendation:** Do not promote to production without: (1) adding trajectory metrics for routing path, (2) calibrating the LLM judge on ≥50 human-labeled examples or replacing the judge model, (3) adding the 3 known production misclassification types to the golden set.

**Artifact written:** `.agentic/artifacts/eval-scorecard-document-classification-agent.html`

The HTML artifact is generated from `templates/html/eval-scorecard.html`:

```
Template variables filled:
  AGENT_NAME: Document Classification Agent
  GENERATED_DATE: [date]
  COVERAGE_VERDICT: Partial
  COVERAGE_VERDICT_CLASS: partial
  DIMENSIONS_TESTED: 3
  COVERAGE_SUMMARY: Task Success, Safety, and Collaboration tested; Trajectory Quality absent; Robustness and Efficiency partial

Block sections rendered:
  DIMENSION_ROWS: 6 rows (one per scorecard dimension)
  GRADER_ROWS: 3 rows with reliability badges
  ANTIPATTERN_ROWS: 6 rows (3 present, 3 absent)
  GAP_ROWS: 4 gaps with priority and recommended fix
  PRIORITY_ITEMS: 4 implementation priorities
```

**Open in browser:** `open .agentic/artifacts/eval-scorecard-document-classification-agent.html`

**Next step:** `/agentic-ai-engineering:agentic-ops` to assess production readiness after the eval gaps are closed.
