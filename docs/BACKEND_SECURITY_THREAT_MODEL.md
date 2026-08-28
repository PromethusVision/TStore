# Backend Security Threat Model

**State:** PROPOSED — STATIC DESIGN REVIEW, NO OFFENSIVE TESTING

## Priority definitions

- **P0:** cross-tenant/customer compromise, forged purchase/trust/economic fact,
  privileged credential exposure or irreversible broad data loss.
- **P1:** material scoped abuse, integrity loss, privacy exposure or sustained
  availability impact.
- **P2:** limited misuse, enumeration, quality degradation or defense-in-depth gap.

## Threat registry

| Threat | Priority | Required control |
|---|---:|---|
| IDOR on customer profile/cart/chat/purchase | P0 | subject-derived ownership, RLS/RPC tests, non-enumerating errors |
| Profile/JWT role escalation | P0 | database role guard; membership/capability authority |
| Cross-shop listing/QR/customer mutation | P0 | exact-shop scope derived from resource |
| Service-role/server credential in client/log | P0 | server-only secret store, scans, key rotation/incident response |
| Unsafe security-definer/generic admin RPC | P0 | narrow grants, fixed search path, internal authorization |
| QR replay/concurrent double confirmation | P0 | atomic state transition and source-session uniqueness |
| Forged verified purchase/review/reward signal | P0 | server-authoritative source/evidence and idempotency |
| Catalog product merge/split tampering | P0 | case/evidence/revision/impact preview and audited operation |
| Review creation/edit by merchant or unverified user | P0 | RPC-only verified evidence and author checks |
| Operator privilege/break-glass misuse | P0 | capabilities, case scope, fresh auth, append-only audit |
| Storage path spoof/cross-shop overwrite | P1 | entity-derived prefix plus media capability and scan |
| Chat spam/content abuse | P1 | participant checks, size/rate limits, reporting |
| Catalog candidate/ads/reward farming | P1 | rate, provenance, fraud and policy controls |
| Mass public scraping | P1 | bounded projection, pagination/rate/behavior controls |
| User-switch stale data leak | P1 | subscription/request generation reset |
| Error/timing enumeration | P2 | stable client-safe classes and bounded latency/detail |
| Oversized/deep/free-form payload | P2 | schema, size, depth and key allowlist |

Security controls remain layered: authentication, RLS, RPC authorization,
constraints, idempotency, audit, monitoring and safe client behavior. No single
layer, including UI hiding, is sufficient.

