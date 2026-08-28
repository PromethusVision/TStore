# EsnaftaVar Platform Operations Product Contract

**State:** PROPOSED FOR OWNER REVIEW — DESIGN ONLY

## Purpose

The Operations platform is EsnaftaVar's lean, server-authoritative control plane for support, review, verification, trust and safety, incidents, and operational audit. It turns reports and system signals into traceable cases, evidence-based decisions, reversible actions where possible, and accountable escalation.

It is used by a small set of authorized operators: support, moderation, merchant verification, catalog/policy review, security/incident responders, and a tightly controlled super-admin or break-glass function. Product Owner involvement is reserved for root product/policy decisions, not every routine case.

## Problems it solves

- one case/evidence/history model across customer, merchant, catalog, listing, review, QR, ads, rewards, security, and privacy;
- least-privilege work queues instead of shared database access;
- consistent reasons, appeals, audit, and impact previews;
- fail-closed handling for regulated or ambiguous decisions;
- safe correlation of support reports, system events, and related cases;
- measurable queue health without operator surveillance.

## Deliberate non-goals

It is not:

- a replacement for server-side authorization, RLS/RPC, or policy enforcement;
- arbitrary SQL access or a general database editor;
- a CRM, enterprise SIEM/SOC, legal case-management suite, or omnichannel contact center;
- a tool for silently rewriting verified purchase, review, reputation, catalog, or audit history;
- a mechanism for Product Owner preferences to bypass evidence;
- a store for unnecessary customer PII, passwords, tokens, private messages, or full raw logs;
- runtime implementation, Production access, or permission grant.

## Invariants

Every privileged decision must bind actor, capability, case, reason, evidence, before/after state, policy version, timestamp, and outcome. UI visibility never grants authority. Sensitive unknowns fail closed. Operators see only the minimum fields needed for the assigned purpose. High-risk mutations require preview, explicit confirmation, and a compensating reversal/superseding event rather than history deletion.

The lean pilot may combine roles, but it must not combine unreviewed power with invisible actions. Compensating controls are immutable audit, re-authentication, reason/evidence requirements, retrospective sampling, and a separately protected kill-switch path.

## Research anchors

The design follows least privilege and deny-by-default principles from the [OWASP Authorization Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/Authorization_Cheat_Sheet.html), security logging guidance from the [OWASP Logging Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/Logging_Cheat_Sheet.html), and incident lifecycle framing from [NIST SP 800-61 Rev. 3](https://csrc.nist.gov/pubs/sp/800/61/r3/final). These are architecture references, not Turkish legal advice.

`OPS_PRODUCT_CONTRACT: PROPOSED`

`RUNTIME_IMPLEMENTATION: NO`
