# Merchant App Security Threat Model

Status: **PROPOSED — SECURITY REVIEW REQUIRED**
Wave: 17 / WP59

## Registry

| ID | Priority | Threat | Required boundary |
|---|---|---|---|
| TH-01 | P0 | Fake merchant/onboarding bypass | Verified membership/policy activation |
| TH-02 | P0 | Account takeover | Strong auth/session controls and alerts |
| TH-03 | P0 | Role escalation | Server capability checks; immutable self-role boundary |
| TH-04 | P0 | Cross-organization/shop access | Scoped RLS/authorization on every read/write |
| TH-05 | P0 | QR forgery/replay | Opaque short-lived token, atomic one-time consume |
| TH-06 | P0 | QR wrong-shop/concurrency | Shop binding and exactly-one transaction |
| TH-07 | P0 | Catalog identity tampering | Protected canonical facts and governed review |
| TH-08 | P0 | Price/listing tampering | Revision, authorization, audit, input validation |
| TH-09 | P1 | Staff invitation abuse | Expiring signed invite and owner controls |
| TH-10 | P1 | Customer data leakage | Data minimization and aggregate analytics |
| TH-11 | P1 | Media/policy abuse | Restricted upload, validation and moderation |
| TH-12 | P1 | Review retaliation/manipulation | No merchant edit/delete; reporting governance |
| TH-13 | P1 | Stale/offline authorization | Server-required mutations and cache isolation |
| TH-14 | P2 | Notification/deep-link phishing | Verified routes and minimal lock-screen content |
| TH-15 | P2 | Analytics gaming | Defined eligibility, bot/internal filtering |

Counts: P0 = 8, P1 = 5, P2 = 2.

## Trust boundaries

Mobile client, camera content, local clock/cache, deep link parameters and merchant-entered role/shop IDs are untrusted. Server-side auth, membership, policy, transactional constraints and immutable evidence are authoritative.
