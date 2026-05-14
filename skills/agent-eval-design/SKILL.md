---
name: agent-eval-design
description: >
  Designs the evaluation strategy for agentic AI systems. Covers the
  six-dimension scorecard, trajectory metrics, grader selection, three-tier
  eval pipeline, EDDOps lifecycle, non-determinism handling, and regression
  strategy.
  Use when setting up evals for a new agent, auditing an existing eval suite,
  choosing between LLM-as-judge and deterministic evaluators, building a
  regression suite from production failures, designing path-based evaluation,
  or diagnosing why evals pass but production quality degrades.
  Trigger phrases: "how should I evaluate this agent", "set up evals for my
  agent", "my agent passes tests but fails in production", "how do I measure
  trajectory quality", "when should I use LLM-as-judge vs deterministic",
  "build a regression suite", "what metrics should I track for my agent",
  "eval my multi-step agent", "how do I handle non-determinism in evals".
  Do not use for high-level architecture decisions (use agentic-system-design)
  or production deployment gates (use deployment-readiness).
allowed-tools:
  - Read
  - Write
metadata:
  category: reliability
  version: "0.1.0"
---

# Agent Eval Design

Evaluation strategy skill for agentic AI systems. Designs the scorecard, selects trajectory metrics and graders, builds the eval pipeline, and connects production failures back into tests.

## When to Use

**Use when:**
- Setting up evals for a new agent (start before building)
- Auditing an existing eval suite for coverage gaps
- Choosing between LLM-as-judge, deterministic, and human graders
- Building regression tests from production incidents
- Diagnosing why evals pass but production quality degrades
- Designing path-based or trajectory evaluation for multi-step agents

**Do not use when:**
- High-level agent architecture decisions → use `agentic-system-design`
- Production deployment gates, rollout posture, or HITL design → use `deployment-readiness`
- Context window or memory design → use `context-engineering-for-agents`
- Multi-agent topology or handoff contracts → use `multi-agent-orchestration`

## Workflow

### Step 1 — Gather inputs

Ask:
1. What task does the agent perform, and how long is a typical run (turns, steps)?
2. Are there existing evals or is this a new suite?
3. What actions can the agent take, and which are irreversible?
4. Is there a known failure mode or production incident prompting this?
5. What is the `eval_assets_path` configured in `.agentic/config.yml`? (Check if present.)

If in audit mode (existing evals), read the eval suite structure before proceeding.

---

### Step 2 — Apply the EDDOps lifecycle

**Eval-Driven Development for Agents (EDDOps)** — define evals before building, not after:

1. **Define evals** — before writing agent code, specify what "done" looks like
2. **Build to evals** — implement until evals pass; do not ship what you cannot measure
3. **Run continuously** — evals on every commit; gate CI/CD on regression
4. **Read traces** — inspect failing traces end-to-end; do not debug from metrics alone
5. **Convert failures to tests** — every production incident becomes a new regression test within 24 hours
6. **Refine** — improve graders and rubrics when evals diverge from human judgment
7. **Re-run** — re-run full suite after any rubric change; re-calibrate LLM judges
8. **Graduate** — promote stable tests from staging to CI/CD regression gate

**The most common mistake:** writing evals after the agent is "done." At that point the agent has been optimized for vibes, and evals measure that.

---

### Step 3 — Score the agent on six dimensions

Apply the **Six-Dimension Scorecard**. Assign a baseline target and measurement method for each dimension:

| Dimension | Weight | What it measures | Baseline target |
|---|---|---|---|
| **Task Success** | 30% | Did the agent complete the goal? | ≥ 80% pass rate on golden set |
| **Trajectory Quality** | 20% | Did the agent take the right steps to get there? | Path efficiency score ≥ 0.7 |
| **Robustness** | 15% | Does performance hold under adversarial input, tool errors, and edge cases? | < 15% drop vs. clean input |
| **Safety & Policy** | 20% | Did the agent stay within allowed actions and policy boundaries? | 0 policy violations on adversarial set |
| **Efficiency & Cost** | 15% | How many tokens, steps, and API calls did the agent use? | Within 1.5× optimal path |
| **Collaboration** | 10% | Did the agent communicate intent, ask for help at the right time, and hand off correctly? | Required only for HITL or multi-agent designs |

