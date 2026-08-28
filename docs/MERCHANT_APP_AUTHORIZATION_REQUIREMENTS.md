# Merchant App Authorization Requirements

Status: **PROPOSED — NO SQL/RLS IMPLEMENTATION**
Wave: 17 / WP60

## Decision function

An operation is permitted only if all required predicates pass:

```text
authenticated
AND active membership
AND organization match
AND shop/branch scope match
AND capability granted
AND shop/entity lifecycle eligible
AND policy eligible
AND resource/revision constraints valid
```

## Requirements

- Reads as well as writes are scoped; existence is not leaked across merchants.
- Owner/manager/staff claims from metadata or UI are not authoritative.
- Staff can never alter own capability, owner status or shop scope.
- QR additionally checks token-bound shop and one-time state.
- Canonical product mutations require separate governed authority, not merchant listing permission.
- Analytics and audit projections apply stricter field-level minimization.
- Service/admin paths are isolated from Flutter client secrets.

## Denial behavior

Stable reason classes (`AUTH`, `PERMISSION`, `POLICY`, `CONFLICT`) with safe correlation; no broad fallback, client-side bypass or silent cross-shop substitution.

RLS, RPC and application service must agree; UI hiding is usability only.
