# Backend Cross-Shop Isolation

**State:** PROPOSED HARD SECURITY BOUNDARY

Merchant access is scoped to exact shop IDs granted by active membership. A user
authorized for Shop A cannot read or mutate Shop B private data merely because
both belong to the same organization.

## Covered resources

Listings, QR preview/confirmation, verified purchases, customer conversations,
shop analytics, media writes, staff assignments, campaigns and operational
configuration all carry exact shop scope. Organization roll-ups require a separate
capability and return minimized aggregates, not unrestricted branch rows.

## Enforcement/tests

- derive target shop from authoritative resource, not payload alone;
- check membership organization and explicit shop scope;
- validate new row shop IDs with `WITH CHECK` or RPC equivalent;
- block parent/child ID substitution and nested-resource reassignment;
- test read/create/update/delete, RPC, Realtime and Storage prefix access from a
  sibling shop;
- deny on missing/retired/ambiguous mapping.

Shared-counter/cross-branch operations remain `OWNER_DECISION_REQUIRED` and must
be explicit exceptions, never policy wildcards.