**Weight these for your context.** Safety & Policy is non-negotiable for external-facing agents. Collaboration weight can be zero for fully autonomous pipelines.

---

### Step 4 — Select trajectory metrics

For multi-step agents, outcome-only scoring misses the most important signal: whether the agent took the right path.

| Metric type | When to use | Measurement |
|---|---|---|
| **Exact Match** | Single correct action sequence exists; deterministic task | Score 1 if full sequence matches, 0 otherwise |
| **In-Order Match** | Correct steps exist but intermediate steps can vary; order matters | Score fraction of required steps taken in correct order |
| **Any-Order Match** | Steps must all happen but order is flexible | Score fraction of required steps taken regardless of order |
| **Precision** | Agent must not take unnecessary steps | Steps taken that were correct / total steps taken |
| **Recall** | Agent must not miss required steps | Required steps taken / total required steps |
| **Single-Tool Use** | A specific tool must (or must not) be called | Binary: was the tool called? |

**Combine Precision + Recall** into an F1 score for open-ended tasks where both over-action and under-action are errors.

**Production rule:** If your evals only measure final output and not the path, you will miss reward-hacking — agents that reach the right answer through wrong steps that happen to produce the correct output by coincidence.

---

### Step 5 — Select graders

Choose the grader type by what you are measuring:

| Grader type | Use for | Failure mode | Required safeguard |
|---|---|---|---|
| **Deterministic** | Exact string match, schema validation, format checks, tool call verification | False precision — grader passes structurally correct but semantically wrong output | Pair with at least one semantic check |
| **LLM-as-Judge** | Nuanced quality, helpfulness, tone, partial correctness | Sycophancy — judge rates confident answers higher regardless of accuracy | Calibrate judge on human-labeled examples; require structured verdict (PASS/FAIL/PARTIAL with evidence) |
| **Human** | High-stakes, new task types, calibrating LLM judges | Slow, expensive, inconsistent at scale | Batch into review sessions; use for calibration and sampling, not as primary gate |

**LLM-as-Judge checklist** (all required before deploying a judge):
- [ ] Rubric is written and versioned — judge criteria are explicit, not "is this good"
- [ ] Judge has been calibrated on ≥ 50 human-labeled examples
- [ ] Judge agreement rate with humans is ≥ 80%
- [ ] Judge outputs structured verdict: `PASS`, `FAIL`, or `PARTIAL` with evidence and failing criterion
- [ ] Judge prompt is separate from agent prompt — no cross-contamination
- [ ] Judge re-calibration is triggered when human audit finds ≥ 10% divergence

**Do not use the same model as both agent and judge.** Shared training causes the judge to rate the agent's characteristic outputs as high quality regardless of actual correctness.

---

### Step 6 — Design the three-tier eval pipeline

| Tier | When runs | What runs | Gate |
|---|---|---|---|
| **CI/CD (Regression)** | Every commit | Fast deterministic tests + golden set; ≤ 5 min | Block merge on failure |
| **Staging (Full Suite)** | Pre-deploy; nightly | Full scorecard; adversarial set; trajectory metrics | Block deploy on failure |
| **Production (KPI + Drift)** | Continuous | Task success sampling; latency; token cost; safety violations | Page on-call on threshold breach |

**Eval suite structure:**

```
evals/
  golden/           # deterministic known-good tasks with expected outputs
  open_ended/       # rubric-scored; LLM-as-judge or human graded
  adversarial/      # prompt injection, malformed inputs, tool failures
  failure_replays/  # production incidents converted to regression tests
  shared/           # schemas, fixtures, rubrics, judge prompts
```

**Golden set rules:**
- Minimum 20 tasks at launch; 100+ at production scale
- Covers happy path, edge cases, and known failure modes
- Each entry: input, expected output or acceptance criteria, grader reference
- Updated when agent capabilities change — stale goldens are worse than none

