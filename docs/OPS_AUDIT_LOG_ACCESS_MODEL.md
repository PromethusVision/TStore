# Audit Log Access Model

**State:** PROPOSED — NO LOG STORE OR QUERY TOOL

## Access tiers

| Tier | Content | Candidate users |
|---|---|---|
| CASE_TIMELINE | events for assigned case with redaction | assigned operator |
| DOMAIN_AUDIT | authorized subject/domain decisions and changes | specialist reviewer/QA |
| SECURITY_AUDIT | Auth, authorization, session, break-glass, exports | security/privacy incident role |
| SYSTEM_WIDE | cross-domain search/export/integrity | tightly controlled break-glass/auditor |

## Controls

Purpose/case binding, field filtering, time/resource scope, exact query preference, query/access audit, fresh re-auth for broad search/export, result cap, export watermark/encryption/expiry, no local persistence by default, retention, and two-person candidate for broad PII/security export.

Audit events are append-only; ordinary operators cannot delete or modify. The log viewer escapes untrusted content and never exposes tokens/passwords/raw QR/private keys. Reporter identity and raw evidence remain separately protected.

## Monitoring

Alert on unusual broad queries, repeated denied access, mass export, after-hours break-glass, self-case review, and attempts to access unrelated subjects. Alerts avoid revealing the sensitive result.

## Appeals and transparency

Auditors can reconstruct decision version and actor. Customer/merchant communication uses safe derived reasons, not raw audit dump.

`AUDIT_ACCESS_IMPLEMENTED: NO`

`BROAD_AUDIT_DEFAULT: DENIED`
