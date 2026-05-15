# Scenario: Designing Tool Contracts for a Customer Support Agent

## Trigger

> "How should I design the tools for this agent?"
>
> "We're building a customer support agent that handles billing questions, order status, and subscription management. It needs to look up customers, check orders, and in some cases issue refunds or cancel subscriptions. The agent keeps calling the wrong tool — 'get_customer' when it should call 'search_orders'. Help us design the tool interface."

## Skill: tool-interface-design

### Inputs gathered

1. Workflow: Resolve customer support tickets — look up customer and order history, answer billing questions, update order status, issue refunds, escalate when needed
2. External systems: CRM (customer records), OMS (order management), billing API
3. Agent autonomy level: L2 (supervised) — agent drafts; support rep approves refunds and cancellations
4. Permission constraints: Agents can read freely; write operations require support-tier auth; refunds/cancellations require supervisor approval

### Step 2 — ACI issues identified

**Current problem — look-alike confusion:** `get_customer` and `search_orders` have similar one-line descriptions and the agent is selecting the wrong one.

**Root cause:** Both descriptions say "look up [entity]" without explaining *when* to use each. The agent lacks the disambiguation signal.

**Fix:** Add explicit "Do NOT use this tool to..." non-use examples to both tools.

**Additional issue:** `cancel_subscription` has no confirmation parameter — the agent could cancel unintentionally in an autonomous mode.

### Step 3 — Granularity decision

**Current tool set (before redesign):** 6 tools
- `get_customer(customer_id)` — confused with search_orders
- `search_orders(query)` — too broad (mixes customer lookup with order status)
- `update_order(order_id, fields)` — action enum anti-pattern risk
- `issue_refund(order_id, amount)` — missing confirmation parameter
- `cancel_subscription(customer_id)` — missing confirmation parameter
- `send_email(customer_id, template_id)` — no tone guidance

**Redesigned tool set (7 tools):**
- `search_customers` — search by name, email, account ID
- `get_order` — get specific order by ID
- `search_orders` — search orders by customer or date range
- `update_order_status` — change order status (write tier)
- `issue_refund` — issue refund with confirmation gate (destructive)
- `cancel_subscription` — cancel subscription with confirmation gate (destructive)
- `draft_customer_response` — draft reply using template + context (not send)

### Step 4 — Tool contracts (selected)

**`search_customers`**
```
Description: Search customer records by name, email address, or account ID.
Use when: You need to look up a customer's account details, plan tier, or 
contact info before answering a billing question.
Do NOT use this to check order history — use search_orders instead.
Parameters:
  - query (string, required): Name, email, or account ID to search
  - limit (integer, default 5): Max results to return
Returns: Array of {id, name, email, plan_tier, account_status}
Side effects: None
Reversible: N/A (read)
Permission: Read
```

**`issue_refund`**
```
Description: Issue a refund for a specific order line item or full order.
Use when: The support decision (by the rep) is to refund the customer.
Do NOT use this to check whether a refund is eligible — use get_order first.
Parameters:
  - order_id (string, required): The order to refund
  - amount_cents (integer, required): Amount to refund in cents
  - reason (string, required): Reason for refund (for audit log)
  - confirm_destructive (bool, required): Must be True — prevents accidental calls
Returns: {refund_id, status, amount_cents, processed_at} or error
Side effects: Initiates payment reversal; sends confirmation email to customer
Reversible: No (payment reversals cannot be reversed)
Permission: Destructive — requires supervisor approval gate at L2
```

### Step 5 — Permission tier mapping

| Tool | Tier | Gate |
|---|---|---|
| `search_customers` | Read | None |
| `get_order` | Read | None |
| `search_orders` | Read | None |
| `update_order_status` | Write | Support-tier auth |
| `draft_customer_response` | Write | None (draft only, not send) |
| `issue_refund` | Destructive | Supervisor HITL approval |
| `cancel_subscription` | Destructive | Supervisor HITL approval |

### Step 6 — MCP ergonomics

Tools exposed via two MCP servers:

**`crm` server:** `crm_customer_search`, `crm_customer_get`
**`oms` server:** `oms_order_get`, `oms_order_search`, `oms_order_update_status`, `oms_refund_issue`, `oms_subscription_cancel`

Naming follows `<server>_<resource>_<action>`. No cross-server name collisions.

### Output

`.agentic/artifacts/tool-interface-support-agent.md`

```
Tool interface spec written for customer support agent.

Tool count: 7 total
  Read: 3 (search_customers, get_order, search_orders)
  Write: 2 (update_order_status, draft_customer_response)
  Destructive: 2 (issue_refund, cancel_subscription)

Granularity flags: None — all tools have ≤3 required parameters.

Look-alike disambiguation added: search_customers and search_orders both 
have explicit "Do NOT use this to..." non-use examples.

Confirmation parameter added: issue_refund and cancel_subscription both 
require confirm_destructive=True.

Next step: /agentic-prototype to generate tool stubs with these contracts,
or /agentic-ops to design the Tool Gateway that enforces the permission 
tiers at runtime.
```
