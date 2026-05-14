# Eval Anti-Pattern Reference

Check your eval design against these anti-patterns before shipping.

## Anti-Pattern Table

| Anti-pattern | Signal | Fix |
|---|---|---|
| **Reward-Hacking Evals** | Agent scores well on evals but fails on production variants | Check if agent has learned to pattern-match eval inputs; add distribution shift tests from production traffic |
| **Outcome-Only Scoring** | Evals measure final answer but not the path taken | Add trajectory metrics for any multi-step task — use Precision/Recall/F1 for open-ended, Exact Match for deterministic |
| **Uncalibrated LLM Judge** | Judge agreement with human < 80%, or judge was never calibrated | Calibrate on ≥ 50 human-labeled examples; require structured verdict format (PASS/FAIL/PARTIAL + evidence) |
| **Eval-Production Gap** | CI/CD evals pass; production quality degrades on new input types | Add production traffic sampling; expand golden set monthly from production failures |
| **No Adversarial Coverage** | Eval suite has only happy-path tests | Add adversarial set: prompt injection, malformed inputs, tool failures, permission boundary probes |
| **Stale Golden Set** | Golden tasks haven't been updated since initial launch; new agent behaviors not tested | Audit golden set when agent capabilities or tools change; remove examples that no longer reflect current behavior |

## Most Common Anti-Pattern by Stage

- **Pre-launch**: Outcome-only scoring (no trajectory metrics)
- **Post-launch, first 90 days**: Eval-production gap (golden set doesn't cover real traffic distribution)
- **Post-launch, 6+ months**: Stale golden set (agent has evolved but tests haven't)
- **Quality review**: Uncalibrated LLM judge (false confidence in eval numbers)
