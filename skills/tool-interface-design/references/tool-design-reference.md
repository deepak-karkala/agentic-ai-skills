# Tool Design Reference

Reference for the `tool-interface-design` skill. Contains ACI patterns, tool schema formats, description templates, granularity anti-patterns, MCP manifest format, and structured error response design.

---

## ACI Pattern Library

### Pattern 1: Poka-Yoke Tool Design

**Goal:** Make common misuses impossible at the schema level, not the error-handling level.

**Example — absolute path enforcement:**
```python
# BAD: accepts relative paths → navigation errors
def read_file(path: str) -> str: ...

# GOOD: validates at entry
def read_file(absolute_path: str) -> str:
    if not absolute_path.startswith("/"):
        return {"error": "INVALID_PATH", "message": "absolute_path must start with /. Got: " + absolute_path}
    ...
```

**Example — destructive confirmation:**
```python
# BAD: agent can delete without explicitly confirming
def delete_record(record_id: str) -> dict: ...

# GOOD: requires confirmation parameter
def delete_record(record_id: str, confirm_destructive: bool) -> dict:
    if not confirm_destructive:
        return {"error": "CONFIRMATION_REQUIRED", "message": "Set confirm_destructive=True to proceed. This action is irreversible."}
    ...
```

---

### Pattern 2: Structured Error Feedback

When a tool fails, return a structured object — not a Python exception, not a boolean, not a raw HTTP error.

**Standard error structure:**
```json
{
  "error": "TOOL_ERROR_CODE",
  "message": "Human-readable explanation of what went wrong",
  "details": {
    "field": "the parameter that caused the error (if applicable)",
    "received": "the value that was provided",
    "expected": "what was expected"
  },
  "retry_guidance": "How the agent should modify the call to recover"
}
```

**Error codes to standardize:**
| Code | When to use |
|---|---|
| `INVALID_PARAMETER` | Parameter value is wrong type, out of range, or malformed |
| `RESOURCE_NOT_FOUND` | The entity being acted on doesn't exist |
| `PERMISSION_DENIED` | The tool is not authorized for the current context |
| `RATE_LIMITED` | The underlying API is rate limiting; retry after backlog clears |
| `EXTERNAL_UNAVAILABLE` | Downstream API or service is unreachable |
| `CONFIRMATION_REQUIRED` | Destructive action requires explicit confirmation parameter |
| `PARTIAL_SUCCESS` | Tool completed partially; details in response |

**Why this matters for agents:** When a tool returns `{"error": "INVALID_PARAMETER", "details": {"field": "date_range", "received": "2024-13-01", "expected": "ISO 8601 date YYYY-MM-DD"}}`, the agent's next reasoning step directly identifies the fix. When a tool returns `False` or raises an exception, the agent's next step is to guess.

---

### Pattern 3: Tool Description Template

**Structure for every tool description:**
```
[One-sentence summary: what this tool does]

Use this tool when: [specific trigger condition — what the agent is trying to accomplish]

Do NOT use this tool to [common misuse case] — use [correct tool] instead.

Returns: [brief description of return structure]
[Optional: "Note: this action is irreversible" or "Note: modifies [resource X]"]
```

**Example — good description:**
```
Search customer records by email, name, or account ID.

Use this tool when you need to look up a customer's account details, 
order history, or contact information before drafting a response.

Do NOT use this tool to check order status — use search_orders instead.

Returns: customer object with fields: id, name, email, plan_tier, 
account_status, created_at. Returns null if no match found.
```

**Example — bad description (what to avoid):**
```
Gets customer info.
```

This is a common failure pattern — the description is technically accurate but doesn't help the agent make tool selection decisions.

---

### Pattern 4: The Non-Use Example

Every tool with a plausible look-alike must have an explicit non-use example. The non-use example prevents the most common tool confusion errors.

**Look-alike pairs to watch for:**
| Tool A | Tool B | Distinguishing non-use |
|---|---|---|
| `search_orders` | `search_customers` | "Do NOT use search_orders to look up a customer's contact info — use search_customers" |
| `update_record` | `create_record` | "Do NOT use update_record if the record might not exist — use create_or_update_record or check first with get_record" |
| `send_email` | `draft_email` | "Do NOT use send_email to preview what will be sent — use draft_email first" |
| `delete_draft` | `delete_record` | "Do NOT use delete_draft for published records — use archive_record instead" |

---

## Tool Schema Formats

### JSON Schema Format (for OpenAI / Anthropic tool-use API)

```json
{
  "name": "search_orders",
  "description": "Search customer orders by customer ID, order status, or date range. Use when you need to retrieve order history or check fulfillment status. Do NOT use this to look up customer contact information — use search_customers instead.",
  "input_schema": {
    "type": "object",
    "properties": {
      "customer_id": {
        "type": "string",
        "description": "The customer's unique identifier (UUID format). Required unless date_range is provided."
      },
      "status": {
        "type": "string",
        "enum": ["pending", "processing", "shipped", "delivered", "cancelled"],
        "description": "Filter by order status. Omit to return all statuses."
      },
      "date_range": {
        "type": "object",
        "properties": {
          "from": {"type": "string", "description": "ISO 8601 date (YYYY-MM-DD)"},
          "to": {"type": "string", "description": "ISO 8601 date (YYYY-MM-DD)"}
        },
        "required": ["from", "to"]
      },
      "limit": {
        "type": "integer",
        "minimum": 1,
        "maximum": 100,
        "default": 20,
        "description": "Maximum number of orders to return."
      }
    },
    "required": []
  }
}
```

