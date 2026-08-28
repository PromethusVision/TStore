# Minimum Merchant Pilot Master Blueprint

State: `READY FOR OWNER REVIEW — NON-FINAL — NO RUNTIME`

## Executive answer

İlk kontrollü Esenler pilotu tam Merchant App olmadan güvenli biçimde başlayabilir. Non-final öneri Model B'dir: tek-owner/tek-shop ordinary cohort, temel listing truth self-service, exact-shop QR verifier, critical support/notifications ve append-only audit. Model C yalnız sınırlı onboarding/catalog bootstrap fallback'idir; Model A pilot öğrenmesinden sonra kademeli büyür.

## Minimum architecture

```text
Merchant own Auth session
  -> server shop membership/capability + shop/policy lifecycle
  -> shop projection
      -> listing truth: price + availability/unknown + freshness
      -> QR: scan -> server preview -> explicit confirm -> atomic single-use
      -> recent PII-minimized history / support case

Operator assistance
  -> evidence/provenance/candidate/listing draft
  -> merchant attestation or authorized review
  -X-> password/session, direct SQL, QR confirm, verified-history mutation
```

## MUST / SHOULD / DEFER

MUST: merchant auth/logout, exact-shop authority, shop verified/active/policy state, listing read and core truth write, canonical association guard, QR preview/confirm/reconcile/history, critical notification/support, audit, regulated fail-closed, Development RLS/RPC/concurrency and exact-artifact physical acceptance.

SHOULD: simple candidate submission, assisted bootstrap with attestation, read-only reviews/structured evaluation, simple report and action summary.

DEFER: advanced dashboard, multi-staff hierarchy, multi-branch, bulk/media/inventory, review reply/reputation/badges, ads and rewards.

## Customer App dependencies

- Customer cart must create one shop-bound, short-lived session with immutable line snapshot.
- Existing verified-purchase/review rights remain unchanged.
- Customer cannot confirm; merchant exact-shop authority is checked server-side.
- Old Customer App remains compatible through additive N/N-1 backend rollout.
- QR wording remains “alışveriş doğrulaması”, not payment/receipt/revenue.

## Backend dependencies

- Shop-scoped membership/capability or equivalent hardened single-owner predicate.
- Shop verification/suspension/policy projection.
- Revisioned/idempotent listing truth command with freshness and audit.
- Candidate provenance/review state.
- QR functions updated to current capability predicate while preserving atomic one-winner behavior.
- PII-minimized history and append-only correction/case relationship.

## Production dependencies

Owner root decisions, ordinary cohort allowlist, verified fixtures/shops, Development migration tests, signed artifact, two-device physical gate, support/pause owner, monitoring/correlation and explicit Production authorization. None was executed in this wave.

## Pilot operations

Assisted onboarding may prepare shop/listing data, but merchant opens its own account and attests truth. Operator does not impersonate or use direct SQL. Critical failure has case/correlation and pause path. One-person ops is possible with reason/evidence/audit and sample review.

## Pilot learning

Measure onboarding contacts, time-to-first-current-listing, stale/unknown rate, listing conflicts, QR preview/confirm/reconcile distribution, replay/wrong-shop rejects, support volume and critical failures. Do not call views/directions/QR count audited sales or revenue.

## First execution sequence

1. Owner scope/model/cohort/policy decisions.
2. Backend authority/RLS contract.
3. Listing truth/freshness contract.
4. Candidate/assisted workflow.
5. Dedicated merchant shell/auth.
6. Listing self-service.
7. QR verifier/history.
8. Support/notifications/audit.
9. Review read/report and pilot polish.
10. Exact signed artifact + two-device certification.

## Non-final recommendation

Model B, Android-only merchant pilot option, single-owner ordinary shops and staged QR subset are the smallest trustworthy configuration. This is an agent recommendation, not Product Owner approval.
