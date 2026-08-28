# Support Tooling Options

**State:** OPTIONS — NO PURCHASE OR IMPLEMENTATION

| Option | Benefits | Risks/cost | Fit |
|---|---|---|---|
| Minimal internal case console | exact permission/evidence/audit model | build/security/maintenance effort | privileged decisions eventually require it |
| External ticketing | mature email/forms/assignment/search | subscription, vendor processing, integration, permission mismatch | support communication/triage candidate |
| Hybrid | external intake + internal privileged action/case reference | correlation/duplication complexity | likely long-term lean option |
| Shared email/spreadsheet | cheap startup | weak authorization/audit/PII/concurrency | temporary intake only, not high-risk action |
| Manual Supabase dashboard/SQL | immediate | arbitrary access, errors, no workflow/reason/appeal | not acceptable routine operations |

## Required evaluation

Case/identity integration, SSO/MFA, role/field access, audit/export, data residency/vendor terms, retention/deletion, attachment security, API/webhook safety, portability, outage/fallback, accessibility, localization, reporting, cost at real volume, and support.

## Recommendation

Do not purchase enterprise tooling before volume and requirements. Use a minimal structured intake/case register for pilot, but keep all privileged mutations behind future server-authoritative operations. Evaluate external ticketing only for communication/queue convenience; it never becomes the security boundary.

## Exit gate

A tool is acceptable only if least privilege, reporter/PII protection, immutable action linkage, environment separation, export/deletion, and incident response are demonstrable.

`PAID_TOOL_SELECTED: NO`

`TICKETING_EQUALS_AUTHORIZATION: NO`
