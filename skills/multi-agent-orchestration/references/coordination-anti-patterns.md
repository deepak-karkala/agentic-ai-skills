# Coordination Anti-Pattern Reference

Check multi-agent designs against these anti-patterns. Most coordination failures are one of these eight.

## Anti-Pattern Table

| Anti-pattern | Diagnostic signal | Fix |
|---|---|---|
| **Shared Scratchpad Trap** | Agents write unstructured prose to shared state; contradictions collapse into confident conclusions | Replace with append-only event log; typed findings with evidence, confidence, source, timestamp |
| **Vague Delegation** | Subagent duplicates work or has coverage gaps; unclear authority | Work order must include objective, scope, allowed tools, forbidden actions, output schema, budget, fallback |
| **Orchestrator Bottleneck** | All information routes through manager; Specialist A's finding for Specialist B requires manager recognition | Move event routing to message bus or isolate collaborative subtasks in shared state |
| **Rubber-Stamp Verifier** | Verifier approves plausible-but-wrong output; quality theater | Verifier criteria must be explicit and independently verifiable; structured verdict required |
| **Silent Routing Failure** | Events disappear; no exception, just non-action | Track event lifecycle (not just agent outputs); correlation IDs, dead-letter queues |
| **Reactive Loop** | Agents react to each other's outputs indefinitely; no convergence | Explicit termination condition; token/step budget; convergence threshold |
| **Tool Poisoning** | Agents behave incorrectly while validation passes | Review tool descriptions like code; validate I/O strictly; pin server versions; sandbox execution |
| **False Independence** | Parallel agents collide through shared resource or hidden dependency | Explicit partition ownership; locking or versioning for any shared resource |

## Most Common by Topology

| Topology | Most likely anti-pattern |
|---|---|
| Hub-and-Spoke | Orchestrator Bottleneck, Vague Delegation |
| Parallel Fan-Out | False Independence, Shared Scratchpad Trap |
| Supervisor-with-Critic | Rubber-Stamp Verifier |
| Message Bus | Silent Routing Failure |
| Shared-State Swarm | Reactive Loop, Shared Scratchpad Trap |
| Sequential Pipeline | Vague Delegation (output contract gaps between stages) |
