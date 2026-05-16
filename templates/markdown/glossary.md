# Glossary: {{PROJECT_NAME}}

> Generated {{GENERATED_DATE}} · Skill: agentic-ubiquitous-language · Plugin: agentic-ai-engineering

This glossary establishes the shared vocabulary for {{PROJECT_NAME}}. Terms are defined once here and should be used consistently across all design documents, code, and team communication.

---

## Terms

{{#TERM_ENTRIES}}
### {{TERM_NAME}}

**Definition:** {{TERM_DEFINITION}}

**Non-example:** {{TERM_NON_EXAMPLE}}

**Project-specific usage:** {{TERM_USAGE_NOTE}}

---
{{/TERM_ENTRIES}}

## Ambiguous Terms (Resolved)

The following terms had multiple competing meanings in the team before this glossary was established. The canonical definition above is the one to use going forward.

| Term | Previous conflicting meanings | Canonical choice | Reason |
|---|---|---|---|
{{#AMBIGUOUS_TERM_ROWS}}
| {{AMBIG_TERM}} | {{AMBIG_CONFLICTING}} | {{AMBIG_CANONICAL}} | {{AMBIG_REASON}} |
{{/AMBIGUOUS_TERM_ROWS}}

---

## Banned Terms

These terms are prohibited in this project because they are ambiguous, misleading, or overloaded. Use the canonical term instead.

| Banned term | Use instead | Why banned |
|---|---|---|
{{#BANNED_TERM_ROWS}}
| {{BANNED_TERM}} | {{BANNED_USE_INSTEAD}} | {{BANNED_REASON}} |
{{/BANNED_TERM_ROWS}}

---

*To extend this glossary, run `/agentic-ai-engineering:agentic-ubiquitous-language` and reference this file via `glossary_path` in `.agentic/config.yml`.*