---

### Step 7 — Handle non-determinism

Agents produce different outputs on repeated runs. Single-run evals produce noisy signal.

| Strategy | When to use | How |
|---|---|---|
| **pass@k** | At least one correct answer is acceptable (exploratory tasks) | Run k times; score 1 if any run passes |
| **pass^k** | All runs must be correct (safety-critical, production pipelines) | Run k times; score 1 only if all runs pass |
| **Majority vote** | Measure consistency of a specific decision | Run k times; check if same decision appears in ≥ 70% of runs |
| **Temperature ablation** | Measure sensitivity to sampling temperature | Run at temperature 0 (deterministic baseline) and production temperature; compare |

**Default:** Run 3–5 times (k=3 minimum) for any eval in the staging tier. Single-run CI/CD evals are acceptable only for deterministic tools with temperature 0.

---

### Step 8 — Connect production failures to tests

**Production failure → regression test protocol:**

1. Capture the full trace (inputs, tool calls, intermediate outputs, final output)
2. Identify the failure category: wrong answer, policy violation, tool misuse, inefficiency, hallucination
3. Write a minimal reproduction: simplest input that triggers the failure
4. Add acceptance criteria: what the agent should have done
5. Add to `evals/failure_replays/` with a reference to the production incident
6. Confirm the new test fails on the current agent version
7. Fix the agent
8. Confirm the test now passes
9. Add to CI/CD regression gate

**Target:** < 24 hours from production failure detection to regression test in CI/CD.

---

### Step 9 — Flag eval anti-patterns

Check the design against the **eval anti-pattern table**:

| Anti-pattern | Signal | Fix |
|---|---|---|
| **Reward-Hacking Evals** | Agent scores well on evals but fails on production variants | Check if agent has learned to pattern-match eval inputs; add distribution shift tests |
| **Outcome-Only Scoring** | Evals measure final answer but not the path | Add trajectory metrics for any multi-step task |
| **Uncalibrated LLM Judge** | Judge agrees with human < 80% of time | Calibrate on labeled examples before deploying judge |
| **Eval-Production Gap** | CI/CD evals pass; production degrades on new input types | Add production sampling and drift detection; expand golden set from production traffic |
| **No Adversarial Coverage** | Eval suite has only happy-path tests | Add adversarial set: injection attempts, malformed inputs, tool failures, permission boundary tests |
| **Stale Golden Set** | Goldens haven't been updated since initial launch | Audit golden set when agent capabilities change; remove outdated examples |

---

### Step 10 — Produce the eval design output

Produce a structured eval plan:

1. **EDDOps status** — are evals defined before building, or after? (Flag if after)
2. **Six-Dimension Scorecard** — dimension targets and measurement methods for this agent
3. **Trajectory metric selection** — which metric types and why
4. **Grader selection** — deterministic / LLM-judge / human assignment per dimension; judge checklist if LLM-judge
5. **Three-tier pipeline design** — what runs at each tier, gate conditions
6. **Eval suite structure** — file layout and golden set size targets
7. **Non-determinism strategy** — pass@k vs pass^k recommendation with k value
8. **Production-to-regression protocol** — SLA for converting incidents to tests
9. **Anti-patterns flagged** — any detected with fixes
10. **Open questions** — what cannot be designed without more information

## Output Format

Structured Markdown covering the ten sections above.

If this output is part of an architecture review (called from `agentic-system-design`), return the eval design as the evaluation section of the architecture output.

If `eval_assets_path` is configured, write the scorecard and eval suite structure scaffold to that path.

## Scope Boundaries

This skill does not:
- Choose agent architecture, patterns, or autonomy level → `agentic-system-design`
- Design multi-agent topologies or handoff contracts → `multi-agent-orchestration`
- Design production guardrails, HITL gates, or deployment rollout → `deployment-readiness`
- Implement graders, test runners, or eval infrastructure — it specifies what to build; implementation is the engineer's responsibility
- Design context compression or memory architecture → `context-engineering-for-agents`
