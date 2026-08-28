# RPC Contract Test Model

**State:** PROPOSED — NO SQL EXECUTION

## Per-RPC matrix

For every callable function record: exact name/signature, execution role, search path, grants, allowed actors, tenant/shop scope, input bounds, output shape, typed failures, state transition, audit/event effects, idempotency key and retry semantics.

## Required cases

- unauthenticated and wrong-role denial;
- correct role but wrong customer/shop/organization scope;
- missing, malformed, boundary and conflicting input;
- stale/revoked session or membership;
- success with exact row/event effects;
- replay and same-key/different-payload conflict;
- two real concurrent callers where the outcome is protected;
- timeout/unknown outcome followed by authoritative read/retry;
- policy/lifecycle disabled state;
- no raw internal SQL/error detail returned to clients.

## Priority examples

| Domain | Critical invariant |
|---|---|
| Auth/profile | customer cannot assign merchant/admin role |
| Cart | one active shop context and serialized mutation |
| QR | single-use, exact shop, immutable price/product snapshot |
| Review | merchant-confirmed evidence and one active review per customer/product |
| Account delete | caller owns subject and controlled cascade/history policy |
| Future merchant listing | active membership + capability + shop ownership |

## Versioning

Additive functions may coexist during client migration. Signature reuse with changed semantics is prohibited. Removal requires supported-client adoption evidence and observability showing no remaining callers.

`RPC_CONTRACT_MANIFEST: OWNER_DECISION_REQUIRED`