**Schema design rules:**
- Use `enum` for any parameter with a fixed set of valid values — prevents hallucinated values
- Use `description` fields on every parameter — these are read by the model at inference time
- Set sensible defaults to reduce required parameters
- Never use `anyOf` or `oneOf` for tool parameters — models struggle with these at inference time

---

### MCP Tool Manifest Format

```json
{
  "tools": [
    {
      "name": "crm_contact_search",
      "description": "Search CRM contacts by name, email, or company. Returns a list of matching contacts with basic profile data. Do NOT use this for order data — use crm_order_search instead.",
      "inputSchema": {
        "type": "object",
        "properties": {
          "query": {
            "type": "string",
            "description": "Search query: name, email address, or company name"
          },
          "limit": {
            "type": "integer",
            "default": 10,
            "description": "Maximum results to return (1–50)"
          }
        },
        "required": ["query"]
      }
    }
  ]
}
```

**MCP namespace convention:**
- Format: `<server_id>_<resource>_<action>`
- `server_id`: short identifier for the MCP server (e.g., `crm`, `billing`, `inventory`)
- `resource`: the entity type being acted on (e.g., `contact`, `order`, `account`)
- `action`: the operation (e.g., `search`, `get`, `create`, `update`, `delete`)

This prevents collisions when an agent connects to multiple MCP servers, and makes tool discovery predictable.

---

## Granularity Anti-Patterns

### Anti-Pattern 1: The Action Enum God Tool

```json
{
  "name": "manage_customer",
  "description": "Manage customer records. Action can be: get, search, create, update, delete, merge, archive, export.",
  "parameters": {
    "action": {"type": "string", "enum": ["get", "search", "create", "update", "delete", "merge", "archive", "export"]},
    "customer_id": {"type": "string"},
    "query": {"type": "string"},
    "fields": {"type": "object"}
  }
}
```

**Problem:** The agent must select both the tool AND the action mode. Error rate compounds. Parameter requirements vary by action — `query` is required for `search` but meaningless for `delete`.

**Fix:** Split into `get_customer`, `search_customers`, `create_customer`, `update_customer`, `delete_customer`, etc. Each tool has consistent, purpose-matched parameters.

---

### Anti-Pattern 2: Tool Overload

An agent with more than 15–20 tools degrades in tool selection accuracy. Signs:
- Agent calls `tool_A` when it should call `tool_B` despite different descriptions
- Agent calls the same wrong tool repeatedly across different sessions
- Debug traces show the agent reasoning about multiple plausible tools before selecting incorrectly

**Fix options:**
1. **Dynamic tool masking:** At each workflow phase, expose only the subset of tools relevant to the current phase. A tool that is not visible cannot be called incorrectly.
2. **Tool grouping via prompt:** Group tools by category in the system prompt and describe the intended use pattern for each category.
3. **Merge related read tools:** If there are 5 separate "search" tools for different fields of the same resource, consider merging them into a single `search_resource(query_type, query_value)` with an enum for `query_type`.

---

### Anti-Pattern 3: Opaque Return Structure

```python
def get_order(order_id: str) -> dict:
    # Returns the full order object with nested fields
    ...
```

**Problem:** The agent doesn't know what to expect from the return value. It may try to access fields that don't exist, or miss the field it needs.

**Fix:** Document the return structure in the tool description:
```
Returns: order object with fields: id (string), status (string), 
created_at (ISO 8601), items (array of {sku, quantity, price}), 
customer_id (string), shipping_address (object). Returns null if order not found.
```

---

## Permission Tier Design: Decision Flowchart

```
Does this tool change any state?
  No → Read tier
  Yes ↓

Is the change reversible?
  Yes → Write tier
  No ↓

Does the change affect only the current session/task, 
or does it persist beyond the session?
  Session-only → Write tier
  Persistent ↓

Does the change affect system configuration, 
user accounts, or permissions?
  Yes → Admin tier
  No → Destructive tier
```

**Confirmation parameter pattern for Destructive tier:**
```python
def cancel_subscription(
    subscription_id: str, 
    confirm_destructive: bool,
    reason: str = ""
) -> dict:
    """
    Permanently cancel a customer subscription. This action is irreversible.
    
    confirm_destructive must be set to True explicitly. Do not set it to True 
    unless the user has confirmed they want to cancel.
    """
    if not confirm_destructive:
        return {
            "error": "CONFIRMATION_REQUIRED",
            "message": "This action permanently cancels the subscription. Set confirm_destructive=True to proceed.",
            "warning": "This action cannot be undone."
        }
    ...
```

---

## Tool Inventory Table Template

Use this table in the tool interface spec to provide a quick-scan view:

| Tool name | Tier | Reversible | Side effects | Description (one line) |
|---|---|---|---|---|
| `search_orders` | Read | N/A | None | Search orders by customer, status, or date |
| `get_order` | Read | N/A | None | Retrieve a specific order by ID |
| `update_order_status` | Write | Yes (re-update) | Modifies order record | Change status of an existing order |
| `send_notification` | Destructive | No | Sends external message | Send email or SMS to customer |
| `cancel_order` | Destructive | No | Cancels order, triggers refund | Permanently cancel an order |
| `update_api_keys` | Admin | Yes | Modifies system config | Rotate API keys for a service |
