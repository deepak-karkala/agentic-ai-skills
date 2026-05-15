# Issue Templates

Templates and sizing guidance for `agentic-to-issues`. Use these when the user wants structured, GitHub-ready output rather than a bare Markdown checklist.

---

## Markdown Checklist Format (default)

```markdown
## Foundation
- [ ] [foundation] Set up agent scaffold and environment (blocked-by: nothing)
- [ ] [foundation] Implement shared tool interface contracts

## Implementation
- [ ] [implementation] Implement tool: <tool-name> (blocked-by: scaffold)
- [ ] [implementation] Implement agent control loop (blocked-by: tool interfaces)
- [ ] [implementation] Implement state management / session store

## Eval
- [ ] [eval] Set up eval harness for <agent-name> (blocked-by: control loop)
- [ ] [eval] Implement deterministic graders for tool call correctness
- [ ] [eval] Create golden test fixtures for core scenarios

## Rollout
- [ ] [rollout] Deploy in shadow mode (blocked-by: eval harness)
- [ ] [rollout] Wire guardrails and approval gates
- [ ] [rollout] Set up MELT observability (metrics, events, logs, traces)
- [ ] [rollout] Gated release with traffic ramp
```

---

## Structured Issue Format (GitHub-ready)

```markdown
### [phase/implementation] Implement <component>

**Description:**
One paragraph describing what this issue delivers and why it is needed at this point.

**Done when:**
- [ ] <specific, testable condition 1>
- [ ] <specific, testable condition 2>
- [ ] Unit tests pass for this component

**Depends on:**
- `[foundation] <prerequisite issue title>`

**Labels:** `phase/implementation`, `component/<name>`, `size/<S|M|L>`

**Notes:**
Any design constraints, references to relevant sections of the architecture plan, or known risks.
```

---

## Sizing Guide

| Size | Scope | Typical effort |
|---|---|---|
| S (small) | Single function, endpoint, or tool stub | Half day to one day |
| M (medium) | One coherent component with tests | Two to three days |
| L (large) | Should be split further if possible | More than three days |

An issue that cannot be defined at size M or smaller is a signal to split it or to revisit the architecture — the design is likely not specific enough.

---

## Category Templates

### Foundation issues

Foundation issues establish the structural preconditions. They should:
- Name the scaffold, environment, or interface being created
- Have zero external dependencies (they are the base layer)
- Include a setup-verification done-when criterion

```markdown
### [foundation] Set up <framework> agent scaffold

**Done when:**
- [ ] Agent can be instantiated and accepts a task input
- [ ] At least one tool stub is wired and callable
- [ ] Local environment runs without errors
```

### Implementation issues

Implementation issues build the core agent behavior. They should:
- Reference the specific pattern or component from the architecture plan
- Have exactly one or two upstream dependencies, not more
- Include a functional done-when criterion, not just "code written"

```markdown
### [implementation] Implement <component>

**Done when:**
- [ ] Component passes <specific scenario> end to end
- [ ] Error path returns a structured failure (not an exception)
- [ ] Integration test against <tool or service> passes
```

### Eval issues

Eval issues should be paired with the implementation issue they test, not batched at the end. This ensures eval coverage does not drift from the implementation.

```markdown
### [eval] Graders for <component>

**Done when:**
- [ ] Deterministic grader covers <specific tool call correctness check>
- [ ] LLM-as-judge prompt written and calibrated on 10+ examples
- [ ] Pass/fail threshold documented and justified
```

### Rollout issues

Rollout issues sequence shadow → gated → full. Each phase should have an explicit gate criterion before the next phase starts.

```markdown
### [rollout] Shadow mode deployment

**Done when:**
- [ ] Agent runs on live traffic without affecting outcomes (observe-only)
- [ ] Trace logging is active and reviewed for at least <N> sessions
- [ ] No critical failures in shadow observations

**Gate before next phase:**
- Shadow observation period: <N days>
- Error rate threshold: <X%>
- Human reviewer sign-off on sample traces
```

---

## Dependency Sequencing Rules

1. **Foundation before implementation.** No implementation issue should start before the scaffold is ready.
2. **Implementation before eval harness.** The eval harness tests the component; it cannot be fully written before the component's interface is stable.
3. **Eval before rollout.** The rollout gate requires eval coverage; do not deploy to shadow without at least the deterministic graders in place.
4. **Shadow before gated before full.** Each rollout phase requires the previous phase's gate criteria to be met.

Violations of these rules (e.g., starting rollout before evals exist) are explicit risks and should be flagged in the issue list output.
