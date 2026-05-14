# Trajectory Metric Reference

For multi-step agents, outcome-only scoring misses whether the agent took the right path. Use these metric types to evaluate trajectory quality.

## Metric Types

| Metric type | When to use | Measurement |
|---|---|---|
| **Exact Match** | Single correct action sequence exists; deterministic task | Score 1 if full sequence matches, 0 otherwise |
| **In-Order Match** | Correct steps exist but intermediate steps can vary; order matters | Score fraction of required steps taken in correct order |
| **Any-Order Match** | Steps must all happen but order is flexible | Score fraction of required steps taken regardless of order |
| **Precision** | Agent must not take unnecessary steps | Steps taken that were correct / total steps taken |
| **Recall** | Agent must not miss required steps | Required steps taken / total required steps |
| **Single-Tool Use** | A specific tool must (or must not) be called | Binary: was the tool called? |

## Combination Rules

**Precision + Recall → F1**: Use for open-ended tasks where both over-action and under-action are errors. F1 = 2 × (Precision × Recall) / (Precision + Recall).

**Typical compositions by task type:**

| Task type | Recommended metrics |
|---|---|
| Deterministic data lookup | Exact Match |
| Multi-step form completion | In-Order Match |
| Research with flexible order | Any-Order Match + Recall |
| Autonomous action agent | Precision + Recall (F1) |
| Safety-critical gate | Single-Tool Use (must NOT call) |
| Efficiency optimization | Precision only |

## Production Rule

If your evals only measure final output and not the path, you will miss reward-hacking — agents that reach the right answer through wrong steps that happen to produce the correct output by coincidence. Always add at least one trajectory metric for any multi-step task.
