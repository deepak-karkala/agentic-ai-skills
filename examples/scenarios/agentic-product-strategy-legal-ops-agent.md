# Scenario: Defining Product Strategy for a Legal Ops Agent

## Trigger

> `/agentic-product-strategy`
>
> "We're building an agent that helps in-house legal teams review and redline NDAs. We're a 6-person startup. Help us define our product strategy — ICP, wedge, and go-to-market."

## Command: /agentic-ai-engineering:agentic-product-strategy

## Skill: agentic-product-strategy

### Inputs gathered

1. Product: NDA review and redlining agent for in-house legal teams
2. Team: 6-person startup, pre-revenue
3. Current alternative: Lawyers review manually (30–120 min per NDA); some use generic ChatGPT informally
4. Target segment: Mid-market companies (200–2000 employees) with in-house legal (1–5 attorneys)
5. Business model: Usage-based (per document) with a team subscription option

### Step 2 — ICP defined

**Role:** In-House Corporate Counsel or Legal Operations Manager at a mid-market B2B company  
**Workflow:** Receiving a vendor or partner NDA, reviewing against company playbook, flagging non-standard clauses, proposing redlines, and returning a marked-up document for negotiation  
**System:** Microsoft Word + Outlook + DocuSign; some teams use contract lifecycle management (CLM) tools (Ironclad, ContractPodAi)

**Validation notes:**
- This ICP reviews NDAs frequently (5–30/month depending on deal volume) — sufficient volume
- Legal ops manager often has budget authority for productivity tools under $20K/year
- 30–90 day pilot is feasible: NDA turnaround time is immediately measurable
- Regulatory consideration: legal advice must be attorney-supervised; product must be positioned as decision support, not autonomous legal counsel

### Step 3 — Wedge score

| # | Dimension | Score | Notes |
|---|---|---|---|
| 1 | Verifiability | 3 | Turnaround time, redline acceptance rate, and time-to-sign are immediately measurable |
| 2 | Reversibility | 3 | Fully reversible — Word + email workflow unchanged; agent adds a review layer |
| 3 | Workflow criticality | 2 | NDAs block deals but are not daily ops; medium criticality |
| 4 | Data advantage | 2 | Agent learns the company's specific playbook and prior redline patterns over time — modest but real advantage |
| 5 | Switching cost | 2 | After 6 months, agent has ingested company's playbook and 100+ prior negotiations — switching means rebuilding that context |
| 6 | Competitive differentiation | 2 | Head start on legal-domain prompting; larger CLM players could add this feature, but integration and playbook capture provide runway |
| 7 | Expansion path | 3 | NDA → MSA → SOW → full contract lifecycle; natural expansion within the same ICP |

**Score: 17/21 — Strong wedge**

No critical dimension failures (verifiability: 3, reversibility: 3).

### Step 4 — Product architecture tier

**Tier 2: Workflow-integrated**

The product is not a thin wrapper: it reads the company's playbook, integrates with Word/Outlook, and accumulates redline history. However, it is not yet Tier 3 (domain-specialized) — that requires encoding the nuanced judgment of senior attorneys across edge-case clause interpretation.

**Thin-wrapper risk assessment:** Low. The playbook ingestion and document integration create differentiation that a raw ChatGPT wrapper cannot replicate without weeks of prompt engineering per customer.

**Path to Tier 3:** Integrate with legal research databases (Westlaw, LexisNexis) and encode clause-level risk heuristics from experienced legal professionals.

### Step 5 — GTM motion

**Land (PLG) — Primary motion**

- Free tier: 10 NDAs/month, standard playbook only
- PLG fit: A solo in-house attorney can get a meaningful result in 15 minutes by uploading an NDA and the company's standard playbook
- Viral signal: Redlined documents are shared back to counterparty — visibility outside the company is limited, but internal spread happens when the attorney shares the tool with their ops team

**Expand (Enterprise) — Second motion**

- Trigger: After PLG proves ROI, champion escalates to General Counsel + IT for org-wide deployment
- Enterprise features needed: SSO, audit logs, matter-level reporting, CLM integrations

**Scale (Regulated) — Not recommended for Year 1**

- Highly regulated legal contexts (financial services M&A, pharma licensing) require deeper compliance investment
- Address in Year 2 after Expand motion validates unit economics

### Step 6 — Moat-building plan

**Priority moats for first 12 months:**

1. **Context advantage**: Store each company's playbook, past redline decisions, and negotiation patterns. After 100+ NDAs, this context is a meaningful switching cost — competitors would need months to replicate.

2. **Domain SOP capture**: Interview 10–20 corporate attorneys to encode standard NDA clause interpretations, risk tiers, and negotiation heuristics. This goes into the system prompt and eval golden fixtures — not replicable by a generalist model.

3. **Evaluation advantage**: Build a labeled dataset of attorney-accepted vs. rejected redlines. This eval set is proprietary and enables quality improvements that competitors without production data cannot match.

### Document written

`.agentic/artifacts/product-strategy-legal-ops-nda-agent.md`

```
Product Strategy: Legal Ops NDA Agent

ICP: In-house corporate counsel / legal ops manager
Workflow: NDA review, redlining, and negotiation prep
System: Word + Outlook + DocuSign

Wedge score: 17/21 — Strong wedge
GTM motion: Land (PLG) → Expand (Enterprise)

Critical flags: None (verifiability 3/3, reversibility 3/3)
Architecture tier: Workflow-integrated (Tier 2) — not a thin wrapper

Top risk: Regulatory positioning — product must be framed as decision 
support for attorneys, not autonomous legal counsel. Affects marketing 
copy, terms of service, and HITL design.

Recommended next steps:
1. /agentic-plan — design the agent architecture (playbook ingestion, 
   Word integration, redline generation)
2. /agentic-economics-and-moats — model unit economics at PLG price point 
   vs. inference cost per document
```
