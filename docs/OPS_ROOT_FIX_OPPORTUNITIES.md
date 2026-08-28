# Operations Root Fix Opportunities

State: PROPOSED FOR OWNER REVIEW — NO IMPLEMENTATION

## Purpose

The stress registry contains repeated symptoms that should be solved once at a root boundary. This document groups those opportunities without choosing runtime architecture, vendors or policy outcomes.

## Root opportunities

| Root | Opportunity | Covers failures | Earliest useful stage | Decision dependency |
|---|---|---|---|---|
| RF-01 | A server-authoritative command gateway checks operator status, capability, tenant, subject, case and action scope | F001, F003, F009, F016 | pilot foundation | role/capability approval |
| RF-02 | A case/evidence/decision spine gives every sensitive action one traceable operational context | F002, F017, F020, F022, F025 | pilot foundation | case schema approval |
| RF-03 | Append-only audit plus superseding correction prevents history rewrite | F002, F007, F013, F019 | pilot foundation | retention and access policy |
| RF-04 | High-risk command envelopes provide preview, reason, exact target, confirmation, idempotency and optional dual review | F003, F004, F008, F010 | before sensitive writes | dual-control action list |
| RF-05 | Versioned policy eligibility remains separate from taxonomy, catalog identity and ad placement | F011, F012, F027, F030 | before regulated commerce | policy owner and legal review |
| RF-06 | Stable catalog identifiers and predecessor/successor relationships preserve references through merge/split/move | F013, F014, F026 | before catalog migration | canonical catalog decisions |
| RF-07 | Identity security lifecycle provides strong operator auth, scoped revocation, session freshness and offboarding | F005, F016, F023 | pilot foundation | MFA/reauth implementation choice |
| RF-08 | Privacy-by-purpose views, structured notes, redaction and export binding minimize PII | F006, F021, F024, F029 | pilot foundation | retention/notification review |
| RF-09 | Dependency-aware merchant enforcement calculates listing, QR, reviews and ads effects with safe restore | F008, F019 | before suspension commands | enforcement ladder approval |
| RF-10 | Event integrity services enforce QR atomicity and future ads/reward deduplication | F004, F015, F019, F028 | capability-specific | ads/reward remain deferred |
| RF-11 | Explainable signal and review contracts separate detection from enforcement | F015, F018, F026, F030 | before automation | threshold/appeal decisions |
| RF-12 | Correlation, health signals, incident linking and scoped kill switches shorten safe containment | F010, F022, F031 | before Production operations | alert and kill-switch ownership |
| RF-13 | Independent appeal and quality sampling catch false positives without enforcement quotas | F017, F018, F030, F032 | pilot process | sample and independence rules |
| RF-14 | Duplicate-case relationships preserve reporters and evidence while reducing queue duplication | F025, F031 | pilot optimization | merge/link presentation choice |

## Recommended sequencing

1. Approve the lean product, role, case, permission and audit contracts.
2. Select P0 high-risk actions and their dual-control/re-auth requirements.
3. Freeze policy ownership, versioning and fail-closed eligibility rules.
4. Design typed server commands; do not expose arbitrary database mutation.
5. Implement privacy-scoped operator views and identity/offboarding controls.
6. Add domain modules incrementally: support, merchant verification, catalog/policy, moderation and QR.
7. Add monitoring, incident response and scoped kill switches before commercial load.
8. Enable ads or rewards only after their owner decisions and event-integrity controls are complete.

## Deliberate non-fixes

- Do not build one universal opaque risk score.
- Do not solve policy uncertainty with taxonomy depth or operator discretion.
- Do not replace missing evidence with higher operator privilege.
- Do not purchase enterprise tooling before measured queue and integration needs exist.
- Do not make irreversible correction or bulk-delete primitives available to routine roles.

All entries are design opportunities. Product Owner selection, implementation authorization and environment-specific acceptance remain open.
