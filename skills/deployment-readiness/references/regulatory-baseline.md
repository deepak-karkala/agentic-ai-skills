# Regulatory Baseline for Agentic AI

Engineering-facing summaries only. Not legal advice.

## Applicability Table

| Regulation | Applies when | Minimum requirement |
|---|---|---|
| **EU AI Act (Art. 6, enforced Aug 2026)** | Healthcare decisions, credit scoring, employment screening, law enforcement | Human oversight (understand, monitor, halt, override); 10-year audit trail retention |
| **GDPR / CCPA** | Agent stores or processes personal data | Agent memory is personal data; Article 17 erasure right applies; pseudonymization required if retention window > erasure obligation |
| **HIPAA** | Agent touches Protected Health Information | Business Associate Agreement required; 6-year audit retention; PHI access logging mandatory |
| **NIST AI RMF (AI 100-1)** | US federal context or enterprise procurement requirement | Govern (accountability chain), Map (delegation chains), Measure (continuous eval), Manage (circuit breakers, rollback) |
| **ISO/IEC 42001** | Enterprise customer procurement requirement | AI management system standard; increasingly required in vendor contracts |

## GDPR / EU AI Act Conflict Resolution

EU AI Act requires 10-year audit trail retention. GDPR Article 17 requires erasure on request. These conflict when the same record serves both audit and personal data purposes.

**Resolution — pseudonymization architecture:**

1. Store all audit events with a pseudonymous identifier (not the real user ID)
2. Maintain a separate key store mapping pseudonymous ID → real user ID
3. On erasure request: delete the key — the pseudonymous audit records remain intact, satisfying retention
4. The audit trail preserves structural integrity; the user's identity is irretrievably removed

This architecture satisfies both obligations. It must be designed in from the start; retrofitting is expensive.

## EU AI Act High-Risk Categories (Article 6)

The following use cases are classified as high-risk under the EU AI Act. If your agent operates in these domains, Article 14 human oversight requirements apply:

- Healthcare: clinical decision support, triage, insurance risk scoring
- Finance: credit scoring, creditworthiness assessment (fraud detection is excluded)
- Employment: candidate screening, worker management, performance assessment
- Law enforcement: crime risk assessment, biometric identification
- Education: student assessment, access to educational institutions

**Penalty:** €35M or 7% of global annual revenue, whichever is higher.
